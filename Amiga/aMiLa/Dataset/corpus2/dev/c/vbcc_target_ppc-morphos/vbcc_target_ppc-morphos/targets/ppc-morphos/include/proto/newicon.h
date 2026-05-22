#ifndef _PROTO_NEWICON_H
#define _PROTO_NEWICON_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_NEWICON_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/newicon_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *NewIconBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/newicon.h>
#else
#include <inline/newicon.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/newicon_protos.h>
#endif
#else
#include <pragma/newicon_lib.h>
#endif

#endif	/*  _PROTO_NEWICON_H  */
