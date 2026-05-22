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
	MsgWin.cpp
-----------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------
	01.01.1997
****************************************************************************************/

#include "MsgWin.hpp"
#include "Tools.hpp"
#include "MCC.hpp"
#include "Images.hpp"

struct MUI_CustomClass *CL_MsgWin;


/****************************************************************************************
	New
****************************************************************************************/

ULONG MsgWin_New(struct IClass* cl, Object* obj, struct opSet* msg)
{
	MsgWin_Data tmp;
	Object* BT_Ok;

	char* txtbig   = (char*)GetTagData(MUIA_MsgWin_MsgBig	 , 0, msg->ops_AttrList);
	char* txtsmall = (char*)GetTagData(MUIA_MsgWin_MsgSmall, 0, msg->ops_AttrList);

	obj = (Object*)DoSuperNew(cl, obj,
		MUIA_Window_LeftEdge   , MUIV_Window_LeftEdge_Centered,
		MUIA_Window_TopEdge    , MUIV_Window_TopEdge_Centered,
		//MUIA_Window_Width      , MUIV_Window_Width_Visible(30),
		MUIA_Window_CloseGadget, FALSE,
		MUIA_Window_DepthGadget, FALSE,
		MUIA_Window_SizeGadget , FALSE,
		MUIA_Window_DragBar    , FALSE,
		MUIA_Window_Borderless , TRUE,


		WindowContents, VGroup, ButtonFrame,

			Child, TextObject,
				MUIA_Font         , MUIV_Font_Big,
				MUIA_Text_Contents, txtbig,
				End,

			Child, TextObject,
				MUIA_Text_Contents, txtsmall,
				End,

			Child, HBar(),
			Child, HGroup,
				Child, HVSpace,
				Child, BT_Ok = MUI_MakeObject(MUIO_Button, GetStr(MSG_WINNER_OK)),
				Child, HVSpace,
				End,

			End,
		TAG_MORE, msg->ops_AttrList);

	if (obj)
	{
		DoMethod(BT_Ok, MUIM_Notify, MUIA_Pressed, FALSE, 
						 MUIV_Notify_Application, 2, MUIM_Application_ReturnID, MUIV_MsgWin_Close);

		struct MsgWin_Data* data = (MsgWin_Data*)INST_DATA(cl, obj);
		*data = tmp;
		return (ULONG)obj;
	}
	return 0;
}


/****************************************************************************************
	Dispatcher
****************************************************************************************/

SAVEDS ASM ULONG MsgWin_Dispatcher(REG(a0) struct IClass* cl, 
																	 REG(a2) Object* 				obj, 
																	 REG(a1) Msg 						msg)
{
	switch(msg->MethodID)
	{
		case OM_NEW: return(MsgWin_New   (cl, obj, (opSet*)msg));
	}
	return DoSuperMethodA(cl, obj, msg);
}

