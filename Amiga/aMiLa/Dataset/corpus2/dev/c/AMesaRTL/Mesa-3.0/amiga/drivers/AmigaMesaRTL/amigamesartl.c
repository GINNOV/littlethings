
/*
 * Mesa 3-D graphics library
 * Version:  2.3
 * Copyright (C) 1995-1997  Brian Paul
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
 * amigamesartl.c
 *
 * Version 1.0  27 Jun 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * Based on ddsample.c ver 1.5
 *
 * Version 1.1  02 Aug 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Fixed several bugs in glClear()
 * - QUICKLOOP macros added
 * - Noticed that { *x = p; x++; } is faster than { *x++ = p; }
 * - Quantizer changed to plugin library
 * - Use environment variables to select quantizer
 *
 * Version 2.0  19 Sep 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - (Get|Set)IndexRGB added
 * - Set and get attributes added
 * - Lots more tags handled
 * - Added palette table for index mode
 * - Demands at least v2 quantizers
 * - Removed colourbase correction from index functions
 * - Deprecated some tags replaced by QNTZR_#?
 * - Changed CreateContext interface
 * - Added Szymon Ulatowski's resizing changes
 * - Changed "Quantizer" to "OutputHandler"
 * - Automagic mesamain.library opening added
 * - AMRTL_SupportsOH tag added
 * - RGBA and ARGB byte order supported
 * - RGBA byte order determined by OH_RGBAOrder
 *
 * Version 3.0  10 Oct 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Changed to Mesa 3.0
 * - Added check to make sure appropriate mesamain version
 *   is used
 */


/*
 * This is a sample template for writing new Mesa device drivers.
 * You'll have to rewrite all the pseudo code below.
 *
 * Let's say you're interfacing Mesa to a window/operating system
 * called FOO.  Replace all occurances of FOOMesa with the real name
 * you select for your interface  (i.e. XMesa, WMesa, AmigaMesa).
 *
 * You'll have to design an API for clients to use, defined in a
 * header called Mesa/include/GL/FooMesa.h  Use the sample as an
 * example.  The API should at least have functions for creating
 * rendering contexts, binding rendering contexts to windows/frame
 * buffers, etc.
 *
 * Next, you'll have to write implementations for the device driver
 * functions described in dd.h
 *
 * Note that you'll usually have to flip Y coordinates since Mesa's
 * window coordinates start at the bottom and increase upward.  Most
 * window system's Y-axis increases downward
 *
 * Functions marked OPTIONAL may be completely omitted by your driver.
 *
 * Your Makefile should compile this module along with the rest of
 * the core Mesa library.
 */


#include <stdlib.h>
#include "GL/mesadriver.h"
#include "context.h"
#include "depth.h"
#include "macros.h"
#include "matrix.h"
#include "types.h"
#include "vb.h"

#include "gl/gl.h"
#include "gl/outputhandler.h"
#include "gl/mesamain.h"

#include <constructor.h>
#include <intuition/intuition.h>
#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/utility.h>
#include <proto/exec.h>
#include <proto/dos.h>

#include <m68881.h>
#include <dos.h>

#define RGBA(r,g,b,a)	(((r)<<24) | ((g)<<16) | ((b)<<8) | (a))
#define ARGB(r,g,b,a)	(((a)<<24) | ((r)<<16) | ((g)<<8) | (b))

#define RGBA2ARGB(rgba)		(__builtin_ror((rgba),8))
#define RGB2RGBA(rgb)		((*((unsigned long *)(rgb))) | 0xff)
#define RGB2ARGB(rgb)		((*((unsigned long *)(rgb-1))) | 0xff000000)
#define ARGB2RGBA(argb)		(__builtin_rol((argb),8))

#define WINWIDTH(w)		((w)->Width - (w)->BorderLeft - (w)->BorderRight)
#define WINHEIGHT(w)	((w)->Height - (w)->BorderTop - (w)->BorderBottom)


#define QUICKLOOP16(n,l)	{ register int ql_var; \
								for(ql_var=0; ql_var<((n) & 15); ql_var++) \
								{ l; }\
								for(; ql_var<(n); ql_var+=16) \
								{ l; l; l; l; l; l; l; l; l; l; l; l; l; l; l; l; } \
							}

#define QUICKLOOP8(n,l)		{ register int ql_var; \
								for(ql_var=0; ql_var<((n) & 7); ql_var++) \
								{ l; }\
								for(; ql_var<(n); ql_var+=8) \
								{ l; l; l; l; l; l; l; l; } \
							}

#define QUICKLOOP4(n,l)		{ register int ql_var; \
								for(ql_var=0; ql_var<((n) & 3); ql_var++) \
								{ l; }\
								for(; ql_var<(n); ql_var+=4) \
								{ l; l; l; l; } \
							}

#define QUICKLOOP2(n,l)		{ register int ql_var; \
								for(ql_var=0; ql_var<((n) & 1); ql_var++) \
								{ l; }\
								for(; ql_var<(n); ql_var+=2) \
								{ l; l; } \
							}

#define QUICKLOOP1(n,l)		{ register int ql_var; \
								for(ql_var=0; ql_var<(n); ql_var++) \
								{ l; } \
							}



/*
 * This struct contains all device-driver state information.  Think of it
 * as an extension of the core GLcontext from types.h.
 */
struct amiga_mesa_rtl_context {
	GLcontext *gl_ctx;		/* the core library context */
	GLvisual *gl_visual;
	GLframebuffer *gl_buffer;	/* The depth, stencil, accum, etc buffers */
	ULONG mode;					/* RGB, Index, etc. */
	ULONG rgbaorder;			/* ORDER_RGBA, ORDER_ARGB */
	unsigned long *buffer;		/* The image buffer */
	GLint width, height;		/* Size of image buffer */
	GLint wwidth, wheight;		/* Current output size */
	GLint reqwidth, reqheight;	/* Requester buffer width and height */
	BOOL justcreated;			/* Context has just been created, not yet made current */
	unsigned long pixel;		/* current color index or RGBA pixel value */
	unsigned long clearpixel;	/* pixel for clearing the color buffers */
	struct Library *outputhandler;	/* Output handler library */
	struct Library *mesamain;	/* MesaMain library */
	BOOL myoutputhandler;		/* I opened the output handler */
	ULONG indexpal[256][3];		/* Palette table for index mode */
	ULONG a4;					/* Global data pointer */
	/* etc... */
};


/*
 * REMEMBER: These functions may be called in
 *           mesamain's context, NOT mesadriver,
 *           so no automatic access to global data
 */


static const char *renderer_string(void)
{
	/* No access to global data at A4, put the read-only
	 * string in the far section so that we have an
	 * absolute reference instead of A4 relative
	 */

	__far static const char renderer[] = "AmigaMesaRTL";

	return renderer;
}


static void clear_index( GLcontext *ctx, GLuint index )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	/* implement glClearIndex */
	/* usually just save the color index value in the amesartl struct */
	amesartl->clearpixel = index;
}


static void clear_color_rgba( GLcontext *ctx, GLubyte r, GLubyte g, GLubyte b, GLubyte a )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	/* implement glClearColor */
	/* color components are floats in [0,1] */
	/* usually just save the value in the amesartl struct */
	amesartl->clearpixel = RGBA(r,g,b,a);
}


static void clear_color_argb( GLcontext *ctx, GLubyte r, GLubyte g, GLubyte b, GLubyte a )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	/* implement glClearColor */
	/* color components are floats in [0,1] */
	/* usually just save the value in the amesartl struct */
	amesartl->clearpixel = ARGB(r,g,b,a);
}


static GLbitfield clear( GLcontext *ctx, GLbitfield mask,
		   GLboolean all, GLint x, GLint y, GLint width, GLint height )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	unsigned long *bp;
	unsigned char *bbp;
	unsigned long p;
/*
 * Clear the specified region of the buffers indicated by 'mask'
 * using the clear color or index as specified by one of the two
 * functions above.
 * If all==GL_TRUE, clear whole buffer, else just clear region defined
 * by x,y,width,height
 */

 	p = amesartl->clearpixel;
 	y = amesartl->wheight-1-y;

	if(mask & GL_COLOR_BUFFER_BIT)
	{
		if(amesartl->mode == AMRTL_RGBAMode)
		{
			if(all)
			{
				bp = amesartl->buffer;
				QUICKLOOP16(amesartl->width*amesartl->height,
					{
						*bp = p;
						bp++;
					}
				)
			}
			else
			{
				bp = amesartl->buffer+y*amesartl->width+x;
				QUICKLOOP16(height,
					{
						QUICKLOOP16(width,
							{
								*bp = p;
								bp++;
							}
						)
						bp -= amesartl->width + width;
					}
				)
			}
		}
		else
		{
			if(all)
			{
				memset(amesartl->buffer, p, amesartl->width * amesartl->height);
			}
			else
			{
				bbp = ((unsigned char *)amesartl->buffer)+y*amesartl->width+x;
				QUICKLOOP16(height,
					{
						memset(bbp, p, width);
						bbp -= amesartl->width;
					}
				)
			}
		}
	}

	return mask & (~GL_COLOR_BUFFER_BIT);
}


static void set_index( GLcontext *ctx, GLuint index )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	/* Set the current color index. */
	amesartl->pixel = index;
}


static void set_color_rgba( GLcontext *ctx, GLubyte r, GLubyte g, GLubyte b, GLubyte a )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	/* Set the current RGBA color. */
	/* r is in [0,ctx->Visual->RedScale]   */
	/* g is in [0,ctx->Visual->GreenScale] */
	/* b is in [0,ctx->Visual->BlueScale]  */
	/* a is in [0,ctx->Visual->AlphaScale] */
	amesartl->pixel = RGBA(r,g,b,a);
}


static void set_color_argb( GLcontext *ctx, GLubyte r, GLubyte g, GLubyte b, GLubyte a )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	/* Set the current ARGB color. */
	/* r is in [0,ctx->Visual->RedScale]   */
	/* g is in [0,ctx->Visual->GreenScale] */
	/* b is in [0,ctx->Visual->BlueScale]  */
	/* a is in [0,ctx->Visual->AlphaScale] */
	amesartl->pixel = ARGB(r,g,b,a);
}


static GLboolean set_buffer( GLcontext *ctx, GLenum mode )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	/* set the current drawing/reading buffer, return GL_TRUE or GL_FALSE */
	/* for success/failure */
	if (mode==GL_FRONT)
	{
 		return GL_TRUE;
	}
	else
	{
		return GL_FALSE;
	}
}


static int check_resized( struct amiga_mesa_rtl_context *amesartl )
{
	if (amesartl->outputhandler)
	{
		struct Library *outputhandlerBase = amesartl->outputhandler;
		GetOutputHandlerAttr(OH_Width,&amesartl->reqwidth);
		GetOutputHandlerAttr(OH_Height,&amesartl->reqheight);
	}

	return (amesartl->reqwidth != amesartl->wwidth) ||
	       (amesartl->reqheight != amesartl->wheight);
}


static void get_buffer_size( GLcontext *ctx, GLuint *width, GLuint *height )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	/* return the width and height of the current buffer */
	/* if anything special has to been done when the buffer/window is */
	/* resized, do it now */
	GLuint rw,rh;
	int resized;

	putreg(REG_A4,amesartl->a4);	/* Needed for calloc/free */

	resized = check_resized(amesartl);

	*width = amesartl->reqwidth;
	*height = amesartl->reqheight;

	if(resized)
	{
		amesartl->wwidth = amesartl->reqwidth;
		amesartl->wheight = amesartl->reqheight;

		rw = (((amesartl->wwidth + 15)>>4)<<4);
		rh = amesartl->wheight;

		if((rw != amesartl->width) || (rh != amesartl->height))
		{
			if(amesartl->buffer) free(amesartl->buffer);
			amesartl->buffer = NULL;

			amesartl->width = rw;
			amesartl->height = rh;

			amesartl->buffer = calloc(amesartl->width * amesartl->height, amesartl->mode == AMRTL_RGBAMode ? sizeof(unsigned long) : sizeof(unsigned char));

		}

		if(amesartl->outputhandler)
		{
			struct Library *outputhandlerBase = amesartl->outputhandler;
			ResizeOutputHandler();
		}
	}
}


static void write_rgba_span_rgba( GLcontext *ctx,
                                  GLuint n, GLint x, GLint y,
                                  CONST GLubyte rgba[][4],
                                  const GLubyte mask[] )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	unsigned long *bp;
	const GLubyte *mi;
	const unsigned long *rgbap;

	y = amesartl->wheight-1-y;
	bp = amesartl->buffer+y*amesartl->width+x;
	rgbap = (unsigned long *)rgba;		/* Nasty? */
	mi = mask;

	if (mask)
	{
		QUICKLOOP1(n,
			{
				if (*mi)
					*bp = *rgbap;
				mi++;
				bp++;
				rgbap++;
			}
		)
	}
	else
	{
		memcpy(bp,rgbap,n*4);
	}
}


static void write_rgba_span_argb( GLcontext *ctx,
                                  GLuint n, GLint x, GLint y,
                                  CONST GLubyte rgba[][4],
                                  const GLubyte mask[] )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	unsigned long *bp;
	const GLubyte *mi;
	const unsigned long *rgbap;

	y = amesartl->wheight-1-y;
	bp = amesartl->buffer+y*amesartl->width+x;
	rgbap = (unsigned long *)rgba;		/* Nasty? */
	mi = mask;

	if (mask)
	{
		QUICKLOOP1(n,
			{
				if (*mi)
					*bp = RGBA2ARGB(*rgbap);
				mi++;
				bp++;
				rgbap++;
			}
		)
	}
	else
	{
		QUICKLOOP1(n,
			{
				*bp = RGBA2ARGB(*rgbap);
				bp++;
				rgbap++;
			}
		)
	}
}


static void write_rgb_span_rgba( GLcontext *ctx,
                                 GLuint n, GLint x, GLint y,
                                 CONST GLubyte rgb[][3],
                                 const GLubyte mask[] )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	unsigned long *bp;
	const GLubyte *mi;
	const GLubyte *rgbp;

	y = amesartl->wheight-1-y;
	bp = amesartl->buffer+y*amesartl->width+x;
	rgbp = (const GLubyte *)rgb;
	mi = mask;

	if (mask)
	{
		QUICKLOOP1(n,
			{
				if (*mi)
					*bp = RGB2RGBA(rgbp);
				mi++;
				bp++;
				rgbp+=3;
			}
		)
	}
	else
	{
		QUICKLOOP1(n,
			{
				*bp = RGB2RGBA(rgbp);
				bp++;
				rgbp+=3;
			}
		)
	}
}


static void write_rgb_span_argb( GLcontext *ctx,
                                 GLuint n, GLint x, GLint y,
                                 CONST GLubyte rgb[][3],
                                 const GLubyte mask[] )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	unsigned long *bp;
	const GLubyte *mi;
	const GLubyte *rgbp;

	y = amesartl->wheight-1-y;
	bp = amesartl->buffer+y*amesartl->width+x;
	rgbp = (const GLubyte *)rgb;
	mi = mask;

	if (mask)
	{
		QUICKLOOP1(n,
			{
				if (*mi)
					*bp = RGB2ARGB(rgbp);
				mi++;
				bp++;
				rgbp+=3;
			}
		)
	}
	else
	{
		QUICKLOOP1(n,
			{
				*bp = RGB2ARGB(rgbp);
				bp++;
				rgbp+=3;
			}
		)
	}
}


static void write_monorgba_span( GLcontext *ctx,
                                 GLuint n, GLint x, GLint y,
                                 const GLubyte mask[])
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	unsigned long *bp;
	const GLubyte *mi;
	unsigned long p;

	y = amesartl->wheight-1-y;
	bp = amesartl->buffer+y*amesartl->width+x;
	mi = mask;
	p = amesartl->pixel;

	if(mask)
	{
		QUICKLOOP1(n,
			{
				if (*mi)
					*bp = p;
				mi++;
				bp++;
			}
		)
	}
	else
	{
		QUICKLOOP16(n,
			{
				*bp = p;
				mi++;
				bp++;
			}
		)
	}
}


static void write_rgba_pixels_rgba( GLcontext *ctx,
                                    GLuint n, const GLint x[], const GLint y[],
                                    CONST GLubyte rgba[][4],
                                    const GLubyte mask[] )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	const GLubyte *mi;
	const unsigned long *rgbap;
	const GLint *xi,*yi;

	rgbap = (unsigned long *)rgba;		/* Nasty? */
	mi = mask;
	xi = x;
	yi = y;

	if(mask)
	{
		QUICKLOOP1(n,
			{
				if (*mi)
					*(amesartl->buffer + (amesartl->wheight-1-*yi) * amesartl->width + *xi) = *rgbap;
				mi++;
				rgbap++;
				xi++;
				yi++;
			}
		)
	}
	else
	{
		QUICKLOOP1(n,
			{
				*(amesartl->buffer + (amesartl->wheight-1-*yi) * amesartl->width + *xi) = *rgbap;
				rgbap++;
				xi++;
				yi++;
			}
		)
	}
}


static void write_rgba_pixels_argb( GLcontext *ctx,
                                    GLuint n, const GLint x[], const GLint y[],
                                    CONST GLubyte rgba[][4],
                                    const GLubyte mask[] )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	const GLubyte *mi;
	const unsigned long *rgbap;
	const GLint *xi,*yi;

	rgbap = (unsigned long *)rgba;		/* Nasty? */
	mi = mask;
	xi = x;
	yi = y;

	if(mask)
	{
		QUICKLOOP1(n,
			{
				if (*mi)
					*(amesartl->buffer + (amesartl->wheight-1-*yi) * amesartl->width + *xi) = RGBA2ARGB(*rgbap);
				mi++;
				rgbap++;
				xi++;
				yi++;
			}
		)
	}
	else
	{
		QUICKLOOP1(n,
			{
				*(amesartl->buffer + (amesartl->wheight-1-*yi) * amesartl->width + *xi) = RGBA2ARGB(*rgbap);
				rgbap++;
				xi++;
				yi++;
			}
		)
	}
}


static void write_monorgba_pixels( GLcontext *ctx,
                                   GLuint n,
                                   const GLint x[], const GLint y[],
                                   const GLubyte mask[] )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	const GLubyte *mi;
	const GLint *xi,*yi;
	unsigned long p;

	mi = mask;
	xi = x;
	yi = y;
	p = amesartl->pixel;

	if(mask)
	{
		QUICKLOOP1(n,
			{
				if (*mi)
					*(amesartl->buffer + (amesartl->wheight-1-*yi) * amesartl->width + *xi) = p;
				mi++;
				xi++;
				yi++;
			}
		)
	}
	else
	{
		QUICKLOOP1(n,
			{
				*(amesartl->buffer + (amesartl->wheight-1-*yi) * amesartl->width + *xi) = p;
				xi++;
				yi++;
			}
		)
	}
}


static void write_index32_span( GLcontext *ctx,
                                GLuint n, GLint x, GLint y,
                                const GLuint index[],
                                const GLubyte mask[] )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	unsigned char *bbp;
	const GLuint *ii;
	const GLubyte *mi;

	y = amesartl->wheight-1-y;
	bbp = ((unsigned char *)amesartl->buffer)+y*amesartl->width+x;
	ii = index;
	mi = mask;

	if(mask)
	{
		QUICKLOOP1(n,
			{
				if (*mi)
					*bbp = (GLubyte) *ii;
				mi++;
				bbp++;
				ii++;
			}
		)
	}
	else
	{
		QUICKLOOP16(n,
			{
				*bbp = (GLubyte) *ii;
				bbp++;
				ii++;
			}
		)
	}
}


static void write_index8_span( GLcontext *ctx,
                               GLuint n, GLint x, GLint y,
                               const GLubyte index[],
                               const GLubyte mask[] )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	unsigned char *bbp;
	const GLubyte *ii;
	const GLubyte *mi;

	y = amesartl->wheight-1-y;
	bbp = ((unsigned char *)amesartl->buffer)+y*amesartl->width+x;
	ii = index;
	mi = mask;

	if(mask)
	{
		QUICKLOOP1(n,
			{
				if (*mi)
					*bbp = *ii;
				mi++;
				bbp++;
				ii++;
			}
		)
	}
	else
	{
		memcpy(bbp,ii,n);
	}
}


static void write_monoindex_span( GLcontext *ctx,
                                  GLuint n,GLint x,GLint y,const GLubyte mask[] )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	unsigned char *bbp;
	unsigned char p;
	const GLubyte *mi;

	y = amesartl->wheight-1-y;
	bbp = ((unsigned char *)amesartl->buffer)+y*amesartl->width+x;
	mi = mask;
	p = (unsigned char)(amesartl->pixel);

	if(mask)
	{
		QUICKLOOP1(n,
			{
				if (*mi)
					*bbp = p;
				mi++;
				bbp++;
			}
		)
	}
	else
	{
		memset(bbp,p,n);
	}
}


static void write_index32_pixels( GLcontext *ctx,
                                  GLuint n, const GLint x[], const GLint y[],
                                  const GLuint index[], const GLubyte mask[] )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	const GLuint *ii;
	const GLubyte *mi;
	const GLint *xi,*yi;

	ii = index;
	mi = mask;
	xi = x;
	yi = y;

	if(mask)
	{
		QUICKLOOP1(n,
			{
				if (*mi)
					*(((unsigned char *)amesartl->buffer) + (amesartl->wheight-1-*yi) * amesartl->width + *xi) = (GLubyte) *ii;
				mi++;
				ii++;
				xi++;
				yi++;
			}
		)
	}
	else
	{
		QUICKLOOP1(n,
			{
				*(((unsigned char *)amesartl->buffer) + (amesartl->wheight-1-*yi) * amesartl->width + *xi) = (GLubyte) *ii;
				ii++;
				xi++;
				yi++;
			}
		)
	}
}


static void write_monoindex_pixels( GLcontext *ctx,
                                    GLuint n,
                                    const GLint x[], const GLint y[],
                                    const GLubyte mask[] )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	unsigned char p;
	const GLubyte *mi;
	const GLint *xi,*yi;

	p = (unsigned char)(amesartl->pixel);
	mi = mask;
	xi = x;
	yi = y;

	if(mask)
	{
		QUICKLOOP1(n,
			{
				if (*mi)
					*(((unsigned char *)amesartl->buffer) + (amesartl->wheight-1-*yi) * amesartl->width + *xi) = p;
				mi++;
				xi++;
				yi++;
			}
		)
	}
	else
	{
		QUICKLOOP1(n,
			{
				*(((unsigned char *)amesartl->buffer) + (amesartl->wheight-1-*yi) * amesartl->width + *xi) = p;
				xi++;
				yi++;
			}
		)
	}
}


static void read_index32_span( GLcontext *ctx,
                               GLuint n, GLint x, GLint y, GLuint index[])
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	const unsigned char *bbp;
	GLuint *ii;

	y = amesartl->wheight-1-y;
	bbp = ((unsigned char *)amesartl->buffer)+y*amesartl->width+x;
	ii = index;

	QUICKLOOP1(n,
		{
			*ii = (GLuint) *bbp;
			ii++;
			bbp++;
		}
	)
}


static void read_rgba_span_rgba( GLcontext *ctx,
                                 GLuint n, GLint x, GLint y,
                                 GLubyte rgba[][4] )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	const unsigned long *bp;

	y = amesartl->wheight-1-y;
	bp = amesartl->buffer+y*amesartl->width+x;

	memcpy(rgba, bp, n * 4);
}


static void read_rgba_span_argb( GLcontext *ctx,
                                 GLuint n, GLint x, GLint y,
                                 GLubyte rgba[][4] )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	const unsigned long *bp;
	unsigned long *rgbap;

	y = amesartl->wheight-1-y;
	bp = amesartl->buffer+y*amesartl->width+x;
	rgbap = (unsigned long *)rgba;		/* Nasty? */

	QUICKLOOP1(n,
		{
			*rgbap = ARGB2RGBA(*bp);
			bp++;
			rgbap++;
		}
	)
}


static void read_index32_pixels( GLcontext *ctx,
                                 GLuint n, const GLint x[], const GLint y[],
                                 GLuint indx[], const GLubyte mask[] )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	const GLint *xi,*yi;
	GLuint *ii;
	const GLubyte *mi;

	ii = indx;
	xi = x;
	yi = y;
	mi = mask;

	if(mask)
	{
		QUICKLOOP1(n,
			{
				if(*mi)
					*ii = (GLuint) *(((unsigned char *)amesartl->buffer) + (amesartl->wheight-1-*yi) * amesartl->width + *xi);
				mi++;
				xi++;
				yi++;
				ii++;
			}
		)
	}
	else
	{
		QUICKLOOP1(n,
			{
				*ii = (GLuint) *(((unsigned char *)amesartl->buffer) + (amesartl->wheight-1-*yi) * amesartl->width + *xi);
				xi++;
				yi++;
				ii++;
			}
		)
	}
}


static void read_rgba_pixels_rgba( GLcontext *ctx,
                                   GLuint n, const GLint x[], const GLint y[],
                                   GLubyte rgba[][4],
                                   const GLubyte mask[] )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	unsigned long *rgbap;
	const GLint *xi,*yi;
	const GLubyte *mi;

	rgbap = (unsigned long *)rgba;
	xi = x;
	yi = y;
	mi = mask;

	if(mask)
	{
		QUICKLOOP1(n,
			{
				if(*mi)
					*rgbap = *(amesartl->buffer + (amesartl->wheight-1-*yi) *amesartl->width + *xi);
				mi++;
				rgbap++;
				xi++;
				yi++;
			}
		)
	}
	else
	{
		QUICKLOOP1(n,
			{
				*rgbap = *(amesartl->buffer + (amesartl->wheight-1-*yi) *amesartl->width + *xi);
				rgbap++;
				xi++;
				yi++;
			}
		)
	}
}


static void read_rgba_pixels_argb( GLcontext *ctx,
                                   GLuint n, const GLint x[], const GLint y[],
                                   GLubyte rgba[][4],
                                   const GLubyte mask[] )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	unsigned long *rgbap;
	const GLint *xi,*yi;
	const GLubyte *mi;

	rgbap = (unsigned long *)rgba;
	xi = x;
	yi = y;
	mi = mask;

	if(mask)
	{
		QUICKLOOP1(n,
			{
				if(*mi)
					*rgbap = ARGB2RGBA(*(amesartl->buffer + (amesartl->wheight-1-*yi) *amesartl->width + *xi));
				mi++;
				rgbap++;
				xi++;
				yi++;
			}
		)
	}
	else
	{
		QUICKLOOP1(n,
			{
				*rgbap = ARGB2RGBA(*(amesartl->buffer + (amesartl->wheight-1-*yi) *amesartl->width + *xi));
				rgbap++;
				xi++;
				yi++;
			}
		)
	}
}


static char *extension_string( GLcontext *ctx )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	/* OPTIONAL FUNCTION */

	return NULL;
}


static void finish( GLcontext *ctx )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	/* OPTIONAL FUNCTION: implements glFinish if possible */
}


static void flush( GLcontext *ctx )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	/* OPTIONAL FUNCTION: implements glFlush if possible */

	/* OK. The big one. Dump the buffer to the window */

	if(amesartl->outputhandler)
	{
		struct Library *outputhandlerBase = amesartl->outputhandler;
		ProcessOutput();
	}
}


static GLboolean index_mask( GLcontext *ctx, GLuint mask )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	/* OPTIONAL FUNCTION: implement glIndexMask if possible, else
	 * return GL_FALSE
	 */
	return(GL_FALSE);
}


static GLboolean color_mask( GLcontext *ctx,
                             GLboolean rmask, GLboolean gmask,
                             GLboolean bmask, GLboolean amask)
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	/* OPTIONAL FUNCTION: implement glColorMask if possible, else
	 * return GL_FALSE
	 */
	return(GL_FALSE);
}


static GLboolean logicop( GLcontext *ctx, GLenum op )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	/*
	 * OPTIONAL FUNCTION:
	 * Implements glLogicOp if possible.  Return GL_TRUE if the device driver
	 * can perform the operation, otherwise return GL_FALSE.  If GL_FALSE
	 * is returned, the logic op will be done in software by Mesa.
	 */
	return(GL_FALSE);
}


static void dither( GLcontext *ctx, GLboolean enable )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	/* OPTIONAL FUNCTION: enable/disable dithering if applicable */
}


static void error( GLcontext *ctx )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	/* OPTIONAL FUNCTION: catch error */
}



/**********************************************************************/
/*****                 Optimized triangle rendering               *****/
/**********************************************************************/
/* (Based on osmesa.c) */

/*
 * Smooth-shaded, z triangle, RGBA color.
 */
static void smooth_color_z_triangle_rgba( GLcontext *ctx, GLuint v0, GLuint v1,
                                          GLuint v2, GLuint pv )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
#define INTERP_Z 1
#define INTERP_RGB 1
#define INTERP_ALPHA 1
#define INNER_LOOP( LEFT, RIGHT, Y )							\
{																\
   const GLint len = RIGHT-LEFT;								\
   unsigned long *bp;											\
   GLdepth *zr = zRow;											\
   GLdepth z;													\
   bp = amesartl->buffer+(amesartl->wheight-1-Y)*amesartl->width+LEFT;	\
   QUICKLOOP1(len,												\
      {															\
         z = FixedToDepth(ffz);									\
         if (z < *zr) {											\
            *zr = z;											\
            *bp = RGBA(FixedToInt(ffr), FixedToInt(ffg),		\
                       FixedToInt(ffb), FixedToInt(ffa) );		\
         }														\
         ffr += fdrdx;  ffg += fdgdx;  ffb += fdbdx;  ffa += fdadx;	\
         ffz += fdzdx;											\
         bp++;													\
         zr++;													\
      }															\
   )															\
}
#include "tritemp.h"
}


/*
 * Flat-shaded, z triangle, RGBA color.
 */
static void flat_color_z_triangle_rgba( GLcontext *ctx, GLuint v0, GLuint v1,
                                        GLuint v2, GLuint pv )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
#define INTERP_Z 1
#define SETUP_CODE					\
   GLubyte r = VB->Color[pv][0];	\
   GLubyte g = VB->Color[pv][1];	\
   GLubyte b = VB->Color[pv][2];	\
   GLubyte a = VB->Color[pv][3];	\
   unsigned long p = RGBA(r,g,b,a);

#define INNER_LOOP( LEFT, RIGHT, Y )							\
{																\
   const GLint len = RIGHT-LEFT;								\
   unsigned long *bp;											\
   GLdepth *zr = zRow;											\
   GLdepth z;													\
   bp = amesartl->buffer+(amesartl->wheight-1-Y)*amesartl->width+LEFT;	\
   QUICKLOOP1(len,												\
      {															\
         z = FixedToDepth(ffz);									\
         if (z < *zr) {											\
            *zr = z;											\
            *bp = p;											\
         }														\
         ffz += fdzdx;											\
         bp++;													\
         zr++;													\
      }															\
   )															\
}
#include "tritemp.h"
}



/*
 * Smooth-shaded, z-less triangle, RGBA color.
 */
static void smooth_color_triangle_rgba( GLcontext *ctx, GLuint v0, GLuint v1,
                                        GLuint v2, GLuint pv )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
#define INTERP_RGB 1
#define INTERP_ALPHA 1
#define INNER_LOOP( LEFT, RIGHT, Y )							\
{																\
   const GLint len = RIGHT-LEFT;								\
   unsigned long *bp;											\
   bp = amesartl->buffer+(amesartl->wheight-1-Y)*amesartl->width+LEFT;	\
   QUICKLOOP1(len,												\
      {															\
         *bp = RGBA(FixedToInt(ffr), FixedToInt(ffg),			\
                    FixedToInt(ffb), FixedToInt(ffa) );			\
         ffr += fdrdx;  ffg += fdgdx;  ffb += fdbdx;  ffa += fdadx;	\
         bp++;													\
      }															\
   )															\
}
#include "tritemp.h"
}


/*
 * Flat-shaded, z triangle, RGBA color.
 */
static void flat_color_triangle_rgba( GLcontext *ctx, GLuint v0, GLuint v1,
                                      GLuint v2, GLuint pv )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
#define SETUP_CODE					\
   GLubyte r = VB->Color[pv][0];	\
   GLubyte g = VB->Color[pv][1];	\
   GLubyte b = VB->Color[pv][2];	\
   GLubyte a = VB->Color[pv][3];	\
   unsigned long p = RGBA(r,g,b,a);

#define INNER_LOOP( LEFT, RIGHT, Y )							\
{																\
   const GLint len = RIGHT-LEFT;								\
   unsigned long *bp;											\
   bp = amesartl->buffer+(amesartl->wheight-1-Y)*amesartl->width+LEFT;	\
   QUICKLOOP1(len,												\
      {															\
         *bp = p;												\
         bp++;													\
      }															\
   )															\
}
#include "tritemp.h"
}


/*
 * Smooth-shaded, z triangle, ARGB color.
 */
static void smooth_color_z_triangle_argb( GLcontext *ctx, GLuint v0, GLuint v1,
                                          GLuint v2, GLuint pv )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
#define INTERP_Z 1
#define INTERP_RGB 1
#define INTERP_ALPHA 1
#define INNER_LOOP( LEFT, RIGHT, Y )							\
{																\
   const GLint len = RIGHT-LEFT;								\
   unsigned long *bp;											\
   GLdepth *zr = zRow;											\
   GLdepth z;													\
   bp = amesartl->buffer+(amesartl->wheight-1-Y)*amesartl->width+LEFT;	\
   QUICKLOOP1(len,												\
      {															\
         z = FixedToDepth(ffz);									\
         if (z < *zr) {											\
            *zr = z;											\
            *bp = ARGB(FixedToInt(ffr), FixedToInt(ffg),		\
                       FixedToInt(ffb), FixedToInt(ffa) );		\
         }														\
         ffr += fdrdx;  ffg += fdgdx;  ffb += fdbdx;  ffa += fdadx;	\
         ffz += fdzdx;											\
         bp++;													\
         zr++;													\
      }															\
   )															\
}
#include "tritemp.h"
}


/*
 * Flat-shaded, z triangle, ARGB color.
 */
static void flat_color_z_triangle_argb( GLcontext *ctx, GLuint v0, GLuint v1,
                                        GLuint v2, GLuint pv )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
#define INTERP_Z 1
#define SETUP_CODE					\
   GLubyte r = VB->Color[pv][0];	\
   GLubyte g = VB->Color[pv][1];	\
   GLubyte b = VB->Color[pv][2];	\
   GLubyte a = VB->Color[pv][3];	\
   unsigned long p = ARGB(r,g,b,a);

#define INNER_LOOP( LEFT, RIGHT, Y )							\
{																\
   const GLint len = RIGHT-LEFT;								\
   unsigned long *bp;											\
   GLdepth *zr = zRow;											\
   GLdepth z;													\
   bp = amesartl->buffer+(amesartl->wheight-1-Y)*amesartl->width+LEFT;	\
   QUICKLOOP1(len,												\
      {															\
         z = FixedToDepth(ffz);									\
         if (z < *zr) {											\
            *zr = z;											\
            *bp = p;											\
         }														\
         ffz += fdzdx;											\
         bp++;													\
         zr++;													\
      }															\
   )															\
}
#include "tritemp.h"
}



/*
 * Smooth-shaded, z-less triangle, ARGB color.
 */
static void smooth_color_triangle_argb( GLcontext *ctx, GLuint v0, GLuint v1,
                                        GLuint v2, GLuint pv )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
#define INTERP_RGB 1
#define INTERP_ALPHA 1
#define INNER_LOOP( LEFT, RIGHT, Y )							\
{																\
   const GLint len = RIGHT-LEFT;								\
   unsigned long *bp;											\
   bp = amesartl->buffer+(amesartl->wheight-1-Y)*amesartl->width+LEFT;	\
   QUICKLOOP1(len,												\
      {															\
         *bp = ARGB(FixedToInt(ffr), FixedToInt(ffg),			\
                    FixedToInt(ffb), FixedToInt(ffa) );			\
         ffr += fdrdx;  ffg += fdgdx;  ffb += fdbdx;  ffa += fdadx;	\
         bp++;													\
      }															\
   )															\
}
#include "tritemp.h"
}


/*
 * Flat-shaded, z triangle, ARGB color.
 */
static void flat_color_triangle_argb( GLcontext *ctx, GLuint v0, GLuint v1,
                                      GLuint v2, GLuint pv )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
#define SETUP_CODE					\
   GLubyte r = VB->Color[pv][0];	\
   GLubyte g = VB->Color[pv][1];	\
   GLubyte b = VB->Color[pv][2];	\
   GLubyte a = VB->Color[pv][3];	\
   unsigned long p = ARGB(r,g,b,a);

#define INNER_LOOP( LEFT, RIGHT, Y )							\
{																\
   const GLint len = RIGHT-LEFT;								\
   unsigned long *bp;											\
   bp = amesartl->buffer+(amesartl->wheight-1-Y)*amesartl->width+LEFT;	\
   QUICKLOOP1(len,												\
      {															\
         *bp = p;												\
         bp++;													\
      }															\
   )															\
}
#include "tritemp.h"
}


/*
 * Return pointer to an accelerated triangle function if possible.
 */
static triangle_func choose_triangle_function( GLcontext *ctx )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	BOOL use_rgba;

	use_rgba = amesartl->rgbaorder == ORDER_RGBA ? TRUE : FALSE;

	if(amesartl->mode != AMRTL_RGBAMode)
		return NULL;

	if (ctx->Polygon.SmoothFlag)     return NULL;
	if (ctx->Polygon.StippleFlag)    return NULL;
	if (ctx->Texture.Enabled)        return NULL;

	if (ctx->RasterMask==DEPTH_BIT
	    && ctx->Depth.Func==GL_LESS
	    && ctx->Depth.Mask==GL_TRUE)
	{
		if (ctx->Light.ShadeModel==GL_SMOOTH) {
			return use_rgba ? smooth_color_z_triangle_rgba : smooth_color_z_triangle_argb;
		}
		else
		{
			return use_rgba ? flat_color_z_triangle_rgba : flat_color_z_triangle_argb;
		}
	}
	else if(ctx->RasterMask==0)
	{
		if (ctx->Light.ShadeModel==GL_SMOOTH) {
			return use_rgba ? smooth_color_triangle_rgba : smooth_color_triangle_argb;
		}
		else
		{
			return use_rgba ? flat_color_triangle_rgba : flat_color_triangle_argb;
		}
	}

	return NULL;
}



/**********************************************************************/
/**********************************************************************/

static void setup_DD_pointers( GLcontext *ctx )
{
	struct amiga_mesa_rtl_context *amesartl = (struct amiga_mesa_rtl_context *) ctx->DriverCtx;
	BOOL use_rgba;
	/* Initialize all the pointers in the DD struct.  Do this whenever */
	/* a new context is made current or we change buffers via set_buffer! */

	use_rgba = amesartl->rgbaorder == ORDER_RGBA ? TRUE : FALSE;

	ctx->Driver.RendererString = renderer_string;
	ctx->Driver.UpdateState = setup_DD_pointers;

	ctx->Driver.ClearIndex = clear_index;
    ctx->Driver.ClearColor = use_rgba ? clear_color_rgba : clear_color_argb;
	ctx->Driver.Clear = clear;

	ctx->Driver.Index = set_index;
	ctx->Driver.Color = use_rgba ? set_color_rgba : set_color_argb;

	ctx->Driver.SetBuffer = set_buffer;
	ctx->Driver.GetBufferSize = get_buffer_size;

	/* Pixel/span writing functions: */
	ctx->Driver.WriteRGBASpan        = use_rgba ? write_rgba_span_rgba : write_rgba_span_argb;
	ctx->Driver.WriteRGBSpan         = use_rgba ? write_rgb_span_rgba : write_rgb_span_argb;
	ctx->Driver.WriteMonoRGBASpan    = write_monorgba_span;
	ctx->Driver.WriteRGBAPixels      = use_rgba ? write_rgba_pixels_rgba : write_rgba_pixels_argb;
	ctx->Driver.WriteMonoRGBAPixels  = write_monorgba_pixels;
	ctx->Driver.WriteCI32Span        = write_index32_span;
	ctx->Driver.WriteCI8Span         = write_index8_span;
	ctx->Driver.WriteMonoCISpan      = write_monoindex_span;
	ctx->Driver.WriteCI32Pixels      = write_index32_pixels;
	ctx->Driver.WriteMonoCIPixels    = write_monoindex_pixels;

	/* Pixel/span reading functions: */
	ctx->Driver.ReadCI32Span         = read_index32_span;
	ctx->Driver.ReadRGBASpan         = use_rgba ? read_rgba_span_rgba : read_rgba_span_argb;
	ctx->Driver.ReadCI32Pixels       = read_index32_pixels;
	ctx->Driver.ReadRGBAPixels       = use_rgba ? read_rgba_pixels_rgba : read_rgba_pixels_argb;

	ctx->Driver.TriangleFunc = choose_triangle_function( ctx );

	/*
	 * OPTIONAL FUNCTIONS:  these may be left uninitialized if the device
	 * driver can't/needn't implement them.
	 */
	ctx->Driver.Flush = flush;
#if 0
	ctx->Driver.Finish = finish;
	ctx->Driver.IndexMask = index_mask;
	ctx->Driver.ColorMask = color_mask;
	ctx->Driver.LogicOp = logicop;
	ctx->Driver.Dither = dither;
	ctx->Driver.Error = error;
	ctx->Driver.NearFar = near_far;
	ctx->GetParameteri = get_parameter_i;

	ctx->Viewport = viewport;
#endif
}



/**********************************************************************/
/*****               FOO/Mesa API Functions                       *****/
/**********************************************************************/

static struct amiga_mesa_rtl_context *Current = NULL;
struct Library *mesamainBase = NULL;
static BOOL myGL = FALSE;
static BOOL haveGL = FALSE;

static int GetOutputHandlerEnv(char *str, char *outputtype)
{
	int l;
	char *quant;

	if(outputtype)
	{
		quant = calloc(strlen(outputtype) + 16,sizeof(char));
		if(!quant)
			return -1;

		strcpy(quant,"AmigaMesaRTL/");
		strcat(quant,outputtype);
		l = GetVar(quant,str,32,0);
		free(quant);
		if(l != -1)
			return l;
	}

	l = GetVar("AmigaMesaRTL/OutputHandler",str,32,0);
	if(l != -1)
		return l;

	strcpy(str,"dl1");
	return 3;
}


static struct Library *GetMyBase(void)
{
	return((struct Library *)getreg(REG_A6));
}


void CloseGL(void)
{
	if(!haveGL)
		return;

	haveGL = FALSE;

	if(mesamainBase)
		mesaSetAttrs(
				MESA_DriverBase,	NULL,
				TAG_END);

	if(myGL)
	{
		if(mesamainBase) CloseLibrary(mesamainBase);
		mesamainBase = NULL;
	}
	myGL = FALSE;
}


void OpenGL(char *gname_arg)
{
	/* Can only set GL library once (at the moment) */
	if(haveGL)
		return;

	mesamainBase = OpenLibrary("mesamain.library",3);

	if(!mesamainBase)
		return;

	if(mesamainBase->lib_Version != 3)
	{
		CloseLibrary(mesamainBase);
		return;
	}

	haveGL = TRUE;
	myGL = TRUE;

	mesaSetAttrs(
				MESA_DriverBase, GetMyBase(),
				TAG_END);
}


void SwitchGL(struct Library *newGL)
{
	/* Can only set GL library once (at the moment) */
	if((haveGL && newGL) || ((!haveGL) && (!newGL)))
		return;

	CloseGL();

	mesamainBase = newGL;

	if((!mesamainBase) || (mesamainBase->lib_Version != 3))
		return;

	haveGL = TRUE;

	mesaSetAttrs(
				MESA_DriverBase, GetMyBase(),
				TAG_END);
}


CBMLIB_DESTRUCTOR(AmigaMesaRTLDestruct)
{
	CloseGL();
}


__asm __saveds AmigaMesaRTLContext AmigaMesaRTLCreateContextA( register __a0 struct TagItem *tags )
{
	struct amiga_mesa_rtl_context *c;
	GLboolean rgb_flag, alpha_flag, db_flag;
	GLint depth_bits, stencil_bits, accum_bits, index_bits;
	GLfloat red_scale, green_scale, blue_scale, alpha_scale;
	GLint red_bits, green_bits, blue_bits, alpha_bits;
	char *strp,str[32],qname[48];
	ULONG qver;
	ULONG mode;
	BOOL haveoutputhandler;
	struct TagItem *tag, *ctags;

	c = (struct amiga_mesa_rtl_context *) calloc( 1, sizeof(struct amiga_mesa_rtl_context) );
	if (!c)
	{
		AmigaMesaRTLDestroyContext( c );
		return NULL;
	}

	if(tag = FindTagItem(AMRTL_GL,tags))
		OpenGL((char *)tag->ti_Data);
	if(tag = FindTagItem(AMRTL_GLBase,tags))
		SwitchGL((struct Library *)tag->ti_Data);

	mode = GetTagData(AMRTL_Mode, AMRTL_RGBAMode, tags);
	mode = GetTagData(AMRTL_RGBAMode, (ULONG)(mode == AMRTL_RGBAMode), tags) ? AMRTL_RGBAMode : AMRTL_IndexMode;
	mode = GetTagData(AMRTL_IndexMode, (ULONG)(mode == AMRTL_IndexMode), tags) ? AMRTL_IndexMode : AMRTL_RGBAMode;

	if(mode == AMRTL_RGBAMode)
	{
		/* RGB(A) mode */
		rgb_flag = GL_TRUE;
		alpha_flag = GL_FALSE;
		db_flag = GL_FALSE;
		depth_bits = DEPTH_BITS;
		stencil_bits = STENCIL_BITS;
		accum_bits = ACCUM_BITS;
		index_bits = 0;
		red_scale = 255.0;
		green_scale = 255.0;
		blue_scale = 255.0;
		alpha_scale = 255.0;
		red_bits = 8;
		green_bits = 8;
		blue_bits = 8;
		alpha_bits = 0;
	}
	else
	{
		/* color index mode */
		rgb_flag = GL_FALSE;
		alpha_flag = GL_FALSE;
		db_flag = GL_FALSE;
		depth_bits = DEPTH_BITS;
		stencil_bits = STENCIL_BITS;
		accum_bits = ACCUM_BITS;
		index_bits = 8;
		red_scale = 0.0;
		green_scale = 0.0;
		blue_scale = 0.0;
		alpha_scale = 0.0;
		red_bits = 8;
		green_bits = 8;
		blue_bits = 8;
		alpha_bits = 0;
	}

	/* Create core visual */
	c->gl_visual = mesaCreateVisual( rgb_flag,
	                                 alpha_flag,
	                                 db_flag,
	                                 GL_FALSE,
	                                 depth_bits,
	                                 stencil_bits,
	                                 accum_bits,
	                                 index_bits,
	                                 red_bits, green_bits, blue_bits, alpha_bits );

	if(!c->gl_visual)
	{
		AmigaMesaRTLDestroyContext( c );
		return NULL;
	}

	c->gl_ctx = mesaCreateContext( c->gl_visual,
	                               NULL,
	                               (void *) c,
	                               GL_TRUE );

	if(!c->gl_ctx)
	{
		AmigaMesaRTLDestroyContext( c );
		return NULL;
	}

	c->gl_buffer = mesaCreateFramebuffer( c->gl_visual );
	if(!c->gl_buffer)
	{
		AmigaMesaRTLDestroyContext( c );
		return NULL;
	}

	c->mode = mode;
	c->buffer = NULL;
	c->width = 0;		/* No buffer allocated here */
	c->height = 0;
	c->wwidth = 0;		/* Some default size, just to be safe */
	c->wheight = 0;
	c->reqwidth = GetTagData(AMRTL_OutputWidth, 8, tags);
	c->reqheight = GetTagData(AMRTL_OutputHeight, 8, tags);
	c->justcreated = TRUE;

	c->pixel = 0;
	c->clearpixel = 0;

	c->outputhandler = NULL;
	haveoutputhandler = FALSE;

	qver = 2;
	if(GetVar("AmigaMesaRTL/OutputHandlerVersion",str,32,0) != -1)
		qver = atol(str);
	qver = GetTagData(AMRTL_OutputHandlerVersion, qver, tags);

	if(tag = FindTagItem(AMRTL_OutputHandlerBase,tags))
	{
		c->outputhandler = (struct Library *)tag->ti_Data;
		c->myoutputhandler = FALSE;
		if(c->outputhandler)
			haveoutputhandler = TRUE;
	}
	else if(tag = FindTagItem(AMRTL_OutputHandler, tags))
	{
		strp = (char *)tag->ti_Data;
		if(strp)
		{
			strcpy(qname,"outputhandlers/");
			strncat(qname,strp,32);

			c->outputhandler = OpenLibrary(qname,qver);
			c->myoutputhandler = TRUE;
			haveoutputhandler = TRUE;
		}
	}
	else if(GetOutputHandlerEnv(str,GetTagData(OH_OutputType,NULL,tags)) != -1)
	{
		strcpy(qname,"outputhandlers/");
		strncat(qname,str,32);

		c->outputhandler = OpenLibrary(qname,qver);
		c->myoutputhandler = TRUE;
		haveoutputhandler = TRUE;
	}

	if(haveoutputhandler && ((!c->outputhandler) || (c->outputhandler->lib_Version < 2)))
	{
		AmigaMesaRTLDestroyContext( c );
		return NULL;
	}

	if(c->outputhandler)
	{
		struct Library *outputhandlerBase = c->outputhandler;

		ctags = CloneTagItems(tags);
		if(!ctags)
		{
			AmigaMesaRTLDestroyContext( c );
			return NULL;
		}

		if(!InitOutputHandler(c, OH_DriverBase, GetMyBase(), TAG_MORE, ctags))
		{
			FreeTagItems(ctags);
			AmigaMesaRTLDestroyContext( c );
			return NULL;
		}

		FreeTagItems(ctags);

		if(c->mode == AMRTL_RGBAMode)
		{
			if(!GetOutputHandlerAttr(OH_RGBAOrder,&(c->rgbaorder)))
				c->rgbaorder = ORDER_RGBA;

			if((c->rgbaorder != ORDER_RGBA) && (c->rgbaorder != ORDER_ARGB))
			{
				AmigaMesaRTLDestroyContext( c );
				return NULL;
			}
		}
	}

	c->a4 = getreg(REG_A4);

	setup_DD_pointers( c->gl_ctx );

	return c;
}


__asm __saveds void AmigaMesaRTLDestroyContext( register __a0 AmigaMesaRTLContext ca )
{
	struct amiga_mesa_rtl_context *c = (struct amiga_mesa_rtl_context *) ca;

	if(c)
	{
		if(c->outputhandler)
		{
			struct Library *outputhandlerBase = c->outputhandler;
			DeleteOutputHandler();

			if(c->myoutputhandler)
				CloseLibrary(c->outputhandler);
		}
		c->outputhandler = NULL;

		if(c->gl_buffer) mesaDestroyFramebuffer( c->gl_buffer );
		c->gl_buffer = NULL;

		if(c->gl_ctx) mesaDestroyContext( c->gl_ctx );
		c->gl_ctx = NULL;

		if(c->gl_visual) mesaDestroyVisual( c->gl_visual );
		c->gl_visual = NULL;

		if(c->buffer) free(c->buffer);
		c->buffer = NULL;

		free(c);
	}
	c = NULL;
}



/*
 * Make the specified context the current one
 * Might also want to specify the window/drawable here, like for GLX.
 */
__asm __saveds void AmigaMesaRTLMakeCurrent( register __a0 AmigaMesaRTLContext ca )
{
	struct amiga_mesa_rtl_context *c = (struct amiga_mesa_rtl_context *) ca;

	mesaMakeCurrent( c->gl_ctx, c->gl_buffer );
	if(c->justcreated)
	{
		check_resized(c);
		mesaViewport( c->gl_ctx, 0, 0, c->reqwidth, c->reqheight );
		c->justcreated = FALSE;
	}
	Current = c;
}


__asm __saveds AmigaMesaRTLContext AmigaMesaRTLGetCurrentContext( void )
{
	return Current;
}


__asm __saveds void AmigaMesaRTLSetIndexRGBTable( register __d0 int index, register __a0 ULONG *rgbtable, register __d1 int numcolours)
{
	int t;
	ULONG *tablep, *palp;

	if(Current->mode != AMRTL_IndexMode)
		return;

	if((index < 0) || (index > 255))
		return;

	if((index + numcolours - 1) > 255)
		numcolours = 255-index+1;

	if(Current->outputhandler)
	{
		struct Library *outputhandlerBase = Current->outputhandler;
		SetIndexRGBTable(index, rgbtable, numcolours);
	}

	palp = Current->indexpal[index];
	tablep = rgbtable;
	for(t=0; t<numcolours; t++)
	{
		*palp = *tablep; palp++; tablep++;	/* Red */
		*palp = *tablep; palp++; tablep++;	/* Green */
		*palp = *tablep; palp++; tablep++;	/* Blue */
	}
}


__asm __saveds void AmigaMesaRTLSetIndexRGB( register __d0 int index, register __d1 ULONG red, register __d2 ULONG green, register __d3 ULONG blue)
{
	ULONG rgbtable[3];

	rgbtable[0] = red;
	rgbtable[1] = green;
	rgbtable[2] = blue;

	AmigaMesaRTLSetIndexRGBTable(index, rgbtable, 1);
}


__asm __saveds void AmigaMesaRTLGetIndexRGB( register __d0 int index, register __a0 ULONG *red, register __a1 ULONG *green, register __a2 ULONG *blue)
{
	if(Current->mode != AMRTL_IndexMode)
		return;

	if((index < 0) || (index > 255))
		return;

	*red = Current->indexpal[index][0];
	*green = Current->indexpal[index][1];
	*blue = Current->indexpal[index][2];
}


__asm __saveds ULONG AmigaMesaRTLSetContextAttrsA(register __a0 AmigaMesaRTLContext ca, register __a1 struct TagItem *tags)
{
	struct amiga_mesa_rtl_context *c = (struct amiga_mesa_rtl_context *) ca;
	struct TagItem *tstate, *tag;
	ULONG tidata;

	if(!c)
		return(0);

	tstate = tags;
	while(tag = NextTagItem(&tstate))
	{
		tidata = tag->ti_Data;

		switch(tag->ti_Tag)
		{
			case AMRTL_OutputWidth:
				c->reqwidth=tidata;
				break;
			case AMRTL_OutputHeight:
				c->reqheight=tidata;
				break;
			default:
				{
					struct TagItem ohtags[] = { { 0, 0 }, { TAG_END } };
					ohtags[0] = *tag;
					AmigaMesaRTLSetOutputHandlerAttrsA(ca, ohtags);
				}
				break;
		}
	}

	return(0);
}


__asm __saveds ULONG AmigaMesaRTLGetContextAttr(register __d0 ULONG attr, register __a0 AmigaMesaRTLContext ca, register __a1 ULONG *data)
{
	struct amiga_mesa_rtl_context *c = (struct amiga_mesa_rtl_context *) ca;

	if(!c)
		return(0);

	switch(attr)
	{
		case AMRTL_RGBAMode:
			*((GLboolean *)data) = c->mode == AMRTL_RGBAMode;
			break;
		case AMRTL_IndexMode:
			*((GLboolean *)data) = c->mode == AMRTL_IndexMode;
			break;
		case AMRTL_OutputHandler:
			*((char **)data) = c->outputhandler->lib_IdString;
			break;
		case AMRTL_OutputHandlerVersion:
			*((ULONG *)data) = c->outputhandler->lib_Version;
			break;
		case AMRTL_OutputHandlerBase:
			*((struct Library **)data) = c->outputhandler;
			break;
		case AMRTL_BufferWidth:
			*((GLint *)data) = c->width;
			break;
		case AMRTL_BufferHeight:
			*((GLint *)data) = c->height;
			break;
		case AMRTL_Buffer:
			*((ULONG **)data) = c->buffer;
			break;
		case AMRTL_OutputWidth:
			*((GLint *)data) = c->reqwidth;
			break;
		case AMRTL_OutputHeight:
			*((GLint *)data) = c->reqheight;
			break;
		case AMRTL_IndexPalette:
			*((ULONG **)data) = (ULONG *)(c->indexpal);
			break;
		case AMRTL_Mode:
			*((ULONG *)data) = c->mode;
			break;
		case AMRTL_Resized:
			*((BOOL *)data) = check_resized(c);
			break;
		default:
			return(AmigaMesaRTLGetOutputHandlerAttr(attr, ca, data));
	}

	return(1);
}


__asm __saveds ULONG AmigaMesaRTLSetOutputHandlerAttrsA(register __a0 AmigaMesaRTLContext ca, register __a1 struct TagItem *tags)
{
	struct amiga_mesa_rtl_context *c = (struct amiga_mesa_rtl_context *) ca;

	if(c->outputhandler)
	{
		struct Library *outputhandlerBase = c->outputhandler;
		return(SetOutputHandlerAttrsA(tags));
	}

	return(0);
}


__asm __saveds ULONG AmigaMesaRTLGetOutputHandlerAttr(register __d0 ULONG attr, register __a0 AmigaMesaRTLContext ca, register __a1 ULONG *data)
{
	struct amiga_mesa_rtl_context *c = (struct amiga_mesa_rtl_context *) ca;

	if(c->outputhandler)
	{
		struct Library *outputhandlerBase = c->outputhandler;
		return(GetOutputHandlerAttr(attr,data));
	}

	return(0);
}


__asm __saveds ULONG AmigaMesaRTLSetAttrsA(register __a0 struct TagItem *tags)
{
	struct TagItem *tstate, *tag;
	ULONG tidata;

	tstate = tags;
	while(tag = NextTagItem(&tstate))
	{
		tidata = tag->ti_Data;

		switch(tag->ti_Tag)
		{
			case AMRTL_GL:
				OpenGL((char *)tidata);
				break;
			case AMRTL_GLBase:
				SwitchGL((struct Library *)tidata);
				break;
			default:
				if(Current)
				{					struct TagItem ctags[] = { { 0, 0 }, { TAG_END } };
					ctags[0] = *tag;
					AmigaMesaRTLSetContextAttrsA(Current, ctags);
				}
				break;
		}
	}

	return(0);
}


#define CHECK_GL		if(!haveGL) OpenGL(NULL)

__asm __saveds ULONG AmigaMesaRTLGetAttr(register __d0 ULONG attr, register __a0 ULONG *data)
{
	switch(attr)
	{
		case AMRTL_GL:
			CHECK_GL;
			*((char **)data) = mesamainBase->lib_IdString;
			break;
		case AMRTL_GLVersion:
			CHECK_GL;
			*((ULONG *)data) = mesamainBase->lib_Version;
			break;
		case AMRTL_GLBase:
			CHECK_GL;
			*((struct Library **)data) = mesamainBase;
			break;
		case AMRTL_HaveGL:
			*((BOOL *)data) = haveGL;
			break;
		case AMRTL_SupportsOH:
			*((BOOL *)data) = TRUE;
			break;
		default:
			if(Current)
				return(AmigaMesaRTLGetContextAttr(attr, Current, data));
			else
				return(0);
	}

	return(1);
}



/* you may need to add other FOO/Mesa functions too... */

