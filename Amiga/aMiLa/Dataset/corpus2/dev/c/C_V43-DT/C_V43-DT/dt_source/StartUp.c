/*
**      $VER: StartUp.c 43.9 (29.6.97)
**
**      Library startup-code and function table definition
**
**      (C) Copyright 1996-97 Andreas R. Kleinert
**      All Rights Reserved.
*/

#define __USE_SYSBASE

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <exec/resident.h>
#include <exec/initializers.h>

#include <proto/exec.h>

#include <class/classbase.h>
#include "libfuncs.h"


extern ULONG __saveds __stdargs L_OpenLibs(void);
extern void  __saveds __stdargs L_CloseLibs(void);


struct ClassBase * __saveds __asm InitLib( register __a6 struct ExecBase      *sysbase,
                                             register __a0 struct SegList       *seglist,
                                             register __d0 struct ClassBase *exb);

struct ClassBase * __saveds __asm OpenLib( register __a6 struct ClassBase *ClassBase);
struct SegList * __saveds __asm CloseLib( register __a6 struct ClassBase *ClassBase);
struct SegList * __saveds __asm ExpungeLib( register __a6 struct ClassBase *exb);
ULONG __saveds __asm ExtFuncLib(void);


LONG __saveds __asm LibStart(void)
{
 return(-1);
}

extern APTR FuncTab [];
extern struct MyDataInit DataTab;

struct InitTable
{
 ULONG              LibBaseSize;
 APTR              *FunctionTable;
 struct MyDataInit *DataTable;
 APTR               InitLibTable;
} InitTab =
{
 sizeof(struct ClassBase),
 &FuncTab[0],
 &DataTab,
 InitLib
};

APTR FuncTab [] =
{
 OpenLib,
 CloseLib,
 ExpungeLib,
 ExtFuncLib,

 ObtainPicClass,

 (APTR) ((LONG)-1)
};


extern struct ClassBase *ClassBase;


struct ClassBase * __saveds __asm InitLib( register __a6 struct ExecBase      *sysbase,
                                             register __a0 struct SegList       *seglist,
                                             register __d0 struct ClassBase *exb)
{
 ClassBase = exb;

 ClassBase->cb_SysBase = sysbase;
 ClassBase->cb_SegList = seglist;

 if(L_OpenLibs()) return(ClassBase);

 L_CloseLibs();

  {
   ULONG negsize, possize, fullsize;
   UBYTE *negptr = (UBYTE *) ClassBase;

   negsize  = ClassBase->cb_LibNode.lib_NegSize;
   possize  = ClassBase->cb_LibNode.lib_PosSize;
   fullsize = negsize + possize;
   negptr  -= negsize;

   FreeMem(negptr, fullsize);
  }

 return(NULL);
}

struct ClassBase * __saveds __asm OpenLib( register __a6 struct ClassBase *ClassBase)
{
 ClassBase->cb_LibNode.lib_OpenCnt++;

 ClassBase->cb_LibNode.lib_Flags &= ~LIBF_DELEXP;

 return(ClassBase);
}

struct SegList * __saveds __asm CloseLib( register __a6 struct ClassBase *ClassBase)
{
 ClassBase->cb_LibNode.lib_OpenCnt--;

 if(!ClassBase->cb_LibNode.lib_OpenCnt)
  {
   if(ClassBase->cb_LibNode.lib_Flags & LIBF_DELEXP)
    {
     return( ExpungeLib(ClassBase) );
    }
  }

 return(NULL);
}

struct SegList * __saveds __asm ExpungeLib( register __a6 struct ClassBase *exb)
{
 struct ClassBase *ClassBase = exb;
 struct SegList       *seglist;

 if(!ClassBase->cb_LibNode.lib_OpenCnt)
  {
   ULONG negsize, possize, fullsize;
   UBYTE *negptr = (UBYTE *) ClassBase;

   seglist = ClassBase->cb_SegList;

   Remove(ClassBase);

   L_CloseLibs();

   negsize  = ClassBase->cb_LibNode.lib_NegSize;
   possize  = ClassBase->cb_LibNode.lib_PosSize;
   fullsize = negsize + possize;
   negptr  -= negsize;

   FreeMem(negptr, fullsize);

   return(seglist);
  }

 ClassBase->cb_LibNode.lib_Flags |= LIBF_DELEXP;

 return(NULL);
}

ULONG __saveds __asm ExtFuncLib(void)
{
 return(NULL);
}

struct ClassBase *ClassBase = NULL;


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
