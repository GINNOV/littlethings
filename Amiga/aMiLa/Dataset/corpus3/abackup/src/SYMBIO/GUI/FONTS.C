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
    fonts.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 12-Feb-94
    Modified: 16-Jan-98
    _______________________________________________________________________
*/
#include "headers.h"
#include "fonts.h"

STATIC VOID     SetupTxtFont    (VOID);
STATIC VOID     SetupScrFont    (VOID);
STATIC VOID     GetSysDefFont   (VOID);
STATIC VOID     GetWBScrDefFont (VOID);

STATIC struct TextAttr DefPolice =
{
  "topaz.font",
  8,
  FS_NORMAL,
  FPF_DESIGNED|FPF_ROMFONT
} ;

//_____________________________________________________________________________

VOID
SetupFonts()
{
	GetScreenInfos();       // we need some screen dimensions first
	SetupTxtFont(); 	// open or get the text font (fixed width)
	SetupScrFont(); 	// open or get the screen font
}
//_____________________________________________________________________________

__inline STATIC VOID
SetupTxtFont()
{
	TxtFont = &TxtAttr;

	// try to open the prefs text font:
	if (DiskfontBase) {
		TxtFont->ta_Name  = PRF_TEXTFONTNAME;
		TxtFont->ta_YSize = PRF_TEXTFONTSIZE;
		TxtFont->ta_Style = FS_NORMAL;
		TxtFont->ta_Flags = FPF_DISKFONT;

		if (TxtTFont = OpenDiskFont(TxtFont)) {
			TxtFontX = TxtTFont->tf_XSize;
			TxtFontY = TxtTFont->tf_YSize;
			TxtBLine = TxtTFont->tf_Baseline;
		}
	}

	// if the text font could not be opened, use the system default instead:
	if (NOT TxtTFont) GetSysDefFont();

	// check if the text font is not too wide:
	// TODO: make this test a little bit safer...
	if (TxtFontX*MWin[WIN_LARGEST].mw_Width/8 > ScrWidth) {
		// if we opened a font, close it and use the system default:
		if (TxtTFont) {
			CloseFont(TxtTFont);
			GetSysDefFont();
			TxtTFont = GfxBase->DefaultFont;
		}

		// if the font is still too wide, use the ROM font (topaz8):
		if ( (TxtFontX * MWin[WIN_LARGEST].mw_Width / 8) > ScrWidth )
		{
		  TxtFont = &DefPolice ;
		  if ( TxtTFont = OpenFont( TxtFont ) )
		  {
		    TxtFontX = TxtTFont->tf_XSize ;
		    TxtFontY = TxtTFont->tf_YSize ;
		    TxtBLine = TxtTFont->tf_Baseline ;
		  }
		}
	}
	else if (TxtFontX < 8) TxtFontX = 8;
}
//_____________________________________________________________________________

__inline STATIC VOID
SetupScrFont()
{
	ScrFont = &ScrAttr;

	// try to open the prefs screen font:
	if (DiskfontBase) {
		ScrFont->ta_Name  = PRF_SCREENFONTNAME;
		ScrFont->ta_YSize = PRF_SCREENFONTSIZE;
		ScrFont->ta_Style = FS_NORMAL;
		ScrFont->ta_Flags = FPF_DISKFONT;

		if (ScrTFont = OpenDiskFont(ScrFont)) {
			ScrFontX = ScrTFont->tf_XSize;
			ScrFontY = ScrTFont->tf_YSize;
		}
	}

	// if the screen font could not be opened, use Workbench's instead:
	if (NOT ScrTFont) GetWBScrDefFont();

	// if screen font is too wide, use the text font instead:
	if (ComputeX(MWin[WIN_LARGEST].mw_Width) > ScrWidth) {
		ScrFont  = TxtFont;
		ScrFontX = TxtFontX;
		ScrFontY = TxtFontY;
	}
	else ScrFontX = MAX(ScrFontX,TxtFontX);
}
//_____________________________________________________________________________

__inline STATIC VOID
GetSysDefFont()
{
	Forbid();
	strcpy(TxtFName,(STRPTR)GfxBase->DefaultFont->tf_Message.mn_Node.ln_Name);
	TxtFont->ta_Name  =     TxtFName;
	TxtFont->ta_YSize =     TxtFontY = GfxBase->DefaultFont->tf_YSize;
						TxtFontX = GfxBase->DefaultFont->tf_XSize;
						TxtBLine = GfxBase->DefaultFont->tf_Baseline;
	Permit();
}
//_____________________________________________________________________________

__inline STATIC VOID
GetWBScrDefFont()
{
	struct Screen   *scr = GetPubScreen(_WBSCRNAME_);

	if (scr) {
		strcpy(ScrFName,(STRPTR)scr->RastPort.Font->tf_Message.mn_Node.ln_Name);
		ScrFont->ta_Name  =     ScrFName;
		ScrFont->ta_YSize =     ScrFontY = scr->RastPort.Font->tf_YSize;
							ScrFontX = scr->RastPort.Font->tf_XSize;
	}
	else {
		ScrFont  = TxtFont;
		ScrFontY = TxtFontY;
		ScrFontX = TxtFontX;
	}
}
//______________________________________________________________________________

WORD
ComputeX (WORD value)
{
	return((WORD)(ScrFontX*value/8));
}

// Tab size: 4
