/* Demo05.c                                                     */
/* September 6, 2008 by Gilles Pelletier, C conversion from     */
/* Demo05.a      Version 1.00   July 20, 2000   by Ken Shillito */

/*
 *  This program demonstrates how ucode.library can grab Amiga fonts
 *  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *  It...  (1) opens a window
 *         (2) puts a Unicode glyph (grabbed from a font) on the window
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
#include <graphics/text.h>

#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/diskfont.h>

#include <libraries/ucode.h>
#include <proto/ucode.h>

int main(int argc, char *argv[])
{
  struct Library  *UcodeBase = NULL ;
  struct Library  *IntuitionBase = NULL ;
  struct Library  *GfxBase = NULL ;

  struct xxp_path *upath = NULL ;
  struct Window   *wndw = NULL ;
  struct Message  *msg = NULL ;
  WORD wint[4] ;
  WORD wbox[4] ;
  struct TextAttr ta ;
  struct TextFont *ffont = NULL ;

  ta.ta_Name = "ruby.font" ;
  ta.ta_YSize = 15 ;
  ta.ta_Style = 0 ;
  ta.ta_Flags = 0 ;

  UcodeBase = OpenLibrary("UCODE:ucode.library", xxp_uver) ;
  if (UcodeBase == NULL)
  {
    printf("Sorry ucode.library not found\n") ;
    exit(0) ;
  }

  /****** Setting up Step 3: make ucode_path structure ******/

  upath = TLUstart( 0, /* same bitplanes as default public screen */
                    0, /* value for single glyphs */
                    0  /* max glyph height */) ;
  if (upath == NULL)
  {
    printf("TLUstart returns NULL\n") ;
    CloseLibrary(UcodeBase) ;
    exit(20) ;
  }

  /*************  Setting up Step 4: open window ***************/

  IntuitionBase = upath->xxp_intp ;
  GfxBase       = upath->xxp_gfxp ;

  wndw = OpenWindowTags(NULL, WA_Left, 20,
                              WA_Top, 20,
                              WA_Width, 600,
                              WA_Height, 75,
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
                              WA_Title, (LONG)"Ucode Demo05 in C",
                              TAG_DONE ) ;
  if (wndw == NULL)
  {
    printf("can't open window\n") ;
    TLUfinish(upath) ;
    CloseLibrary(UcodeBase) ;
    exit(21) ;
  }

  /******* Setting up Step 5: Open a Font *******/

  /*
   * This programs will only work if you have ruby.font in your FONTS:
   * directory.
   */

   ffont = NULL ; /* clear ffont - will hold font address if loads ok */

   DiskfontBase = OpenLibrary("diskfont.library", 0) ;
   if (DiskfontBase != NULL)
   {
     ffont = OpenDiskFont(&ta) ; /* open an Amiga font (i.e. Ruby/15) */
     CloseLibrary(DiskfontBase) ;
   }

/*
***************************************************************************
*
*            Setting up is complete - now do something
*            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
***************************************************************************


******************  Step 1: set ucode_path attributes  ********************

; In order to use Amiga fonts, we must have a list of fonts with the
; unicodes they are to be glyphs for, usually in the stack.
;
; The font glyphs are grabbed into the ucode_path's internal ucode_block
; sructure, the structure which (in Demo03) stored glyphs in memkory. So,
; after TLUset grabs the required font glyphs, the font can be closed. The
; font glyphs will only be used whenever the ucode_path is TLUset to the
; same attributes (and warper parameters if any) that were being TLUset
; when the font glyphs were grabbed.
;
; You can poke any font glyph into any Unicode slot which has a glyph. e.g.
; if you have a Greek Amiga font, you ocan poke it over the Greek slphabet
; at U0370+. (Note: in more advanced ucode.library usage, ucode.library can
; compose all characters developed from a given glyph. So, for example,
; if you grab a font glyph to A (U0041), then all letters developed from A
; can use that glyph, with diactirical marks added.
;
; If you have a fontlist, you must set the xxp_fmake flag in D4, and also
; point A3 to your fontlist. The fontlist below only uses one font, but you
; can use several (e.g. one for Latin, another for Cyrillic) at once if
; you wish.
*/

  if (ffont != NULL)
  {
    struct mytruc 
    {
      struct TextFont* font ;
      UBYTE beg ;
      UBYTE end ;
      UWORD ubeg ;
      UWORD uend ;
    } mytruc ;

    mytruc.font = ffont ;
    mytruc.beg  = 0x21 ;
    mytruc.end  = 0x7e ;
    mytruc.ubeg = 0x0021 ;
    mytruc.uend = 0x0000 ;

    TLUset( 11, /* nominal height = 11 */
             4, /* width = 4 = NM = normal */
            ('S'<<8)|('S'), /* style = SS = sans serif */
             1, /* weight = 1 */
            xxp_fmake, /* xxp_fmake = fontlist in (A3) */
             0, /* gunic */
            upath,
            NULL, /* blist */
            NULL, /* klist */
            &mytruc /* flist */ ) ;

    CloseFont(ffont) ;
  }

  /****************  Step 2: show a string of glyhps  ************************/

  /* xpos of top of interior */
  wint[0] = wndw->BorderLeft ;

  /* width of window interior */
  wint[2] = wndw->Width - (wint[0] + wndw->BorderRight) ;
 
  /* -ypos of top of window interior */  
  wint[1] = wndw->BorderTop ;

  /* height of window interior */
  wint[3] = wndw->Height - (wint[1] + wndw->BorderBottom) ;

  /* make wbox (2, 1, wint wdth - 4, wint height -2) */
  wbox[0] = 2 ;
  wbox[1] = 1 ;
  wbox[2] = wint[2] - 4 ;
  wbox[3] = wint[3] - 2 ;

  /* call TLUstring */
  TLUstring( 0,     /* xpos  } relative to wbox */
             0,     /* ypos  }                  */
             &wbox, /* wbox                     */
             &wint, /* wint                     */
             0xc0000000, /* bit 31 = ASCII format, bit 30 = allow HTML-style '&...;' things */
             1,     /* fgpen */
             0,     /* bgpen */
             2,     /* character spacing */
             upath,
             wndw->RPort, /* wndw's rastport */
             "Well - my glyphs come from Ruby/15...",
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
