/*
  $Id: rexx_supp.c,v 1.2 1997/10/21 22:35:08 wegge Stab wegge $
  
  $Log: rexx_supp.c,v $
  Revision 1.2  1997/10/21 22:35:08  wegge
  Snapshot inden upload af 2.13 i source og binær form

  Revision 1.1  1997/10/21 03:49:58  wegge
  Initial revision

 */


#include "rexx_gls.h"

/* Out of sheer lazyness, we create a global visible copy of our
   library base pointer. We declare it here, instead of in libinit.c,
   which will be kept totally unaware of it's existance, simply to
   avoid confusion. We also keep a copy of the librarybase for
   Utility.library, to ease the job for the assembler stub. */

struct RexxGLSBase *RglsBase = NULL;
struct UtilityBase *_UtilBase = NULL;


#include "rexx_supp_priv.h"
#include "localerexx_protos.h"
#include "localerexx.h"
#include "rexx_supp_protos.h"
#include "functabl.h"
#include "rxslibinlines.h"

/* ARexx calls us here each time it need to query for a function. We
   get a standard RexxMsg packet, which cointains the name and
   arguments for the needed function. Unfortunately ARexx expects
   two returns, an error code in d0, and a pointer to an argstring
   with the result in a1. 
   
   As a consequence, we are going through this handcrafted piece of
   obfuscated m68k code.
   */

VOID ArexxMatchPoint(struct RexxMsg * __asm("a1"),
                     struct RexxGLSBase * __asm("a6"));
__asm("
.even
.globl _ArexxMatchPoint
_ArexxMatchPoint:

link a5,#-8	| Storage for the return values
lea a5@(-8),a1	| Address of struct RetVal
movel a6,sp@-	| struct RexxGLSBase *LibBase
movel a0,sp@-	| struct RexxMsg *Message
movel a1,sp@-	| Address for the return struct
jsr _QueryPoint	| Call QueryPoint(&RetVal, Message, LibBase)
addw #12,sp	| Clean up
movel a5@(-4),a0| a0 = RexxMatch_ret.ArgStr (Blast lousy docs!!)
movel a5@(-8),d0| d0 = RexxMatch_ret.Error
unlk a5         | Release storage
rts
");

/* The Arexx Match Func. */


VOID QueryPoint(struct RexxMatch_ret * RV, struct RexxMsg * RMsg,
		struct RexxGLSBase * RglsBase_arg) 
{

  /* This is where the actual work will be done. The RexxMsg contains
     the name of the needed function in ARG0, with its arguments in
     ARG1..ARGxx. We do a bisection of the functable, which much be
     sorted in ascending order (case insensitive), so that we don't
     use inordinate amounts of time here. */

  VOID(*Func) (struct RexxMatch_ret *, struct RexxMsg *);
  LONG Min = 0, Mid = 0, Max = JTABL_ENTRIES - 1;
  LONG TestRes;

  /* Since we are now in a somewhat safer environment now, we'll
     perform the initialization that we couldn't do in libinit. If our
     global copy of RglsBase is NULL, we can be reasonably sure that
     this is the first invocation, but to protect against race
     conditions, we will then aquire the semaphore, and check again. */
  
  RglsBase = RglsBase_arg;
  KPRINTF_HERE;

  if (_UtilBase == NULL)
    {
      ObtainSemaphore(&RglsBase_arg->RexxGLS_Sem);
      if (_UtilBase == NULL)
	{
	  if (PerformInit() == DOSFALSE)
	    {

	      /* What gives? We're somewhat stuck, since we might be
		 missing rexxsyslib.library (For some obscure
		 reason). */
	      ReleaseSemaphore(&RglsBase_arg->RexxGLS_Sem);
	      RV->ArgStr = NULL;
	      RV->Error = ERR10_014; /* Required library not found. */
	      return;
	    }
	}
      ReleaseSemaphore(&RglsBase_arg->RexxGLS_Sem);
    }
  
  while ((Max >= 0) && (Min < JTABL_ENTRIES) && (Min <= Max))
    {
      Mid = (Min + Max) / 2;
      
      /* ARexx mangles names into uppercase (mostly), so we has to do
	 a case insensitive comparision. */

      TestRes = StrcmpU(RMsg->rm_Args[0], jt[Mid].FuncName, jt[Mid].StrLen);

      
      if (TestRes < 0)
	Min = (Mid + 1);

      if (TestRes == 0)
	{

	  /* The name match, now let's see if the argument count is
	     within the useful range. */
	  if ((jt[Mid].MinArg <= (RMsg->rm_Action & RXARGMASK)) &&
	      (jt[Mid].MaxArg >= (RMsg->rm_Action & RXARGMASK)))
	    {
	      /* They were. */
	      Func = jt[Mid].Func;
	      (*Func) (RV, RMsg);
	      return;
	    }
	  /* Nope, we return an error. */
	  RV->ArgStr = CreateArgstring("", 0);
	  RV->Error = ERR10_017; /* Wrong number of arguments */
	  SetRexxRC(RMsg, RC_ERROR);
	  return;
	}

      if (TestRes > 0)
	Max = (Mid - 1);
    }
  
  /* The requested function is not one of ours. To indicate this, we
     return an empty ArgString and ERR10_001. */

  RV->ArgStr = CreateArgstring("", 0);
  RV->Error = ERR10_001;	/* Program not found. */
}

VOID SetRexxRC(struct RexxMsg *RMsg, LONG RC_Val)
{

  /* Set the variable RC in the current ARexx environment to the value
     RC_Val. */

  UBYTE *ArgString;
  struct RexxArg *RxArg;
  KPRINTF_HERE;

  ArgString = CVi2arg(RC_Val, 0);
  RxArg = (struct RexxArg *) (ArgString - 8);

  SetRexxVar((struct Message *) RMsg, "RC", ArgString, RxArg->ra_Length);
  DeleteArgstring(ArgString);

}

BOOL
PerformInit(VOID)
{
  BOOL RV = DOSTRUE;
  KPRINTF_HERE;

  RglsBase->rgls_DOSBase = (struct DosLibrary *)
    OpenLibrary( "dos.library", 37L);
  if (!RglsBase->rgls_DOSBase)
    RV = DOSFALSE;
  
  RglsBase->rgls_RexxSysBase = (struct RxsLib *)
    OpenLibrary( "rexxsyslib.library", 36L);
  if (!RglsBase->rgls_RexxSysBase)
    RV = DOSFALSE;
  
  RglsBase->rgls_UtilityBase = (struct UtilityBase *)
    OpenLibrary( "utility.library", 37L);
  if (!RglsBase->rgls_UtilityBase)
    RV = DOSFALSE;
  
  RglsBase->rgls_LocaleBase = (struct LocaleBase *)
    OpenLibrary( "locale.library", 37L);
  if (!RglsBase->rgls_LocaleBase)
    RV = DOSFALSE;

  if (RV == DOSFALSE)
    {
      if (RglsBase->rgls_DOSBase != NULL)
	CloseLibrary ((struct Library *)RglsBase->rgls_DOSBase);
      
      if (RglsBase->rgls_RexxSysBase != NULL)
	CloseLibrary ((struct Library *)RglsBase->rgls_RexxSysBase);
      
      if (RglsBase->rgls_UtilityBase != NULL)
	CloseLibrary ((struct Library *)RglsBase->rgls_UtilityBase);
      
      if (RglsBase->rgls_LocaleBase != NULL)
	CloseLibrary ((struct Library *)RglsBase->rgls_LocaleBase);
    }
  
  _UtilBase = RglsBase->rgls_UtilityBase;

  return (RV);
}


/* Since we dont link with the standard library, we'll have to provide
   the required math functions. The easy way around this problem, is
   utility.library/UDivMod32, which can handle our exact needs. */

__asm("
.globl  ___umodsi3
.globl  ___udivsi3
.even

| d1 = d0 % d1 (unsigned)

___umodsi3:	moveml sp@(4:w),d0/d1
jbsr udivsi3x
movel d1,d0
rts

| d1 = d0 / d1 (unsigned)
		
___udivsi3:	moveml sp@(4:w),d0/d1
udivsi3x:
movel __UtilBase,a0
jmp a0@(-0x9c:w)
");
