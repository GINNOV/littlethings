#ifndef _PROTO_PPD_H
#define _PROTO_PPD_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_PPD_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/ppd_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *PPDBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/ppd.h>
#else
#include <inline/ppd.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/ppd_protos.h>
#endif
#else
#include <pragma/ppd_lib.h>
#endif

#endif	/*  _PROTO_PPD_H  */
