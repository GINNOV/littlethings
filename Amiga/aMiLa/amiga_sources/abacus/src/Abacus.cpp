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
	Abacus.cpp
-----------------------------------------------------------------------------------------

  CL_Abacus (Application)

-----------------------------------------------------------------------------------------
	01.01.1997
****************************************************************************************/

#include "Abacus.hpp"
#include "BoardWindow.hpp"
#include "Settings.hpp"
#include "About.hpp"
#include "Rules.hpp"
#include "Tools.hpp"


MUI_CustomClass *CL_Abacus;



/****************************************************************************************
	About
****************************************************************************************/

ULONG Abacus_About(struct IClass* cl, Object* obj, Msg msg)
{
	struct Abacus_Data* data = (Abacus_Data*)INST_DATA(cl, obj);
	setatt(data->WI_About, MUIA_Window_RefWindow, data->WI_Main);
	setatt(data->WI_About, MUIA_Window_Open			, TRUE);
	return 0;
}


/****************************************************************************************
	Rules
****************************************************************************************/

ULONG Abacus_Rules(struct IClass* cl, Object* obj, Msg msg)
{
	struct Abacus_Data* data = (Abacus_Data*)INST_DATA(cl, obj);
	setatt(data->WI_Rules, MUIA_Window_Open, TRUE);
	return 0;
}


/****************************************************************************************
	OpenSettings
****************************************************************************************/

ULONG Abacus_OpenSettings(struct IClass* cl, Object* obj, Msg msg)
{
	struct Abacus_Data* data = (Abacus_Data*)INST_DATA(cl, obj);
	setatt(data->WI_Settings, MUIA_Window_Open, TRUE);
	return 0;
}


/****************************************************************************************
	New
****************************************************************************************/

ULONG Abacus_New(struct IClass* cl, Object* obj, struct opSet* msg)
{
	Abacus_Data tmp;
	obj = (Object*)DoSuperNew(cl, obj,
		MUIA_Application_Title      , "Abacus",
		MUIA_Application_Version    , version_string,
		MUIA_Application_Copyright  , "(c)1995-97, Kai Nickel",
		MUIA_Application_Author     , "Kai Nickel",
		MUIA_Application_Description, GetStr(MSG_APPDESCRIPTION),
		MUIA_Application_Base       , "ABACUS",
		MUIA_Application_HelpFile   , "Abacus.guide",

		MUIA_Application_Window, 
			tmp.WI_Main     = (Object*)NewObject(CL_BoardWindow->mcc_Class, NULL, TAG_DONE),

  	MUIA_Application_Window, 
			tmp.WI_Settings = (Object*)NewObject(CL_Settings->mcc_Class   , NULL, TAG_DONE),

  	MUIA_Application_Window, 
  	  tmp.WI_About    = (Object*)NewObject(CL_About->mcc_Class      , NULL, 
  	  																		 TAG_DONE),

  	MUIA_Application_Window, 
  	  tmp.WI_Rules    = (Object*)NewObject(CL_Rules->mcc_Class      , NULL, TAG_DONE),

 		TAG_MORE, msg->ops_AttrList);

	if (obj) 
	{
		struct Abacus_Data* data = (Abacus_Data*)INST_DATA(cl, obj);
		*data = tmp;

	  DoMethod(obj, MUIM_Application_Load, MUIV_Application_Load_ENVARC);
	  DoMethod(obj, MUIM_Application_Save, MUIV_Application_Save_ENV);
		setatt(obj, MUIA_Abacus_Settings, xget(data->WI_Settings, MUIA_Settings_Settings)); 
		// erste Settings installieren

		setatt(tmp.WI_Main, MUIA_Window_Open, TRUE);

		return((ULONG)obj);
	}
	ShowError(NULL, NULL, MSG_NOAPP);
	return(0);
}


/****************************************************************************************
	Dispose
****************************************************************************************/

ULONG Abacus_Dispose(struct IClass* cl, Object* obj, Msg msg)
{
	struct Abacus_Data* data = (Abacus_Data*)INST_DATA(cl, obj);
	return(DoSuperMethodA(cl, obj, msg));
}


/****************************************************************************************
	Get / Set
****************************************************************************************/

ULONG Abacus_Get(struct IClass* cl, Object* obj, struct opGet* msg)
{
	struct Abacus_Data* data = (Abacus_Data*)INST_DATA(cl, obj);
	switch (msg->opg_AttrID)
	{
		case MUIA_Abacus_Settings:
		{
			Settings* s = (Settings*)xget(data->WI_Settings, MUIA_Settings_Settings);
			*(msg->opg_Storage) = (ULONG)s;
			return(TRUE);
		}
	}
  return(DoSuperMethodA(cl, obj, (Msg)msg));
}

ULONG Abacus_Set(struct IClass* cl, Object* obj, struct opSet* msg)
{
	struct Abacus_Data* data = (Abacus_Data*)INST_DATA(cl, obj);
	struct TagItem *tag;
  tag = FindTagItem(MUIA_Abacus_Settings, msg->ops_AttrList);
	if (tag)
	{
  	DoMethod(data->WI_Main, MUIM_BoardWindow_NewSettings);
	}
  return(DoSuperMethodA(cl, obj, (Msg)msg));
}

        
/****************************************************************************************
	Dispatcher
****************************************************************************************/

SAVEDS ASM ULONG Abacus_Dispatcher(REG(a0) struct IClass* cl, 
                                   REG(a2) Object* 				obj, 
                                   REG(a1) Msg 						msg)
{
	switch(msg->MethodID)
	{
		case OM_NEW                  : return(Abacus_New          (cl, obj, (opSet*)msg));
  	case OM_DISPOSE              : return(Abacus_Dispose	    (cl, obj, msg));
		case OM_GET                  : return(Abacus_Get          (cl, obj, (opGet*)msg));
		case OM_SET                  : return(Abacus_Set          (cl, obj, (opSet*)msg));
		case MUIM_Abacus_EditSettings: return(Abacus_OpenSettings (cl, obj, msg));
		case MUIM_Abacus_About       : return(Abacus_About        (cl, obj, msg));
		case MUIM_Abacus_Rules       : return(Abacus_Rules        (cl, obj, msg));
	}
	return(DoSuperMethodA(cl, obj, msg));
}

