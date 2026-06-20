/*
 * $Id: hclip.c,v 1.1.1.1 2000/04/07 19:44:51 hfrieden Exp $
 *
 * $Date: 2000/04/07 19:44:51 $
 * $Revision: 1.1.1.1 $
 *
 * (C) 1999 by Hyperion
 * All rights reserved
 *
 * This file is part of the MiniGL library project
 * See the file Licence.txt for more details
 *
 */

static char rcsid[] = "$Id: hclip.c,v 1.1.1.1 2000/04/07 19:44:51 hfrieden Exp $";

#include "sysinc.h"
#include <math.h>

#include <stdio.h> //remove this

#define CLIP_EPS (1e-7)

#define DUMP_VERTEX(vert) \
 mykprintf("x:%6.3f y:%6.3f z:%6.3f w:%6.3f\nR:%6.3f G:%6.3f B:%6.3f A:%6.3f\nU:%6.3f V:%6.3f\noutcode=0x%X\n",\
		 (vert).bx, (vert).by, (vert).bz, (vert).bw,                                                                                      \
		 (vert).v.color.r, (vert).v.color.g, (vert).v.color.b, (vert).v.color.a,                                                          \
		 (vert).v.u, (vert).v.v, (vert).outcode)


#define LERP(t,a,b) \
	( (a) + (float)t * ( (b) - (a) ) )


#define x1 (a->bx)
#define y1 (a->by)
#define z1 (a->bz)
#define w1 (a->bw)

#define x2 (b->bx)
#define y2 (b->by)
#define z2 (b->bz)
#define w2 (b->bw)

#ifdef GLNDEBUG
#define DEBUG_CLIP(name,code) code
#else
#define DEBUG_CLIP(name,code) \
	mykprintf("%s: t=%f\n", #name, t);\
	DUMP_VERTEX(*a); \
	DUMP_VERTEX(*b); \
	code             \
	DUMP_VERTEX(*r);
#endif


//multitexturing with virtual units:(real unit0 + 1 virt)

/*
Units are managed so unit0 is always first in line.
Texture2D_State[1] is only set if there is any active units other than unit 0

If more than 1 hardware unit is present, the number of active virtual units should be reduced by 1. HW units should probably be implemented in a different manner.
*/


static void hc_ClipWZero(MGLVertex *a, MGLVertex *b, MGLVertex *r, GLenum shading)
{
	float w;
	ULONG outcode;


	float t = (CLIP_EPS-w1)/(w2-w1);
	r->bx = LERP(t,a->bx, b->bx);
	r->by = LERP(t,a->by, b->by);
	r->bz = LERP(t,a->bz, b->bz);
	r->bw = CLIP_EPS;
	if(shading == GL_SMOOTH)
	{
	r->v.color.a = LERP(t,a->v.color.a, b->v.color.a);
	r->v.color.r = LERP(t,a->v.color.r, b->v.color.r);
	r->v.color.g = LERP(t,a->v.color.g, b->v.color.g);
	r->v.color.b = LERP(t,a->v.color.b, b->v.color.b);
	}
	r->v.u = LERP(t,a->v.u, b->v.u);
	r->v.v = LERP(t,a->v.v, b->v.v);

	if(mini_CurrentContext->Texture2D_State[1])
	{
		r->tcoord.s = LERP(t,a->tcoord.s, b->tcoord.s);
		r->tcoord.t = LERP(t,a->tcoord.t, b->tcoord.t);
	}

	w = r->bw;
	outcode = 0;


	if (-w > r->bx)
	{
		outcode |= MGL_CLIP_LEFT;
	}
	else if (r->bx > w)
	{
		outcode |= MGL_CLIP_RIGHT;
	}

	if (-w > r->by)
	{
		outcode |= MGL_CLIP_BOTTOM;
	}
	else if (r->by > w)
	{
		outcode |= MGL_CLIP_TOP;
	}

	if (-w > r->bz)
	{
		outcode |= MGL_CLIP_BACK;
	}
	else if (r->bz > w)
	{
		outcode |= MGL_CLIP_FRONT;
	}

	r->outcode = outcode;

	if(mini_CurrentContext->CurrentTexQValid == GL_TRUE)
	{
	if (a->q == 1.0 && b->q == 1.0)
		r->q = 1.0;
	else
		r->q = CLIP_EPS;
	}
}

static void hc_ClipLeft(MGLVertex *a, MGLVertex *b, MGLVertex *r, GLenum shading)
{
	float w;
	ULONG outcode;
	

	float t = (w1+x1)/((w1+x1)-(w2+x2));
	r->by = LERP(t,a->by, b->by);
	r->bz = LERP(t,a->bz, b->bz);
	r->bw = LERP(t,a->bw, b->bw);
	r->bx = -r->bw;
	if(shading == GL_SMOOTH)
	{
	r->v.color.a = LERP(t,a->v.color.a, b->v.color.a);
	r->v.color.r = LERP(t,a->v.color.r, b->v.color.r);
	r->v.color.g = LERP(t,a->v.color.g, b->v.color.g);
	r->v.color.b = LERP(t,a->v.color.b, b->v.color.b);
	}
	r->v.u = LERP(t,a->v.u, b->v.u);
	r->v.v = LERP(t,a->v.v, b->v.v);

	if(mini_CurrentContext->Texture2D_State[1])
	{
		r->tcoord.s = LERP(t,a->tcoord.s, b->tcoord.s);
		r->tcoord.t = LERP(t,a->tcoord.t, b->tcoord.t);
	}

	w = r->bw;
	outcode = 0;

/*
	if (r->bw < CLIP_EPS )
	{
		outcode |= MGL_CLIP_NEGW;
	}
*/

	if (-w > r->by)
	{
		outcode |= MGL_CLIP_BOTTOM;
	}
	else if (r->by > w)
	{
		outcode |= MGL_CLIP_TOP;
	}

	if (-w > r->bz)
	{
		outcode |= MGL_CLIP_BACK;
	}
	else if (r->bz > w)
	{
		outcode |= MGL_CLIP_FRONT;
	}

	r->outcode = outcode;

	if(mini_CurrentContext->CurrentTexQValid == GL_TRUE)
	{
		r->q = LERP(t, a->q, b->q);
	}
}

static void hc_ClipRight(MGLVertex *a, MGLVertex *b, MGLVertex *r, GLenum shading)
{
	float w;
	ULONG outcode;
	

	float t = (w1-x1)/((w1-x1)-(w2-x2));
	r->by = LERP(t,a->by, b->by);
	r->bz = LERP(t,a->bz, b->bz);
	r->bw = LERP(t,a->bw, b->bw);
	r->bx = r->bw;
	if(shading == GL_SMOOTH)
	{
	r->v.color.a = LERP(t,a->v.color.a, b->v.color.a);
	r->v.color.r = LERP(t,a->v.color.r, b->v.color.r);
	r->v.color.g = LERP(t,a->v.color.g, b->v.color.g);
	r->v.color.b = LERP(t,a->v.color.b, b->v.color.b);
	}
	r->v.u = LERP(t,a->v.u, b->v.u);
	r->v.v = LERP(t,a->v.v, b->v.v);

	if(mini_CurrentContext->Texture2D_State[1])
	{
		r->tcoord.s = LERP(t,a->tcoord.s, b->tcoord.s);
		r->tcoord.t = LERP(t,a->tcoord.t, b->tcoord.t);
	}

	w = r->bw;
	outcode = 0;

/*
	if (r->bw < CLIP_EPS )
	{
		outcode |= MGL_CLIP_NEGW;
	}
*/

	if (-w > r->by)
	{
		outcode |= MGL_CLIP_BOTTOM;
	}
	else if (r->by > w)
	{
		outcode |= MGL_CLIP_TOP;
	}

	if (-w > r->bz)
	{
		outcode |= MGL_CLIP_BACK;
	}
	else if (r->bz > w)
	{
		outcode |= MGL_CLIP_FRONT;
	}

	r->outcode = outcode;

	if(mini_CurrentContext->CurrentTexQValid == GL_TRUE)
	{
		r->q = LERP(t, a->q, b->q);
	}
}

static void hc_ClipFront(MGLVertex *a, MGLVertex *b, MGLVertex *r, GLenum shading)
{
	float w;
	ULONG outcode;


	float t = (w1-z1)/((w1-z1)-(w2-z2));
	r->bx = LERP(t,a->bx, b->bx);
	r->by = LERP(t,a->by, b->by);
	r->bw = LERP(t,a->bw, b->bw);
	r->bz = r->bw;
	if(shading == GL_SMOOTH)
	{
	r->v.color.a = LERP(t,a->v.color.a, b->v.color.a);
	r->v.color.r = LERP(t,a->v.color.r, b->v.color.r);
	r->v.color.g = LERP(t,a->v.color.g, b->v.color.g);
	r->v.color.b = LERP(t,a->v.color.b, b->v.color.b);
	}
	r->v.u = LERP(t,a->v.u, b->v.u);
	r->v.v = LERP(t,a->v.v, b->v.v);

	if(mini_CurrentContext->Texture2D_State[1])
	{
		r->tcoord.s = LERP(t,a->tcoord.s, b->tcoord.s);
		r->tcoord.t = LERP(t,a->tcoord.t, b->tcoord.t);
	}

	w = r->bw;
	outcode = 0;

/*
	if (r->bw < CLIP_EPS )
	{
		outcode |= MGL_CLIP_NEGW;
	}

	if (-w > r->bx)
	{
		outcode |= MGL_CLIP_LEFT;
	}
	else if (r->bx > w)
	{
		outcode |= MGL_CLIP_RIGHT;
	}
*/
	if (-w > r->by)
	{
		outcode |= MGL_CLIP_BOTTOM;
	}
	else if (r->by > w)
	{
		outcode |= MGL_CLIP_TOP;
	}

	r->outcode = outcode;

	if(mini_CurrentContext->CurrentTexQValid == GL_TRUE)
	{
		r->q = LERP(t, a->q, b->q);
	}
}

static void hc_ClipBack(MGLVertex *a, MGLVertex *b, MGLVertex *r, GLenum shading)
{
	float w;
	ULONG outcode;


	float t = (w1+z1)/((w1+z1)-(w2+z2));
	r->bx = LERP(t,a->bx, b->bx);
	r->by = LERP(t,a->by, b->by);
	r->bw = LERP(t,a->bw, b->bw);
	r->bz = -r->bw;
	if(shading == GL_SMOOTH)
	{
	r->v.color.a = LERP(t,a->v.color.a, b->v.color.a);
	r->v.color.r = LERP(t,a->v.color.r, b->v.color.r);
	r->v.color.g = LERP(t,a->v.color.g, b->v.color.g);
	r->v.color.b = LERP(t,a->v.color.b, b->v.color.b);
	}
	r->v.u = LERP(t,a->v.u, b->v.u);
	r->v.v = LERP(t,a->v.v, b->v.v);

	if(mini_CurrentContext->Texture2D_State[1])
	{
		r->tcoord.s = LERP(t,a->tcoord.s, b->tcoord.s);
		r->tcoord.t = LERP(t,a->tcoord.t, b->tcoord.t);
	}

	w = r->bw;
	outcode = 0;

/*
	if (r->bw < CLIP_EPS )
	{
		outcode |= MGL_CLIP_NEGW;
	}

	if (-w > r->bx)
	{
		outcode |= MGL_CLIP_LEFT;
	}
	else if (r->bx > w)
	{
		outcode |= MGL_CLIP_RIGHT;
	}
*/
	if (-w > r->by)
	{
		outcode |= MGL_CLIP_BOTTOM;
	}
	else if (r->by > w)
	{
		outcode |= MGL_CLIP_TOP;
	}

	r->outcode = outcode;

	if(mini_CurrentContext->CurrentTexQValid == GL_TRUE)
	{
		r->q = LERP(t, a->q, b->q);
	}
}

static void hc_ClipTop(MGLVertex *a, MGLVertex *b, MGLVertex *r, GLenum shading)
{
	float w;
	ULONG outcode;


	float t = (w1-y1)/((w1-y1)-(w2-y2));
	r->bx = LERP(t,a->bx, b->bx);
	r->bz = LERP(t,a->bz, b->bz);
	r->bw = LERP(t,a->bw, b->bw);
	r->by = r->bw;
	if(shading == GL_SMOOTH)
	{
	r->v.color.a = LERP(t,a->v.color.a, b->v.color.a);
	r->v.color.r = LERP(t,a->v.color.r, b->v.color.r);
	r->v.color.g = LERP(t,a->v.color.g, b->v.color.g);
	r->v.color.b = LERP(t,a->v.color.b, b->v.color.b);
	}
	r->v.u = LERP(t,a->v.u, b->v.u);
	r->v.v = LERP(t,a->v.v, b->v.v);

	if(mini_CurrentContext->Texture2D_State[1])
	{
		r->tcoord.s = LERP(t,a->tcoord.s, b->tcoord.s);
		r->tcoord.t = LERP(t,a->tcoord.t, b->tcoord.t);
	}

/*
Surgeon: this is always the 2nd last routine called, so here is no need to recode since a top-code means that there can be no bottom-code - we can safely set the outcode of the clipped vert to 0
*/
#if 1
	r->outcode = 0;
#else
	w = r->bw;
	outcode = 0;

	if (r->bw < CLIP_EPS )
	{
		outcode |= MGL_CLIP_NEGW;
	}

	if (-w > r->bx)
	{
		outcode |= MGL_CLIP_LEFT;
	}
	else if (r->bx > w)
	{
		outcode |= MGL_CLIP_RIGHT;
	}

	if (-w > r->bz)
	{
		outcode |= MGL_CLIP_BACK;
	}
	else if (r->bz > w)
	{
		outcode |= MGL_CLIP_FRONT;
	}

	r->outcode = outcode;
#endif
	if(mini_CurrentContext->CurrentTexQValid == GL_TRUE)
	{
		r->q = LERP(t, a->q, b->q);
	}
}

static void hc_ClipBottom(MGLVertex *a, MGLVertex *b, MGLVertex *r, GLenum shading)
{
	float w;
	ULONG outcode;


	float t = (w1+y1)/((w1+y1)-(w2+y2));
	r->bx = LERP(t,a->bx, b->bx);
	r->bz = LERP(t,a->bz, b->bz);
	r->bw = LERP(t,a->bw, b->bw);
	r->by = -r->bw;
	if(shading == GL_SMOOTH)
	{
	r->v.color.a = LERP(t,a->v.color.a, b->v.color.a);
	r->v.color.r = LERP(t,a->v.color.r, b->v.color.r);
	r->v.color.g = LERP(t,a->v.color.g, b->v.color.g);
	r->v.color.b = LERP(t,a->v.color.b, b->v.color.b);
	}
	r->v.u = LERP(t,a->v.u, b->v.u);
	r->v.v = LERP(t,a->v.v, b->v.v);

	if(mini_CurrentContext->Texture2D_State[1])
	{
		r->tcoord.s = LERP(t,a->tcoord.s, b->tcoord.s);
		r->tcoord.t = LERP(t,a->tcoord.t, b->tcoord.t);
	}

/*
Surgeon: this is always the last routine called, so here is no need to recode - we can safely set the outcode of the clipped vert to 0
*/
#if 1
	r->outcode = 0;
#else
	w = r->bw;
	outcode = 0;

	if (r->bw < CLIP_EPS )
	{
		outcode |= MGL_CLIP_NEGW;
	}

	if (-w > r->bx)
	{
		outcode |= MGL_CLIP_LEFT;
	}
	else if (r->bx > w)
	{
		outcode |= MGL_CLIP_RIGHT;
	}

	if (-w > r->bz)
	{
		outcode |= MGL_CLIP_BACK;
	}
	else if (r->bz > w)
	{
		outcode |= MGL_CLIP_FRONT;
	}

	r->outcode = outcode;
#endif
	if(mini_CurrentContext->CurrentTexQValid == GL_TRUE)
	{
		r->q = LERP(t, a->q, b->q);
	}
}



#undef x1
#undef y1
#undef z1
#undef w1
#undef x2
#undef y2
#undef z2
#undef w2

GLboolean hc_DecideFrontface(GLcontext context, MGLVertex *a, MGLVertex *b, MGLVertex *c)
{
	GLboolean front;
	float a1,a2,b1,b2,r;
	float aw,bw,cw;

	aw = 1.0 / a->bw;
	bw = 1.0 / b->bw;
	cw = 1.0 / c->bw;

	a1 = a->bx*aw - b->bx*bw;
	a2 = a->by*aw - b->by*bw;
	b1 = c->bx*cw - b->bx*bw;
	b2 = c->by*cw - b->by*bw;

	#define EPSILON (1e-5)

#if 0

/*
Surgeon: BUGFIX
These expressions test the length of the triangle-sides in 3D space and is in essence a simple areatest - it should return GL_FALSE instead of GL_TRUE
*/

	if (fabs(a1) < EPSILON && fabs(a2) < EPSILON)
	{
		return GL_TRUE;
	}

	if (fabs(b1) < EPSILON && fabs(b2) < EPSILON)
	{
		return GL_TRUE;
	}
#else

#if 0
//this test catches less than 1 in 1000 triangles so we disable it anyway

	if (fabs(a1) < EPSILON && fabs(a2) < EPSILON)
	{
		return GL_FALSE;
	}

	if (fabs(b1) < EPSILON && fabs(b2) < EPSILON)
	{
		return GL_FALSE;
	}
#endif

#endif

	r  = a1*b2-a2*b1;

	if ((r < 0.0 && context->CurrentCullSign < 0) ||
		(r > 0.0 && context->CurrentCullSign > 0))
	{
		return GL_FALSE;
	}
	else
	{
		return GL_TRUE;
	}
}


void GLFrontFace(GLcontext context, GLenum mode)
{
	int facing;
	GLint sign;

	if (mode == GL_CW || mode == GL_CCW)
	{
	   context->CurrentFrontFace = mode;

	//Surgeon -->

	   facing = (int)context->CurrentCullFace;

	   switch(facing)
	   {
		case GL_BACK:
			sign = 1;
			break;
		case GL_FRONT:
			sign = -1;
			break;
		default:
			sign = 0;
			break;
	   }
	
	   if(mode == GL_CW)
	   {
		sign = -sign;
	   }

	   context->CurrentCullSign = sign;

	//Surgeon <--

	}
	else
	{
		GLFlagError(context, 1, GL_INVALID_ENUM);
	}
}

void GLCullFace(GLcontext context, GLenum mode)
{
	GLint sign;

	if (mode == GL_FRONT || mode == GL_FRONT_AND_BACK || mode == GL_BACK)
	{
	context->CurrentCullFace = mode;

	//Surgeon -->

	   switch ((int)mode)
	   {
		case GL_BACK:
			sign = 1;
			break;
		case GL_FRONT:
			sign = -1;
			break;
		default:
			sign = 0;
			break;
	   }

	   if(context->CurrentFrontFace == GL_CW)
	   {
		sign = -sign;
	   }

	context->CurrentCullSign = sign;

	//Surgeon <--
	}
	else
	{
		GLFlagError(context, 1, GL_INVALID_ENUM);
	}
}

/*
** Complicated clipping macro stuff.
*/

#define VERTP(i) &(context->VertexBuffer[a->verts[i]])
#define VERT(i) ( context->VertexBuffer[a->verts[i]] )

#define OLD_POLYSWAP \
	if (b->numverts == 0) return; \
	temp=a; a=b; b=temp; \

#define POLYSWAP \
	if (b->numverts == 0) {out->numverts = 0;return;} \
	temp=a; a=b; b=temp; \

#define OLD_DOCLIP(edge, routine)                                           \
	if (or_codes & edge)                                                 \
	{                                                                     \
		b->numverts = 0;                                                   \
		prev = a->numverts-1;                                               \
	i=0;    do                 \
		{                                                                     \
			/* Case 1 and 4*/                                                  \
			if (!(VERT(prev).outcode & edge))                                   \
			{                                                                    \
				b->verts[b->numverts] = a->verts[prev];                           \
				b->numverts++;                                                     \
			}                                                                       \
			/* Case 3 and 4 */                                                       \
			if ((VERT(prev).outcode ^ VERT(i).outcode) & edge)                        \
			{                                                                          \
				hc_##routine (VERTP(prev), VERTP(i), &(context->VertexBuffer[free]), (const GLenum)context->ShadeModel);   \
				b->verts[b->numverts]=free++;                                            \
				b->numverts++;                                                            \
			}                                                                              \
			prev = i;                                                                       \
		} while (++i < a->numverts); \
		OLD_POLYSWAP                 \
	}                                                      

#define DOCLIP(edge, routine)                                           \
	if (or_codes & edge)                                                 \
	{                                                                     \
		b->numverts = 0;                                                   \
		prev = a->numverts-1;                                               \
	i=0; do	{                                                                          \
			/* Case 1 and 4*/                                                  \
			if (!(VERT(prev).outcode & edge))                                   \
			{                                                                    \
				b->verts[b->numverts] = a->verts[prev];                           \
				b->numverts++;                                                     \
			}                                                                       \
			/* Case 3 and 4 */                                                       \
			if ((VERT(prev).outcode ^ VERT(i).outcode) & edge)                        \
			{                                                                                  \
				hc_##routine (VERTP(prev), VERTP(i), &(context->VertexBuffer[free]), (const GLenum)context->ShadeModel);                \
				b->verts[b->numverts]=free++;                                              \
				b->numverts++;                                                             \
			}                     \
			prev = i;             \
		}  while (++i < a->numverts); \
		POLYSWAP                      \
	}                                                      

#ifndef GLNDEBUG
void hc_DumpPolygon(GLcontext context, MGLPolygon *poly, char *string, int clipcode)
{
	int i;
	mykprintf("--- %s (0x%X) -- (%d vertices)\n", string,clipcode, poly->numverts);
	for (i=0; i<poly->numverts; i++)
	{
		DUMP_VERTEX(context->VertexBuffer[poly->verts[i]]);
	}
	mykprintf("-------------------------\n");
}

#define CLIPDBG(string,code) \
	hc_DumpPolygon(context,a,#string,code);

#else

#define CLIPDBG(string,code)

#endif


void hc_ClipAndDrawPoly(GLcontext context, MGLPolygon *poly, ULONG or_codes)
{
	/*
	** Sutherland-Hodgeman clipping algorithm (almost)
	**
	** This clipping algorithm sucessively clips against each of the six
	** clipping planes (additional client-defined clipping planes would
	** be possible, those would be added to the back of this).
	** Vertices are copied from a to b and swapped at the end.
	** Output occurs within the clipping region:
	**
	**                | b
	**               i|/|
	**               /| |
	**              / | |c
	**            a/  |/
	**             | /|j
	**             |/ |
	**            d/  |
	**                |clip plane
	**
	** In the above figure, the algorithm first consideres edge d-a. Since it
	** does not cross the clipping plane, it outputs d and proceeds to edge
	** a-b. Since it crosses, it outputs a, calculates intersection i and outputs it.
	** No output occurs while b-c is considered, since it lies outside the frustum
	** and does not cross it. Finally, edge c-d yields output j.
	**
	** The result is d-a-i-j
	**
	** Classification of edges are divided into four cases:
	** Case 1: Edge is completely inside -> two vertices
	** Case 2: Edge is completely outside -> no output
	** Case 3: Edge enters the frustum -> one output
	** Case 4: Edge leaves frustum -> two outputs
	**
	** At any stage, if the output polygon has zero vertices, return immediately.
	*/

	MGLPolygon output;
	MGLPolygon *a, *b, *temp;
	int i,j;
	int prev;
	int free = context->VertexBufferPointer;
	GLboolean flag;
	ULONG original_or_codes = or_codes;

	a = poly; b=&output;

	CLIPDBG(ClipWZero, MGL_CLIP_NEGW)
	OLD_DOCLIP(MGL_CLIP_NEGW, ClipWZero);

// Surgeon: conditioned by macro execution
      if(or_codes & MGL_CLIP_NEGW)
	{
	j = 0;
	or_codes = 0;
		do
		{
		or_codes |= context->VertexBuffer[a->verts[j]].outcode;
		j++;
		} while (j < a->numverts);
	}

	CLIPDBG(ClipLeft, MGL_CLIP_LEFT)
	OLD_DOCLIP(MGL_CLIP_LEFT, ClipLeft)

	CLIPDBG(ClipRight, MGL_CLIP_RIGHT)
	OLD_DOCLIP(MGL_CLIP_RIGHT, ClipRight)

	CLIPDBG(ClipFront, MGL_CLIP_FRONT)
	OLD_DOCLIP(MGL_CLIP_FRONT, ClipFront)

	CLIPDBG(ClipBack, MGL_CLIP_BACK)
	OLD_DOCLIP(MGL_CLIP_BACK, ClipBack)

	CLIPDBG(ClipTop, MGL_CLIP_TOP)
	OLD_DOCLIP(MGL_CLIP_TOP, ClipTop)

	CLIPDBG(ClipBottom, MGL_CLIP_BOTTOM)
	OLD_DOCLIP(MGL_CLIP_BOTTOM, ClipBottom)

	CLIPDBG(Final,0)

	// If we get here, there are vertices left...
	dh_DrawPoly(context, a);
}


void hc_ClipAndDrawLine(GLcontext context, MGLPolygon *poly, ULONG or_codes)
{
    MGLPolygon output;
    MGLPolygon *a, *b, *temp;
    int i,j;
    int prev;
    int free = context->VertexBufferPointer;
    GLboolean flag;
    ULONG original_or_codes = or_codes;

    a = poly; b=&output;

    OLD_DOCLIP(MGL_CLIP_NEGW, ClipWZero);

// Surgeon: conditioned by macro execution
      if(or_codes & MGL_CLIP_NEGW)
	{
	j = 0;
	or_codes = 0;
		do
		{
		or_codes |= context->VertexBuffer[a->verts[j]].outcode;
		j++;
		} while (j < a->numverts);
	}

    OLD_DOCLIP(MGL_CLIP_LEFT, ClipLeft)
    OLD_DOCLIP(MGL_CLIP_RIGHT, ClipRight)
    OLD_DOCLIP(MGL_CLIP_FRONT, ClipFront)
    OLD_DOCLIP(MGL_CLIP_BACK, ClipBack)
    OLD_DOCLIP(MGL_CLIP_TOP, ClipTop)
    OLD_DOCLIP(MGL_CLIP_BOTTOM, ClipBottom)

    dh_DrawLine(context,a);
}


//buffering: 
 
void hc_ClipPoly(GLcontext context, MGLPolygon *poly, PolyBuffer *out, int clipstart, ULONG or_codes)
{
	MGLPolygon output;
	MGLPolygon *a, *b, *temp;
	int i,j;
	int prev;
	int free = clipstart;
	ULONG original_or_codes = or_codes;

	a = poly; b=&output;

	CLIPDBG(ClipWZero, MGL_CLIP_NEGW)
	DOCLIP(MGL_CLIP_NEGW, ClipWZero);

// Surgeon: conditioned by macro execution
      if(or_codes & MGL_CLIP_NEGW)
	{
	j = 0;
	or_codes = 0;
		do
		{
		or_codes |= context->VertexBuffer[a->verts[j]].outcode;
		j++;
		} while (j < a->numverts);
	}

	CLIPDBG(ClipLeft, MGL_CLIP_LEFT)
	DOCLIP(MGL_CLIP_LEFT, ClipLeft)

	CLIPDBG(ClipRight, MGL_CLIP_RIGHT)
	DOCLIP(MGL_CLIP_RIGHT, ClipRight)

	CLIPDBG(ClipFront, MGL_CLIP_FRONT)
	DOCLIP(MGL_CLIP_FRONT, ClipFront)

	CLIPDBG(ClipBack, MGL_CLIP_BACK)
	DOCLIP(MGL_CLIP_BACK, ClipBack)

	CLIPDBG(ClipTop, MGL_CLIP_TOP)
	DOCLIP(MGL_CLIP_TOP, ClipTop)

	CLIPDBG(ClipBottom, MGL_CLIP_BOTTOM)
	DOCLIP(MGL_CLIP_BOTTOM, ClipBottom)

	CLIPDBG(Final,0)


//write buffer index
	for(j=0; j<a->numverts; j++)
		out->verts[j] = a->verts[j];

	out->numverts = a->numverts;
	out->nextfree = free;
}


void hc_ClipPolyFF(GLcontext context, MGLPolygon *poly, ULONG or_codes)
{
	MGLPolygon *out;
	MGLPolygon output;
	MGLPolygon *a, *b, *temp;
	int i,j;
	int prev;
	int free = context->VertexBufferPointer;

	a = poly; b=&output;
	out = poly;

	CLIPDBG(ClipWZero, MGL_CLIP_NEGW)
	DOCLIP(MGL_CLIP_NEGW, ClipWZero);

// Surgeon: conditioned by macro execution
      if(or_codes & MGL_CLIP_NEGW)
	{
	j = 0;
	or_codes = 0;
		do
		{
		or_codes |= context->VertexBuffer[a->verts[j]].outcode;
		j++;
		} while (j < a->numverts);
	}

	CLIPDBG(ClipLeft, MGL_CLIP_LEFT)
	DOCLIP(MGL_CLIP_LEFT, ClipLeft)

	CLIPDBG(ClipRight, MGL_CLIP_RIGHT)
	DOCLIP(MGL_CLIP_RIGHT, ClipRight)

	CLIPDBG(ClipFront, MGL_CLIP_FRONT)
	DOCLIP(MGL_CLIP_FRONT, ClipFront)

	CLIPDBG(ClipBack, MGL_CLIP_BACK)
	DOCLIP(MGL_CLIP_BACK, ClipBack)

	CLIPDBG(ClipTop, MGL_CLIP_TOP)
	DOCLIP(MGL_CLIP_TOP, ClipTop)

	CLIPDBG(ClipBottom, MGL_CLIP_BOTTOM)
	DOCLIP(MGL_CLIP_BOTTOM, ClipBottom)

	CLIPDBG(Final,0)

//write buffer index
	for(j=0; j<a->numverts; j++)
		poly->verts[j] = a->verts[j];

	poly->numverts = a->numverts;
}



