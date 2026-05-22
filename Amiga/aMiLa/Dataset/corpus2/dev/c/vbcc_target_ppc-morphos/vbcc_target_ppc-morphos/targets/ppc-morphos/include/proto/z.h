#ifndef _PROTO_Z_H
#define _PROTO_Z_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_Z_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/z_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *ZBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/z.h>
#else
#include <inline/z.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/z_protos.h>
#endif
#else
#include <pragma/z_lib.h>
#endif

#endif	/*  _PROTO_Z_H  */
