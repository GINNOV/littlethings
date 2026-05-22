/* $Revision Header built by KCommodity by Kai Iske *** (do not edit) ************
**
** © Copyright by H.P.G
**
** File             : Aztec:Source/ZipWd/ZipWd.c
** Created on       : Sunday, 02-Aug-92 15:47:24
** Created by       : Hans-Peter Guenther
** Current revision : V0.01
**
**
** Purpose
** -------
**     ZipWd is a simple cli tool that zips the current active window.
**     Just a little OS 2.0 example.
**
** Revision V0.41
** --------------
**     --- Initial release ---
**
*********************************************************************************/
#define REVISION "0.41"		/* This is the revision number */
#define REVDATE  "02-Aug-92"		/* This is the revision date */

char *VERSION="$VER: ZipWd 0.50 (3.8.92) by H.P.G PublicDomain";

/* this version string can be read by the Version program */

/* Options for MANX Aztec 5.xx  */
/* COMPILE: cc ZipWd.c          */
/* LINK:    ln ZipWd.o -lc      */

#include <exec/types.h>
#include <intuition/intuition.h>
#include <intuition/intuitionbase.h>
#include <functions.h>

#define IB IntuitionBase
#define PUTS(a) Write(Output(),a,strlen(a))

static char *ErrorTxt = "You need at minimum OS 2.xx WBench Version 37.xx\n";

struct IB *IB;

void _main(void)
{
struct Window *Wd;
ULONG ilock;

if (!(IB=(struct IB *)OpenLibrary("intuition.library",36L)))
    {
    PUTS(ErrorTxt);  /* Checks for the correct version  */
    Exit(20);        /* if fail , OS 1.3 or 1.2 */
    }

ilock=LockIBase( 0L );
/* disables changes of the intuition structures before reading */

if (Wd=IB->ActiveWindow)    /* get the active window */
    ZipWindow(Wd);

UnlockIBase(ilock);
CloseLibrary((struct Library *)IB);
Exit(0);
}
