
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


#include "PhysicalComponents/HDock.h"
#include "PhysicalComponents/Style.h"
#include <climits>


namespace PhysicalComponents {


//!  Constructor
HDock::HDock( const char *name ):Dock(name){
}


//!  Destructor
/*virtual*/ HDock::~HDock(){
	//  FIX
}


//!  Dock Layout Interface - update splitter position
/*virtual*/ void HDock::splitDelta( Area *the_splitter, int x_delta, int y_delta ){
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
		prev    ->sizeDelta( -x_delta, 0 );
/*		next    ->sizeDelta(  x_delta/2, 0 );
		next    ->moveDelta(  x_delta, 0 );
		splitter->moveDelta(  x_delta, 0 );*/
		this->place();
	}

}


//!  Area Layout Interface - Set place for one child
/*virtual*/ void HDock::placeOne( Area *area ){
	int w;
	int h;
	area->place( cursor_x, cursor_y );
	area->getSize( w, h );
	cursor_x += style->inner_x_space_pixels + w;
	//cout << this->name << " " << cursor_x << endl;
}


//!  Area Layout Interface - Query minimum accepted size for Area
/*virtual*/ void HDock::getMinSize( int *min_width, int *min_height ) const {
	//  Minimum width of horizontal container
	//  is sum of childrens minimal widths.
	//    PLUS 2 * inner_x_space_pixels

	//  Minimum height of horizontal container
	//  is largest of childrens minimal heights.
	//    PLUS 2 * inner_y_space_pixels

	int sum_of_children_min_x = 0;
	int max_of_children_min_y = INT_MIN;

	//  Query areas
	list<Area*>::const_iterator a_it = areas.begin();
	while( a_it != areas.end() ){
		int x;
		int y;
		(*a_it)->getMinSize( x, y );
		sum_of_children_min_x += x;
		if( y>max_of_children_min_y ){
			max_of_children_min_y = y;
		}
		a_it++;
	}

	*min_width  = sum_of_children_min_x + 2*style->inner_x_space_pixels;
	*min_height = max_of_children_min_y + 2*style->inner_y_space_pixels;
}


//!  Area Layout interface
/*virtual*/ void HDock::place( int offset_x, int offset_y ){
	//  Set minimum size
	int w;
	int h;
	getMinSize( &w, &h );
	setSize( w, h );

	//  Do the actual place process
	Area::place( offset_x, offset_y );
}


};  //  namespace PhysicalComponents

