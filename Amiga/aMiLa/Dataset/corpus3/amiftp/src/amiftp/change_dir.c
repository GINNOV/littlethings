/* RCS Id: $Id: change_dir.c 1.625 1996/07/04 17:50:58 lilja Exp $
   Locked version: $Revision: 1.625 $
*/

#include "AmiFTP.h"

#ifndef MAXPATHLEN
#define MAXPATHLEN 1024
#endif

int change_remote_dir(char *s, int force)
{
    char	*ftperr;
    char	crd[MAXPATHLEN + 1];
    char	*dir = NULL;
    int	rval = 0;
    int	pwdfailed = 0;
    char	*quote;

    if (ping_server())
      goto out;

    /* send cd command */
    dir = strdup(s);
    if (dir == NULL)
      goto out;
    if (!strcmp(dir, "..")) {
	if (up_one_level())
	  goto out;
    } else if (strcmp(dir, ".")) {
	extern int code;

	code = -1;
	command("CWD %s", dir);
	/* success */
	/*
	 * 250 CWD command successful.
	 */
	/* failure */
	/*
	 * 550 k: No such file or directory
	 */
	if (code == 550) {
	    ftperr = index(response_line, ':');
	    if (ftperr == NULL) {
		rval = 1;
		goto out;
	    }
	    if (!strncmp(ftperr, ": Not a directory.", 18)) {
//		printf("%s is not a directory.", dir);
		rval = ENOTDIR;
		goto out;
	    }
	    command("CWD %s", dir);
	    if (code == 550) {
		sprintf(scratch,
			GetAmiFTPString(Str_NoSuchDir), dir);
		ftperr = ftp_error(' ', scratch);
		rval = 1;
		goto out;
	    }
	}
    }

    /* set current directory */
    if (command("PWD") == ERROR && code == 500) {
	/* try quote xpwd */
	if (command("XPWD") == ERROR && code == 500) {
//	    printf("pwd and xpwd not recognized.");
	    pwdfailed = 1;
	}
    }
    /* response */
    /*
     * 25[17] "/" is current directory.
     * 257 PWD: "/Print_Output" is current directory.
     *
     * Skip to first double-quote, since they seem to have that.
     */
    crd[0] = '\0';
    if (pwdfailed) {
	force = 1;
    } else if (!strncmp(response_line, "257", 3)) {
	quote = strchr(response_line, '\"');
	if (quote != NULL)
	  sscanf (quote, "\"%[^\"]\"", crd);
    } else if (!strncmp(response_line, "251", 3)) {
	quote = strchr(response_line, '\"');
	if (quote != NULL)
	  sscanf (quote, "\"%[^\"]\"", crd);
    } else {
	PrintConnectStatus("pwd or xpwd returned bad response.");
	force = 1;
    }

    strncpy(CurrentState.CurrentRemoteDir,crd,MAXPATHLEN+1);
    UpdateRemoteDir(CurrentState.CurrentRemoteDir);

  out:
    if (dir)
      free(dir);

    if (timedout) {
/*	PrintConnectStatus("Command timed out");*/
	return 1;
    }
    return rval;
}

int up_one_level(void)
{
    static struct {
	char	*cmd;
	char	*msg;
    } method[] = {
	{ "CDUP", "CDUP failed, trying XCUP" },
	{ "XCUP", "CDUP and XCUP failed, trying 'CD ..'" },
	{ "CWD ..", "CDUP, XCUP, and 'CD ..' failed.  Try manually." },
	{ NULL, NULL }
    };

    if (which_up_cmd != -1) {
	if (command(method[which_up_cmd].cmd) == ERROR &&
	    code >= 500) {
//	    printf(method[which_up_cmd].msg);
	    which_up_cmd = -1;
	} else
	  return 0;
    }
    for (which_up_cmd = 0; method[which_up_cmd].cmd; which_up_cmd++) {
	if (command(method[which_up_cmd].cmd) == ERROR &&
	    code >= 500){}
//	  printf(method[which_up_cmd].msg);
	else
	  return 0;
    }
    which_up_cmd = -1;
    return 1;

}

int delete_remote(char *name, const char *delcmd)
{
    sprintf(scratch,"%s %s",delcmd,name);
    if (command(scratch)==ERROR) {
	ShowErrorReq("Delete failed.\n");
	return 0;
    }
    return 1;
}
