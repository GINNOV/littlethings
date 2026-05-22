#ifndef _PROTO_BITMAP_H
#define _PROTO_BITMAP_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_BITMAP_PROTOS_H
#include <clib/bitmap_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *BitMapBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/bitmap.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/bitmap_lib.h>
#endif
#endif

#endif	/*  _PROTO_BITMAP_H  */
