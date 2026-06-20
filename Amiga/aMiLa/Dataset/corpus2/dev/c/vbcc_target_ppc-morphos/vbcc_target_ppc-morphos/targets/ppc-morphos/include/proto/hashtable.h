#ifndef _PROTO_HASHTABLE_H
#define _PROTO_HASHTABLE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_HASHTABLE_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/hashtable_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *HashTableBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/hashtable.h>
#else
#include <inline/hashtable.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/hashtable_protos.h>
#endif
#else
#include <pragma/hashtable_lib.h>
#endif

#endif	/*  _PROTO_HASHTABLE_H  */
