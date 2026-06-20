/*
 *	File:					Alert.c
 *	Description:	Displays given parameter in an standard system-alert.
 *	Version:			1.1
 *	Author:				Ketil Hunn
 *	Mail:					hunn@dhmolde.no
 *
 *	Copyright © 1993 Ketil Hunn.
 *
 *	In order to list the source-files included in this package properly,
 *	the TAB size should be set at 2.
 *
 *	To compile and link:
 *	sc link optimize nostandardio smallcode smalldata Alert.c
 */

#include <stdlib.h>
#include <string.h>
#include <intuition/intuition.h>
#include <clib/intuition_protos.h>
#include <clib/exec_protos.h>

#define PROGRAM "Alert"
#define VERSION "V1.2"
char const *version = "\0$VER: " PROGRAM " " VERSION " (20.10.94)";

struct IntuitionBase	*IntuitionBase;

#include "myinclude:myAlert.h"

#define TEMPLATE "TYPE=NUMBER/A/N,TIMEOUT=NUMBER/A/N,TEXT/A/M"
#define TYPE		0
#define TIMEOUT	1
#define	TEXT		3

void __main(void)
{
	struct RDArgs	*args;
	LONG					arg[2];

	if(IntuitionBase=(struct IntuitionBase *)OpenLibrary("intuition.library", 33L))
	{
		if(args=ReadArgs(TEMPLATE, arg, NULL))
		{
			register WORD type		=(ULONG)*((LONG *)arg[TYPE]),
										timeout	=(ULONG)*((LONG *)arg[TIMEOUT]);
			if(arg)
			{
				int i=0;
				char	*text;

				if(text=AllocVec(2400, MEMF_CLEAR))
				{
					strcpy(text,argv[1]);
					for(i=2; i<argc; ++i)
					{
						strcat(text,"\n");
						strcat(text,argv[i]);
					}
					myAlert(RECOVERY_ALERT,text, type);

					FreeVec(text);
				}
				else 
					MyAlert(RECOVERY_ALERT, "Out of memory!", 0);
			}
			FreeArgs(args);
		}
		CloseLibrary((struct Library *)IntuitionBase);
	}
}
