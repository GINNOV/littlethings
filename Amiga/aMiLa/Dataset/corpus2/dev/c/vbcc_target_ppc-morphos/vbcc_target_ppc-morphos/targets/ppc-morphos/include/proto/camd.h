#ifndef _PROTO_CAMD_H
#define _PROTO_CAMD_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_CAMD_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/camd_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *CamdBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/camd.h>
#else
#include <inline/camd.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/camd_protos.h>
#endif
#else
#include <pragma/camd_lib.h>
#endif

#endif	/*  _PROTO_CAMD_H  */
