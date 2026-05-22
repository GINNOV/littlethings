#ifndef _PROTO_BSDSOCKET_H
#define _PROTO_BSDSOCKET_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#if !defined(CLIB_BSDSOCKET_PROTOS_H) && !defined(__GNUC__)
#pragma stdargs-on
#include <clib/bsdsocket_protos.h>
#pragma stdargs-off
#endif

#ifndef __NOLIBBASE__
extern struct Library *SocketBase;
#endif

#ifdef __GNUC__
#ifdef __AROS__
#include <defines/bsdsocket.h>
#else
#include <inline/bsdsocket.h>
#endif
#elif defined(__VBCC__)
#ifndef _NO_INLINE
#include <inline/bsdsocket_protos.h>
#endif
#else
#include <pragma/bsdsocket_lib.h>
#endif

#endif	/*  _PROTO_BSDSOCKET_H  */
