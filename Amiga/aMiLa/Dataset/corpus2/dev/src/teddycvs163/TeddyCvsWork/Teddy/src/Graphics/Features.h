
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
	\file
	\ingroup  g_graphics
	\author   Timo Suoranta
	\brief	  OpenGL header
	\date	  2001
*/


#ifndef TEDDY_GRAPHICS_FEATURES_H
#define TEDDY_GRAPHICS_FEATURES_H


//	Features
#define CULL_FACE		 1
#define BLEND			 2
#define FOG 			 3
#define NORMALIZE		 4
#define ALPHA_TEST		 5
#define DEPTH_TEST		 6
#define STENCIL_TEST	 7
#define SCISSOR_TEST	 8
#define TEXTURE_1D		 9
#define TEXTURE_2D		10
#define POINT_SMOOTH	11
#define LINE_SMOOTH 	12
#define POLYGON_SMOOTH	13
#define POINT_OFFSET	14
#define LINE_OFFSET 	15
#define POLYGON_OFFSET	16
#define LIGHTING		19
#define LIGHT0			20
#define LIGHT1			21
#define LIGHT2			22
#define LIGHT3			23
#define LIGHT4			24
#define LIGHT5			25
#define LIGHT6			26
#define LIGHT7			27
#define COLOR_MATERIAL	28


extern unsigned int  feature_to_code[256];
extern void          init_graphics_device();
extern char         *feature_to_str( int a );

#define getCode(a) feature_to_code[a]


#endif	//	TEDDY_GRAPHICS_FEATURES_H


