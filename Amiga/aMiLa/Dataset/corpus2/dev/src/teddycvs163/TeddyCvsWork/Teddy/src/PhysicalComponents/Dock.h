
/*
	TEDDY - General graphics application library
	Copyright (C) 1999, 2000, 2001	Timo Suoranta
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
	\class	 Dock
	\ingroup g_physical_components
	\author  Timo Suoranta
	\brief	 Base class for docking components
	\date	 2000, 2001

	Dock is a group of Areas such that each child area is placed next to each other.
	HDock is Horizontal Dock which places children from left to right.
	VDock is Vertical Dock which places children from top to bottom.
	Size of Dock is sum of size of children.
	Size of children of Dock
*/


#ifndef TEDDY_PHYSICAL_COMPONENTS_DOCK_H
#define TEDDY_PHYSICAL_COMPONENTS_DOCK_H


#include "PhysicalComponents/Area.h"


namespace PhysicalComponents {


class Dock : public Area {
public:
	Dock( const char *name );
	virtual ~Dock();

	virtual void insert    ( Area *area );
	virtual void splitDelta( Area *splitter, int x, int y ) = 0;

protected:
	virtual void beginPlace();
	virtual void endPlace  ();

	int cursor_x;
	int cursor_y;
};


};	//	namespace PhysicalComponents


#endif	//	TEDDY_PHYSICAL_COMPONENTS_DOCK_H

