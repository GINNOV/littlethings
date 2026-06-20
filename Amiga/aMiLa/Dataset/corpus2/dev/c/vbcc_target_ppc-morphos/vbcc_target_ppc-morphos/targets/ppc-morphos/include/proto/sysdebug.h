#ifndef _PROTO_SYSDEBUG_H
#define _PROTO_SYSDEBUG_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_SYSDEBUG_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/sysdebug_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *SysDebugBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/sysdebug.h>
#else
#include <inline/sysdebug.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/sysdebug_protos.h>
#endif
#else
#include <pragma/sysdebug_lib.h>
#endif

#endif	/*  _PROTO_SYSDEBUG_H  */
