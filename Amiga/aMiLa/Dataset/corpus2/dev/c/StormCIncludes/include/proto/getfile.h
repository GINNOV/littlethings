#ifndef _PROTO_GETFILE_H
#define _PROTO_GETFILE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_GETFILE_PROTOS_H
#include <clib/getfile_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *GetFileBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/getfile.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/getfile_lib.h>
#endif
#endif

#endif	/*  _PROTO_GETFILE_H  */
