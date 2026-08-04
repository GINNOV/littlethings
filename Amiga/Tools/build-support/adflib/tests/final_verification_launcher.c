#define _DARWIN_C_SOURCE
#define _GNU_SOURCE

#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/resource.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#if defined(__APPLE__)
#include <CommonCrypto/CommonDigest.h>
#include <CoreFoundation/CoreFoundation.h>
#include <Security/Security.h>
#include <sys/ptrace.h>
#else
#include <openssl/sha.h>
#include <sys/prctl.h>
#endif

#ifndef FINAL_VERIFY_PYTHON
#define FINAL_VERIFY_PYTHON "/usr/bin/python3"
#endif
#ifndef FINAL_VERIFY_PYTHON_SHA256
#define FINAL_VERIFY_PYTHON_SHA256 "0000000000000000000000000000000000000000000000000000000000000000"
#endif
#ifndef FINAL_VERIFY_TEST_REBIND_READY_FD
#define FINAL_VERIFY_TEST_REBIND_READY_FD -1
#endif
#ifndef FINAL_VERIFY_TEST_REBIND_RELEASE_FD
#define FINAL_VERIFY_TEST_REBIND_RELEASE_FD -1
#endif

extern char **environ;
static volatile sig_atomic_t supervisor_child = 0;

static void forward_signal(int signal_number) {
    pid_t child = (pid_t)supervisor_child;
    if (child > 0) kill(child, signal_number);
}

static int install_signal_forwarding(void) {
    struct sigaction action;
    memset(&action, 0, sizeof(action));
    action.sa_handler = forward_signal;
    if (sigemptyset(&action.sa_mask) != 0) return -1;
    if (sigaction(SIGINT, &action, NULL) != 0) return -1;
    if (sigaction(SIGTERM, &action, NULL) != 0) return -1;
    if (sigaction(SIGHUP, &action, NULL) != 0) return -1;
    return 0;
}

static int fail(const char *code) {
    dprintf(STDERR_FILENO, "%s\n", code);
    return 2;
}

static int apply_process_protection(void) {
    struct rlimit limit = {0, 0};
    if (setrlimit(RLIMIT_CORE, &limit) != 0) return -1;
#if defined(__APPLE__)
    if (ptrace(PT_DENY_ATTACH, 0, NULL, 0) != 0) return -1;
#else
    if (prctl(PR_SET_DUMPABLE, 0, 0, 0, 0) != 0) return -1;
#endif
    return 0;
}

static int valid_directory(const struct stat *metadata) {
    if (!S_ISDIR(metadata->st_mode)) return 0;
#if !defined(FINAL_VERIFY_TEST_BUILD)
    if (metadata->st_uid != 0 || (metadata->st_mode & 0022) != 0) return 0;
#endif
    return 1;
}

static int open_verified(const char *path, struct stat *identity) {
    if (path == NULL || path[0] != '/') return -1;
    char *copy = strdup(path + 1);
    if (copy == NULL) return -1;
    int directory = open("/", O_RDONLY | O_DIRECTORY | O_CLOEXEC);
    if (directory < 0) {
        free(copy);
        return -1;
    }
    char *save = NULL;
    char *component = strtok_r(copy, "/", &save);
    if (component == NULL) {
        close(directory);
        free(copy);
        return -1;
    }
    for (;;) {
        char *next = strtok_r(NULL, "/", &save);
        if (next == NULL) {
            int result = openat(directory, component, O_RDONLY | O_NONBLOCK | O_NOFOLLOW | O_CLOEXEC);
            close(directory);
            free(copy);
            if (result < 0 || fstat(result, identity) != 0 || !S_ISREG(identity->st_mode)) {
                if (result >= 0) close(result);
                return -1;
            }
#if !defined(FINAL_VERIFY_TEST_BUILD)
            if (identity->st_uid != 0 || (identity->st_mode & 0222) != 0) {
                close(result);
                return -1;
            }
#endif
            return result;
        }
        int following = openat(directory, component, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC);
        struct stat metadata;
        if (following < 0 || fstat(following, &metadata) != 0 || !valid_directory(&metadata)) {
            if (following >= 0) close(following);
            close(directory);
            free(copy);
            return -1;
        }
        close(directory);
        directory = following;
        component = next;
    }
}

static int decode_expected(const char *text, unsigned char output[32]) {
    if (text == NULL || strlen(text) != 64) return -1;
    for (size_t index = 0; index < 32; index++) {
        char pair[3] = {text[index * 2], text[index * 2 + 1], 0};
        char *end = NULL;
        unsigned long value = strtoul(pair, &end, 16);
        if (end == NULL || *end != 0 || value > 255) return -1;
        output[index] = (unsigned char)value;
    }
    return 0;
}

static int hash_fd(int descriptor, unsigned char output[32]) {
#if defined(__APPLE__)
    CC_SHA256_CTX context;
#else
    SHA256_CTX context;
#endif
    unsigned char buffer[131072];
#if defined(__APPLE__)
    if (CC_SHA256_Init(&context) != 1 || lseek(descriptor, 0, SEEK_SET) < 0) return -1;
#else
    if (SHA256_Init(&context) != 1 || lseek(descriptor, 0, SEEK_SET) < 0) return -1;
#endif
    for (;;) {
        ssize_t count = read(descriptor, buffer, sizeof(buffer));
        if (count < 0) return -1;
        if (count == 0) break;
#if defined(__APPLE__)
        if (CC_SHA256_Update(&context, buffer, (CC_LONG)count) != 1) return -1;
#else
        if (SHA256_Update(&context, buffer, (size_t)count) != 1) return -1;
#endif
    }
#if defined(__APPLE__)
    if (CC_SHA256_Final(output, &context) != 1 || lseek(descriptor, 0, SEEK_SET) < 0) return -1;
#else
    if (SHA256_Final(output, &context) != 1 || lseek(descriptor, 0, SEEK_SET) < 0) return -1;
#endif
    return 0;
}

static const char *argument_value(char *const arguments[], const char *name) {
    for (size_t index = 0; arguments[index] != NULL; index++) {
        if (strcmp(arguments[index], name) == 0 && arguments[index + 1] != NULL) return arguments[index + 1];
    }
    return NULL;
}

static int open_coordinator_log(char *const lifecycle[], int *retained_parent) {
    const char *evidence = argument_value(lifecycle, "--evidence-dir");
    if (evidence == NULL || evidence[0] != '/') return -1;
    int parent = open(evidence, O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC);
    if (parent < 0) return -1;
    struct stat before;
    if (fstat(parent, &before) != 0 || !S_ISDIR(before.st_mode) || before.st_uid != getuid() || (before.st_mode & 0077) != 0) {
        close(parent);
        return -1;
    }
    int log = openat(parent, "coordinator.log", O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC, 0600);
    struct stat after;
    int unchanged = fstat(parent, &after) == 0 && before.st_dev == after.st_dev && before.st_ino == after.st_ino;
    if (log < 0 || !unchanged) {
        if (log >= 0) close(log);
        close(parent);
        return -1;
    }
    *retained_parent = parent;
    return log;
}

static int bootstrap_receipt_exists(int evidence_parent) {
    struct stat metadata;
    if (fstatat(evidence_parent, "bootstrap.json", &metadata, AT_SYMLINK_NOFOLLOW) != 0) return 0;
    return S_ISREG(metadata.st_mode) && metadata.st_uid == getuid() && (metadata.st_mode & 0777) == 0600;
}

static int execute_supervisor(int descriptor, char *const lifecycle[]) {
    if (fcntl(descriptor, F_SETFD, 0) != 0) return fail("supervisor_fd_inheritance_failed");
    struct stat python_identity;
    int python = open_verified(FINAL_VERIFY_PYTHON, &python_identity);
    unsigned char expected_python[32];
    unsigned char observed_python[32];
    if (python < 0 || decode_expected(FINAL_VERIFY_PYTHON_SHA256, expected_python) != 0 ||
        hash_fd(python, observed_python) != 0 || memcmp(expected_python, observed_python, 32) != 0) {
        if (python >= 0) close(python);
        return fail("python_install_untrusted");
    }
    struct stat python_after;
    if (fstat(python, &python_after) != 0 || python_identity.st_dev != python_after.st_dev ||
        python_identity.st_ino != python_after.st_ino || python_identity.st_size != python_after.st_size ||
        fcntl(python, F_SETFD, 0) != 0) {
        close(python);
        return fail("python_identity_changed");
    }
    char script[64];
    if (snprintf(script, sizeof(script), "/dev/fd/%d", descriptor) >= (int)sizeof(script)) return fail("supervisor_fd_path_failed");
    size_t count = 0;
    while (lifecycle[count] != NULL) count++;
    char **child = calloc(count + 3, sizeof(char *));
    if (child == NULL) return fail("argv_allocation_failed");
    child[0] = (char *)FINAL_VERIFY_PYTHON;
    child[1] = script;
    for (size_t index = 0; index < count; index++) child[index + 2] = lifecycle[index];
    child[count + 2] = NULL;
    char *empty_environment[] = {NULL};
    environ = empty_environment;
    setenv("LANG", "C", 1);
    setenv("LC_ALL", "C", 1);
#if defined(__APPLE__)
#if defined(FINAL_VERIFY_TEST_BUILD)
    if (FINAL_VERIFY_TEST_REBIND_READY_FD >= 0 && FINAL_VERIFY_TEST_REBIND_RELEASE_FD >= 0) {
        char barrier = 'R';
        if (write(FINAL_VERIFY_TEST_REBIND_READY_FD, &barrier, 1) != 1 ||
            read(FINAL_VERIFY_TEST_REBIND_RELEASE_FD, &barrier, 1) != 1) {
            close(python);
            return fail("python_rebind_barrier_failed");
        }
    }
#endif
    struct stat rebound_identity;
    int rebound = open_verified(FINAL_VERIFY_PYTHON, &rebound_identity);
    unsigned char rebound_digest[32];
    if (rebound < 0 || hash_fd(rebound, rebound_digest) != 0 || memcmp(expected_python, rebound_digest, 32) != 0 ||
        python_identity.st_dev != rebound_identity.st_dev || python_identity.st_ino != rebound_identity.st_ino ||
        python_identity.st_gen != rebound_identity.st_gen || python_identity.st_size != rebound_identity.st_size ||
        python_identity.st_mode != rebound_identity.st_mode ||
        python_identity.st_mtimespec.tv_sec != rebound_identity.st_mtimespec.tv_sec ||
        python_identity.st_mtimespec.tv_nsec != rebound_identity.st_mtimespec.tv_nsec) {
        if (rebound >= 0) close(rebound);
        close(python);
        return fail("python_rebind_failed");
    }
    close(rebound);
    CFStringRef path_string = CFStringCreateWithCString(NULL, FINAL_VERIFY_PYTHON, kCFStringEncodingUTF8);
    CFURLRef path_url = path_string == NULL ? NULL : CFURLCreateWithFileSystemPath(NULL, path_string, kCFURLPOSIXPathStyle, false);
    SecStaticCodeRef static_code = NULL;
    OSStatus code_status = path_url == NULL ? errSecParam : SecStaticCodeCreateWithPath(path_url, kSecCSDefaultFlags, &static_code);
    if (code_status == errSecSuccess) code_status = SecStaticCodeCheckValidity(static_code, kSecCSStrictValidate, NULL);
    if (static_code != NULL) CFRelease(static_code);
    if (path_url != NULL) CFRelease(path_url);
    if (path_string != NULL) CFRelease(path_string);
    if (code_status != errSecSuccess) {
        close(python);
        return fail("python_code_signature_invalid");
    }
    execve(FINAL_VERIFY_PYTHON, child, environ);
#else
    fexecve(python, child, environ);
#endif
    close(python);
    free(child);
    return fail("supervisor_exec_failed");
}

int main(int argc, char **argv) {
    if (apply_process_protection() != 0) return fail("process_protection_failed");
    if (argc < 7 || strcmp(argv[1], "--supervisor") != 0 || strcmp(argv[3], "--expected-sha256") != 0 || strcmp(argv[5], "--") != 0) {
        return fail("launcher_interface_invalid");
    }
    struct stat identity;
    int supervisor = open_verified(argv[2], &identity);
    if (supervisor < 0) return fail("supervisor_install_untrusted");
    unsigned char expected[32];
    unsigned char observed[32];
    if (decode_expected(argv[4], expected) != 0 || hash_fd(supervisor, observed) != 0 || memcmp(expected, observed, 32) != 0) {
        close(supervisor);
        return fail("supervisor_digest_mismatch");
    }
    struct stat after;
    if (fstat(supervisor, &after) != 0 || identity.st_dev != after.st_dev || identity.st_ino != after.st_ino || identity.st_size != after.st_size) {
        close(supervisor);
        return fail("supervisor_identity_changed");
    }
    if (strcmp(argv[6], "start") != 0) return execute_supervisor(supervisor, &argv[6]);
    if (install_signal_forwarding() != 0) {
        close(supervisor);
        return fail("signal_forwarding_failed");
    }
    sigset_t blocked_signals;
    sigset_t previous_signals;
    if (sigemptyset(&blocked_signals) != 0 || sigaddset(&blocked_signals, SIGINT) != 0 ||
        sigaddset(&blocked_signals, SIGTERM) != 0 || sigaddset(&blocked_signals, SIGHUP) != 0 ||
        sigprocmask(SIG_BLOCK, &blocked_signals, &previous_signals) != 0) {
        close(supervisor);
        return fail("signal_mask_failed");
    }
    int evidence_parent = -1;
    int log = open_coordinator_log(&argv[6], &evidence_parent);
    if (log < 0) {
        sigprocmask(SIG_SETMASK, &previous_signals, NULL);
        close(supervisor);
        return fail("coordinator_log_create_failed");
    }
    pid_t child = fork();
    if (child < 0) {
        sigprocmask(SIG_SETMASK, &previous_signals, NULL);
        close(log);
        close(evidence_parent);
        close(supervisor);
        return fail("supervisor_fork_failed");
    }
    if (child == 0) {
        if (sigprocmask(SIG_SETMASK, &previous_signals, NULL) != 0) _exit(126);
        close(evidence_parent);
        if (dup2(log, STDOUT_FILENO) < 0 || dup2(log, STDERR_FILENO) < 0) _exit(126);
        close(log);
        _exit(execute_supervisor(supervisor, &argv[6]));
    }
    supervisor_child = child;
    if (sigprocmask(SIG_SETMASK, &previous_signals, NULL) != 0) {
        kill(child, SIGKILL);
        waitpid(child, NULL, 0);
        close(log);
        close(evidence_parent);
        close(supervisor);
        return fail("signal_unmask_failed");
    }
    close(log);
    close(supervisor);
    int status = 0;
    pid_t waited;
    do {
        waited = waitpid(child, &status, 0);
    } while (waited < 0 && errno == EINTR);
    supervisor_child = 0;
    if (waited != child) {
        close(evidence_parent);
        return fail("supervisor_wait_failed");
    }
    int receipt_exists = bootstrap_receipt_exists(evidence_parent);
    close(evidence_parent);
    if (!receipt_exists || !WIFEXITED(status)) return fail("supervisor_terminated_before_receipt");
    return WEXITSTATUS(status);
}
