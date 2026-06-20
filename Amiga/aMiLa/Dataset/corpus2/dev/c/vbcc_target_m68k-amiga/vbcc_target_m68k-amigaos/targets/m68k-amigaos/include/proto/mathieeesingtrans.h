#ifndef _PROTO_MATHIEEESINGTRANS_H
#define _PROTO_MATHIEEESINGTRANS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_MATHIEEESINGTRANS_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/mathieeesingtrans_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct MathIEEEBase *MathIeeeSingTransBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/mathieeesingtrans.h>
#else
#include <inline/mathieeesingtrans.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/mathieeesingtrans_protos.h>
#endif
#else
#include <pragma/mathieeesingtrans_lib.h>
#endif

#endif	/*  _PROTO_MATHIEEESINGTRANS_H  */
