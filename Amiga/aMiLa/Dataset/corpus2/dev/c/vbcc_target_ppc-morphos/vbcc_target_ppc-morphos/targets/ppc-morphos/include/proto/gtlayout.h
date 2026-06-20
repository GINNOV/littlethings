#ifndef _PROTO_GTLAYOUT_H
#define _PROTO_GTLAYOUT_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_GTLAYOUT_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/gtlayout_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *GTLayoutBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/gtlayout.h>
#else
#include <inline/gtlayout.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/gtlayout_protos.h>
#endif
#else
#include <pragma/gtlayout_lib.h>
#endif

#endif	/*  _PROTO_GTLAYOUT_H  */
