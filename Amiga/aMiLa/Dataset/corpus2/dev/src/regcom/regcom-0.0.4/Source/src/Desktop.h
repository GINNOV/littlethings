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

#ifndef DESKTOP_H
#define DESKTOP_H

#include "Window.h"

#define DESKTOP_MAXDIRTY 200

class Desktop : public Window
{
private:

	Rect m_dirty_rects[DESKTOP_MAXDIRTY];
	int m_dirty_count;

public:

	Desktop();
	virtual ~Desktop();

	virtual void Invalidate(Rect rect);
	virtual void Invalidate();

	virtual void Update(Rect rect);
	virtual void Update();
};

#endif
