#ifndef _PROTO_MULTIMEDIA_H
#define _PROTO_MULTIMEDIA_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_MULTIMEDIA_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/multimedia_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *MultimediaBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/multimedia.h>
#else
#include <inline/multimedia.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/multimedia_protos.h>
#endif
#else
#include <pragma/multimedia_lib.h>
#endif

#endif	/*  _PROTO_MULTIMEDIA_H  */
