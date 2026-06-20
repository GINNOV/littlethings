//
//  $VER: Ed+ 0.004 (14 Sep 1995)  **
//
//  by Stefan Berendes; © 1995 Dietmar Eilert & Stefan Berendes
//
//  PROGRAMNAME: Ed.c
//
//  FUNCTION: GoldED quickstarter that requires a special AREXX port name
//             this makes it possible to use different configs
//
//  $HISTORY:
//
//  14 Sep 1995 : 000.004 :  FORCE is ignored if no host is specified
//  02 Sep 1995 : 000.003 :  fixed bug in args counting disabling force feature
//  02 Sep 1995 : 000.002 :  interim debug version
//   18 Aug 1995 : 0.01 : initial release, based on original source code
//                        ED 2.4 © 1995 Dietmar Eilert
//
//
//  This is C source code of ED to give you an idea of how to address GoldED
//  from other applications. Feel free to change this code. Dice:
//
//  dcc ed.c sprintf.a -// -proto -mRR -mi -pr -2.0 -o ram:ED


/// "includes"

#include <amiga20/exec/exec.h>
#include <string.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include <amiga20/intuition/intuition.h>
#include <amiga20/dos/dos.h>
#include <amiga20/dos/dosextens.h>
#include <amiga20/dos/rdargs.h>
#include <amiga20/dos/dostags.h>
#include <amiga20/workbench/startup.h>
#include <amiga20/workbench/workbench.h>
#include <amiga20/rexx/errors.h>
#include <amiga20/rexx/rxslib.h>

#include <amiga20/clib/alib_protos.h>
#include <amiga20/clib/dos_protos.h>
#include <amiga20/clib/exec_protos.h>
#include <amiga20/clib/icon_protos.h>
#include <amiga20/clib/intuition_protos.h>
#include <amiga20/clib/utility_protos.h>
#include <amiga20/clib/rexxsyslib_protos.h>
#include <amiga20/clib/wb_protos.h>

#ifdef PRAGMAS

#include "Pragmas/exec.h"
#include "Pragmas/disk.h"
#include "Pragmas/diskfont.h"
#include "Pragmas/dynamic.h"
#include "Pragmas/gadtools.h"
#include "Pragmas/keymap.h"
#include "Pragmas/graphics.h"
#include "Pragmas/icon.h"
#include "Pragmas/input.h"
#include "Pragmas/intuition.h"
#include "Pragmas/layers.h"
#include "Pragmas/locale.h"
#include "Pragmas/misc.h"
#include "Pragmas/timer.h"
#include "Pragmas/wb.h"
#include "Pragmas/xpkmaster.h"
#include "Pragmas/amigaguide.h"
#include "Pragmas/reqtools.h"

#endif

#define Prototype        extern
#define MAX_LEN          120
#define ARGBUFFER_SIZE   10500
#define ARGBUFFER_LIMIT  10000

///
/// "prototypes"

Prototype void   main(ULONG, UBYTE **);
Prototype int    wbmain(struct WBStartup *);
Prototype void   Action(UBYTE *, UBYTE *, UBYTE *, BOOL, BOOL, ULONG *, UBYTE *, BOOL, BOOL);
Prototype UBYTE  *StartGED(UBYTE *, UBYTE *, UBYTE *, BOOL, BOOL);
Prototype ULONG *SendRexxCommand(UBYTE *, UBYTE *, struct MsgPort *);
Prototype UBYTE  *LookForGED(UBYTE *, BOOL);
Prototype UBYTE  *myprintf(UBYTE *, UBYTE*, ...);
Prototype UBYTE  *xsprintf(UBYTE *, APTR);
Prototype BOOL   FindAssign(UBYTE *);

extern struct Library *IconBase;
extern struct Library *DOSBase;
extern struct Library *SysBase;
extern struct Library *IntuitionBase;

///
/// "entry points"

/* --------------------------------------- main --------------------------------

 CLI entry point. Parse command line - create a string <argBuffer> containing
 provided  file  names  (file names are made absolute). This string has to be
 FreeVec()'ed later on. Additionally, command line options are checked.

*/

void
main(argc, argv)

ULONG argc;
UBYTE *argv[];
{
    UBYTE *argBuffer;

    if (argBuffer = AllocVec(ARGBUFFER_SIZE, MEMF_PUBLIC | MEMF_CLEAR)) {

        struct RDArgs *rdArgs;

        ULONG args[] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };

        BOOL fast = FALSE;

        if (rdArgs = ReadArgs("C=CONFIG/K,S=SCREEN/K,Y=STICKY/S,F=FILE/M,HIDE/S,-STICKY/S,L=LINE/N,A=AREXX/K,FAST/S,FORCE/S", args, NULL)) {

            if (args[8])                             // FAST/S
                fast = TRUE;

            if (args[3]) {

                UBYTE **nextFile, path[MAX_LEN + 1];
                BPTR    lock;

                for (nextFile = (UBYTE **)args[3]; *nextFile; ++nextFile) {

                    strcpy(path, *nextFile);

                    if (lock = Lock(path, ACCESS_READ)) {

                        NameFromLock(lock, path, MAX_LEN);
                        UnLock(lock);
                    }
                    else if (strchr(path, ':') == NULL) {

                        GetCurrentDirName(path, MAX_LEN);

                        AddPart(path, *nextFile, MAX_LEN);
                    }

                    strcat(argBuffer, xsprintf("\42%s\42", path));

                    // files are specified: disable AutoDesktop feature of GoldED

                    fast = TRUE;

                    if (strlen(argBuffer) > ARGBUFFER_LIMIT)
                        break;
                }
            }

            Action(argBuffer, (UBYTE *)args[0], (UBYTE *)args[1], (BOOL)args[2] || (BOOL)args[5], (BOOL)args[4] || (BOOL)args[5], (ULONG *)args[6], (UBYTE *)args[7], fast, (BOOL)args[9]);

            FreeArgs(rdArgs);
        }
        else
            exit(20);
    }
    exit(0);
}

/* ------------------------------------ wbmain ---------------------------------

 Workbench entry point. Read tooltypes of ED icon to decide wether user prefers
 a special configuration/public screen.

*/

int
wbmain(struct WBStartup *wbs)
{
    UBYTE *argBuffer;

    if (argBuffer = AllocVec(ARGBUFFER_SIZE, MEMF_PUBLIC | MEMF_CLEAR)) {

        struct DiskObject *diskObject;
        UBYTE             *config, *screen, *arexx, progName[MAX_LEN + 1];
        BOOL               hide, fast, force;

        screen = NULL;
        config = NULL;
        arexx  = NULL;

        hide  = FALSE;
        fast  = FALSE;
        force = FALSE;

        NameFromLock(GetProgramDir(), progName, MAX_LEN);

        AddPart(progName, wbs->sm_ArgList[0].wa_Name, MAX_LEN);

        if (diskObject = GetDiskObject(progName)) {

            config = FindToolType(diskObject->do_ToolTypes, "CONFIG");
            screen = FindToolType(diskObject->do_ToolTypes, "SCREEN");
            arexx  = FindToolType(diskObject->do_ToolTypes, "AREXX" );

            if (FindToolType(diskObject->do_ToolTypes, "HIDE"))
                hide = TRUE;

            if (FindToolType(diskObject->do_ToolTypes, "FAST"))
                fast = TRUE;

            if (FindToolType(diskObject->do_ToolTypes, "FORCE"))
                force = TRUE;
        }

        if (--wbs->sm_NumArgs) {

            UBYTE file[MAX_LEN + 1];

            struct WBArg *wbArg = wbs->sm_ArgList;

            while ((wbs->sm_NumArgs)--) {

                ++wbArg;

                NameFromLock( wbArg->wa_Lock, file, MAX_LEN);
                AddPart(file, wbArg->wa_Name, MAX_LEN);

                strcat(argBuffer, xsprintf("\42%s\42", file));

                // files are specified: disable AutoDesktop feature of GoldED

                fast = TRUE;

                if (strlen(argBuffer) > ARGBUFFER_LIMIT)
                    break;
            }
        }

        Action(argBuffer, config, screen, FALSE, hide, NULL, arexx, fast, force);

        if (diskObject)
            FreeDiskObject(diskObject);
    }

    exit(0);
}

///
/// "main routine"

/* ------------------------------------ Action ---------------------------------

 Run GoldED if no running instance of GED is found (note:  running  GED  will
 open  a  first  window,  i.e. no need to open a further one unless files are
 specified). Send LOCK message to running GoldED. Wait  for  positive  reply,
 pass  our  list of <files> to that editor, unlock editor (use delayed unlock
 if <sticky> is specified).

*/

void
Action(files, config, screen, sticky, hide, line, arexx, fast, force)

UBYTE *files, *config, *screen, *arexx;
ULONG *line;
BOOL   sticky, hide, fast, force;
{
    static UBYTE version[] = "$VER: ED 2.4+ (" __COMMODORE_DATE__ ")";

    BOOL   useResident;
    ULONG *result;
    UBYTE *host;

    useResident = ((host = LookForGED(arexx, force)) != NULL);

    if (useResident == FALSE)
        host = StartGED(config, screen, arexx, hide, fast);

    // any further action required (besides running GoldED) ?

    if (host && (*files || (useResident && (hide == FALSE)))) {

        struct MsgPort *replyPort;

        if (replyPort = CreateMsgPort()) {

            if (result = SendRexxCommand(host, "LOCK CURRENT", replyPort)) {

                if (*result == RC_OK) {

                    if (config && useResident)
                        SendRexxCommand(host, xsprintf("PREFS LOAD SMART CONFIG=\42%s\42 ", config), replyPort);

                    if (*files)
                        strins(files, "OPEN SMART QUIET ");
                    else
                        strcpy(files, "MORE SMART");

                    SendRexxCommand(host, files, replyPort);

                    if (line)
                        SendRexxCommand(host, xsprintf("GOTO LINE=%ld UNFOLD=TRUE", (APTR)*line), replyPort);

                    SendRexxCommand(host, sticky ? "UNLOCK STICKY" : "UNLOCK", replyPort);
                }
            }

            DeleteMsgPort(replyPort);
        }
    }

    FreeVec(files);
}

///
/// "misc"

/* -------------------------------- FindAssign ---------------------------------

 Check whether assign exists without annoying 'insert drive' requester

*/

BOOL
FindAssign(assign)

UBYTE *assign;
{
    BOOL success = (FindDosEntry(LockDosList(LDF_ASSIGNS | LDF_READ), assign, LDF_ASSIGNS) != NULL);

    UnLockDosList(LDF_ASSIGNS | LDF_READ);

    return(success);
}


/* ----------------------------------- LookForGED ----------------------------

 Look for running GoldED task (check <host> and GOLDED.1 to GOLDED.9)

*/

UBYTE *
LookForGED(host, forcehost)

UBYTE *host;
BOOL forcehost;
{
    if (host && FindPort(host))

        return(host);

    else {
        if ( ( forcehost == FALSE) || (host == NULL)) {

            static UBYTE name[] = "GOLDED.1";

            while (name[7] <= '9') {

                if (FindPort(name))
                    return(name);
                else
                    ++name[7];
            } 

            return(NULL);
        }
        else {

            return(NULL);
        }
    }
}

/* ------------------------------------- StartGED -----------------------------

 Launch a new GoldED task. Look for "GOLDED:" assign. Add assign if  none  is
 found (defaultPath[] is set by the installer script). Return pointer to host
 name (or NULL). Screen/config keywords are considered.

*/

UBYTE *
StartGED(config, screen, arexx, hide, fast)

UBYTE *config, *screen, *arexx;
BOOL   hide, fast;
{
    static UBYTE host[255], defaultPath[255] = "$GOLDED";

    UBYTE command[MAX_LEN + 1];

    if (FindAssign("GOLDED") == FALSE)
        AssignLock("GOLDED", Lock(defaultPath, ACCESS_READ));

    if (arexx)
        strcpy(host, arexx);
    else
        strcpy(host, "GOLDED.1");

    strcpy(command, xsprintf("GOLDED:GOLDED AREXX=%s", host));

    if (hide)
        strcat(command, " HIDE");

    if (fast)
        strcat(command, " FAST");

    if (config)
        strcat(command, xsprintf(" CONFIG=\42%s\42", config));

    if (screen)
        strcat(command, xsprintf(" SCREEN=%s", screen));

    if (SystemTags(command, SYS_Asynch, TRUE, SYS_Input, NULL, SYS_Output, NULL, NP_StackSize, 8192, TAG_DONE) == 0) {

        UWORD try;

        for (try = 50; try; try--, Delay(10))
            if (FindPort(host))
                return(host);
    }

    return(NULL);
}

/* --------------------------------- xsprintf ----------------------------------

 sprintf frontend (returns pointer to static buffer)

*/

UBYTE *
xsprintf(template, data)

UBYTE *template;
APTR  data;
{
    static UBYTE buffer[MAX_LEN + 1];

    return(myprintf(buffer, template, data));
}


///
/// "ARexx"

/* ---------------------------------- SendRexxCommand -------------------------

 Send ARexx message & wait for answer. Return pointer to result or NULL.

*/

ULONG *
SendRexxCommand(port, cmd, replyPort)

struct MsgPort *replyPort;
UBYTE          *cmd, *port;
{
    struct MsgPort *rexxport;

    Forbid();

    if (rexxport = FindPort(port)) {

        struct RexxMsg *rexxMsg, *answer;

        if (rexxMsg = CreateRexxMsg(replyPort, NULL, NULL)) {

            if (rexxMsg->rm_Args[0] = CreateArgstring(cmd, strlen(cmd))) {

                static ULONG result;

                rexxMsg->rm_Action = RXCOMM | RXFF_RESULT;

                PutMsg(rexxport, &rexxMsg->rm_Node);

                do {
                    
                    WaitPort(replyPort);

                    if (answer = (struct RexxMsg *)GetMsg(replyPort))
                        result = answer->rm_Result1;

                } while (!answer);

                Permit();

                if (answer->rm_Result1 == RC_OK) 
                    if (answer->rm_Result2)
                        DeleteArgstring((UBYTE *)answer->rm_Result2);

                DeleteArgstring((UBYTE *)ARG0(answer));

                DeleteRexxMsg(answer);

                return(&result);
            }
        }
    }

    Permit();

    return(NULL);
}

///
