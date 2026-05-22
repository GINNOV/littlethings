
/*
 *  FCNTL.H
 *
 *  (c)Copyright 1990, Matthew Dillon, All Rights Reserved
 */

#ifndef FCNTL_H
#define FCNTL_H

#define O_RDONLY    0
#define O_WRONLY    1
#define O_RDWR	    2
#define O_NDELAY    4
#define O_APPEND    8
#define O_CREAT     0x0100
#define O_TRUNC     0x0200
#define O_EXCL	    0x0400
#define O_BINARY    0x0800

/*
 *  Internal, never specify
 */

#define O_INTERNAL  0xF000
#define O_ISOPEN    0x1000
#define O_NOCLOSE   0x2000  /*	not a closable file */
#define O_CEXEC     0x4000  /*	close on exec	    */

/*
 *  UNIX support
 */

#define F_DUPFD     1
#define F_GETFD     2
#define F_SETFD     3
#define F_GETFL     4
#define F_SETFL     5
#define FNDELAY     0x00010000


extern unsigned int write(int, const void *, unsigned int);
extern unsigned int read(int, void *, unsigned int);
extern int close(int);
extern int open(const char *, int, ...);
extern int creat(const char *, ...);
extern long lseek(int, long, int);

extern void *fdtofh(int);

#ifdef STDIO_H
extern _IOFDS *__getfh(short);      /*  for system use only */
extern _IOFDS *_MakeFD(int *);      /*  for system use only */
#endif

/*
 *  UNIX
 */

extern int fcntl(int, int, int);
extern int isatty(int);
extern int access(const char *, int);

#define X_OK	1
#define W_OK	2
#define R_OK	4

#endif
