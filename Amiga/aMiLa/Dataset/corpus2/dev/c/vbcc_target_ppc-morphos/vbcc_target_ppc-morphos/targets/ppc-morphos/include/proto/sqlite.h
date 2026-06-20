#ifndef _PROTO_SQLITE_H
#define _PROTO_SQLITE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_SQLITE_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/sqlite_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *SQLiteBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/sqlite.h>
#else
#include <inline/sqlite.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/sqlite_protos.h>
#endif
#else
#include <pragma/sqlite_lib.h>
#endif

#endif	/*  _PROTO_SQLITE_H  */
