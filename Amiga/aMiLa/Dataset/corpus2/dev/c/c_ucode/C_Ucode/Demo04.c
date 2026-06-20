/* Demo04.c                                                     */
/* September 6, 2008 by Gilles Pelletier, C conversion from     */
/* Demo04.a      Version 1.00   July 20, 2000   by Ken Shillito */

/*
 *
 *  This program demonstrates how to dimension strings before printing
 *  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *  It...  (1) opens a window
 *         (2) puts a string of Unicode glyphs in the window's bottom right
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
  WORD wbox[4] ;
  char *string = NULL ;
  ULONG res ;

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

  wndw = OpenWindowTags(NULL, WA_Left, 20,
                              WA_Top, 20,
                              WA_Width, 350,
                              WA_Height, 120,
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
                              WA_Title, (LONG)"Ucode Demo04 in C",
                              TAG_DONE ) ;
  if (wndw == NULL)
  {
    printf("can't open window\n") ;
    TLUfinish(upath) ;
    CloseLibrary(UcodeBase) ;
    exit(21) ;
  }


/*
***************************************************************************
*
*            Setting up is complete - now do something
*            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
***************************************************************************
*/

  /********  Step 1: set ucode_path attributes  ********/

  TLUset( 11, /* nominal height = 11 */
           4, /* width = 4 = NM = normal */
          ('S'<<8)|('S'), /* style = SS = sans serif */
           1, /* weight = 1 */
          0, /* no flags set */
          0, /* gunic */
          upath,
          NULL, /* blist */
          NULL, /* klist */
          NULL  /* flist */ ) ;

  /********   Step 2: Find the String Dimensions   ********/
/*
; This demo shows how to set a flag in TLUstring to preview rather than
; print a string, in order to find out its dimensions. There is also a
; ucode.library routine called TLUdims to find the dimensions of a single
; glyph. TLstring, whether previewing or printing, returns in D0:
;
;      bits 24-31  ascender
;           16-23  descender
;           0-15   width
;
; TLUprint previews much quicker than it prints, still more so if most of
; the glyphs it previews are in a ucode_block.
*/

  /* xpos of top of interior */
  wint[0] = wndw->BorderLeft ;

  /* width of window interior */
  wint[2] = wndw->Width - (wint[0] + wndw->BorderRight) ;
 
  /* -ypos of top of window interior */  
  wint[1] = wndw->BorderTop ;

  /* height of window interior */
  wint[3] = wndw->Height - (wint[1] + wndw->BorderBottom) ;

  /* make wbox (0, 0, wint width, wint height) */
  wbox[0] = 0 ;
  wbox[1] = 0 ;
  wbox[2] = wint[2] ;
  wbox[3] = wint[3] ;

  /* the string */
  string = "&#X261E; &#X00AB;Voici la fen&#X00EA;tre&#X00BB; &#X261C;" ;

  /* call TLUstring in preview mode */
  res = TLUstring( 0,     /* xpos  } relative to wbox */
                   0,     /* ypos  }                  */
                   &wbox, /* wbox                     */
                   &wint, /* wint                     */
                   (1 << 15)| /* bit 15 = preview only */
                   (1 << 31)| /* bit 31 = ASCII format */
                   (1 << 30), /* bit 30 = allow HTML-style '&...;' things */
                   1,     /* fgpen */
                   0,     /* bgpen */
                   2,     /* character spacing */
                   upath,
                   wndw->RPort, /* wndw's rastport */
                   string,
                   NULL ) ;
 
  /*******   Step 3: show a string in the bottom right of the window   *******/

  res = TLUstring( wbox[2] - (res & 0x0000ffff),
                   wbox[3] - (upath->xxp_uwbl + ((res & 0x00ff0000) >> 16)),
                   &wbox, /* wbox                     */
                   &wint, /* wint                     */
                   (1 << 31)| /* bit 31 = ASCII format */
                   (1 << 30), /* bit 30 = allow HTML-style '&...;' things */
                   1,     /* fgpen */
                   0,     /* bgpen */
                   2,     /* character spacing */
                   upath,
                   wndw->RPort, /* wndw's rastport */
                   string,
                   NULL ) ;


  /***  Step 4: Wait until user clicks the CloseWindow gadget ***/
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
