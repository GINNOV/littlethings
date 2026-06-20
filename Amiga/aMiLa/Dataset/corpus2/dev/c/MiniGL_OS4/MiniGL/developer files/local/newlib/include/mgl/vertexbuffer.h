/*
 * $Id: vertexbuffer.h 177 2005-10-20 14:23:30Z tfrieden $
 *
 * $Date: 2005-10-20 09:23:30 -0359ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ $
 * $Revision: 177 $
 *
 * (C) 1999 by Hyperion
 * All rights reserved
 *
 * This file is part of the MiniGL library project
 * See the file Licence.txt for more details
 *
 */

#ifndef __VERTEXBUFFER_H
#define __VERTEXBUFFER_H

#include <warp3D/warp3D.h>
#include <mgl/config.h>
#include <mgl/mgltypes.h>

/* New vertex structure for W3D_InterleavedArray */

struct MGLTexCoordSet_t
{
	GLfloat u, v, w;
};

struct MGLVertex_t
{
	/* --- Projected part --- */
	GLfloat x, y, z;				/* Vertex position */
	GLfloat fogdepth;				/* Fog coordinate */
	GLfloat r, g, b, a;				/* Primary color */
	GLfloat sr, sg, sb, sa;			/* Secondary color */
	struct MGLTexCoordSet_t
			uvw[MAX_TEXTURE_UNITS];	/* Texure coordinate sets for all texture
									   units */
	/* -- Management part --- */
	GLboolean	rhw_valid[MAX_TEXTURE_UNITS];
	GLuint     outcode;
	GLfloat		dist[MAX_CLIPPLANES];
	GLboolean   inview;
GLubyte align[2]; // FIXME: Remove
	MGLPosition clip;
	MGLPosition object;
	MGLPosition eye;				/* Eye coordinates, used for texture gen
									   and light */
	MGLNormal	EyeNormal;			/* Normal, projected to eye coordinates */
	float bf;
	MGLNormal   Normal;
	GLuint frame_code;				/* Used to check for validity of transformed
									   coordinates */
	GLuint tex_frame_code;			/* Like frame_code, for texture coordinates */
};

typedef struct MGLVertex_t MGLVertex;

enum {
	MGL_CLIP_NEGW   =   1<<0,
	MGL_CLIP_TOP    =   1<<1,
	MGL_CLIP_BOTTOM =   1<<2,
	MGL_CLIP_LEFT   =   1<<3,
	MGL_CLIP_RIGHT  =   1<<4,
	MGL_CLIP_FRONT  =   1<<5,
	MGL_CLIP_BACK   =   1<<6,
	MGL_CLIP_USER0	=	1<<7,
	MGL_CLIP_USER1	=	1<<8,
	MGL_CLIP_USER2	=	1<<9,
	MGL_CLIP_USER3	=	1<<10,
	MGL_CLIP_USER4	=	1<<11,
	MGL_CLIP_USER5	=	1<<12,
	MGL_CLIP_USER6	=	1<<13,
	MGL_CLIP_USER7	=	1<<14,	
};

#define MGL_CLIP_USER_MASK 	\
	( 						\
	  MGL_CLIP_USER1		\
	| MGL_CLIP_USER2		\
	| MGL_CLIP_USER3		\
	| MGL_CLIP_USER4		\
	| MGL_CLIP_USER5		\
	| MGL_CLIP_USER6		\
	| MGL_CLIP_USER7		\
	)


#endif
