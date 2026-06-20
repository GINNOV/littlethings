#ifndef _FILEUTIL_H
#define _FILEUTIL_H

#include <stdio.h>
#include <crbinc/inc.h>

#ifdef __WATCOM__

#include <direct.h>
#include <dos.h>

#else /* not Watcom */

#ifdef _AMIGA

#include <sys/dir.h>
#include <dos.h>

#else

/* GCC */

#include <sys/dirent.h>

#endif /* _AMIGA */
#endif /* watcom */

extern void CatPaths(char *Base,char *Add);

  /* note: CatPaths() only works on AMIGA and PC

    use CatPaths(Path,"") to add an ending path delimiter
  */

extern bool NameIsDir(char *Name);

/***

NameIsDir behaves properly even when Name is terminated with
 a delimiter ('/','\',etc.)

***/

extern char * FilePart(char *FName);
extern char * PathPart(char *FName);
extern void PathPartInsert(char *F,char *Insert);

/***

avoiding using PathPart() whenever possible,
  use PathPartInsert() instead

PathPart() may only be called & used consecutively, and
 subsequent calls destroy the data returned

PathPart() should never be used inside functions

***/

extern ulong FileLengthofFH(FILE * fh);
#define FileLengthofFH_Error ((ulong)0xFFFFFFFF)

#define FRead(fp,buf,len)  fread(buf,1,len,fp)
#define FWrite(fp,buf,len) fwrite(buf,1,len,fp)

#ifndef BTPR
#define BTPR FILE *
#endif

#ifndef MODE_OLDFILE
#define MODE_OLDFILE "rb"
#endif

#ifndef MODE_NEWFILE
#define MODE_NEWFILE "wb"
#endif

#define Open(name,mode) fopen(name,mode)
#define Close(fh) fclose(fh)
#define Read FRead
#define Write FWrite

#endif /* FILEUTIL */
