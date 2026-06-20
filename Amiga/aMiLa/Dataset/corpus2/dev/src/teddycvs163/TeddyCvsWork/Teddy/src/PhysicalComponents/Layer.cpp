
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


#include "Graphics/View.h"
#include "PhysicalComponents/EventListener.h"
#include "PhysicalComponents/Layer.h"
#include "PhysicalComponents/LayoutConstraint.h"
#include "PhysicalComponents/Projection.h"
#include "SysSupport/Messages.h"
using namespace Graphics;


namespace PhysicalComponents {


//!  Constructor
Layer::Layer( const char *name, View *view ):Area(name){
	int *viewp   = view->getViewport();
	this->parent   = NULL;
	this->view     = view;
	this->ordering = post_self;
	constraint = new LayoutConstraint();
	constraint->local_x_fill_pixels = viewp[2] - viewp[0];
	constraint->local_y_fill_pixels = viewp[3] - viewp[1];
	place();
}


//!  Area Input Interface - Get Hit Area, NULL if none
/*virtual*/ Area *Layer::getHit( const int x, const int y ){
	EventListener *e = dynamic_cast<EventListener*>( this );
/*	if( e != NULL ){
		printf( "Trying %s - Listening for events\n", getName() );
	}else{
		printf( "Trying %s - not listening for events\n", getName() );
	}*/
	Area *hit = NULL;

	//	If we are last to draw, we could be hit?
	if( ordering == pre_self && e != NULL ){
		if( (x >= viewport[0]) &&
			(x <= viewport[2]) &&
			(y >= viewport[1]) &&
			(y <= viewport[3])	  )
		{
			return this;
		}
	}

	//  Test Children for hits
//	printf( "Begin Try Children\n" );
	list<Area*>::iterator a_it = areas.begin();
	while( a_it != areas.end() ){
		hit = (*a_it)->Area::getHit( x, y );
		if( hit != NULL ){
			return hit;
		}
		a_it++;
	}
//	printf( "End Try Children\n" );

	//  Test Projection areas for hits
//	printf( "Begin Try Projections\n" );
	list<Projection*>::iterator p_it = projs.begin();
	while( p_it != projs.end() ){
		hit = (*p_it)->getHit( x, y );
		if( hit != NULL ){
			return hit;
		}
		p_it++;
	}
//	printf( "End Try Projections\n" );

	//	If we are last to draw, we could be hit?
	if( ordering == post_self && e != NULL ){
		if( (x >= viewport[0]) &&
			(x <= viewport[2]) &&
			(y >= viewport[1]) &&
			(y <= viewport[3])	  )
		{
			return this;
		}
	}
	return hit;
}


//!  Set View
void Layer::update( View *view ){ // refresh/update, on resize for example
	GLint *viewp = view->getViewport();
	constraint->local_x_fill_pixels = viewp[2] - viewp[0];
	constraint->local_y_fill_pixels = viewp[3] - viewp[1];
	place();
}


//!  Draw Layer Self; draw Projection component
/*virtual*/ void Layer::drawSelf(){
	list<Projection*>::iterator p_it = projs.begin();
	while( p_it != projs.end() ){
		(*p_it)->drawSelf();
		p_it++;
	}
}

//!  Set Projection
void Layer::addProjection( Projection *p ){
	if( p!=NULL ){
		projs.push_back( p );
		p->setParent( this, this->view );
		this->insert( p );
	}
}


//!  Area Layout Interface
/*virtual*/ void Layer::place( int offset_x, int offset_y ){
	Area::place( offset_x, offset_y );
	list<Projection*>::iterator p_it = projs.begin();
	while( p_it != projs.end() ){
		(*p_it)->place( offset_x, offset_y );
		p_it++;
	}
}


//!  Draw area recursively - draw all areas in layer
/*virtual*/ void Layer::drawLayer(){

	drawSelf();

	view->begin2d();
	list<Area*>::iterator a_it = areas.begin();
	while( a_it != areas.end() ){
		(*a_it)->draw();
		a_it++;
	}
	view->end2d();
}


};  //  namespace PhysicalComponents

