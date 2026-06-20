#ifndef _PROTO_BZ2_H
#define _PROTO_BZ2_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_BZ2_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/bz2_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *BZ2Base;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/bz2.h>
#else
#include <inline/bz2.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/bz2_protos.h>
#endif
#else
#include <pragma/bz2_lib.h>
#endif

#endif	/*  _PROTO_BZ2_H  */
