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

#ifndef FONT_H
#define FONT_H

class Surface;

#define FONT_MAX 96

class Font
{
private:

	Surface* m_font;
	int m_char_pos[190];

public:

	Font() { m_font = 0; }
	virtual ~Font() {}

	// Initializes the font
	// font: this is the surface which contains the font.
	void Init(Surface* font);

	// Blits a string to a surface
	// dest: the suface you want to blit to
	// text: a string containing the text you want to blit.
	void PutText(Surface* surface, int x, int y, const char *text) const;

	// Returns the width of "text" in pixels
	// width: What is the maximum width of the text (in pixels)
	// text: This string contains the text which was entered by the user
	int TextWidth(const char* text) const;
};

#endif
