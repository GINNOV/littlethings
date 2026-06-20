
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


#include "Graphics/View.h"
#include "Graphics/ViewClient.h"


namespace Graphics {


void ViewClient::color( float r, float g, float b, float a ){
	view->color( r, g, b, a );
}

void ViewClient::color( Color &c ){
	view->color( c );
}

void ViewClient::vertex( float x, float y, float z ){
	view->vertex( x, y, z );
}

void ViewClient::vertex( float *xyz ){
	view->vertex( xyz );
}

void ViewClient::normal( float x, float y, float z ){
	view->normal( x, y, z );
}

void ViewClient::normal( float *xyz ){
	view->normal( xyz );
}

void ViewClient::texture( float s, float t ){
	view->texture( s, t );
}

void ViewClient::texture( float *st ){
	view->texture( st );
}

void ViewClient::beginPoints(){
	view->beginLines();
}


void ViewClient::beginLines(){
	view->beginLines();
}


void ViewClient::beginLineStrip(){
	view->beginLines();
}


void ViewClient::beginLineLoop(){
	view->beginLineLoop();
}

void ViewClient::beginTriangles(){
	view->beginTriangles();
}

void ViewClient::beginTriangleFan(){
	view->beginTriangleFan();
}

void ViewClient::beginTriangleStrip(){
	view->beginTriangleStrip();
}

void ViewClient::beginQuads(){
	view->beginQuads();
}

void ViewClient::beginQuadStrip(){
	view->beginQuadStrip();
}

void ViewClient::beginPolygon(){
	view->beginPolygon();
}

void ViewClient::end(){
	view->end();
}

void ViewClient::setView( View *view ){
	this->view = view;
}

View *ViewClient::getView() const {
	return this->view;
}


};  //  namespace Graphics

