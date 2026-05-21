head	1.815;
access;
symbols;
locks
	lilja:1.815; strict;
comment	@ * @;


1.815
date	96.12.14.12.13.03;	author lilja;	state Exp;
branches;
next	1.625;

1.625
date	96.07.04.17.50.58;	author lilja;	state Exp;
branches;
next	1.587;

1.587
date	96.06.14.13.23.25;	author lilja;	state Exp;
branches;
next	1.541;

1.541
date	96.06.04.21.43.36;	author lilja;	state Exp;
branches;
next	1.531;

1.531
date	96.05.28.00.17.52;	author lilja;	state Exp;
branches;
next	1.200;

1.200
date	96.02.20.00.19.28;	author lilja;	state Exp;
branches;
next	0.814;

0.814
date	95.10.15.15.22.12;	author lilja;	state Exp;
branches;
next	0.723;

0.723
date	95.09.29.16.48.36;	author lilja;	state Exp;
branches;
next	0.486;

0.486
date	95.08.26.11.48.42;	author lilja;	state Exp;
branches;
next	0.413;

0.413
date	95.07.23.13.03.53;	author lilja;	state Exp;
branches;
next	0.388;

0.388
date	95.07.16.13.14.48;	author lilja;	state Exp;
branches;
next	0.284;

0.284
date	95.06.06.21.42.35;	author lilja;	state Exp;
branches;
next	;


desc
@ftphookup/ftplogin functions for AmiFTP
@


1.815
log
@Fixed the proxy-port settings.
Replaced % with @@ since the proxy actually seems to work with other
ftpproxies.
Fixed the Height/Width save-problem.
@
text
@/* RCS Id: $Id: dofuncs.c 1.625 1996/07/04 17:50:58 lilja Exp $
   Locked version: $Revision: 1.625 $
*/

#include "AmiFTP.h"

int doconnect(struct SiteNode *sn)
{
    char	*password=NULL;
    char        *account=NULL;
    char        *login;
    char        *ftphost;
    int		rval;
    int         port=sn->sn_Port;

    if (!sn->sn_SiteAddress)
      return CONN_ERROR;

    login = sn->sn_LoginName;
    password=sn->sn_Password;
    if (login == NULL || sn->sn_Anonymous) {
	if (MainPrefs.mp_AnonymousPW)
	  password=MainPrefs.mp_AnonymousPW;
	else
	  password=defaultanonymouspw;
	login = "anonymous";
    }
    if (connected)
      quit_ftp();

    ftphost = parse_hostname(sn->sn_SiteAddress, &port);

    return openhost(ftphost, login, password, account, port, sn->sn_Proxy);
}

int openhost(char *ftphost, char *login, char *password,
	char *account, short port, int useproxy)
{
    char	*atsign;
    char	*auto_cd;
    char buf[100];
    int		rval = 0;

    timedout = 0;
    rval = ftp_hookup(useproxy?MainPrefs.mp_ProxyServer:ftphost, useproxy?MainPrefs.mp_ProxyPort:port);
    if (rval!=CONN_OK)
      return rval;

    if (useproxy)
	sprintf(buf,"%s@@%s",login,ftphost);
    if ((rval = ftp_login(useproxy?buf:login, password, account)) == 0) {
	return CONN_ERROR;
    }
    connected = 1;
    which_up_cmd = -1;

    /*
     * ftphost is not the name of outside machines.
     * Need to extract outside name from login
     */
    if ((atsign = index(login, '@@')) != NULL)
      sprintf(CurrentState.CurrentSite, "%s",atsign + 1);
    else
      sprintf(CurrentState.CurrentSite, "%s",ftphost);

    UpdateSiteName(CurrentState.CurrentSite);
    auto_cd = (char *)".";
    if (*auto_cd == '\0' || change_remote_dir(auto_cd, 0))
      change_remote_dir(".", 0);

    remote_os_type = REMOTE_OS_UNIX;
    other_dir_pattern = NULL;

    return CONN_OK;
}
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
/* RCS Id: $Id: dofuncs.c 1.587 1996/06/14 13:23:25 lilja Exp lilja $
   Locked version: $Revision: 1.587 $
d50 1
a50 1
	sprintf(buf,"%s%%%s",login,ftphost);
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
d5 1
a5 1
#include "ftpwin.h"
@


1.541
log
@Fixed bug in UnlockWindow().
@
text
@d1 4
@


1.531
log
@Lots of stuff
@
text
@d3 1
a3 1
int doconnect(struct SiteNode *sn)//char *ftphost,int rport,char *login, int useproxy)
d11 3
@


1.200
log
@GETATTR-hit fixed.
@
text
@d26 1
a26 6
    rval = openhost(ftphost, login, password, account, port, sn->sn_Proxy);
    if (rval != 0)
      return 0;
    else
      return 1;

a37 1
//    Printf("Connecting to %s\n",useproxy?MainPrefs.mp_ProxyServer:ftphost);
d39 3
a41 13
    switch (rval) {
      case 0:			/* error */
	rval = 2;
	goto out;
	break;
      case 1:
	/* couldn't resolve hostname: try proxy */
	goto out;
	break;
      default:
	rval = 0;
	break;
    }
d45 1
a45 2
	rval = 2;
	goto out;
a57 1
//    printf("Connected to: %s\n",scratch);
d67 1
a67 3
    return 0;
  out:
    return rval;
@


0.814
log
@Added default download-dir.
@
text
@d28 1
a28 1
      return (0);
d30 1
a30 1
      return(1);
d85 1
a85 1
    return (0);
d87 1
a87 1
    return (rval);
@


0.723
log
@AmiFTP adds .i if the ARexx-port is present.
@
text
@a4 1
    char	*proxyhost;
a8 1
    char	crap[50];
@


0.486
log
@Recursive getting of directory trees implemented.
Password/Anonymous-gadget added in SiteConfiguration Window
Layout fixes.
@
text
@a22 1

@


0.413
log
@Added password-gadget.
@
text
@d16 1
a16 1
    if (login == NULL) {
@


0.388
log
@send/recv-request re-written
Layoutbug in connect-window fixed
@
text
@d28 1
a28 1
Printf("%s\n",ftphost);
@


0.284
log
@First RCS version.
@
text
@d28 1
@
