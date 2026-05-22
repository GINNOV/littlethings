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
#ifndef INCLUDE_ABACUS_HPP
#define INCLUDE_ABACUS_HPP
/****************************************************************************************
	Abacus.hpp
-----------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------
	29.12.1996
****************************************************************************************/

#include "MCC.hpp"


#define MUIA_Abacus_Settings	   			(TAGBASE_KAI | 0x1001)
#define MUIM_Abacus_EditSettings    	(TAGBASE_KAI | 0x1003)
#define MUIM_Abacus_About			    		(TAGBASE_KAI | 0x1004)
#define MUIM_Abacus_Rules  		    		(TAGBASE_KAI | 0x1005)

extern MUI_CustomClass *CL_Abacus;


struct Abacus_Data
{
	Object *WI_Main, *WI_Settings, *WI_About, *WI_Rules;
};


SAVEDS ASM ULONG Abacus_Dispatcher(REG(a0) struct IClass* cl, 
                                   REG(a2) Object* 				obj, 
                                   REG(a1) Msg 						msg);
#endif
