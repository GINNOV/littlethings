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
 * mesamain.h
 *
 * Version 2.0  13 Sep 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * Interface for drivers to main library
 * - Stubs are now #defined so that they pass the
 *   current mesamainBase rather than the global one
 *
 * Version 3.0  10 Oct 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Changed to Mesa 3.0
 *
 */

#ifndef MESAMAIN_H
#define MESAMAIN_H

#ifdef __cplusplus
extern "C" {
#endif

#include "types.h"

#include <utility/tagitem.h>


#define MESA_Base			(TAG_USER + 42)
#define MESA_Driver			(MESA_Base + 0)			/* GS */
#define MESA_DriverBase		(MESA_Base + 1)			/* GS */
#define MESA_DriverVersion	(MESA_Base + 2)			/* G  */
#define MESA_HaveDriver		(MESA_Base + 3)			/* G  */

extern __asm __saveds GLvisual* APIENTRY mesaCreateVisual( register __d0 GLboolean rgb_flag,
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
													register __a2 GLint alpha_bits );
extern __asm __saveds void APIENTRY mesaDestroyVisual( register __a0 GLvisual *vis);
extern __asm __saveds GLcontext* APIENTRY mesaCreateContext( register __a0 GLvisual *vis, register __a1 GLcontext *share, register __a2 void *c, register __d0 GLboolean direct );
extern __asm __saveds void APIENTRY mesaDestroyContext( register __a0 GLcontext *ctx );
extern __asm __saveds GLframebuffer* APIENTRY mesaCreateFramebuffer( register __a0 GLvisual *vis );
extern __asm __saveds void APIENTRY mesaDestroyFramebuffer( register __a0 GLframebuffer *buf );
extern __asm __saveds void APIENTRY mesaMakeCurrent( register __a0 GLcontext *ctx, register __a1 GLframebuffer *buffer );
extern __asm __saveds GLcontext* APIENTRY mesaGetCurrentContext( void );
extern __asm __saveds void APIENTRY mesaCopyContext( register __a0 const GLcontext *src, register __a1 GLcontext *dst, register __d0 GLuint mask );
extern __asm __saveds void APIENTRY mesaSetAPITable( register __a0 GLcontext *ctx, register __a1 const struct gl_api_table *api );
extern __asm __saveds void APIENTRY mesaProblem( register __a0 const GLcontext *ctx, register __a1 const char *s );
extern __asm __saveds void APIENTRY mesaWarning( register __a0 const GLcontext *ctx, register __a1 const char *s );
extern __asm __saveds void APIENTRY mesaError( register __a0 const GLcontext *ctx, register __d0 GLenum error, register __a1 const char *s );
extern __asm __saveds GLenum APIENTRY mesaGetError( register __a0 GLcontext *ctx );
extern __asm __saveds void APIENTRY mesaUpdateState( register __a0 GLcontext *ctx );
extern __asm __saveds void APIENTRY mesaViewport( register __a0 GLcontext *ctx, register __d0 GLint x, register __d1 GLint y, register __d2 GLsizei width, register __d3 GLsizei height );

extern __asm __saveds ULONG mesaGetAttr(register __d0 ULONG attr, register __a0 ULONG *data);
extern __asm __saveds ULONG mesaSetAttrsA(register __a0 struct TagItem *tags);
extern ULONG mesaSetAttrs(Tag tag, ...);

#ifdef __cplusplus
}
#endif


#endif
