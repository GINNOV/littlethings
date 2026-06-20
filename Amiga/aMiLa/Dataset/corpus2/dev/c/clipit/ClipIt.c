/****h* ClipIt.c [2.0] **************************************************
*
* NAME
*    ClipIt.c
*
* DESCRIPTION
*    ClipIt.c is a GUI for accessing all 256 clipboard units in the
*    clipboard device.
*
* HISTORY
*    02-Nov-2005 - Started re-write for PowerPC, AmigaOS4 & gcc.
*    Jul-10-2005 - Created this file.
*
* COPYRIGHT
*    ClipIt.c Jul-10-2005(C) by J.T. Steichen
*
* NOTES
*    Defined ToolTypes & their default values are:
*
*       CLIPPATH   =CLIPS:
*       TEXTEDITOR =C:Ed
*       TEXTVIEWER =MultiView
*       IMAGEEDITOR=PPaint:ppaint
*       IMAGEVIEWER=MultiView
*       PROGRAMPATH=ClipIt:
*
*    Program set up to compile with gcc & AmigaOS4 also.
*
*    $VER: ClipIt.c 2.0 (02-Nov-2005) by J.T. Steichen
************************************************************************
*
*/

#include <stdio.h>
#include <string.h>
#include <fcntl.h>   // O_RDONLY, etc.

#include <exec/types.h>

#include <AmigaDOSErrs.h>

#include <intuition/intuition.h>
#include <intuition/classes.h>
#include <intuition/classusr.h>
#include <intuition/gadgetclass.h>

#include <libraries/gadtools.h>

#include <workbench/workbench.h>
#include <workbench/startup.h>
#include <workbench/icon.h>

#include <utility/tagitem.h>
#include <dos/dostags.h>

#include <libraries/asl.h>
#include <libraries/locale.h>

#include <graphics/displayinfo.h>
#include <graphics/gfxbase.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/graphics_protos.h>
#include <clib/utility_protos.h>
#include <clib/diskfont_protos.h>

#ifdef   __amigaos4__

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

#endif

#include "CB.h"
#include "ClipItConstants.h"

PUBLIC struct Catalog *catalog = NULL;

#define   CATCOMP_ARRAY    1
#include "ClipItLocale.h"

#define  MY_LANGUAGE "english"

#define    ALLOCATE
# include <Author.h> // for authorName[] & authorEMail[]
#undef     ALLOCATE

#include "CPGM:GlobalObjects/CommonFuncs.h"

// ----------------------------------------------------

PRIVATE UBYTE *TempFileName = "T:ClipItTempFile";

IMPORT struct DiskObject *diskobj; // Located in ClipItTools.c

#ifndef __amigaos4__

IMPORT  struct WBStartup  *_WBenchMsg;

struct Library       *IconBase;
struct IntuitionBase *IntuitionBase;
struct GfxBase       *GfxBase;
struct Library       *GadToolsBase;
struct LocaleBase    *LocaleBase;

PRIVATE char v[] = "\0$VER: ClipIt 2.0 " __AMIGADATE__ " by J.T. Steichen \0";

#else

IMPORT struct WBStartup *__WBenchMsg;

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

PRIVATE char v[] = "\0$VER: ClipItPPC 2.0 " __DATE__ " by J.T. Steichen \0";

#endif

// ----------------------------------------------------

IMPORT int GetClipNumber( int currentClipNumber ); // In ClipItReq.c file.

// --------- Located in ClipItTools.c file: ---------------

IMPORT void UpdateMyIcon( UBYTE *programName );
IMPORT void UpdateToolTypeList( void );

IMPORT UBYTE ClipPath[];
IMPORT UBYTE TextEditor[];
IMPORT UBYTE TextViewer[];
IMPORT UBYTE ImageEditor[];
IMPORT UBYTE ImageViewer[];
IMPORT UBYTE ProgramPath[];
IMPORT UBYTE HelpViewer[];
IMPORT UBYTE HelpFile[];

IMPORT UBYTE *TTClipPath;
IMPORT UBYTE *TTTextEditor;
IMPORT UBYTE *TTTextViewer;
IMPORT UBYTE *TTImageEditor;
IMPORT UBYTE *TTImageViewer;
IMPORT UBYTE *TTProgramPath;
IMPORT UBYTE *TTHelpViewer;
IMPORT UBYTE *TTHelpFile;
// --------------------------------------------------------

// Visible to ClipItReq.c & ClipItTools.c file also...

PUBLIC UBYTE ClipItPgmName[BUFF_SIZE] = { 0, };
PUBLIC UBYTE em[BUFF_SIZE] = { 0, }, *ErrMsg = &em[0];

PUBLIC struct Screen *DBCScr                = NULL;
PUBLIC struct Window *DBCWnd                = NULL;
PUBLIC struct Gadget *DBCGadgets[ DBC_CNT ] = { 0, }; // Used by ClipItTools.c also

PUBLIC UBYTE         *PubScreenName = "Workbench";
PUBLIC APTR           VisualInfo    = NULL;

PUBLIC struct TextFont     *DBCFont = NULL;
PUBLIC struct TextAttr     *Font, Attr;
PUBLIC struct CompFont      CFont = { 0, };

// PUBLIC struct TextAttr topaz8      = { "topaz.font",      8, 0x00, 0x62 };
PUBLIC struct TextAttr Helvetica13 = { "Helvetica.font", 13, 0x00, 0x62 };

// ----------------------------------------------------

PRIVATE struct Menu         *DBCMenus = NULL;
PRIVATE struct Gadget       *DBCGList = NULL;

PRIVATE struct IntuiMessage  DBCMsg = { 0, };

PRIVATE UWORD  DBCLeft   = 148;
PRIVATE UWORD  DBCTop    = 218;
PRIVATE UWORD  DBCWidth  = 760;
PRIVATE UWORD  DBCHeight = 360;
PRIVATE UBYTE *DBCWdt    = NULL;   // WA_Title
PRIVATE UBYTE *ScrTitle  = NULL;   // WA_ScreenTitle

// ------------------------------ ListView storage: ------------------------------

PRIVATE struct List         ClipsList = { 0, };
PRIVATE struct ListViewMem *ClipsLvm  = NULL;

// Visible to ClipItTools.c file also...
PUBLIC struct List         ToolTypesList = { 0, };
PUBLIC struct ListViewMem *ToolsLvm      = NULL;

// -------------------------------------------------------------------------------

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

PRIVATE int LoadMI(      void );
PRIVATE int SaveMI(      void );
// (BAR_LABEL)! -------------- 
PRIVATE int TextEditMI(  void );
PRIVATE int ImageEditMI( void );
// (BAR_LABEL)! -------------- 
PRIVATE int AboutMI(     void );
PRIVATE int HelpMI(      void );
PRIVATE int QuitMI(      void );

PRIVATE struct NewMenu DBCNMenu[ 11 ] = {

   NM_TITLE, "PROJECT", NULL, 0, 0L, (APTR) NULL,

    NM_ITEM, "Load...", "L", 0x0000, 0L, (APTR) LoadMI,

    NM_ITEM, "Save", "S", 0x0000, 0L, (APTR) SaveMI,

    NM_ITEM, (STRPTR) NM_BARLABEL, NULL, 0, 0L, (APTR) NULL,
    // ---------------------------------------------

    NM_ITEM, "Edit Text...", 0, 0x0000, 0L, (APTR) TextEditMI,

    NM_ITEM, "Edit Image...", 0, 0x0000, 0L, (APTR) ImageEditMI,

    NM_ITEM, (STRPTR) NM_BARLABEL, NULL, 0, 0L, (APTR) NULL,
    // ---------------------------------------------

    NM_ITEM, "About..", "I", 0x0000, 0L, (APTR) AboutMI,

    NM_ITEM, "Help...", "H", 0x0000, 0L, (APTR) HelpMI,

    NM_ITEM, "Quit", "Q", 0x0000, 0L, (APTR) QuitMI,

   NM_END, NULL, NULL, 0, 0L, (APTR) NULL
};

PRIVATE UWORD DBCGTypes[ DBC_CNT ] = {

      BUTTON_KIND,      BUTTON_KIND,    LISTVIEW_KIND,
    LISTVIEW_KIND,        TEXT_KIND,        TEXT_KIND,
      STRING_KIND,      BUTTON_KIND,        TEXT_KIND,
        TEXT_KIND,      NUMBER_KIND,      BUTTON_KIND,
};

// Located in ClipItTools.c file...
IMPORT  int ToolTypesClicked(   int whichTool );
IMPORT  int TTypeStringClicked( int dummy );

PRIVATE int ViewClipClicked(    int dummy );
PRIVATE int MakeClipClicked(    int dummy );
PRIVATE int ClipLVClicked(      int whichClip );
PRIVATE int DeleteClicked(      int dummy );
PRIVATE int UpdateBtClicked(    int dummy );

PRIVATE struct NewGadget DBCNGad[ DBC_CNT ] = {

   241, 156,  94,  20, "_View Clip", NULL,
   ID_ViewClip, PLACETEXT_IN, 0L, (APTR) ViewClipClicked,

   241, 183,  94,  20, "_Make Clip", NULL,
   ID_MakeClip, PLACETEXT_IN, 0L, (APTR) MakeClipClicked,

    10,  46, 215, 280, "Clip List:", NULL,
   ID_ClipLV, PLACETEXT_ABOVE, 0L, (APTR) ClipLVClicked,

   455,  46, 290, 176, "Tool Types:", NULL,
   ID_ToolTypes, NG_HIGHLABEL | PLACETEXT_ABOVE, 0L, (APTR) ToolTypesClicked,

   317,  75,  75,  20, "Clip Size (bytes):", NULL,
   ID_ClipSize, PLACETEXT_ABOVE, 0L, (APTR) NULL, // Text Gadget

   241, 126,  90,  20, "Clip Type:", NULL,
   ID_ClipType, PLACETEXT_ABOVE, 0L, (APTR) NULL, // Text Gadget

   455, 220, 290,  20, NULL, NULL,
   ID_TTypeString, 0, 0L, (APTR) TTypeStringClicked,

   241, 210,  94,  20, "Delete Clip", NULL,
   ID_Delete, PLACETEXT_IN, 0L, (APTR) DeleteClicked,

   243, 269, 502,  20, "Status:", NULL,
   ID_StatusTxt, PLACETEXT_ABOVE, 0L, (APTR) NULL, // Text Gadget

    10, 328, 199,  21, NULL, NULL,
   ID_ClipSelectedTxt, 0, 0L, (APTR) NULL, // Selected Clip Text Gadget

   344, 126,  61,  20, "Clip #:", NULL,
   ID_ClipNum, PLACETEXT_ABOVE, 0L, (APTR) NULL, // Number Gadget

    30,   5, 160,  20, "_Update Clip List", NULL,
   ID_UpdateBt, PLACETEXT_IN, 0L, (APTR) UpdateBtClicked,
};

PRIVATE ULONG DBCGTags[] = {

   GT_Underscore, '_', TAG_DONE, // _View Clip

   GT_Underscore, '_', TAG_DONE, // _Make Clip

   LAYOUTA_Spacing, 3, GTLV_ShowSelected,0L, GTLV_Selected, 0, GTLV_ShowSelected, 0, TAG_DONE, // Clip LV

   LAYOUTA_Spacing, 3, GTLV_ShowSelected, 0, GTLV_Selected, 0, TAG_DONE, // Tools LV

   GTTX_Border, TRUE, TAG_DONE, // Clip Size Txt

   GTTX_Border, TRUE, TAG_DONE, // Clip Type Txt

   GTST_MaxChars, 512, STRINGA_Justification, GTJ_LEFT, TAG_DONE, // Tool Selected String 

   TAG_DONE, // Delete Clip

   GTTX_Border, TRUE, TAG_DONE, // Status

   GTTX_Border, TRUE, TAG_DONE, // Selected Clip Txt

   GTNM_Border, TRUE, TAG_DONE, // CLip #

   GT_Underscore, '_', TAG_DONE, // _Update Clip List
};

// ----------------------------------------------------

PRIVATE struct IOClipReq *CurrentClipIOR  = NULL;
PRIVATE int               CurrentClipSize = 0;
PRIVATE int               CurrentClipType = 0;
PRIVATE int               CurrentClipNum  = 0;
PRIVATE BOOL              ClipInMemory    = FALSE;

// ----------------------------------------------------

/****h* CMsg() [2.0] *************************************************
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

/****i* SetupCatalog() [2.0] *****************************************
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
   ScrTitle = CMsg( MSG_DBC_STITLE, MSG_DBC_STITLE_STR ); // WA_ScreenTitle
   DBCWdt   = CMsg( MSG_DBC_WTITLE, MSG_DBC_WTITLE_STR ); // WA_Title

   // ToolTypes ----------------------------------------------------------------
   StringNCopy( ClipPath,    CMsg( MSG_DBC_TT_CLIPPATH,    MSG_DBC_TT_CLIPPATH_STR    ), TNAMELENGTH ); // CLIPPATH
   StringNCopy( TextEditor,  CMsg( MSG_DBC_TT_TEXTEDITOR,  MSG_DBC_TT_TEXTEDITOR_STR  ), TNAMELENGTH ); // TEXTEDITOR
   StringNCopy( TextViewer,  CMsg( MSG_DBC_TT_TEXTVIEWER,  MSG_DBC_TT_TEXTVIEWER_STR  ), TNAMELENGTH ); // TEXTVIEWER
   StringNCopy( ImageEditor, CMsg( MSG_DBC_TT_IMAGEEDITOR, MSG_DBC_TT_IMAGEEDITOR_STR ), TNAMELENGTH ); // IMAGEEDITOR
   StringNCopy( ImageViewer, CMsg( MSG_DBC_TT_IMAGEVIEWER, MSG_DBC_TT_IMAGEVIEWER_STR ), TNAMELENGTH ); // IMAGEVIEWER
   StringNCopy( ProgramPath, CMsg( MSG_DBC_TT_PROGRAMPATH, MSG_DBC_TT_PROGRAMPATH_STR ), TNAMELENGTH ); // PROGRAMPATH
   StringNCopy( HelpViewer,  CMsg( MSG_DBC_TT_HELPVIEWER,  MSG_DBC_TT_HELPVIEWER_STR  ), TNAMELENGTH ); //  HELPVIEWER
   StringNCopy( HelpFile,    CMsg( MSG_DBC_TT_HELPFILE,    MSG_DBC_TT_HELPFILE_STR    ), TNAMELENGTH ); // HELPFILE
   
   DBCNGad[  0 ].ng_GadgetText = CMsg( MSG_GAD_ViewClip,    MSG_GAD_ViewClip_STR );
   DBCNGad[  1 ].ng_GadgetText = CMsg( MSG_GAD_MakeClip,    MSG_GAD_MakeClip_STR );
   DBCNGad[  2 ].ng_GadgetText = CMsg( MSG_GAD_ClipLV,      MSG_GAD_ClipLV_STR );
   DBCNGad[  3 ].ng_GadgetText = CMsg( MSG_GAD_ToolTypes,   MSG_GAD_ToolTypes_STR );
   DBCNGad[  4 ].ng_GadgetText = CMsg( MSG_GAD_ClipSize,    MSG_GAD_ClipSize_STR );
   DBCNGad[  5 ].ng_GadgetText = CMsg( MSG_GAD_ClipType,    MSG_GAD_ClipType_STR );
//   DBCNGad[  6 ].ng_GadgetText = NULL; // Unlabeled Selected Tool Txt
   DBCNGad[  7 ].ng_GadgetText = CMsg( MSG_GAD_Delete,          MSG_GAD_Delete_STR );
   DBCNGad[  8 ].ng_GadgetText = CMsg( MSG_GAD_StatusTxt,       MSG_GAD_StatusTxt_STR );
//   DBCNGad[  9 ].ng_GadgetText = NULL; // Unlabeled ClipSelected Txt
   DBCNGad[ 10 ].ng_GadgetText = CMsg( MSG_GAD_ClipNumber,      MSG_GAD_ClipNumber_STR );
   DBCNGad[ 11 ].ng_GadgetText = CMsg( MSG_GAD_UpdateBt,        MSG_GAD_UpdateBt_STR   );

   // ---- Menu Strings (if any): -------------------------------- 
   DBCNMenu[ 0 ].nm_Label = CMsg( MSG_MENU_PROJECT, MSG_MENU_PROJECT_STR );
   DBCNMenu[ 1 ].nm_Label = CMsg( MSG_MENU_Load, MSG_MENU_Load_STR );
   DBCNMenu[ 2 ].nm_Label = CMsg( MSG_MENU_Save, MSG_MENU_Save_STR );
   // BAR_LABEL --------------------------------------------------- 
   DBCNMenu[ 4 ].nm_Label = CMsg( MSG_MENU_Edit_Text,  MSG_MENU_Edit_Text_STR );
   DBCNMenu[ 5 ].nm_Label = CMsg( MSG_MENU_Edit_Image, MSG_MENU_Edit_Image_STR );
   // BAR_LABEL --------------------------------------------------- 
   DBCNMenu[ 7 ].nm_Label = CMsg( MSG_MENU_About, MSG_MENU_About_STR );
   DBCNMenu[ 8 ].nm_Label = CMsg( MSG_MENU_Help,  MSG_MENU_Help_STR );
   DBCNMenu[ 9 ].nm_Label = CMsg( MSG_MENU_Quit,  MSG_MENU_Quit_STR );

   // ----- Menu Key strings (if any): ---------------------------- 
   DBCNMenu[ 1 ].nm_CommKey = CMsg( MSG_MENUKEY_L, MSG_MENUKEY_L_STR );
   DBCNMenu[ 2 ].nm_CommKey = CMsg( MSG_MENUKEY_S, MSG_MENUKEY_S_STR );
   DBCNMenu[ 7 ].nm_CommKey = CMsg( MSG_MENUKEY_I, MSG_MENUKEY_I_STR );
   DBCNMenu[ 8 ].nm_CommKey = CMsg( MSG_MENUKEY_H, MSG_MENUKEY_H_STR );
   DBCNMenu[ 9 ].nm_CommKey = CMsg( MSG_MENUKEY_Q, MSG_MENUKEY_Q_STR );

   SetTagItem( FileTags, ASLFR_TitleText,    (ULONG) CMsg( MSG_ASL_RTITLE,    MSG_ASL_RTITLE_STR    ));
   SetTagItem( FileTags, ASLFR_PositiveText, (ULONG) CMsg( MSG_ASL_OKAY_BT,   MSG_ASL_OKAY_BT_STR   ));
   SetTagItem( FileTags, ASLFR_NegativeText, (ULONG) CMsg( MSG_ASL_CANCEL_BT, MSG_ASL_CANCEL_BT_STR ));

   return;
}

PRIVATE int   currentSelection     = 0;
PRIVATE UBYTE CurrentClipName[256] = { 0, };

// Do NOT add any un-necessary '/' characters to the path/fileName string:

SUBFUNC void formatFile_Path( UBYTE *dest, UBYTE *clipPath, UBYTE *fileName )
{
   if (!strchr( fileName, ':' ) && !strchr( fileName, '/' )) // Path already present?
      {
      int len = StringLength( clipPath );
   
      if (clipPath[len - 1] == ':' || clipPath[len - 1] == '/')
         sprintf( dest, "%s%s", clipPath, fileName );
      else
         sprintf( dest, "%s/%s", clipPath, fileName );
      }
   else
      StringCopy( dest, fileName );
      
//   DBG( fprintf( stderr, "formatFile_Path() returns:  %s\n", dest ) );
   
   return;
}

SUBFUNC void getClipNumberFromUser( void )
{
   CurrentClipNum = GetClipNumber( CurrentClipNum );

   if (CurrentClipNum < 0 || CurrentClipNum > 255) // Bulletproof this variable.
      CurrentClipNum = 0;                          // Use default clip number = 0.

   sprintf( CurrentClipName, "%d", CurrentClipNum );

   formatFile_Path( ErrMsg, TTClipPath, CurrentClipName );

   StringNCopy( &CurrentClipName[0], ErrMsg, 256 );
      
   SetNotifyWindow( DBCWnd ); // Undo side-effect in GetClipNumber()

   return;
}

// ----------------------------------------------------------------

PRIVATE BOOL UnlockFlag = FALSE;

PRIVATE int OpenDBCScreen( void )
{
   struct Screen *chk = GetActiveScreen();

   if (!(DBCFont = OpenDiskFont( &Helvetica13 )))
      return( -5 );

   Font = &Attr;

   if (!(DBCScr = LockPubScreen( PubScreenName )))
      return( -1 );

   if (chk != DBCScr)
      {
      UnlockPubScreen( NULL, DBCScr );
      DBCScr = chk;
      UnlockFlag = FALSE;
      }
   else
      UnlockFlag = TRUE;

   ComputeFont( DBCScr, Font, &CFont, 0, 0 );

   if (!(VisualInfo = GetVisualInfo( DBCScr, TAG_DONE )))
      return( -2 );

   return( RETURN_OK );
}

PRIVATE void CloseDBCScreen( void )
{
   if (VisualInfo)
      {
      FreeVisualInfo( VisualInfo );

      VisualInfo = NULL;
      }

   if ((UnlockFlag == TRUE) && DBCScr)
      {
      UnlockPubScreen( NULL, DBCScr );

      DBCScr = NULL;
      }

   if (DBCFont)
      {
      CloseFont( DBCFont );

      DBCFont = NULL;
      }

   return;
}

PRIVATE void CloseDBCWindow( void )
{
   if (DBCMenus)
      {
      ClearMenuStrip( DBCWnd );
      FreeMenus( DBCMenus );
      DBCMenus = NULL;
      }

   if (DBCWnd)
      {
      CloseWindow( DBCWnd );

      DBCWnd = NULL;
      }

   if (DBCGList)
      {
      FreeGadgets( DBCGList );

      DBCGList = NULL;
      }

   return;
}

PRIVATE int DBCCloseWindow( void )
{
   if (SanityCheck( CMsg( MSG_USER_SANITY_CHECK, MSG_USER_SANITY_CHECK_STR )) == TRUE)
      {
      // Before closing, write out the ToolTypes to the icon:
      UpdateMyIcon( ClipItPgmName ); // Verify that this works (JTS)

      CloseDBCWindow();

      return( FALSE );
      }
   
   return( TRUE );
}

// ----------------------------------------------------------------

// nil out the ListView Gadget, for renewal later...

SUBFUNC void KillClipList( void )
{
   int i;
   
   HideListFromView( CLIPS_LV, DBCWnd );

      for (i = 0; i < MAX_CLIPS; i++)
         ClipsLvm->lvm_NodeStrs[i * ELEMENT_SIZE] = '\0';
	 
   GT_SetGadgetAttrs( CLIPS_LV, DBCWnd, NULL,
                      GTLV_Labels,       (ULONG) &ClipsList,
                      GTLV_ShowSelected, CLIP_TXT_GAD,
                      GTLV_Selected,     0,
                      TAG_DONE
                    );
   
   return;
}

PRIVATE int MakeClipList( void )
{
   struct FileInfoBlock *clip_fib    = NULL;
   BPTR                  clipdirlock = Lock( TTClipPath, ACCESS_READ );
   int  i = 0;
   
   if (!clipdirlock)
      {
      KillClipList();

      return( ERROR_DIR_NOT_FOUND );
      }

   clip_fib = (struct FileInfoBlock *) AllocDosObject( DOS_FIB, NULL );

   if (!clip_fib)
      {
      UnLock( clipdirlock );

      KillClipList();

      return( ERROR_NO_FREE_STORE );
      }

   // Disable Clip listview:
   HideListFromView( CLIPS_LV, DBCWnd );

   if (Examine( clipdirlock, clip_fib  ) != 0)
      {
      while ((ExNext( clipdirlock, clip_fib ) != 0) && (i < MAX_CLIPS))
         {
         if (clip_fib->fib_DirEntryType < 0)
            {
            // Got a file:
            StringCopy( &ClipsLvm->lvm_NodeStrs[ i * ELEMENT_SIZE ], clip_fib->fib_FileName );
            }

         i++;
         }
      }

   // Turn Clips ListView Gadget back on...
   GT_SetGadgetAttrs( CLIPS_LV, DBCWnd, NULL,
                      GTLV_Labels,       (ULONG) &ClipsList,
                      GTLV_ShowSelected, CLIP_TXT_GAD,
                      GTLV_Selected,     0,
                      TAG_DONE
                    );

   FreeDosObject( DOS_FIB, (void *) clip_fib );

   UnLock( clipdirlock );

   return( RETURN_OK );
}

PRIVATE char I2A[10];

PUBLIC char *Int2ASCII( int number ) // Used in ClipItReq.c also.
{
#  ifdef __SASC
   (void) stci_d( &I2A[0], number );
#  else
   itoa( number, &I2A[0] );
   // sprintf( &I2A[0], "%d", number );
#  endif

   return( &I2A[0] );
}

// Beyond this point be Dragons (& bugs, lots of them!).

// ----------------------------------------------------------------

PRIVATE int GetClipSizeType( int unitnumber )
{
   ULONG SizeTypeBuf[4] = { 0, 0, 0, 0 };
   
   CurrentClipIOR = CBOpen( unitnumber );

   if (!CurrentClipIOR)
      {
      UserInfo( CMsg( MSG_CLIP_NOT_OPEN, MSG_CLIP_NOT_OPEN_STR ),
                CMsg( MSG_NO_MEMORY_HUH, MSG_NO_MEMORY_HUH_STR )
	      );

      GT_SetGadgetAttrs( STATUS_TXT_GAD, DBCWnd, NULL,
                         GTTX_Text, CMsg( MSG_CLIP_NOT_OPEN, MSG_CLIP_NOT_OPEN_STR ),
                         TAG_END 
                       );

      return( ERROR_OBJECT_NOT_FOUND );
      }

   CurrentClipIOR->io_Offset  = 0;
   CurrentClipIOR->io_Error   = 0;
   CurrentClipIOR->io_ClipID  = 0;
   CurrentClipIOR->io_Command = CMD_READ;
   CurrentClipIOR->io_Data    = (STRPTR) &SizeTypeBuf[0];
   CurrentClipIOR->io_Length  = 16; // Just read the header info.

   DoIO( (struct IORequest *) CurrentClipIOR );

   if (CurrentClipIOR->io_Actual == 16)
      {
      if (SizeTypeBuf[0] == ID_FORM)
         {
         if (SizeTypeBuf[2] == ID_FTXT)
            {
            CurrentClipType = 0; 
            GT_SetGadgetAttrs( CLIPTYPE_TXT, DBCWnd, NULL,
                               GTTX_Text, (STRPTR) "FTXT", TAG_END
                             );

            CurrentClipSize = (int) SizeTypeBuf[1];
            }
         else // ILBM??
            {
            CurrentClipType = 1; 
            GT_SetGadgetAttrs( CLIPTYPE_TXT, DBCWnd, NULL,
                               GTTX_Text, (STRPTR) "ILBM", TAG_END
                             );
            }

         CurrentClipSize = (int) SizeTypeBuf[1];


         GT_SetGadgetAttrs( CLIPSIZE_TXT, DBCWnd, NULL,
                            GTTX_Text, 
                            (STRPTR) Int2ASCII( (int) SizeTypeBuf[1] ), 
                            TAG_END
                          );
         }
      }
   else // Didn't read the header in:
      {
      CurrentClipType = 0; 
      GT_SetGadgetAttrs( CLIPTYPE_TXT, DBCWnd, NULL,
                         GTTX_Text, (STRPTR) "FTXT", TAG_END
                       );

      CurrentClipSize = 0;
      GT_SetGadgetAttrs( CLIPSIZE_TXT, DBCWnd, NULL,
                         GTTX_Text, 
                         (STRPTR) "0", TAG_END
                       );

      GT_SetGadgetAttrs( STATUS_TXT_GAD, DBCWnd, NULL,
                         GTTX_Text, CMsg( MSG_CLIP_NOT_READ, MSG_CLIP_NOT_READ_STR ),
			 TAG_END 
                       );
      }

   CBReadDone( CurrentClipIOR );
   CBClose( CurrentClipIOR );

   return( RETURN_OK );
}

SUBFUNC int RunMyCommand( UBYTE *command )
{
   int rval = RETURN_OK;

   DBG( fprintf( stderr, "System( \"%s\" )...\n", command ) );
   
   if ((rval = System( command, TAG_DONE )) != RETURN_OK)
      {
      sprintf( ErrMsg, CMsg( MSG_FMT_GARBLED_COMMAND, MSG_FMT_GARBLED_COMMAND_STR ), command );

      UserInfo( ErrMsg, CMsg( MSG_BAD_TOOLTYPE, MSG_BAD_TOOLTYPE_STR ) );
      }
   
   return( rval );
}

/****i* DisplayText() ---------------------------------------------
*
* NAME
*    DisplayText() 
*
* NOTES
*    Incredibubble!  This function worked right from the start!
*******************************************************************
*
*/

PRIVATE void DisplayText( char *text, int size )
{
/*
#  ifndef __amigaos4__
   struct ProcID   disp_proc = { 0, };
   struct FORKENV  disp_env  = { 0, };
#  endif
*/
   FILE           *tfile = NULL;
   char            ch;
   int             i, rval = 0;
      
   if (!(tfile = fopen( TempFileName, "w" )))
      return;
   
   i = 0;

   /* CurrentClipSize is gathered from the FTXT size field.  It does NOT
   ** reflect the fact that there is a string for FORM & a long value
   ** for the size field.  This means that we have to adjust the 
   ** output by FORMSIZE_OFFSET in order to compensate for this:
   */

   while (i < (size)) // + FORMSIZE_OFFSET))
      {
      ch = *(text + i);

      (void) fputc( (int) ch, tfile );

      i++;
      }

   if (CurrentClipType == 0)
      {
      i = 0;

      while (i < FORMSIZE_OFFSET)
         {
         (void) fputc( 0, tfile );

         i++;
         }
      }   

   fclose( tfile );

//#  ifdef __amigaos4__
   sprintf( ErrMsg, "%s %s", TTTextViewer, TempFileName );

   (void) RunMyCommand( ErrMsg );
/*
#  else // Works for SAS-C at any rate...
   rval = forkl( TTTextViewer, TTTextViewer, 
                 TempFileName, NULL, &disp_env, &disp_proc
               );

   (void) wait( &disp_proc ); // wait for the viewer to exit.
#  endif
*/

   return;
}

/****i* DisplayImage() --------------------------------------------
*
* NAME
*    DisplayImage() 
*
* NOTES
*    Incredibubble!  This function worked right from the start!
*******************************************************************
*
*/

PRIVATE void DisplayImage( char *text, int size )
{
/*
#  ifndef __amigaos4__
   struct ProcID   disp_proc = { 0, };
   struct FORKENV  disp_env  = { 0, };
#  endif
*/
   FILE           *tfile = NULL;
   char            ch;
   int             i, rval = 0;

   if (CurrentClipType != 1)
      return;
       
   if (!(tfile = fopen( TempFileName, "w" )))
      return;
   
   i = 0;

   /* CurrentClipSize is gathered from the FTXT size field.  It does NOT
   ** reflect the fact that there is a string for FORM & a long value
   ** for the size field.  This means that we have to adjust the 
   ** output by FORMSIZE_OFFSET in order to compensate for this:
   */

   while (i < (size)) //  + FORMSIZE_OFFSET))
      {
      ch = *(text + i);

      (void) fputc( (int) ch, tfile );

      i++;
      }

   i = 0;
   
   while (i < FORMSIZE_OFFSET)
      {
      (void) fputc( 0, tfile );

      i++;
      }

   fclose( tfile );

//#  ifdef __amigaos4__
   sprintf( ErrMsg, "%s %s", TTImageViewer, TempFileName );

   (void) RunMyCommand( ErrMsg );
/*
#  else   // works for SAS-C at any rate...
   rval = forkl( TTImageViewer, TTImageViewer, 
                 TempFileName, NULL, &disp_env, &disp_proc
               );

   (void) wait( &disp_proc ); // wait for the viewer to exit.
#  endif
*/
   return;
}

// -----------------------------------------------------------------

SUBFUNC int callTranslateToFile( int clipNumber, UBYTE *clipName )
{
   int err = RETURN_OK;

   if ((err = FTXTToFile( clipNumber, clipName )) != 0)
      {
      SetReqButtons( CMsg( MSG_OUCH_BUTTON, MSG_OUCH_BUTTON_STR ) );

      sprintf( ErrMsg, CMsg( MSG_FMT_TRANSLATION_ERROR, MSG_FMT_TRANSLATION_ERROR_STR ), 
                       clipNumber, clipName
             );

      StringCat( ErrMsg, CBErrMsgs[ -err - 1 ] );

      UserInfo( ErrMsg, CMsg( MSG_SYSTEM_PROBLEM, MSG_SYSTEM_PROBLEM_STR ) );

      SetReqButtons( CMsg( MSG_DEFAULT_BUTTONS, MSG_DEFAULT_BUTTONS_STR ) );
      } 
   
   return( err );
}

/****i* TranslateToFile() -----------------------------------------
*
* NAME
*    TranslateToFile() 
*
*******************************************************************
*
*/

PRIVATE int TranslateToFile( void )
{
   int err = 0;
   
   if (StringLength( CurrentClipName ) < 1)   
      {
      SetReqButtons( CMsg( MSG_OOPS_BUTTON, MSG_OOPS_BUTTON_STR ) );

      UserInfo( CMsg( MSG_ENTER_CLIP_NAME, MSG_ENTER_CLIP_NAME_STR ), // "Enter a FileName first!", 
                CMsg( MSG_USER_ERROR, MSG_USER_ERROR_STR )
              );

      SetReqButtons( CMsg( MSG_DEFAULT_BUTTONS, MSG_DEFAULT_BUTTONS_STR ) );

      return( (int) TRUE );
      }

   if (callTranslateToFile( CurrentClipNum, CLIP_TEXT ) != RETURN_OK)
      return( TRUE );
   
   SetReqButtons( CMsg( MSG_WELL_OKAY_BUTTON, MSG_WELL_OKAY_BUTTON_STR ) );

   sprintf( ErrMsg, CMsg( MSG_FMT_CLIP_SENT_OUT, MSG_FMT_CLIP_SENT_OUT_STR ), CurrentClipNum, CLIP_TEXT );

   UserInfo( ErrMsg, CMsg( MSG_USER_INFO_RQTITLE, MSG_USER_INFO_RQTITLE_STR ) );

   SetReqButtons( CMsg( MSG_DEFAULT_BUTTONS, MSG_DEFAULT_BUTTONS_STR ) );

   return( (int) TRUE );
}

PRIVATE int CBTextEdit( int clipnumber, UBYTE *clipName )
{
   char command[ BUFF_SIZE ] = { 0, };

   // translate from FTXT to something an editor understands...
   if (callTranslateToFile( clipnumber, TempFileName ) != RETURN_OK)
      return( TRUE );

   StringCopy( &command[0], TTTextEditor );
   StringCat( &command[0], " " );
   StringCat( &command[0], TempFileName ); // has path also.

   (void) RunMyCommand( &command[0] );   

   return( (int) TRUE );
}

PRIVATE int CBImageEdit( int clipnumber, UBYTE *clipName )
{
   char command[ BUFF_SIZE ] = { 0, };

   StringCopy( &command[0], TTImageEditor );
   StringCat( &command[0], " " );
   StringCat( &command[0], clipName ); // has path also.

   (void) RunMyCommand( &command[0] );   

   return( (int) TRUE );
}

/* GetClipSizeType() doesn't get the proper header information from a
** stored clip file.
*/

PRIVATE int GetFileSizeType( char *filename )
{
   ULONG SizeTypeBuf[4] = { 0, 0, 0, 0 };

   int   infile = 0, readsize = 0, rval = 0;
      
   if ((infile = open( filename, O_RDONLY, 0 )) < 0)
      return( IFFERR_READ );

   readsize = read( infile, &SizeTypeBuf[0], 16 );

   if (readsize > 0)
      {
      if (SizeTypeBuf[0] == ID_FORM)
         {
         if (SizeTypeBuf[2] == ID_FTXT)
            {
            CurrentClipType = 0; 
            GT_SetGadgetAttrs( CLIPTYPE_TXT, DBCWnd, NULL,
                               GTTX_Text, (ULONG) "FTXT", TAG_END
                             );
            }
         else // ILBM??
            {
            CurrentClipType = 1; 
            GT_SetGadgetAttrs( CLIPTYPE_TXT, DBCWnd, NULL,
                               GTTX_Text, (ULONG) "ILBM", TAG_END
                             );
            }

         CurrentClipSize = (int) SizeTypeBuf[1];

         GT_SetGadgetAttrs( CLIPSIZE_TXT, DBCWnd, NULL,
                            GTTX_Text, (ULONG) Int2ASCII( (int) SizeTypeBuf[1] ), 
                            TAG_END
                          );
         }
      }
   else // Didn't read the header in:
      {
      CurrentClipType = 0; 
      GT_SetGadgetAttrs( CLIPTYPE_TXT, DBCWnd, NULL,
                         GTTX_Text, (STRPTR) "FTXT", TAG_END
                       );

      CurrentClipSize = 0;
      GT_SetGadgetAttrs( CLIPSIZE_TXT, DBCWnd, NULL,
                         GTTX_Text, (STRPTR) "0", TAG_END
                       );

      GT_SetGadgetAttrs( STATUS_TXT_GAD, DBCWnd, NULL,
                         GTTX_Text, (ULONG) CMsg( MSG_CLIP_NOT_READ_STATUS, MSG_CLIP_NOT_READ_STATUS_STR ),
			 TAG_END 
                       );
      rval = -1;
      }

   close( infile );

   return( rval );
}

PRIVATE int LoadMI( void );

PRIVATE int ViewClip( int cliptype )
{
   char *clipdata = NULL;

   if (ClipInMemory == FALSE) // Avoid ping-ponging with LoadMI()!!
      (void) LoadMI();

   if (StringLength( CurrentClipName ) < 1)
      return( TRUE ); // getClipNumberFromUser();

   GT_SetGadgetAttrs( CLIP_NUMGAD, DBCWnd, NULL,
                      GTST_String, (ULONG) Int2ASCII( CurrentClipNum ),
                      TAG_END
                    );

   GetClipSizeType( CurrentClipNum ); // Has to be BEFORE CBOpen()!!!

   if (cliptype == FTXT_CLIP_TYPE)
      {
      CurrentClipIOR = CBOpen( CurrentClipNum );

      if (!CurrentClipIOR)
         {
         sprintf( ErrMsg, CMsg( MSG_FMT_CLIP_NOT_OPEN, MSG_FMT_CLIP_NOT_OPEN_STR ), CurrentClipNum );

         UserInfo( ErrMsg, CMsg( MSG_NO_MEMORY_HUH, MSG_NO_MEMORY_HUH_STR ) );

         GT_SetGadgetAttrs( STATUS_TXT_GAD, DBCWnd, NULL,
                            GTTX_Text, (STRPTR) ErrMsg,
                            TAG_END 
                          );

         return( ERROR_OBJECT_NOT_FOUND );
         }

      if (CurrentClipSize > 0) // Need to fix this!
         clipdata = FillCBData( CurrentClipIOR, CurrentClipSize );

      DisplayText( clipdata, CurrentClipSize );

      CBFreeBuf( clipdata );

      CBReadDone( CurrentClipIOR );
      CBClose(    CurrentClipIOR );
      }
   else
      {
      sprintf( ErrMsg, "%s %s", TTImageViewer, CurrentClipName );
      
      (void) RunMyCommand( ErrMsg );
//      DisplayImage( clipdata, CurrentClipSize ); // Delete this later
      }

   return( RETURN_OK );
}

/****i* LoadThefile() ---------------------------------------------
*
* NAME
*    LoadThefile()
* 
* DESCRIPTION
*    Take the input file & move it to the given glip number.
*    The file has to contain an FTXT or ILBM chunk.
*******************************************************************
*
*/

PRIVATE int LoadTheFile( char *filename, int clipnumber )
{
   int errchk = RETURN_OK;

   sprintf( ErrMsg, CMsg( MSG_FMT_LOADING_CLIP, MSG_FMT_LOADING_CLIP_STR ), filename );
   
   GT_SetGadgetAttrs( STATUS_TXT_GAD, DBCWnd, NULL, GTTX_Text, (ULONG) ErrMsg, TAG_END );

   GetFileSizeType( filename );

   if (CurrentClipType == 1)
      {
      // The file is an ILBM picture:
      if ((errchk = ILBMFileToClip( filename, clipnumber )) < 0)
         {
         sprintf( ErrMsg, CMsg( MSG_FMT_FILE_NOT_LOADED, MSG_FMT_FILE_NOT_LOADED_STR ),
                  errchk, CBGetIFFError( errchk ) 
                );

         SetReqButtons( CMsg( MSG_OUCH_BUTTON, MSG_OUCH_BUTTON_STR ) );
      
         UserInfo( ErrMsg, CMsg( MSG_FILING_SYSTEM_PROBLEM, MSG_FILING_SYSTEM_PROBLEM_STR ) );

         SetReqButtons( CMsg( MSG_DEFAULT_BUTTONS, MSG_DEFAULT_BUTTONS_STR ) );
         
         GT_SetGadgetAttrs( STATUS_TXT_GAD, DBCWnd, NULL,
                            GTTX_Text, CMsg( MSG_TRANSFER_PROBLEM, MSG_TRANSFER_PROBLEM_STR ), TAG_END 
                          );
         return( -1 );
         }

      goto ExitLoadTheFile;
      }
   else
      {
      // Here is where we read in the file. 
      if ((errchk = FTXTFileToClip( filename, clipnumber )) < 0)
         {
         int ans = 0;

         SetReqButtons( CMsg( MSG_METHOD_BUTTONS, MSG_METHOD_BUTTONS_STR ) );
         
         ans = Handle_Problem( CMsg( MSG_UNKNOWN_FILE_TYPE, MSG_UNKNOWN_FILE_TYPE_STR ),
                               CMsg( MSG_FILING_SYSTEM_PROBLEM, MSG_FILING_SYSTEM_PROBLEM_STR ), NULL
                             );

         SetReqButtons( CMsg( MSG_DEFAULT_BUTTONS, MSG_DEFAULT_BUTTONS_STR ) );

         if (ans == 0)
            {
            if ((errchk = FileToFTXT( clipnumber, filename )) < 0)
               {
               sprintf( ErrMsg, CMsg( MSG_FMT_FILE_NOT_ASCII, MSG_FMT_FILE_NOT_ASCII_STR ),
                                      errchk, CBGetIFFError( errchk ) 
                      );

               SetReqButtons( CMsg( MSG_OUCH_BUTTON, MSG_OUCH_BUTTON_STR ) );
      
               UserInfo( ErrMsg,
                         CMsg( MSG_FILING_SYSTEM_PROBLEM, MSG_FILING_SYSTEM_PROBLEM_STR )
                       );

               SetReqButtons( CMsg( MSG_DEFAULT_BUTTONS, MSG_DEFAULT_BUTTONS_STR ) );
         
               GT_SetGadgetAttrs( STATUS_TXT_GAD, DBCWnd, NULL,
                                  GTTX_Text, CMsg( MSG_TRANSFER_PROBLEM, MSG_TRANSFER_PROBLEM_STR ),
				  TAG_END 
                                );
               return( -1 );
               }
         
            GT_SetGadgetAttrs( STATUS_TXT_GAD, DBCWnd, NULL,
                               GTTX_Text, CMsg( MSG_TRANSFER_COMPLETE, MSG_TRANSFER_COMPLETE_STR ),
			       TAG_END 
                             );
            return( RETURN_OK );
            }
         else 
            GT_SetGadgetAttrs( STATUS_TXT_GAD, DBCWnd, NULL,
                                  GTTX_Text, CMsg( MSG_TRANSFER_PROBLEM, MSG_TRANSFER_PROBLEM_STR ),
				  TAG_END 
                             );
         return( -1 );
         } 
      }

ExitLoadTheFile:

   GT_SetGadgetAttrs( STATUS_TXT_GAD, DBCWnd, NULL,
                             GTTX_Text, CMsg( MSG_TRANSFER_COMPLETE, MSG_TRANSFER_COMPLETE_STR ),
                             TAG_END 
                    );

   return( RETURN_OK );
}

SUBFUNC int callTranslateToClip( int clipNumber, UBYTE *clipFileName )
{
   int err = RETURN_OK;
   
   if ((err = FileToFTXT( clipNumber, clipFileName )) != 0)
      {
      SetReqButtons( CMsg( MSG_OUCH_BUTTON, MSG_OUCH_BUTTON_STR ) );

      sprintf( ErrMsg, CMsg( MSG_FMT_FILE_TRANSLATION_ERROR, MSG_FMT_FILE_TRANSLATION_ERROR_STR ), 
                             clipFileName, clipNumber
             );

      StringCat( ErrMsg, CBErrMsgs[ -err - 1 ] );

      UserInfo( ErrMsg, CMsg( MSG_SYSTEM_PROBLEM, MSG_SYSTEM_PROBLEM_STR ) );

      SetReqButtons( CMsg( MSG_DEFAULT_BUTTONS, MSG_DEFAULT_BUTTONS_STR ) );
      }
   
   return( err );
}

/****i* TranslateToClip() -----------------------------------------
*
* NAME
*    TrnanslateToClip() 
*
*******************************************************************
*
*/

PRIVATE int TranslateToClip( int dummy )
{
   if (StringLength( CurrentClipName ) < 1)   
      {
      SetReqButtons( CMsg( MSG_OOPS_BUTTON, MSG_OOPS_BUTTON_STR ) );

      UserInfo( CMsg( MSG_ENTER_CLIP_NAME, MSG_ENTER_CLIP_NAME_STR ), // "Enter a FileName first!", 
                CMsg( MSG_USER_ERROR, MSG_USER_ERROR_STR )
              );

      SetReqButtons( CMsg( MSG_DEFAULT_BUTTONS, MSG_DEFAULT_BUTTONS_STR ) );

      return( (int) TRUE );
      }

   if (callTranslateToClip( CurrentClipNum, CurrentClipName ) != RETURN_OK)
      return( TRUE );
      
   SetReqButtons( CMsg( MSG_WELL_OKAY_BUTTON, MSG_WELL_OKAY_BUTTON_STR ) );

   sprintf( ErrMsg, CMsg( MSG_FMT_FILE_SENT_OUT, MSG_FMT_FILE_SENT_OUT_STR ),
                    CurrentClipName, CurrentClipNum 
          );

   UserInfo( ErrMsg, CMsg( MSG_USER_INFO_RQTITLE, MSG_USER_INFO_RQTITLE_STR ) );

   SetReqButtons( CMsg( MSG_DEFAULT_BUTTONS, MSG_DEFAULT_BUTTONS_STR ) );

   return( (int) TRUE );
}

// --------------------------------------------------------------------

PRIVATE int ASLClicked( int dummy )
{
   char UserClipName[ BUFF_SIZE ] = { 0, };

   SetTagItem( &FileTags[0], ASLFR_Window, (ULONG) DBCWnd );

   SetTagItem( &FileTags[0], ASLFR_InitialDrawer, (ULONG) &TTClipPath[0] );

   SetTagItem( &FileTags[0], ASLFR_TitleText, (ULONG) CMsg( MSG_SET_CLIP_NAME, MSG_SET_CLIP_NAME_STR ));

   if (FileReq( UserClipName, &FileTags[0] ) > 1)
      {
      StringNCopy( ErrMsg, &UserClipName[0], ELEMENT_SIZE );
      
      GT_SetGadgetAttrs( CLIP_TXT_GAD, DBCWnd, NULL,
                         GTTX_Text, (ULONG) ErrMsg, TAG_END 
                       );

      GT_SetGadgetAttrs( STATUS_TXT_GAD, DBCWnd, NULL,
                         GTTX_Text, (ULONG) CMsg( MSG_WAITING_FOR_USER, MSG_WAITING_FOR_USER_STR ), 
			 TAG_END 
                       );
      }

   return( TRUE );
}

// User wants to view the CurrentClipNum: 

PRIVATE int ViewClipClicked( int dummy )
{
   if (StringLength( CurrentClipName ) < 1)
      getClipNumberFromUser();

   GT_SetGadgetAttrs( CLIP_NUMGAD, DBCWnd, NULL,
                      GTST_String, (ULONG) Int2ASCII( CurrentClipNum ),
                      TAG_END
                    );

   ClipInMemory = TRUE;

   // This should work, check & see:
   // (void) GetClipSizeType( CurrentClipNum );

   (void) ViewClip( CurrentClipType );

   return( TRUE );
}

// Just call the appropriate Editor:

PRIVATE int MakeClipClicked( int dummy )
{
   int cliptype = -1;
   
   getClipNumberFromUser();
   
   GT_SetGadgetAttrs( CLIP_NUMGAD, DBCWnd, NULL,
                      GTST_String, (ULONG) Int2ASCII( CurrentClipNum ),
                      TAG_END
                    );

   SetReqButtons( CMsg( MSG_CLIP_TYPE_BUTTONS, MSG_CLIP_TYPE_BUTTONS_STR ) );
   
   cliptype = Handle_Problem( CMsg( MSG_WHAT_TYPE_OF_CLIP, MSG_WHAT_TYPE_OF_CLIP_STR ),
                              CMsg( MSG_HELP_ME_RQTITLE, MSG_HELP_ME_RQTITLE_STR ), NULL 
                            );
   
   SetReqButtons( CMsg( MSG_DEFAULT_BUTTONS, MSG_DEFAULT_BUTTONS_STR ) );
   
   if (cliptype != ILBM_RESPONSE)      // 2nd Button = 1
      {
//      (void) CBTextEdit( CurrentClipNum, CurrentClipName );
      DBG( fprintf( stderr, "Calling \"%s\"...\n", TTTextEditor ) );
      
      (void) RunMyCommand( TTTextEditor );   
      }
   else if (cliptype == ILBM_RESPONSE) // First button == 0
      (void) CBImageEdit( CurrentClipNum, CurrentClipName );
   // else // Might be an abort button added later!!
   
   return( TRUE );
}

/****i* ClipLVClicked() ------------------------------------------
*
* NAME
*    ClipLVClicked()
*
* NOTES
*    This function is now working correctly.
******************************************************************
*
*/

PRIVATE int ClipLVClicked( int whichClip )
{
   UBYTE  clip                 = 0;
   UBYTE  tbuf[ ELEMENT_SIZE ] = { 0, };

   // clipname contains the clip numbers only, no path info!
   char  *clipname = (char *) &ClipsLvm->lvm_NodeStrs[ whichClip * ELEMENT_SIZE ];
   char   dummy[12] = { 0, };

   if (StringLength( clipname ) > 0)
      {
      currentSelection = whichClip;
      formatFile_Path( ErrMsg, TTClipPath, clipname ); // Add in the Path to clipboards...

      StringNCopy( &tbuf[0], ErrMsg, ELEMENT_SIZE );
      StringCopy( &CurrentClipName[0], &tbuf[0] ); // Set up a global.
   
      GT_SetGadgetAttrs( CLIP_TXT_GAD, DBCWnd, NULL,
                         GTTX_Text, (ULONG) &CurrentClipName[0], TAG_END 
                       );

      // translate the contents into a clip number...
      clip           = (UBYTE) strtoul( FilePart( &tbuf[0] ), &dummy[0], 10 );
      CurrentClipNum = clip;    // Update global variable.

      (void) GetClipSizeType( CurrentClipNum );
	 
      DBG( fprintf( stderr, "ClipLVClicked() generated %d from %s\n", clip, &tbuf[0] ) );
      }
   else
      {
      UserInfo( CMsg( MSG_EMPTY_SLOT, MSG_EMPTY_SLOT_STR ), 
                CMsg( MSG_USER_ERROR, MSG_USER_ERROR_STR ) 
	      );

      clip = 0;

      formatFile_Path( ErrMsg, TTClipPath, "0" ); // Add in the Path to clipboards...

      StringNCopy( &CurrentClipName[0], ErrMsg, ELEMENT_SIZE );

      (void) GetClipSizeType( clip );

      GT_SetGadgetAttrs( CLIP_TXT_GAD, DBCWnd, NULL,
                         GTTX_Text, (ULONG) &CurrentClipName[0], TAG_END 
                       );
      }

   GT_SetGadgetAttrs( CLIP_NUMGAD, DBCWnd, NULL,
                      GTNM_Number, (ULONG) clip,
                      TAG_END
                    );

   return( TRUE );
}

PRIVATE int DeleteClicked( int dummy )
{
   BOOL answer = FALSE;
   
   sprintf( ErrMsg, CMsg( MSG_FMT_DELETE_CHECK, MSG_FMT_DELETE_CHECK_STR ), 
                    CurrentClipName
          );

   // Check user sanity first...
   answer = SanityCheck( ErrMsg );

   if (answer == TRUE)
      {
      (void) DeleteFile( CurrentClipName );

      KillClipList(); // Re-make the Clip ListView.

      (void) MakeClipList();

      ClipInMemory = FALSE;
      
      GT_SetGadgetAttrs( CLIP_TXT_GAD, DBCWnd, NULL,
                         GTTX_Text, (STRPTR) "", TAG_END 
                       );

      GT_SetGadgetAttrs( CLIPTYPE_TXT, DBCWnd, NULL,
                         GTTX_Text, (STRPTR) "", TAG_END 
                       );

      GT_SetGadgetAttrs( CLIPSIZE_TXT, DBCWnd, NULL,
                         GTTX_Text, (STRPTR) "", TAG_END 
                       );

      GT_SetGadgetAttrs( STATUS_TXT_GAD, DBCWnd, NULL,
                         GTTX_Text, (ULONG) CMsg( MSG_CLIP_DELETED, MSG_CLIP_DELETED_STR ),
                         TAG_END 
                       );
      }

   return( (int) TRUE );
}

PRIVATE int UpdateBtClicked( int dummy )
{
   KillClipList();

   (void) MakeClipList();

   ClipInMemory = FALSE;
      
   GT_SetGadgetAttrs( CLIP_TXT_GAD, DBCWnd, NULL, GTTX_Text, (ULONG) "", TAG_END );

   GT_SetGadgetAttrs( CLIPTYPE_TXT, DBCWnd, NULL, GTTX_Text, (ULONG) "", TAG_END );

   GT_SetGadgetAttrs( CLIPSIZE_TXT, DBCWnd, NULL, GTTX_Text, (ULONG) "", TAG_END );

   GT_SetGadgetAttrs( STATUS_TXT_GAD, DBCWnd, NULL,
                      GTTX_Text, (ULONG) CMsg( MSG_WAITING_FOR_USER, MSG_WAITING_FOR_USER_STR ), 
	              TAG_END 
                    );
   
   return( ClipLVClicked( 0 ) );
}

// ------------ Menu functions are next... -------------------------------------

/****i* LoadMI() *************************************************
*
* NAME
*    LoadMI()
*
* NOTES
*    The user might think that they're loading a clip but in
*    reality, this function just reads a file, since loading
*    from a real clip in memory is performed with the 
*    ClipNumber Gadget handler.  This function will have to be
*    changed so that it will read a file, instead of using
*    CBOpen(), etc.
*
****************************************************************
*
*/

PRIVATE int LoadMI( void )
{
   char UserClipName[ ELEMENT_SIZE ] = { 0, };
   int  answer = 0;

   if (StringLength( CurrentClipName ) < 1)
      getClipNumberFromUser(); // Along with path name!

   GT_SetGadgetAttrs( CLIP_NUMGAD, DBCWnd, NULL,
                      GTNM_Number, (ULONG) CurrentClipNum,
                      TAG_END
                    );
    
   if (StringLength( CurrentClipName ) < 1)
      {
      // need an input filename:
      SetTagItem( &FileTags[0], ASLFR_Window, (ULONG) DBCWnd );
      SetTagItem( &FileTags[0], ASLFR_InitialDrawer, (ULONG) TTClipPath );

      answer = FileReq( UserClipName, &FileTags[0] );

      if (answer > 1)
         {
	 GT_SetGadgetAttrs( CLIP_TXT_GAD, DBCWnd, NULL, GTTX_Text, UserClipName, TAG_DONE );

         formatFile_Path( ErrMsg, TTClipPath, CurrentClipName );

         StringCopy( &UserClipName[0], ErrMsg );

         GT_SetGadgetAttrs( CLIP_TXT_GAD, DBCWnd, NULL,
                            GTTX_Text, (ULONG) ErrMsg, TAG_END 
                          );
         }
      else
         {
	 ClipInMemory = FALSE;
	 
         return( (int) TRUE ); // No filename, abort operation.
	 }
      }

   if (LoadTheFile( CurrentClipName, CurrentClipNum ) < 0)
      return( (int) TRUE );

   if (GetFileSizeType( CurrentClipName ) != 0)
      return( (int) TRUE );

   ClipInMemory = TRUE; // Don't play ping-pong with ViewClip()!

   SetReqButtons( CMsg( MSG_CLIP_ACTION_BUTTONS, MSG_CLIP_ACTION_BUTTONS_STR ) );

   answer = GetUserResponse( CMsg( MSG_SELECT_ACTION, MSG_SELECT_ACTION_STR ),
                             CMsg( MSG_HELP_ME_RQTITLE, MSG_HELP_ME_RQTITLE_STR ), NULL
                           );

   SetReqButtons( CMsg( MSG_DEFAULT_BUTTONS, MSG_DEFAULT_BUTTONS_STR ) );
      
   if (answer == 1)              // User wants to View Clip:
      {
      if (CurrentClipType == FTXT_CLIP_TYPE)
         (void) ViewClip( FTXT_CLIP_TYPE );
      else   
         (void) ViewClip( ILBM_CLIP_TYPE );
      }
   else if (answer == 2)         // User wants to Edit Clip:
      {
      if (CurrentClipType == FTXT_CLIP_TYPE)
         (void) CBTextEdit( CurrentClipNum, CurrentClipName );
      else   
         (void) CBImageEdit( CurrentClipNum, CurrentClipName );
      }
   // else User selected Abort.

   GT_SetGadgetAttrs( STATUS_TXT_GAD, DBCWnd, NULL,
                      GTTX_Text, CMsg( MSG_WAITING_FOR_USER, MSG_WAITING_FOR_USER_STR ), TAG_END 
                    );

   return( (int) TRUE );
}

/****i* SaveMI() **************************************************
*
* NAME
*    SaveMI()
*******************************************************************
*
*/

PRIVATE int SaveMI( void )
{
   char  UserFileName[ BUFF_SIZE ] = { 0, };
   int   answer = 0;
   
   getClipNumberFromUser();
   
   GT_SetGadgetAttrs( CLIP_NUMGAD, DBCWnd, NULL,
                      GTNM_Number, (ULONG) CurrentClipNum,
                      TAG_END
                    );

   SetTagItem( &FileTags[0], ASLFR_Window, (ULONG) DBCWnd );
   SetTagItem( &FileTags[0], ASLFR_InitialDrawer, (ULONG) TTProgramPath );
   SetTagItem( &FileTags[0], ASLFR_TitleText, (ULONG) CMsg( MSG_SAVE_CLIP, MSG_SAVE_CLIP_STR ) );

   answer = FileReq( UserFileName, &FileTags[0] );

   if (answer > 1)
      {
      sprintf( ErrMsg, CMsg( MSG_FMT_TRANSLATE_SAVING, MSG_FMT_TRANSLATE_SAVING_STR ),
                             CurrentClipNum, UserFileName 
	     );
	 
      GT_SetGadgetAttrs( STATUS_TXT_GAD, DBCWnd, NULL,
                         GTTX_Text, (ULONG) ErrMsg, TAG_DONE 
                       );
      }
   else
      {
      GT_SetGadgetAttrs( STATUS_TXT_GAD, DBCWnd, NULL,
                         GTTX_Text, CMsg( MSG_ABORTED_SAVE, MSG_ABORTED_SAVE_STR ), 
                         TAG_DONE 
                       );

      return( TRUE ); // No filename, abort operation.
      }
      
   if (GetFileSizeType( CurrentClipName ) != 0)
      return( TRUE );

   sprintf( ErrMsg, CMsg( MSG_FMT_WRITE_CHECK, MSG_FMT_WRITE_CHECK_STR ), 
                    CurrentClipNum, UserFileName
          );

   if (SanityCheck( ErrMsg ) == FALSE)
      {
      GT_SetGadgetAttrs( STATUS_TXT_GAD, DBCWnd, NULL,
                         GTTX_Text, CMsg( MSG_USER_IS_SANE, MSG_USER_IS_SANE_STR ), TAG_END 
                       );

      return( TRUE );
      }
   
   if (ClipToFile( CurrentClipNum, UserFileName ) < 0) // ClipFuncs.c function
      {
      SetReqButtons( CMsg( MSG_WELL_OKAY_BUTTON, MSG_WELL_OKAY_BUTTON_STR ) );

      UserInfo( CMsg( MSG_NO_TRANSFER_DONE, MSG_NO_TRANSFER_DONE_STR ),
                CMsg( MSG_SYSTEM_PROBLEM, MSG_SYSTEM_PROBLEM_STR )
              );

      SetReqButtons( CMsg( MSG_DEFAULT_BUTTONS, MSG_DEFAULT_BUTTONS_STR ) );

      GT_SetGadgetAttrs( STATUS_TXT_GAD, DBCWnd, NULL,
                            GTTX_Text, CMsg( MSG_TRANSFER_PROBLEM, MSG_TRANSFER_PROBLEM_STR ),
	                    TAG_END 
                       );

      ClipInMemory = FALSE;

      return( TRUE );
      }

   GT_SetGadgetAttrs( STATUS_TXT_GAD, DBCWnd, NULL,
                      GTTX_Text, CMsg( MSG_CLIP_WRITTEN, MSG_CLIP_WRITTEN_STR ), TAG_END 
                    );

   return( TRUE );
}

SUBFUNC void setupForEditing( void )
{
   if (ClipInMemory == FALSE)
      (void) LoadMI();

   (void) GetClipSizeType( CurrentClipNum );

   return;
}

PRIVATE int TextEditMI( void )
{
   setupForEditing();
   
   (void) CBTextEdit( CurrentClipNum, CurrentClipName );

   return( TRUE );
}

PRIVATE int ImageEditMI( void )
{
   setupForEditing();

   (void) CBImageEdit( CurrentClipNum, CurrentClipName );

   return( TRUE );
}

/****i* AboutMI() **************************************************
*
* NAME
*    AboutMI() - Show the user some info on the program.
******************************************************************
*
*/

PRIVATE int AboutMI( void )
{
   sprintf( ErrMsg, CMsg( MSG_FMT_ABOUT_PROGRAM, MSG_FMT_ABOUT_PROGRAM_STR ),
                    ClipItPgmName, authorName, authorEMail           
	  );

   SetReqButtons( CMsg( MSG_ASL_OKAY_BT, MSG_ASL_OKAY_BT_STR ) );

   UserInfo( ErrMsg, CMsg( MSG_ABOUT_RQTITLE, MSG_ABOUT_RQTITLE_STR ) );

   SetReqButtons( CMsg( MSG_DEFAULT_BUTTONS, MSG_DEFAULT_BUTTONS_STR ) );
   
   GT_SetGadgetAttrs( STATUS_TXT_GAD, DBCWnd, NULL,
                      GTTX_Text, CMsg( MSG_WAITING_FOR_USER, MSG_WAITING_FOR_USER_STR ), TAG_END 
                    );

   return( TRUE );
}

PRIVATE int HelpMI( void )
{
   UBYTE command[ BUFF_SIZE ];
   
   sprintf( command, "%s %s", TTHelpViewer, TTHelpFile );

   (void) RunMyCommand( command );
      
   return( TRUE );
}

PRIVATE int QuitMI( void )
{
   return( DBCCloseWindow() );
}

// ----------------------------------------------------------------

PRIVATE int OpenDBCWindow( void )
{
   struct NewGadget  ng;
   struct Gadget    *g;
   UWORD             lc, tc;
   UWORD             wleft, wtop, ww, wh;
   UWORD             zoomCoords[] = { 200, 0, 300, 25 };
    
   ComputeFont( DBCScr, Font, &CFont, DBCWidth, DBCHeight );

   ww = ComputeX( CFont.FontX, DBCWidth  );
   wh = ComputeY( CFont.FontY, DBCHeight );

   wleft = (DBCScr->Width  - DBCWidth ) / 2;
   wtop  = (DBCScr->Height - DBCHeight) / 2;

   if (!(g = CreateContext( &DBCGList )))
      return( -1 );

   for (lc = 0, tc = 0; lc < DBC_CNT; lc++)
      {
      CopyMem( (char *) &DBCNGad[ lc ], (char *) &ng,
               (long) sizeof( struct NewGadget )
             );

      ng.ng_VisualInfo = VisualInfo;
      ng.ng_TextAttr   = &Helvetica13;
      ng.ng_LeftEdge   = CFont.OffX + ComputeX( CFont.FontX, ng.ng_LeftEdge );
      ng.ng_TopEdge    = CFont.OffY + ComputeY( CFont.FontY, ng.ng_TopEdge );

      DBCGadgets[ lc ] = g
                       = CreateGadgetA( (ULONG) DBCGTypes[ lc ],
                                        g,
                                        &ng,
                                        (struct TagItem *) &DBCGTags[ tc ]
                                      );

      while (DBCGTags[ tc ] != TAG_DONE)
         tc += 2;

      tc++;

      if (!g)
         return( -2 );
      }

   if (!(DBCMenus = CreateMenus( DBCNMenu, GTMN_FrontPen, 0L, TAG_DONE )))
      return( -3 );

   LayoutMenus( DBCMenus, VisualInfo, TAG_DONE );

   if (!(DBCWnd = OpenWindowTags( NULL,

         WA_Left,          wleft,
         WA_Top,           wtop,
         WA_Width,         ww + CFont.OffX + DBCScr->WBorRight,
         WA_Height,        wh + CFont.OffY + DBCScr->WBorBottom,

         WA_IDCMP,        STRINGIDCMP | BUTTONIDCMP | LISTVIEWIDCMP | IDCMP_RAWKEY
           | TEXTIDCMP | IDCMP_CLOSEWINDOW | IDCMP_MENUPICK | IDCMP_VANILLAKEY 
	   | IDCMP_REFRESHWINDOW,

         WA_Flags,         WFLG_ACTIVATE | WFLG_DRAGBAR | WFLG_DEPTHGADGET
           | WFLG_CLOSEGADGET | WFLG_HASZOOM,

         WA_NewLookMenus,  TRUE,
         WA_Gadgets,       DBCGList,
         WA_Title,         DBCWdt,
	 WA_Zoom,          (ULONG) &zoomCoords,
         WA_ScreenTitle,   ScrTitle,
         WA_CustomScreen,  DBCScr,
         TAG_DONE )))
      {
      return( -4 );
      }

   SetMenuStrip( DBCWnd, DBCMenus );

   GT_RefreshWindow( DBCWnd, NULL );

   return( 0 );
}

PRIVATE int DBCVanillaKey( int whichKey )
{
   int rval = TRUE;

   switch (whichKey)
      {
      case 'v':
      case 'V': // _View Clip
         rval = ViewClipClicked( 0 );
         break;
	 
      case 'm':
      case 'M': // _Make Clip
         rval = MakeClipClicked( 0 );
	 break;
	 
      case 'q':
      case 'Q':
         rval = QuitMI();
	 break;
      
      case 'l':
      case 'L':
         rval = LoadMI();
         break;

      case 's':
      case 'S':
         rval = SaveMI();
         break;

      case 'i':
      case 'I':
         rval = AboutMI();
         break;

      case 'h':
      case 'H':
         rval = HelpMI();
         break;

      default:
         break;
      }

   return( rval );
}

PRIVATE int DBCRawKey( struct IntuiMessage *msg )
{
   int   rval     = TRUE;
   UWORD whichKey = (UWORD) msg->Code;
      
   switch (whichKey)
      {
      case HELP: // 95 = 0x5F 
         rval = HelpMI();
         break;
                  
      default:
         break;
      }
      
   return( rval );
}

PRIVATE int HandleDBCIDCMP( void )
{
   struct IntuiMessage *m;
   int                (*func)( int );
   BOOL                 running = TRUE;

   while (running == TRUE)
      {
      if (!(m = GT_GetIMsg( DBCWnd->UserPort )))
         {
         (void) Wait( 1L << DBCWnd->UserPort->mp_SigBit );

         continue;
         }

      CopyMem( (char *) m, (char *) &DBCMsg, 
               (long) sizeof( struct IntuiMessage )
             );

      GT_ReplyIMsg( m );

      switch (DBCMsg.Class)
         {
         case IDCMP_CLOSEWINDOW:
            running = DBCCloseWindow();
            break;

         case IDCMP_GADGETDOWN:
         case IDCMP_GADGETUP:
            if ((func = (int (*)( int )) ((struct Gadget *) DBCMsg.IAddress)->UserData))
               running = func( DBCMsg.Code );

            break;

         case IDCMP_MENUPICK:
            if (DBCMsg.Code != MENUNULL)
               {
               int (*mfunc)( void );

               struct MenuItem *n = ItemAddress( DBCMenus, DBCMsg.Code );

               if (n)
                  if ((mfunc = (int (*)( void )) (GTMENUITEM_USERDATA( n ))))
                     running = mfunc();
               }

            break;

         case IDCMP_VANILLAKEY:
            running = DBCVanillaKey( DBCMsg.Code );
            break;

         case IDCMP_RAWKEY:
            running = DBCRawKey( &DBCMsg );
            break;

         case IDCMP_REFRESHWINDOW:
            GT_BeginRefresh( DBCWnd );

            GT_EndRefresh( DBCWnd, TRUE );

            break;
         }
      }

   return( running );
}

// ----------------------------------------------------------------

PRIVATE void closeLibraries( void )
{
#  ifndef __amigaos4__
   CloseLibs();

   if (LocaleBase)
      CloseLibrary( (struct Library *) LocaleBase );

   if (IconBase)
      CloseLibrary( (struct Library *) IconBase );
#  else
   if (IGadTools)
      DropInterface( (struct Interface *) IGadTools );
   
   if (GadToolsBase)
      CloseLibrary( GadToolsBase );
#  endif

   return;
}

PRIVATE void ShutdownProgram( void )
{
   CloseDBCWindow();

   CloseDBCScreen();

   Guarded_FreeLV( ClipsLvm );

   Guarded_FreeLV( ToolsLvm );
 
   if (catalog)
      CloseCatalog( catalog );

   closeLibraries();

   if (FileExists( TempFileName )) // Located in CommonFuncsPPC.o
      {
      sprintf( ErrMsg, "delete %s QUIET\n", TempFileName );
   
      (void) System( ErrMsg, TAG_DONE );
      }

   return;
}

PRIVATE int openLibraries( void )
{
   int rval = RETURN_OK;
   
#  ifndef __amigaos4__
   rval = OpenLibs();

   if (!(IconBase = OpenLibrary( "icon.library", 37L )))
      {
      fprintf( stderr, CMsg( MSG_FMT_LIB_UNOPENED, MSG_FMT_LIB_UNOPENED_STR ),
                       "icon.library", "37" 
             );

      closeLibraries();	
                  
      rval = ERROR_INVALID_RESIDENT_LIBRARY;
      }

   if (!(LocaleBase = OpenLibrary( "locale.library", 37L )))
      {
      fprintf( stderr, CMsg( MSG_FMT_LIB_UNOPENED, MSG_FMT_LIB_UNOPENED_STR ),
                       "locale.library", "37" 
             );

      closeLibraries();
            
      rval = ERROR_INVALID_RESIDENT_LIBRARY;
      }
#  else // __amigaos4__ is DEFINED!  -lauto does NOT open gadtools.library!

   if ((GadToolsBase = OpenLibrary( "gadtools.library", 50L )))
      {
      if (!(IGadTools = (struct GadToolsIFace *) GetInterface( GadToolsBase, "main", 1, NULL )))
         {
         fprintf( stderr, CMsg( MSG_FMT_LIB_UNOPENED, MSG_FMT_LIB_UNOPENED_STR ),
                          "IGadTools.IFace", "50" 
                );

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

   catalog = OpenCatalog( NULL, "ClipIt.catalog",
                                OC_BuiltInLanguage, MY_LANGUAGE,
                                TAG_DONE 
                        );

   (void) SetupCatalog();

   if (OpenDBCScreen() != RETURN_OK)
      {
      rval = ERROR_ON_OPENING_SCREEN;

      ShutdownProgram();

      goto exitSetup;
      }

   if (OpenDBCWindow() != RETURN_OK)
      {
      rval = ERROR_ON_OPENING_WINDOW;

      ShutdownProgram();

      goto exitSetup;
      }

   ToolsLvm = Guarded_AllocLV( NUM_TOOLS, ELEMENT_SIZE );

   if ( !ToolsLvm )
      {
      rval = ERROR_NO_FREE_STORE;

      ShutdownProgram();

      goto exitSetup;
      }
   else
      {
      UBYTE temp[256] = { 0, };
	
      SetupList( &ToolTypesList, ToolsLvm );
      
      sprintf( temp, "%s=%s", ClipPath, TTClipPath );
      StringNCopy( &ToolsLvm->lvm_NodeStrs[ 0 ], temp, ELEMENT_SIZE );

      sprintf( temp, "%s=%s", TextEditor, TTTextEditor );
      StringNCopy( &ToolsLvm->lvm_NodeStrs[ ELEMENT_SIZE ], temp, ELEMENT_SIZE );

      sprintf( temp, "%s=%s", TextViewer, TTTextViewer );
      StringNCopy( &ToolsLvm->lvm_NodeStrs[ 2 * ELEMENT_SIZE ], temp, ELEMENT_SIZE );

      sprintf( temp, "%s=%s", ImageEditor, TTImageEditor );
      StringNCopy( &ToolsLvm->lvm_NodeStrs[ 3 * ELEMENT_SIZE ], temp, ELEMENT_SIZE );

      sprintf( temp, "%s=%s", ImageViewer, TTImageViewer );
      StringNCopy( &ToolsLvm->lvm_NodeStrs[ 4 * ELEMENT_SIZE ], temp, ELEMENT_SIZE );

      sprintf( temp, "%s=%s", ProgramPath, TTProgramPath );
      StringNCopy( &ToolsLvm->lvm_NodeStrs[ 5 * ELEMENT_SIZE ], temp, ELEMENT_SIZE );

      GT_SetGadgetAttrs( TOOLTYPES_LV, DBCWnd, NULL,
                          GTLV_ShowSelected, TOOLSTR_GAD,
			  GTLV_Labels,       &ToolTypesList,
			  GTLV_Selected,     0,
			  TAG_DONE
		       );
      }

   ClipsLvm = Guarded_AllocLV( MAX_CLIPS, ELEMENT_SIZE );

   if ( !ClipsLvm )
      {
      rval = ERROR_NO_FREE_STORE;

      ShutdownProgram();

      goto exitSetup;
      }
   else
      {
      SetupList( &ClipsList, ClipsLvm );

      GT_SetGadgetAttrs( CLIPS_LV, DBCWnd, NULL,
                          GTLV_ShowSelected, (ULONG) CLIP_TXT_GAD,
			  GTLV_Labels,       (ULONG) &ClipsList,
			  GTLV_Selected,     0,
			  TAG_DONE
		       );
      }

exitSetup:

   return( rval );
}

IMPORT void *processToolTypes( STRPTR *toolptr );

PUBLIC int main( int argc, char **argv )
{
   struct WBArg  *wbarg;
   STRPTR        *toolptr = (STRPTR *) NULL;

   int error = RETURN_OK;

   if ((error = SetupProgram()) != RETURN_OK)
      {
      return( error );
      }
      
   if (argc > 0)    // from CLI:
      {
      // We prefer to use the ToolTypes: 
      (void) FindIcon( &processToolTypes, diskobj, argv[0] );

      StringNCopy( &ClipItPgmName[0], argv[0], BUFF_SIZE );
      DBG( fprintf( stderr, "ProgramName = '%s'\n", ClipItPgmName ) );
      }
   else             // from Workbench:
      {
#     ifndef __amigaos4__
      wbarg   = &(_WBenchMsg->sm_ArgList[ _WBenchMsg->sm_NumArgs - 1 ]);
#     else
      wbarg   = &( __WBenchMsg->sm_ArgList[ __WBenchMsg->sm_NumArgs - 1 ]);
#     endif

      toolptr = FindTools( diskobj, wbarg->wa_Name, wbarg->wa_Lock );

      processToolTypes( toolptr );

      StringNCopy( &ClipItPgmName[0], wbarg->wa_Name, BUFF_SIZE );
      DBG( fprintf( stderr, "ProgramName = '%s'\n", ClipItPgmName ) );
      }

   UpdateToolTypeList(); // Reflect the Icon tooltypes -> listview.

   SetNotifyWindow( DBCWnd );

   (void) MakeClipList(); // Ignore errors from here.

   (void) ClipLVClicked( 0 ); // Fake a User click on top element.

   (void) HandleDBCIDCMP();

   FreeDiskObject( diskobj );
   
   ShutdownProgram();

   return( RETURN_OK );
}

/* --------------- END of ClipIt.c file! ------------------ */
