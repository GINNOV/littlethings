/* Demo03.c                                                     */
/* September 3, 2008 by Gilles Pelletier, C conversion from     */
/* Demo03.a      Version 1.00   July 20, 2000   by Ken Shillito */

/*
 *  This program demonstrates the use of a ucode_blok in ucode_library
 *  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *  It...  (1) opens a window
 *         (2) puts a string of Unicode glyphs on the window
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
  BOOL fp = FALSE ;
  UWORD ublk[] = { 0x0021, 0x007e, 0x00a1, 0x00ff, 0x0000 } ;
  

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
                              WA_IDCMP, IDCMP_SIZEVERIFY|IDCMP_CLOSEWINDOW,
                              WA_Title, (LONG)"Ucode Demo03 in C",
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


******************  Step 1: set ucode_path attributes  ********************

; In the example below, I will set up a ucode_blok. This is a set of
; glyphs which are kept in memory, rather then read from file, when
; required. This is only slightly slower to set up, but the when you print
; glyphs from a ucode_block it is much quicker than printing them from file.
; A particular ucode_blok is only usable when TLUset/findpath has set
; attributes (and ucode_warper if any) the same as when the ucode_blok
; was created. ucode.library automatically caches and classifies the
; ucode_bloks, so when you re-call TLUset/findpath, it will retrieve any
; ucode_path matching the attributes (and warper if any) you are setting.
; Any new ucode_blok you create will be interleaved with any already found
; to be existing. Any glyphs you want that are not in the ucode_blok will
; be loaded from the file as required.

; Below you will see you must create a list of Unicode ranges, usually in
; the stack, to make a ucode_blok. The list items can: overlap; or be out of
; order; or overlap with previous calls. ucode.library will sort it all out.
; After you call TLUset/findpath, you can discard the list. You must point
; A1 to the list, and set the xxp_stab in D4 to tell TLUset/findpath that
; you want a ucode_blok.
*/

  
  TLUset( 11, /* nominal height = 11 */
           4, /* width = 4 = NM = normal */
          ('S'<<8)|('S'), /* style = SS = sans serif */
           1, /* weight = 1 */
          xxp_bmake, /* xxp_bmake = A1 points to ucode_blok list */
           0, /* gunic */
          upath,
          &ublk[4], /* blist */
          &ublk[0], /* klist */
          NULL /* flist */ ) ;

 

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

    /* print string at 0,0 */
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
               "Here are some Unicodes:",
               NULL ) ;

    TLUstring( 0,     /* xpos  } relative to wbox */
               16,    /* ypos  }                  */
               &wbox, /* wbox                     */
               &wint, /* wint                     */
               0xc0000000, /* bit 31 = ASCII format, bit 30 = allow HTML-style '&...;' things */
               1,     /* fgpen */
               0,     /* bgpen */
               2,     /* character spacing */
               upath,
               wndw->RPort, /* wndw's rastport */
               "&#XBCA0;&#XA006;&#X5145; &#X260E;&#X27AE;&#X3265; "
               "&#X0634;&#X05E9;&#X0409;&#X03A3;&#X01C5;&#X0905;",
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
