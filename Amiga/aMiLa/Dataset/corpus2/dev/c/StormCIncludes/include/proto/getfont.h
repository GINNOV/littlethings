#ifndef _PROTO_GETFONT_H
#define _PROTO_GETFONT_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_GETFONT_PROTOS_H
#include <clib/getfont_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *GetFontBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/getfont.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/getfont_lib.h>
#endif
#endif

#endif	/*  _PROTO_GETFONT_H  */
