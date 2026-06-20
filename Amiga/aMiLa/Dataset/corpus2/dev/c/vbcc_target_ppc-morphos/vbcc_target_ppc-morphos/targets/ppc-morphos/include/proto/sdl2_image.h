#ifndef _PROTO_SDL2_IMAGE_H
#define _PROTO_SDL2_IMAGE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_SDL2_IMAGE_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/sdl2_image_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *SDL2ImageBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/sdl2_image.h>
#else
#include <inline/sdl2_image.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/sdl2_image_protos.h>
#endif
#else
#include <pragma/sdl2_image_lib.h>
#endif

#endif	/*  _PROTO_SDL2_IMAGE_H  */
