/****h* CommonFuncs/CommonFuncs.h **********************************
*
* NAME
*    CommonFuncs.h - the #include file for CommonFuncs.o usage.
* 
* DESCRIPTION
*    See CommonFuncs.c file for documentation.
*
* WARNINGS
*    Be sure that this header is one of the last files #included 
*    in your source code!.
********************************************************************
*
*/

#ifndef  COMMONFUNCS_H
# define COMMONFUNCS_H 1

# ifndef STDIO_H
#  include <stdio.h> 
# endif

# ifndef WORKBENCH_WORKBENCH_H
#  include <workbench/workbench.h>
# endif 

# ifndef INTUITION_INTUITION_H
#  include <intuition/intuition.h>
# endif 

# ifndef LIBRARIES_DISKFONT_H
#  include <libraries/diskfont.h>
# endif 

# ifndef LIBRARIES_ASL_H
#  include <libraries/asl.h>
# endif 

/*
The User of this object file must declare the following library vectors:

struct IntuitionBase *IntuitionBase;
struct GfxBase       *GfxBase;
struct Library       *GadToolsBase;

*/

# ifdef __amigaos4__
#  include <proto/dos.h>
#  include <proto/exec.h>
#  include <proto/intuition.h>
#  include <proto/gadtools.h>
#  include <proto/graphics.h>
#  include <proto/asl.h>
#  include <proto/locale.h>
#  include <proto/icon.h>
#  include <proto/diskfont.h>
#  include <proto/utility.h>
# endif

# ifdef DEBUG
#  define DBG(p) p
# else
#  define DBG(p)
# endif

# ifndef  BUFF_SIZE
#  define BUFF_SIZE 512 // Used for fileName string buffers 
# endif

struct ColorCoords {

   LONG Red_Hue;
   LONG Green_Saturation;
   LONG Blue_Luminance;    
};

struct CompFont {

   UWORD FontX, FontY; // Font X & Y sizes.
   UWORD OffX,  OffY;  // Font X & Y offsets.
};

struct ListViewMem {
    
   UBYTE       *lvm_NodeStrs;
   struct Node *lvm_Nodes;
   int          lvm_NumItems;
   int          lvm_NodeLength;
};

IMPORT int LVMError;             // Communication flag - Guarded_AllocLV().

# define  LVM_ERROR_NONE       0 // Values for LVMError
# define  LVM_ERROR_WRONG_SIZE 1
# define  LVM_ERROR_NOMEM      2

# ifndef  StrBfPtr
#  define StrBfPtr( g ) (((struct StringInfo *)g->SpecialInfo)->Buffer)
#  define IntBfPtr( g ) (((struct StringInfo *)g->SpecialInfo)->LongInt)
# endif

# define  INTUITIONLIB   0x00000001  // OpenLibs() & CloseLibs() flags
# define  GRAPHICSLIB    0x00000002  // NOT currently used.
# define  EXECLIB        0x00000004
# define  DOSLIB         0x00000008
# define  LAYERSLIB      0x00000010
# define  IFFPARSELIB    0x00000020
# define  UTILITYLIB     0x00000040
# define  COMMODITIESLIB 0x00000080
# define  ASLLIB         0x00000100
# define  DISKFONTLIB    0x00000200
# define  AMIGAGUIDELIB  0x00000400
# define  GADTOOLSLIB    0x00000800

// RawKey values:

# define  F1             80
# define  F2             81
# define  F3             82
# define  F4             83
# define  F5             84
# define  F6             85
# define  F7             86 
# define  F8             87
# define  F9             88
# define  F10            89

# define  HELP           95

# define  LEFT_ARROW     79
# define  RIGHT_ARROW    78
# define  UP_ARROW       76
# define  DOWN_ARROW     77

// -------- Function protos: -------------------------------------------

PUBLIC BOOL FileExists( UBYTE *fileName ); // For V3.6

# ifndef __amigaos4__
// Duplicate StringFunctions.c for SAS-C : -----------------------------------------------
IMPORT void StringNCopy( UBYTE *dest, UBYTE *src, int size );

IMPORT int stoi( char **inputString );
IMPORT int StringCopy( UBYTE *dest, UBYTE *src );
IMPORT int StringLength( UBYTE *str );
IMPORT int StringComp( UBYTE *str1, UBYTE *str2 );
IMPORT int StringNComp( UBYTE *str1, UBYTE *str2, unsigned int size );
IMPORT int StringNIComp( char *str1, char *str2, int length );
IMPORT int StringIComp( UBYTE *str1, UBYTE *str2 );
IMPORT int StringIndex( char *string, char *substring );
IMPORT int FindChar( char *string, char letter );
IMPORT int RemoveSubString( char *delstr, int first, int num_char );

IMPORT UBYTE *SubString( UBYTE *str, UBYTE *end );
IMPORT UBYTE *StringCat( char *string1, char *string2 );
IMPORT UBYTE *StringNCat( char *string1, char *string2, int maxSize );
IMPORT UBYTE *UpperCase( UBYTE *inputString );
IMPORT UBYTE *LowerCase( UBYTE *inputString );
IMPORT UBYTE *ReverseString( char *string );
IMPORT UBYTE *ReplaceChar( UBYTE *string, UBYTE old_char, UBYTE new_char );

# endif // __amigaos4__

// ---------------------------------------------------------------------------------------

IMPORT UBYTE *GetUserString( struct Window *parentW, UBYTE *requestMsg, UBYTE *wTitle );

IMPORT UBYTE *TrimSpaces( UBYTE *string );

IMPORT FILE *OpenFile( char *fileName, char *fileMode );

IMPORT BOOL IsGadgetSelected( struct Gadget *g );

IMPORT BOOL IsMenuChecked( struct MenuItem *m );

IMPORT void strClear( char *str ); // Clear out (nil) a string.

IMPORT void drawArc( struct Window *w, int Xs, int Ys, 
                     float arcAngle,   int Xc, int Yc
                   );

IMPORT struct TextAttr *getUserFont( struct TagItem *taglist, 
                                     struct Screen  *scr,
                                     char           *title 
                                   );

IMPORT void *CFFindMenuPtr( struct Menu *menustrip, char *searchForMI );

# ifndef    itoa // do NOT override a library function:
IMPORT void itoa( int convertMe, char *stringbuffer );
# endif

# ifndef __amigaos4__
IMPORT int  OpenLibs(  void );
IMPORT void CloseLibs( void );
# endif

IMPORT void SetupList( struct List *list, struct ListViewMem *lvm );

IMPORT void Guarded_FreeLV( struct ListViewMem *lvm );

IMPORT struct ListViewMem *Guarded_AllocLV( int numitems, int itemsize );

IMPORT void ReportAllocLVError( void );

// ---------------------------------------------------------------------

IMPORT void HideListFromView( struct Gadget *lv, struct Window *w );

IMPORT void ModifyListView( struct Gadget *lv, 
                            struct Window *w,
                            struct List   *list,
                            struct Gadget *strgadget
                          );

// ---------------------------------------------------------------------

IMPORT struct Window *GetActiveWindow( void ); // Added on 20-Mar-2002

IMPORT struct Screen *GetActiveScreen( void );

IMPORT ULONG getScreenModeID( struct TagItem *taglist, 
                              struct Screen  *scr,
                              char           *title 
                            );

IMPORT int File_DirReq( char           *filename, 
                        char           *dirname, 
                        struct TagItem *taglist
                      );

IMPORT int FileReq( char *filename, struct TagItem *taglist );

IMPORT char *GetPathName( char *path, char *filename, int size );

// ---------------------------------------------------------------------

/* SetNotifyWindow() has to be called BEFORE you use User Requesters,
** like Handle_Problem(), or they will not work!
*/

IMPORT void SetNotifyWindow( struct Window *wptr       );
IMPORT void SetReqButtons(   char          *newbuttons );

IMPORT void UserInfo(        char *message, char *windowtitle );
IMPORT int  Handle_Problem(  char *info, char *title, int *errnum );
IMPORT int  GetUserResponse( char *info, char *title, int *errnum );
IMPORT BOOL SanityCheck(     char *question );

IMPORT void DisplayTitle(    struct Window *wptr, char *txt );

// ---------------------------------------------------------------------

IMPORT int   FontXDim( struct TextAttr *font );
IMPORT UWORD ComputeX( UWORD fontxsize, UWORD value );
IMPORT UWORD ComputeY( UWORD fontysize, UWORD value );

IMPORT void ComputeFont( struct Screen   *Scr, 
                         struct TextAttr *Font,
                         struct CompFont *cf,
                         UWORD            width, 
                         UWORD            height
                       );

// ---------------------------------------------------------------------

IMPORT STRPTR *FindTools( struct DiskObject *diskobj, 
                          char              *name, 
                          BPTR               lock 
                        );

IMPORT char *GetToolStr( STRPTR *toolptr, char *name, char *deflt );
IMPORT int   GetToolInt( STRPTR *toolptr, char *name, int defaultvalue );

IMPORT BOOL GetToolBoolean( STRPTR *toolptr, char *name, int defaultBool );

IMPORT void *FindIcon( void              *(ToolProc)( STRPTR * ), 
                       struct DiskObject *dobj,
                       char              *pgmname
                     );

// ---------------------------------------------------------------------

IMPORT struct ColorCoords *RGB2HSV( struct ColorCoords *input );
IMPORT struct ColorCoords *HSV2RGB( struct ColorCoords *input );

// ---------------------------------------------------------------------

IMPORT void SetTagItem( struct TagItem *taglist, ULONG tag, ULONG value );
IMPORT void SetTagPair( struct TagItem *taglist, ULONG tag, ULONG value );

// ---------------------------------------------------------------------

IMPORT char *FGetS( char *buffer, int length, FILE *stream );

IMPORT unsigned int MakeHexASCIIStr( char *out, char *input, int inlen );

IMPORT char *Byt2Str( char *out, UBYTE input );

#endif

/* ---------------- END of CommonFuncs.h file! ------------------ */
