/* Running commands on Amiga
Copyright (C) 1995, 1996 Free Software Foundation, Inc.
This file is part of GNU Make.

GNU Make is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

GNU Make is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with GNU Make; see the file COPYING.  If not, write to
the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.  */

#include "make.h"
#include "variable.h"
#include "amiga.h"
#include <assert.h>
#include <exec/memory.h>
#include <dos/dostags.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/icon.h>

#include <workbench/startup.h>

#include "wbpath.h"

#define PATH_SIZE       1024

char *variable_buffer_output();

extern void KPrintF(char *fmt,...);

static struct WBStartup *wbmsg = NULL;
static const char Amiga_version[] = "$VER: Make 3.76.1 (24.09.97)\n"
		    "Amiga Port by\n"
		    "A. Digulla (digulla@home.lake.de) and\n"
		    "St. Ruppert (ruppert@amigaworld.com)\n";

/* SAS/C startup configuration */
long __stack = 20000;
char __stdiowin[] = "CON:////GNU make V3.76.1/AUTOOPEN/CLOSE/WAIT";

int
MyExecute (argv)
char ** argv;
{
    char * buffer, * ptr;
    char ** aptr;
    int len = 0;
    int status;

    for (aptr=argv; *aptr; aptr++)
    {
	len += strlen (*aptr) + 4;
    }

    buffer = xmalloc (len);

    ptr = buffer;

    for (aptr=argv; *aptr; aptr++)
    {
	if (((*aptr)[0] == ';' && !(*aptr)[1]))
	{
	    *ptr ++ = '"';
	    strcpy (ptr, *aptr);
	    ptr += strlen (ptr);
	    *ptr ++ = '"';
	}
	else if ((*aptr)[0] == '@' && (*aptr)[1] == '@' && !(*aptr)[2])
	{
	    *ptr ++ = '\n';
	    continue;
	}
	else
	{
	    strcpy (ptr, *aptr);
	    ptr += strlen (ptr);
	}
	*ptr ++ = ' ';
	*ptr = 0;
    }

    ptr[-1] = '\n';

    if(wbmsg != NULL)
    {
	BPTR path = CloneWorkbenchPath(wbmsg);

	status = SystemTags(buffer,
			    SYS_UserShell, TRUE,
			    NP_Path, path,
			    TAG_DONE);

	if(status == -1)
	    FreeWorkbenchPath(path); 
    } else
	status = SystemTags(buffer,
			    SYS_UserShell, TRUE,
			    TAG_END);

    free(buffer);

    if (SetSignal(0L,0L) & SIGBREAKF_CTRL_C)
	status = 20;

    /* Warnings don't count */
    if (status == 5)
	status = 0;

    return status;
}

char *
wildcard_expansion (wc, o)
char * wc, * o;
{
    struct AnchorPath * apath;

	
    apath = (struct AnchorPath *) xmalloc (sizeof (struct AnchorPath) + PATH_SIZE);
    memset(apath,0,sizeof (struct AnchorPath) + PATH_SIZE);

    {
	apath->ap_Strlen = PATH_SIZE;

	if (MatchFirst (wc, apath) == 0)
	{
	    do
	    {
		o = variable_buffer_output (o, apath->ap_Buf,
			strlen (apath->ap_Buf));
		o = variable_buffer_output (o, " ",1);
	    } while (MatchNext (apath) == 0);
	}

	MatchEnd (apath);
    }
    free(apath);

    return o;
}

void
amiga_get_global_env(void)
{
    BPTR env, old;
    struct FileInfoBlock *fib;

    if((fib = AllocDosObject(DOS_FIB,NULL)) != NULL)
    {
	env = Lock ("ENV:", ACCESS_READ);
	if (env)
	{
	    old = CurrentDir (DupLock(env));
	    Examine (env, fib);

	    while (ExNext (env, fib))
	    {
		if (fib->fib_DirEntryType < 0) /* File */
		{
		    /* Define an empty variable. It will be filled in
			variable_lookup(). Makes startup quite a bit
			faster. */
			define_variable (fib->fib_FileName,
			    strlen (fib->fib_FileName),
			"", o_env, 1)->export = v_export;
		}
	    }
	    UnLock (env);
	    UnLock(CurrentDir(old));
	}
	FreeDosObject(DOS_FIB,fib);
    }
}

void 
amiga_set_makelevel(unsigned int makelevel)
{
    char buffer[20];
    int len;

    len = GetVar ("MAKELEVEL", buffer, sizeof (buffer), GVF_LOCAL_ONLY);

    if (len != -1)
    {
	sprintf (buffer, "%u", makelevel);
	SetVar ("MAKELEVEL", buffer, -1, GVF_LOCAL_ONLY);
    }
}

void
amiga_startup(int *argc,char ***argv)
{
    if(*argc == 0)
    {
	wbmsg = (struct WBStartup *) *argv;

	if(wbmsg->sm_NumArgs > 1)
	{       
	    char **myargv;
	    char *namebuf;
	    char *dirbuf;

	    struct DiskObject *dobj;
	    BPTR chdir;
	    BPTR olddir = NULL;
	    int ac = 2;

	    namebuf = xmalloc(PATH_SIZE * 2);
	    dirbuf  = namebuf + PATH_SIZE;
	    if((chdir   = DupLock(wbmsg->sm_ArgList[1].wa_Lock)) != NULL)
		olddir = CurrentDir(chdir);

	    if((dobj = GetDiskObjectNew(wbmsg->sm_ArgList[1].wa_Name)) != NULL)
	    {
		char **tt = dobj->do_ToolTypes;

		while(*tt != NULL)
		{
		    ac++;
		    tt++;
		}
	    }

	    myargv  = (char **) xmalloc((ac+1) * sizeof(char *));

	    /* add any tooltype */
	    if(dobj != NULL)
	    {
		char **tt = dobj->do_ToolTypes;
		int ac = 2;

		while(*tt != NULL)
		{
		    myargv[ac] = xmalloc(strlen(*tt)+1);
		    strcpy(myargv[ac],*tt);
		    ac++;
		    tt++;
		}
		FreeDiskObject(dobj);
	    }
	    if(olddir != NULL)
		CurrentDir(olddir);

	    /* argv[0] have to contain the program name */
	    myargv[0] = xmalloc(strlen(wbmsg->sm_ArgList[0].wa_Name)+1);
	    strcpy(myargv[0],wbmsg->sm_ArgList[0].wa_Name);

	    if(chdir != NULL)
	    {
	       /* now change to the working directory */
	       strcpy(dirbuf,"-C");
	       if(NameFromLock(chdir,&dirbuf[2],PATH_SIZE-2))
	       {
		   myargv[1] = xmalloc(strlen(dirbuf)+1);
		   strcpy(myargv[1],dirbuf);
	       }
	       UnLock(chdir);
	    } else
	       ac--;

	    /* terminate argument vector */
	    myargv[ac] = NULL;

	    *argv = myargv;
	    *argc = ac;

	    /* free the tempory buffer */
	    free(namebuf);

#ifdef DEBUG
	    {
	       int i;

	       for(i = 0; i < ac ; i++)
		   KPrintF("myargv[%ld] = \"%s\"\n",i,myargv[i]);
	    }
#endif
	}
    }
}

#ifdef HAVE_GETLOADAVG
#include <proto/SysInfo.h>
#include <libraries/SysInfo.h>
int
getloadavg(double loadavg[],int nelem)
{
    struct Library *SysInfoBase;
    int rc = -1;

    if((SysInfoBase = OpenLibrary(SYSINFONAME,SYSINFOVERSION)) != NULL)
    {
	struct SysInfo *sinfo;

	if((sinfo = InitSysInfo()) != NULL)
	{
	    struct SI_LoadAverage load;

	    if(sinfo->loadavg_type != LOADAVG_NONE)
	    {
		GetLoadAverage(sinfo,&load);

		rc = 0;
		switch(sinfo->loadavg_type)
		{
		case LOADAVG_FIXEDPNT:
		    if(nelem >= 0)
		    {
			loadavg[0] = (double) load.lavg_fixed.load1 / (double) sinfo->fscale;
			rc++;
		    }
		    if(nelem >= 1)
		    {
			loadavg[1] = (double) load.lavg_fixed.load2 / (double) sinfo->fscale;
			rc++;
		    }
		    if(nelem >= 2)
		    {
			loadavg[2] = (double) load.lavg_fixed.load3 / (double) sinfo->fscale;
			rc++;
		    }
		    break;
		default:
		    rc = -1;
		}
	    }

	    FreeSysInfo(sinfo);
	}
	CloseLibrary(SysInfoBase);
    }

    return rc;
}
#endif
