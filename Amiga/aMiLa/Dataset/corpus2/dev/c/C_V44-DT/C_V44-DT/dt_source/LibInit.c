/*
**      $VER: LibInit.c 44.1 (11.2.2006)
**
**      Library initializers and functions to be called by StartUp.c
**
**      (C) Copyright 1996-2006 Andreas R. Kleinert
**      All Rights Reserved.
*/

#define __USE_SYSBASE

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <exec/resident.h>
#include <exec/initializers.h>
#include <datatypes/pictureclass.h>

#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/datatypes.h>

#include <class/classbase.h>
#include "libfuncs.h"


ULONG __saveds __stdargs L_OpenLibs(void);
void  __saveds __stdargs L_CloseLibs(void);

extern struct ClassBase *ClassBase;


struct ExecBase      *SysBase        = NULL;
struct DosLibrary    *DOSBase        = NULL;
struct IntuitionBase *IntuitionBase  = NULL;
struct GfxBase       *GfxBase        = NULL;
struct Library       *UtilityBase    = NULL;
struct Library       *DataTypesBase  = NULL;
struct Library       *SuperClassBase = NULL;
struct Library       *IFFParseBase   = NULL;


#define VERSION  44
#define REVISION 2

char __aligned ExLibName [] = "samplePNM.datatype";
char __aligned ExLibID   [] = "samplePNM 44.2 (18.3.2008)";
char __aligned Copyright [] = "(C)opyright 1996-2008 by Andreas R. Kleinert. All rights reserved.";

extern ULONG InitTab[];

extern APTR EndResident; /* below */

struct Resident __aligned ROMTag =
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

 /* Libraries not shareable between Processes or libraries messing
    with RamLib (deadlock and crash) may not be opened here - open/close
    these later locally and or maybe close them fromout L_CloseLibs()
    when expunging !

    iffparse.library e.g. *should* not matter here, since our base class
    (picture.datatype) will have opened it before
 */

ULONG __saveds __stdargs L_OpenLibs(void)
{
 SysBase = (*((struct ExecBase **) 4));

 DOSBase = (struct DosLibrary *) OpenLibrary("dos.library", 39);
 if(!DOSBase) return(FALSE);

 IntuitionBase = (struct IntuitionBase *) OpenLibrary("intuition.library", 39);
 if(!IntuitionBase) return(FALSE);

 GfxBase = (struct GfxBase *) OpenLibrary("graphics.library", 39);
 if(!GfxBase) return(FALSE);

 UtilityBase = (struct Library *) OpenLibrary("utility.library", 39);
 if(!UtilityBase) return(FALSE);

 DataTypesBase = (struct Library *) OpenLibrary("datatypes.library", 39);
 if(!DataTypesBase) return(FALSE);

 SuperClassBase = (struct Library *) OpenLibrary("datatypes/picture.datatype", 39);
 if(!SuperClassBase) return(FALSE);

 IFFParseBase = (struct Library *) OpenLibrary("iffparse.library", 37);
 if(!IFFParseBase) return(FALSE);

 InitSemaphore(&ClassBase->cb_DTSemaphore);

 ClassBase->cb_SysBase        = (struct ExecBase      *) SysBase;

 ClassBase->cb_DOSBase        = (struct DosLibrary    *) DOSBase;
 ClassBase->cb_IntuitionBase  = (struct IntuitionBase *) IntuitionBase;
 ClassBase->cb_GfxBase        = (struct GfxBase       *) GfxBase;
 ClassBase->cb_UtilityBase    = (struct Library       *) UtilityBase;
 ClassBase->cb_DataTypesBase  = (struct Library       *) DataTypesBase;
 ClassBase->cb_SuperClassBase = (struct Library       *) SuperClassBase;
 ClassBase->cb_IFFParseBase   = (struct Library       *) IFFParseBase;

 ClassBase->cb_Methods        = NULL;

 if(ClassBase->cb_Class = initClass(ClassBase)) return(TRUE);

 return(FALSE);
}

void __saveds __stdargs L_CloseLibs(void)
{
 if(ClassBase->cb_Class)   FreeClass(ClassBase->cb_Class);

 if(ClassBase->cb_Methods) FreeVec(ClassBase->cb_Methods);

 if(IFFParseBase)   CloseLibrary((struct Library *) IFFParseBase);
 if(SuperClassBase) CloseLibrary((struct Library *) SuperClassBase);
 if(DataTypesBase)  CloseLibrary((struct Library *) DataTypesBase);
 if(UtilityBase)    CloseLibrary((struct Library *) UtilityBase);
 if(GfxBase)        CloseLibrary((struct Library *) GfxBase);
 if(IntuitionBase)  CloseLibrary((struct Library *) IntuitionBase);
 if(DOSBase)        CloseLibrary((struct Library *) DOSBase);
}
