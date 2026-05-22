#ifndef _PROTO_TIFF_H
#define _PROTO_TIFF_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_TIFF_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/tiff_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *TIFFBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/tiff.h>
#else
#include <inline/tiff.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/tiff_protos.h>
#endif
#else
#include <pragma/tiff_lib.h>
#endif

#endif	/*  _PROTO_TIFF_H  */
