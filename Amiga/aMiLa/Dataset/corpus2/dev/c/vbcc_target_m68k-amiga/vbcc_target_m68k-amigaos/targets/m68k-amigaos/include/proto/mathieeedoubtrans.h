#ifndef _PROTO_MATHIEEEDOUBTRANS_H
#define _PROTO_MATHIEEEDOUBTRANS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_MATHIEEEDOUBTRANS_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/mathieeedoubtrans_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct MathIEEEBase *MathIeeeDoubTransBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/mathieeedoubtrans.h>
#else
#include <inline/mathieeedoubtrans.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/mathieeedoubtrans_protos.h>
#endif
#else
#include <pragma/mathieeedoubtrans_lib.h>
#endif

#endif	/*  _PROTO_MATHIEEEDOUBTRANS_H  */
