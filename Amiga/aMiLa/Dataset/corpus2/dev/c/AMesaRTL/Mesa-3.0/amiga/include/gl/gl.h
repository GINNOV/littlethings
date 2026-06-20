
/*
 * Mesa 3-D graphics library
 * Version:  3.0
 * Copyright (C) 1995-1998  Brian Paul
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the Free
 * Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */


/*
 * gl.h
 *
 * Version 1.0  27 Jun 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * File created from gl.c ver 1.26 using GenProtos
 *
 * Version 2.0  13 Sep 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Changed to using mesamainBase
 * - Stubs are now #defined so that they pass the
 *   current mesamainBase rather than the global one
 *
 * Version 3.0  04 Oct 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Mesa v3.0
 *
 */

#ifndef GL_H
#define GL_H


#if defined(USE_MGL_NAMESPACE)
#include "gl_mangle.h"
#endif


#if defined(__WIN32__) || defined(__CYGWIN32__)
#include <windows.h>
#pragma warning (disable:4273)
#pragma warning( disable : 4244 ) /* '=' : conversion from 'const double ' to 'float ', possible loss of data */
#pragma warning( disable : 4018 ) /* '<' : signed/unsigned mismatch */
#pragma warning( disable : 4305 ) /* '=' : truncation from 'const double ' to 'float ' */
#pragma warning( disable : 4013 ) /* 'function' undefined; assuming extern returning int */
#pragma warning( disable : 4761 ) /* integral size mismatch in argument; conversion supplied */
#pragma warning( disable : 4273 ) /* 'identifier' : inconsistent DLL linkage. dllexport assumed */
#if (MESA_WARNQUIET>1)
#	pragma warning( disable : 4146 ) /* unary minus operator applied to unsigned type, result still unsigned */
#endif
#if defined(_STATIC_MESA) /* for use with static link lib build of Win32 edition only */
#undef APIENTRY
#undef CALLBACK
#undef WINGDIAPI
#define APIENTRY __cdecl
#define CALLBACK __cdecl
#define WINGDIAPI extern
#endif /* _STATIC_MESA support */
#else
#define APIENTRY
#define CALLBACK
#define WINGDIAPI extern
#endif


#ifdef __cplusplus
extern "C" {
#endif


#ifndef MAKE_MESAMAINLIB
#include "pragmas/gl_pragmas.h"
extern struct Library *mesamainBase;
#endif

#ifdef macintosh
	#pragma enumsalwaysint on
	#if PRAGMA_IMPORT_SUPPORTED
	#pragma import on
	#endif
#endif



/*
 * Apps can test for this symbol to do conditional compilation if needed.
 */
#define MESA

#define MESA_MAJOR_VERSION 3
#define MESA_MINOR_VERSION 0


#define GL_VERSION_1_1   1
#define GL_VERSION_1_2   1


/*
 *
 * Enumerations
 *
 */

typedef enum {
	/* Boolean values */
	GL_FALSE			= 0,
	GL_TRUE				= 1,

	/* Data types */
	GL_BYTE				= 0x1400,
	GL_UNSIGNED_BYTE		= 0x1401,
	GL_SHORT			= 0x1402,
	GL_UNSIGNED_SHORT		= 0x1403,
	GL_INT				= 0x1404,
	GL_UNSIGNED_INT			= 0x1405,
	GL_FLOAT			= 0x1406,
	GL_DOUBLE			= 0x140A,
	GL_2_BYTES			= 0x1407,
	GL_3_BYTES			= 0x1408,
	GL_4_BYTES			= 0x1409,

	/* Primitives */
	GL_LINES			= 0x0001,
	GL_POINTS			= 0x0000,
	GL_LINE_STRIP			= 0x0003,
	GL_LINE_LOOP			= 0x0002,
	GL_TRIANGLES			= 0x0004,
	GL_TRIANGLE_STRIP		= 0x0005,
	GL_TRIANGLE_FAN			= 0x0006,
	GL_QUADS			= 0x0007,
	GL_QUAD_STRIP			= 0x0008,
	GL_POLYGON			= 0x0009,
	GL_EDGE_FLAG			= 0x0B43,

	/* Vertex Arrays */
	GL_VERTEX_ARRAY			= 0x8074,
	GL_NORMAL_ARRAY			= 0x8075,
	GL_COLOR_ARRAY			= 0x8076,
	GL_INDEX_ARRAY			= 0x8077,
	GL_TEXTURE_COORD_ARRAY		= 0x8078,
	GL_EDGE_FLAG_ARRAY		= 0x8079,
	GL_VERTEX_ARRAY_SIZE		= 0x807A,
	GL_VERTEX_ARRAY_TYPE		= 0x807B,
	GL_VERTEX_ARRAY_STRIDE		= 0x807C,
	GL_NORMAL_ARRAY_TYPE		= 0x807E,
	GL_NORMAL_ARRAY_STRIDE		= 0x807F,
	GL_COLOR_ARRAY_SIZE		= 0x8081,
	GL_COLOR_ARRAY_TYPE		= 0x8082,
	GL_COLOR_ARRAY_STRIDE		= 0x8083,
	GL_INDEX_ARRAY_TYPE		= 0x8085,
	GL_INDEX_ARRAY_STRIDE		= 0x8086,
	GL_TEXTURE_COORD_ARRAY_SIZE	= 0x8088,
	GL_TEXTURE_COORD_ARRAY_TYPE	= 0x8089,
	GL_TEXTURE_COORD_ARRAY_STRIDE	= 0x808A,
	GL_EDGE_FLAG_ARRAY_STRIDE	= 0x808C,
	GL_VERTEX_ARRAY_POINTER		= 0x808E,
	GL_NORMAL_ARRAY_POINTER		= 0x808F,
	GL_COLOR_ARRAY_POINTER		= 0x8090,
	GL_INDEX_ARRAY_POINTER		= 0x8091,
	GL_TEXTURE_COORD_ARRAY_POINTER	= 0x8092,
	GL_EDGE_FLAG_ARRAY_POINTER	= 0x8093,
	GL_V2F				= 0x2A20,
	GL_V3F				= 0x2A21,
	GL_C4UB_V2F			= 0x2A22,
	GL_C4UB_V3F			= 0x2A23,
	GL_C3F_V3F			= 0x2A24,
	GL_N3F_V3F			= 0x2A25,
	GL_C4F_N3F_V3F			= 0x2A26,
	GL_T2F_V3F			= 0x2A27,
	GL_T4F_V4F			= 0x2A28,
	GL_T2F_C4UB_V3F			= 0x2A29,
	GL_T2F_C3F_V3F			= 0x2A2A,
	GL_T2F_N3F_V3F			= 0x2A2B,
	GL_T2F_C4F_N3F_V3F		= 0x2A2C,
	GL_T4F_C4F_N3F_V4F		= 0x2A2D,

	/* Matrix Mode */
	GL_MATRIX_MODE			= 0x0BA0,
	GL_MODELVIEW			= 0x1700,
	GL_PROJECTION			= 0x1701,
	GL_TEXTURE			= 0x1702,

	/* Points */
	GL_POINT_SMOOTH			= 0x0B10,
	GL_POINT_SIZE			= 0x0B11,
	GL_POINT_SIZE_GRANULARITY 	= 0x0B13,
	GL_POINT_SIZE_RANGE		= 0x0B12,

	/* Lines */
	GL_LINE_SMOOTH			= 0x0B20,
	GL_LINE_STIPPLE			= 0x0B24,
	GL_LINE_STIPPLE_PATTERN		= 0x0B25,
	GL_LINE_STIPPLE_REPEAT		= 0x0B26,
	GL_LINE_WIDTH			= 0x0B21,
	GL_LINE_WIDTH_GRANULARITY	= 0x0B23,
	GL_LINE_WIDTH_RANGE		= 0x0B22,

	/* Polygons */
	GL_POINT			= 0x1B00,
	GL_LINE				= 0x1B01,
	GL_FILL				= 0x1B02,
	GL_CCW				= 0x0901,
	GL_CW				= 0x0900,
	GL_FRONT			= 0x0404,
	GL_BACK				= 0x0405,
	GL_CULL_FACE			= 0x0B44,
	GL_CULL_FACE_MODE		= 0x0B45,
	GL_POLYGON_SMOOTH		= 0x0B41,
	GL_POLYGON_STIPPLE		= 0x0B42,
	GL_FRONT_FACE			= 0x0B46,
	GL_POLYGON_MODE			= 0x0B40,
	GL_POLYGON_OFFSET_FACTOR	= 0x8038,
	GL_POLYGON_OFFSET_UNITS		= 0x2A00,
	GL_POLYGON_OFFSET_POINT		= 0x2A01,
	GL_POLYGON_OFFSET_LINE		= 0x2A02,
	GL_POLYGON_OFFSET_FILL		= 0x8037,

	/* Display Lists */
	GL_COMPILE			= 0x1300,
	GL_COMPILE_AND_EXECUTE		= 0x1301,
	GL_LIST_BASE			= 0x0B32,
	GL_LIST_INDEX			= 0x0B33,
	GL_LIST_MODE			= 0x0B30,

	/* Depth buffer */
	GL_NEVER			= 0x0200,
	GL_LESS				= 0x0201,
	GL_GEQUAL			= 0x0206,
	GL_LEQUAL			= 0x0203,
	GL_GREATER			= 0x0204,
	GL_NOTEQUAL			= 0x0205,
	GL_EQUAL			= 0x0202,
	GL_ALWAYS			= 0x0207,
	GL_DEPTH_TEST			= 0x0B71,
	GL_DEPTH_BITS			= 0x0D56,
	GL_DEPTH_CLEAR_VALUE		= 0x0B73,
	GL_DEPTH_FUNC			= 0x0B74,
	GL_DEPTH_RANGE			= 0x0B70,
	GL_DEPTH_WRITEMASK		= 0x0B72,
	GL_DEPTH_COMPONENT		= 0x1902,

	/* Lighting */
	GL_LIGHTING			= 0x0B50,
	GL_LIGHT0			= 0x4000,
	GL_LIGHT1			= 0x4001,
	GL_LIGHT2			= 0x4002,
	GL_LIGHT3			= 0x4003,
	GL_LIGHT4			= 0x4004,
	GL_LIGHT5			= 0x4005,
	GL_LIGHT6			= 0x4006,
	GL_LIGHT7			= 0x4007,
	GL_SPOT_EXPONENT		= 0x1205,
	GL_SPOT_CUTOFF			= 0x1206,
	GL_CONSTANT_ATTENUATION		= 0x1207,
	GL_LINEAR_ATTENUATION		= 0x1208,
	GL_QUADRATIC_ATTENUATION	= 0x1209,
	GL_AMBIENT			= 0x1200,
	GL_DIFFUSE			= 0x1201,
	GL_SPECULAR			= 0x1202,
	GL_SHININESS			= 0x1601,
	GL_EMISSION			= 0x1600,
	GL_POSITION			= 0x1203,
	GL_SPOT_DIRECTION		= 0x1204,
	GL_AMBIENT_AND_DIFFUSE		= 0x1602,
	GL_COLOR_INDEXES		= 0x1603,
	GL_LIGHT_MODEL_TWO_SIDE		= 0x0B52,
	GL_LIGHT_MODEL_LOCAL_VIEWER	= 0x0B51,
	GL_LIGHT_MODEL_AMBIENT		= 0x0B53,
	GL_FRONT_AND_BACK		= 0x0408,
	GL_SHADE_MODEL			= 0x0B54,
	GL_FLAT				= 0x1D00,
	GL_SMOOTH			= 0x1D01,
	GL_COLOR_MATERIAL		= 0x0B57,
	GL_COLOR_MATERIAL_FACE		= 0x0B55,
	GL_COLOR_MATERIAL_PARAMETER	= 0x0B56,
	GL_NORMALIZE			= 0x0BA1,

	/* User clipping planes */
	GL_CLIP_PLANE0			= 0x3000,
	GL_CLIP_PLANE1			= 0x3001,
	GL_CLIP_PLANE2			= 0x3002,
	GL_CLIP_PLANE3			= 0x3003,
	GL_CLIP_PLANE4			= 0x3004,
	GL_CLIP_PLANE5			= 0x3005,

	/* Accumulation buffer */
	GL_ACCUM_RED_BITS		= 0x0D58,
	GL_ACCUM_GREEN_BITS		= 0x0D59,
	GL_ACCUM_BLUE_BITS		= 0x0D5A,
	GL_ACCUM_ALPHA_BITS		= 0x0D5B,
	GL_ACCUM_CLEAR_VALUE		= 0x0B80,
	GL_ACCUM			= 0x0100,
	GL_ADD				= 0x0104,
	GL_LOAD				= 0x0101,
	GL_MULT				= 0x0103,
	GL_RETURN			= 0x0102,

	/* Alpha testing */
	GL_ALPHA_TEST			= 0x0BC0,
	GL_ALPHA_TEST_REF		= 0x0BC2,
	GL_ALPHA_TEST_FUNC		= 0x0BC1,

	/* Blending */
	GL_BLEND			= 0x0BE2,
	GL_BLEND_SRC			= 0x0BE1,
	GL_BLEND_DST			= 0x0BE0,
	GL_ZERO				= 0,
	GL_ONE				= 1,
	GL_SRC_COLOR			= 0x0300,
	GL_ONE_MINUS_SRC_COLOR		= 0x0301,
	GL_DST_COLOR			= 0x0306,
	GL_ONE_MINUS_DST_COLOR		= 0x0307,
	GL_SRC_ALPHA			= 0x0302,
	GL_ONE_MINUS_SRC_ALPHA		= 0x0303,
	GL_DST_ALPHA			= 0x0304,
	GL_ONE_MINUS_DST_ALPHA		= 0x0305,
	GL_SRC_ALPHA_SATURATE		= 0x0308,
	GL_CONSTANT_COLOR		= 0x8001,
	GL_ONE_MINUS_CONSTANT_COLOR	= 0x8002,
	GL_CONSTANT_ALPHA		= 0x8003,
	GL_ONE_MINUS_CONSTANT_ALPHA	= 0x8004,

	/* Render Mode */
	GL_FEEDBACK			= 0x1C01,
	GL_RENDER			= 0x1C00,
	GL_SELECT			= 0x1C02,

	/* Feedback */
	GL_2D				= 0x0600,
	GL_3D				= 0x0601,
	GL_3D_COLOR			= 0x0602,
	GL_3D_COLOR_TEXTURE		= 0x0603,
	GL_4D_COLOR_TEXTURE		= 0x0604,
	GL_POINT_TOKEN			= 0x0701,
	GL_LINE_TOKEN			= 0x0702,
	GL_LINE_RESET_TOKEN		= 0x0707,
	GL_POLYGON_TOKEN		= 0x0703,
	GL_BITMAP_TOKEN			= 0x0704,
	GL_DRAW_PIXEL_TOKEN		= 0x0705,
	GL_COPY_PIXEL_TOKEN		= 0x0706,
	GL_PASS_THROUGH_TOKEN		= 0x0700,
	GL_FEEDBACK_BUFFER_POINTER	= 0x0DF0,
	GL_FEEDBACK_BUFFER_SIZE		= 0x0DF1,
	GL_FEEDBACK_BUFFER_TYPE		= 0x0DF2,

	/* Selection */
	GL_SELECTION_BUFFER_POINTER	= 0x0DF3,
	GL_SELECTION_BUFFER_SIZE	= 0x0DF4,

	/* Fog */
	GL_FOG				= 0x0B60,
	GL_FOG_MODE			= 0x0B65,
	GL_FOG_DENSITY			= 0x0B62,
	GL_FOG_COLOR			= 0x0B66,
	GL_FOG_INDEX			= 0x0B61,
	GL_FOG_START			= 0x0B63,
	GL_FOG_END			= 0x0B64,
	GL_LINEAR			= 0x2601,
	GL_EXP				= 0x0800,
	GL_EXP2				= 0x0801,

	/* Logic Ops */
	GL_LOGIC_OP			= 0x0BF1,
	GL_INDEX_LOGIC_OP		= 0x0BF1,
	GL_COLOR_LOGIC_OP		= 0x0BF2,
	GL_LOGIC_OP_MODE		= 0x0BF0,
	GL_CLEAR			= 0x1500,
	GL_SET				= 0x150F,
	GL_COPY				= 0x1503,
	GL_COPY_INVERTED		= 0x150C,
	GL_NOOP				= 0x1505,
	GL_INVERT			= 0x150A,
	GL_AND				= 0x1501,
	GL_NAND				= 0x150E,
	GL_OR				= 0x1507,
	GL_NOR				= 0x1508,
	GL_XOR				= 0x1506,
	GL_EQUIV			= 0x1509,
	GL_AND_REVERSE			= 0x1502,
	GL_AND_INVERTED			= 0x1504,
	GL_OR_REVERSE			= 0x150B,
	GL_OR_INVERTED			= 0x150D,

	/* Stencil */
	GL_STENCIL_TEST			= 0x0B90,
	GL_STENCIL_WRITEMASK		= 0x0B98,
	GL_STENCIL_BITS			= 0x0D57,
	GL_STENCIL_FUNC			= 0x0B92,
	GL_STENCIL_VALUE_MASK		= 0x0B93,
	GL_STENCIL_REF			= 0x0B97,
	GL_STENCIL_FAIL			= 0x0B94,
	GL_STENCIL_PASS_DEPTH_PASS	= 0x0B96,
	GL_STENCIL_PASS_DEPTH_FAIL	= 0x0B95,
	GL_STENCIL_CLEAR_VALUE		= 0x0B91,
	GL_STENCIL_INDEX		= 0x1901,
	GL_KEEP				= 0x1E00,
	GL_REPLACE			= 0x1E01,
	GL_INCR				= 0x1E02,
	GL_DECR				= 0x1E03,

	/* Buffers, Pixel Drawing/Reading */
	GL_NONE				= 0,
	GL_LEFT				= 0x0406,
	GL_RIGHT			= 0x0407,
	/*GL_FRONT			= 0x0404, */
	/*GL_BACK			= 0x0405, */
	/*GL_FRONT_AND_BACK		= 0x0408, */
	GL_FRONT_LEFT			= 0x0400,
	GL_FRONT_RIGHT			= 0x0401,
	GL_BACK_LEFT			= 0x0402,
	GL_BACK_RIGHT			= 0x0403,
	GL_AUX0				= 0x0409,
	GL_AUX1				= 0x040A,
	GL_AUX2				= 0x040B,
	GL_AUX3				= 0x040C,
	GL_COLOR_INDEX			= 0x1900,
	GL_RED				= 0x1903,
	GL_GREEN			= 0x1904,
	GL_BLUE				= 0x1905,
	GL_ALPHA			= 0x1906,
	GL_LUMINANCE			= 0x1909,
	GL_LUMINANCE_ALPHA		= 0x190A,
	GL_ALPHA_BITS			= 0x0D55,
	GL_RED_BITS			= 0x0D52,
	GL_GREEN_BITS			= 0x0D53,
	GL_BLUE_BITS			= 0x0D54,
	GL_INDEX_BITS			= 0x0D51,
	GL_SUBPIXEL_BITS		= 0x0D50,
	GL_AUX_BUFFERS			= 0x0C00,
	GL_READ_BUFFER			= 0x0C02,
	GL_DRAW_BUFFER			= 0x0C01,
	GL_DOUBLEBUFFER			= 0x0C32,
	GL_STEREO			= 0x0C33,
	GL_BITMAP			= 0x1A00,
	GL_COLOR			= 0x1800,
	GL_DEPTH			= 0x1801,
	GL_STENCIL			= 0x1802,
	GL_DITHER			= 0x0BD0,
	GL_RGB				= 0x1907,
	GL_RGBA				= 0x1908,

	/* Implementation limits */
	GL_MAX_LIST_NESTING		= 0x0B31,
	GL_MAX_ATTRIB_STACK_DEPTH	= 0x0D35,
	GL_MAX_MODELVIEW_STACK_DEPTH	= 0x0D36,
	GL_MAX_NAME_STACK_DEPTH		= 0x0D37,
	GL_MAX_PROJECTION_STACK_DEPTH	= 0x0D38,
	GL_MAX_TEXTURE_STACK_DEPTH	= 0x0D39,
	GL_MAX_EVAL_ORDER		= 0x0D30,
	GL_MAX_LIGHTS			= 0x0D31,
	GL_MAX_CLIP_PLANES		= 0x0D32,
	GL_MAX_TEXTURE_SIZE		= 0x0D33,
	GL_MAX_PIXEL_MAP_TABLE		= 0x0D34,
	GL_MAX_VIEWPORT_DIMS		= 0x0D3A,
	GL_MAX_CLIENT_ATTRIB_STACK_DEPTH= 0x0D3B,

	/* Gets */
	GL_ATTRIB_STACK_DEPTH		= 0x0BB0,
	GL_CLIENT_ATTRIB_STACK_DEPTH	= 0x0BB1,
	GL_COLOR_CLEAR_VALUE		= 0x0C22,
	GL_COLOR_WRITEMASK		= 0x0C23,
	GL_CURRENT_INDEX		= 0x0B01,
	GL_CURRENT_COLOR		= 0x0B00,
	GL_CURRENT_NORMAL		= 0x0B02,
	GL_CURRENT_RASTER_COLOR		= 0x0B04,
	GL_CURRENT_RASTER_DISTANCE	= 0x0B09,
	GL_CURRENT_RASTER_INDEX		= 0x0B05,
	GL_CURRENT_RASTER_POSITION	= 0x0B07,
	GL_CURRENT_RASTER_TEXTURE_COORDS = 0x0B06,
	GL_CURRENT_RASTER_POSITION_VALID = 0x0B08,
	GL_CURRENT_TEXTURE_COORDS	= 0x0B03,
	GL_INDEX_CLEAR_VALUE		= 0x0C20,
	GL_INDEX_MODE			= 0x0C30,
	GL_INDEX_WRITEMASK		= 0x0C21,
	GL_MODELVIEW_MATRIX		= 0x0BA6,
	GL_MODELVIEW_STACK_DEPTH	= 0x0BA3,
	GL_NAME_STACK_DEPTH		= 0x0D70,
	GL_PROJECTION_MATRIX		= 0x0BA7,
	GL_PROJECTION_STACK_DEPTH	= 0x0BA4,
	GL_RENDER_MODE			= 0x0C40,
	GL_RGBA_MODE			= 0x0C31,
	GL_TEXTURE_MATRIX		= 0x0BA8,
	GL_TEXTURE_STACK_DEPTH		= 0x0BA5,
	GL_VIEWPORT			= 0x0BA2,


	/* Evaluators */
	GL_AUTO_NORMAL			= 0x0D80,
	GL_MAP1_COLOR_4			= 0x0D90,
	GL_MAP1_GRID_DOMAIN		= 0x0DD0,
	GL_MAP1_GRID_SEGMENTS		= 0x0DD1,
	GL_MAP1_INDEX			= 0x0D91,
	GL_MAP1_NORMAL			= 0x0D92,
	GL_MAP1_TEXTURE_COORD_1		= 0x0D93,
	GL_MAP1_TEXTURE_COORD_2		= 0x0D94,
	GL_MAP1_TEXTURE_COORD_3		= 0x0D95,
	GL_MAP1_TEXTURE_COORD_4		= 0x0D96,
	GL_MAP1_VERTEX_3		= 0x0D97,
	GL_MAP1_VERTEX_4		= 0x0D98,
	GL_MAP2_COLOR_4			= 0x0DB0,
	GL_MAP2_GRID_DOMAIN		= 0x0DD2,
	GL_MAP2_GRID_SEGMENTS		= 0x0DD3,
	GL_MAP2_INDEX			= 0x0DB1,
	GL_MAP2_NORMAL			= 0x0DB2,
	GL_MAP2_TEXTURE_COORD_1		= 0x0DB3,
	GL_MAP2_TEXTURE_COORD_2		= 0x0DB4,
	GL_MAP2_TEXTURE_COORD_3		= 0x0DB5,
	GL_MAP2_TEXTURE_COORD_4		= 0x0DB6,
	GL_MAP2_VERTEX_3		= 0x0DB7,
	GL_MAP2_VERTEX_4		= 0x0DB8,
	GL_COEFF			= 0x0A00,
	GL_DOMAIN			= 0x0A02,
	GL_ORDER			= 0x0A01,

	/* Hints */
	GL_FOG_HINT			= 0x0C54,
	GL_LINE_SMOOTH_HINT		= 0x0C52,
	GL_PERSPECTIVE_CORRECTION_HINT	= 0x0C50,
	GL_POINT_SMOOTH_HINT		= 0x0C51,
	GL_POLYGON_SMOOTH_HINT		= 0x0C53,
	GL_DONT_CARE			= 0x1100,
	GL_FASTEST			= 0x1101,
	GL_NICEST			= 0x1102,

	/* Scissor box */
	GL_SCISSOR_TEST			= 0x0C11,
	GL_SCISSOR_BOX			= 0x0C10,

	/* Pixel Mode / Transfer */
	GL_MAP_COLOR			= 0x0D10,
	GL_MAP_STENCIL			= 0x0D11,
	GL_INDEX_SHIFT			= 0x0D12,
	GL_INDEX_OFFSET			= 0x0D13,
	GL_RED_SCALE			= 0x0D14,
	GL_RED_BIAS			= 0x0D15,
	GL_GREEN_SCALE			= 0x0D18,
	GL_GREEN_BIAS			= 0x0D19,
	GL_BLUE_SCALE			= 0x0D1A,
	GL_BLUE_BIAS			= 0x0D1B,
	GL_ALPHA_SCALE			= 0x0D1C,
	GL_ALPHA_BIAS			= 0x0D1D,
	GL_DEPTH_SCALE			= 0x0D1E,
	GL_DEPTH_BIAS			= 0x0D1F,
	GL_PIXEL_MAP_S_TO_S_SIZE	= 0x0CB1,
	GL_PIXEL_MAP_I_TO_I_SIZE	= 0x0CB0,
	GL_PIXEL_MAP_I_TO_R_SIZE	= 0x0CB2,
	GL_PIXEL_MAP_I_TO_G_SIZE	= 0x0CB3,
	GL_PIXEL_MAP_I_TO_B_SIZE	= 0x0CB4,
	GL_PIXEL_MAP_I_TO_A_SIZE	= 0x0CB5,
	GL_PIXEL_MAP_R_TO_R_SIZE	= 0x0CB6,
	GL_PIXEL_MAP_G_TO_G_SIZE	= 0x0CB7,
	GL_PIXEL_MAP_B_TO_B_SIZE	= 0x0CB8,
	GL_PIXEL_MAP_A_TO_A_SIZE	= 0x0CB9,
	GL_PIXEL_MAP_S_TO_S		= 0x0C71,
	GL_PIXEL_MAP_I_TO_I		= 0x0C70,
	GL_PIXEL_MAP_I_TO_R		= 0x0C72,
	GL_PIXEL_MAP_I_TO_G		= 0x0C73,
	GL_PIXEL_MAP_I_TO_B		= 0x0C74,
	GL_PIXEL_MAP_I_TO_A		= 0x0C75,
	GL_PIXEL_MAP_R_TO_R		= 0x0C76,
	GL_PIXEL_MAP_G_TO_G		= 0x0C77,
	GL_PIXEL_MAP_B_TO_B		= 0x0C78,
	GL_PIXEL_MAP_A_TO_A		= 0x0C79,
	GL_PACK_ALIGNMENT		= 0x0D05,
	GL_PACK_LSB_FIRST		= 0x0D01,
	GL_PACK_ROW_LENGTH		= 0x0D02,
	GL_PACK_SKIP_PIXELS		= 0x0D04,
	GL_PACK_SKIP_ROWS		= 0x0D03,
	GL_PACK_SWAP_BYTES		= 0x0D00,
	GL_UNPACK_ALIGNMENT		= 0x0CF5,
	GL_UNPACK_LSB_FIRST		= 0x0CF1,
	GL_UNPACK_ROW_LENGTH		= 0x0CF2,
	GL_UNPACK_SKIP_PIXELS		= 0x0CF4,
	GL_UNPACK_SKIP_ROWS		= 0x0CF3,
	GL_UNPACK_SWAP_BYTES		= 0x0CF0,
	GL_ZOOM_X			= 0x0D16,
	GL_ZOOM_Y			= 0x0D17,

	/* Texture mapping */
	GL_TEXTURE_ENV			= 0x2300,
	GL_TEXTURE_ENV_MODE		= 0x2200,
	GL_TEXTURE_1D			= 0x0DE0,
	GL_TEXTURE_2D			= 0x0DE1,
	GL_TEXTURE_WRAP_S		= 0x2802,
	GL_TEXTURE_WRAP_T		= 0x2803,
	GL_TEXTURE_MAG_FILTER		= 0x2800,
	GL_TEXTURE_MIN_FILTER		= 0x2801,
	GL_TEXTURE_ENV_COLOR		= 0x2201,
	GL_TEXTURE_GEN_S		= 0x0C60,
	GL_TEXTURE_GEN_T		= 0x0C61,
	GL_TEXTURE_GEN_MODE		= 0x2500,
	GL_TEXTURE_BORDER_COLOR		= 0x1004,
	GL_TEXTURE_WIDTH		= 0x1000,
	GL_TEXTURE_HEIGHT		= 0x1001,
	GL_TEXTURE_BORDER		= 0x1005,
	GL_TEXTURE_COMPONENTS		= 0x1003,
	GL_TEXTURE_RED_SIZE		= 0x805C,
	GL_TEXTURE_GREEN_SIZE		= 0x805D,
	GL_TEXTURE_BLUE_SIZE		= 0x805E,
	GL_TEXTURE_ALPHA_SIZE		= 0x805F,
	GL_TEXTURE_LUMINANCE_SIZE	= 0x8060,
	GL_TEXTURE_INTENSITY_SIZE	= 0x8061,
	GL_NEAREST_MIPMAP_NEAREST	= 0x2700,
	GL_NEAREST_MIPMAP_LINEAR	= 0x2702,
	GL_LINEAR_MIPMAP_NEAREST	= 0x2701,
	GL_LINEAR_MIPMAP_LINEAR		= 0x2703,
	GL_OBJECT_LINEAR		= 0x2401,
	GL_OBJECT_PLANE			= 0x2501,
	GL_EYE_LINEAR			= 0x2400,
	GL_EYE_PLANE			= 0x2502,
	GL_SPHERE_MAP			= 0x2402,
	GL_DECAL			= 0x2101,
	GL_MODULATE			= 0x2100,
	GL_NEAREST			= 0x2600,
	GL_REPEAT			= 0x2901,
	GL_CLAMP			= 0x2900,
	GL_S				= 0x2000,
	GL_T				= 0x2001,
	GL_R				= 0x2002,
	GL_Q				= 0x2003,
	GL_TEXTURE_GEN_R		= 0x0C62,
	GL_TEXTURE_GEN_Q		= 0x0C63,

	/* GL 1.1 texturing */
	GL_PROXY_TEXTURE_1D		= 0x8063,
	GL_PROXY_TEXTURE_2D		= 0x8064,
	GL_TEXTURE_PRIORITY		= 0x8066,
	GL_TEXTURE_RESIDENT		= 0x8067,
	GL_TEXTURE_BINDING_1D		= 0x8068,
	GL_TEXTURE_BINDING_2D		= 0x8069,
	GL_TEXTURE_INTERNAL_FORMAT	= 0x1003,

	/* GL 1.2 texturing */
	GL_PACK_SKIP_IMAGES		= 0x806B,
	GL_PACK_IMAGE_HEIGHT		= 0x806C,
	GL_UNPACK_SKIP_IMAGES		= 0x806D,
	GL_UNPACK_IMAGE_HEIGHT		= 0x806E,
	GL_TEXTURE_3D			= 0x806F,
	GL_PROXY_TEXTURE_3D		= 0x8070,
	GL_TEXTURE_DEPTH		= 0x8071,
	GL_TEXTURE_WRAP_R		= 0x8072,
	GL_MAX_3D_TEXTURE_SIZE		= 0x8073,
	GL_TEXTURE_BINDING_3D		= 0x806A,

	/* Internal texture formats (GL 1.1) */
	GL_ALPHA4			= 0x803B,
	GL_ALPHA8			= 0x803C,
	GL_ALPHA12			= 0x803D,
	GL_ALPHA16			= 0x803E,
	GL_LUMINANCE4			= 0x803F,
	GL_LUMINANCE8			= 0x8040,
	GL_LUMINANCE12			= 0x8041,
	GL_LUMINANCE16			= 0x8042,
	GL_LUMINANCE4_ALPHA4		= 0x8043,
	GL_LUMINANCE6_ALPHA2		= 0x8044,
	GL_LUMINANCE8_ALPHA8		= 0x8045,
	GL_LUMINANCE12_ALPHA4		= 0x8046,
	GL_LUMINANCE12_ALPHA12		= 0x8047,
	GL_LUMINANCE16_ALPHA16		= 0x8048,
	GL_INTENSITY			= 0x8049,
	GL_INTENSITY4			= 0x804A,
	GL_INTENSITY8			= 0x804B,
	GL_INTENSITY12			= 0x804C,
	GL_INTENSITY16			= 0x804D,
	GL_R3_G3_B2			= 0x2A10,
	GL_RGB4				= 0x804F,
	GL_RGB5				= 0x8050,
	GL_RGB8				= 0x8051,
	GL_RGB10			= 0x8052,
	GL_RGB12			= 0x8053,
	GL_RGB16			= 0x8054,
	GL_RGBA2			= 0x8055,
	GL_RGBA4			= 0x8056,
	GL_RGB5_A1			= 0x8057,
	GL_RGBA8			= 0x8058,
	GL_RGB10_A2			= 0x8059,
	GL_RGBA12			= 0x805A,
	GL_RGBA16			= 0x805B,

	/* Utility */
	GL_VENDOR			= 0x1F00,
	GL_RENDERER			= 0x1F01,
	GL_VERSION			= 0x1F02,
	GL_EXTENSIONS			= 0x1F03,

	/* Errors */
	GL_INVALID_VALUE		= 0x0501,
	GL_INVALID_ENUM			= 0x0500,
	GL_INVALID_OPERATION		= 0x0502,
	GL_STACK_OVERFLOW		= 0x0503,
	GL_STACK_UNDERFLOW		= 0x0504,
	GL_OUT_OF_MEMORY		= 0x0505,

	/*
	 * Extensions
	 */

	/* GL_EXT_blend_minmax and GL_EXT_blend_color */
	GL_CONSTANT_COLOR_EXT			= 0x8001,
	GL_ONE_MINUS_CONSTANT_COLOR_EXT		= 0x8002,
	GL_CONSTANT_ALPHA_EXT			= 0x8003,
	GL_ONE_MINUS_CONSTANT_ALPHA_EXT		= 0x8004,
	GL_BLEND_EQUATION_EXT			= 0x8009,
	GL_MIN_EXT				= 0x8007,
	GL_MAX_EXT				= 0x8008,
	GL_FUNC_ADD_EXT				= 0x8006,
	GL_FUNC_SUBTRACT_EXT			= 0x800A,
	GL_FUNC_REVERSE_SUBTRACT_EXT		= 0x800B,
	GL_BLEND_COLOR_EXT			= 0x8005,

	/* GL_EXT_polygon_offset */
	GL_POLYGON_OFFSET_EXT			= 0x8037,
	GL_POLYGON_OFFSET_FACTOR_EXT		= 0x8038,
	GL_POLYGON_OFFSET_BIAS_EXT		= 0x8039,

	/* GL_EXT_vertex_array */
	GL_VERTEX_ARRAY_EXT			= 0x8074,
	GL_NORMAL_ARRAY_EXT			= 0x8075,
	GL_COLOR_ARRAY_EXT			= 0x8076,
	GL_INDEX_ARRAY_EXT			= 0x8077,
	GL_TEXTURE_COORD_ARRAY_EXT		= 0x8078,
	GL_EDGE_FLAG_ARRAY_EXT			= 0x8079,
	GL_VERTEX_ARRAY_SIZE_EXT		= 0x807A,
	GL_VERTEX_ARRAY_TYPE_EXT		= 0x807B,
	GL_VERTEX_ARRAY_STRIDE_EXT		= 0x807C,
	GL_VERTEX_ARRAY_COUNT_EXT		= 0x807D,
	GL_NORMAL_ARRAY_TYPE_EXT		= 0x807E,
	GL_NORMAL_ARRAY_STRIDE_EXT		= 0x807F,
	GL_NORMAL_ARRAY_COUNT_EXT		= 0x8080,
	GL_COLOR_ARRAY_SIZE_EXT			= 0x8081,
	GL_COLOR_ARRAY_TYPE_EXT			= 0x8082,
	GL_COLOR_ARRAY_STRIDE_EXT		= 0x8083,
	GL_COLOR_ARRAY_COUNT_EXT		= 0x8084,
	GL_INDEX_ARRAY_TYPE_EXT			= 0x8085,
	GL_INDEX_ARRAY_STRIDE_EXT		= 0x8086,
	GL_INDEX_ARRAY_COUNT_EXT		= 0x8087,
	GL_TEXTURE_COORD_ARRAY_SIZE_EXT		= 0x8088,
	GL_TEXTURE_COORD_ARRAY_TYPE_EXT		= 0x8089,
	GL_TEXTURE_COORD_ARRAY_STRIDE_EXT	= 0x808A,
	GL_TEXTURE_COORD_ARRAY_COUNT_EXT	= 0x808B,
	GL_EDGE_FLAG_ARRAY_STRIDE_EXT		= 0x808C,
	GL_EDGE_FLAG_ARRAY_COUNT_EXT		= 0x808D,
	GL_VERTEX_ARRAY_POINTER_EXT		= 0x808E,
	GL_NORMAL_ARRAY_POINTER_EXT		= 0x808F,
	GL_COLOR_ARRAY_POINTER_EXT		= 0x8090,
	GL_INDEX_ARRAY_POINTER_EXT		= 0x8091,
	GL_TEXTURE_COORD_ARRAY_POINTER_EXT	= 0x8092,
	GL_EDGE_FLAG_ARRAY_POINTER_EXT		= 0x8093,

	/* GL_EXT_texture_object */
	GL_TEXTURE_PRIORITY_EXT			= 0x8066,
	GL_TEXTURE_RESIDENT_EXT			= 0x8067,
	GL_TEXTURE_1D_BINDING_EXT		= 0x8068,
	GL_TEXTURE_2D_BINDING_EXT		= 0x8069,

	/* GL_EXT_texture3D */
	GL_PACK_SKIP_IMAGES_EXT			= 0x806B,
	GL_PACK_IMAGE_HEIGHT_EXT		= 0x806C,
	GL_UNPACK_SKIP_IMAGES_EXT		= 0x806D,
	GL_UNPACK_IMAGE_HEIGHT_EXT		= 0x806E,
	GL_TEXTURE_3D_EXT			= 0x806F,
	GL_PROXY_TEXTURE_3D_EXT			= 0x8070,
	GL_TEXTURE_DEPTH_EXT			= 0x8071,
	GL_TEXTURE_WRAP_R_EXT			= 0x8072,
	GL_MAX_3D_TEXTURE_SIZE_EXT		= 0x8073,
	GL_TEXTURE_3D_BINDING_EXT		= 0x806A,

        /* GL_EXT_paletted_texture */
	GL_TABLE_TOO_LARGE_EXT			= 0x8031,
	GL_COLOR_TABLE_FORMAT_EXT		= 0x80D8,
	GL_COLOR_TABLE_WIDTH_EXT		= 0x80D9,
	GL_COLOR_TABLE_RED_SIZE_EXT		= 0x80DA,
	GL_COLOR_TABLE_GREEN_SIZE_EXT		= 0x80DB,
	GL_COLOR_TABLE_BLUE_SIZE_EXT		= 0x80DC,
	GL_COLOR_TABLE_ALPHA_SIZE_EXT	 	= 0x80DD,
	GL_COLOR_TABLE_LUMINANCE_SIZE_EXT	= 0x80DE,
	GL_COLOR_TABLE_INTENSITY_SIZE_EXT	= 0x80DF,
	GL_TEXTURE_INDEX_SIZE_EXT		= 0x80ED,
	GL_COLOR_INDEX1_EXT			= 0x80E2,
	GL_COLOR_INDEX2_EXT			= 0x80E3,
	GL_COLOR_INDEX4_EXT			= 0x80E4,
	GL_COLOR_INDEX8_EXT			= 0x80E5,
	GL_COLOR_INDEX12_EXT			= 0x80E6,
	GL_COLOR_INDEX16_EXT			= 0x80E7,

	/* GL_EXT_shared_texture_palette */
	GL_SHARED_TEXTURE_PALETTE_EXT		= 0x81FB,

	/* GL_EXT_point_parameters */
	GL_POINT_SIZE_MIN_EXT			= 0x8126,
	GL_POINT_SIZE_MAX_EXT			= 0x8127,
	GL_POINT_FADE_THRESHOLD_SIZE_EXT	= 0x8128,
	GL_DISTANCE_ATTENUATION_EXT		= 0x8129,

	/* GL_EXT_rescale_normal */
	GL_RESCALE_NORMAL_EXT			= 0x803A,

	/* GL_EXT_abgr */
	GL_ABGR_EXT				= 0x8000,

	/* GL_SGIS_multitexture */
	GL_SELECTED_TEXTURE_SGIS		= 0x835C,
	GL_SELECTED_TEXTURE_COORD_SET_SGIS	= 0x835D,
	GL_MAX_TEXTURES_SGIS			= 0x835E,
	GL_TEXTURE0_SGIS			= 0x835F,
	GL_TEXTURE1_SGIS			= 0x8360,
	GL_TEXTURE2_SGIS			= 0x8361,
	GL_TEXTURE3_SGIS			= 0x8362,
	GL_TEXTURE_COORD_SET_SOURCE_SGIS	= 0x8363,

	/* GL_EXT_multitexture */
	GL_SELECTED_TEXTURE_EXT			= 0x83C0,
	GL_SELECTED_TEXTURE_COORD_SET_EXT	= 0x83C1,
	GL_SELECTED_TEXTURE_TRANSFORM_EXT	= 0x83C2,
	GL_MAX_TEXTURES_EXT			= 0x83C3,
	GL_MAX_TEXTURE_COORD_SETS_EXT		= 0x83C4,
	GL_TEXTURE_ENV_COORD_SET_EXT		= 0x83C5,
	GL_TEXTURE0_EXT				= 0x83C6,
	GL_TEXTURE1_EXT				= 0x83C7,
	GL_TEXTURE2_EXT				= 0x83C8,
	GL_TEXTURE3_EXT				= 0x83C9,

	/* GL_SGIS_texture_edge_clamp */
	GL_CLAMP_TO_EDGE_SGIS			= 0x812F,

	/* OpenGL 1.2 */
	GL_RESCALE_NORMAL			= 0x803A,
	GL_CLAMP_TO_EDGE			= 0x812F,
	GL_MAX_ELEMENTS_VERTICES		= 0xF0E8,
	GL_MAX_ELEMENTS_INDICES			= 0xF0E9,
	GL_BGR					= 0x80E0,
	GL_BGRA					= 0x80E1,
	GL_UNSIGNED_BYTE_3_3_2			= 0x8032,
	GL_UNSIGNED_BYTE_2_3_3_REV		= 0x8362,
	GL_UNSIGNED_SHORT_5_6_5			= 0x8363,
	GL_UNSIGNED_SHORT_5_6_5_REV		= 0x8364,
	GL_UNSIGNED_SHORT_4_4_4_4		= 0x8033,
	GL_UNSIGNED_SHORT_4_4_4_4_REV		= 0x8365,
	GL_UNSIGNED_SHORT_5_5_5_1		= 0x8034,
	GL_UNSIGNED_SHORT_1_5_5_5_REV		= 0x8366,
	GL_UNSIGNED_INT_8_8_8_8			= 0x8035,
	GL_UNSIGNED_INT_8_8_8_8_REV		= 0x8367,
	GL_UNSIGNED_INT_10_10_10_2		= 0x8036,
	GL_UNSIGNED_INT_2_10_10_10_REV		= 0x8368,
	GL_LIGHT_MODEL_COLOR_CONTROL		= 0x81F8,
	GL_SINGLE_COLOR				= 0x81F9,
	GL_SEPARATE_SPECULAR_COLOR		= 0x81FA,
	GL_TEXTURE_MIN_LOD			= 0x813A,
	GL_TEXTURE_MAX_LOD			= 0x813B,
	GL_TEXTURE_BASE_LEVEL			= 0x813C,
	GL_TEXTURE_MAX_LEVEL			= 0x813D
}
#ifdef CENTERLINE_CLPP
  /* CenterLine C++ workaround: */
  gl_enum;
  typedef int GLenum;
#else
  /* all other compilers */
  GLenum;
#endif


/* GL_NO_ERROR must be zero */
#define GL_NO_ERROR 0



enum {
	GL_CURRENT_BIT		= 0x00000001,
	GL_POINT_BIT		= 0x00000002,
	GL_LINE_BIT		= 0x00000004,
	GL_POLYGON_BIT		= 0x00000008,
	GL_POLYGON_STIPPLE_BIT	= 0x00000010,
	GL_PIXEL_MODE_BIT	= 0x00000020,
	GL_LIGHTING_BIT		= 0x00000040,
	GL_FOG_BIT		= 0x00000080,
	GL_DEPTH_BUFFER_BIT	= 0x00000100,
	GL_ACCUM_BUFFER_BIT	= 0x00000200,
	GL_STENCIL_BUFFER_BIT	= 0x00000400,
	GL_VIEWPORT_BIT		= 0x00000800,
	GL_TRANSFORM_BIT	= 0x00001000,
	GL_ENABLE_BIT		= 0x00002000,
	GL_COLOR_BUFFER_BIT	= 0x00004000,
	GL_HINT_BIT		= 0x00008000,
	GL_EVAL_BIT		= 0x00010000,
	GL_LIST_BIT		= 0x00020000,
	GL_TEXTURE_BIT		= 0x00040000,
	GL_SCISSOR_BIT		= 0x00080000,
	GL_ALL_ATTRIB_BITS	= 0x000fffff
};


enum {
	GL_CLIENT_PIXEL_STORE_BIT	= 0x00000001,
	GL_CLIENT_VERTEX_ARRAY_BIT	= 0x00000002,
	GL_CLIENT_ALL_ATTRIB_BITS	= 0x0000FFFF
};



typedef unsigned int GLbitfield;


#ifdef CENTERLINE_CLPP
#define signed
#endif


/*
 *
 * Data types (may be architecture dependent in some cases)
 *
 */

/*  C type		GL type		storage                            */
/*-------------------------------------------------------------------------*/
typedef void		GLvoid;
typedef unsigned char	GLboolean;
typedef signed char	GLbyte;		/* 1-byte signed */
typedef short		GLshort;	/* 2-byte signed */
typedef int		GLint;		/* 4-byte signed */
typedef unsigned char	GLubyte;	/* 1-byte unsigned */
typedef unsigned short	GLushort;	/* 2-byte unsigned */
typedef unsigned int	GLuint;		/* 4-byte unsigned */
typedef int		GLsizei;	/* 4-byte signed */
typedef float		GLfloat;	/* single precision float */
typedef float		GLclampf;	/* single precision float in [0,1] */
typedef double		GLdouble;	/* double precision float */
typedef double		GLclampd;	/* double precision float in [0,1] */



#if defined(__BEOS__) || defined(__QUICKDRAW__)
#pragma export on
#endif


/*
 * Miscellaneous
 */

extern __asm __saveds void APIENTRY glClearIndex( register __fp0 GLfloat c );

extern __asm __saveds void APIENTRY glClearColor( register __fp0 GLclampf red,
                                                  register __fp1 GLclampf green,
                                                  register __fp2 GLclampf blue,
                                                  register __fp3 GLclampf alpha );

extern __asm __saveds void APIENTRY glClear( register __d0 GLbitfield mask );

extern __asm __saveds void APIENTRY glIndexMask( register __d0 GLuint mask );

extern __asm __saveds void APIENTRY glColorMask( register __d0 GLboolean red, register __d1 GLboolean green,
                                                 register __d2 GLboolean blue, register __d3 GLboolean alpha );

extern __asm __saveds void APIENTRY glAlphaFunc( register __d0 GLenum func, register __fp0 GLclampf ref );

extern __asm __saveds void APIENTRY glBlendFunc( register __d0 GLenum sfactor, register __d1 GLenum dfactor );

extern __asm __saveds void APIENTRY glLogicOp( register __d0 GLenum opcode );

extern __asm __saveds void APIENTRY glCullFace( register __d0 GLenum mode );

extern __asm __saveds void APIENTRY glFrontFace( register __d0 GLenum mode );

extern __asm __saveds void APIENTRY glPointSize( register __fp0 GLfloat size );

extern __asm __saveds void APIENTRY glLineWidth( register __fp0 GLfloat width );

extern __asm __saveds void APIENTRY glLineStipple( register __d0 GLint factor, register __d1 GLushort pattern );

extern __asm __saveds void APIENTRY glPolygonMode( register __d0 GLenum face, register __d1 GLenum mode );

extern __asm __saveds void APIENTRY glPolygonOffset( register __fp0 GLfloat factor, register __fp1 GLfloat units );

extern __asm __saveds void APIENTRY glPolygonStipple( register __a0 const GLubyte *mask );

extern __asm __saveds void APIENTRY glGetPolygonStipple( register __a0 GLubyte *mask );

extern __asm __saveds void APIENTRY glEdgeFlag( register __d0 GLboolean flag );

extern __asm __saveds void APIENTRY glEdgeFlagv( register __a0 const GLboolean *flag );

extern __asm __saveds void APIENTRY glScissor( register __d0 GLint x, register __d1 GLint y,
                                               register __d2 GLsizei width, register __d3 GLsizei height );

extern __asm __saveds void APIENTRY glClipPlane( register __d0 GLenum plane, register __a0 const GLdouble *equation );

extern __asm __saveds void APIENTRY glGetClipPlane( register __d0 GLenum plane, register __a0 GLdouble *equation );

extern __asm __saveds void APIENTRY glDrawBuffer( register __d0 GLenum mode );

extern __asm __saveds void APIENTRY glReadBuffer( register __d0 GLenum mode );

extern __asm __saveds void APIENTRY glEnable( register __d0 GLenum cap );

extern __asm __saveds void APIENTRY glDisable( register __d0 GLenum cap );

extern __asm __saveds GLboolean APIENTRY glIsEnabled( register __d0 GLenum cap );


extern __asm __saveds void APIENTRY glEnableClientState( register __d0 GLenum cap );

extern __asm __saveds void APIENTRY glDisableClientState( register __d0 GLenum cap );


extern __asm __saveds void APIENTRY glGetBooleanv( register __d0 GLenum pname, register __a0 GLboolean *params );

extern __asm __saveds void APIENTRY glGetDoublev( register __d0 GLenum pname, register __a0 GLdouble *params );

extern __asm __saveds void APIENTRY glGetFloatv( register __d0 GLenum pname, register __a0 GLfloat *params );

extern __asm __saveds void APIENTRY glGetIntegerv( register __d0 GLenum pname, register __a0 GLint *params );


extern __asm __saveds void APIENTRY glPushAttrib( register __d0 GLbitfield mask );

extern __asm __saveds void APIENTRY glPopAttrib( void );


extern __asm __saveds void APIENTRY glPushClientAttrib( register __d0 GLbitfield mask );  /* 1.1 */

extern __asm __saveds void APIENTRY glPopClientAttrib( void );  /* 1.1 */


extern __asm __saveds GLint APIENTRY glRenderMode( register __d0 GLenum mode );

extern __asm __saveds GLenum APIENTRY glGetError( void );

extern __asm __saveds const GLubyte* APIENTRY glGetString( register __d0 GLenum name );

extern __asm __saveds void APIENTRY glFinish( void );

extern __asm __saveds void APIENTRY glFlush( void );

extern __asm __saveds void APIENTRY glHint( register __d0 GLenum target, register __d1 GLenum mode );



/*
 * Depth Buffer
 */

extern __asm __saveds void APIENTRY glClearDepth( register __fp0 GLclampd depth );

extern __asm __saveds void APIENTRY glDepthFunc( register __d0 GLenum func );

extern __asm __saveds void APIENTRY glDepthMask( register __d0 GLboolean flag );

extern __asm __saveds void APIENTRY glDepthRange( register __fp0 GLclampd near_val, register __fp1 GLclampd far_val );


/*
 * Accumulation Buffer
 */

extern __asm __saveds void APIENTRY glClearAccum( register __fp0 GLfloat red, register __fp1 GLfloat green,
                                                  register __fp2 GLfloat blue, register __fp3 GLfloat alpha );

extern __asm __saveds void APIENTRY glAccum( register __d0 GLenum op, register __fp0 GLfloat value );



/*
 * Transformation
 */

extern __asm __saveds void APIENTRY glMatrixMode( register __d0 GLenum mode );

extern __asm __saveds void APIENTRY glOrtho( register __fp0 GLdouble left, register __fp1 GLdouble right,
                                             register __fp2 GLdouble bottom, register __fp3 GLdouble top,
                                             register __fp4 GLdouble near_val, register __fp5 GLdouble far_val );

extern __asm __saveds void APIENTRY glFrustum( register __fp0 GLdouble left, register __fp1 GLdouble right,
                                               register __fp2 GLdouble bottom, register __fp3 GLdouble top,
                                               register __fp4 GLdouble near_val, register __fp5 GLdouble far_val );

extern __asm __saveds void APIENTRY glViewport( register __d0 GLint x, register __d1 GLint y,
                                                register __d2 GLsizei width, register __d3 GLsizei height );

extern __asm __saveds void APIENTRY glPushMatrix( void );

extern __asm __saveds void APIENTRY glPopMatrix( void );

extern __asm __saveds void APIENTRY glLoadIdentity( void );

extern __asm __saveds void APIENTRY glLoadMatrixd( register __a0 const GLdouble *m );
extern __asm __saveds void APIENTRY glLoadMatrixf( register __a0 const GLfloat *m );

extern __asm __saveds void APIENTRY glMultMatrixd( register __a0 const GLdouble *m );
extern __asm __saveds void APIENTRY glMultMatrixf( register __a0 const GLfloat *m );

extern __asm __saveds void APIENTRY glRotated( register __fp0 GLdouble angle,
                                               register __fp1 GLdouble x, register __fp2 GLdouble y, register __fp3 GLdouble z );
extern __asm __saveds void APIENTRY glRotatef( register __fp0 GLfloat angle,
                                               register __fp1 GLfloat x, register __fp2 GLfloat y, register __fp3 GLfloat z );

extern __asm __saveds void APIENTRY glScaled( register __fp0 GLdouble x, register __fp1 GLdouble y, register __fp2 GLdouble z );
extern __asm __saveds void APIENTRY glScalef( register __fp0 GLfloat x, register __fp1 GLfloat y, register __fp2 GLfloat z );

extern __asm __saveds void APIENTRY glTranslated( register __fp0 GLdouble x, register __fp1 GLdouble y, register __fp2 GLdouble z );
extern __asm __saveds void APIENTRY glTranslatef( register __fp0 GLfloat x, register __fp1 GLfloat y, register __fp2 GLfloat z );



/*
 * Display Lists
 */

extern __asm __saveds GLboolean APIENTRY glIsList( register __d0 GLuint list );

extern __asm __saveds void APIENTRY glDeleteLists( register __d0 GLuint list, register __d1 GLsizei range );

extern __asm __saveds GLuint APIENTRY glGenLists( register __d0 GLsizei range );

extern __asm __saveds void APIENTRY glNewList( register __d0 GLuint list, register __d1 GLenum mode );

extern __asm __saveds void APIENTRY glEndList( void );

extern __asm __saveds void APIENTRY glCallList( register __d0 GLuint list );

extern __asm __saveds void APIENTRY glCallLists( register __d0 GLsizei n, register __d1 GLenum type,
                                                 register __a0 const GLvoid *lists );

extern __asm __saveds void APIENTRY glListBase( register __d0 GLuint base );



/*
 * Drawing Functions
 */

extern __asm __saveds void APIENTRY glBegin( register __d0 GLenum mode );

extern __asm __saveds void APIENTRY glEnd( void );


extern __asm __saveds void APIENTRY glVertex2d( register __fp0 GLdouble x, register __fp1 GLdouble y );
extern __asm __saveds void APIENTRY glVertex2f( register __fp0 GLfloat x, register __fp1 GLfloat y );
extern __asm __saveds void APIENTRY glVertex2i( register __d0 GLint x, register __d1 GLint y );
extern __asm __saveds void APIENTRY glVertex2s( register __d0 GLshort x, register __d1 GLshort y );

extern __asm __saveds void APIENTRY glVertex3d( register __fp0 GLdouble x, register __fp1 GLdouble y, register __fp2 GLdouble z );
extern __asm __saveds void APIENTRY glVertex3f( register __fp0 GLfloat x, register __fp1 GLfloat y, register __fp2 GLfloat z );
extern __asm __saveds void APIENTRY glVertex3i( register __d0 GLint x, register __d1 GLint y, register __d2 GLint z );
extern __asm __saveds void APIENTRY glVertex3s( register __d0 GLshort x, register __d1 GLshort y, register __d2 GLshort z );

extern __asm __saveds void APIENTRY glVertex4d( register __fp0 GLdouble x, register __fp1 GLdouble y, register __fp2 GLdouble z, register __fp3 GLdouble w );
extern __asm __saveds void APIENTRY glVertex4f( register __fp0 GLfloat x, register __fp1 GLfloat y, register __fp2 GLfloat z, register __fp3 GLfloat w );
extern __asm __saveds void APIENTRY glVertex4i( register __d0 GLint x, register __d1 GLint y, register __d2 GLint z, register __d3 GLint w );
extern __asm __saveds void APIENTRY glVertex4s( register __d0 GLshort x, register __d1 GLshort y, register __d2 GLshort z, register __d3 GLshort w );

extern __asm __saveds void APIENTRY glVertex2dv( register __a0 const GLdouble *v );
extern __asm __saveds void APIENTRY glVertex2fv( register __a0 const GLfloat *v );
extern __asm __saveds void APIENTRY glVertex2iv( register __a0 const GLint *v );
extern __asm __saveds void APIENTRY glVertex2sv( register __a0 const GLshort *v );

extern __asm __saveds void APIENTRY glVertex3dv( register __a0 const GLdouble *v );
extern __asm __saveds void APIENTRY glVertex3fv( register __a0 const GLfloat *v );
extern __asm __saveds void APIENTRY glVertex3iv( register __a0 const GLint *v );
extern __asm __saveds void APIENTRY glVertex3sv( register __a0 const GLshort *v );

extern __asm __saveds void APIENTRY glVertex4dv( register __a0 const GLdouble *v );
extern __asm __saveds void APIENTRY glVertex4fv( register __a0 const GLfloat *v );
extern __asm __saveds void APIENTRY glVertex4iv( register __a0 const GLint *v );
extern __asm __saveds void APIENTRY glVertex4sv( register __a0 const GLshort *v );


extern __asm __saveds void APIENTRY glNormal3b( register __d0 GLbyte nx, register __d1 GLbyte ny, register __d2 GLbyte nz );
extern __asm __saveds void APIENTRY glNormal3d( register __fp0 GLdouble nx, register __fp1 GLdouble ny, register __fp2 GLdouble nz );
extern __asm __saveds void APIENTRY glNormal3f( register __fp0 GLfloat nx, register __fp1 GLfloat ny, register __fp2 GLfloat nz );
extern __asm __saveds void APIENTRY glNormal3i( register __d0 GLint nx, register __d1 GLint ny, register __d2 GLint nz );
extern __asm __saveds void APIENTRY glNormal3s( register __d0 GLshort nx, register __d1 GLshort ny, register __d2 GLshort nz );

extern __asm __saveds void APIENTRY glNormal3bv( register __a0 const GLbyte *v );
extern __asm __saveds void APIENTRY glNormal3dv( register __a0 const GLdouble *v );
extern __asm __saveds void APIENTRY glNormal3fv( register __a0 const GLfloat *v );
extern __asm __saveds void APIENTRY glNormal3iv( register __a0 const GLint *v );
extern __asm __saveds void APIENTRY glNormal3sv( register __a0 const GLshort *v );


extern __asm __saveds void APIENTRY glIndexd( register __fp0 GLdouble c );
extern __asm __saveds void APIENTRY glIndexf( register __fp0 GLfloat c );
extern __asm __saveds void APIENTRY glIndexi( register __d0 GLint c );
extern __asm __saveds void APIENTRY glIndexs( register __d0 GLshort c );
extern __asm __saveds void APIENTRY glIndexub( register __d0 GLubyte c );

extern __asm __saveds void APIENTRY glIndexdv( register __a0 const GLdouble *c );
extern __asm __saveds void APIENTRY glIndexfv( register __a0 const GLfloat *c );
extern __asm __saveds void APIENTRY glIndexiv( register __a0 const GLint *c );
extern __asm __saveds void APIENTRY glIndexsv( register __a0 const GLshort *c );
extern __asm __saveds void APIENTRY glIndexubv( register __a0 const GLubyte *c );

extern __asm __saveds void APIENTRY glColor3b( register __d0 GLbyte red, register __d1 GLbyte green, register __d2 GLbyte blue );
extern __asm __saveds void APIENTRY glColor3d( register __fp0 GLdouble red, register __fp1 GLdouble green, register __fp2 GLdouble blue );
extern __asm __saveds void APIENTRY glColor3f( register __fp0 GLfloat red, register __fp1 GLfloat green, register __fp2 GLfloat blue );
extern __asm __saveds void APIENTRY glColor3i( register __d0 GLint red, register __d1 GLint green, register __d2 GLint blue );
extern __asm __saveds void APIENTRY glColor3s( register __d0 GLshort red, register __d1 GLshort green, register __d2 GLshort blue );
extern __asm __saveds void APIENTRY glColor3ub( register __d0 GLubyte red, register __d1 GLubyte green, register __d2 GLubyte blue );
extern __asm __saveds void APIENTRY glColor3ui( register __d0 GLuint red, register __d1 GLuint green, register __d2 GLuint blue );
extern __asm __saveds void APIENTRY glColor3us( register __d0 GLushort red, register __d1 GLushort green, register __d2 GLushort blue );

extern __asm __saveds void APIENTRY glColor4b( register __d0 GLbyte red, register __d1 GLbyte green,
                                               register __d2 GLbyte blue, register __d3 GLbyte alpha );
extern __asm __saveds void APIENTRY glColor4d( register __fp0 GLdouble red, register __fp1 GLdouble green,
                                               register __fp2 GLdouble blue, register __fp3 GLdouble alpha );
extern __asm __saveds void APIENTRY glColor4f( register __fp0 GLfloat red, register __fp1 GLfloat green,
                                               register __fp2 GLfloat blue, register __fp3 GLfloat alpha );
extern __asm __saveds void APIENTRY glColor4i( register __d0 GLint red, register __d1 GLint green,
                                               register __d2 GLint blue, register __d3 GLint alpha );
extern __asm __saveds void APIENTRY glColor4s( register __d0 GLshort red, register __d1 GLshort green,
                                               register __d2 GLshort blue, register __d3 GLshort alpha );
extern __asm __saveds void APIENTRY glColor4ub( register __d0 GLubyte red, register __d1 GLubyte green,
                                                register __d2 GLubyte blue, register __d3 GLubyte alpha );
extern __asm __saveds void APIENTRY glColor4ui( register __d0 GLuint red, register __d1 GLuint green,
                                                register __d2 GLuint blue, register __d3 GLuint alpha );
extern __asm __saveds void APIENTRY glColor4us( register __d0 GLushort red, register __d1 GLushort green,
                                                register __d2 GLushort blue, register __d3 GLushort alpha );


extern __asm __saveds void APIENTRY glColor3bv( register __a0 const GLbyte *v );
extern __asm __saveds void APIENTRY glColor3dv( register __a0 const GLdouble *v );
extern __asm __saveds void APIENTRY glColor3fv( register __a0 const GLfloat *v );
extern __asm __saveds void APIENTRY glColor3iv( register __a0 const GLint *v );
extern __asm __saveds void APIENTRY glColor3sv( register __a0 const GLshort *v );
extern __asm __saveds void APIENTRY glColor3ubv( register __a0 const GLubyte *v );
extern __asm __saveds void APIENTRY glColor3uiv( register __a0 const GLuint *v );
extern __asm __saveds void APIENTRY glColor3usv( register __a0 const GLushort *v );

extern __asm __saveds void APIENTRY glColor4bv( register __a0 const GLbyte *v );
extern __asm __saveds void APIENTRY glColor4dv( register __a0 const GLdouble *v );
extern __asm __saveds void APIENTRY glColor4fv( register __a0 const GLfloat *v );
extern __asm __saveds void APIENTRY glColor4iv( register __a0 const GLint *v );
extern __asm __saveds void APIENTRY glColor4sv( register __a0 const GLshort *v );
extern __asm __saveds void APIENTRY glColor4ubv( register __a0 const GLubyte *v );
extern __asm __saveds void APIENTRY glColor4uiv( register __a0 const GLuint *v );
extern __asm __saveds void APIENTRY glColor4usv( register __a0 const GLushort *v );


extern __asm __saveds void APIENTRY glTexCoord1d( register __fp0 GLdouble s );
extern __asm __saveds void APIENTRY glTexCoord1f( register __fp0 GLfloat s );
extern __asm __saveds void APIENTRY glTexCoord1i( register __d0 GLint s );
extern __asm __saveds void APIENTRY glTexCoord1s( register __d0 GLshort s );

extern __asm __saveds void APIENTRY glTexCoord2d( register __fp0 GLdouble s, register __fp1 GLdouble t );
extern __asm __saveds void APIENTRY glTexCoord2f( register __fp0 GLfloat s, register __fp1 GLfloat t );
extern __asm __saveds void APIENTRY glTexCoord2i( register __d0 GLint s, register __d1 GLint t );
extern __asm __saveds void APIENTRY glTexCoord2s( register __d0 GLshort s, register __d1 GLshort t );

extern __asm __saveds void APIENTRY glTexCoord3d( register __fp0 GLdouble s, register __fp1 GLdouble t, register __fp2 GLdouble r );
extern __asm __saveds void APIENTRY glTexCoord3f( register __fp0 GLfloat s, register __fp1 GLfloat t, register __fp2 GLfloat r );
extern __asm __saveds void APIENTRY glTexCoord3i( register __d0 GLint s, register __d1 GLint t, register __d2 GLint r );
extern __asm __saveds void APIENTRY glTexCoord3s( register __d0 GLshort s, register __d1 GLshort t, register __d2 GLshort r );

extern __asm __saveds void APIENTRY glTexCoord4d( register __fp0 GLdouble s, register __fp1 GLdouble t, register __fp2 GLdouble r, register __fp3 GLdouble q );
extern __asm __saveds void APIENTRY glTexCoord4f( register __fp0 GLfloat s, register __fp1 GLfloat t, register __fp2 GLfloat r, register __fp3 GLfloat q );
extern __asm __saveds void APIENTRY glTexCoord4i( register __d0 GLint s, register __d1 GLint t, register __d2 GLint r, register __d3 GLint q );
extern __asm __saveds void APIENTRY glTexCoord4s( register __d0 GLshort s, register __d1 GLshort t, register __d2 GLshort r, register __d3 GLshort q );

extern __asm __saveds void APIENTRY glTexCoord1dv( register __a0 const GLdouble *v );
extern __asm __saveds void APIENTRY glTexCoord1fv( register __a0 const GLfloat *v );
extern __asm __saveds void APIENTRY glTexCoord1iv( register __a0 const GLint *v );
extern __asm __saveds void APIENTRY glTexCoord1sv( register __a0 const GLshort *v );

extern __asm __saveds void APIENTRY glTexCoord2dv( register __a0 const GLdouble *v );
extern __asm __saveds void APIENTRY glTexCoord2fv( register __a0 const GLfloat *v );
extern __asm __saveds void APIENTRY glTexCoord2iv( register __a0 const GLint *v );
extern __asm __saveds void APIENTRY glTexCoord2sv( register __a0 const GLshort *v );

extern __asm __saveds void APIENTRY glTexCoord3dv( register __a0 const GLdouble *v );
extern __asm __saveds void APIENTRY glTexCoord3fv( register __a0 const GLfloat *v );
extern __asm __saveds void APIENTRY glTexCoord3iv( register __a0 const GLint *v );
extern __asm __saveds void APIENTRY glTexCoord3sv( register __a0 const GLshort *v );

extern __asm __saveds void APIENTRY glTexCoord4dv( register __a0 const GLdouble *v );
extern __asm __saveds void APIENTRY glTexCoord4fv( register __a0 const GLfloat *v );
extern __asm __saveds void APIENTRY glTexCoord4iv( register __a0 const GLint *v );
extern __asm __saveds void APIENTRY glTexCoord4sv( register __a0 const GLshort *v );


extern __asm __saveds void APIENTRY glRasterPos2d( register __fp0 GLdouble x, register __fp1 GLdouble y );
extern __asm __saveds void APIENTRY glRasterPos2f( register __fp0 GLfloat x, register __fp1 GLfloat y );
extern __asm __saveds void APIENTRY glRasterPos2i( register __d0 GLint x, register __d1 GLint y );
extern __asm __saveds void APIENTRY glRasterPos2s( register __d0 GLshort x, register __d1 GLshort y );

extern __asm __saveds void APIENTRY glRasterPos3d( register __fp0 GLdouble x, register __fp1 GLdouble y, register __fp2 GLdouble z );
extern __asm __saveds void APIENTRY glRasterPos3f( register __fp0 GLfloat x, register __fp1 GLfloat y, register __fp2 GLfloat z );
extern __asm __saveds void APIENTRY glRasterPos3i( register __d0 GLint x, register __d1 GLint y, register __d2 GLint z );
extern __asm __saveds void APIENTRY glRasterPos3s( register __d0 GLshort x, register __d1 GLshort y, register __d2 GLshort z );

extern __asm __saveds void APIENTRY glRasterPos4d( register __fp0 GLdouble x, register __fp1 GLdouble y, register __fp2 GLdouble z, register __fp3 GLdouble w );
extern __asm __saveds void APIENTRY glRasterPos4f( register __fp0 GLfloat x, register __fp1 GLfloat y, register __fp2 GLfloat z, register __fp3 GLfloat w );
extern __asm __saveds void APIENTRY glRasterPos4i( register __d0 GLint x, register __d1 GLint y, register __d2 GLint z, register __d3 GLint w );
extern __asm __saveds void APIENTRY glRasterPos4s( register __d0 GLshort x, register __d1 GLshort y, register __d2 GLshort z, register __d3 GLshort w );

extern __asm __saveds void APIENTRY glRasterPos2dv( register __a0 const GLdouble *v );
extern __asm __saveds void APIENTRY glRasterPos2fv( register __a0 const GLfloat *v );
extern __asm __saveds void APIENTRY glRasterPos2iv( register __a0 const GLint *v );
extern __asm __saveds void APIENTRY glRasterPos2sv( register __a0 const GLshort *v );

extern __asm __saveds void APIENTRY glRasterPos3dv( register __a0 const GLdouble *v );
extern __asm __saveds void APIENTRY glRasterPos3fv( register __a0 const GLfloat *v );
extern __asm __saveds void APIENTRY glRasterPos3iv( register __a0 const GLint *v );
extern __asm __saveds void APIENTRY glRasterPos3sv( register __a0 const GLshort *v );

extern __asm __saveds void APIENTRY glRasterPos4dv( register __a0 const GLdouble *v );
extern __asm __saveds void APIENTRY glRasterPos4fv( register __a0 const GLfloat *v );
extern __asm __saveds void APIENTRY glRasterPos4iv( register __a0 const GLint *v );
extern __asm __saveds void APIENTRY glRasterPos4sv( register __a0 const GLshort *v );


extern __asm __saveds void APIENTRY glRectd( register __fp0 GLdouble x1, register __fp1 GLdouble y1, register __fp2 GLdouble x2, register __fp3 GLdouble y2 );
extern __asm __saveds void APIENTRY glRectf( register __fp0 GLfloat x1, register __fp1 GLfloat y1, register __fp2 GLfloat x2, register __fp3 GLfloat y2 );
extern __asm __saveds void APIENTRY glRecti( register __d0 GLint x1, register __d1 GLint y1, register __d2 GLint x2, register __d3 GLint y2 );
extern __asm __saveds void APIENTRY glRects( register __d0 GLshort x1, register __d1 GLshort y1, register __d2 GLshort x2, register __d3 GLshort y2 );


extern __asm __saveds void APIENTRY glRectdv( register __a0 const GLdouble *v1, register __a1 const GLdouble *v2 );
extern __asm __saveds void APIENTRY glRectfv( register __a0 const GLfloat *v1, register __a1 const GLfloat *v2 );
extern __asm __saveds void APIENTRY glRectiv( register __a0 const GLint *v1, register __a1 const GLint *v2 );
extern __asm __saveds void APIENTRY glRectsv( register __a0 const GLshort *v1, register __a1 const GLshort *v2 );



/*
 * Vertex Arrays  (1.1)
 */

extern __asm __saveds void APIENTRY glVertexPointer( register __d0 GLint size, register __d1 GLenum type,
                                                     register __d2 GLsizei stride, register __a0 const GLvoid *ptr );

extern __asm __saveds void APIENTRY glNormalPointer( register __d0 GLenum type, register __d1 GLsizei stride,
                                                     register __a0 const GLvoid *ptr );

extern __asm __saveds void APIENTRY glColorPointer( register __d0 GLint size, register __d1 GLenum type,
                                                    register __d2 GLsizei stride, register __a0 const GLvoid *ptr );

extern __asm __saveds void APIENTRY glIndexPointer( register __d0 GLenum type, register __d1 GLsizei stride,
                                                    register __a0 const GLvoid *ptr );

extern __asm __saveds void APIENTRY glTexCoordPointer( register __d0 GLint size, register __d1 GLenum type, register __d2 GLsizei stride,
                                                       register __a0 const GLvoid *ptr );

extern __asm __saveds void APIENTRY glEdgeFlagPointer( register __d0 GLsizei stride,
                                                       register __a0 const GLboolean *ptr );

extern __asm __saveds void APIENTRY glGetPointerv( register __d0 GLenum pname, register __a0 void **params );

extern __asm __saveds void APIENTRY glArrayElement( register __d0 GLint i );

extern __asm __saveds void APIENTRY glDrawArrays( register __d0 GLenum mode, register __d1 GLint first,
                                                  register __d2 GLsizei count );

extern __asm __saveds void APIENTRY glDrawElements( register __d0 GLenum mode, register __d1 GLsizei count,
                                                    register __d2 GLenum type, register __a0 const GLvoid *indices );

extern __asm __saveds void APIENTRY glInterleavedArrays( register __d0 GLenum format, register __d1 GLsizei stride,
                                                         register __a0 const GLvoid *pointer );


/*
 * Lighting
 */

extern __asm __saveds void APIENTRY glShadeModel( register __d0 GLenum mode );

extern __asm __saveds void APIENTRY glLightf( register __d0 GLenum light, register __d1 GLenum pname, register __fp0 GLfloat param );
extern __asm __saveds void APIENTRY glLighti( register __d0 GLenum light, register __d1 GLenum pname, register __d2 GLint param );
extern __asm __saveds void APIENTRY glLightfv( register __d0 GLenum light, register __d1 GLenum pname,
                                               register __a0 const GLfloat *params );
extern __asm __saveds void APIENTRY glLightiv( register __d0 GLenum light, register __d1 GLenum pname,
                                               register __a0 const GLint *params );

extern __asm __saveds void APIENTRY glGetLightfv( register __d0 GLenum light, register __d1 GLenum pname,
                                                  register __a0 GLfloat *params );
extern __asm __saveds void APIENTRY glGetLightiv( register __d0 GLenum light, register __d1 GLenum pname,
                                                  register __a0 GLint *params );

extern __asm __saveds void APIENTRY glLightModelf( register __d0 GLenum pname, register __fp0 GLfloat param );
extern __asm __saveds void APIENTRY glLightModeli( register __d0 GLenum pname, register __d1 GLint param );
extern __asm __saveds void APIENTRY glLightModelfv( register __d0 GLenum pname, register __a0 const GLfloat *params );
extern __asm __saveds void APIENTRY glLightModeliv( register __d0 GLenum pname, register __a0 const GLint *params );

extern __asm __saveds void APIENTRY glMaterialf( register __d0 GLenum face, register __d1 GLenum pname, register __fp0 GLfloat param );
extern __asm __saveds void APIENTRY glMateriali( register __d0 GLenum face, register __d1 GLenum pname, register __d2 GLint param );
extern __asm __saveds void APIENTRY glMaterialfv( register __d0 GLenum face, register __d1 GLenum pname, register __a0 const GLfloat *params );
extern __asm __saveds void APIENTRY glMaterialiv( register __d0 GLenum face, register __d1 GLenum pname, register __a0 const GLint *params );

extern __asm __saveds void APIENTRY glGetMaterialfv( register __d0 GLenum face, register __d1 GLenum pname, register __a0 GLfloat *params );
extern __asm __saveds void APIENTRY glGetMaterialiv( register __d0 GLenum face, register __d1 GLenum pname, register __a0 GLint *params );

extern __asm __saveds void APIENTRY glColorMaterial( register __d0 GLenum face, register __d1 GLenum mode );




/*
 * Raster functions
 */

extern __asm __saveds void APIENTRY glPixelZoom( register __fp0 GLfloat xfactor, register __fp1 GLfloat yfactor );

extern __asm __saveds void APIENTRY glPixelStoref( register __d0 GLenum pname, register __fp0 GLfloat param );
extern __asm __saveds void APIENTRY glPixelStorei( register __d0 GLenum pname, register __d1 GLint param );

extern __asm __saveds void APIENTRY glPixelTransferf( register __d0 GLenum pname, register __fp0 GLfloat param );
extern __asm __saveds void APIENTRY glPixelTransferi( register __d0 GLenum pname, register __d1 GLint param );

extern __asm __saveds void APIENTRY glPixelMapfv( register __d0 GLenum map, register __d1 GLint mapsize,
                                                  register __a0 const GLfloat *values );
extern __asm __saveds void APIENTRY glPixelMapuiv( register __d0 GLenum map, register __d1 GLint mapsize,
                                                   register __a0 const GLuint *values );
extern __asm __saveds void APIENTRY glPixelMapusv( register __d0 GLenum map, register __d1 GLint mapsize,
                                                   register __a0 const GLushort *values );

extern __asm __saveds void APIENTRY glGetPixelMapfv( register __d0 GLenum map, register __a0 GLfloat *values );
extern __asm __saveds void APIENTRY glGetPixelMapuiv( register __d0 GLenum map, register __a0 GLuint *values );
extern __asm __saveds void APIENTRY glGetPixelMapusv( register __d0 GLenum map, register __a0 GLushort *values );

extern __asm __saveds void APIENTRY glBitmap( register __d0 GLsizei width, register __d1 GLsizei height,
                                              register __fp0 GLfloat xorig, register __fp1 GLfloat yorig,
                                              register __fp2 GLfloat xmove, register __fp3 GLfloat ymove,
                                              register __a0 const GLubyte *bitmap );

extern __asm __saveds void APIENTRY glReadPixels( register __d0 GLint x, register __d1 GLint y,
                                                  register __d2 GLsizei width, register __d3 GLsizei height,
                                                  register __d4 GLenum format, register __d5 GLenum type,
                                                  register __a0 GLvoid *pixels );

extern __asm __saveds void APIENTRY glDrawPixels( register __d0 GLsizei width, register __d1 GLsizei height,
                                                  register __d2 GLenum format, register __d3 GLenum type,
                                                  register __a0 const GLvoid *pixels );

extern __asm __saveds void APIENTRY glCopyPixels( register __d0 GLint x, register __d1 GLint y,
                                                  register __d2 GLsizei width, register __d3 GLsizei height,
                                                  register __d4 GLenum type );



/*
 * Stenciling
 */

extern __asm __saveds void APIENTRY glStencilFunc( register __d0 GLenum func, register __d1 GLint ref, register __d2 GLuint mask );

extern __asm __saveds void APIENTRY glStencilMask( register __d0 GLuint mask );

extern __asm __saveds void APIENTRY glStencilOp( register __d0 GLenum fail, register __d1 GLenum zfail, register __d2 GLenum zpass );

extern __asm __saveds void APIENTRY glClearStencil( register __d0 GLint s );



/*
 * Texture mapping
 */

extern __asm __saveds void APIENTRY glTexGend( register __d0 GLenum coord, register __d1 GLenum pname, register __fp0 GLdouble param );
extern __asm __saveds void APIENTRY glTexGenf( register __d0 GLenum coord, register __d1 GLenum pname, register __fp0 GLfloat param );
extern __asm __saveds void APIENTRY glTexGeni( register __d0 GLenum coord, register __d1 GLenum pname, register __d2 GLint param );

extern __asm __saveds void APIENTRY glTexGendv( register __d0 GLenum coord, register __d1 GLenum pname, register __a0 const GLdouble *params );
extern __asm __saveds void APIENTRY glTexGenfv( register __d0 GLenum coord, register __d1 GLenum pname, register __a0 const GLfloat *params );
extern __asm __saveds void APIENTRY glTexGeniv( register __d0 GLenum coord, register __d1 GLenum pname, register __a0 const GLint *params );

extern __asm __saveds void APIENTRY glGetTexGendv( register __d0 GLenum coord, register __d1 GLenum pname, register __a0 GLdouble *params );
extern __asm __saveds void APIENTRY glGetTexGenfv( register __d0 GLenum coord, register __d1 GLenum pname, register __a0 GLfloat *params );
extern __asm __saveds void APIENTRY glGetTexGeniv( register __d0 GLenum coord, register __d1 GLenum pname, register __a0 GLint *params );


extern __asm __saveds void APIENTRY glTexEnvf( register __d0 GLenum target, register __d1 GLenum pname, register __fp0 GLfloat param );
extern __asm __saveds void APIENTRY glTexEnvi( register __d0 GLenum target, register __d1 GLenum pname, register __d2 GLint param );

extern __asm __saveds void APIENTRY glTexEnvfv( register __d0 GLenum target, register __d1 GLenum pname, register __a0 const GLfloat *params );
extern __asm __saveds void APIENTRY glTexEnviv( register __d0 GLenum target, register __d1 GLenum pname, register __a0 const GLint *params );

extern __asm __saveds void APIENTRY glGetTexEnvfv( register __d0 GLenum target, register __d1 GLenum pname, register __a0 GLfloat *params );
extern __asm __saveds void APIENTRY glGetTexEnviv( register __d0 GLenum target, register __d1 GLenum pname, register __a0 GLint *params );


extern __asm __saveds void APIENTRY glTexParameterf( register __d0 GLenum target, register __d1 GLenum pname, register __fp0 GLfloat param );
extern __asm __saveds void APIENTRY glTexParameteri( register __d0 GLenum target, register __d1 GLenum pname, register __d2 GLint param );

extern __asm __saveds void APIENTRY glTexParameterfv( register __d0 GLenum target, register __d1 GLenum pname,
                                                      register __a0 const GLfloat *params );
extern __asm __saveds void APIENTRY glTexParameteriv( register __d0 GLenum target, register __d1 GLenum pname,
                                                      register __a0 const GLint *params );

extern __asm __saveds void APIENTRY glGetTexParameterfv( register __d0 GLenum target,
                                                         register __d1 GLenum pname, register __a0 GLfloat *params );
extern __asm __saveds void APIENTRY glGetTexParameteriv( register __d0 GLenum target,
                                                         register __d1 GLenum pname, register __a0 GLint *params );

extern __asm __saveds void APIENTRY glGetTexLevelParameterfv( register __d0 GLenum target, register __d1 GLint level,
                                                              register __d2 GLenum pname, register __a0 GLfloat *params );
extern __asm __saveds void APIENTRY glGetTexLevelParameteriv( register __d0 GLenum target, register __d1 GLint level,
                                                              register __d2 GLenum pname, register __a0 GLint *params );


extern __asm __saveds void APIENTRY glTexImage1D( register __d0 GLenum target, register __d1 GLint level,
                                                  register __d2 GLint internalFormat,
                                                  register __d3 GLsizei width, register __d4 GLint border,
                                                  register __d5 GLenum format, register __d6 GLenum type,
                                                  register __a0 const GLvoid *pixels );

extern __asm __saveds void APIENTRY glTexImage2D( register __d0 GLenum target, register __d1 GLint level,
                                                  register __d2 GLint internalFormat,
                                                  register __d3 GLsizei width, register __d4 GLsizei height,
                                                  register __d5 GLint border, register __d6 GLenum format, register __d7 GLenum type,
                                                  register __a0 const GLvoid *pixels );

extern __asm __saveds void APIENTRY glGetTexImage( register __d0 GLenum target, register __d1 GLint level,
                                                   register __d2 GLenum format, register __d3 GLenum type,
                                                   register __a0 GLvoid *pixels );



/* 1.1 functions */

extern __asm __saveds void APIENTRY glGenTextures( register __d0 GLsizei n, register __a0 GLuint *textures );

extern __asm __saveds void APIENTRY glDeleteTextures( register __d0 GLsizei n, register __a0 const GLuint *textures );

extern __asm __saveds void APIENTRY glBindTexture( register __d0 GLenum target, register __d1 GLuint texture );

extern __asm __saveds void APIENTRY glPrioritizeTextures( register __d0 GLsizei n,
                                                          register __a0 const GLuint *textures,
                                                          register __a1 const GLclampf *priorities );

extern __asm __saveds GLboolean APIENTRY glAreTexturesResident( register __d0 GLsizei n,
                                                                register __a0 const GLuint *textures,
                                                                register __a1 GLboolean *residences );

extern __asm __saveds GLboolean APIENTRY glIsTexture( register __d0 GLuint texture );


extern __asm __saveds void APIENTRY glTexSubImage1D( register __d0 GLenum target, register __d1 GLint level,
                                                     register __d2 GLint xoffset,
                                                     register __d3 GLsizei width, register __d4 GLenum format,
                                                     register __d5 GLenum type, register __a0 const GLvoid *pixels );


extern __asm __saveds void APIENTRY glTexSubImage2D( register __d0 GLenum target, register __d1 GLint level,
                                                     register __d2 GLint xoffset, register __d3 GLint yoffset,
                                                     register __d4 GLsizei width, register __d5 GLsizei height,
                                                     register __d6 GLenum format, register __d7 GLenum type,
                                                     register __a0 const GLvoid *pixels );


extern __asm __saveds void APIENTRY glCopyTexImage1D( register __d0 GLenum target, register __d1 GLint level,
                                                      register __d2 GLenum internalformat,
                                                      register __d3 GLint x, register __d4 GLint y,
                                                      register __d5 GLsizei width, register __d6 GLint border );


extern __asm __saveds void APIENTRY glCopyTexImage2D( register __d0 GLenum target, register __d1 GLint level,
                                                      register __d2 GLenum internalformat,
                                                      register __d3 GLint x, register __d4 GLint y,
                                                      register __d5 GLsizei width, register __d6 GLsizei height,
                                                      register __d7 GLint border );


extern __asm __saveds void APIENTRY glCopyTexSubImage1D( register __d0 GLenum target, register __d1 GLint level,
                                                         register __d2 GLint xoffset, register __d3 GLint x, register __d4 GLint y,
                                                         register __d5 GLsizei width );


extern __asm __saveds void APIENTRY glCopyTexSubImage2D( register __d0 GLenum target, register __d1 GLint level,
                                                         register __d2 GLint xoffset, register __d3 GLint yoffset,
                                                         register __d4 GLint x, register __d5 GLint y,
                                                         register __d6 GLsizei width, register __d7 GLsizei height );




/*
 * Evaluators
 */

extern __asm __saveds void APIENTRY glMap1d( register __d0 GLenum target, register __fp0 GLdouble u1, register __fp1 GLdouble u2,
                                             register __d1 GLint stride,
                                             register __d2 GLint order, register __a0 const GLdouble *points );
extern __asm __saveds void APIENTRY glMap1f( register __d0 GLenum target, register __fp0 GLfloat u1, register __fp1 GLfloat u2,
                                             register __d1 GLint stride,
                                             register __d2 GLint order, register __a0 const GLfloat *points );

extern __asm __saveds void APIENTRY glMap2d( register __d0 GLenum target,
                                             register __fp0 GLdouble u1, register __fp1 GLdouble u2, register __d1 GLint ustride, register __d2 GLint uorder,
                                             register __fp2 GLdouble v1, register __fp3 GLdouble v2, register __d3 GLint vstride, register __d4 GLint vorder,
                                             register __a0 const GLdouble *points );
extern __asm __saveds void APIENTRY glMap2f( register __d0 GLenum target,
                                             register __fp0 GLfloat u1, register __fp1 GLfloat u2, register __d1 GLint ustride, register __d2 GLint uorder,
                                             register __fp2 GLfloat v1, register __fp3 GLfloat v2, register __d3 GLint vstride, register __d4 GLint vorder,
                                             register __a0 const GLfloat *points );

extern __asm __saveds void APIENTRY glGetMapdv( register __d0 GLenum target, register __d1 GLenum query, register __a0 GLdouble *v );
extern __asm __saveds void APIENTRY glGetMapfv( register __d0 GLenum target, register __d1 GLenum query, register __a0 GLfloat *v );
extern __asm __saveds void APIENTRY glGetMapiv( register __d0 GLenum target, register __d1 GLenum query, register __a0 GLint *v );

extern __asm __saveds void APIENTRY glEvalCoord1d( register __fp0 GLdouble u );
extern __asm __saveds void APIENTRY glEvalCoord1f( register __fp0 GLfloat u );

extern __asm __saveds void APIENTRY glEvalCoord1dv( register __a0 const GLdouble *u );
extern __asm __saveds void APIENTRY glEvalCoord1fv( register __a0 const GLfloat *u );

extern __asm __saveds void APIENTRY glEvalCoord2d( register __fp0 GLdouble u, register __fp1 GLdouble v );
extern __asm __saveds void APIENTRY glEvalCoord2f( register __fp0 GLfloat u, register __fp1 GLfloat v );

extern __asm __saveds void APIENTRY glEvalCoord2dv( register __a0 const GLdouble *u );
extern __asm __saveds void APIENTRY glEvalCoord2fv( register __a0 const GLfloat *u );

extern __asm __saveds void APIENTRY glMapGrid1d( register __d0 GLint un, register __fp0 GLdouble u1, register __fp1 GLdouble u2 );
extern __asm __saveds void APIENTRY glMapGrid1f( register __d0 GLint un, register __fp0 GLfloat u1, register __fp1 GLfloat u2 );

extern __asm __saveds void APIENTRY glMapGrid2d( register __d0 GLint un, register __fp0 GLdouble u1, register __fp1 GLdouble u2,
                                                 register __d1 GLint vn, register __fp2 GLdouble v1, register __fp3 GLdouble v2 );
extern __asm __saveds void APIENTRY glMapGrid2f( register __d0 GLint un, register __fp0 GLfloat u1, register __fp1 GLfloat u2,
                                                 register __d1 GLint vn, register __fp2 GLfloat v1, register __fp3 GLfloat v2 );

extern __asm __saveds void APIENTRY glEvalPoint1( register __d0 GLint i );

extern __asm __saveds void APIENTRY glEvalPoint2( register __d0 GLint i, register __d1 GLint j );

extern __asm __saveds void APIENTRY glEvalMesh1( register __d0 GLenum mode, register __d1 GLint i1, register __d2 GLint i2 );

extern __asm __saveds void APIENTRY glEvalMesh2( register __d0 GLenum mode, register __d1 GLint i1, register __d2 GLint i2, register __d3 GLint j1, register __d4 GLint j2 );



/*
 * Fog
 */

extern __asm __saveds void APIENTRY glFogf( register __d0 GLenum pname, register __fp0 GLfloat param );

extern __asm __saveds void APIENTRY glFogi( register __d0 GLenum pname, register __d1 GLint param );

extern __asm __saveds void APIENTRY glFogfv( register __d0 GLenum pname, register __a0 const GLfloat *params );

extern __asm __saveds void APIENTRY glFogiv( register __d0 GLenum pname, register __a0 const GLint *params );



/*
 * Selection and Feedback
 */

extern __asm __saveds void APIENTRY glFeedbackBuffer( register __d0 GLsizei size, register __d1 GLenum type, register __a0 GLfloat *buffer );

extern __asm __saveds void APIENTRY glPassThrough( register __fp0 GLfloat token );

extern __asm __saveds void APIENTRY glSelectBuffer( register __d0 GLsizei size, register __a0 GLuint *buffer );

extern __asm __saveds void APIENTRY glInitNames( void );

extern __asm __saveds void APIENTRY glLoadName( register __d0 GLuint name );

extern __asm __saveds void APIENTRY glPushName( register __d0 GLuint name );

extern __asm __saveds void APIENTRY glPopName( void );



/*
 * 1.0 Extensions
 */

/* GL_EXT_blend_minmax */
extern __asm __saveds void APIENTRY glBlendEquationEXT( register __d0 GLenum mode );



/* GL_EXT_blend_color */
extern __asm __saveds void APIENTRY glBlendColorEXT( register __fp0 GLclampf red, register __fp1 GLclampf green,
                                                     register __fp2 GLclampf blue, register __fp3 GLclampf alpha );



/* GL_EXT_polygon_offset */
extern __asm __saveds void APIENTRY glPolygonOffsetEXT( register __fp0 GLfloat factor, register __fp1 GLfloat bias );



/* GL_EXT_vertex_array */

extern __asm __saveds void APIENTRY glVertexPointerEXT( register __d0 GLint size, register __d1 GLenum type,
                                                        register __d2 GLsizei stride,
                                                        register __d3 GLsizei count, register __a0 const GLvoid *ptr );

extern __asm __saveds void APIENTRY glNormalPointerEXT( register __d0 GLenum type, register __d1 GLsizei stride,
                                                        register __d2 GLsizei count, register __a0 const GLvoid *ptr );

extern __asm __saveds void APIENTRY glColorPointerEXT( register __d0 GLint size, register __d1 GLenum type,
                                                       register __d2 GLsizei stride,
                                                       register __d3 GLsizei count, register __a0 const GLvoid *ptr );

extern __asm __saveds void APIENTRY glIndexPointerEXT( register __d0 GLenum type, register __d1 GLsizei stride,
                                                       register __d2 GLsizei count, register __a0 const GLvoid *ptr );

extern __asm __saveds void APIENTRY glTexCoordPointerEXT( register __d0 GLint size, register __d1 GLenum type,
                                                          register __d2 GLsizei stride, register __d3 GLsizei count,
                                                          register __a0 const GLvoid *ptr );

extern __asm __saveds void APIENTRY glEdgeFlagPointerEXT( register __d0 GLsizei stride, register __d1 GLsizei count,
                                                          register __a0 const GLboolean *ptr );

extern __asm __saveds void APIENTRY glGetPointervEXT( register __d0 GLenum pname, register __a0 void **params );

extern __asm __saveds void APIENTRY glArrayElementEXT( register __d0 GLint i );

extern __asm __saveds void APIENTRY glDrawArraysEXT( register __d0 GLenum mode, register __d1 GLint first,
                                                     register __d2 GLsizei count );



/* GL_EXT_texture_object */

extern __asm __saveds void APIENTRY glGenTexturesEXT( register __d0 GLsizei n, register __a0 GLuint *textures );

extern __asm __saveds void APIENTRY glDeleteTexturesEXT( register __d0 GLsizei n,
                                                         register __a0 const GLuint *textures );

extern __asm __saveds void APIENTRY glBindTextureEXT( register __d0 GLenum target, register __d1 GLuint texture );

extern __asm __saveds void APIENTRY glPrioritizeTexturesEXT( register __d0 GLsizei n,
                                                             register __a0 const GLuint *textures,
                                                             register __a1 const GLclampf *priorities );

extern __asm __saveds GLboolean APIENTRY glAreTexturesResidentEXT( register __d0 GLsizei n,
                                                                   register __a0 const GLuint *textures,
                                                                   register __a1 GLboolean *residences );

extern __asm __saveds GLboolean APIENTRY glIsTextureEXT( register __d0 GLuint texture );



/* GL_EXT_texture3D */

extern __asm __saveds void APIENTRY glTexImage3DEXT( register __d0 GLenum target, register __d1 GLint level,
                                                     register __d2 GLenum internalFormat,
                                                     register __d3 GLsizei width, register __d4 GLsizei height,
                                                     register __d5 GLsizei depth, register __d6 GLint border,
                                                     register __d7 GLenum format, register __a0 GLenum type,
                                                     register __a1 const GLvoid *pixels );

extern __asm __saveds void APIENTRY glTexSubImage3DEXT( register __d0 GLenum target, register __d1 GLint level,
                                                        register __d2 GLint xoffset, register __d3 GLint yoffset,
                                                        register __d4 GLint zoffset, register __d5 GLsizei width,
                                                        register __d6 GLsizei height, register __d7 GLsizei depth,
                                                        register __a0 GLenum format,
                                                        register __a1 GLenum type, register __a2 const GLvoid *pixels );

extern __asm __saveds void APIENTRY glCopyTexSubImage3DEXT( register __d0 GLenum target, register __d1 GLint level,
                                                            register __d2 GLint xoffset, register __d3 GLint yoffset,
                                                            register __d4 GLint zoffset, register __d5 GLint x,
                                                            register __d6 GLint y, register __d7 GLsizei width,
                                                            register __a0 GLsizei height );



/* GL_EXT_color_table */

extern __asm __saveds void APIENTRY glColorTableEXT( register __d0 GLenum target, register __d1 GLenum internalformat,
                                                     register __d2 GLsizei width, register __d3 GLenum format,
                                                     register __d4 GLenum type, register __a0 const GLvoid *table );

extern __asm __saveds void APIENTRY glColorSubTableEXT( register __d0 GLenum target,
                                                        register __d1 GLsizei start, register __d2 GLsizei count,
                                                        register __d3 GLenum format, register __d4 GLenum type,
                                                        register __a0 const GLvoid *data );

extern __asm __saveds void APIENTRY glGetColorTableEXT( register __d0 GLenum target, register __d1 GLenum format,
                                                        register __d2 GLenum type, register __a0 GLvoid *table );

extern __asm __saveds void APIENTRY glGetColorTableParameterfvEXT( register __d0 GLenum target,
                                                                   register __d1 GLenum pname,
                                                                   register __a0 GLfloat *params );

extern __asm __saveds void APIENTRY glGetColorTableParameterivEXT( register __d0 GLenum target,
                                                                   register __d1 GLenum pname,
                                                                   register __a0 GLint *params );

/*CHANGE {*/
/* GL_SGIS_multitexture */

extern __asm __saveds void APIENTRY glMultiTexCoord1dSGIS( register __d0 GLenum target, register __fp0 GLdouble s );
extern __asm __saveds void APIENTRY glMultiTexCoord1dvSGIS( register __d0 GLenum target, register __a0 const GLdouble *v );
extern __asm __saveds void APIENTRY glMultiTexCoord1fSGIS( register __d0 GLenum target, register __fp0 GLfloat s );
extern __asm __saveds void APIENTRY glMultiTexCoord1fvSGIS( register __d0 GLenum target, register __a0 const GLfloat *v );
extern __asm __saveds void APIENTRY glMultiTexCoord1iSGIS( register __d0 GLenum target, register __d1 GLint s );
extern __asm __saveds void APIENTRY glMultiTexCoord1ivSGIS( register __d0 GLenum target, register __a0 const GLint *v );
extern __asm __saveds void APIENTRY glMultiTexCoord1sSGIS( register __d0 GLenum target, register __d1 GLshort s );
extern __asm __saveds void APIENTRY glMultiTexCoord1svSGIS( register __d0 GLenum target, register __a0 const GLshort *v );
extern __asm __saveds void APIENTRY glMultiTexCoord2dSGIS( register __d0 GLenum target, register __fp0 GLdouble s, register __fp1 GLdouble t );
extern __asm __saveds void APIENTRY glMultiTexCoord2dvSGIS( register __d0 GLenum target, register __a0 const GLdouble *v );
extern __asm __saveds void APIENTRY glMultiTexCoord2fSGIS( register __d0 GLenum target, register __fp0 GLfloat s, register __fp1 GLfloat t );
extern __asm __saveds void APIENTRY glMultiTexCoord2fvSGIS( register __d0 GLenum target, register __a0 const GLfloat *v );
extern __asm __saveds void APIENTRY glMultiTexCoord2iSGIS( register __d0 GLenum target, register __d1 GLint s, register __d2 GLint t );
extern __asm __saveds void APIENTRY glMultiTexCoord2ivSGIS( register __d0 GLenum target, register __a0 const GLint *v );
extern __asm __saveds void APIENTRY glMultiTexCoord2sSGIS( register __d0 GLenum target, register __d1 GLshort s, register __d2 GLshort t );
extern __asm __saveds void APIENTRY glMultiTexCoord2svSGIS( register __d0 GLenum target, register __a0 const GLshort *v );
extern __asm __saveds void APIENTRY glMultiTexCoord3dSGIS( register __d0 GLenum target, register __fp0 GLdouble s, register __fp1 GLdouble t, register __fp2 GLdouble r );
extern __asm __saveds void APIENTRY glMultiTexCoord3dvSGIS( register __d0 GLenum target, register __a0 const GLdouble *v );
extern __asm __saveds void APIENTRY glMultiTexCoord3fSGIS( register __d0 GLenum target, register __fp0 GLfloat s, register __fp1 GLfloat t, register __fp2 GLfloat r );
extern __asm __saveds void APIENTRY glMultiTexCoord3fvSGIS( register __d0 GLenum target, register __a0 const GLfloat *v );
extern __asm __saveds void APIENTRY glMultiTexCoord3iSGIS( register __d0 GLenum target, register __d1 GLint s, register __d2 GLint t, register __d3 GLint r );
extern __asm __saveds void APIENTRY glMultiTexCoord3ivSGIS( register __d0 GLenum target, register __a0 const GLint *v );
extern __asm __saveds void APIENTRY glMultiTexCoord3sSGIS( register __d0 GLenum target, register __d1 GLshort s, register __d2 GLshort t, register __d3 GLshort r );
extern __asm __saveds void APIENTRY glMultiTexCoord3svSGIS( register __d0 GLenum target, register __a0 const GLshort *v );
extern __asm __saveds void APIENTRY glMultiTexCoord4dSGIS( register __d0 GLenum target, register __fp0 GLdouble s, register __fp1 GLdouble t, register __fp2 GLdouble r, register __fp3 GLdouble q );
extern __asm __saveds void APIENTRY glMultiTexCoord4dvSGIS( register __d0 GLenum target, register __a0 const GLdouble *v );
extern __asm __saveds void APIENTRY glMultiTexCoord4fSGIS( register __d0 GLenum target, register __fp0 GLfloat s, register __fp1 GLfloat t, register __fp2 GLfloat r, register __fp3 GLfloat q );
extern __asm __saveds void APIENTRY glMultiTexCoord4fvSGIS( register __d0 GLenum target, register __a0 const GLfloat *v );
extern __asm __saveds void APIENTRY glMultiTexCoord4iSGIS( register __d0 GLenum target, register __d1 GLint s, register __d2 GLint t, register __d3 GLint r, register __d4 GLint q );
extern __asm __saveds void APIENTRY glMultiTexCoord4ivSGIS( register __d0 GLenum target, register __a0 const GLint *v );
extern __asm __saveds void APIENTRY glMultiTexCoord4sSGIS( register __d0 GLenum target, register __d1 GLshort s, register __d2 GLshort t, register __d3 GLshort r, register __d4 GLshort q );
extern __asm __saveds void APIENTRY glMultiTexCoord4svSGIS( register __d0 GLenum target, register __a0 const GLshort *v );

extern __asm __saveds void APIENTRY glMultiTexCoordPointerSGIS( register __d0 GLenum target, register __d1 GLint size, register __d2 GLenum type, register __d3 GLsizei stride, register __a0 const GLvoid *pointer );

extern __asm __saveds void APIENTRY glSelectTextureSGIS( register __d0 GLenum target );

extern __asm __saveds void APIENTRY glSelectTextureCoordSetSGIS( register __d0 GLenum target );


/* GL_EXT_multitexture */

extern __asm __saveds void APIENTRY glMultiTexCoord1dEXT( register __d0 GLenum target, register __fp0 GLdouble s );
extern __asm __saveds void APIENTRY glMultiTexCoord1dvEXT( register __d0 GLenum target, register __a0 const GLdouble *v );
extern __asm __saveds void APIENTRY glMultiTexCoord1fEXT( register __d0 GLenum target, register __fp0 GLfloat s );
extern __asm __saveds void APIENTRY glMultiTexCoord1fvEXT( register __d0 GLenum target, register __a0 const GLfloat *v );
extern __asm __saveds void APIENTRY glMultiTexCoord1iEXT( register __d0 GLenum target, register __d1 GLint s );
extern __asm __saveds void APIENTRY glMultiTexCoord1ivEXT( register __d0 GLenum target, register __a0 const GLint *v );
extern __asm __saveds void APIENTRY glMultiTexCoord1sEXT( register __d0 GLenum target, register __d1 GLshort s );
extern __asm __saveds void APIENTRY glMultiTexCoord1svEXT( register __d0 GLenum target, register __a0 const GLshort *v );
extern __asm __saveds void APIENTRY glMultiTexCoord2dEXT( register __d0 GLenum target, register __fp0 GLdouble s, register __fp1 GLdouble t );
extern __asm __saveds void APIENTRY glMultiTexCoord2dvEXT( register __d0 GLenum target, register __a0 const GLdouble *v );
extern __asm __saveds void APIENTRY glMultiTexCoord2fEXT( register __d0 GLenum target, register __fp0 GLfloat s, register __fp1 GLfloat t );
extern __asm __saveds void APIENTRY glMultiTexCoord2fvEXT( register __d0 GLenum target, register __a0 const GLfloat *v );
extern __asm __saveds void APIENTRY glMultiTexCoord2iEXT( register __d0 GLenum target, register __d1 GLint s, register __d2 GLint t );
extern __asm __saveds void APIENTRY glMultiTexCoord2ivEXT( register __d0 GLenum target, register __a0 const GLint *v );
extern __asm __saveds void APIENTRY glMultiTexCoord2sEXT( register __d0 GLenum target, register __d1 GLshort s, register __d2 GLshort t );
extern __asm __saveds void APIENTRY glMultiTexCoord2svEXT( register __d0 GLenum target, register __a0 const GLshort *v );
extern __asm __saveds void APIENTRY glMultiTexCoord3dEXT( register __d0 GLenum target, register __fp0 GLdouble s, register __fp1 GLdouble t, register __fp2 GLdouble r );
extern __asm __saveds void APIENTRY glMultiTexCoord3dvEXT( register __d0 GLenum target, register __a0 const GLdouble *v );
extern __asm __saveds void APIENTRY glMultiTexCoord3fEXT( register __d0 GLenum target, register __fp0 GLfloat s, register __fp1 GLfloat t, register __fp2 GLfloat r );
extern __asm __saveds void APIENTRY glMultiTexCoord3fvEXT( register __d0 GLenum target, register __a0 const GLfloat *v );
extern __asm __saveds void APIENTRY glMultiTexCoord3iEXT( register __d0 GLenum target, register __d1 GLint s, register __d2 GLint t, register __d3 GLint r );
extern __asm __saveds void APIENTRY glMultiTexCoord3ivEXT( register __d0 GLenum target, register __a0 const GLint *v );
extern __asm __saveds void APIENTRY glMultiTexCoord3sEXT( register __d0 GLenum target, register __d1 GLshort s, register __d2 GLshort t, register __d3 GLshort r );
extern __asm __saveds void APIENTRY glMultiTexCoord3svEXT( register __d0 GLenum target, register __a0 const GLshort *v );
extern __asm __saveds void APIENTRY glMultiTexCoord4dEXT( register __d0 GLenum target, register __fp0 GLdouble s, register __fp1 GLdouble t, register __fp2 GLdouble r, register __fp3 GLdouble q );
extern __asm __saveds void APIENTRY glMultiTexCoord4dvEXT( register __d0 GLenum target, register __a0 const GLdouble *v );
extern __asm __saveds void APIENTRY glMultiTexCoord4fEXT( register __d0 GLenum target, register __fp0 GLfloat s, register __fp1 GLfloat t, register __fp2 GLfloat r, register __fp3 GLfloat q );
extern __asm __saveds void APIENTRY glMultiTexCoord4fvEXT( register __d0 GLenum target, register __a0 const GLfloat *v );
extern __asm __saveds void APIENTRY glMultiTexCoord4iEXT( register __d0 GLenum target, register __d1 GLint s, register __d2 GLint t, register __d3 GLint r, register __d4 GLint q );
extern __asm __saveds void APIENTRY glMultiTexCoord4ivEXT( register __d0 GLenum target, register __a0 const GLint *v );
extern __asm __saveds void APIENTRY glMultiTexCoord4sEXT( register __d0 GLenum target, register __d1 GLshort s, register __d2 GLshort t, register __d3 GLshort r, register __d4 GLshort q );
extern __asm __saveds void APIENTRY glMultiTexCoord4svEXT( register __d0 GLenum target, register __a0 const GLshort *v );

extern __asm __saveds void APIENTRY glInterleavedTextureCoordSetsEXT( register __d0 GLint factor );

extern __asm __saveds void APIENTRY glSelectTextureEXT( register __d0 GLenum target );

extern __asm __saveds void APIENTRY glSelectTextureCoordSetEXT( register __d0 GLenum target );

extern __asm __saveds void APIENTRY glSelectTextureTransformEXT( register __d0 GLenum target );

/*END }*/



/* GL_EXT_point_parameters */
extern __asm __saveds void APIENTRY glPointParameterfEXT( register __d0 GLenum pname, register __fp0 GLfloat param );
extern __asm __saveds void APIENTRY glPointParameterfvEXT( register __d0 GLenum pname,
                                                           register __a0 const GLfloat *params );



/* GL_MESA_window_pos */

extern __asm __saveds void APIENTRY glWindowPos2iMESA( register __d0 GLint x, register __d1 GLint y );
extern __asm __saveds void APIENTRY glWindowPos2sMESA( register __d0 GLshort x, register __d1 GLshort y );
extern __asm __saveds void APIENTRY glWindowPos2fMESA( register __fp0 GLfloat x, register __fp1 GLfloat y );
extern __asm __saveds void APIENTRY glWindowPos2dMESA( register __fp0 GLdouble x, register __fp1 GLdouble y );

extern __asm __saveds void APIENTRY glWindowPos2ivMESA( register __a0 const GLint *p );
extern __asm __saveds void APIENTRY glWindowPos2svMESA( register __a0 const GLshort *p );
extern __asm __saveds void APIENTRY glWindowPos2fvMESA( register __a0 const GLfloat *p );
extern __asm __saveds void APIENTRY glWindowPos2dvMESA( register __a0 const GLdouble *p );

extern __asm __saveds void APIENTRY glWindowPos3iMESA( register __d0 GLint x, register __d1 GLint y, register __d2 GLint z );
extern __asm __saveds void APIENTRY glWindowPos3sMESA( register __d0 GLshort x, register __d1 GLshort y, register __d2 GLshort z );
extern __asm __saveds void APIENTRY glWindowPos3fMESA( register __fp0 GLfloat x, register __fp1 GLfloat y, register __fp2 GLfloat z );
extern __asm __saveds void APIENTRY glWindowPos3dMESA( register __fp0 GLdouble x, register __fp1 GLdouble y, register __fp2 GLdouble z );

extern __asm __saveds void APIENTRY glWindowPos3ivMESA( register __a0 const GLint *p );
extern __asm __saveds void APIENTRY glWindowPos3svMESA( register __a0 const GLshort *p );
extern __asm __saveds void APIENTRY glWindowPos3fvMESA( register __a0 const GLfloat *p );
extern __asm __saveds void APIENTRY glWindowPos3dvMESA( register __a0 const GLdouble *p );

extern __asm __saveds void APIENTRY glWindowPos4iMESA( register __d0 GLint x, register __d1 GLint y, register __d2 GLint z, register __d3 GLint w );
extern __asm __saveds void APIENTRY glWindowPos4sMESA( register __d0 GLshort x, register __d1 GLshort y, register __d2 GLshort z, register __d3 GLshort w );
extern __asm __saveds void APIENTRY glWindowPos4fMESA( register __fp0 GLfloat x, register __fp1 GLfloat y, register __fp2 GLfloat z, register __fp3 GLfloat w );
extern __asm __saveds void APIENTRY glWindowPos4dMESA( register __fp0 GLdouble x, register __fp1 GLdouble y, register __fp2 GLdouble z, register __fp3 GLdouble w );

extern __asm __saveds void APIENTRY glWindowPos4ivMESA( register __a0 const GLint *p );
extern __asm __saveds void APIENTRY glWindowPos4svMESA( register __a0 const GLshort *p );
extern __asm __saveds void APIENTRY glWindowPos4fvMESA( register __a0 const GLfloat *p );
extern __asm __saveds void APIENTRY glWindowPos4dvMESA( register __a0 const GLdouble *p );


/* GL_MESA_resize_buffers */

extern __asm __saveds void APIENTRY glResizeBuffersMESA( void );


/*CHANGE {*/
/* 1.2 functions */
extern __asm __saveds void APIENTRY glDrawRangeElements( register __d0 GLenum mode, register __d1 GLuint start,
                                                         register __d2 GLuint end, register __d3 GLsizei count, register __d4 GLenum type, register __a0 const GLvoid *indices );

extern __asm __saveds void APIENTRY glTexImage3D( register __d0 GLenum target, register __d1 GLint level,
                                                  register __d2 GLenum internalFormat,
                                                  register __d3 GLsizei width, register __d4 GLsizei height,
                                                  register __d5 GLsizei depth, register __d6 GLint border,
                                                  register __d7 GLenum format, register __a0 GLenum type,
                                                  register __a1 const GLvoid *pixels );

extern __asm __saveds void APIENTRY glTexSubImage3D( register __d0 GLenum target, register __d1 GLint level,
                                                     register __d2 GLint xoffset, register __d3 GLint yoffset,
                                                     register __d4 GLint zoffset, register __d5 GLsizei width,
                                                     register __d6 GLsizei height, register __d7 GLsizei depth,
                                                     register __a0 GLenum format,
                                                     register __a1 GLenum type, register __a2 const GLvoid *pixels );

extern __asm __saveds void APIENTRY glCopyTexSubImage3D( register __d0 GLenum target, register __d1 GLint level,
                                                         register __d2 GLint xoffset, register __d3 GLint yoffset,
                                                         register __d4 GLint zoffset, register __d5 GLint x,
                                                         register __d6 GLint y, register __d7 GLsizei width,
                                                         register __a0 GLsizei height );
/*END }*/


#ifndef MAKE_MESAMAINLIB

extern __asm __saveds void APIENTRY STUBglOrtho(register __fp0 GLdouble left, register __fp1 GLdouble right, register __fp2 GLdouble bottom, register __fp3 GLdouble top, register __fp4 GLdouble near_val, register __fp5 GLdouble far_val, register __a0 struct Library *mesamainBase);
#define glOrtho(left,right,bottom,top,near_val,far_val)	STUBglOrtho(left,right,bottom,top,near_val,far_val,mesamainBase)

extern __asm __saveds void APIENTRY STUBglFrustum(register __fp0 GLdouble left, register __fp1 GLdouble right, register __fp2 GLdouble bottom, register __fp3 GLdouble top, register __fp4 GLdouble near_val, register __fp5 GLdouble far_val, register __a0 struct Library *mesamainBase);
#define glFrustum(left,right,bottom,top,near_val,far_val) STUBglFrustum(left,right,bottom,top,near_val,far_val,mesamainBase)

extern __asm __saveds void APIENTRY STUBglBitmap(register __d0 GLsizei width, register __d1 GLsizei height, register __fp0 GLfloat xorig, register __fp1 GLfloat yorig, register __fp2 GLfloat xmove, register __fp3 GLfloat ymove, register __a0 const GLubyte *bitmap, register __a1 struct Library *mesamainBase);
#define glBitmap(width,height,xorig,yorig,xmove,ymove,bitmap) STUBglBitmap(width,height,xorig,yorig,xmove,ymove,bitmap,mesamainBase)

extern __asm __saveds void APIENTRY STUBglMap1d(register __d0 GLenum target, register __fp0 GLdouble u1, register __fp1 GLdouble u2, register __d1 GLint stride, register __d2 GLint order, register __a0 const GLdouble *points, register __a1 struct Library *mesamainBase);
#define glMap1d(target,u1,u2,stride,order,points) STUBglMap1d(target,u1,u2,stride,order,points,mesamainBase)

extern __asm __saveds void APIENTRY STUBglMap1f(register __d0 GLenum target, register __fp0 GLfloat u1, register __fp1 GLfloat u2, register __d1 GLint stride, register __d2 GLint order, register __a0 const GLfloat *points, register __a1 struct Library *mesamainBase);
#define glMap1f(target,u1,u2,stride,order,points) STUBglMap1f(target,u1,u2,stride,order,points,mesamainBase)

extern __asm __saveds void APIENTRY STUBglMap2d(register __d0 GLenum target, register __fp0 GLdouble u1, register __fp1 GLdouble u2, register __d1 GLint ustride, register __d2 GLint uorder, register __fp2 GLdouble v1, register __fp3 GLdouble v2, register __d3 GLint vstride, register __d4 GLint vorder, register __a0 const GLdouble *points, register __a1 struct Library *mesamainBase);
#define glMap2d(target,u1,u2,ustride,uorder,v1,v2,vstride,vorder,points) STUBglMap2d(target,u1,u2,ustride,uorder,v1,v2,vstride,vorder,points,mesamainBase)

extern __asm __saveds void APIENTRY STUBglMap2f(register __d0 GLenum target, register __fp0 GLfloat u1, register __fp1 GLfloat u2, register __d1 GLint ustride, register __d2 GLint uorder, register __fp2 GLfloat v1, register __fp3 GLfloat v2, register __d3 GLint vstride, register __d4 GLint vorder, register __a0 const GLfloat *points, register __a1 struct Library *mesamainBase);
#define glMap2f(target,u1,u2,ustride,uorder,v1,v2,vstride,vorder,points) STUBglMap2f(target,u1,u2,ustride,uorder,v1,v2,vstride,vorder,points,mesamainBase)

extern __asm __saveds void APIENTRY STUBglMapGrid2d(register __d0 GLint un, register __fp0 GLdouble u1, register __fp1 GLdouble u2, register __d1 GLint vn, register __fp2 GLdouble v1, register __fp3 GLdouble v2, register __a0 struct Library *mesamainBase);
#define glMapGrid2d(un,u1,u2,vn,v1,v2) STUBglMapGrid2d(un,u1,u2,vn,v1,v2,mesamainBase)

extern __asm __saveds void APIENTRY STUBglMapGrid2f(register __d0 GLint un, register __fp0 GLfloat u1, register __fp1 GLfloat u2, register __d1 GLint vn, register __fp2 GLfloat v1, register __fp3 GLfloat v2, register __a0 struct Library *mesamainBase);
#define glMapGrid2f(un,u1,u2,vn,v1,v2) STUBglMapGrid2f(un,u1,u2,vn,v1,v2,mesamainBase)

#endif

#if defined(__BEOS__) || defined(__QUICKDRAW__)
#pragma export off
#endif


/*
 * Compile-time tests for extensions:
 */
#define GL_EXT_blend_color		1
#define GL_EXT_blend_logic_op		1
#define GL_EXT_blend_minmax		1
#define GL_EXT_blend_subtract		1
#define GL_EXT_polygon_offset		1
#define GL_EXT_vertex_array		1
#define GL_EXT_texture_object		1
#define GL_EXT_texture3D		1
#define GL_EXT_paletted_texture		1
#define GL_EXT_shared_texture_palette	1
#define GL_EXT_point_parameters		1
#define GL_EXT_rescale_normal		1
#define GL_EXT_abgr			1
#define GL_EXT_multitexture		1
#define GL_MESA_window_pos		1
#define GL_MESA_resize_buffers		1
#define GL_SGIS_multitexture		1
#define GL_SGIS_texture_edge_clamp	1


#ifdef macintosh
	#pragma enumsalwaysint reset
	#if PRAGMA_IMPORT_SUPPORTED
	#pragma import off
	#endif
#endif


#ifdef __cplusplus
}
#endif

#endif
