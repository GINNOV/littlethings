/*
**     $VER: IFFConverter.h V0.01 (13-06-95)
**
**     Author:  Gerben Venekamp
**     Updates: 13-06-96  Version 0.01
**
**
**  Include file for IFFConveter modules.
**  This include file contains external declarations.
**
*/

#ifndef IFFCONVERTER_H
#define IFFCONVERTER_H

#include <exec/types.h>
#include <libraries/gadtools.h>

#include "Gadgets_enum.h"

// Define Macros
#define Version   0.5
#define VersionQ "0.5"
#define VersionText "$VER: IFFconverter V0.5 (05-12-96)"
#define Lib_Version   39L
#define Lib_VersionQ "39"
#define PanelHeight 104
#define DefaultSaveBufferSize 32000
#define ExtensionSize 6

typedef struct {
   WORD ClipLeft;
   WORD ClipTop;
   WORD ClipWidth;
   WORD ClipHeight;
   WORD ClipPointX;
   WORD ClipPointY;
   ULONG ClipSize;
} IFFClip_s;

typedef struct SavePicStruct_s {
   struct Screen *ViewScreen;
   ULONG FileMode;
   ULONG RenderMode;
   IFFClip_s IFFClip;
} SavePicStruct_t;

// Define external variables

extern BOOL PictureValid;
extern BOOL DrawHairCross;

extern enum ByteBoundry ByteBoundry;

extern APTR VisualInfo;
extern APTR LoadFileName;
extern APTR SaveFileName;
extern APTR SystemFont;
extern APTR SaveBuffer;

extern ULONG  *ColourMap;
extern ULONG  *SColourMap;
extern ULONG  *PlanePtrs;
extern STRPTR GraphicsDrawer;
extern STRPTR BPLCON3OrMask;

extern ULONG ColourMapSize;
extern ULONG PlanePtrsSize;
extern ULONG LoadFileNameSize;
extern ULONG SaveFileNameSize;
extern ULONG SaveBufferSize;
extern ULONG GraphicsDrawerSize;

extern UWORD PicWidth;
extern UWORD PicHeight;
extern UWORD PicDepth;

extern UWORD TAB1;
extern UWORD TAB2;
extern UWORD NumberOfItems1;
extern UWORD NumberOfItems2;

extern ULONG PicSize;

extern IFFClip_s IFFClip;
   
extern WORD OldClipLeft;

extern WORD PubScreenWidth;
extern WORD PubScreenHeight;

extern char ESW_Title[];
extern char ESW_PicInfo[];

extern char EST_LockErr[];
extern char EST_OpenLibErr[];
extern char EST_OpenErr[];
extern char EST_AllocErr[];
extern char EST_AllocMemErr[];
extern char EST_NoVisIErr[];
extern char EST_NoIFFErr[];
extern char EST_NoIFFILBMErr[];
extern char EST_Fail[];
extern char EST_NotFound[];
extern char EST_GadCreate[];
extern char EST_AslNoFreeStore[];
extern char EST_AslNoMoreEntries[];
extern char EST_NotImplemented[];

extern char ESG_RetryCancel[];
extern char ESG_Okay[];

extern struct IntuitionBase *IntuitionBase;
extern struct DosLibrary    *DOSBase;
extern struct Library       *GadToolsBase;
extern struct Library       *AslBase;
extern struct Library       *IFFParseBase;
extern struct GfxBase       *GfxBase;
extern struct Library       *DiskfontBase;
extern struct Library       *IconBase;

extern struct FileRequester *Asl_FRLoad;
extern struct FileRequester *Asl_FRSave;

extern struct Screen *ViewScreen;
extern struct Screen *PanelScreen;
extern struct Window *ViewWindow;
extern struct Window *PanelWindow;
extern struct Window *InfoWindow;
extern struct Gadget *FirstGadget;

struct MyNewGadget {
   struct NewGadget mng;
   ULONG MyGadgetType;
   APTR MyGadgetTags;
};

extern struct MyNewGadget PanelGadgets[];

extern struct TextAttr System_8;

extern ULONG EnableGadget[];
extern ULONG DisableGadget[];
extern ULONG SetTextGadget[];
extern ULONG SetIntegerGadget[];
extern ULONG MakeChecked[];
extern ULONG UnmakeChecked[];
extern UBYTE *CYL_FileMode[];
extern UBYTE *CYL_RenderMode[];
extern UBYTE *MXL_ByteBoundry[];
extern ULONG GT_FileMode[];
extern ULONG GT_RenderMode[];
extern ULONG GT_ByteBoundry[];

enum RVSError {
   RVS_Okay,
   RVS_PictureFailure,
   RVS_NoWindow_PictureOkay,
   RVS_NoWindow_PictureFailure,
   RVS_BlackScreen,
   RVS_NoScreen,
   RVS_NoColourMap
};

enum IFF_ErrorNumber {
   IFFerror_NoIntuition,
   IFFerror_NoLibrary,
   IFFerror_NoMemory,
   IFFerror_NoMemoryDoReturn,
   IFFerror_NoLock,
   IFFerror_NoLockDoReturn,
   IFFerror_GadCreate,
   IFFerror_OpenErr,
   IFFerror_NoVisIErr,
   IFFerror_AllocErr,
   IFFerror_NotFound,
   IFFerror_Fail,
   IFFerror_NoIFFErr,
   IFFerror_AslNoFreeStore,
   IFFerror_AslNoMoreEntries,
   IFFerror_NotImplemented,
   IFFerror_NotOpen,
   IFFerror_FileExistsAsk
};


enum Fade {
   FADE_UP,
   FADE_DOWN
};

// Define external prototyes
extern void  AllocAsl_Requests(void);
extern void  AllocateMemory(void);
extern BOOL  AllocThisMem(APTR, ULONG, ULONG);
extern BOOL  AllocThisMemNoComplain(APTR, ULONG, ULONG);
extern void  CleanExit(int);
extern void  CleanLibExit(int);
extern void  CloseDiskFonts(void);
extern void  CloseFonts(void);
extern void  CloseLibraries(void);
extern void  CloseScreens(void);
extern void  CloseThisScreen(struct Screen **);
extern void  CloseThisWindow(struct Window **);
extern void  CloseWindows(void);
extern ULONG ConvertDecimal(STRPTR);
extern ULONG DisplayInfo(void);
extern LONG  ErrorHandler(enum enum_ErrorNumber, APTR, ...);
extern void  __asm exit(register __d0 LONG);
extern void  FadeColours(enum Fade, UWORD, struct Screen*);
extern void  FreeAsl_Requests(void);
extern void  FreeMemory(void);
extern void  FreeThisMem(APTR, ULONG);
extern void  GetDiskFonts(void);
extern void  GetGadgetStatus(ULONG, ULONG, ...);
extern BOOL  GetNewColourMap(UBYTE *, UWORD);
extern void  HandleIntuiMessages(void);
extern void  InitGadgets(void);
extern void  LoadPicture(enum FileModeType);
extern void  MakeDecimal(LONG, char *, UWORD);
extern void  OpenLibraries(void);
extern void  OpenScreens(void);
extern void  OpenWindows(void);
extern void  PositionScreen(struct Screen*, WORD, WORD);
extern enum  RVSError RebuildViewScreen(struct BitMapHeader *, ULONG, APTR, APTR);
extern void  SavePicture(SavePicStruct_t *);
//extern void  SavePicture(struct Screen *, enum FileModeType, enum RenderModeType, IFFClip_s *);
extern BOOL  StringCompare(STRPTR, STRPTR);
extern UWORD StringLength(char *);
extern void  UpdateDimensions(ULONG, ...);
extern void  UpdateGadgets(ULONG, ...);


#endif    /*  IFFCONVERTER_H  */
