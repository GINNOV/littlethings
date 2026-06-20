/*
 *  This file is part of ixemul-dice-sas for the Amiga
 *  Copyright (C) 1994 Blaz Zupan
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Library General Public
 *  License as published by the Free Software Foundation; either
 *  version 2 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Library General Public License for more details.
 *
 *  You should have received a copy of the GNU Library General Public
 *  License along with this library; if not, write to the Free
 *  Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

/*
 * ixstartup.c
 *
 * Hacked together from original GCC startup code.
 * This is a generic ixemul.library startup routine
 * for SAS and Dice. This opens ixemul.library, parses
 * the command line and executes main().
 */

#include <exec/libraries.h>
#include <dos/dosextens.h>
#include <proto/exec.h>
#include <proto/intuition.h>
#include <sys/syscall.h>

/* Set the current revision number. Version control is automatically done by
 * OpenLibrary(), I just have to check the revision number.
 */
#define IXEMUL_VERSION 39
#define IXEMUL_REVISION 45
#define STRING_IXEMUL_VERSION "39"
#define STRING_IXEMUL_REVISION "45"

static int start_stdio (int, char **, char **);
static int __request_msg (const char *msg, const char *button);
#ifdef NO_TRAP_CODE
static struct Library *OpenIXEmul (void);
#endif

struct ExecBase *SysBase;
struct DosLibrary *DOSBase;
struct Library *ixemulbase;

int expand_cmd_line = 1;	/* expand wildcards ? */
char *default_wb_window = "CON:10/10/320/80/Output/AUTO/WAIT/CLOSE";
				/* Default Workbench output window name */
int errno;			/* error results from the library come in here */
char **environ;			/* this is a default for programs not started via exec_entry */
char *_ctype_;			/* we use a pointer into the library, this is static anyway */
int sys_nerr;			/* number of system error codes */
struct __sFILE **__sF;

extern int ix_startup (char *, int, int, char *, int (*)(), int *);
extern void ix_get_vars2 (int, char **, int *, struct ExecBase **, struct DosLibrary **, struct __sFILE ***, char ***);

int __asm __saveds
ENTRY (register __a0 char *aline, register __d0 int alen)
{
  SysBase = *((struct ExecBase **) 4L);
#ifdef NO_TRAP_CODE
  ixemulbase = OpenIXEmul ();
#else /* NO_TRAP_CODE */
  ixemulbase = OpenLibrary ("ixemul.library", IXEMUL_VERSION);
#endif /* NO_TRAP_CODE */
  if (ixemulbase)
  {
    int res;

    /* Just warn, in case the user tries to run program which might require
       * more functions than are currently available under this revision.
     */

    if (ixemulbase->lib_Version == IXEMUL_VERSION &&
	ixemulbase->lib_Revision < IXEMUL_REVISION)
      __request_msg ("ixemul.library warning: needed revision "
		     STRING_IXEMUL_REVISION, "Continue");

    res = ix_startup (aline, alen,
		   expand_cmd_line, default_wb_window, start_stdio, &errno);

    CloseLibrary (ixemulbase);

    return res;
  }
  else
  {
    struct Process *me;

    __request_msg ("Need at least version " STRING_IXEMUL_VERSION
		   " of ixemul.library.", "Abort");

    /* Quickly deal with the WB startup message, as the library couldn't do
       * this for us. Nothing at all is done that isn't necessary to just shutup
       * workbench.
     */
    me = (struct Process *) FindTask (NULL);
    if (!me->pr_CLI)
    {
      Forbid ();
      ReplyMsg ((WaitPort (&me->pr_MsgPort), GetMsg (&me->pr_MsgPort)));
    }
    return 20;
  }
}

#ifdef NO_TRAP_CODE
/*
 * When trying to debug a program that uses ixemul.library
 * you get a nasty requester when trying to singlestep through the
 * program with a debugger (like MonAm or CPR). This is of course
 * the library's fault because it sets a new tc_TrapCode in the task
 * structure. This is a kludgy workaround. Just don't single step
 * into this function and everything will be allright. This function
 * only opens ixemul.library and after that it restores the original
 * tc_TrapCode.
 */

#include <exec/tasks.h>
static struct Library *
OpenIXEmul (void)
{
  struct Library *lib;
  struct Task *task = FindTask (NULL);
  APTR trapCode;

  trapCode = task->tc_TrapCode;
  lib = OpenLibrary ("ixemul.library", IXEMUL_VERSION);
  task->tc_TrapCode = trapCode;
  return lib;
}
#endif /* NO_TRAP_CODE */

static int
start_stdio (int argc, char **argv, char **env)
{
  ix_get_vars2 (6, &_ctype_, &sys_nerr, &SysBase, &DOSBase, &__sF, &environ);
  return main (argc, argv, env);
}

/*
 * This once was req.c by Markus Wandel. It doesn't look too much like the
 * original version though... Well, it was PD, I used it, so here is his
 * original disclaimer:
 *
 * req.c - by Markus Wandel - 1990
 * Placed in the public domain 7 Oct 1990
 * Please have the courtesy to give credit if you use this code
 * in any program.
 *
 */

static int
__request_msg (const char *msg, const char *button)
{
  struct IntuiText line, righttext;
  struct IntuitionBase *IntuitionBase;
  int result;

  /* we (re)open intuition, because that way we don't depend on arp.library
   * being available for us to open intuibase */

  if (IntuitionBase = (struct IntuitionBase *) OpenLibrary ("intuition.library", 0))
  {
    line.FrontPen = AUTOFRONTPEN;
    line.BackPen = AUTOBACKPEN;
    line.DrawMode = AUTODRAWMODE;
    line.ITextFont = AUTOITEXTFONT;
    line.NextText = 0;
    CopyMem (&line, &righttext, sizeof (line));
    righttext.LeftEdge = AUTOLEFTEDGE;
    righttext.TopEdge = AUTOTOPEDGE;
    line.LeftEdge = 15;
    line.TopEdge = 5;

    line.IText = (UBYTE *) msg;
    righttext.IText = (UBYTE *) button;
    result = AutoRequest (0L, &line, 0L, &righttext, 0L, 0L, 320L, 72L);
    CloseLibrary ((struct Library *) IntuitionBase);
    return result;
  }
  return -1;
}
