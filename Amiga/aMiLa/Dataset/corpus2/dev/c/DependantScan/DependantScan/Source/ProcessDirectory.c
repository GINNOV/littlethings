#define DEF_PROCESSDIRECTORY_C

#include <exec/types.h>
#include <dos/dos.h>
#include <dos/dosasl.h>
#include <clib/dos_protos.h>
#include <clib/exec_protos.h>

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "ProcessDirectory.h"

/*
	int process_directory(
		char *name,																the name of the directory to examine (NULL - examine current directory)
		char *pattern,															pattern to search for (NULL - either the file pattern is in 'name' or use "#?")
		int (*filefunc)(														function to call when a file is encountered (NULL - dont' call any function)
			struct AnchorPath *anchor,										the file to being processed
			void *app_data),													some data specific to this process
		int (*dirfunc)(														function to call when a directory is encountered (NULL - do root only)
			struct AnchorPath *anchor,										the directory being processed
			void *app_data),													some data specific to this process
   	void *app_data)														data to be passed to 'filefunc' and 'dirfunc'

   * Description
   	This function will examine all the files in the directory specified by 'name' and all the files in it's sub-directories (if 'dirfunc'
   	is non-NULL). For each file found, 'filefunc' will be called. If non-NULL, directories will be processed and each directory
   	encountered will cause a call to the 'dirfunc' function. The 'dirfunc' and 'filefunc' functions are normally return a 0. If these
		function wish to stop the processing of the directory tree, they should return non-zero.

   * Return Value
   	0		= success
   	-1    = failure
   	other	= an error of some sort has occurred
*/
int process_directory(
	char *name,																	/* the name of the directory to examine (NULL - examine current directory) */
	char *pattern,																/* pattern to search for (NULL - either the file pattern is in 'name' or use "#?") */
	int (*filefunc)(															/* function to call when a file is encountered (NULL - dont' call any function) */
		struct AnchorPath *anchor,											/* the file to being processed */
		void *app_data),														/* some data specific to this process */
	int (*dirfunc)(															/* function to call when a directory is encountered (NULL - do root only) */
		struct AnchorPath *anchor,											/* the directory being processed */
		void *app_data),														/* some data specific to this process */
   void *app_data)															/* data to be passed to 'filefunc' and 'dirfunc' */
{
	struct AnchorPath *anchor = NULL;                           /* the file/directory we are currently dealing with */
	char *new_name = NULL;													/* needed so that we can effectively alter 'name' */
	BPTR previous_dir;														/* the directory we were in before we switched */
	int switch_back = 0;                                        /* true when we need to restore the current directory */
	int retval = -1;															/* assume an error condition */

	if ((pattern == NULL) && (name == NULL))                    /* if no pattern was supplied or there is no pattern in 'name' */
		pattern = "#?";														/* match all files */

	if (name == NULL)                                           /* if no name was supplied */
	{
		name = pattern;														/* then search the current directory for 'pattern' */
   }
   else if (strlen(pattern))												/* if we have a pattern */
   {
   	if ((new_name = AllocVec(PD_PATHMAX,0)) == NULL)			/* if we cannot get some memory for our revised name */
   		goto _ABORT;

      name = strcpy(new_name,name);										/* copy the supplied name to our new storage area and remember where that is */

   	if ((name[strlen(name)-1] != ':') && (name[strlen(name)-1] != '/'))								/* if the 'name' does not end in a directory separator */
   		strcat(name,"/");													/* separate the name from the pattern */

      strcat(name,pattern);												/* put the pattern after the name */
   }

	pattern = FilePart(name);												/* get the part of the spec that is the pattern */

	if ((anchor = AllocVec(sizeof(struct AnchorPath)+PD_PATHMAX,0)) == NULL)							/* if we cannot get some memory for the file/directory we are currently dealing with */
		goto _ABORT;

   anchor->ap_Strlen = PD_PATHMAX;										/* tell AmigaDOS how much space we have for the full path name */
   anchor->ap_BreakBits = NULL;											/* we don't want to convience the user with the ability of aborting */

   if (MatchFirst(name,anchor) == 0)									/* if at least one file matches */
   {
      previous_dir = CurrentDir(anchor->ap_Current->an_Lock);  /* switch to the directory where these files may be found */
		switch_back = 1;														/* remember that we need to restore the current directory */

		do																			/* process all the files that match */
		{
         if (anchor->ap_Info.fib_DirEntryType > 0)					/* if this is a new directory */
         {
         	if (dirfunc)													/* if we have a function to process directories */
         	{
               if ((retval = dirfunc(anchor,app_data)) != 0)   /* if there is an error when calling the application supplied function */
               	goto _ABORT;											/* then we are done */

					CurrentDir(previous_dir);								/* switch back to where we came from */

					anchor->ap_Buf[anchor->ap_Strlen-1] = '\0';		/* ensure that the full name is terminated */
/* if we have difficulty scanning this directory with the same pattern */
					if ((retval = process_directory(anchor->ap_Buf,pattern,filefunc,dirfunc,app_data)) != 0)
						goto _ABORT;

      			previous_dir = CurrentDir(anchor->ap_Current->an_Lock);                          /* switch back to the directory we are processing */
         	}
         }
      	else                                                  /* just a "plain file" */
      	{
      		if (filefunc)                                      /* if we have a function for processing files */
      		{
					if ((retval = filefunc(anchor,app_data)) != 0)  /* if we have a problem accessing this file */
						goto _ABORT;
				}
      	}
		}
		while (MatchNext(anchor) == 0);                          /* keep going while we have a matching file */
	}

	if (IoErr() == ERROR_NO_MORE_ENTRIES)                       /* if we are here because no more files matched */
		retval = 0;                                              /* that's OK */
   else
   	retval = -1;															/* we had a problem */

_ABORT:
	if (switch_back)															/* if we need to restore the current directory */
		CurrentDir(previous_dir);											/* switch back to where we came from */

	if (new_name)                                               /* if we allocated some memory */
      FreeVec(new_name);                                       /* then, clean up after ourselves */

	if (anchor)																	/* if we have an anchor */
	{
		MatchEnd(anchor);														/* free up any additional memory used by this anchor */
		FreeVec(anchor);														/* remove the anchor itself */
	}

	return (retval);															/* let caller know what happened */
}

/*
	int process_directory_do_nothing(
		struct AnchorPath *anchor,											the directory currently being processed
		void *app_data)														data specific to this directory process

   * Description
   	This function can be used as one of the function pointer arguments to process_directory() when 1) You want to ignore everything except
   	sub-directory entries or 2) You want to recurse into sub-directories, but not process the directory entries themselves.

   * Return Value
	   0
*/
int process_directory_do_nothing(
	struct AnchorPath *anchor,												/* the directory currently being processed */
	void *app_data)															/* data specific to this directory process */
{
	return (0);
}
