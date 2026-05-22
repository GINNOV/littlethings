/****h* ProgramLauncher.c [1.0] ****************************************
*
* NAME
*    ProgramLauncher.c
*
* DESCRIPTION
*    ProgramLauncher is a GUI for launching prgorams from Workbench,
*    similar to AmiDock (just not as complicated).
*    
* HISTORY
*    Jan-30-2005 - Created this file.
*
* COPYRIGHT
*    ProgramLauncher.c Jan-30-2005(C) by J.T. Steichen, All Rights Reserved.
*
* NOTES
*    ToolTypes:
*
*        STARTUPFILE      = ProgramLauncher:LauncherStart.ini
*        AMIPREFSFILENAME = System:Prefs/Env-Archive/Sys/AmiDock.amiga.com.xml
*        TOOLEDITOR       = ToolTypesEditorPPC
*        HELPVIEWER       = System:Utilities/MultiView
*
*    Program set up to compile with gcc & AmigaOS4 also.
*
*    $VER: ProgramLauncher.c 1.0 (Jan-30-2005) by J.T. Steichen
************************************************************************
*
*/

#include <stdio.h>
#include <string.h>

#include <exec/types.h>

#include <AmigaDOSErrs.h>

#define    ALLOCATE
# include <Author.h>
#undef     ALLOCATE

#include <intuition/intuition.h>
#include <intuition/classes.h>
#include <intuition/classusr.h>
#include <intuition/gadgetclass.h>

#include <libraries/gadtools.h>
#include <libraries/asl.h>

#include <workbench/workbench.h>
#include <workbench/startup.h>
#include <workbench/icon.h>

#include <utility/tagitem.h>

#include <dos/dos.h>
#include <dos/dostags.h>

#include <graphics/displayinfo.h>
#include <graphics/gfxbase.h>

#ifdef __SASC

# include <proto/locale.h>

# include <clib/exec_protos.h>
# include <clib/intuition_protos.h>
# include <clib/gadtools_protos.h>
# include <clib/graphics_protos.h>
# include <clib/utility_protos.h>
# include <clib/diskfont_protos.h>

IMPORT  struct WBStartup  *_WBenchMsg;

struct IntuitionBase      *IntuitionBase;
struct GfxBase            *GfxBase;
struct Library            *GadToolsBase;

PRIVATE struct Library    *IconBase;
PRIVATE struct LocaleBase *LocaleBase;

PRIVATE char v[] = "\0$VER: ProgramLauncher.c 1.0 " __AMIGADATE__ " by J.T. Steichen \0";

#else

# define __USE_INLINE__

# include <proto/exec.h>
# include <proto/dos.h>
# include <proto/intuition.h>
# include <proto/gadtools.h>
# include <proto/graphics.h>
# include <proto/utility.h>
# include <proto/diskfont.h>
# include <proto/locale.h>

# include <proto/icon.h>

IMPORT struct Library *SysBase;
IMPORT struct Library *DOSBase;
IMPORT struct Library *IntuitionBase;
IMPORT struct Library *GfxBase;
IMPORT struct Library *UtilityBase;
IMPORT struct Library *DiskfontBase;
IMPORT struct Library *LocaleBase;
IMPORT struct Library *IconBase;

PUBLIC struct Library *GadToolsBase;

IMPORT struct ExecIFace      *IExec;
IMPORT struct DOSIFace       *IDOS;
IMPORT struct IntuitionIFace *IIntuition;
IMPORT struct GraphicsIFace  *IGraphics;
IMPORT struct UtilityIFace   *IUtility;
IMPORT struct DiskfontIFace  *IDiskfont;
IMPORT struct LocaleIFace    *ILocale;
IMPORT struct IconIFace      *IIcon;

PUBLIC struct GadToolsIFace  *IGadTools;

PRIVATE char v[] = "\0$VER: ProgramLauncher.c 1.0 " __DATE__ " by J.T. Steichen \0";

IMPORT struct WBStartup      *__WBenchMsg;

#endif

struct Catalog *catalog = NULL;

#define   CATCOMP_ARRAY    1
#include "ProgramLauncherLocale.h"

#define  MY_LANGUAGE "english"

#include "CPGM:GlobalObjects/CommonFuncs.h"
#include "CPGM:GlobalObjects/IniFuncs.h"

#define ID_ProgramsLV 	0
#define ID_ProgramStr 	1
#define ID_DeleteBt     2

#define PL_CNT 		3

#define PGM_STR_GAD PLGadgets[ ID_ProgramStr ]
#define PGM_LV_GAD  PLGadgets[ ID_ProgramsLV ]

#define PROGRAM_STRING StrBfPtr( PGM_STR_GAD )

// ----------------------------------------------------

PUBLIC const UBYTE *PROGRAMVERSION  = "1.0";
PUBLIC UBYTE        programName[80] = { 0, };

#ifndef  BUFF_SIZE
# define BUFF_SIZE 512
#endif

PRIVATE struct DiskObject *diskobj = NULL;

PRIVATE UBYTE em[ BUFF_SIZE ] = { 0, }, *ErrMsg = &em[0];

PRIVATE struct Screen *PLScr        = NULL;
PRIVATE UBYTE         *PubScreenName = "Workbench";
PRIVATE APTR           VisualInfo    = NULL;

PRIVATE struct TextFont     *PLFont = NULL;
PRIVATE struct TextAttr     *Font, Attr;
PRIVATE struct CompFont      CFont = { 0, };

PRIVATE struct Window       *PLWnd   = NULL;
PRIVATE struct Menu         *PLMenus = NULL;
PRIVATE struct Gadget       *PLGList = NULL;
PRIVATE struct Gadget       *PLGadgets[ PL_CNT ] = { 0, };

PRIVATE struct IntuiMessage  PLMsg = { 0, };

PRIVATE UWORD  PLLeft    = 269;
PRIVATE UWORD  PLTop     = 179;
PRIVATE UWORD  PLWidth   = 565;
PRIVATE UWORD  PLHeight  = 340;
PRIVATE UBYTE  PLWdt[80] = { 0, };   // WA_Title
PRIVATE UBYTE *ScrTitle  = NULL;   // WA_ScreenTitle

PRIVATE int numElements = 0;

#define ELEMENT_SIZE      BUFF_SIZE

PRIVATE struct List         ProgramsLVList = { 0, };
PRIVATE struct ListViewMem *lvm            = NULL;

PRIVATE struct TextAttr Bitstream_Vera_Sans_Bold14 = { "Bitstream Vera Sans Bold.font", 14, 0x00, 0x62 };

// TTTTTTTTT ProgramLauncher.c ToolTypes: TTTTTTTTTTTTTTTTTTTTTTTTT

PRIVATE char StartupFile[32]             = "STARTUPFILE";
PRIVATE char AmiPrefsFile[32]            = "AMIPREFSFILENAME";
PRIVATE char ToolEditor[32]              = "TOOLTYPESEDITOR";
PRIVATE char HelpViewer[32]              = "HELPVIEWER";

PRIVATE char DefStartupFile[ BUFF_SIZE ] = "ProgramLauncher:LauncherStart.ini";
PRIVATE char DefPrefsFile[   BUFF_SIZE ] = "System:Prefs/Env-Archive/Sys/AmiDock.amiga.com.xml";
PRIVATE char DefToolEditor[  BUFF_SIZE ] = "ToolTypesEditorPPC";
PRIVATE char DefHelpViewer[  BUFF_SIZE ] = "System:Utilities/MultiView";

PRIVATE char *TTStartupFile              = &DefStartupFile[0];
PRIVATE char *TTPrefsFile                = &DefPrefsFile[0];
PRIVATE char *TTToolEditor               = &DefToolEditor[0];
PRIVATE char *TTHelpViewer               = &DefHelpViewer[0];

// TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT

PRIVATE struct TagItem FileTags[] = {

   ASLFR_Window,          (ULONG) NULL,
   ASLFR_TitleText,       (ULONG) "Obtain a filename...",
   ASLFR_InitialHeight,   400,
   ASLFR_InitialWidth,    500,
   ASLFR_InitialTopEdge,  16,
   ASLFR_InitialLeftEdge, 100,
   ASLFR_PositiveText,    (ULONG) " OKAY! ",
   ASLFR_NegativeText,    (ULONG) " CANCEL! ",
   ASLFR_InitialPattern,  (ULONG) "#?",
   ASLFR_InitialFile,     (ULONG) "",
   ASLFR_InitialDrawer,   (ULONG) "RAM:",
   ASLFR_Flags1,          FRF_DOPATTERNS,
   ASLFR_Flags2,          FRF_REJECTICONS,
   ASLFR_SleepWindow,     TRUE,
   ASLFR_PrivateIDCMP,    TRUE,
   TAG_END 
};

PRIVATE int AddProgramMI(    struct MenuItem *dummy );
PRIVATE int RemoveProgramMI( struct MenuItem *dummy );
PRIVATE int ImportAmiDockMI( struct MenuItem *dummy );
PRIVATE int EditToolTypesMI( struct MenuItem *dummy );
// Menu item 5 has NO User-Defined Action (BAR_LABEL??)! ------------ 
PRIVATE int AboutMI(         struct MenuItem *dummy );
PRIVATE int HelpMI(          struct MenuItem *dummy );
// Menu item 8 has NO User-Defined Action (BAR_LABEL??)! ------------ 
PRIVATE int QuitMI(          struct MenuItem *dummy );
PRIVATE int LaunchShellMI(   struct MenuItem *dummy );
PRIVATE int userMenuItem(    struct MenuItem *whichItem );

PRIVATE struct NewMenu PLNMenu[ ] = {

   NM_TITLE, "PROJECT", NULL, 0, 0L, NULL,

    NM_ITEM, "Add Menu...", "A", 0x0000, 0L, (APTR) AddProgramMI,

    NM_ITEM, "Remove Menu...", "R", 0x0000, 0L, (APTR) RemoveProgramMI,

    NM_ITEM, "Import AmiDock", 0, 0x0000, 0L, (APTR) ImportAmiDockMI,

    NM_ITEM, "Edit ToolTypes...", "T", 0x0000, 0L, (APTR) EditToolTypesMI,

    NM_ITEM, (STRPTR) NM_BARLABEL, NULL, 0, 0L, NULL,
    // ---------------------------------------------

    NM_ITEM, "About..", "I", 0x0000, 0L, (APTR) AboutMI,

    NM_ITEM, "Help!", "H", 0x0000, 0L, (APTR) HelpMI,

    NM_ITEM, (STRPTR) NM_BARLABEL, NULL, 0, 0L, NULL,
    // ---------------------------------------------

    NM_ITEM, "Quit", "Q", 0x0000, 0L, (APTR) QuitMI,

   NM_TITLE, "PROGRAMS", NULL, 0, 0L, NULL,

    NM_ITEM, "Launch Shell", 0, 0x0000, 0L, (APTR) LaunchShellMI,

    NM_IGNORE, "Empty", 0, 0x0000, 0L, (APTR) userMenuItem, // 12

    NM_IGNORE, "Empty", 0, 0x0000, 0L, (APTR) userMenuItem,

    NM_IGNORE, "Empty", 0, 0x0000, 0L, (APTR) userMenuItem,

    NM_IGNORE, "Empty", 0, 0x0000, 0L, (APTR) userMenuItem, // 15

    NM_IGNORE, "Empty", 0, 0x0000, 0L, (APTR) userMenuItem,

    NM_IGNORE, "Empty", 0, 0x0000, 0L, (APTR) userMenuItem,

    NM_IGNORE, "Empty", 0, 0x0000, 0L, (APTR) userMenuItem,

    NM_IGNORE, "Empty", 0, 0x0000, 0L, (APTR) userMenuItem,

    NM_IGNORE, "Empty", 0, 0x0000, 0L, (APTR) userMenuItem, // 20

    NM_IGNORE, "Empty", 0, 0x0000, 0L, (APTR) userMenuItem,

    NM_IGNORE, "Empty", 0, 0x0000, 0L, (APTR) userMenuItem,

    NM_IGNORE, "Empty", 0, 0x0000, 0L, (APTR) userMenuItem,

    NM_IGNORE, "Empty", 0, 0x0000, 0L, (APTR) userMenuItem,

    NM_IGNORE, "Empty", 0, 0x0000, 0L, (APTR) userMenuItem, // 25

    NM_IGNORE, "Empty", 0, 0x0000, 0L, (APTR) userMenuItem,

    NM_IGNORE, "Empty", 0, 0x0000, 0L, (APTR) userMenuItem,

    NM_IGNORE, "Empty", 0, 0x0000, 0L, (APTR) userMenuItem,

    NM_IGNORE, "Empty", 0, 0x0000, 0L, (APTR) userMenuItem,

    NM_IGNORE, "Empty", 0, 0x0000, 0L, (APTR) userMenuItem, // 30

   NM_END, NULL, NULL, 0, 0L, NULL
};

PRIVATE UBYTE userMenuNames[ 20 ][ 80 ] = { 0, };
     
PRIVATE UWORD PLGTypes[ PL_CNT ] = {

    LISTVIEW_KIND, STRING_KIND, BUTTON_KIND,
};

PRIVATE int ProgramsLVClicked( int whichItem );
PRIVATE int ProgramStrClicked( int dummy );
PRIVATE int DeleteBtClicked(   int dummy );

PRIVATE struct NewGadget PLNGad[ PL_CNT ] = {

    10,  25, 410, 290, "Programs:", NULL,
   ID_ProgramsLV, NG_HIGHLABEL | PLACETEXT_ABOVE, NULL, (APTR) ProgramsLVClicked,

    10, 305, 530,  20, NULL, NULL,
   ID_ProgramStr, 0, NULL, (APTR) ProgramStrClicked,

   425,  25, 110,  20, "Delete Item", NULL,
   ID_DeleteBt, PLACETEXT_IN, NULL, (APTR) DeleteBtClicked, 
};

PRIVATE ULONG PLGTags[] = {

   LAYOUTA_Spacing, 2, GTLV_ShowSelected, 0, TAG_DONE,

   GTST_MaxChars, 512, TAG_DONE,
   
   TAG_DONE,
};

#define MAX_AMIDOCK 100

PRIVATE UBYTE amiDockStrings[ MAX_AMIDOCK ][80] = { 0, };
    
// ----------------------------------------------------

/****h* CMsg() [1.0] *************************************************
*
* NAME
*    STRPTR rval = CMsg( int index, char *defaultStr );
*
* DESCRIPTION
*    Obtain a string from the locale catalog file, failing that,
*    return the default string.
**********************************************************************
*
*/

PUBLIC STRPTR CMsg( int strIndex, char *defaultString )
{
   if (catalog)
      return( (STRPTR) GetCatalogStr( catalog, strIndex, defaultString ) );
   else
      return( (STRPTR) defaultString );
}

/****i* SetupCatalog() [1.0] *****************************************
*
* NAME
*    SetupCatalog()
*
* DESCRIPTION
**********************************************************************
*
*/

PRIVATE void SetupCatalog( void )
{
   ScrTitle = CMsg( MSG_PL_STITLE, MSG_PL_STITLE_STR ); // WA_ScreenTitle

   StringNCopy( PLWdt, CMsg( MSG_PL_WTITLE, MSG_PL_WTITLE_STR ), 80 ); // WA_Title

   PLNGad[ 0 ].ng_GadgetText = CMsg( MSG_GAD_ProgramsLV, MSG_GAD_ProgramsLV_STR );
   PLNGad[ 2 ].ng_GadgetText = CMsg( MSG_GAD_DeleteBt,   MSG_GAD_DeleteBt_STR   );

   // ---- Menu Strings (if any): -------------------------------- 
   PLNMenu[ 0 ].nm_Label = CMsg( MSG_MENU_PROJECT,        MSG_MENU_PROJECT_STR );
   PLNMenu[ 1 ].nm_Label = CMsg( MSG_MENU_Add,            MSG_MENU_Add_STR );
   PLNMenu[ 2 ].nm_Label = CMsg( MSG_MENU_Remove,         MSG_MENU_Remove_STR );
   PLNMenu[ 3 ].nm_Label = CMsg( MSG_MENU_Import_AmiDock, MSG_MENU_Import_AmiDock_STR );
   PLNMenu[ 4 ].nm_Label = CMsg( MSG_MENU_Edit_ToolTypes, MSG_MENU_Edit_ToolTypes_STR );
   // BAR_LABEL -------------------------------------------------- 
   PLNMenu[ 6 ].nm_Label = CMsg( MSG_MENU_About, MSG_MENU_About_STR );
   PLNMenu[ 7 ].nm_Label = CMsg( MSG_MENU_Help,  MSG_MENU_Help_STR );
   // BAR_LABEL -------------------------------------------------- 
   PLNMenu[  9 ].nm_Label = CMsg( MSG_MENU_Quit,          MSG_MENU_Quit_STR );
   PLNMenu[ 10 ].nm_Label = CMsg( MSG_MENU_PROGRAMS,     MSG_MENU_PROGRAMS_STR );
   PLNMenu[ 11 ].nm_Label = CMsg( MSG_MENU_Launch_Shell, MSG_MENU_Launch_Shell_STR );

   // ----- Menu Key strings (if any): ------------------------------- 
   PLNMenu[ 1 ].nm_CommKey = CMsg( MSG_MENUKEY_A, MSG_MENUKEY_A_STR );
   PLNMenu[ 2 ].nm_CommKey = CMsg( MSG_MENUKEY_R, MSG_MENUKEY_R_STR );
   PLNMenu[ 4 ].nm_CommKey = CMsg( MSG_MENUKEY_T, MSG_MENUKEY_T_STR );
   PLNMenu[ 6 ].nm_CommKey = CMsg( MSG_MENUKEY_I, MSG_MENUKEY_I_STR );
   PLNMenu[ 7 ].nm_CommKey = CMsg( MSG_MENUKEY_H, MSG_MENUKEY_H_STR );
   PLNMenu[ 9 ].nm_CommKey = CMsg( MSG_MENUKEY_Q, MSG_MENUKEY_Q_STR );

   StringNCopy( StartupFile,  CMsg( MSG_TT_STARTUPFILE,  MSG_TT_STARTUPFILE_STR  ), 32 ); // STARTUPFILE
   StringNCopy( AmiPrefsFile, CMsg( MSG_TT_AMIPREFSFILE, MSG_TT_AMIPREFSFILE_STR ), 32 ); // AMIPREFSFILENAME
   StringNCopy( ToolEditor,   CMsg( MSG_TT_TOOLEDITOR,   MSG_TT_TOOLEDITOR_STR   ), 32 ); // TOOLTYPESEDITOR
   StringNCopy( HelpViewer,   CMsg( MSG_TT_HELPVIEWER,   MSG_TT_HELPVIEWER_STR   ), 32 ); // HELPVIEWER

   SetTagItem( FileTags, ASLFR_TitleText,    (ULONG) CMsg( MSG_ASL_RTITLE,    MSG_ASL_RTITLE_STR    ));
   SetTagItem( FileTags, ASLFR_PositiveText, (ULONG) CMsg( MSG_ASL_OKAY_BT,   MSG_ASL_OKAY_BT_STR   ));
   SetTagItem( FileTags, ASLFR_NegativeText, (ULONG) CMsg( MSG_ASL_CANCEL_BT, MSG_ASL_CANCEL_BT_STR ));

   return;
}

// ----------------------------------------------------------------

/****h* WriteProgramString() [1.0] *************************************
* 
* NAME
*    WriteProgramString()
*
* DESCRIPTION
*    This function is called by storeProgramString(), located in
*    ReadAmiDockFile.flex.  This is how the AmiDock program strings
*    get into the ProgramLauncher system.
*
* WARNING
*    Each AmiDock program string is expected to be < 80 characters in
*    length & there is a hard-coded limit of 100 (MAX_AMIDOCK)!
************************************************************************
*
*/

PUBLIC void WriteProgramString( char *pgmString, int arrayIndex )
{
   if (arrayIndex < MAX_AMIDOCK)
      {
      StringNCopy( &amiDockStrings[ arrayIndex ][0], pgmString, 80 );
      }
   else
      {
      sprintf( ErrMsg, CMsg( MSG_FMT_NO_ROOM_AMIDOCK, MSG_FMT_NO_ROOM_AMIDOCK_STR ), pgmString );
      
      UserInfo( ErrMsg, CMsg( MSG_USER_ERROR, MSG_USER_ERROR_STR ) );
      }

   return;
}

// ----------------------------------------------------------------

PRIVATE BOOL UnlockFlag = FALSE;

PRIVATE int OpenPLScreen( void )
{
   struct Screen *chk = GetActiveScreen();

   if (!(PLFont = OpenDiskFont( &Bitstream_Vera_Sans_Bold14 ))) // == NULL
      return( -5 );

   Font = &Attr;

   if (!(PLScr = LockPubScreen( PubScreenName ))) // == NULL
      return( -1 );

   if (chk != PLScr)
      {
      UnlockPubScreen( NULL, PLScr );
      PLScr = chk;
      UnlockFlag = FALSE;
      }
   else
      UnlockFlag = TRUE;

   ComputeFont( PLScr, Font, &CFont, 0, 0 );

   if (!(VisualInfo = GetVisualInfo( PLScr, TAG_DONE ))) // == NULL
      return( -2 );

   return( RETURN_OK );
}

PRIVATE void ClosePLScreen( void )
{
   if (VisualInfo) // != NULL
      {
      FreeVisualInfo( VisualInfo );

      VisualInfo = NULL;
      }

   if ((UnlockFlag == TRUE) && PLScr) // != NULL
      {
      UnlockPubScreen( NULL, PLScr );

      PLScr = NULL;
      }

   if (PLFont) // != NULL
      {
      CloseFont( PLFont );

      PLFont = NULL;
      }

   return;
}

PRIVATE void ClosePLWindow( void )
{
   if (PLMenus) // != NULL
      {
      ClearMenuStrip( PLWnd );
      FreeMenus( PLMenus );
      PLMenus = NULL;
      }

   if (PLWnd) // != NULL
      {
      CloseWindow( PLWnd );

      PLWnd = NULL;
      }

   if (PLGList) // != NULL
      {
      FreeGadgets( PLGList );

      PLGList = NULL;
      }

   return;
}

// ----------------------------------------------------------------

PRIVATE UBYTE extCommand[ 1024 ]    = { 0, };
PRIVATE UBYTE pathName[ BUFF_SIZE ] = { 0, };

SUBFUNC int runExternCommand( UBYTE *command )
{
   BPTR oldLock    = (BPTR) NULL, newLock = (BPTR) NULL;
   BOOL changedDir = FALSE;
   int  rval       = RETURN_OK;

   /* Some commands require that we be in their home directory, so we have to
   ** change directories from 'ProgramLauncher:' to wherever the command is located.
   */   
   (void) GetPathName( &pathName[0], command, BUFF_SIZE );
   
   if (StringLength( &pathName[0] ) > 0)
      {
      newLock    = Lock( &pathName[0], SHARED_LOCK );
      oldLock    = CurrentDir( newLock ); // Change Directory.
      changedDir = TRUE;
      }

   if ((rval = System( command, TAG_DONE )) != RETURN_OK)
      {
      sprintf( ErrMsg, CMsg( MSG_FMT_NO_COMMAND, MSG_FMT_NO_COMMAND_STR ), command, rval );
      
      UserInfo( ErrMsg, CMsg( MSG_SPELLING_ERROR, MSG_SPELLING_ERROR_STR ) );
      }

   if (changedDir == TRUE)
      { 
      (void) CurrentDir( oldLock ); // Go back to 'ProgramLauncher:' Directory

      UnLock( newLock );
      }

   return( rval );
}

PRIVATE int userMenuItem( struct MenuItem *whichItem )
{
   UBYTE *itemString = ((struct IntuiText *) whichItem->ItemFill)->IText;
   
   if (!itemString || StringLength( itemString ) < 1)
      return( TRUE ); // Invalid menu item, abort!!

   if (StringNComp( itemString, "Empty", 5 ) != 0) // Just in case!
      (void) runExternCommand( itemString );
      
   return( TRUE );
}
    
// This adds a program to the menu strip.

PRIVATE int AddProgramMI( struct MenuItem *dummy )
{
   UBYTE *addItem = NULL;
   int    i       = 0;
   
   if ((addItem = GetUserString( PLWnd, CMsg( MSG_ADD_MENU_INST, MSG_ADD_MENU_INST_STR ), 
                                        CMsg( MSG_ADD_MENU_RQTITLE, MSG_ADD_MENU_RQTITLE_STR ) )))
      {
      ClearMenuStrip( PLWnd );

      while ((PLNMenu[i].nm_Type != NM_IGNORE) && (PLNMenu[i].nm_Type != NM_END))
         i++; // 12 through 30 are NM_IGNORE

      if (PLNMenu[i].nm_Type != NM_END)
         {
	 StringNCopy( &userMenuNames[ i - 12 ][ 0 ], addItem, 80 );

         PLNMenu[i].nm_Type  = NM_ITEM; // Transform NM_IGNORE to NM_ITEM.
         PLNMenu[i].nm_Label = &userMenuNames[ i - 12 ][ 0 ];
	 }

      if (!(PLMenus = CreateMenus( PLNMenu, GTMN_FrontPen, 0L, TAG_DONE )))
         {
         sprintf( ErrMsg, CMsg( MSG_FMT_MENU_FAILED, MSG_FMT_MENU_FAILED_STR ),
	                  CMsg( MSG_MENU_Add, MSG_MENU_Add_STR )
	        );
	 
	 UserInfo( ErrMsg, CMsg( MSG_SYSTEM_PROBLEM, MSG_SYSTEM_PROBLEM_STR ) );

         return( TRUE );
	 }

      LayoutMenus( PLMenus, VisualInfo, TAG_DONE );
      
      SetMenuStrip( PLWnd, PLMenus );
      }

   return( TRUE );
}

SUBFUNC int RemoveItemMI( char *menuName )
{
   int i = 0;

   while (PLNMenu[i].nm_Type != NM_END)
      i++; // Find end of list marker.
   
   i--; // go up one in the list to last NM_ITEM or NM_IGNORE.

   ClearMenuStrip( PLWnd );

checkAgain:

   if (PLNMenu[i].nm_Type != NM_TITLE) // Have we gone too far up the menu list??
      {
      if (StringNComp( menuName, PLNMenu[i].nm_Label, StringLength( menuName ) ) == 0)
         {
         PLNMenu[i].nm_Type  = NM_IGNORE;
         PLNMenu[i].nm_Label = NULL;

	 userMenuNames[ i - 12 ][ 0 ] = '\0';
	 
	 goto reattachMenus;
         }
      else
         {
         i--; // Go back up the menu list by one item & test again...

         goto checkAgain;
         }
      }

reattachMenus:

   if (!(PLMenus = CreateMenus( PLNMenu, GTMN_FrontPen, 0L, TAG_DONE ))) // == NULL)
      {  
      sprintf( ErrMsg, CMsg( MSG_FMT_MENU_FAILED, MSG_FMT_MENU_FAILED_STR ), 
                       CMsg( MSG_MENU_Remove, MSG_MENU_Remove_STR ) 
	     );
      
      UserInfo( ErrMsg, CMsg( MSG_SYSTEM_PROBLEM, MSG_SYSTEM_PROBLEM_STR ) );
      
      return( TRUE );
      }

   LayoutMenus( PLMenus, VisualInfo, TAG_DONE );
      
   SetMenuStrip( PLWnd, PLMenus );

   return( TRUE );
}

// This removes a program from the menu strip.

PRIVATE int RemoveProgramMI( struct MenuItem *dummy )
{
   UBYTE *removeItem = NULL;

   if ((removeItem = GetUserString( PLWnd, CMsg( MSG_REM_MENU_INST,    MSG_REM_MENU_INST_STR ), 
                                           CMsg( MSG_REM_MENU_RQTITLE, MSG_REM_MENU_RQTITLE_STR ) )))
      {
      if (StringLength( removeItem ) > 0)
         return( RemoveItemMI( removeItem ) );
      }

   return( TRUE );
}

SUBFUNC void addToListView( void )
{
   int i = lvm->lvm_NumItems, arrayIndex = 0, displayIndex = 0;
   
   while (i > 0)
      {
      if (StringLength( &lvm->lvm_NodeStrs[ i * lvm->lvm_NodeLength ] ) > 0)
         {
         i++;
         break;
         }	
      
      i--;
      }

   displayIndex = i;
   
   HideListFromView( PGM_LV_GAD, PLWnd );
   
   while (i < lvm->lvm_NumItems)
      {
      if (StringLength( &amiDockStrings[ arrayIndex ][0] ) > 0)
         {
         StringNCopy( &lvm->lvm_NodeStrs[ i * lvm->lvm_NodeLength ],
	              &amiDockStrings[ arrayIndex ][0], 80 
		    );
         }

      arrayIndex++;
      i++;
      }

   GT_SetGadgetAttrs( PGM_LV_GAD, PLWnd, NULL, GTLV_Labels,       &ProgramsLVList,
                                               GTLV_ShowSelected, PGM_STR_GAD, 
                                               GTLV_Selected,     0,
					       GTLV_Top,          displayIndex,
					       TAG_DONE
		    );
   return;
}

PRIVATE int ImportAmiDockMI( struct MenuItem *dummy )
{
   IMPORT int readAmiDockFile( UBYTE *prefsFileName );

   int chk = RETURN_OK;
   
   if ((chk = readAmiDockFile( TTPrefsFile )) != RETURN_OK)
      {
      sprintf( ErrMsg, CMsg( MSG_FMT_AMIDOCK_ERROR, MSG_FMT_AMIDOCK_ERROR_STR ), chk );
      
      UserInfo( ErrMsg, CMsg( MSG_AMIDOCK_FILE_PROBLEM, MSG_AMIDOCK_FILE_PROBLEM_STR ) );
      }
   else
      {
      addToListView();
      }

   return( TRUE );
}

PRIVATE int EditToolTypesMI( struct MenuItem *dummy )
{
   sprintf( &extCommand[0], "%s %s", TTToolEditor, programName ); 

   (void) runExternCommand( &extCommand[0] );
      
   return( TRUE );
}

PRIVATE int AboutMI( struct MenuItem *dummy )
{
   UBYTE title[80] = { 0, };

   sprintf( ErrMsg, CMsg( MSG_FMT_PL_ABOUT, MSG_FMT_PL_ABOUT_STR ), 
                    programName, authorName, authorEMail 
          );

   sprintf( title, CMsg( MSG_FMT_PL_ABOUT_RQTITLE, MSG_FMT_PL_ABOUT_RQTITLE_STR ), 
                         programName, PROGRAMVERSION 
          );

   UserInfo( ErrMsg, title );
      	  
   return( TRUE );
}

PRIVATE int HelpMI( struct MenuItem *dummy )
{
   sprintf( &extCommand[0], "%s ProgramLauncher:%s.guide", TTHelpViewer, programName );

   (void) runExternCommand( &extCommand[0] );
      
   return( TRUE );
}

PRIVATE int QuitMI( struct MenuItem *dummy )
{
   return( FALSE );
}

PRIVATE int LaunchShellMI( struct MenuItem *dummy )
{
   (void) runExternCommand( "NewShell" );
      
   return( TRUE );
}

// ----------------------------------------------------------------------------

PRIVATE int currentLVItem = 0;

PRIVATE int DeleteBtClicked( int dummy )
{
   HideListFromView( PGM_LV_GAD, PLWnd );
   
      lvm->lvm_NodeStrs[ currentLVItem * lvm->lvm_NodeLength ] = '\0';

      GT_SetGadgetAttrs( PGM_STR_GAD, PLWnd, NULL, GTST_String, "", TAG_DONE );

   GT_SetGadgetAttrs( PGM_LV_GAD, PLWnd, NULL, GTLV_Labels,       &ProgramsLVList,
                                               GTLV_Selected,     currentLVItem + 1,
					       GTLV_ShowSelected, PGM_STR_GAD,
					       GTLV_Top,          currentLVItem,
					       TAG_DONE 
		    );
   
   return( TRUE );
}

PRIVATE int ProgramsLVClicked( int whichItem )
{
   UBYTE *pgm = &lvm->lvm_NodeStrs[ whichItem * lvm->lvm_NodeLength ];
   
   currentLVItem = whichItem;

   GT_SetGadgetAttrs( PGM_STR_GAD, PLWnd, NULL, GTST_String, pgm, TAG_DONE );

   if (StringLength( pgm ) > 0)
      {   
      (void) runExternCommand( pgm );
      }

   return( TRUE );
}

PRIVATE int ProgramStrClicked( int dummy )
{
   HideListFromView( PGM_LV_GAD, PLWnd ); 
   
      StringNCopy( &lvm->lvm_NodeStrs[ currentLVItem * lvm->lvm_NodeLength ], 
                   PROGRAM_STRING, lvm->lvm_NodeLength 
	         );
   
   ModifyListView( PGM_LV_GAD, PLWnd, &ProgramsLVList, PGM_STR_GAD );

   return( TRUE );
}

// ----------------------------------------------------------------

PRIVATE int OpenPLWindow( void )
{
   struct NewGadget  ng;
   struct Gadget    *g;
   WORD              zoomCoords[4] = { 250, 0, 380, 20 };
   UWORD             lc, tc;
   UWORD             wleft, wtop, ww, wh;

   ComputeFont( PLScr, Font, &CFont, PLWidth, PLHeight );

   ww = ComputeX( CFont.FontX, PLWidth  );
   wh = ComputeY( CFont.FontY, PLHeight );

   wleft = (PLScr->Width  - PLWidth ) / 2;
   wtop  = (PLScr->Height - PLHeight) / 2;

   if (!(g = CreateContext( &PLGList ))) // == NULL
      return( RETURN_FAIL );

   for (lc = 0, tc = 0; lc < PL_CNT; lc++)
      {
      CopyMem( (char *) &PLNGad[ lc ], (char *) &ng,
               (long) sizeof( struct NewGadget )
             );

      ng.ng_VisualInfo = VisualInfo;
      ng.ng_TextAttr   = &Bitstream_Vera_Sans_Bold14;
      ng.ng_LeftEdge   = CFont.OffX + ComputeX( CFont.FontX, ng.ng_LeftEdge );
      ng.ng_TopEdge    = CFont.OffY + ComputeY( CFont.FontY, ng.ng_TopEdge );

      PLGadgets[ lc ] = g
                      = CreateGadgetA( (ULONG) PLGTypes[ lc ],
                                       g,
                                       &ng,
                                       (struct TagItem *) &PLGTags[ tc ]
                                     );

      while (PLGTags[ tc ] != TAG_DONE)
         tc += 2;

      tc++;

      if (!g) // == NULL
         return( RETURN_FAIL );
      }

   if (!(PLMenus = CreateMenus( PLNMenu, GTMN_FrontPen, 0L,
                                TAG_DONE ))) // == NULL
      return( RETURN_FAIL );

   LayoutMenus( PLMenus, VisualInfo, TAG_DONE );

   if (!(PLWnd = OpenWindowTags( NULL,

         WA_Left,          wleft,
         WA_Top,           wtop,
	 WA_MinWidth,      380,
	 WA_MinHeight,     20,
         WA_Zoom,          &zoomCoords[0],
         WA_Width,         ww + CFont.OffX + PLScr->WBorRight,
         WA_Height,        wh + CFont.OffY + PLScr->WBorBottom,

         WA_IDCMP,         LISTVIEWIDCMP | STRINGIDCMP | IDCMP_CLOSEWINDOW 
	   | IDCMP_MENUPICK | IDCMP_VANILLAKEY | IDCMP_RAWKEY 
	   | IDCMP_REFRESHWINDOW | IDCMP_CHANGEWINDOW,

         WA_Flags,         WFLG_ACTIVATE | WFLG_DRAGBAR | WFLG_DEPTHGADGET
           | WFLG_CLOSEGADGET | WFLG_SMART_REFRESH | WFLG_HASZOOM,

         WA_NewLookMenus,  TRUE,
         WA_Gadgets,       PLGList,
         WA_Title,         PLWdt,
         WA_ScreenTitle,   ScrTitle,
         WA_CustomScreen,  PLScr,
         TAG_DONE ))) // == NULL
      {
      return( ERROR_ON_OPENING_WINDOW );
      }

   SetMenuStrip( PLWnd, PLMenus );

   GT_RefreshWindow( PLWnd, NULL );

   // These have to be set up for writeStartupFile() since the PLWnd will be closed then:
   PLTop  = PLWnd->TopEdge;
   PLLeft = PLWnd->LeftEdge;
   StringNCopy( PLWdt, PLWnd->Title, 80 );
   // -----------------------------------------------------------------------------------
      
   return( RETURN_OK );
}


PRIVATE int PLCloseWindow( void )
{
   ClosePLWindow();

   return( FALSE );
}

PRIVATE int PLVanillaKey( int whichKey )
{
   int rval = TRUE;

   switch (whichKey)
      {
      case 'a':
      case 'A':
         rval = AddProgramMI( NULL );
	 break;

      case 'r':
      case 'R':
         rval = RemoveProgramMI( NULL );
	 break;

      case 't':
      case 'T':
         rval = EditToolTypesMI( NULL );
	 break;

      case 'i':
      case 'I':
         rval = AboutMI( NULL );
	 break;

      case 'h':
      case 'H':
      case '?':
         rval = HelpMI( NULL );
	 break;

      case 'q':
      case 'Q':
         rval = QuitMI( NULL );
         break;

      default:
         break;
      }

   return( rval );
}

PRIVATE int PLRawKey( struct IntuiMessage *m )
{
   int rval = TRUE;

   switch (m->Code)
      {
      case HELP: // 0x5F == 95
         rval = HelpMI( NULL );
         break;

      case UP_ARROW:
         if (currentLVItem > 0)
	    currentLVItem--;
	 else
	    currentLVItem = 0;
	 
         GT_SetGadgetAttrs( PGM_LV_GAD, PLWnd, NULL, GTLV_Selected, currentLVItem,
					             GTLV_Top,      currentLVItem,
					             TAG_DONE 
                          );
	 break;

      case DOWN_ARROW:
         if (currentLVItem < lvm->lvm_NumItems)
	    currentLVItem++;
	 else
	    currentLVItem = lvm->lvm_NumItems;

         GT_SetGadgetAttrs( PGM_LV_GAD, PLWnd, NULL, GTLV_Selected, currentLVItem,
					             GTLV_Top,      currentLVItem,
					             TAG_DONE 
                          );
         break;

      default:
         break;
      }

   return( rval );
}

PRIVATE int HandlePLIDCMP( void )
{
   struct IntuiMessage *m;
   int                (*func)( int );
   BOOL                 running = TRUE;

   while (running == TRUE)
      {
      if (!(m = GT_GetIMsg( PLWnd->UserPort ))) // == NULL
         {
         (void) Wait( 1L << PLWnd->UserPort->mp_SigBit );

         continue;
         }

      CopyMem( (char *) m, (char *) &PLMsg, 
               (long) sizeof( struct IntuiMessage )
             );

      GT_ReplyIMsg( m );

      switch (PLMsg.Class)
         {
         case IDCMP_CLOSEWINDOW:
            running = FALSE; // PLCloseWindow(); ShutdownProgram() will take care of this.
            break;

         case IDCMP_GADGETDOWN:
         case IDCMP_GADGETUP:
            if ((func = (int (*)( int )) ((struct Gadget *) PLMsg.IAddress)->UserData))
               running = func( PLMsg.Code );

            break;

         case IDCMP_MENUPICK:
            if (PLMsg.Code != MENUNULL)
               {
               int (*mfunc)( struct MenuItem * );

               struct MenuItem *n = ItemAddress( PLMenus, PLMsg.Code );

               if (n)
                  mfunc = (int (*)( struct MenuItem * )) (GTMENUITEM_USERDATA( n ));

               if (mfunc)
                  running = mfunc( n );
               }

            break;

         case IDCMP_VANILLAKEY:
            running = PLVanillaKey( PLMsg.Code );
            break;

         case IDCMP_RAWKEY:
            running = PLRawKey( &PLMsg );
            break;

         case IDCMP_REFRESHWINDOW:
            GT_BeginRefresh( PLWnd );

            GT_EndRefresh( PLWnd, TRUE );

            break;

         case IDCMP_CHANGEWINDOW:
            break;
         }
      }

   return( running );
}

// ----------------------------------------------------------------

PRIVATE void closeLibraries( void )
{
#  ifdef __SASC
   CloseLibs();

   if (LocaleBase) // != NULL)
      CloseLibrary( (struct Library *) LocaleBase );

   if (IconBase) // != NULL)
      CloseLibrary( (struct Library *) IconBase );

#  else // __amigaos4__ is #defined!
   if (IGadTools)
      DropInterface( (struct Interface *) IGadTools );
   
   if (GadToolsBase)
      CloseLibrary( GadToolsBase );
#  endif

   return;
}

PRIVATE void ShutdownProgram( void )
{
   ClosePLWindow();

   ClosePLScreen();

   Guarded_FreeLV( lvm );
 
   if (catalog) // != NULL)
      CloseCatalog( catalog );

   closeLibraries();
   
   return;
}

PRIVATE int openLibraries( void )
{
   int rval = RETURN_OK;
   
#  ifdef __SASC
   rval = OpenLibs();

   if (!(LocaleBase = OpenLibrary( "locale.library", 37L ))) // == NULL)
      {
      fprintf( stderr, CMsg( MSG_FMT_LIB_UNOPENED, MSG_FMT_LIB_UNOPENED_STR ),
                       "locale.library", "37" 
             );

      closeLibraries();
            
      rval = ERROR_INVALID_RESIDENT_LIBRARY;
      }

   if (!(IconBase = OpenLibrary( "icon.library", 37L ))) // == NULL)
      {
      fprintf( stderr, CMsg( MSG_FMT_LIB_UNOPENED, MSG_FMT_LIB_UNOPENED_STR ),
                       "icon.library", "37" 
             );

      closeLibraries();	
                  
      rval = ERROR_INVALID_RESIDENT_LIBRARY;
      }
#  else // __amigaos4__ is DEFINED!  -lauto does NOT open gadtools.library!

   if ((GadToolsBase = OpenLibrary( "gadtools.library", 50L )))
      {
      if (!(IGadTools = (struct GadToolsIFace *) GetInterface( GadToolsBase, "main", 1, NULL )))
         {
	 closeLibraries();
	 
         rval = ERROR_INVALID_RESIDENT_LIBRARY;
	 }
      }
   else
      rval = ERROR_INVALID_RESIDENT_LIBRARY;
#  endif

   return( rval );
}

PRIVATE int SetupProgram( void )
{
   int rval = RETURN_OK;
   
   if (openLibraries() != RETURN_OK)
      {
      rval = ERROR_INVALID_RESIDENT_LIBRARY;
      
      goto exitSetup;
      }

   catalog = OpenCatalog( NULL, "ProgramLauncher.catalog",
                                OC_BuiltInLanguage, MY_LANGUAGE,
                                TAG_DONE 
                        );

   (void) SetupCatalog();

   if (OpenPLScreen() != RETURN_OK)
      {
      rval = ERROR_ON_OPENING_SCREEN;

      ShutdownProgram();

      goto exitSetup;
      }

exitSetup:

   return( rval );
}

PRIVATE void *processToolTypes( STRPTR *toolptr )
{
   if (!toolptr) // == NULL)
      return( NULL );

   TTStartupFile = GetToolStr( toolptr, StartupFile,  &DefStartupFile[0] );
   TTPrefsFile   = GetToolStr( toolptr, AmiPrefsFile, &DefPrefsFile[0]   );
   TTToolEditor  = GetToolStr( toolptr, ToolEditor,   &DefToolEditor[0]  );
   TTHelpViewer  = GetToolStr( toolptr, HelpViewer,   &DefHelpViewer[0]  );

   return( NULL );
}

SUBFUNC int readInProgramItems( aiPTR ai , ULONG index )
{
   ULONG idx  = index;
   int   rval = RETURN_OK;
      
   if ((idx = iniFindItem( ai, "ButtonCount" )) != 0)
      {
      numElements = atoi( iniGetItemValue( ai, idx ) );

      if (numElements > 500)
         numElements = 500;
      else if (numElements < 20)
         numElements = 50;
      }
   else
      numElements = 50;
      
   lvm = Guarded_AllocLV( numElements, ELEMENT_SIZE );

   if (lvm == NULL)
      {
      rval = ERROR_NO_FREE_STORE;
      
      fprintf( stderr, "Could NOT allocate space for ListView Gadget List!\n" );

      ShutdownProgram();

      goto exitReadInProgramItems;
      }
   else
      {
      UBYTE *command = NULL;
      int    k = 0;

      idx++;

      if (StringComp( iniGetItemName( ai, idx ),  "Button" ) != 0)
         goto exitReadInProgramItems;
      
      for (k = 0; k < numElements; k++)
         {
	 command = TrimSpaces( iniGetItemValue( ai, idx ) );

         StringNCopy( &lvm->lvm_NodeStrs[ k * lvm->lvm_NodeLength ], command, lvm->lvm_NodeLength );

         idx++;

	 if (iniIsGroup( ai, idx ))
	    break;
         }
      }

exitReadInProgramItems:

   return( rval );
}

SUBFUNC void readInProgramMenus( aiPTR ai, ULONG index )
{
   ULONG idx = index;
   int   menuNumber = 12;
   
   idx = iniFindItem( ai, "Menu" );
      
   while (idx < numberOfElements && menuNumber < 31)
      {
      UBYTE *item = TrimSpaces( iniGetItemValue( ai, idx ) );
      
      if (item && StringLength( item ) > 0)
         {
	 PLNMenu[ menuNumber ].nm_Label = item;
	 PLNMenu[ menuNumber ].nm_Type  = NM_ITEM;
	 
	 menuNumber++;
	 }
      
      idx++;
      }

   return;
}

SUBFUNC int readInStartupFile( UBYTE *fileName )
{
   aiPTR   ai = (aiPTR) NULL;
   int   rval = RETURN_OK;
   ULONG idx  = 0L;
   
   if (!(ai = iniOpenFile( fileName, FALSE, "= &|" ))) 
      {
      sprintf( ErrMsg, CMsg( MSG_FMT_BAD_STARTUPFILE, MSG_FMT_BAD_STARTUPFILE_STR ), fileName );
      
      UserInfo( ErrMsg, CMsg( MSG_BAD_TOOLTYPE, MSG_BAD_TOOLTYPE_STR ) );
      }

   idx = iniFirstGroup( ai );

   if ((idx = iniFindItem( ai, "WA_Title" )) != 0)
      {
      StringNCopy( PLWdt, TrimSpaces( iniGetItemValue( ai, idx ) ), 80 );
      }
      
   if ((idx = iniFindItem( ai, "WA_TopEdge" )) != 0)
      {
      PLTop = atoi( iniGetItemValue( ai, idx ) );
      }

   if ((idx = iniFindItem( ai, "WA_LeftEdge" )) != 0)
      {
      PLLeft = atoi( iniGetItemValue( ai, idx ) );
      }

   (void) iniFirstGroup( ai );

   if ((idx = iniFindGroup( ai, "[Programs]" )) != 0)
      {
      if ((rval = readInProgramItems( ai, idx + 1 )) != RETURN_OK)
         goto abort;
      }

   (void) iniFirstGroup( ai );

   if ((idx = iniFindGroup( ai, "[ProgramMenus]" )) != 0)
      {
      readInProgramMenus( ai, idx + 1 );
      }

abort:
       
   if (ai)
      iniExit( ai );
         
   return( rval );
}

PRIVATE int setupGUI( void )
{
   int rval = RETURN_OK;

   if ((rval = readInStartupFile( TTStartupFile )) != RETURN_OK)
      {
      FreeDiskObject( diskobj );

      ShutdownProgram();

      exit( rval );
      }
	   
   if (OpenPLWindow() != RETURN_OK)
      {
      rval = ERROR_ON_OPENING_WINDOW;

      ShutdownProgram();

      goto exitSetupGUI;
      }

exitSetupGUI:

   return( rval );
}

SUBFUNC void writeProgramMenus( FILE *fp )
{
   struct Menu      *programsMenu     = PLWnd->MenuStrip->NextMenu;
   struct MenuItem  *programsMenuItem = programsMenu->FirstItem;   
   struct IntuiText *text             = NULL;

   programsMenuItem = programsMenuItem->NextItem; // Skip over 'Launch Shell' menu Item

   while (programsMenuItem)
      {
      text = (struct IntuiText *) programsMenuItem->ItemFill;
      
      if (text && (StringLength( text->IText ) > 0) && (StringNComp( text->IText, "Empty", 5 ) != 0))
         fprintf( fp, "Menu = %s\n", text->IText );
	 
      programsMenuItem = programsMenuItem->NextItem;
      }

   return;
}

PRIVATE int writeStartupFile( void )
{
   FILE *fp   = NULL;
   int   rval = RETURN_OK, i, count;

   if (!(fp = fopen( TTStartupFile, "w" )))
      {
      rval = IoErr();
      
      fprintf( stderr, "fopen( \"%s\", \"w\" ) returned ERROR number %d\n", TTStartupFile, rval );

      goto exitWriteStartupFile;
      }

   fputs( "[WindowDataTags]\n", fp );
   fflush( fp );

   fprintf( fp, "WA_Title    = %s\n", PLWdt  ); // PLWnd->Title    );
   fprintf( fp, "WA_TopEdge  = %d\n", PLTop  ); // PLWnd->TopEdge  );
   fprintf( fp, "WA_LeftEdge = %d\n", PLLeft ); // PLWnd->LeftEdge );

   fputs( "[Programs]\n", fp );
   fflush( fp );
   
   for (i = 0, count = 0; i < lvm->lvm_NumItems; i++)
      {
      if (StringLength( &lvm->lvm_NodeStrs[ i * lvm->lvm_NodeLength ] ) > 0)
         count++;  
      }

   fprintf( fp, "ButtonCount = %d\n", count );

   for (i = 0; i < lvm->lvm_NumItems; i++)
      {
      if (StringLength( &lvm->lvm_NodeStrs[ i * lvm->lvm_NodeLength ] ) > 0)
         fprintf( fp, "Button      = %s\n", &lvm->lvm_NodeStrs[ i * lvm->lvm_NodeLength ] ); 
      }

   fputs( "[ProgramMenus]\n", fp );
   fflush( fp );
   
   writeProgramMenus( fp );
   
   if (fp)
      fclose( fp );
      
exitWriteStartupFile:

   return( rval );
}

PUBLIC int main( int argc, char **argv )
{
   struct WBArg  *wbarg;
   STRPTR        *toolptr = (STRPTR *) NULL;

   int errorChk = RETURN_OK;

   if ((errorChk = SetupProgram()) != RETURN_OK)
      {
      return( errorChk );
      }

   if (argc > 0)    // from CLI:
      {
      StringNCopy( &programName[0], argv[0], 80 );

      // We prefer to use the ToolTypes: 
      (void) FindIcon( &processToolTypes, diskobj, argv[0] );
      }
   else             // from Workbench:
      {
#     ifdef  __SASC
      wbarg = &(_WBenchMsg->sm_ArgList[ _WBenchMsg->sm_NumArgs - 1 ]);
#     else
      wbarg = &( __WBenchMsg->sm_ArgList[ __WBenchMsg->sm_NumArgs - 1 ]);
#     endif

      StringNCopy( &programName[0], wbarg->wa_Name, 80 );

      toolptr = FindTools( diskobj, wbarg->wa_Name, wbarg->wa_Lock );

      processToolTypes( toolptr );
      }

   if ((errorChk = setupGUI()) != RETURN_OK)
      goto exitProgramLauncher;

   if ( !lvm )
      {
      errorChk = ERROR_NO_FREE_STORE;

      goto exitProgramLauncher;
      }

   SetupList( &ProgramsLVList, lvm );

   GT_SetGadgetAttrs( PGM_LV_GAD, PLWnd, NULL,
                                  GTLV_Labels,       (ULONG) &ProgramsLVList, 
				  GTLV_ShowSelected, PGM_STR_GAD,
				  GTLV_Selected,     0,
				  TAG_DONE
		    );

   SetNotifyWindow( PLWnd );

   (void) HandlePLIDCMP();

   if ((errorChk = writeStartupFile()) != RETURN_OK)
      {
      sprintf( ErrMsg, CMsg( MSG_FMT_BAD_STARTUPFILE, MSG_FMT_BAD_STARTUPFILE_STR ), TTStartupFile );
      
      UserInfo( ErrMsg, CMsg( MSG_BAD_TOOLTYPE, MSG_BAD_TOOLTYPE_STR ) );
      }

exitProgramLauncher:

   FreeDiskObject( diskobj );
   
   ShutdownProgram();

   return( errorChk );
}

/* --------------- END of ProgramLauncher.c file! ------------------ */
