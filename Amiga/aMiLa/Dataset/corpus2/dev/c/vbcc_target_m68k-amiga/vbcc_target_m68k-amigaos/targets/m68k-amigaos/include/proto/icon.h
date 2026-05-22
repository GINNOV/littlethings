#ifndef _PROTO_ICON_H
#define _PROTO_ICON_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_ICON_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/icon_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *IconBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/icon.h>
#else
#include <inline/icon.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/icon_protos.h>
#endif
#else
#include <pragma/icon_lib.h>
#endif

#endif	/*  _PROTO_ICON_H  */
