
//
// debug.h
//

#ifndef __debug_h__
#define __debug_h__

#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <stdarg.h>
#include <stdlib.h>
#include <time.h>

void debug_set_log(FILE * log_file);
FILE * debug_get_log();

void debug_fprintf(FILE * log_file, const char * format, ...);

#ifdef NDEBUG
#define debug(M, ...)
#define die(M, ...) do { debug_fprintf(stderr, "fatal: " M "\n", ##__VA_ARGS__); exit(128); } while(0)
#else
#define debug(M, ...) debug_fprintf(stderr, "DEBUG %s:%d: " M "\n", __FILE__, __LINE__, ##__VA_ARGS__)
#define die(M, ...) do { debug_fprintf(stderr, "[FATAL] (%s:%d) " M "\n", __FILE__, __LINE__, ##__VA_ARGS__); exit(128); } while(0)
#endif

#define debug_errno() (errno == 0 ? "None" : strerror(errno))

#define log_error(M, ...) debug_fprintf(debug_get_log(), "[ERROR] (%s:%d: errno: %s) " M "\n", __FILE__, __LINE__, debug_errno(), ##__VA_ARGS__)
#define log_warning(M, ...) debug_fprintf(debug_get_log(), "[WARNING] (%s:%d: errno: %s) " M "\n", __FILE__, __LINE__, debug_errno(), ##__VA_ARGS__)
#define log_info(M, ...) debug_fprintf(debug_get_log(), "[INFO] (%s:%d) " M "\n", __FILE__, __LINE__, ##__VA_ARGS__)

#endif
