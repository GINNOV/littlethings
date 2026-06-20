#include "error.h"
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <unistd.h>
#include "luxcc.h"

void emit_error(int fatal, char *file, int line, int column, char *fmt, ...)
{
	va_list args;

    /*if (fatal)
        fprintf(stderr, "An unrecoverable error occurred\n");*/

    if (!colored_diagnostics || !isatty(fileno(stderr)))
        fprintf(stderr, "%s:%d:%d: error: ", file, line, column);
    else
        fprintf(stderr, INFO_COLOR "%s:%d:%d: " ERROR_COLOR "error: " RESET_ATTR, file, line, column);

	va_start(args, fmt);
	vfprintf(stderr, fmt, args);
	va_end(args);

	fprintf(stderr, "\n");

    if (fatal)
        exit(EXIT_FAILURE);

    ++error_count;
}

void emit_warning(char *file, int line, int column, char *fmt, ...)
{
	va_list args;

    if (disable_warnings)
        return;

    if (colored_diagnostics)
        fprintf(stderr, INFO_COLOR "%s:%d:%d: " WARNING_COLOR "warning: " RESET_ATTR, file, line, column);
    else
        fprintf(stderr, "%s:%d:%d: warning: ", file, line, column);

	va_start(args, fmt);
	vfprintf(stderr, fmt, args);
	va_end(args);

	fprintf(stderr, "\n");

    ++warning_count;
}
