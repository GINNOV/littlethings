#ifndef _PROTO_DOS_H
#define _PROTO_DOS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_DOS_PROTOS_H
#include <clib/dos_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct DosLibrary *DOSBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/dos.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/dos_lib.h>
#endif
#endif

#endif	/*  _PROTO_DOS_H  */
