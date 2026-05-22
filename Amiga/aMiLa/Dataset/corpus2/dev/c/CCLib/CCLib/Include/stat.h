#ifndef STAT_H
#define STAT_H 1

#ifndef STDDEF_H
#include "stddef.h"
#endif


/* this structure is filled in by the stat function */

struct stat
{
unsigned short st_attr; /* attribute, see below      */
time_t st_mtime;	/* time of last modification */
long st_size;		/* size in bytes	     */

/* THESE ARE ONLY FILLED OUT BY THE stat_() FUNCTION
 * in order to maintain compatibility with the older
 * versions of CClib.library			     */

unsigned short st_mode; /* file type, see below      */
short st_nlink; 	/* number of links to file   */
time_t st_atime;	/* time last accessed	     */
time_t st_ctime;	/* creation time	     */
};

/* st_mtime member is in seconds since Jan 1, 1978 */

/* st_attr member... */

/* file is NOT deletable */
#define ST_DELETE (1L<<0)
/* file is NOT executable */
#define ST_EXECUTE (1L<<1)
/* file is NOT writeable */
#define ST_WRITE (1L<<2)
/* file is NOT readable */
#define ST_READ (1L<<3)
/* file has been archived */
#define ST_ARCHIVE (1L<<4)

/* bits for st_mode... */

 /* all file type bits */
#define S_IFMT	0x16
 /* directory */
#define S_IFDIR 0x04
 /* character special */
#define S_IFCHR 0x02
 /* block special */
#define S_IFBLK 0x06
 /* regular */
#define S_IFREG 0x10

#ifdef ANSIC
long stat(char *,struct stat *);
long stat_(char *,struct stat *);
#else
long stat();
long stat_();
#endif

#endif

