#ifndef _PROTO_MATHIEEEDOUBTRANS_H
#define _PROTO_MATHIEEEDOUBTRANS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_MATHIEEEDOUBTRANS_PROTOS_H
#include <clib/mathieeedoubtrans_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct MathIEEEBase *MathIeeeDoubTransBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/mathieeedoubtrans.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/mathieeedoubtrans_lib.h>
#endif
#endif

#endif	/*  _PROTO_MATHIEEEDOUBTRANS_H  */
