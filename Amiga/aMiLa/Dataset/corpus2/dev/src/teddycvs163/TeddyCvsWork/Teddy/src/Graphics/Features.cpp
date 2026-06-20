
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


#include "Graphics/Features.h"
#include "Graphics/Device.h"
#include "SysSupport/Messages.h"


unsigned int feature_to_code[256];


void init_graphics_device(){
	init_msg( "init_graphics_device..." );
	feature_to_code[CULL_FACE     ] = GL_CULL_FACE     ;
	feature_to_code[BLEND         ] = GL_BLEND         ;
	feature_to_code[FOG           ] = GL_FOG           ;
	feature_to_code[NORMALIZE     ] = GL_NORMALIZE     ;
	feature_to_code[ALPHA_TEST    ] = GL_ALPHA_TEST    ;
	feature_to_code[DEPTH_TEST    ] = GL_DEPTH_TEST    ;
	feature_to_code[STENCIL_TEST  ] = GL_STENCIL_TEST  ;
	feature_to_code[SCISSOR_TEST  ] = GL_SCISSOR_TEST  ;
	feature_to_code[TEXTURE_1D    ] = GL_TEXTURE_1D    ;
	feature_to_code[TEXTURE_2D    ] = GL_TEXTURE_2D    ;
	feature_to_code[POINT_SMOOTH  ] = GL_POINT_SMOOTH  ;
	feature_to_code[LINE_SMOOTH   ] = GL_LINE_SMOOTH   ;
	feature_to_code[POLYGON_SMOOTH] = GL_POLYGON_SMOOTH;
	feature_to_code[POINT_OFFSET  ] = GL_POLYGON_OFFSET_POINT;
	feature_to_code[LINE_OFFSET   ] = GL_POLYGON_OFFSET_LINE;
	feature_to_code[POLYGON_OFFSET] = GL_POLYGON_OFFSET_FILL;
	feature_to_code[LIGHTING      ] = GL_LIGHTING      ;
	feature_to_code[LIGHT0        ] = GL_LIGHT0        ;
	feature_to_code[LIGHT1        ] = GL_LIGHT1        ;
	feature_to_code[LIGHT2        ] = GL_LIGHT2        ;
	feature_to_code[LIGHT3        ] = GL_LIGHT3        ;
	feature_to_code[LIGHT4        ] = GL_LIGHT4        ;
	feature_to_code[LIGHT5        ] = GL_LIGHT5        ;
	feature_to_code[LIGHT6        ] = GL_LIGHT6        ;
	feature_to_code[LIGHT7        ] = GL_LIGHT7        ;
	feature_to_code[COLOR_MATERIAL] = GL_COLOR_MATERIAL;
}

char *feature_to_str( int a ){
	switch( a ){
	case CULL_FACE     : return "CULL_FACE     ";
	case BLEND         : return "BLEND         ";
	case FOG           : return "FOG           ";
	case NORMALIZE     : return "NORMALIZE     ";
	case ALPHA_TEST    : return "ALPHA_TEST    ";
	case DEPTH_TEST    : return "DEPTH_TEST    ";
	case STENCIL_TEST  : return "STENCIL_TEST  ";
	case SCISSOR_TEST  : return "SCISSOR_TEST  ";
	case TEXTURE_1D    : return "TEXTURE_1D    ";
	case TEXTURE_2D    : return "TEXTURE_2D    ";
	case POINT_SMOOTH  : return "POINT_SMOOTH  ";
	case LINE_SMOOTH   : return "LINE_SMOOTH   ";
	case POLYGON_SMOOTH: return "POLYGON_SMOOTH";
	case POINT_OFFSET  : return "POINT_OFFSET  ";
	case LINE_OFFSET   : return "LINE_OFFSET   ";
	case POLYGON_OFFSET: return "POLYGON_OFFSET";
	case LIGHTING      : return "LIGHTING      ";
	case LIGHT0        : return "LIGHT0        ";
	case LIGHT1        : return "LIGHT1        ";
	case LIGHT2        : return "LIGHT2        ";
	case LIGHT3        : return "LIGHT3        ";
	case LIGHT4        : return "LIGHT4        ";
	case LIGHT5        : return "LIGHT5        ";
	case LIGHT6        : return "LIGHT6        ";
	case LIGHT7        : return "LIGHT7        ";
	case COLOR_MATERIAL: return "COLOR_MATERIAL";
	default:
		return "unknown";
		break;
	}
}

