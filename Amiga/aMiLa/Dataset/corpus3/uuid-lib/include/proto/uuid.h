#ifndef PROTO_UUID_H
#define PROTO_UUID_H

/*
**	$Id$
**
**	Prototype/inline/pragma header file combo
**
**	Copyright (c) 2010 Hyperion Entertainment CVBA.
**	All Rights Reserved.
*/

#ifndef LIBRARIES_UUID_H
#include <libraries/uuid.h>
#endif

/****************************************************************************/

#ifndef __NOLIBBASE__
 #ifndef __USE_BASETYPE__
  extern struct Library * uuidBase;
 #else
  extern struct Library * uuidBase;
 #endif /* __USE_BASETYPE__ */
#endif /* __NOLIBBASE__ */

/****************************************************************************/

#ifdef __amigaos4__
 #include <interfaces/uuid.h>
 #ifdef __USE_INLINE__
  #include <inline4/uuid.h>
 #endif /* __USE_INLINE__ */
 #ifndef CLIB_UUID_PROTOS_H
  #define CLIB_UUID_PROTOS_H 1
 #endif /* CLIB_UUID_PROTOS_H */
 #ifndef __NOGLOBALIFACE__
  extern struct UuidIFace *IUuid;
 #endif /* __NOGLOBALIFACE__ */
#else /* __amigaos4__ */
 #ifndef CLIB_UUID_PROTOS_H
  #include <clib/uuid_protos.h>
 #endif /* CLIB_UUID_PROTOS_H */
 #if defined(__GNUC__)
  #ifndef __PPC__
   #include <inline/uuid.h>
  #else /* __PPC__ */
   #include <ppcinline/uuid.h>
  #endif /* __PPC__ */
 #elif defined(__VBCC__)
  #ifndef __PPC__
   #include <inline/uuid_protos.h>
  #endif /* __PPC__ */
 #else /* __GNUC__ */
  #include <pragmas/uuid_pragmas.h>
 #endif /* __GNUC__ */
#endif /* __amigaos4__ */

/****************************************************************************/

#endif /* PROTO_UUID_H */
