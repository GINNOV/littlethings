#ifndef _PROTO_MATHFFP_H
#define _PROTO_MATHFFP_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_MATHFFP_PROTOS_H
#include <clib/mathffp_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *MathBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/mathffp.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/mathffp_lib.h>
#endif
#endif

#endif	/*  _PROTO_MATHFFP_H  */
