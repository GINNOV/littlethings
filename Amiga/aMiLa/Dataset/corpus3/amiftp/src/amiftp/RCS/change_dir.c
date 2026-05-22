head	1.625;
access;
symbols;
locks
	lilja:1.625; strict;
comment	@ * @;


1.625
date	96.07.04.17.50.58;	author lilja;	state Exp;
branches;
next	1.587;

1.587
date	96.06.14.13.23.25;	author lilja;	state Exp;
branches;
next	1.200;

1.200
date	96.02.20.00.19.28;	author lilja;	state Exp;
branches;
next	0.814;

0.814
date	95.10.15.15.22.12;	author lilja;	state Exp;
branches;
next	0.757;

0.757
date	95.09.30.16.00.45;	author lilja;	state Exp;
branches;
next	0.371;

0.371
date	95.06.30.19.18.41;	author lilja;	state Exp;
branches;
next	0.336;

0.336
date	95.06.15.11.53.20;	author lilja;	state Exp;
branches;
next	0.303;

0.303
date	95.06.08.15.30.02;	author lilja;	state Exp;
branches;
next	0.284;

0.284
date	95.06.06.21.42.35;	author lilja;	state Exp;
branches;
next	;


desc
@Functions to change remote directory
@


1.625
log
@Cleaned up the code a bit.
Rename ftpwin.h to AmiFTP.h and ftpwin.c to AmiFTP.c.
Created Menu.c and moved all menu-functions there.
@
text
@/* RCS Id: $Id: change_dir.c 1.587 1996/06/14 13:23:25 lilja Exp lilja $
   Locked version: $Revision: 1.587 $
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
a10 2
int dirlastmtime;

d146 1
a146 1
	ShowErrorReq("Delete failed\n");
@


1.200
log
@GETATTR-hit fixed.
@
text
@d1 4
@


0.814
log
@Added default download-dir.
@
text
@d103 1
a103 1
	return (1);
d105 1
a105 1
    return (rval);
d126 1
a126 1
	  return (0);
d133 1
a133 1
	  return (0);
d136 1
a136 1
    return (1);
d145 1
a145 1
	return(0);
d147 1
a147 1
    return(1);
@


0.757
log
@Slightly improved timedout-control.
View handles spaces in filenames now (added a pair of \")
@
text
@a12 2
    struct dirlist *head = NULL;
    int		wasinactive;
@


0.371
log
@Localized source.
@
text
@a99 3
/*    if (rval == 0)
      printf("");*/

d103 4
a106 2
    if (timedout)
      PrintConnectStatus("Command timed out");
@


0.336
log
@Added AS225-support (via #ifdefs)
Using GetSysTime() instead of time() in transferroutines
@
text
@d57 1
a57 1
			"%s: No such file or directory.", dir);
@


0.303
log
@Added delete_remote()
@
text
@d3 1
d5 1
@


0.284
log
@First RCS version.
@
text
@d140 10
@
