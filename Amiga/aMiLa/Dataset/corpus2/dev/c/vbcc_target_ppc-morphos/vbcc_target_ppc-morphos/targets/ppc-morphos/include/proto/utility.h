#ifndef _PROTO_UTILITY_H
#define _PROTO_UTILITY_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_UTILITY_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/utility_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct UtilityBase *UtilityBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/utility.h>
#else
#include <inline/utility.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/utility_protos.h>
#endif
#else
#include <pragma/utility_lib.h>
#endif

#endif	/*  _PROTO_UTILITY_H  */
