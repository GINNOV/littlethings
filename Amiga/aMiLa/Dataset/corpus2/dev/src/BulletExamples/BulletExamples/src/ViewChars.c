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
#include "rev/ViewChars_rev.h"
#include "input.h"

static char *version = VERSTAG;

/* Code point for missing glyph (white square) */
#define NOGLYPHCODE 9633

static PLANEPTR        tempbitmap;
static struct IntuiMessage *mymsg;
static UBYTE           *viewfilebuf, *currchar;
static ULONG           emheight, emwidth, x, y;

static LONG            actual;
static struct Task     *mytask;
static struct FileInfoBlock *fib;

void
BulletExample(struct GlyphEngine * ge,
              struct Window * w, struct RastPort * rp,
              ULONG pointheight, ULONG leading, ULONG descender,
              ULONG xdpi, ULONG ydpi, ULONG startcode, ULONG endcode)
{
  UWORD           wlimitx, wlimity, newwidth;

  SetWindowTitles(w, VERS, VERS);

  if (pointheight < 100) pointheight = 100;

  wlimitx = w->Width  - w->BorderRight  - 2; /* The X and Y extent of the window */
  wlimity = w->Height - w->BorderBottom - 2; /* that we can draw into.           */

  if (SetInfo(ge,                                      /* Set up the X and Y DPI of */
          OT_DeviceDPI, xdpi << 16 | ydpi,             /* target raster.  Neither   */
          OT_PointHeight, (pointheight << 16) / 100,   /* of these can be zero!     */
          TAG_END) != OTERR_Success)                   /* BulletMainChars.c checks  */
    return;                                            /* for zero.                 */

  SetDrMd(w->RPort, JAM1);

  if (tempbitmap = AllocRaster(640, 200)) /* Allocate some Chip RAM space */
  {      /* where we can temporarily store the glyph so we can blit it.   */
    if (ModifyIDCMP(w,                        /* Turn on the Close gadget */
            IDCMP_CLOSEWINDOW | IDCMP_VANILLAKEY))  /* and key presses.   */
    {
      int i;

      emheight = (pointheight * ydpi) / 7200; /* Calculate the dimensions   */
      emwidth = (pointheight * xdpi) / 7200;  /* of the EM square in screen */
           /* pixels. This is necessary because bullet.library measures   */
           /* character widths and kerning values as fractions of an EM.  */
           /* An EM (pronounced like the letter 'M') is a measure of      */
           /* distance that is equal to the point size of a typeface      */
           /* (which means one EM is not constant across different type   */
           /* sizes).  For a 72 point typeface, one EM = 72 points which  */
           /* approximately equals one inch.                              */
      descender = emheight * descender / 100;
      leading = (emheight * leading) / 100;
      x = w->BorderLeft + 2;           /* Calculate the starting point    */
      y = w->BorderTop + 2 + emheight; /* for glyph rendering.            */

                            /* Step through each character in the range. */
      for (i = startcode; i < endcode + 1; i++)
      {
        if (SetInfo(ge, OT_GlyphCode, (ULONG)i, TAG_END) == OTERR_Success)
        {
          struct GlyphMap *gm = NULL;
          struct MinList *wl = NULL;

          /* Ask the scaling engine for the */
          /* bitmap for the current glyph.  */
          if (ObtainInfo(ge, OT_GlyphMap, &gm, TAG_END) != OTERR_Success)
          {
            /* If there is no glyph, get the width */
            if (SetInfo(ge, OT_GlyphCode2, (ULONG)i, TAG_END) == OTERR_Success)
            {
              if (ObtainInfo(ge, OT_WidthList, &wl, TAG_END) == OTERR_Success)
              {
                struct GlyphWidthEntry *we =
                        (struct GlyphWidthEntry *)wl->mlh_Head;
                if (! we->gwe_Node.mln_Succ) {
                  /* If there is no width, get the bitmap for the "missing */
                  /* glyph" glyph.                                         */
                  if (SetInfo(ge, OT_GlyphCode, NOGLYPHCODE,
                          TAG_END) == OTERR_Success)
                    ObtainInfo(ge, OT_GlyphMap, &gm, TAG_END);
                }
              }
            }
          }

          newwidth = 0;
          if (gm)
            /* Calculate the width of the current character.               */
            /* Because the width is represented as a fixed point binary    */
            /* fraction of an EM, this needs to be converted to a width in */
            /* screen pixels.                                              */
            newwidth = (gm->glm_Width * emwidth) >> 16;
          else if (wl)
          {
            /* Calculate the width of a whitespace character.              */
            struct GlyphWidthEntry *we =
                    (struct GlyphWidthEntry *)wl->mlh_Head;
            newwidth = (we->gwe_Width * emwidth) >> 16;
          }
          if (x + newwidth > wlimitx)   /* Make sure the glyph gets     */
                                        /* renderered inside the window */
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
          if (wl)
            ReleaseInfo(ge, OT_WidthList, wl, TAG_END);
          x += newwidth;
          if (! handlekey(w))
            i = endcode;
        }
      }
    }
    FreeRaster(tempbitmap, 640, 200);
  }
  waitclose(w);
}
