//**********************************************************************
//
//  REGCOM: Regimental Command
//  Copyright (C) 1997-2001 Randi J. Relander
//	<rjrelander@users.sourceforge.net>
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 2
//  of the License, or (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public
//  License along with this program; if not, write to the Free
//  Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
//  MA 02111-1307, USA.
//  
//**********************************************************************

#ifndef STRINGVIEW_H
#define STRINGVIEW_H

#include "Window.h"
#include "Font.h"

class StringView : public Window
{
public:
	
	char* m_text;
	
	Surface* m_font_image;
	
	Font m_font;

public:

	StringView();
	virtual ~StringView();

	virtual void Draw(Rect rect);

	void LoadFontImage(const char* filename);
	
	void SetText(const char* text);
};

#endif

