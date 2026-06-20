#ifndef _PROTO_LAYOUT_H
#define _PROTO_LAYOUT_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_LAYOUT_PROTOS_H
#include <clib/layout_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *LayoutBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/layout.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/layout_lib.h>
#endif
#endif

#endif	/*  _PROTO_LAYOUT_H  */
