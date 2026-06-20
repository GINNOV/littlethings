
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


#include "Materials/Render.h"
#include "SysSupport/Messages.h"


namespace Materials {


int mode_to_feature[32];


void init_materials(){
	init_msg( "init_materials..." );
	mode_to_feature[RENDER_OPTION_RESERVED      ] = 0;
	mode_to_feature[RENDER_OPTION_SMOOTH        ] = 0;
	mode_to_feature[RENDER_OPTION_CULL_FACE     ] = CULL_FACE       ;
	mode_to_feature[RENDER_OPTION_BLEND         ] = BLEND           ;
	mode_to_feature[RENDER_OPTION_FOG           ] = FOG             ;
	mode_to_feature[RENDER_OPTION_NORMALIZE     ] = NORMALIZE       ;
	mode_to_feature[RENDER_OPTION_ALPHA_TEST    ] = ALPHA_TEST      ;
	mode_to_feature[RENDER_OPTION_DEPTH_TEST    ] = DEPTH_TEST      ;
	mode_to_feature[RENDER_OPTION_STENCIL_TEST  ] = STENCIL_TEST    ;
	mode_to_feature[RENDER_OPTION_SCISSOR_TEST  ] = SCISSOR_TEST    ;
	mode_to_feature[RENDER_OPTION_TEXTURE_1D    ] = TEXTURE_1D      ;
	mode_to_feature[RENDER_OPTION_TEXTURE_2D    ] = TEXTURE_2D      ;
	mode_to_feature[RENDER_OPTION_TEXTURE_3D    ] = 0;
	mode_to_feature[RENDER_OPTION_POINT_SMOOTH  ] = POINT_SMOOTH    ;
	mode_to_feature[RENDER_OPTION_LINE_SMOOTH   ] = LINE_SMOOTH     ;
	mode_to_feature[RENDER_OPTION_POLYGON_SMOOTH] = POLYGON_SMOOTH  ;
	mode_to_feature[RENDER_OPTION_AMBIENT       ] = 0;
	mode_to_feature[RENDER_OPTION_DIFFUSE       ] = 0;
	mode_to_feature[RENDER_OPTION_SPECULAR      ] = 0;
	mode_to_feature[RENDER_OPTION_EMISSION      ] = 0;
	mode_to_feature[RENDER_OPTION_SHINYNESS     ] = 0;
	mode_to_feature[RENDER_OPTION_BORDER        ] = 0;
	mode_to_feature[RENDER_OPTION_REMOVE_HIDDEN ] = 0;
	mode_to_feature[RENDER_OPTION_FRUSTUM_CULL  ] = 0;
	mode_to_feature[RENDER_OPTION_SORT_OBJECTS  ] = 0;
	mode_to_feature[RENDER_OPTION_SORT_ELEMENTS ] = 0;
	mode_to_feature[RENDER_OPTION_COLOR_MATERIAL] = COLOR_MATERIAL  ;
}

char *render_option_to_str( int a ){
	switch( a ){
	case RENDER_OPTION_RESERVED      : return "RENDER_OPTION_RESERVED      ";
	case RENDER_OPTION_SMOOTH        : return "RENDER_OPTION_SMOOTH        ";
	case RENDER_OPTION_CULL_FACE     : return "RENDER_OPTION_CULL_FACE     ";
	case RENDER_OPTION_BLEND         : return "RENDER_OPTION_BLEND         ";
	case RENDER_OPTION_FOG           : return "RENDER_OPTION_FOG           ";
	case RENDER_OPTION_NORMALIZE     : return "RENDER_OPTION_NORMALIZE     ";
	case RENDER_OPTION_ALPHA_TEST    : return "RENDER_OPTION_ALPHA_TEST    ";
	case RENDER_OPTION_DEPTH_TEST    : return "RENDER_OPTION_DEPTH_TEST    ";
	case RENDER_OPTION_STENCIL_TEST  : return "RENDER_OPTION_STENCIL_TEST  ";
	case RENDER_OPTION_SCISSOR_TEST  : return "RENDER_OPTION_SCISSOR_TEST  ";
	case RENDER_OPTION_TEXTURE_1D    : return "RENDER_OPTION_TEXTURE_1D    ";
	case RENDER_OPTION_TEXTURE_2D    : return "RENDER_OPTION_TEXTURE_2D    ";
	case RENDER_OPTION_TEXTURE_3D    : return "RENDER_OPTION_TEXTURE_3D    ";
	case RENDER_OPTION_POINT_SMOOTH  : return "RENDER_OPTION_POINT_SMOOTH  ";
	case RENDER_OPTION_LINE_SMOOTH   : return "RENDER_OPTION_LINE_SMOOTH   ";
	case RENDER_OPTION_POLYGON_SMOOTH: return "RENDER_OPTION_POLYGON_SMOOTH";
	case RENDER_OPTION_AMBIENT       : return "RENDER_OPTION_AMBIENT       ";
	case RENDER_OPTION_DIFFUSE       : return "RENDER_OPTION_DIFFUSE       ";
	case RENDER_OPTION_SPECULAR      : return "RENDER_OPTION_SPECULAR      ";
	case RENDER_OPTION_EMISSION      : return "RENDER_OPTION_EMISSION      ";
	case RENDER_OPTION_SHINYNESS     : return "RENDER_OPTION_SHINYNESS     ";
	case RENDER_OPTION_BORDER        : return "RENDER_OPTION_BORDER        ";
	case RENDER_OPTION_REMOVE_HIDDEN : return "RENDER_OPTION_REMOVE_HIDDEN ";
	case RENDER_OPTION_FRUSTUM_CULL  : return "RENDER_OPTION_FRUSTUM_CULL  ";
	case RENDER_OPTION_SORT_OBJECTS  : return "RENDER_OPTION_SORT_OBJECTS  ";
	case RENDER_OPTION_SORT_ELEMENTS : return "RENDER_OPTION_SORT_ELEMENTS ";
	case RENDER_OPTION_COLOR_MATERIAL: return "RENDER_OPTION_COLOR_MATERIAL";
	default:
		return "unknown";
		break;
	}
}


};  //  namespace Materials


