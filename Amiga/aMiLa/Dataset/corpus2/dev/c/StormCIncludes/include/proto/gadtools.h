#ifndef _PROTO_GADTOOLS_H
#define _PROTO_GADTOOLS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_GADTOOLS_PROTOS_H
#include <clib/gadtools_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *GadToolsBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/gadtools.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/gadtools_lib.h>
#endif
#endif

#endif	/*  _PROTO_GADTOOLS_H  */
