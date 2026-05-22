
//
// debug.c
//

#include "debug.h"

FILE * LOG_FILE = NULL;

void debug_set_log(FILE * log_file) {
    LOG_FILE = log_file;
}

FILE * debug_get_log() {
    return LOG_FILE != NULL ? LOG_FILE : stderr;
}

void debug_fprintf(FILE * log_file, const char * format, ...) {
    va_list args;

    va_start(args, format);
    vfprintf(log_file, format, args);
    va_end(args);
}
