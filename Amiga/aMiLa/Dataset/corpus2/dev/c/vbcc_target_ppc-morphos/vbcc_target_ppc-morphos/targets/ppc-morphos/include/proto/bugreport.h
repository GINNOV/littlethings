#ifndef _PROTO_BUGREPORT_H
#define _PROTO_BUGREPORT_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_BUGREPORT_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/bugreport_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *BugReportBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/bugreport.h>
#else
#include <inline/bugreport.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/bugreport_protos.h>
#endif
#else
#include <pragma/bugreport_lib.h>
#endif

#endif	/*  _PROTO_BUGREPORT_H  */
