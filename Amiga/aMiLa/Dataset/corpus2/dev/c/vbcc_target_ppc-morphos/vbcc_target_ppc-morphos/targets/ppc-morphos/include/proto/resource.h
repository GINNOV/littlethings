#ifndef _PROTO_RESOURCE_H
#define _PROTO_RESOURCE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_RESOURCE_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/resource_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *ResourceBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/resource.h>
#else
#include <inline/resource.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/resource_protos.h>
#endif
#else
#include <pragma/resource_lib.h>
#endif

#endif	/*  _PROTO_RESOURCE_H  */
