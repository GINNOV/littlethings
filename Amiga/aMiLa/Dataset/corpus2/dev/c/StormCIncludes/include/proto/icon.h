#ifndef _PROTO_ICON_H
#define _PROTO_ICON_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_ICON_PROTOS_H
#include <clib/icon_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *IconBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/icon.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/icon_lib.h>
#endif
#endif

#endif	/*  _PROTO_ICON_H  */
