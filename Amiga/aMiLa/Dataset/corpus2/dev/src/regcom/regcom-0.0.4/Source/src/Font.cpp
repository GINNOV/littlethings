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

#include "Font.h"

#include "Surface.h"
#include "Rect.h"

#include <stdlib.h>

#define SPACE_WIDTH (m_char_pos[2]-m_char_pos[1])

//----------------------------------------------------------------------
// FUNCTION: Font::Init
//----------------------------------------------------------------------

void Font::Init(Surface* font)
{
	m_font = font;

    if (m_font == NULL) return;

	Uint32 c = m_font->GetPixel(0,0);
    
    int x = 0;
	int i = 0;

	while ( (x < m_font->Width()) && (i < 190) )
	{
		if (m_font->GetPixel(x,0) == c)
		{
			m_char_pos[i++] = x;
			while (m_font->GetPixel(x,0) == c) x++;
			m_char_pos[i++] = x;
		}

		x++;
    }

	if ( (i != 190) || (x != m_font->Width()) )
	{
		fprintf(stderr,"invalid font image\n");
		exit(-1);
	}
}

//----------------------------------------------------------------------
// FUNCTION: Font::PutText
//----------------------------------------------------------------------

void Font::PutText(
	Surface* surface, int x, int y, const char *text) const
{
    if (m_font == NULL) return;

    unsigned char ofs;
    int i=0;
    
    while (text[i] != '\0')
	{
		int ch = text[i];

		if ((ch < 32) || (ch >= 126)) ch = '?';

		if (ch == ' ')
		{
			x += SPACE_WIDTH;
			i++;
		}
		else
		{
			ofs = (ch - 33) * 2 + 1;

		    Rect src(m_char_pos[ofs],1,
				m_char_pos[ofs+1] - m_char_pos[ofs],
				m_font->Height() - 1);

			m_font->Blit(surface,&src,x,y);

			x += m_char_pos[ofs+1] - m_char_pos[ofs] - 1;
			
			i++;
		}
    }    
}

//----------------------------------------------------------------------
// FUNCTION: Font::TextWidth
//----------------------------------------------------------------------

int Font::TextWidth(const char* text) const
{
    if (m_font == NULL) return 0;

    int x = 0;
	int i = 0;
    unsigned char ofs;

    while (text[i] != '\0')
	{
		if (text[i] == ' ')
		{
			x += SPACE_WIDTH;
			i++;
		}
		else
		{
			ofs = (text[i]-33)*2+1;
			x += m_char_pos[ofs+1] - m_char_pos[ofs];
			i++;
		}
    }

    return x + m_char_pos[ofs+2] - m_char_pos[ofs+1];
}

