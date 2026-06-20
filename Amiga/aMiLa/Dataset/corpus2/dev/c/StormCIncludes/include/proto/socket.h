#ifndef _PROTO_SOCKET_H
#define _PROTO_SOCKET_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef CLIB_SOCKET_PROTOS_H
#include <clib/socket_protos.h>
#endif

#ifndef __NOLIBBASE__
extern struct Library *SocketBase;
#endif

#ifdef __GNUC__
#if !defined(__cplusplus) && !defined(__PPC__) && !defined(NO_INLINE_LIBCALLS)
#include <inline/socket.h>
#endif
#elif !defined(__VBCC__)
#ifndef __PPC__
#include <pragma/socket_lib.h>
#endif
#endif

#endif	/*  _PROTO_SOCKET_H  */
