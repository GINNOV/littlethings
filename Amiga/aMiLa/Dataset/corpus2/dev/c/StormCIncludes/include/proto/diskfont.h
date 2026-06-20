#ifndef _PROTO_DISKFONT_H
#define _PROTO_DISKFONT_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_DISKFONT_PROTOS_H
#include <clib/diskfont_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *DiskfontBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/diskfont.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/diskfont_lib.h>
#endif
#endif

#endif	/*  _PROTO_DISKFONT_H  */
