#ifndef _PROTO_DISK_H
#define _PROTO_DISK_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_DISK_PROTOS_H
#include <clib/disk_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct DiskResource *DiskBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/disk.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/disk_lib.h>
#endif
#endif

#endif	/*  _PROTO_DISK_H  */
