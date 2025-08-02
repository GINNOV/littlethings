#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <errno.h>
#include <time.h>
#include <stdarg.h>
#include <libgen.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <dirent.h>
#include <getopt.h>

/*
 * ADFlib headers.
 */
#include "adflib.h"
#include "adf_env.h"
#include "adf_dev.h"
#include "adf_vol.h"
#include "adf_file.h"
#include "adf_blk.h"
#include "adf_err.h"
#include "adf_dev_flop.h"
#include "adf_dev_drivers.h"
#include "adf_dir.h"

// ANSI Color Codes
#define ANSI_COLOR_CYAN    "\x1b[36m"
#define ANSI_COLOR_RESET   "\x1b[0m"
#define ANSI_COLOR_RED     "\x1b[31m"
#define ANSI_COLOR_GREEN   "\x1b[32m"
#define ANSI_COLOR_YELLOW  "\x1b[33m"

// Version information
#define VERSION_MAJOR "1"
#define VERSION_MINOR "1"

// Global verbosity level
int verbosity_level = 0;

// Boot Block Data (from ADFinder project)
unsigned char kick13BootBlock[] = {
    0x44, 0x4F, 0x53, 0x00, 0xDF, 0x10, 0x1A, 0x2A, 0x00, 0x00, 0x03, 0x70, 0x43, 0xFA, 0x00, 0x18,
    0x4E, 0xAE, 0xFF, 0xA0, 0x4A, 0x80, 0x67, 0x0A, 0x20, 0x40, 0x20, 0x68, 0x00, 0x16, 0x70, 0x00,
    0x4E, 0x75, 0x70, 0xFF, 0x60, 0xFA, 0x64, 0x6F, 0x73, 0x2E, 0x6C, 0x69, 0x62, 0x72, 0x61, 0x72,
    0x79, 0x00
};

unsigned char kick20BootBlock[] = {
    0x44, 0x4F, 0x53, 0x01, 0x43, 0x1A, 0x4A, 0x2A, 0x00, 0x00, 0x03, 0x70, 0x43, 0xFA, 0x00, 0x18,
    0x4E, 0xAE, 0xFF, 0xA0, 0x4A, 0x80, 0x67, 0x0A, 0x20, 0x40, 0x20, 0x68, 0x00, 0x16, 0x70, 0x00,
    0x4E, 0x75, 0x70, 0xFF, 0x60, 0xFA, 0x64, 0x6F, 0x73, 0x2E, 0x6C, 0x69, 0x62, 0x72, 0x61, 0x72,
    0x79, 0x00
};

// Forward declarations
static bool add_host_directory_to_adf_recursive(struct AdfVolume *vol, const char *host_dirpath);
static bool install_bootblock(struct AdfVolume *vol, const char* bootblock_name);


void debug_printf(int required_level, const char *format, ...) {
    if (verbosity_level >= required_level) {
        va_list args;
        if (required_level == 1 && verbosity_level == 1) {
            fprintf(stderr, ANSI_COLOR_YELLOW "[INFO]  " ANSI_COLOR_RESET);
        } else if (verbosity_level >= 2) {
            fprintf(stderr, ANSI_COLOR_YELLOW "[DEBUG] " ANSI_COLOR_RESET);
        }
        va_start(args, format);
        vfprintf(stderr, format, args);
        va_end(args);
    }
}

char* get_build_date() {
    static char build_date_str[9];
    time_t t = time(NULL);
    struct tm *tm_info = localtime(&t);
    strftime(build_date_str, sizeof(build_date_str), "%Y%m%d", tm_info);
    return build_date_str;
}

void print_usage(const char *prog_name) {
    char* build_date = get_build_date();
    printf(ANSI_COLOR_CYAN "Create ADF Images by x.com/WINDRAGO. Version %s.%s build (%s)\n" ANSI_COLOR_RESET,
           VERSION_MAJOR, VERSION_MINOR, build_date);
    printf("Usage: %s -o <output.adf> -N <volname> [-B <bootblock>] [-v] <file_or_dir1> ...\n", prog_name);
    printf("Options:\n");
    printf("  -o, --output    <filename>      Specify the output ADF filename (required).\n");
    printf("  -N, --volname   <name>          Specify the volume name for the ADF (required).\n");
    printf("  -B, --bootblock <name>          Specify the bootblock to install. Default is '1.3'.\n");
    printf("                                  Available: 'none', '1.3', '2.0'.\n");
    printf("  -v, --verbose                 Enable verbose messages. Use -vv for extensive debug.\n");
    printf("  -h, --help                    Display this help message.\n");
}

char* get_amiga_basename(const char *path) {
    char *path_copy = strdup(path);
    if (!path_copy) {
        perror("strdup failed in get_amiga_basename");
        return NULL;
    }
    char *bname = basename(path_copy);
    char *result = strdup(bname);
    free(path_copy);
    if (!result) {
        perror("strdup failed for basename result");
    }
    return result;
}

static bool add_host_file_to_adf(struct AdfVolume *vol, const char *host_filepath, const char *amiga_filename) {
    debug_printf(1, "Adding host file '%s' -> ADF as '%s'\n", host_filepath, amiga_filename);

    FILE *host_file_ptr = fopen(host_filepath, "rb");
    if (!host_file_ptr) {
        fprintf(stderr, ANSI_COLOR_RED "Error: Could not open host input file '%s': %s\n" ANSI_COLOR_RESET, host_filepath, strerror(errno));
        return false;
    }

    struct AdfFile *amiga_file_ptr = adfFileOpen(vol, amiga_filename, ADF_FILE_MODE_WRITE);
    if (!amiga_file_ptr) {
        fprintf(stderr, ANSI_COLOR_RED "Error: Could not create Amiga file '%s' in ADF.\n" ANSI_COLOR_RESET, amiga_filename);
        fclose(host_file_ptr);
        return false;
    }

    unsigned char buffer[4096];
    size_t bytes_read;
    bool success = true;

    while ((bytes_read = fread(buffer, 1, sizeof(buffer), host_file_ptr)) > 0) {
        uint32_t bytes_written = adfFileWrite(amiga_file_ptr, bytes_read, buffer);
        if (bytes_written != bytes_read) {
            fprintf(stderr, ANSI_COLOR_RED "Warning: Failed to write all bytes to '%s'. Disk full?\n" ANSI_COLOR_RESET, amiga_filename);
            success = false;
            break;
        }
    }
    
    if (ferror(host_file_ptr)) {
        fprintf(stderr, ANSI_COLOR_RED "Error: Failure reading host file '%s'\n" ANSI_COLOR_RESET, host_filepath);
        success = false;
    }

    adfFileClose(amiga_file_ptr);
    fclose(host_file_ptr);

    return success;
}

static bool add_host_directory_to_adf_recursive(struct AdfVolume *vol, const char *host_dirpath) {
    debug_printf(1, "Processing host directory '%s'\n", host_dirpath);
    DIR *dir = opendir(host_dirpath);
    if (!dir) {
        fprintf(stderr, ANSI_COLOR_RED "Error: Could not open host directory '%s': %s\n" ANSI_COLOR_RESET, host_dirpath, strerror(errno));
        return false;
    }

    struct dirent *entry;
    bool all_success = true;
    while ((entry = readdir(dir)) != NULL) {
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) {
            continue;
        }

        char host_entry_path[FILENAME_MAX];
        snprintf(host_entry_path, sizeof(host_entry_path), "%s/%s", host_dirpath, entry->d_name);

        struct stat entry_stat;
        if (stat(host_entry_path, &entry_stat) == -1) {
            fprintf(stderr, ANSI_COLOR_RED "Error: Could not stat host path '%s': %s\n" ANSI_COLOR_RESET, host_entry_path, strerror(errno));
            all_success = false;
            continue;
        }

        if (S_ISDIR(entry_stat.st_mode)) {
            debug_printf(2, "Creating Amiga directory '%s'\n", entry->d_name);
            if (adfCreateDir(vol, vol->curDirPtr, entry->d_name) != ADF_RC_OK) {
                fprintf(stderr, ANSI_COLOR_RED "Error: Failed to create Amiga directory '%s'.\n" ANSI_COLOR_RESET, entry->d_name);
                all_success = false;
            } else {
                if (adfChangeDir(vol, entry->d_name) == ADF_RC_OK) {
                    if (!add_host_directory_to_adf_recursive(vol, host_entry_path)) {
                        all_success = false;
                    }
                    if (adfParentDir(vol) != ADF_RC_OK) {
                        fprintf(stderr, ANSI_COLOR_RED "Error: Failed to return to parent ADF directory from '%s'.\n" ANSI_COLOR_RESET, entry->d_name);
                        all_success = false;
                        break;
                    }
                } else {
                    fprintf(stderr, ANSI_COLOR_RED "Error: Failed to change into newly created Amiga directory '%s'.\n" ANSI_COLOR_RESET, entry->d_name);
                    all_success = false;
                }
            }
        } else if (S_ISREG(entry_stat.st_mode)) {
            if (!add_host_file_to_adf(vol, host_entry_path, entry->d_name)) {
                all_success = false;
            }
        } else {
            debug_printf(1, "Skipping non-regular file/directory: '%s'\n", host_entry_path);
        }
    }
    closedir(dir);
    return all_success;
}

struct AdfDevice* create_blank_adf(const char* filename, const char* vol_name) {
    debug_printf(2, "Creating new ADF device for '%s'\n", filename);
    struct AdfDevice *device = adfDevCreate("dump", filename, 80, 2, 11);
    if (!device) {
        fprintf(stderr, ANSI_COLOR_RED "Error: Failed to create ADF device '%s'.\n" ANSI_COLOR_RESET, filename);
        return NULL;
    }

    debug_printf(2, "Formatting volume as OFS with name '%s'\n", vol_name);
    if (adfCreateFlop(device, vol_name, ADF_DOSFS_OFS) != ADF_RC_OK) {
        fprintf(stderr, ANSI_COLOR_RED "Error: Failed to format floppy volume '%s'.\n" ANSI_COLOR_RESET, vol_name);
        adfDevClose(device);
        return NULL;
    }
    
    return device;
}

static bool install_bootblock(struct AdfVolume *vol, const char* bootblock_name) {
    if (strcmp(bootblock_name, "none") == 0) {
        debug_printf(1, "Bootblock installation skipped by user.\n");
        return true;
    }

    unsigned char* boot_data = NULL;
    size_t boot_size = 0;

    if (strcmp(bootblock_name, "1.3") == 0) {
        boot_data = kick13BootBlock;
        boot_size = sizeof(kick13BootBlock);
        debug_printf(1, "Selected Kickstart 1.3 bootblock for installation.\n");
    } else if (strcmp(bootblock_name, "2.0") == 0) {
        boot_data = kick20BootBlock;
        boot_size = sizeof(kick20BootBlock);
        debug_printf(1, "Selected Kickstart 2.0+ bootblock for installation.\n");
    } else {
        fprintf(stderr, ANSI_COLOR_RED "Error: Invalid bootblock type '%s'.\n" ANSI_COLOR_RESET, bootblock_name);
        return false;
    }
    
    unsigned char full_block[1024] = {0};
    memcpy(full_block, boot_data, boot_size);
    
    debug_printf(2, "Calling adfVolInstallBootBlock...\n");
    // rationale: Corrected the function name from adfInstallBootBlock to adfVolInstallBootBlock
    // as per the compiler's suggestion and the library header.
    if (adfVolInstallBootBlock(vol, full_block) != ADF_RC_OK) {
        fprintf(stderr, ANSI_COLOR_RED "Error: Failed to install bootblock.\n" ANSI_COLOR_RESET);
        return false;
    }

    debug_printf(1, "Bootblock installed successfully.\n");
    return true;
}

int main(int argc, char *argv[]) {
    char *output_filename = NULL;
    char *volume_name_arg = NULL;
    char *bootblock_arg = "1.3";
    int opt;

    static struct option long_options[] = {
        {"output",    required_argument, 0, 'o'},
        {"volname",   required_argument, 0, 'N'},
        {"bootblock", required_argument, 0, 'B'},
        {"verbose",   no_argument,       0, 'v'},
        {"help",      no_argument,       0, 'h'},
        {0, 0, 0, 0}
    };

    while ((opt = getopt_long(argc, argv, "o:N:B:vh", long_options, NULL)) != -1) {
        switch (opt) {
            case 'o': output_filename = optarg; break;
            case 'N': volume_name_arg = optarg; break;
            case 'B': bootblock_arg = optarg; break;
            case 'v': verbosity_level++; break;
            case 'h': print_usage(argv[0]); return EXIT_SUCCESS;
            default: print_usage(argv[0]); return EXIT_FAILURE;
        }
    }

    if (!output_filename || !volume_name_arg || optind >= argc) {
        if (!output_filename) fprintf(stderr, ANSI_COLOR_RED "Error: Output ADF filename missing.\n" ANSI_COLOR_RESET);
        if (!volume_name_arg) fprintf(stderr, ANSI_COLOR_RED "Error: Volume name missing.\n" ANSI_COLOR_RESET);
        if (optind >= argc) fprintf(stderr, ANSI_COLOR_RED "Error: No input files or directories specified.\n" ANSI_COLOR_RESET);
        print_usage(argv[0]);
        return EXIT_FAILURE;
    }

    debug_printf(1, "Verbose mode enabled (level %d).\n", verbosity_level);
    debug_printf(2, "Output ADF: %s, Volume Name: %s, Bootblock: %s\n", output_filename, volume_name_arg, bootblock_arg);

    if (adfLibInit() != ADF_RC_OK) {
        fprintf(stderr, ANSI_COLOR_RED "Error: Failed to initialize ADFLib.\n" ANSI_COLOR_RESET);
        return EXIT_FAILURE;
    }
    
    struct AdfDevice *device = create_blank_adf(output_filename, volume_name_arg);
    if (!device) {
        adfLibCleanUp();
        return EXIT_FAILURE;
    }
    
    if (adfDevMount(device) != ADF_RC_OK) {
        fprintf(stderr, ANSI_COLOR_RED "Error: Failed to mount device '%s'.\n" ANSI_COLOR_RESET, output_filename);
        adfDevClose(device);
        adfLibCleanUp();
        return EXIT_FAILURE;
    }
    
    struct AdfVolume *volume = adfVolMount(device, 0, ADF_ACCESS_MODE_READWRITE);
    if (!volume) {
        fprintf(stderr, ANSI_COLOR_RED "Error: Failed to mount volume from device.\n" ANSI_COLOR_RESET);
        adfDevUnMount(device);
        adfDevClose(device);
        adfLibCleanUp();
        return EXIT_FAILURE;
    }

    if (!install_bootblock(volume, bootblock_arg)) {
        adfVolUnMount(volume);
        adfDevUnMount(device);
        adfDevClose(device);
        adfLibCleanUp();
        return EXIT_FAILURE;
    }

    bool all_items_success = true;
    for (int i = optind; i < argc; i++) {
        const char *host_item_path = argv[i];
        struct stat item_stat;

        debug_printf(2, "Processing top-level host item: '%s'\n", host_item_path);
        
        if (adfToRootDir(volume) != ADF_RC_OK) {
            fprintf(stderr, ANSI_COLOR_RED "Error: Failed to set ADF to root before processing '%s'.\n" ANSI_COLOR_RESET, host_item_path);
            all_items_success = false;
            continue;
        }

        if (stat(host_item_path, &item_stat) == -1) {
            fprintf(stderr, ANSI_COLOR_RED "Error: Could not stat host path '%s': %s\n" ANSI_COLOR_RESET, host_item_path, strerror(errno));
            all_items_success = false;
            continue;
        }

        char *amiga_item_basename = get_amiga_basename(host_item_path);
        if (!amiga_item_basename) {
            all_items_success = false;
            continue;
        }

        if (S_ISDIR(item_stat.st_mode)) {
            debug_printf(1, "Adding host directory '%s' as '%s/'\n", host_item_path, amiga_item_basename);
            if (adfCreateDir(volume, volume->curDirPtr, amiga_item_basename) != ADF_RC_OK) {
                fprintf(stderr, ANSI_COLOR_RED "Error: Failed to create top-level directory '%s'.\n" ANSI_COLOR_RESET, amiga_item_basename);
                all_items_success = false;
            } else {
                if (adfChangeDir(volume, amiga_item_basename) == ADF_RC_OK) {
                    if (!add_host_directory_to_adf_recursive(volume, host_item_path)) {
                        all_items_success = false;
                    }
                } else {
                    fprintf(stderr, ANSI_COLOR_RED "Error: Failed to change into top-level directory '%s'.\n" ANSI_COLOR_RESET, amiga_item_basename);
                    all_items_success = false;
                }
            }
        } else if (S_ISREG(item_stat.st_mode)) {
            if (!add_host_file_to_adf(volume, host_item_path, amiga_item_basename)) {
                all_items_success = false;
            }
        } else {
            fprintf(stderr, ANSI_COLOR_YELLOW "Warning: Skipping unsupported file type: '%s'\n" ANSI_COLOR_RESET, host_item_path);
        }
        free(amiga_item_basename);
    }

    debug_printf(2, "Unmounting volume and device...\n");
    adfVolUnMount(volume);
    adfDevUnMount(device);
    adfDevClose(device);
    adfLibCleanUp();

    if (all_items_success) {
        printf(ANSI_COLOR_GREEN "ADF file '%s' created successfully.\n" ANSI_COLOR_RESET, output_filename);
    } else {
        fprintf(stderr, ANSI_COLOR_RED "ADF creation completed with one or more errors.\n" ANSI_COLOR_RESET);
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}