/*
 *  File:       bogogui.c
 *  Purpose:    AmigaOS 3.2 ReAction GUI for BogoMIPS calculation
 *  Version:    1.10.24
 *  Date:       16.10..2024
 *  Author:     Micha B.
 *  Compiler:   SAS/C 6.58 (other Compilers untested)
 *
 */
#include <clib/macros.h>
#include <clib/alib_protos.h>
#include <clib/compiler-specific.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/utility.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/gadtools.h>
#include <proto/icon.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <proto/window.h>
#include <proto/layout.h>
#include <proto/button.h>
#include <proto/string.h>
#include <proto/label.h>
#include <proto/requester.h>


#include <libraries/gadtools.h>
#include <reaction/reaction.h>
#include <intuition/gadgetclass.h>
#include <intuition/icclass.h>
#include <reaction/reaction_macros.h>
#include <classes/window.h>
#include <classes/requester.h>

#include <exec/memory.h>

/* repeated Delay() loop for best accurancy */
#define DELAYSERIE 8
/* classic bogomips calculation - MAGIC1 original Linus value 500000 - MAGIC2 original Linus value 5000 */
/* MACIC1 MACIC2 recalculated due delay() loop repeated 8 times */
#define MACIC1 (500000 / DELAYSERIE)
#define MACIC2 (5000 / DELAYSERIE)

#define PROGRAMNAME     "bogoGUI"
#define VERSION         "0"
#define SUBVERSION      "98"
#define REVISION        "5"

BOOL myDebug = FALSE;         // Show or hide Debugging Messages

/* construct version tag */
#if defined(__SASC)
  const UBYTE VersionTag[] = "$VER: " PROGRAMNAME " v" VERSION "." SUBVERSION "." REVISION " " __AMIGADATE__ "\n\0";
#else
  const UBYTE VersionTag[] = "$VER: bogoGUI v0.98 (16.10.2024)";
#endif
char progVersion[256] = "";

void window_main( void );

struct Screen	*gScreen = NULL;
struct DrawInfo	*gDrawInfo = NULL;
APTR gVisinfo = NULL;
struct MsgPort	*gAppPort = NULL;

struct Library *WindowBase = NULL,
               *ButtonBase = NULL,
               *StringBase = NULL,
               *LabelBase = NULL,
               *GadToolsBase = NULL,
               *LayoutBase = NULL,
               *RequesterBase = NULL,
               *IconBase = NULL;
struct IntuitionBase *IntuitionBase = NULL;

/* -- Easy Request structures: Fail if AmigOS < OS 3.9 -- */
struct EasyStruct warnreq =
  {
    sizeof(struct EasyStruct),
    0,
    "Error",
    "BogoGUI need AmigaOS 3.2.x or\nat least AmigaOS 3.9\n\nProgram aborded.",
    "Ok"
  };

/* --- Function Prototypes --------------------------------------------------- */
int main( int argc, char **argv );
int setup( void );
void cleanup( void );
void runWindow( Object *window_object,
                int window_id, struct Menu *menu_strip,
                struct Gadget *win_gadgets[] );
void window_main( void );
int doInfoRequest(struct Screen *screen, struct Window *window, const char *title,
                  const char *body,
                  const char *buttons, ULONG image );
void Delay (long);
STRPTR calcMIPS(void);

//window ids
enum win { window_main_id = 4 };

//Window_Main gadgets
enum window_main_idx { vert_6, vert_container, label_8, string_message, horiz_buttons, 
  button_quit, button_about, label_14, button_calc };
enum window_main_id { vert_6_id = 6, vert_container_id = 7, label_8_id = 8, string_message_id = 10, 
  horiz_buttons_id = 11, button_quit_id = 12, button_about_id = 13, 
  label_14_id = 14, button_calc_id = 15 };



/* --- Functions --------------------------------------------------------------- */
void delay(long loops)
{
  volatile register long i;

  for (i = loops; i >= 0 ; i--);
}


int doInfoRequest(struct Screen *screen, struct Window *window,
                  const char *title, const char *body,
                  const char *buttons, ULONG image )
{
  Object *req = 0;		// the requester itself
  int button;			// the button that was clicked by the user

  // fill in the requester structure
  req = NewObject(REQUESTER_GetClass(), NULL,
                  REQ_Type,       REQTYPE_INFO,
                  REQ_TitleText,  (ULONG)title,
                  REQ_BodyText,   (ULONG)body,
                  REQ_GadgetText, (ULONG) buttons ,
                  REQ_Image,      image,
                  TAG_DONE);

  if (req)
  {
    struct orRequest reqmsg;

    reqmsg.MethodID  = RM_OPENREQ;
    reqmsg.or_Attrs  = NULL;
    reqmsg.or_Window = NULL;
    reqmsg.or_Screen = screen;

    button = DoMethodA(req, (Msg) &reqmsg);
    DisposeObject(req);

    return button;

  }
  else if(myDebug)
    printf("[request] Failed to allocate requester\n");

  return 0;
}

int setup( void )
{
  if( !(IntuitionBase = (struct IntuitionBase*) OpenLibrary("intuition.library",0L)) ) return 0;
  if( !(GadToolsBase = (struct Library*) OpenLibrary("gadtools.library",0L) ) ) return 0;
  if( !(WindowBase = (struct Library*) OpenLibrary("window.class",0L) ) ) return 0;
  if( !(IconBase = (struct Library*) OpenLibrary("icon.library",0L) ) ) return 0;
  /* --- Check for a sufficient OS! --- */
  if( !(LayoutBase = (struct Library*) OpenLibrary("gadgets/layout.gadget",39L) ) )
  {
    EasyRequest(NULL, &warnreq, NULL);
    return 0;
  }
  if( !(ButtonBase = (struct Library*) OpenLibrary("gadgets/button.gadget",0L) ) ) return 0;
  if( !(RequesterBase = (struct Library*) OpenLibrary("requester.class",0L) ) )
    return 0;
  if( !(StringBase = (struct Library*) OpenLibrary("gadgets/string.gadget",0L) ) ) return 0;
  if( !(LabelBase = (struct Library*) OpenLibrary("images/label.image",0L) ) ) return 0;
  if( !(gScreen = LockPubScreen( 0 ) ) ) return 0;
  if( !(gVisinfo = GetVisualInfo( gScreen, TAG_DONE ) ) ) return 0;
  if( !(gDrawInfo = GetScreenDrawInfo ( gScreen ) ) ) return 0;
  if( !(gAppPort = CreateMsgPort() ) ) return 0;

  return -1;
}

void cleanup( void )
{
  if ( gDrawInfo ) FreeScreenDrawInfo( gScreen, gDrawInfo);
  if ( gVisinfo ) FreeVisualInfo( gVisinfo );
  if ( gAppPort ) DeleteMsgPort( gAppPort );
  if ( gScreen ) UnlockPubScreen( 0, gScreen );

  if (GadToolsBase) CloseLibrary( (struct Library *)GadToolsBase );
  if (IconBase) CloseLibrary( (struct Library *)IconBase );
  if (IntuitionBase) CloseLibrary( (struct Library *)IntuitionBase );
  if (RequesterBase) CloseLibrary( (struct Library *)RequesterBase );
  if (ButtonBase) CloseLibrary( (struct Library *)ButtonBase );
  if (StringBase) CloseLibrary( (struct Library *)StringBase );
  if (LabelBase) CloseLibrary( (struct Library *)LabelBase );
  if (LayoutBase) CloseLibrary( (struct Library *)LayoutBase );
  if (WindowBase) CloseLibrary( (struct Library *)WindowBase );
}

void runWindow( Object *window_object, int window_id, struct Menu *menu_strip, struct Gadget *win_gadgets[] )
{
  struct Window	*main_window = NULL;
  int req_result = 0;
  STRPTR mipsResult = "nix!";

  if ( window_object )
  {
    if ( main_window = (struct Window *) RA_OpenWindow( window_object ))
    {
      WORD Code;
      ULONG wait = 0, signal = 0, result = 0, done = FALSE;
      GetAttr( WINDOW_SigMask, window_object, &signal );
      if ( menu_strip)  SetMenuStrip( main_window, menu_strip );
      while ( !done)
      {
        wait = Wait( signal | SIGBREAKF_CTRL_C );

        if ( wait & SIGBREAKF_CTRL_C )
          done = TRUE;
        else
          while (( result = RA_HandleInput( window_object, &Code )) != WMHI_LASTMSG)
          {
            switch ( result & WMHI_CLASSMASK )
            {
              case WMHI_CLOSEWINDOW:
                SetAttrs(window_object, WA_BusyPointer, TRUE, TAG_DONE);
                req_result = doInfoRequest(NULL, main_window, "About to quit BogoGUI", \
                                           " Do you really want that? ",
                                           "_Quit now|_Cancel", REQIMAGE_QUESTION);
                if (req_result == 1)
                  done = TRUE;
                SetAttrs(window_object, WA_BusyPointer, FALSE, TAG_DONE);
                break;

              case WMHI_GADGETUP:
                switch (result & WMHI_GADGETMASK)
                {
                    case button_quit_id:
                        SetAttrs(window_object, WA_BusyPointer, TRUE, TAG_DONE);
                        req_result = doInfoRequest(NULL, main_window, "About to quit bogoGUI", \
                                                   " Do you really want that? ",
                                                   "_Quit now|_Cancel", REQIMAGE_QUESTION);
                        if (req_result == 1)
                          done = TRUE;
                        SetAttrs(window_object, WA_BusyPointer, FALSE, TAG_DONE);
                        break;
                    case button_about_id:
                        sprintf(progVersion, "              bogoGUI v%s.%s.%s \n %s ", VERSION, SUBVERSION, REVISION,
                                " - a tool for measuring your AMIGA's speed - " \
                                " \n\n  written by Micha B. in October 2024\n\n" \
                                " GUI made with ReBuild 1.2.0\n (c) Darren Coles " \
                                " \n\nBogoMips calculation routine based on code " \
                                " \nwritten by Linus Thorvalds and Dino Papararo "
                               );
                        SetAttrs(window_object, WA_BusyPointer, TRUE, TAG_DONE);
                        doInfoRequest(NULL, main_window, "About bogoGUI ", progVersion, "Now I know!", REQIMAGE_INFO);
                        SetAttrs(window_object, WA_BusyPointer, FALSE, TAG_DONE);
                        done = FALSE;	// Workaround for ReAction stack corruption bug
                        break;
                    case button_calc_id:
                        SetGadgetAttrs((APTR)win_gadgets[string_message], main_window, NULL, STRINGA_TextVal, (STRPTR)"Now calculating delay loop...", TAG_END);
                        SetAttrs(window_object, WA_BusyPointer, TRUE, TAG_DONE);
                        mipsResult = calcMIPS();
                        if(myDebug)
                            printf("mipsResult = %s\n", mipsResult);

                        SetGadgetAttrs((APTR)win_gadgets[string_message], main_window, NULL, STRINGA_TextVal, (STRPTR)mipsResult, TAG_END);
                        SetAttrs(window_object, WA_BusyPointer, FALSE, TAG_DONE);
                        break; 
                }
                break;

              case WMHI_ICONIFY:
                if ( RA_Iconify( window_object ) )
                  main_window = NULL;
                break;

              case WMHI_UNICONIFY:
                main_window = RA_OpenWindow( window_object );
                if ( menu_strip)  SetMenuStrip( main_window, menu_strip );
              break;

            }
          }
      }
    }
  }
}

void window_main( void )
{
  struct Gadget	*main_gadgets[ 10 ];
  Object *window_object = NULL;
  struct HintInfo hintInfo[] =
  {
    {vert_6_id,-1,"",0},
    {vert_container_id,-1,"",0},
    {label_8_id,-1,"",0},
    {string_message_id,-1,"Show calculated results",0},
    {horiz_buttons_id,-1,"",0},
    {button_quit_id,-1,"The End is near...",0},
    {button_about_id,-1,"Tell me who did it?",0},
    {label_14_id,-1,"",0},
    {button_calc_id,-1,"Test for Speed!",0},
    {-1,-1,NULL,0}
  };

  window_object = WindowObject,
    WA_Title, "bogoGUI v0.98",
    WA_ScreenTitle, "bogoGUI v0.98 by Micha B.",
    WA_Left, 5,
    WA_Top, 20,
    WA_Width, 250,
    WA_Height, 10,
    WA_MinWidth, 250,
    WA_MinHeight, 10,
    WA_MaxWidth, 8192,
    WA_MaxHeight, 10,
    WINDOW_LockHeight, TRUE,
    WINDOW_IconifyGadget, TRUE,
    WINDOW_HintInfo, hintInfo,
    WINDOW_GadgetHelp, TRUE,
    WINDOW_AppPort, gAppPort,
    WINDOW_IconifyGadget, TRUE,
    WA_CloseGadget, TRUE,
    WA_DepthGadget, TRUE,
    WA_SizeGadget, TRUE,
    WA_DragBar, TRUE,
    WA_Activate, TRUE,
    WA_SizeBBottom, TRUE,
    WINDOW_Position, WPOS_TOPLEFT,
    WINDOW_IconTitle, "bogoGUI",
    WINDOW_Icon,  GetDiskObject("bogoGUI"),
    WA_NoCareRefresh, TRUE,
    WA_IDCMP, IDCMP_GADGETDOWN | IDCMP_GADGETUP | IDCMP_CLOSEWINDOW | IDCMP_MENUPICK | IDCMP_NEWSIZE | IDCMP_INTUITICKS,
    WINDOW_ParentGroup, VLayoutObject,
    LAYOUT_SpaceOuter, TRUE,
    LAYOUT_DeferLayout, TRUE,
      LAYOUT_AddChild, main_gadgets[vert_6] = LayoutObject,
        GA_ID, vert_6_id,
        LAYOUT_Orientation, LAYOUT_ORIENT_VERT,
        LAYOUT_AddChild, main_gadgets[vert_container] = LayoutObject,
          GA_ID, vert_container_id,
          LAYOUT_Orientation, LAYOUT_ORIENT_VERT,
          LAYOUT_BevelStyle, BVS_GROUP,
          LAYOUT_SpaceOuter, TRUE,
          LAYOUT_LeftSpacing, 2,
          LAYOUT_RightSpacing, 2,
          LAYOUT_TopSpacing, 2,
          LAYOUT_BottomSpacing, 2,
          LAYOUT_DeferLayout, TRUE,
          LAYOUT_AddImage, main_gadgets[label_8] = LabelObject,
            GA_ID, label_8_id,
            LABEL_DrawInfo, gDrawInfo,
            LABEL_Text, "Amiga BogoMIPS Calculator",
            IA_FGPen, 2,
            IA_BGPen, 51,
            LABEL_DisposeImage, TRUE,
            LABEL_Justification, LJ_CENTER,
          LabelEnd,
          LAYOUT_AddChild, main_gadgets[string_message] = StringObject,
            GA_ID, string_message_id,
            GA_RelVerify, TRUE,
            GA_TabCycle, TRUE,
            GA_ReadOnly, TRUE,
            STRINGA_TextVal, "Waiting...",
            STRINGA_MaxChars, 80,
            STRINGA_MinVisible, 10,
          StringEnd,
          CHILD_Label, LabelObject,
            LABEL_Text, "BogoMIPS:",
          LabelEnd,
        LayoutEnd,
        LAYOUT_AddChild, main_gadgets[horiz_buttons] = LayoutObject,
          GA_ID, horiz_buttons_id,
          LAYOUT_Orientation, LAYOUT_ORIENT_HORIZ,
          LAYOUT_SpaceOuter, TRUE,
          LAYOUT_EvenSize, TRUE,
          LAYOUT_DeferLayout, TRUE,
          LAYOUT_AddChild, main_gadgets[button_quit] = ButtonObject,
            GA_ID, button_quit_id,
            GA_Text, "_Quit",
            GA_RelVerify, TRUE,
            GA_TabCycle, TRUE,
            BUTTON_TextPen, 1,
            BUTTON_BackgroundPen, 0,
            BUTTON_FillTextPen, 1,
            BUTTON_FillPen, 3,
          ButtonEnd,
          LAYOUT_AddChild, main_gadgets[button_about] = ButtonObject,
            GA_ID, button_about_id,
            GA_Text, "_About...",
            GA_RelVerify, TRUE,
            GA_TabCycle, TRUE,
            BUTTON_TextPen, 1,
            BUTTON_BackgroundPen, 0,
            BUTTON_FillTextPen, 1,
            BUTTON_FillPen, 3,
          ButtonEnd,
          LAYOUT_AddImage, main_gadgets[label_14] = LabelObject,
            GA_ID, label_14_id,
            LABEL_DrawInfo, gDrawInfo,
            LABEL_Text, "",
            LABEL_DisposeImage, TRUE,
          LabelEnd,
          LAYOUT_AddChild, main_gadgets[button_calc] = ButtonObject,
            GA_ID, button_calc_id,
            GA_Text, "_Calculate",
            GA_RelVerify, TRUE,
            GA_TabCycle, TRUE,
            BUTTON_TextPen, 1,
            BUTTON_BackgroundPen, 0,
            BUTTON_FillTextPen, 1,
            BUTTON_FillPen, 3,
          ButtonEnd,
        LayoutEnd,
      LayoutEnd,
    LayoutEnd,
  WindowEnd;  
  main_gadgets[9] = 0;

  runWindow( window_object, window_main_id, 0, main_gadgets );

  if ( window_object ) DisposeObject( window_object );
}

int main( int argc, char **argv )
{
  if ( setup() )
  {
    window_main();
  }
  cleanup();
}

/* === bogoMips calculation routine ===================================== */
/* === based on BogoMIPS - coded by Dino Papararo (Fl@sh) 04 nov 2020 === */
STRPTR calcMIPS(void)
{
  unsigned long loops_per_sec = 1;
  unsigned long ticks;
  static char bmips[20];

  int success = 0;

  if(myDebug)
    printf("Calibrating delay loop..\n");

  while ((loops_per_sec<<=1) && (!success))
  {
    ticks = clock();

/* repeat delay() 8 times to increase precision */
    delay(loops_per_sec); delay(loops_per_sec);
    delay(loops_per_sec); delay(loops_per_sec);
    delay(loops_per_sec); delay(loops_per_sec);
    delay(loops_per_sec); delay(loops_per_sec);

    ticks=clock()-ticks;

    if (ticks>=CLOCKS_PER_SEC)
    {
       loops_per_sec=(loops_per_sec/ticks)*CLOCKS_PER_SEC;
       if(myDebug)
         printf("\nOk - %lu.%02lu BogoMips\n\n",loops_per_sec/MACIC1,(loops_per_sec/MACIC2)%100);

       sprintf(bmips, "%lu.%02lu",loops_per_sec/MACIC1,(loops_per_sec/MACIC2)%100);
       success = 1;
    }
  }

  if (!success)
  {
    strcpy(bmips, "Calculation failed");
  }

  if(myDebug)
    printf("Function debug: bmips = %s\n", &bmips);

  return bmips;
}
