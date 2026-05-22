#ifndef _PROTO_CIA_H
#define _PROTO_CIA_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_CIA_PROTOS_H
#include <clib/cia_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *CIABase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/cia.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/cia_lib.h>
#endif
#endif

#endif	/*  _PROTO_CIA_H  */
