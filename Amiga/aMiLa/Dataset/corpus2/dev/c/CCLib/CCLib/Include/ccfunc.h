#ifndef CCFUNC_H
#define CCFUNC_H 1

#ifndef ANSIC
#define ANSIC 1
#endif

#ifndef STAT_H
#include "stat.h"
#endif

#ifndef STDLIST_H
#include "stdlist.h"
#endif

#ifndef IOLIB_H
#include "iolib.h"
#endif

#define NOMACROS 1

#ifndef STDIO_H
#include "stdio.h"
#endif

#ifndef TIME_H
#include "time.h"
#endif

#ifndef STRING_H
#include "string.h"
#endif

#ifndef STDLIB_H
#include "stdlib.h"
#endif


#ifdef ANSIC

#ifndef STDARG_H
#include "stdarg.h"
#endif

/* for compilers that support function prototypes */

long SetSTDIO(void);
long SetupSTDIO( FILE **, FILE **, FILE **, long *, long *, char **, void *,
		 long, char *, struct WBStartup *wbm, void (*)(long) );
task_UserData *GetSTDIO(void);
void ClearSTDIO(void);
void closeall(void);
void SetAbortFunc(ABORT_FUNC);
void ClearAbortFunc(void);
void cli_parse(task_UserData *, long, char *);
long wb_parse(task_UserData *, struct WBStartup *);
char *scdir(char *);
void scdir_clean(void);
void _exit(long);
void exit(long);
long open(char *,unsigned long,unsigned long);
long close(long);
long read(long, char *, long);
long write(long, char *, long);
long creat(char *, unsigned long);
long lseek(long, long, unsigned long);
long isatty(long);
long access(char *, long);
FILE *fdopen(long,char *);
void getbuff(FILE *);
char *mktemp(char *);
long putw(unsigned long,FILE *);
long puterr(long);
long getw(FILE *);


/* memory allocation functions */
void *_alloc(task_UserData *,long,long);
void _fre(task_UserData *,void *);
void _freall(task_UserData *);
void *sbrk(long);
void *heap_alloc(unsigned long);
void heap_free(void *);
void be_free(void *,unsigned long);
unsigned long malloc_size(void *);
void freeall(void);

/* format conversion functions */
void ltoa(long, char *);
void stoa(long, char *);

/* sorting functions */
void vquicksort(unsigned long,long (*)(unsigned long,unsigned long),
     void (*)(unsigned long, unsigned long));
void quicksort(unsigned long, long (*)(unsigned long,unsigned long,void *),
     void (*)(unsigned long,unsigned long,void *),void *);

#else

/* for compilers that do not support function prototypes */

long SetSTDIO();
long SetupSTDIO();
task_UserData *GetSTDIO();
void ClearSTDIO();
void closeall();
void SetAbortFunc();
void ClearAbortFunc();
void cli_parse();
long wb_parse();
char *scdir();
void _exit();
void exit();
long open();
long close();
long unlink();
long rename();
long read();
long write();
long creat();
long lseek();
long isatty();
long access();
FILE *fopen();
FILE *freopen();
long fclose();
FILE *fdopen();
void getbuff();
long setvbuf();
char *mktemp();
char *tmpnam();
FILE *tmpfile();
long putc();
long aputc();
long getc();
long agetc();
long ungetc();
long putw();
long puts();
long puterr();
size_t fwrite();
long perror();
long fseek();
long ftell();
long fflush();
long getw();
size_t fread();
char *gets();
char *fgets();
long fputs();
long scanf();
long printf();
long fscanf();
long fprintf();
long sscanf();
long sprintf();
long vprintf();
long vfprintf();
long vsprintf();
long fgetpos();
long fsetpos();
void *_alloc();
void _fre();
void _freall();
void *sbrk();
void *heap_alloc();
void heap_free();
void be_free();
unsigned long malloc_size();
void freeall();
void ltoa();
void stoa();
void vquicksort();
void quicksort();
#endif

#endif

