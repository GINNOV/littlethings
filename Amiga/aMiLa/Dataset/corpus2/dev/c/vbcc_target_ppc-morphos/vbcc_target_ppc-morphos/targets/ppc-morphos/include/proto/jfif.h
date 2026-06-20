#ifndef _PROTO_JFIF_H
#define _PROTO_JFIF_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_JFIF_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/jfif_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *JFIFBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/jfif.h>
#else
#include <inline/jfif.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/jfif_protos.h>
#endif
#else
#include <pragma/jfif_lib.h>
#endif

#endif	/*  _PROTO_JFIF_H  */
