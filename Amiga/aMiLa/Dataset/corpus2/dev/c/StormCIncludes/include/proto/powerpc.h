#ifndef _PROTO_POWERPC_H
#define _PROTO_POWERPC_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_POWERPC_PROTOS_H
#include <clib/powerpc_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *PowerPCBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/powerpc.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/powerpc_lib.h>
#endif
#endif

#endif	/*  _PROTO_POWERPC_H  */
