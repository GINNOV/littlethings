
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
	\class   HSplit
	\ingroup g_physical_components
	\author  Timo Suoranta
	\brief   Horizontal docking component splitter
	\date    2001

*/


#ifndef TEDDY_PHYSICAL_COMPONENTS_H_SPLIT_H
#define TEDDY_PHYSICAL_COMPONENTS_H_SPLIT_H


#include "PhysicalComponents/Dock.h"
#include "PhysicalComponents/EventListener.h"


namespace PhysicalComponents {


class HSplit : public Area, public EventListener {
public:
	HSplit( const char *name, Area *target );
	virtual ~HSplit();

	//  Area Interface
	virtual void  drawSelf   ();
	virtual Area *getTarget  ();

	//  EventListener interface
	virtual void  mouseKey   ( const int button, const int state, const int x, const int y );
	virtual void  mouseDrag  ( const Uint32 button_mask, const int x, const int y );

protected:
	Area *target;
	bool  drag;    //  Currently any button; FIX
};


};  //  namespace PhysicalComponents


#endif  //  TEDDY_PHYSICAL_COMPONENTS_H_SPLIT_H

