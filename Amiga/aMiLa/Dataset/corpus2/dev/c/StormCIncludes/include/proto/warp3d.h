#ifndef _PROTO_WARP3D_H
#define _PROTO_WARP3D_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_WARP3D_PROTOS_H
#include <clib/Warp3D_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *Warp3DBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/Warp3D.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/Warp3D_lib.h>
#endif
#endif

#endif	/*  _PROTO_WARP3D_H  */
