
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


#include "PhysicalComponents/Window.h"
#include "PhysicalComponents/LayoutConstraint.h"
#include "PhysicalComponents/WindowFrame.h"
#include "PhysicalComponents/GradientFill.h"


namespace PhysicalComponents {


//!  Constructor
Window::Window( const char *label, Area *area, Uint32 flags ):Area(label),label(label){
	constraint = new LayoutConstraint();

	this->insert( new WindowFrame(label) );
	this->insert(
		new GradientFill(
			Color( 0.9f, 0.9f, 1.00f, 0.33f ),
			Color( 0.9f, 0.9f, 0.95f, 0.33f ),
			Color( 0.9f, 0.9f, 0.90f, 0.33f ),
			Color( 0.9f, 0.9f, 0.95f, 0.33f )
		)
	);
	ordering = pre_self;

/*	int w;
	int h;*/
	Area::insert( area );
	getMinSize( constraint->min_x_fill_pixels, constraint->min_y_fill_pixels );
/*	constraint->min_x_fill_pixels = w;
	constraint->min_y_fill_pixels = h;*/
}


//!  Destructor
Window::~Window(){
}


//	Area Layout Interface
/*virtual*/ void Window::move( int x, int y ){
}


/*virtual*/ void Window::size( int w, int h ){
}


/*virtual*/ void Window::toFront(){
}


/*virtual*/ void Window::toBack(){
}


};	//	namespace PhysicalComponents

