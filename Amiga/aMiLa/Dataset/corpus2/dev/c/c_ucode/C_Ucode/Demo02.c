/* Demo02.c                                                     */
/* September 2, 2008 by Gilles Pelletier, C conversion from     */
/* Demo02.a      Version 1.00   July 20, 2000   by Ken Shillito */


/*
 *  This program demonstrates the use of ucode.library's TLUfindpath routine
 *  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
  WORD wbox[4] ;
  BOOL fp = FALSE ;

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
                              WA_IDCMP, IDCMP_SIZEVERIFY|IDCMP_CLOSEWINDOW,
                              WA_Title, (LONG)"Ucode Demo02 in C",
                              TAG_DONE ) ;
  if (wndw == NULL)
  {
    printf("can't open window\n") ;
    TLUfinish(upath) ;
    CloseLibrary(UcodeBase) ;
    exit(21) ;
  }

  /***************************************************************/
  /*                                                             */
  /*        Setting up is complete - now do something            */
  /*        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~            */
  /***************************************************************/


  /***********  Step 1: set ucode_path attributes  ************************/
  /* In Demo01.c, the program knew that a data file existed. This program */
  /* does not; rather, it blindly sets a set of file attributes.          */
  /* ucode.library will search through its data files, finding the file   */
  /* of best match, and if the match is not perfect, will set values in a */
  /* "ucode_warper" which will try to change all glyphs loaded to match   */
  /* as closely as possible the attributes specified.                     */
  /*                                                                      */
  /* The above is done by calling TLUfindpath, which has the same calling */
  /* registers as TLUset, except that in addition D5 is set with a        */
  /* Unicode value. The Unicode value is set within a range of 1024       */
  /* values for which a file is sought. You can always assume that if a   */
  /* file exists for any value not with 0000 to 03FF, it will also exist  */
  /* for 0000 ro 03FF. So if, for example, you are working with Arabic    */
  /* text, you might specify D5 = 0700, and you TLUfindpath will set      */
  /* things up for finding glyphs from 0000 to 03FF and also 0400 to 07FF */
  /* (the range which includes Arabic).                                   */
  /*                                                                      */
  /* I have specified a value of 4 for D3 below, which will seek a file   */
  /* Ucode/Uni/U0B/NMSS420. TLUfindpath will not find such a file, but    */
  /* will find the best fit, i.e. NMSS120, and will set the ucode_warper  */
  /* to embold glyphs from weight 1 to weight 4. If you want to use the   */
  /* warper (if required), then set the flag "xxp_lwarp" in D4.           */
  /************************************************************************/
 
  fp = TLUfindpath( 11, /* nominal height = 11 */
                     4, /* width = 4 = NM = normal */
                    ('S'<<8)|'S', /* style = SS = sans serif */
                     4, /* weight = 4 */
                    xxp_lwarp, /* flags = xxp_lwarp = use warper */
                    0x2000, /* set for Unicodes in range 2000-23FF */
                    0,
                    upath,
                    NULL,
                    NULL,
                    NULL ) ;

  /**************  Step 2: show glyphs ************************************/
  /* This section prints a string of glyphs to the window.                */
  /* The string to be printed is at address *string.                      */
  /* So far, TLUstring does not do character forming or adding diacritical*/
  /* marks or bidirectionality - it simply shows the glyphs one after     */
  /* another.                                                             */
  /************************************************************************/
  if (fp)
  {
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
               "&ldquo;Hello, world&rdquo;", /* string to be printed */
               NULL ) ;
  }

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
