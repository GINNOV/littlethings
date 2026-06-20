#ifndef _INLINE_SOCKET_H
#define _INLINE_SOCKET_H

#ifndef SOCKET_BASE_NAME
#define SOCKET_BASE_NAME SocketBase
#endif

#define socket(domain, type, protocol) \
	((LONG (*)(LONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 30))(domain, type, protocol, (struct Library *) SOCKET_BASE_NAME)

#define bind(s, name, namelen) \
	((LONG (*)(LONG __asm("d0"), const struct sockaddr * __asm("a0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 36))(s, name, namelen, (struct Library *) SOCKET_BASE_NAME)

#define listen(s, backlog) \
	((LONG (*)(LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 42))(s, backlog, (struct Library *) SOCKET_BASE_NAME)

#define accept(s, addr, addrlen) \
	((LONG (*)(LONG __asm("d0"), struct sockaddr * __asm("a0"), LONG * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 48))(s, addr, addrlen, (struct Library *) SOCKET_BASE_NAME)

#define connect(s, name, namelen) \
	((LONG (*)(LONG __asm("d0"), const struct sockaddr * __asm("a0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 54))(s, name, namelen, (struct Library *) SOCKET_BASE_NAME)

#define sendto(s, msg, len, flags, to, tolen) \
	((LONG (*)(LONG __asm("d0"), CONST_STRPTR __asm("a0"), LONG __asm("d1"), LONG __asm("d2"), const struct sockaddr * __asm("a1"), LONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 60))(s, msg, len, flags, to, tolen, (struct Library *) SOCKET_BASE_NAME)

#define send(s, msg, len, flags) \
	((LONG (*)(LONG __asm("d0"), CONST_STRPTR __asm("a0"), LONG __asm("d1"), LONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 66))(s, msg, len, flags, (struct Library *) SOCKET_BASE_NAME)

#define recvfrom(s, buf, len, flags, from, fromlen) \
	((LONG (*)(LONG __asm("d0"), UBYTE * __asm("a0"), LONG __asm("d1"), LONG __asm("d2"), struct sockaddr * __asm("a1"), LONG * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 72))(s, buf, len, flags, from, fromlen, (struct Library *) SOCKET_BASE_NAME)

#define recv(s, buf, len, flags) \
	((LONG (*)(LONG __asm("d0"), UBYTE * __asm("a0"), LONG __asm("d1"), LONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 78))(s, buf, len, flags, (struct Library *) SOCKET_BASE_NAME)

#define shutdown(s, how) \
	((LONG (*)(LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 84))(s, how, (struct Library *) SOCKET_BASE_NAME)

#define setsockopt(s, level, optname, optval, optlen) \
	((LONG (*)(LONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), const void * __asm("a0"), LONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 90))(s, level, optname, optval, optlen, (struct Library *) SOCKET_BASE_NAME)

#define getsockopt(s, level, optname, optval, optlen) \
	((LONG (*)(LONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), void * __asm("a0"), LONG * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 96))(s, level, optname, optval, optlen, (struct Library *) SOCKET_BASE_NAME)

#define getsockname(s, hostname, namelen) \
	((LONG (*)(LONG __asm("d0"), struct sockaddr * __asm("a0"), LONG * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 102))(s, hostname, namelen, (struct Library *) SOCKET_BASE_NAME)

#define getpeername(s, hostname, namelen) \
	((LONG (*)(LONG __asm("d0"), struct sockaddr * __asm("a0"), LONG * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 108))(s, hostname, namelen, (struct Library *) SOCKET_BASE_NAME)

#define IoctlSocket(d, request, argp) \
	((LONG (*)(LONG __asm("d0"), ULONG __asm("d1"), char * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 114))(d, request, argp, (struct Library *) SOCKET_BASE_NAME)

#define CloseSocket(d) \
	((LONG (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 120))(d, (struct Library *) SOCKET_BASE_NAME)

#define WaitSelect(nfds, readfds, writefds, execptfds, timeout, maskp) \
	((LONG (*)(LONG __asm("d0"), fd_set * __asm("a0"), fd_set * __asm("a1"), fd_set * __asm("a2"), struct timeval * __asm("a3"), ULONG * __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 126))(nfds, readfds, writefds, execptfds, timeout, maskp, (struct Library *) SOCKET_BASE_NAME)

#define SetSocketSignals(SIGINTR, SIGIO, SIGURG) \
	((void (*)(ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 132))(SIGINTR, SIGIO, SIGURG, (struct Library *) SOCKET_BASE_NAME)

#define getdtablesize() \
	((LONG (*)(struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 138))((struct Library *) SOCKET_BASE_NAME)

#define ObtainSocket(id, domain, type, protocol) \
	((LONG (*)(LONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 144))(id, domain, type, protocol, (struct Library *) SOCKET_BASE_NAME)

#define ReleaseSocket(fd, id) \
	((LONG (*)(LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 150))(fd, id, (struct Library *) SOCKET_BASE_NAME)

#define ReleaseCopyOfSocket(fd, id) \
	((LONG (*)(LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 156))(fd, id, (struct Library *) SOCKET_BASE_NAME)

#define Errno() \
	((LONG (*)(struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 162))((struct Library *) SOCKET_BASE_NAME)

#define SetErrnoPtr(errno_p, size) \
	((LONG (*)(void * __asm("a0"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 168))(errno_p, size, (struct Library *) SOCKET_BASE_NAME)

#define Inet_NtoA(in) \
	((char * (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 174))(in, (struct Library *) SOCKET_BASE_NAME)

#define inet_addr(cp) \
	((ULONG (*)(CONST_STRPTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 180))(cp, (struct Library *) SOCKET_BASE_NAME)

#define Inet_LnaOf(in) \
	((ULONG (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 186))(in, (struct Library *) SOCKET_BASE_NAME)

#define Inet_NetOf(in) \
	((ULONG (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 192))(in, (struct Library *) SOCKET_BASE_NAME)

#define Inet_MakeAddr(net, host) \
	((ULONG (*)(ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 198))(net, host, (struct Library *) SOCKET_BASE_NAME)

#define inet_network(cp) \
	((ULONG (*)(CONST_STRPTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 204))(cp, (struct Library *) SOCKET_BASE_NAME)

#define gethostbyname(name) \
	((struct hostent  * (*)(CONST_STRPTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 210))(name, (struct Library *) SOCKET_BASE_NAME)

#define gethostbyaddr(addr, len, type) \
	((struct hostent  * (*)(CONST_STRPTR __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 216))(addr, len, type, (struct Library *) SOCKET_BASE_NAME)

#define getnetbyname(name) \
	((struct netent   * (*)(CONST_STRPTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 222))(name, (struct Library *) SOCKET_BASE_NAME)

#define getnetbyaddr(net, type) \
	((struct netent   * (*)(LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 228))(net, type, (struct Library *) SOCKET_BASE_NAME)

#define getservbyname(name, proto) \
	((struct servent  * (*)(CONST_STRPTR __asm("a0"), CONST_STRPTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 234))(name, proto, (struct Library *) SOCKET_BASE_NAME)

#define getservbyport(port, proto) \
	((struct servent  * (*)(LONG __asm("d0"), CONST_STRPTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 240))(port, proto, (struct Library *) SOCKET_BASE_NAME)

#define getprotobyname(name) \
	((struct protoent * (*)(CONST_STRPTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 246))(name, (struct Library *) SOCKET_BASE_NAME)

#define getprotobynumber(proto) \
	((struct protoent * (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 252))(proto, (struct Library *) SOCKET_BASE_NAME)

#define vsyslog(level, format, ap) \
	((void (*)(int __asm("d0"), const char * __asm("a0"), _BSD_VA_LIST_ __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 258))(level, format, ap, (struct Library *) SOCKET_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define syslog(level, format, tags...) \
	({ULONG _tags[] = {tags}; vsyslog((level), (format), () _tags);})
#endif

#define Dup2Socket(fd1, fd2) \
	((LONG (*)(LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 264))(fd1, fd2, (struct Library *) SOCKET_BASE_NAME)

#define sendmsg(s, msg, flags) \
	((LONG (*)(LONG __asm("d0"), struct msghdr * __asm("a0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 270))(s, msg, flags, (struct Library *) SOCKET_BASE_NAME)

#define recvmsg(s, msg, flags) \
	((LONG (*)(LONG __asm("d0"), struct msghdr * __asm("a0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 276))(s, msg, flags, (struct Library *) SOCKET_BASE_NAME)

#define gethostname(hostname, size) \
	((LONG (*)(STRPTR __asm("a0"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 282))(hostname, size, (struct Library *) SOCKET_BASE_NAME)

#define gethostid() \
	((ULONG (*)(struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 288))((struct Library *) SOCKET_BASE_NAME)

#define SocketBaseTagList(taglist) \
	((LONG (*)(struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 294))(taglist, (struct Library *) SOCKET_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SocketBaseTags(tags...) \
	({ULONG _tags[] = {tags}; SocketBaseTagList((LONG) _tags);})
#endif

#define GetSocketEvents(eventmaskp) \
	((LONG (*)(ULONG * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) SOCKET_BASE_NAME) - 300))(eventmaskp, (struct Library *) SOCKET_BASE_NAME)

#endif /*  _INLINE_SOCKET_H  */
