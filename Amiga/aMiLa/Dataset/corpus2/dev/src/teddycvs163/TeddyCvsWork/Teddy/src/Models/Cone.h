
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
	\class   Cone
	\ingroup g_models
	\author	 Timo Suoranta
	\brief   Cone Mesh
	\date    2001

	This is Cone primitive Mesh class.
*/


#ifndef TEDDY_MODELS_CONE_H
#define TEDDY_MODELS_CONE_H


#include "Models/Mesh.h"
#include "SysSupport/Types.h"


namespace Models {


class Cone : public Mesh {
public:
	Cone( const char *name, float baseRadius, float topRadius, float height, float slices, float stacks );
};


};  //  namespace Models


#endif  //  TEDDY_MODELS_CONE_H

