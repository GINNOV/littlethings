#ifndef _PROTO_RAMDRIVE_H
#define _PROTO_RAMDRIVE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_RAMDRIVE_PROTOS_H
#include <clib/ramdrive_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Device *RamdriveDevice;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/ramdrive.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/ramdrive_lib.h>
#endif
#endif

#endif	/*  _PROTO_RAMDRIVE_H  */
