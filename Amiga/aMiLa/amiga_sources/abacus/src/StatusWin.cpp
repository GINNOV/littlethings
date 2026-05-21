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
	StatusWin.cpp
-----------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------
	29.12.1996
****************************************************************************************/

#include "StatusWin.hpp"
#include "Tools.hpp"
#include "MCC.hpp"
#include "Images.hpp"
#include "images/IMG_Time.c"

struct MUI_CustomClass *CL_StatusWin;


/****************************************************************************************
	StatusWin_Status
****************************************************************************************/

StatusWin_Status::StatusWin_Status(Object* appl, Object* refwin) 
{
	app = appl;
	swin = (Object*)NewObject(CL_StatusWin->mcc_Class, NULL,
														MUIA_Window_RefWindow  , refwin,
														TAG_DONE);
	if (!swin)
	{
		//ShowError(app, NULL, "Could not create MUI window!");
		return;
	}
	data = (StatusWin_Data*)INST_DATA(CL_StatusWin->mcc_Class, swin);

	err = 0;
	DoMethod(app, OM_ADDMEMBER, swin);
};

StatusWin_Status::~StatusWin_Status()
{
	DoMethod(app, OM_REMMEMBER, swin);
	DisposeObject(swin);
}

void StatusWin_Status::Init()
{	
	setatt(swin, MUIA_Window_Open, TRUE);
}

void StatusWin_Status::Exit() 				
{
	setatt(swin, MUIA_Window_Open, FALSE);
}

void StatusWin_Status::Update(int done, int max)
{	
	if (done != -1) 
	{
		setatt(data->GA_Status, MUIA_Gauge_Current, done);
		if (max != -1)
		{
			setatt(data->GA_Status, MUIA_Disabled, FALSE);
			setatt(data->GA_Status, MUIA_Gauge_Max, max);
		}
	}	
	else
		setatt(data->GA_Status, MUIA_Disabled, TRUE);
}

BOOL StatusWin_Status::Break()
{
	if (err != 0) return TRUE;
	ULONG sigs = 0;
	DoMethod(app, MUIM_Application_NewInput, &sigs);
  return !data->running;
}

void StatusWin_Status::SetInfo(int txt)
{
	setatt(data->GA_Status, MUIA_Gauge_InfoText, GetStr(txt));
}


/****************************************************************************************
	Break
****************************************************************************************/

ULONG StatusWin_Break(struct IClass* cl, Object* obj, Msg msg)
{
	struct StatusWin_Data* data = (StatusWin_Data*)INST_DATA(cl, obj);
	data->running = FALSE;
	return 0;
}


/****************************************************************************************
	New
****************************************************************************************/

ULONG StatusWin_New(struct IClass* cl, Object* obj, struct opSet* msg)
{
	StatusWin_Data 	tmp;
	Object* BT_Stop;

	obj = (Object*)DoSuperNew(cl, obj,
		MUIA_Window_LeftEdge   , MUIV_Window_LeftEdge_Centered,
		MUIA_Window_TopEdge    , MUIV_Window_TopEdge_Centered,
		MUIA_Window_Width      , MUIV_Window_Width_Visible(30),
		MUIA_Window_CloseGadget, FALSE,
		MUIA_Window_DepthGadget, FALSE,
		MUIA_Window_SizeGadget , FALSE,
		MUIA_Window_DragBar    , FALSE,
		MUIA_Window_Borderless , TRUE,

		WindowContents, VGroup, ButtonFrame,

			Child, HGroup,
				Child, MakeImage(IMG_Time_body, IMG_TIME_WIDTH, IMG_TIME_HEIGHT, 
				                 IMG_TIME_DEPTH, IMG_TIME_COMPRESSION, IMG_TIME_MASKING, 
				                 IMG_Save_colors),
				Child, HVSpace,
				Child, BT_Stop = MUI_MakeObject(MUIO_Button, "Stop"),
				End,

			Child, tmp.GA_Status = GaugeObject,
															 GaugeFrame,
															 MUIA_Gauge_Horiz	 	, TRUE,
															 MUIA_Gauge_InfoText, "",
															 End,
			Child, ScaleObject, End,
/*
			Child, HGroup,
				Child, HVSpace,
				Child, BT_Stop = MUI_MakeObject(MUIO_Button, "Stop"),
				Child, HVSpace,
				End,
*/
			End,
		TAG_MORE, msg->ops_AttrList);

	if (obj)
	{
		DoMethod(BT_Stop , MUIM_Notify, MUIA_Pressed, FALSE, obj, 1, MUIM_StatusWin_Break);

		struct StatusWin_Data* data = (StatusWin_Data*)INST_DATA(cl, obj);
		*data = tmp;
		data->running = TRUE;
		return (ULONG)obj;
	}
	return 0;
}


/****************************************************************************************
	Dispatcher
****************************************************************************************/

SAVEDS ASM ULONG StatusWin_Dispatcher(REG(a0) struct IClass* cl, REG(a2) Object* obj, REG(a1) Msg msg)
{
	switch(msg->MethodID)
	{
		case OM_NEW              : return(StatusWin_New   (cl, obj, (opSet*)msg));
		case MUIM_StatusWin_Break: return(StatusWin_Break (cl, obj, msg));
	}
	return DoSuperMethodA(cl, obj, msg);
}
