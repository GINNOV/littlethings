#ifndef _PROTO_LZMA_H
#define _PROTO_LZMA_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_LZMA_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/lzma_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *LZMABase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/lzma.h>
#else
#include <inline/lzma.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/lzma_protos.h>
#endif
#else
#include <pragma/lzma_lib.h>
#endif

#endif	/*  _PROTO_LZMA_H  */
