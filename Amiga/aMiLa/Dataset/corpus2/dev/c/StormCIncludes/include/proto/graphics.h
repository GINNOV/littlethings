#ifndef _PROTO_GRAPHICS_H
#define _PROTO_GRAPHICS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_GRAPHICS_PROTOS_H
#include <clib/graphics_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct GfxBase *GfxBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/graphics.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/graphics_lib.h>
#endif
#endif

#endif	/*  _PROTO_GRAPHICS_H  */
