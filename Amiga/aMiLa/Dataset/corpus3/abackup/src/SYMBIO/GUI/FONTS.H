/*
* This file is part of ABackup.
* Copyright (C) 1999 Denis Gounelle
* 
* ABackup is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* ABackup is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with ABackup.  If not, see <http://www.gnu.org/licenses/>.
*
*/
/*  _______________________________________________________________________

    ABackup 5.0
    fonts.h

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 12-Feb-94
    Modified: 18-Apr-95
    _______________________________________________________________________
*/
#ifndef ABACKUP_FONTS_H
#define ABACKUP_FONTS_H

static UBYTE TxtFName[MINSTR+1], ScrFName[MINSTR+1];

struct TextFont *ScrTFont = NULL,
				*TxtTFont = NULL;
struct TextAttr *ScrFont,*TxtFont;

UWORD	ScrFontX,ScrFontY,TxtFontX,TxtFontY,TxtBLine;

STATIC struct TextAttr	ScrAttr,TxtAttr;

#define DEF_FONT	(STRPTR)"topaz.font"

#endif	// ABACKUP_FONTS_H
