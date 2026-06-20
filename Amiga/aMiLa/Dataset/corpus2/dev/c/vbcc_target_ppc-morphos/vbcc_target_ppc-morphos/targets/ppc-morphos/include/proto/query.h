#ifndef _PROTO_QUERY_H
#define _PROTO_QUERY_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_QUERY_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/query_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *QueryBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/query.h>
#else
#include <inline/query.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/query_protos.h>
#endif
#else
#include <pragma/query_lib.h>
#endif

#endif	/*  _PROTO_QUERY_H  */
