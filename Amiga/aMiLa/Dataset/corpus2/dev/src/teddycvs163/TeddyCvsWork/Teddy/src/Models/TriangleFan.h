
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
	\class   TriangleFan
	\ingroup g_models
	\author  Timo Suoranta
	\bug     Not yet implemented
	\bug     Destructors missing?
	\date    2000, 2001

	TriangleFan Element builds up a triangle fan from
	its vertices.
*/


#ifndef TEDDY_MODELS_TRIANGLE_FAN_H
#define TEDDY_MODELS_TRIANGLE_FAN_H


#include "Models/Element.h"
#include "SysSupport/StdList.h"


namespace Models {


class Vertex;


class TriangleFan : public Element {
public:
	TriangleFan();
	virtual ~TriangleFan();

	void insert( Vertex *v );

	virtual void draw( Projection *p );

protected:
	list<Vertex*> vertices;
};


};  //  namespace Models


#endif  //  TEDDY_MODELS_TRIANGLE_FAN_H

