#ifndef _PROTO_LISTVIEW_H
#define _PROTO_LISTVIEW_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_LISTVIEW_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/listview_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *ListViewBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/listview.h>
#else
#include <inline/listview.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/listview_protos.h>
#endif
#else
#include <pragma/listview_lib.h>
#endif

#endif	/*  _PROTO_LISTVIEW_H  */
