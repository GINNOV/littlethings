/*
 * $Id: vertexbuffer.c,v 1.1.1.1 2000/04/07 19:44:51 hfrieden Exp $
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

/*
Surgeon:

Changes to vertexbuffer building API:
- added MGL_FLATSTRIP primitive similar to MGL_FLATFAN
- reduced memory-reads/writes
- implemented a normalbuffer instead of pr-vertex normals
- texcoords are multiplied with width/height after culling.
- moved color-clamp to the GLColor functions
- glVertex only cares for vertex coords, colors and normal- index.

Most functions are now so small that the obvious step is to change parts of the API to macros/static inlines, since per-vertex funcs are called many thousands of times per frame.
See include/mgl/mglmacros.h

- context->CurrentTexQ does not need to be cleared to 1.0 if only two texcoords are specified since it is only used if context->CurrentTexQValid is equal to GL_TRUE
This boolean is only set in the event of glTexCoord4f and cleared to GL_FALSE by glBegin
*/

#include "sysinc.h"
#include <stdio.h>

#if defined (__VBCC__) && defined(__M68K__)
	#include <inline/timer_protos.h>
#endif

static char rcsid[] = "$Id: vertexbuffer.c,v 1.1.1.1 2000/04/07 19:44:51 hfrieden Exp $";

#ifdef __VBCC__
extern void d_DrawPoints        (GLcontext context);
extern void d_DrawLines         (GLcontext context);
extern void d_DrawLineStrip     (GLcontext context);
extern void d_DrawTriangles     (GLcontext context);
extern void d_DrawTrianglesVA   (GLcontext context);
extern void d_DrawTriangleFan   (GLcontext context);
extern void d_DrawTriangleStrip (GLcontext context);
extern void d_DrawQuads         (GLcontext context);
extern void d_DrawNormalPoly    (GLcontext context);
extern void d_DrawSmoothPoly    (GLcontext context);
extern void d_DrawMtexPoly      (GLcontext context);
extern void d_DrawQuadStrip     (GLcontext context);
   #if 0
extern void d_DrawFlatFan       (GLcontext context);
extern void d_DrawFlatStrip     (GLcontext context);
   #else
extern void d_DrawFlat          (GLcontext context);
   #endif

#else

extern void d_DrawPoints        (struct GLcontext_t);
extern void d_DrawLines         (struct GLcontext_t);
extern void d_DrawLineStrip     (struct GLcontext_t);
extern void d_DrawTriangles     (struct GLcontext_t);
extern void d_DrawTriangleFan   (struct GLcontext_t);
extern void d_DrawTriangleStrip (struct GLcontext_t);
extern void d_DrawQuads         (struct GLcontext_t);
extern void d_DrawNormalPoly    (struct GLcontext_t);
extern void d_DrawSmoothPoly    (struct GLcontext_t);
extern void d_DrawMtexPoly      (struct GLcontext_t);
extern void d_DrawQuadStrip     (struct GLcontext_t);
extern void d_DrawTrianglesVA   (struct GLcontext_t);
   #if 0
extern void d_DrawFlatFan  	  (struct GLcontext_t);
extern void d_DrawFlatStrip	  (struct GLcontext_t);
   #else
 extern void d_DrawFlat	  (struct GLcontext_t);
   #endif
#endif

extern void tex_ConvertTexture  (GLcontext);
extern void fog_Set             (GLcontext);


#ifndef __PPC__
	static struct Device *TimerBase = NULL;
#endif


void TMA_Start(LockTimeHandle *handle);
GLboolean TMA_Check(LockTimeHandle *handle);


/*
Timer based locking stuff.

TMA_Start starts the time measuring for the lock time. The 68k uses the ReadEClock
function due to its low overhead. PPC will use GetSysTimePPC for the same reasons.

The EClock version reads the eclock and stores the current values in the handle.
It then calculates a maximum lock time based on the assumption that the lock
should be unlocked after 0.05 seconds (i.e. twenty times per second).

TMA_Check checks if the specified time has expired. If it returns GL_FALSE,
the lock may be kept alive. On return of GL_TRUE, the lock must be released.

Note that this routine handles the case where the ev_hi values has changed, i.e.
the eV_lo value had an overrun. This code also assumes, however, that the difference
between the current and former ev_hi is no more than 1. This is, however, a very
safe assumption; It takes approx. 100 minutes for the ev_hi field to increment,
and it is extremely unlikely that the ev_hi field overruns - this will happen after
approx. 820,000 years uptime (of course, a reliable system should be prepared for
this)

*/

#ifndef __PPC__
void TMA_Start(LockTimeHandle *handle)
{
	struct EClockVal eval;
	extern struct ExecBase *SysBase;
	if (!TimerBase)
	{
		TimerBase = (struct Device *)FindName(&SysBase->DeviceList, "timer.device");
	}

	handle->e_freq = ReadEClock(&eval);
	handle->s_hi = eval.ev_hi;
	handle->s_lo = eval.ev_lo;
	handle->e_freq /= 20;
}

GLboolean TMA_Check(LockTimeHandle *handle)
{
	struct EClockVal eval;
	ULONG ticks;

	ReadEClock(&eval);

	if (eval.ev_hi == handle->s_hi)
	{
		ticks = eval.ev_lo - handle->s_lo;
	}
	else
	{
		ticks = (~0)-handle->s_lo + eval.ev_lo;
	}

	if (ticks > handle->e_freq) return GL_TRUE;
	else return GL_FALSE;
}

#else
void TMA_Start(LockTimeHandle *handle)
{
	GetSysTimePPC(&(handle->StartTime));
}

GLboolean TMA_Check(LockTimeHandle *handle)
{
	struct timeval curTime;

	GetSysTimePPC(&curTime);
	SubTimePPC(&curTime, &(handle->StartTime));
	if (curTime.tv_secs) return GL_TRUE;
	if (curTime.tv_micro > 50000) return GL_TRUE;
	return GL_FALSE;
}
#endif



void GLBegin(GLcontext context, GLenum mode)
{
//    GLFlagError(context, context->CurrentPrimitive != GL_BASE, GL_INVALID_OPERATION);

	context->CurrentTexQValid = GL_FALSE; //Surgeon
	context->VertexBufferPointer = 0;

	switch((int)mode)
	{
		case GL_POINTS:
			//LOG(1, glBegin, "GL_POINTS");
			context->CurrentPrimitive = mode;
			context->CurrentDraw = (DrawFn)d_DrawPoints;
			break;
		case GL_LINES:
			//LOG(1, glBegin, "GL_LINES");
			context->CurrentPrimitive = mode;
			context->CurrentDraw = (DrawFn)d_DrawLines;
			break;
		case GL_LINE_STRIP:
			//LOG(1, glBegin, "GL_LINE_STRIP");
			context->CurrentPrimitive = mode;
			context->CurrentDraw = (DrawFn)d_DrawLineStrip;
			break;
		case GL_LINE_LOOP:
			//LOG(1, glBegin, "GL_LINE_LOOP");
			context->CurrentPrimitive = mode;
			context->CurrentDraw = (DrawFn)d_DrawLineStrip;
			break;
		case GL_TRIANGLES:
			//LOG(1, glBegin, "GL_TRIANLES");
			context->CurrentPrimitive = mode;
			//Surgeon:
			//Delay setting pointer until we know the number of triangles that enters the pipeline
			break;
		case GL_TRIANGLE_STRIP:
			//LOG(1, glBegin, "GL_TRIANGLE_STRIP");
			context->CurrentPrimitive = mode;
			context->CurrentDraw = (DrawFn)d_DrawTriangleStrip;
			break;
		case GL_TRIANGLE_FAN:
			//LOG(1, glBegin, "GL_TRIANGLE_FAN");
			context->CurrentPrimitive = mode;
			context->CurrentDraw = (DrawFn)d_DrawTriangleFan;
			break;
		case GL_QUADS:
			//LOG(1, glBegin, "GL_QUADS");
			context->CurrentPrimitive = mode;
			context->CurrentDraw = (DrawFn)d_DrawQuads;
			break;
		case GL_QUAD_STRIP:
			//LOG(1, glBegin, "GL_QUAD_STRIP");
			context->CurrentPrimitive = mode;
			context->CurrentDraw = (DrawFn)d_DrawQuadStrip;
			break;
		case GL_POLYGON:
			//LOG(1, glBegin, "GL_POLYGON");
			context->CurrentPrimitive = mode;
			if(context->Texture2D_State[1] == GL_TRUE)
			context->CurrentDraw = (DrawFn)d_DrawMtexPoly;
			else if(context->ShadeModel == GL_SMOOTH)
			context->CurrentDraw = (DrawFn)d_DrawSmoothPoly;
			else
			context->CurrentDraw = (DrawFn)d_DrawNormalPoly;

			break;
		case MGL_FLATFAN:
			//LOG(1, glBegin, "MGL_FLATFAN");
			context->CurrentPrimitive = mode;
			context->CurrentDraw = (DrawFn)d_DrawFlat;
			break;
		case MGL_FLATSTRIP:
			//LOG(1, glBegin, "MGL_FLATSTRIP");
			context->CurrentPrimitive = mode;
			context->CurrentDraw = (DrawFn)d_DrawFlat;
			break;
		default:
			//LOG(1, glBegin, "Error GL_INVALID_OPERATION");
			GLFlagError (context, 1, GL_INVALID_OPERATION);
			break;
	}

	//warp Current Normal

	if(context->NormalBufferPointer)
	{
		context->NormalBuffer[0].x = context->NormalBuffer[context->NormalBufferPointer].x;
		context->NormalBuffer[0].y = context->NormalBuffer[context->NormalBufferPointer].y;
		context->NormalBuffer[0].z = context->NormalBuffer[context->NormalBufferPointer].z;

	context->NormalBufferPointer = 0;
	}
}

//surgeon:

void GLPointSize(GLcontext context, GLfloat size)
{
	context->CurrentPointSize = size;
}

#if !defined (__STORM__)
static
#endif
inline W3D_Float CLAMPF(GLfloat x)
{
	if (x>=0.f && x<=1.f) return x;
	else if (x<=0.f)      return 0.f;
	else                  return 1.f;
}



void GLColor4f(GLcontext context, GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha)
{
	//LOG(2, glColor4f, "%f %f %f %f", red, green, blue, alpha);

#ifdef CLAMP_COLORS
	W3D_Float r,g,b,a;

	if (red<0.f)		r = 0.f;
	else if (red>1.f)	r = 1.f;
	else			r = red;

	if (green<0.f)		g = 0.f;
	else if (green>1.f)	g = 1.f;
	else			g = green;

	if (blue<0.f)		b = 0.f;
	else if (blue>1.f)	b = 1.f;
	else			b = blue;

	if (alpha<0.f)		a = 0.f;
	else if (alpha>1.f)	a = 1.f;
	else			a = alpha;

	context->CurrentColor.r = r;
	context->CurrentColor.g = g;
	context->CurrentColor.b = b;
	context->CurrentColor.a = a;
#else
	context->CurrentColor.r = (W3D_Float)red;
	context->CurrentColor.g = (W3D_Float)green;
	context->CurrentColor.b = (W3D_Float)blue;
	context->CurrentColor.a = (W3D_Float)alpha;
#endif

	context->UpdateCurrentColor = GL_TRUE;
}

void GLColor3f(GLcontext context, GLfloat red, GLfloat green, GLfloat blue)
{
#ifdef CLAMP_COLORS
	W3D_Float r,g,b;

	if (red<0.f)		r = 0.f;
	else if (red>1.f)	r = 1.f;
	else			r = red;

	if (green<0.f)		g = 0.f;
	else if (green>1.f)	g = 1.f;
	else			g = green;

	if (blue<0.f)		b = 0.f;
	else if (blue>1.f)	b = 1.f;
	else			b = blue;

	context->CurrentColor.r = r;
	context->CurrentColor.g = g;
	context->CurrentColor.b = b;
	context->CurrentColor.a = 1.f;
#else
	context->CurrentColor.r = (W3D_Float)red;
	context->CurrentColor.g = (W3D_Float)green;
	context->CurrentColor.b = (W3D_Float)blue;
	context->CurrentColor.a = (W3D_Float)1.f;
#endif

	context->UpdateCurrentColor = GL_TRUE;
}

void GLColor4fv(GLcontext context, GLfloat *v)
{
	//LOG(2, glColor4fv, "%f %f %f %f", v[0], v[1], v[2], v[3]);

	W3D_Float red	= v[0];
	W3D_Float green	= v[1];
	W3D_Float blue	= v[2];
	W3D_Float alpha	= v[3];

#ifdef CLAMP_COLORS
	if (red<0.f)		red = 0.f;
	else if (red>1.f)	red = 1.f;
	if (green<0.f)		green = 0.f;
	else if (green>1.f)	green = 1.f;
	if (blue<0.f)		blue = 0.f;
	else if (blue>1.f)	blue = 1.f;
	if (alpha<0.f)		alpha = 0.f;
	else if (alpha>1.f)	alpha = 1.f;
#endif

	context->CurrentColor.r = red;
	context->CurrentColor.g = green;
	context->CurrentColor.b = blue;
	context->CurrentColor.a = alpha;

	context->UpdateCurrentColor = GL_TRUE;
}

void GLColor3fv(GLcontext context, GLfloat *v)
{
	//LOG(2, glColor3fv, "%f %f %f", v[0], v[1], v[2]);

	W3D_Float red	= v[0];
	W3D_Float green	= v[1];
	W3D_Float blue	= v[2];

#ifdef CLAMP_COLORS
	if (red<0.f)		red = 0.f;
	else if (red>1.f)	red = 1.f;
	if (green<0.f)		green = 0.f;
	else if (green>1.f)	green = 1.f;
	if (blue<0.f)		blue = 0.f;
	else if (blue>1.f)	blue = 1.f;
#endif

	context->CurrentColor.r = red;
	context->CurrentColor.g = green;
	context->CurrentColor.b = blue;
	context->CurrentColor.a = 1.0;

	context->UpdateCurrentColor = GL_TRUE;
}

void GLColor4ub(GLcontext context, GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha)
{
	register W3D_Float f = 1/255.0;
	//LOG(2, glColor4ub, "%f %f %f %f", red*f, green*f, blue*f, alpha*f);

	// no clamping: ubyte always between 0 and 255 :)

	context->CurrentColor.r = (W3D_Float)red*f;
	context->CurrentColor.g = (W3D_Float)green*f;
	context->CurrentColor.b = (W3D_Float)blue*f;
	context->CurrentColor.a = (W3D_Float)alpha*f;

	context->UpdateCurrentColor = GL_TRUE;
}

void GLColor3ub(GLcontext context, GLubyte red, GLubyte green, GLubyte blue)
{
	register W3D_Float f = 1/255.0;

	// no clamping: ubyte always between 0 and 255 :)

	context->CurrentColor.r = (W3D_Float)red*f;
	context->CurrentColor.g = (W3D_Float)green*f;
	context->CurrentColor.b = (W3D_Float)blue*f;
	context->CurrentColor.a = 1.f;

	context->UpdateCurrentColor = GL_TRUE;
}

void GLColor4ubv(GLcontext context, GLubyte *v)
{
	register W3D_Float f = 1/255.0;

	//LOG(2, glColor4ubv, "%f %f %f %f", v[0]*f, v[1]*f, v[2]*f, v[3]*f);

	context->CurrentColor.r = (W3D_Float)v[0]*f;
	context->CurrentColor.g = (W3D_Float)v[1]*f;
	context->CurrentColor.b = (W3D_Float)v[2]*f;
	context->CurrentColor.a = (W3D_Float)v[3]*f;

	context->UpdateCurrentColor = GL_TRUE;
}

void GLColor3ubv(GLcontext context, GLubyte *v)
{
	register W3D_Float f = 1/255.0;
	//LOG(2, glColor3ubv, "%f %f %f", v[0]*f, v[1]*f, v[2]*f);

	// no clamping: ubyte always between 0 and 255 :)

	context->CurrentColor.r = (W3D_Float)v[0]*f;
	context->CurrentColor.g = (W3D_Float)v[1]*f;
	context->CurrentColor.b = (W3D_Float)v[2]*f;
	context->CurrentColor.a = (W3D_Float)1.0;

	context->UpdateCurrentColor = GL_TRUE;
}

void GLNormal3f(GLcontext context, GLfloat x, GLfloat y, GLfloat z)
{
	//LOG(2, glNormal3f, "%f %f %f", x,y,z);

  GLuint nbp = ++context->NormalBufferPointer;
  context->NormalBuffer[nbp].x = x;
  context->NormalBuffer[nbp].y = y;
  context->NormalBuffer[nbp].z = z;
}

void GLNormal3fv(GLcontext context, GLfloat *n)
{
}


#define CURRENTVERT context->VertexBuffer[context->VertexBufferPointer]

void GLMultiTexCoord2fARB(GLcontext context, GLenum unit, GLfloat s, GLfloat t)
{
	int u = unit - GL_TEXTURE0_ARB;

	if(u<0 || u>MAX_TEXUNIT)
	return;

	if(u)
	{
		CURRENTVERT.tcoord.s = s;
		CURRENTVERT.tcoord.t = t;
	}
	else //unit 0
	{
		CURRENTVERT.v.u = s;
		CURRENTVERT.v.v = t;
	}
}

void GLMultiTexCoord2fvARB(GLcontext context, GLenum unit, GLfloat *v)
{
	int u = unit - GL_TEXTURE0_ARB;

	if(u<0 || u>MAX_TEXUNIT)
	return;

	if(u)
	{
		CURRENTVERT.tcoord.s = v[0];
		CURRENTVERT.tcoord.t = v[1];
	}
	else //unit 0
	{
		CURRENTVERT.v.u = v[0];
		CURRENTVERT.v.v = v[1];
	}
}

void GLTexCoord2f(GLcontext context, GLfloat s, GLfloat t)
{
	//LOG(2, glTexCoord2f, "%f %f", s,t);

	#define thisvertex context->VertexBuffer[context->VertexBufferPointer]

	thisvertex.v.u = (W3D_Float)s;
	thisvertex.v.v = (W3D_Float)t;
	
	#undef thisvertex
}

void GLTexCoord2fv(GLcontext context, GLfloat *v)
{
	#define thisvertex context->VertexBuffer[context->VertexBufferPointer]

	thisvertex.v.u = (W3D_Float)v[0];
	thisvertex.v.v = (W3D_Float)v[1];

	#undef thisvertex

	//LOG(2, glTexCoord2fv, "%f %f", v[0], v[1]);
}

void GLTexCoord4f(GLcontext context, GLfloat s, GLfloat t, GLfloat r, GLfloat q)
{
	#define thisvertex context->VertexBuffer[context->VertexBufferPointer]

	thisvertex.v.u = (W3D_Float)s/(W3D_Float)q;
	thisvertex.v.v = (W3D_Float)t/(W3D_Float)q;
	thisvertex.q = q;

	context->CurrentTexQValid = GL_TRUE;

	#undef thisvertex
}

void GLTexCoord4fv(GLcontext context, GLfloat *v)
{
	#define thisvertex context->VertexBuffer[context->VertexBufferPointer]

	thisvertex.v.u = (W3D_Float)v[1]/(W3D_Float)v[3];
	thisvertex.v.v = (W3D_Float)v[2]/(W3D_Float)v[3];
	thisvertex.q = v[3];

	context->CurrentTexQValid = GL_TRUE;

	#undef thisvertex
}


void GLVertex4f(GLcontext context, GLfloat x, GLfloat y, GLfloat z, GLfloat w)
{
	#define thisvertex context->VertexBuffer[context->VertexBufferPointer]

	//LOG(1, glVertex4f, "%f %f %f %f", x,y,z,w);

	if(context->ShadeModel == GL_SMOOTH)
	{
	thisvertex.v.color.r = context->CurrentColor.r;
	thisvertex.v.color.g = context->CurrentColor.g;
	thisvertex.v.color.b = context->CurrentColor.b;
	thisvertex.v.color.a = context->CurrentColor.a;
	}

	thisvertex.bx = x;
	thisvertex.by = y;
	thisvertex.bz = z;
	thisvertex.bw = w;

	thisvertex.normal = context->NormalBufferPointer;

	context->VertexBufferPointer ++;
	#undef thisvertex
}

void GLVertex4fv(GLcontext context, GLfloat *v)
{
	#define thisvertex context->VertexBuffer[context->VertexBufferPointer]

	if(context->ShadeModel == GL_SMOOTH)
	{
	thisvertex.v.color.r = context->CurrentColor.r;
	thisvertex.v.color.g = context->CurrentColor.g;
	thisvertex.v.color.b = context->CurrentColor.b;
	thisvertex.v.color.a = context->CurrentColor.a;
	}

	thisvertex.bx = v[0];
	thisvertex.by = v[1];
	thisvertex.bz = v[2];
	thisvertex.bw = v[3];

	thisvertex.normal = context->NormalBufferPointer;

	context->VertexBufferPointer ++;
	#undef thisvertex
}

void GLVertex3fv(GLcontext context, GLfloat *v)
{
	#define thisvertex context->VertexBuffer[context->VertexBufferPointer]

	if(context->ShadeModel == GL_SMOOTH)
	{
	thisvertex.v.color.r = context->CurrentColor.r;
	thisvertex.v.color.g = context->CurrentColor.g;
	thisvertex.v.color.b = context->CurrentColor.b;
	thisvertex.v.color.a = context->CurrentColor.a;
	}

	thisvertex.bx = v[0];
	thisvertex.by = v[1];
	thisvertex.bz = v[2];
	thisvertex.bw = 1.f;

	thisvertex.normal = context->NormalBufferPointer;

	context->VertexBufferPointer ++;
	#undef thisvertex
}

void GLVertex2f(GLcontext context, GLfloat x, GLfloat y)
{
	#define thisvertex context->VertexBuffer[context->VertexBufferPointer]

	//LOG(1, glVertex4f, "%f %f %f %f", x,y,z,w);

	if(context->ShadeModel == GL_SMOOTH)
	{
	thisvertex.v.color.r = context->CurrentColor.r;
	thisvertex.v.color.g = context->CurrentColor.g;
	thisvertex.v.color.b = context->CurrentColor.b;
	thisvertex.v.color.a = context->CurrentColor.a;
	}

	thisvertex.bx = x;
	thisvertex.by = y;
	thisvertex.bz = 0.0;
	thisvertex.bw = 1.0;

	thisvertex.normal = context->NormalBufferPointer;

	context->VertexBufferPointer ++;
	#undef thisvertex
}

void GLVertex2fv(GLcontext context, GLfloat *v)
{
	#define thisvertex context->VertexBuffer[context->VertexBufferPointer]

	if(context->ShadeModel == GL_SMOOTH)
	{
	thisvertex.v.color.r = context->CurrentColor.r;
	thisvertex.v.color.g = context->CurrentColor.g;
	thisvertex.v.color.b = context->CurrentColor.b;
	thisvertex.v.color.a = context->CurrentColor.a;
	}

	thisvertex.bx = v[0];
	thisvertex.by = v[1];
	thisvertex.bz = 0.f;
	thisvertex.bw = 1.f;

	thisvertex.normal = context->NormalBufferPointer;

	context->VertexBufferPointer ++;
	#undef thisvertex
}


void GLDepthRange(GLcontext context, GLclampd n, GLclampd f)
{
	//LOG(2, glDepthRange, "%f %f", n, f);
	context->near = n;
	context->far  = f;
#if 0
	context->sz = (f-n)*0.5;
	context->az = (n+f)*0.5;
#else
	context->sz = (GLfloat)((f-n)*0.5);
	context->az = (GLfloat)((n+f)*0.5);
#endif
}


void GLViewport(GLcontext context, GLint x, GLint y, GLsizei w, GLsizei h)
{
	GLuint clipflags;
	//LOG(2, glViewPort, "%d %d %d %d", x,y,w,h);

//surgeon begin -->
	//the are the default 'must' clipflags:

	if(context->GuardBand == GL_TRUE)
	{
		clipflags = (MGL_CLIP_NEGW|MGL_CLIP_BACK|MGL_CLIP_FRONT);

	//the following flags are viewport-dependant:

	if(x > 0)
		clipflags |= MGL_CLIP_LEFT;

	if((x+w) < context->w3dScreen->Width)
		clipflags |= MGL_CLIP_RIGHT;

	if(y > 0)
		clipflags |= MGL_CLIP_BOTTOM;

	if((y+h) < context->w3dScreen->Height)
		clipflags |= MGL_CLIP_TOP;

	context->ClipFlags = clipflags;
	}
	else //guardband clipping disabled
	{
	context->ClipFlags = (MGL_CLIP_NEGW | MGL_CLIP_BACK | MGL_CLIP_FRONT | MGL_CLIP_LEFT | MGL_CLIP_RIGHT | MGL_CLIP_TOP | MGL_CLIP_BOTTOM);
	}

//surgeon end <--

#if 0 //double precision not needed

	context->ax = (double)x + (double)w*0.5;
	context->ay =  (double)(context->w3dWindow->Height-context->w3dWindow->BorderTop-context->w3dWindow->BorderBottom)
	              -(double)y - (double)h*0.5;
	context->sx = (double)w * 0.5;
	context->sy = (double)h * 0.5;

#else

	context->ax = (float)x + (float)w*0.5;
	context->ay =  (float)(context->w3dWindow->Height-context->w3dWindow->BorderTop-context->w3dWindow->BorderBottom)
	              -(float)y - (float)h*0.5;
	context->sx = (float)w * 0.5;
	context->sy = (float)h * 0.5;

#endif
}


extern void GLDrawElements(GLcontext context, GLenum mode, const GLsizei count, GLenum type, const GLvoid *indices);

//added 31-03-02: (moved from vertexelements.c)

void GLArrayElement(GLcontext context, GLint i)
{
	context->ElementIndex[context->VertexBufferPointer++] = (UWORD)i;
}
 

void GLEnd(GLcontext context)
{
	//LOG(1, glEnd, "");

	if(context->VertexBufferPointer == 0)
	{
		context->CurrentPrimitive = GL_BASE;
		return; //no verts recorded
	}

	if(context->ClientState & GLCS_VERTEX)
	{
	    //assume that a series of glArrayElement commands has been issued
	    GLDrawElements(context, context->CurrentPrimitive, context->VertexBufferPointer, GL_UNSIGNED_SHORT, context->ElementIndex);

	    context->CurrentPrimitive = GL_BASE;
	    return;
	}

	if(context->Texture2D_State[1] == GL_TRUE)
	{
	//buffered drawing, so don't check for anything

		context->CurrentDraw(context);
		context->CurrentPrimitive = GL_BASE;
		return;
	}

	if (context->FogDirty && context->Fog_State)
	{
		fog_Set(context);
		context->FogDirty = GL_FALSE;
	}

	if (context->ShadeModel == GL_FLAT)
	{
		if(context->UpdateCurrentColor == GL_TRUE)
		{

		W3D_SetCurrentColor(context->w3dContext, &context->CurrentColor);
		context->UpdateCurrentColor = GL_FALSE;
		}
	}

	// Check for blending inconsistancy
	if (context->AlphaFellBack && (context->SrcAlpha == GL_ONE || context->DstAlpha == GL_ONE)
		&& context->Blend_State == GL_TRUE)
	{
		tex_ConvertTexture(context);
	}


/* Surgeon:
** if more than 20 triangles enters pipeline we use
** vertexarrays. I suppose 20 tris warrants the overhead
** of pointer modifications.
*/
	if(context->CurrentPrimitive == GL_TRIANGLES)
	{
	  if(context->VertexBufferPointer < 60)
	    context->CurrentDraw = (DrawFn)d_DrawTriangles;
	  else
	    context->CurrentDraw = (DrawFn)d_DrawTrianglesVA;
	}


#ifdef AUTOMATIC_LOCKING_ENABLE

	if (context->LockMode == MGL_LOCK_AUTOMATIC) // Automatic: Lock per primitive
	{
		if (W3D_SUCCESS == W3D_LockHardware(context->w3dContext))
		{
			context->w3dLocked = GL_TRUE;
			context->CurrentDraw(context);
			W3D_UnLockHardware(context->w3dContext);
			context->w3dLocked = GL_FALSE;
		}
		else
		{
			printf("Error during LockHardware\n");
		}
	}
	else if (context->LockMode == MGL_LOCK_MANUAL) // Manual: Lock manually
	{
		context->CurrentDraw(context);
	}
	else // Smart: Lock timer based
	{
		if (context->w3dLocked == GL_FALSE)
		{
			if (W3D_SUCCESS != W3D_LockHardware(context->w3dContext))
			{
				printf("[glEnd] Error during W3D_LockHardware()\n");
				return; // give up
			}
			context->w3dLocked = GL_TRUE;
			TMA_Start(&(context->LockTime));
		}
		context->CurrentDraw(context);  // Draw!
		if (TMA_Check(&(context->LockTime)) == GL_TRUE)
		{
			// Time to unlock
			W3D_UnLockHardware(context->w3dContext);
			context->w3dLocked = GL_FALSE;
		}
	}

#else
	context->CurrentDraw(context);
#endif

	context->CurrentPrimitive = GL_BASE;
}

void GLFinish(GLcontext context)
{
	//LOG(2, glFinish, "");
	GLFlush(context);
	W3D_WaitIdle(context->w3dContext);
}

void GLFlush(GLcontext context)
{
	//LOG(2, glFlush, "");
}

