/*
**      $VER: DCBack.c 1.5 (22.4.93)
**      Auto-detach link library for DICE.
**
**      (C) Copyright 1991-1993 Jaba Development.
**          Written by Jan van den Baard
**/

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/execbase.h>
#include <exec/libraries.h>
#include <exec/alerts.h>
#include <dos/dos.h>
#include <dos/dosextens.h>
#include <dos/rdargs.h>
#include <workbench/startup.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>

#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <lib/misc.h>

/*
 * --- These globals MUST be defined somewhere in your source!
 */
extern  UBYTE   *_procname;         /* process name */
extern  UBYTE   *_template;         /* commandline template */
extern  UBYTE   *_exthelp;          /* extended command line help */
extern  LONG     _stack;            /* process stack */
extern  LONG     _priority;         /* process priority */
extern  LONG     _BackGroundIO;     /* open background io channel */

/*
 * --- externally referenced structures.
 */
extern struct ExecBase  *SysBase;   /* to check for V36 minimum */
extern struct WBStartup *_WBMsg;    /* guess what.... */

/*
 * --- This is how both main() and wbmain() are called.
 */
extern long main( long, long * );
extern long wbmain( struct WBStartup * );

/*
 * --- Proto for the exit routines and waitwbmsg
 */
long exit( long );
long _exit( long );
void _waitwbmsg( void );

/*
 * --- Data that isn't chucked in the BSS section.
 */
BPTR             _DetachDir      =       0l;    /* process current dir */
BPTR             _Backstdout     =       0l;    /* io channel */
UBYTE            _IsDetached     =       FALSE; /* detached flag */
ULONG           *_DosArray       =       0l;    /* commandline array */
UWORD            _NumArgs        =       0l;    /* max # of args */
UBYTE           *_Arguments      =       0l;    /* argument line */
struct RDArgs   *_DosSource      =       0l;    /* for the arguments */

/*
 * --- New _main() which checks if it is run from the shell or
 * --- the workbench.
 */
__stkargs long _main( long len, char *lin )
{
    struct Process              *ThisTask;
    struct CommandLineInterface *cli;
    struct MemList              *mlist;
    BPTR                        *SegList, *TmpSeg;
    ULONG                        SegCount = 0l, ArgCount = 0l;
    BYTE                         DetachRun = FALSE;
    UBYTE                       *Tmp;
    ULONG                        alert;

   /*
    * --- First we must see wether we are running
    * --- under 2.0 or not. We need 2.0 for the
    * --- commandline parsing!
    */
    if ((( struct Library *)SysBase)->lib_Version < 36 )
        return( RETURN_FAIL );

   /*
    * --- Get a pointer to our Task (Process)
    */
    ThisTask = ( struct Process * )SysBase->ThisTask;

   /*
    * --- When run from the shell the process has
    * --- a CLI structure. If this is the case
    * --- the 'DetachRun' flag is set to TRUE so we
    * --- we know that the program still has to be
    * --- detached.
    */
    if ( ThisTask->pr_CLI )
        DetachRun = TRUE;

   /*
    * --- When either the 'DetachRun' or '_IsDetached' flag
    * --- is TRUE it means that we are run from the shell.
    */
    if ( DetachRun || _IsDetached ) {
       /*
        * --- Check if we are detached yet...
        */
        if ( ! _IsDetached ) {
           /*
            * --- We arn't detached yet so we must parse
            * --- the arguments given to us by the shell.
            */
            if ( Tmp = _template ) {
               /*
                * --- There is a template string supplied
                */
                if ( *Tmp ) {
                   /*
                    * --- The template string even got characters in it!
                    * --- Now we must count the maximum number of arguments
                    * --- we can expect. This is done by counting the
                    * --- commas in the template string and then adding
                    * --- one to the result
                    */
                    while ( *Tmp ) {
                        if ( *Tmp == ',' ) ArgCount++;
                        Tmp++;
                    }
                    ArgCount++;
                }
            }

           /*
            * --- Allocate and parse the arguments.
            */
            if ( ArgCount ) {
               /*
                * --- There are arguments to be expected.
                */
                _NumArgs   = ArgCount; /* save argument count */
                _Arguments = lin;      /* save the argument line pointer */

               /*
                * --- Allocate our RDArgs structure.
                */
                if ( ! ( _DosSource = ( struct RDArgs * )AllocVec((long)sizeof( struct RDArgs ), MEMF_PUBLIC | MEMF_CLEAR ))) {
                    alert = AT_Recovery | AG_NoMemory | AO_Unknown;
                    goto suError;
                }

               /*
                * --- Setup the RDArgs structure for extended help.
                */
                _DosSource->RDA_ExtHelp          = _exthelp;

               /*
                * --- Try to allocate the array that will hold
                * --- the result of the parse.
                */
                if ( ! (_DosArray = (ULONG *)AllocVec( ArgCount * sizeof( LONG ), MEMF_PUBLIC | MEMF_CLEAR ))) {
                    alert = AT_Recovery | AG_NoMemory | AO_Unknown;
                    goto suError;
                }

               /*
                * --- Try to parse the arguments from STDIN.
                */
                if ( ! ReadArgs( _template, _DosArray, _DosSource )) {
                    PrintFault( IoErr(), NULL );
                    alert = 0l;
                    goto suError;
                }
            }
        }

       /*
        * --- This code only get's executed when the program
        * --- was started from the shell and isn't detached yet.
        */
        if ( cli = ( struct CommandLineInterface * )BADDR( ThisTask->pr_CLI )) {
           /*
            * --- Get a copy of the lock to the current directory
            */
            CurrentDir( _DetachDir = CurrentDir( 0l ));
            _DetachDir = DupLock( _DetachDir );

           /*
            * --- Mark us as detached ( a little premature but so what.. )
            */
            _IsDetached = TRUE;

           /*
            * --- Open a io channel if requested
            */
            if ( _BackGroundIO )
                _Backstdout = Open( "*", MODE_OLDFILE );

           /*
            * --- Sanity check. If the stack is 0 then make the stack 4096
            */
            if ( ! _stack )
                _stack = 4096l;

           /*
            * --- Clear processor caches.
            */
            CacheClearU();

           /*
            * --- Try to launch us as a non-cli process
            */
            if ( CreateProc(  _procname, _priority, cli->cli_Module, _stack )) {
               /*
                * --- Don't rip the code out from under us
                */
                cli->cli_Module = 0l;

               /*
                * --- We must make sure that dos doesn't deallocate
                * --- our arguments before we get a chance to use
                * --- them.
                */
                SetArgStr( 0l );

                return ( RETURN_OK );
            } else {
                alert = AT_Recovery | AG_ProcCreate | AO_Unknown;
                goto suError;
            }
        } else {
           /*
            * --- Getting here means that we now run as a non-cli
            * --- process initially started from a shell.
            */
            if ( ! strcmp( ThisTask->pr_Task.tc_Node.ln_Name, _procname )) {

               /*
                * --- Now we are running detached we must make sure that
                * --- dos deallocates the commandline (if there) when
                * --- we exit.
                */
                SetArgStr( _Arguments );

               /*
                * --- Now we must make sure that we get deallocated
                * --- when the program exits. This is done by creating
                * --- a MemList with pointers to all our segments in
                * --- it and then AddTail'ing this to the Task it's
                * --- MemList which automatically get's deallocated
                * --- by the system.
                */
                SegList = ( BPTR * )BADDR( ThisTask->pr_SegList );
                SegList = ( BPTR * )BADDR( SegList[3] );
                TmpSeg  = SegList;

               /*
                * --- Count the number of segments we have.
                */
                while ( SegList ) {
                    SegList = ( BPTR * )BADDR( *SegList );
                    SegCount++;
                }

               /*
                * --- Try to allocate a MemList with enough MemEntry's
                * --- I didn't use AllocVec because the system deallocates
                * --- this structure itself with FreeMem() and not FreeVec()
                * --- (I think........)
                */
                if ( mlist = ( struct MemList * )AllocMem( sizeof( struct MemList ) + sizeof( struct MemEntry ) * ( SegCount - 1 ), MEMF_PUBLIC | MEMF_CLEAR )) {

                    SegList  = TmpSeg;
                    mlist->ml_NumEntries = SegCount;
                    SegCount = 0l;

                   /*
                    * --- Initialize all MemEntries
                    */
                    while ( SegList ) {
                        mlist->ml_me[ SegCount ].me_Addr   = (APTR)&SegList[ -1 ];
                        mlist->ml_me[ SegCount ].me_Length = SegList[ -1 ];
                        SegList = ( BPTR * )BADDR( *SegList );
                        SegCount++;
                    }

                   /*
                    * --- Add our MemList to the Task it's MemList.
                    */
                    Forbid();
                    AddTail( &ThisTask->pr_Task.tc_MemEntry, &mlist->ml_Node );
                    Permit();

                   /*
                    * --- Set our current dir
                    */
                    CurrentDir( _DetachDir );

                   /*
                    * --- If an io channel was requested we must
                    * --- initialize the proper stdio structures
                    */
                    if ( _BackGroundIO ) {
                        ThisTask->pr_COS = _Backstdout;

                        _IoStaticFD[1].fd_Fh    =   _Backstdout;
                        _IoStaticFD[1].fd_Flags =   O_RDWR | O_NOCLOSE | O_ISOPEN;
                        _IoStaticFD[2].fd_Fh    =   _Backstdout;
                        _IoStaticFD[2].fd_Flags =   O_RDWR | O_NOCLOSE | O_ISOPEN;

                        _finitdesc( stdout,  1, __SIF_WRITE | __SIF_NOFREE );
                        _finitdesc( stderr,  2, __SIF_WRITE | __SIF_NOFREE );
                    }

                   /*
                    * --- Now we just exit with whatever main()
                    * --- returns to us.
                    */
                    exit( main( (long)_NumArgs, _DosArray ));

                } else {
                    alert = AT_Recovery | AG_NoMemory | AO_Unknown;
                    goto suError;
                }
            }
        }
    } else {
       /*
        * --- Getting here means we have been started from the workbench.
        */
        if ( _WBMsg->sm_ArgList )
           /*
            * --- CurrentDir to the directory we are started from
            */
            CurrentDir( _WBMsg->sm_ArgList->wa_Lock );

       /*
        * --- Now we just exit with whatever wbmain()
        * --- returns to us.
        */
        exit( wbmain( _WBMsg ));
    }

   /*
    * --- This is never called! It just brings in the code that
    * --- waits for the Workbench message for when we are started
    * --- from the workbench! See wbmain.a!
    */
    _waitwbmsg();

   /*
    * --- Here's where we land when something failed.
    * --- This cleans up the mess we made except when we
    * --- got here because the MemList could not be
    * --- allocated! If that's the case the segments wont
    * --- be deallocated. This shouldn't be a problem
    * --- because when the MemList cannot be allocated anymore
    * --- your system is really fuc#@$$##@ up!
    */
suError:
    if ( _DosSource ) {
        FreeArgs( _DosSource );
        FreeVec( _DosSource );
    }
    if ( _DosArray )    FreeVec( _DosArray );
    if ( _DetachDir )   UnLock( _DetachDir );
    if ( alert )        Alert( alert );
    return( RETURN_FAIL );
}

#include <lib/atexit.h>

typedef struct Process Process;

AtExit *_ExitBase;

/*
 * --- A New exit which cleans up the mess we made.
 */
long exit( long code )
{
    AtExit *eb;

   /*
    * --- If opened, close the io channel
    */
    if ( _Backstdout )
        Close( _Backstdout );

   /*
    * --- UnLock our current dir
    */
    if ( _DetachDir )
        UnLock( _DetachDir );

   /*
    * --- Deallocate our argument array
    */
    if ( _DosArray )
        FreeVec( _DosArray );

   /*
    * --- Cleanup our RDArgs structure
    */
    if ( _DosSource ) {
        FreeArgs( _DosSource );
        FreeVec( _DosSource );
    }

   /*
    * --- Ask Matthew...... I don't know!
    */
    for (eb = _ExitBase; eb; eb = eb->Next)
        (*eb->Func)();

   /*
    * --- Low level exit
    */
    _exit(code);
}
