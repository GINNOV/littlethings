/*
  $Id: libinit.c,v 1.2 1997/10/21 22:35:08 wegge Stab wegge $

  $Log: libinit.c,v $
  Revision 1.2  1997/10/21 22:35:08  wegge
  Snapshot inden upload af 2.13 i source og binær form

  Revision 1.1  1997/10/21 03:49:58  wegge
  Initial revision

 */

/* Definitions that are private to libint. */
#include "libinit_priv.h"
/* Library wide definitions. */
#include "rexx_gls.h"

/* Exit safely, is the library should happen to be executed. */

LONG FailOnRun(VOID)
{
  return (-1);
}

/*
 * The resident structure. 
 */

static const struct Resident RomTag =
{
  /* The magic cookie and pointer, that identifies this as a Resident
     structure.  */
  RTC_MATCHWORD,
  (struct Resident *) &RomTag,

  /* InitResident need a place to continue search, after looking at
     this structure. The rules say that we should point to a place
     after this Resident, but within the same section. */
  (APTR) ((&RomTag) + 1),	

  /* rt_Init has valid content  */
  RTF_AUTOINIT,

  /* Version, defined in libinit_priv.h */
  REXXGLS_VER,		

  /* This module is a library. */
  NT_LIBRARY,

  /* We don't need any special priority. */
  0,				/* No special priority needed. */

  /* This string *must* match the filename of the library. Otherwise
     Exec will (if we are lucky) load a new copy of this library for
     each OpenLibrary(). */
  (BYTE *) LibName,	

  /* This string is what Version and other similar tools will look
     for. */
  (BYTE *) LibIdString,

  /* Data for MakeLibrary. */
  (APTR) & InitTab	
};

/* InitResident() uses this table for initialization purposes. */

const APTR InitTab[4] =
{
  /* The size of the entire library base. */
  (APTR) sizeof(struct RexxGLSBase),

  /* The table of entrypoints to the library. */
  (APTR) &__rgls_functable__[0],
  
  /* We dont use InitStructs. */
  0L,

  /* Instead we do all initializing on our own. */
  (APTR) LibInit
};

/* Library Name & Version strings.  */

const BYTE LibName[] = REXXGLS_NAME;
const BYTE LibIdString[] = REXXGLS_VERSTAG;

/* Library init function called by MakeLibrary. */

struct Library *LibInit(APTR SegList __asm("a0"),
			struct RexxGLSBase *RglsBase __asm("d0"),
			struct ExecBase *ExecBase __asm("a6"))
{

  KPRINTF_HERE;
  
  /* We keep the SegList for the time we leave. */
  RglsBase->rgls_seglist = SegList;
  RglsBase->rgls_SYSBase = ExecBase;

  /*
   * Initialize our own Library base.
   */

  RglsBase->rgls_lib.lib_Node.ln_Type = NT_LIBRARY;
  RglsBase->rgls_lib.lib_Node.ln_Name = (UBYTE *) LibName;
  RglsBase->rgls_lib.lib_Flags = (LIBF_CHANGED | LIBF_SUMUSED);
  RglsBase->rgls_lib.lib_Version = (UWORD) REXXGLS_VER;
  RglsBase->rgls_lib.lib_Revision = (UWORD) REXXGLS_REV;
  RglsBase->rgls_lib.lib_IdString = (APTR) LibIdString;
  InitSemaphore(&RglsBase->RexxGLS_Sem);
  RglsBase->CookieCount=0;

  /* We are running in a forbidden state, so we can't open the needed
     libraries. Instead we NULL out the various bases, and open them
     when needed. */

  RglsBase->rgls_DOSBase = NULL;
  RglsBase->rgls_RexxSysBase = NULL;
  RglsBase->rgls_UtilityBase = NULL;
  RglsBase->rgls_LocaleBase = NULL;
 
  return ((struct Library *) RglsBase);

}

struct Library *LibOpen(struct  RexxGLSBase *RglsBase __asm("a6"))
{

/* Each time this library is OpenLibrary()'d, this function will be
   called. As for LibInit(), we are forbidden, so we limit the actions
   to updating the OpenCount and clearing the delayed expunge flag. */
  KPRINTF_HERE;

  RglsBase->rgls_lib.lib_Flags &= ~LIBF_DELEXP;
  RglsBase->rgls_lib.lib_OpenCnt++;

  return ((struct Library *) RglsBase);
}

/*
 * Each call of CloseLibrary() will result in a call of this function.
 */

APTR LibClose(struct  RexxGLSBase *RglsBase __asm("a6"))
{

/* Each time this library is CloseLibrary()'d, this function will be
   called. As for LibInit(), we are forbidden, so we limit the actions
   to updating the OpenCount, and removing ourselves if needed. */

  /* We return this to indicate whether or not we are gone. */
  APTR SegList = 0;
  KPRINTF_HERE;

  RglsBase->rgls_lib.lib_OpenCnt--;
  
  /* If usage count hits zero, and the delayed expunge flag is set, we
     should unload the library if possible. Note that this might not
     always be the case due to ARexx habit of opening and closing
     libraries at random. */

  if ((RglsBase->rgls_lib.lib_OpenCnt == 0) &&
      (RglsBase->rgls_lib.lib_Flags & LIBF_DELEXP))
    SegList = LibExpunge(RglsBase);

  /* Return seglist if LibExpunge unloaded us. Otherwise return NULL. */

  return (SegList);
}

/* Unload RglsBase if possible. */

APTR LibExpunge(struct RexxGLSBase *RglsBase __asm("a6"))
{

/* Each time the memory allocator need space, this function will be
   called. If we can, we unload ourselves, otherwise Exec will have to
   manage without our memory. */

  APTR SegList = 0;
  KPRINTF_HERE;

  /* Set the delayed expunge flag. */

  RglsBase->rgls_lib.lib_Flags |= LIBF_DELEXP;

  /* If OpenCount is zero, we might be able to unload, but only if
     there are no opened locales. */

  ObtainSemaphore(&RglsBase->RexxGLS_Sem);
  
  if ((RglsBase->rgls_lib.lib_OpenCnt == 0) &&
      (RglsBase->CookieCount == 0))
    {
      ULONG NegSize;

      /* Return the seglist, so UnLoadSeg() has something to work
	 on. */

      SegList = RglsBase->rgls_seglist;


      /* Remove RglsBase from SysBase->LibList. */

      Remove((struct Node *) RglsBase);

      /* Close any open libraries. */

      if (RglsBase->rgls_DOSBase != NULL)
	CloseLibrary((struct Library *)RglsBase->rgls_DOSBase);
      
      if (RglsBase->rgls_RexxSysBase != NULL)
	CloseLibrary((struct Library *)RglsBase->rgls_RexxSysBase);
      
      if (RglsBase->rgls_UtilityBase != NULL)
	CloseLibrary((struct Library *)RglsBase->rgls_UtilityBase);
      
      if (RglsBase->rgls_LocaleBase != NULL)
	CloseLibrary((struct Library *)RglsBase->rgls_LocaleBase);
      
      /* Free the Library base and vector table. */

      NegSize = RglsBase->rgls_lib.lib_NegSize;
      FreeMem((APTR) ((UBYTE *) RglsBase - (UBYTE *) NegSize), NegSize +
	      RglsBase->rgls_lib.lib_PosSize);
    }
  ReleaseSemaphore(&RglsBase->RexxGLS_Sem);

  return SegList;
}

/* This function is reserved for future compatibility. */

APTR LibExtFunc(struct  RexxGLSBase *RglsBase __asm("a6"))
{
  KPRINTF_HERE;

  /* We play by the rules, although it's tempting to return 42. */
  return (0);
}

/* List of functions in the library. */

const APTR __rgls_functable__[] =
{
  LibOpen,
  LibClose,
  LibExpunge,
  LibExtFunc,
  ArexxMatchPoint,
  (APTR) - 1L
};
