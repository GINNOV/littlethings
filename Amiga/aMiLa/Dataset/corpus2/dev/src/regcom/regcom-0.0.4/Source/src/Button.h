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

#ifndef BUTTON_H
#define BUTTON_H

#include "Window.h"

class Console;

class Button : public Window  
{
public:

	Surface* m_image[4];

	int m_state;
	char* m_status;
	Console* m_console;

	int m_code;
	void* m_data1;
	void* m_data2;

public:

	Button();
	virtual ~Button();

	void SetStatus(const char* status);

	virtual void Draw(Rect rect);

	virtual void OnMouseMove(Point point);
	virtual void OnMouseDown(int n, Point point);
	virtual void OnMouseUp(int n, Point point);

	void Load(Surface* surface);
};

#endif
