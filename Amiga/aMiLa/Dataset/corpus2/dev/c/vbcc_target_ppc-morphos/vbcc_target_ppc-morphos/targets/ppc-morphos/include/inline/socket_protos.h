#ifndef _VBCCINLINE_SOCKET_H
#define _VBCCINLINE_SOCKET_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

LONG __socket(void *, LONG domain, LONG type, LONG protocol) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define socket(domain, type, protocol) __socket(SocketBase, (domain), (type), (protocol))

LONG __bind(void *, LONG s, const struct sockaddr * name, LONG namelen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define bind(s, name, namelen) __bind(SocketBase, (s), (name), (namelen))

LONG __listen(void *, LONG s, LONG backlog) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define listen(s, backlog) __listen(SocketBase, (s), (backlog))

LONG __accept(void *, LONG s, struct sockaddr * addr, LONG * addrlen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define accept(s, addr, addrlen) __accept(SocketBase, (s), (addr), (addrlen))

LONG __connect(void *, LONG s, const struct sockaddr * name, LONG namelen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define connect(s, name, namelen) __connect(SocketBase, (s), (name), (namelen))

LONG __sendto(void *, LONG s, const UBYTE * msg, LONG len, LONG flags, const struct sockaddr * to, LONG tolen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,36(2)\n"
	"\tstw\t9,12(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define sendto(s, msg, len, flags, to, tolen) __sendto(SocketBase, (s), (msg), (len), (flags), (to), (tolen))

LONG __send(void *, LONG s, const UBYTE * msg, LONG len, LONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define send(s, msg, len, flags) __send(SocketBase, (s), (msg), (len), (flags))

LONG __recvfrom(void *, LONG s, UBYTE * buf, LONG len, LONG flags, struct sockaddr * from, LONG * fromlen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,36(2)\n"
	"\tstw\t9,40(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define recvfrom(s, buf, len, flags, from, fromlen) __recvfrom(SocketBase, (s), (buf), (len), (flags), (from), (fromlen))

LONG __recv(void *, LONG s, UBYTE * buf, LONG len, LONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define recv(s, buf, len, flags) __recv(SocketBase, (s), (buf), (len), (flags))

LONG __shutdown(void *, LONG s, LONG how) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define shutdown(s, how) __shutdown(SocketBase, (s), (how))

LONG __setsockopt(void *, LONG s, LONG level, LONG optname, const void * optval, LONG optlen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tstw\t7,32(2)\n"
	"\tstw\t8,12(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define setsockopt(s, level, optname, optval, optlen) __setsockopt(SocketBase, (s), (level), (optname), (optval), (optlen))

LONG __getsockopt(void *, LONG s, LONG level, LONG optname, void * optval, LONG * optlen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tstw\t7,32(2)\n"
	"\tstw\t8,36(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define getsockopt(s, level, optname, optval, optlen) __getsockopt(SocketBase, (s), (level), (optname), (optval), (optlen))

LONG __getsockname(void *, LONG s, struct sockaddr * hostname, LONG * namelen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define getsockname(s, hostname, namelen) __getsockname(SocketBase, (s), (hostname), (namelen))

LONG __getpeername(void *, LONG s, struct sockaddr * hostname, LONG * namelen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define getpeername(s, hostname, namelen) __getpeername(SocketBase, (s), (hostname), (namelen))

LONG __IoctlSocket(void *, LONG d, ULONG request, char * argp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,32(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define IoctlSocket(d, request, argp) __IoctlSocket(SocketBase, (d), (request), (argp))

LONG __CloseSocket(void *, LONG d) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define CloseSocket(d) __CloseSocket(SocketBase, (d))

LONG __WaitSelect(void *, LONG nfds, fd_set * readfds, fd_set * writefds, fd_set * execptfds, struct timeval * timeout, ULONG * maskp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\tstw\t7,40(2)\n"
	"\tstw\t8,44(2)\n"
	"\tstw\t9,4(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define WaitSelect(nfds, readfds, writefds, execptfds, timeout, maskp) __WaitSelect(SocketBase, (nfds), (readfds), (writefds), (execptfds), (timeout), (maskp))

void __SetSocketSignals(void *, ULONG SIGINTR, ULONG SIGIO, ULONG SIGURG) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define SetSocketSignals(SIGINTR, SIGIO, SIGURG) __SetSocketSignals(SocketBase, (SIGINTR), (SIGIO), (SIGURG))

LONG __getdtablesize(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define getdtablesize() __getdtablesize(SocketBase)

LONG __ObtainSocket(void *, LONG id, LONG domain, LONG type, LONG protocol) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tstw\t7,12(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define ObtainSocket(id, domain, type, protocol) __ObtainSocket(SocketBase, (id), (domain), (type), (protocol))

LONG __ReleaseSocket(void *, LONG fd, LONG id) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define ReleaseSocket(fd, id) __ReleaseSocket(SocketBase, (fd), (id))

LONG __ReleaseCopyOfSocket(void *, LONG fd, LONG id) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define ReleaseCopyOfSocket(fd, id) __ReleaseCopyOfSocket(SocketBase, (fd), (id))

LONG __Errno(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define Errno() __Errno(SocketBase)

LONG __SetErrnoPtr(void *, void * errno_p, LONG size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-168\n"
	"\tbctrl";
#define SetErrnoPtr(errno_p, size) __SetErrnoPtr(SocketBase, (errno_p), (size))

char * __Inet_NtoA(void *, ULONG in) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-174\n"
	"\tbctrl";
#define Inet_NtoA(in) __Inet_NtoA(SocketBase, (in))

ULONG __inet_addr(void *, const UBYTE * cp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-180\n"
	"\tbctrl";
#define inet_addr(cp) __inet_addr(SocketBase, (cp))

ULONG __Inet_LnaOf(void *, LONG in) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-186\n"
	"\tbctrl";
#define Inet_LnaOf(in) __Inet_LnaOf(SocketBase, (in))

ULONG __Inet_NetOf(void *, LONG in) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-192\n"
	"\tbctrl";
#define Inet_NetOf(in) __Inet_NetOf(SocketBase, (in))

ULONG __Inet_MakeAddr(void *, ULONG net, ULONG host) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-198\n"
	"\tbctrl";
#define Inet_MakeAddr(net, host) __Inet_MakeAddr(SocketBase, (net), (host))

ULONG __inet_network(void *, const UBYTE * cp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-204\n"
	"\tbctrl";
#define inet_network(cp) __inet_network(SocketBase, (cp))

struct hostent  * __gethostbyname(void *, const UBYTE * name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-210\n"
	"\tbctrl";
#define gethostbyname(name) __gethostbyname(SocketBase, (name))

struct hostent  * __gethostbyaddr(void *, const UBYTE * addr, LONG len, LONG type) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-216\n"
	"\tbctrl";
#define gethostbyaddr(addr, len, type) __gethostbyaddr(SocketBase, (addr), (len), (type))

struct netent   * __getnetbyname(void *, const UBYTE * name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-222\n"
	"\tbctrl";
#define getnetbyname(name) __getnetbyname(SocketBase, (name))

struct netent   * __getnetbyaddr(void *, LONG net, LONG type) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-228\n"
	"\tbctrl";
#define getnetbyaddr(net, type) __getnetbyaddr(SocketBase, (net), (type))

struct servent  * __getservbyname(void *, const UBYTE * name, const UBYTE * proto) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-234\n"
	"\tbctrl";
#define getservbyname(name, proto) __getservbyname(SocketBase, (name), (proto))

struct servent  * __getservbyport(void *, LONG port, const UBYTE * proto) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-240\n"
	"\tbctrl";
#define getservbyport(port, proto) __getservbyport(SocketBase, (port), (proto))

struct protoent * __getprotobyname(void *, const UBYTE * name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-246\n"
	"\tbctrl";
#define getprotobyname(name) __getprotobyname(SocketBase, (name))

struct protoent * __getprotobynumber(void *, LONG proto) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-252\n"
	"\tbctrl";
#define getprotobynumber(proto) __getprotobynumber(SocketBase, (proto))

void __vsyslog(void *, ULONG level, const char * format, LONG * ap) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-258\n"
	"\tbctrl";
#define vsyslog(level, format, ap) __vsyslog(SocketBase, (level), (format), (ap))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void __linearvarargs __syslog(void *, ULONG level, const char * format, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-258\n"
	"\tbctrl";
#define syslog(level, ...) __syslog(SocketBase, (level), __VA_ARGS__)
#endif

LONG __Dup2Socket(void *, LONG fd1, LONG fd2) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-264\n"
	"\tbctrl";
#define Dup2Socket(fd1, fd2) __Dup2Socket(SocketBase, (fd1), (fd2))

LONG __sendmsg(void *, LONG s, struct msghdr * msg, LONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-270\n"
	"\tbctrl";
#define sendmsg(s, msg, flags) __sendmsg(SocketBase, (s), (msg), (flags))

LONG __recvmsg(void *, LONG s, struct msghdr * msg, LONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-276\n"
	"\tbctrl";
#define recvmsg(s, msg, flags) __recvmsg(SocketBase, (s), (msg), (flags))

LONG __gethostname(void *, STRPTR hostname, LONG size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-282\n"
	"\tbctrl";
#define gethostname(hostname, size) __gethostname(SocketBase, (hostname), (size))

ULONG __gethostid(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-288\n"
	"\tbctrl";
#define gethostid() __gethostid(SocketBase)

LONG __SocketBaseTagList(void *, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-294\n"
	"\tbctrl";
#define SocketBaseTagList(taglist) __SocketBaseTagList(SocketBase, (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __SocketBaseTags(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-294\n"
	"\tbctrl";
#define SocketBaseTags(...) __SocketBaseTags(SocketBase, __VA_ARGS__)
#endif

LONG __GetSocketEvents(void *, ULONG * eventmaskp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-300\n"
	"\tbctrl";
#define GetSocketEvents(eventmaskp) __GetSocketEvents(SocketBase, (eventmaskp))

#endif /*  _VBCCINLINE_SOCKET_H  */
