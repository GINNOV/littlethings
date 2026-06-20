#ifdef AMITCP
#include "amiga.h"
#include "files.h"
#include <sys/ioctl.h>
#include <sys/cdefs.h>
#include <amiga/ioctl.h>
#include <string.h>
#include <netdb.h>
#undef _OPTINLINE
#include <proto/socket.h>
#include <amitcp/socketbasetags.h>
#include <intuition/intuition.h>
#include <signal.h>

#undef lseek
#undef read
#undef write
#undef close

extern void _message(char *format,...);
long ASM fdCallback(REG(d0) int fd, REG(d1) int action);

struct Library *SocketBase = NULL;
int h_errno = 0;

static long sigio_ok, sigurg_ok;
extern long _sigio_sig, _sigurg_sig;
extern long _fd_setsize;

long __stdargs
_STI_200_openSockets(void)
{
    struct Library *msg_IntuitionBase;
    LONG msg_req(struct Window *, struct EasyStruct *, ULONG *, APTR);
#pragma libcall msg_IntuitionBase msg_req 24C BA9804
    extern char *_ProgramName;

    if ((SocketBase = OpenLibrary("bsdsocket.library", 4)) != NULL) {
	if (SocketBaseTags(SBTM_SETVAL(SBTC_ERRNOLONGPTR), &errno,
			   SBTM_SETVAL(SBTC_HERRNOLONGPTR), &h_errno,
			   SBTM_SETVAL(SBTC_LOGTAGPTR), _ProgramName,
			   SBTM_SETVAL(SBTC_DTABLESIZE), _fd_setsize,
			   TAG_END))
	    return 1;

	_sigio_sig = AllocSignal(-1);
	sigio_ok = _sigio_sig >= 0 &&
	    !SocketBaseTags(SBTM_SETVAL(SBTC_SIGIOMASK), sigmask(_sigio_sig),
		    TAG_END);

	_sigurg_sig = AllocSignal(-1);
	sigurg_ok = _sigurg_sig >= 0 &&
	    !SocketBaseTags(SBTM_SETVAL(SBTC_SIGURGMASK), sigmask(_sigurg_sig),
		    TAG_END);
	return 0;
    }
    msg_IntuitionBase = OpenLibrary("intuition.library", 37);
    if (msg_IntuitionBase) {
	struct EasyStruct msg;
	msg.es_StructSize = sizeof(msg);
	msg.es_Flags = 0;
	msg.es_Title = _ProgramName;
	msg.es_TextFormat = "AmiTCP/IP version 4 or later is not running";
	msg.es_GadgetFormat = "Exit %s";
	msg_req(NULL, &msg, NULL, (APTR)&_ProgramName);
	CloseLibrary(msg_IntuitionBase);
    }
    return 1;
}

void __stdargs
_STD_200_closeSockets(void)
{
    if (SocketBase) {
	CloseLibrary(SocketBase);
	SocketBase = NULL;
    }
    if (_sigio_sig >= 0)
	FreeSignal(_sigio_sig);
    if (_sigurg_sig >= 0)
	FreeSignal(_sigurg_sig);
}

long __stdargs
_STI_510_install_AmiTCP_callback(void)
{
    if (SocketBaseTags(SBTM_SETVAL(SBTC_FDCALLBACK), &fdCallback, TAG_END)) {
	_message("Cannot install fdCallback!");
	return 1;
    }
    return 0;
}

/* Code for fd's describing sockets */

struct sockinfo {
    int fd;
};

static ULONG sock_select_start(void *userinfo, int rd, int wr, int ex)
{
    int fd = ((struct sockinfo *)userinfo)->fd;

    if ((sigio_ok && (rd || wr)) || (sigurg_ok && ex)) {
	int async = 1;
	IoctlSocket(fd, FIOASYNC, (char *)&async);
    }
    return 0;
}

static int sock_select_poll(void *userinfo, int *rd, int *wr, int *ex)
{
    int ret, async = 0;
    int fd = ((struct sockinfo *)userinfo)->fd;
    struct timeval timeout = {0, 0};
    fd_set *rdfds = NULL, *wrfds = NULL, *exfds = NULL;

    IoctlSocket(fd, FIOASYNC, (char *)&async);

    if (*rd) {
	if (!(rdfds = calloc(howmany(_fd_setsize, NFDBITS), sizeof(fd_mask))))
	    goto nomem;
	FD_SET(fd, rdfds);
    }
    if (*wr) {
	if (!(wrfds = calloc(howmany(_fd_setsize, NFDBITS), sizeof(fd_mask))))
	    goto nomem;
	FD_SET(fd, wrfds);
    }
    if (*ex) {
	if (!(exfds = calloc(howmany(_fd_setsize, NFDBITS), sizeof(fd_mask))))
	    goto nomem;
	FD_SET(fd, exfds);
    }

    ret = WaitSelect(fd+1, rdfds, wrfds, exfds, &timeout, NULL);

    if (*rd) {
	*rd = FD_ISSET(fd, rdfds);
	free(rdfds);
    }
    if (*wr) {
	*wr = FD_ISSET(fd, wrfds);
	free(wrfds);
    }
    if (*ex) {
	*ex = FD_ISSET(fd, exfds);
	free(exfds);
    }

    return(ret);

nomem:
    if (rdfds)
	free(rdfds);
    if (wrfds)
	free(wrfds);
    if (exfds)
	free(exfds);
    errno = ENOMEM;
    return -1;
}

static int sock_read(void *userinfo, void *buffer, unsigned int length)
{
    int fd = ((struct sockinfo *)userinfo)->fd;
    int cnt;

    if ((cnt = recv(fd, (UBYTE *)buffer, length, 0)) < 0)
	return -1;
    return cnt;
}

static int sock_write(void *userinfo, void *buffer, unsigned int length)
{
    int fd = ((struct sockinfo *)userinfo)->fd;
    int cnt;

    if ((cnt = send(fd, (char *)buffer, length, 0)) < 0)
	return -1;
    return cnt;
}

static int sock_lseek(void *userinfo, long rpos, int mode)
{
    errno = ESPIPE;
    return -1;
}

static int sock_close(void *userinfo, int internal)
{
    int fd = ((struct sockinfo *)userinfo)->fd;

#ifdef DEBUG
    _message("Closing socket %ld, ptr=%ld", fd, userinfo);
#endif
    CloseSocket(fd);
    /* This is not an error return, but is intended to
     * signal __close() not to free the slot for the fd:
     * this will be the job of fdCallback.
     */
    return 1;
}

static int sock_ioctl(void *userinfo, int request, void *data)
{
    int fd = ((struct sockinfo *)userinfo)->fd;

    switch (request) {
	case _AMIGA_INTERACTIVE:
	case _AMIGA_GET_FH:
	case _AMIGA_FREE_FH:
	case _AMIGA_TRUNCATE:
	case _AMIGA_SETPROTECTION:
	case _AMIGA_DELETE_IF_ME:
	    errno = EINVAL;
	    return -1;
	case _AMIGA_IS_FIFO: {
	    int *is_fifo = data;

	    *is_fifo = FALSE;
	    return 0;
	}
	case _AMIGA_IS_SOCK: {
	    int *is_sock = data;

	    *is_sock = TRUE;
	    return 0;
	}
	default:
	    return(IoctlSocket(fd, request, data));
    }
}

long ASM SAVEDS
fdCallback(REG(d0) int fd, REG(d1) int action)
{
    struct fileinfo *fi;

    switch (action) {
	case FDCB_FREE:
	    if (fi = _find_fd(fd)) {
		int is_sock;
		if (fi->ioctl(fi->userinfo, _AMIGA_IS_SOCK, &is_sock) == -1) {
#ifdef DEBUG
		    _message("Requested to free fd %ld, but can't find it", fd);
#endif
		    return EBADF;
		}
		if (!is_sock) {
#ifdef DEBUG
		    _message("Requested to free fd %ld, but it isn't a socket", fd);
#endif
		    return ENOTSOCK;
		}
#ifdef DEBUG
		_message("Requested to free fd %ld, ptr=%ld", fd, fi->userinfo);
#endif
		free(fi->userinfo);
		_free_fd(fd);
		return 0;
	    }
	    return EBADF;
	
	case FDCB_ALLOC: {
	    int fd2;
	    struct fileinfo **fdtab;
	    struct sockinfo *new = malloc(sizeof(struct sockinfo));
#ifdef DEBUG
	    _message("Requested to allocate fd %ld, ptr=%ld", fd, new);
#endif
	    if (_get_free_fd(&fd2, &fdtab) < 0) {
		free(new);
		return ENOMEM;
	    }
	    /*
	     * If a file descriptor associated with a file or pipe was
	     * freed, the first free fd could be less than the minimum fd
	     * AmiTCP thinks is available. Because of this we must do ourself
	     * the job of _alloc_fd() which would allocate the lowest
	     * available fd. The only possibility that fd2 > fd is that
	     * the fd was allocated, by an open() or pipe() call for example,
	     * in the time between the check and allocation request by AmiTCP.
	     * Hopefully this is a low probability event.
	     */
	    if (fd2 != fd) {
		int i, fdmax = _last_fd();
		struct fileinfo *info;
#ifdef DEBUG
		if (fd2 > fd) {
		    _message("fdCallback: fd2(%ld) > fd(%ld)!", fd2, fd);
		    free(new);
		    return EINVAL;
		}
#endif
		fdtab[fd2] = NULL;	/* free the slot for other uses */
		info = (struct fileinfo *) &fdtab[fdmax];
		for (i = 0; i < fdmax; i++) {
		    if (info[i].userinfo == 0) {
			fdtab[fd] = info + i;	/* fd was already checked     */
			break;			/* and should be free, unless */
		    }				/* fd2 > fd, in which case it */
		}				/* is a disaster              */
	    }
	    new->fd = fd;
	    fdtab[fd]->userinfo = new;
	    fdtab[fd]->flags = FI_READ|FI_WRITE;
	    fdtab[fd]->count = 1;
	    fdtab[fd]->select_start = sock_select_start;
	    fdtab[fd]->select_poll = sock_select_poll;
	    fdtab[fd]->read = sock_read;
	    fdtab[fd]->write = sock_write;
	    fdtab[fd]->lseek = sock_lseek;
	    fdtab[fd]->close = sock_close;
	    fdtab[fd]->ioctl = sock_ioctl;
	    return 0;
	}
	case FDCB_CHECK:
#ifdef DEBUG
	    _message("Requested to check fd %ld", fd);
#endif
	    if (_find_fd(fd))
		return EBADF;
	    return 0;

	default:
#ifdef DEBUG
	    _message("fdCallback: invalid action.");
#endif
	    return EINVAL;
    }
}

char * 
inet_ntoa(struct in_addr addr) 
{
  return Inet_NtoA(addr.s_addr);
}

struct in_addr 
inet_makeaddr(int net, int host)
{
  struct in_addr addr;
  addr.s_addr = Inet_MakeAddr(net, host);
  return addr;
}

unsigned long 
inet_lnaof(struct in_addr addr) 
{
  return Inet_LnaOf(addr.s_addr);
}

unsigned long   
inet_netof(struct in_addr addr)
{
  return Inet_NetOf(addr.s_addr);
}

struct hostent *gethostent(void)
{
    return NULL;
}

struct netent *getnetent(void)
{
    return NULL;
}

struct servent *getservent(void)
{
    return NULL;
}

struct protoent *getprotoent(void)
{
    return NULL;
}

#endif	/* AMITCP */
