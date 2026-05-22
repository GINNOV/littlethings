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
#ifndef INCLUDE_MSGWIN_HPP
#define INCLUDE_MSGWIN_HPP
/****************************************************************************************
	MsgWin.hpp
-----------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------
	01.01.1997
****************************************************************************************/

#include "MCC.hpp"


extern struct MUI_CustomClass *CL_MsgWin;

#define MUIA_MsgWin_MsgBig 			(TAGBASE_KAI | 0x2511)
#define MUIA_MsgWin_MsgSmall		(TAGBASE_KAI | 0x2512)
#define MUIV_MsgWin_Close  			(TAGBASE_KAI | 0x2513)



struct MsgWin_Data
{
	LONG dummy;
};


SAVEDS ASM ULONG MsgWin_Dispatcher(REG(a0) struct IClass* cl, 
												 					 REG(a2) Object* 				obj, 
																	 REG(a1) Msg 						msg);

#endif
