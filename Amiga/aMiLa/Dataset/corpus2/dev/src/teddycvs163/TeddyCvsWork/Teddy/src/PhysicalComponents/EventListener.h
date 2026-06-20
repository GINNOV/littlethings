
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
	\class   EventListener
	\ingroup g_physical_components
	\author  Timo Suoranta
	\date    2000, 2001
*/


#ifndef TEDDY_PHYSICAL_COMPONENTS_EVENT_LISTENER_H
#define TEDDY_PHYSICAL_COMPONENTS_EVENT_LISTENER_H


#include "SDL_types.h"
#include "SDL_keyboard.h"


namespace PhysicalComponents {


#define EVENT_NULL             0ul
#define EVENT_MOVE             1ul
#define EVENT_SIZE             2ul
#define EVENT_TO_FRONT         3ul
#define EVENT_TO_BACK          4ul
#define EVENT_SPLIT_UPDATE     5ul
#define EVENT_KEY_DOWN         6ul
#define EVENT_KEY_UP           7ul
#define EVENT_MOUSE_KEY        8ul
#define EVENT_MOUSE_MOTION     9ul
#define EVENT_MOUSE_DRAG      10ul
#define EVENT_MOUSE_HOLD_DRAG 11ul

#define EVENT_NULL_M             (1ul<<EVENT_NULL           )
#define EVENT_MOVE_M             (1ul<<EVENT_MOVE           )
#define EVENT_SIZE_M             (1ul<<EVENT_SIZE           )
#define EVENT_TO_FRONT_M         (1ul<<EVENT_TO_FRONT       )
#define EVENT_TO_BACK_M          (1ul<<EVENT_TO_BACK        )
#define EVENT_SPLIT_UPDATE_M     (1ul<<EVENT_SPLIT_UPDATE   )
#define EVENT_KEY_DOWN_M         (1ul<<EVENT_KEY_DOWN       )
#define EVENT_KEY_UP_M           (1ul<<EVENT_KEY_UP         )
#define EVENT_MOUSE_KEY_M        (1ul<<EVENT_MOUSE_KEY      )
#define EVENT_MOUSE_MOTION_M     (1ul<<EVENT_MOUSE_MOTION   )
#define EVENT_MOUSE_DRAG_M       (1ul<<EVENT_MOUSE_DRAG     )
#define EVENT_MOUSE_HOLD_DRAG_M  (1ul<<EVENT_MOUSE_HOLD_DRAG)

typedef Uint32 EventMask;
typedef Uint8  Event;


class EventListener {
public:
	EventListener( EventMask event_mask ){
		this->event_mask = event_mask;
	}
	virtual ~EventListener(){
	}

	EventMask getEventMask() const {
		return event_mask;
	}

	virtual void enableEvents ( const Uint32 event_mask ){
		this->event_mask &= event_mask;
	}

	virtual void disableEvents( const Uint32 event_mask ){
		this->event_mask &= ~event_mask;
	}

	virtual void focusActive  ( const bool active ){}
	virtual void mouseKey     ( const int button, const int state, const int x, const int y ){}
	virtual void mouseMotion  ( const int x, const int y, const int dx, const int dy ){}
	virtual void mouseDrag    ( const int button, const int x, const int y, const int dx, const int dy ){}
	virtual void keyDown      ( const SDL_keysym key ){}
	virtual void keyUp        ( const SDL_keysym key ){}

	bool doesEvent( EventMask e );

protected:
	EventMask event_mask;
};


};  //  namespace PhysicalComponents


#endif  //  TEDDY_PHYSICAL_COMPONENTS_EVENT_LISTENER_H

