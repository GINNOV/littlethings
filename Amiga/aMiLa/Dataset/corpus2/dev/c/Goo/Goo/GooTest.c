// GooTest

#include <graphics/gfx.h>
#include <intuition/intuition.h>
#include <pragma/intuition_lib.h>
#include <pragma/graphics_lib.h>
#include <pragma/exec_lib.h>
#include <pragma/dos_lib.h>
#include <stdio.h>

#define ID_TROOPTAB   1
#define ID_CITYTAB    2
#define ID_OPTIONSTAB 3
#define ID_QUIT       4
#define ID_STRING     5
#define ID_STRING2    6
#define TAB_ON  0
#define TAB_OFF 1

#define TROOPTAB_ON   "FUBAR:Graphics/WorldMapUI/TroopTabOn.pic"
#define TROOPTAB_OFF  "FUBAR:Graphics/WorldMapUI/TroopTabOff.pic"
#define CITYTAB_ON    "FUBAR:Graphics/WorldMapUI/CityTabOn.pic"
#define CITYTAB_OFF   "FUBAR:Graphics/WorldMapUI/CityTabOff.pic"
#define OPTSTAB_ON    "FUBAR:Graphics/WorldMapUI/OptionsTabOn.pic"
#define OPTSTAB_OFF   "FUBAR:Graphics/WorldMapUI/OptionsTabOff.pic"
#define BUT1          "FUBAR:!Goo/bm1.pic"
#define BUT2          "FUBAR:!Goo/bm2.pic"

#include "Goo.h"
#include "LARD.h"

struct Library *UtilityBase = NULL, *IFFBase = NULL;
struct BitMap *TroopTabs[2] = {NULL, NULL}, *CityTabs[2] = {NULL, NULL}, 
              *OptsTabs[2] = {NULL, NULL}, *bm1 = NULL, *bm2 = NULL;
extern struct ColourTableStruct CTS;
struct Screen *MyScreen = NULL;
struct GOOWindow *GOOWindow = NULL;
int TroopTab = TAB_ON, CityTab = TAB_OFF, OptsTab = TAB_OFF;
int LastSecs, LastMics, Secs, Mics;

void RefreshTabs(void);

void main(void)
{
  BOOL ok;
  int a = 1;
  
  // Here goes
  printf("Libs open...\n");
  if((UtilityBase = OpenLibrary("utility.library", 36)) && (IFFBase = OpenLibrary("iff.library", 0)))
  {
    // Right, open a screen
    printf("Open screen...\n");
    if(MyScreen = OpenScreenTags(NULL, SA_LikeWorkbench, TRUE, SA_Depth, 6, TAG_DONE))
    {
      if(!(LARD_GetCMAP(CITYTAB_ON)))
      {
        LoadRGB32(&MyScreen->ViewPort, (ULONG *)&CTS);
      }
      // Okay, open a GOO window...
      printf("Open GOO Window...\n");
      if(GOOWindow = GOO_OpenWindowTags(MyScreen, WA_Left, 20, WA_Top, 20, WA_Width, 200, WA_Height, 150, TAG_DONE))
      {
        // Add an object or two
        ok = TRUE;
        printf("Read images...\n");
        if(!(TroopTabs[TAB_ON]  = LARD_ReadImage(TROOPTAB_ON)))  ok = FALSE;
        if(!(TroopTabs[TAB_OFF] = LARD_ReadImage(TROOPTAB_OFF))) ok = FALSE;
        if(!(CityTabs[TAB_ON]   = LARD_ReadImage(CITYTAB_ON)))   ok = FALSE;
        if(!(CityTabs[TAB_OFF]  = LARD_ReadImage(CITYTAB_OFF)))  ok = FALSE;
        if(!(OptsTabs[TAB_ON]   = LARD_ReadImage(OPTSTAB_ON)))   ok = FALSE;
        if(!(OptsTabs[TAB_OFF]  = LARD_ReadImage(OPTSTAB_OFF)))  ok = FALSE;
        if(!(bm1                = LARD_ReadImage(BUT1)))         ok = FALSE;
        if(!(bm2                = LARD_ReadImage(BUT2)))         ok = FALSE;

        if(ok)
        {
          UWORD x = 0;
          printf("Create objects...\n");
          if(!(GOO_NewObjectTags(GOOWindow, 
               GOOTAG_Type,     GOOTYPE_BUTTON,
               GOOTAG_BitMap,   TroopTabs[TroopTab],
               GOOTAG_LeftEdge, x,
               GOOTAG_TopEdge,  0,
               GOOTAG_Width,    GOOOBJ_USEBITMAPWIDTH,
               GOOTAG_Height,   GOOOBJ_USEBITMAPHEIGHT,
               GOOTAG_ID,       ID_TROOPTAB,
               GOOTAG_TipText,  "Troop Options",
               TAG_DONE))) ok = FALSE;
          x += (GetBitMapAttr(TroopTabs[TroopTab], BMA_WIDTH));
          if(!(GOO_NewObjectTags(GOOWindow, 
               GOOTAG_Type,     GOOTYPE_BUTTON,
               GOOTAG_BitMap,   CityTabs[CityTab],
               GOOTAG_LeftEdge, x,
               GOOTAG_TopEdge,  0,
               GOOTAG_Width,    GOOOBJ_USEBITMAPWIDTH,
               GOOTAG_Height,   GOOOBJ_USEBITMAPHEIGHT,
               GOOTAG_ID,       ID_CITYTAB,
               GOOTAG_TipText,  "City Options",
               TAG_DONE))) ok = FALSE;
          x += (GetBitMapAttr(CityTabs[CityTab], BMA_WIDTH));
          if(!(GOO_NewObjectTags(GOOWindow, 
               GOOTAG_Type,     GOOTYPE_BUTTON,
               GOOTAG_BitMap,   OptsTabs[OptsTab],
               GOOTAG_LeftEdge, x,
               GOOTAG_TopEdge,  0,
               GOOTAG_Width,    GOOOBJ_USEBITMAPWIDTH,
               GOOTAG_Height,   GOOOBJ_USEBITMAPHEIGHT,
               GOOTAG_ID,       ID_OPTIONSTAB,
               GOOTAG_TipText,  "Options",
               TAG_DONE))) ok = FALSE;
          if(!(GOO_NewObjectTags(GOOWindow, 
               GOOTAG_Type,     GOOTYPE_BUTTON,
               GOOTAG_LeftEdge, 0,
               GOOTAG_TopEdge,  70,
               GOOTAG_ID,       ID_QUIT,
               GOOTAG_Text,     "Quitting Time",
               TAG_DONE))) ok = FALSE;
          if(!(GOO_NewObjectTags(GOOWindow,
               GOOTAG_Type,     GOOTYPE_STRING,
               GOOTAG_LeftEdge, 20,
               GOOTAG_TopEdge,  100,
               GOOTAG_Width,    100,
               GOOTAG_Height,   12,
               GOOTAG_ID,       ID_STRING,
               GOOTAG_Text,     "String Test!",
               GOOTAG_TipText,  "Wow, a string gadget!",
               TAG_DONE))) ok = FALSE;
          if(!(GOO_NewObjectTags(GOOWindow,
               GOOTAG_Type,     GOOTYPE_STRING,
               GOOTAG_LeftEdge, 20,
               GOOTAG_TopEdge,  115,
               GOOTAG_Width,    125,
               GOOTAG_Height,   12,
               GOOTAG_ID,       ID_STRING2,
               GOOTAG_Text,     "16 chars...",
               GOOTAG_TipText,  "Multiple string gadgets are a doddle!",
               GOOTAG_MaxChars, 16,
               TAG_DONE))) ok = FALSE;
          if(!(GOO_NewObjectTags(GOOWindow,
               GOOTAG_Type,     GOOTYPE_BUTTON,
               GOOTAG_LeftEdge, 20,
               GOOTAG_TopEdge,  140,
               GOOTAG_ID,       9,
               GOOTAG_Text,     "Click me to remove string gadget 1",
               TAG_DONE))) ok = FALSE;
          if(!(GOO_NewObjectTags(GOOWindow,
               GOOTAG_Type,     GOOTYPE_LABEL,
               GOOTAG_LeftEdge, 20,
               GOOTAG_TopEdge,  50,
               GOOTAG_ID,       8,
               GOOTAG_Text,     "Some Text!",
               GOOTAG_TipText,  "This is some text.",
               GOOTAG_FrontPen, 2,
               GOOTAG_BackPen,  1,
               GOOTAG_Border,   TRUE,
               TAG_DONE))) ok = FALSE;
          if(!(GOO_NewObjectTags(GOOWindow,
               GOOTAG_Type,      GOOTYPE_TEXT,
               GOOTAG_ID,        11,
               GOOTAG_LeftEdge,  20,
               GOOTAG_TopEdge,   20,
               GOOTAG_FrontPen,  2,
               GOOTAG_BackPen,   0,
               GOOTAG_Text,      "Selected Category",
               GOOTAG_Border,    TRUE,
               GOOTAG_BGapX,     2,
               GOOTAG_BGapY,     2,
               TAG_DONE))) ok = FALSE;
          if(!(GOO_NewObjectTags(GOOWindow,
               GOOTAG_Type,     GOOTYPE_BUTTON,
               GOOTAG_BitMap,   bm1,
               GOOTAG_AltBitMap,bm2,
               GOOTAG_LeftEdge, 0,
               GOOTAG_TopEdge,  100,
               GOOTAG_Width,    GOOOBJ_USEBITMAPWIDTH,
               GOOTAG_Height,   GOOOBJ_USEBITMAPHEIGHT,
               GOOTAG_ID,       997,
               GOOTAG_TipText,  "Alternate button",
               TAG_DONE))) ok = FALSE;
          if(ok)
          {
            struct GOOIMsg *Msg;
            BOOL Done = FALSE;
            ULONG Class, ID, Code;
            
            // Set up the pens
            GOO_SetInternal(GOOINT_TIPBACKPEN, 16);
            GOO_SetInternal(GOOINT_TIPTEXTPEN, 31);
            GOO_SetInternal(GOOINT_SHINEPEN,   23);
            GOO_SetInternal(GOOINT_SHADOWPEN,  28);

            // Refresh objects
            printf("Refresh...\n");
            GOO_RefreshObjects(GOOWindow, FALSE);
/*
            GOO_RefreshObject(GOOWindow, ID_QUIT);
            GOO_RefreshObject(GOOWindow, ID_STRING);
            GOO_RefreshObject(GOOWindow, ID_STRING2);
*/
            RefreshTabs();
            // Wait for a click on the 2nd button
            while(!Done)
            {
              if(Msg = GOO_WaitIMsg(GOOWindow))
              {
                while(Msg)
                {
                  Class = Msg->Class; ID = Msg->ID; Code = Msg->Code;
                  Mics = Msg->Micros; Secs = Msg->Seconds;
                  GOO_ReplyIMsg(Msg);

                  switch(Class)
                  {
                    case GOOCL_BUTTONSELECT:
                    {
                      // A button object was selected
                      switch(ID)
                      {
                        case ID_TROOPTAB:
                        {
                          TroopTab = TAB_ON;
                          CityTab = OptsTab = TAB_OFF;
                          RefreshTabs();
                          break;
                        }
                        case ID_CITYTAB:
                        {
                          CityTab = TAB_ON;
                          TroopTab = OptsTab = TAB_OFF;
                          RefreshTabs();
                          break;
                        }
                        case ID_OPTIONSTAB:
                        {
                          OptsTab = TAB_ON;
                          CityTab = TroopTab = TAB_OFF;
                          RefreshTabs();
                          break;
                        }
                        case ID_QUIT:
                        {
                          Done = TRUE;
                          break;
                        }
                        case 9:
                        {
                          // Remove the first string gadget
                          printf("Freeing object...\n");
                          GOO_FreeObject(GOOWindow, ID_STRING);
                          GOO_FreeObject(GOOWindow, ID_STRING2);
                          GOO_FreeObject(GOOWindow, 9);
                          printf("Refreshing objects...\n");
                          GOO_RefreshObjects(GOOWindow, TRUE);
                          break;
                        }
                        case 997:
                        {
                          char texty[20];
                          sprintf(texty, "%ld", a++);
                          GOO_SetObjectAttrTags(GOOWindow, 11, GOOTAG_Text, texty, TAG_DONE);
                          GOO_RefreshObject(GOOWindow, 11);
                          break;
                        }
                      }
                      break;
                    }
                    case GOOCL_MOUSECLICK:
                    {
                      if(Code == SELECTUP)
                      {
                        if(DoubleClick(LastSecs, LastMics, Secs, Mics))
                        {
                          DisplayBeep(MyScreen);
                        }
                        LastMics = Mics; LastSecs = Secs;
                      }
                      break;
                    }
                    case GOOCL_STRINGCHANGE:
                    {
                      switch(ID)
                      {
                        case ID_STRING:
                        {
                          printf("You entered '%s'\n", (STRPTR)GOO_GetObjectAttr(GOOWindow, ID, GOOTAG_Text));
                          break;
                        }
                        case ID_STRING2:
                        {
                          printf("Second string gadget contains '%s'\n", (STRPTR)GOO_GetObjectAttr(GOOWindow, ID, GOOTAG_Text));
                          break;
                        }
                      }
                      break;
                    }
                    case GOOCL_RAWKEYPRESS:
                    {
                      printf("You pressed key ID %ld\n", Code);
                      break;
                    }
                  }

                  // Next message
                  Msg = GOO_GetIMsg(GOOWindow);
                }
              }
            }
          }
        }
      }
    }
  }
  
  // Tidy up
  printf("Freeing...\n");
  if(TroopTabs[TAB_ON])  FreeBitMap(TroopTabs[TAB_ON]);
  if(TroopTabs[TAB_OFF]) FreeBitMap(TroopTabs[TAB_OFF]);
  if(CityTabs[TAB_ON])   FreeBitMap(CityTabs[TAB_ON]);
  if(CityTabs[TAB_OFF])  FreeBitMap(CityTabs[TAB_OFF]);
  if(OptsTabs[TAB_ON])   FreeBitMap(OptsTabs[TAB_ON]);
  if(OptsTabs[TAB_OFF])  FreeBitMap(OptsTabs[TAB_OFF]);
  if(bm1) FreeBitMap(bm1);
  if(bm2) FreeBitMap(bm2);
  if(GOOWindow)          GOO_CloseWindow(GOOWindow, TRUE);
  if(MyScreen)           CloseScreen(MyScreen);
  if(IFFBase)            CloseLibrary(IFFBase);
  if(UtilityBase)        CloseLibrary(UtilityBase);
  printf("done\n");
}

void RefreshTabs(void)
{
  if(GOOWindow)
  {
    // Which tab is on?
    if(TroopTab == TAB_ON)
    {
      CityTab = OptsTab = TAB_OFF;
      GOO_SetObjectAttrTags(GOOWindow, ID_TROOPTAB, 
                            GOOTAG_BitMap, TroopTabs[TroopTab], 
                            TAG_DONE);
      GOO_SetObjectAttrTags(GOOWindow, ID_CITYTAB, 
                            GOOTAG_BitMap, CityTabs[CityTab], 
                            TAG_DONE);
      GOO_SetObjectAttrTags(GOOWindow, ID_OPTIONSTAB, 
                            GOOTAG_BitMap, OptsTabs[OptsTab], 
                            TAG_DONE);
      GOO_RefreshObject(GOOWindow, ID_CITYTAB);
      GOO_RefreshObject(GOOWindow, ID_OPTIONSTAB);
      GOO_RefreshObject(GOOWindow, ID_TROOPTAB);
    }
    else if(CityTab == TAB_ON)
    {
      TroopTab = OptsTab = TAB_OFF;
      GOO_SetObjectAttrTags(GOOWindow, ID_TROOPTAB, 
                            GOOTAG_BitMap, TroopTabs[TroopTab], 
                            TAG_DONE);
      GOO_SetObjectAttrTags(GOOWindow, ID_CITYTAB, 
                            GOOTAG_BitMap, CityTabs[CityTab], 
                            TAG_DONE);
      GOO_SetObjectAttrTags(GOOWindow, ID_OPTIONSTAB, 
                            GOOTAG_BitMap, OptsTabs[OptsTab], 
                            TAG_DONE);
      GOO_RefreshObject(GOOWindow, ID_CITYTAB);
      GOO_RefreshObject(GOOWindow, ID_OPTIONSTAB);
      GOO_RefreshObject(GOOWindow, ID_TROOPTAB);
    }
    else if(OptsTab == TAB_ON)
    {
      TroopTab = CityTab = TAB_OFF;
      GOO_SetObjectAttrTags(GOOWindow, ID_TROOPTAB, 
                            GOOTAG_BitMap, TroopTabs[TroopTab], 
                            TAG_DONE);
      GOO_SetObjectAttrTags(GOOWindow, ID_CITYTAB, 
                            GOOTAG_BitMap, CityTabs[CityTab], 
                            TAG_DONE);
      GOO_SetObjectAttrTags(GOOWindow, ID_OPTIONSTAB, 
                            GOOTAG_BitMap, OptsTabs[OptsTab], 
                            TAG_DONE);
      GOO_RefreshObject(GOOWindow, ID_CITYTAB);
      GOO_RefreshObject(GOOWindow, ID_OPTIONSTAB);
      GOO_RefreshObject(GOOWindow, ID_TROOPTAB);
    }
  }
}


