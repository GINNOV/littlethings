#ifndef _PROTO_THREADPOOL_H
#define _PROTO_THREADPOOL_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_THREADPOOL_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/threadpool_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *ThreadPoolBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/threadpool.h>
#else
#include <inline/threadpool.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/threadpool_protos.h>
#endif
#else
#include <pragma/threadpool_lib.h>
#endif

#endif	/*  _PROTO_THREADPOOL_H  */
