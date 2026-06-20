
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
	\class	 Layer
	\ingroup g_physical_components
	\author  Timo Suoranta
	\brief	 Base class for display layers
	\date	 2000, 2001

	Layer is link between View and Area. To add Area to View, there
	must be Layer between.

	Views display Layers. Each Layer may contain a number of
	Areas.
*/


#ifndef TEDDY_PHYSICAL_COMPONENTS_LAYER_H
#define TEDDY_PHYSICAL_COMPONENTS_LAYER_H


#include "PhysicalComponents/Area.h"
#include "SysSupport/StdList.h"
namespace Graphics { class View; };


namespace PhysicalComponents {


class Projection;


class Layer : public Area {
public:
	Layer( const char *name, View *view );

	void update( View *view );

	//	Area Input Interface
	virtual Area *getHit       ( const int x, const int y );

	//	Area Layout Interface
	virtual void  drawLayer    ();
	virtual void  drawSelf	   ();	//!<  Will render only self
	virtual void  place 	   ( int offset_x=0, int offset_y=0 );

	void		  addProjection( Projection *p );  //!<  Set Layer projection

protected:
	list<Projection*> projs;
};


};	//	namespace PhysicalComponents


#endif	//	TEDDY_PHYSICAL_COMPONENTS_LAYER_H

