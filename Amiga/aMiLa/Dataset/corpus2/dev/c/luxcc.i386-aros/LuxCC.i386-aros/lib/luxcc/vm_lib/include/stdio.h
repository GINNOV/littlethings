#ifndef _STDIO_H
#define _STDIO_H

#include <stddef.h> /* for size_t, NULL */
#include <stdarg.h> /* for va_list */

#define EOF         (-1)

#define SEEK_SET    0
#define SEEK_CUR    1
#define SEEK_END    2

typedef struct _FILE FILE;
typedef unsigned long fpos_t;

extern FILE *stdin, *stdout, *stderr;
#define stdin  stdin
#define stdout stdout
#define stderr stderr

/* File access functions */
int fclose(FILE *stream);
FILE *fopen(const char *filename, const char *mode);

/* Formatted input/output functions */
int fprintf(FILE *stream, const char *format, ...);
int printf(const char *format, ...);
int snprintf(char *str, size_t size, const char *format, ...);
int sprintf(char *s, const char *format, ...);
int sscanf(const char *s, const char *format, ...);
int vfprintf(FILE *stream, const char *format, va_list ap);
int vsnprintf(char *str, size_t size, const char *format, va_list ap);
int vsprintf(char *s, const char *format, va_list ap);
int vsscanf(const char *str, const char *format, va_list ap);

/* Character input/output functions */
int fgetc(FILE *stream);
char *fgets(char *s, int n, FILE *stream);
int fputc(int c, FILE *stream);

/* Direct input/output functions */
size_t fread(void *ptr, size_t size, size_t nelem, FILE *stream);
size_t fwrite(const void *ptr, size_t size, size_t nelem, FILE *stream);

/* File positioning functions */
int fseek(FILE *stream, long offset, int mode);
long ftell(FILE *stream);
void rewind(FILE *stream);

/* Error-handling functions */
int ferror(FILE *stream);

/* POSIX */
int fileno(FILE *stream);

/* General file functions */
int remove(const char *filename);
int rename(const char *old_filename, const char *new_filename);

/* Buffer managing functions */
int fflush(FILE *stream);

#endif
