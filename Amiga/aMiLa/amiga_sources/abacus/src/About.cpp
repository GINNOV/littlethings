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
	About.cpp
-----------------------------------------------------------------------------------------

  CL_About (Window)

-----------------------------------------------------------------------------------------
	01.01.1996
****************************************************************************************/

#include "About.hpp"
#include "Tools.hpp"
#include "Images.hpp"
#include <stdio.h>    // für sprintf

MUI_CustomClass *CL_About;


/****************************************************************************************
	AboutMUI
****************************************************************************************/

ULONG About_AboutMUI(struct IClass* cl, Object* obj, Msg msg)
{
	struct About_Data* data = (About_Data*)INST_DATA(cl, obj);
	Object* app = (Object*)xget(obj, MUIA_ApplicationObject);
	Object* aboutwin = AboutmuiObject,
                       MUIA_Window_RefWindow    , obj,
                       MUIA_Aboutmui_Application, app,
                       End;
	if (aboutwin) setatt(aboutwin, MUIA_Window_Open, TRUE);
	return 0;
}


/****************************************************************************************
	New
****************************************************************************************/

ULONG About_New(struct IClass* cl, Object* obj, struct opSet* msg)
{
	Object *BT_Ok, *BT_MUI;
	About_Data tmp;

	static char version_text[50];
	sprintf(version_text, GetStr(MSG_ABOUT_VERSION), version_number, version_date);

	obj = (Object*)DoSuperNew(cl, obj,
		MUIA_HelpNode        	 , "COPYRIGHT",
		MUIA_Window_LeftEdge   , MUIV_Window_LeftEdge_Centered,
		MUIA_Window_TopEdge    , MUIV_Window_TopEdge_Centered,
		MUIA_Window_CloseGadget, FALSE,
		MUIA_Window_DepthGadget, FALSE,
		MUIA_Window_SizeGadget , FALSE,
		MUIA_Window_DragBar    , FALSE,
		MUIA_Window_Borderless , TRUE,

		WindowContents, VGroup, ButtonFrame,

			Child, HGroup,
				Child, HVSpace,
	      Child, MakeImage(IMG_Logo_body, IMG_LOGO_WIDTH, IMG_LOGO_HEIGHT, 
	      								 IMG_LOGO_DEPTH, IMG_LOGO_COMPRESSION, IMG_LOGO_MASKING, 
	      								 IMG_Abacus_colors),
				Child, VGroup,
		      Child, MakeImage(IMG_Abacus_body, IMG_ABACUS_WIDTH, IMG_ABACUS_HEIGHT, 
		      								 IMG_ABACUS_DEPTH, IMG_ABACUS_COMPRESSION, 
		      								 IMG_ABACUS_MASKING, IMG_Abacus_colors),
					Child, TextObject,
						MUIA_Text_Contents, version_text,
						MUIA_Font   		  , MUIV_Font_Tiny,
						End,
					End,
				Child, HVSpace,
				End,

			Child, HBar(),

			Child, HGroup,
				Child, HVSpace,
				Child, TextObject,
					MUIA_Text_Contents, GetStr(MSG_ABOUT_TEXT),
					End,
				Child, HVSpace,
				End,

			Child, HBar(),
			Child, HGroup,
				Child, BT_Ok     = MakeButton(MSG_ABOUT_OK , MSG_ABOUT_OK_HELP ),
				Child, BT_MUI    = MakeButton(MSG_ABOUT_MUI, MSG_ABOUT_MUI_HELP),
				End,

			End,

		TAG_MORE, msg->ops_AttrList);

	if (obj)
	{
		DoMethod(obj   , MUIM_Notify, MUIA_Window_CloseRequest, TRUE , obj, 3, MUIM_Set, MUIA_Window_Open, FALSE);
		DoMethod(BT_Ok , MUIM_Notify, MUIA_Pressed            , FALSE, obj, 3, MUIM_Set, MUIA_Window_Open, FALSE);
		DoMethod(BT_MUI, MUIM_Notify, MUIA_Pressed            , FALSE, obj, 1, MUIM_About_AboutMUI);



		struct About_Data* data = (About_Data*)INST_DATA(cl, obj);
		*data = tmp;
		return (ULONG)obj;
	}
	return 0;
}


/****************************************************************************************
	Dispatcher
****************************************************************************************/

SAVEDS ASM ULONG About_Dispatcher(REG(a0) struct IClass* cl, 
											 					  REG(a2) Object* 				obj, 
												  			  REG(a1) Msg 						msg)
{
	switch(msg->MethodID)
	{
		case OM_NEW							: return(About_New     (cl, obj, (opSet*)msg));
		case MUIM_About_AboutMUI: return(About_AboutMUI(cl, obj, msg));
	}
	return DoSuperMethodA(cl, obj, msg);
}
