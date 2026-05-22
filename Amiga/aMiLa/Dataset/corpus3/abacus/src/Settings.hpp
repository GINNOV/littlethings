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
#ifndef INCLUDE_SETTINGS_HPP
#define INCLUDE_SETTINGS_HPP
/****************************************************************************************
	Settings.hpp
-----------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------
	29.12.1996
****************************************************************************************/

#include "MCC.hpp"

extern MUI_CustomClass *CL_Settings;

#define MUIA_Settings_Settings 	   		(TAGBASE_KAI | 0x1301)
#define MUIM_Settings_Close	   	   		(TAGBASE_KAI | 0x1302)

struct MUIP_Settings_Close 						{ULONG MethodID; LONG typ;};


struct Settings
{
	struct MUI_PenSpec color1, color2, color3, color4;
	char							 name1[40], name2[40];
	BOOL							 dirs, auto2;
	int								 depth2;
};


struct Settings_Data
{
	Object *PP_Color1, *PP_Color2, *PP_Color3, *PP_Color4,
				 *ST_Name1 , *ST_Name2 , *CH_Auto2 , *CH_Dirs  , *NU_Depth2;
	Settings settings; // nur für get
};


SAVEDS ASM ULONG Settings_Dispatcher(REG(a0) struct IClass* cl, 
																		 REG(a2) Object* 				obj, 
																		 REG(a1) Msg 						msg);

#endif
