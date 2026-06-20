#ifndef _PROTO_INTUITION_H
#define _PROTO_INTUITION_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_INTUITION_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/intuition_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct IntuitionBase *IntuitionBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/intuition.h>
#else
#include <inline/intuition.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/intuition_protos.h>
#endif
#else
#include <pragma/intuition_lib.h>
#endif

#endif	/*  _PROTO_INTUITION_H  */
