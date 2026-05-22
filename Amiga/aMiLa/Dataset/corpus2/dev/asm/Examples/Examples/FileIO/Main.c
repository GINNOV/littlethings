#include <functions.h>
#include <exec/types.h>
#include <exec/io.h>
#include <stdio.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include <intuition/intuitionbase.h>
#include <graphics/gfxbase.h>
#include "FileIO.h"

/* extern long GetMsg(), OpenWindow(), IoErr(), OpenLibrary(); */

/* === System Global Variables ========================================== */
struct IntuitionBase *IntuitionBase = 0L;
struct GfxBase       *GfxBase  = 0L;
struct DosLibrary    *DosBase  = 0L;
struct RequesterBase *RequesterBase = 0L;
struct FileIO        *myFileIO  = 0L;
struct FileIO        *myFileIO2 = 0L;
struct Window        *myWindow  = 0L;
struct Screen        *myScreen  = 0L;
ULONG  argcount;  /* Saves argc from main(). argcount==0, then run from WB. */

struct TextAttr  topaz80_font;

BOOL TestFileIO();

struct NewScreen NewFileIOScreen =
   {
   0, 0,           /* LeftEdge, TopEdge */
   640, 400,       /* Width, Height */
   2,              /* Depth */
   0, 1,           /* Detail/BlockPens */
   HIRES | LACE,   /* ViewPort Modes (must set/clear HIRES as needed) */
   CUSTOMSCREEN,
   &topaz80_font,  /* Font */
   (UBYTE *)"Example FileIO Program's Screen",
   0L,             /* Gadgets */
   0L,             /* CustomBitMap */
   };

struct NewWindow NewFileIOWindow =
   {
   168, 30,            /* LeftEdge, TopEdge */
   303, 145,          /* Width, Height */
   -1, -1,            /* Detail/BlockPens */
   MOUSEBUTTONS | CLOSEWINDOW | RAWKEY,
                      /* IDCMP Flags */
   WINDOWDRAG | WINDOWDEPTH | SIZEBRIGHT | SMART_REFRESH |
   WINDOWCLOSE | ACTIVATE | NOCAREREFRESH,
                      /* Window Specification Flags */
   0L,                /* FirstGadget */
   0L,                /* Checkmark */
   (UBYTE *)"FileIO Requester Window",  /* WindowTitle */
   0L,                /* Screen */
   0L,                /* SuperBitMap */
   303, 145,          /* MinWidth, MinHeight */
   600, 200,          /* MaxWidth, MaxHeight */
   WBENCHSCREEN,
   };


/************************ MAIN ROUTINE *****************************/

VOID main(argc, argv)
LONG argc;
char **argv;
{
   LONG   class;
   struct IntuiMessage *message;
   BOOL   end;

   argcount = argc;

   if (!(IntuitionBase = (struct IntuitionBase *)
      OpenLibrary("intuition.library", 0L)))
      exit_program("FileIO Demo: No intuition library. \n", 1L);

   if (!(GfxBase = (struct GfxBase *) OpenLibrary("graphics.library", 0L)))
      exit_program("FileIO Demo: No graphics library. \n", 2L);

   /* NOW OPEN THE REQUESTER LIBRARY */

   if (!(RequesterBase = (struct RequesterBase *)OpenLibrary("requester.library", 0L)))
      exit_program("FileIO Demo: No requester library. \n", 4L);

   if (argv)
      {
      /* OK, we started from CLI */
      if (argc > 1)
         {
         if (myScreen = OpenScreen(&NewFileIOScreen))
            {
            NewFileIOWindow.Screen = myScreen;
            NewFileIOWindow.Type = CUSTOMSCREEN;
            }
         }
      }

   if (!(myWindow = (struct Window *) OpenWindow( &NewFileIOWindow ) ))
      exit_program("FileIO Demo: Null Window.\n", 5L);

 /* GET 2 FileIO STRUCTURES */

   if (!(myFileIO = GetFileIO() ))
      exit_program("FileIO Demo: No FileIO 1.\n", 6L);

   if (!(myFileIO2 = GetFileIO() ))
      exit_program("FileIO Demo: No FileIO 2.\n", 7L);

  /* Set up the XY co-ordinates where the requester should open */

  myFileIO->X = 6;
  myFileIO->Y = 11;

  myFileIO2->X = 6;
  myFileIO2->Y = 11;

 /* Set default colors and DrawMode */
  myFileIO->DrawMode = JAM2;
  myFileIO->PenA = 1;
  myFileIO->PenB = 0;
  myFileIO2->DrawMode = JAM2;
  myFileIO2->PenA = 1;
  myFileIO2->PenB = 0;

          /* pretty easy to set up, eh?  */

   end = FALSE;

   SetFlag(myFileIO2->Flags, WBENCH_MATCH | MATCH_OBJECTTYPE);
   myFileIO2->MatchType = WBTOOL;
   SetFlag(myFileIO2->Flags, USE_DEVICE_NAMES);


   while (end == FALSE)
    {
      WaitPort(myWindow->UserPort);

      while (message = ( struct IntuiMessage *)GetMsg(myWindow->UserPort))
       {
         class = message->Class;
         ReplyMsg(message);

         switch (class)
          {
            case CLOSEWINDOW:
               end = TRUE;
               break;
            case DISKINSERTED:
               /* You should clear the NO_CARE_REDRAW flag whenever you
                * detect that a new disk was inserted (if using this feature).
                  We aren't using it, so comment it out.
               ClearFlag(myFileIO->Flags, NO_CARE_REDRAW);
               ClearFlag(myFileIO2->Flags, NO_CARE_REDRAW);
                */
               break;
            case MOUSEBUTTONS:
               if (TestFileIO(myFileIO, myWindow))
                 {
                  /*
                  ClearFlag(myFileIO->Flags, NO_CARE_REDRAW);
                  ClearFlag(myFileIO2->Flags, NO_CARE_REDRAW);
                  */
                 }
               break;
            case RAWKEY:
               if (TestFileIO(myFileIO2, myWindow))
                {
                  /*
                  ClearFlag(myFileIO->Flags, NO_CARE_REDRAW);
                  ClearFlag(myFileIO2->Flags, NO_CARE_REDRAW);
                  */
                }
               break;
            default:
               break;
          }
       }
    }
  exit_program( 0L, 0L);
}



exit_program( error_words, error_code )      /* All exits through here. */
char  error_words;
ULONG error_code;
{
   if( argcount && error_words ) puts( error_words );
   if (myFileIO)  ReleaseFileIO(myFileIO);
   if (myFileIO2) ReleaseFileIO(myFileIO2);

   if (myWindow) CloseWindow(myWindow);
   if (myScreen) CloseScreen(myScreen);

   if (IntuitionBase) CloseLibrary(IntuitionBase);
   if (GfxBase)       CloseLibrary(GfxBase);
   if (DosBase)       CloseLibrary(DosBase);
   if (RequesterBase) CloseLibrary(RequesterBase);
   exit( error_code );
}



BOOL TestFileIO(fileio, wind)
struct FileIO *fileio;
struct Window *wind;
{
 ULONG address;

/* This guy calls DoFileIO(), displays the file name selected by the
 * user, and returns TRUE if the user swapped disks during DoFileIO()
 * (else returns FALSE) if an error, CANCEL, or no disk swap.
 */
   UBYTE buffer[80];

   fileio->Buffer = buffer;

   address = DoFileIO(fileio, wind);

   if( address == (ULONG)buffer )
      {
      /* If user was positive and no error, display the name */
      AutoMessage( buffer, wind);
      }

   if (!address)    AutoMessage("Error in operation", wind);
   if (address==-1) AutoMessage("Cancelled operation", wind);

   if (FlagIsSet(fileio->Flags, DISK_HAS_CHANGED))
      {
      ClearFlag(fileio->Flags, DISK_HAS_CHANGED);
      return(TRUE);
      }
   else
     return(FALSE);
}
