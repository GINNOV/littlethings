
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
	\class   TextureFill
	\ingroup g_physical_components
	\author  Timo Suoranta
	\brief   Userinterface component area fill with texture
	\warning Very incomplete
	\bug     Destructors missing?
	\bug     OpenGL displaylists not yet used
	\date    2000
*/


#ifndef TEDDY_PHYSICAL_COMPONENTS_TEXTURE_FILL_H
#define TEDDY_PHYSICAL_COMPONENTS_TEXTURE_FILL_H


#include "PhysicalComponents/Fill.h"
namespace Graphics { class Texture; };
using namespace Graphics;


namespace PhysicalComponents {


class TextureFill : public Fill {
public:
	TextureFill( Texture *texture );

	virtual void drawSelf();

protected:
	Texture *texture;
};


};  //  namespace PhysicalComponents


#endif  //  TEDDY_PHYSICAL_COMPONENTS_TEXTURE_FILL_H

