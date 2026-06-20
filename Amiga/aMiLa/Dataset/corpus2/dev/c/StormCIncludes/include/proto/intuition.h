#ifndef _PROTO_INTUITION_H
#define _PROTO_INTUITION_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_INTUITION_PROTOS_H
#include <clib/intuition_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct IntuitionBase *IntuitionBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/intuition.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/intuition_lib.h>
#endif
#endif

#endif	/*  _PROTO_INTUITION_H  */
