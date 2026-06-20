/*
 * AmigaMesaRTL graphics library
 * Version:  2.0
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
 * mesadriver.h
 *
 * Version 1.0  27 Jun 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * Based on FooMesa.h ver 1.1
 *
 * Version 1.1  02 Aug 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Quantizer plugin tags added
 *
 * Version 2.0  13 Sep 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - (Get|Set)IndexRGB added
 * - Set and get attributes added
 * - Lots more tags
 * - AmigaMesaRTLContext is now an APTR
 * - Deprecated some tags replaced by QNTZR_#? tags
 * - Change in CreateContext interface
 * - Changed to driver library
 * - Renamed to mesadriver.h
 * - Added AMRTL_SupportsOH tag
 *
 */



#ifndef MESADRIVER_H
#define MESADRIVER_H


#ifdef __cplusplus
extern "C" {
#endif


#ifndef MAKE_MESADRIVERLIB
#include "pragmas/mesadriver_pragmas.h"
extern struct Library *mesadriverBase;
#endif

#include "GL/gl.h"

#include <utility/tagitem.h>


#define AMRTL_Base		(TAG_USER + 42)

#define AMRTL_RGBAMode		(AMRTL_Base + 0)		/* IG  */	/* Context */
#define AMRTL_IndexMode		(AMRTL_Base + 1)		/* IG  */	/* Context */
#define AMRTL_OutputHandler	(AMRTL_Base + 4)		/* IG  */	/* Context */
#define AMRTL_OutputHandlerVersion	(AMRTL_Base + 5)	/* IG  */	/* Context */
#define AMRTL_OutputHandlerBase		(AMRTL_Base + 7)	/* IG  */	/* Context */
#define AMRTL_BufferWidth	(AMRTL_Base + 8)		/*  G  */	/* Context */
#define AMRTL_BufferHeight	(AMRTL_Base + 9)		/*  G  */	/* Context */
#define AMRTL_Buffer		(AMRTL_Base + 10)		/*  G  */	/* Context */
#define AMRTL_IndexPalette	(AMRTL_Base + 11)		/*  G  */	/* Context */
#define AMRTL_Mode			(AMRTL_Base + 12)		/* IG  */	/* Context */
#define AMRTL_Resized		(AMRTL_Base + 13)		/*  G  */	/* Context */
#define AMRTL_OutputWidth	(AMRTL_Base + 14)		/* IGS */	/* Context */
#define AMRTL_OutputHeight	(AMRTL_Base + 15)		/* IGS */	/* Context */
#define AMRTL_GL			(AMRTL_Base + 16)		/* IGS */
#define AMRTL_GLBase		(AMRTL_Base + 17)		/* IGS */
#define AMRTL_GLVersion		(AMRTL_Base + 18)		/*  G  */
#define AMRTL_HaveGL		(AMRTL_Base + 19)		/*  G  */
#define AMRTL_SupportsOH	(AMRTL_Base + 20)		/*  G  */

#define AMRTL_CustomBase	(AMRTL_Base + 512)

typedef APTR AmigaMesaRTLContext;

/* Byte order for AMRTL_Mode==AMRTL_RGBAMode */
#define ORDER_RGBA	0
#define ORDER_ARGB	1


extern __asm __saveds AmigaMesaRTLContext AmigaMesaRTLCreateContextA( register __a0 struct TagItem *tags );
extern AmigaMesaRTLContext AmigaMesaRTLCreateContext( Tag tag, ...  );
extern __asm __saveds void AmigaMesaRTLDestroyContext( register __a0 AmigaMesaRTLContext context );
extern __asm __saveds void AmigaMesaRTLMakeCurrent( register __a0 AmigaMesaRTLContext context );
extern __asm __saveds AmigaMesaRTLContext AmigaMesaRTLGetCurrentContext( void );

extern __asm __saveds void AmigaMesaRTLSetIndexRGBTable( register __d0 int index, register __a0 ULONG *rgbtable, register __d1 int numcolours);
extern __asm __saveds void AmigaMesaRTLSetIndexRGB( register __d0 int index, register __d1 ULONG red, register __d2 ULONG green, register __d3 ULONG blue);
extern __asm __saveds void AmigaMesaRTLGetIndexRGB( register __d0 int index, register __a0 ULONG *red, register __a1 ULONG *green, register __a2 ULONG *blue);

extern __asm __saveds ULONG AmigaMesaRTLSetContextAttrsA(register __a0 AmigaMesaRTLContext ca, register __a1 struct TagItem *tags);
extern ULONG AmigaMesaRTLSetContextAttrs( AmigaMesaRTLContext ca, Tag tag, ... );
extern __asm __saveds ULONG AmigaMesaRTLGetContextAttr(register __d0 ULONG attr, register __a0 AmigaMesaRTLContext ca, register __a1 ULONG *data);

extern __asm __saveds ULONG AmigaMesaRTLSetOutputHandlerAttrsA(register __a0 AmigaMesaRTLContext ca, register __a1 struct TagItem *tags);
extern ULONG AmigaMesaRTLSetOutputHandlerAttrs( AmigaMesaRTLContext ca, Tag tag, ... );
extern __asm __saveds ULONG AmigaMesaRTLGetOutputHandlerAttr(register __d0 ULONG attr, register __a0 AmigaMesaRTLContext ca, register __a1 ULONG *data);

extern __asm __saveds ULONG AmigaMesaRTLSetAttrsA(register __a0 struct TagItem *tags);
extern ULONG AmigaMesaRTLSetAttrs( Tag tag, ... );
extern __asm __saveds ULONG AmigaMesaRTLGetAttr(register __d0 ULONG attr, register __a0 ULONG *data);


/* Probably some more functions... */

#ifdef __cplusplus
}
#endif


#endif

