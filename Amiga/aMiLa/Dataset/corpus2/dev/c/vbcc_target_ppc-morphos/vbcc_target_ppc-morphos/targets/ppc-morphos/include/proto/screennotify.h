#ifndef _PROTO_SCREENNOTIFY_H
#define _PROTO_SCREENNOTIFY_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_SCREENNOTIFY_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/screennotify_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *ScreenNotifyBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/screennotify.h>
#else
#include <inline/screennotify.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/screennotify_protos.h>
#endif
#else
#include <pragma/screennotify_lib.h>
#endif

#endif	/*  _PROTO_SCREENNOTIFY_H  */
