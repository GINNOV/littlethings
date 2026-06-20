/****h *CommonFuncs/CommonFuncs.h **********************************
**
** NAME
**    CommonFuncs.h - the #include file for CommonFuncs.o usage.
********************************************************************
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

struct ColorCoords {

   LONG Red_Hue;
   LONG Green_Saturation;
   LONG Blue_Luminance;    
};

struct CompFont {

   UWORD FontX, FontY; // Font X & Y sizes.
   UWORD OffX,  OffY;  // Font X & Y offsets.
};


# define  INTUITIONLIB   0x00000001  /* OpenLibs() & CloseLibs() flags */
# define  GRAPHICSLIB    0x00000002
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

// Function protos:

PUBLIC int  OpenLibs(  void );
PUBLIC void CloseLibs( void );

PUBLIC int FontXDim( struct TextAttr *font );

PUBLIC ULONG getScreenModeID( struct TagItem *taglist, 
                              struct Screen  *scr,
                              char           *title 
                            );

PUBLIC int File_DirReq( char           *filename, 
                        char           *dirname, 
                        struct TagItem *taglist
                      );

PUBLIC int FileReq( char *filename, struct TagItem *taglist );

/* SetNotifyWindow() has to be called BEFORE you use Handle_Problem(),
** or Handle_Problem() will not work!
*/

PUBLIC void SetNotifyWindow( struct Window *wptr );
PUBLIC void SetReqButtons( char *newbuttons );
PUBLIC int  Handle_Problem( char *info, char *title, int *errnum );
PUBLIC int  GetUserResponse( char *info, char *title, int *errnum );
PUBLIC BOOL SanityCheck( char *question );

PUBLIC UWORD ComputeX( UWORD fontxsize, UWORD value );
PUBLIC UWORD ComputeY( UWORD fontysize, UWORD value );

PUBLIC void ComputeFont( struct Screen   *Scr, 
                         struct TextAttr *Font,
                         struct CompFont *cf,
                         UWORD            width, 
                         UWORD            height
                       );

PUBLIC char **FindTools( struct DiskObject *diskobj, 
                         char              *name, 
                         BPTR               lock 
                       );

PUBLIC char *GetToolStr( char **toolptr, char *name, char *deflt );
PUBLIC int   GetToolInt( char **toolptr, char *name, int defaultvalue );

PUBLIC BOOL GetToolBoolean( char **toolptr, char *name, int defaultBool );

PUBLIC void *FindIcon( void *(ToolProc)(char **), 
                       struct DiskObject *dobj,
                       char *pgmname
                     );

PUBLIC struct ColorCoords *RGB2HSV( struct ColorCoords *input );
PUBLIC struct ColorCoords *HSV2RGB( struct ColorCoords *input );

PUBLIC void SetTagItem( struct TagItem *taglist, ULONG tag, ULONG value );

PUBLIC char *FGetS( char *buffer, int length, FILE *stream );

PUBLIC unsigned int MakeHexASCIIStr( char *out, char *input, int inlen );

PUBLIC char *Byt2Str( char *out, UBYTE input );

PUBLIC void HideListFromView( struct Gadget *lv, struct Window *w );

PUBLIC void ModifyListView( struct Gadget *lv, 
                            struct Window *w,
                            struct List   *list,
                            struct Gadget *strgadget
                          );
#endif

/* ---------------- END of CommonFuncs.h file! ------------------ */
