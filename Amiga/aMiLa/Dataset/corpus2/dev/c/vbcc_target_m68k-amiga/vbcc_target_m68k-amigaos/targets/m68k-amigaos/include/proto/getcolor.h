#ifndef _PROTO_GETCOLOR_H
#define _PROTO_GETCOLOR_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_GETCOLOR_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/getcolor_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *GetColorBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/getcolor.h>
#else
#include <inline/getcolor.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/getcolor_protos.h>
#endif
#else
#include <pragma/getcolor_lib.h>
#endif

#endif	/*  _PROTO_GETCOLOR_H  */
