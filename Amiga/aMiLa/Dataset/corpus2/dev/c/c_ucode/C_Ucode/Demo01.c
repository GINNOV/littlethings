/* Demo01.c                                                     */
/* September 1, 2008 by Gilles Pelletier, C conversion from     */
/* Demo01.a      Version 1.00   July 20, 2000   by Ken Shillito */

/*
 *  This program demonstrates minimal programming of ucode.library
 *  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *  It...  (1) opens a window
 *         (2) puts a Unicode glyph on the window
 *         (3) waits for the user to click the close window gadget
 *         (4) shuts down
 *
 *  (Caution: If the program fails, it does not report why, but just exits)
 */

#include <stdio.h>
#include <stdlib.h>

#include <exec/types.h>

#include <dos/dosextens.h>
#include <intuition/intuition.h>

#include <proto/exec.h>
#include <proto/intuition.h>

#include <libraries/ucode.h>
#include <proto/ucode.h>


int main(int argc, char *argv[])
{
  struct Library  *UcodeBase = NULL ;
  struct Library  *IntuitionBase = NULL ;
  struct xxp_path *upath = NULL ;
  struct Window   *wndw = NULL ;
  struct Message  *msg = NULL ;
  WORD wint[4] ;

  UcodeBase = OpenLibrary("UCODE:ucode.library", xxp_uver) ;
  if (UcodeBase == NULL)
  {
    printf("Sorry ucode.library not found\n") ;
    exit(0) ;
  }

  /****** Setting up Step 3: make ucode_path structure   *******/

  upath = TLUstart( 0, /* same bitplanes as default public screen */
                   48, /* value for single glyphs */
                   70  /* max glyph height */) ;
  if (upath == NULL)
  {
    printf("TLUstart returns NULL\n") ;
    CloseLibrary(UcodeBase) ;
    exit(20) ;
  }

  /*************  Setting up Step 4: open window ***************/

  IntuitionBase = upath->xxp_intp ;

  wndw = OpenWindowTags(NULL, WA_Left, 20,
                              WA_Top, 20,
                              WA_Width, 400,
                              WA_Height, 150,
                              WA_MinWidth, 80,
                              WA_MinHeight, 20,
                              WA_MaxWidth, 0,
                              WA_MaxHeight, 0,
                              WA_CloseGadget, -1,
                              WA_SizeGadget, -1,
                              WA_DragBar, -1,
                              WA_Activate, -1,
                              WA_NoCareRefresh, -1,
                              WA_IDCMP, IDCMP_CLOSEWINDOW,
                              WA_Title, (LONG)"Ucode Demo01 in C",
                              TAG_DONE ) ;
  if (wndw == NULL)
  {
    printf("can't open window\n") ;
    TLUfinish(upath) ;
    CloseLibrary(UcodeBase) ;
    exit(21) ;
  }

  /****************************************************************/
  /*                                                              */
  /*        Setting up is complete - now do something             */
  /*        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~             */
  /****************************************************************/


  /***********  Step 1: set ucode_path attributes  ********************/
  /* The glyph to be displayed below will be grabbed from a data file */
  /* named "Ucode/Uni/U0B/NMSS100".  The "0B" in the "U0B"            */
  /* sub-directory means the glyphs are of nominal height 11 ($0B=11).*/
  /* Files of nominal height 11 have "actual" height of 14 (for       */
  /* details, see ucode.guide). The "NM" means width = NorMal, which  */
  /* means the width code (which can be 0-8) is 4. The "SS" means     */
  /* "Sans Serif" style. The "1" means the weight code (which can be  */
  /* 1 to 9) is 1. The "00" means that the 1024 glyphs in the file    */
  /* have first 2 digits $00.., that is they are $0000 to $03FF.      */
  /********************************************************************/

  TLUset(11, /* nominal height = 11 */
          4, /* width = 4 = NM = normal */
         'S'<<8|'S', /* style = SS = sans serif */
          1, /* weight = 1 */
          0, /* flags = 0 = no flags set */
          0, /* gunic */
          upath,
          NULL,
          NULL,
          NULL) ;

  /***********  Step 2: show a glyph ******************************/
  /* I arbitrarily decided to show the glyph for Unicode $0158,   */
  /* at position 20,10 on the window interior, with pens 1,0.     */
  /****************************************************************/

  /* xpos of top of interior */
  wint[0] = wndw->BorderLeft ;

  /* width of window interior */
  wint[2] = wndw->Width - (wint[0] + wndw->BorderRight) ;
 
  /* -ypos of top of window interior */  
  wint[1] = wndw->BorderTop ;

  /* height of window interior */
  wint[3] = wndw->Height - (wint[1] + wndw->BorderBottom) ;


  /* grab the glyph to the window */

  TLUgrabrport(     20, /* xpos of lhs of glyph = 20 */
                    10, /* ypos of top of glyph's max ascender = 10 */
                     0, /* 0 = use default wbox (i.e. 0,0,10000,10000) */
                 &wint,
                0x0158, /* Unicode = $0158 */
                     1, /* fgpen = 1 */
                     0, /* bgpen = 0 */
                 upath, /* ucode_path */
               wndw->RPort /* window's rastport */ ) ;

  /***  Step 3: Wait until user clicks the CloseWindow gadget ***/
  WaitPort(wndw->UserPort) ;
  do
  {
    msg = GetMsg(wndw->UserPort) ;
    if (msg != NULL)
    {
      ReplyMsg(msg) ;
    }
  } while (msg != NULL) ;


  /***************************************************************/
  /*                                                             */
  /*              Finally, close everything down                 */
  /*              ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~                 */
  /***************************************************************/

  /*****   Close window  *****/

  CloseWindow(wndw) ;


  /*****   Release ucode.library structures  *****/

  TLUfinish(upath) ;

  /*****   Close ucode.library  *******/

  CloseLibrary(UcodeBase) ;

  return 0 ;
}

