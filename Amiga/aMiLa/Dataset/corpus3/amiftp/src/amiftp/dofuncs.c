/* RCS Id: $Id: dofuncs.c 1.815 1996/12/14 12:13:03 lilja Exp lilja $
   Locked version: $Revision: 1.815 $
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
	sprintf(buf,"%s@%s",login,ftphost);
    if ((rval = ftp_login(useproxy?buf:login, password, account)) == 0) {
	return CONN_ERROR;
    }
    connected = 1;
    which_up_cmd = -1;

    /*
     * ftphost is not the name of outside machines.
     * Need to extract outside name from login
     */
    if ((atsign = index(login, '@')) != NULL)
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
