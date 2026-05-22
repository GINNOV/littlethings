
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


#include "PhysicalComponents/Area.h"
#include "PhysicalComponents/EventListener.h"
#include "PhysicalComponents/Projection.h"
#include "PhysicalComponents/LayoutConstraint.h"
#include "PhysicalComponents/Style.h"
#include "Graphics/View.h"
#include "Graphics/Font.h"
#include "SysSupport/Messages.h"
using namespace Graphics;


namespace PhysicalComponents {


WindowManager *Area::default_window_manager = NULL;


/*static*/ void Area::setDefaultWindowManager( WindowManager *wm ){
	Area::default_window_manager = wm;
}


//!  Constructor
Area::Area( char *name ):Named(name),ViewClient(NULL){
	constraint     = &LayoutConstraint::default_constraint;
	style          = Style::default_style;
	parent         = NULL;
	viewport[0]    = viewport[1] = viewport[2] = viewport[3] = 0;
	ordering       = pre_self;
	window_manager = default_window_manager;
}

//!  Constructor
Area::Area( const char *name ):Named(name),ViewClient(NULL){
	constraint     = &LayoutConstraint::default_constraint;
	style          = Style::default_style;
	parent         = NULL;
	viewport[0]    = viewport[1] = viewport[2] = viewport[3] = 0;
	ordering       = pre_self;
	view           = NULL;
	window_manager = default_window_manager;
}


//!  Destructor
/*virtual*/ Area::~Area(){
	// FIX
}



//!  Area Layout Interface - Resize area
/*virtual*/ void Area::sizeDelta( const int x_delta, const int y_delta ){
	int old_width;
	int old_height;

	this->getSize( old_width, old_height );

	int old_local_x_relative = (int)(constraint->local_x_offset_relative * old_width );
	int old_local_y_relative = (int)(constraint->local_y_offset_relative * old_height);

	constraint->local_x_fill_pixels -= x_delta;
	constraint->local_y_fill_pixels -= y_delta;

	constraint->local_x_offset_pixels += (int)(constraint->local_x_offset_relative * x_delta);
	constraint->local_y_offset_pixels += (int)(constraint->local_y_offset_relative * y_delta);
	place();
}


//!  Area Input Interface - Get Hit Area, NULL if none
/*virtual*/ Area *Area::getHit( const int x, const int y ){
	Projection    *p = dynamic_cast<Projection   *>( this );
	EventListener *e = dynamic_cast<EventListener*>( this );
/*	if( e != NULL ){
		printf( "Trying %s - Listening for events\n", getName() );
	}else{
		printf( "Trying %s - not listening for events\n", getName() );
	}*/

	//	If we are last to draw, we could be hit?
	if( ordering == pre_self && e != NULL && p == NULL ){
		if( (x >= viewport[0]) &&
			(x <= viewport[2]) &&
			(y >= viewport[1]) &&
			(y <= viewport[3])	  )
		{
			return this;
		}
	}

	list<Area*>::iterator a_it = areas.begin();
	while( a_it != areas.end() ){
		Area *hit = (*a_it)->getHit( x, y );
		if( hit != NULL ){
			return hit;
		}
		a_it++;
	}

	//	If we are last to draw, we could be hit?
	if( ordering == post_self && e != NULL && p == NULL ){
		if( (x >= viewport[0]) &&
			(x <= viewport[2]) &&
			(y >= viewport[1]) &&
			(y <= viewport[3])	  )
		{
			return this;
		}
	}
	return NULL;
}


//!  Draw area recursively - draw all areas in layer
/*virtual*/ void Area::draw(){
	if( ordering == pre_self ){
		drawSelf();
	}

	list<Area*>::iterator a_it = areas.begin();
	while( a_it != areas.end() ){
		(*a_it)->draw();
		a_it++;
	}

	if( ordering == post_self ){
		drawSelf();
	}
}


//!  Draw area - draw area self component
/*virtual*/ void Area::drawSelf(){
}


//!  Area Layout interface - Set Area ordering
void Area::setOrdering( const e_ordering ordering ){
	this->ordering = ordering;
}


//!  Debugging informaation
/*virtual*/ void Area::debug( int depth ){
}


//!  Return event target
/*virtual*/ Area *Area::getTarget( const Event e ){
	return this;  //  Default behaviour
}


//!  Set parent Area
/*virtual*/ void Area::setParent( Area *parent, View *view ){
	this->parent = parent;
	setView( view );

	//	Place flat areas
	list<Area*>::iterator a_it = areas.begin();
	while( a_it != areas.end() ){
		if( (*a_it)->getParent() != NULL ){
			(*a_it)->setParent( this, view );
		}
		a_it++;
	}
}


//!  Parent accessor
Area *Area::getParent(){
	return this->parent;
}


//!  Area Layout interface - Insert Area to Layer
/*virtual*/ void Area::insert( Area *area ){
	areas.push_back( area );
	area->setParent( this, this->view );
}


/*virtual*/ void Area::toFront(){
	if( parent != NULL ){
		parent->childToFront( this );
	}
}


/*virtual*/ void Area::toBack(){
	if( parent != NULL ){
		parent->childToBack( this );
	}
}

/*virtual*/ void Area::childToFront( Area *child ){
	list<Area*>::iterator a_it = areas.begin();
	while( a_it != areas.end() ){
		if( *a_it == child ){
			this->areas.remove( child );
			this->areas.push_back( child );
			return;
		}
		a_it++;
	}
}

/*virtual*/ void Area::childToBack( Area *child ){
	list<Area*>::iterator a_it = areas.begin();
	while( a_it != areas.end() ){
		if( *a_it == child ){
			this->areas.remove( child );
			this->areas.push_front( child );
			return;
		}
		a_it++;
	}
}


//!  Area Layout interface - Layout code
/*virtual*/ void Area::place( int offset_x, int offset_y ){
	const LayoutConstraint &c = *constraint;
	int t_xx;
	int t_yy;
	int p_xx;
	int p_yy;
	int p_x;
	int p_y;

	t_xx = c.local_x_fill_pixels;
	t_yy = c.local_y_fill_pixels;
	if( parent!=NULL ){
		parent->getSize( p_xx, p_yy );
		parent->getPos ( p_x, p_y );
	}else{
		p_xx = p_yy = p_x = p_y = 0;			
	}

	if( c.parent_x_fill_relative >= 0 ){
		t_xx += (int)(c.parent_x_fill_relative * p_xx);
	}
	if( (c.min_x_fill_pixels >= 0) && (t_xx < c.min_x_fill_pixels) ){
		t_xx = c.min_x_fill_pixels; 					
	}
	if( (c.max_x_fill_pixels >= 0) && (t_xx > c.max_x_fill_pixels) ){
		t_xx = c.max_x_fill_pixels;
	}
	if( c.parent_y_fill_relative >= 0 ){
		t_yy += (int)(c.parent_y_fill_relative * p_yy);
	}										 
	if( (c.min_y_fill_pixels >= 0) && (t_yy < c.min_y_fill_pixels) ){
		t_yy = c.min_y_fill_pixels; 					
	}
	if( (c.max_y_fill_pixels >= 0) && (t_yy > c.max_y_fill_pixels) ){
		t_yy = c.max_y_fill_pixels;
	}
	setSize( t_xx, t_yy );
	setPos(
		(int)((c.local_x_offset_pixels) +
		(c.local_x_offset_relative * t_xx) +
		(c.parent_x_offset_pixels) +
		(c.parent_x_offset_relative * p_xx) +
		(p_x) + offset_x),
		(int)((c.local_y_offset_pixels) +
		(c.local_y_offset_relative * t_yy) +
		(c.parent_y_offset_pixels) +
		(c.parent_y_offset_relative * p_yy )+
		(p_y) + offset_y)
	);

	beginPlace();

	//	Place children areas
	if( areas.size() > 0 ){
		list<Area*>::iterator a_it = areas.begin();
		while( a_it != areas.end() ){
			placeOne( *a_it );
			a_it++;
		}
	}

	endPlace();
}


//!  Area Layout Interface - Query minimum accepted size for Area
/*virtual*/ void Area::getMinSize( int &width, int &height ) const {
	width  = constraint->min_x_fill_pixels;
	height = constraint->min_y_fill_pixels;
}


/*virtual*/ void Area::placeOne( Area *area ){
	area->place();	
}


//!  Area Layout Interface - Begin placement process for children
/*virtual*/ void Area::beginPlace(){
}


//!  Area Layout Interface - End placement process for children
/*virtual*/ void Area::endPlace(){
}


//!  Area Layout interface - Set Area size
void Area::setSize( const int width, const int height ){
	viewport[2] = viewport[0] + width;
	viewport[3] = viewport[1] + height;
}


//!  Area Layout interface - Get Area size
void Area::getSize( int &width, int &height ) const {
	width  = viewport[2] - viewport[0];
	height = viewport[3] - viewport[1];
}


float Area::getRatio() const {
	int width;
	int height;

	getSize( width, height );
	if( height == 0 ){
		return 1.0;
	}
	return (float)(width) / (float)(height);
}


View *Area::getView() const {
	return view;
}


int *Area::getViewport(){
	return viewport;
}


//!  Area Layout interface - Set Area position
void Area::setPos( const int x, const int y ){
	int width  = viewport[2] - viewport[0];
	int height = viewport[3] - viewport[1];
	viewport[0] = /*x<0?0:*/x;
	viewport[1] = /*y<0?0:*/y;
	viewport[2] = viewport[0] + width;
	viewport[3] = viewport[1] + height; 	
}


//!  Area Layout Interface - Get Area position
void Area::getPos( int &x, int &y ) const {
	x = viewport[0];
	y = viewport[1];
}


//!  Area Layout Interface - Move area
/*virtual*/ void Area::moveDelta( const int x_delta, const int y_delta ){
	constraint->local_x_offset_pixels += x_delta;
	constraint->local_y_offset_pixels += y_delta;
	place();
}


//!  Area Graphics interface - Enter vertex to rendering engine
void Area::vertex2i( const GLint x, const GLint y ) const {
	view->vertex2i( viewport[0]+x, viewport[1]+y );
}


//!  Area Graphics interface - Draw filled rectangle - changed polygonmode..
void Area::drawFillRect( const int x1, const int y1, const int x2, const int y2 ){
	view->drawFillRect( viewport[0]+x1, viewport[1]+y1, viewport[0]+x2, viewport[1]+y2 );
}


//!  Area Graphics interface - Draw non-filled rectangle - changed polygonmode..
void Area::drawRect( const int x1, const int y1, const int x2, const int y2 ){
	view->drawRect( viewport[0]+x1, viewport[1]+y1, viewport[0]+x2, viewport[1]+y2 );
}


//!  Area Graphics interface - Draw twocolor rectangle
void Area::drawBiColRect( const Color &top_left, const Color &bottom_right, const int x1, const int y1, const int x2, const int y2 ){
	view->drawBiColRect( top_left, bottom_right, viewport[0]+x1, viewport[1]+y1, viewport[0]+x2, viewport[1]+y2 );
}


//!  Area Graphics interface - Draw string - no formatting
void Area::drawString( Font *font, const char *str, const int xp, const int yp ){
	view->drawString( font, str, viewport[0]+xp, viewport[1]+yp );
}


/*!
	\warning memory leak
*/
void Area::setLayoutConstraint( LayoutConstraint *lc ){
	this->constraint = lc;
}

LayoutConstraint *Area::getLayoutConstraint(){
	return this->constraint;
}


};	//	namespace PhysicalComponents

