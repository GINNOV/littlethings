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

#include "StringView.h"

#include "Screen.h"

#include <string.h>

//----------------------------------------------------------------------
// FUNCTION: StringView::StringView
//----------------------------------------------------------------------

StringView::StringView()
{
	m_text = new char[1];
	*m_text = '\0';
	m_font_image = NULL;
}

//----------------------------------------------------------------------
// FUNCTION: StringView::~StringView
//----------------------------------------------------------------------

StringView::~StringView()
{
	if (m_text) delete [] m_text;
	if (m_font_image) delete m_font_image;
}

//----------------------------------------------------------------------
// FUNCTION: StringView::Draw
//----------------------------------------------------------------------

void StringView::Draw(Rect rect)
{
	Point point = ConvertToScreen(Point(3,2));
	m_font.PutText(Screen::Instance(),point.x,point.y,m_text);
}

//----------------------------------------------------------------------      
// FUNCTION: StringView::LoadFontImage
//----------------------------------------------------------------------

void StringView::LoadFontImage(const char* filename)
{
	if (m_font_image) delete m_font_image;

	m_font_image = new Surface;
	m_font_image->Load(filename);
	m_font_image->SetColorKey(255,0,255);
	m_font_image->DisplayFormat();

	m_font.Init(m_font_image);
}

//----------------------------------------------------------------------      
// FUNCTION: StringView::SetText
//----------------------------------------------------------------------

void StringView::SetText(const char* text)
{
	if (m_text && (strcmp(text,m_text) == 0)) return;
	
	if (m_text) delete [] m_text;
	m_text = new char[strlen(text)+1];
	strcpy(m_text,text);

	Invalidate();
}
