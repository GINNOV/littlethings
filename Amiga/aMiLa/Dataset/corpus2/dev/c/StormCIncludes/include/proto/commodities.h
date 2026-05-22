#ifndef _PROTO_COMMODITIES_H
#define _PROTO_COMMODITIES_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_COMMODITIES_PROTOS_H
#include <clib/commodities_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *CxBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/commodities.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/commodities_lib.h>
#endif
#endif

#endif	/*  _PROTO_COMMODITIES_H  */
