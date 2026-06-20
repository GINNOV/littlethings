/*
 *  guithread.cpp - GUI thread for MorphOS
 *
 *  Basilisk II (C) 1997-2001 Christian Bauer
 *                  2005-2006 Ilkka Lehtoranta
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <dos/dostags.h>
#include <libraries/iffparse.h>

#include <proto/alib.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/muimaster.h>

#include "guithread.h"
#include "mui.h"

#include <stdio.h>

// Global variables
extern struct MsgPort		*StartupMsgPort, *GUIPort;
extern struct Screen			*MainScreen;
extern ULONG					SubTaskCount, quitflag;
extern struct DiskObject	*dobj;

// Local variables

STATIC CONST CONST_STRPTR ClassList[] = { NULL };

static struct MsgPort *Rendezvous;
Object	*app;

bool RunPrefs(void);
bool RunVideo(void);

/**********************************************************************
	SendInfo

	Inform main task are we alive or dead
**********************************************************************/

static void SendInfo(struct MsgPort *replyport, LONG ok)
{
	struct GUI_Info msg;

	msg.Message.mn_Node.ln_Type	= NT_MESSAGE;
	msg.Message.mn_ReplyPort		= replyport;
	msg.Message.mn_Length			= sizeof(msg);
	msg.Ok								= ok;

	PutMsg(Rendezvous, (struct Message *)&msg);
	WaitPort(replyport);
	GetMsg(replyport);
}

/**********************************************************************
	Application class
**********************************************************************/

struct App_Data
{
	Object	*win_about;
};

static ULONG App_AboutBasilisk(struct IClass *cl, Object *obj)
{
	struct App_Data *data = (struct App_Data *)INST_DATA(cl, obj);
	Object *win;

	win = data->win_about;

	if (win == NULL)
	{
		Object *win, *ok;

		win = WindowObject,
			MUIA_Window_Title, "Basilisk II",
			MUIA_Window_ID, MAKE_ID('A','B','T','W'),
			WindowContents, VGroup,
				MUIA_Background, MUII_RequesterBack,
				Child, HGroup,
					Child, MUI_NewObject("Dtpic.mui", MUIA_Dtpic_Name, "PROGDIR:gfx/maconmos.png", End,
					Child, VGroup,
						Child, TextObject, MUIA_Text_Contents, _L(MSG_AUTHOR_INFORMATION), End,
						Child, RectangleObject, MUIA_Rectangle_HBar, TRUE, End,
						Child, TextObject, MUIA_Text_Contents, _L(MSG_PORT_INFORMATION), End,
						Child, RectangleObject, MUIA_Rectangle_HBar, TRUE, End,
						Child, TextObject, MUIA_Text_Contents, _L(MSG_GFX_INFORMATION), End,
					End,
				End,
				Child, HGroup,
					Child, MakeRect(100),
					Child, ok = MakeButton(MSG_OK_GAD),
					Child, MakeRect(100),
				End,
			End,
		End;

		if (!win)
		{
			return 0;
		}

		data->win_about	= win;

		DoMethod(obj, OM_ADDMEMBER, win);
		DoMethod(win, MUIM_Notify, MUIA_Window_CloseRequest, TRUE, win, 3, MUIM_Set, MUIA_Window_Open, FALSE);
		DoMethod(ok, MUIM_Notify, MUIA_Pressed, FALSE, win, 3, MUIM_Set, MUIA_Window_Open, FALSE);
		DoMethod(obj, MUIM_Application_PushMethod, win, 3, MUIM_Set, MUIA_Window_Open, TRUE);
		return SetAttrs(win, MUIA_Window_ActiveObject, ok, TAG_DONE);
	}

	return SetAttrs(win, MUIA_Window_Open, TRUE, TAG_DONE);
}

static ULONG AppDispatcher(void)
{
	struct IClass	*cl;
	Object	*obj;
	Msg	msg;

	cl		= (struct IClass *)REG_A0;
	msg	= (Msg)REG_A1;
	obj	= (Object *)REG_A2;

	switch (msg->MethodID)
	{
		case MM_Application_About	: return App_AboutBasilisk	(cl, obj);
	}

	return DoSuperMethodA(cl, obj, msg);
}

static struct EmulLibEntry ApplicationTrap = {TRAP_LIB, 0, (void (*)())&AppDispatcher };

/**********************************************************************
	FinishThread
**********************************************************************/

static struct MUI_CustomClass *CL_App;
struct MUI_CustomClass	*CL_Display;
extern struct EmulLibEntry DisplayTrap;

static void FinishThread(void)
{
	MUI_DisposeObject(app);

	if (CL_Display)
		MUI_DeleteCustomClass(CL_Display);

	if (CL_App)
		MUI_DeleteCustomClass(CL_App);

	if (MainScreen)
		CloseScreen(MainScreen);
}

/**********************************************************************
	MainGUI

	Initialize GUI thread
**********************************************************************/

static void MainGUI(void)
{
	struct MsgPort *port;

	NewGetTaskAttrs(NULL, &port, sizeof(struct MsgPort *), TASKINFOTYPE_TASKMSGPORT, TAG_DONE);

	if ((CL_App = MUI_CreateCustomClass(NULL, MUIC_Application, NULL, sizeof(struct App_Data), (APTR)&ApplicationTrap)))
	if ((CL_Display = MUI_CreateCustomClass(NULL, MUIC_Area, NULL, sizeof(struct Display_Data), (APTR)&DisplayTrap)))
	{
		Object *myapp;

		myapp = (Object *)NewObject(CL_App->mcc_Class, NULL,
			MUIA_Application_DiskObject, dobj,
			MUIA_Application_Version, "Basilisk II 1.1",
			MUIA_Application_Copyright, "Christian Bauer, Ilkka Lehtoranta",
			MUIA_Application_Author, "Christian Bauer, Ilkka Lehtoranta",
			MUIA_Application_Base, "BASILISKII",
			MUIA_Application_UsedClasses, ClassList,
			MUIA_Application_Title, "Basilisk II",
			MUIA_Application_Description, _L(MSG_DESCRIPTION),
		End;

		if (myapp)
		{
			ULONG	signals, portmask, quit;

			app = myapp;
			SendInfo(port, 1);

			portmask	= 1 << port->mp_SigBit;
			quit		= 0;
			signals	= 0;

			do
			{
				LONG ret = DoMethod(myapp, MUIM_Application_NewInput, &signals);

				if (ret == MUIV_Application_ReturnID_Quit)
				{
					quitflag = 1;
				}

				if (signals)
				{
					signals	= Wait(signals | portmask | SIGBREAKF_CTRL_C);

					if (signals & SIGBREAKF_CTRL_C)
					{
						quitflag = 1;
					}

					if (signals & portmask)
					{
						struct GUI_Message	*msg;

						msg	= (struct GUI_Message *)GetMsg(port);

						if (msg)
						{
							int rc = 0;

							switch (msg->Command)
							{
								case GUICMD_Quit	: quit = 1; break;
								case GUICMD_Prefs	:
									rc = RunPrefs();
									break;
								case GUICMD_InitVideo:
									rc	= RunVideo();
									break;
							}

							msg->Ok	= rc;

							ReplyMsg((struct Message *)msg);
						}
					}
				}
			}
			while (!quit);

			port = NULL;
		}
	}

	FinishThread();

	if (port)
	{
		SendInfo(port, 0);
	}
}

/**********************************************************************
	SendGUICmd

	Send a command to GUI thread and wait for info
**********************************************************************/

int SendGUICmd(GUICMD cmd)
{
	struct GUI_Message	msg;

	msg.Message.mn_ReplyPort	= Rendezvous;
	msg.Message.mn_Length		= sizeof(msg);
	msg.Command						= cmd;

	PutMsg(GUIPort, (struct Message *)&msg);
	WaitPort(Rendezvous);
	GetMsg(Rendezvous);

	return msg.Ok;
}

/**********************************************************************
	InitGUIThread
**********************************************************************/

int InitGUIThread(void)
{
	int rc;

	Rendezvous	= CreateMsgPort();
	rc	= 0;

	if (Rendezvous)
	{
		struct Message *msg;

		msg	= (struct Message *)AllocTaskPooled(sizeof(*msg));

		if (msg)
		{
			struct Process *GUIThread;

			msg->mn_Node.ln_Type	= NT_MESSAGE;
			msg->mn_ReplyPort		= StartupMsgPort;
			msg->mn_Length			= sizeof(*msg);

			GUIThread = CreateNewProcTags(
				NP_CodeType		, CODETYPE_PPC,
				NP_Entry			, &MainGUI,
				NP_Name			, "Basilisk II GUI",
				NP_Priority		, -1,
				NP_StartupMsg	, msg,
				NP_TaskMsgPort	, &GUIPort,
				TAG_DONE
			);

			if (GUIThread)
			{
				SubTaskCount++;

				WaitPort(Rendezvous);
				msg	= GetMsg(Rendezvous);
				rc		= ((struct GUI_Info *)msg)->Ok;
				ReplyMsg((struct Message *)msg);

				if (!rc)
				{
					GUIPort = NULL;
				}
			}
		}
	}

	return rc;
}

/**********************************************************************
	FinishGUIThread
**********************************************************************/

void FinishGUIThread(void)
{
	if (GUIPort)
	{
		SendGUICmd(GUICMD_Quit);
	}

	DeleteMsgPort(Rendezvous);
}
