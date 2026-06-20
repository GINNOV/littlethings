/*
 * $Id: sysinc.h,v 1.5 2001/12/25 00:55:26 tfrieden Exp $
 *
 * $Date: 2001/12/25 00:55:26 $
 * $Revision: 1.5 $
 *
 * (C) 1999 by Hyperion
 * All rights reserved
 *
 * This file is part of the MiniGL library project
 * See the file Licence.txt for more details
 *
 */

#ifndef __MINIGL_COMPILER_H
#define __MINIGL_COMPILER_H

#ifdef __PPC__
extern struct Library *Warp3DPPCBase;
#else
extern struct Library *Warp3DBase;
#endif

#ifdef __VBCC__
#pragma amiga-align
#endif

#include <exec/types.h>
#include <exec/exec.h>
#include <intuition/intuition.h>
#include <graphics/gfx.h>
#include <graphics/scale.h>
#include <utility/tagitem.h>
#include <dos/dos.h>
#include <dos/exall.h>
#include <devices/timer.h>
#include <Warp3D/Warp3D.h>
#include <cybergraphx/cybergraphics.h>

#ifdef __VBCC__
#pragma default-align
#endif

#if defined(__GNUC__)
    #define UNUSED  __attribute__ ((unused))
#else
    #define UNUSED
#endif

#if defined(__GNUC__)
#include "../include/mgl/gl.h"
	#ifdef __PPC__
	#include <powerpc/memoryPPC.h>

		#ifndef __STORMGCC__
			#include <Warp3D/Warp3D_protos.h>
		#else
	    		#include <Warp3D/Warp3D.h>
	    		#include <clib/Warp3D_protos.h>
		#endif
		#ifndef __STORMGCC__
			#include <powerpc/powerpc_protos.h>
		#else
			#include <clib/powerpc_protos.h>
		#endif
	#include <proto/intuition.h>
	#include <proto/exec.h>
	#include <proto/graphics.h>
	#include <proto/dos.h>
	#include <proto/cybergraphics.h>
	#else
      #include <inline/Warp3D.h>
      #include <inline/intuition.h>
      #include <inline/exec.h>
      #include <inline/graphics.h>
      #include <inline/dos.h>
      #include <proto/timer.h>
      #include <inline/timer.h>
      #include <proto/cybergraphics.h>
      #endif
#elif defined(__STORM__)
    #include "/include/mgl/gl.h"
    #include <Warp3D/Warp3D.h>
    #include <clib/Warp3D_protos.h>
    	#ifdef __PPC__
    	#include <clib/powerpc_protos.h>
   	#include <clib/cybergraphics_protos.h>
   	#else
      #include <pragma/Warp3D_lib.h>
      #endif
    #define INLINE __inline
    #define inline __inline
#elif defined(__VBCC__)
#pragma amiga-align
    #include <proto/Warp3D.h>
    #include <proto/intuition.h>
    #include <proto/exec.h>
    #include <proto/graphics.h>
    #include <proto/dos.h>
    #include <proto/cybergraphics.h>
    #ifdef __PPC__
	#include <clib/powerpc_protos.h>
    #endif

#pragma default-align

    #include "/include/mgl/gl.h"

	#ifndef inline
	#define inline
	#endif

    #define INLINE inline
    #define __inline inline
#endif

#include <mgl/config.h>

#endif
