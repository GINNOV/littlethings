
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
	\class   Frame
	\ingroup g_physical_components
	\author  Timo Suoranta
	\brief   Frame decoration area
	\warning Very incomplete
	\bug     Destructors missing?
	\date    2000

	Is frame supposed to be sub- or parent area?
	Parent area would make sense as container;
	Sub area would make sense as decoration.
	In both cases the Frame can contain subareas like title strings and buttons,
	so ordering should be preself.

*/


#ifndef TEDDY_PHYSICAL_COMPONENTS_FRAME_H
#define TEDDY_PHYSICAL_COMPONENTS_FRAME_H


#include "PhysicalComponents/Area.h"


namespace PhysicalComponents {


class Frame : public Area {
public:
	Frame( const char *name );
    virtual ~Frame();

	//  Area interface
	virtual void drawSelf();
};


};  //  namespace PhysicalComponents


#endif  //  TEDDY_PHYSICAL_COMPONENTS_FRAME_H

