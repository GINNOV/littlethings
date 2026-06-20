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
#ifndef INCLUDE_ABOUT_HPP
#define INCLUDE_ABOUT_HPP
/****************************************************************************************
	About.hpp
-----------------------------------------------------------------------------------------

  Interface des About-Fenster

-----------------------------------------------------------------------------------------
	02.12.1996
****************************************************************************************/

#include "MCC.hpp"

extern MUI_CustomClass *CL_About;

#define MUIM_About_AboutMUI   	   		(TAGBASE_KAI | 0x1402)



/******************************************************************************
	About_Data
******************************************************************************/

struct About_Data
{
	Object *dummy;
};


/******************************************************************************
	Dispatcher
******************************************************************************/

SAVEDS ASM ULONG About_Dispatcher(REG(a0) struct IClass* cl, 
											 					  REG(a2) Object* 				obj, 
												  			  REG(a1) Msg 						msg);

#endif
