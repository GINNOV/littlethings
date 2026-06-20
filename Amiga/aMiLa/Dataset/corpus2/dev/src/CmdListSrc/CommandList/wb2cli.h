/*
 * $Id: WB2CLI.h,v 1.51 1993/07/31 23:12:44 Gael Exp Gael $
 *
 * $Log: WB2CLI.h,v $
 * Revision 1.51  1993/07/31  23:12:44  Gael
 * *** empty log message ***
 *
 * Revision 1.7  92/02/11  12:24:34  mks
 * Slight wording change
 *
 * Revision 1.6  92/02/11  12:14:19  mks
 * Minor doc change
 *
 * Revision 1.5  91/12/30  18:22:28  mks
 * Cleaned up the docs a bit...
 *
 * Revision 1.4  91/07/24  20:03:29  mks
 * Autodoc cleanup
 *
 * Revision 1.2  91/07/24  18:58:42  mks
 * Forgot to fix the example to use default stack.
 *
 * Revision 1.1  91/07/24  18:57:46  mks
 * Added the defaultstack to the prototype and documentation.
 *
 * Revision 1.0  91/07/24  17:03:24  mks
 * Initial revision
 *
 */

/*
 * WB2CLI - By Michael Sinz
 *             Operating System Development Group
 *             Commodore-Amiga, Inc.
 *
 * This is the magic code needed to take a started workbench process
 * and convert it into a CLI process with a copy of the workbench path.
 *
 * After that point, the process will look much like a background CLI.
 */

/*
******* WB2CLI ***************************************************************
*
*   NAME
*       WB2CLI                                                          (V37)
*
*   SYNOPSIS
*       status = WB2CLI(wbmsg,defaultstack,dosbase)
*         D0             A0    D0           A1
*
*       LONG WB2CLI(struct WBStartup *,ULONG,struct DosLibrary *)
*
*   FUNCTION
*       This function will take a workbench started application and change
*       it into a CLI-like application.  This will include a path as copied
*       from the Workbench.  The CLI default stack is used to pick the stack
*       size for the processes run as CLIs.  (This is in SYNC mode)
*
*       You would pass in the Workbench message pointer and a pointer
*       to an open dos.library.  (The DosLibrary pointer is used to call
*       dos.library without the need of globals.)
*
*       This *REQUIRES* V37 dos.library and exec.library.
*
*   NOTES
*       Assembly language programmers:  This routine is _WB2CLI
*
*       If you call WB2CLI() and are already a CLI, it will return as if
*       it worked even though it did nothing.  (After all, you were a CLI)
*       For this reason, you do not need to check if you are a CLI
*       started program before you call the function.
*
*       One word of interest:  Once you call this function, the pr_CLI
*       field of your process will *NOT* be NULL.  This is by definition
*       of what this program is trying to do, which is make you like a CLI.
*       You will, however, still need to reply the workbench startup message
*       that you passed to the WB2CLI routine.
*
*       You are, however, responsible for setting up any input or output
*       file handles that you may needed.  Being workbench started means
*       that you have no standard-in or standard-out.  (Just as before)
*       (In other words, this function does not magically give you any
*       I/O as you may already have done so or need a special form of it)
*       These handles are pr_CIS, pr_COS, etc.  For example, many DOS
*       calls may rely on these being valid.  RunCommand() under V37
*       is one such creature.
*
*   EXAMPLE
*       void main(int argc, char *argv[])
*       {
*       struct  DosLibrary  *DOSBase;
*
*           \* We need V37 to do this *\
*           if (DOSBase=(struct DosLibrary *)OpenLibrary("dos.library",37L))
*           {
*               \* Cute trick:  If you are a CLI, WB2CLI is a NO-OP *\
*               \* Thus, you normally don't need to check *\
*               \* NOTE:  Most of the time you will ignore the error *\
*               if (WB2CLI((struct WBStartup *)argv,4000,DOSBase))
*               {
*                   \* We now are workbench started CLI *\
*                   \* (Complete with path *\
*               }
*               else
*               {
*                   \* We did not become a CLI but we still *\
*                   \* can run.  Just not as a CLI *\
*               }
*
*               \* More stuff *\
*
*               CloseLibrary((struct Library *)DOSBase);
*           }
*       }
*
*   INPUTS
*       wbmsg -- The Workbench message that you were started with.  If NULL
*                this routine will do nothing...
*
*       defaultstack -- The size of the CLI default stack in bytes.
*                       You *SHOULD* supply a value of at least 4000.
*
*       dosbase -- Pointer to dos.library (must be open)
*
*   RESULTS
*       A magically transformed process that has a CLI structure added.
*
*       status -- Returns TRUE if it worked.  Usually can be ignored
*                 as your program will continue to work as if you did not
*                 call this function.
*
*   SEE ALSO
*       None
*
*   BUGS
*
******************************************************************************
*/

#include        <dos/dosextens.h>
#include        <workbench/startup.h>

__asm LONG WB2CLI(register __A0 struct WBStartup *,register __D0 ULONG,register __A1 struct DosLibrary *);
