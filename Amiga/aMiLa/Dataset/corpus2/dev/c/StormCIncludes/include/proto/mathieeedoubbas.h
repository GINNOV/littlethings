#ifndef _PROTO_MATHIEEEDOUBBAS_H
#define _PROTO_MATHIEEEDOUBBAS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_MATHIEEEDOUBBAS_PROTOS_H
#include <clib/mathieeedoubbas_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct MathIEEEBase *MathIeeeDoubBasBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/mathieeedoubbas.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/mathieeedoubbas_lib.h>
#endif
#endif

#endif	/*  _PROTO_MATHIEEEDOUBBAS_H  */
