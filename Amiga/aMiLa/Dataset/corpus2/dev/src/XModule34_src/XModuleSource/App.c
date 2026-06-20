/*
**	App.c
**
**	Copyright (C) 1994,1995 by Bernardo Innocenti
**
**	Handle AppIcons & AppWindows
*/

#include <exec/memory.h>
#include <workbench/workbench.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/intuition_protos.h>
#include <clib/wb_protos.h>
#include <clib/icon_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/wb_pragmas.h>
#include <pragmas/icon_pragmas.h>

#include "Xmodule.h"
#include "Gui.h"


struct MsgPort	*AppPort = NULL;
ULONG			 AppSig = 0;

LONG	IconX = NO_ICON_POSITION;
LONG	IconY = NO_ICON_POSITION;
UBYTE	IconName[16];

static struct AppIcon *MyAppIcon = NULL;
static struct DiskObject *AppDObj = NULL;

BOOL	Iconified = FALSE;



void HandleAppMessage (void)

/* App Window event handler.  Get Workbench message and call server */
{
	struct AppMessage *am;

	while (am = (struct AppMessage *) GetMsg (AppPort))
	{
		switch (am->am_Type)
		{
			case AMTYPE_APPWINDOW:
				(((struct WinUserData *) am->am_UserData)->DropIcon) (am);
				break;

			case AMTYPE_APPICON:
				if (am->am_NumArgs == 0)
					DeIconify();
				else if (am->am_UserData)
					((void (*) (struct AppMessage *am))(am->am_UserData)) (am);

				break;

			default:
				break;
		}

		ReplyMsg ((struct Message *) am);
	}
}



void AddAppWin (struct WinUserData *wud)
{
	wud->AppWin = AddAppWindowA (0, (ULONG)wud, wud->Win, AppPort, NULL);
}



void RemAppWin (struct WinUserData *wud)
{
	struct Node		*succ;
	struct Message	*msg;

	RemoveAppWindow (wud->AppWin);
	wud->AppWin = NULL;

	/* Reply all pending messages for this window */

	Forbid();

	msg = (struct Message *) AppPort->mp_MsgList.lh_Head;

	while (succ = msg->mn_Node.ln_Succ)
	{
		if ((struct WinUserData *)(((struct AppMessage *)msg)->am_UserData) == wud)
		{
			Remove ((struct Node *)msg);
			ReplyMsg (msg);
		}
		msg = (struct Message *) succ;
	}

	Permit();
}



LONG CreateAppIcon (void (*handler) (struct AppMessage *am))
{
	if (!AppPort) return RETURN_FAIL;

	if (MyAppIcon) return RETURN_OK;

	/* Get icon */
	if ( !(AppDObj = GetProgramIcon() ))
		AppDObj = GetDefDiskObject (WBTOOL);

	if (!AppDObj) return RETURN_FAIL;

	/* Initialize AppIcon */
	AppDObj->do_CurrentX = IconX;
	AppDObj->do_CurrentY = IconY;

	if (MyAppIcon = AddAppIconA (0, (ULONG)handler, IconName, AppPort, NULL, AppDObj, NULL))
		return RETURN_OK;

	FreeDiskObject (AppDObj); AppDObj = NULL;
	return RETURN_FAIL;
}



void DeleteAppIcon (void)
{
	if (MyAppIcon)
	{
		RemoveAppIcon (MyAppIcon); MyAppIcon = NULL;
		FreeDiskObject (AppDObj); AppDObj = NULL;
	}
}



void Iconify (void)
{
	if (!CreateAppIcon (ToolBoxDropIcon))
	{
		CloseDownScreen();
		Iconified = TRUE;
	}
}



void DeIconify (void)
{
	if (!SetupScreen())
	{
		Iconified = FALSE;
		if (!GuiSwitches.ShowAppIcon) DeleteAppIcon();
	}
}


LONG SetupApp (void)
{
	if (!(AppPort = CreateMsgPort()))
		return ERROR_NO_FREE_STORE;
	AppSig = 1 << AppPort->mp_SigBit;
	Signals |= AppSig;

	if (GuiSwitches.ShowAppIcon)
		CreateAppIcon (ToolBoxDropIcon);

	return RETURN_OK;
}



void CleanupApp (void)
{
	if (AppPort)
	{
		DeleteAppIcon();

		KillMsgPort (AppPort); AppPort = NULL;
		Signals &= ~AppSig; AppSig = 0;
	}
}
