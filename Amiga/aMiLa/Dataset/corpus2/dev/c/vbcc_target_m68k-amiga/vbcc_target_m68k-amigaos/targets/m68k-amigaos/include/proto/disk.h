#ifndef _PROTO_DISK_H
#define _PROTO_DISK_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_DISK_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/disk_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct DiskResource *DiskBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/disk.h>
#else
#include <inline/disk.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/disk_protos.h>
#endif
#else
#include <pragma/disk_lib.h>
#endif

#endif	/*  _PROTO_DISK_H  */
