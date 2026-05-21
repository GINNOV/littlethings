#include <string.h>

#define TCPFIONBIO 1
#define TCPFIOASYNC 2

extern struct hostent *(*tcp_gethostbyname)(const UBYTE *name);
extern struct servent *(*tcp_getservbyname)(const UBYTE *name, const UBYTE *proto);
extern char * (*tcp_getlogin)(void);
extern struct passwd *(*tcp_getpwnam)(const char *name);
extern void (*tcp_endpwent)(void);
extern LONG (*tcp_gethostname)(STRPTR hostname, LONG size);

extern ULONG (*tcp_inetaddr)(const UBYTE *);
extern LONG (*tcp_socket)(LONG domain, LONG type, LONG protocol);
extern LONG (*tcp_ioctl)(LONG fd, ULONG request, char *argp);
extern LONG (*tcp_connect)(LONG s, const struct mysockaddr_in *name);
extern LONG (*tcp_waitselect)(LONG nfds,  fd_set *readfds, fd_set *writefds, fd_set *exeptfds,
		       struct timeval *timeout, ULONG *maskp);
extern LONG (*tcp_getpeername)(LONG s, struct sockaddr *name, LONG *namelen);
extern LONG (*tcp_closesocket)(LONG d);
extern LONG (*tcp_getsockname)(LONG s, struct sockaddr *name, LONG *namelen);
extern LONG (*tcp_setsockopt)(LONG s, LONG level, LONG optname, void *optval, LONG optlen);
extern LONG (*tcp_send)(LONG s, const UBYTE *msg, LONG len, LONG flags);
extern LONG (*tcp_recv)(LONG s, UBYTE *buf, LONG len, LONG flags);
extern LONG (*tcp_bind)(LONG s, const struct sockaddr *name, LONG namelen);
extern LONG (*tcp_listen)(LONG s, LONG backlog);
extern LONG (*tcp_accept)(LONG s, struct sockaddr *addr, LONG *addrlen);
extern LONG (*tcp_shutdown)(LONG s, LONG how);

struct mysockaddr_in {
    u_char sin_family;
    u_short sin_port;
    struct in_addr sin_addr;
    char sin_zero[8];
};

int SetupAmiTCPHooks(void);
int Setup225Hooks(void);
int OpenTCP(BOOL UseAS225);
void CloseTCP(void);
