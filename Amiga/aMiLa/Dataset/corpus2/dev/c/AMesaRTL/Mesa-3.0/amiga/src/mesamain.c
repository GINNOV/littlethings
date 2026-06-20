/*
 * AmigaMesaRTL graphics library
 * Version:  3.0
 * Copyright (C) 1998  Jarno van der Linden
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
 * mesamain.c
 *
 * Version 2.0  13 Sep 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * Driver interface to some Mesa setup stuff
 * (Basically, context.h interface)
 * - Added automagic mesamain.library opening
 *
 * Version 3.0  04 Oct 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Changed to Mesa 3.0
 *
 */

#include <dos.h>
#include <constructor.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/utility.h>

#include <stdlib.h>
#include <string.h>

#include "gl/gl.h"
#include "gl/mesamain.h"
#include "gl/mesadriver.h"

#include "context.h"
#include "matrix.h"


struct Library *mesadriverBase = NULL;
static BOOL havedriver = FALSE;
static BOOL mydriver = FALSE;


static struct Library *GetMyBase(void)
{
	return((struct Library *)getreg(REG_A6));
}


void CloseDriver(void)
{
	if(!havedriver)
		return;
	havedriver = FALSE;

	if(mesadriverBase)
		AmigaMesaRTLSetAttrs(
					AMRTL_GLBase,	NULL,
					TAG_END);

	if(mydriver)
	{
		if(mesadriverBase) CloseLibrary(mesadriverBase);
		mesadriverBase = NULL;
	}
	mydriver = FALSE;
}


void OpenDriver(char *dname_arg)
{
	char dname[48];
	ULONG dver;
	char str[32];

	/* Can only set driver library once (at the moment) */
	if(havedriver)
		return;

	dver = 3;
	if(GetVar("AmigaMesaRTL/DriverVersion",str,32,0) != -1)
		dver = atol(str);

	if(dname_arg)
		mesadriverBase = OpenLibrary(dname_arg,dver);
	else
	{
		strcpy(dname,"MesaDrivers/amigamesartl");
		if(GetVar("AmigaMesaRTL/Driver",str,32,0) != -1)
		{
			strcpy(dname,"MesaDrivers/");
			strncat(dname,str,32);
		}

		mesadriverBase = OpenLibrary(dname,dver);
	}

	if(!mesadriverBase)
		return;

	if(mesadriverBase->lib_Version != 3)
	{
		CloseLibrary(mesadriverBase);
		return;
	}

	havedriver = TRUE;
	mydriver = TRUE;

	AmigaMesaRTLSetAttrs(
				AMRTL_GLBase, GetMyBase(),
				TAG_END);
}


void SwitchDriver(struct Library *newdriver)
{
	/* Can only set driver library once (at the moment) */
	if((havedriver && newdriver) || ((!havedriver) && (!newdriver)))
		return;

	CloseDriver();

	mesadriverBase = newdriver;

	if((!mesadriverBase) || (mesadriverBase->lib_Version != 3))
		return;

	havedriver = TRUE;

	AmigaMesaRTLSetAttrs(
				AMRTL_GLBase, GetMyBase(),
				TAG_END);
}


CBMLIB_DESTRUCTOR(mesaDestruct)
{
	CloseDriver();
}


__asm __saveds GLvisual* APIENTRY mesaCreateVisualV2( register __d0 GLboolean rgb_flag,
													register __d1 GLboolean alpha_flag,
													register __d2 GLboolean db_flag,
													register __d3 GLint depth_bits,
													register __d4 GLint stencil_bits,
													register __d5 GLint accum_bits,
													register __d6 GLint index_bits,
													register __fp0 GLfloat red_scale,
													register __fp1 GLfloat green_scale,
													register __fp2 GLfloat blue_scale,
													register __fp3 GLfloat alpha_scale,
													register __d7 GLint red_bits,
													register __a0 GLint green_bits,
													register __a1 GLint blue_bits,
													register __a2 GLint alpha_bits)
{
	return gl_create_visual(rgb_flag,
	                        alpha_flag,
	                        db_flag,
	                        FALSE,
	                        depth_bits,
	                        stencil_bits,
	                        accum_bits,
	                        index_bits,
	                        red_bits,
	                        green_bits,
	                        blue_bits,
	                        alpha_bits);
}


__asm __saveds GLvisual* APIENTRY mesaCreateVisualAV2(register __a0 void *vargs)
{
	struct mesaCreateVisualArgs {
		GLboolean rgb_flag;
		GLboolean alpha_flag;
		GLboolean db_flag;
		GLint depth_bits;
		GLint stencil_bits;
		GLint accum_bits;
		GLint index_bits;
		GLfloat red_scale;
		GLfloat green_scale;
		GLfloat blue_scale;
		GLfloat alpha_scale;
		GLint red_bits;
		GLint green_bits;
		GLint blue_bits;
		GLint alpha_bits;
	} *args;

	args = (struct mesaCreateVisualArgs *)vargs;

	return mesaCreateVisualV2(args->rgb_flag,
	                          args->alpha_flag,
	                          args->db_flag,
	                          args->depth_bits,
	                          args->stencil_bits,
	                          args->accum_bits,
	                          args->index_bits,
	                          args->red_scale,
	                          args->green_scale,
	                          args->blue_scale,
	                          args->alpha_scale,
	                          args->red_bits,
	                          args->green_bits,
	                          args->blue_bits,
	                          args->alpha_bits);
}


__asm __saveds GLvisual* APIENTRY mesaCreateVisual( register __d0 GLboolean rgb_flag,
													register __d1 GLboolean alpha_flag,
													register __d2 GLboolean db_flag,
													register __a4 GLboolean stereo_flag,
													register __d3 GLint depth_bits,
													register __d4 GLint stencil_bits,
													register __d5 GLint accum_bits,
													register __d6 GLint index_bits,
													register __d7 GLint red_bits,
													register __a0 GLint green_bits,
													register __a1 GLint blue_bits,
													register __a2 GLint alpha_bits)
{
	return gl_create_visual(rgb_flag,
	                        alpha_flag,
	                        db_flag,
	                        stereo_flag,
	                        depth_bits,
	                        stencil_bits,
	                        accum_bits,
	                        index_bits,
	                        red_bits,
	                        green_bits,
	                        blue_bits,
	                        alpha_bits);
}


__asm __saveds void APIENTRY mesaDestroyVisual( register __a0 GLvisual *vis)
{
	gl_destroy_visual( vis );
}


__asm __saveds GLcontext* APIENTRY mesaCreateContextV2( register __a0 GLvisual *vis, register __a1 GLcontext *share, register __a2 void *c )
{
	return gl_create_context( vis,
	                          share,
	                          c,
	                          GL_FALSE );
}


__asm __saveds GLcontext* APIENTRY mesaCreateContext( register __a0 GLvisual *vis, register __a1 GLcontext *share, register __a2 void *c, register __d0 GLboolean direct )
{
	return gl_create_context( vis,
	                          share,
	                          c,
	                          direct );
}


__asm __saveds void APIENTRY mesaDestroyContext( register __a0 GLcontext *ctx )
{
	gl_destroy_context( ctx );
}


__asm __saveds GLframebuffer* APIENTRY mesaCreateFramebuffer( register __a0 GLvisual *vis )
{
	return gl_create_framebuffer( vis );
}


__asm __saveds void APIENTRY mesaDestroyFramebuffer( register __a0 GLframebuffer *buf )
{
	gl_destroy_framebuffer( buf );
}


__asm __saveds void APIENTRY mesaMakeCurrent( register __a0 GLcontext *ctx, register __a1 GLframebuffer *buffer )
{
	gl_make_current( ctx, buffer );
}


__asm __saveds GLcontext* APIENTRY mesaGetCurrentContext( void )
{
	return gl_get_current_context();
}


__asm __saveds void APIENTRY mesaCopyContext( register __a0 const GLcontext *src, register __a1 GLcontext *dst, register __d0 GLuint mask )
{
	gl_copy_context(src, dst, mask);
}


__asm __saveds void APIENTRY mesaSetAPITable( register __a0 GLcontext *ctx, register __a1 const struct gl_api_table *api )
{
	gl_set_api_table(ctx, api);
}


__asm __saveds void APIENTRY mesaProblem( register __a0 const GLcontext *ctx, register __a1 const char *s )
{
	gl_problem( ctx, s );
}


__asm __saveds void APIENTRY mesaWarning( register __a0 const GLcontext *ctx, register __a1 const char *s )
{
	gl_warning( ctx, s );
}


__asm __saveds void APIENTRY mesaError( register __a0 const GLcontext *ctx, register __d0 GLenum error, register __a1 const char *s )
{
	gl_error( ctx, error, s );
}


__asm __saveds GLenum APIENTRY mesaGetError( register __a0 GLcontext *ctx )
{
	return gl_GetError( ctx );
}


__asm __saveds void APIENTRY mesaUpdateState( register __a0 GLcontext *ctx )
{
	gl_update_state( ctx );
}


__asm __saveds void APIENTRY mesaViewport( register __a0 GLcontext *ctx, register __d0 GLint x, register __d1 GLint y, register __d2 GLsizei width, register __d3 GLsizei height )
{
	gl_Viewport(ctx,x,y,width,height);
}


#define CHECK_DRIVER	if(!havedriver) OpenDriver(NULL)

__asm __saveds ULONG mesaGetAttr(register __d0 ULONG attr, register __a0 ULONG *data)
{
	switch(attr)
	{
		case MESA_Driver:
			CHECK_DRIVER;
			*((char **)data) = mesadriverBase->lib_IdString;
			break;
		case MESA_DriverVersion:
			CHECK_DRIVER;
			*((ULONG *)data) = mesadriverBase->lib_Version;
			break;
		case MESA_DriverBase:
			CHECK_DRIVER;
			*((struct Library **)data) = mesadriverBase;
			break;
		case MESA_HaveDriver:
			*((BOOL *)data) = havedriver;
			break;
		default:
			return(0);
	}

	return(1);
}


__asm __saveds ULONG mesaSetAttrsA(register __a0 struct TagItem *tags)
{
	struct TagItem *tstate, *tag;
	ULONG tidata;

	tstate = tags;
	while(tag = NextTagItem(&tstate))
	{
		tidata = tag->ti_Data;

		switch(tag->ti_Tag)
		{
			case MESA_Driver:
				OpenDriver((char *)tidata);
				break;
			case MESA_DriverBase:
				SwitchDriver((struct Library *)tidata);
				break;
			default:
				break;
		}
	}

	return(0);
}
