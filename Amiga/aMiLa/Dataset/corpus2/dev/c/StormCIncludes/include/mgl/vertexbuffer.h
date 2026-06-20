/*
 * $Id: vertexbuffer.h,v 1.2 2000/10/20 11:32:51 nobody Exp $
 *
 * $Date: 2000/10/20 11:32:51 $
 * $Revision: 1.2 $
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

#include <Warp3D/Warp3D.h>

struct MGLVertex_t {
	W3D_Vertex  v;
	GLfloat     q;
	GLubyte     outcode;
	GLboolean   inview;
	float bx,by,bz,bw;
	MGLNormal   Normal;
};

typedef struct MGLVertex_t MGLVertex;

enum {
	MGL_CLIP_NEGW   =   1<<0,
	MGL_CLIP_TOP    =   1<<1,
	MGL_CLIP_BOTTOM =   1<<2,
	MGL_CLIP_LEFT   =   1<<3,
	MGL_CLIP_RIGHT  =   1<<4,
	MGL_CLIP_FRONT  =   1<<5,
	MGL_CLIP_BACK   =   1<<6
};

#endif
