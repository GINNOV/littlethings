#ifndef BSDSOCKET_H
#define BSDSOCKET_H

#ifndef _UNISTD_H_
#include <unistd.h>
#endif

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef _CDEFS_H_
#include <sys/cdefs.h>
#endif
#ifndef EXEC_LIBRARIES_H
struct Library;
#endif
#ifndef _SYS_TIME_H_
#include <sys/time.h>
#endif
#ifndef _SYS_SOCKET_H
#include <sys/socket.h>
#endif
#ifndef NETDB_H
struct hostent;
struct netent;
struct servent;
struct protoent;
#endif
#ifndef NETINET_IN_H
#include <netinet/in.h>
#endif
#ifndef _STAT_H
#include <sys/stat.h>
#endif

#ifndef _STDARG_H
#include <stdarg.h>
#endif

/* autoinit.c */
extern int h_errno;
extern struct Library *SocketBase;
long __stdargs _STI_200_openSockets(void);
void __stdargs _STD_200_closeSockets(void);

/* dummy.c */
struct hostent  *gethostent(void);
struct netent  *getnetent(void);
struct servent  *getservent(void);
struct protoent *getprotoent(void);

/* stubs.c */
#if !defined(_OPTINLINE) /* these are inlined for SAS/C */
char * inet_ntoa(struct in_addr addr);
struct in_addr inet_makeaddr(int net, int host);
unsigned long inet_lnaof(struct in_addr addr);
unsigned long inet_netof(struct in_addr addr);
#endif

#endif
