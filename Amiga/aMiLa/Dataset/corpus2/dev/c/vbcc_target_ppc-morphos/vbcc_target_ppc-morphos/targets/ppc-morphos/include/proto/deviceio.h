#ifndef _PROTO_DEVICEIO_H
#define _PROTO_DEVICEIO_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_DEVICEIO_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/deviceio_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *DeviceIOBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/deviceio.h>
#else
#include <inline/deviceio.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/deviceio_protos.h>
#endif
#else
#include <pragma/deviceio_lib.h>
#endif

#endif	/*  _PROTO_DEVICEIO_H  */
