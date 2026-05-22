#ifndef _PROTO_EXPAT_H
#define _PROTO_EXPAT_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_EXPAT_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/expat_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *ExpatBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/expat.h>
#else
#include <inline/expat.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/expat_protos.h>
#endif
#else
#include <pragma/expat_lib.h>
#endif

#endif	/*  _PROTO_EXPAT_H  */
