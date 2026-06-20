#ifndef _PROTO_BATTMEM_H
#define _PROTO_BATTMEM_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_BATTMEM_PROTOS_H
#include <clib/battmem_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *BattMemBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/battmem.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/battmem_lib.h>
#endif
#endif

#endif	/*  _PROTO_BATTMEM_H  */
