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
	Settings.cpp
-----------------------------------------------------------------------------------------

  CL_Settings (Window)

-----------------------------------------------------------------------------------------
	03.01.1997
****************************************************************************************/

#include "Settings.hpp"
#include "Abacus.hpp"
#include "Tools.hpp"
#include "Images.hpp"
#include "images/IMG_Prefs.c"

MUI_CustomClass *CL_Settings;


/****************************************************************************************
	Close
****************************************************************************************/

ULONG Settings_Close(struct IClass* cl, Object* obj, struct MUIP_Settings_Close* msg)
{
	struct Settings_Data* data = (Settings_Data*)INST_DATA(cl, obj);
	setatt(obj, MUIA_Window_Open, FALSE);
	Object* app;
	getatt(obj, MUIA_ApplicationObject, &app);
	switch (msg->typ) 
  {
		case 0: DoMethod(app, MUIM_Application_Load, MUIV_Application_Load_ENV); 
						break;
		case 1:	DoMethod(app, MUIM_Application_Save, MUIV_Application_Save_ENVARC);	// Fallthrough
		case 2:	DoMethod(app, MUIM_Application_Save, MUIV_Application_Save_ENV   );
						setatt(app, MUIA_Abacus_Settings, xget(obj, MUIA_Settings_Settings));
	}
	return 0;
}


/****************************************************************************************
	Get
****************************************************************************************/

ULONG Settings_Get(struct IClass* cl, Object* obj, struct opGet* msg)
{
	struct Settings_Data* data = (Settings_Data*)INST_DATA(cl, obj);
	switch (msg->opg_AttrID)
	{
		case MUIA_Settings_Settings:
			Settings* s = &data->settings;

			s->color1 = *(MUI_PenSpec*)xget(data->PP_Color1, MUIA_Pendisplay_Spec);
			s->color2 = *(MUI_PenSpec*)xget(data->PP_Color2, MUIA_Pendisplay_Spec);
			s->color3 = *(MUI_PenSpec*)xget(data->PP_Color3, MUIA_Pendisplay_Spec);
			s->color4 = *(MUI_PenSpec*)xget(data->PP_Color4, MUIA_Pendisplay_Spec);
			s->dirs		= 					(int)xget(data->CH_Dirs	 , MUIA_Selected     	 );
			s->auto2	= 					(int)xget(data->CH_Auto2 , MUIA_Selected     	 );
			s->depth2	= 					(int)xget(data->NU_Depth2, MUIA_Slider_Level	 );
			strcpy(s->name1, StringContents(data->ST_Name1));
			strcpy(s->name2, StringContents(data->ST_Name2));
			*(msg->opg_Storage) = (ULONG)s;
			return(TRUE);
	}
  return(DoSuperMethodA(cl, obj, (Msg)msg));
}


/****************************************************************************************
	New
****************************************************************************************/

ULONG Settings_New(struct IClass* cl, Object* obj, struct opSet* msg)
{
	Object *BT_Save, *BT_Use, *BT_Cancel;
	Settings_Data tmp;
	enum {ID_COLOR1 = 10, ID_COLOR2, ID_COLOR3, ID_COLOR4, ID_NAME1, ID_NAME2,
				ID_DIRS, ID_AUTO2, ID_DEPTH2};

	static char* PG_Pages[3];
	PG_Pages[0] =	GetStr(MSG_SETTINGS_PLAYER);
	PG_Pages[1] =	GetStr(MSG_SETTINGS_MISC);
	PG_Pages[2] =	NULL;


	obj = (Object*)DoSuperNew(cl, obj,
		MUIA_Window_Title		   , GetStr(MSG_SETTINGS_TITLE),
		MUIA_Window_ID   		   , MAKE_ID('A','S','E','T'),
		MUIA_Window_CloseGadget, FALSE,
		MUIA_HelpNode          , "SETTINGS",
		WindowContents, VGroup,

			Child, HGroup,
				Child, MakeImage(IMG_Prefs_body, IMG_PREFS_WIDTH, IMG_PREFS_HEIGHT, 
				                 IMG_PREFS_DEPTH, IMG_PREFS_COMPRESSION, IMG_PREFS_MASKING, 
				                 IMG_Save_colors),
				Child, TextObject,
					MUIA_Text_Contents, GetStr(MSG_SETTINGS_TOPIC),
					End,
				Child, HVSpace,
				End,


			Child, RegisterGroup(PG_Pages),
				MUIA_Register_Frame, TRUE,

				/*
				**	Player
				*/

				Child, VGroup,
					Child, HGroup,
						Child, ColGroup(2), GroupFrameT(GetStr(MSG_SETTINGS_PLAYER1)),
							Child, MakeLabel2(MSG_SETTINGS_NAME1),
							Child, tmp.ST_Name1 = MakeString(10, MSG_SETTINGS_NAME1, "Human", MSG_SETTINGS_NAME1_HELP),
							Child, MakeFreeLabel(MSG_SETTINGS_COLOR1),
							Child, tmp.PP_Color1 = PoppenObject,
																		 	 MUIA_CycleChain	, 1,
																			 MUIA_Window_Title, GetStr(MSG_SETTINGS_COLOR1_REQ),
																			 MUIA_ShortHelp   , GetStr(MSG_SETTINGS_COLOR1_HELP),
																			 End,
							Child, HVSpace,
							Child, HVSpace,
							End,
	
						Child, ColGroup(2), GroupFrameT(GetStr(MSG_SETTINGS_PLAYER2)),
							Child, MakeLabel2(MSG_SETTINGS_NAME2),
							Child, tmp.ST_Name2 = MakeString(10, MSG_SETTINGS_NAME2, "Computer", MSG_SETTINGS_NAME2_HELP),
							Child, MakeFreeLabel(MSG_SETTINGS_COLOR2),
							Child, tmp.PP_Color2 = PoppenObject,
																		   MUIA_CycleChain	, 1,
																			 MUIA_Window_Title, GetStr(MSG_SETTINGS_COLOR2_REQ),
																			 MUIA_ShortHelp   , GetStr(MSG_SETTINGS_COLOR2_HELP),
																			 End,
							Child, MakeLLabel1(MSG_SETTINGS_AUTO2),
							Child, HGroup,
								Child, tmp.CH_Auto2  = MakeCheck(MSG_SETTINGS_AUTO2, FALSE, MSG_SETTINGS_AUTO2_HELP),
								Child, MakeLLabel1(MSG_SETTINGS_DEPTH),
								Child, tmp.NU_Depth2   = MakeSlider(1, 5, 1, MSG_SETTINGS_DEPTH,  MSG_SETTINGS_DEPTH_HELP),
								End,
							End,

						End,
					End,

				/*
				**	Misc
				*/

				Child, ColGroup(2),

					Child, MakeFreeLabel(MSG_SETTINGS_COLOR3),
					Child, tmp.PP_Color3 = PoppenObject,
																   MUIA_CycleChain	, 1,
																	 MUIA_Window_Title, GetStr(MSG_SETTINGS_COLOR3_REQ),
																	 MUIA_ShortHelp   , GetStr(MSG_SETTINGS_COLOR3_HELP),
																	 End,

					Child, MakeFreeLabel(MSG_SETTINGS_COLOR4),
					Child, tmp.PP_Color4 = PoppenObject,
																   MUIA_CycleChain	, 1,
																	 MUIA_Window_Title, GetStr(MSG_SETTINGS_COLOR4_REQ),
																	 MUIA_ShortHelp   , GetStr(MSG_SETTINGS_COLOR4_HELP),
																	 End,

					Child, MakeLLabel1(MSG_SETTINGS_DIRS),
					Child, HGroup,
						Child, tmp.CH_Dirs  = MakeCheck(MSG_SETTINGS_DIRS , TRUE, MSG_SETTINGS_DIRS_HELP),
						Child, HVSpace,
						End,
					End,

				End,


			Child, HGroup,
				Child, BT_Save   = MakeButton(MSG_SETTINGS_SAVE  , MSG_SETTINGS_SAVE_HELP  ),
				Child, BT_Use    = MakeButton(MSG_SETTINGS_USE   , MSG_SETTINGS_USE_HELP   ),
				Child, BT_Cancel = MakeButton(MSG_SETTINGS_CANCEL, MSG_SETTINGS_CANCEL_HELP),
				End,

			End,

		TAG_MORE, msg->ops_AttrList);

	if (obj)
	{
		DoMethod(BT_Cancel  , MUIM_Notify, MUIA_Pressed            , FALSE, obj, 2, MUIM_Settings_Close, 0);
		DoMethod(BT_Use     , MUIM_Notify, MUIA_Pressed            , FALSE, obj, 2, MUIM_Settings_Close, 2);
		DoMethod(BT_Save    , MUIM_Notify, MUIA_Pressed            , FALSE, obj, 2, MUIM_Settings_Close, 1);

	  setatt(tmp.PP_Color1, MUIA_ObjectID, ID_COLOR1);
	  setatt(tmp.PP_Color2, MUIA_ObjectID, ID_COLOR2);
	  setatt(tmp.PP_Color3, MUIA_ObjectID, ID_COLOR3);
	  setatt(tmp.PP_Color4, MUIA_ObjectID, ID_COLOR3);
	  setatt(tmp.ST_Name1	, MUIA_ObjectID, ID_NAME1);
	  setatt(tmp.ST_Name2	, MUIA_ObjectID, ID_NAME2);
	  setatt(tmp.CH_Dirs	, MUIA_ObjectID, ID_DIRS);
	  setatt(tmp.CH_Auto2	, MUIA_ObjectID, ID_AUTO2);
	  setatt(tmp.NU_Depth2, MUIA_ObjectID, ID_DEPTH2);

		DoMethod(tmp.PP_Color1, MUIM_Pendisplay_SetMUIPen, MPEN_SHINE);
		DoMethod(tmp.PP_Color2, MUIM_Pendisplay_SetMUIPen, MPEN_SHADOW);
		DoMethod(tmp.PP_Color3, MUIM_Pendisplay_SetMUIPen, MPEN_HALFSHADOW);
		DoMethod(tmp.PP_Color4, MUIM_Pendisplay_SetMUIPen, MPEN_MARK);

		DoMethod(tmp.CH_Auto2, MUIM_Notify, MUIA_Selected, MUIV_EveryTime, 
             tmp.NU_Depth2, 3, MUIM_Set, MUIA_Disabled, MUIV_NotTriggerValue);


		struct Settings_Data* data = (Settings_Data*)INST_DATA(cl, obj);
		*data = tmp;
		return((ULONG)obj);
	}
	return(0);
}


/****************************************************************************************
	Dispatcher
****************************************************************************************/

SAVEDS ASM ULONG Settings_Dispatcher(REG(a0) struct IClass* cl, 
																		 REG(a2) Object* 				obj, 
																		 REG(a1) Msg 						msg)
{
	switch(msg->MethodID)
	{
		case OM_NEW             : return(Settings_New   (cl, obj, (opSet*)msg));
		case OM_GET             : return(Settings_Get   (cl, obj, (opGet*)msg));
		case MUIM_Settings_Close: return(Settings_Close (cl, obj, (MUIP_Settings_Close*)msg));
	}
	return(DoSuperMethodA(cl, obj, msg));
}
