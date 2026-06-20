#include "dh1:sc/as225/include/ss/socket.h"
#include "tcphooks.h"
#include "dh1:sc/as225/include/sys/ioctl.h"

extern struct Library *SockBase;
extern int errno;

struct hostent *as225_gethostbyname(const UBYTE *name)
{
    return gethostbyname(name);
}

struct servent *as225_getservbyname(const UBYTE *name, const UBYTE *proto)
{
    return getservbyname(name,proto);
}

char *as225_getlogin()
{
    return getlogin();
}

struct passwd *as225_getpwnam(const char *name)
{
    return getpwnam(name);
}

void as225_endpwent()
{
    endpwent();
}

LONG as225_gethostname(STRPTR hostname, LONG size)
{
    return gethostname(hostname,size);
}

ULONG as225_inetaddr(const UBYTE *s)
{
    return inet_addr(s);
}

LONG as225_socket(LONG domain, LONG type, LONG protocol)
{
    return socket(domain,type,protocol);
}

LONG as225_ioctl(LONG fd, ULONG request, char *argp)
{
    if (request==TCPFIONBIO)
      request=FIONBIO;
    else if (request==TCPFIOASYNC)
      request=FIOASYNC;

    return s_ioctl(fd, request, argp);
}

LONG as225_waitselect(LONG nfds,  fd_set *readfds, fd_set *writefds, fd_set *exeptfds,
		       struct timeval *timeout, ULONG *maskp)
{
    return selectwait(nfds, readfds,writefds,exeptfds,timeout,maskp);
}

LONG as225_getpeername(LONG s, struct sockaddr *name, LONG *namelen)
{
    return getpeername(s,name,namelen);
}

LONG as225_closesocket(LONG d)
{
    return s_close(d);
}

LONG as225_getsockname(LONG s, struct sockaddr *name, LONG *namelen)
{
    return getsockname(s,name,namelen);
}

LONG as225_setsockopt(LONG s, LONG level, LONG optname, void *optval, LONG optlen)
{
    return setsockopt(s,level,optname,optval,optlen);
}

LONG as225_send(LONG s, const UBYTE *msg, LONG len, LONG flags)
{
    return send(s,msg,len,flags);
}

LONG as225_recv(LONG s, UBYTE *buf, LONG len, LONG flags)
{
    return recv(s,buf,len,flags);
}

LONG as225_bind(LONG s, const struct sockaddr *name, LONG namelen)
{
    return bind(s,name,namelen);
}

LONG as225_listen(LONG s, LONG backlog)
{
    return listen(s,backlog);
}

LONG as225_accept(LONG s, struct sockaddr *addr, LONG *addrlen)
{
    return accept(s,addr,addrlen);
}

LONG as225_shutdown(LONG s, LONG how)
{
    return shutdown(s,how);
}

LONG as225_connect(LONG s, const struct mysockaddr_in *sin)
{
    struct sockaddr_in hisctladdr;

    bzero((char *)&hisctladdr,sizeof(hisctladdr));
    hisctladdr.sin_family=sin->sin_family;
    hisctladdr.sin_addr.s_addr=sin->sin_addr.s_addr;
    hisctladdr.sin_port=sin->sin_port;

    return (connect(s,(struct sockaddr *)&hisctladdr,sizeof(hisctladdr)));
}

int Setup225Hooks()
{
    tcp_socket=as225_socket;
    tcp_bind=as225_bind;
    tcp_listen=as225_listen;
    tcp_accept=as225_accept;
    tcp_connect=as225_connect;
    tcp_send=as225_send;
    tcp_recv=as225_recv;
    tcp_shutdown=as225_shutdown;
    tcp_setsockopt=as225_setsockopt;
    tcp_getsockname=as225_getsockname;
    tcp_getpeername=as225_getpeername;
    tcp_ioctl=as225_ioctl;
    tcp_closesocket=as225_closesocket;
    tcp_waitselect=as225_waitselect;
    tcp_inetaddr=as225_inetaddr;
    tcp_gethostbyname=as225_gethostbyname;
    tcp_endpwent=as225_endpwent;
    tcp_getpwnam=as225_getpwnam;
    tcp_getlogin=as225_getlogin;
    tcp_gethostname=as225_gethostname;
    tcp_getservbyname=as225_getservbyname;

    setup_sockets(6,&errno);

    return 1;
}

void Shutdown225(void)
{
    cleanup_sockets();
}
