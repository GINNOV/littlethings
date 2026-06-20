/****h* IniFuncs.h [1.4] ****************************************
*
* NAME
*    IniFuncs.h
*
* DESCRIPTION
*    Primary structure definition & function prototypes for 
*    IniFuncs.c
*
* HISTORY
*    01-Nov-2004 - Added AmigaOS4 & gcc support.
*
*    28-Sep-2003 - Added iniFirstGroup & iniLastGroup functions.
*
*    23-Sep-2003 - Changed the return type of iniGetItemValue() to
*                  char * from ULONG *.
*
*    16-Sep-2003 - Created this file.
*
* COPYRIGHT
*    (c) 2003 by J.T. Steichen, ALL rights reserved.
*   
* NOTES
*    The idea for this group of functions was inspired by
*    amigaini.library.  Since I don't have access to the original
*    source code, everything in this file is of my own efforts.
*
*    $VER: IniFuncs.h 1.4 (01-Nov-2004) by J.T. Steichen
*****************************************************************
*
*/


#ifndef  INIFUNCS_H
# define INIFUNCS_H 1

# ifndef    EXEC_TYPES_H
#  include <exec/types.h>
# endif

# ifndef    AMIGADOSERRS_H
#  include <AmigaDOSErrs.h> // PUBLIC, PRIVATE, etc.
# endif

# ifndef    INTUITION_INTUITION_H
#  include <intuition/intuition.h>
# endif

# ifndef    GRAPHICS_GFXBASE_H
#  include <graphics/gfxbase.h>
# endif

# include <proto/locale.h>

# ifndef     INIFUNCSLOCALE_H
#  define    CATCOMP_ARRAY      1
#  include  "IniFuncsLocale.h"
# endif

# ifndef __amigaos4__ 
IMPORT __far struct IntuitionBase *IntuitionBase;
IMPORT __far struct GfxBase       *GfxBase;
IMPORT __far struct Library       *GadToolsBase;
IMPORT __far struct LocaleBase    *LocaleBase;
# else
IMPORT struct Library *IntuitionBase;
IMPORT struct Library *GfxBase;
IMPORT struct Library *GadToolsBase;
IMPORT struct Library *LocaleBase;
# endif

# define MAX_ERROR_NUMBER       12
 
# define INI_MAX_LINE_SIZE      512

# define INI_MAX_GROUPNAME_SIZE (INI_MAX_LINE_SIZE - 3) // because of the []\n requirements

# define DEFAULT_FILE_SIZE      100

// --------------------------------------------------------------------

# ifdef INIFUNCS_C
PUBLIC char const *DEFAULT_DELIMITERS = "= &|\0"; // 0x3D20267C
# else
IMPORT char const *DEFAULT_DELIMITERS; // "= &|\0"; 0x3D20267C
# endif

PUBLIC struct amigaIni {

   // Fields that get set once only (normally): ------------------

   char               *ai_FileName;         
   BPTR                ai_FilePtr;

   // Fields that change: ----------------------------------------
   
   struct List         ai_FileList;
   struct ListViewMem *ai_LVM;      // The .ini file contents.
   
};

typedef struct amigaIni *aiPTR, AI;

/* If you use iniView_EditContents, be sure to test for changes
** to updateAIPointer & use aiCopy to reset whatever aiPTR you're
** currently using after iniVIew_EditContents() returns.
*/

IMPORT aiPTR aiCopy;
IMPORT BOOL  updateAIPointer; // FALSE unless set by iniView_EditContents()

IMPORT struct Catalog       *aiCatalog;

IMPORT char const *DEFAULT_DELIMITERS; // = "= &|"; // 0x3D20267C

IMPORT char currentGroupName[ INI_MAX_LINE_SIZE ];
IMPORT char currentItemName[  INI_MAX_LINE_SIZE ];
IMPORT char currentItemValue[ INI_MAX_LINE_SIZE ];

IMPORT ULONG currentErrorNumber;
IMPORT ULONG currentLineNumber;
IMPORT ULONG currentGroupStartLineNumber;
IMPORT ULONG currentGroupEndLineNumber;
IMPORT ULONG numberOfElements;            // The number of lines in the file.

// --------------------------------------------------------------------

# define INI_NOERROR     0
# define INI_NOFILE      1
# define INI_NOCONTENT   2             // FileLines < 1 
# define INI_NOFILEOPEN  3
# define INI_NOHEADER    4             // Missing []
# define INI_NOITEM      5
# define INI_NOMEMORY    6
# define INI_NOITEMADDED 7
# define INI_USERERROR   8
# define INI_UNKERROR    9
# define INI_DUPHEADER   10
# define INI_TEXTERROR   11


// Deeze be da function protos mon: -----------------------------------

IMPORT int iniAskForFileName( char *fnBuffer );

IMPORT struct ListViewMem *iniGetListViewMem( aiPTR ai );

IMPORT struct List *iniGetList( aiPTR ai );

IMPORT char  *iniTranslateErrorNumber( int errNumber );

# ifdef INCLUDE_EDITCONTENTS
IMPORT int    iniView_EditContents( aiPTR ai );
# endif

IMPORT aiPTR  iniCreateNewFile( char *fileName, int numElements, 
                                BOOL  caseFlag, char *delimiters
                              );

IMPORT aiPTR  iniOpenFile(     char *fileName, BOOL caseFlag, char *delimiters );
IMPORT int    iniWriteToFile(  aiPTR ai, char *fileName );
IMPORT int    iniWrite(        aiPTR ai );
IMPORT void   iniExit(         aiPTR ai );

// Group operations:

IMPORT ULONG  iniSearchForGroup( aiPTR ai, char *groupName ); // For V2.0

IMPORT int    iniLastGroup(        aiPTR ai ); // For V1.4
IMPORT int    iniFirstGroup(       aiPTR ai ); // For V1.4

IMPORT int    iniAddGroup(         aiPTR ai, char *groupName, int NumItems );
IMPORT int    iniSetGroupName(     aiPTR ai, int   lineIndex, char *groupName );
IMPORT ULONG  iniGetGroupEnd(      aiPTR ai, char *groupName );
IMPORT ULONG  iniGetGroupStart(    aiPTR ai, char *groupName );
IMPORT ULONG  iniNamedGroupLen(    aiPTR ai, char *groupName );
IMPORT ULONG  iniFindGroup(        aiPTR ai, char *groupName );
IMPORT int    iniRemoveGroup(      aiPTR ai, char *groupName );
IMPORT ULONG  iniGroupLength(      aiPTR ai );
IMPORT ULONG  iniNextGroup(        aiPTR ai );
IMPORT ULONG  iniPrevGroup(        aiPTR ai );
IMPORT char  *iniCurrentGroup(     aiPTR ai );

IMPORT BOOL   iniIsGroup(          aiPTR ai, int lineIndex );

// Item operations:

IMPORT BOOL   iniItemTypeIsString( char  *itemValue );
IMPORT BOOL   iniIsItem(           aiPTR ai, int lineIndex );

IMPORT char  *iniGetItemName(      aiPTR ai, int lineIndex );
IMPORT char  *iniGetItemValue(     aiPTR ai, int lineIndex );

IMPORT ULONG  iniFindItemInGroup(  aiPTR ai, char *groupName, char *itemName );
IMPORT ULONG  iniFindItem(         aiPTR ai, char *itemName );

IMPORT int    iniSetItemName(      aiPTR ai, int lineIndex, char *itemName );
IMPORT int    iniSetItemValue(     aiPTR ai, int lineIndex, char *itemValue );

IMPORT int    iniAddItem(          aiPTR ai, char *groupName, 
                                             char *itemName,
                                             char *itemValue
                        );

IMPORT int    iniRemoveItem( aiPTR ai, char  *groupName, char  *itemName );

#endif

/* ------------------ END of IniFuncs.h file! ---------------- */
