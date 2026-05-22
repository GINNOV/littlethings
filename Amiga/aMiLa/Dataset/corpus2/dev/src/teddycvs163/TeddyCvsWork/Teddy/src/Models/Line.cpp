
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


#include "Models/Line.h"
#include "Models/Vertex.h"


namespace Models {


//!  Constructor, set start and end vertex pointers
Line::Line( Vertex *v1, Vertex * v2 ){
	start_point = v1;
	end_point   = v2;
}


//!  Copy-Constructor, clears state
Line::Line( const Line &l ){
	start_point = l.start_point;
	end_point   = l.end_point;
//	state       = 0;
}


/*!
	Draw routine.
*/
void Line::draw( Projection *p ){
	start_point->draw( p );
	end_point  ->draw( p );
}


//!  Debugging information
//void Line::debug(){
//	printf( "(" );
//	start_point->debug(); printf( ") - (" );
//	end_point->debug(); printf( ")" );
//}


//!  Swap start and end point vertices.
void Line::swap(){
	Vertex *old_start = start_point;
	start_point = end_point;
	end_point   = old_start;
}


/*!
	Compare equality based on pointer equality.
	Must use shared vertices with this one...
*/
bool Line::operator==( const Line &l ) const {
	if( (start_point==l.start_point &&
		 end_point  ==l.end_point      ) ||
		(start_point==l.end_point   &&
		 end_point  ==l.start_point    )    )
	{
		return true;
	}else{
		return false;
	}
}


//!  Compare inequality. Like operator==(), must use shared vertices...
bool Line::operator!=( const Line &l ) const {
	if( (start_point==l.start_point &&
		 end_point  ==l.end_point      ) ||
		(start_point==l.end_point   &&
		 end_point  ==l.start_point    )    )
	{
		return false;
	}else{
		return true;
	}
}


};  //  namespace Models

