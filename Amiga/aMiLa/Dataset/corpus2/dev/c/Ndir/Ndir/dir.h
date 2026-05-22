#ifndef DIR_H
#define DIR_H

#ifndef	EXEC_TYPES_H
#include "exec/types.h"
#endif

#ifndef	LIBRARIES_DOS_H
#include "libraries/dos.h"
#endif

#ifndef	LIBRARIES_DOSEXTENS_H
#include "libraries/dosextens.h"
#endif
/*
 * MAXNAMELEN is the maximum length a file name can be. The direct structure
 * is lifted form 4BSD, and has not been changed so that code which uses
 * it will be compatable with 4BSD code. d_ino and d_reclen are unused,
 * and will probably be set to some non-zero value.
 */
#define	MAXNAMLEN	31		/* AmigaDOS file max length */

struct	direct {
	ULONG	d_ino ;			/* unused - there for compatability */
	USHORT	d_reclen ;		/* ditto */
	USHORT	d_namlen ;		/* length of string in d_name */
	char	d_name[MAXNAMLEN + 1] ;	/* name must be no longer than this */
};
/*
 * The DIRSIZ macro gives the minimum record length which will hold
 * the directory entry.  This requires the amount of space in struct direct
 * without the d_name field, plus enough space for the name with a terminating
 * null byte (dp->d_namlen+1), rounded up to a 4 byte boundary.
 */

#undef DIRSIZ
#define DIRSIZ(dp) \
    ((sizeof(struct direct) - (MAXNAMLEN+1)) + (((dp) -> d_namlen+1 + 3) &~ 3))
/*
 * The DIR structure holds the things that AmigaDOS needs to know about
 * a file to keep track of where it is and what it's doing.
 */

typedef struct {
	struct FileInfoBlock	d_info ,	/* Default info block */
				d_seek ;	/* Info block for seeks */
	struct FileLock		*d_lock ;	/* Lock on directory */
	} DIR ;
	
extern	DIR *opendir(char *) ;
extern	struct direct *readdir(DIR *) ;
extern	long telldir(DIR *) ;
extern	void seekdir(DIR *, long) ;
extern	void rewinddir(DIR *) ;
extern	void closedir(DIR *) ;
#endif	DIR_H
