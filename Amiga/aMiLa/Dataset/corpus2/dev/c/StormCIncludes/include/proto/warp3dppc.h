#ifndef _PROTO_WARP3DPPC_H
#define _PROTO_WARP3DPPC_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_WARP3DPPC_PROTOS_H
#include <clib/Warp3DPPC_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *Warp3DPPCBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/Warp3DPPC.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/Warp3DPPC_lib.h>
#endif
#endif

#endif	/*  _PROTO_WARP3DPPC_H  */
