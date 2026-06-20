#ifndef _PROTO_ASOUND_H
#define _PROTO_ASOUND_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_ASOUND_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/asound_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *ASoundBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/asound.h>
#else
#include <inline/asound.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/asound_protos.h>
#endif
#else
#include <pragma/asound_lib.h>
#endif

#endif	/*  _PROTO_ASOUND_H  */
