#ifndef _PROTO_WARP3D_H
#define _PROTO_WARP3D_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_WARP3D_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/Warp3D_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *Warp3DBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/Warp3D.h>
#else
#include <inline/Warp3D.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/Warp3D_protos.h>
#endif
#else
#include <pragma/Warp3D_lib.h>
#endif

#endif	/*  _PROTO_WARP3D_H  */
