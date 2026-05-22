/*
** WbPath.h - clone the Workbench process's command path.
** Copyright © 1994 by Ralph Babel. Permission granted to
** distribute this file in conjunction with »WbPath.o« and
** »PathTest.c« in unmodified form and to use the associated
** object module »WbPath.o«, provided that this file,
** »WbPath.o«, and »PathTest.c« accompany the resulting
** program. All other rights reserved.
*/

#ifndef WBPATH_H
#define WBPATH_H

/*** included files ***/

#ifndef EXEC_EXECBASE_H
#include <exec/execbase.h>
#endif

#ifndef DOS_DOS_H
#include <dos/dos.h>
#endif

#ifndef DOS_DOSEXTENS_H
#include <dos/dosextens.h>
#endif

#ifndef WORKBENCH_STARTUP_H
#include <workbench/startup.h>
#endif

/*

When a program is launched via the »Execute Command ...«
menu item provided by Workbench, Workbench passes the CLI
command path that was active at the time LoadWb was invoked
to the application. Regular Workbench processes, however, do
not operate in a CLI environment, so they cannot inherit the
Workbench path, and new shells spawned by such processes via
SystemTagList() start with an »empty« path (i.e. just »C:«
and the current directory).

The function CloneWorkbenchPath() creates a local copy of
the current Workbench path, usually for the purpose of it
being passed to SystemTagList() or to CreateNewProc() via
the NP_Path tag; the WBStartup parameter passed to
CloneWorkbenchPath() must be valid and non-NULL. The path is
deallocated automatically by the OS upon the termination of
the newly created process; if the CreateNewProc() or
SystemTagList() call fails, however, the cloned path must be
freed explicitly by calling FreeWorkbenchPath().

The actual return value of CloneWorkbenchPath() need/must
not be checked for zero (the Workbench path may be empty
after all), and all possible results may safely be used with
NP_Path or passed to FreeWorkbenchPath(). The result may
also be zero if the Workbench path could not be obtained for
any reason, and the path may be truncated if an error
occurred or if the path was updated via »LoadWb NEWPATH«
while it was being cloned.

These functions may safely be called under all versions of
the Amiga's OS, although prior to 2.0 they usually don't do
a whole lot, and the dos.library functions they are usually
used with did not exist prior to 2.0.

WARNING: Accessing another process's CLI path is an
unsupported operation, and although CloneWorkbenchPath()
tries to take all possible precautions, all bets are off
should the Workbench path become inconsistent while it is
being cloned. (This is not currently the case, though.)

Further information can be found in the Amiga Guru Book on
pages 400 and 571 f. The Amiga Guru Book is available from:

Hirsch & Wolf OHG
Mittelstraße 33
D-56564 Neuwied
Germany
Voice: +49 (2631) 8399-0
Fax:   +49 (2631) 8399-31

Periscope Discs, Tapes, Books
Attn: Cody Lee
1717 West Kirby Avenue
Champaign, IL 61821
USA
Voice: +1 (217) 398 4237
Fax:   +1 (217) 398 4238
E-Mail: <periscope@cei.com>

Someware
27 rue Gabriel Péri
59186 Anor
France
Voice: +33 27596000
Fax:   +33 27595206

*/

/*** macros ***/

#define CloneWorkbenchPath(sm) cloneWorkbenchPath(SysBase, DOSBase, sm)
#define FreeWorkbenchPath(path) freeWorkbenchPath(SysBase, DOSBase, path)

/*** symbol export ***/

BPTR __stdargs cloneWorkbenchPath(struct ExecBase *,
 struct DosLibrary *, struct WBStartup *);
void __stdargs freeWorkbenchPath(struct ExecBase *,
 struct DosLibrary *, BPTR);

#endif /* WBPATH_H */
