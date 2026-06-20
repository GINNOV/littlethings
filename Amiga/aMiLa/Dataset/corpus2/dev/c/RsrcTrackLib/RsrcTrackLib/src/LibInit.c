/*
**      $VER: LibInit.c 37.0 (20.07.98)
**
**      Library initializers and functions to be called by StartUp.c
**
**      (C) Copyright 1998 Patrick BURNAND
**      All Rights Reserved.
**
**      Original code for the example.library done by Andreas R. Kleinert.
**      See Clib37x.lha on Aminet !
*/

#define __USE_SYSBASE        /* perhaps only recognized by SAS/C */

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <exec/resident.h>
#include <exec/initializers.h>

#ifdef __MAXON__
#include <clib/exec_protos.h>
#else
#include <proto/exec.h>
#endif
#include "compiler.h"

#ifdef __GNUC__
#include "../include/ressourcetracking/ressourcetrackingbase.h"
#elif VBCC
#include "include/ressourcetracking/ressourcetrackingbase.h"
#else
#include "/include/ressourcetracking/ressourcetrackingbase.h"
#endif

ULONG __saveds __stdargs L_OpenLibs(struct RessourceTrackingBase *RessourceTrackingBase);
void  __saveds __stdargs L_CloseLibs(void);

struct ExecBase      *SysBase       = NULL;
struct IntuitionBase *IntuitionBase = NULL;
struct GfxBase       *GfxBase       = NULL;
struct DOSBase       *DOSBase       = NULL;

#define VERSION  37
#define REVISION 0

char __aligned RtLibName [] = "ressourcetracking.library";
char __aligned RtLibID   [] = "ressourcetracking 37.0 (20.07.98)";
char __aligned Copyright [] = "(C)opyright 1998 by Patrick BURNAND. All rights reserved.";


/* ----------------------------------------------------------------------------------------
   ! ROMTag and Library inilitalization structure:
   !
   ! Below you find the ROMTag, which is the most important "magic" part of a library
   ! (as for any other resident module). You should not need to modify any of the
   ! structures directly, since all the data is referenced from constants from somewhere else.
   !
   ! You may place the ROMTag directly after the LibStart (-> StartUp.c) function as well.
   !
   ! Note, that the data initialization structure may be somewhat redundant - it's
   ! for demonstration purposes.
   !
   ! EndResident can be placed somewhere else - but it must follow the ROMTag and
   ! it must not be placed in a different SECTION.
   ---------------------------------------------------------------------------------------- */

extern ULONG InitTab[];
extern APTR EndResident; /* below */

struct Resident __aligned ROMTag =     /* do not change */
{
 RTC_MATCHWORD,
 &ROMTag,
 &EndResident,
 RTF_AUTOINIT,
 VERSION,
 NT_LIBRARY,
 0,
 &RtLibName[0],
 &RtLibID[0],
 &InitTab[0]
};

APTR EndResident;

struct MyDataInit                      /* do not change */
{
 UWORD ln_Type_Init;      UWORD ln_Type_Offset;      UWORD ln_Type_Content;
 UBYTE ln_Name_Init;      UBYTE ln_Name_Offset;      ULONG ln_Name_Content;
 UWORD lib_Flags_Init;    UWORD lib_Flags_Offset;    UWORD lib_Flags_Content;
 UWORD lib_Version_Init;  UWORD lib_Version_Offset;  UWORD lib_Version_Content;
 UWORD lib_Revision_Init; UWORD lib_Revision_Offset; UWORD lib_Revision_Content;
 UBYTE lib_IdString_Init; UBYTE lib_IdString_Offset; ULONG lib_IdString_Content;
 ULONG ENDMARK;
} DataTab =
#ifdef VBCC
{
        0xe000,8,NT_LIBRARY,
        0x0080,10,(ULONG) &RtLibName[0],
        0xe000,LIBF_SUMUSED|LIBF_CHANGED,
        0xd000,20,VERSION,
        0xd000,22,REVISION,
        0x80,24,(ULONG) &RtLibID[0],
        (ULONG) 0
};
#else
{
 INITBYTE(OFFSET(Node,         ln_Type),      NT_LIBRARY),
 0x80, (UBYTE) OFFSET(Node,    ln_Name),      (ULONG) &RtLibName[0],
 INITBYTE(OFFSET(Library,      lib_Flags),    LIBF_SUMUSED|LIBF_CHANGED),
 INITWORD(OFFSET(Library,      lib_Version),  VERSION),
 INITWORD(OFFSET(Library,      lib_Revision), REVISION),
 0x80, (UBYTE) OFFSET(Library, lib_IdString), (ULONG) &RtLibID[0],
 (ULONG) 0
};
#endif

/* ----------------------------------------------------------------------------------------
   ! L_OpenLibs:
   !
   ! Since this one is called by InitLib, libraries not shareable between Processes or
   ! libraries messing with RamLib (deadlock and crash) may not be opened here.
   !
   ! You may bypass this by calling this function fromout LibOpen, but then you will
   ! have to a) protect it by a semaphore and b) make sure, that libraries are only
   ! opened once (when using globa library bases).
   ---------------------------------------------------------------------------------------- */

ULONG __saveds __stdargs L_OpenLibs(struct RessourceTrackingBase *RessourceTrackingBase)
{
 SysBase = (*((struct ExecBase **) 4));

 IntuitionBase = (struct IntuitionBase *) OpenLibrary("intuition.library", 37);
 if(!IntuitionBase) return(FALSE);

 GfxBase = (struct GfxBase *) OpenLibrary("graphics.library", 37);
 if(!GfxBase) return(FALSE);

 DOSBase = (struct DOSBase *) OpenLibrary("dos.library", 37);
 if(!DOSBase) return(FALSE);

 RessourceTrackingBase->rtb_SysBase       = SysBase;
 RessourceTrackingBase->rtb_IntuitionBase = IntuitionBase;
 RessourceTrackingBase->rtb_GfxBase       = GfxBase;
 RessourceTrackingBase->rtb_DOSBase       = DOSBase;

 RessourceTrackingBase->rtb_TaskLstPtr = RessourceTrackingBase->rtb_LastTPtr = NULL;
 InitSemaphore (&RessourceTrackingBase->rtb_Semaphore);   /*  */

 return(TRUE);
}

/* ----------------------------------------------------------------------------------------
   ! L_CloseLibs:
   !
   ! This one by default is called by ExpungeLib, which only can take place once
   ! and thus per definition is single-threaded.
   !
   ! When calling this fromout LibClose instead, you will have to protect it by a
   ! semaphore, since you don't know whether a given CloseLibrary(foobase) may cause a Wait().
   ! Additionally, there should be protection, that a library won't be closed twice.
   ---------------------------------------------------------------------------------------- */

void __saveds __stdargs L_CloseLibs(void)
{
 if(DOSBase)       CloseLibrary((struct Library *) DOSBase);
 if(GfxBase)       CloseLibrary((struct Library *) GfxBase);
 if(IntuitionBase) CloseLibrary((struct Library *) IntuitionBase);
}
