/*
**	$VER: cybergl.h 1.0 (20.03.97)
**	
**	Copyright © 1996-1997 by phase5 digital products
**      All Rights reserved.
**
*/

#ifndef _CYBERGL_H
#define _CYBERGL_H

#include <cybergl/cybergl_display.h>

extern struct Library *CyberGLBase;

/*----------------------Defines------------------------------*/

#define GL_ACCUM_BUFFER_BIT    (1 <<  0) /* accumulation buffer mask */
#define GL_COLOR_BUFFER_BIT    (1 <<  1) /* color buffer mask */
#define GL_CURRENT_BIT         (1 <<  2) /* current values mask */
#define GL_DEPTH_BUFFER_BIT    (1 <<  3) /* depth buffer mask */
#define GL_ENABLE_BIT          (1 <<  4) /* enable mask */
#define GL_EVAL_BIT            (1 <<  5) /* evaluator mask */
#define GL_FOG_BIT             (1 <<  6) /* fog mask */
#define GL_HINT_BIT            (1 <<  7) /* hint mask */
#define GL_LIGHTING_BIT        (1 <<  8) /* lighting mask */
#define GL_LINE_BIT            (1 <<  9) /* line mask */
#define GL_LIST_BIT            (1 << 10) /* display list mask */
#define GL_PIXEL_MODE_BIT      (1 << 11) /* pixel mode mask */
#define GL_POINT_BIT           (1 << 12) /* point mask */
#define GL_POLYGON_BIT         (1 << 13) /* polygon mask */
#define GL_POLYGON_STIPPLE_BIT (1 << 14) /* polygon stipple mask */
#define GL_SCISSOR_BIT         (1 << 15) /* scissor mask */
#define GL_STENCIL_BUFFER_BIT  (1 << 16) /* stencil buffer mask */
#define GL_TEXTURE_BIT         (1 << 17) /* texture mask */
#define GL_TRANSFORM_BIT       (1 << 18) /* transformation mask */
#define GL_VIEWPORT_BIT        (1 << 19) /* viewport mask */
#define GL_ALL_ATTRIB_BIT       (GL_ACCUM_BUFFER_BIT    || GL_COLOR_BUFFER_BIT || \
                                 GL_CURRENT_BIT         || GL_DEPTH_BUFFER_BIT || \
                                 GL_ENABLE_BIT          || GL_EVAL_BIT         || \
                                 GL_FOG_BIT             || GL_HINT_BIT         || \
                                 GL_LIGHTING_BIT        || GL_LINE_BIT         || \
                                 GL_LIST_BIT            || GL_PIXEL_MODE_BIT   || \
                                 GL_POINT_BIT           || GL_POLYGON_BIT      || \
                                 GL_POLYGON_STIPPLE_BIT || GL_SCISSOR_BIT      || \
                                 GL_STENCIL_BUFFER_BIT  || GL_TEXTURE_BIT      || \
                                 GL_TRANSFORM_BIT       || GL_VIEWPORT_BIT)
                                         /* all attrib bits at once */

/*----------------------Types--------------------------------*/

typedef void           GLvoid;
typedef unsigned long  GLbitfield;
typedef signed char    GLbyte;
typedef short          GLshort;
typedef long           GLint;
typedef unsigned long  GLsizei;
typedef unsigned char  GLubyte;
typedef unsigned short GLushort;
typedef unsigned long  GLuint;
typedef float          GLfloat;
typedef float          GLclampf;
typedef double         GLdouble;
typedef double         GLclampd;

typedef enum {
  GL_FALSE,
  GL_TRUE
}                      GLboolean;

enum {
  GL_CLIENT_PIXEL_STORE_BIT	= 0x00000001,
  GL_CLIENT_VERTEX_ARRAY_BIT	= 0x00000002,
  GL_CLIENT_ALL_ATTRIB_BITS	= 0x0000FFFF
};

typedef enum {                      /* enumerated constants */
  GL_NO_ERROR,                      /* no error occured */
  GL_INVALID_ENUM,                  /* invalid enum specified */
  GL_INVALID_VALUE,                 /* invalid value specified */
  GL_INVALID_OPERATION,             /* invalid operation executed */
  GL_STACK_OVERFLOW,                /* stack overflow error */
  GL_STACK_UNDERFLOW,               /* stack underflow error */
  GL_OUT_OF_MEMORY,                 /* out of memory */
  GL_NOT_IMPLEMENTED,               /* not implemented in simpleGL */
  GL_NO_PRIMITIVE,                  /* currently not in begin/end mode */
  GL_POINTS,                        /* assembling points */
  GL_LINE_STRIP,                    /* assembling a line strip */
  GL_LINE_LOOP,                     /* assembling a line loop */
  GL_LINES,                         /* assembling lines */
  GL_POLYGON,                       /* assembling a polygon */
  GL_TRIANGLE_STRIP,                /* assembling a triangle strip */
  GL_TRIANGLE_FAN,                  /* assembling a triangle fan */
  GL_TRIANGLES,                     /* assembling triangles */
  GL_QUAD_STRIP,                    /* assembling a quad strip */
  GL_QUADS,                         /* assembling quads */
  GL_CLIP_PLANE0,                   /* clip plane 0 */
  GL_CLIP_PLANE1,                   /* clip plane 1 */
  GL_CLIP_PLANE2,                   /* clip plane 2 */
  GL_CLIP_PLANE3,                   /* clip plane 3 */
  GL_CLIP_PLANE4,                   /* clip plane 4 */
  GL_CLIP_PLANE5,                   /* clip plane 5 */
  GL_LESS,                          /* pass depth test if new z is less */
  GL_ALWAYS,                        /* always pass depth test */
  GL_GEQUAL,                        /* pass depth test if new z is greater or equal */
  GL_GREATER,                       /* pass depth test if new z is greater */
  GL_LEQUAL,                        /* pass depth test if new z is less or equal */
  GL_EQUAL,                         /* pass depth test if new z is equal */
  GL_NOTEQUAL,                      /* pass depth test if new z is different */
  GL_NEVER,                         /* never pass depth test */
  GL_NONE,                          /* draw to no buffer */
  GL_FRONT_LEFT,                    /* draw to front left buffer */
  GL_FRONT_RIGHT,                   /* draw to front right buffer */
  GL_BACK_LEFT,                     /* draw to back left buffer */
  GL_BACK_RIGHT,                    /* draw to back right buffer */
  GL_LEFT,                          /* draw to front and back left buffers */
  GL_RIGHT,                         /* draw to front and back right buffers */
  GL_FRONT,                         /* draw to left and right front buffers */
  GL_BACK,                          /* draw to left and right back buffers */
  GL_FRONT_AND_BACK,                /* draw to all buffers */
  GL_AUX0,                          /* draw to auxiliary buffer 0 */
  GL_COLOR_MATERIAL,                /* enable current color tracking */
  GL_CULL_FACE,                     /* enable back face culling */
  GL_DEPTH_TEST,                    /* enable depth test */
  GL_FOG,                           /* enable fog calculation */
  GL_LIGHTING,                      /* enable lighting */
  GL_NORMALIZE,                     /* enable auto normalization */
  GL_DITHER,                        /* enable dithering */
  GL_FOG_MODE,                      /* specify fog mode */
  GL_FOG_DENSITY,                   /* specify fog density */
  GL_FOG_START,                     /* distance where no fog occurs */
  GL_FOG_END,                       /* distance where full fog occurs */
  GL_FOG_COLOR,                     /* color of fog */
  GL_FOG_INDEX,                     /* not implemented */
  GL_CW,                            /* clock wise */
  GL_CCW,                           /* counter clock wise */
  GL_AUX_BUFFERS,                   /* get number of auxiliary buffers */
  GL_DEPTH_BITS,                    /* get number of depth buffer bits */
  GL_RED_BITS,                      /* get number of red component bits */
  GL_GREEN_BITS,                    /* get number of green component bits */
  GL_BLUE_BITS,                     /* get number of blue component bits */
  GL_ALPHA_BITS,                    /* get number of alpha component bits */
  GL_COLOR_CLEAR_VALUE,             /* get current clear color */
  GL_COLOR_MATERIAL_FACE,           /* get current color tracking face(s) */
  GL_COLOR_MATERIAL_PARAMETER,      /* get current color tracking material property */
  GL_CULL_FACE_MODE,                /* get current cull face mode */
  GL_CURRENT_COLOR,                 /* get current color */
  GL_CURRENT_NORMAL,                /* get current normal */
  GL_DEPTH_CLEAR_VALUE,             /* get current depth clear value */
  GL_DEPTH_FUNC,                    /* get current depth test function */
  GL_DEPTH_RANGE,                   /* get current depth range */
  GL_DOUBLEBUFFER,                  /* ask wheter doublebuffering is possible */
  GL_DRAW_BUFFER,                   /* get current draw buffer(s) */
  GL_EDGE_FLAG,                     /* get current edge flag */
  GL_FRONT_FACE,                    /* get current front face orientation */
  GL_MATRIX_MODE,                   /* get current matrix mode */
  GL_MAX_CLIP_PLANES,               /* get maximum number of clipping planes */
  GL_MAX_LIGHTS,                    /* get maximum number of lights */
  GL_MAX_MODELVIEW_STACK_DEPTH,     /* get maximum modelview matrix stack depth */
  GL_MAX_NAME_STACK_DEPTH,          /* get maximum name stack depth */
  GL_MAX_PROJECTION_STACK_DEPTH,    /* get maximum projection matrix stack depth */
  GL_MAX_VIEWPORT_DIMS,             /* get maximum viewport dimensions */
  GL_MODELVIEW_MATRIX,              /* get current modelview matrix */
  GL_MODELVIEW_STACK_DEPTH,         /* get current modelview matrix stack depth */
  GL_NAME_STACK_DEPTH,              /* get current name stack depth */
  GL_POLYGON_MODE,                  /* get current polygon rasterisation mode */
  GL_PROJECTION_MATRIX,             /* get current projection matrix */
  GL_PROJECTION_STACK_DEPTH,        /* get current projection matrix stack depth */
  GL_RENDER_MODE,                   /* get current render mode */
  GL_SHADE_MODEL,                   /* get current shade model */
  GL_STEREO,                        /* ask whether stereo drawing is possible  */
  GL_VIEWPORT,                      /* get current viewport dimensions */
  GL_VENDOR,                        /* get the implementation company's name */
  GL_RENDERER,                      /* get platform specific string */
  GL_VERSION,                       /* get release version */
  GL_EXTENSIONS,                    /* get list of extensions */
  GL_FOG_HINT,                      /* get current fog hint */
  GL_PERSPECTIVE_CORRECTION_HINT,   /* get current perspective correction hint */
  GL_FASTEST,                       /* hint value 'fastest' */
  GL_NICEST,                        /* hint value 'nicest' */
  GL_DONT_CARE,                     /* do not care about hint */
  GL_LIGHT0,                        /* light 0 */
  GL_LIGHT1,                        /* light 1 */
  GL_LIGHT2,                        /* light 2 */
  GL_LIGHT3,                        /* light 3 */
  GL_LIGHT4,                        /* light 4 */
  GL_LIGHT5,                        /* light 5 */
  GL_LIGHT6,                        /* light 6 */
  GL_LIGHT7,                        /* light 7 */
  GL_AMBIENT,                       /* ambient color */
  GL_DIFFUSE,                       /* diffuse color */
  GL_SPECULAR,                      /* specular color */
  GL_POSITION,                      /* light position */
  GL_SPOT_EXPONENT,                 /* spot exponent */
  GL_SPOT_CUTOFF,                   /* spot light cutoff angle */
  GL_SPOT_DIRECTION,                /* spot light direction */
  GL_CONSTANT_ATTENUATION,          /* constant attenuation factor */
  GL_LINEAR_ATTENUATION,            /* linear attenuation factor */
  GL_QUADRATIC_ATTENUATION,         /* quadratic attenuation factor */
  GL_LIGHT_MODEL_LOCAL_VIEWER,      /* viewer at infinity or at [0,0,0,1] */
  GL_LIGHT_MODEL_TWO_SIDE,          /* handle front and back materials different */
  GL_LIGHT_MODEL_AMBIENT,           /* ambient color of scene */
  GL_EMISSION,                      /* emissive color */
  GL_SHININESS,                     /* specular reflection shininess */
  GL_AMBIENT_AND_DIFFUSE,           /* ambient and diffuse color */
  GL_MODELVIEW,                     /* modelview matrix mode */
  GL_PROJECTION,                    /* perspective matrix mode */
  GL_POINT,                         /* polygon rasterisation mode 'point' */
  GL_LINE,                          /* polygon rasterisation mode 'line' */
  GL_FILL,                          /* polygon rasterisation mode 'fill' */
  GL_RENDER,                        /* render primitives */
  GL_SELECT,                        /* determine selected primitives */
  GL_FEEDBACK,                      /* determine data, that would have been rendered */
  GL_FLAT,                          /* flat shading */
  GL_SMOOTH,                        /* gouraud shading */
  GL_S,                             /* TexGen s coordinate */
  GL_T,                             /* TexGen t coordinate */
  GL_R,                             /* TexGen r coordinate */
  GL_Q,                             /* TexGen q coordinate */
  GL_PACK_SWAP_BYTES,               /* swap bytes while packing image data */
  GL_PACK_LSB_FIRST,                /* swap bits while packing image data */
  GL_PACK_ROW_LENGTH,               /* image row length for packing */
  GL_PACK_SKIP_PIXELS,              /* image left offset for packing */
  GL_PACK_SKIP_ROWS,                /* image bottom offset for packing */
  GL_PACK_ALIGNMENT,                /* image packing row alignment */
  GL_UNPACK_SWAP_BYTES,             /* swap bytes while unpacking image data */
  GL_UNPACK_LSB_FIRST,              /* swap bits while unpacking image data */
  GL_UNPACK_ROW_LENGTH,             /* image row length for unpacking */
  GL_UNPACK_SKIP_PIXELS,            /* image left offset for unpacking */
  GL_UNPACK_SKIP_ROWS,              /* image bottom offset for unpacking */
  GL_UNPACK_ALIGNMENT,              /* image unpacking row alignment */
  GL_MAP_COLOR,                     /* color mapping via lookup tables */
  GL_MAP_STENCIL,                   /* stencil mapping vias lookup table */
  GL_INDEX_SHIFT,                   /* index shift for images */
  GL_INDEX_OFFSET,                  /* index offset for images */
  GL_RED_SCALE,                     /* red scale for images */
  GL_RED_BIAS,                      /* red bias for images */
  GL_GREEN_SCALE,                   /* green scale for images */
  GL_GREEN_BIAS,                    /* green bias for images */
  GL_BLUE_SCALE,                    /* blue scale for images */
  GL_BLUE_BIAS,                     /* blue bias for images */
  GL_ALPHA_SCALE,                   /* alpha scale for images */
  GL_ALPHA_BIAS,                    /* alpha bias for images */
  GL_DEPTH_SCALE,                   /* depth scale for images */
  GL_DEPTH_BIAS,                    /* depth bias for images */
  GL_ALPHA_TEST,                    /* not implemented */
  GL_AUTO_NORMAL,                   /* not implemented */
  GL_MODULATE,                      /* texture environment mode modulate */
  GL_DECAL,                         /* texture environment mode decal */
  GL_BLEND,                         /* texture environment mode blend */
  GL_LINE_SMOOTH,                   /* not implemented */
  GL_LINE_STIPPLE,                  /* not implemented */
  GL_LOGIC_OP,                      /* not implemented */
  GL_MAP1_COLOR4,                   /* not implemented */
  GL_MAP1_INDEX,                    /* not implemented */
  GL_MAP1_NORMAL,                   /* not implemented */
  GL_MAP1_TEXTURE_COORD_1,          /* not implemented */
  GL_MAP1_TEXTURE_COORD_2,          /* not implemented */
  GL_MAP1_TEXTURE_COORD_3,          /* not implemented */
  GL_MAP1_TEXTURE_COORD_4,          /* not implemented */
  GL_MAP1_VERTEX_3,                 /* not implemented */
  GL_MAP1_VERTEX_4,                 /* not implemented */
  GL_MAP2_COLOR4,                   /* not implemented */
  GL_MAP2_INDEX,                    /* not implemented */
  GL_MAP2_NORMAL,                   /* not implemented */
  GL_MAP2_TEXTURE_COORD_1,          /* not implemented */
  GL_MAP2_TEXTURE_COORD_2,          /* not implemented */
  GL_MAP2_TEXTURE_COORD_3,          /* not implemented */
  GL_MAP2_TEXTURE_COORD_4,          /* not implemented */
  GL_MAP2_VERTEX_3,                 /* not implemented */
  GL_MAP2_VERTEX_4,                 /* not implemented */
  GL_POINT_SMOOTH,                  /* not implemented */
  GL_POLYGON_SMOOTH,                /* not implemented */
  GL_POLYGON_STIPPLE,               /* not implemented */
  GL_SCISSOR_TEST,                  /* not implemented */
  GL_STENCIL_TEST,                  /* not implemented */
  GL_TEXTURE_1D,                    /* 1D texture mapping */
  GL_TEXTURE_2D,                    /* 2D texture mapping */
  GL_TEXTURE_GEN_Q,                 /* q-texture-coordinate generation */
  GL_TEXTURE_GEN_R,                 /* r-texture-coordinate generation */
  GL_TEXTURE_GEN_S,                 /* s-texture-coordinate generation */
  GL_TEXTURE_GEN_T,                 /* t-texture-coordinate generation */
  GL_ACCUM_ALPHA_BITS,              /* not implemented */
  GL_ACCUM_BLUE_BITS,               /* not implemented */
  GL_ACCUM_CLEAR_VALUE,             /* not implemented */
  GL_ACCUM_GREEN_BITS,              /* not implemented */
  GL_ACCUM_RED_BITS,                /* not implemented */
  GL_ALPHA_TEST_FUNC,               /* not implemented */
  GL_ALPHA_TEST_REF,                /* not implemented */
  GL_ATTRIB_STACK_DEPTH,            /* attribute stack depth */
  GL_BLEND_DST,                     /* not implemented */
  GL_BLEND_SRC,                     /* not implemented */
  GL_COLOR_WRITEMASK,               /* not implemented */
  GL_CURRENT_INDEX,                 /* not implemented */
  GL_CURRENT_RASTER_COLOR,          /* not implemented */
  GL_CURRENT_RASTER_INDEX,          /* not implemented */
  GL_CURRENT_RASTER_POSITION,       /* not implemented */
  GL_CURRENT_RASTER_TEXTURE_COORDS, /* not implemented */
  GL_CURRENT_RASTER_POSITION_VALID, /* not implemented */
  GL_CURRENT_TEXTURE_COORDS,        /* not implemented */
  GL_DEPTH_WRITEMASK,               /* not implemented */
  GL_INDEX_BITS,                    /* number of color index bits */
  GL_INDEX_CLEAR_VALUE,             /* not implemented */
  GL_INDEX_MODE,                    /* not implemented */
  GL_INDEX_WRITEMASK,               /* not implemented */
  GL_LINE_SMOOTH_HINT,              /* not implemented */
  GL_LINE_STIPPLE_PATTERN,          /* not implemented */
  GL_LINE_STIPPLE_REPEAT,           /* not implemented */
  GL_LINE_WIDTH,                    /* not implemented */
  GL_LINE_WIDTH_GRANULARITY,        /* not implemented */
  GL_LINE_WIDTH_RANGE,              /* not implemented */
  GL_LIST_BASE,                     /* not implemented */
  GL_LIST_INDEX,                    /* not implemented */
  GL_LIST_MODE,                     /* not implemented */
  GL_LOGIC_OP_MODE,                 /* not implemented */
  GL_MAP1_COLOR_4,                  /* not implemented */
  GL_MAP1_GRID_DOMAIN,              /* not implemented */
  GL_MAP1_GRID_SEGMENTS,            /* not implemented */
  GL_MAP2_COLOR_4,                  /* not implemented */
  GL_MAP2_GRID_DOMAIN,              /* not implemented */
  GL_MAP2_GRID_SEGMENTS,            /* not implemented */
  GL_MAX_ATTRIB_STACK_DEPTH,        /* not implemented */
  GL_MAX_EVAL_ORDER,                /* not implemented */
  GL_MAX_LIST_NESTING,              /* not implemented */
  GL_MAX_PIXEL_MAP_TABLE,           /* maximum mapping table size */
  GL_MAX_TEXTURE_SIZE,              /* maximum texture size */
  GL_MAX_TEXTURE_STACK_DEPTH,       /* maximum texture stack depth */
  GL_PIXEL_MAP_A_TO_A_SIZE,         /* alpha to alpha mapping table size */
  GL_PIXEL_MAP_B_TO_B_SIZE,         /* blue to blue mapping table size */
  GL_PIXEL_MAP_G_TO_G_SIZE,         /* green to green mapping table size */
  GL_PIXEL_MAP_I_TO_A_SIZE,         /* index to alpha mapping table size */
  GL_PIXEL_MAP_I_TO_B_SIZE,         /* index to blue mapping table size */
  GL_PIXEL_MAP_I_TO_G_SIZE,         /* index to green mapping table size */
  GL_PIXEL_MAP_I_TO_I_SIZE,         /* index to index mapping table size */
  GL_PIXEL_MAP_I_TO_R_SIZE,         /* index to red mapping table size */
  GL_PIXEL_MAP_R_TO_R_SIZE,         /* red to red mapping table size */
  GL_PIXEL_MAP_S_TO_S_SIZE,         /* stencil to stencil mapping table size */
  GL_PIXEL_MAP_A_TO_A,              /* alpha to alpha mapping table */
  GL_PIXEL_MAP_B_TO_B,              /* blue to blue mapping table */
  GL_PIXEL_MAP_G_TO_G,              /* green to green mapping table */
  GL_PIXEL_MAP_I_TO_A,              /* index to alpha mapping table */
  GL_PIXEL_MAP_I_TO_B,              /* index to blue mapping table */
  GL_PIXEL_MAP_I_TO_G,              /* index to green mapping table */
  GL_PIXEL_MAP_I_TO_I,              /* index to index mapping table */
  GL_PIXEL_MAP_I_TO_R,              /* index to red mapping table */
  GL_PIXEL_MAP_R_TO_R,              /* red to red mapping table */
  GL_PIXEL_MAP_S_TO_S,              /* stencil to stencil mapping table */
  GL_POINT_SIZE,                    /* not implemented */
  GL_POINT_SIZE_GRANULARITY,        /* not implemented */
  GL_POINT_SIZE_RANGE,              /* not implemented */
  GL_POINT_SMOOTH_HINT,             /* not implemented */
  GL_POLYGON_SMOOTH_HINT,           /* not implemented */
  GL_READ_BUFFER,                   /* not implemented */
  GL_RGBA_MODE,                     /* RGBA mode */
  GL_SCISSOR_BOX,                   /* not implemented */
  GL_STENCIL_BITS,                  /* not implemented */
  GL_STENCIL_CLEAR_VALUE,           /* not implemented */
  GL_STENCIL_FAIL,                  /* not implemented */
  GL_STENCIL_FUNC,                  /* not implemented */
  GL_STENCIL_PASS_DEPTH_FAIL,       /* not implemented */
  GL_STENCIL_PASS_DEPTH_PASS,       /* not implemented */
  GL_STENCIL_REF,                   /* not implemented */
  GL_STENCIL_VALUE_MASK,            /* not implemented */
  GL_STENCIL_WRITEMASK,             /* not implemented */
  GL_SUBPIXEL_BITS,                 /* not implemented */
  GL_TEXTURE_ENV,                   /* texture environment */
  GL_TEXTURE_ENV_COLOR,             /* texture environment color */
  GL_TEXTURE_ENV_MODE,              /* texture environment mode */
  GL_TEXTURE_MATRIX,                /* texture matrix */
  GL_TEXTURE_STACK_DEPTH,           /* texture matrix stack depth */
  GL_ZOOM_X,                        /* pixel zoom x-value for images */
  GL_ZOOM_Y,                        /* pixel zoom y-value for images */
  GL_COLOR_INDEXES,                 /* not implemented */
  GL_TEXTURE,                       /* not implemented */
  GL_UNSIGNED_BYTE,                 /* unsigned byte type */
  GL_BYTE,                          /* byte type */
  GL_BITMAP,                        /* single bits in unsigned byte type */
  GL_UNSIGNED_SHORT,                /* unsigned short type */
  GL_SHORT,                         /* short type */
  GL_UNSIGNED_INT,                  /* unsigned int type */
  GL_INT,                           /* int type */
  GL_FLOAT,                         /* float type */
  GL_COLOR_INDEX,                   /* color index image */
  GL_STENCIL_INDEX,                 /* stencil index image */
  GL_DEPTH_COMPONENT,               /* depth component image */
  GL_RED,                           /* red image */
  GL_GREEN,                         /* green image */
  GL_BLUE,                          /* blue image */
  GL_ALPHA,                         /* alpha image */
  GL_RGB,                           /* rgb image */
  GL_RGBA,                          /* rgba image */
  GL_LUMINANCE,                     /* luminance image */
  GL_LUMINANCE_ALPHA,               /* luminance alpha image */
  GL_LINEAR,                        /* fog mode linear */
  GL_EXP,                           /* fog mode exp    */
  GL_EXP2,                          /* fog mode exp2   */
  GL_EYE_LINEAR,                    /* eye linear texture generation mode */
  GL_OBJECT_LINEAR,                 /* object linear texture generation mode */
  GL_SPHERE_MAP,                    /* sphere map texture generation mode */
  GL_TEXTURE_GEN_MODE,              /* texture generation mode */
  GL_OBJECT_PLANE,                  /* object plane equation for texture generation */
  GL_EYE_PLANE,                     /* eye plane equation for texture generation */
  GL_TEXTURE_WRAP_S,                /* texture wrapping mode for s-coordinate */
  GL_TEXTURE_WRAP_T,                /* texture wrapping mode for t-coordinate */
  GL_TEXTURE_MIN_FILTER,            /* texture minification filter type */
  GL_TEXTURE_MAG_FILTER,            /* texture magnification filter type */
  GL_TEXTURE_BORDER_COLOR,          /* texture border color */
  GL_CLAMP,                         /* texture wrapping mode clamp */
  GL_REPEAT,                        /* texture wrapping mode repeat */
  GL_NEAREST,                       /* texture filter type nearest texel */
  GL_NEAREST_MIPMAP_NEAREST,        /* texture filter type nearest mipmap nearest texel */
  GL_NEAREST_MIPMAP_LINEAR,         /* texture filter type nearest mipmap linear texel */
  GL_LINEAR_MIPMAP_NEAREST,         /* texture filter type linear mipmap nearest texel */
  GL_LINEAR_MIPMAP_LINEAR,          /* texture filter type linear mipmap linear texel */
  GL_TEXTURE_WIDTH,                 /* texture image width */
  GL_TEXTURE_HEIGHT,                /* texture image height */
  GL_TEXTURE_COMPONENTS,            /* texture image component number */
  GL_TEXTURE_BORDER                 /* texture image border */
}                      GLenum;

typedef struct
{
	GLdouble	eyex;
	GLdouble	eyey;
	GLdouble	eyez;
	GLdouble	centerx;
	GLdouble	centery;
	GLdouble	centerz;
	GLdouble	upx;
	GLdouble	upy;
	GLdouble	upz;
} GLlookAt;

typedef struct
{
	GLdouble	objx;
	GLdouble	objy;
	GLdouble	objz;
	GLdouble	*winx;		/* x coordinate of resulting point */
	GLdouble	*winy;		/* y coordinate of resulting point */
	GLdouble	*winz;		/* z coordinate of resulting point */
} GLproject;

typedef struct
{
	GLdouble	winx;
	GLdouble	winy;
	GLdouble	winz;
	GLdouble	*objx;		/* x coordinate of resulting point */
	GLdouble	*objy;		/* y coordinate of resulting point */
	GLdouble	*objz;		/* z coordinate of resulting point */
} GLunProject;

typedef struct
{
	GLdouble	left;
	GLdouble	right;
	GLdouble	bottom;
	GLdouble	top;
	GLdouble	zNear;
	GLdouble	zFar;

} GLfrustum;


typedef struct
{
	GLdouble	left;
	GLdouble	right;
	GLdouble	bottom;
	GLdouble	top;
	GLdouble	zNear;
	GLdouble	zFar;

} GLortho;

typedef struct
{
	GLsizei		width;
	GLsizei		height;
	GLfloat		xorig;
	GLfloat		yorig;
	GLfloat		xmove;
	GLfloat		ymove;
	GLubyte	   *bitmap;
} GLbitmap;

#endif
