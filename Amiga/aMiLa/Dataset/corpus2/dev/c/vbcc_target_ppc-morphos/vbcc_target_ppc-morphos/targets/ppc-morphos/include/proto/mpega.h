#ifndef _PROTO_MPEGA_H
#define _PROTO_MPEGA_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_MPEGA_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/mpega_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *MPEGABase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/mpega.h>
#else
#include <inline/mpega.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/mpega_protos.h>
#endif
#else
#include <pragma/mpega_lib.h>
#endif

#endif	/*  _PROTO_MPEGA_H  */
