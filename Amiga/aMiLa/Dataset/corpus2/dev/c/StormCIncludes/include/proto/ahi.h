#ifndef _PROTO_AHI_H
#define _PROTO_AHI_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_AHI_PROTOS_H
#include <clib/ahi_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *AHIBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/ahi.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/ahi_lib.h>
#endif
#endif

#endif	/*  _PROTO_AHI_H  */
