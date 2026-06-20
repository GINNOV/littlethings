#ifndef ERROR_H_
#define ERROR_H_

#define ERROR_COLOR        "\x1b[1;31m"
#define WARNING_COLOR      "\x1b[1;33m"
#define INFO_COLOR         "\x1b[1;37m"
#define RESET_ATTR         "\x1b[0m"

void emit_error(int fatal, char *file, int line, int column, char *fmt, ...);
void emit_warning(char *file, int line, int column, char *fmt, ...);

#endif
