#ifndef _PROTO_WINDOW_H
#define _PROTO_WINDOW_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_WINDOW_PROTOS_H
#include <clib/window_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *WindowBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/window.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/window_lib.h>
#endif
#endif

#endif	/*  _PROTO_WINDOW_H  */
