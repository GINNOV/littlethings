#ifndef STDIO_H
#define STDIO_H 1

#ifndef NULL
#define NULL 0L
#endif
#define EOF -1

/* size of the buffer for buffered files... */
#define BUFSIZ 1024L

#define _BUSY (1<<0)
#define _ALLBUF (1<<1)
#define _DIRTY (1<<2)
#define _EOF (1<<3)
#define _IOERR (1<<4)
#define _TEMP (1<<5)

/* Flags for setvbuf */
#define _IOFBF 1L
#define _IOLBF 2L
#define _IONBF 3L
/* errors from setvbuf */
#define HASBUF 1L
#define NOBUFMEM 2L

/* seek positions */
#define SEEK_SET 0L
#define SEEK_CUR 1L
#define SEEK_END 2L

typedef struct
{
long _unit;		/* token returned by open -> FileDesc */
char *_bp;		/* position in character buffer */
char *_bend;		/* end of buffer */
char *_buff;		/* start */
char _flags;		/* open mode  */
char _bytbuf;		/* single character buffer (non-bufered files) */
short _buflen;		/* # characters in buffer */
char *_tmpname; 	/* temporary file name */
} FILE;

extern FILE *stdin, *stdout, *stderr;

/* use function calls instead, if NOMACROS is defined */
#ifndef NOMACROS

#define getchar() agetc(stdin)
#define putchar(c) aputc(c, stdout)

#else

#ifdef ANSIC
long getchar(void);
long putchar(long c);
#else
long getchar();
long putchar();
#endif

#endif

/* macros... */
#define feof(STREAM) ( ((FILE *)(STREAM))->_flags&_EOF )
#define ferror(STREAM) ( ((FILE *)(STREAM))->_flags&_IOERR )
#define clearerr(STREAM) ( ((FILE *)(STREAM))->_flags &= ~(_IOERR|_EOF) )
#define fileno(STREAM) ( ((FILE *)(STREAM))->_unit )
#define rewind(STREAM) (fseek((FILE *)(STREAM), 0L, SEEK_SET))
#define remove(NAME) ( unlink((char *)(NAME)) )
#define setbuf(STREAM,BUFFER)\
 (setvbuf(STREAM,BUFFER,BUFFER ? _IOFBF : _IONBF,BUFSIZ))
#define fgetc(STREAM) ((int)agetc(STREAM))
#define fputc(CH,STREAM) ((int)aputc((int)(CH),STREAM))

/* The name of the C DLL is here. */
#define CCLIBNAME "CClib.library"

/* The only practical limit to the number of
 * opened files is the amount of memory in the
 * computer.
 */
#define FOPEN_MAX 2147483647L

/* the length of a temporary file name */
#define L_tmpnam	30
#define TMP_MAX FOPEN_MAX

/* The theoretical maximum of the number of
 * characters in a file is 107 but the current
 * limit is set to 30. This doesn't include
 * the path name.
 */
#define FILENAME_MAX 107

#ifndef __SIZE_T
#define __SIZE_T 1
typedef unsigned long size_t;
#endif

#ifndef __FPOS_T
#define __FPOS_T 1
typedef long fpos_t;
#endif

#ifndef __SYS_ERRLIST
#define __SYS_ERRLIST 1
/* these correspond to the error codes returned in errno */
extern char *sys_errlist[];
#define sys_nerr 9
#endif

#ifdef ANSIC

#ifndef STDARG_H
#include "stdarg.h"
#endif

FILE *fopen(char *,char *);
FILE *freopen(char *, char *, FILE *);
long fflush(FILE *);
long fclose(FILE *);
long unlink(char *);
long rename(char *,char *);
FILE *tmpfile(void);
char *tmpnam(char *);
long setvbuf(FILE *,char *,long,size_t);
long fprintf(FILE *, char *, ...);
long printf(char *, ...);
long sprintf(char *, char *,...);
long vprintf(char *,va_list);
long vfprintf(FILE *,char *,va_list);
long vsprintf(char *,char *,va_list);
long fscanf(FILE *, char *, ...);
long scanf(char *, ...);
long sscanf(char *, char *, ...);
char *fgets(char *, long, FILE *);
long fputs(char *, FILE *);
long getc(FILE *);
char *gets(char *);
long putc(long ,FILE *);
long aputc(long, FILE *);
long agetc(FILE *);
long puts(char *);
long ungetc(long,FILE *);
size_t fread(void *,size_t,size_t,FILE *);
size_t fwrite(void *,size_t,size_t,FILE *);
long fseek(FILE *,long,long);
long ftell(FILE *);
long fgetpos(FILE *,fpos_t *);
long fsetpos(FILE *,fpos_t *);
long perror(char *);


#else

FILE *fopen();
FILE *freopen();
long fflush();
long fclose();
long unlink();
long rename();
FILE *tmpfile();
char *tmpnam();
long setvbuf();
long fprintf();
long printf();
long sprintf();
long vprintf();
long vfprintf();
long vsprintf();
long fscanf();
long scanf();
long sscanf();
char *fgets();
long fputs();
long getc();
char *gets();
long putc();
long aputc();
long agetc();
long puts();
long ungetc();
size_t fread();
size_t fwrite();
long fseek();
long ftell();
long fgetpos();
long fsetpos();
long perror();


#endif

#endif

