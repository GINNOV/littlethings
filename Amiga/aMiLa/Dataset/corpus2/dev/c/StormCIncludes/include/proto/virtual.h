#ifndef PROTO_VIRTUAL_H
#define PROTO_VIRTUAL_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_VIRTUAL_PROTOS_H
#include <clib/virtual_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *VirtualBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/virtual.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/virtual_lib.h>
#endif
#endif

#endif	/*  _PROTO_VIRTUAL_H  */
