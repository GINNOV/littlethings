
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
	\class   VDock
	\ingroup g_physical_components
	\author  Timo Suoranta
	\brief   Vertical docking components
	\date    2000, 2001

*/


#ifndef TEDDY_PHYSICAL_COMPONENTS_V_DOCK_H
#define TEDDY_PHYSICAL_COMPONENTS_V_DOCK_H


#include "PhysicalComponents/Dock.h"
#include "SysSupport/StdList.h"


namespace PhysicalComponents {


class VDock : public Dock {
public:
	VDock( const char *name );
	virtual ~VDock();

	//  Area Layout Interface
	virtual void place     ( int offset_x = 0, int offset_y = 0 );
	virtual void getMinSize( int *min_width, int *min_height ) const;  //!<  Query minimal accepted size for Area
	virtual void splitDelta( Area *splitter, int x_delta, int y_delta );

protected:
	virtual void placeOne  ( Area *area );
};


};  //  namespace PhysicalComponents


#endif  //  TEDDY_PHYSICAL_COMPONENTS_V_DOCK_H

