#ifndef _PROTO_SPACE_H
#define _PROTO_SPACE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_SPACE_PROTOS_H
#include <clib/space_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *SpaceBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/space.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/space_lib.h>
#endif
#endif

#endif	/*  _PROTO_SPACE_H  */
