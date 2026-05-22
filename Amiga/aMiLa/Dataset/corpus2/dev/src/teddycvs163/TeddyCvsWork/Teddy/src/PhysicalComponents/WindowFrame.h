
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
	\class   WindowFrame
	\ingroup g_physical_components
	\author  Timo Suoranta
	\brief   Frame decoration area for Windows with title bar
	\warning Very incomplete
	\bug     Destructors missing
	\date    2000

	Currently testing HDock

	'Move Window' behaviour hacked in
	
*/


#ifndef TEDDY_PHYSICAL_COMPONENTS_WINDOW_FRAME_H
#define TEDDY_PHYSICAL_COMPONENTS_WINDOW_FRAME_H


#include "PhysicalComponents/HDock.h"
#include "Graphics/Color.h"
using namespace Graphics;


namespace PhysicalComponents {


class WindowFrame : public HDock {
public:
	WindowFrame( const char *name );
	virtual ~WindowFrame();

	void          setColor ( Color c );

	//  Area interface
	virtual void  drawSelf ();
	virtual Area *getTarget( const Uint8 e );

protected:
	Color color;
};


};  //  namespace PhysicalComponents


#endif  //  TEDDY_PHYSICAL_COMPONENTS_WINDOW_FRAME_H

