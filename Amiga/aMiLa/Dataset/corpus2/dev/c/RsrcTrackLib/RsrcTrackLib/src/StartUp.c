/*
**      $VER: StartUp.c 37.0 (20.07.98)
**
**      Library startup-code and function table definition
**
**      (C) Copyright 1996-97 Andreas R. Kleinert
**      All Rights Reserved.
**  
**      Adaptations done by BURNAND Patrick.
*/

#define __USE_SYSBASE        /* perhaps only recognized by SAS/C */

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <exec/resident.h>
#include <exec/initializers.h>


#ifdef __MAXON__
#include <pragma/exec_lib.h>
#include <linkerfunc.h>
#else
#include <proto/exec.h>    /* all other compilers */
#endif
#include "compiler.h"


#ifdef __GNUC__
#include "include/ressourcetracking/ressourcetrackingbase.h"
#elif VBCC
#include "include/ressourcetracking/ressourcetrackingbase.h"
#else
#include "/include/ressourcetracking/ressourcetrackingbase.h"
#endif
#include "SampleFuncs.h"

extern ULONG __saveds __stdargs L_OpenLibs(struct RessourceTrackingBase *RessourceTrackingBase);
extern void  __saveds __stdargs L_CloseLibs(void);

struct RessourceTrackingBase * __saveds ASM InitLib( register __a6 struct ExecBase *sysbase GNUCREG(a6),
                    register __a0 struct SegList *seglist GNUCREG(a0),
                    register __d0 struct RessourceTrackingBase *rtb GNUCREG(d0));
struct RessourceTrackingBase * __saveds ASM OpenLib( register __a6 struct RessourceTrackingBase *RessourceTrackingBase GNUCREG(a6));
APTR __saveds ASM CloseLib( register __a6 struct RessourceTrackingBase *RessourceTrackingBase GNUCREG(a6));
APTR __saveds ASM ExpungeLib( register __a6 struct RessourceTrackingBase *rtb GNUCREG(a6));
ULONG ASM ExtFuncLib(void);


/* ----------------------------------------------------------------------------------------
   ! LibStart:
   !
   ! If someone tries to start a library as an executable, it must return (LONG) -1
   ! as result. That's what we are doing here.
   ---------------------------------------------------------------------------------------- */

LONG ASM LibStart(void)
{
 return(-1);
}


/* ----------------------------------------------------------------------------------------
   ! Function and Data Tables:
   !
   ! The function and data tables have been placed here for traditional reasons.
   ! Placing the RomTag structure before (-> LibInit.c) would also be a good idea,
   ! but it depends on whether you would like to keep the "version" stuff separately.
   ---------------------------------------------------------------------------------------- */

extern APTR FuncTab [];
extern DataTab;                   /* instead you may place ROMTag + Datatab directly, here */
                                  /* (see LibInit.c). This may fix "Installer" version     */
                                  /* checking problems, too.                               */

struct InitTable                       /* do not change */
{
 ULONG              LibBaseSize;
 APTR              *FunctionTable;
 struct MyDataInit *DataTable;
 APTR               InitLibTable;
} InitTab =
{
 sizeof(struct RessourceTrackingBase),
 &FuncTab[0],
 (struct MyDataInit *)&DataTab,
 (APTR) InitLib
};

APTR FuncTab [] =
{
 (APTR) OpenLib,
 (APTR) CloseLib,
 (APTR) ExpungeLib,
 (APTR) ExtFuncLib,

 (APTR) rt_AddManager,
 (APTR) rt_RemManager,
 (APTR) rt_FindNumUsed,
 (APTR) rt_UnsetMarker,
 (APTR) rt_AllocMem, 
 (APTR) rt_SetCustomF0, 
 (APTR) rt_SetCustomF1, 
 (APTR) rt_SetCustomF2, 
 (APTR) rt_SetMarker, 
 (APTR) rt_AllocSignal,
 (APTR) rt_OpenLibrary,
 (APTR) rt_AddSemaphore,
 (APTR) rt_Forbid,
 (APTR) rt_AllocTrap,
 (APTR) rt_CreateMsgPort,
 (APTR) rt_AddPort,
 (APTR) ((LONG)-1)
};


extern struct RessourceTrackingBase *RessourceTrackingBase;

/* ----------------------------------------------------------------------------------------
   ! InitLib:
   !
   ! This one is single-threaded by the Ramlib process. Theoretically you can do, what
   ! you like here, since you have full exclusive control over all the library code and data.
   ! But due to some bugs in Ramlib V37-40, you can easily cause a deadlock when opening
   ! certain libraries here (which open other libraries, that open other libraries, that...)
   !
   ---------------------------------------------------------------------------------------- */
struct RessourceTrackingBase * __saveds ASM InitLib( register __a6 struct ExecBase      *sysbase GNUCREG(a6),
                    register __a0 struct SegList *seglist GNUCREG(a0),
                    register __d0 struct RessourceTrackingBase *rtb GNUCREG(d0))
{
 RessourceTrackingBase = rtb;

 RessourceTrackingBase->rtb_SysBase = sysbase;
 RessourceTrackingBase->rtb_SegList = seglist;

 if(L_OpenLibs(RessourceTrackingBase)) return(RessourceTrackingBase);

 L_CloseLibs();

  {
   ULONG negsize, possize, fullsize;
   UBYTE *negptr = (UBYTE *) RessourceTrackingBase;

   negsize  = RessourceTrackingBase->rtb_LibNode.lib_NegSize;
   possize  = RessourceTrackingBase->rtb_LibNode.lib_PosSize;
   fullsize = negsize + possize;
   negptr  -= negsize;

   FreeMem(negptr, fullsize);

   #ifdef __MAXON__
   CleanupModules();
   #endif
  }

 return(NULL);
}

/* ----------------------------------------------------------------------------------------
   ! OpenLib:
   !
   ! This one is enclosed within a Forbid/Permit pair by Exec V37-40. Since a Wait() call
   ! would break this Forbid/Permit(), you are not allowed to start any operations that
   ! may cause a Wait() during their processing. It's possible, that future OS versions
   ! won't turn the multi-tasking off, but instead use semaphore protection for this
   ! function.
   !
   ! Currently you only can bypass this restriction by supplying your own semaphore
   ! mechanism.
   ---------------------------------------------------------------------------------------- */

struct RessourceTrackingBase * __saveds ASM OpenLib( register __a6 struct RessourceTrackingBase *ressourcetrackingBase GNUCREG(a6))
{
 #ifdef __MAXON__
 GetBaseReg();
 InitModules();
 #endif

 RessourceTrackingBase->rtb_LibNode.lib_OpenCnt++;

 RessourceTrackingBase->rtb_LibNode.lib_Flags &= ~LIBF_DELEXP;

 return(RessourceTrackingBase);
}

/* ----------------------------------------------------------------------------------------
   ! CloseLib:
   !
   ! This one is enclosed within a Forbid/Permit pair by Exec V37-40. Since a Wait() call
   ! would break this Forbid/Permit(), you are not allowed to start any operations that
   ! may cause a Wait() during their processing. It's possible, that future OS versions
   ! won't turn the multi-tasking off, but instead use semaphore protection for this
   ! function.
   !
   ! Currently you only can bypass this restriction by supplying your own semaphore
   ! mechanism.
   ---------------------------------------------------------------------------------------- */

APTR __saveds ASM CloseLib( register __a6 struct RessourceTrackingBase *RessourceTrackingBase GNUCREG(a6))
{
 RessourceTrackingBase->rtb_LibNode.lib_OpenCnt--;

 if(!RessourceTrackingBase->rtb_LibNode.lib_OpenCnt)
  {
   if(RessourceTrackingBase->rtb_LibNode.lib_Flags & LIBF_DELEXP)
    {
     return( ExpungeLib(RessourceTrackingBase) );
    }
  }

 return(NULL);
}

/* ----------------------------------------------------------------------------------------
   ! ExpungeLib:
   !
   ! This one is enclosed within a Forbid/Permit pair by Exec V37-40. Since a Wait() call
   ! would break this Forbid/Permit(), you are not allowed to start any operations that
   ! may cause a Wait() during their processing. It's possible, that future OS versions
   ! won't turn the multi-tasking off, but instead use semaphore protection for this
   ! function.
   !
   ! Currently you only could bypass this restriction by supplying your own semaphore
   ! mechanism - but since expunging can't be done twice, one should avoid it here.
   ---------------------------------------------------------------------------------------- */

APTR __saveds ASM ExpungeLib( register __a6 struct RessourceTrackingBase *rtb GNUCREG(a6))
{
 struct RessourceTrackingBase *RessourceTrackingBase = rtb;
 struct SegList *seglist;

 if(!RessourceTrackingBase->rtb_LibNode.lib_OpenCnt)
  {
   ULONG negsize, possize, fullsize;
   UBYTE *negptr = (UBYTE *) RessourceTrackingBase;

   seglist = RessourceTrackingBase->rtb_SegList;

   Remove((struct Node *)RessourceTrackingBase);

   L_CloseLibs();

   negsize  = RessourceTrackingBase->rtb_LibNode.lib_NegSize;
   possize  = RessourceTrackingBase->rtb_LibNode.lib_PosSize;
   fullsize = negsize + possize;
   negptr  -= negsize;

   FreeMem(negptr, fullsize);

   #ifdef __MAXON__
   CleanupModules();
   #endif

   return(seglist);
  }

 RessourceTrackingBase->rtb_LibNode.lib_Flags |= LIBF_DELEXP;

 return(NULL);
}

/* ----------------------------------------------------------------------------------------
   ! ExtFunct:
   !
   ! This one is enclosed within a Forbid/Permit pair by Exec V37-40. Since a Wait() call
   ! would break this Forbid/Permit(), you are not allowed to start any operations that
   ! may cause a Wait() during their processing. It's possible, that future OS versions
   ! won't turn the multi-tasking off, but instead use semaphore protection for this
   ! function.
   !
   ! Currently you only can bypass this restriction by supplying your own semaphore
   ! mechanism - but since this function currently is unused, you should not touch
   ! it, either.
   ---------------------------------------------------------------------------------------- */

ULONG ASM ExtFuncLib(void)
{
 return(NULL);
}

struct RessourceTrackingBase *RessourceTrackingBase = NULL;


/* ----------------------------------------------------------------------------------------
   ! __SASC stuff:
   !
   ! This is only for SAS/C - its intention is to turn off internal CTRL-C handling
   ! for standard C function and to avoid calls to exit() et al.
   ---------------------------------------------------------------------------------------- */

#ifdef __SASC

#ifdef ARK_OLD_STDIO_FIX

ULONG XCEXIT       = NULL; /* these symbols may be referenced by    */
ULONG _XCEXIT      = NULL; /* some functions of sc.lib, but should  */
ULONG ONBREAK      = NULL; /* never be used inside a shared library */
ULONG _ONBREAK     = NULL;
ULONG base         = NULL;
ULONG _base        = NULL;
ULONG ProgramName  = NULL;
ULONG _ProgramName = NULL;
ULONG StackPtr     = NULL;
ULONG _StackPtr    = NULL;
ULONG oserr        = NULL;
ULONG _oserr       = NULL;
ULONG OSERR        = NULL;
ULONG _OSERR       = NULL;

#endif /* ARK_OLD_STDIO_FIX */

void __regargs __chkabort(void) { }  /* a shared library cannot be    */
void __regargs _CXBRK(void)     { }  /* CTRL-C aborted when doing I/O */

#endif /* __SASC */
