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
#ifndef INCLUDE_MCC_HPP
#define INCLUDE_MCC_HPP
/****************************************************************************************
	MCC.hpp
-----------------------------------------------------------------------------------------

  Definitionen für MUI-CustomClasses

-----------------------------------------------------------------------------------------
	01.01.1996
****************************************************************************************/


#include <libraries/mui.h>

#include <clib/muimaster_protos.h>

#define REG(x) register __ ## x

#if defined __MAXON__ || defined __GNUC__
	#define ASM
	#define SAVEDS
#else
	#define ASM    __asm
	#define SAVEDS __saveds
#endif /* if defined ... */

#include <pragma/muimaster_lib.h>


#define MUISERIALNR_KAI 1300604193
#define TAGBASE_KAI (TAG_USER | (MUISERIALNR_KAI << 16))

#ifndef MAKE_ID
	#define MAKE_ID(a,b,c,d) ((ULONG) (a)<<24 | (ULONG) (b)<<16 | (ULONG) (c)<<8 | (ULONG) (d))
#endif




#endif
