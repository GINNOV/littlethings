#ifndef _SYS_SOCKET_H
#define _SYS_SOCKET_H

#ifdef AMITCP

#ifndef _TYPES_H_
#include <sys/types.h>
#define SYS_TYPES_H
#endif
#include "netinclude:sys/socket.h"

#else

/* Support for socket pairs only */
#define AF_UNIX 1
#define SOCK_STREAM 1

#endif

extern int socketpair(int, int, int, int *);

#endif
