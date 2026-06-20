#ifndef _PROTO_AC97MIXER_H
#define _PROTO_AC97MIXER_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_AC97MIXER_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/ac97mixer_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *AC97MixerBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/ac97mixer.h>
#else
#include <inline/ac97mixer.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/ac97mixer_protos.h>
#endif
#else
#include <pragma/ac97mixer_lib.h>
#endif

#endif	/*  _PROTO_AC97MIXER_H  */
