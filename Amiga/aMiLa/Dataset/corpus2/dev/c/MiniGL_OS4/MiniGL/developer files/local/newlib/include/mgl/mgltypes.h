/*
 * $Id: mgltypes.h 184 2005-10-26 12:09:08Z tfrieden $
 *
 * $Date: 2005-10-26 07:09:08 -0359ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ $
 * $Revision: 184 $
 *
 * (C) 1999 by Hyperion
 * All rights reserved
 *
 * This file is part of the MiniGL library project
 * See the file Licence.txt for more details
 *
 */

#ifndef MGLTYPES_H_
#define MGLTYPES_H_

#ifdef __cplusplus
extern "C"
{
#endif


#include "mgl/config.h"
#include "mgl/log.h"
#include <warp3d/warp3d.h>

/* MiniGL internal types */

typedef struct GLcontext_t * GLcontext;

struct GLcontext_t;

struct GLarray_t;

typedef void (*ArrayFetcherFn)(GLcontext, struct GLarray_t *, GLvoid *, GLuint unit);
typedef void (*ArrayFetcherIdxFn)(GLcontext, struct GLarray_t *, GLuint, GLuint unit);

typedef struct GLarray_t
{
	/*
	** Vertex array
	*/

	GLint       size;           /* Number of elements per entry (mostly 3 or 4) */
	GLenum      type;           /* Data type of entries */
	GLsizei     stride;         /* How to reach the next array element */
	GLvoid*     pointer;        /* Pointer to the actual data */
	ArrayFetcherFn fetch;		/* Function to fetch sequentially */
	ArrayFetcherIdxFn fetchIdx; /* Function fo fetch indexed */
	ArrayFetcherIdxFn fetchElement; /* For ArrayElement, sets via current state */
} GLarray;

typedef void (*DrawElementsFn)(GLcontext context, GLenum mode, GLsizei count, GLenum type, const GLvoid *indices);
typedef void (*DrawArraysFn)(GLcontext context, GLenum mode, GLint first, GLsizei count);

typedef struct MGLTexture_t
{
	W3D_Texture *texObj;		/* Warp3D texture object */
	void *texData;				/* Raw texture data */
	GLuint internalFormat;		/* Internal format */
	GLuint bytesPerTexel;		/* Bytes per texel for normal textures, bytes
								 * per 4x4 texel block for S3TC textures */
	GLubyte *mipmaps[20];		/* Mipmap array */
} MGLTexture;

typedef struct MGLColor_t
{
	GLfloat r,g,b,a;
} MGLColor;

#define MGL_SET_COLOR(c, _r, _g, _b, _a)\
	c.r = _r;							\
	c.g = _g;							\
	c.b = _b;							\
	c.a = _a;

typedef struct MGLPosition_t
{
	GLfloat x, y, z, w;
} MGLPosition;

typedef struct MGLDirection_t
{
	GLfloat x, y, z;
} MGLDirection;

typedef struct MGLNormal_t
{
	GLfloat x,y,z;
} MGLNormal;

/*
** This structure holds the polygon data for clipping.
*/
typedef struct MGLPolygon_t
{
	int numverts;
	int verts[MGL_MAXVERTS];
	GLfloat zoffset;
} MGLPolygon;


#define MAT_UPDATE_AMBIENT	(1L << 0)
#define MAT_UPDATE_DIFFUSE	(1L << 1)
#define MAT_UPDATE_SPECULAR	(1L << 2)

typedef struct GLmaterial_t
{
	GLuint 		Index;
	/* -- Normal material properties -- */
	MGLColor	Ambient;
	MGLColor	Diffuse;
	MGLColor	Specular;
	MGLColor	Emission;
	GLfloat		Shininess;
	/* -- Precomputed stuff -- */
	MGLColor		Acm_Acs;				/* Ambient material by ambient global */
	/* -- Used to track ColorMaterial state */
	MGLColor 	*ColorMaterial[2];
	GLuint		Update;
} GLmaterial;



typedef struct GLlight_t
{
	GLuint			Number;
	/* -- Normal light properties -- */
	MGLColor		Ambient;
	MGLColor		Diffuse;
	MGLColor		Specular;
	MGLPosition		Position;
	MGLDirection 	SpotDirection;
	GLfloat			SpotExponent;
	GLfloat			SpotCutoff;
	GLfloat			ConstantAttenuation;
	GLfloat			LinearAttenuation;
	GLfloat			QuadraticAttenuation;
	/* -- Precomputed stuff -- */
	MGLColor		Acm_by_Acli[2];		/* Ambient material by ambient light */
	MGLColor		Dcm_by_Dcli[2];		/* Diffuse material by diffuse light */
	MGLColor		Scm_by_Scli[2];		/* Specular material by specular light */
	GLfloat			OneOverConstantAttenuation;	
} GLlight;


/* A client-defined clip plane */
typedef struct GLclipplane_t
{
	GLuint			number;				/* Number of clipplane */
	GLdouble 		eqn[4];				/* Plane equation coefficients */
	GLuint			outcode;			/* One of MGL_CLIP_USERn */
} GLclipplane;

/* Used for texture coordinate generation */
typedef struct GLtexgen_t
{
	GLenum		mode;					/* OBJECT_LINEAR, EYE_LINEAR, ... */
	GLfloat 	objectPlane[4];			/* Object plane equation */
	GLfloat		eyePlane[4];			/* Eye plane equation */
	GLboolean	needR;					/* Set during enable to indicate the
										   need for the R vector */
	GLboolean	needM;					/* Set during enable to indicate the 
										   need for the m value */
} GLtexgen;

/* The following is used to unpack textures from client space to Warp3D */

typedef void (*write_func)(GLubyte *from, GLubyte *to, GLsizei num, GLsizei stride);
typedef void (*unpack_func)(void *context, GLubyte *from, GLubyte *to, GLsizei num);

struct FormatTypeToUnpack
{
	GLenum format;
	GLenum type;
	unpack_func unpack;
	GLsizei stride;
};

struct InternalToW3D
{
	GLenum internalformat;
	uint32 w3dFormat;
	uint32 w3dBpp;
	write_func write;
};

#ifdef __cplusplus
}
#endif

#endif
