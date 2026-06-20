
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
	\class   ActionButton
	\ingroup g_physical_components
	\author  Timo Suoranta
	\brief   Action button
	\date    2001
*/


#ifndef TEDDY_PHYSICAL_COMPONENTS_ACTION_BUTTON_H
#define TEDDY_PHYSICAL_COMPONENTS_ACTION_BUTTON_H


#include "PhysicalComponents/Area.h"
#include "PhysicalComponents/EventListener.h"
#include "PhysicalComponents/WindowManager.h"
#include "Graphics/Color.h"
using namespace Graphics;


namespace PhysicalComponents {


class ActionButton : public Area, public EventListener {
public:
	ActionButton( const char *name, Area *target, EventMask in_event_mask, Event out_event, Color color );
	virtual ~ActionButton();

	//  Area interface
	virtual void  drawSelf();

	//  EventListener interface
	virtual void  mouseKey   ( const int button, const int state, const int x, const int y );
	virtual void  mouseDrag  ( const int button, const int x, const int y, const int dx, const int dy );

	virtual Area *getTarget  ( const Event e );

protected:
	const char *label;
	Color   color;      //!<  Color to be used for filling
	Event   out_event;  //!<  Which WindowManagerEvent will be triggered?
	Area   *target;
};


};  //  namespace PhysicalComponents


#endif  //  TEDDY_PHYSICAL_COMPONENTS_ACTION_BUTTON_H

