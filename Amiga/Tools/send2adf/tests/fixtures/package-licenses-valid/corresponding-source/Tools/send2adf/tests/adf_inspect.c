#include <errno.h>
#include <inttypes.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#include "adflib.h"
#include "adf_blk.h"
#include "adf_dev.h"
#include "adf_dir.h"
#include "adf_file.h"
#include "adf_str.h"
#include "adf_vol.h"

#define ADF_IMAGE_SIZE 901120U
#define BOOTBLOCK_SIZE 1024U

struct ExpectedFile {
    char *path;
    char *host;
};

struct Options {
    const char *image;
    const char *volume;
    const char *bootblock;
    int dos_type;
    char **directories;
    size_t directory_count;
    struct ExpectedFile *files;
    size_t file_count;
};

struct Paths {
    char **items;
    size_t count;
};

static const uint8_t installed_boot_code[] = {
    0x43, 0xfa, 0x00, 0x18, 0x4e, 0xae, 0xff, 0xa0, 0x4a, 0x80,
    0x67, 0x0a, 0x20, 0x40, 0x20, 0x68, 0x00, 0x16, 0x70, 0x00,
    0x4e, 0x75, 0x70, 0xff, 0x60, 0xfa, 0x64, 0x6f, 0x73, 0x2e,
    0x6c, 0x69, 0x62, 0x72, 0x61, 0x72, 0x79, 0x00
};

static void usage(FILE *stream) {
    fputs("Usage: adf_inspect --image IMAGE --volume NAME --dos-type 0|1 "
          "--bootblock none|1.3|2.0 [--expect-dir PATH] "
          "[--expect-file PATH=HOST]...\n", stream);
}

static bool append_string(char ***items, size_t *count, const char *value) {
    char **resized = realloc(*items, (*count + 1U) * sizeof(**items));
    if (resized == NULL) {
        return false;
    }
    resized[*count] = strdup(value);
    if (resized[*count] == NULL) {
        *items = resized;
        return false;
    }
    *items = resized;
    ++*count;
    return true;
}

static bool append_expected_file(struct Options *options, const char *spec) {
    const char *separator = strchr(spec, '=');
    if (separator == NULL || separator == spec || separator[1] == '\0') {
        return false;
    }
    struct ExpectedFile *resized = realloc(
        options->files, (options->file_count + 1U) * sizeof(*options->files));
    if (resized == NULL) {
        return false;
    }
    options->files = resized;
    struct ExpectedFile *file = &options->files[options->file_count];
    const size_t path_length = (size_t)(separator - spec);
    file->path = malloc(path_length + 1U);
    file->host = strdup(separator + 1);
    if (file->path == NULL || file->host == NULL) {
        free(file->path);
        free(file->host);
        return false;
    }
    memcpy(file->path, spec, path_length);
    file->path[path_length] = '\0';
    ++options->file_count;
    return true;
}

static bool parse_dos_type(const char *value, int *dos_type) {
    if (strcmp(value, "0") == 0) {
        *dos_type = 0;
        return true;
    }
    if (strcmp(value, "1") == 0) {
        *dos_type = 1;
        return true;
    }
    return false;
}

static bool parse_options(int argc, char **argv, struct Options *options) {
    memset(options, 0, sizeof(*options));
    options->dos_type = -1;
    for (int index = 1; index < argc; ++index) {
        if (strcmp(argv[index], "--help") == 0) {
            usage(stdout);
            exit(EXIT_SUCCESS);
        }
        if (index + 1 >= argc) {
            return false;
        }
        const char *value = argv[++index];
        if (strcmp(argv[index - 1], "--image") == 0) {
            options->image = value;
        } else if (strcmp(argv[index - 1], "--volume") == 0) {
            options->volume = value;
        } else if (strcmp(argv[index - 1], "--dos-type") == 0) {
            if (!parse_dos_type(value, &options->dos_type)) {
                return false;
            }
        } else if (strcmp(argv[index - 1], "--bootblock") == 0) {
            options->bootblock = value;
        } else if (strcmp(argv[index - 1], "--expect-dir") == 0) {
            if (!append_string(&options->directories, &options->directory_count, value)) {
                return false;
            }
        } else if (strcmp(argv[index - 1], "--expect-file") == 0) {
            if (!append_expected_file(options, value)) {
                return false;
            }
        } else {
            return false;
        }
    }
    return options->image != NULL && options->volume != NULL &&
           options->bootblock != NULL && options->dos_type >= 0;
}

static void free_options(struct Options *options) {
    for (size_t index = 0; index < options->directory_count; ++index) {
        free(options->directories[index]);
    }
    for (size_t index = 0; index < options->file_count; ++index) {
        free(options->files[index].path);
        free(options->files[index].host);
    }
    free(options->directories);
    free(options->files);
}

static const struct ExpectedFile *find_expected_file(
    const struct Options *options, const char *path) {
    for (size_t index = 0; index < options->file_count; ++index) {
        if (strcmp(options->files[index].path, path) == 0) {
            return &options->files[index];
        }
    }
    return NULL;
}

static bool expects_directory(const struct Options *options, const char *path) {
    for (size_t index = 0; index < options->directory_count; ++index) {
        if (strcmp(options->directories[index], path) == 0) {
            return true;
        }
    }
    return false;
}

static bool append_path(struct Paths *paths, const char *path) {
    return append_string(&paths->items, &paths->count, path);
}

static uint64_t digest_byte(uint64_t digest, uint8_t value) {
    return (digest ^ value) * UINT64_C(1099511628211);
}

static bool compare_file(struct AdfVolume *volume, const char *name,
                         const char *path, const struct ExpectedFile *expected) {
    struct AdfFile *adf_file = adfFileOpen(volume, name, ADF_FILE_MODE_READ);
    FILE *host_file = fopen(expected->host, "rb");
    if (adf_file == NULL || host_file == NULL) {
        fprintf(stderr, "content_digest_mismatch path=%s field=open_or_checksum\n", path);
        if (adf_file != NULL) {
            adfFileClose(adf_file);
        }
        if (host_file != NULL) {
            fclose(host_file);
        }
        return false;
    }
    uint64_t digest = UINT64_C(14695981039346656037);
    uint64_t length = 0;
    bool matches = true;
    while (!adfFileAtEOF(adf_file)) {
        uint8_t adf_buffer[4096];
        uint8_t host_buffer[4096];
        const uint32_t adf_count = adfFileRead(adf_file, sizeof(adf_buffer), adf_buffer);
        if (adf_count == 0U && !adfFileAtEOF(adf_file)) {
            matches = false;
            break;
        }
        const size_t host_count = fread(host_buffer, 1, adf_count, host_file);
        if (host_count != adf_count || memcmp(adf_buffer, host_buffer, adf_count) != 0) {
            matches = false;
            break;
        }
        for (uint32_t index = 0; index < adf_count; ++index) {
            digest = digest_byte(digest, adf_buffer[index]);
        }
        length += adf_count;
    }
    if (matches && fgetc(host_file) != EOF) {
        matches = false;
    }
    if (ferror(host_file)) {
        matches = false;
    }
    adfFileClose(adf_file);
    fclose(host_file);
    if (!matches) {
        fprintf(stderr, "content_digest_mismatch path=%s\n", path);
        return false;
    }
    printf("file path=%s length=%" PRIu64 " digest=fnv1a64:%016" PRIx64 "\n",
           path, length, digest);
    return true;
}

static char *join_path(const char *parent, const char *name) {
    const size_t parent_length = strlen(parent);
    const size_t name_length = strlen(name);
    const size_t separator = parent_length == 0U ? 0U : 1U;
    char *path = malloc(parent_length + separator + name_length + 1U);
    if (path == NULL) {
        return NULL;
    }
    memcpy(path, parent, parent_length);
    if (separator != 0U) {
        path[parent_length] = '/';
    }
    memcpy(path + parent_length + separator, name, name_length + 1U);
    return path;
}

static bool inspect_directory(struct AdfVolume *volume, const char *parent,
                              const struct Options *options, struct Paths *paths) {
    struct AdfList *list = adfGetDirEnt(volume, volume->curDirPtr);
    bool success = true;
    for (struct AdfList *node = list; node != NULL; node = node->next) {
        const struct AdfEntry *entry = node->content;
        char *path = join_path(parent, entry->name);
        if (path == NULL || !append_path(paths, path == NULL ? "" : path)) {
            free(path);
            success = false;
            break;
        }
        if (entry->type == ADF_ST_DIR) {
            printf("directory path=%s\n", path);
            if (!expects_directory(options, path)) {
                fprintf(stderr, "unexpected_directory path=%s\n", path);
                success = false;
            } else if (adfChangeDir(volume, entry->name) != ADF_RC_OK ||
                !inspect_directory(volume, path, options, paths) ||
                adfParentDir(volume) != ADF_RC_OK) {
                success = false;
            }
        } else if (entry->type == ADF_ST_FILE) {
            const struct ExpectedFile *expected = find_expected_file(options, path);
            if (expected == NULL) {
                fprintf(stderr, "unexpected_file path=%s\n", path);
                success = false;
            } else if (!compare_file(volume, entry->name, path, expected)) {
                success = false;
            }
        } else {
            fprintf(stderr, "unsupported_adf_entry path=%s type=%d\n", path, entry->type);
            success = false;
        }
        free(path);
        if (!success) {
            break;
        }
    }
    adfFreeDirList(list);
    return success;
}

static int compare_strings(const void *left, const void *right) {
    const char *const *left_string = left;
    const char *const *right_string = right;
    return strcmp(*left_string, *right_string);
}

static bool verify_paths(struct Paths *actual, const struct Options *options) {
    struct Paths expected = {0};
    bool success = true;
    for (size_t index = 0; index < options->directory_count; ++index) {
        success = success && append_path(&expected, options->directories[index]);
    }
    for (size_t index = 0; index < options->file_count; ++index) {
        success = success && append_path(&expected, options->files[index].path);
    }
    if (!success) {
        return false;
    }
    qsort(actual->items, actual->count, sizeof(*actual->items), compare_strings);
    qsort(expected.items, expected.count, sizeof(*expected.items), compare_strings);
    if (actual->count != expected.count) {
        success = false;
    } else {
        for (size_t index = 0; index < actual->count; ++index) {
            if (strcmp(actual->items[index], expected.items[index]) != 0) {
                success = false;
                break;
            }
        }
    }
    if (!success) {
        fprintf(stderr, "path_set_mismatch actual=%zu expected=%zu\n",
                actual->count, expected.count);
    } else {
        for (size_t index = 0; index < actual->count; ++index) {
            printf("path_set item=%s\n", actual->items[index]);
        }
    }
    for (size_t index = 0; index < expected.count; ++index) {
        free(expected.items[index]);
    }
    free(expected.items);
    return success;
}

static bool verify_bootblock(const struct Options *options) {
    FILE *image = fopen(options->image, "rb");
    uint8_t boot[BOOTBLOCK_SIZE];
    if (image == NULL || fread(boot, 1, sizeof(boot), image) != sizeof(boot)) {
        fprintf(stderr, "bootblock_read_failed\n");
        if (image != NULL) {
            fclose(image);
        }
        return false;
    }
    fclose(image);
    const uint8_t expected_dos[4] = {'D', 'O', 'S', (uint8_t)options->dos_type};
    if (memcmp(boot, expected_dos, sizeof(expected_dos)) != 0) {
        fprintf(stderr, "bootblock_mismatch field=dos_signature\n");
        return false;
    }
    const bool none = strcmp(options->bootblock, "none") == 0;
    const bool installed = strcmp(options->bootblock, "1.3") == 0 ||
                           strcmp(options->bootblock, "2.0") == 0;
    if (!none && !installed) {
        fprintf(stderr, "bootblock_mode_invalid\n");
        return false;
    }
    for (size_t index = 12U; index < sizeof(boot); ++index) {
        const size_t code_index = index - 12U;
        const uint8_t expected = installed && code_index < sizeof(installed_boot_code)
                                     ? installed_boot_code[code_index]
                                     : 0U;
        if (boot[index] != expected) {
            fprintf(stderr, "bootblock_mismatch offset=%zu\n", index);
            return false;
        }
    }
    printf("bootblock mode=%s dos=hex:444f53%02x\n",
           options->bootblock, options->dos_type);
    return true;
}

static bool verify_geometry(const struct Options *options, const struct AdfDevice *device) {
    struct stat image_stat;
    if (stat(options->image, &image_stat) != 0 ||
        (uint64_t)image_stat.st_size != ADF_IMAGE_SIZE ||
        device->geometry.cylinders != 80U || device->geometry.heads != 2U ||
        device->geometry.sectors != 11U) {
        fprintf(stderr, "geometry_mismatch\n");
        return false;
    }
    printf("geometry bytes=%u cylinders=80 heads=2 sectors=11\n", ADF_IMAGE_SIZE);
    return true;
}

static void free_paths(struct Paths *paths) {
    for (size_t index = 0; index < paths->count; ++index) {
        free(paths->items[index]);
    }
    free(paths->items);
}

static int inspect_image(const struct Options *options) {
    int result = EXIT_FAILURE;
    struct Paths paths = {0};
    if (!verify_bootblock(options) || adfLibInit() != ADF_RC_OK) {
        return result;
    }
    struct AdfDevice *device = adfDevOpen(options->image, ADF_ACCESS_MODE_READONLY);
    if (device == NULL || !verify_geometry(options, device) ||
        adfDevMount(device) != ADF_RC_OK) {
        fprintf(stderr, "image_mount_failed\n");
        goto cleanup_library;
    }
    struct AdfVolume *volume = adfVolMount(device, 0, ADF_ACCESS_MODE_READONLY);
    if (volume == NULL) {
        fprintf(stderr, "volume_mount_failed\n");
        goto cleanup_device_mount;
    }
    if (strcmp(volume->volName, options->volume) != 0) {
        fprintf(stderr, "volume_label_mismatch actual=%s expected=%s\n",
                volume->volName, options->volume);
        goto cleanup_volume;
    }
    if (memcmp(volume->fs.id, "DOS", 3) != 0 || volume->fs.type != options->dos_type) {
        fprintf(stderr, "filesystem_mismatch actual=%d expected=%d\n",
                volume->fs.type, options->dos_type);
        goto cleanup_volume;
    }
    printf("filesystem id=hex:444f53%02x kind=%s volume=%s\n",
           volume->fs.type, adfVolIsOFS(volume) ? "OFS" : "FFS", volume->volName);
    if (inspect_directory(volume, "", options, &paths) && verify_paths(&paths, options)) {
        puts("inspection_ok");
        result = EXIT_SUCCESS;
    }

cleanup_volume:
    adfVolUnMount(volume);
cleanup_device_mount:
    adfDevUnMount(device);
cleanup_library:
    if (device != NULL) {
        adfDevClose(device);
    }
    adfLibCleanUp();
    free_paths(&paths);
    return result;
}

int main(int argc, char **argv) {
    struct Options options;
    if (!parse_options(argc, argv, &options)) {
        usage(stderr);
        return EXIT_FAILURE;
    }
    const int result = inspect_image(&options);
    free_options(&options);
    return result;
}
