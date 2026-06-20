;/* AvailFonts.c - Execute me to compile me with Lattice 5.10a
LC -cfistq -v -y -j73 AvailFonts.c
Blink FROM LIB:c.o,AvailFonts.o TO AvailFonts LIBRARY LIB:LC.lib,LIB:Amiga.lib
quit ;


Copyright (c) 1992 Commodore-Amiga, Inc.

This example is provided in electronic form by Commodore-Amiga, Inc. for
use with the "Amiga ROM Kernel Reference Manual: Libraries", 3rd Edition,
published by Addison-Wesley (ISBN 0-201-56774-1).

The "Amiga ROM Kernel Reference Manual: Libraries" contains additional
information on the correct usage of the techniques and operating system
functions presented in these examples.  The source and executable code
of these examples may only be distributed in free electronic form, via
bulletin board or as part of a fully non-commercial and freely
redistributable diskette.  Both the source and executable code (including
comments) must be included, without modification, in any copy.  This
example may not be published in printed form or distributed with any
commercial product.  However, the programming techniques and support
routines set forth in these examples may be used in the development
of original executable software products for Commodore Amiga computers.

All other rights reserved.

This example is provided "as-is" and is subject to change; no
warranties are made.  All use is at your own risk. No liability or
responsibility is assumed.
*/

#include <exec/types.h>
#include <dos/rdargs.h>
#include <dos/dosextens.h>
#include <intuition/intuition.h>
#include <intuition/screens.h>
#include <graphics/text.h>
#include <graphics/displayinfo.h>
#include <graphics/regions.h>
#include <graphics/gfx.h>
#include <libraries/diskfont.h>
#include <utility/tagitem.h>
#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/layers_protos.h>
#include <clib/alib_stdio_protos.h>
#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>
#include <clib/diskfont_protos.h>
#include <clib/utility_protos.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }
#endif

UBYTE *vers = "\0$VER: AvailFonts 36.3";

void MainLoop(void);
ULONG StrLen(UBYTE *);

struct stringstruct {
        UBYTE *string;
        LONG charcount;
        WORD stringwidth;
};

UBYTE *alphabetstring = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
struct stringstruct fname, fheight, XDPI, YDPI, entrynum;
struct Library *DiskfontBase, *IntuitionBase, *LayersBase, *GfxBase, *UtilityBase;
struct Window *mywin;
struct RastPort *mycliprp, myrp;
struct Rectangle myrect;
struct Region *new_region, *old_region;
struct DrawInfo *mydrawinfo;
struct AvailFontsHeader *afh;
LONG fontheight, alphabetcharcount;
WORD stringwidth;

void main(int argc, char **argv)
{
  struct TextFont *defaultfont = NULL;
  struct TextAttr defaultfontattr = { "topaz.font", 9, 0, 0 };

  LONG afsize, afshortage, cliprectside;

  fname.string = "Font Name:  ";
  fheight.string = "Font Height:  ";
  XDPI.string = "X DPI:  ";
  YDPI.string = "Y DPI:  ";
  entrynum.string = "Entry #:  ";

  if (DiskfontBase = OpenLibrary("diskfont.library", 37L))              /* Open the libraries. */
  {
    if (IntuitionBase = OpenLibrary("intuition.library", 37L))
    {
      if (GfxBase = OpenLibrary("graphics.library", 37L))
      {
        if (LayersBase = OpenLibrary("layers.library", 37L))
        {
          if (UtilityBase = OpenLibrary("utility.library", 37L))
          {
            if (mywin = OpenWindowTags(NULL,                              /* Open that window. */
                                    WA_SmartRefresh,TRUE,
                                    WA_SizeGadget,  FALSE,
                                    WA_CloseGadget, TRUE,
                                    WA_IDCMP,       IDCMP_CLOSEWINDOW,
                                    WA_DragBar,     TRUE,
                                    WA_DepthGadget, TRUE,
                                    WA_Title,       (ULONG)"AvailFonts() example",
                                    TAG_END))
            {
              myrp = *(mywin->RPort);       /* A structure assign: clone my window's Rastport. */
                                            /* RastPort.  This RastPort will be used to render */
                                            /* the font specs, not the actual font sample.     */
              if (mydrawinfo = GetScreenDrawInfo(mywin->WScreen))
              {
                SetFont(&myrp, mydrawinfo->dri_Font);

                myrect.MinX = mywin->BorderLeft;                          /* LAYOUT THE WINDOW */
                myrect.MinY = mywin->BorderTop;
                myrect.MaxX = mywin->Width - (mywin->BorderRight + 1);
                myrect.MaxY = mywin->Height - (mywin->BorderBottom + 1);

                cliprectside = (myrect.MaxX - myrect.MinX) / 20;

                fname.charcount    = StrLen(fname.string);
                fheight.charcount  = StrLen(fheight.string);
                XDPI.charcount     = StrLen(XDPI.string);
                YDPI.charcount     = StrLen(YDPI.string);
                entrynum.charcount = StrLen(entrynum.string);
                alphabetcharcount  = StrLen(alphabetstring);

                fontheight = (myrp.Font->tf_YSize) + 2;

                if (fontheight > ((myrect.MaxY - myrect.MinY) / 6))  /* If the default screen  */
                {                                                    /* font is more than one- */
                  defaultfont = OpenFont(&defaultfontattr);          /* sixth the size of the  */
                  SetFont(&myrp, defaultfont);                       /* window, use topaz-9.   */
                  fontheight = (myrp.Font->tf_YSize) + 2;
                }

                fname.stringwidth   = TextLength(&myrp, (STRPTR)fname.string, fname.charcount);
                fheight.stringwidth = TextLength(&myrp, (STRPTR)fheight.string, fheight.charcount);
                XDPI.stringwidth    = TextLength(&myrp, (STRPTR)XDPI.string, XDPI.charcount);
                YDPI.stringwidth    = TextLength(&myrp, (STRPTR)YDPI.string, YDPI.charcount);
                entrynum.stringwidth =
                    TextLength(&myrp, (STRPTR)entrynum.string, entrynum.charcount);

                stringwidth = fname.stringwidth;         /* What is the largest string length? */
                stringwidth =
                    (fheight.stringwidth > stringwidth) ? fheight.stringwidth : stringwidth;
                stringwidth = (XDPI.stringwidth > stringwidth) ? XDPI.stringwidth : stringwidth;
                stringwidth = (YDPI.stringwidth > stringwidth) ? YDPI.stringwidth : stringwidth;
                stringwidth =
                    (entrynum.stringwidth > stringwidth) ? entrynum.stringwidth : stringwidth;
                stringwidth += mywin->BorderLeft;

                if (stringwidth < ((myrect.MaxX - myrect.MinX) >> 1)) /* If the stringwidth is */
                {                                                 /* more than half the viewing*/
                  SetAPen(&myrp, mydrawinfo->dri_Pens[TEXTPEN]);  /* area, quit because the    */
                  SetDrMd(&myrp, JAM2);                           /* font is just too big.     */

                  Move(&myrp, myrect.MinX + 8 + stringwidth - fname.stringwidth,
                               myrect.MinY + 4 + (myrp.Font->tf_Baseline));
                  Text(&myrp, fname.string, fname.charcount);

                  Move(&myrp, myrect.MinX + 8 + stringwidth - fheight.stringwidth,
                              myrp.cp_y + fontheight);
                  Text(&myrp, fheight.string, fheight.charcount);

                  Move(&myrp, myrect.MinX + 8 + stringwidth - XDPI.stringwidth,
                              myrp.cp_y + fontheight);
                  Text(&myrp, XDPI.string, XDPI.charcount);

                  Move(&myrp, myrect.MinX + 8 + stringwidth - YDPI.stringwidth,
                              myrp.cp_y + fontheight);
                  Text(&myrp, YDPI.string, YDPI.charcount);

                  Move(&myrp, myrect.MinX + 8 + stringwidth - entrynum.stringwidth,
                              myrp.cp_y + fontheight);
                  Text(&myrp, entrynum.string, entrynum.charcount);

                  myrect.MinX = myrect.MinX + cliprectside;
                  myrect.MaxX = myrect.MaxX - cliprectside;
                  myrect.MinY = myrect.MinY + (5 * fontheight) + 8;
                  myrect.MaxY = myrect.MaxY - 8;

                  SetAPen(&myrp, mydrawinfo->dri_Pens[SHINEPEN]);         /* Draw a box around */
                  Move(&myrp, myrect.MinX - 1, myrect.MaxY + 1);          /* the cliprect.     */
                  Draw(&myrp, myrect.MaxX + 1, myrect.MaxY + 1);
                  Draw(&myrp, myrect.MaxX + 1, myrect.MinY - 1);

                  SetAPen(&myrp, mydrawinfo->dri_Pens[SHADOWPEN]);
                  Draw(&myrp, myrect.MinX - 1, myrect.MinY - 1);
                  Draw(&myrp, myrect.MinX - 1, myrect.MaxY);

                  SetAPen(&myrp, mydrawinfo->dri_Pens[TEXTPEN]);
                                          /* Fill up a buffer with a list of the available fonts */
                  afsize = AvailFonts((STRPTR)afh, 0L, AFF_MEMORY|AFF_DISK|AFF_SCALED|AFF_TAGGED);
                  do
                  {
                    afh = (struct AvailFontsHeader *) AllocMem(afsize, 0);
                    if (afh)
                    {
                      afshortage = AvailFonts((STRPTR)afh, afsize,
                                              AFF_MEMORY|AFF_DISK|AFF_SCALED|AFF_TAGGED);
                      if (afshortage)
                      {
                        FreeMem(afh, afsize);
                        afsize += afshortage;
                        afh = (struct AvailFontsHeader *)(-1L);
                      }
                    }
                  } while (afshortage && afh);

                  if (afh)
                  {
                    /* This is for the layers.library clipping region that gets attached to */
                    /* the window.  This prevents the application from unnecessarily        */
                    /* rendering beyond the bounds of the inner part of the window. For     */
                    /* more information on clipping, see the Layers chapter of this manual. */

                    if (new_region = NewRegion())                 /* More layers stuff */
                    {
                      if (OrRectRegion(new_region, &myrect)) /* Even more layers stuff */
                      {
                         /* Obtain a pointer to the window's rastport and set up some of    */
                         /* the rastport attributes.  This example obtains the text pen     */
                         /* for the window's screen using the GetScreenDrawInfo() function. */
                         mycliprp = mywin->RPort;
                         SetAPen(mycliprp, mydrawinfo->dri_Pens[TEXTPEN]);

                         MainLoop();
                      }
                      DisposeRegion(new_region);
                    }
                    FreeMem(afh, afsize);
                  }
                }
                FreeScreenDrawInfo(mywin->WScreen, mydrawinfo);
              }
              CloseWindow(mywin);
            }
            CloseLibrary(UtilityBase);
          }
          CloseLibrary(LayersBase);
        }
        CloseLibrary(GfxBase);
      }
      CloseLibrary(IntuitionBase);
    }
    CloseLibrary(DiskfontBase);
  }
}



void MainLoop(void)
{
  UWORD x;
  struct Task *mytask;
  struct IntuiMessage *mymsg;
  BOOL aok = TRUE;
  struct TAvailFonts *afont;
  struct TextFont *myfont;
  UBYTE buf[8];
  ULONG dpi;

  mytask = FindTask(NULL);
  afont = (struct TAvailFonts *)&(afh[1]);

  for (x = 0; (x < afh->afh_NumEntries); x++)
  {
    if (aok)
    {
      if (myfont = OpenDiskFont(&(afont->taf_Attr)))
      {
        SetAPen(&myrp, mydrawinfo->dri_Pens[BACKGROUNDPEN]);   /* Print the TextFont attributes. */
        RectFill( &myrp, stringwidth, mywin->BorderTop + 4,
                  mywin->Width - (mywin->BorderRight + 1), myrect.MinY - 2 );

        SetAPen(&myrp, mydrawinfo->dri_Pens[TEXTPEN]);
        Move( &myrp, stringwidth + mywin->BorderLeft,
              mywin->BorderTop + 4 + (myrp.Font->tf_Baseline) );
        Text( &myrp, (UBYTE *)myfont->tf_Message.mn_Node.ln_Name,
              StrLen((UBYTE *)myfont->tf_Message.mn_Node.ln_Name) );

        Move(&myrp, stringwidth + mywin->BorderLeft, myrp.cp_y + fontheight); /* Print the      */
        sprintf(buf, "%d\0", myfont->tf_YSize);                               /* font's Y Size. */
        Text(&myrp, buf, StrLen(buf));

        Move(&myrp, stringwidth + mywin->BorderLeft, myrp.cp_y + fontheight); /* Print the X DPI */
        dpi = GetTagData( TA_DeviceDPI, 0L,
                          ((struct TextFontExtension *)(myfont->tf_Extension))->tfe_Tags);
        if (dpi)
        {
            sprintf(buf, "%d\0", ((dpi & 0xFFFF0000)>>16));
            Text(&myrp, buf, StrLen(buf));
        }
        else Text(&myrp, "nil", 3L);

        Move(&myrp, stringwidth + mywin->BorderLeft, myrp.cp_y + fontheight); /* Print the Y DPI */
        if (dpi)
        {
            sprintf(buf, "%d\0", (dpi & 0x0000FFFF));
            Text(&myrp, buf, StrLen(buf));
        }
        else Text(&myrp, "nil", 3L);

        Move(&myrp, stringwidth + mywin->BorderLeft, myrp.cp_y + fontheight);     /* Print the */
        sprintf(buf, "%d\0", x);                                                   /* entrynum. */
        Text(&myrp, buf, StrLen(buf));

        SetFont(mycliprp, myfont);
        old_region = InstallClipRegion(mywin->WLayer, new_region); /* Install clipping rectangle */

        SetRast(mycliprp, mydrawinfo->dri_Pens[BACKGROUNDPEN]);
        Move( mycliprp, myrect.MinX, myrect.MaxY - (myfont->tf_YSize - myfont->tf_Baseline) );
        Text(mycliprp, alphabetstring, alphabetcharcount);

        Delay(100);

        new_region = InstallClipRegion(mywin->WLayer, old_region);  /* Remove clipping rectangle */

        while (mymsg = (struct IntuiMessage *)GetMsg(mywin->UserPort))
        {
            aok = FALSE;
            x = afh->afh_NumEntries;
            ReplyMsg((struct Message *)mymsg);
        }



        if (mytask->tc_SigRecvd & SIGBREAKF_CTRL_C)        /* Did the user hit CTRL-C (the shell */
        {                                                  /* window has to receive the CTRL-C)? */
            aok = FALSE;
            x = afh->afh_NumEntries;
            VPrintf("Ctrl-C Break\n", NULL);
        }
        CloseFont(myfont);
      }
    }
    afont++;
  }
}


ULONG StrLen(UBYTE *string)
{
    ULONG x = 0L;

    while (string[x++]);
    return(--x);
}
