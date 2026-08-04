#if defined(__APPLE__)
#define _DARWIN_C_SOURCE
#endif
#define _POSIX_C_SOURCE 200809L

#include "send2adf_runtime.h"

#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#if defined(__linux__)
#include <sys/random.h>
#endif

#include "adf_blk.h"
#include "adf_dev.h"
#include "adf_err.h"
#include "adf_file.h"
#include "adf_vol.h"
#include "adflib.h"

#ifndef O_NOFOLLOW
#define O_NOFOLLOW 0
#endif

#ifndef AT_SYMLINK_NOFOLLOW
#define AT_SYMLINK_NOFOLLOW 0
#endif

#define SEND2ADF_MAX_DEPTH 64U
#define SEND2ADF_MAX_ENTRIES 256U
#define SEND2ADF_MAX_TOTAL_BYTES 901120U
#define SEND2ADF_IMAGE_BYTES 901120U
#define SEND2ADF_COPY_BUFFER 4096U
#define SEND2ADF_USABLE_BLOCKS 1740U
#define SEND2ADF_ROOT_PARENT ((size_t)-1)

extern unsigned char kick13BootBlock[];
extern const size_t kick13BootBlockSize;
extern unsigned char kick20BootBlock[];
extern const size_t kick20BootBlockSize;

enum HostEntryKind {
    HOST_ENTRY_FILE,
    HOST_ENTRY_DIRECTORY
};

struct HostEntry {
    char *name;
    enum HostEntryKind kind;
    size_t parent;
    int spool_fd;
    off_t size;
    uint64_t hash;
    char spool_name[32];
};

struct InputIdentity {
    dev_t device;
    ino_t inode;
};

struct Preflight {
    struct HostEntry entries[SEND2ADF_MAX_ENTRIES];
    struct InputIdentity input_identities[SEND2ADF_MAX_ENTRIES];
    size_t count;
    size_t input_identity_count;
    off_t total_bytes;
    int spool_dir_fd;
    char *spool_dir_path;
};

struct ResolvedParent {
    int fd;
    char *name;
};

struct TopInput {
    char *path;
    char *name;
    int parent_fd;
    struct stat status;
};

struct OutputTransaction {
    int parent_fd;
    char *path;
    char *name;
    struct stat parent_status;
    int temp_fd;
    char temp_name[64];
    struct stat temp_status;
    bool temp_owned;
    bool destination_linked;
    bool published;
};

static volatile sig_atomic_t interrupted_signal;
#if defined(SEND2ADF_TEST_HOOKS)
static volatile sig_atomic_t test_resume;
#endif

static void handle_interrupt(int signal_number)
{
    interrupted_signal = signal_number;
}

#if defined(SEND2ADF_TEST_HOOKS)
static void handle_test_resume(int signal_number)
{
    (void)signal_number;
    test_resume = 1;
}
#endif

static bool same_inode(const struct stat *left, const struct stat *right)
{
    return left->st_dev == right->st_dev && left->st_ino == right->st_ino;
}

static bool same_file_state(const struct stat *left, const struct stat *right)
{
#if defined(__APPLE__)
    const bool same_times =
        left->st_mtimespec.tv_sec == right->st_mtimespec.tv_sec &&
        left->st_mtimespec.tv_nsec == right->st_mtimespec.tv_nsec &&
        left->st_ctimespec.tv_sec == right->st_ctimespec.tv_sec &&
        left->st_ctimespec.tv_nsec == right->st_ctimespec.tv_nsec;
#else
    const bool same_times =
        left->st_mtim.tv_sec == right->st_mtim.tv_sec &&
        left->st_mtim.tv_nsec == right->st_mtim.tv_nsec &&
        left->st_ctim.tv_sec == right->st_ctim.tv_sec &&
        left->st_ctim.tv_nsec == right->st_ctim.tv_nsec;
#endif
    return same_inode(left, right) && left->st_mode == right->st_mode &&
           left->st_size == right->st_size && same_times;
}

static void report_errno(const char *operation, const char *path)
{
    fprintf(stderr, "Error: %s '%s': %s\n", operation, path, strerror(errno));
}

static bool valid_component(const char *name, const char *kind)
{
    const size_t length = strlen(name);
    if (length == 0 || length > ADF_MAX_NAME_LEN || strcmp(name, ".") == 0 ||
        strcmp(name, "..") == 0) {
        fprintf(stderr, "Error: invalid %s name '%s' (expected 1-30 ASCII bytes)\n",
                kind, name);
        return false;
    }
    for (size_t index = 0; index < length; ++index) {
        const unsigned char byte = (unsigned char)name[index];
        if (byte < 0x20 || byte > 0x7e || byte == ':' || byte == '/') {
            fprintf(stderr, "Error: invalid %s name '%s' (unsupported byte)\n",
                    kind, name);
            return false;
        }
    }
    return true;
}

static unsigned char fold_ascii(unsigned char byte)
{
    if (byte >= 'A' && byte <= 'Z') {
        return (unsigned char)(byte + ('a' - 'A'));
    }
    return byte;
}

static bool names_collide(const char *left, const char *right)
{
    size_t index = 0;
    while (left[index] != '\0' && right[index] != '\0') {
        if (fold_ascii((unsigned char)left[index]) !=
            fold_ascii((unsigned char)right[index])) {
            return false;
        }
        ++index;
    }
    return left[index] == right[index];
}

static bool path_has_invalid_component(const char *path)
{
    if (path == NULL || path[0] == '\0' || strstr(path, "//") != NULL) {
        return true;
    }
    const size_t length = strlen(path);
    if (length > 1 && path[length - 1] == '/') {
        return true;
    }
    char *copy = strdup(path);
    if (copy == NULL) {
        return true;
    }
    char *cursor = copy;
    if (cursor[0] == '/') {
        ++cursor;
    }
    bool invalid = false;
    char *save = NULL;
    for (char *part = strtok_r(cursor, "/", &save); part != NULL;
         part = strtok_r(NULL, "/", &save)) {
        if (strcmp(part, ".") == 0 || strcmp(part, "..") == 0) {
            invalid = true;
            break;
        }
    }
    free(copy);
    return invalid;
}

static int open_directory_chain(const char *directory, bool absolute)
{
    int current = open(absolute ? "/" : ".", O_RDONLY | O_DIRECTORY | O_CLOEXEC);
    if (current < 0) {
        return -1;
    }
    char *copy = strdup(directory);
    if (copy == NULL) {
        close(current);
        return -1;
    }
    char *cursor = copy;
    if (cursor[0] == '/') {
        ++cursor;
    }
    char *save = NULL;
    for (char *part = strtok_r(cursor, "/", &save); part != NULL;
         part = strtok_r(NULL, "/", &save)) {
        if (strcmp(part, ".") == 0 || strcmp(part, "..") == 0 || part[0] == '\0') {
            errno = EINVAL;
            close(current);
            free(copy);
            return -1;
        }
        const int next = openat(current, part,
                                O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW);
        if (next < 0) {
            close(current);
            free(copy);
            return -1;
        }
        close(current);
        current = next;
    }
    free(copy);
    return current;
}

static bool resolve_parent(const char *path, struct ResolvedParent *resolved)
{
    if (path_has_invalid_component(path)) {
        errno = EINVAL;
        report_errno("invalid path", path == NULL ? "(null)" : path);
        return false;
    }
    char *copy = strdup(path);
    if (copy == NULL) {
        report_errno("allocate path", path);
        return false;
    }
    const bool absolute = copy[0] == '/';
    char *separator = strrchr(copy, '/');
    const char *name_source = copy;
    if (separator != NULL) {
        name_source = separator + 1;
        *separator = '\0';
    }
    char *name = strdup(name_source);
    if (name == NULL) {
        free(copy);
        report_errno("allocate basename", path);
        return false;
    }
    const char *directory = separator == NULL ? "" : copy;
    const int parent = open_directory_chain(directory, absolute);
    free(copy);
    if (parent < 0) {
        report_errno("open path ancestor", path);
        free(name);
        return false;
    }
    resolved->fd = parent;
    resolved->name = name;
    return true;
}

static int compare_strings(const void *left, const void *right)
{
    const char *const *left_name = left;
    const char *const *right_name = right;
    return strcmp(*left_name, *right_name);
}

static int compare_top_inputs(const void *left, const void *right)
{
    const struct TopInput *left_input = left;
    const struct TopInput *right_input = right;
    return strcmp(left_input->name, right_input->name);
}

static bool create_spool(struct Preflight *preflight)
{
    char template_path[] = "/tmp/send2adf-spool.XXXXXX";
    char *created = mkdtemp(template_path);
    if (created == NULL) {
        report_errno("create private spool", template_path);
        return false;
    }
    preflight->spool_dir_path = strdup(created);
    if (preflight->spool_dir_path == NULL) {
        rmdir(created);
        return false;
    }
    if (chmod(created, 0700) != 0) {
        report_errno("secure private spool", created);
        rmdir(created);
        free(preflight->spool_dir_path);
        preflight->spool_dir_path = NULL;
        return false;
    }
    preflight->spool_dir_fd = open(created,
                                    O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW);
    if (preflight->spool_dir_fd < 0) {
        report_errno("open private spool", created);
        rmdir(created);
        free(preflight->spool_dir_path);
        preflight->spool_dir_path = NULL;
        return false;
    }
    return true;
}

static void cleanup_preflight(struct Preflight *preflight)
{
    for (size_t index = 0; index < preflight->count; ++index) {
        struct HostEntry *entry = &preflight->entries[index];
        if (entry->spool_fd >= 0) {
            close(entry->spool_fd);
        }
        if (entry->spool_name[0] != '\0' && preflight->spool_dir_fd >= 0) {
            (void)unlinkat(preflight->spool_dir_fd, entry->spool_name, 0);
        }
        free(entry->name);
    }
    if (preflight->spool_dir_fd >= 0) {
        close(preflight->spool_dir_fd);
    }
    if (preflight->spool_dir_path != NULL) {
        (void)rmdir(preflight->spool_dir_path);
        free(preflight->spool_dir_path);
    }
}

#if defined(SEND2ADF_TEST_HOOKS)
static bool test_pause_at(const char *phase)
{
    const char *requested = getenv("SEND2ADF_TEST_PAUSE_PHASE");
    if (requested == NULL || strcmp(requested, phase) != 0) {
        return true;
    }
    const char *ready_value = getenv("SEND2ADF_TEST_READY_FD");
    if (ready_value == NULL) {
        fprintf(stderr, "Error: SEND2ADF_TEST_READY_FD is required for pause hook\n");
        return false;
    }
    char *end = NULL;
    errno = 0;
    const long parsed = strtol(ready_value, &end, 10);
    if (errno != 0 || end == ready_value || *end != '\0' || parsed < 0 ||
        parsed > INT32_MAX) {
        fprintf(stderr, "Error: invalid test readiness descriptor\n");
        return false;
    }
    test_resume = 0;
    const int ready = (int)parsed;
    if (write(ready, "R", 1) != 1) {
        report_errno("write test readiness descriptor", phase);
        return false;
    }
    while (!test_resume && interrupted_signal == 0) {
        (void)pause();
    }
    return interrupted_signal == 0;
}

static long test_fail_after_bytes(void)
{
    const char *value = getenv("SEND2ADF_TEST_FAIL_AFTER_BYTES");
    if (value == NULL || value[0] == '\0') {
        return -1;
    }
    char *end = NULL;
    errno = 0;
    const long parsed = strtol(value, &end, 10);
    if (errno != 0 || end == value || *end != '\0' || parsed < 0) {
        return 0;
    }
    return parsed;
}
#else
static bool test_pause_at(const char *phase)
{
    (void)phase;
    return true;
}

static long test_fail_after_bytes(void)
{
    return -1;
}
#endif

static bool add_entry(struct Preflight *preflight, const char *name,
                      enum HostEntryKind kind, size_t parent, size_t *entry_index)
{
    if (preflight->count >= SEND2ADF_MAX_ENTRIES) {
        fprintf(stderr, "Error: input entry limit exceeded (%u)\n",
                SEND2ADF_MAX_ENTRIES);
        return false;
    }
    struct HostEntry *entry = &preflight->entries[preflight->count];
    entry->name = strdup(name);
    if (entry->name == NULL) {
        report_errno("allocate input name", name);
        return false;
    }
    entry->kind = kind;
    entry->parent = parent;
    entry->spool_fd = -1;
    entry->size = 0;
    entry->hash = 0;
    entry->spool_name[0] = '\0';
    *entry_index = preflight->count;
    ++preflight->count;
    return true;
}

static bool remember_input_identity(struct Preflight *preflight,
                                    const struct stat *status, const char *name)
{
    for (size_t index = 0; index < preflight->input_identity_count; ++index) {
        const struct InputIdentity *identity = &preflight->input_identities[index];
        if (identity->device == status->st_dev && identity->inode == status->st_ino) {
            fprintf(stderr, "Error: duplicate input inode alias '%s'\n", name);
            return false;
        }
    }
    if (preflight->input_identity_count >= SEND2ADF_MAX_ENTRIES) {
        fprintf(stderr, "Error: input entry limit exceeded (%u)\n", SEND2ADF_MAX_ENTRIES);
        return false;
    }
    struct InputIdentity *identity =
        &preflight->input_identities[preflight->input_identity_count++];
    identity->device = status->st_dev;
    identity->inode = status->st_ino;
    return true;
}

static bool spool_regular_file(struct Preflight *preflight, int parent_fd,
                               const char *name, const struct stat *observed,
                               size_t entry_index)
{
    const int input = openat(parent_fd, name, O_RDONLY | O_CLOEXEC | O_NOFOLLOW);
    if (input < 0) {
        report_errno("open input without following links", name);
        return false;
    }
    struct stat before;
    if (fstat(input, &before) != 0 || !S_ISREG(before.st_mode) ||
        !same_inode(&before, observed)) {
        fprintf(stderr, "Error: input changed before read '%s'\n", name);
        close(input);
        return false;
    }
    if (!remember_input_identity(preflight, &before, name)) {
        close(input);
        return false;
    }
    if (!test_pause_at("after-input-open")) {
        close(input);
        return false;
    }
    struct HostEntry *entry = &preflight->entries[entry_index];
    (void)snprintf(entry->spool_name, sizeof(entry->spool_name), "entry-%06zu", entry_index);
    const int spool = openat(preflight->spool_dir_fd, entry->spool_name,
                             O_WRONLY | O_CREAT | O_EXCL | O_CLOEXEC | O_NOFOLLOW,
                             0600);
    if (spool < 0) {
        report_errno("create sealed spool", entry->spool_name);
        close(input);
        return false;
    }
    unsigned char buffer[SEND2ADF_COPY_BUFFER];
    off_t copied = 0;
    uint64_t hash = UINT64_C(1469598103934665603);
    bool success = true;
    for (;;) {
        const ssize_t bytes_read = read(input, buffer, sizeof(buffer));
        if (bytes_read < 0) {
            report_errno("read input", name);
            success = false;
            break;
        }
        if (bytes_read == 0) {
            break;
        }
        for (ssize_t index = 0; index < bytes_read; ++index) {
            hash ^= buffer[index];
            hash *= UINT64_C(1099511628211);
        }
        ssize_t offset = 0;
        while (offset < bytes_read) {
            const ssize_t written = write(spool, buffer + offset,
                                          (size_t)(bytes_read - offset));
            if (written <= 0) {
                report_errno("write sealed spool", entry->spool_name);
                success = false;
                break;
            }
            offset += written;
        }
        if (!success) {
            break;
        }
        copied += bytes_read;
        if (copied > SEND2ADF_MAX_TOTAL_BYTES ||
            preflight->total_bytes > (off_t)SEND2ADF_MAX_TOTAL_BYTES - copied) {
            fprintf(stderr, "Error: input payload limit exceeded\n");
            success = false;
            break;
        }
        if (interrupted_signal != 0) {
            success = false;
            break;
        }
    }
    struct stat after;
    struct stat path_after;
    if (success && (fstat(input, &after) != 0 ||
                    fstatat(parent_fd, name, &path_after, AT_SYMLINK_NOFOLLOW) != 0 ||
                    !same_file_state(&before, &after) ||
                    !same_file_state(&after, &path_after) || copied != before.st_size)) {
        fprintf(stderr, "Error: input changed while being spooled '%s'\n", name);
        success = false;
    }
    if (success && fsync(spool) != 0) {
        report_errno("flush sealed spool", entry->spool_name);
        success = false;
    }
    close(input);
    close(spool);
    if (!success) {
        return false;
    }
    if (fchmodat(preflight->spool_dir_fd, entry->spool_name, 0400, 0) != 0) {
        report_errno("seal spool read-only", entry->spool_name);
        return false;
    }
    entry->spool_fd = openat(preflight->spool_dir_fd, entry->spool_name,
                              O_RDONLY | O_CLOEXEC | O_NOFOLLOW);
    if (entry->spool_fd < 0) {
        report_errno("open sealed spool", entry->spool_name);
        return false;
    }
    entry->size = copied;
    entry->hash = hash;
    preflight->total_bytes += copied;
    return true;
}

static bool preflight_directory(struct Preflight *preflight, int directory_fd,
                                size_t parent, unsigned int depth);

static bool preflight_child(struct Preflight *preflight, int directory_fd,
                            const char *name, size_t parent, unsigned int depth)
{
    struct stat observed;
    if (fstatat(directory_fd, name, &observed, AT_SYMLINK_NOFOLLOW) != 0) {
        report_errno("inspect input", name);
        return false;
    }
    if (S_ISLNK(observed.st_mode)) {
        fprintf(stderr, "Error: symbolic links are not supported '%s'\n", name);
        return false;
    }
    size_t entry_index;
    if (S_ISDIR(observed.st_mode)) {
        if (!add_entry(preflight, name, HOST_ENTRY_DIRECTORY, parent, &entry_index)) {
            return false;
        }
        const int child = openat(directory_fd, name,
                                 O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW);
        struct stat opened;
        if (child < 0 || fstat(child, &opened) != 0 || !same_inode(&observed, &opened)) {
            report_errno("open input directory", name);
            if (child >= 0) {
                close(child);
            }
            return false;
        }
        const bool result = preflight_directory(preflight, child, entry_index, depth + 1);
        close(child);
        return result;
    }
    if (S_ISREG(observed.st_mode)) {
        if (!add_entry(preflight, name, HOST_ENTRY_FILE, parent, &entry_index)) {
            return false;
        }
        return spool_regular_file(preflight, directory_fd, name, &observed, entry_index);
    }
    fprintf(stderr, "Error: unsupported input type '%s'\n", name);
    return false;
}

static bool preflight_directory(struct Preflight *preflight, int directory_fd,
                                size_t parent, unsigned int depth)
{
    if (depth > SEND2ADF_MAX_DEPTH) {
        fprintf(stderr, "Error: input depth limit exceeded (%u)\n", SEND2ADF_MAX_DEPTH);
        return false;
    }
    const int scan_fd = dup(directory_fd);
    if (scan_fd < 0) {
        report_errno("duplicate directory descriptor", "input");
        return false;
    }
    DIR *directory = fdopendir(scan_fd);
    if (directory == NULL) {
        close(scan_fd);
        report_errno("scan input directory", "input");
        return false;
    }
    char *names[SEND2ADF_MAX_ENTRIES];
    size_t name_count = 0;
    bool success = true;
    errno = 0;
    for (struct dirent *item = readdir(directory); item != NULL; item = readdir(directory)) {
        if (strcmp(item->d_name, ".") == 0 || strcmp(item->d_name, "..") == 0) {
            continue;
        }
        if (name_count >= SEND2ADF_MAX_ENTRIES) {
            fprintf(stderr, "Error: input entry limit exceeded (%u)\n",
                    SEND2ADF_MAX_ENTRIES);
            success = false;
            break;
        }
        if (!valid_component(item->d_name, "input")) {
            success = false;
            break;
        }
        names[name_count] = strdup(item->d_name);
        if (names[name_count] == NULL) {
            success = false;
            break;
        }
        ++name_count;
    }
    if (errno != 0) {
        report_errno("read input directory", "input");
        success = false;
    }
    closedir(directory);
    if (success) {
        qsort(names, name_count, sizeof(names[0]), compare_strings);
        for (size_t left = 0; success && left < name_count; ++left) {
            for (size_t right = left + 1; right < name_count; ++right) {
                if (names_collide(names[left], names[right])) {
                    fprintf(stderr, "Error: case-fold name collision '%s' and '%s'\n",
                            names[left], names[right]);
                    success = false;
                    break;
                }
            }
        }
    }
    for (size_t index = 0; success && index < name_count; ++index) {
        success = preflight_child(preflight, directory_fd, names[index], parent, depth);
    }
    for (size_t index = 0; index < name_count; ++index) {
        free(names[index]);
    }
    return success;
}

static bool directory_contains(int possible_child_fd, const struct stat *ancestor)
{
    int current = dup(possible_child_fd);
    if (current < 0) {
        return false;
    }
    bool contains = false;
    for (unsigned int depth = 0; depth <= SEND2ADF_MAX_DEPTH; ++depth) {
        struct stat current_status;
        if (fstat(current, &current_status) != 0) {
            break;
        }
        if (same_inode(&current_status, ancestor)) {
            contains = true;
            break;
        }
        const int parent = openat(current, "..",
                                  O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW);
        if (parent < 0) {
            break;
        }
        struct stat parent_status;
        const bool at_root = fstat(parent, &parent_status) == 0 &&
                             same_inode(&current_status, &parent_status);
        close(current);
        current = parent;
        if (at_root) {
            break;
        }
    }
    close(current);
    return contains;
}

static void cleanup_top_inputs(struct TopInput *inputs, size_t count)
{
    for (size_t index = 0; index < count; ++index) {
        free(inputs[index].path);
        free(inputs[index].name);
        if (inputs[index].parent_fd >= 0) {
            close(inputs[index].parent_fd);
        }
    }
}

static bool preflight_inputs(struct Preflight *preflight,
                             struct OutputTransaction *transaction,
                             char *const *paths, size_t path_count)
{
    if (path_count > SEND2ADF_MAX_ENTRIES) {
        fprintf(stderr, "Error: input entry limit exceeded (%u)\n",
                SEND2ADF_MAX_ENTRIES);
        return false;
    }
    struct TopInput *inputs = calloc(path_count, sizeof(*inputs));
    if (inputs == NULL) {
        report_errno("allocate input list", "inputs");
        return false;
    }
    for (size_t index = 0; index < path_count; ++index) {
        inputs[index].parent_fd = -1;
    }
    size_t resolved_count = 0;
    bool success = true;
    for (size_t index = 0; index < path_count; ++index) {
        struct ResolvedParent resolved;
        if (!resolve_parent(paths[index], &resolved)) {
            success = false;
            break;
        }
        inputs[index].path = strdup(paths[index]);
        inputs[index].name = resolved.name;
        inputs[index].parent_fd = resolved.fd;
        ++resolved_count;
        if (inputs[index].path == NULL || !valid_component(inputs[index].name, "input") ||
            fstatat(resolved.fd, resolved.name, &inputs[index].status,
                    AT_SYMLINK_NOFOLLOW) != 0) {
            if (errno != 0) {
                report_errno("inspect input", paths[index]);
            }
            success = false;
            break;
        }
        if (S_ISLNK(inputs[index].status.st_mode)) {
            fprintf(stderr, "Error: symbolic links are not supported '%s'\n", paths[index]);
            success = false;
            break;
        }
        if (!S_ISREG(inputs[index].status.st_mode) &&
            !S_ISDIR(inputs[index].status.st_mode)) {
            fprintf(stderr, "Error: unsupported input type '%s'\n", paths[index]);
            success = false;
            break;
        }
        if (S_ISDIR(inputs[index].status.st_mode) &&
            directory_contains(transaction->parent_fd, &inputs[index].status)) {
            fprintf(stderr, "Error: output is contained in input '%s'\n", paths[index]);
            success = false;
            break;
        }
    }
    if (success) {
        qsort(inputs, path_count, sizeof(*inputs), compare_top_inputs);
        for (size_t left = 0; success && left < path_count; ++left) {
            for (size_t right = left + 1; right < path_count; ++right) {
                if (names_collide(inputs[left].name, inputs[right].name)) {
                    fprintf(stderr, "Error: duplicate top-level destination name '%s'\n",
                            inputs[right].name);
                    success = false;
                    break;
                }
            }
        }
    }
    for (size_t index = 0; success && index < path_count; ++index) {
        success = preflight_child(preflight, inputs[index].parent_fd,
                                  inputs[index].name, SEND2ADF_ROOT_PARENT, 0);
    }
    cleanup_top_inputs(inputs, resolved_count);
    free(inputs);
    return success;
}

static bool payload_fits_image(const struct Preflight *preflight)
{
    uint64_t blocks = 8;
    for (size_t index = 0; index < preflight->count; ++index) {
        const struct HostEntry *entry = &preflight->entries[index];
        if (entry->kind == HOST_ENTRY_DIRECTORY) {
            ++blocks;
            continue;
        }
        const uint64_t data_blocks = ((uint64_t)entry->size + 487) / 488;
        blocks += 1 + data_blocks + (data_blocks + 71) / 72;
    }
    if (blocks > SEND2ADF_USABLE_BLOCKS) {
        fprintf(stderr, "Error: input payload cannot fit in an ADF image\n");
        return false;
    }
    return true;
}

static bool open_output_transaction(const char *path,
                                    struct OutputTransaction *transaction)
{
    struct ResolvedParent resolved;
    if (!resolve_parent(path, &resolved)) {
        return false;
    }
    transaction->parent_fd = resolved.fd;
    transaction->name = resolved.name;
    transaction->path = strdup(path);
    transaction->temp_fd = -1;
    if (transaction->path == NULL || fstat(transaction->parent_fd,
                                            &transaction->parent_status) != 0) {
        report_errno("open output parent", path);
        return false;
    }
    struct stat destination;
    if (fstatat(transaction->parent_fd, transaction->name, &destination,
                AT_SYMLINK_NOFOLLOW) == 0) {
        fprintf(stderr, "Error: destination already exists '%s'\n", path);
        errno = EEXIST;
        return false;
    }
    if (errno != ENOENT) {
        report_errno("inspect destination", path);
        return false;
    }
    return true;
}

static bool output_parent_unchanged(const struct OutputTransaction *transaction)
{
    struct ResolvedParent current;
    if (!resolve_parent(transaction->path, &current)) {
        return false;
    }
    struct stat status;
    const bool unchanged = fstat(current.fd, &status) == 0 &&
                           same_inode(&status, &transaction->parent_status);
    close(current.fd);
    free(current.name);
    if (!unchanged) {
        fprintf(stderr, "Error: output parent changed during preflight\n");
    }
    return unchanged;
}

static bool fill_random(void *buffer, size_t size)
{
#if defined(__APPLE__) || defined(__FreeBSD__) || defined(__OpenBSD__)
    arc4random_buf(buffer, size);
    return true;
#elif defined(__linux__)
    return getrandom(buffer, size, 0) == (ssize_t)size;
#else
    (void)buffer;
    (void)size;
    errno = ENOTSUP;
    return false;
#endif
}

static bool create_image_temporary(struct OutputTransaction *transaction)
{
    if (!output_parent_unchanged(transaction)) {
        return false;
    }
    for (unsigned int attempt = 0; attempt < 64; ++attempt) {
        unsigned char random_bytes[12];
        if (!fill_random(random_bytes, sizeof(random_bytes))) {
            report_errno("obtain random temporary name", transaction->path);
            return false;
        }
        char random_hex[25];
        for (size_t index = 0; index < sizeof(random_bytes); ++index) {
            (void)snprintf(random_hex + index * 2, 3, "%02x", random_bytes[index]);
        }
        (void)snprintf(transaction->temp_name, sizeof(transaction->temp_name),
                       ".send2adf-%s.tmp", random_hex);
        transaction->temp_fd = openat(transaction->parent_fd, transaction->temp_name,
                                       O_RDWR | O_CREAT | O_EXCL | O_CLOEXEC |
                                           O_NOFOLLOW,
                                       0600);
        if (transaction->temp_fd >= 0) {
            if (fstat(transaction->temp_fd, &transaction->temp_status) != 0) {
                return false;
            }
            transaction->temp_owned = true;
            const int descriptor_flags = fcntl(transaction->temp_fd, F_GETFD);
            if (descriptor_flags < 0 ||
                fcntl(transaction->temp_fd, F_SETFD,
                      descriptor_flags & ~FD_CLOEXEC) != 0) {
                report_errno("make image descriptor inheritable", transaction->path);
                return false;
            }
            return true;
        }
        if (errno != EEXIST) {
            report_errno("create image temporary", transaction->path);
            return false;
        }
    }
    fprintf(stderr, "Error: could not allocate unique image temporary\n");
    return false;
}

static bool owned_name_matches(const struct OutputTransaction *transaction,
                               const char *name)
{
    struct stat status;
    return fstatat(transaction->parent_fd, name, &status, AT_SYMLINK_NOFOLLOW) == 0 &&
           S_ISREG(status.st_mode) && same_inode(&status, &transaction->temp_status);
}

static void cleanup_transaction(struct OutputTransaction *transaction)
{
    if (!transaction->published && transaction->destination_linked &&
        owned_name_matches(transaction, transaction->name)) {
        (void)unlinkat(transaction->parent_fd, transaction->name, 0);
    }
    if (transaction->temp_owned &&
        owned_name_matches(transaction, transaction->temp_name)) {
        (void)unlinkat(transaction->parent_fd, transaction->temp_name, 0);
    }
    if (transaction->temp_fd >= 0) {
        close(transaction->temp_fd);
    }
    if (transaction->parent_fd >= 0) {
        close(transaction->parent_fd);
    }
    free(transaction->path);
    free(transaction->name);
}

static bool probe_descriptor_path(int descriptor, char *path, size_t path_size,
                                  const struct stat *expected)
{
    (void)snprintf(path, path_size, "/dev/fd/%d", descriptor);
    FILE *created = fopen(path, "wb");
    struct stat status;
    if (created == NULL || fstat(fileno(created), &status) != 0 ||
        !same_inode(&status, expected)) {
        if (created != NULL) {
            fclose(created);
        }
        fprintf(stderr, "Error: dump-driver wb descriptor probe failed\n");
        return false;
    }
    fclose(created);
    FILE *opened = fopen(path, "rb+");
    if (opened == NULL || fstat(fileno(opened), &status) != 0 ||
        !same_inode(&status, expected)) {
        if (opened != NULL) {
            fclose(opened);
        }
        fprintf(stderr, "Error: dump-driver rb+ descriptor probe failed\n");
        return false;
    }
    fclose(opened);
    return true;
}

static bool install_bootblock(struct AdfVolume *volume, const char *bootblock)
{
    if (strcmp(bootblock, "none") == 0) {
        return true;
    }
    const unsigned char *source = kick13BootBlock;
    size_t source_size = kick13BootBlockSize;
    if (strcmp(bootblock, "2.0") == 0) {
        source = kick20BootBlock;
        source_size = kick20BootBlockSize;
    }
    unsigned char full_block[1024] = {0};
    memcpy(full_block, source, source_size);
    return adfVolInstallBootBlock(volume, full_block) == ADF_RC_OK;
}

static bool populate_file(struct AdfVolume *volume, struct HostEntry *entry,
                          off_t *bytes_written, long fail_after)
{
    struct AdfFile *destination = adfFileOpen(volume, entry->name,
                                               ADF_FILE_MODE_WRITE);
    if (destination == NULL) {
        fprintf(stderr, "Error: could not create Amiga file '%s'\n", entry->name);
        return false;
    }
    bool success = lseek(entry->spool_fd, 0, SEEK_SET) == 0;
    unsigned char buffer[SEND2ADF_COPY_BUFFER];
    while (success) {
        const ssize_t read_size = read(entry->spool_fd, buffer, sizeof(buffer));
        if (read_size < 0) {
            report_errno("read sealed spool", entry->name);
            success = false;
            break;
        }
        if (read_size == 0) {
            break;
        }
        if (fail_after >= 0 && *bytes_written + read_size > fail_after) {
            fprintf(stderr, "Error: test-injected image write failure\n");
            success = false;
            break;
        }
        if (adfFileWrite(destination, (uint32_t)read_size, buffer) !=
            (uint32_t)read_size) {
            fprintf(stderr, "Error: disk full while writing '%s'\n", entry->name);
            success = false;
            break;
        }
        *bytes_written += read_size;
        if (interrupted_signal != 0) {
            success = false;
            break;
        }
    }
    adfFileClose(destination);
    return success;
}

static bool populate_children(struct AdfVolume *volume, struct Preflight *preflight,
                              size_t parent, off_t *bytes_written, long fail_after)
{
    for (size_t index = 0; index < preflight->count; ++index) {
        struct HostEntry *entry = &preflight->entries[index];
        if (entry->parent != parent) {
            continue;
        }
        if (entry->kind == HOST_ENTRY_FILE) {
            if (!populate_file(volume, entry, bytes_written, fail_after)) {
                return false;
            }
            continue;
        }
        if (adfCreateDir(volume, volume->curDirPtr, entry->name) != ADF_RC_OK ||
            adfChangeDir(volume, entry->name) != ADF_RC_OK) {
            fprintf(stderr, "Error: could not create Amiga directory '%s'\n", entry->name);
            return false;
        }
        if (!populate_children(volume, preflight, index, bytes_written, fail_after) ||
            adfParentDir(volume) != ADF_RC_OK) {
            return false;
        }
    }
    return true;
}

static bool create_adf(struct OutputTransaction *transaction,
                       struct Preflight *preflight, const char *volume_name,
                       const char *bootblock)
{
    char descriptor_path[64];
    if (!probe_descriptor_path(transaction->temp_fd, descriptor_path,
                               sizeof(descriptor_path), &transaction->temp_status)) {
        return false;
    }
    if (adfLibInit() != ADF_RC_OK) {
        fprintf(stderr, "Error: failed to initialize ADFlib\n");
        return false;
    }
    bool success = false;
    struct AdfDevice *device = adfDevCreate("dump", descriptor_path, 80, 2, 11);
    if (device == NULL) {
        fprintf(stderr, "Error: failed to create ADF device\n");
        goto library_cleanup;
    }
    const int dos_type = strcmp(bootblock, "2.0") == 0 ? ADF_DOSFS_FFS : ADF_DOSFS_OFS;
    if (adfCreateFlop(device, volume_name, dos_type) != ADF_RC_OK) {
        fprintf(stderr, "Error: failed to format ADF device\n");
        goto device_cleanup;
    }
    struct AdfVolume *volume = adfVolMount(device, 0, ADF_ACCESS_MODE_READWRITE);
    if (volume == NULL) {
        fprintf(stderr, "Error: failed to mount formatted ADF volume\n");
        goto device_cleanup;
    }
    if (!install_bootblock(volume, bootblock)) {
        fprintf(stderr, "Error: failed to install bootblock\n");
        goto volume_cleanup;
    }
    unsigned char boot_sector[512];
    const unsigned char expected_dos = strcmp(bootblock, "2.0") == 0 ? 1 : 0;
    if (adfDevReadBlock(device, 0, sizeof(boot_sector), boot_sector) != ADF_RC_OK ||
        memcmp(boot_sector, "DOS", 3) != 0 || boot_sector[3] != expected_dos) {
        fprintf(stderr, "Error: formatted filesystem DOS identifier mismatch\n");
        goto volume_cleanup;
    }
    off_t bytes_written = 0;
    if (!populate_children(volume, preflight, SEND2ADF_ROOT_PARENT, &bytes_written,
                           test_fail_after_bytes())) {
        goto volume_cleanup;
    }
    success = interrupted_signal == 0;

volume_cleanup:
    adfVolUnMount(volume);
device_cleanup:
    adfDevClose(device);
library_cleanup:
    adfLibCleanUp();
    if (success && fsync(transaction->temp_fd) != 0) {
        report_errno("flush completed image", transaction->path);
        success = false;
    }
    struct stat final_status;
    if (success && (fstat(transaction->temp_fd, &final_status) != 0 ||
                    final_status.st_size != SEND2ADF_IMAGE_BYTES)) {
        fprintf(stderr, "Error: completed image has unexpected size\n");
        success = false;
    }
    return success;
}

static bool validate_owned_temporary(struct OutputTransaction *transaction)
{
    struct stat descriptor_status;
    struct stat name_status;
    if (fstat(transaction->temp_fd, &descriptor_status) != 0 ||
        fstatat(transaction->parent_fd, transaction->temp_name, &name_status,
                AT_SYMLINK_NOFOLLOW) != 0 ||
        !same_inode(&descriptor_status, &name_status) ||
        !same_inode(&descriptor_status, &transaction->temp_status) ||
        !S_ISREG(name_status.st_mode) || name_status.st_nlink != 1 ||
        name_status.st_uid != geteuid() || (name_status.st_mode & 0777) != 0600) {
        fprintf(stderr, "Error: image temporary ownership changed\n");
        return false;
    }
    return true;
}

static bool publish_image(struct OutputTransaction *transaction)
{
    if (!output_parent_unchanged(transaction) ||
        !validate_owned_temporary(transaction)) {
        return false;
    }
    if (linkat(transaction->parent_fd, transaction->temp_name,
               transaction->parent_fd, transaction->name, 0) != 0) {
        report_errno("publish without replacing destination", transaction->path);
        return false;
    }
    transaction->destination_linked = true;
    if (!owned_name_matches(transaction, transaction->name) ||
        !test_pause_at("after-destination-link") || interrupted_signal != 0) {
        return false;
    }
    if (unlinkat(transaction->parent_fd, transaction->temp_name, 0) != 0) {
        report_errno("remove published temporary link", transaction->path);
        return false;
    }
    transaction->temp_owned = false;
    if (interrupted_signal != 0) {
        return false;
    }
    transaction->published = true;
    return true;
}

static bool install_signal_handlers(void)
{
    struct sigaction action;
    memset(&action, 0, sizeof(action));
    action.sa_handler = handle_interrupt;
    sigemptyset(&action.sa_mask);
    if (sigaction(SIGINT, &action, NULL) != 0 ||
        sigaction(SIGTERM, &action, NULL) != 0) {
        return false;
    }
#if defined(SEND2ADF_TEST_HOOKS)
    action.sa_handler = handle_test_resume;
    if (sigaction(SIGUSR1, &action, NULL) != 0) {
        return false;
    }
#endif
    return true;
}

int send2adf_create_image(const char *output_path, const char *volume_name,
                          const char *bootblock, char *const *input_paths,
                          size_t input_count)
{
    if (!valid_component(volume_name, "volume")) {
        return EXIT_FAILURE;
    }
    if (strcmp(bootblock, "none") != 0 && strcmp(bootblock, "1.3") != 0 &&
        strcmp(bootblock, "2.0") != 0) {
        fprintf(stderr, "Error: invalid bootblock type '%s'\n", bootblock);
        return EXIT_FAILURE;
    }
    interrupted_signal = 0;
    if (!install_signal_handlers()) {
        report_errno("install signal handlers", "send2adf");
        return EXIT_FAILURE;
    }
    struct OutputTransaction transaction;
    memset(&transaction, 0, sizeof(transaction));
    transaction.parent_fd = -1;
    transaction.temp_fd = -1;
    struct Preflight preflight;
    memset(&preflight, 0, sizeof(preflight));
    preflight.spool_dir_fd = -1;
    bool success = open_output_transaction(output_path, &transaction) &&
                   create_spool(&preflight) &&
                   preflight_inputs(&preflight, &transaction, input_paths, input_count) &&
                   payload_fits_image(&preflight) &&
                   test_pause_at("after-preflight") && interrupted_signal == 0 &&
                   create_image_temporary(&transaction) &&
                   test_pause_at("after-temp") && interrupted_signal == 0 &&
                   create_adf(&transaction, &preflight, volume_name, bootblock) &&
                   validate_owned_temporary(&transaction) &&
                   publish_image(&transaction);
    if (!success && interrupted_signal != 0) {
        fprintf(stderr, "Error: interrupted by signal %d\n", (int)interrupted_signal);
    }
    cleanup_preflight(&preflight);
    cleanup_transaction(&transaction);
    if (!success) {
        return EXIT_FAILURE;
    }
    printf("ADF file '%s' created successfully.\n", output_path);
    return EXIT_SUCCESS;
}
