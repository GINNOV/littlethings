#ifndef PROTO_MINIGL_H
#define PROTO_MINIGL_H

/*
**	$Id$
**	Includes Release 50.1
**
**	Prototype/inline/pragma header file combo
**
**	(C) Copyright 2003-2005 Amiga, Inc.
**	    All Rights Reserved
*/


/****************************************************************************/

#ifndef __NOLIBBASE__
 #ifndef __USE_BASETYPE__
  extern struct Library * MiniGLBase;
 #else
  extern struct Library * MiniGLBase;
 #endif /* __USE_BASETYPE__ */
#endif /* __NOLIBBASE__ */

/****************************************************************************/

#ifdef __amigaos4__
 #include <interfaces/minigl.h>
 #ifdef __USE_INLINE__
  #include <inline4/minigl.h>
 #endif /* __USE_INLINE__ */
 #ifndef CLIB_MINIGL_PROTOS_H
  #define CLIB_MINIGL_PROTOS_H 1
 #endif /* CLIB_MINIGL_PROTOS_H */
 #ifndef __NOGLOBALIFACE__
  extern struct MiniGLIFace *IMiniGL;
 #endif /* __NOGLOBALIFACE__ */
#else /* __amigaos4__ */
 #ifndef CLIB_MINIGL_PROTOS_H
  #include <clib/minigl_protos.h>
 #endif /* CLIB_MINIGL_PROTOS_H */
 #if defined(__GNUC__)
  #ifndef __PPC__
   #include <inline/minigl.h>
  #else
   #include <ppcinline/minigl.h>
  #endif /* __PPC__ */
 #elif defined(__VBCC__)
  #ifndef __PPC__
   #include <inline/minigl_protos.h>
  #endif /* __PPC__ */
 #else
  #include <pragmas/minigl_pragmas.h>
 #endif /* __GNUC__ */
#endif /* __amigaos4__ */

/****************************************************************************/

#endif /* PROTO_MINIGL_H */
