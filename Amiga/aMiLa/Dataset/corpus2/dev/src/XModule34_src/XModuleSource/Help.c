/*	HandleHelp.c
**
** Copyright (C) 1994,1995 by Bernardo Innocenti
**
**	Handle on-line, context sensitive, AmigaGuide help.
*/

#include <libraries/amigaguide.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/amigaguide_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/amigaguide_pragmas.h>

#include "XModule.h"
#include "Gui.h"


static struct Library *AmigaGuideBase = NULL;
static struct NewAmigaGuide NewGuide ={0};
static AMIGAGUIDECONTEXT Context = NULL;
ULONG	AmigaGuideSig = 0L;

static STRPTR ContextList[] =
{
	"Main",
	NULL
};



void HandleHelp (struct IntuiMessage *msg)
{

	if (!AmigaGuideBase)
	{
		if (!(AmigaGuideBase = OpenLibrary ("amigaguide.library", 33)))
		{
			CantOpenLib ("amigaguide.library", 33);
			return;
		}

		NewGuide.nag_Name		= "XModule.guide";
		NewGuide.nag_Node		= "MAIN";
		NewGuide.nag_BaseName	= PRGNAME;
		NewGuide.nag_ClientPort	= NULL; // "XMODULE_HELP";
		NewGuide.nag_Context	= ContextList;
		NewGuide.nag_Screen		= Scr;

		if(Context = OpenAmigaGuideAsync (&NewGuide,
			AGA_HelpGroup,	UniqueID,
			TAG_DONE))
		{
			AmigaGuideSig = AmigaGuideSignal (Context);
			Signals |= AmigaGuideSig;

			/* Get startup message */
			Wait (AmigaGuideSig);
			HandleAmigaGuide();
		}
		else
		{
			LastErr = IoErr();
			CloseLibrary (AmigaGuideBase); AmigaGuideBase = NULL;
			return;
		}
	}


	/* Link with node */
	{
		UBYTE cmd[48];

		if (IntuiMsg.Class == IDCMP_RAWKEY || IntuiMsg.Class == IDCMP_MENUHELP)
			SPrintf (cmd, "LINK \"%s\"", ((struct WinUserData *)IntuiMsg.IDCMPWindow->UserData)->Title);
		else
			strcpy (cmd, "LINK Main");

		SendAmigaGuideCmdA (Context, cmd, NULL);
	}
}



void HandleAmigaGuide (void)
{
	struct AmigaGuideMsg *agm;

	while (agm = GetAmigaGuideMsg (Context))
	{
		if (agm->agm_Pri_Ret) /* Error? */
		{
			STRPTR reason;

			if (reason = GetAmigaGuideString (agm->agm_Sec_Ret))
				ShowRequest (MSG_AMIGAGUIDE_ERROR, 0, reason);
		}

//		switch (agm->agm_Type)
//		{
//			case ToolCmdReplyID:		/* A command has completed */
//			case ToolStatusID:

//			default:
//				break;
//		}

		ReplyAmigaGuideMsg (agm);
	}
}



void CleanupHelp (void)
{
	if (AmigaGuideBase)
	{
		Signals &= ~AmigaGuideSig;
		AmigaGuideSig = 0;
		CloseAmigaGuide (Context);		Context = NULL;
		CloseLibrary (AmigaGuideBase);	AmigaGuideBase = NULL;
	}
}
