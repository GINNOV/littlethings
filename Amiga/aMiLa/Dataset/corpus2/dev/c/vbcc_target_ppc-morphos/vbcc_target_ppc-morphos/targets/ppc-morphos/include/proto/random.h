#ifndef _PROTO_RANDOM_H
#define _PROTO_RANDOM_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_RANDOM_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/random_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *RandomBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/random.h>
#else
#include <inline/random.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/random_protos.h>
#endif
#else
#include <pragma/random_lib.h>
#endif

#endif	/*  _PROTO_RANDOM_H  */
