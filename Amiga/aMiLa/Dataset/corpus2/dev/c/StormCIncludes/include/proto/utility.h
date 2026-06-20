#ifndef _PROTO_UTILITY_H
#define _PROTO_UTILITY_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_UTILITY_PROTOS_H
#include <clib/utility_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct UtilityBase *UtilityBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/utility.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/utility_lib.h>
#endif
#endif

#endif	/*  _PROTO_UTILITY_H  */
