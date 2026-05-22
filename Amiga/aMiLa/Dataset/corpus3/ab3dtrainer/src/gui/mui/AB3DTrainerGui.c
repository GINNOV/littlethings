#ifndef MAKE_ID
#define MAKE_ID(a,b,c,d) ((ULONG) (a)<<24 | (ULONG) (b)<<16 | (ULONG) (c)<<8 | (ULONG) (d))
#endif

#ifdef _DCC
#define __inline
#endif

#include "AB3DTrainerGui.h"

struct ObjApp * CreateApp(void)
{
	struct ObjApp * Object;

	APTR	GROUP_ROOT, GR_TRAINER, LA_ENERGY, LA_AMMO, Space0, Space1, LA_HACK;
	APTR	GR_CONTROL, Space2, GR_START;

	if (!(Object = AllocVec(sizeof(struct ObjApp), MEMF_PUBLIC|MEMF_CLEAR)))
		return(NULL);

	Object->CY_CONTROLContent[0] = "No change";
	Object->CY_CONTROLContent[1] = "Force Joystick";
	Object->CY_CONTROLContent[2] = "Force Joypad";
	Object->CY_CONTROLContent[3] = NULL;

	LA_ENERGY = Label("Infinite Energy");

	Object->CH_ENERGY = KeyCheckMark(FALSE, 'E');

	LA_AMMO = Label("Infinite Ammunition");

	Object->CH_AMMO = KeyCheckMark(FALSE, 'A');

	Space0 = VSpace(10);

	Space1 = VSpace(10);

	LA_HACK = Label("Use HackAB3D");

	Object->CH_HACK = CheckMark(FALSE);

	GR_TRAINER = GroupObject,
		MUIA_HelpNode, "GR_TRAINER",
		MUIA_Frame, MUIV_Frame_Group,
		MUIA_FrameTitle, "Trainers",
		MUIA_Group_Columns, 2,
		Child, LA_ENERGY,
		Child, Object->CH_ENERGY,
		Child, LA_AMMO,
		Child, Object->CH_AMMO,
		Child, Space0,
		Child, Space1,
		Child, LA_HACK,
		Child, Object->CH_HACK,
	End;

	Object->CY_CONTROL = CycleObject,
		MUIA_HelpNode, "CY_CONTROL",
		MUIA_Cycle_Entries, Object->CY_CONTROLContent,
	End;

	GR_CONTROL = GroupObject,
		MUIA_HelpNode, "GR_CONTROL",
		MUIA_Frame, MUIV_Frame_Group,
		MUIA_FrameTitle, "Control Method",
		Child, Object->CY_CONTROL,
	End;

	Space2 = VSpace(10);

	Object->BT_PLAY = SimpleButton("_Play");

	Object->BT_CANCEL = SimpleButton("_Cancel");

	GR_START = GroupObject,
		MUIA_HelpNode, "GR_START",
		MUIA_Group_Columns, 2,
		Child, Object->BT_PLAY,
		Child, Object->BT_CANCEL,
	End;

	GROUP_ROOT = GroupObject,
		Child, GR_TRAINER,
		Child, GR_CONTROL,
		Child, Space2,
		Child, GR_START,
	End;

	Object->WI_Main = WindowObject,
		MUIA_Window_Title, "AB3DTrainer",
		MUIA_Window_ID, MAKE_ID('0', 'W', 'I', 'N'),
		MUIA_Window_NoMenus, TRUE,
		WindowContents, GROUP_ROOT,
	End;

	Object->App = ApplicationObject,
		MUIA_Application_Author, "John Girvin",
		MUIA_Application_Base, "AB3DTRAINER",
		MUIA_Application_Title, "AB3DTrainer",
		MUIA_Application_Version, "$VER: 3.02",
		MUIA_Application_Copyright, "Halibut Software",
		SubWindow, Object->WI_Main,
	End;


	if (!Object->App)
	{
		FreeVec(Object);
		return(NULL);
	}

	DoMethod(Object->App,
		MUIM_Notify, MUIA_Application_Iconified, TRUE,
		Object->App,
		3,
		MUIM_Set, MUIA_Application_Sleep, TRUE
		);

	DoMethod(Object->App,
		MUIM_Notify, MUIA_Application_Iconified, FALSE,
		Object->App,
		3,
		MUIM_Set, MUIA_Application_Sleep, FALSE
		);

	DoMethod(Object->WI_Main,
		MUIM_Notify, MUIA_Window_CloseRequest, TRUE,
		Object->App,
		2,
		MUIM_Application_ReturnID, MUIV_Application_ReturnID_Quit
		);

	DoMethod(Object->WI_Main,
		MUIM_Window_SetCycleChain, Object->CH_ENERGY,
		Object->CH_AMMO,
		Object->CH_HACK,
		Object->CY_CONTROL,
		Object->BT_PLAY,
		Object->BT_CANCEL,
		0
		);

	set(Object->WI_Main,
		MUIA_Window_Open, TRUE
		);


	return(Object);
}

void DisposeApp(struct ObjApp * Object)
{
	MUI_DisposeObject(Object->App);
	FreeVec(Object);
}
