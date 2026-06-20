
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


#include "PhysicalComponents/VDock.h"
#include "PhysicalComponents/Style.h"


#if defined( _MSC_VER )
# include <limits>
#else
extern "C" {
#include <limits.h>
}
#endif


namespace PhysicalComponents {


//!  Constructor
VDock::VDock( const char *name ):Dock(name){
}


//!  Destructor
/*virtual*/ VDock::~VDock(){
	//  FIX
}


//!  Dock Layout Interface - update splitter position
/*virtual*/ void VDock::splitDelta( Area *the_splitter, int x_delta, int y_delta ){
	Area *prev     = NULL;
	Area *splitter = NULL;
	Area *next     = NULL;

	list<Area*>::iterator l_it = areas.begin();
	while( l_it != areas.end() ){
		prev     = splitter;
		splitter = next;
		next     = (*l_it);
		if( splitter == the_splitter ){
			break;
		}
		l_it++;
	}

	//  Splitter last?
	if( next == the_splitter ){
		prev     = splitter;
		splitter = next;
		next     = NULL;
	}

	//  Found splitter?
	if( splitter != NULL ){
		prev    ->sizeDelta( 0, -y_delta );
		next    ->sizeDelta( 0,  y_delta );
		next    ->moveDelta( 0,  y_delta );
		splitter->moveDelta( 0,  y_delta );
		this->place();
	}

}


//!  Area Layout Interface - Set place for one child
/*virtual*/ void VDock::placeOne( Area *area ){
	int w;
	int h;
	area->place( cursor_x, cursor_y );
	area->getSize( w, h );
	cursor_y += h + style->inner_y_space_pixels;
}


//!  Area Layout Interface - Query minimum accepted size for Area
/*virtual*/ void VDock::getMinSize( int *min_width, int *min_height ) const {
	//  Minimum width of vertical container
	//  is largest of childrens minimal widths.
	//  Minimum height of vertical container
	//  is sum of childrens minimal heights.

	int max_of_children_min_x = INT_MIN;
	int sum_of_children_min_y = 0;

	//  Query areas
	list<Area*>::const_iterator a_it = areas.begin();
	while( a_it != areas.end() ){
		int x;
		int y;
		(*a_it)->getMinSize( x, y );
		sum_of_children_min_y += y;
		if( y>max_of_children_min_x ){
			max_of_children_min_x = x;
		}
		a_it++;
	}

	*min_width  = max_of_children_min_x + 2*style->inner_x_space_pixels;
	*min_height = sum_of_children_min_y + 2*style->inner_y_space_pixels;
}


//!  Area Layout interface
/*virtual*/ void VDock::place( int offset_x, int offset_y ){
	//  Set minimum size
	int w;
	int h;
	getMinSize( &w, &h );
	setSize( w, h );

	//  Do the actual place process
	Area::place( offset_x, offset_y );
}


};  //  namespace PhysicalComponents

