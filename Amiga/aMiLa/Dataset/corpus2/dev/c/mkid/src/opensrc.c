/* Copyright (c) 1986, Greg McGary */
static char sccsid[] = "@(#)opensrc.c	1.1 86/10/09";

#include	<stdio.h>
#include	"string.h"
#ifdef UNIX
#include	<sys/types.h>
#include	<sys/stat.h>
#endif

#include "extern.h"

#ifdef AMIGA
#include <dos/dosextens.h>
#include <dos/dostags.h>
#include <clib/dos_protos.h>
#include <pragmas/dos_pragmas.h>

extern struct DosLibrary *DOSBase;

/* this macro lets us long-align structures on the stack */
#define D_S(type,name) char a_##name[sizeof(type)+3]; \
                       type *name = (type *)((LONG)(a_##name+3) & ~3);
#endif

FILE * openSrcFILE(char *path,char *sccsDir,char *rcsDir);
char * getSCCS(char *dir,char *base,char *sccsDir);
char * coRCS(char *dir,char *base,char *rcsDir);

FILE *
openSrcFILE(char *path,char *sccsDir,char *rcsDir)
{
	char		*command = NULL;
	char		*what = NULL;
#ifndef AMIGA
	char		*get = "get SCCS file";
#endif	/* AMIGA */
	char		*checkout = "checkout RCS file";
	char		*dirName;
	char		*baseName;
	FILE		*srcFILE;

#ifdef UNIX
	if ((srcFILE = fopen(path, "r")) != NULL)
		return srcFILE;

	if ((baseName = strrchr(path, '/')) == NULL) {
		dirName = ".";
		baseName = path;
	} else {
		dirName = path;
		*baseName++ = '\0';
	}

	if (rcsDir && (command = coRCS(dirName, baseName, rcsDir)))
		what = checkout;
	else if (sccsDir && (command = getSCCS(dirName, baseName, sccsDir)))
		what = get;
	else if ((command = coRCS(dirName, baseName, "RCS"))
	     ||  (command = coRCS(dirName, baseName, ".")))
		what = checkout;
	else if ((command = getSCCS(dirName, baseName, "SCCS"))
	     ||  (command = getSCCS(dirName, baseName, "sccs"))
	     ||  (command = getSCCS(dirName, baseName, ".")))
		what = get;

	if (dirName == path)
		*--baseName = '/';

	if (!command) {
		filerr("open", path);
		return NULL;
	}

	system(command);
	if ((srcFILE = fopen(path, "r")) == NULL) {
		filerr("open", path);
		return NULL;
	}

	fprintf(stderr, "%s\n", command);
	return srcFILE;
#endif
#ifdef AMIGA
    static struct TagItem standard_tags[] = { SYS_UserShell,TRUE,TAG_DONE };
	char *anchor,sep;

		/* Try to open the plain file. */

	if ((srcFILE = fopen(path, "r")) != NULL)
		return srcFILE;

		/* If that didn't work, get the name of the file and
		 * the name of the drawer it is found in.
		 */

	baseName = FilePart(path);
	dirName = PathPart(path);

		/* If the name doesn't have a drawer part attached,
		 * it must be located in the current directory.
		 */

	if(dirName == path)
	{
		dirName = "";
		anchor = NULL;
	}
	else
	{
			/* Chop off the path part. */

		anchor = dirName;
		sep = *anchor;

		*dirName = 0;
		dirName = path;
	}

		/* Try to check out the file. */

	if (command = coRCS(dirName, baseName, rcsDir))
		what = checkout;

		/* Restore the path part if necessary. */

	if(anchor)
		*anchor = sep;

		/* Everything ready for the checkout procedure? */

	if (!command) {
		filerr(checkout, path);
		return NULL;
	}

		/* Check the file out. */

    if(SystemTagList(command,standard_tags) != 0)
    {
		filerr(what, path);
		return NULL;
    }

		/* Now try to open the file that got checked out. */

	if ((srcFILE = fopen(path, "r")) == NULL) {
		filerr("open", path);
		return NULL;
	}

	fprintf(stderr, "%s\n", command);
	return srcFILE;
#endif
}

char *
getSCCS(char *dir,char *base,char *sccsDir)
{
#ifdef UNIX
	static char	cmdBuf[BUFSIZ];
	char		fileBuf[BUFSIZ];
	struct stat	statBuf;

	if (!*sccsDir)
		sccsDir = ".";

	sprintf(fileBuf, "%s/%s/s.%s", dir, sccsDir, base);
	if (stat(fileBuf, &statBuf) < 0)
		return NULL;
	sprintf(cmdBuf, "cd %s; get -s %s/s.%s", dir, sccsDir, base);

	return cmdBuf;
#endif
#ifdef AMIGA
	return NULL;	/* No SCCS on the Amiga. */
#endif
}

char *
coRCS(char *dir,char *base,char *rcsDir)
{
#ifdef UNIX
	static char	cmdBuf[BUFSIZ];
	char		fileBuf[BUFSIZ];
	struct stat	statBuf;

	if (!*rcsDir)
		rcsDir = ".";

	sprintf(fileBuf, "%s/%s/%s,v", dir, rcsDir, base);
	if (stat(fileBuf, &statBuf) < 0)
		return NULL;
	sprintf(cmdBuf, "cd %s; co -q %s/%s,v", dir, rcsDir, base);

	return cmdBuf;
#endif
#ifdef AMIGA
	static char	cmdBuf[2*BUFSIZ];
	static char	rcs_drawer_name[BUFSIZ];
	char		fileBuf[BUFSIZ];
	char		suffixBuf[BUFSIZ];
	char 		*result;
	int			i;
	D_S(struct FileInfoBlock,FileInfo);

		/* If we don't have an RCS drawer to look into, we'll
		 * try to find it on our own.
		 */

	if(!rcsDir)
	{
			/* First test: look for an "RCS" subdirectory in
			 * the given source drawer.
			 */

		strcpy(fileBuf,dir);

		if(AddPart(fileBuf,"RCS",sizeof(fileBuf)))
		{
			BPTR FileLock;

			if(FileLock = Lock("RCS",SHARED_LOCK))
			{
				if(Examine(FileLock,FileInfo))
				{
					if(FileInfo->fib_DirEntryType > 0)
						strcpy(rcsDir = rcs_drawer_name,fileBuf);
				}

				UnLock(FileLock);
			}
		}
	}

	if(!rcsDir)
	{
			/* Second test: look for an "rcs_link" file in the
			 * given source drawer.
			 */

		strcpy(fileBuf,dir);

		if(AddPart(fileBuf,"rcs_link",sizeof(fileBuf)))
		{
			FILE *in;

			if(in = fopen(fileBuf,"rb"))
			{
					/* Read the contents. This will be the name of the
					 * drawer to look into for RCS files.
					 */

				if(fgets(rcs_drawer_name,sizeof(rcs_drawer_name)-1,in))
				{
					int len;

						/* Strip trailing line feeds. */

					len = strlen(rcs_drawer_name);

					while(len > 0 && rcs_drawer_name[len - 1] == '\n')
						len--;

					rcs_drawer_name[len] = 0;

					rcsDir = rcs_drawer_name;
				}

				fclose(in);
			}
		}
	}

		/* If we still couldn't find any RCS drawer we'll look for the
		 * files in the current directory.
		 */

	if(!rcsDir)
		rcsDir = dir;

		/* We'll try to locate the file with the ",v" suffix first,
		 * then repeat it without the suffix.
		 */

	for(i = 0, result = NULL ; result == NULL && i < 2 ; i++)
	{
		if(i)
			strcpy(suffixBuf,base);
		else
			sprintf(suffixBuf,"%s,v",base);

		strcpy(fileBuf,rcsDir);

		if(AddPart(fileBuf,suffixBuf,sizeof(fileBuf)))
		{
			BPTR FileLock;

			if(FileLock = Lock(fileBuf,SHARED_LOCK))
			{
				if(Examine(FileLock,FileInfo))
				{
					if(FileInfo->fib_DirEntryType < 0)
					{
						if(*dir)
							sprintf(cmdBuf,"cd \"%s\"\nco -q \"%s\"",dir,suffixBuf);
						else
							sprintf(cmdBuf,"co -q \"%s\"",suffixBuf);

						result = cmdBuf;
					}
				}

				UnLock(FileLock);
			}
		}
	}

	return(result);
#endif
}
