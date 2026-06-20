#ifndef _PROTO_PIXMAN_H
#define _PROTO_PIXMAN_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_PIXMAN_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/pixman_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *PixManBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/pixman.h>
#else
#include <inline/pixman.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/pixman_protos.h>
#endif
#else
#include <pragma/pixman_lib.h>
#endif

#endif	/*  _PROTO_PIXMAN_H  */
