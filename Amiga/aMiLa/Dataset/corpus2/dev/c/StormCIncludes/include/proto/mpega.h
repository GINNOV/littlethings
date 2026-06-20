#ifndef _PROTO_MPEGA_H
#define _PROTO_MPEGA_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_MPEGA_PROTOS_H
#include <clib/mpega_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *MPEGABase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/mpega.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/mpega_lib.h>
#endif
#endif

#endif	/*  _PROTO_MPEGA_H  */
