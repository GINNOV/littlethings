#ifndef _PROTO_KEYMAP_H
#define _PROTO_KEYMAP_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_KEYMAP_PROTOS_H
#include <clib/keymap_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *KeymapBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/keymap.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/keymap_lib.h>
#endif
#endif

#endif	/*  _PROTO_KEYMAP_H  */
