#ifndef _PROTO_SKETCHBOARD_H
#define _PROTO_SKETCHBOARD_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_SKETCHBOARD_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/sketchboard_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *SketchBoardBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/sketchboard.h>
#else
#include <inline/sketchboard.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/sketchboard_protos.h>
#endif
#else
#include <pragma/sketchboard_lib.h>
#endif

#endif	/*  _PROTO_SKETCHBOARD_H  */
