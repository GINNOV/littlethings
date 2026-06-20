#ifndef _PROTO_ASL_H
#define _PROTO_ASL_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_ASL_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/asl_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *AslBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/asl.h>
#else
#include <inline/asl.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/asl_protos.h>
#endif
#else
#include <pragma/asl_lib.h>
#endif

#endif	/*  _PROTO_ASL_H  */
