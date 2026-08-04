#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
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
#include "send2adf_version.h"
#include "send2adf_runtime.h"

// ANSI Color Codes
#define ANSI_COLOR_CYAN    "\x1b[36m"
#define ANSI_COLOR_RESET   "\x1b[0m"
#define ANSI_COLOR_RED     "\x1b[31m"
#define ANSI_COLOR_GREEN   "\x1b[32m"
#define ANSI_COLOR_YELLOW  "\x1b[33m"

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
const size_t kick13BootBlockSize = sizeof(kick13BootBlock);
const size_t kick20BootBlockSize = sizeof(kick20BootBlock);


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

void print_usage(const char *prog_name) {
    printf(ANSI_COLOR_CYAN "Create ADF Images by x.com/WINDRAGO. Version %s build (%s)\n" ANSI_COLOR_RESET,
           SEND2ADF_VERSION, SEND2ADF_BUILD_DATE);
    printf("Usage: %s -o <output.adf> -N <volname> [-B <bootblock>] [-v] <file_or_dir1> ...\n", prog_name);
    printf("Example: %s -o disk1.adf -N myDisk1 demo.exe anotherfile.raw a_directory_here \n", prog_name);
    printf("*------------------------------------------------------------------------------* \n");
    printf("Options:\n");
    printf("  -o, --output    <filename>      Specify the output ADF filename (required).\n");
    printf("  -N, --volname   <name>          Specify the volume name for the ADF (required).\n");
    printf("  -B, --bootblock <name>          Specify the bootblock to install. Default is '1.3'.\n");
    printf("                                  Available: 'none', '1.3', '2.0'.\n");
    printf("  -v, --verbose                 Enable verbose messages. Use -vv for extensive debug.\n");
    printf("  -h, --help                    Display this help message.\n");
}

int main(int argc, char *argv[]) {
    char *output_filename = NULL;
    char *volume_name_arg = NULL;
    char *bootblock_arg = "1.3";
    int opt;

    enum { OPTION_BUILD_IDENTITY = 1000, OPTION_BUILD_PROVENANCE };
    static struct option long_options[] = {
        {"output",    required_argument, 0, 'o'},
        {"volname",   required_argument, 0, 'N'},
        {"bootblock", required_argument, 0, 'B'},
        {"verbose",   no_argument,       0, 'v'},
        {"help",      no_argument,       0, 'h'},
        {"build-identity", no_argument,  0, OPTION_BUILD_IDENTITY},
        {"build-provenance", no_argument, 0, OPTION_BUILD_PROVENANCE},
        {0, 0, 0, 0}
    };

    while ((opt = getopt_long(argc, argv, "o:N:B:vh", long_options, NULL)) != -1) {
        switch (opt) {
            case 'o': output_filename = optarg; break;
            case 'N': volume_name_arg = optarg; break;
            case 'B': bootblock_arg = optarg; break;
            case 'v': verbosity_level++; break;
            case 'h': print_usage(argv[0]); return EXIT_SUCCESS;
            case OPTION_BUILD_IDENTITY: fputs(SEND2ADF_ADFLIB_IDENTITY "\n", stdout); return EXIT_SUCCESS;
            case OPTION_BUILD_PROVENANCE:
                fputs("{\"identity\":" SEND2ADF_ADFLIB_IDENTITY ",\"transport\":" SEND2ADF_ADFLIB_TRANSPORT "}\n", stdout);
                return EXIT_SUCCESS;
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
    debug_printf(2, "Output ADF: %s, Volume Name: %s, Bootblock: %s\n",
                 output_filename, volume_name_arg, bootblock_arg);
    return send2adf_create_image(output_filename, volume_name_arg, bootblock_arg,
                                 &argv[optind], (size_t)(argc - optind));
}
