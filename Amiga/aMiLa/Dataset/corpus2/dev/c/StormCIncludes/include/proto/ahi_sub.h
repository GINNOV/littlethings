#ifndef _PROTO_AHI_SUB_H
#define _PROTO_AHI_SUB_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_AHI_SUB_PROTOS_H
#include <clib/ahi_sub_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *AHIsubBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/ahi_sub.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/ahi_sub_lib.h>
#endif
#endif

#endif	/*  _PROTO_AHI_SUB_H  */
