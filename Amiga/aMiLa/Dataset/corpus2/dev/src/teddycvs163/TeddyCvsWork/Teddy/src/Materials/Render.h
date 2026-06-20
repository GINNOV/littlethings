
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
	\ingroup g_materials
	\author  Timo Suoranta

	This file defines material rendering properties.

	RENDER_MODE     chooses betwen point, line or filled polygon rendering
	RENDER_LIGHTING chooses between color, primary light only, simple or full lighting model
	RENDER_OPTIONS  sets various options
*/


#ifndef TEDDY_MATERIALS_RENDER_H
#define TEDDY_MATERIALS_RENDER_H


#include "Graphics/Features.h"


namespace Materials {


#define RENDER_MODE_DEFAULT     RENDER_MODE_FILL_OUTLINE
#define RENDER_LIGHTING_DEFAULT RENDER_LIGHTING_SIMPLE
#define RENDER_OPTION_DEFAULT_M    \
	RENDER_OPTION_CULL_FACE_M    | \
	RENDER_OPTION_DEPTH_TEST_M   | \
	RENDER_OPTION_DIFFUSE_M      | \
	RENDER_OPTION_FRUSTUM_CULL_M

#define RENDER_OPTION_ALL_M          \
	RENDER_OPTION_SMOOTH_M         | \
	RENDER_OPTION_CULL_FACE_M      | \
	RENDER_OPTION_BLEND_M          | \
	RENDER_OPTION_FOG_M            | \
	RENDER_OPTION_NORMALIZE_M      | \
	RENDER_OPTION_ALPHA_TEST_M     | \
	RENDER_OPTION_DEPTH_TEST_M     | \
	RENDER_OPTION_STENCIL_TEST_M   | \
	RENDER_OPTION_SCISSOR_TEST_M   | \
	RENDER_OPTION_TEXTURE_1D_M     | \
	RENDER_OPTION_TEXTURE_2D_M     | \
	RENDER_OPTION_TEXTURE_3D_M     | \
	RENDER_OPTION_POINT_SMOOTH_M   | \
	RENDER_OPTION_LINE_SMOOTH_M    | \
	RENDER_OPTION_POLYGON_SMOOTH_M | \
	RENDER_OPTION_AMBIENT_M        | \
	RENDER_OPTION_DIFFUSE_M        | \
	RENDER_OPTION_SPECULAR_M       | \
	RENDER_OPTION_EMISSION_M       | \
	RENDER_OPTION_SHINYNESS_M      | \
	RENDER_OPTION_BORDER_M         | \
	RENDER_OPTION_REMOVE_HIDDEN_M  | \
	RENDER_OPTION_FRUSTUM_CULL_M   | \
	RENDER_OPTION_SORT_OBJECTS_M   | \
	RENDER_OPTION_SORT_ELEMENTS_M  | \
	RENDER_OPTION_COLOR_MATERIAL_M








#define RENDER_MODE_POINT                   0x01        //!  Very simple dot only rendering (pretty much useless?)
#define RENDER_MODE_LINE                    0x02        //!  Wireframe, possible backface culling, but no partial hidden line removal
#define RENDER_MODE_FILL                    0x03        //!  Polygons are filled with face colors
#define RENDER_MODE_FILL_OUTLINE            0x04        //!  Polygons are filled with face colors and have outline

#define RENDER_LIGHTING_COLOR               0x01        //!  Use face and or vertex colors, no lighting
#define RENDER_LIGHTING_CUSTOM              0x02        //!  Apply simple custom lighting calculations (minigl, tinygl etc.)
#define RENDER_LIGHTING_PRIMARY_LIGHT_ONLY  0x03        //!  Use scene's primary lightsource only
#define RENDER_LIGHTING_SIMPLE              0x04        //!  Max 8 lightsources per scene
#define RENDER_LIGHTING_FULL                0x05        //!  Advanced lighting including lightmaps (not yet implemented)

#define RENDER_OPTION_RESERVED               0l  //  0 could be used, but I have reserved it..
#define RENDER_OPTION_SMOOTH                 1l
#define RENDER_OPTION_CULL_FACE              2l
#define RENDER_OPTION_BLEND                  3l
#define RENDER_OPTION_FOG                    4l
#define RENDER_OPTION_NORMALIZE              5l  
#define RENDER_OPTION_ALPHA_TEST             6l 
#define RENDER_OPTION_DEPTH_TEST             7l  //!  CULL_FACE also recommended with this option
#define RENDER_OPTION_STENCIL_TEST           8l
#define RENDER_OPTION_SCISSOR_TEST           9l
#define RENDER_OPTION_TEXTURE_1D            10l
#define RENDER_OPTION_TEXTURE_2D            11l
#define RENDER_OPTION_TEXTURE_3D            12l
#define RENDER_OPTION_POINT_SMOOTH          13l  //!  Requires BLEND option
#define RENDER_OPTION_LINE_SMOOTH           14l  //!  Requires BLEND option
#define RENDER_OPTION_POLYGON_SMOOTH        15l  //!  Perspective correction
#define RENDER_OPTION_AMBIENT               16l  //!  If false, override all ambient colors
#define RENDER_OPTION_DIFFUSE               17l  //!  If false, override all diffuse colors
#define RENDER_OPTION_SPECULAR              18l  //!  If false, override all specular colors
#define RENDER_OPTION_EMISSION              19l  //!  If false, override all emission colors
#define RENDER_OPTION_SHINYNESS             20l  //!  If false, override all (specular) shinyness settings
#define RENDER_OPTION_BORDER                21l  //!  If false, override all border (color) settings
#define RENDER_OPTION_REMOVE_HIDDEN         22l  //!  Forces extra fill pass if not fill render type, requires DEPTH_TEST option, CULL_FACE recommended
#define RENDER_OPTION_FRUSTUM_CULL          23l  //!  Objects are culled to view frustum; always enable
#define RENDER_OPTION_SORT_OBJECTS          24l  //!  Objects are drawn from back to front
#define RENDER_OPTION_SORT_ELEMENTS         25l  //!  Elements are drawn from back to front
#define RENDER_OPTION_COLOR_MATERIAL        26l  //!  Use Color Material

#define RENDER_OPTION_RESERVED_M            (1l<<RENDER_OPTION_RESERVED       )
#define RENDER_OPTION_SMOOTH_M              (1l<<RENDER_OPTION_SMOOTH         )
#define RENDER_OPTION_CULL_FACE_M           (1l<<RENDER_OPTION_CULL_FACE      )
#define RENDER_OPTION_BLEND_M               (1l<<RENDER_OPTION_BLEND          )
#define RENDER_OPTION_FOG_M                 (1l<<RENDER_OPTION_FOG            )
#define RENDER_OPTION_NORMALIZE_M           (1l<<RENDER_OPTION_NORMALIZE      )
#define RENDER_OPTION_ALPHA_TEST_M          (1l<<RENDER_OPTION_ALPHA_TEST     )
#define RENDER_OPTION_DEPTH_TEST_M          (1l<<RENDER_OPTION_DEPTH_TEST     )
#define RENDER_OPTION_STENCIL_TEST_M        (1l<<RENDER_OPTION_STENCIL_TEST   )
#define RENDER_OPTION_SCISSOR_TEST_M        (1l<<RENDER_OPTION_SCISSOR_TEST   )
#define RENDER_OPTION_TEXTURE_1D_M          (1l<<RENDER_OPTION_TEXTURE_1D     )
#define RENDER_OPTION_TEXTURE_2D_M          (1l<<RENDER_OPTION_TEXTURE_2D     )
#define RENDER_OPTION_TEXTURE_3D_M          (1l<<RENDER_OPTION_TEXTURE_3D     )
#define RENDER_OPTION_POINT_SMOOTH_M        (1l<<RENDER_OPTION_POINT_SMOOTH   )
#define RENDER_OPTION_LINE_SMOOTH_M         (1l<<RENDER_OPTION_LINE_SMOOTH    )
#define RENDER_OPTION_POLYGON_SMOOTH_M      (1l<<RENDER_OPTION_POLYGON_SMOOTH )
#define RENDER_OPTION_AMBIENT_M             (1l<<RENDER_OPTION_AMBIENT        )
#define RENDER_OPTION_DIFFUSE_M             (1l<<RENDER_OPTION_DIFFUSE        )
#define RENDER_OPTION_SPECULAR_M            (1l<<RENDER_OPTION_SPECULAR       )
#define RENDER_OPTION_EMISSION_M            (1l<<RENDER_OPTION_EMISSION       )
#define RENDER_OPTION_SHINYNESS_M           (1l<<RENDER_OPTION_SHINYNESS      )
#define RENDER_OPTION_BORDER_M              (1l<<RENDER_OPTION_BORDER         )
#define RENDER_OPTION_REMOVE_HIDDEN_M       (1l<<RENDER_OPTION_REMOVE_HIDDEN  )
#define RENDER_OPTION_FRUSTUM_CULL_M        (1l<<RENDER_OPTION_FRUSTUM_CULL   )
#define RENDER_OPTION_SORT_OBJECTS_M        (1l<<RENDER_OPTION_SORT_OBJECTS   )
#define RENDER_OPTION_SORT_ELEMENTS_M       (1l<<RENDER_OPTION_SORT_ELEMENTS  )
#define RENDER_OPTION_COLOR_MATERIAL_M      (1l<<RENDER_OPTION_COLOR_MATERIAL )


extern int   mode_to_feature[32];
extern char *render_option_to_str( int a );
extern void  init_materials      ();


#define getFeature(a) mode_to_feature[a]


/*!
	Vertices usually belong to more than one face. Should the used color be average of faces colors?
	Vertex colors recommended, no above problem.

	It is also possible to use Projection without ambient, diffuse, specular and
	emission options. In that case, Projections settings override given material
	options. 
*/


/*!
	\define RENDER_TYPE_POINT

	Point	 elements: Render points
	Line	 elements: Render points
	GL_POINT polygons: Render GL_POINT
	GL_LINE  polygons: Render GL_POINT
	GL_FILL  polygons: Render GL_POINT

	Lighting: COLOR only
*/

/*!
	\define RENDER_TYPE_LINE

	Point	 elements: render points
	Line	 elements: render lines
	GL_POINT polygons: render GL_POINT
	GL_LINE  polygons: render GL_LINE
	GL_FILL  polygons: render GL_LINE
*/

/*!
	\define RENDER_TYPE_FILL

	Point	 elements: render points
	Line	 elements: render points
	GL_POINT polygons: render GL_POINT
	GL_LINE  polygons: render GL_LINE
	GL_FILL  polygons: render GL_FILL

	Lighting: Anything
*/

/*!
	\define RENDER_LIGHTING_COLOR

	Lighting is actually disabled in this mode.
	Colors set set to full diffuse color.
*/

/*!
	\define RENDER_LIGHTING_CUSTOM

	This is reserved mode. It is reserved for custom lighting calculations
	which do not require lighting support from underlying OpenGL implementation
	(MiniGL and TinyGL).

	Even though Material might have specified lighting enabled,
	everything is rendered without lights.
*/

/*!
	\define RENDER_LIGHTING_PRIMARY_LIGHT_ONLY

	Primary light of Scene is enabled.
	Material still may decide not to use lighting.
*/

/*
	\define RENDER_LIGHTING_SIMPLE

	Lighting is used by OpenGL specification.
	Maximum 8 lights per scene can be used (minimum supported by all valid OpenGL implementations).
*/

/*!
	\define RENDER_LIGHTING_FULL

	This is reserved mode. It is reserved for custom lighting system
	which would allow more than 8 lights per scene, and advanced features
	like lightmaps. This mode is not yet implemented.
*/

/*!
	\define RENDER_OPTION_CULL_FACE

	This option enables or disables backface culling. If this option
	is disabled in projection, no backface culling happens.
	
	Double sided elements are rendered without backface culling even
	if this option is set; you do not have to touch CULL_FACE.

	This option does not ensure hidden line removal if models are
	rendered in POINT or LINE (wireframe) mode. In those cases, if
	you want hidden feature removal, also set REMOVE_HIDDEN and
	DEPTH_TEST options.
*/

/*!
	\define RENDER_OPTION_BLEND

	This option enables use of alpha blending features.
	It is required for LINE_SMOOTH options.
	If this option is disabled, no alpha blending
	effects are rendered.
*/

/*!
	\define RENDER_OPTION_ALPHA_TEST

	This option is reserved for OpenGL alpha test. This feature
	is not yet implemented nor designed.
*/

/*!
	\define RENDER_OPTION_DEPTH_TEST

	Depth test option can only be enabled for those Views which
	have depth buffer. Using depth test enables automatic
	correct rendering of non-transluent elements (assuming suitable range
	of depth buffer is used).

	Transluent elements need sorting (which is not yet implemented).
*/

/*!
	\define RENDER_OPTION_STENCIL_TEST

	This option is reserved for OpenGL stencil test. This feature
	is not yet implemented nor designed.
*/

/*!
	\define RENDER_OPTION_FOG
*/

/*!
	\define RENDER_OPTION_TEXTURE_1D
*/

/*!
	\define RENDER_OPTION_TEXTURE_2D
*/

/*!
	\define RENDER_OPTION_TEXTURE_3D
*/

/*!
	\define RENDER_OPTION_LINE_SMOOTH
*/

/*!
	\define RENDER_OPTION_POLYGON_SMOOTH
*/

/*!
	\define RENDER_OPTION_AMBIENT
*/

/*!
	\define RENDER_OPTION_DIFFUSE
*/

/*!
	\define RENDER_OPTION_SPECULAR
*/

/*!
	\define RENDER_OPTION_EMISSION
*/

/*!
	\define RENDER_OPTION_NORMALIZE
*/

/*!
	\define RENDER_OPTION_REMOVE_HIDDEN
*/

/*!
	\define RENDER_OPTION_FRUSTUM_CULL
*/

/*!
	\define RENDER_OPTION_SORT
*/


};	//	namespace Materials


#endif	//	TEDDY_MATERIALS_RENDER_H

