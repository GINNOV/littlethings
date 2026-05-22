#ifndef _PROTO_BULLET_H
#define _PROTO_BULLET_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_BULLET_PROTOS_H
#include <clib/bullet_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *BulletBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/bullet.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/bullet_lib.h>
#endif
#endif

#endif	/*  _PROTO_BULLET_H  */
