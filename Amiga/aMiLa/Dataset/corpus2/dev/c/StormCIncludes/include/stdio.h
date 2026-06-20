#ifndef _INCLUDE_STDIO_H
#define _INCLUDE_STDIO_H

/*
**  $VER: stdio.h 1.04 (24.07.2000)
**  StormC Release 4.0
**
**  '(C) Copyright 1995-2000 Haage & Partner Computer GmbH'
**   All Rights Reserved
*/

#ifndef _INCLUDE_STDDEF_H
#include <stddef.h>
#endif

#ifndef _INCLUDE_STDARG_H
#include <stdarg.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct filehandle FILE;

#ifndef NULL
#define NULL 0
#endif

#define EOF (-1)

int getc(FILE *);
int fgetc(FILE *);
int getchar (void);
int ungetc(int, FILE *);

char *fgets(char *, int, FILE *);
char *gets(char *);

int fputc(int, FILE *);
int putc(int, FILE *);
int putchar(int);
int fputs(const char *, FILE *);
int puts(const char *);
void perror(const char *);

#define FILENAME_MAX 126
#define FOPEN_MAX (unsigned int) -1
FILE *fopen(const char *, const char *);
FILE *freopen(const char *, const char *, FILE *);
int fclose(FILE *);
int feof(FILE *);
int ferror(FILE *);
void clearerr(FILE *);
int fileno(FILE *);

#define _IOFBF 1
#define _IOLBF (-1)
#define _IONBF 0
#define BUFSIZ 2048
int setvbuf(FILE *, char *, int, size_t);
void setbuf(FILE *, char *);
int fflush(FILE *);

int printf(const char *, ...);
int fprintf(FILE *, const char *, ...);
int sprintf(char *, const char *, ...);

int vprintf(const char *, va_list);
int vfprintf(FILE *, const char *, va_list);
int vsprintf(char *, const char *, va_list);

int scanf(const char *, ...);
int fscanf(FILE *, const char *, ...);
int sscanf(const char *, const char *, ...);

int vscanf(const char *, va_list);
int vfscanf(FILE *, const char *, va_list);
int vsscanf(const char *, const char *, va_list);

int snprintf(char *s,size_t size,const char *format,...);
int vsnprintf(char *s,size_t size,const char *format,va_list args);

int remove(const char *);
int rename(const char *, const char *);

#define L_tmpnam 40
#define TMP_MAX ((unsigned int) -1)
char *tmpnam (char *);
FILE *tmpfile (void);

size_t fread(void *, size_t, size_t, FILE *);
size_t fwrite(const void *, size_t, size_t, FILE *);

#if defined(__STORM__)
#define SEEK_SET (-1)
#define SEEK_CUR 0
#define SEEK_END 1
#else
#define SEEK_SET 0
#define SEEK_CUR 1
#define SEEK_END 2
#endif

typedef int fpos_t;
int fseek(FILE *, long, int);
long ftell(FILE *);
void rewind(FILE *);
int fgetpos(FILE *, fpos_t *);
int fsetpos(FILE *, fpos_t *);

void exit(int);

#ifdef __STORM__

extern FILE std__in, std__out, std__err;
#define stdin (&std__in)
#define stdout (&std__out)
#define stderr (&std__err)

#else /* __STORM__ */

extern FILE **__sF; /* Standard I/O streams */
#define stdin  (__sF[0]) /* Other streams are not in __sF */
#define stdout (__sF[1])
#define stderr (__sF[2])

#ifdef __STORMLIBNIX__
#include <filedefs.h>
extern int __swbuf(int c,FILE *stream);
extern int __srget(FILE *stream);
/* Be careful: We have side effects and use incount in __srget -
	       must use comma-operator */
#define getc(fp) ((fp)->incount--,(fp)->incount>=0?(int)*(fp)->p++:__srget(fp))
#define putc(c,fp)                                        \
	((fp)->outcount--,(fp)->outcount>=0||                  \
	((fp)->outcount>=(fp)->linebufsize&&(char)(c)!='\n')?  \
	*(fp)->p++=(c):__swbuf((c),(fp)))
#define ferror(fp) ((fp)->flags&64)
#define feof(fp)   ((fp)->flags&32)
#endif /* __STORMLIBNIX__ */
#endif /* __STORM__ */

#ifdef __cplusplus
}
#endif

#endif
