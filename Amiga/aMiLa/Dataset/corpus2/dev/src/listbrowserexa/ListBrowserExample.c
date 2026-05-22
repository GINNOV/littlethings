/****h* ListBrowserExample.c [2.0] **********************************************
*
* NAME
*    ListBrowserExample.c -- List Browser class test.
*
* DESCRIPTION
*    This is a simple example testing some of the capabilities of the
*    ListBrowser gadget class.
*
*    This is a good example how to use Reaction classes like simple BOOPSI
*    classes and how to use it without window.class and the full ReAction
*    environment and layouter.
*
*    This code opens a simple window and then a ListBrowser gadget which is
*    subsequently attached to the window's gadget list.  Everytime the user
*    clicks on the close gadget, this code changes some of the attributes
*    of the ListBrowser gadget to demonstrate different ways it can be used,
*    including one demonstration which creates two images using the Label
*    class and shows them in the ListBrowser.
*
* NOTES
*    The original code has been refactored to:
*    a. MAKE IT READABLE
*    b. MAKE IT UNDERSTANDABLE (see a.)
*    by James T. Steichen:  http://www.frontiernet.net/~jimbot
*
*       Please folks, DO NOT follow Commodore's (Amiga Inc.) coding examples & 
*       nest your if statements 8 levels deep.  It just makes it harder to under-
*       stand your code and a pain in the butt to refactor.  I defy anyone to
*       assert that the code in this file is harder to understand than the
*       original source code.
*********************************************************************************
*
*/

#include <string.h>
#include <stdio.h>

#include <exec/types.h>
#include <exec/memory.h>

#include <AmigaDOSErrs.h>             // For RETURN_OK, PRIVATE, etc.

#include <intuition/intuition.h>
#include <intuition/gadgetclass.h>
#include <intuition/imageclass.h>
#include <intuition/icclass.h>

#include <utility/tagitem.h>          // Only necessary for the definition of struct TagItem 

#include <graphics/rastport.h>        // For JAM1, JAM2, etc

#include <gadgets/listbrowser.h>

#include <images/label.h>

#include <reaction/reaction_macros.h> // VLayoutObject, etc.

#ifdef   __amigaos4__

# define __USE_INLINE__

#else

# include <clib/alib_protos.h> // Probably not necessary for AmigaOS4.

#endif

#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/listbrowser.h>
#include <proto/label.h>

#define RAWKEY_CURSORUP   76
#define RAWKEY_CURSORDOWN 77
#define QUALIFIER_SHIFT   0x03
#define QUALIFIER_ALT     0x30
#define QUALIFIER_CTRL    0x08

#ifdef __amigaos4__

extern struct Library *IntuitionBase;
extern struct Library *SysBase;

extern struct IntuitionIFace *IIntuition;
extern struct ExecIFace      *IExec;

PRIVATE struct Library *ListBrowserBase;
PRIVATE struct Library *LabelBase;

PRIVATE struct ListBrowserIFace *IListBrowser;
PRIVATE struct LabelIFace       *ILabel;

/*
** CommonFuncsPPC.o support.  There are currently no functions from CommonFuncsPPC.o used
** in this example; however, if you want to, you can find CommonFuncsPPC.lha at
** http://www.os4depot.net/share/development/misc/commonfuncsppc.lha or on aminet
** at:  http://wuarchive.wustl.edu/pub/aminet/dev/c/commonfuncs.lha
**
# include "CPGM:GlobalObjects/CommonFuncs.h"

PUBLIC struct Library       *GadToolsBase;
PUBLIC struct GadToolsIFace *IGadTools;
*/

#else

struct IntuitionBase *IntuitionBase; // SAS-C should not need this to automatically open intuition.library
struct Library       *ListBrowserBase;
struct Library       *LabelBase;

#endif

#define GD_PClassStr     0
//#define GD_CNameStr      1
//#define GD_FNameStr      2
//#define GD_MethodsTE     3
//#define GD_IVarsTE       4
#define GD_ClassLV       5    // Only Gadget in this example.
//#define GD_AddClassBt    6
//#define GD_CancelBt      7

// Long list for testing the scroller keys functionality:

PRIVATE UBYTE *testClasses[] =
{
   "This is a", "test of the", "ListBrowser", "gadget class.",
   "This is like", "a souped-up", "listview", "gadget.  It", "has many",
   "cool new", "features", "though like", "multiple", "columns,",
   "horizontal", "scrolling,", "images in", "nodes,", "columns titles",
   "and much much", "more!",
   "This is a", "test of the", "ListBrowser", "gadget class.",
   "This is like", "a souped-up", "listview", "gadget.  It", "has many",
   "cool new", "features", "though like", "multiple", "columns,",
   "horizontal", "scrolling,", "images in", "nodes,", "columns titles",
   "and much much", "more!",
   "This is a", "test of the", "ListBrowser", "gadget class.",
   "This is like", "a souped-up", "listview", "gadget.  It", "has many",
   "cool new", "features", "though like", "multiple", "columns,",
   "horizontal", "scrolling,", "images in", "nodes,", "columns titles",
   "and much much", "more!", NULL
};

PRIVATE struct ColumnInfo fancy_ci[] = {

   { 100, NULL, 0 },
   { -1, (STRPTR)~0, -1 }
};

/* Some fonts for our fancy list.  */

PRIVATE struct TextAttr helvetica24b = { "helvetica.font", 24, FSF_BOLD, FPF_DISKFONT };
PRIVATE struct TextAttr times18i     = { "times.font",     18, FSF_ITALIC, FPF_DISKFONT };
PRIVATE struct TextAttr times18      = { "times.font",     18, 0, FPF_DISKFONT };

PRIVATE struct DrawInfo *dri     = NULL;
PRIVATE struct Screen   *Scr     = NULL;
PRIVATE struct Window   *ACRWnd  = NULL;
PRIVATE struct Gadget   *ClassLV = NULL;
PRIVATE struct List      classList;

PRIVATE UWORD ACRTop    = 0;
PRIVATE UWORD ACRLeft   = 0;
PRIVATE UWORD ACRWidth  = 800; // 790
PRIVATE UWORD ACRHeight = 600; // 575

/* Normally I would add a header comment to each function in my source code, but the
** names of the function explain just what each function does, making such comments
** unnecessary.
*/

PRIVATE void freeListBrowserNodes( struct List *list ) // list is an Exec-type list
{
   struct Node *node, *nextnode;

   if (!list) // == NULL)
      return; // No point in continuing
      
   node = list->lh_Head;

   while (nextnode = node->ln_Succ) // != NULL)
      {
      FreeListBrowserNode( node );

      node = nextnode;
      }

   return;
}

/* Function to make a List of ListBrowserNodes from an array of strings. */

PRIVATE BOOL makeListBrowserNodes( struct List *list, UBYTE **labels )
{
   struct Node *node = NULL;
   WORD         i    = 0;
   BOOL         rval = TRUE;
   
   NewList( list );

   while (*labels) // != NULL)
      {
      if (node = AllocListBrowserNode( 1, LBNCA_CopyText, TRUE,
                                          LBNCA_Text,     *labels,
                                          LBNCA_MaxChars, 80,
                                          LBNCA_Editable, TRUE,
                                          TAG_DONE )) // != NULL)
         {
         AddTail( list, node );
         }
      else
         {
         freeListBrowserNodes( list ); // Free what's been done so far!
	 
	 rval = FALSE;   
         break;
	 }

      labels++;
      i++;
      }

   return( rval );
}

PRIVATE void HandleACRIDCMP( struct Window *win, struct Gadget *ClassLV )
{
   BOOL running = TRUE;

   while (running == TRUE)
      {
      struct Gadget       *gadget;
      struct IntuiMessage *imsg;
         
      WaitPort( win->UserPort );
      
      while (imsg = (struct IntuiMessage *) GetMsg( win->UserPort )) // != NULL)
         {
         switch (imsg->Class)
            {
            case IDCMP_CLOSEWINDOW:
               running = FALSE;
               break;

            case IDCMP_GADGETUP:
               gadget = (struct Gadget *) imsg->IAddress;

               Printf( "Gadget: %ld  Code: %ld\n", (LONG) gadget->GadgetID, (LONG) imsg->Code );

               break;

            case IDCMP_RAWKEY:
               if (!(imsg->Code & IECODE_UP_PREFIX)) // == 0)
                  {
                  switch (imsg->Code)
                     {
                     case RAWKEY_CURSORUP:
                        if (imsg->Qualifier & QUALIFIER_CTRL) // != 0)
                           SetGadgetAttrs( ClassLV, win, NULL,
                                                            LISTBROWSER_Position, LBP_TOP,
                                                            TAG_DONE
				         );

                        if (imsg->Qualifier & QUALIFIER_SHIFT) // != 0)
                           SetGadgetAttrs( ClassLV, win, NULL,
                                                            LISTBROWSER_Position, LBP_PAGEUP,
                                                            TAG_DONE
				         );
                        else
                           SetGadgetAttrs( ClassLV, win, NULL,
                                                            LISTBROWSER_Position, LBP_LINEUP,
                                                            TAG_DONE
				         );
                        break;

                     case RAWKEY_CURSORDOWN:
                        if (imsg->Qualifier & QUALIFIER_CTRL) // != 0)
                           SetGadgetAttrs( ClassLV, win, NULL,
                                                            LISTBROWSER_Position, LBP_BOTTOM,
                                                            TAG_DONE
				         );

                        if (imsg->Qualifier & QUALIFIER_SHIFT) // != 0)
                           SetGadgetAttrs( ClassLV, win, NULL,
                                                            LISTBROWSER_Position, LBP_PAGEDOWN,
                                                            TAG_DONE
				         );
                        else
                           SetGadgetAttrs( ClassLV, win, NULL,
                                                            LISTBROWSER_Position, LBP_LINEDOWN,
                                                            TAG_DONE
				         );
                        break;

                     default:
                        break;
                     }
                  }
               break;
      
            default:
               break;
            }
   
         ReplyMsg( (struct Message *) imsg );
         }
      }

   return;
}

PRIVATE int displayClassLabel( int x, int y, int w )
{
   struct IntuiText classText;
   int    left, top;
   
   classText.FrontPen  = dri->dri_Pens[ TEXTPEN ];
   classText.BackPen   = dri->dri_Pens[ BACKGROUNDPEN ];
   classText.IText     = "Classes:";
   classText.DrawMode  = JAM1;
   classText.ITextFont = &times18;
   classText.NextText  = NULL;
      
   left = x + (w - IntuiTextLength( &classText )) / 2;
   top  = y - times18.ta_YSize;

//   fprintf( stderr, "Label Coords: (%d, %d)\n", left, top );

   classText.LeftEdge  = left;
   classText.TopEdge   = top;

   PrintIText( ACRWnd->RPort, &classText, 0, 0 );
   
   return( RETURN_OK );
}

PRIVATE int createListView( void )
{
   if (ClassLV = (struct Gadget *)
        NewObject( LISTBROWSER_GetClass(), NULL,
            GA_ID,                    GD_PClassStr,
            GA_Left,                  390,                                   // 10,
            GA_Top,                   Scr->BarHeight + times18.ta_YSize + 5, // ACRWnd->BorderTop + 5,
            GA_Width,                 400,
	    GA_Height,                480,
/*
            GA_RelWidth,              -34,
            GA_RelHeight,             -(ACRWnd->BorderTop + ACRWnd->BorderBottom + 10),
*/
            GA_RelVerify,             TRUE,
            LISTBROWSER_Labels,       (ULONG) &classList,
            LISTBROWSER_MultiSelect,  FALSE,
            LISTBROWSER_ShowSelected, TRUE,
            LISTBROWSER_Editable,     TRUE,

            TAG_END )) // != NULL)
      {
      (void) displayClassLabel( 390, Scr->BarHeight + times18.ta_YSize + 5, 400 ); // ACRWnd->BorderTop + 5, 400 );
      
      return( RETURN_OK );
      }
   else
      return( RETURN_FAIL );
}

PRIVATE void closeLibraries( void )
{
#  ifdef __amigaos4__
   if (IListBrowser) // != NULL)
      DropInterface( (struct Interface *) IListBrowser );

   if (ILabel)       // != NULL)
      DropInterface( (struct Interface *) ILabel );
/*
   CommonFuncsPPC.o support.  There are currently no functions from CommonFuncsPPC.o used
   in this example; however, if you want to, you can find CommonFuncsPPC.lha at
   http://www.os4depot.net/share/development/misc/commonfuncsppc.lha or on aminet
   at:  http://wuarchive.wustl.edu/pub/aminet/dev/c/commonfuncs.lha

   if (IGadTools)
      DropInterface( (struct Interface *) IGadTools );

   if (GadToolsBase)
      CloseLibrary( GadToolsBase );
*/
#  endif

   if (ListBrowserBase) // != NULL)
      CloseLibrary( ListBrowserBase );

   if (LabelBase)       // != NULL)
      CloseLibrary( LabelBase );

   return;
}

PRIVATE int openLibraries( void )
{
   int rval = RETURN_OK;

#  ifdef __amigaos4__
   ULONG libVersion = 50L;
#  else
   ULONG libVersion = 44L; // Original value from the source code.
#  endif
   
   if (ListBrowserBase = OpenLibrary( "gadgets/listbrowser.gadget", libVersion )) // != NULL)
      {
#     ifdef __amigaos4__
      if (!(IListBrowser = (struct ListBrowserIFace *) GetInterface( ListBrowserBase, "main", 1, NULL )))
         {
         PutStr( "IListBrowser.IFace did NOT open!" );

	 rval = ERROR_INVALID_RESIDENT_LIBRARY;
	 
	 closeLibraries();

	 goto ExitOpenLibraries;
         }
#     endif
      }
   else
      {
      PutStr( "ERROR: Could NOT open ListBrowser.gadget\n" );

      rval = ERROR_INVALID_RESIDENT_LIBRARY;

      closeLibraries();
      
      goto ExitOpenLibraries;
      }

   if (LabelBase = OpenLibrary("images/label.image", libVersion ))
      {
#     ifdef __amigaos4__
      if (!(ILabel = (struct LabelIFace *) GetInterface( LabelBase, "main", 1, NULL )))
         {
         PutStr( "ILabel.IFace did NOT open!" );

	 rval = ERROR_INVALID_RESIDENT_LIBRARY;
	 
	 closeLibraries();

	 goto ExitOpenLibraries;
         }
#     endif
      }
   else
      {
      PutStr( "ERROR: Could NOT open label.image\n" );

      rval = ERROR_INVALID_RESIDENT_LIBRARY;

      closeLibraries();
      
      goto ExitOpenLibraries;
      }

/* 
   CommonFuncsPPC.o support.  There are currently no functions from CommonFuncsPPC.o used
   in this example; however, if you want to, you can find CommonFuncsPPC.lha at
   http://www.os4depot.net/share/development/misc/commonfuncsppc.lha or on aminet
   at:  http://wuarchive.wustl.edu/pub/aminet/dev/c/commonfuncs.lha
   
#  ifdef __amigaos4__
   if (GadToolsBase = OpenLibrary( "gadtools.library", libVersion ))
      {
      if (!(IGadTools = (struct GadToolsIFace *) GetInterface( GadToolsBase, "main", 1, NULL )))
         {
         PutStr( "IGadTools.IFace did NOT open!" );

	 rval = ERROR_INVALID_RESIDENT_LIBRARY;
	 
	 closeLibraries();

	 goto ExitOpenLibraries;
         }
      }
   else
      {
      PutStr( "ERROR: Could NOT open gadtools.library\n" );

      rval = ERROR_INVALID_RESIDENT_LIBRARY;

      closeLibraries();
      
      goto ExitOpenLibraries;
      }
#  endif
*/

ExitOpenLibraries:

   return( rval );
}

PRIVATE void ShutdownProgram( BOOL madeList )
{
   if (madeList == TRUE)
      freeListBrowserNodes( &classList );

   closeLibraries();

   if (ACRWnd) // != NULL)
      CloseWindow( ACRWnd );

   if (dri)    // != NULL)
      FreeScreenDrawInfo( Scr, dri );
    
   if (Scr)    // != NULL)
      UnlockPubScreen( 0, Scr );
      
   return;
}

PRIVATE int SetupProgram( char *pgmName )
{
   int rval = RETURN_OK;

   if ((rval = openLibraries()) != RETURN_OK)
      {
      goto ExitSetup;
      }

   if (!(Scr = LockPubScreen( NULL ))) // == NULL)
      {
      PutStr( "ERROR: Could NOT lock public screen\n" );
      
      ShutdownProgram( FALSE );
      
      goto ExitSetup;
      }
   else
      {
      dri = GetScreenDrawInfo( Scr ); // For Pens & labels, etc.
      
      ACRTop  = (Scr->Height - ACRHeight) / 2; // Center the window in the Screen.
      ACRLeft = (Scr->Width  - ACRWidth ) / 2;
      }

   // Open the window:

   if (!(ACRWnd = OpenWindowTags( NULL,

            WA_Left,         ACRTop,    // 0,
            WA_Top,          ACRLeft,   // Scr->Font->ta_YSize + 3,
            WA_Width,        ACRWidth,  // 300,
            WA_Height,       ACRHeight, // 160,
            WA_CustomScreen, Scr,

            WA_IDCMP,        IDCMP_GADGETUP | IDCMP_MOUSEMOVE | IDCMP_RAWKEY
              | IDCMP_CLOSEWINDOW | IDCMP_GADGETDOWN,

            WA_Flags,        WFLG_DRAGBAR | WFLG_DEPTHGADGET | WFLG_CLOSEGADGET 
	      | WFLG_ACTIVATE | WFLG_SMART_REFRESH,

            WA_Title,        "ListBrowser Class Demo",
            WA_MinWidth,     50,
            WA_MinHeight,    50,
            WA_MaxWidth,     -1,
            WA_MaxHeight,    -1,

            TAG_DONE ))) // == NULL)
      {
      PutStr( "ERROR: Could NOT open window\n" );

      ShutdownProgram( FALSE );
      
      goto ExitSetup;
      }

ExitSetup:

   return( rval );
}

PRIVATE void doMakeVisible( void )
{
   SetWindowTitles( ACRWnd, "Make the 10th node Visible:", (UBYTE *) ~0 );

   SetGadgetAttrs( ClassLV, ACRWnd, NULL,
                            LISTBROWSER_MakeVisible, 10,
                            LISTBROWSER_EditNode,    8,
                            LISTBROWSER_EditColumn,  1,
                            TAG_DONE
	         );

   ActivateGadget( ClassLV, ACRWnd, NULL );

   HandleACRIDCMP( ACRWnd, ClassLV );

   return;
}

PRIVATE void doShowSelectedAutoFit( void )
{	    
   SetWindowTitles( ACRWnd, "Show selected, Auto-Fit", (UBYTE *) ~0 );

   SetGadgetAttrs( ClassLV, ACRWnd, NULL,
                            LISTBROWSER_ShowSelected,   TRUE,
                            LISTBROWSER_AutoFit,        TRUE,
                            LISTBROWSER_HorizontalProp, TRUE,
                            TAG_DONE
                 );

   HandleACRIDCMP( ACRWnd, ClassLV );
   
   return;
}

PRIVATE void doMultiSelect_VirtualWidth( void )
{
   SetWindowTitles( ACRWnd, "Multi-select, Virtual Width of 500", (UBYTE *) ~0 );

   SetGadgetAttrs( ClassLV, ACRWnd, NULL,
                            LISTBROWSER_MultiSelect,  TRUE,
                            LISTBROWSER_VirtualWidth, 500,
                            LISTBROWSER_AutoFit,      FALSE,
                            TAG_DONE
                 );

   HandleACRIDCMP( ACRWnd, ClassLV );
   
   return;
}

PRIVATE void doDetachedList( void )
{
   SetWindowTitles( ACRWnd, "Detached list", (UBYTE *) ~0 );

   SetGadgetAttrs( ClassLV, ACRWnd, NULL,
                            LISTBROWSER_MultiSelect, FALSE,
                            LISTBROWSER_Labels,      ~0, // This is the detaching item
                            TAG_DONE
                 );

   HandleACRIDCMP( ACRWnd, ClassLV );
   
   return;
}

PRIVATE void doNoSeparatorsNoTitle( void )
{
   SetWindowTitles( ACRWnd, "No separators, no title, 1 column.", (UBYTE *) ~0 );

   SetGadgetAttrs( ClassLV, ACRWnd, NULL,
                            LISTBROWSER_Labels,       (ULONG) &classList,
                            LISTBROWSER_ColumnInfo,   (ULONG) &fancy_ci,
                            LISTBROWSER_Separators,   FALSE,
                            LISTBROWSER_ColumnTitles, FALSE,
                            LISTBROWSER_AutoFit,      TRUE,
                            LISTBROWSER_VirtualWidth, 0,
                            TAG_DONE
                 );

   HandleACRIDCMP( ACRWnd, ClassLV );
   
   return;
}

PRIVATE void doReadOnly( void )
{
   SetWindowTitles( ACRWnd, "Read-only", (UBYTE *) ~0 );

   SetGadgetAttrs( ClassLV, ACRWnd, NULL,
                            LISTBROWSER_Labels,     (ULONG) &classList,
                            LISTBROWSER_AutoFit,    TRUE,
                            LISTBROWSER_Selected,   -1,
                            GA_ReadOnly,            TRUE, // The workhorse
                            TAG_DONE
                 );

   HandleACRIDCMP( ACRWnd, ClassLV );
   
   return;
}

PRIVATE void doDisabled( void )
{
   SetWindowTitles( ACRWnd, "Disabled", (UBYTE *) ~0 );

   SetGadgetAttrs( ClassLV, ACRWnd, NULL,
                            GA_Disabled, TRUE,
                            GA_ReadOnly, FALSE,
                            TAG_DONE 
	         );

   HandleACRIDCMP( ACRWnd, ClassLV );
   
   return;
}

PRIVATE void doNoScrollersNoBorders( void )
{
   SetWindowTitles( ACRWnd, "No scrollbars, borderless", (UBYTE *) ~0 );

   SetGadgetAttrs( ClassLV, ACRWnd, NULL,
                            GA_Disabled,                FALSE,
                            GA_Top,                     ACRWnd->BorderTop,
                            GA_Left,                    2,
                            GA_RelWidth,                -18,
                            GA_RelHeight,               -(ACRWnd->BorderTop + ACRWnd->BorderBottom),
                            LISTBROWSER_Borderless,     TRUE,
                            LISTBROWSER_HorizontalProp, FALSE,
                            LISTBROWSER_VerticalProp,   FALSE,
                            TAG_DONE
	         );

   HandleACRIDCMP( ACRWnd, ClassLV );

   return;
}

PRIVATE void doFancyList( void )
{
   struct List   fancy_list;
   struct Image *image1, *image2;
   struct Node  *node1,  *node2;

   PutStr( "Creating Label class\n" );

   NewList( &fancy_list );

   PutStr( "Creating Label object\n" );

   if (!(image1 = (struct Image *) NewObject( LABEL_GetClass(), NULL,

              IA_FGPen,    1,
              IA_BGPen,    2,
              IA_Font,    (ULONG) &helvetica24b,
              LABEL_Text, (ULONG) "R",
              IA_Font,    (ULONG) &times18i,
              LABEL_Text, (ULONG) "e ",
              IA_Font,    (ULONG) &helvetica24b,
              LABEL_Text, (ULONG) "Act",
              IA_Font,    (ULONG) &times18i,
              LABEL_Text, (ULONG) "ion",
              TAG_END ))) // NULL)
      {
      PutStr( "ERROR: Couldn't create image1\n" );
      
      goto ExitFancyList;
      }

   PutStr( "Creating Label object\n" );

   if (!(image2 = (struct Image *) NewObject( LABEL_GetClass(), NULL,

              IA_FGPen,    2,
              IA_BGPen,    0,
              IA_Font,    (ULONG) &times18,
              LABEL_Text, (ULONG) "Amiga Inc.",
              TAG_END ))) // NULL)
      {
      PutStr( "ERROR: Couldn't create image2\n" );
      
      goto ExitFancyList;
      }

   if (!(node1 = AllocListBrowserNode( 1, LBNA_Column, 0,
                                            LBNCA_Image,         (ULONG) image1,
                                            LBNCA_Justification, LCJ_CENTRE,
                                            TAG_DONE ))) // NULL)
      {
      PutStr( "ERROR: Couldn't create node1\n" );
      
      goto ExitFancyList;
      }

   AddTail( &fancy_list, node1 );

   if (!(node2 = AllocListBrowserNode( 1, LBNA_Column, 0,
                                            LBNCA_Image,         (ULONG) image2,
                                            LBNCA_Justification, LCJ_CENTRE,
                                            TAG_DONE ))) // NULL)
      {
      PutStr( "ERROR: Couldn't create node2\n" );
      
      goto ExitFancyList;
      }

   AddTail( &fancy_list, node2 );

   // Set listbrowser.
   SetWindowTitles( ACRWnd, "Fancy Renderings...", (UBYTE *) ~0 );

   SetGadgetAttrs( ClassLV, ACRWnd, NULL,
                            LISTBROWSER_ColumnInfo, &fancy_ci,
                            LISTBROWSER_Labels,     (ULONG) &fancy_list,
                            LISTBROWSER_AutoFit,    TRUE,
                            TAG_DONE 
	         );

   HandleACRIDCMP( ACRWnd, ClassLV );

   SetGadgetAttrs( ClassLV, ACRWnd, NULL, LISTBROWSER_Labels, ~0, TAG_DONE );

ExitFancyList:
   if (node2) // != NULL)
      FreeListBrowserNode( node2 );

   if (node1) // != NULL)
      FreeListBrowserNode( node1 );

   if (image2) // != NULL)
      DisposeObject( image2 );
   
   if (image1) // != NULL)
      DisposeObject( image1 );

   return;
}

/* The original code had just about everything buried in the main() function.  Com'on folks,
** are you really that lazy?  Readable code will save you time in the long run.
*/

PUBLIC int main( int argc, char *argv[] )
{
   BOOL madeList = FALSE;
   int  rval     = RETURN_OK;
   
   if ((rval = SetupProgram( argv[0] )) != RETURN_OK)   
      {
      // SetupProgram() cleans up after itself, so...
      fprintf( stderr, "Could NOT setup %s!\n", argv[0] );

      return( rval ); // We can bail out here because SetupProgram() is such a nice function.
      }

   if ((madeList = makeListBrowserNodes( &classList, testClasses )) != TRUE)
      {
      PutStr( "ERROR: Could NOT make Node for ListBrowser!\n" );

      goto BailOut;
      } 

   // Create a listbrowser gadget.
   PutStr( "Creating ListBrowser object\n" );
   
   if (createListView() != RETURN_OK)
      {
      PutStr( "ERROR: Couldn't create ListBrowser gadget\n" );

      goto BailOut;
      }

   // Adding gadgets.
   PutStr( "Adding gadget\n" );
   AddGList( ACRWnd, ClassLV, -1, -1, NULL );

   PutStr( "Refreshing gadget\n" );
   RefreshGList( ClassLV, ACRWnd, NULL, -1 );

   // Wait for close gadget click to continue.
   SetWindowTitles( ACRWnd, "<- Click here to continue", (UBYTE *) ~0 );

   HandleACRIDCMP( ACRWnd, ClassLV );

   doMakeVisible();
   doShowSelectedAutoFit();
   doMultiSelect_VirtualWidth();
   doDetachedList();
   doNoSeparatorsNoTitle();
   doReadOnly();
   doDisabled();
   doNoScrollersNoBorders();
   doFancyList();
   
   RemoveGList( ACRWnd, ClassLV, -1 ); // Opposite of AddGList()
   DisposeObject( ClassLV );           // Clean up for createListView()

BailOut:

   ShutdownProgram( madeList );

   return( rval );
}

/* ----------------- END of ListBrowserExample.c file ----------------- */
