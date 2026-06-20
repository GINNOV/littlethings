#ifndef _PROTO_CARDRES_H
#define _PROTO_CARDRES_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_CARDRES_PROTOS_H
#include <clib/cardres_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *CardResource;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/cardres.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/cardres_lib.h>
#endif
#endif

#endif	/*  _PROTO_CARDRES_H  */
