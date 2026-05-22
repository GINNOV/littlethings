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
#ifndef INCLUDE_TOOLS_HPP
#define INCLUDE_TOOLS_HPP
/****************************************************************************************
	Tools.hpp
-----------------------------------------------------------------------------------------

	Definition der Hilfsfunktionen und Creationmakros

-----------------------------------------------------------------------------------------
	27.12.1996
****************************************************************************************/

#define CATCOMP_NUMBERS
#include "LocStrings.h"

#include "System.hpp"
#include <string.h>
#include <graphics/text.h>


/****************************************************************************************
	GetStr
****************************************************************************************/

extern struct Catalog* catalog;

char* GetStr(int idstr);



/****************************************************************************************
	MUI-Hilfstools
****************************************************************************************/

#define getatt(obj,attr,store) GetAttr(attr,obj,(ULONG *)store)
#define setatt(obj,attr,value) SetAttrs(obj,attr,value,TAG_DONE)

LONG xget(Object* obj, ULONG attribute);

char* StringContents(Object* obj);

ULONG /*__stdargs*/ DoSuperNew(struct IClass* cl, Object* obj, ULONG tag1,...);



/****************************************************************************************
	MUI-Creation"makros"
****************************************************************************************/


Object* HBar();
Object* VBar();

Object* MakeButton	 				(int num, int help);
Object* MakeString	 				(int maxlen, int num, char* contents, int help);
Object* MakeCycle 	 				(char** array, int num, int help);
Object* MakeCheck 	 				(int num, BOOL pressed, int help);
Object* MakeNumerical				(int num, LONG min, LONG max, LONG val, int help);
Object* MakeSlider	 				(int min, int max, int val, int text, int help);
Object* MakeImageTextButton (int text, int help, int control, const UBYTE* data);
Object* MakeImage						(const UBYTE* data, LONG w, LONG h, LONG d, 
					 							     LONG compr, LONG mask, const ULONG* colors);


Object* MakeLabel     (int num);
Object* MakeLabel1    (int num);
Object* MakeLabel2    (int num);
Object* MakeLLabel    (int num);
Object* MakeLLabel1   (int num);
Object* MakeLLabel2   (int num);
Object* MakeFreeLabel (int num);
Object* MakeFreeLLabel(int num);


Object* MenuObj(Object* strip, int data);




/****************************************************************************************
	ShowError

	Zeigt einen Fehler in einem Requester mit "Ok" Button
****************************************************************************************/

void ShowError(Object* app, Object* win, int msg);


/****************************************************************************************
	GetFilename
****************************************************************************************/

char* GetFilename(Object* win, BOOL save, int title, char* pattern, char* initdrawer);

#endif
