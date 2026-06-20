/*  stdio.h for vbcc Amiga WarpOS version  */

#ifndef __STDIO_H
#define __STDIO_H 1

#define EOF (-1)

#define BUFSIZ 4096L            /*  buffered i/o, default buf. size */
#define FOPEN_MAX   1024        /*  not used under AmigaOS          */

#define _IOFBF 1L               /*  full buffering                  */
#define _IOLBF 2L               /*  line buffer                     */
#define _IONBF 3L               /*  no buffer                       */

#define HASBUF 1L               /*  has a buffer                    */
#define NOBUFMEM 2L             /*  no buffering support            */

#define SEEK_SET (-1)           /*  fseek relative to beginning     */
#define SEEK_CUR  0             /*                 current position */
#define SEEK_END  1             /*                 end of file      */

#define _READ 1                 /*  FILE flags                      */
#define _WRITE 2
#define _UNBUF 4                /*  unbuffered i/o                  */
#define _EOF 8                  /*  end of file                     */
#define _ERR 16                 /*  error                           */
#define _READABLE 32
#define _WRITEABLE 64
#define _LINEBUF 128
#define _NOTMYBUF 256
#define _ISTTY 512

typedef struct _iobuf           /*  FILE structure                  */
{
    char *filehandle;           /*  AmigaDos file handle            */
    char *pointer;              /*  pointer to next character       */
    char *base;                 /*  buffer address                  */
    struct _iobuf *next;        /*  pointer to next structure       */
    struct _iobuf *prev;        /*  previous...                     */
    int count;                  /*  number of characters in buffer  */
    int flags;                  /*  access mode                     */
    int bufsize;                /*  buffer size                     */
} FILE;

/*  stdin/out/err must be initialized by _main()  */
extern FILE *stdin, *stdout, *stderr;

char *_open(char *,const char *,long);
long _read(char *,void *,long),_write(char *,void *,long),_seek(char *,long,int);
int _close(char *),_fillbuf(FILE *),_putbuf(int,FILE *),_flushbuf(FILE *);
void _ttyflush(void);

#define L_tmpnam        30
#define TMP_MAX FOPEN_MAX

#define FILENAME_MAX 107

#ifndef __SIZE_T
#define __SIZE_T 1
typedef unsigned long size_t;
#endif

#ifndef __FPOS_T
#define __FPOS_T 1
typedef long fpos_t;
#endif

#ifndef __STDARG_H
#include <stdarg.h>
#endif

#undef NULL
#define NULL ((void*)0)

FILE *fopen(const char *,const char *);
FILE *freopen(const char *,const char *,FILE *);
int fflush(FILE *);
int fclose(FILE *);
int rename(const char *,const char *);
int remove(const char *);
FILE *tmpfile(void);
char *tmpnam(char *);
int setvbuf(FILE *,char *,int,size_t);
void setbuf(FILE *,char *);
int fprintf(FILE *,const char *,...);
int printf(const char *,...);
int sprintf(char *,const char *,...);
int snprintf(char *,size_t,const char *,...);
int __v0fprintf(FILE *,const char *);
int __v0printf(const char *);
int __v0sprintf(char *,const char *);
int __v2vfprintf(FILE *,const char *,va_list);
int __v2fprintf(FILE *,const char *,...);
int __v2printf(const char *,...);
int __v2sprintf(char *,const char *,...);
int vprintf(const char *,va_list);
int vfprintf(FILE *,const char *,va_list);
int vsprintf(char *,const char *,va_list);
int vsnprintf(char *,size_t,const char *,va_list);
int fscanf(FILE *,const char *,...);
int scanf(const char *,...);
int sscanf(const char *,const char *,...);
int __v2vfscanf(FILE *,const char *,va_list);
int __v2fscanf(FILE *,const char *,...);
int __v2scanf(const char *,...);
int __v2sscanf(const char *,const char *,...);
int vscanf(const char *,va_list);
int vfscanf(FILE *,const char *,va_list);
int vsscanf(const char *,const char *,va_list);
char *fgets(char *,int,FILE *);
int fputs(const char *,FILE *);
char *gets(char *);
int puts(const char *);
int ungetc(int,FILE *);
size_t fread(void *,size_t,size_t,FILE *);
size_t fwrite(void *,size_t,size_t,FILE *);
int fseek(FILE *,long,int);
void rewind(FILE *);
long ftell(FILE *);
int fgetpos(FILE *,fpos_t *);
int fsetpos(FILE *,const fpos_t *);
void perror(const char *);
int fgetc(FILE *);
int fputc(int,FILE *);
int getchar(void);
int putchar(int);

#define __check(arg,type) (volatile size_t)sizeof((arg)==(type)0)

#define __putc(x,p) (((p)->flags|=_WRITE),((--((FILE*)(p))->count>=0&&((x)!='\n'||!(((FILE*)(p))->flags&_LINEBUF)))?(unsigned char)(*((FILE*)(p))->pointer++=(x)):_putbuf((x),p)))
#define putc(x,f) __putc((x),(f))
#define putchar(x) __putc((x),stdout)
#define __getc(p) (__check((p),FILE*),((p)->flags|=_READ),--((FILE*)(p))->count>=0?(unsigned char)*((FILE*)(p))->pointer++:_fillbuf(p))
#define getc(f) __getc(f)
#define getchar() __getc(stdin)

/*  some macros should be replaced by real functions   */
#define feof(p)         (__check((p),FILE*),((FILE*)(p))->flags&_EOF)
#define ferror(p)       (__check((p),FILE*),((FILE*)(p))->flags&_ERR)
/*#define fileno(p)       ((p)->filehandle)   does this make any sense? */
#define clearerr(p)     (__check((p),FILE*),((FILE*)(p))->flags&=~(_ERR|_EOF))

#define fsetpos(f,ptr)  fseek((f),*(ptr),SEEK_SET)

#pragma printflike printf
#pragma printflike fprintf
#pragma printflike sprintf
#pragma printflike snprintf
#pragma scanflike scanf
#pragma scanflike fscanf
#pragma scanflike sscanf

#ifdef __BUILD_LIB
char *__open(char *,const char *,long);
int __close(char *);
long __read(char *,void *,long);
long __write(char *,void *,long);
long __seek(char *,long,int);
#endif
#endif
