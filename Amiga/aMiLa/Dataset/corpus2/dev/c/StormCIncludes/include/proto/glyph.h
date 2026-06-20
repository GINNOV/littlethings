#ifndef _PROTO_GLYPH_H
#define _PROTO_GLYPH_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_GLYPH_PROTOS_H
#include <clib/glyph_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *GlyphBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/glyph.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/glyph_lib.h>
#endif
#endif

#endif	/*  _PROTO_GLYPH_H  */
