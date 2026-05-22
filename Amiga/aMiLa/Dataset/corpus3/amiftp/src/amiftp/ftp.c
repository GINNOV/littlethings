/* RCS Id: $Id: ftp.c 1.736 1996/08/17 18:17:57 lilja Exp $
   Locked version: $Revision: 1.736 $
*/
/*
 * Copyright (c) 1985, 1989 Regents of the University of California.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *	This product includes software developed by the University of
 *	California, Berkeley and its contributors.
 * 4. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include "AmiFTP.h"
#include "gui.h"

#define AMIGAIO 1
unsigned char str_buf[2048];
char *transfer_buf=0;
int bufsize=0;

int ftp_hookup(char *host, short port)
{
    register struct hostent *hp = 0;
    struct mysockaddr_in hisctladdr;
    int s, res, rval;
    LONG len;
    static char hostnamebuf[MAXHOSTNAMELEN + 1];
    char	*ftperr;
    ULONG mask,mainwinsignal=NULL,winmask=NULL;
    extern Object *ConnectWin_Object;

    code = 0;
    bzero((char *)&hisctladdr, sizeof (hisctladdr));
    hisctladdr.sin_addr.s_addr = tcp_inetaddr(host);
    if (hisctladdr.sin_addr.s_addr != -1) {
	hisctladdr.sin_family = AF_INET;
	(void) strncpy(hostnamebuf, host, sizeof (hostnamebuf));
    } else {
	hp = tcp_gethostbyname(host);
	if (hp == NULL) {
	    PrintConnectStatus(GetAmiFTPString(Str_UnknownHost));
	    code = -1;
	    return CONN_ERROR;
	}
	hisctladdr.sin_family = hp->h_addrtype;
	bcopy(hp->h_addr_list[0],
	      (caddr_t)&hisctladdr.sin_addr, hp->h_length);
	(void) strncpy(hostnamebuf, hp->h_name, sizeof (hostnamebuf));
    }
    s = tcp_socket(hisctladdr.sin_family, SOCK_STREAM, 0);
    if (s < 0) {
	code = -1;
	return CONN_ERROR;
    }
    errno=0;
    {
	long on=1;
	tcp_ioctl(s,TCPFIONBIO,(char *)&on);
    }
    hisctladdr.sin_port = port;
    /* timeout 1 minute 20 seconds */
    if (ConnectWin_Object)
      GetAttr(WINDOW_SigMask,ConnectWin_Object,&winmask);
    GetAttr(WINDOW_SigMask,MainWin_Object,&mainwinsignal);

    errno=EINPROGRESS;
    res=tcp_connect(s,(struct mysockaddr_in *)&hisctladdr);

    while (res==-1 && errno==EINPROGRESS) {
	fd_set rs,ws,es;
	struct timeval tv;
	mask=winmask|mainwinsignal|AG_Signal|SIGBREAKF_CTRL_C;
	FD_ZERO(&rs);
	FD_SET(s,&rs);
	FD_ZERO(&ws);
	FD_SET(s,&ws);
	FD_ZERO(&es);
	FD_SET(s,&es);
	tv.tv_secs=80;
	tv.tv_micro=0;

	res=tcp_waitselect(s+1,&rs,&ws,&es,&tv,&mask);

	if (mask) {
	    if (mask&SIGBREAKF_CTRL_C)
	      goto bad;
	    if (mask&AG_Signal)
	      HandleAmigaGuide();
	    if (mask&mainwinsignal)
	      HandleMainWindowIDCMP(FALSE);
	    if (mask&winmask) {
		if (HandleConnectIDCMP()) {
		    rval=CONN_ABORTED;
		    goto bad;
		}
	    }
	}
	else {
	    if (res>0) {
		long off=0;
		struct sockaddr_in in;int len;len=sizeof(in);

		tcp_ioctl(s,TCPFIONBIO,(char *)&off);

		if (tcp_getpeername(s,(struct sockaddr *)&in,(LONG *)&len)==0) {/* This means we are connected */
		    goto cont;
		}
		else {
		    tcp_closesocket(s);
		    PrintConnectStatus("Connection refused");
		    return CONN_ERROR;
		}
	    }
	    else { /* Timedout */
		if (hp && hp->h_addr_list[1]) {
		    extern char *inet_ntoa();
		    hp->h_addr_list++;
		    bcopy(hp->h_addr_list[0],(caddr_t)&hisctladdr.sin_addr,hp->h_length);
		    tcp_closesocket(s);
		    s=tcp_socket(hisctladdr.sin_family,SOCK_STREAM,0);
		    if (s<0) {
			code=-1;
			return CONN_ERROR;
		    }
		    {
			long on=1;
			tcp_ioctl(s,TCPFIONBIO,(char *)&on);
		    }
		    res=tcp_connect(s,(struct mysockaddr_in *)&hisctladdr);
		    continue;
		}
		code=-1;
		if ((errno==ENETUNREACH)||(errno==EHOSTUNREACH)) {
		    tcp_closesocket(s);
		    return CONN_ERROR;
		}
		goto bad;
	    }
	}
	res=-1;
	errno=EINPROGRESS;
    }
  cont:
    len = sizeof (myctladdr);
    if (tcp_getsockname(s, (struct sockaddr *)&myctladdr, &len) < 0) {
	code = -1;
	rval=CONN_ERROR;
	goto bad;
    }

    cin = cout = s;

    if (getreply(0) > 2) {	/* read startup message from server */
	close_files();
	code = -1;
	ftperr = ftp_error(' ', GetAmiFTPString(Str_ServiceNotAvail));
	PrintConnectStatus(ftperr);
	rval=CONN_ERROR;
	goto bad;
    }

    /*
     * Could get:
     * Connected to sun-barr.ebay.sun.com.
     * The Internet FTP relay is down for system maintenance.
     * Please try again later this weekend.
     * Sorry for any inconvenience.
     * Network Operations
     * 421 Service not available, remote server has closed connection
     */
    if (!strncmp(response_line, "The Internet", 12)) {

	close_files();
	code = -1;
	rval=CONN_ERROR;
	goto bad;
    }
#ifdef SO_OOBINLINE
    {
	int on = 1;

if (tcp_setsockopt(s, SOL_SOCKET, SO_OOBINLINE, (char *)&on,
		   sizeof (on)) < 0) {
//	    perror("AmiFTP: setsockopt");
	}
    }
#endif				/* SO_OOBINLINE */
    {
	int on = 1;

	if (tcp_setsockopt(s, SOL_SOCKET, SO_KEEPALIVE, (char *)&on,
			   sizeof (on)) < 0) {
	    //	    perror("AmiFTP: setsockopt");
	}
    }

    return CONN_OK;
  bad:
    tcp_closesocket(s);

    return rval;
}

int ftp_login(char *user, char *pass, char *acct)
{
    int n;
    char	*ftperr;
    int	aflag;

    PrintConnectStatus(GetAmiFTPString(CW_SendingLogin));

    n = command("USER %s", user);
    /*
     * We may have just consumed some startup messages from a
     * server that spews them at connection, but we only grabbed
     * the sun-barr one.
     */
    if (code == 220) {
	cpend = 1;
	n = getreply(0);
    } else if (code == 0) {
	/* for nic.ddn.mil */
	while (code == 0 || code == 220) {
	    cpend = 1;
	    n = getreply(0);
	}
    }
    if (code == 500) {
	/* sun-barr.ebay doesn't recognize host */
	/* 500 yavin: unknown host */
	/* 500 connect: connection timed out */
	ftperr = ftp_error(' ', GetAmiFTPString(Str_ConnectFailed));
	PrintConnectStatus(ftperr);
	quit_ftp();
    } else if (code == 530) {
	/* XXX login unknown */
	/* login failed */
	ftperr = ftp_error(' ', GetAmiFTPString(Str_ConnectLoginFailed));
	PrintConnectStatus(ftperr);
	quit_ftp();
    } else if (code == 421) {
	PrintConnectStatus(GetAmiFTPString(Str_ServiceNotAvail));
	quit_ftp();
    }

    /* Contact line is in the Sorry line */
    /* 421 Service not available  (for Iftp ) */
    if (!strncmp(response_line, "Sorry", 5)) {
	ftperr = "Connect failed. This host is directly reachable.";
	PrintConnectStatus(ftperr);
	quit_ftp();
	return 0;
    }
    if (n == CONTINUE) {
	char passbuf[25];
	passbuf[0]=0;
	code = 0;
	if (pass == NULL && !SilentMode)
	  pass = GetPassword(user,&passbuf[0]);
	PrintConnectStatus(GetAmiFTPString(CW_SendingPassword));
	n = command("PASS %s", pass);
	if (n == ERROR || code == 421) {
	    if (code == 421)
	      ftperr = &response_line[4];
	    else
	      ftperr = ftp_error(' ', GetAmiFTPString(Str_ConnectFailed));
	    PrintConnectStatus(ftperr);
	    quit_ftp();
	    return 0;
	}
    }
    aflag = 0;
    if (n == CONTINUE) {
	/* Account needed */
	aflag++;
	if (acct != NULL)
	  n = command("ACCT %s", acct);
	else
	  n = command("ACCT %s", "anonymous");
    }
    if (n != COMPLETE) {
	return 0;
    }
    if (!aflag && acct != NULL && *acct != '\0')
      (void) command("ACCT %s", acct);
    return 1;
}

int command(char *fmt, ...)
{
    va_list ap;
    int len;

    if (cout == -1) {
	code = 421;
	return 0;
    }

    va_start(ap, fmt);

    len = vsprintf(str_buf,fmt,ap);
    strcpy(&str_buf[len],"\r\n");
    tcp_send(cout,str_buf,len+2,0);
    va_end(ap);

    cpend = 1;

    return getreply(!strcmp(fmt, "QUIT"));
}

int sendrequest(char *cmd, char *local, char *remote) /*Fixa samma som med recvreq */
{
    struct AsyncFile *ASyncFH;
    int sout=-1;
    register int bytes;
    int c;
    long d,bytes_transferred=0,retcode=TRSF_ABORTED;
    struct timeval starttime,currtime;
    fd_set writemask;
    char buf[512],*bufp;
    BPTR flock;
    struct FileInfoBlock fib;
    ULONG winmask=NULL,mask=NULL,mainsignal,t;
    BOOL Continue=TRUE;
    long ret,done;
    int error;
    extern Object *TransferWin_Object;
    extern struct Window *TransferWindow;
    int timesent=0;

    flock=Lock(local,ACCESS_READ);
    if (flock==NULL) {
	code=-1;
	return TRSF_BADFILE;
    }
    Examine(flock,&fib);
    UnLock(flock);
    if (fib.fib_DirEntryType>=0) {
	code=-1;
	return TRSF_BADFILE;
    }

    ASyncFH=OpenAsync(local,MODE_READ, MainPrefs.mp_BufferSize);
    if (!ASyncFH) {
	ShowErrorReq(GetAmiFTPString(Str_LocalfileError), local);
	code=-1;
	return TRSF_BADFILE;
    }

    if (initconn()) {
	code=-1;
	CloseAsync(ASyncFH);
	return TRSF_INITCONN;
    }

    if (command("%s %s",cmd,remote) != PRELIM) {
	CloseAsync(ASyncFH);
	return TRSF_BADFILE;
    }

    sout=dataconn();
    if (sout==-1)
      goto abort;

    GetSysTime(&starttime);

    if (TransferWin_Object)
      GetAttr(WINDOW_SigMask,TransferWin_Object, &winmask);
    GetAttr(WINDOW_SigMask,MainWin_Object,&mainsignal);

    error=d=bytes_transferred=bytes=0;
    {
	long true=1;
	tcp_ioctl(sout,TCPFIOASYNC,(char *)&true);
    }
    t=1L<<TimerPort->mp_SigBit;
    TimeRequest->tr_node.io_Command=TR_ADDREQUEST;
    TimeRequest->tr_time.tv_secs=1;
    TimeRequest->tr_time.tv_micro=0;
    if (TransferWindow) {
	SendIO(TimeRequest);
	timesent=1;
    }

    while (Continue) {
	mask=winmask|AG_Signal|SIGBREAKF_CTRL_C|t;
	FD_ZERO(&writemask);
	FD_SET(sout,&writemask);
	ret=tcp_waitselect(sout+1,NULL,&writemask,NULL,NULL,&mask);
	if (mask) {
	    if (mask&SIGBREAKF_CTRL_C) {
		goto abort;
	    }
	    if (mask&AG_Signal) {
		HandleAmigaGuide();
	    }
	    if (mask&mainsignal)
	      HandleMainWindowIDCMP(FALSE);
	    if (mask&winmask) {
		done=HandleTransferIDCMP();
		if (done)
		  goto abort;
	    }
	    if (mask&t) {
		TimeRequest->tr_node.io_Command=TR_ADDREQUEST;
		TimeRequest->tr_time.tv_secs=1;
		TimeRequest->tr_time.tv_micro=0;
		if (TransferWindow) {
		    UpdateDLGads(bytes_transferred,0,(GetSysTime(&currtime),currtime.tv_sec-starttime.tv_sec));
		}
		SendIO(TimeRequest);
	    }
	}
	if (((SocketBase!=0)&&(!mask)&&(ret>0)) || ((SocketBase==NULL) && (ret>0))) {
	    /* Socket has something for us */
	    if (FD_ISSET(sout,&writemask)) {
		switch (curtype) {
		  case TYPE_I:
		  case TYPE_L:
		    c=ReadAsync(ASyncFH,buf,sizeof(buf));
		    if (c>0) {
			for (bufp=buf;c>0;c-=d,bufp+=d)
			  if ((d=tcp_send(sout,bufp,c,0))<=0)
			    break;
			  else {
			      bytes_transferred+=d;
			  }
		    }
		    else
		      Continue=FALSE;
/*		    if (c<0) {
			if (dl_Win)
			  ShowErrorReq("Read %s: %s.",local,(Fault(IoErr(),NULL,buf,100),buf));
			retcode=TRSF_FAILED;
			goto abort;
		    }*/
/*		    if (c==-1 && )
		      Continue=FALSE;*/
		    if (d<0) {
			if (TransferWindow)
			  ShowErrorReq(GetAmiFTPString(Str_RemoteWriteFailed));
			retcode=TRSF_FAILED;
			goto abort;
		    }
		    break;
		  case TYPE_A:
		    c=ReadCharAsync(ASyncFH);
		    if (c!=EOF) {
			if (c=='\n') {
			    tcp_send(sout,"\r",1,0);
			    bytes++;
			}
			tcp_send(sout,(UBYTE *)&c,1,0);
			bytes++;
			bytes_transferred++;
			if (bytes>=1024) {
			    bytes=0;
			}
		    }
		    else
		      Continue=FALSE;
		    break;
		  default:
		    break;
		}
	    }
	}
	else if ((SocketBase && (ret<0)) || (!SocketBase && errno!=4 && (ret<0))){
	    goto abort;
	}
	    
    }
    if (TransferWindow)
      UpdateDLGads(bytes_transferred,0,(GetSysTime(&currtime),currtime.tv_sec-starttime.tv_sec));

    if (ASyncFH)
      CloseAsync(ASyncFH);
    tcp_closesocket(sout);
    sout=-1;
    data=-1;

    getreply(0);
    if (TransferWindow) {
	if (!CheckIO(TimeRequest))
	  AbortIO(TimeRequest);
	WaitIO(TimeRequest);
    }
    return TRSF_OK;
  abort:
    if (!cpend) {
	code=-1;
	return TRSF_ABORTED;
    }

    if (data >= 0) {
	tcp_closesocket(data);
	data = -1;
    }
    getreply(0);
    code=-1;

    if (ASyncFH!=NULL)
      CloseAsync(ASyncFH);
    if (TransferWindow && timesent==1) {
	if (!CheckIO(TimeRequest))
	  AbortIO(TimeRequest);
	WaitIO(TimeRequest);
    }
    return retcode;
}
static char tbufs[50];

int recvrequest(char *cmd, char *local, char *remote,char *lmode,
		ULONG restartpoint)
{
    struct AsyncFile *ASyncFH;
    int sin=-1;
    int is_retr,tcrflag,bare_lfs=0;
    register int bytes;
    register int c;
    long d,bytes_transferred=0;
    int errormsg=0,error;
    struct timeval starttime,currtime;
    fd_set readmask;
    extern Object *TransferWin_Object;
    ULONG done;
    ULONG winmask=NULL,mask,mainsignal,t;
    long ret;
    BOOL Continue=TRUE;
    int timesent=0;

    is_retr=strcmp(cmd,"RETR")==0;
    tcrflag=!crflag&&is_retr;

    TimeRequest->tr_node.io_Command=TR_ADDREQUEST;
    TimeRequest->tr_time.tv_secs=1;
    TimeRequest->tr_time.tv_micro=0;

    if (initconn()) {
	code=-1;
	return TRSF_INITCONN;
    }
    if (restartpoint) {
	command("REST %ld",restartpoint);
	if (code!=350) {
	    ShowErrorReq(GetAmiFTPString(Str_NoRestart));
	    return TRSF_FAILED;
	}
    }
    if (remote) {
	if (command("%s %s",cmd,remote) != PRELIM) {
	    return TRSF_BADFILE;
	}
	/* "150 Opening BINARY mode data connection for README (899 bytes)." */
	{
	    char *ptr;
	    long size;

	    response_line[strlen(response_line)-9]='\0';
	    ptr=&response_line[strlen(response_line)-1];
	    while (*ptr && ptr > &response_line[0]) {
		if (!isdigit(*ptr))
		  break;
		ptr--;
	    }
	    ptr++;
	    size=atol(ptr);

	    if (size)
	      SetTransferSize(size);
	}
    }
    else {
	if (command("%s",cmd)!=PRELIM) {
	    return TRSF_BADFILE;
	}
    }
    if (!transfer_buf) {
	transfer_buf=malloc(MainPrefs.mp_BufferSize);
	if (transfer_buf)
	  bufsize=MainPrefs.mp_BufferSize;
	else {
	    transfer_buf=malloc(512);
	    if (transfer_buf==NULL) {
		bufsize=0;
		goto abort;
	    }
	    bufsize=512;
	}
    }

    sin=dataconn();
    if (sin==-1)
      goto abort;

    ASyncFH=OpenAsync(local, restartpoint?MODE_APPEND:MODE_WRITE,
		      MainPrefs.mp_BufferSize);
    if (!ASyncFH) {
	ShowErrorReq(GetAmiFTPString(Str_LocalfileError),local);
	errormsg=1;
	goto abort;
    }
    GetSysTime(&starttime);

    if (TransferWin_Object)
      GetAttr(WINDOW_SigMask, TransferWin_Object, &winmask);
    error=d=0;
    bytes_transferred=restartpoint;

    {
	long true=1;
	tcp_ioctl(sin,TCPFIOASYNC,(char *)&true);
    }
    bytes=0;

    t=1L<<TimerPort->mp_SigBit;
    if (TransferWindow) {
	SendIO(TimeRequest);
	timesent=1;
    }

    while (Continue) {
	fd_set exceptmask;
	GetAttr(WINDOW_SigMask,MainWin_Object,&mainsignal);
	errno=0;
	mask=mainsignal|winmask|AG_Signal|SIGBREAKF_CTRL_C|t;
	FD_ZERO(&readmask);
	FD_ZERO(&exceptmask);
	ret=0;

	FD_SET(sin,&readmask);
	FD_SET(sin,&exceptmask);
	ret=tcp_waitselect(sin+1,&readmask,NULL,&exceptmask,NULL,&mask);

	if (mask) {
	    if (mask&SIGBREAKF_CTRL_C) {
		goto abort;
	    }
	    if (mask&AG_Signal) {
		HandleAmigaGuide();
	    }
	    if (mask&mainsignal) {
		HandleMainWindowIDCMP(FALSE);
	    }
	    if (mask&winmask) {
		done=HandleTransferIDCMP();
		if (done) {
		    goto abort;
		}
	    }
	    if (mask&t) {
		TimeRequest->tr_node.io_Command=TR_ADDREQUEST;
		TimeRequest->tr_time.tv_secs=1;
		TimeRequest->tr_time.tv_micro=0;
		if (TransferWindow) {
		    UpdateDLGads(bytes_transferred,restartpoint,(GetSysTime(&currtime),currtime.tv_sec-starttime.tv_sec));
		}
		SendIO(TimeRequest);
	    }
	} 
	if (((SocketBase!=0)&&(!mask)&&(ret>0)) || ((SocketBase==NULL) && (ret>0))) {
	    /* Socket has something for us */
	    if (FD_ISSET(sin,&readmask)) {
		switch (curtype) {
		  case TYPE_I:
		  case TYPE_L:
		    c=tcp_recv(sin,transfer_buf,bufsize,0);
		    if (c>0) {
			if ((d=WriteAsync(ASyncFH,transfer_buf,c))<=0)
			  {goto abort;}
		    }
		    else if (c<0) {
			 goto abort;
		    }
		    else
		      Continue=FALSE;
		    if (d!=c&&Continue)
		      {goto abort;}
		    if (c!=0) {
			bytes_transferred+=(long)d;
		    }
		    /* plus en massa kod...*/
		    break;
		  case TYPE_A:
		    c=sgetc(sin);
		    if (c!=EOF) {
			if (c=='\n')
			  bare_lfs++;
			while (c=='\r') {
			    bytes++;
			    if ((c=sgetc(sin))!='\n'||tcrflag) {
				WriteCharAsync(ASyncFH,'\r');
			    }
			}
			WriteCharAsync(ASyncFH,c);
			bytes++;
			if (bytes>=1024) {
			    bytes_transferred+=bytes;
			    bytes=0;
			}
			}
		    else Continue=FALSE;
		    break;
		}
	    }
	    if (FD_ISSET(sin, &exceptmask)) {
		goto abort;
	    }
	}
	else if ((SocketBase && (ret < 0)) || (!SocketBase && errno!=4 && (ret<0))) {
	    goto abort;
	}
	    
    }
    if (TransferWindow)
      UpdateDLGads(bytes_transferred,restartpoint,(GetSysTime(&currtime),currtime.tv_sec-starttime.tv_sec));
    if (ASyncFH)
      CloseAsync(ASyncFH);
    tcp_closesocket(sin);
    sin=-1;
    data=-1;
    getreply(0);
    if (TransferWindow) {
	if (!CheckIO(TimeRequest))
	  AbortIO(TimeRequest);
	WaitIO(TimeRequest);
    }
    return TRSF_OK;
  abort:
    if (!cpend) {
	code=-1;
	return TRSF_ABORTED;
    }
    abort_remote(sin);

    code = -1;
    if (data >= 0) {
	tcp_closesocket(data);
	data = -1;
    }

    if (ASyncFH!=NULL)
      CloseAsync(ASyncFH);

    if (TransferWindow && timesent==1) {
	if (!CheckIO(TimeRequest))
	  AbortIO(TimeRequest);
	WaitIO(TimeRequest);
    }

    return TRSF_ABORTED;
}

/*
 * Need to start a listen on the data channel before we send the command,
 * otherwise the server's connect may fail.
 */
int initconn(void)

{
    register char *p, *a;
    int result, tmpno = 0;
    LONG len;
    int on = 1;

  noport:
    data_addr = myctladdr;
    if (sendport)
      data_addr.sin_port = 0;	/* let system pick one */
    if (data != -1) {
	tcp_closesocket(data);
	data = -1;
    }

    data = tcp_socket(AF_INET, SOCK_STREAM, 0);
    if (data < 0) {
//	perror("AmiFTP: socket");
	if (tmpno)
	  sendport = 1;
	return 1;
    }

    if (!sendport) {
	if (tcp_setsockopt(data, SOL_SOCKET, SO_REUSEADDR, (char *)&on,
			   sizeof (on)) < 0) {
	    //	  perror("AmiFTP: setsockopt (reuse address)");
	    goto bad;
	}
    }

    if (tcp_bind(data, (struct sockaddr *)&data_addr, sizeof (data_addr)) < 0) {
//	perror("AmiFTP: bind");
	goto bad;
    }
    len = sizeof (data_addr);

    if (tcp_getsockname(data, (struct sockaddr *)&data_addr, &len) < 0) {
//	perror("AmiFTP: getsockname");
	goto bad;
    }

    if (tcp_listen(data, 1) < 0) {}
//      perror("AmiFTP: listen");
    if (sendport) {
	a = (char *)&data_addr.sin_addr;
	p = (char *)&data_addr.sin_port;
#define	UC(b)	(((int)b)&0xff)
	result = command("PORT %d,%d,%d,%d,%d,%d",
			 UC(a[0]), UC(a[1]), UC(a[2]), UC(a[3]),
			 UC(p[0]), UC(p[1]));
	if (result == ERROR && sendport == -1) {
	    sendport = 0;
	    tmpno = 1;
	    goto noport;
	}
	return result != COMPLETE;
    }
    if (tmpno)
      sendport = 1;
    return 0;
  bad:
    tcp_closesocket(data);
    data = -1;

    if (tmpno)
      sendport = 1;
    return 1;
}

int dataconn(void)

{
    struct sockaddr_in from;
    int s;
    LONG fromlen = sizeof (from);

  restart:
    s = tcp_accept(data, (struct sockaddr *) &from, &fromlen);

    if (s < 0) {
	if (errno == EINTR)
	  goto restart;
//	perror("AmiFTP: accept");
	tcp_closesocket(data);
	data = -1;
	return -1;
    }
    tcp_closesocket(data);
    data = s;
    {
	int on = 1;

	if (tcp_setsockopt(data, SOL_SOCKET, SO_OOBINLINE, (char *)&on,
			   sizeof (on)) < 0) {
	    //	    perror("AmiFTP: setsockopt");
	}
    }
    return data;
}

#include <ctype.h>

int getreply(const int expecteof)
{
    register int c, n;
    register int dig;
    register char *cp;
    int originalcode = 0, continuation = 0;
    int pflag = 0;

    for (;;) {
	dig = n = code = 0;
	cp = response_line;
	memset(response_line,0,sizeof(response_line)-1);
	while ((c = sgetc(cin)) != '\n')
	  //	    printf("%c",c);
	//	    fflush(stdout);
	  {
	      if (c == IAC) {	/* handle telnet commands */
		  switch (c = sgetc(cin))
		      {
			case WILL:
			case WONT:
			  str_buf[0] = IAC; str_buf[1] = DONT;
			  str_buf[2] = sgetc(cin);
			  tcp_send(cout,str_buf,3,0);
			  break;
			case DO:
			case DONT:
			  str_buf[0] = IAC;str_buf[1]=DONT;
			  str_buf[2] = sgetc(cin);
			  tcp_send(cout,str_buf,3,0);
			  break;
			default:
			  break;
		      }
		  continue;
	      }
	      dig++;
	      if (c == EOF) {
		  if (expecteof) {
		      code = 221;
		      //printf("\n");
		      return 0;
		  }
		  lostpeer();
		  code = 421;
		  //printf("\n");
		  return 4;
	      }
	      if (c != '\r' && (verbose > 0 ||
				(verbose > -1 && n == '5' && dig > 4))) {
		  /*
		    (void) putchar(c);
		    */
		  //		printf("%c",c);
	      }
	      if (dig < 4 && isdigit(c))
		code = code * 10 + (c - '0');
	      if (!pflag && code == 227)
		pflag = 1;
	      if (dig > 4 && pflag == 1 && isdigit(c))
		pflag = 2;
	      /*
		if (pflag == 2) {
		if (c != '\r' && c != ')')
		*pt++ = c;
		else {
		*pt = '\0';
		pflag = 3;
		}
		}
		*/
	      if (dig == 4 && c == '-') {
		  if (continuation)
		    code = 0;
		  continuation++;
	      }
	      if (n == 0)
		n = c;
	      if (cp < &response_line[sizeof (response_line) - 1])
		*cp++ = c;
	  }
	if (LogWindow)
	  LogMessage(response_line,0);
	if (verbose > 0 || (verbose > -1 && n == '5')) {
	    /*
	      (void) putchar(c);
	      */
	    //	    printf("%c",c);
	    (void) fflush (stdout);
	}
	if (continuation && code != originalcode) {
	    if (originalcode == 0)
	      originalcode = code;
	    continue;
	}
	*cp = '\0';
	if (n != '1')
	  cpend = 0;
	if (code == 421 || originalcode == 421)
	  lostpeer();
	//printf("\n");
	/*	    if (LogWindow)
		    LogMessage(response_line,0);*/
	return n - '0';
    }
    //printf("\n");
}

int empty(fd_set *mask, const int sec)
{
    struct timeval t;

    t.tv_sec = (long) sec;
    t.tv_usec = 0;
    return tcp_waitselect(32, mask, (fd_set *)NULL, (fd_set *)NULL, &t,NULL);
}

void abort_remote(const int din)
{
    char buf[BUFSIZ];
    int nfnd;
    fd_set mask;
    int	rval;

    /*
     * send IAC in urgent mode instead of DM because 4.3BSD places oob mark
     * after urgent byte rather than before as is protocol now
     */
    sprintf(buf, "%c%c%c", IAC, IP, IAC);
  restart:
    rval = tcp_send(cout,buf,3,MSG_OOB);

    if (rval == -1 && errno == EINTR)
      goto restart;
    if (rval != 3)
      perror("abort_remote1");
    sprintf(buf,"%cABOR\r\n",DM);
    tcp_send(cout,buf,strlen(buf), MSG_OOB);

    FD_ZERO(&mask);
    FD_SET(cin, &mask);

    if (din) {
	FD_SET(din, &mask);
    }

    if ((nfnd = empty(&mask, 10)) <= 0) {
	if (nfnd < 0) {
	    perror("abort_remote2");
	}
	/*
	  if (ptabflg)
	  code = -1;
	  */
	lostpeer();
    }
    if (din && FD_ISSET(din, &mask)){
	while ((FD_ISSET(din,&mask)==din) && (tcp_recv(din, buf, BUFSIZ,0)>0));
	  //Printf("recv'ing %ld\n",FD_ISSET(din,&mask));
    }

    if (getreply(0) == ERROR && code == 552) {
	/* 552 needed for nic style abort */
	(void) getreply(0);
    }
    (void) getreply(0);
}

void lostpeer(void)
{
    if (connected) {
	if (cout >= 0) {
	    tcp_shutdown(cout, 1+1);
	    tcp_closesocket(cout);
	    cout=-1;
	}
	if (data>=0) {
	    tcp_shutdown(data,1+1);
	    tcp_closesocket(data);
	    data=-1;
	}
	connected=0;
    }
}

char *s_fgets(char *buf, int n, const int fd)
{
    int s = 1;
    char *start = buf;

    while (s && --n) {
	if (tcp_recv(fd, buf, 1,0) <= 0)
	    return NULL;
	if ( (*(buf++) || *(buf++) == '\n') && (buf != start))
	    s = 0;
    }
    *buf = 0;
    return start;
}

char *next_remote_line(const int sin)
{
    char	*str = response_line;
    char	*cptr = str;
    int		c;


    while ((c = sgetc(sin)) != '\n' && c != EOF && c != '\0') {
//    return (s_fgets(str,256,sin));
	if (c == '\r')
	  continue;
	*cptr++ = (char)c;
    }
    *cptr = '\0';
    if (c == EOF)
      return NULL;
    return str;
}

char *parse_hostname(const char *host, int *port)
{
    static char ftphost[MAXHOSTNAMELEN + 1];
    char *tmp;
    struct servent *servent;

    /* strip leading whitespace */
    while (*host != '\0' && isspace(*host))
      host++;

    if (*host == '\0')
      return NULL;

    (void) strcpy(ftphost, host);

    tmp = strtok(ftphost, " \t");
    /* now ftphost is terminated. */

    tmp = strtok(NULL, " \t");
    if (tmp == NULL)		/* no port */
      return ftphost;

    if (isdigit(*tmp)) {
	*port = htons(atoi(tmp));
    } else {
	servent = tcp_getservbyname(tmp, "tcp");
	if (servent == NULL) {
	    sprintf(scratch, "%s service unknown. Using %d.",
		    tmp, *port);
	    PrintConnectStatus(scratch);
	} else {
	    *port = servent->s_port;
	}
    }
    return ftphost;
}

int open_remote_ls(const int nlst)
{
    char	*ftperr;
    char	*cmd;
    int sin=0;

    if (nlst)
      cmd = "NLST";		/* dir */
    else
      cmd = "LIST";		/* ls */

    settype(ASCII);

    if (initconn()) {
	code = -1;
	return -1;
    }

    if (command("%s", cmd) != PRELIM) {
	if (code == 530) {
	    /* 530 You must define working directory with CWD */
	    ftperr = ftp_error(' ',
			       "cd somewhere first or invalid directory");
	} else if (code == 550) {
	    /* 550 No files found. */
	    ftperr = ftp_error(' ', "No files found.");
	} else {
	}
	return -1;
    }

    sin = dataconn();
    if (sin == -1)
      return -1 ;

    return sin;
}

void close_remote_ls(const int sin)
{
    tcp_shutdown(sin,1+1);
    tcp_closesocket(sin);

    (void) getreply(0);
    return;
}


struct	types {
	char	*t_name;
	char	*t_mode;
	int	t_type;
	char	*t_arg;
} types[] = {
	{ "binary",	"I",	TYPE_I,	0 },
	{ "ascii",	"A",	TYPE_A,	0 },
	{ "tenex",	"L",	TYPE_L,	"8" },
/*
	{ "image",	"I",	TYPE_I,	0 },
	{ "ebcdic",	"E",	TYPE_E,	0 },
*/
};

/*
 * Set transfer type.
 */
void settype(const int type)
{
    register struct types *p;
    int comret;

    if (type > (sizeof (types)/sizeof (types[0]))) {
//	fprintf(stderr, "%d: unknown mode\n", type);
	code = -1;
	return;
    }
    /* make sure values in window match table! */
    p = &types[type];

    if ((p->t_arg != NULL) && (*(p->t_arg) != '\0'))
      comret = command ("TYPE %s %s", p->t_mode, p->t_arg);
    else
      comret = command("TYPE %s", p->t_mode);
    if (comret == COMPLETE) {
	curtype = p->t_type;
    }
}

/* End */
