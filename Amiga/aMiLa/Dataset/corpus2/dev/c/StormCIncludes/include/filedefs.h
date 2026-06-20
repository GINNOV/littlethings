#ifndef _INCLUDE_FILEDEFS_H
#define _INCLUDE_FILEDEFS_H

/*
**  $VER: filedefs.h 1.2 (31.7.2000)
**  StormC Release 4.0
**
**  '(C) Copyright 1995-2000 Haage & Partner Computer GmbH'
**   All Rights Reserved
*/

#ifdef __STORMLIBNIX__

struct filehandle
{
  unsigned char *p;	  /* pointer to actual character */
  int incount;		  /* Bytes left in buffer for reading, writemode: 0 */
  int outcount; 	  /* Space left in buffer for writing + fp->linebufsize,
			   * readmode: 0
			   */
  short flags;		  /* Some flags: 0x01 line buffered
			   *		 0x02 unbuffered
			   *		 0x04 read mode
			   *		 0x08 write mode
			   *		 0x20 EOF read
			   *		 0x40 error encountered
			   *		 0x80 buffer malloc'ed by library
			   *		0x200 sprintf/sscanf buffer
			   */
  short file;		  /* The filehandle */
  unsigned char *buffer;  /* original buffer pointer */
  int bufsize;		  /* size of the buffer */
  int linebufsize;	  /* 0 full buffered
			   * -bufsize line buffered&write mode
			   * readmode: undefined */
/* from this point on not binary compatible to bsd headers */
  unsigned char unget[4]; /* ungetc buffer 4 bytes necessary (for -Na*)
			   * ANSI requires 3 bytes (for -.*), so one more
			   * doesn't matter
			   */
  unsigned char *tmpp;	  /* Stored p if ungetc pending, otherwise NULL */
  int tmpinc;		  /* Stored incount if ungetc pending, otherwise undefined */
  long tmpdir;		  /* lock to directory if temporary file */
  char *name;		  /* filename if temporary file */
};

#else

#define FILEMODE_READ   1
#define FILEMODE_WRITE  2

#define FILEFLAGS_EOF            0x0001UL
#define FILEFLAGS_UNGOT          0x0002UL
#define FILEFLAGS_ISINTERACTIVE  0x0004UL
#define FILEFLAGS_AUTODELETE     0x0008UL
#define FILEFLAGS_AUTOBUFFER     0x0010UL
#define FILEFLAGS_WRITTEN        0x0020UL
#define FILEFLAGS_READ           0x0040UL
#define FILEFLAGS_READABLE       0x0080UL
#define FILEFLAGS_WRITEABLE      0x0100UL
#define FILEFLAGS_APPEND         0x0200UL


struct filehandle
{
    struct filehandle *next;
    struct filehandle *pred;
    unsigned int handle;
    int ungetC;
    unsigned int mode;
    unsigned int flags;
    int error;
    void *buffer;
    unsigned int size;
    unsigned int fill;
    unsigned int pos;
    unsigned int filepos;
    unsigned int bufmode;
    int (*read)(struct filehandle *, void *, unsigned int, unsigned int);
    int (*write)(struct filehandle *, void *, unsigned int);
    int (*eof)(struct filehandle *);
    int (*seek)(struct filehandle *, int, int);
    int (*getch)(struct filehandle *);
    int (*ungetch)(struct filehandle *, int);
    int (*putch)(struct filehandle *, int);
    int (*flush)(struct filehandle *);
    int (*close)(struct filehandle *);
#ifdef __MIXEDBINARY__
    int (*read2)(struct filehandle *, void *, unsigned int, unsigned int);
    int (*write2)(struct filehandle *, void *, unsigned int);
    int (*eof2)(struct filehandle *);
    int (*seek2)(struct filehandle *, int, int);
    int (*getch2)(struct filehandle *);
    int (*ungetch2)(struct filehandle *, int);
    int (*putch2)(struct filehandle *, int);
    int (*flush2)(struct filehandle *);
    int (*close2)(struct filehandle *);
#endif // __MIXEDBINARY__
};

#endif

#endif  /* _INCLUDE_FILEDEFS_H */
