#ifndef _INCLUDE_PROTO_SOCKET_LOC_H
#define _INCLUDE_PROTO_SOCKET_LOC_H

#include <exec/types.h>

#ifdef __cplusplus
extern "C" {
#endif

LONG LOC_socket(struct Library * libbase, LONG domain, LONG type, LONG protocol);
#define socket(a, b, c) LOC_socket((struct Library *) SocketBase, a, b, c)

LONG LOC_bind(struct Library * libbase, LONG s, const struct sockaddr * name, LONG namelen);
#define bind(a, b, c) LOC_bind((struct Library *) SocketBase, a, b, c)

LONG LOC_listen(struct Library * libbase, LONG s, LONG backlog);
#define listen(a, b) LOC_listen((struct Library *) SocketBase, a, b)

LONG LOC_accept(struct Library * libbase, LONG s, struct sockaddr * addr, LONG * addrlen);
#define accept(a, b, c) LOC_accept((struct Library *) SocketBase, a, b, c)

LONG LOC_connect(struct Library * libbase, LONG s, const struct sockaddr * name, LONG namelen);
#define connect(a, b, c) LOC_connect((struct Library *) SocketBase, a, b, c)

LONG LOC_sendto(struct Library * libbase, LONG s, CONST_STRPTR msg, LONG len, LONG flags, const struct sockaddr * to, LONG tolen);
#define sendto(a, b, c, d, e, f) LOC_sendto((struct Library *) SocketBase, a, b, c, d, e, f)

LONG LOC_send(struct Library * libbase, LONG s, CONST_STRPTR msg, LONG len, LONG flags);
#define send(a, b, c, d) LOC_send((struct Library *) SocketBase, a, b, c, d)

LONG LOC_recvfrom(struct Library * libbase, LONG s, UBYTE * buf, LONG len, LONG flags, struct sockaddr * from, LONG * fromlen);
#define recvfrom(a, b, c, d, e, f) LOC_recvfrom((struct Library *) SocketBase, a, b, c, d, e, f)

LONG LOC_recv(struct Library * libbase, LONG s, UBYTE * buf, LONG len, LONG flags);
#define recv(a, b, c, d) LOC_recv((struct Library *) SocketBase, a, b, c, d)

LONG LOC_shutdown(struct Library * libbase, LONG s, LONG how);
#define shutdown(a, b) LOC_shutdown((struct Library *) SocketBase, a, b)

LONG LOC_setsockopt(struct Library * libbase, LONG s, LONG level, LONG optname, const void * optval, LONG optlen);
#define setsockopt(a, b, c, d, e) LOC_setsockopt((struct Library *) SocketBase, a, b, c, d, e)

LONG LOC_getsockopt(struct Library * libbase, LONG s, LONG level, LONG optname, void * optval, LONG * optlen);
#define getsockopt(a, b, c, d, e) LOC_getsockopt((struct Library *) SocketBase, a, b, c, d, e)

LONG LOC_getsockname(struct Library * libbase, LONG s, struct sockaddr * hostname, LONG * namelen);
#define getsockname(a, b, c) LOC_getsockname((struct Library *) SocketBase, a, b, c)

LONG LOC_getpeername(struct Library * libbase, LONG s, struct sockaddr * hostname, LONG * namelen);
#define getpeername(a, b, c) LOC_getpeername((struct Library *) SocketBase, a, b, c)

LONG LOC_IoctlSocket(struct Library * libbase, LONG d, ULONG request, char * argp);
#define IoctlSocket(a, b, c) LOC_IoctlSocket((struct Library *) SocketBase, a, b, c)

LONG LOC_CloseSocket(struct Library * libbase, LONG d);
#define CloseSocket(a) LOC_CloseSocket((struct Library *) SocketBase, a)

LONG LOC_WaitSelect(struct Library * libbase, LONG nfds, fd_set * readfds, fd_set * writefds, fd_set * execptfds, struct timeval * timeout, ULONG * maskp);
#define WaitSelect(a, b, c, d, e, f) LOC_WaitSelect((struct Library *) SocketBase, a, b, c, d, e, f)

void LOC_SetSocketSignals(struct Library * libbase, ULONG SIGINTR, ULONG SIGIO, ULONG SIGURG);
#define SetSocketSignals(a, b, c) LOC_SetSocketSignals((struct Library *) SocketBase, a, b, c)

LONG LOC_getdtablesize(struct Library * libbase);
#define getdtablesize(a) LOC_getdtablesize((struct Library *) a)

LONG LOC_ObtainSocket(struct Library * libbase, LONG id, LONG domain, LONG type, LONG protocol);
#define ObtainSocket(a, b, c, d) LOC_ObtainSocket((struct Library *) SocketBase, a, b, c, d)

LONG LOC_ReleaseSocket(struct Library * libbase, LONG fd, LONG id);
#define ReleaseSocket(a, b) LOC_ReleaseSocket((struct Library *) SocketBase, a, b)

LONG LOC_ReleaseCopyOfSocket(struct Library * libbase, LONG fd, LONG id);
#define ReleaseCopyOfSocket(a, b) LOC_ReleaseCopyOfSocket((struct Library *) SocketBase, a, b)

LONG LOC_Errno(struct Library * libbase);
#define Errno(a) LOC_Errno((struct Library *) a)

LONG LOC_SetErrnoPtr(struct Library * libbase, void * errno_p, LONG size);
#define SetErrnoPtr(a, b) LOC_SetErrnoPtr((struct Library *) SocketBase, a, b)

char * LOC_Inet_NtoA(struct Library * libbase, ULONG in);
#define Inet_NtoA(a) LOC_Inet_NtoA((struct Library *) SocketBase, a)

ULONG LOC_inet_addr(struct Library * libbase, CONST_STRPTR cp);
#define inet_addr(a) LOC_inet_addr((struct Library *) SocketBase, a)

ULONG LOC_Inet_LnaOf(struct Library * libbase, LONG in);
#define Inet_LnaOf(a) LOC_Inet_LnaOf((struct Library *) SocketBase, a)

ULONG LOC_Inet_NetOf(struct Library * libbase, LONG in);
#define Inet_NetOf(a) LOC_Inet_NetOf((struct Library *) SocketBase, a)

ULONG LOC_Inet_MakeAddr(struct Library * libbase, ULONG net, ULONG host);
#define Inet_MakeAddr(a, b) LOC_Inet_MakeAddr((struct Library *) SocketBase, a, b)

ULONG LOC_inet_network(struct Library * libbase, CONST_STRPTR cp);
#define inet_network(a) LOC_inet_network((struct Library *) SocketBase, a)

struct hostent  * LOC_gethostbyname(struct Library * libbase, CONST_STRPTR name);
#define gethostbyname(a) LOC_gethostbyname((struct Library *) SocketBase, a)

struct hostent  * LOC_gethostbyaddr(struct Library * libbase, CONST_STRPTR addr, LONG len, LONG type);
#define gethostbyaddr(a, b, c) LOC_gethostbyaddr((struct Library *) SocketBase, a, b, c)

struct netent   * LOC_getnetbyname(struct Library * libbase, CONST_STRPTR name);
#define getnetbyname(a) LOC_getnetbyname((struct Library *) SocketBase, a)

struct netent   * LOC_getnetbyaddr(struct Library * libbase, LONG net, LONG type);
#define getnetbyaddr(a, b) LOC_getnetbyaddr((struct Library *) SocketBase, a, b)

struct servent  * LOC_getservbyname(struct Library * libbase, CONST_STRPTR name, CONST_STRPTR proto);
#define getservbyname(a, b) LOC_getservbyname((struct Library *) SocketBase, a, b)

struct servent  * LOC_getservbyport(struct Library * libbase, LONG port, CONST_STRPTR proto);
#define getservbyport(a, b) LOC_getservbyport((struct Library *) SocketBase, a, b)

struct protoent * LOC_getprotobyname(struct Library * libbase, CONST_STRPTR name);
#define getprotobyname(a) LOC_getprotobyname((struct Library *) SocketBase, a)

struct protoent * LOC_getprotobynumber(struct Library * libbase, LONG proto);
#define getprotobynumber(a) LOC_getprotobynumber((struct Library *) SocketBase, a)

void LOC_vsyslog(struct Library * libbase, int level, const char * format, _BSD_VA_LIST_ ap);
#define vsyslog(a, b, c) LOC_vsyslog((struct Library *) SocketBase, a, b, c)

void LOC_syslog(struct Library * libbase, int level, const char * format, ...);
LONG LOC_Dup2Socket(struct Library * libbase, LONG fd1, LONG fd2);
#define Dup2Socket(a, b) LOC_Dup2Socket((struct Library *) SocketBase, a, b)

LONG LOC_sendmsg(struct Library * libbase, LONG s, struct msghdr * msg, LONG flags);
#define sendmsg(a, b, c) LOC_sendmsg((struct Library *) SocketBase, a, b, c)

LONG LOC_recvmsg(struct Library * libbase, LONG s, struct msghdr * msg, LONG flags);
#define recvmsg(a, b, c) LOC_recvmsg((struct Library *) SocketBase, a, b, c)

LONG LOC_gethostname(struct Library * libbase, STRPTR hostname, LONG size);
#define gethostname(a, b) LOC_gethostname((struct Library *) SocketBase, a, b)

ULONG LOC_gethostid(struct Library * libbase);
#define gethostid(a) LOC_gethostid((struct Library *) a)

LONG LOC_SocketBaseTagList(struct Library * libbase, struct TagItem * taglist);
#define SocketBaseTagList(a) LOC_SocketBaseTagList((struct Library *) SocketBase, a)

LONG LOC_SocketBaseTags(struct Library * libbase, ...);
LONG LOC_GetSocketEvents(struct Library * libbase, ULONG * eventmaskp);
#define GetSocketEvents(a) LOC_GetSocketEvents((struct Library *) SocketBase, a)

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PROTO_SOCKET_LOC_H  */
