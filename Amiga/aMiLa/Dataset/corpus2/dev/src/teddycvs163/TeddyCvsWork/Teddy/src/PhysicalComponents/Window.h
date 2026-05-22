
/*
    TEDDY - General graphics application library
    Copyright (C) 1999, 2000, 2001  Timo Suoranta
    tksuoran@cc.helsinki.fi

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

/*!
	\class   Window
	\ingroup g_physical_components
	\author  Timo Suoranta
	\brief   Basic window baseclass
	\date    2001
*/


#ifndef TEDDY_PHYSICAL_COMPONENTS_WINDOW_H
#define TEDDY_PHYSICAL_COMPONENTS_WINDOW_H


#include "PhysicalComponents/Area.h"


namespace PhysicalComponents {


class Window : public Area {
public:
	Window( const char *label, Area *area, Uint32 flags );
	~Window();

	//  Area Layout Interface
	virtual void move   ( int x, int y );
	virtual void size   ( int w, int h );
	virtual void toFront();
	virtual void toBack ();
	virtual void focus  ( bool enter );

protected:
	const char *label;
	Uint32 flags;
};


};  //  namespace PhysicalComponents


#endif  //  TEDDY_PHYSICAL_COMPONENTS_WINDOW_H

