/*
 * $Id: aclip.c,v 1.1.1.1 2000/04/07 19:44:51 hfrieden Exp $
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

static char rcsid[] = "$Id: aclip.c,v 1.1.1.1 2000/04/07 19:44:51 hfrieden Exp $";

#include "sysinc.h"
#include "vertexarray.h"
#include <math.h>


#define LERP(t,a,b) \
	( (a) + (float)t * ( (b) - (a) ) )


#define CLIP_EPS (1e-7)

#define x1 (a->bx)
#define y1 (a->by)
#define z1 (a->bz)
#define w1 (a->bw)

#define x2 (b->bx)
#define y2 (b->by)
#define z2 (b->bz)
#define w2 (b->bw)


#if 0 //set a pointer to one of these

static void LerpRGBA(MGLVertex *a, MGLVertex *b, MGLVertex *r, float t)
{
	r->v.color.r = LERP(t,a->v.color.r, b->v.color.r);
	r->v.color.g = LERP(t,a->v.color.g, b->v.color.g);
	r->v.color.b = LERP(t,a->v.color.b, b->v.color.b);
	r->v.color.a = LERP(t,a->v.color.a, b->v.color.a);

	r->v.u = LERP(t,a->v.u, b->v.u);
	r->v.v = LERP(t,a->v.v, b->v.v);
}

static void LerpRGB(MGLVertex *a, MGLVertex *b, MGLVertex *r, float t)
{
	r->v.color.r = LERP(t,a->v.color.r, b->v.color.r);
	r->v.color.g = LERP(t,a->v.color.g, b->v.color.g);
	r->v.color.b = LERP(t,a->v.color.b, b->v.color.b);
	r->v.color.a = 1.f;

	r->v.u = LERP(t,a->v.u, b->v.u);
	r->v.v = LERP(t,a->v.v, b->v.v);
}

static void LerpFlat(MGLVertex *a, MGLVertex *b, MGLVertex *r, float t)
{
	r->v.u = LERP(t,a->v.u, b->v.u);
	r->v.v = LERP(t,a->v.v, b->v.v);
}

typedef void (*TCLerpfn)(MGLVertex *, MGLVertex *, MGLVertex *, float);

TCLerpfn TCLerp = (TCLerpfn)LerpFlat;

#endif

static void A_ClipWZero(MGLVertex *a, MGLVertex *b, MGLVertex *r)
{
	ULONG outcode;
	
	float t = (CLIP_EPS-w1)/(w2-w1);

	r->v.color.r = LERP(t,a->v.color.r, b->v.color.r);
	r->v.color.g = LERP(t,a->v.color.g, b->v.color.g);
	r->v.color.b = LERP(t,a->v.color.b, b->v.color.b);
	r->v.color.a = LERP(t,a->v.color.a, b->v.color.a);

	r->v.u = LERP(t,a->v.u, b->v.u);
	r->v.v = LERP(t,a->v.v, b->v.v);

	r->bx = LERP(t,a->bx, b->bx);
	r->by = LERP(t,a->by, b->by);
	r->bz = LERP(t,a->bz, b->bz);
	r->bw = CLIP_EPS;

	outcode = 0;

	if (-CLIP_EPS > r->bx)
	{
		outcode = MGL_CLIP_LEFT;
	}
	else if (r->bx > CLIP_EPS)
	{
		outcode = MGL_CLIP_RIGHT;
	}

	if (-CLIP_EPS > r->by)
	{
		outcode |= MGL_CLIP_BOTTOM;
	}
	else if (r->by > CLIP_EPS)
	{
		outcode |= MGL_CLIP_TOP;
	}

	if (-CLIP_EPS > r->bz)
	{
		outcode |= MGL_CLIP_BACK;
	}
	else if (r->bz > CLIP_EPS)
	{
		outcode |= MGL_CLIP_FRONT;
	}

	r->outcode = outcode;
}

static void A_ClipTop(MGLVertex *a, MGLVertex *b, MGLVertex *r)
{
	float t = (w1-y1)/((w1-y1)-(w2-y2));

	r->v.color.r = LERP(t,a->v.color.r, b->v.color.r);
	r->v.color.g = LERP(t,a->v.color.g, b->v.color.g);
	r->v.color.b = LERP(t,a->v.color.b, b->v.color.b);
	r->v.color.a = LERP(t,a->v.color.a, b->v.color.a);

	r->v.u = LERP(t,a->v.u, b->v.u);
	r->v.v = LERP(t,a->v.v, b->v.v);

	r->bx = LERP(t,a->bx, b->bx);
	r->bz = LERP(t,a->bz, b->bz);
	r->bw = LERP(t,a->bw, b->bw);
	r->by = r->bw;

/*
Surgeon: this is always the 2nd last routine called, so here is no need to recode since a top-code means that there can be no bottom-code - we can safely set the outcode of the clipped vert to 0
*/
	r->outcode = 0;
}

static void A_ClipBottom(MGLVertex *a, MGLVertex *b, MGLVertex *r)
{
	float t = (w1+y1)/((w1+y1)-(w2+y2));

	r->v.color.r = LERP(t,a->v.color.r, b->v.color.r);
	r->v.color.g = LERP(t,a->v.color.g, b->v.color.g);
	r->v.color.b = LERP(t,a->v.color.b, b->v.color.b);
	r->v.color.a = LERP(t,a->v.color.a, b->v.color.a);

	r->v.u = LERP(t,a->v.u, b->v.u);
	r->v.v = LERP(t,a->v.v, b->v.v);

	r->bx = LERP(t,a->bx, b->bx);
	r->bz = LERP(t,a->bz, b->bz);
	r->bw = LERP(t,a->bw, b->bw);
	r->by = -r->bw;

/*
Surgeon: this is always the last routine called, so here is no need to recode - we can safely set the outcode of the clipped vert to 0
*/

	r->outcode = 0;
}

static void A_ClipLeft(MGLVertex *a, MGLVertex *b, MGLVertex *r)
{
	float w;
	ULONG outcode;

	float t = (w1+x1)/((w1+x1)-(w2+x2));

	r->v.color.r = LERP(t,a->v.color.r, b->v.color.r);
	r->v.color.g = LERP(t,a->v.color.g, b->v.color.g);
	r->v.color.b = LERP(t,a->v.color.b, b->v.color.b);
	r->v.color.a = LERP(t,a->v.color.a, b->v.color.a);

	r->v.u = LERP(t,a->v.u, b->v.u);
	r->v.v = LERP(t,a->v.v, b->v.v);

	r->by = LERP(t,a->by, b->by);
	r->bz = LERP(t,a->bz, b->bz);
	r->bw = LERP(t,a->bw, b->bw);
	r->bx = -r->bw;

	w = r->bw;
	outcode = 0;

	if (-w > r->by)
	{
		outcode = MGL_CLIP_BOTTOM;
	}
	else if (r->by > w)
	{
		outcode = MGL_CLIP_TOP;
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
}

static void A_ClipRight(MGLVertex *a, MGLVertex *b, MGLVertex *r)
{
	float w;
	ULONG outcode;

	float t = (w1-x1)/((w1-x1)-(w2-x2));

	r->v.color.r = LERP(t,a->v.color.r, b->v.color.r);
	r->v.color.g = LERP(t,a->v.color.g, b->v.color.g);
	r->v.color.b = LERP(t,a->v.color.b, b->v.color.b);
	r->v.color.a = LERP(t,a->v.color.a, b->v.color.a);

	r->v.u = LERP(t,a->v.u, b->v.u);
	r->v.v = LERP(t,a->v.v, b->v.v);

	r->by = LERP(t,a->by, b->by);
	r->bz = LERP(t,a->bz, b->bz);
	r->bw = LERP(t,a->bw, b->bw);
	r->bx = r->bw;

	w = r->bw;
	outcode = 0;

	if (-w > r->by)
	{
		outcode = MGL_CLIP_BOTTOM;
	}
	else if (r->by > w)
	{
		outcode = MGL_CLIP_TOP;
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
}

static void A_ClipFront(MGLVertex *a, MGLVertex *b, MGLVertex *r)
{
	float w;

	float t = (w1-z1)/((w1-z1)-(w2-z2));

	r->v.color.r = LERP(t,a->v.color.r, b->v.color.r);
	r->v.color.g = LERP(t,a->v.color.g, b->v.color.g);
	r->v.color.b = LERP(t,a->v.color.b, b->v.color.b);
	r->v.color.a = LERP(t,a->v.color.a, b->v.color.a);

	r->v.u = LERP(t,a->v.u, b->v.u);
	r->v.v = LERP(t,a->v.v, b->v.v);

	r->bx = LERP(t,a->bx, b->bx);
	r->by = LERP(t,a->by, b->by);
	r->bw = LERP(t,a->bw, b->bw);
	r->bz = r->bw;

	w = r->bw;

	if (-w > r->by)
	{
		r->outcode = MGL_CLIP_BOTTOM;
	}
	else if (r->by > w)
	{
		r->outcode = MGL_CLIP_TOP;
	}
	else
	{
		r->outcode = 0;
	}
}

static void A_ClipBack(MGLVertex *a, MGLVertex *b, MGLVertex *r)
{
	float w;

	float t = (w1+z1)/((w1+z1)-(w2+z2));

	r->v.color.r = LERP(t,a->v.color.r, b->v.color.r);
	r->v.color.g = LERP(t,a->v.color.g, b->v.color.g);
	r->v.color.b = LERP(t,a->v.color.b, b->v.color.b);
	r->v.color.a = LERP(t,a->v.color.a, b->v.color.a);

	r->v.u = LERP(t,a->v.u, b->v.u);
	r->v.v = LERP(t,a->v.v, b->v.v);

	r->bx = LERP(t,a->bx, b->bx);
	r->by = LERP(t,a->by, b->by);
	r->bw = LERP(t,a->bw, b->bw);
	r->bz = -r->bw;

	w = r->bw;

	if (-w > r->by)
	{
		r->outcode = MGL_CLIP_BOTTOM;
	}
	else if (r->by > w)
	{
		r->outcode = MGL_CLIP_TOP;
	}
	else
	{
		r->outcode = 0;
	}
}

//Flatshade

static void AF_ClipWZero(MGLVertex *a, MGLVertex *b, MGLVertex *r)
{
	ULONG outcode;
	
	float t = (CLIP_EPS-w1)/(w2-w1);

	r->v.u = LERP(t,a->v.u, b->v.u);
	r->v.v = LERP(t,a->v.v, b->v.v);

	r->bx = LERP(t,a->bx, b->bx);
	r->by = LERP(t,a->by, b->by);
	r->bz = LERP(t,a->bz, b->bz);
	r->bw = CLIP_EPS;

	outcode = 0;

	if (-CLIP_EPS > r->bx)
	{
		outcode = MGL_CLIP_LEFT;
	}
	else if (r->bx > CLIP_EPS)
	{
		outcode = MGL_CLIP_RIGHT;
	}

	if (-CLIP_EPS > r->by)
	{
		outcode |= MGL_CLIP_BOTTOM;
	}
	else if (r->by > CLIP_EPS)
	{
		outcode |= MGL_CLIP_TOP;
	}

	if (-CLIP_EPS > r->bz)
	{
		outcode |= MGL_CLIP_BACK;
	}
	else if (r->bz > CLIP_EPS)
	{
		outcode |= MGL_CLIP_FRONT;
	}

	r->outcode = outcode;
}

static void AF_ClipTop(MGLVertex *a, MGLVertex *b, MGLVertex *r)
{
	float t = (w1-y1)/((w1-y1)-(w2-y2));

	r->v.u = LERP(t,a->v.u, b->v.u);
	r->v.v = LERP(t,a->v.v, b->v.v);

	r->bx = LERP(t,a->bx, b->bx);
	r->bz = LERP(t,a->bz, b->bz);
	r->bw = LERP(t,a->bw, b->bw);
	r->by = r->bw;

/*
Surgeon: this is always the 2nd last routine called, so here is no need to recode since a top-code means that there can be no bottom-code - we can safely set the outcode of the clipped vert to 0
*/
	r->outcode = 0;
}

static void AF_ClipBottom(MGLVertex *a, MGLVertex *b, MGLVertex *r)
{
	float t = (w1+y1)/((w1+y1)-(w2+y2));

	r->v.u = LERP(t,a->v.u, b->v.u);
	r->v.v = LERP(t,a->v.v, b->v.v);

	r->bx = LERP(t,a->bx, b->bx);
	r->bz = LERP(t,a->bz, b->bz);
	r->bw = LERP(t,a->bw, b->bw);
	r->by = -r->bw;

/*
Surgeon: this is always the last routine called, so here is no need to recode - we can safely set the outcode of the clipped vert to 0
*/

	r->outcode = 0;
}

static void AF_ClipLeft(MGLVertex *a, MGLVertex *b, MGLVertex *r)
{
	float w;
	ULONG outcode;

	float t = (w1+x1)/((w1+x1)-(w2+x2));

	r->v.u = LERP(t,a->v.u, b->v.u);
	r->v.v = LERP(t,a->v.v, b->v.v);

	r->by = LERP(t,a->by, b->by);
	r->bz = LERP(t,a->bz, b->bz);
	r->bw = LERP(t,a->bw, b->bw);
	r->bx = -r->bw;

	w = r->bw;
	outcode = 0;

	if (-w > r->by)
	{
		outcode = MGL_CLIP_BOTTOM;
	}
	else if (r->by > w)
	{
		outcode = MGL_CLIP_TOP;
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
}

static void AF_ClipRight(MGLVertex *a, MGLVertex *b, MGLVertex *r)
{
	float w;
	ULONG outcode;

	float t = (w1-x1)/((w1-x1)-(w2-x2));

	r->v.u = LERP(t,a->v.u, b->v.u);
	r->v.v = LERP(t,a->v.v, b->v.v);

	r->by = LERP(t,a->by, b->by);
	r->bz = LERP(t,a->bz, b->bz);
	r->bw = LERP(t,a->bw, b->bw);
	r->bx = r->bw;

	w = r->bw;
	outcode = 0;

	if (-w > r->by)
	{
		outcode = MGL_CLIP_BOTTOM;
	}
	else if (r->by > w)
	{
		outcode = MGL_CLIP_TOP;
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
}

static void AF_ClipFront(MGLVertex *a, MGLVertex *b, MGLVertex *r)
{
	float w;

	float t = (w1-z1)/((w1-z1)-(w2-z2));

	r->v.u = LERP(t,a->v.u, b->v.u);
	r->v.v = LERP(t,a->v.v, b->v.v);

	r->bx = LERP(t,a->bx, b->bx);
	r->by = LERP(t,a->by, b->by);
	r->bw = LERP(t,a->bw, b->bw);
	r->bz = r->bw;

	w = r->bw;

	if (-w > r->by)
	{
		r->outcode = MGL_CLIP_BOTTOM;
	}
	else if (r->by > w)
	{
		r->outcode = MGL_CLIP_TOP;
	}
	else
	{
		r->outcode = 0;
	}
}

static void AF_ClipBack(MGLVertex *a, MGLVertex *b, MGLVertex *r)
{
	float w;

	float t = (w1+z1)/((w1+z1)-(w2+z2));

	r->v.u = LERP(t,a->v.u, b->v.u);
	r->v.v = LERP(t,a->v.v, b->v.v);

	r->bx = LERP(t,a->bx, b->bx);
	r->by = LERP(t,a->by, b->by);
	r->bw = LERP(t,a->bw, b->bw);
	r->bz = -r->bw;

	w = r->bw;

	if (-w > r->by)
	{
		r->outcode = MGL_CLIP_BOTTOM;
	}
	else if (r->by > w)
	{
		r->outcode = MGL_CLIP_TOP;
	}
	else
	{
		r->outcode = 0;
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


/*
** Complicated clipping macro stuff.
*/

#define VERTP(i) &(context->VertexBuffer[a->verts[i]])
#define VERT(i)  (context->VertexBuffer[a->verts[i]])

#define POLYSWAP \
	if (b_numverts<3) return 0; temp=a; a=b; b=temp;


#define DOCLIP(edge, routine)                                           \
	if (or_codes & edge)                                                 \
	{                                                                     \
		int b_numverts, prev;	\
		b_numverts = 0;                                                   \
		prev = a->numverts-1;                                               \
	i=0; do	{                                                                          \
			/* Case 1 and 4*/                                                  \
			if (!(VERT(prev).outcode & edge))                                   \
			{                                                                    \
				b->verts[b_numverts] = a->verts[prev];                           \
				b_numverts++;                                                     \
			}                                                                       \
			/* Case 3 and 4 */                                                       \
			if ((VERT(prev).outcode ^ VERT(i).outcode) & edge)                        \
			{                                                                                  \
				A_##routine (VERTP(prev), VERTP(i), &(context->VertexBuffer[free]));                \
				b->verts[b_numverts]=free++;                                              \
				b_numverts++;                                                             \
			}                     \
			prev = i;             \
		}  while (++i < a->numverts); \
		b->numverts = b_numverts;	\
		POLYSWAP                      \
	}                          


#define DOCLIP_F(edge, routine)                                           \
	if (or_codes & edge)                                                 \
	{	\
		int b_numverts, prev;	\
		b_numverts = 0;     \
                         \
		prev = a->numverts-1;                                               \
	i=0; do	{                                                                          \
			/* Case 1 and 4*/                                                  \
			if (!(VERT(prev).outcode & edge))                                   \
			{                                                                    \
				b->verts[b_numverts] = a->verts[prev];                           \
				b_numverts++;                                                     \
			}                                                                       \
			/* Case 3 and 4 */                                                       \
			if ((VERT(prev).outcode ^ VERT(i).outcode) & edge)                        \
			{                                                                                  \
				AF_##routine (VERTP(prev), VERTP(i), &(context->VertexBuffer[free]));                \
				b->verts[b_numverts]=free++;                                              \
				b_numverts++;                                                             \
			}                     \
			prev = i;             \
		}  while (++i < a->numverts); \
		b->numverts = b_numverts;	\
		POLYSWAP                      \
	}                          



int AE_ClipTriangle(GLcontext context, PolyBuffer *in, PolyBuffer *out, int *clipstart, ULONG or_codes)
{
	PolyBuffer *a, *b, *temp;
	int i;
	int free;

	free = *clipstart;

	in->numverts = 3;
	a=in; b=out;


	if(context->ShadeModel == GL_FLAT)
	{
		DOCLIP_F(MGL_CLIP_NEGW, ClipWZero);

		if((or_codes & MGL_CLIP_NEGW) && (or_codes != MGL_CLIP_NEGW))
		{
		   or_codes = context->VertexBuffer[a->verts[0]].outcode | context->VertexBuffer[a->verts[1]].outcode;

		   i = 2;
		   do
		   {
			or_codes |= context->VertexBuffer[a->verts[i]].outcode;
		   } while (++i < a->numverts);
		}

		DOCLIP_F(MGL_CLIP_LEFT, ClipLeft)
		DOCLIP_F(MGL_CLIP_RIGHT, ClipRight)
		DOCLIP_F(MGL_CLIP_FRONT, ClipFront)
		DOCLIP_F(MGL_CLIP_BACK, ClipBack)
		DOCLIP_F(MGL_CLIP_TOP, ClipTop)
		DOCLIP_F(MGL_CLIP_BOTTOM, ClipBottom)
	}
	else
	{
		DOCLIP(MGL_CLIP_NEGW, ClipWZero);

		if((or_codes & MGL_CLIP_NEGW) && (or_codes != MGL_CLIP_NEGW))
		{
		   or_codes = context->VertexBuffer[a->verts[0]].outcode | context->VertexBuffer[a->verts[1]].outcode;

		   i = 2;
		   do
		   {
			or_codes |= context->VertexBuffer[a->verts[i]].outcode;
		   } while (++i < a->numverts);
		}

		DOCLIP(MGL_CLIP_LEFT, ClipLeft)
		DOCLIP(MGL_CLIP_RIGHT, ClipRight)
		DOCLIP(MGL_CLIP_FRONT, ClipFront)
		DOCLIP(MGL_CLIP_BACK, ClipBack)
		DOCLIP(MGL_CLIP_TOP, ClipTop)
		DOCLIP(MGL_CLIP_BOTTOM, ClipBottom)
	}


//write buffer index ?

      if(a != out)
      {
         out->numverts = a->numverts;
         out->verts[0] = a->verts[0];
         out->verts[1] = a->verts[1];

         i = 2;
         do
         {
                out->verts[i] = a->verts[i];
         } while (++i < a->numverts);
      }

	*clipstart = free;

	return 1;
}
