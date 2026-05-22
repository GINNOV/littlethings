#ifndef _PROTO_SPEEDBAR_H
#define _PROTO_SPEEDBAR_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_SPEEDBAR_PROTOS_H
#include <clib/speedbar_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *SpeedBarBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/speedbar.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/speedbar_lib.h>
#endif
#endif

#endif	/*  _PROTO_SPEEDBAR_H  */
