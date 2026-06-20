#ifndef _PROTO_BATTCLOCK_H
#define _PROTO_BATTCLOCK_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_BATTCLOCK_PROTOS_H
#include <clib/battclock_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *BattClockBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/battclock.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/battclock_lib.h>
#endif
#endif

#endif	/*  _PROTO_BATTCLOCK_H  */
