#ifndef _PROTO_MISC_H
#define _PROTO_MISC_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_MISC_PROTOS_H
#include <clib/misc_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *MiscBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/misc.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/misc_lib.h>
#endif
#endif

#endif	/*  _PROTO_MISC_H  */
