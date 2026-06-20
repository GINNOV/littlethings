/* $Id: config.h,v 3.5 1998/09/16 02:25:53 brianp Exp $ */

/*
 * Mesa 3-D graphics library
 * Version:  3.0
 * Copyright (C) 1995-1998  Brian Paul
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
 * config.h
 *
 * Modified  27 Jun 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * Based on config,h ver 1.8
 * Removed any Amiga-specific #defines
 *
 * Version 1.1  04 Oct 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Changed to v3.5 of config.h
 *
 */


/*
 * Tunable configuration parameters.
 */



#ifndef CONFIG_H
#define CONFIG_H


/*
 *
 * OpenGL implementation limits
 *
 */


/* Maximum modelview matrix stack depth: */
#define MAX_MODELVIEW_STACK_DEPTH 32

/* Maximum projection matrix stack depth: */
#define MAX_PROJECTION_STACK_DEPTH 32

/* Maximum texture matrix stack depth: */
#define MAX_TEXTURE_STACK_DEPTH 10

/* Maximum attribute stack depth: */
#define MAX_ATTRIB_STACK_DEPTH 16

/* Maximum client attribute stack depth: */
#define MAX_CLIENT_ATTRIB_STACK_DEPTH 16

/* Maximum recursion depth of display list calls: */
#define MAX_LIST_NESTING 64

/* Maximum number of lights: */
#define MAX_LIGHTS 8

/* Maximum user-defined clipping planes: */
#define MAX_CLIP_PLANES 6

/* Number of texture levels */
#ifdef FX
#define MAX_TEXTURE_LEVELS 9
#else
#define MAX_TEXTURE_LEVELS 11
#endif

/* Max texture size */
#define MAX_TEXTURE_SIZE   (1 << (MAX_TEXTURE_LEVELS-1))

/* Maximum pixel map lookup table size: */
#define MAX_PIXEL_MAP_TABLE 256

/* Number of auxillary color buffers: */
#define NUM_AUX_BUFFERS 0

/* Maximum order (degree) of curves: */
#define MAX_EVAL_ORDER 30

/* Maximum Name stack depth */
#define MAX_NAME_STACK_DEPTH 64

/* Min and Max point sizes and granularity */
#define MIN_POINT_SIZE 1.0
#define MAX_POINT_SIZE 10.0
#define POINT_SIZE_GRANULARITY 0.1

/* Min and Max line widths and granularity */
#define MIN_LINE_WIDTH 1.0
#define MAX_LINE_WIDTH 10.0
#define LINE_WIDTH_GRANULARITY 1.0

/* Max texture palette size */
#define MAX_TEXTURE_PALETTE_SIZE 256

/* Number of texture maps and environments - GL_EXT_multitexture */
#define MAX_TEX_SETS 2

/* Number of texture coordinate sets - GL_EXT_multitexture */
#define MAX_TEX_COORD_SETS 2

/* Maximum viewport size: */
#define MAX_WIDTH 1600
#define MAX_HEIGHT 1200




/*
 *
 * Mesa-specific parameters
 *
 */


/*
 * Bits per color channel (must be 8 at this time!)
 */
#define CHAN_BITS 8


/*
 * Bits per accumulation buffer color component:  8 or 16
 */
#define ACCUM_BITS 16


/*
 * Bits per depth buffer value:  16 or 32
 */
#define DEPTH_BITS 16

#if DEPTH_BITS==16
#  define MAX_DEPTH 0xffff
#  define DEPTH_SCALE 65535.0F
#elif DEPTH_BITS==32
#  define MAX_DEPTH 0x00ffffff
#  define DEPTH_SCALE ((GLfloat) 0x00ffffff)
#else
   invalid value!
#endif


/*
 * Bits per stencil value:  8
 */
#define STENCIL_BITS 8



/*
 * Color channel component order
 * (changes will almost certainly cause problems at this time)
 */
#define RCOMP 0
#define GCOMP 1
#define BCOMP 2
#define ACOMP 3



/*
 * Vertex buffer size.  Must be a multiple of 12.
 */
#if defined(FX) && !defined(MITS)
#  define VB_MAX 72   /* better performance */
#else
#  define VB_MAX 480
#endif



/*
 *
 * For X11 driver only:
 *
 */

/*
 * When defined, use 6x6x6 dithering instead of 5x9x5.
 * 5x9x5 better for general colors, 6x6x6 better for grayscale.
 */
/*#define DITHER666*/



#endif

