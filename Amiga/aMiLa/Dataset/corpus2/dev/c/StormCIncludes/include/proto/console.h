#ifndef _PROTO_CONSOLE_H
#define _PROTO_CONSOLE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_CONSOLE_PROTOS_H
#include <clib/console_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Device *ConsoleDevice;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/console.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/console_lib.h>
#endif
#endif

#endif	/*  _PROTO_CONSOLE_H  */
