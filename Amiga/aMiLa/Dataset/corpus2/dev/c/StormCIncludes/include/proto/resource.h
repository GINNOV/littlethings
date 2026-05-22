#ifndef _PROTO_RESOURCE_H
#define _PROTO_RESOURCE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_RESOURCE_PROTOS_H
#include <clib/resource_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *ResourceBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/resource.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/resource_lib.h>
#endif
#endif

#endif	/*  _PROTO_RESOURCE_H  */
