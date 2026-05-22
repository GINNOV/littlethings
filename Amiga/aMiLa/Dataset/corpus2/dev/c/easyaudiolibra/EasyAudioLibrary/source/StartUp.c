/* ------------------------------------------------------------------ */
/* $VER: StartUp.c 39.01 (12.12.1999)                                 */
/*                                                                    */
/* Easyaudio Library startup-code and function table definitions.     */
/*                                                                    */
/* (C) Copyright 1999-2000 Matthew J Fletcher - All Rights Reserved.  */
/* amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk            */
/* ------------------------------------------------------------------ */

/* perhaps only recognized by SAS/C */
#define __USE_SYSBASE        

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <exec/resident.h>
#include <exec/initializers.h>

#include <proto/exec.h>

#include "compiler.h"
#include "Funcs.h" /* usefull stuff ! */

/* i love egcs..! */
#ifdef __GNUC__  
#include "../include/easyaudio/easyaudiobase.h"
#else
#include "/include/easyaudio/easyaudiobase.h"
#endif


extern ULONG __saveds __stdargs L_OpenLibs(struct EasyaudioBase *EasyaudioBase);



extern void  __saveds __stdargs L_CloseLibs(void);


struct EasyaudioBase * __saveds ASM
InitLib( register __a6 struct ExecBase      *sysbase GNUCREG(a6),
         register __a0 SEGLISTPTR           seglist GNUCREG(a0),
         register __d0 struct EasyaudioBase *eab     GNUCREG(d0)
       );


struct EasyaudioBase * __saveds ASM
OpenLib( register __a6 struct EasyaudioBase *EasyaudioBase GNUCREG(a6)
       );


SEGLISTPTR __saveds ASM
CloseLib( register __a6 struct EasyaudioBase *EasyaudioBase GNUCREG(a6)
        );


SEGLISTPTR __saveds ASM
ExpungeLib( register __a6 struct EasyaudioBase *eab GNUCREG(a6)
          );


ULONG ASM ExtFuncLib(void);


/* -------------------------------------------------------------------
 LibStart:

 If someone tries to start a library as an executable, it must return
 (LONG) -1 as result. That's what we are doing here.
 --------------------------------------------------------------------- */

LONG ASM LibStart(void)
{
 return(-1);
}


/* ------------------------------------------------------------------------
 Function and Data Tables:

 The function and data tables have been placed here for traditional reasons.
 Placing the RomTag structure before (-> Init.c) would also be a good idea,
 but it depends on whether you would like to keep the "version" stuff
 separately.
 ----------------------------------------------------------------------- */

extern APTR FuncTab [];
extern struct MyDataInit DataTab;

/* Instead you may place ROMTag + Datatab directly, here */
/* (see Init.c). This may fix "Installer" version        */
/* checking problems, too - try it.                      */


struct InitTable                       /* do not change */
{
 ULONG              LibBaseSize;
 APTR              *FunctionTable;
 struct MyDataInit *DataTable;
 APTR               InitLibTable;
} InitTab =
{
 (ULONG)               sizeof(struct EasyaudioBase),
 (APTR              *) &FuncTab[0],
 (struct MyDataInit *) &DataTab,
 (APTR)                InitLib
};

APTR FuncTab [] =
{
 OpenLib,
 CloseLib,
 ExpungeLib,
 ExtFuncLib,

 EA_Request,  /* my functions start here */
 EA_Speech,
 EA_Beep,

 EA_PrepareSound,
 EA_PlaySound,
 EA_StopSound,
 EA_RemoveSound,

 (APTR) ((LONG)-1)
};


extern struct EasyaudioBase *EasyaudioBase;

/* -------------------------------------------------------------------------
 InitLib:

 This one is single-threaded by the Ramlib process. Theoretically you can do,
 what you like here, since you have full exclusive control over all the
 library code and data.

 But due to some bugs in Ramlib V37-40, you can easily cause a deadlock when
 opening certain libraries here (which open other libraries, that open other
 libraries, that...)
 ------------------------------------------------------------------------ */

struct EasyaudioBase * __saveds ASM
InitLib( register __a6 struct ExecBase      *sysbase GNUCREG(a6),
         register __a0 SEGLISTPTR            seglist GNUCREG(a0),
         register __d0 struct EasyaudioBase *eab     GNUCREG(d0)
       )
{
 EasyaudioBase = eab;

 EasyaudioBase->eab_SysBase = sysbase;
 EasyaudioBase->eab_SegList = seglist;

 if(L_OpenLibs(EasyaudioBase)) return(EasyaudioBase);

 L_CloseLibs();

  {
   ULONG negsize, possize, fullsize;
   UBYTE *negptr = (UBYTE *) EasyaudioBase;

   negsize  = EasyaudioBase->eab_LibNode.lib_NegSize;
   possize  = EasyaudioBase->eab_LibNode.lib_PosSize;
   fullsize = negsize + possize;
   negptr  -= negsize;

   FreeMem(negptr, fullsize);
  }

 return(NULL);
}

/* -----------------------------------------------------------------------
 OpenLib:

 This one is enclosed within a Forbid/Permit pair by Exec V37-40. Since a
 Wait() call would break this Forbid/Permit(), you are not allowed to start
 any operations that may cause a Wait() during their processing. It's possible,
 that future OS versions won't turn the multi-tasking off, but instead use
 semaphore protection for this function.
 ------------------------------------------------------------------------ */

struct EasyaudioBase * __saveds ASM
OpenLib( register __a6 struct EasyaudioBase *EasyaudioBase GNUCREG(a6))
{
 EasyaudioBase->eab_LibNode.lib_OpenCnt++;

 EasyaudioBase->eab_LibNode.lib_Flags &= ~LIBF_DELEXP;

 return(EasyaudioBase);
}

/* -------------------------------------------------------------------------
 CloseLib:

 This one is enclosed within a Forbid/Permit pair by Exec V37-40. Since a
 Wait() call would break this Forbid/Permit(), you are not allowed to start
 any operations that may cause a Wait() during their processing. It's possible,
 that future OS versions won't turn the multi-tasking off, but instead use
 semaphore protection for this function.
 ------------------------------------------------------------------------ */

SEGLISTPTR __saveds ASM
CloseLib( register __a6 struct EasyaudioBase *EasyaudioBase GNUCREG(a6))
{
 EasyaudioBase->eab_LibNode.lib_OpenCnt--;

 if(!EasyaudioBase->eab_LibNode.lib_OpenCnt)
  {
   if(EasyaudioBase->eab_LibNode.lib_Flags & LIBF_DELEXP)
    {
     return( ExpungeLib(EasyaudioBase) );
    }
  }

 return(NULL);
}

/* ------------------------------------------------------------------------
 ExpungeLib:

 Currently you only could bypass this restriction by supplying your own
 semaphore mechanism - but since expunging can't be done twice, one should
 avoid it here.
 ----------------------------------------------------------------------- */

SEGLISTPTR __saveds ASM
ExpungeLib( register __a6 struct EasyaudioBase *eab GNUCREG(a6))
{
 struct EasyaudioBase *EasyaudioBase = eab;
 SEGLISTPTR seglist;

 if(!EasyaudioBase->eab_LibNode.lib_OpenCnt)
  {
   ULONG negsize, possize, fullsize;
   UBYTE *negptr = (UBYTE *) EasyaudioBase;

   seglist = EasyaudioBase->eab_SegList;

   Remove((struct Node *)EasyaudioBase);

   L_CloseLibs();

   negsize  = EasyaudioBase->eab_LibNode.lib_NegSize;
   possize  = EasyaudioBase->eab_LibNode.lib_PosSize;
   fullsize = negsize + possize;
   negptr  -= negsize;

   FreeMem(negptr, fullsize);

   return(seglist);
  }

 EasyaudioBase->eab_LibNode.lib_Flags |= LIBF_DELEXP;

 return(NULL);
}

/* ---------------------------------------------------------------------
 ExtFunct:
 -------------------------------------------------------------------- */

ULONG ASM ExtFuncLib(void)
{
 return(NULL);
}

struct EasyaudioBase *EasyaudioBase = NULL;

/* thats it folks */
