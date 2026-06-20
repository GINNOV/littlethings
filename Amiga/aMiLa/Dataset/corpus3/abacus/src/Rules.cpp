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
	Rules.cpp
-----------------------------------------------------------------------------------------

  CL_Rules (Window)

-----------------------------------------------------------------------------------------
	01.01.1997
****************************************************************************************/

#include "Rules.hpp"
#include "Tools.hpp"
#include "Images.hpp"
#include "images/IMG_Moves.c"
#include <stdio.h>    // für sprintf

MUI_CustomClass *CL_Rules;

/****************************************************************************************
	New
****************************************************************************************/

ULONG Rules_New(struct IClass* cl, Object* obj, struct opSet* msg)
{
	Object *BT_Ok, *BT_Help;
	Rules_Data tmp;

	static char version_text[50];
	sprintf(version_text, GetStr(MSG_ABOUT_VERSION), version_number, version_date);

	obj = (Object*)DoSuperNew(cl, obj,
		MUIA_Window_Title		 , GetStr(MSG_RULES_TITLE),
		MUIA_HelpNode        , "RULES",
		MUIA_Window_SizeGadget, FALSE,
		WindowContents, VGroup,

			Child, HGroup,
				Child, TextObject,
          MUIA_Text_Contents, GetStr(MSG_RULES_TEXT),
					End,

				Child, VGroup,
					Child, BodychunkObject,
						MUIA_Weight, 1,
						MUIA_FixWidth             , IMG_MOVES_WIDTH,
						MUIA_FixHeight            , IMG_MOVES_HEIGHT,
						MUIA_Bitmap_Width         , IMG_MOVES_WIDTH,
						MUIA_Bitmap_Height        , IMG_MOVES_HEIGHT,
						MUIA_Bodychunk_Depth      , IMG_MOVES_DEPTH,
						MUIA_Bodychunk_Body       , IMG_Moves_body,
						MUIA_Bodychunk_Compression, IMG_MOVES_COMPRESSION,
				  	MUIA_Bodychunk_Masking    , IMG_MOVES_MASKING,
						MUIA_Bitmap_SourceColors  , IMG_Abacus_colors,
						MUIA_Bitmap_Transparent   , 0,
						MUIA_ShowSelState 				, FALSE,
						End,
					Child, HVSpace,
					End,

				End,
	
			Child, HBar(),
 	    Child, HGroup,
				Child, BT_Help = MakeButton(MSG_RULES_HELP , MSG_RULES_HELP_HELP),
				Child, HVSpace,
				Child, BT_Ok   = MakeButton(MSG_ABOUT_OK , MSG_ABOUT_OK_HELP),
				End,
			End,

		TAG_MORE, msg->ops_AttrList);

	if (obj)
	{
		DoMethod(obj    , MUIM_Notify, MUIA_Window_CloseRequest, TRUE , obj, 3, MUIM_Set, MUIA_Window_Open, FALSE);
		DoMethod(BT_Ok  , MUIM_Notify, MUIA_Pressed            , FALSE, obj, 3, MUIM_Set, MUIA_Window_Open, FALSE);
  	DoMethod(BT_Help, MUIM_Notify, MUIA_Pressed            , FALSE, MUIV_Notify_Application, 5, MUIM_Application_ShowHelp, NULL, "Abacus.guide", "RULES", 0);


		struct Rules_Data* data = (Rules_Data*)INST_DATA(cl, obj);
		*data = tmp;
		return((ULONG)obj);
	}
	return 0;
}


/****************************************************************************************
	Dispatcher
****************************************************************************************/

SAVEDS ASM ULONG Rules_Dispatcher(REG(a0) struct IClass* cl, 
											 					  REG(a2) Object* 				obj, 
												  			  REG(a1) Msg 						msg)
{
	switch(msg->MethodID)
	{
		case OM_NEW	: return(Rules_New     (cl, obj, (opSet*)msg));
	}
	return DoSuperMethodA(cl, obj, msg);
}
