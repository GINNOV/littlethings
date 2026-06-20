#ifndef PROTO_GLUT_H
#define PROTO_GLUT_H

/*
**	$Id: glut.h 153 2005-07-28 10:51:48Z tfrieden $
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
  extern struct Library * GlutBase;
 #else
  extern struct Library * GlutBase;
 #endif /* __USE_BASETYPE__ */
#endif /* __NOLIBBASE__ */

/****************************************************************************/

#ifdef __amigaos4__
 #include <interfaces/glut.h>
 #ifdef __USE_INLINE__
  #include <inline4/glut.h>
 #endif /* __USE_INLINE__ */
 #ifndef CLIB_GLUT_PROTOS_H
  #define CLIB_GLUT_PROTOS_H 1
 #endif /* CLIB_GLUT_PROTOS_H */
 #ifndef __NOGLOBALIFACE__
  extern struct GlutIFace *IGlut;
 #endif /* __NOGLOBALIFACE__ */
#else /* __amigaos4__ */
 #ifndef CLIB_GLUT_PROTOS_H
  #include <clib/glut_protos.h>
 #endif /* CLIB_GLUT_PROTOS_H */
 #if defined(__GNUC__)
  #ifndef __PPC__
   #include <inline/glut.h>
  #else
   #include <ppcinline/glut.h>
  #endif /* __PPC__ */
 #elif defined(__VBCC__)
  #ifndef __PPC__
   #include <inline/glut_protos.h>
  #endif /* __PPC__ */
 #else
  #include <pragmas/glut_pragmas.h>
 #endif /* __GNUC__ */
#endif /* __amigaos4__ */

/****************************************************************************/

#endif /* PROTO_GLUT_H */
