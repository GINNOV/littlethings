/* asl.c -- function for getting filenames */

#ifndef ASL_C
#define ASL_C

#include <stdio.h>
#include <string.h>
#include <time.h>

#include <clib/asl_protos.h>
#include <clib/intuition_protos.h>
#include <libraries/asl.h>

#include "codec.h"
#include "asl.h"
 
extern struct Window *PhoneWindow;
/*	__chip extern UBYTE waitPointer[];  */

/* Fills out szBuffer with the filename/path selected by the user from
   a file requester.   szMessage can be used to change the title string */
int FileRequest(char *szMessage, char *szBuffer, char *szOKMessage, char *szDefaultDirParam, char *szDefaultFile, BOOL BSaveIt)
{
	int rvalue = TRUE;
	struct FileRequester *fr;
	LONG lFlags = FILF_NEWIDCMP;
	static char szDefaultDefaultDir[300] = "\0";
	char * szDefaultDir;
	
	if (szBuffer == NULL)      	return(FALSE);
	if (BSaveIt == TRUE)       	lFlags        |= FILF_SAVE;
	if (szMessage == NULL)     	szMessage     = "Select a file!";
	if (szOKMessage == NULL)   	szOKMessage   = "OK";
	if (szDefaultDirParam == NULL) 	szDefaultDir  = szDefaultDefaultDir; else szDefaultDir = szDefaultDirParam;
	if (szDefaultFile == NULL) 	szDefaultFile = "";
       
	struct TagItem frtags[] =
	{
		ASL_Hail,	(ULONG)szMessage,
		ASL_Height,	185,
		ASL_Width,	320,
		ASL_LeftEdge,	0,
		ASL_TopEdge,	15,
		ASL_Dir,        (ULONG)szDefaultDir,
		ASL_File,       (ULONG)szDefaultFile,
		ASL_OKText,	(ULONG)szOKMessage,
		ASL_FuncFlags,  lFlags,
		ASL_CancelText,	(ULONG)"Cancel",
		ASL_Window,	PhoneWindow,
		TAG_DONE
	};
	
	fr = (struct FileRequester *) AllocAslRequest(ASL_FileRequest, frtags);	
	if (fr == NULL) return(FALSE);
	
/*	SetPointer(PhoneWindow, (UWORD *)waitPointer, 16, 16, -6, 0); */
	if (AslRequest(fr, NULL))
	{
		*szBuffer = '\0';
		strcpy(szBuffer,fr->rf_Dir);

		/* set default dir for next time */
		Strncpy(szDefaultDefaultDir,fr->rf_Dir,sizeof(szDefaultDefaultDir));
		
		if ((strlen(szBuffer) > 0)&&(szBuffer[strlen(szBuffer)-1] != '/')&&
		    (szBuffer[strlen(szBuffer)-1] != ':')) strcat(szBuffer,"/");
		strcat(szBuffer,fr->rf_File);
	}
	else rvalue = FALSE;
/*	ClearPointer(PhoneWindow); */

	FreeAslRequest(fr);
	return(rvalue);
}
#endif