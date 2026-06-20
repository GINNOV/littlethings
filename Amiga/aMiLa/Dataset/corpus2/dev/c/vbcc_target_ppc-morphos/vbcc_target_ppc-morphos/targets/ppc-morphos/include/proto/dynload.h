#ifndef _PROTO_DYNLOAD_H
#define _PROTO_DYNLOAD_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_DYNLOAD_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/dynload_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *DynLoadBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/dynload.h>
#else
#include <inline/dynload.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/dynload_protos.h>
#endif
#else
#include <pragma/dynload_lib.h>
#endif

#endif	/*  _PROTO_DYNLOAD_H  */
