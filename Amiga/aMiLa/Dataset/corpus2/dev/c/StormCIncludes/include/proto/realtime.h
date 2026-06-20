#ifndef _PROTO_REALTIME_H
#define _PROTO_REALTIME_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_REALTIME_PROTOS_H
#include <clib/realtime_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct RealTimeBase *RealTimeBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/realtime.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/realtime_lib.h>
#endif
#endif

#endif	/*  _PROTO_REALTIME_H  */
