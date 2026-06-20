/*
**     $VER: WindowScreenMaintenace.c V0.03 (21-06-95)
**
**     Author:  Gerben Venekamp
**     Updates: 14-06-95  Version 0.01     Initial module
**              21-06-95  Version 0.02     CloseThisScreen and CloseThisWindow
**                                         have been added. Also CloseWindows
**                                         uses CloseThisWindow now.
**              21-06-95  Version 0.03     FadeColours has been moved to a
**                                         new module called PaletteMaintenance.c
**
**  WindowScreenMaintenace.c contains the function to maintain
**  screens and windows of IFFConverter.
**
*/

#include <datatypes/pictureclass.h>
#include <exec/memory.h>
#include <graphics/modeid.h>
#include <graphics/videocontrol.h>
#include <intuition/intuition.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/gadtools.h>
#include <proto/graphics.h>
#include <proto/intuition.h>

#include "IFFConverter.h"


// Define variables
APTR VisualInfo = NULL;

struct Screen *ViewScreen  = NULL;
struct Screen *PanelScreen = NULL;
struct Window *ViewWindow  = NULL;
struct Window *PanelWindow = NULL;
struct Window *InfoWindow  = NULL;

char ViewScreenTitle[]  = "The View";
char PanelScreenTitle[] = "The Window";

WORD PubScreenWidth;
WORD PubScreenHeight;

// Tags for VideoControl
ULONG VCTags[] = {
   VTAG_BORDERSPRITE_SET, FALSE,
   TAG_DONE
};


// Define prototypes
BOOL  BuildPicture(struct Screen *, struct BitMapHeader *, APTR);
void  CloseScreens(void);
void  CloseThisScreen(struct Screen **);
void  CloseThisWindow(struct Window **);
void  CloseWindows(void);
void  __asm DecompressPic(register __a0 APTR,
                          register __a1 APTR,
                          register __a2 APTR,
                          register __a3 APTR);
ULONG DisplayInfo(void);
void  OpenScreens(void);
void  OpenWindows(void);
void  PositionScreen(struct Screen *, WORD, WORD);
enum  RVSError RebuildViewScreen(struct BitMapHeader *, ULONG, APTR, APTR);



/*
**  OpenScreens()
**
**     Opens two screen for you. One screen, called `The Panel', is used
**     to display a panel from which you can preform all operation in
**     IFFConverter. The second screen, called `The Display', is used to
**     display your picture and your clipping operations. Also
**     GetVisualInfo is called for `The Panel' Screen, so be sure to
**     free it!
**
**  pre:  None.
**  post: None.
**
*/
void OpenScreens()
{
   struct Screen *PubScreen = NULL;

   if(!(PubScreen=LockPubScreen(NULL)))  // Lock the Public Screen (Workbench).
      ErrorHandler( IFFerror_NoLock, "PubScreen" );

   PubScreenWidth  = PubScreen->Width;
   PubScreenHeight = PubScreen->Height;

   *((UWORD *) ColourMap) = 2;

   if(!(ViewScreen=OpenScreenTags(NULL, SA_Top, 256,
                                        SA_Left, 0,
                                        SA_Width, 320,
                                        SA_Height, 256,
                                        SA_Depth, 1,
                                        SA_Title, &ViewScreenTitle,
                                        SA_FullPalette, TRUE,
                                        SA_Quiet, TRUE,
                                        SA_AutoScroll, TRUE,
                                        SA_ShowTitle, FALSE,
                                        SA_Type, CUSTOMSCREEN,
                                        SA_Colors32, ColourMap,
                                        SA_Interleaved, TRUE,
                                        SA_VideoControl, &VCTags,
                                        TAG_DONE)))
      ErrorHandler( IFFerror_OpenErr, "View Screen" );

   PositionScreen(ViewScreen, 0, 12);

   if(!(PanelScreen=OpenScreenTags(NULL, SA_Left, 0,
                                         SA_Top, PubScreenHeight,
                                         SA_Width, 640,
                                         SA_Depth,2,
                                         SA_Font, &System_8,
                                         SA_Title, &PanelScreenTitle,
//                                         SA_DetailPen,0,
//                                         SA_BlockPen,1,
//                                         SA_ShowTitle, FALSE,
                                         SA_AutoScroll, FALSE,
                                         SA_Quiet, FALSE,
                                         SA_LikeWorkbench, TRUE,
                                         SA_Parent, ViewScreen,
                                         TAG_DONE)))
      ErrorHandler( IFFerror_OpenErr, " Panel Screen" );

   PositionScreen(PanelScreen, PubScreenHeight-PanelHeight, 12);

   if(!( VisualInfo = GetVisualInfo(PanelScreen, TAG_DONE) ))
      ErrorHandler( IFFerror_NoVisIErr, NULL);

   UnlockPubScreen(NULL, PubScreen);  // Free the Public Screen.
}


/*
**  CloseScreens()
**
**     Closes all open screens and frees the VisualInfo for the
**     'PanelScreen'.
**     NOTE: 'CloseScreen' could use 'CloseThisScreen'. The reason why
**     this is not the case, is as follows. Both screens, 'ViewScreen'
**     and 'PanelScreen' needs to be scrolled down. To do so, a test
**     to see whether the screens are available needs to be done.
**     'CloseThisScreen' prefroms the same test. So, it's a bit silly
**     to do the same test twice! 'CloseThisScreen' sets the pointer to
**     a screen to NULL. Since 'CloseScreen' should only be called when
**     quiting, there's no benefit to set a pointer to NULL. This pointer
**     will never be used again!
**
**  pre:  None.
**  post: None.
**
*/
void CloseScreens()
{
   if(VisualInfo)  FreeVisualInfo(VisualInfo);

   if(PanelScreen)
   {
      PositionScreen(PanelScreen, PubScreenHeight, 12);
      CloseScreen(PanelScreen);
   }

   if(ViewScreen)
   {
      PositionScreen(ViewScreen, PubScreenHeight, 12);
      CloseScreen(ViewScreen);
   }
}


/*
**  CloseThisScreen(ScreenToClose)
**
**     Closes 'ScreenToClose' and marks 'ScreenToClose' as invalid (NULL).
**
**  pre:  ScreenToClose - Screen to be closed.
**  post: ScreenToClose - NULL;
**
*/
void CloseThisScreen(struct Screen **ScreenToClose)
{
   if(*ScreenToClose)   //  Points 'ScreenToClose' to a screen structure?
   {
      CloseScreen(*ScreenToClose);   // Yes, close screen.
      *ScreenToClose = NULL;         // Mark pointer as invalid.
   }
}


/*
**  OpenWindows()
**
**     Opens two windows for you. Both windows are backdrop windows.
**     One window for each screen. 'ViewScreen' and 'PanelScreen' that is.
**
**  pre:  None.
**  post: None.
**
*/
void OpenWindows()
{
   if(!(ViewWindow=OpenWindowTags(NULL, WA_Top, 0,
                                        WA_Left, 0,
                                        WA_InnerWidth, 320,
                                        WA_InnerHeight, 256,
                                        WA_PubScreen, ViewScreen,
                                        WA_Borderless, TRUE,
                                        WA_Backdrop, TRUE,
                                        WA_Flags, WFLG_RMBTRAP | WFLG_REPORTMOUSE,
                                        WA_IDCMP, IDCMP_MOUSEBUTTONS | IDCMP_MOUSEMOVE,
                                        TAG_DONE)))
      ErrorHandler( IFFerror_OpenErr, "View Window" );

   if(!(PanelWindow=OpenWindowTags(NULL, WA_Top, 0,
                                         WA_Left, 0,
                                         WA_InnerHeight, PanelHeight,
                                         WA_InnerWidth, 640,
                                         WA_PubScreen, PanelScreen,
                                         WA_Title, "PanelWindow",
                                         WA_Backdrop, TRUE,
                                         WA_Borderless, TRUE,
                                         WA_Activate, TRUE,
                                         WA_Flags, WFLG_RMBTRAP | WFLG_REPORTMOUSE | WFLG_NOCAREREFRESH,
                                         WA_IDCMP, BUTTONIDCMP | MXIDCMP | INTEGERIDCMP | IDCMP_MOUSEBUTTONS | IDCMP_MOUSEMOVE,
                                         WA_ScreenTitle, &PanelScreenTitle,
                                         WA_Gadgets, FirstGadget,
                                         TAG_DONE)))
      ErrorHandler( IFFerror_OpenErr, "Panel Window" );

   GT_RefreshWindow(PanelWindow, NULL);
}


/*
**  CloseWindows()
**
**     Closes all open windows.
**
**  pre:  None.
**  post: None.
**
*/
void CloseWindows()
{
   CloseThisWindow(&ViewWindow);
   CloseThisWindow(&PanelWindow);
   CloseThisWindow(&InfoWindow);
}


/*
**  CloseThisWindow(WindowToClose)
**
**     Closes 'WindowToClose' and marks 'WindowToClose' as invalid (NULL).
**
**  pre:  WindowToClose - Window to be closed.
**  post: WindowToClose - NULL;
**
*/
void CloseThisWindow(struct Window **WindowToClose)
{
   if(*WindowToClose)
   {
      CloseWindow(*WindowToClose);
      *WindowToClose = NULL;
   }
}


/*
**  Result = RebuildViewScreen(BitMapHdr, DisplayMode, CMapData, BodyData)
**
**     Rebuilds your 'ViewScreen' from scratch. The way this is done,
**     is as follows: As the 'PanelScreen' should be blocking all other
**     screens, the 'ViewScreen' will be closed. Then a new 'ViewScreen'
**     will be opend according to 'BitMapHdr', 'DisplayMode' and
**     'CMapData'. The 'BodyData' will be drawn onto the 'ViewScreen'
**     and the 'PanelScreen' will be moved back into its pre-defined
**     position.
**
**  pre:  BitMapHdr - BitMapHeader structure.
**        DisplayMode - ModeID
**        CMapData - ILBM CMAP Chunk
**        BodyData - ILBM BODY Chunk
**  post: Result - RVS_Okay           if function succeeds.
**                 RVS_PictureFailure if no picture could be created.
**                 RVS_NoWindow       if no window could be opened.
**                 RVS_BlackScreen    if no screen could be opened, but
**                                    a black screen could be opened.
**                 RVS_NoScreen       if no screen could be opened at all.
**                 RVS_NoColourMap    if no colour map could be created.
**
*/
enum RVSError RebuildViewScreen(BitMapHdr, DisplayMode, CMapData, BodyData)
struct BitMapHeader *BitMapHdr;
ULONG DisplayMode;
APTR CMapData, BodyData;

{
   if( GetNewColourMap(CMapData, BitMapHdr->bmh_Depth) )
   {
      ULONG OpenScreenFailure;
      ULONG DisplayModeID;
      
      CloseThisWindow(&ViewWindow);
      CloseThisScreen(&ViewScreen);
      
      DisplayModeID = BestModeID(BIDTAG_SourceID, DisplayMode,
                                 BIDTAG_DesiredWidth, BitMapHdr->bmh_Width,
                                 BIDTAG_DesiredHeight, BitMapHdr->bmh_Height,
                                 BIDTAG_Depth, BitMapHdr->bmh_Depth,
                                 TAG_DONE);
      
      if( !(DisplayModeID == INVALID_ID) )
         if( ViewScreen = OpenScreenTags(NULL, SA_Width, BitMapHdr->bmh_Width,
                                               SA_Height, BitMapHdr->bmh_Height,
                                               SA_Left, (BitMapHdr->bmh_PageWidth - BitMapHdr->bmh_Width) / 2,
                                               SA_Depth, BitMapHdr->bmh_Depth,
                                               SA_FrontChild, PanelScreen,
                                               SA_DisplayID, DisplayModeID,
                                               SA_Title, &ViewScreenTitle,
                                               SA_ShowTitle, FALSE,
                                               SA_Type, CUSTOMSCREEN,
                                               SA_AutoScroll, TRUE,
                                               SA_FullPalette, TRUE,
                                               SA_Colors32, ColourMap,
                                               SA_Interleaved, TRUE,
                                               SA_VideoControl, &VCTags,
                                               SA_Quiet, TRUE,
                                               SA_LikeWorkbench, TRUE,
                                               SA_ErrorCode, &OpenScreenFailure,
                                               TAG_DONE) )
                                               
            if( ViewWindow = OpenWindowTags(NULL, WA_Top, 0,
                                                  WA_Left, 0,
                                                  WA_InnerWidth, BitMapHdr->bmh_Width,
                                                  WA_InnerHeight, BitMapHdr->bmh_Height,
                                                  WA_PubScreen, ViewScreen,
                                                  WA_Backdrop, TRUE,
                                                  WA_Borderless, TRUE,
                                                  WA_Activate, TRUE,
                                                  WA_Flags, WFLG_RMBTRAP | WFLG_REPORTMOUSE,
                                                  WA_IDCMP, IDCMP_MOUSEBUTTONS |IDCMP_MOUSEMOVE,
                                                  TAG_DONE) )
                                                  
               if( BuildPicture(ViewScreen, BitMapHdr, BodyData) )
                  // Picture has succesfully been drawn
                  return(RVS_Okay);
               else
                  // Some error has occoured during image drawing
                  return(RVS_PictureFailure);
            else
               // A proper screen was opened, but a backdrop window
               // could not be opened. No serious problem though.
               // All we need to to is not to display the picture.
               if( BuildPicture(ViewScreen, BitMapHdr, BodyData) )
                  // Picture has succesfully been drawn.
                  return(RVS_NoWindow_PictureOkay);
               else
                  // Some Error has occoured during image drawing
                  return(RVS_NoWindow_PictureFailure);
         else
            if( !(ViewScreen = OpenScreenTags(NULL, SA_Top, 256,
                                                    SA_Left, 0,
                                                    SA_Width, 320,
                                                    SA_Height, 256,
                                                    SA_Depth, 1,
                                                    SA_Title, &ViewScreenTitle,
                                                    SA_FullPalette, TRUE,
                                                    SA_Quiet, TRUE,
                                                    SA_AutoScroll, TRUE,
                                                    SA_ShowTitle, FALSE,
                                                    SA_Type, CUSTOMSCREEN,
                                                    SA_Colors32, ColourMap,
                                                    SA_Interleaved, TRUE,
                                                    SA_VideoControl, &VCTags,
                                                    TAG_DONE)) )
               
               // Normal screen creation has failed, but a black screen
               // could be opened.
               return(RVS_BlackScreen);
            else
               // No screen could be opened. This means that the Workbench
               // and/or other screens/windows become visable to the user
               // when the 'PanelScreen' is moved back to its pre-defined
               // position.
               return(RVS_NoScreen);
      else
         // 'ModeID' could not be calculated. This means that it's
         // impossible to open a screen which matches 'DisplayMode'.
         return(RVS_NoScreen);
   }
   else
   // No memory for a colour map could be allocated. Which means, even
   // if you were able to open a screen and window, you have no palette.
   // therefor it makes little sence to display a picture on such a screen.
      return(RVS_NoColourMap);
   
}


/*
**  succes = BuildPicture(PicScreen, BitMapHdr, BodyData)
**
**     Draws a picture to 'Screen'
**
**  pre:  PicScreen - A pointer to a Screen structure on which the
**                    picture has to appear.
**        BitMapHdr - A pointer to a BitMapHeader structure.
**        BodyData - Pointer to a ILBM BODY chunck
**  post: succes - TRUE  if image has succesfully been drawn,
**                 FALSE if image creation went wrong.
**
*/
BOOL BuildPicture(PicScreen, BitMapHdr, BodyData)
   struct Screen *PicScreen;
   struct BitMapHeader *BitMapHdr;
   APTR BodyData;
{
   FreeThisMem(&PlanePtrs, PlanePtrsSize);
   
   PlanePtrsSize = (PicScreen->ViewPort.RasInfo->BitMap->Depth)<<2;
   
   // Allocate some memory which 'DecompressPic' can use to store
   // bitplane addresses.
   if( AllocThisMem(&PlanePtrs, PlanePtrsSize, MEMF_CLEAR) )
   {
      DecompressPic(BodyData, BitMapHdr, ViewScreen, PlanePtrs);
      return TRUE;
   }
   else
      return(FALSE);
}


/*
**  PositionScreen(ScreenToMove, FinalPos, Steps):
**
**     Positions a screen for you.
**
**  pre:  ScreenToMove - Pointer to a Screen structure.
**        FinalPos - Final position of the screen.
**        Steps - Number of steps in which the FinalPos is reached.
**  post: None.
**
*/
void PositionScreen(ScreenToMove, FinalPos, Steps)
   struct Screen *ScreenToMove;
   WORD FinalPos, Steps;

{
   WORD NewPos, DeltaMove, i;

   DeltaMove = FinalPos - (ScreenToMove->TopEdge);

   for(i=Steps-1; i>=0; i--)
   {
      NewPos = (WORD) FinalPos - (DeltaMove * i / Steps);
      ScreenPosition(ScreenToMove, SPOS_ABSOLUTE, 0, NewPos, 0, 0);
      Delay(0);
   }
}


/*
**  DisplayInfo()
**
**     Displays a window containing information on the current picture.
**     When display window is activated, it will automaticly remove itself.
**
**  pre:  None.
**  post: None.
**
*/
ULONG DisplayInfo()
{
   UBYTE APen;
   static struct NameInfo buffer;
   ULONG DisplayModeID;
   
   static struct IntuiText window_IText[] = {   
      {2, 0, JAM2, 108,  0, NULL, "IFF ILBM Converter",        &window_IText[ 1]},
      {1, 0, JAM2,  80, 12, NULL, "© 1995 by Gerben Venekamp", &window_IText[ 2]},
      {1, 0, JAM2,   0, 36, NULL, "Picture Name:",             &window_IText[ 3]},
      {1, 0, JAM2, 112, 36, NULL, "No Picture Loaded",         &window_IText[ 4]},
      {1, 0, JAM2,   0, 48, NULL, "Picture Dimensions:",       &window_IText[ 5]},
      {1, 0, JAM2, 160, 48, NULL, "---- × ---- × -",           &window_IText[ 6]},
      {1, 0, JAM2,   0, 60, NULL, "Screen Mode:",              &window_IText[ 7]},
      {1, 0, JAM2, 104, 60, NULL, "Default",                   &window_IText[ 8]},
      {1, 0, JAM2,   0, 72, NULL, "Colours:",                  &window_IText[ 9]},
      {1, 0, JAM2,  72, 72, NULL, "---",                       &window_IText[10]},
      {1, 0, JAM2,   0, 84, NULL, "Chip:",                     &window_IText[11]},
      {1, 0, JAM2,  48, 84, NULL, "1234567",                   NULL}
   };
   
//   static char *No_ViewInfo = "Not determened";
   static char *GetDisFail = "GetDisplayInfo failed";
   static char *GetVPFail = "GetVPModeID failed";
   
   MakeDecimal(AvailMem(MEMF_CHIP), window_IText[11].IText, 7);
   
   if( !InfoWindow )  // See if Info Window is already opened.
   {
      if( !(InfoWindow = OpenWindowTags(NULL, WA_Left, 140,
                                              WA_Top, 18,
                                              WA_Width, 360,
                                              WA_Height, 108,
                                              WA_IDCMP, IDCMP_ACTIVEWINDOW,
                                              WA_PubScreen, PanelScreen,
                                              TAG_DONE)) )
      {
         ErrorHandler( IFFerror_NotOpen, "Info Window" );
         return(0);
      }
      
      if( (DisplayModeID = GetVPModeID( &ViewScreen->ViewPort )) != INVALID_ID )
         if( GetDisplayInfoData(NULL, (UBYTE *)&buffer, sizeof(buffer), DTAG_NAME, DisplayModeID & ~(0x800 | 0x80)) )
            window_IText[7].IText = buffer.Name;
         else
            window_IText[7].IText = GetDisFail;
      else
         window_IText[7].IText = GetVPFail;

      APen = GetAPen(InfoWindow->RPort);
      
      SetAPen(InfoWindow->RPort, 2);
      Move(InfoWindow->RPort,  10, 34);
      Draw(InfoWindow->RPort, 350, 34);
      SetAPen(InfoWindow->RPort, 1);
      Move(InfoWindow->RPort,  11, 35);
      Draw(InfoWindow->RPort, 351, 35);
   
      SetAPen(InfoWindow->RPort, APen);

   }
      
   PrintIText(InfoWindow->RPort, &window_IText[0], 12, 8);

   return( (ULONG)(1L << InfoWindow->UserPort->mp_SigBit) );
}
