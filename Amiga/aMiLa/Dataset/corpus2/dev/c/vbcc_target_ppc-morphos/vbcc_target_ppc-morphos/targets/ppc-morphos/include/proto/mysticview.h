#ifndef _PROTO_MYSTICVIEW_H
#define _PROTO_MYSTICVIEW_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_MYSTICVIEW_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/mysticview_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *MysticBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/mysticview.h>
#else
#include <inline/mysticview.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/mysticview_protos.h>
#endif
#else
#include <pragma/mysticview_lib.h>
#endif

#endif	/*  _PROTO_MYSTICVIEW_H  */
