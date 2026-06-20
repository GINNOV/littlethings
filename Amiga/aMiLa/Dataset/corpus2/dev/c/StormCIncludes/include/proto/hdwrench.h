#ifndef _PROTO_HDWRENCH_H
#define _PROTO_HDWRENCH_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_HDWRENCH_PROTOS_H
#include <clib/hdwrench_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *HDWBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/hdwrench.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/hdwrench_lib.h>
#endif
#endif

#endif	/*  _PROTO_HDWRENCH_H  */
