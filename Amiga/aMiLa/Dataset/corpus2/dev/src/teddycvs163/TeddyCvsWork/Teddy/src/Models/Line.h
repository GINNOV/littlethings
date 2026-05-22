
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
	\class   Line
	\ingroup g_models
	\author  Timo Suoranta
	\brief   Line Element
	\date    1999, 2000, 2001

	Line is simple thin line defined by two points.
*/


#ifndef TEDDY_MODELS_LINE_H
#define TEDDY_MODELS_LINE_H


#include "Models/Element.h"


namespace Models {


class Vertex;


class Line : public Element {
public:
	Vertex *start_point;
	Vertex *end_point;

	Line( Vertex *v1, Vertex * v2 );
	Line( const Line &l );

	virtual void draw ( Projection *p );
	virtual void swap ();

	bool operator==( const Line &l ) const;
	bool operator!=( const Line &l ) const;
};


};  //  namespace Models


#endif  //  TEDDY_MODELS_LINE_H

