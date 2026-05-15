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
#ifndef INCLUDE_STATUSWIN_HPP
#define INCLUDE_STATUSWIN_HPP
/****************************************************************************************
	StatusWin.hpp
-----------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------
	29.12.1996
****************************************************************************************/

#include "MCC.hpp"
#include "Tools.hpp"
#include "Status.hpp"


extern struct MUI_CustomClass *CL_StatusWin;

#define MUIM_StatusWin_Break   			(TAGBASE_KAI | 0x1933)



/****************************************************************************************
	StatusWin_Data
****************************************************************************************/

struct StatusWin_Data
{
	Object  *GA_Status;
	BOOL    running;
};


/****************************************************************************************
	StatusWin_Status
****************************************************************************************/

class StatusWin_Status : public Status
{
	public:

		StatusWin_Status(Object* appl, Object* refwin);
		~StatusWin_Status();
		void SetInfo(int txt);

		void Init();
		void Exit();
		void Update(int done = -1, int max = -1);
		BOOL Break();

	private:

		struct StatusWin_Data* data;
		Object *app, *swin;
};


/****************************************************************************************
	Dispatcher
****************************************************************************************/

SAVEDS ASM ULONG StatusWin_Dispatcher(REG(a0) struct IClass* cl, 
													 					  REG(a2) Object* obj, 
																			REG(a1) Msg msg);

#endif
