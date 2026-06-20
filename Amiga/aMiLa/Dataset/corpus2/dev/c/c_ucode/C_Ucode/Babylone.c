/* Babylone.c                                                   */
/* September 1, 2008 by Gilles Pelletier                        */

/*
 *  This program shows some programming of ucode.library
 *  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *  It...  (1) opens a window
 *         (2) puts a Unicode glyph on the window
 *         (3) waits for the user to click the close window gadget
 *         (4) shuts down
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
  int xpos = 0 ;
  int ypos = 0 ;
  UWORD *unichar ;

  UWORD utf16_chain[] = {
    0x0425, /* Cyrillic */
    0x0430,
    0x0440,
    0x0434,
    0x0443,
    0x0435,
    0x0440,
    0x0020,
    0x786c, /* Traditional Chinese */
    0x4ef6,
    0x0020,
    0x0627, /* Arabic */
    0x0644,
    0x0627,
    0x062c,
    0x0647,
    0x0632,
    0x0647,
    0x0000
  } ;

  UWORD utf16_mariya[] = {
    0x041c, /* M */
    0x0430, /* A */
    0x0440, /* R */
    0x0438, /* IY */
    0x044f, /* A */
    0x0000
  } ;

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
                              WA_Title, (LONG)"Babylone",
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
         ('S'<<8)|'S', /* style = SS = sans serif */
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

  unichar = utf16_chain ;
  xpos = 20 ;
  ypos = 10 ;
  while (*unichar != 0)
  {

   TLUgrabrport(  xpos, /* xpos of lhs of glyph = 20 */
                  ypos, /* ypos of top of glyph's max ascender = 10 */
                  NULL, /* NULL = use default wbox (i.e. 0,0,10000,10000) */
                 &wint,
              *unichar, /* Unicode char */
                     1, /* fgpen = 1 */
                     0, /* bgpen = 0 */
                 upath, /* ucode_path */
               wndw->RPort /* window's rastport */ ) ;
    unichar++ ;
    xpos += 10 ;
  }

  xpos = 1 ;
  ypos += 13 ;

  TLUstring( xpos,
             ypos,
             NULL,
             &wint,
             0x00000000,
             1,
             0,
             0,
             upath,
             wndw->RPort,
             utf16_chain,
             NULL ) ;

  ypos += 13 ;
  TLUstring( xpos,
             ypos,
             NULL,
             &wint,
             0x00000000,
             1,
             0,
             1,
             upath,
             wndw->RPort,
             utf16_chain,
             NULL ) ;

  ypos += 13 ;
  TLUstring( xpos,
             ypos,
             NULL,
             &wint,
             0x00000000,
             1,
             0,
             2,
             upath,
             wndw->RPort,
             utf16_chain,
             NULL ) ;

  ypos += 13 ;
  TLUstring( xpos,
             ypos,
             NULL,
             &wint,
             (1 << 31)|(1 << 30)|(1 << 29),
             1,
             0,
             2,
             upath,
             wndw->RPort,
             "&laquo;Hello&raquo; &ldquo;Hello&rdquo; <b>mon c&oelig;ur balance en &eacute;t&eacute;.</b>",
             NULL ) ;

  ypos += 13 ;
  TLUstring( xpos,
             ypos,
             NULL,
             &wint,
             0x00000000,
             1,
             0,
             2,
             upath,
             wndw->RPort,
             utf16_mariya,
             NULL ) ;

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

