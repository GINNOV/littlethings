head	1.736;
access;
symbols;
locks
	lilja:1.736
	lilja:0.667; strict;
comment	@ * @;


1.736
date	96.08.17.18.17.57;	author lilja;	state Exp;
branches;
next	1.625;

1.625
date	96.07.04.17.50.58;	author lilja;	state Exp;
branches;
next	1.587;

1.587
date	96.06.14.13.23.25;	author lilja;	state Exp;
branches;
next	1.531;

1.531
date	96.05.28.00.17.52;	author lilja;	state Exp;
branches;
next	1.430;

1.430
date	96.04.14.13.21.26;	author lilja;	state Exp;
branches;
next	1.401;

1.401
date	96.03.28.13.52.44;	author lilja;	state Exp;
branches;
next	1.265;

1.265
date	96.03.08.18.01.38;	author lilja;	state Exp;
branches;
next	1.200;

1.200
date	96.02.20.00.19.28;	author lilja;	state Exp;
branches;
next	1.150;

1.150
date	96.02.11.16.38.55;	author lilja;	state Exp;
branches;
next	1.124;

1.124
date	96.02.10.15.46.32;	author lilja;	state Exp;
branches;
next	0.1332;

0.1332
date	95.12.17.13.21.38;	author lilja;	state Exp;
branches;
next	0.1300;

0.1300
date	95.12.08.20.24.52;	author lilja;	state Exp;
branches;
next	0.857;

0.857
date	95.10.24.18.41.14;	author lilja;	state Exp;
branches;
next	0.827;

0.827
date	95.10.23.21.01.35;	author lilja;	state Exp;
branches;
next	0.814;

0.814
date	95.10.15.15.22.12;	author lilja;	state Exp;
branches;
next	0.807;

0.807
date	95.10.13.12.51.19;	author lilja;	state Exp;
branches;
next	0.700;

0.700
date	95.09.24.00.57.34;	author lilja;	state Exp;
branches;
next	0.671;

0.671
date	95.09.20.10.15.33;	author lilja;	state Exp;
branches;
next	0.667;

0.667
date	95.09.18.10.34.24;	author lilja;	state Exp;
branches;
next	0.656;

0.656
date	95.09.17.11.32.29;	author lilja;	state Exp;
branches;
next	0.647;

0.647
date	95.09.16.21.18.38;	author lilja;	state Exp;
branches;
next	0.623;

0.623
date	95.09.16.10.54.30;	author lilja;	state Exp;
branches;
next	0.588;

0.588
date	95.09.12.16.24.08;	author lilja;	state Exp;
branches;
next	0.563;

0.563
date	95.09.10.20.59.20;	author lilja;	state Exp;
branches;
next	0.531;

0.531
date	95.09.01.17.25.42;	author lilja;	state Exp;
branches;
next	0.486;

0.486
date	95.08.26.11.48.42;	author lilja;	state Exp;
branches;
next	0.388;

0.388
date	95.07.16.13.14.48;	author lilja;	state Exp;
branches;
next	0.371;

0.371
date	95.06.30.19.18.41;	author lilja;	state Exp;
branches;
next	0.347;

0.347
date	95.06.16.09.38.24;	author lilja;	state Exp;
branches;
next	0.345;

0.345
date	95.06.15.23.29.18;	author lilja;	state Exp;
branches;
next	0.336;

0.336
date	95.06.15.11.53.20;	author lilja;	state Exp;
branches;
next	0.284;

0.284
date	95.06.06.21.42.35;	author lilja;	state Exp;
branches;
next	;


desc
@All ftp-routines
@


1.736
log
@Transferwindow progressbar freaked out if the file was too big. now fixed.
Other stuff fixed.
@
text
@/* RCS Id: $Id: ftp.c 1.625 1996/07/04 17:50:58 lilja Exp lilja $
   Locked version: $Revision: 1.625 $
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
	GetAttr(WINDOW_SigMask,MainWin_Object,&mainsignal);
	errno=0;
	mask=mainsignal|winmask|AG_Signal|SIGBREAKF_CTRL_C|t;
	FD_ZERO(&readmask);
	ret=0;

	FD_SET(sin,&readmask);
	ret=tcp_waitselect(sin+1,&readmask,NULL,NULL,NULL,&mask);

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
@


1.625
log
@Cleaned up the code a bit.
Rename ftpwin.h to AmiFTP.h and ftpwin.c to AmiFTP.c.
Created Menu.c and moved all menu-functions there.
@
text
@d1 2
a2 2
/* RCS Id: $Id: ftp.c 1.587 1996/06/14 13:23:25 lilja Exp lilja $
   Locked version: $Revision: 1.587 $
d359 1
a359 1
    ASyncFH=OpenAsync(local,MODE_READ,MainPrefs.mp_BufferSize);
d612 2
a613 1
    ASyncFH=OpenAsync(local,restartpoint?MODE_APPEND:MODE_WRITE,MainPrefs.mp_BufferSize);
@


1.587
log
@Added RCS-variables to source-files.
@
text
@d1 2
a2 2
/* RCS Id: $Id$
   Locked version: $Revision$
d37 1
a37 1
#include "ftpwin.h"
@


1.531
log
@Lots of stuff
@
text
@d1 3
@


1.430
log
@Fixed name/date-sorting in ADT-mode.
@
text
@d46 1
a46 1
    int s, res;
d64 1
a64 1
	    return 1;
d74 1
a74 1
	return 0;
d113 4
a116 4
//		kprintf("Connectwin\n");
		if (HandleConnectIDCMP())
		  goto bad;
//		kprintf("Not aborted\n");
d132 1
a132 1
		    return 1;
d144 1
a144 1
			return 0;
d156 1
a156 1
		    return 1;
d168 1
d179 1
d196 1
d210 1
a210 1
    return 2;
d214 1
a214 1
    return 0;
d342 1
d393 4
a396 2
    if (TransferWindow)
      SendIO(TimeRequest);
d514 1
a514 1
//Printf("Abort done\n");
d517 1
a517 1
    if (TransferWindow) {
d526 2
a527 1
int recvrequest(char *cmd, char *local, char *remote,char *lmode, ULONG restartpoint)
d543 1
d548 4
d571 1
a571 1
//	    Printf("Responseline: '%s'\n",response_line);
a573 1
//	    Printf("'%s' '%c'\n",response_line,*ptr);
d581 1
a581 2
//	    Printf("Size: '%s' (%ld)\n",ptr,size=atol(ptr));
//Printf("%ld\n",size);
d604 1
a604 1
//    kprintf("%s %ld\n",__FILE__,__LINE__);Delay(50);
d629 4
a632 5
    TimeRequest->tr_node.io_Command=TR_ADDREQUEST;
    TimeRequest->tr_time.tv_secs=1;
    TimeRequest->tr_time.tv_micro=0;
    if (TransferWindow)
      SendIO(TimeRequest);
a633 1
//    kprintf("%s %ld\n",__FILE__,__LINE__);Delay(50);
d656 3
a658 2
		if (done)
		  goto abort;
d747 1
a747 1
//Printf("Abort done\n");
d751 1
a751 1
    if (TransferWindow) {
d756 1
a757 1

a994 1
//Printf("A1\n");
a998 1
//    Printf("A2\n");
a1016 1
//    Printf("A3\n");
a1020 1
//    Printf("A4\n");
a1074 1
if(DEBUG)Printf("next_remote_line: '%s'\n",str);
a1077 1
//#endif
@


1.401
log
@Started on improving the functionnames.
Added Aminet-mode, not 100% finished yet.
Reworked the prefs-window, not everything is finished.
Started using listbrowser v41-functions.
Added parsing of URL-like commandline.
@
text
@d201 1
a201 1
		   sizeof (on)) < 0 && debug) {
a302 2

    abrtflag = 0;
@


1.265
log
@Groups added. Bugs fixed.
@
text
@d126 1
a126 1
		if (tcp_getpeername(s,(struct sockaddr *)&in,&len)==0) {/* This means we are connected */
d354 1
a354 1
    ASyncFH=OpenAsync(local,MODE_READ,8192);
d360 1
a360 2
    if (DEBUG)
      Printf("Calling initconn()\n");
d366 1
a366 2
    if (DEBUG)
      Printf("Sending STOR-command\n");
a370 2
    if (DEBUG)
      Printf("Opening dataconns\n");
a381 1
    if (DEBUG) Printf("Settings sockets to async-mode\n");
a393 1
    if (DEBUG) Printf("Entering main-loop\n");
a425 1
		if (DEBUG) Printf("Got signal from socket\n");
d584 1
a584 1
	transfer_buf=malloc(10240);
d586 1
a586 1
	  bufsize=10240;
d601 1
a601 1
    ASyncFH=OpenAsync(local,restartpoint?MODE_APPEND:MODE_WRITE,8192);
d773 1
a773 2
    if (DEBUG)
      Printf("initconn: socket()\n");
a776 2
if (DEBUG)
  Printf("initconn: socket() failed: errno=%ld\n",errno);
d781 1
a781 2
    if (DEBUG)
      Printf("initconn: %ld\n",__LINE__);
a782 2
	if (DEBUG)
	  Printf("initconn: setsockopt()\n");
a785 2
	    if (DEBUG)
	      Printf("initconn: %ld\n",__LINE__);
d789 1
a789 2
    if (DEBUG)
      Printf("initconn: bind()\n");
d795 1
a795 2
    if (DEBUG)
      Printf("initconn: getsockname()\n");
d800 1
a800 2
    if (DEBUG)
      Printf("initconn: listen()\n");
a836 2
    if (DEBUG)
      Printf("dataconn: accept()\n");
d838 1
a838 2
    if (DEBUG)
      Printf("dataconn: accept() return %ld\n",s);
a848 2
    if (DEBUG)
      Printf("dataconn: s = %ld\n",s);
d1128 1
a1128 2
    if (DEBUG)
      Printf("o_r_l: Entering initconn())\n");
d1133 1
a1133 2
    if (DEBUG)
      Printf("o_r_l: initconn() ok\n");
a1138 1
//	    printf(ftperr);
a1141 1
//	    printf(ftperr);
a1142 1
//	    printf("Unknown error %d.", code);
a1146 2
    if (DEBUG)
      Printf("o_r_l: Entering dataconn())\n");
d1150 1
a1150 2
    if (DEBUG)
      Printf("o_r_l: dataconn finished\n");
a1155 2
    if (DEBUG)
      Printf("c_r_l: Closing ls\n");
a1159 2
    if (DEBUG)
      Printf("c_r_l: ls closed\n");
@


1.200
log
@GETATTR-hit fixed.
@
text
@d1155 1
a1155 1
	return NULL;
d1172 1
a1172 1
	return NULL;
@


1.150
log
@Iconify while transferring added.
Nicer update of fuelgauge.
@
text
@d38 1
a38 1
char str_buf[2048];
d46 2
a47 1
    int s, len,res;
d64 1
a64 1
	    return (1);
d74 1
a74 1
	return (0);
d88 1
a88 1
    res=tcp_connect(s,(struct sockaddr *)&hisctladdr);
d126 1
a126 1
		if (tcp_getpeername(s,&in,&len)==0) {/* This means we are connected */
d132 1
a132 1
		    return (1);
d144 1
a144 1
			return (0);
d150 1
a150 1
		    res=tcp_connect(s,(struct sockaddr *)&hisctladdr);
d156 1
a156 1
		    return (1);
d207 1
a207 1
    return (2);
d211 1
a211 1
    return (0);
d262 1
a262 1
	return (0);
d279 1
a279 1
	    return (0);
d292 1
a292 1
	return (0);
d296 1
a296 1
    return (1);
d302 1
a302 1
    int r,len;
d308 1
a308 1
	return(0);
d319 2
a320 2
    r = getreply(!strcmp(fmt, "QUIT"));
    return (r);
a329 1
    int errormsg=0;
d345 1
a345 1
	return (TRSF_BADFILE);
d351 1
a351 1
	return (TRSF_BADFILE);
d358 1
a358 1
	return (TRSF_BADFILE);
d365 1
a365 1
	return (TRSF_INITCONN);
d371 1
a371 1
	return (TRSF_BADFILE);
d376 1
a376 1
    sout=dataconn("w");
d390 1
a390 1
	tcp_ioctl(sout,TCPFIOASYNC,&true);
d469 1
a469 1
			tcp_send(sout,&c,1,0);
d504 1
a504 1
    return (TRSF_OK);
d508 1
a508 1
	return (TRSF_ABORTED);
d525 1
a525 1
    return (retcode);
d536 1
a536 1
    long d,bytes_transferred=0,retcode=TRSF_ABORTED;
d551 1
a551 1
	return (TRSF_INITCONN);
d557 1
a557 1
	    return (TRSF_FAILED);
d562 1
a562 1
	    return (TRSF_BADFILE);
d587 1
a587 1
	    return (TRSF_BADFILE);
d604 1
a604 1
    sin=dataconn("r");
d623 1
a623 2

	tcp_ioctl(sin,TCPFIOASYNC,&true);
d734 1
a734 1
    return (TRSF_OK);
d738 1
a738 1
	return (TRSF_ABORTED);
d756 1
a756 1
    return (TRSF_ABORTED);
d768 2
a769 1
    int result, len, tmpno = 0;
d789 1
a789 1
	return (1);
d833 1
a833 1
	return (result != COMPLETE);
d837 1
a837 1
    return (0);
d844 1
a844 1
    return (1);
d847 1
a847 1
int dataconn(char *lmode)
d851 2
a852 1
    int s, fromlen = sizeof (from);
d866 1
a866 1
	return (-1);
d877 1
a877 1
int getreply(int expecteof)
d918 1
a918 1
		      return (0);
d923 1
a923 1
		  return (4);
d980 1
a980 1
	return (n - '0');
d985 1
a985 1
int empty(fd_set *mask, int sec)
d991 1
a991 1
    return (tcp_waitselect(32, mask, (fd_set *)NULL, (fd_set *)NULL, &t,NULL));
d994 1
a994 1
void abort_remote(int din)
d1066 1
a1066 1
char *s_fgets(char *buf, int n, int fd)
d1081 1
a1081 1
char *next_remote_line(int sin)
d1097 2
a1098 2
      return (NULL);
    return (str);
d1113 1
a1113 1
      return (NULL);
d1122 1
a1122 1
      return (ftphost);
d1136 1
a1136 1
    return (ftphost);
d1139 1
a1139 1
int open_remote_ls(int nlst)
d1155 1
a1155 1
	return (NULL);
d1172 1
a1172 1
	return (NULL);
d1177 1
a1177 1
    sin = dataconn("r");
d1179 1
a1179 1
      return(-1);
d1182 1
a1182 1
    return(sin);
d1185 1
a1185 1
void close_remote_ls(int sin)
d1217 1
a1217 1
void settype(int type)
@


1.124
log
@AmiTCP and AS225r2 support in the same binary.
ARexx-command VIEW added.
New option to SETATTR, QUIET.
SETATTR LOCALDIR didn't update the download dir-gadget.
GETATTR STEM=bar didn't work since bar is in lowercase.
Enforcer hits when trying to open AmiFTP on a non-existing screen removed.
Moved 'Show dot-files?' to the Settings-menu.
Icelandic and Spanish catalogs added.
@
text
@a41 4
#ifdef AS225
#include "network:amitcp-3.0b2/netinclude/arpa/telnet.h"
#endif

d112 1
a112 1
		kprintf("Connectwin\n");
d115 1
a115 1
		kprintf("Not aborted\n");
a617 1
    GetAttr(WINDOW_SigMask,MainWin_Object,&mainsignal);
d637 1
a846 1
#ifdef SOCKIO
d848 1
a848 3
#else
FILE *dataconn(char *lmode)
#endif
a992 1
#ifdef SOCKIO
a993 3
#else
void abort_remote(FILE *din)
#endif
a1064 1
#ifdef SOCKIO
a1078 1
#endif
a1079 1
#ifdef SOCKIO
a1080 3
#else
char *next_remote_line(FILE *din)
#endif
a1137 1
#ifdef SOCKIO
a1138 3
#else
FILE *open_remote_ls(int nlst)
#endif
a1183 1
#ifdef SOCKIO
a1184 3
#else
void close_remote_ls(FILE *din)
#endif
@


0.1332
log
@Release 1.0
AmiFTP doesn't need amigaguide.library in order to start.
@
text
@d49 1
d58 1
a58 1
    hisctladdr.sin_addr.s_addr = inet_addr(host);
d63 1
a63 1
	hp = gethostbyname(host);
d74 1
a74 1
    s = socket(hisctladdr.sin_family, SOCK_STREAM, 0);
a75 1
//	perror("AmiFTP: socket");
d79 1
d82 1
a82 5
#ifndef AS225
	IoctlSocket(s,FIONBIO,(char *)&on);
#else
	s_ioctl(s,FIONBIO,(char *)&on);
#endif
d90 3
a92 2
#if 1
    res=connect(s,(struct sockaddr *)&hisctladdr,sizeof(hisctladdr));
d106 2
a107 5
#ifndef AS225
	res=WaitSelect(s+1,&rs,&ws,&es,&tv,&mask);
#else
	res=selectwait(s+1,&rs,&ws,&es,&tv,&mask);
#endif
d116 1
d119 1
d126 4
a129 6
#ifndef AS225
		IoctlSocket(s,FIONBIO,(char *)&off);
#else
		s_ioctl(s,FIONBIO,(char *)&off);
#endif
		if (getpeername(s,&in,&len)==0) {/* This means we are connected */
d133 1
a133 5
#ifndef AS225
		    CloseSocket(s);
#else
		    s_close(s);
#endif
d143 2
a144 6
#ifndef AS225
		    CloseSocket(s);
#else
		    s_close(s);
#endif
		    s=socket(hisctladdr.sin_family,SOCK_STREAM,0);
d151 1
a151 5
#ifndef AS225
			IoctlSocket(s,FIONBIO,(char *)&on);
#else
			s_ioctl(s,FIONBIO,(char *)&on);
#endif
d153 1
a153 1
		    res=connect(s,(struct sockaddr *)&hisctladdr,sizeof(hisctladdr));
d158 1
a158 5
#ifndef AS225
		    CloseSocket(s);
#else
		    s_close(s);
#endif
a166 50
#else
    while (connect(s, (struct sockaddr *)&hisctladdr,
		   sizeof (hisctladdr)) < 0) {
	if (hp && hp->h_addr_list[1]) {
	    extern char *inet_ntoa();

	    sprintf(scratch, "connect to address %s: %s",
		    inet_ntoa(hisctladdr.sin_addr), strerror(errno));
//	    printf(scratch);
	    hp->h_addr_list++;
	    bcopy(hp->h_addr_list[0],
		  (caddr_t)&hisctladdr.sin_addr, hp->h_length);
	    sprintf(scratch, "Trying %s...",
		    inet_ntoa(hisctladdr.sin_addr));
//	    printf(scratch);
#ifdef SOCKIO
#ifndef AS225
	    CloseSocket(s);
#else
	    s_close(s);
#endif
#else
	    (void) close(s);
#endif
	    s = socket(hisctladdr.sin_family, SOCK_STREAM, 0);
	    if (s < 0) {
//		perror("AmiFTP: socket");
		code = -1;
		return (0);
	    }
	    continue;
	}
	code = -1;
	if ((errno == ENETUNREACH) || (errno == EHOSTUNREACH)) {
#ifdef SOCKIO
#ifndef AS225
	    CloseSocket(s);
#else
	    s_close(s);
#endif
#else
	    (void) close(s);
#endif
	    return (1);
	}
//	sprintf(scratch, "connect: %s: %s", host, strerror(errno));
	PrintConnectStatus(strerror(errno));
	goto bad;
    }
#endif
d169 1
a169 2
    if (getsockname(s, (struct sockaddr *)&myctladdr, &len) < 0) {
//	perror("AmiFTP: getsockname");
d173 1
a173 1
#ifdef SOCKIO
d175 1
a175 10
#else
    responsefp = fdopen(s, "r");
    commandfp = fdopen(s, "w");
    if (responsefp == NULL || commandfp == NULL) {
//	fprintf(stderr, "AmiFTP: fdopen failed.\n");
	close_files();
	code = -1;
	goto bad;
    }
#endif
d194 1
a194 1
//	printf("The proxy FTP relay is down. Try again later.");
d203 2
a204 2
	if (setsockopt(s, SOL_SOCKET, SO_OOBINLINE, (char *)&on,
		       sizeof (on)) < 0 && debug) {
d212 2
a213 9
#ifdef SOCKIO
#ifndef AS225
    CloseSocket(s);
#else
    s_close(s);
#endif
#else
    (void) close(s);
#endif
d271 1
a271 1
	if (pass == NULL)
d308 1
a308 1
#ifdef SOCKIO
a312 9
#else
    if (commandfp == NULL) {
	/*
	  perror ("No control connection for command");
	  */
	code = 421;
	return (0);
    }
#endif
d315 1
a315 1
#ifdef SOCKIO
d318 1
a318 1
    send(cout,str_buf,len+2,0);
a319 6
#else
    vfprintf(commandfp, fmt, ap);
    va_end(ap);
    fprintf(commandfp, "\r\n");
    (void) fflush(commandfp);
#endif
d326 1
a326 4
#ifndef AS225
#include <amitcp/socketbasetags.h>
#endif
int sendrequest(char *cmd, char *local, char *remote)
a328 1
#ifdef SOCKIO
a329 3
#else
    FILE *dout=0;
#endif
d379 1
a379 1
#ifdef SOCKIO
a382 5
#else
    dout=dataconn("w");
    if (dout==NULL)
      goto abort;
#endif
d394 1
a394 5
#ifndef AS225
	IoctlSocket(fileno(dout),FIOASYNC,&true);
#else
	s_ioctl(sout,FIOASYNC,&true);
#endif
a406 4
#ifndef AS225
	FD_SET(fileno(dout),&writemask);
	ret=WaitSelect(fileno(dout)+1,NULL,&writemask,NULL,NULL,&mask);
#else
d408 1
a408 2
	ret=selectwait(sout+1,NULL,&writemask,NULL,NULL,&mask);
#endif
a421 39
#if 0
		struct IntuiMessage *imsg;
		if (DEBUG) Printf("Got signal from window\n");
		while (imsg=GT_GetIMsg(dl_Win->UserPort)) {
		    ULONG MsgClass;
		    UWORD Code;
		    APTR IAddress;
		    MsgClass=imsg->Class;
		    Code    =imsg->Code;
		    IAddress=imsg->IAddress;
		    GT_ReplyIMsg(imsg);
		    switch (MsgClass) {
		      case IDCMP_CLOSEWINDOW:
			goto abort;
			break;
		      case IDCMP_REFRESHWINDOW:
			GT_BeginRefresh(dl_Win);
			GT_EndRefresh(dl_Win,TRUE);
			break;
		      case IDCMP_GADGETHELP:
			ag.ag_region=-1;
			if (IAddress==(APTR)dl_Win) {
			    ag.ag_region=0;
			}
			break;
		      case IDCMP_RAWKEY:
			if (Code==95) {
			    SendAGMessage(AG_TRANSWIN);
			}
			break;
		      case IDCMP_GADGETUP:
		      case IDCMP_GADGETDOWN:
			goto abort;
			break;
		      default:
			break;
		    }
		}
#endif
a427 1
#ifndef AS225
a428 3
#else
		    UpdateDLGads(bytes_transferred,0,(GetSysTime(&currtime),currtime.tv_secs-starttime.tv_secs));
#endif
d433 1
a433 1
	else if (ret>0) {
a434 3
#ifndef AS225
	    if (FD_ISSET(fileno(dout),&writemask)) {
#else
a435 1
#endif
d443 1
a443 5
#ifdef SOCKIO
			  if ((d=send(sout,bufp,c,0))<=0)
#else
			  if ((d=write(fileno(dout),bufp,c))<=0)
#endif
a446 8
#if 0
			      if (TransferWindow)
#ifndef AS225
				UpdateDLGads(bytes_transferred,NULL,(GetSysTime(&currtime),currtime.tv_sec-starttime.tv_sec));
#else
			        UpdateDLGads(bytes_transferred,NULL,(GetSysTime(&currtime),currtime.tv_secs-starttime.tv_secs));
#endif
#endif
d470 1
a470 5
#ifdef SOCKIO
			    send(sout,"\r",1,0);
#else
			    putc('\r',dout);
#endif
d473 1
a473 5
#ifdef SOCKIO
			send(sout,&c,1,0);
#else
			putc(c,dout);
#endif
a477 7
#if 0
#ifndef AS225
			    UpdateDLGads(bytes_transferred,0,(GetSysTime(&currtime),currtime.tv_sec-starttime.tv_sec));
#else
			    UpdateDLGads(bytes_transferred,0,(GetSysTime(&currtime),currtime.tv_secs-starttime.tv_secs));
#endif
#endif
d488 1
a488 1
	else {
a493 1
#ifndef AS225
d495 1
a495 3
#else
      UpdateDLGads(bytes_transferred,0,(GetSysTime(&currtime),currtime.tv_secs-starttime.tv_secs));
#endif
d498 1
a498 6
#ifdef SOCKIO
#ifndef AS225
    CloseSocket(sout);
#else
    s_close(sout);
#endif
d501 1
a501 4
#else
    fclose(dout);
    dout=NULL;
#endif
d516 1
a516 9
#ifdef SOCKIO
#ifndef AS225
	CloseSocket(data);
#else
	s_close(data);
#endif
#else
	(void) close(data);
#endif
a535 1
#ifdef SOCKIO
a536 3
#else
    FILE *din=0;
#endif
d607 1
a607 1
#ifdef SOCKIO
d611 1
a611 5
#else
    din=dataconn("r");
    if (din==NULL)
      goto abort;
#endif
d628 2
a629 5
#ifndef AS225
	IoctlSocket(fileno(din),FIOASYNC,&true);
#else
	s_ioctl(sin,FIOASYNC,&true);
#endif
d640 1
d642 2
a643 1
	mask=winmask|AG_Signal|SIGBREAKF_CTRL_C|t;
d645 2
a646 4
#ifndef AS225
	FD_SET(fileno(din),&readmask);
	ret=WaitSelect(fileno(din)+1,&readmask,NULL,NULL,NULL,&mask);
#else
d648 2
a649 2
	ret=selectwait(sin+1,&readmask,NULL,NULL,NULL,&mask);
#endif
d657 3
a659 2
	    if (mask&mainsignal)
	      HandleMainWindowIDCMP(FALSE);
a663 38
#if 0
		struct IntuiMessage *imsg;
		while (imsg=GT_GetIMsg(dl_Win->UserPort)) {
		    ULONG MsgClass;
		    UWORD Code;
		    APTR IAddress;
		    MsgClass=imsg->Class;
		    Code    =imsg->Code;
		    IAddress=imsg->IAddress;
		    GT_ReplyIMsg(imsg);
		    switch (MsgClass) {
		      case IDCMP_CLOSEWINDOW:
			goto abort;
			break;
		      case IDCMP_REFRESHWINDOW:
			GT_BeginRefresh(dl_Win);
			GT_EndRefresh(dl_Win,TRUE);
			break;
		      case IDCMP_GADGETHELP:
			ag.ag_region=-1;
			if (IAddress==(APTR)dl_Win) {
			    ag.ag_region=0;
			}
			break;
		      case IDCMP_RAWKEY:
			if (Code==95) {
			    SendAGMessage(AG_TRANSWIN);
			}
			break;
		      case IDCMP_GADGETUP:
		      case IDCMP_GADGETDOWN:
			goto abort;
			break;
		      default:
			break;
		    }
		}
#endif
a669 1
#ifndef AS225
a670 3
#else
		    UpdateDLGads(bytes_transferred,restartpoint,(GetSysTime(&currtime),currtime.tv_secs-starttime.tv_secs));
#endif
d674 2
a675 2
	}
	else if (ret>0) {
a676 3
#ifndef AS225
	    if (FD_ISSET(fileno(din),&readmask)) {
#else
a677 1
#endif
d681 1
a681 5
#ifndef AS225
		    c=recv(fileno(din),transfer_buf,bufsize,0);
#else
		    c=recv(sin,transfer_buf,bufsize,0);
#endif
a694 7
#if 0
#ifndef AS225
			UpdateDLGads(bytes_transferred,restartpoint,(GetSysTime(&currtime),currtime.tv_sec-starttime.tv_sec));
#else
			UpdateDLGads(bytes_transferred,restartpoint,(GetSysTime(&currtime),currtime.tv_secs-starttime.tv_secs));
#endif
#endif
a698 3
#ifndef AS225
		    c=getc(din);
#else
a699 1
#endif
a704 3
#ifndef AS225
			    if ((c=getc(din))!='\n'||tcrflag) {
#else
a705 1
#endif
a713 7
#if 0
#ifndef AS225
			    UpdateDLGads(bytes_transferred,restartpoint,(GetSysTime(&currtime),currtime.tv_sec-starttime.tv_sec));
#else
			    UpdateDLGads(bytes_transferred,restartpoint,(GetSysTime(&currtime),currtime.tv_secs-starttime.tv_secs));
#endif
#endif
d720 2
a721 2
	}
	else {
a726 1
#ifndef AS225
a727 3
#else
      UpdateDLGads(bytes_transferred,restartpoint,(GetSysTime(&currtime),currtime.tv_secs-starttime.tv_secs));
#endif
d730 1
a730 6
#ifdef SOCKIO
#ifndef AS225
    CloseSocket(sin);
#else
    s_close(sin);
#endif
a732 3
#else
    fclose(din);
#endif
a744 1
#ifdef SOCKIO
d746 1
a746 3
#else
    abort_remote(din);
#endif
d749 1
a749 9
#ifdef SOCKIO
#ifndef AS225
	CloseSocket(data);
#else
	s_close(data);
#endif
#else
	(void) close(data);
#endif
d755 1
a755 6
#ifndef SOCKIO
    if (din) {
	(void) fclose(din);
	din = NULL;
    }
#endif
d781 1
a781 9
#ifdef SOCKIO
#ifndef AS225
	CloseSocket(data);
#else
	s_close(data);
#endif
#else
	(void) close(data);
#endif
d786 1
a786 1
    data = socket(AF_INET, SOCK_STREAM, 0);
d800 2
a801 2
	if (setsockopt(data, SOL_SOCKET, SO_REUSEADDR, (char *)&on,
		       sizeof (on)) < 0) {
d810 1
a810 1
    if (bind(data, (struct sockaddr *)&data_addr, sizeof (data_addr)) < 0) {
d817 1
a817 1
    if (getsockname(data, (struct sockaddr *)&data_addr, &len) < 0) {
d823 1
a823 1
    if (listen(data, 1) < 0) {}
d843 1
a843 6
#ifdef SOCKIO
#ifndef AS225
    CloseSocket(data);
#else
    s_close(data);
#endif
d845 1
a845 3
#else
    (void) close(data), data = -1;
#endif
d863 1
a863 1
    s = accept(data, (struct sockaddr *) &from, &fromlen);
d870 1
a870 9
#ifdef SOCKIO
#ifndef AS225
	CloseSocket(data);
#else
	s_close(data);
#endif
#else
	(void) close(data);
#endif
a871 1
#ifdef SOCKIO
a872 3
#else
	return (NULL);
#endif
d874 1
a874 9
#ifdef SOCKIO
#ifndef AS225
    CloseSocket(data);
#else
    s_close(data);
#endif
#else
    (void) close(data);
#endif
a875 1
#ifdef SOCKIO
a878 3
#else
    return (fdopen(data, lmode));
#endif
a894 1
#ifdef SOCKIO
a897 3
#else
	while ((c = getc(responsefp)) != '\n')
#endif
a899 1
#ifdef SOCKIO
a900 3
#else
		    switch (c = getc(responsefp))
#endif
a903 1
#ifdef SOCKIO
d906 1
a906 1
			  send(cout,str_buf,3,0);
d912 1
a912 7
			  send(cout,str_buf,3,0);
			  break;
#else
			  c = getc(responsefp);
			  fprintf(commandfp,
				  "%c%c%c", IAC, DONT, c);
			  (void) fflush(commandfp);
a913 8
			case DO:
			case DONT:
			  c = getc(responsefp);
			  fprintf(commandfp,
				  "%c%c%c", IAC, WONT, c);
			  (void) fflush(commandfp);
			  break;
#endif
d994 1
a994 1
#ifndef AS225
d997 1
a997 5
#else
    t.tv_secs=(long)sec;
    t.tv_micro=0;
#endif
    return (select(32, mask, (fd_set *)NULL, (fd_set *)NULL, &t));
d1017 2
a1018 5
#ifdef SOCKIO
    rval = send(cout,buf,3,MSG_OOB);
#else
    rval = send(fileno(commandfp), buf, 3, MSG_OOB);
#endif
a1023 1
#ifdef SOCKIO
d1025 1
a1025 1
    send(cout,buf,strlen(buf), MSG_OOB);
d1027 1
a1027 4
#else
    fprintf(commandfp, "%cABOR\r\n", DM);
    (void) fflush(commandfp);
#endif
a1028 1
#ifdef SOCKIO
d1030 1
a1030 4
#else
    FD_SET(fileno(responsefp), &mask);
#endif
#ifdef SOCKIO
d1034 1
a1034 5
#else
    if (din) {
	FD_SET(fileno(din), &mask);
    }
#endif
a1044 1
#ifdef SOCKIO
d1047 1
a1047 1
	while ((FD_ISSET(din,&mask)==din) && (recv(din, buf, BUFSIZ,0)>0));
d1051 1
a1051 6
#else
    if (din && FD_ISSET(fileno(din), &mask)) {
	while (read(fileno(din), buf, BUFSIZ) > 0)
	{  /* LOOP */}
    }
#endif
a1060 1
#ifdef SOCKIO
d1063 2
a1064 6
	    shutdown(cout, 1+1);
#ifndef AS225
	    CloseSocket(cout);
#else
	    s_close(cout);
#endif
d1068 2
a1069 6
	    shutdown(data,1+1);
#ifndef AS225
	    CloseSocket(data);
#else
	    s_close(data);
#endif
a1073 15
#else
    if (connected) {
	if (commandfp != NULL) {
	    (void) shutdown(fileno(commandfp), 1+1);
	    (void) fclose(commandfp);
	    commandfp = NULL;
	}
	if (data >= 0) {
	    (void) shutdown(data, 1+1);
	    (void) close(data);
	    data = -1;
	}
	connected = 0;
    }
#endif
d1083 1
a1083 1
	if (recv(fd, buf, 1,0) <= 0)
a1103 1
#ifdef SOCKIO
a1105 3
#else
    while ((c = getc(din)) != '\n' && c != EOF && c != '\0') {
#endif
d1143 1
a1143 1
	servent = getservbyname(tmp, "tcp");
a1162 1
#ifdef SOCKIO
a1163 3
#else
    FILE *din = 0;
#endif
a1194 1
#ifdef SOCKIO
a1202 6
#else
    din = dataconn("r");
    if (din == NULL)
      return (NULL);
    return (din);
#endif
a1210 1
#ifdef SOCKIO
d1213 3
a1215 11
    shutdown(sin,1+1);
#ifndef AS225
    CloseSocket(sin);
#else
    s_close(sin);
#endif
#else
    if (ferror(din))
      perror("netin");
    (void) fclose(din);
#endif
@


0.1300
log
@Added Reload-gadget.
Added Sort-gadget to sitelist-window.
AmiFTP now show the correct size of links during transfer.
@
text
@d803 1
d805 1
@


0.857
log
@Log-window function working. Only thing missing a to control it from ARexx.
@
text
@d35 1
d49 1
a49 1
    int s, len;
d52 2
d79 8
d88 101
d237 2
d311 2
d361 1
d449 1
a449 1
    ULONG winmask=NULL,mask=NULL;
d451 1
a451 1
    long ret;
d453 2
a454 1
    extern struct Window *dl_Win;
d501 4
a504 2
    if (dl_Win)
      winmask=1<<dl_Win->UserPort->mp_SigBit;
d515 7
d524 1
a524 1
	mask=winmask|AG_Signal|SIGBREAKF_CTRL_C;
d540 2
d543 4
d584 14
d622 2
a623 1
			      if (dl_Win)
d629 1
d643 1
a643 1
			if (dl_Win)
d666 1
d669 1
d675 1
d691 6
d712 5
d741 5
d748 1
d765 3
a767 1
    ULONG winmask=NULL,mask;
d789 18
d843 3
a845 2
    if (dl_Win)
      winmask=1<<dl_Win->UserPort->mp_SigBit;
d858 8
d867 1
a867 1
	mask=winmask|AG_Signal|SIGBREAKF_CTRL_C;
d883 2
d886 4
d926 14
d970 1
d976 1
d1004 1
d1010 1
d1023 6
d1043 5
d1081 5
@


0.827
log
@Add Current to sitelist added.
More rtLockWindow()'s
Leeching seems to work, but is not finished yet.
@
text
@d1020 1
a1020 1

d1022 3
a1024 3
	while ((c = sgetc(cin)) != '\n') {
//	    printf("%c",c);
//	    fflush(stdout);
d1026 1
a1026 1
	while ((c = getc(responsefp)) != '\n') {
d1028 2
a1029 1
	    if (c == IAC) {	/* handle telnet commands */
d1031 1
a1031 1
		switch (c = sgetc(cin)) {
d1033 1
a1033 1
		switch (c = getc(responsefp)) {
d1035 3
a1037 2
		  case WILL:
		  case WONT:
d1039 10
a1048 10
		    str_buf[0] = IAC; str_buf[1] = DONT;
		    str_buf[2] = sgetc(cin);
		    send(cout,str_buf,3,0);
		    break;
		  case DO:
		  case DONT:
		    str_buf[0] = IAC;str_buf[1]=DONT;
		    str_buf[2] = sgetc(cin);
		    send(cout,str_buf,3,0);
		    break;
d1050 12
a1061 12
		    c = getc(responsefp);
		    fprintf(commandfp,
			    "%c%c%c", IAC, DONT, c);
		    (void) fflush(commandfp);
		    break;
		  case DO:
		  case DONT:
		    c = getc(responsefp);
		    fprintf(commandfp,
			    "%c%c%c", IAC, WONT, c);
		    (void) fflush(commandfp);
		    break;
d1063 37
a1099 2
		  default:
		    break;
a1100 8
		continue;
	    }
	    dig++;
	    if (c == EOF) {
		if (expecteof) {
		    code = 221;
//printf("\n");
		    return (0);
d1102 5
a1106 28
		lostpeer();
		code = 421;
//printf("\n");
		return (4);
	    }
	    if (c != '\r' && (verbose > 0 ||
			      (verbose > -1 && n == '5' && dig > 4))) {
		/*
		  (void) putchar(c);
		  */
//		printf("%c",c);
	    }
		if (c!='\r')
		  Printf("%lc",c);
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
d1108 7
a1114 11
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
d1119 1
a1119 1
//	    printf("%c",c);
a1121 1
	    Printf("%lc",c);
d1132 3
a1134 1
//printf("\n");
d1137 1
a1137 1
//printf("\n");
@


0.814
log
@Added default download-dir.
@
text
@d1085 2
d1112 1
a1112 1
	}
d1120 1
@


0.807
log
@Added AmigaGuide on-line help.
@
text
@d35 1
a35 1
void UpdateDLGads(long bytes,time_t time);
@


0.700
log
@Fixed bug in initconn(). Now works with mlink!!!
CPS is now cleared after each upload.
@
text
@d397 1
a397 1
	mask=winmask|SIGBREAKF_CTRL_C;
d410 3
d419 1
d422 1
d432 11
d669 1
a669 1
	mask=winmask|SIGBREAKF_CTRL_C;
d682 3
d690 1
d693 1
d702 11
@


0.671
log
@"View" on links downloaded it twice.
@
text
@d858 13
a870 8
    if (!sendport)
      if (DEBUG)
	Printf("initconn: setsockopt()\n");
      if (setsockopt(data, SOL_SOCKET, SO_REUSEADDR, (char *)&on,
		     sizeof (on)) < 0) {
//	  perror("AmiFTP: setsockopt (reuse address)");
	  goto bad;
      }
d1237 17
d1266 1
d1279 1
@


0.667
log
@Datatransferred was updated one time too much.
@
text
@d444 1
a444 1
		Printf("Got signal from socket\n");
@


0.656
log
@De-selection after downloading multiple files now work again.
Aborting now results in aborting the entire transfer.
@
text
@d332 1
a332 1
    ULONG winmask,mask;
d353 2
a354 1
	goto abort;
d356 2
a357 1

d363 2
a364 1

d369 2
d383 3
a385 1
    winmask=1<<dl_Win->UserPort->mp_SigBit;
d395 1
d412 1
d444 1
d580 1
a580 1
    ULONG winmask,mask;
d638 2
a639 1
    winmask=1<<dl_Win->UserPort->mp_SigBit;
d718 2
a719 1
		    bytes_transferred+=(long)d;
d721 1
a721 1
		    UpdateDLGads(bytes_transferred,restartpoint,(GetSysTime(&currtime),currtime.tv_sec-starttime.tv_sec));
d723 1
a723 1
		    UpdateDLGads(bytes_transferred,restartpoint,(GetSysTime(&currtime),currtime.tv_secs-starttime.tv_secs));
d725 1
a725 1
		    
d929 2
@


0.647
log
@Release version, small things fixed.
@
text
@d698 1
a698 1
			  goto abort;
d701 1
a701 1
			goto abort;
d705 2
a706 2
		    if (d!=c)
		      goto abort;
@


0.623
log
@Added menuitem TransferMode->Binary/ASCII
@
text
@d324 1
a324 1
    register int c;
d379 1
a379 1
    error=d=bytes_transferred=0;
d385 1
a385 1
	ioctl(sin,FIOASYNC,&true);
d430 1
d432 3
d493 5
d521 1
a521 1
    sin=-1;
d637 1
a637 1
	ioctl(sin,FIOASYNC,&true);
d730 1
a730 1
			    if ((c=sgetc(din))!='\n'||tcrflag) {
d1159 2
a1160 1
	while (recv(din, buf, BUFSIZ,0)>0);
d1166 1
a1166 1
	  /* LOOP */;
@


0.588
log
@The GUI now handles proportional fonts. Only the main listview is fixed font.
@
text
@a314 1

d317 1
d323 7
a329 4
    long d,bytes,c,bytes_transferred=0,retcode=TRSF_ABORTED;
    struct timeval starttime, currtime;
    struct FileInfoBlock __aligned fib;
    struct AsyncFile *ASyncFH;
d331 5
a335 1
    char buf[512],*bufp;
d361 2
a362 2
    
    if (command("%s %s",cmd,remote)!=PRELIM) {
d364 1
a364 1
	return (TRSF_FAILED);
d368 2
a369 4
    if (sout==-1) {
	retcode=TRSF_INITCONN;
	goto abort;
    }
d372 2
a373 4
    if (dout==NULL) {
	retcode=TRSF_INITCONN;
	goto abort;
    }
d375 1
d378 8
a385 30
    switch (curtype) {
      case TYPE_I:
      case TYPE_L:
	d=0;
	while ((c=ReadAsync(ASyncFH,buf,sizeof(buf)))>0) {
	    for (bufp=buf;c>0;c-=d,bufp+=d)
#ifdef SOCKIO
	      if ((d=send(sout,bufp,c,0))<=0)
#else
	      if ((d=write(fileno(dout),bufp,c))<=0)
#endif
		break;
	      else {
		  bytes_transferred+=d;
		  if (dl_Win)
#ifndef AS225
		    UpdateDLGads(bytes_transferred,(GetSysTime(&currtime),currtime.tv_sec-starttime.tv_sec));
#else
		    UpdateDLGads(bytes_transferred,(GetSysTime(&currtime),currtime.tv_secs-starttime.tv_secs));
#endif
#ifdef AS225
		  if (dl_Win)
		    if (SetSignal(0L,1<<dl_Win->UserPort->mp_SigBit)&(1<<dl_Win->UserPort->mp_SigBit)) {
			retcode=TRSF_ABORTED;
			goto abort;
		    }
		  if (SetSignal(0L,SIGBREAKF_CTRL_C)&SIGBREAKF_CTRL_C) {
		      retcode=TRSF_ABORTED;
		      goto abort;
		  }
d387 4
a390 14
	      }
	      if (c<0) {
		  if (dl_Win)
		    ShowErrorReq("Read %s: %s.",local,(Fault(IoErr(),NULL,buf,100),buf));
		  retcode=TRSF_FAILED;
		  goto abort;
	      }
	      if (d<0) {
		  if (errno==EINTR) {
		      struct IntuiMessage *imsg;
		      if (dl_Win) {
			  WaitPort(dl_Win->UserPort);
			  while (imsg=GT_GetIMsg(dl_Win->UserPort)) {GT_ReplyIMsg(imsg);}
		      }
d392 5
a396 1
		      SocketBaseTags(SBTM_SETVAL(SBTC_BREAKMASK),SIGBREAKF_CTRL_C,TAG_END);
d398 29
a426 7
		      retcode=TRSF_ABORTED;
		      goto abort;
		  }
		  ShowErrorReq(GetAmiFTPString(Str_RemoteWriteFailed));
		  retcode=TRSF_FAILED;
		  goto abort;
	      }
d428 22
a449 8
	break;
      case TYPE_A:
	bytes=0;
	while((c=ReadCharAsync(ASyncFH)) !=-1) {
	    if (c=='\n') {
#ifndef SOCKIO
		if (ferror(dout))
		  break;
d451 23
d475 1
a475 1
		send(sout,"\r",1,0);
d477 1
a477 1
		putc('\r',dout);
d479 2
a480 2
		bytes++;
	    }
d482 1
a482 1
	    send(sout,&c,1,0);
d484 1
a484 1
	    putc(c,dout);
d486 11
a496 3
	    bytes++;
	    if (bytes>=1024) {
		bytes=0; // Fix this:
d499 2
a500 4
	/* Fix this: Check if while() was ended because of failure */
	if (IoErr()) {
	    // Read error
	      retcode=TRSF_FAILED;
d502 1
a502 1
	break;
d512 1
a512 1
    sout=-1;
d525 2
a526 1
    if (data>=0) {
d531 1
a531 1
        s_close(data);
a532 1
	sout=-1;
d534 1
a534 1
	close(data);
d536 1
a536 6
	data=-1;
    }
#ifndef SOCKIO
    if (dout) {
	fclose(dout);
	dout=NULL;
a537 1
#endif
d540 2
a541 1
    if (ASyncFH)
d546 1
a546 1
int recvrequest(char *cmd, char *local, char *remote, char *lmode, ULONG restartpoint)
d554 1
a554 1
    int is_retr, tcrflag, bare_lfs = 0;
d558 6
a563 2
    int		errormsg = 0;
    struct timeval starttime,currtime;;
d565 2
a566 2
    is_retr = strcmp(cmd, "RETR") == 0;
    tcrflag = !crflag && is_retr;
d569 1
a569 1
	code = -1;
d580 1
a580 6
	if (command("%s %s", cmd, remote) != PRELIM) {
	    /* Not a plain file */
	    /* Permission denied */
	    /* No such file or directory */

//	    ShowErrorReq(GetAmiFTPString(Str_GetFailed),remote);
d583 4
a586 7
    } else {
	if (command("%s", cmd) != PRELIM) {
//	    ShowErrorReq(GetAmiFTPString(Str_GetFailed),cmd);
	    /*
	      fprintf(stderr, "command != PRELIM\n");
	      */
	    return (TRSF_FAILED);
a588 1

d590 3
a592 4
	transfer_buf=malloc((unsigned)10240);
	if (transfer_buf) {
	    bufsize=10240;
	}
d594 2
a595 3
	    transfer_buf=malloc((unsigned)512);
	    if (transfer_buf == NULL) {
		perror("malloc");
d603 2
a604 2
    sin = dataconn("r");
    if (sin == -1)
d607 2
a608 2
    din = dataconn("r");
    if (din == NULL)
a610 4

//    if (DEBUG)
//      kprintf("Ping 6\n");

d613 1
a613 1
	ShowErrorReq(GetAmiFTPString(Str_LocalfileError), local);
d617 1
d619 3
a621 1
    GetSysTime(&starttime);
d623 6
a628 31
    switch (curtype) {
      case TYPE_I:
      case TYPE_L:
	errno = d = bytes_transferred = 0;
#ifdef SOCKIO
	while ((c = recv(sin, transfer_buf, bufsize, 0)) > 0) {
#else
	while ((c = read(fileno(din), transfer_buf, bufsize)) > 0) {
#endif
	    if ((d=WriteAsync(ASyncFH,transfer_buf,c)) <=0)
	      break;

	    /* change image */
	    if (d != c)
	      break;
	    bytes_transferred=bytes_transferred+(long)d;
#ifndef AS225
	    UpdateDLGads(bytes_transferred,(GetSysTime(&currtime),currtime.tv_sec-starttime.tv_sec));
#else
	    UpdateDLGads(bytes_transferred,(GetSysTime(&currtime),currtime.tv_secs-starttime.tv_secs));
#endif
#ifdef AS225
	    if (dl_Win)
	      if (SetSignal(0L,1<<dl_Win->UserPort->mp_SigBit)&(1<<dl_Win->UserPort->mp_SigBit)) {
		  retcode=TRSF_ABORTED;
		  goto abort;
	      }
	    if (SetSignal(0L,SIGBREAKF_CTRL_C)&SIGBREAKF_CTRL_C) {
		retcode=TRSF_ABORTED;
		goto abort;
	    }
d630 5
a634 9
	}
	if (c < 0) {
	    if (errno == EINTR) {
		extern struct Window *dl_Win;
		struct IntuiMessage *imsg;
		if (dl_Win) {
		    WaitPort(dl_Win->UserPort);
		    while(imsg=GT_GetIMsg(dl_Win->UserPort)){GT_ReplyIMsg(imsg);}
		}
d636 5
a640 1
		SocketBaseTags(SBTM_SETVAL(SBTC_BREAKMASK),SIGBREAKF_CTRL_C,TAG_END);
d642 2
a643 2
//		Printf("Got interrupt\n");
		retcode=TRSF_ABORTED;
d646 24
a669 13
	    if (errno != EPIPE){}
//	      perror("netin");
	}
	if (d < c) {
	    errormsg = 1;
	    if (d < 0) {
		ShowErrorReq(GetAmiFTPString(Str_LocalWriteFailed),
		       strerror(errno));
		retcode=TRSF_FAILED;
		goto abort;
	    } else {
		ShowErrorReq("Short write: %s",
		       strerror(errno));
d672 38
a709 6
	break;

      case TYPE_A:
	bytes = 0;
#ifdef SOCKIO
	while ((c = sgetc(sin)) != EOF) {
d711 1
a711 1
	while ((c = getc(din)) != EOF) {
d713 7
a719 6
	    if (c == '\n')
	      bare_lfs++;
	    while (c == '\r') {
		bytes++;
#ifdef SOCKIO
		if ((c = sgetc(sin)) !='\n' || tcrflag) {
d721 1
a721 1
		if ((c = getc(din)) != '\n' || tcrflag) {
d723 8
a730 9
		    WriteCharAsync(ASyncFH,'\r');
		}
	    }
	    WriteCharAsync(ASyncFH,c);
	    bytes++;
	    if (bytes >= 1024) {
		/* change image */
		bytes_transferred+=bytes;
		bytes = 0;
d732 1
a732 1
		UpdateDLGads(bytes_transferred,(GetSysTime(&currtime),currtime.tv_sec-starttime.tv_sec));
d734 1
a734 1
		UpdateDLGads(bytes_transferred,(GetSysTime(&currtime),currtime.tv_secs-starttime.tv_secs));
d736 5
a741 1
	      contin2:		/* null */;
d743 2
a744 14
      break2:
	if (bare_lfs) {
/*	    fprintf(stdout,
		    "WARNING! %d bare linefeeds received in ASCII mode\n",
		    bare_lfs);
	    fprintf(stdout,
		    "File may not have transferred correctly.\n");*/
	}
#ifndef SOCKIO
	if (ferror(din)) {
	    if (errno == EINTR)
	      break;
	    if (errno != EPIPE){}
//	      perror("netin");
d746 1
a746 2
#endif
	break;
d756 2
a757 2
    sin =-1;
    data = -1;
d759 1
a759 2
    (void) fclose(din);
    din = NULL;
d761 2
a762 4
    (void) getreply(0);
//    if (!errormsg)
//      printf("Receive of %s complete.", remote);
    return (0);
a763 3
 
    /* abort using RFC959 recommended IP,SYNC sequence  */

d765 1
a765 1
	code = -1;
a767 1
//Printf("Aborting\n");
d796 1
@


0.563
log
@AmiFTP now works with AS225r2 and hopefully with mlink.
Fixes concerning the locale.
@
text
@d394 11
d615 11
@


0.531
log
@Resume transfer added (when getting files).
Get-dir-tree is broken.
@
text
@d61 1
a61 1
	    PrintConnectStatus("Unknown host");
d869 3
d873 1
d1175 1
d1266 2
a1267 2
    if (sin == NULL)
      return(NULL);
@


0.486
log
@Recursive getting of directory trees implemented.
Password/Anonymous-gadget added in SiteConfiguration Window
Layout fixes.
@
text
@d499 1
a499 1
int recvrequest(char *cmd, char *local, char *remote, char *lmode)
d521 7
d575 1
a575 1
    ASyncFH=OpenAsync(local,MODE_WRITE,8192);
@


0.388
log
@send/recv-request re-written
Layoutbug in connect-window fixed
@
text
@d510 1
a510 1
    long d,bytes_transferred,retcode=TRSF_ABORTED;
d527 1
a527 1
	    ShowErrorReq(GetAmiFTPString(Str_GetFailed),remote);
d532 1
a532 1
	    ShowErrorReq(GetAmiFTPString(Str_GetFailed),cmd);
@


0.371
log
@Localized source.
@
text
@d316 1
a316 1
int sendrequest(char *cmd, char *local, char *remote, int size, int *aborted)
a317 6
#ifndef AS225
    struct stat st;
#endif
    int c, bytes;
    long d,bytes_transferred=0;
    FILE *fin = NULL;
d323 6
a328 5
    int (*closefunc)();
    char *lmode, buf[BUFSIZ], *bufp;
    char	*ftperr;
    int		errormsg = 0;
    struct timeval starttime,currtime;
d331 9
a339 5
    closefunc = NULL;
    lmode = "w";
    fin = fopen(local, "r");
    if (fin == NULL) {
	code = -1;
a341 1
    closefunc = fclose;
d343 4
a346 8
#ifndef AS225
    if (fstat(fileno(fin), &st) < 0 ||
	(st.st_mode&S_IFMT) != S_IFREG) {
	ShowErrorReq("%s: not a plain file.",local);
	fclose(fin);
	fin = NULL;
	code = -1;
	return (TRSF_BADFILE);
d348 1
a348 1
#endif
d350 2
a351 3
	code = -1;
	if (closefunc != NULL)
	  (*closefunc)(fin);
d354 17
a370 28
    if (remote) {
	if (command("%s %s", cmd, remote) != PRELIM) {
	    if (closefunc != NULL)
	      (*closefunc)(fin);
	    /* Permission denied */

	    sprintf(scratch, GetAmiFTPString(Str_Putfailed), remote);
	    ftperr = ftp_error(' ', scratch);
	    if (dl_Win)
	      ShowErrorReq(ftperr);

	    return (TRSF_FAILED);
	}
    } else
      if (command("%s", cmd) != PRELIM) {
	  if (closefunc != NULL)
	    (*closefunc)(fin);
//	  fprintf(stderr, "command != PRELIM\n");
	  return (TRSF_FAILED);
      }
#ifdef SOCKIO
    sout = dataconn(lmode);
    if (sout == -1)
      goto abort;
#else
    dout = dataconn(lmode);
    if (dout == NULL)
      goto abort;
d373 1
a374 1

d377 3
a379 6
	errno = d = 0;
	while ((c = read(fileno(fin), buf, sizeof (buf))) > 0) {
	    if (abort_transfer) {
		goto abort;
	    }
	    for (bufp = buf; c > 0; c -= d, bufp += d)
d381 1
a381 1
	      if ((d = send(sout,bufp,c,0)) <=0) {
d383 1
a383 1
	      if ((d = write(fileno(dout), bufp, c)) <= 0) {
d385 2
a386 2
		  break;
	      } else {
d395 23
a417 26
	    if (abort_transfer) {
//		notify_no_dispatch();
		goto abort;
	    }
	}
//	notify_no_dispatch();
	if (c < 0) {
	    if (dl_Win)
	      ShowErrorReq("Read %s: %s.", local, strerror(errno));
	    errormsg = 1;
	}
	if (d < 0) {
	    if (errno == EINTR) {
		struct IntuiMessage *imsg;
		if (dl_Win) {
		    WaitPort(dl_Win->UserPort);
		    while(imsg=GT_GetIMsg(dl_Win->UserPort)) {GT_ReplyIMsg(imsg);}
		}
#ifndef AS225
		SocketBaseTags(SBTM_SETVAL(SBTC_BREAKMASK),SIGBREAKF_CTRL_C,TAG_END);
#endif
		goto abort;
	    }
	    ShowErrorReq(GetAmiFTPString(Str_RemoteWriteFailed));
	    errormsg = 1;
	    goto abort;
a419 1

d421 3
a423 6
	bytes = 0;
	while ((c = getc(fin)) != EOF) {
	    if (abort_transfer) {
		goto abort;
	    }
	    if (c == '\n') {
d431 1
a431 1
		(void) putc('\r', dout);
d438 1
a438 1
	    (void) putc(c, dout);
d441 2
a442 6
	    if (bytes >= 1024) {
		/* change image */
		bytes = 0;
	    }
	    if (abort_transfer) {
		goto abort;
d445 4
a448 12
	if (ferror(fin)) {
	    errormsg = 1;
	    if (dl_Win)
	      ShowErrorReq("%s: %s.", local, strerror(errno));
	}
#ifdef SOCKIO
	if (0) {
#else
	if (ferror(dout)) {
#endif
	    if (errno != EPIPE){}
//	      perror("netout");
d452 2
a453 3

    if (closefunc != NULL)
      (*closefunc)(fin);
d463 2
a464 2
    (void) fclose(dout);
    dout = NULL;
d466 1
a466 1
    (void) getreply(0);
a468 1
    *aborted=1;
d470 1
a470 1
	code = -1;
d473 1
a473 1
    if (data >= 0) {
d478 1
a478 1
	s_close(data);
d482 1
a482 1
	(void) close(data);
d484 1
a484 1
	data = -1;
d488 2
a489 2
	(void) fclose(dout);
	dout = NULL;
d492 5
a496 7
    (void) getreply(0);
    code = -1;
    if (closefunc != NULL && fin != NULL)
      (*closefunc)(fin);
    if (!errormsg){/* aborted */};

    return (TRSF_ABORTED);
d499 1
a499 2
int recvrequest(char *cmd, char *local, char *remote,
	char *lmode, int size,BOOL *aborted)
a500 1
#ifdef AMIGAIO
a501 3
#else
    FILE *fout = NULL;
#endif
a506 1
    int (*closefunc)();
d510 1
a510 3
    long d,bytes_transferred;
    off_t lseek();
    char	*ftperr;
a513 2
//    if (DEBUG)
//      kprintf("Ping 1 cmd=%lx (%s) local=%lx (%s) remote=%lx (%s) lmode=%lx (%s)\n",cmd,cmd?cmd:"",local,local?local:"",remote,remote?remote:"",lmode,lmode?lmode:"");
a514 1
    closefunc = NULL;
a516 2
//    if (DEBUG)
//      kprintf("Ping 2\n");
a520 2
//    if (DEBUG)
//      kprintf("Ping 3\n");
d527 1
a527 3
	    sprintf(scratch, GetAmiFTPString(Str_GetFailed), remote);
	    ftperr = ftp_error(' ', scratch);
	    ShowErrorReq("%s",scratch);
a530 2
//    if (DEBUG)
//      kprintf("Ping 41\n");
a537 2
//    if (DEBUG)
//      kprintf("Ping 5\n");
d568 6
a573 17
#ifdef AMIGAIO
	ASyncFH=OpenAsync(local,MODE_WRITE,8192);
	if (!ASyncFH) {
	    ShowErrorReq(GetAmiFTPString(Str_LocalfileError), local);
	    errormsg=1;
	    goto abort;
	}
	closefunc = CloseAsync;
#else
	fout = fopen(local, lmode);	
	if (fout == NULL) {
	    ShowErrorReq("Error opening %s:\n%s.", local, strerror(errno));
	    errormsg = 1;
	    goto abort;
	}
	closefunc = fclose;
#endif
d575 1
a575 2
//    if (DEBUG)
//      kprintf("Ping 7\n");
a576 3
//    if (DEBUG)
//      kprintf("Ping 8\n");
    GetSysTime(&starttime);
a580 2
//    if (DEBUG)
//      kprintf("Ping 9\n");
a585 6
	    if (abort_transfer) {
		goto abort;
	    }
//    if (DEBUG)
//      kprintf("Ping 10\n");
#ifdef AMIGAIO
d588 1
a588 4
#else
	    if ((d = write(fileno(fout), transfer_buf, c)) <= 0)
	      break;
#endif
a597 3
	    if (abort_transfer) {
		goto abort;
	    }
a598 3
//    if (DEBUG)
//      kprintf("Ping 11\n");

d611 2
a612 2
		*aborted=TRUE;
	      goto abort;
d622 1
a637 3
	    if (abort_transfer) {
		goto abort;
	    }
a646 1
#ifdef AMIGAIO
a647 5
#else
		    if (ferror(fout))
		      goto break2;
		    (void) putc('\r', fout);
#endif
a649 1
#ifdef AMIGAIO
a650 3
#else
	    (void) putc(c, fout);
#endif
d662 1
a662 4
	    if (abort_transfer) {
		goto abort;
	    }
	  contin2:		/* null */;
d672 1
a672 3
#ifdef SOCKIO
	if (0) {
#else
a673 1
#endif
a678 7
#ifndef AMIGAIO
	if (ferror(fout)) {
	    char bf[256];
	    errormsg = 1;
	    sprintf(bf,"%s: %s.", local,strerror(errno));
	    ShowErrorReq(bf);
	}
d682 2
a683 6
    if (closefunc != NULL)
#ifdef AMIGAIO
      (*closefunc)(ASyncFH);
#else
      (*closefunc)(fout);
#endif
d728 2
a729 7
#ifdef AMIGAIO
    if (closefunc!=NULL && ASyncFH!=NULL)
      (*closefunc)(ASyncFH);
#else
    if (closefunc != NULL && fout != NULL)
      (*closefunc)(fout);
#endif
a735 2
//    if (!errormsg)
//      printf("Receive of %s aborted.", remote);
a949 3
		if (verbose) {
		    printf("421 Service not available, remote server has closed connection\n");
		}
a1218 2
    char *gunique();
    off_t lseek();
d1333 1
@


0.347
log
@Yet another change to make it work with as225
@
text
@d146 1
a146 1
	ftperr = ftp_error(' ', "Service not available.");
d217 1
a217 1
	ftperr = ftp_error(' ', "Connect failed.");
d223 1
a223 1
	ftperr = ftp_error(' ', "Connect failed. Login unknown.");
d227 1
a227 1
	PrintConnectStatus("Service not available.");
d250 1
a250 1
	      ftperr = ftp_error(' ', "Connect failed.");
d367 1
a367 1
	    sprintf(scratch, "Put %s failed.", remote);
d439 1
a439 1
	    ShowErrorReq("Write failed (remote file system full?).");
d586 1
a586 1
	    sprintf(scratch, "Get %s failed.", remote);
d595 1
a595 1
	    ShowErrorReq("Get %s failed.",cmd);
d636 1
a636 1
	    ShowErrorReq("Error opening %s:\n%s.", local, "Error");
d707 1
a707 1
		Printf("Got interrupt\n");
d717 1
a717 1
		ShowErrorReq("Write failed: %s",
@


0.345
log
@Upload via ARexx now works
Entering a remotedir in stringgadget results in re-reading it
@
text
@d410 1
d412 3
d684 1
d686 3
d765 1
d767 3
@


0.336
log
@Added AS225-support (via #ifdefs)
Using GetSysTime() instead of time() in transferroutines
@
text
@d334 1
d369 2
a370 1
	    ShowErrorReq(ftperr);
d409 2
a410 1
		  UpdateDLGads(bytes_transferred,(GetSysTime(&currtime),currtime.tv_sec-starttime.tv_sec));
d419 2
a420 1
	    ShowErrorReq("Read %s: %s.", local, strerror(errno));
a424 1
		extern struct Window *dl_Win;
d475 2
a476 1
	    ShowErrorReq("%s: %s.", local, strerror(errno));
@


0.284
log
@First RCS version.
@
text
@d41 4
d92 1
d95 3
d111 1
d114 3
d180 1
d183 3
d312 1
d314 1
d318 1
d320 1
a320 1
    struct timeval start, stop;
d333 1
a333 2
    int	gettimeofday();
    time_t starttime=time(NULL);
d344 1
d353 1
a353 1

d388 1
a388 1
    (void) gettimeofday(&start, (struct timezone *)0);
d407 1
a407 1
		  UpdateDLGads(bytes_transferred,time(NULL)-starttime);
d427 1
d429 1
d484 1
a484 1
    (void) gettimeofday(&stop, (struct timezone *)0);
d488 1
d490 3
a502 1
    (void) gettimeofday(&stop, (struct timezone *)0);
d509 1
d511 3
a552 2
    struct timeval start, stop;
    struct stat st;
d556 2
a557 2
    int	gettimeofday();
    time_t starttime=time(NULL);
a645 2

    (void) gettimeofday(&start, (struct timezone *)0);
d648 1
d676 1
a676 1
	    UpdateDLGads(bytes_transferred,time(NULL)-starttime);
d692 1
d694 1
d753 1
a753 1
		UpdateDLGads(bytes_transferred,time(NULL)-starttime);
a793 1
    (void) gettimeofday(&stop, (struct timezone *)0);
d795 1
d797 3
a813 1
    (void) gettimeofday(&stop, (struct timezone *)0);
d827 1
d830 3
d873 1
d876 3
d938 6
a943 1
    CloseSocket(data), data = -1;
d970 1
d973 3
d982 1
d985 3
d1133 1
a1133 1

d1136 4
d1228 1
d1230 3
d1237 1
d1239 3
d1399 1
d1401 3
@
