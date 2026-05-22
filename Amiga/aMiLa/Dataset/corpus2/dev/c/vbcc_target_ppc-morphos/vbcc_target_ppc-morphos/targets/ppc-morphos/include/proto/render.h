#ifndef _PROTO_RENDER_H
#define _PROTO_RENDER_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_RENDER_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/render_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *RenderBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/render.h>
#else
#include <inline/render.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/render_protos.h>
#endif
#else
#include <pragma/render_lib.h>
#endif

#endif	/*  _PROTO_RENDER_H  */
