/*           This program explains how to use xmplayer.library      */
/*                           Author: Igor/TCG                       */
/*                           Date: 17.04.2001                       */
/*             Written especially for CruST/Amnesty^.humbug.        */

/*
**	Library coded by CruST / Amnesty^.humbug.
**	Released by .humbug. 17.04.2001
**
**	Library based on the PS3M source 
**	Copyright (c) Jarno Paananen a.k.a. Guru / S2 1994-96.
*/

/********************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <exec/types.h>
#include <exec/exec.h>
#include <proto/exec.h>
#include <dos/dos.h>
#include <proto/dos.h>
#include <libraries/xmplayer.h>
#include <proto/xmplayer.h>

/********************************************************************/
struct ReqToolsBase *ReqToolsBase = NULL;
struct DosLibrary *DOSBase = NULL;
struct Library *XMPlayerBase = NULL;

char *prname		= "Amnesty XM-Player";			/* process name */
char *exampleXM	= "PROGDIR:example.xm";			/* path to module file */

/********************************************************************/
void StartCode(void);
void EndCode(void);
APTR LoadData(char *filename, ULONG memtype);

/********************************************************************/
int main()
{
	struct XMPlayerInfo *XMPlayerInfo = NULL;
	APTR buffer = NULL;

	StartCode();										/* open libs, load data */

	/* load module into memory */
	if( (buffer = LoadData(exampleXM,MEMF_ANY)) == NULL)
	{
		printf("Can't open %s\nThist means that is out of memory (to much cholesterol!)\nor the file was lost (to much polish vodka!)\n",exampleXM);
		EndCode();
		exit(10);
	}

	/* allocate and init XMPlayerInfo structure */
	if( (XMPlayerInfo = AllocVec(sizeof(struct XMPlayerInfo),MEMF_ANY)) == NULL)
	{
		printf("Out of memory... to much russian vodka!\n");
		EndCode();
		exit(10);
	}
	
	XMPlayerInfo->XMPl_Cont = buffer;						/* module pointer */
	XMPlayerInfo->XMPl_Mixtype = XM_STEREO14;				/* mixing type; see autodoc */
	XMPlayerInfo->XMPl_Mixfreq = 22000;						/* mixing frequency; see autodoc */
	XMPlayerInfo->XMPl_Vboost = 2;							/* volume boosting; see autodoc */
	XMPlayerInfo->XMPl_PrName = prname;						/* name for playing process; see autodoc */
	XMPlayerInfo->XMPl_PrPri = 0;								/* playing process priority; see autodoc */

	if( XMPl_Init(XMPlayerInfo) == TRUE )					/* inits a player structure */
	{
		XMPl_Play();												/* I don't know... ;) */
		printf("playing xm module... press enter to stop...\n");

		getchar();													/* wait user reaction ;) */
		XMPl_StopPlay();											/* stop playing process */

		XMPl_DeInit();												/* well... guess what ;) */
	}
	else
		printf("Houston! We have a problem... Init fails\n");
	
	if(XMPlayerInfo != NULL)									/* and free resources */
		FreeVec(XMPlayerInfo);
	
	if(buffer != NULL)
		FreeVec(buffer);

	EndCode();
	return 0;
}

/********************************************************************/
void StartCode()
{
	if( (DOSBase = (struct DosLibrary *)OpenLibrary("dos.library",0)) == NULL)
	{
		printf("Ooops... turn off your girl friend, call your local customer service and pray... I can't open dos.library...\n");
		EndCode();
		exit(666);													/* ;-))))) */
	}

	if( (XMPlayerBase = OpenLibrary("xmplayer.library",1)) == NULL )
	{
		printf("Can't open xmplayer.library - throw away your computer and start singing...\n");
		EndCode();
		exit(10);
	}
}

/********************************************************************/
void EndCode()
{
	if(DOSBase != NULL)
		CloseLibrary((struct Library *)DOSBase);

	if(XMPlayerBase != NULL)
		CloseLibrary(XMPlayerBase);
}

/********************************************************************/
APTR LoadData(char *filename, ULONG memtype)
{
	BPTR lock;
	BPTR file;
	APTR buffer = NULL;

	struct FileInfoBlock fib;

	if( (lock = Lock(filename,ACCESS_READ)) )
	{
		Examine(lock,&fib);

		if( (buffer = AllocVec(fib.fib_Size,memtype)) )
		{
			if( (file = OpenFromLock(lock)) )
			{
				Read(file,buffer,fib.fib_Size);
				Close(file);
			} else {FreeVec(buffer);buffer = NULL;}
		} else {UnLock(lock);}
	}
	return buffer;
}

/********************************************************************/
