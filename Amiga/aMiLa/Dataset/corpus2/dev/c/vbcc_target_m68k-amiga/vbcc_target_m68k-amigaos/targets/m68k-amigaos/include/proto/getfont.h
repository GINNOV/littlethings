#ifndef _PROTO_GETFONT_H
#define _PROTO_GETFONT_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_GETFONT_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/getfont_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *GetFontBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/getfont.h>
#else
#include <inline/getfont.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/getfont_protos.h>
#endif
#else
#include <pragma/getfont_lib.h>
#endif

#endif	/*  _PROTO_GETFONT_H  */
