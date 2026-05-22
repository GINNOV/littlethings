
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
	\class	 ViewClient
	\ingroup g_graphics
	\author  Timo Suoranta
	\brief	 Base class for View users
	\date	 2001
*/


#ifndef TEDDY_GRAPHICS_VIEW_CLIENT_H
#define TEDDY_GRAPHICS_VIEW_CLIENT_H


#include "Graphics/Color.h"


namespace Graphics {


class View;


class ViewClient {
public:
	ViewClient( View *view ):view(view){}
	virtual ~ViewClient(){}

	void  vertex            ( float x, float y, float z = 0 );
	void  vertex            ( float *xyz );
	void  normal            ( float x, float y, float z = 0 );
	void  normal            ( float *xyz );
	void  color             ( float r, float g, float b, float a = 1 );
	void  color             ( Color &c );
	void  texture           ( float s, float t );
	void  texture           ( float *st );
	void  beginPoints       ();
	void  beginLines        ();
	void  beginLineStrip    ();
	void  beginLineLoop     ();
	void  beginTriangles    ();
	void  beginTriangleStrip();
	void  beginTriangleFan  ();
	void  beginQuads        ();
	void  beginQuadStrip    ();
	void  beginPolygon      ();
	void  end               ();
	void  begin2d           ();
	void  end2d             ();
	void  setView           ( View *view );
	View *getView           () const;

protected:
	View *view;
};


};  //  namespace Graphics


#endif  //  TEDDY_GRAPHICS_VIEW_CLIENT_H

