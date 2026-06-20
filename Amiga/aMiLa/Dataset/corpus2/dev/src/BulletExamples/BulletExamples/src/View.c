/* View.c - Execute me to compile me with SAS/C 5.10a
LC -cfistq -v -y -j73 View.c
Blink FROM LIB:c.o,BulletMainFile.o,engine.o,View.o TO View LIBRARY LIB:LC.lib,LIB:Amiga.lib
quit */

/* (c)  Copyright 1992 Commodore-Amiga, Inc.   All rights reserved.       */
/* The information contained herein is subject to change without notice,  */
/* and is provided "as is" without warranty of any kind, either expressed */
/* or implied.  The entire risk as to the use of this information is      */
/* assumed by the user.                                                   */

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/bullet.h>
#include <exec/memory.h>
#include <diskfont/diskfonttag.h>
#include <diskfont/oterrors.h>
#include <string.h>
#include "rev/View_rev.h"
#include "input.h"

/* Defining DISPKERN enables display of kerning values. */
#undef DISPKERN

static char *version = VERSTAG;

static PLANEPTR        tempbitmap;
static struct IntuiMessage *mymsg;
static UBYTE           *viewfilebuf, *currchar;
static ULONG           currposition, emheight, emwidth, x, y;

static BPTR            viewfile;
static LONG            actual;
static struct Task     *mytask;
static struct FileInfoBlock *fib;

void
BulletExample(struct GlyphEngine * ge,
              struct Window * w, struct RastPort * rp,
              ULONG pointheight, ULONG leading, ULONG descender,
              ULONG xdpi, ULONG ydpi, ULONG nokern, ULONG spckern,
              ULONG tabfigs, STRPTR tracking, STRPTR ucs, STRPTR viewfilename)
{
  UWORD           wlimitx, wlimity, newwidth;
  FIXED           kern;

  SetWindowTitles(w, VERS, VERS);

  if (pointheight < 100) pointheight = 100;

  wlimitx = w->Width  - w->BorderRight  - 2; /* The X and Y extent of the window */
  wlimity = w->Height - w->BorderBottom - 2; /* that we can draw into.           */

  if (SetInfo(ge,                                      /* Set up the X and Y DPI of */
          OT_DeviceDPI, xdpi << 16 | ydpi,             /* target raster.  Neither   */
          OT_PointHeight, (pointheight << 16) / 100,   /* of these can be zero!     */
          TAG_END) != OTERR_Success)                   /* BulletMainFile.c checks   */
    return;                                            /* for zero.                 */

  if (viewfile = Open(viewfilename, MODE_OLDFILE))/* Open the ASCII file to display.*/
  {
    if (fib = AllocDosObject(DOS_FIB, NULL))      /* Find out how big the display   */
    {                                             /* file is by looking at its      */
      if (ExamineFH(viewfile, fib))               /* FileInfoBlock.  Allocate that  */
      {                                           /* Much memory.                   */
        if (viewfilebuf = (UBYTE *) AllocVec(fib->fib_Size, MEMF_CLEAR))
        {
          if (Read(viewfile, (UBYTE *) viewfilebuf, fib->fib_Size))    /* Read the  */
          {                                          /* whole file into its buffer. */
            SetDrMd(w->RPort, JAM1);
            if (tempbitmap = AllocRaster(640, 200)) /* Allocate some Chip RAM space */
            {      /* where we can temporarily store the glyph so we can blit it.   */
              if (ModifyIDCMP(w,                        /* Turn on the Close gadget */
                      IDCMP_CLOSEWINDOW | IDCMP_VANILLAKEY))  /* and key presses.   */
              {
                FIXED trk = 0;
                LONG ucstype = 0;

                if (tracking && StrToLong(tracking, (LONG *)&trk) > 0)
                  trk = (trk << 16) / 100;

                if (ucs && StrToLong(ucs, &ucstype) > 0)
                  if (ucstype != 2 && ucstype != 4)
                    ucstype = 0;

                emheight = (pointheight * ydpi) / 7200; /* Calculate the dimensions   */
                emwidth = (pointheight * xdpi) / 7200;  /* of the EM square in screen */
                     /* pixels. This is necessary because bullet.library measures   */
                     /* character widths and kerning values as fractions of an EM.  */
                     /* An EM (pronounced like the letter 'M') is a measure of      */
                     /* distance that is equal to the point size of a typeface      */
                     /* (which means one EM is not constant across different type   */
                     /* sizes).  For a 72 point typeface, one EM = 72 points which  */
                     /* approximately equals one inch.                              */
                leading = (emheight * leading) / 100;
                descender = (emheight * descender) / 100;
                x = w->BorderLeft + 2;           /* Calculate the starting point    */
                y = w->BorderTop + 2 + emheight; /* for glyph rendering.            */

                                      /* Step through each character in the buffer. */
                for (currposition = 0; currposition < fib->fib_Size;
                        currposition += ucstype ? ucstype : 1)
                {
                  ULONG c, c2;

                  if (ucstype == 4)
                  {
                    c = *((ULONG *)&viewfilebuf[currposition]);
                    c2 = currposition < fib->fib_Size - 7 ?
                            *((ULONG *)&viewfilebuf[currposition + 4]) : 0;
                  }
                  else if (ucstype == 2)
                  {
                    c = *((UWORD *)&viewfilebuf[currposition]);
                    c2 = currposition < fib->fib_Size - 3 ?
                            *((UWORD *)&viewfilebuf[currposition + 2]) : 0;
                  }
                  else
                  {
                    c = viewfilebuf[currposition];
                    c2 = currposition < fib->fib_Size - 1 ?
                            viewfilebuf[currposition + 1] : 0;
                  }

                                /* Set the current glyph, which is the one we'll be */
                                /* rendering in this interation of the loop, and    */
                                /* the secondary glyph, which, besides being the    */
                                /* next glyph we will render, is necessary to find  */
                                /* the proper kerning value between the glyphs.     */
                                /* Notice that this example does not account for    */
                                /* the presence of non-printables (carriage return, */
                                /* DEL, etc.) which effects the kerning.  A real    */
                  if (SetInfo(ge,  /* application should consider these.           */
                              OT_GlyphCode, c,
                              OT_GlyphCode2, c2,
                              TAG_END) == OTERR_Success)
                  {
                    struct GlyphMap *gm = NULL;
                    struct MinList *wl = NULL;

                    kern = 0;         /* Find the kerning adjustment between glyph1 */
                                      /* and glyph2.  This example doesn't account  */
                                      /* for the validity of the glyphs.            */
                    if (! nokern && (spckern ||
                            c != 0x20 && c != 0xa0 &&
                            (c < 0x2000 || c > 0x200b)) &&
                            c2 != 0x20 && c2 != 0xa0 &&
                            (c2 < 0x2000 || c2 > 0x200b) &&
                            (! tabfigs ||
                            (c < '0' || c > '9') && (c2 < '0' || c2 > '9')))
                      ObtainInfo(ge, OT_TextKernPair, &kern, TAG_END);

                    #ifdef DISPKERN
                    Printf("%04lx <-> %04lx: %lu\n", c, c2, kern);
                    #endif

                    /* Ask the scaling engine for the */
                    /* bitmap for the current glyph.  */
                    if (ObtainInfo(ge, OT_GlyphMap, &gm, TAG_END) != OTERR_Success)
                    {
                      /* If there is no glyph, get the width */
                      if (SetInfo(ge, OT_GlyphCode2, c, TAG_END) == OTERR_Success)
                        ObtainInfo(ge, OT_WidthList, &wl, TAG_END);
                    }

                    newwidth = 0;
                    if (gm)
                    {
                      /* Calculate the width of the current character including    */
                      /* any kerning adjustment.  Because the width is represented */
                      /* as a fixed point binary fraction of an EM, this needs to  */
                      /* be converted to a width in screen pixels.                 */
                      newwidth = ((gm->glm_Width - kern + trk) * emwidth) >> 16;
                    }
                    else if (wl)
                    {
                      /* Calculate the width of a whitespace character including */
                      /* any kerning adjustment.                                 */
                      struct GlyphWidthEntry *we =
                              (struct GlyphWidthEntry *)wl->mlh_Head;
                      if (we->gwe_Node.mln_Succ)
                        newwidth = ((we->gwe_Width - kern + trk) * emwidth) >> 16;
                    }
                    if (x + newwidth > wlimitx    /* Make sure the glyph gets     */
                            || c == '\n')         /* renderered inside the window */
                    {                             /* bounds.                      */
                      x = w->BorderLeft + 2;
                      y += leading;
                      if (y + descender > wlimity)
                                         /* If the text goes beyond the bottom of */
                      {                  /* the window, scroll the contents of    */
                                         /* the window up one line.               */
                        y -= leading;
                        ScrollRaster(rp, 0, leading, w->BorderLeft, w->BorderTop,
                                wlimitx + 1, wlimity + 1);
                      }
                    }
                    if (gm)
                    {
                      CopyMem(gm->glm_BitMap,/* Copy the raw bitmap to chip memory. */
                              tempbitmap,
                              gm->glm_BMModulo * gm->glm_BMRows);

                      BltTemplate(           /* Render the glyph using the blitter  */
                                             /* and the RastPort settings.          */
                                   (PLANEPTR) (((ULONG) tempbitmap)
                                     + (gm->glm_BMModulo * gm->glm_BlackTop)
                                         + ((gm->glm_BlackLeft >> 4) << 1)),
                                   gm->glm_BlackLeft & 0xF,
                                   gm->glm_BMModulo,
                                   w->RPort,
                                   x - gm->glm_X0 + gm->glm_BlackLeft,
                                   y - gm->glm_Y0 + gm->glm_BlackTop,
                                   gm->glm_BlackWidth,     /* glm_X0 & Y0 are used  */
                                   gm->glm_BlackHeight);   /* to make the example a */
                                    /* little simpler.  They are not as accurate as */
                                    /* using glm_XOrigin and glm_YOrigin in con-    */
                                    /* juntion with fractional width and kerning    */
                                    /* values.                                      */
                      ReleaseInfo(ge, OT_GlyphMap, gm, TAG_END);
                    }
                    else if (wl)
                      ReleaseInfo(ge, OT_WidthList, wl, TAG_END);
                    if (c != '\n')
                      x += newwidth;
                    if (! handlekey(w))
                      currposition = fib->fib_Size;
                  }
                }
              }
              FreeRaster(tempbitmap, 640, 200);
            }
          }
          FreeVec(viewfilebuf);
        }
      }
      FreeDosObject(DOS_FIB, fib);
    }
    Close(viewfile);
    waitclose(w);
  }
}
