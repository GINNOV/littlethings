#ifndef _PROTO_SCROLLER_H
#define _PROTO_SCROLLER_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_SCROLLER_PROTOS_H
#include <clib/scroller_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *ScrollerBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/scroller.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/scroller_lib.h>
#endif
#endif

#endif	/*  _PROTO_SCROLLER_H  */
