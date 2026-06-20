/*
**	PlayWin.c
**
**	Copyright (C) 1995 Bernardo Innocenti
**
**	Play window handling functions.
*/

#include <intuition/intuition.h>
#include <libraries/gadtools.h>
#include <dos/dostags.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/utility_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/gadtools_pragmas.h>
#include <pragmas/utility_pragmas.h>

#include "Gui.h"
#include "XModule.h"
#include "Player.h"
#include "CustomClasses.h"



/*****************************/
/* Local function prototypes */
/*****************************/

static struct Gadget *CreateVImageButton (Class *cl, struct NewGadget *ng);
static void DeleteVImageButton (struct Gadget *g);

static void PlayPlayClicked (void);
static void PlayRewClicked (void);
static void PlayFwdClicked (void);
static void PlayStopClicked (void);
static void PlayVolClicked (void);
static void PlayTimeResetClicked (void);



enum {
	GD_PlayPlay,
	GD_PlayRew,
	GD_PlayFwd,
	GD_PlayStop,
	GD_PlayTime,
	GD_PlayPos,
	GD_PlayVol,
	GD_PlayTimeReset,

	Play_CNT
};



static UWORD PlayGTypes[] = {
	GENERIC_KIND,
	GENERIC_KIND,
	GENERIC_KIND,
	GENERIC_KIND,
	TEXT_KIND,
	TEXT_KIND,
	SLIDER_KIND,
	BUTTON_KIND
};



static struct NewGadget PlayNGad[] = {
	40, 1, 34, 13, (UBYTE *)"_p", NULL, GD_PlayPlay, IM_PLAY, NULL, (APTR)PlayPlayClicked,
	2, 1, 34, 13, (UBYTE *)"_r", NULL, GD_PlayRew, IM_REW, NULL, (APTR)PlayRewClicked,
	78, 1, 34, 13, (UBYTE *)"_f", NULL, GD_PlayFwd, IM_FWD, NULL, (APTR)PlayFwdClicked,
	116, 1, 34, 13, (UBYTE *)"_s", NULL, GD_PlayStop, IM_STOP, NULL, (APTR)PlayStopClicked,
	235, 13, 51, 11, (UBYTE *)"Time:", NULL, GD_PlayTime, PLACETEXT_LEFT, NULL, NULL,
	235, 1, 97, 11, (UBYTE *)"Pos:", NULL, GD_PlayPos, PLACETEXT_LEFT, NULL, NULL,
	44, 16, 106, 7, (UBYTE *)"_Vol:", NULL, GD_PlayVol, PLACETEXT_LEFT, NULL, (APTR)PlayVolClicked,
	290, 13, 42, 11, (UBYTE *)"Rst", NULL, GD_PlayTimeReset, PLACETEXT_IN, NULL, (APTR)PlayTimeResetClicked
};



static ULONG PlayGTags[] =
{
	XMGAD_BoopsiClass, TRUE, XMGAD_SetupFunc, (ULONG)CreateVImageButton, TAG_DONE,
	XMGAD_BoopsiClass, TRUE, XMGAD_SetupFunc, (ULONG)CreateVImageButton, TAG_DONE,
	XMGAD_BoopsiClass, TRUE, XMGAD_SetupFunc, (ULONG)CreateVImageButton, TAG_DONE,
	XMGAD_BoopsiClass, TRUE, XMGAD_SetupFunc, (ULONG)CreateVImageButton, TAG_DONE,
	GTTX_Border, TRUE, TAG_DONE,
	GTTX_Border, TRUE, TAG_DONE,
	GTSL_LevelPlace, PLACETEXT_RIGHT, GA_Immediate, TRUE, GA_RelVerify, TRUE, GTSL_Max, 64, GTSL_LevelFormat, (ULONG)"%ld", TAG_DONE,
	TAG_DONE
};


static struct Gadget *PlayGadgets[Play_CNT];

struct WinUserData PlayWUD =
{
	{ NULL, NULL },
	NULL,
	PlayGadgets,
	NULL,
	{ 0, 0, 0, 0 },
	NULL,
	NULL,
	NULL,
	0,

	NULL,
	ClosePlayWindow,
	NULL,
	NULL,
	NULL,

	{ 100, 30, 336, 25 },
	NULL,
	PlayGTypes,
	PlayNGad,
	PlayGTags,
	Play_CNT,
	WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_CLOSEGADGET|WFLG_ACTIVATE,
	IDCMP_CLOSEWINDOW|IDCMP_REFRESHWINDOW|BUTTONIDCMP|SLIDERIDCMP,
	"Play"
};



static struct Process *PlayerProc = NULL;
static struct MsgPort *PlayerPort = NULL;

static Class		*VImageClass = NULL;
static struct Image	*ButtonFrame = NULL;
static WORD			 ButtonFrameWidth;
static WORD			 ButtonFrameHeight;



/*************************/
/* Play window functions */
/*************************/


static struct Gadget *CreateVImageButton (Class *cl, struct NewGadget *ng)
{
	struct Gadget	*VButton;
	struct Image	*VImage;


	if (!(VImage = (struct Image *)NewObject (VImageClass, NULL,
		IA_Width,		ng->ng_Width - ButtonFrameWidth,
		IA_Height,		ng->ng_Height - ButtonFrameHeight,
		SYSIA_Which,	ng->ng_Flags,
		TAG_DONE)))
		return NULL;

	if (!(VButton = (struct Gadget *)NewObject (NULL, FRBUTTONCLASS,
		GA_ID,				ng->ng_GadgetID,
		GA_UserData,		ng->ng_UserData,
		GA_Left,			ng->ng_LeftEdge,
		GA_Top,				ng->ng_TopEdge,
		GA_Image,			ButtonFrame,
		GA_LabelImage,		VImage,
		GA_RelVerify,		TRUE,
		TAG_DONE)))
		DisposeObject (VImage);

	return VButton;
}


static void DeleteVImageButton (struct Gadget *g)
{
	if (g)
	{
		DisposeObject (g->GadgetText);
		DisposeObject (g);
	}
}



LONG OpenPlayWindow (void)
{
	if (PlayWUD.Win)
	{
		RevealWindow (&PlayWUD);
		return 0;
	}


	if (!(LastErr = SetupPlayer()))
	{
		if (VImageClass = InitVImageClass ())
		{
			if (ButtonFrame = NewObject (NULL, FRAMEICLASS,
				IA_FrameType,	FRAME_BUTTON,
				IA_EdgesOnly,	TRUE,
				TAG_DONE))
			{
				{
					struct IBox FrameBox,
								ContentsBox = { 0 };

					DoMethod ((Object *)ButtonFrame, IM_FRAMEBOX, &ContentsBox, &FrameBox, FRAMEF_SPECIFY);

					ButtonFrameWidth = FrameBox.Width;
					ButtonFrameHeight = FrameBox.Height;
				}

				if (MyOpenWindow (&PlayWUD))
				{
					UpdatePlay();
					return 0;
				}

				DisposeObject (ButtonFrame); ButtonFrame = NULL;
			}

			FreeVImageClass (VImageClass);	VImageClass = NULL;
		}

		CleanupPlayer();
	}

	return 1;
}



void ClosePlayWindow (void)
{
	MyCloseWindow (PlayWUD.Win);

	DeleteVImageButton (PlayWUD.Gadgets[GD_PlayPlay]);	PlayWUD.Gadgets[GD_PlayPlay] = NULL;
	DeleteVImageButton (PlayWUD.Gadgets[GD_PlayRew]);	PlayWUD.Gadgets[GD_PlayRew] = NULL;
	DeleteVImageButton (PlayWUD.Gadgets[GD_PlayFwd]);	PlayWUD.Gadgets[GD_PlayFwd] = NULL;
	DeleteVImageButton (PlayWUD.Gadgets[GD_PlayStop]);	PlayWUD.Gadgets[GD_PlayStop] = NULL;

	if (ButtonFrame)
	{
		DisposeObject (ButtonFrame);
		ButtonFrame = NULL;
	}

	if (VImageClass)
	{
		FreeVImageClass (VImageClass);
		VImageClass = NULL;
	}

	CleanupPlayer ();
}



void UpdatePlay (void)
{

}



LONG SetupPlayer (void)
{
	LONG err;
	BPTR PlayerSegList;

	if (PlayerProc) return RETURN_OK;

	if (PlayerPort = CreateMsgPort())
	{
		if (PlayerSegList = NewLoadSeg ("PROGDIR:Players/32Channels.player", NULL))
		{
			if (PlayerProc = CreateNewProcTags (
				NP_Seglist,		PlayerSegList,
				NP_FreeSeglist,	TRUE,
				NP_Name,		"XModule Player",
				NP_Priority,	25,
				NP_WindowPtr,	NULL,
				//NP_Input,		NULL,
				//NP_Output,		NULL,
				//NP_Error,		NULL,
				NP_CopyVars,	FALSE,
				TAG_DONE))
			{
				struct PlayerCmd dummy;

				dummy.pcmd_Message.mn_ReplyPort = PlayerPort;
				dummy.pcmd_ID = PCMD_SETUP;

				PutMsg (&PlayerProc->pr_MsgPort, (struct Message *)&dummy);

				WaitPort (PlayerPort);
				GetMsg (PlayerPort);

				if (!dummy.pcmd_Err)
	 				return RETURN_OK;

				/* Error cleanup */

				ShowRequest (MSG_PLAYER_INIT_ERR, 0, dummy.pcmd_Err);
				CleanupPlayer();
				return dummy.pcmd_Err;
			}
			else
				err = ERROR_NO_FREE_STORE;

			UnLoadSeg (PlayerSegList);
		}
		else
			ShowFault (MSG_CANT_OPEN_PLAYER, TRUE);

		DeleteMsgPort (PlayerPort);	PlayerPort = NULL;
	}
	else
		err = ERROR_NO_FREE_STORE;

	return err;
}



void CleanupPlayer (void)
{
	if (PlayerProc)
	{
		/* Signal player process to give up.  dos.library will
		 * automatically UnLoadSeg() its code.
		 */
		Signal ((struct Task *)PlayerProc, SIGBREAKF_CTRL_C);
		PlayerProc = NULL;

		DeleteMsgPort (PlayerPort);	PlayerPort = NULL;
	}
}



/****************/
/* Play Gadgets */
/****************/

static void PlayPlayClicked (void)
{
	ShowRequestStr ("Enjoy the silence...\n\n"
		"Sorry, XModule replay code is still under developement.\n"
		"I'm adapting the DeliTracker 14bit-NotePlayer mixing engine\n"
		"to XModule's internal module format, which will allow\n"
		"upto 32 channels with 14bit stereo output at 60Khz max,\n"
		"provided your machine is fast enough.",
		"Incredible!", NULL);
}



static void PlayRewClicked (void)
{
/*
	struct PlayerCmd cmd;

	cmd.pcmd_Message.mn_ReplyPort = PlayerPort;
	cmd.pcmd_ID = PCMD_INIT;
	cmd.pcmd_Data = songinfo;

	PutMsg (&PlayerProc->pr_MsgPort, (struct Message *)&cmd);

	WaitPort (PlayerPort);
	GetMsg (PlayerPort);

	ShowString ("%ld", &cmd.pcmd_Err);
*/
}


static void PlayFwdClicked (void)
{
/*
	struct PlayerCmd cmd;

	cmd.pcmd_Message.mn_ReplyPort = PlayerPort;
	cmd.pcmd_ID = PCMD_PLAY;
	cmd.pcmd_Data = songinfo;

	PutMsg (&PlayerProc->pr_MsgPort, (struct Message *)&cmd);

	WaitPort (PlayerPort);
	GetMsg (PlayerPort);
*/
}


static void PlayStopClicked (void)
{
}


static void PlayVolClicked (void)
{
}


static void PlayTimeResetClicked (void)
{
}
