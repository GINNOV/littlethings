
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
	\class   SkyBox
	\ingroup g_models
	\author  Timo Suoranta
	\brief   Camera skybox mesh
	\date    2000

	SkyBox 
*/


#ifndef TEDDY_MODELS_SKY_BOX_H
#define TEDDY_MODELS_SKY_BOX_H


#include "Models/Mesh.h"
namespace Materials          { class Material; };
namespace PhysicalComponents { class Projection; };
using namespace Materials;
using namespace PhysicalComponents;


namespace Models {


class SkyBox : public Mesh {
public:
	SkyBox();

	virtual void drawElements ( Projection *p );

protected:
	Material *front;
	Material *back;
	Material *left;
	Material *right;
	Material *up;
	Material *down;
};


};  //  namespace Models


#endif  //  TEDDY_MODELS_SKY_BOX_H

