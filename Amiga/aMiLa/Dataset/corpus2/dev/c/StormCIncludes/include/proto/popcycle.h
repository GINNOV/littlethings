#ifndef _PROTO_POPCYCLE_H
#define _PROTO_POPCYCLE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_POPCYCLE_PROTOS_H
#include <clib/popcycle_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *PopCycleBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/popcycle.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/popcycle_lib.h>
#endif
#endif

#endif	/*  _PROTO_POPCYCLE_H  */
