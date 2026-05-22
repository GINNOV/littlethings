/****h* ClipItTools.c [2.0] *******************************************
*
* NAME
*    ClipItTools.c
*
* DESCRIPTION
*    The various functions for dealing with the ToolTypes &
*    ToolTypes ListView Gadget in the ClipIt Program.
***********************************************************************
*
*/

#include <stdio.h>
#include <string.h>

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

#ifndef __amigaos4__

# include <proto/locale.h>

# include <clib/exec_protos.h>
# include <clib/intuition_protos.h>
# include <clib/gadtools_protos.h>
# include <clib/diskfont_protos.h>

#else

# define __USE_INLINE__

# include <proto/exec.h>
# include <proto/dos.h>
# include <proto/intuition.h>
# include <proto/gadtools.h>
# include <proto/locale.h>
# include <proto/icon.h>

# include <StringFunctions.h>
#endif

IMPORT struct Catalog *catalog;

#define   CATCOMP_ARRAY    1
#include "ClipItLocale.h"

#include "ClipItConstants.h"

#include "CPGM:GlobalObjects/CommonFuncs.h"

PUBLIC struct DiskObject *diskobj = NULL;

#ifndef __amigaos4__

IMPORT  struct WBStartup  *_WBenchMsg;

IMPORT struct Library       *IconBase;
IMPORT struct IntuitionBase *IntuitionBase;
IMPORT struct Library       *GadToolsBase;
IMPORT struct LocaleBase    *LocaleBase;

#else

IMPORT struct WBStartup *__WBenchMsg;

IMPORT struct Library *SysBase;
IMPORT struct Library *DOSBase;
IMPORT struct Library *IntuitionBase;
IMPORT struct Library *LocaleBase;
IMPORT struct Library *IconBase;
IMPORT struct Library *GadToolsBase;

IMPORT struct ExecIFace      *IExec;
IMPORT struct DOSIFace       *IDOS;
IMPORT struct IntuitionIFace *IIntuition;
IMPORT struct LocaleIFace    *ILocale;
IMPORT struct IconIFace      *IIcon;
IMPORT struct GadToolsIFace  *IGadTools;

#endif

// Located in ClipIt.c file... ------------------------------------------
IMPORT UBYTE         *ClipItPgmName;
IMPORT UBYTE         *ErrMsg;
IMPORT struct Screen *DBCScr;
IMPORT struct Window *DBCWnd;
IMPORT struct Gadget *DBCGadgets[];

IMPORT struct List         ToolTypesList;
IMPORT struct ListViewMem *ToolsLvm;

IMPORT STRPTR CMsg( int strIndex, char *defaultString );
// ----------------------------------------------------------------------

// ToolTypes: TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT

PUBLIC UBYTE ClipPath[TNAMELENGTH]    = "CLIPPATH";
PUBLIC UBYTE TextEditor[TNAMELENGTH]  = "TEXTEDITOR";
PUBLIC UBYTE TextViewer[TNAMELENGTH]  = "TEXTVIEWER";
PUBLIC UBYTE ImageEditor[TNAMELENGTH] = "IMAGEEDITOR";
PUBLIC UBYTE ImageViewer[TNAMELENGTH] = "IMAGEVIEWER";
PUBLIC UBYTE ProgramPath[TNAMELENGTH] = "PROGRAMPATH";
PUBLIC UBYTE HelpFile[TNAMELENGTH]    = "HELPFILE";
PUBLIC UBYTE HelpViewer[TNAMELENGTH]  = "HELPVIEWER";

PUBLIC UBYTE DefClipPath[TOOL_LENGTH]    = "CLIPS:";
PUBLIC UBYTE DefTextEditor[TOOL_LENGTH]  = "C:Ed";
PUBLIC UBYTE DefTextViewer[TOOL_LENGTH]  = "MultiView";
PUBLIC UBYTE DefImageEditor[TOOL_LENGTH] = "PPaint:PPaint";
PUBLIC UBYTE DefImageViewer[TOOL_LENGTH] = "MultiView";
PUBLIC UBYTE DefProgramPath[TOOL_LENGTH] = "ClipIt:";
PUBLIC UBYTE DefHelpFile[TOOL_LENGTH]    = "ClipIt.guide";
PUBLIC UBYTE DefHelpViewer[TOOL_LENGTH]  = "MultiView";

PUBLIC UBYTE *TTClipPath    = &DefClipPath[0];
PUBLIC UBYTE *TTTextEditor  = &DefTextEditor[0];
PUBLIC UBYTE *TTTextViewer  = &DefTextViewer[0];
PUBLIC UBYTE *TTImageEditor = &DefImageEditor[0];
PUBLIC UBYTE *TTImageViewer = &DefImageViewer[0];
PUBLIC UBYTE *TTProgramPath = &DefProgramPath[0];
PUBLIC UBYTE *TTHelpFile    = &DefHelpFile[0];
PUBLIC UBYTE *TTHelpViewer  = &DefHelpViewer[0];

// TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT

PRIVATE char PrgmName[ BUFF_SIZE ] = { 0, };

PUBLIC void UpdateMyIcon( UBYTE *OurProgramName )
{
   STRPTR *toolArray = NULL;
   BOOL    rval      = FALSE;

   if (StringLength( OurProgramName ) < 1)
      rval = GetProgramName( &PrgmName[0], BUFF_SIZE );
   else
      {
      StringCopy( PrgmName, OurProgramName );
      rval = TRUE;
      }

   if (rval != 0)
      {
      int    i;
      
      diskobj = GetDiskObject( &PrgmName[0] );

      if (!diskobj)
         {
         UserInfo( CMsg( MSG_MISSING_ICON_HUH, MSG_MISSING_ICON_HUH_STR ), 
	           CMsg( MSG_SYSTEM_PROBLEM, MSG_SYSTEM_PROBLEM_STR )
	         );

         return;
         }

      toolArray = diskobj->do_ToolTypes;
//      DBG( fprintf( stderr, "UpdateMyIcon():  toolArray = 0x%08LX\n", toolArray ) );

      i = 0;

      while (i < NUM_TOOLS)
         {
	 if (StringLength( &ToolsLvm->lvm_NodeStrs[ i * ELEMENT_SIZE ] ) > 0)
	    {
            *(toolArray + i) = &ToolsLvm->lvm_NodeStrs[ i * ELEMENT_SIZE ];

//	    DBG( fprintf( stderr, "   toolArray[%d] = %s\n", i, *(toolArray + i) ) );
	    }

         i++;
	 }

      (void) PutDiskObject( &PrgmName[0], diskobj );   
      }

   return;
}

PUBLIC void UpdateToolTypeList( void )
{
   HideListFromView( TOOLTYPES_LV, DBCWnd );

   sprintf( &ToolsLvm->lvm_NodeStrs[0               ], "%s=%s", ClipPath,    TTClipPath    );
   sprintf( &ToolsLvm->lvm_NodeStrs[    ELEMENT_SIZE], "%s=%s", TextEditor,  TTTextEditor  );
   sprintf( &ToolsLvm->lvm_NodeStrs[2 * ELEMENT_SIZE], "%s=%s", TextViewer,  TTTextViewer  );
   sprintf( &ToolsLvm->lvm_NodeStrs[3 * ELEMENT_SIZE], "%s=%s", ImageEditor, TTImageEditor );
   sprintf( &ToolsLvm->lvm_NodeStrs[4 * ELEMENT_SIZE], "%s=%s", ImageViewer, TTImageViewer );
   sprintf( &ToolsLvm->lvm_NodeStrs[5 * ELEMENT_SIZE], "%s=%s", ProgramPath, TTProgramPath );
   sprintf( &ToolsLvm->lvm_NodeStrs[6 * ELEMENT_SIZE], "%s=%s", HelpFile,    TTHelpFile    );
   sprintf( &ToolsLvm->lvm_NodeStrs[7 * ELEMENT_SIZE], "%s=%s", HelpViewer,  TTHelpViewer  );

   GT_SetGadgetAttrs( TOOLTYPES_LV, DBCWnd, NULL,
                      GTLV_Labels,       (ULONG) &ToolTypesList,
                      GTLV_ShowSelected, TOOLSTR_GAD,
                      GTLV_Selected,     0,
                      TAG_DONE
                    );

   GT_RefreshWindow( DBCWnd, NULL );

   return;
}

// FindToolString() called by ResetToolType() only.

SUBFUNC UBYTE *FindToolString( char *tool, int len )
{
   UBYTE *rval = NULL; 
   int    i    = 0;
   
   while (i < NUM_TOOLS)
      {
      if (StringNComp( &ToolsLvm->lvm_NodeStrs[ i * ELEMENT_SIZE ], tool, len ) == 0)
         {
         rval = &ToolsLvm->lvm_NodeStrs[ i * ELEMENT_SIZE ];

         break;
         }

      i++;
      }

   return( rval );
}

/****i* ResetToolType() -------------------------------------------
*
* NAME
*    ResetToolType()
*
* NOTES
*    Function works.
*******************************************************************
*
*/

PRIVATE void ResetToolType( char *newToolStr, int len )
{
   UBYTE *modTool   = NULL;
   char   temp[256] = { 0, };
   int    whichTool = -1;
   
   StringNCopy( &temp[0], newToolStr, ELEMENT_SIZE );

# define CLIPPATH_TOOL    0
# define TEXTEDITOR_TOOL  1
# define TEXTVIEWER_TOOL  2
# define IMAGEEDITOR_TOOL 3
# define IMAGEVIEWER_TOOL 4
# define PROGRAMPATH_TOOL 5
# define HELPFILE_TOOL    6
# define HELPVIEWER_TOOL  7
   
   if (StringNIComp( &temp[0], &ClipPath[0], len ) == 0)
      {
      modTool = FindToolString( &ClipPath[0], len );
      StringCopy( TTClipPath, &newToolStr[len + 1] );
      whichTool = CLIPPATH_TOOL;
      }
   else if (StringNIComp( &temp[0], &TextEditor[0], len ) == 0)
      {
      modTool = FindToolString( &TextEditor[0], len );
      StringCopy( TTTextEditor, &newToolStr[len + 1] );
      whichTool = TEXTEDITOR_TOOL;
      }
   else if (StringNIComp( &temp[0], &TextViewer[0], len ) == 0)
      {
      modTool = FindToolString( &TextViewer[0], len );
      StringCopy( TTTextViewer, &newToolStr[len + 1] );
      whichTool = TEXTVIEWER_TOOL;
      }
   else if (StringNIComp( &temp[0], &ImageEditor[0], len ) == 0)
      {
      modTool = FindToolString( &ImageEditor[0], len );
      StringCopy( TTImageEditor, &newToolStr[len + 1] );
      whichTool = IMAGEEDITOR_TOOL;
      }
   else if (StringNIComp( &temp[0], &ImageViewer[0], len ) == 0)
      {
      modTool = FindToolString( &ImageViewer[0], len );
      StringCopy( TTImageViewer, &newToolStr[len + 1] );
      whichTool = IMAGEVIEWER_TOOL;
      }
   else if (StringNIComp( &temp[0], &ProgramPath[0], len ) == 0)
      {
      modTool = FindToolString( &ProgramPath[0], len );
      StringCopy( TTProgramPath, &newToolStr[len + 1] );
      whichTool = PROGRAMPATH_TOOL;
      }
   else if (StringNIComp( &temp[0], &HelpViewer[0], len ) == 0)
      {
      modTool = FindToolString( &HelpViewer[0], len );
      StringCopy( TTHelpViewer, &newToolStr[len + 1] );
      whichTool = HELPVIEWER_TOOL;
      }
   else if (StringNIComp( &temp[0], &HelpFile[0], len ) == 0)
      {
      modTool = FindToolString( &HelpFile[0], len );
      StringCopy( TTHelpFile, &newToolStr[len + 1] );
      whichTool = HELPFILE_TOOL;
      }

   if (modTool)
      {
      HideListFromView( TOOLTYPES_LV, DBCWnd );

      switch (whichTool)
         {  
         case CLIPPATH_TOOL:    // 0
	    sprintf( modTool, "%s=%s", ClipPath, TTClipPath );
	    break;

         case TEXTEDITOR_TOOL:  // 1
	    sprintf( modTool, "%s=%s", TextEditor, TTTextEditor );
	    break;

         case TEXTVIEWER_TOOL:  // 2
	    sprintf( modTool, "%s=%s", TextViewer, TTTextViewer );
	    break;

         case IMAGEEDITOR_TOOL: // 3
	    sprintf( modTool, "%s=%s", ImageEditor, TTImageEditor );
	    break;

         case IMAGEVIEWER_TOOL: // 4
	    sprintf( modTool, "%s=%s", ImageViewer, TTImageViewer );
	    break;

         case PROGRAMPATH_TOOL: // 5
	    sprintf( modTool, "%s=%s", ProgramPath, TTProgramPath );
	    break;

         case HELPFILE_TOOL:    // 6
	    sprintf( modTool, "%s=%s", HelpFile, TTHelpFile );
	    break;

         case HELPVIEWER_TOOL:  // 7
	    sprintf( modTool, "%s=%s", HelpViewer, TTHelpViewer );
	    break;
	 }

      GT_SetGadgetAttrs( TOOLTYPES_LV, DBCWnd, NULL,
                         GTLV_Labels,       (ULONG) &ToolTypesList,
                         GTLV_ShowSelected, TOOLSTR_GAD,
                         GTLV_Selected,     0,
                         TAG_DONE
                       );
      }

   return;
}

/****i* ToolTypesClicked() ---------------------------------------
*
* NAME
*    ToolTypesClicked()
*
* NOTES
*    This function is now working correctly.
******************************************************************
*
*/

PUBLIC int ToolTypesClicked( int whichTool )
{
   char *toolname = (char *) &ToolsLvm->lvm_NodeStrs[ whichTool * ELEMENT_SIZE ];

   GT_SetGadgetAttrs( TOOLSTR_GAD, DBCWnd, NULL, GTST_String, (ULONG) toolname, TAG_END );

   return( (int) TRUE );
}

PUBLIC int TTypeStringClicked( int dummy )
{
   char *equal_loc = NULL;
   int   tool_len  = 0;

   if (StringLength( TOOLTYPE_STRING ) < 1)
      return( (int) TRUE );

   equal_loc = strchr( TOOLTYPE_STRING, '=' );

   if (!equal_loc)
      return( (int) TRUE ); // User typed in junk!
      
   tool_len = (int) (equal_loc - (char *) StrBfPtr( TOOLSTR_GAD ));

   ResetToolType( TOOLTYPE_STRING, tool_len );
      
   return( (int) TRUE );
}

PUBLIC void *processToolTypes( STRPTR *toolptr )
{
   if (!toolptr)
      return( NULL );

   TTClipPath    = GetToolStr( toolptr, ClipPath,    &DefClipPath[0]    );
   TTTextEditor  = GetToolStr( toolptr, TextEditor,  &DefTextEditor[0]  );
   TTTextViewer  = GetToolStr( toolptr, TextViewer,  &DefTextViewer[0]  );
   TTImageEditor = GetToolStr( toolptr, ImageEditor, &DefImageEditor[0] );
   TTImageViewer = GetToolStr( toolptr, ImageViewer, &DefImageViewer[0] );
   TTProgramPath = GetToolStr( toolptr, ProgramPath, &DefProgramPath[0] );
   TTHelpFile    = GetToolStr( toolptr, HelpFile,    &DefHelpFile[0]    );
   TTHelpViewer  = GetToolStr( toolptr, HelpViewer,  &DefHelpViewer[0]  );

   return( NULL );
}

/* --------------------- END of ClipItTools.c file! ----------------- */
