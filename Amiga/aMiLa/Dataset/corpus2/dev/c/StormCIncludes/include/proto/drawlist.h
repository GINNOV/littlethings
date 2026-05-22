#ifndef _PROTO_DRAWLIST_H
#define _PROTO_DRAWLIST_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_DRAWLIST_PROTOS_H
#include <clib/drawlist_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *DrawListBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/drawlist.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/drawlist_lib.h>
#endif
#endif

#endif	/*  _PROTO_DRAWLIST_H  */
