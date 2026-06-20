#ifndef _PROTO_SLIDER_H
#define _PROTO_SLIDER_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_SLIDER_PROTOS_H
#include <clib/slider_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *SliderBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/slider.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/slider_lib.h>
#endif
#endif

#endif	/*  _PROTO_SLIDER_H  */
