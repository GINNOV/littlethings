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
#ifndef INCLUDE_BOARDWIN_HPP
#define INCLUDE_BOARDWIN_HPP
/****************************************************************************************
	BoardWindow.hpp
-----------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------
	03.01.1997
****************************************************************************************/

#include "MCC.hpp"

extern MUI_CustomClass *CL_BoardWindow;

#define MUIA_BoardWindow_ActivePlayer	(TAGBASE_KAI | 0x1100) // [.S.]
#define MUIM_BoardWindow_Quit   	   	(TAGBASE_KAI | 0x1101)
#define MUIM_BoardWindow_NewSettings 	(TAGBASE_KAI | 0x1102)


struct BoardWindow_Data
{
	Object *Board, 
				 *TX_Player1, *TX_Player2, 
				 *PD_Player1, *PD_Player2;
};


SAVEDS ASM ULONG BoardWindow_Dispatcher(REG(a0) struct IClass* cl, 
																				REG(a2) Object* 			 obj, 
																				REG(a1) Msg 					 msg);
#endif
