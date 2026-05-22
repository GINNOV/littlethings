/*
* This file is part of Abacus.
* Copyright (C) 1997 Kai Nickel
* 
* Abacus is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Abacus is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Abacus.  If not, see <http://www.gnu.org/licenses/>.
*
*/
/****************************************************************************************
	BoardWindow.cpp
-----------------------------------------------------------------------------------------

  CL_BoardWindow (Window)

-----------------------------------------------------------------------------------------
	03.01.1997
****************************************************************************************/

#include <pragma/gadtools_lib.h>

#include "BoardWindow.hpp"
#include "BoardClass.hpp"
#include "Abacus.hpp"
#include "Tools.hpp"
#include "Settings.hpp"
#include "Images.hpp"

#include "images/IMG_Start.c"
#include "images/IMG_Undo.c"
#include "images/IMG_Settings.c"
#include "images/IMG_Quit.c"
#include "images/IMG_Rules.c"

MUI_CustomClass *CL_BoardWindow;


/****************************************************************************************
	Quit
****************************************************************************************/

ULONG BoardWindow_Quit(struct IClass* cl, Object* obj, Msg msg)
{
	struct BoardWindow_Data* data = (BoardWindow_Data*)INST_DATA(cl, obj);
	Object* app = (Object*)xget(obj, MUIA_ApplicationObject);
	if (MUI_RequestA(app, obj, 0, GetStr(MSG_QUIT_TITLE),
              		 GetStr(MSG_QUIT_GADGETS), GetStr(MSG_QUIT_TEXT), NULL) == 1)
		DoMethod(app, MUIM_Application_ReturnID, MUIV_Application_ReturnID_Quit);
	return 0;
}


/****************************************************************************************
	NewSettings
****************************************************************************************/

ULONG BoardWindow_NewSettings(struct IClass* cl, Object* obj, Msg msg)
{
	struct BoardWindow_Data* data = (BoardWindow_Data*)INST_DATA(cl, obj);
	Object*   app = (Object*	)xget(obj, MUIA_ApplicationObject);
	Settings* s 	= (Settings*)xget(app, MUIA_Abacus_Settings);
	DoMethod(data->Board, MUIM_Board_NewSettings);

	setatt(data->TX_Player1, MUIA_Text_Contents	 , s->name1	 );
	setatt(data->TX_Player2, MUIA_Text_Contents	 , s->name2	 );
	setatt(data->PD_Player1, MUIA_Pendisplay_Spec, &s->color1);
	setatt(data->PD_Player2, MUIA_Pendisplay_Spec, &s->color2);

	return 0;
}


/****************************************************************************************
	New
****************************************************************************************/


ULONG BoardWindow_New(struct IClass* cl, Object* obj, struct opSet* msg)
{
	Object *BT_New,   *BT_Quit, *BT_Settings, *strip, *BT_About, 
				 *BT_Rules, *BT_Undo;
	BoardWindow_Data tmp;

	enum 
	{
		MEN_NEW = 1, MEN_ICONIFY, MEN_HELP, MEN_RULES, MEN_QUIT, MEN_COMPUTER,
		MEN_SAVE, MEN_LOAD,	MEN_UNDO, MEN_SETABACUS, MEN_SETMUI, MEN_ABOUT,
	};

	struct NewMenu Menu[] =
	{
		{ NM_TITLE, GetStr(MSG_MENU_PROJECT) 		 		, 0, 0, 0, (APTR)0          	},
		{ NM_ITEM,  GetStr(MSG_MENU_PROJECT_NEW) 		, 0, 0, 0, (APTR)MEN_NEW    	},
		{ NM_ITEM,  GetStr(MSG_MENU_PROJECT_SAVE)		, 0, 0, 0, (APTR)MEN_SAVE  		},
		{ NM_ITEM,  GetStr(MSG_MENU_PROJECT_LOAD)		, 0, 0, 0, (APTR)MEN_LOAD  		},
		{ NM_ITEM,  NM_BARLABEL          		 				, 0, 0, 0, (APTR)0          	},
		{ NM_ITEM,  GetStr(MSG_MENU_PROJECT_ABOUT)	, 0, 0, 0, (APTR)MEN_ABOUT		},
		{ NM_ITEM,  GetStr(MSG_MENU_PROJECT_RULES)	, 0, 0, 0, (APTR)MEN_RULES		},
		{ NM_ITEM,  GetStr(MSG_MENU_PROJECT_HELP) 	, 0, 0, 0, (APTR)MEN_HELP			},
		{ NM_ITEM,  NM_BARLABEL          		 				, 0, 0, 0, (APTR)0          	},
		{ NM_ITEM,  GetStr(MSG_MENU_PROJECT_ICONIFY), 0, 0, 0, (APTR)MEN_ICONIFY	},
		{ NM_ITEM,  GetStr(MSG_MENU_PROJECT_QUIT)   , 0, 0, 0, (APTR)MEN_QUIT   	},

		{ NM_TITLE, GetStr(MSG_MENU_MOVE) 		 			, 0, 0, 0, (APTR)0           	},
		{ NM_ITEM,  GetStr(MSG_MENU_MOVE_UNDO)      , 0, 0, 0, (APTR)MEN_UNDO		 	},
		{ NM_ITEM,  GetStr(MSG_MENU_MOVE_COMPUTER)  , 0, 0, 0, (APTR)MEN_COMPUTER	},

		{ NM_TITLE, GetStr(MSG_MENU_SETTINGS) 			, 0, 0, 0, (APTR)0           	},
		{ NM_ITEM,  GetStr(MSG_MENU_SETTINGS_ABACUS), 0, 0, 0, (APTR)MEN_SETABACUS},
		{ NM_ITEM,  GetStr(MSG_MENU_SETTINGS_MUI)		, 0, 0, 0, (APTR)MEN_SETMUI 	},

		{ NM_END ,  NULL                 		 		, 0, 0, 0, (APTR)0          	},
	};

	obj = (Object*)DoSuperNew(cl, obj,
		MUIA_Window_Title		 , GetStr(MSG_BOARD_TITLE),
		MUIA_Window_ID   		 , MAKE_ID('B','W','I','N'),
		MUIA_HelpNode        , "MAINWINDOW",
		MUIA_Window_Menustrip, 
			strip = MUI_MakeObject(MUIO_MenustripNM, Menu, MUIO_MenustripNM_CommandKeyCheck),
		WindowContents, HGroup,

			Child, tmp.Board = (Object*)NewObject(CL_Board->mcc_Class , NULL,	TAG_DONE),

      Child, VBar(),

			Child, VGroup, MUIA_Weight, 1,

				Child, BT_About = VGroup,
					MUIA_InputMode  	, MUIV_InputMode_RelVerify,
					MUIA_ShowSelState , FALSE,
			      Child, MakeImage(IMG_Logo_body, IMG_LOGO_WIDTH, IMG_LOGO_HEIGHT, IMG_LOGO_DEPTH, 
														 IMG_LOGO_COMPRESSION, IMG_LOGO_MASKING, IMG_Save_colors),
			      Child, MakeImage(IMG_Abacus_body, IMG_ABACUS_WIDTH, IMG_ABACUS_HEIGHT, IMG_ABACUS_DEPTH,
														 IMG_ABACUS_COMPRESSION, IMG_ABACUS_MASKING, IMG_Save_colors),
					End,

				Child, HVSpace,
				Child, ColGroup(2),
					Child, tmp.TX_Player1 = TextObject, End,
					Child, tmp.PD_Player1 = MUI_NewObject(MUIC_Pendisplay, TAG_DONE),
					Child, tmp.TX_Player2 = TextObject, End,
					Child, tmp.PD_Player2 = MUI_NewObject(MUIC_Pendisplay, TAG_DONE),
					End,
				Child, HVSpace,


				Child, BT_New 			= MakeImageTextButton(MSG_BOARD_NEW, MSG_BOARD_NEW_HELP,
                       		                        MSG_BOARD_NEW_CHAR, IMG_Start_body),
		    Child, BT_Undo  		= MakeImageTextButton(MSG_BOARD_UNDO, MSG_BOARD_UNDO_HELP,
       			                                      MSG_BOARD_UNDO_CHAR, IMG_Undo_body),
				Child, BT_Settings  = MakeImageTextButton(MSG_BOARD_SETTINGS, MSG_BOARD_SETTINGS_HELP, 
                                                  MSG_BOARD_SETTINGS_CHAR, IMG_Settings_body),
				Child, BT_Rules     = MakeImageTextButton(MSG_BOARD_RULES, MSG_BOARD_RULES_HELP, 
                                                  MSG_BOARD_RULES_CHAR, IMG_Rules_body),
				Child, BT_Quit      = MakeImageTextButton(MSG_BOARD_QUIT, MSG_BOARD_QUIT_HELP, 
                                                  MSG_BOARD_QUIT_CHAR, IMG_Quit_body),

				Child, HVSpace,


				End,

			End,
		TAG_MORE, msg->ops_AttrList);

	if (obj)
	{
		DoMethod(obj        , MUIM_Notify, MUIA_Window_CloseRequest, TRUE , obj                    	, 1, MUIM_BoardWindow_Quit);
		DoMethod(BT_Quit    , MUIM_Notify, MUIA_Pressed            , FALSE, obj											, 1, MUIM_BoardWindow_Quit);
		DoMethod(BT_New			, MUIM_Notify, MUIA_Pressed            , FALSE, tmp.Board								, 1, MUIM_Board_NewGame);
		DoMethod(BT_Undo		, MUIM_Notify, MUIA_Pressed            , FALSE, tmp.Board  							, 1, MUIM_Board_Undo);
		DoMethod(BT_Settings, MUIM_Notify, MUIA_Pressed            , FALSE, MUIV_Notify_Application	, 1, MUIM_Abacus_EditSettings);
		DoMethod(BT_About  	, MUIM_Notify, MUIA_Pressed            , FALSE, MUIV_Notify_Application	, 1, MUIM_Abacus_About);
		DoMethod(BT_Rules  	, MUIM_Notify, MUIA_Pressed            , FALSE, MUIV_Notify_Application	, 1, MUIM_Abacus_Rules);

  	DoMethod(MenuObj(strip, MEN_HELP       ), MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime, MUIV_Notify_Application, 5, MUIM_Application_ShowHelp, NULL, "Abacus.guide", "MAIN", 0);
		DoMethod(MenuObj(strip, MEN_ICONIFY    ), MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime, MUIV_Notify_Application, 3, MUIM_Set, MUIA_Application_Iconified, TRUE);
		DoMethod(MenuObj(strip, MEN_QUIT    	 ), MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime, obj										 , 1, MUIM_BoardWindow_Quit);
		DoMethod(MenuObj(strip, MEN_NEW	   	 	 ), MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime, tmp.Board							 , 1, MUIM_Board_NewGame);
		DoMethod(MenuObj(strip, MEN_UNDO    	 ), MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime, tmp.Board  						 , 1, MUIM_Board_Undo);
		DoMethod(MenuObj(strip, MEN_COMPUTER 	 ), MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime, tmp.Board							 , 1, MUIM_Board_ComputerMove);
		DoMethod(MenuObj(strip, MEN_LOAD    	 ), MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime, tmp.Board	 						 , 1, MUIM_Board_Load);
		DoMethod(MenuObj(strip, MEN_SAVE    	 ), MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime, tmp.Board	 						 , 1, MUIM_Board_Save);
		DoMethod(MenuObj(strip, MEN_SETABACUS	 ), MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime, MUIV_Notify_Application, 1, MUIM_Abacus_EditSettings);
		DoMethod(MenuObj(strip, MEN_SETMUI  	 ), MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime, MUIV_Notify_Application, 2, MUIM_Application_OpenConfigWindow, 0);
		DoMethod(MenuObj(strip, MEN_ABOUT   	 ), MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime, MUIV_Notify_Application, 1, MUIM_Abacus_About);
		DoMethod(MenuObj(strip, MEN_RULES   	 ), MUIM_Notify, MUIA_Menuitem_Trigger, MUIV_EveryTime, MUIV_Notify_Application, 1, MUIM_Abacus_Rules);

		struct BoardWindow_Data* data = (BoardWindow_Data*)INST_DATA(cl, obj);
		*data = tmp;

		setatt(obj, MUIA_BoardWindow_ActivePlayer, 1);

		return (ULONG)obj;
	}
	return 0;
}


/****************************************************************************************
	Set
****************************************************************************************/

ULONG BoardWindow_Set(struct IClass* cl, Object* obj, struct opSet* msg)
{
	struct BoardWindow_Data* data = (BoardWindow_Data*)INST_DATA(cl, obj);
	struct TagItem *tag;

  tag = FindTagItem(MUIA_BoardWindow_ActivePlayer, msg->ops_AttrList);
	if (tag)
	{
		ULONG player = tag->ti_Data;
		Object* app = (Object*	)xget(obj, MUIA_ApplicationObject);
		Settings* s = (Settings*)xget(app, MUIA_Abacus_Settings);
		switch (player)
		{
			case 0: 
				setatt(data->TX_Player1, MUIA_Background, MUII_BACKGROUND);
				setatt(data->TX_Player2, MUIA_Background, MUII_BACKGROUND);
				break;
			case 1: 
				setatt(data->TX_Player1, MUIA_Background, MUII_FILL);
				setatt(data->TX_Player2, MUIA_Background, MUII_BACKGROUND);
				break;
			case 2:
				setatt(data->TX_Player1, MUIA_Background, MUII_BACKGROUND);
				setatt(data->TX_Player2, MUIA_Background, MUII_FILL);
				break;
		}
		return TRUE;
	}

  return DoSuperMethodA(cl, obj, (Msg)msg);
}


/****************************************************************************************
	Dispatcher
****************************************************************************************/

SAVEDS ASM ULONG BoardWindow_Dispatcher(REG(a0) struct IClass* cl, 
																				REG(a2) Object* 			 obj, 
																				REG(a1) Msg 					 msg)
{
	switch(msg->MethodID)
	{
		case OM_NEW                     	: return(BoardWindow_New         (cl, obj, (opSet*)msg));
		case OM_SET      			            : return(BoardWindow_Set         (cl, obj, (opSet*)msg));
		case MUIM_BoardWindow_Quit      	: return(BoardWindow_Quit        (cl, obj, msg));
		case MUIM_BoardWindow_NewSettings	: return(BoardWindow_NewSettings (cl, obj, msg));
	}
	return DoSuperMethodA(cl, obj, msg);
}
