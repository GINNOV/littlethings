#ifndef _PROTO_WBSTART_H
#define _PROTO_WBSTART_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_WBSTART_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/wbstart_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *WBStartBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/wbstart.h>
#else
#include <inline/wbstart.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/wbstart_protos.h>
#endif
#else
#include <pragma/wbstart_lib.h>
#endif

#endif	/*  _PROTO_WBSTART_H  */
