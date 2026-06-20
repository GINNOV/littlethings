/*
**     $VER: OpenCloseLibs.c V0.01 (13-06-95)
**
**     Author:  Gerben Venekamp
**     Updates: 13-06-95  Version 0.01    Initial module
**
**
**  OpenCloseLibs.c contains the basic routines to open and close libraries.
**
*/

#include <intuition/intuition.h>
#include <proto/exec.h>
#include <proto/intuition.h>

#include "IFFConverter.h"


// Define Variables
struct IntuitionBase *IntuitionBase = NULL;
struct DosLibrary    *DOSBase       = NULL;
struct Library       *GadToolsBase  = NULL;
struct Library       *AslBase       = NULL;
struct Library       *IFFParseBase  = NULL;
struct GfxBase       *GfxBase       = NULL;
struct Library       *DiskfontBase  = NULL;
struct Library       *IconBase      = NULL;


// Define protos
void OpenLibraries(void);
void CloseLibraries(void);


/*
**  OpenLibraries()
**
**     Open a hole bunch of libraries, just for you.
**     Libraries attempted to open are:
**        · Intuition
**        · Dos
**        · Gadtools
**        · Asl
**        · IFFParse
**        · Graphics
**        · Diskfont
**        · Icon
**
**  pre:  None.
**  post: None.
**
*/
void OpenLibraries()
{
// Try to open intuition.library
   if(!(IntuitionBase = (struct IntuitionBase *) OpenLibrary("intuition.library", Lib_Version)))
   {   // Couldn't open intuirion.library Lib_Version. Try to open ANY version.
      if(IntuitionBase = (struct IntuitionBase *) OpenLibrary("intuition.library", 0L))
      {
         struct IntuiText AR_ErrorMessage = {
            0, 1, JAM2, 20, 8, NULL,
            (UBYTE *)"I Need intuition.library V" Lib_VersionQ "+", NULL
         };
         struct IntuiText AR_NegText = {
            0, 1, JAM2, 6, 4, NULL,
            (UBYTE *)"Right", NULL
         };
         
         AutoRequest(NULL, &AR_ErrorMessage, NULL, &AR_NegText, 0, 0, 60, 30);
      }
      ErrorHandler( IFFerror_NoIntuition, NULL );
   }

// Try to open dos.library   
   if(!(DOSBase = (struct DosLibrary *)OpenLibrary("dos.library", Lib_Version)))
      ErrorHandler( IFFerror_NoLibrary, "dos", Lib_Version );

// Try to open gadtools.library
   if(!(GadToolsBase = OpenLibrary("gadtools.library", Lib_Version)))
      ErrorHandler( IFFerror_NoLibrary, "gadtools", Lib_Version);

// Try to open asl.library
   if(!(AslBase = OpenLibrary("asl.library", Lib_Version)))
      ErrorHandler( IFFerror_NoLibrary, "asl", Lib_Version );

// Try to open iffparse.library
   if(!(IFFParseBase = OpenLibrary("iffparse.library", Lib_Version)))
      ErrorHandler( IFFerror_NoLibrary, "iffparse", Lib_Version );

// Try to open graphics.library
   if(!(GfxBase = (struct GfxBase*)OpenLibrary("graphics.library", Lib_Version)))
      ErrorHandler( IFFerror_NoLibrary, "graphics", Lib_Version );

// Try to open diskfont.library
   if(!(DiskfontBase = OpenLibrary("diskfont.library", Lib_Version)))
      ErrorHandler( IFFerror_NoLibrary, "diskfont", Lib_Version );

// Try to open icon.library
   if(!(IconBase = OpenLibrary("icon.library", Lib_Version)))
      ErrorHandler( IFFerror_NoLibrary, "icon", Lib_Version );
   
}


/*
**  CloseLibraries()
**
**     Here we close all the libraries that we've opend.
**     The nomenies are:
**        · Intuition
**        · Dos
**        · Gadtools
**        · Asl
**        · IFFParse
**        · Graphics
**        · Diskfont
**        · Icon
**
**  pre:  None.
**  post: None.
**
*/
void CloseLibraries()
{
   if(IntuitionBase) CloseLibrary((struct Library *)IntuitionBase);
   if(DOSBase)       CloseLibrary((struct Library *)DOSBase);
   if(GadToolsBase)  CloseLibrary((struct Library *)GadToolsBase);
   if(AslBase)       CloseLibrary((struct Library *)AslBase);
   if(IFFParseBase)  CloseLibrary((struct Library *)IFFParseBase);
   if(GfxBase)       CloseLibrary((struct Library *)GfxBase);
   if(DiskfontBase)  CloseLibrary((struct Library *)DiskfontBase);
   if(IconBase )     CloseLibrary((struct Library *)IconBase);
}
