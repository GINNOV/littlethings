/* ------------------------------------------------------------------ */
/* $VER: Init.c 39.01 (12.12.1999)                                    */
/*                                                                    */
/* Easyaudio Library initializers and functions called by StartUp.c   */
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

/* our little header */
#include "compiler.h"

/* cos i use egcs */
#ifdef __GNUC__  
#include "../include/easyaudio/easyaudiobase.h"
#else
#include "/include/easyaudio/easyaudiobase.h"
#endif

ULONG __saveds __stdargs L_OpenLibs(struct EasyaudioBase *EasyaudioBase);
void  __saveds __stdargs L_CloseLibs(void);

struct ExecBase      *SysBase       = NULL;
struct IntuitionBase *IntuitionBase = NULL;
struct GfxBase       *GfxBase       = NULL;
struct DOSLibrary    *DOSBase       = NULL;
struct Library       *UtilityBase   = NULL;

#define VERSION  39
#define REVISION 01

#define EXLIBNAME "easyaudio"
#define EXLIBVER  "39.01 (12.12.99)"

char __aligned ExLibName [] = EXLIBNAME ".library";
char __aligned ExLibID   [] = EXLIBNAME EXLIBVER;
char __aligned Copyright [] = "(C)opyright 1999-2000 by Matthew J Fletcher, All rights reserved.";

char __aligned VERSTRING [] = "\0$VER: " EXLIBNAME EXLIBVER;

/* -----------------------------------------------------------------------
 ROMTag and Library inilitalization structure:

 Below you find the ROMTag, which is the most important "magic" part of a
 library (as for any other resident module). You should not need to modify
 any of the structures directly, since all the data is referenced from
 constants from somewhere else.

 You may place the ROMTag directly after the LibStart (-> StartUp.c)
 function as well.

 Note, that the data initialization structure may be somewhat redundant -
 it's for demonstration purposes.

 EndResident can be placed somewhere else - but it must follow the ROMTag
 and it must not be placed in a different SECTION.
 ----------------------------------------------------------------------- */

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
 &ExLibName[0],
 &ExLibID[0],
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

{
 INITBYTE(OFFSET(Node,         ln_Type),      NT_LIBRARY),
 0x80, (UBYTE) OFFSET(Node,    ln_Name),      (ULONG) &ExLibName[0],
 INITBYTE(OFFSET(Library,      lib_Flags),    LIBF_SUMUSED|LIBF_CHANGED),
 INITWORD(OFFSET(Library,      lib_Version),  VERSION),
 INITWORD(OFFSET(Library,      lib_Revision), REVISION),
 0x80, (UBYTE) OFFSET(Library, lib_IdString), (ULONG) &ExLibID[0],
 (ULONG) 0
};



/* ----------------------------------------------------------------------
 L_OpenLibs:

 Since this one is called by InitLib, libraries not shareable between
 Processes or libraries messing with RamLib (deadlock and crash) may not
 be opened here.

 You may bypass this by calling this function fromout LibOpen, but the you
 will have to a) protect it by a semaphore and b) make sure, that libraries
 are only opened once (when using global library bases).
 ----------------------------------------------------------------------- */

ULONG __saveds __stdargs L_OpenLibs(struct EasyaudioBase *EasyaudioBase)
{
 SysBase = (*((struct ExecBase **) 4));

 /* -------------------------- */
 /* we really want OS 3.x here */
 /* -------------------------- */

 IntuitionBase = (struct IntuitionBase *) OpenLibrary("intuition.library", 39);
 if(!IntuitionBase) return(FALSE);

 GfxBase = (struct GfxBase *) OpenLibrary("graphics.library", 39);
 if(!GfxBase) return(FALSE);

 DOSBase = (struct DOSLibrary *) OpenLibrary("dos.library", 39);
 if(!DOSBase) return(FALSE);

 UtilityBase = (struct Library *) OpenLibrary("utility.library", 39);
 if(!UtilityBase) return(FALSE);


 EasyaudioBase->eab_IntuitionBase = IntuitionBase;
 EasyaudioBase->eab_GfxBase       = GfxBase;
 EasyaudioBase->eab_DOSBase       = DOSBase;
 EasyaudioBase->eab_UtilityBase   = UtilityBase;
 EasyaudioBase->eab_SysBase       = SysBase;

 return(TRUE);
}

/* -------------------------------------------------------------------------
 L_CloseLibs:

 This one by default is called by ExpungeLib, which only can take place once
 and thus per definition is single-threaded.

 When calling this fromout LibClose instead, you will have to protect it by
 a semaphore, since you don't know whether a given CloseLibrary(foobase) may
 cause a Wait(). Additionally, there should be protection, that a library
 won't be closed twice.
 ------------------------------------------------------------------------- */

void __saveds __stdargs L_CloseLibs(void)
{
 if(UtilityBase)   CloseLibrary((struct Library *) UtilityBase);
 if(DOSBase)       CloseLibrary((struct Library *) DOSBase);
 if(GfxBase)       CloseLibrary((struct Library *) GfxBase);
 if(IntuitionBase) CloseLibrary((struct Library *) IntuitionBase);
}

/* ---------------------------------------------- */
/* YOU CANNOT CALL A LIBRARY AS AN EXECUTABLE !!! */
/* ---------------------------------------------- */
int main (void)
{
    printf("This is a library you cant run it,..!!!\n");
    exit(20);
}

/* thats it folks */
