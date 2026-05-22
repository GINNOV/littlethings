;/* Rotate.c - Execute me to compile me with SAS/C 5.10a
LC -cfistq -v -y -j73 Rotate.c
Blink FROM LIB:c.o,BulletMain.o,engine.o,Rotate.o TO Rotate LIBRARY LIB:LC.lib,LIB:Amiga.lib
quit ;*/

/* (c)  Copyright 1992 Commodore-Amiga, Inc.   All rights reserved.       */
/* The information contained herein is subject to change without notice,  */
/* and is provided "as is" without warranty of any kind, either expressed */
/* or implied.  The entire risk as to the use of this information is      */
/* assumed by the user.                                                   */

#include <exec/types.h>
#include <diskfont/diskfonttag.h>
#include <diskfont/diskfont.h>
#include <diskfont/glyph.h>
#include <diskfont/oterrors.h>
#include <graphics/gfx.h>
#include <graphics/regions.h>
#include <utility/tagitem.h>
#include <intuition/intuition.h>
#include <devices/timer.h>

#include <clib/alib_stdio_protos.h>
#include <clib/alib_protos.h>
#include <clib/bullet_protos.h>
#include <clib/exec_protos.h>
#include <clib/layers_protos.h>
#include <clib/graphics_protos.h>
#include <clib/intuition_protos.h>

extern struct Library *BulletBase, *UtilityBase, *GfxBase, *IntuitionBase;
struct Library *LayersBase;
void            BulletExample(struct GlyphEngine *,
                              struct Window *,
                              struct RastPort *,
                              ULONG, ULONG, ULONG, ULONG, ULONG);

UBYTE          *vers = "\0$VER: Rotate 38.10";

#define TABLE_ENTRIES 24
#define SINE_INDEX    0
#define COSINE_INDEX  1

/* precalculated sine and cosine */
LONG            table[TABLE_ENTRIES][2] =
{
  {0x0, 0x10000},             /* 0   degrees */ /* Notice that the sine and cosine  */
  {0x424e, 0xf747},           /* 15  degrees */ /* values have to correspond to the */
  {0x8000, 0xddb4},           /* 30  degrees */ /* same angle.  The IntelliFont     */
  {0xb505, 0xb505},           /* 45  degrees */ /* engine will have severe mental   */
  {0xddb4, 0x8000},           /* 60  degrees */ /* problems if the values aren't    */
  {0xf747, 0x424e},           /* 75  degrees */ /* close to representing the same   */
  {0x10000, 0x0},             /* 90  degrees */ /* angle.                           */
  {0xf747, 0xffffbdbe},       /* 105 degrees */
  {0xddb4, 0xffff8000},       /* 120 degrees */
  {0xb505, 0xffff4afb},       /* 135 degrees */
  {0x8000, 0xffff224c},       /* 150 degrees */
  {0x424e, 0xffff08b9},       /* 165 degrees */
  {0x0, 0xffff0000},          /* 180 degrees */
  {0xffffbdbe, 0xffff08b9},   /* 195 degrees */
  {0xffff8000, 0xffff224c},   /* 210 degrees */
  {0xffff4afb, 0xffff4afb},   /* 225 degrees */
  {0xffff224c, 0xffff8000},   /* 240 degrees */
  {0xffff08b9, 0xffffbdbe},   /* 255 degrees */
  {0xffff0000, 0x0},          /* 270 degrees */
  {0xffff08b9, 0x424e},       /* 285 degrees */
  {0xffff224c, 0x8000},       /* 300 degrees */
  {0xffff4afb, 0xb505},       /* 315 degrees */
  {0xffff8000, 0xddb4},       /* 330 degrees */
  {0xffffbdbe, 0xf747}        /* 345 degrees */
};

struct Rectangle rectangle;
struct Region    *region;

void
BulletExample(struct GlyphEngine * ge,
              struct Window * w, struct RastPort * rp,
     ULONG pointheight, ULONG xdpi, ULONG ydpi, ULONG unicode, ULONG unicode2)
{
  struct GlyphMap *gm;
  PLANEPTR        tempbitmap;
  ULONG           centerx, centery, x, y, dx, dy, sin, cos, oldx, oldy, olddx,
                  olddy, emheight, emwidth;
  ULONG           i = 0;

  struct IntuiMessage *mymsg;
  BOOL            done = FALSE;

  if (pointheight > 180) pointheight = 180;

  if (SetInfo(ge,
              OT_DeviceDPI, ((ULONG) xdpi) << 16 | ydpi,
              TAG_END) != OTERR_Success)
        return;

  emheight = (pointheight * ydpi) / 72; /* Calculate the pixel dimensions */
  emwidth  = (pointheight * xdpi) / 72; /* of the EM square.              */
  centerx  = w->BorderLeft + emheight;
  centery  = w->BorderTop  + emwidth;

  dx = (2 * emwidth) + w->BorderLeft + w->BorderRight;  /* Calculate window size to */
  dy = (2 * emheight) + w->BorderTop + w->BorderBottom; /* fit around glyph com-    */
  dx = (dx > 640) ? 640 : dx;                           /* fortablely.              */
  dy = (dy > 200) ? 200 : dy;
  dx = (dx < 80) ? 80: dx;
  dy = (dy < 50) ? 50: dy;

  if (ModifyIDCMP(w, IDCMP_CHANGEWINDOW))
  {
    ChangeWindowBox(w, w->LeftEdge, w->TopEdge, dx, dy);        /* Set window size  */
    WaitPort(w->UserPort);                                      /* and wait for the */
    while (mymsg = (struct IntuiMessage *) GetMsg(w->UserPort)) /* dimension change */
      ReplyMsg((struct Message *) mymsg);                       /* to take place.   */
    if (!(ModifyIDCMP(w, NULL))) return;  /* Quit if there is a problem with IDCMP. */
  }

  x = centerx; /* calculate original rendering position. */
  y = centery;
  dx = 1;   /* Since dx and dy are no longer necessary for figuring out the window  */
  dy = 1;   /* dimensions, I use them to measure the full width and height of the   */
            /* glyph bitmap supplied by bullet.  I need this to erase the glyph.    */

  if (LayersBase = OpenLibrary("layers.library", 37L)) /* These lines are       */
  {                                                    /* here to install       */
    rectangle.MinX = w->BorderLeft;                    /* a clipping            */
    rectangle.MinY = w->BorderTop;                     /* region to the         */
    rectangle.MaxX = w->Width  - w->BorderRight - 1;   /* window to keep        */
    rectangle.MaxY = w->Height - w->BorderBottom - 1;  /* the glyph within      */
                                                       /* window bounds.        */
    if (region = NewRegion())                          /* For more information, */
    {                                                  /* see the "Layers"      */
      if (OrRectRegion(region, &rectangle))            /* chapter of the        */
      {                                                /* RKRM: Libraries       */
        InstallClipRegion(w->WLayer, region);          /* Manual.               */

        if (SetInfo(ge,
                    OT_GlyphCode, unicode,                      /* Set the glyph to */
                    OT_PointHeight, (ULONG) pointheight << 16,  /* rotate and its   */
                    TAG_END) == OTERR_Success)                  /* pointsize.       */
        {
          SetDrMd(w->RPort, JAM1);
          if (tempbitmap = AllocRaster(640, 200))
          {
            if (ModifyIDCMP(w, IDCMP_CLOSEWINDOW)) /* Turn on close window reports  */
            {                                      /* so the example can quit.      */
              for (i = 0; done == FALSE; i++)
              {
                if (i == TABLE_ENTRIES)
                  i = 0;

                sin = table[i][SINE_INDEX];   /* Step through the sine/cosine array */
                cos = table[i][COSINE_INDEX]; /* 360 degrees @ 15 degree increments */

                if (SetInfo(ge,                  /* Set the current rotation angle. */
                            OT_RotateSin, sin,
                            OT_RotateCos, cos,
                            TAG_END) == OTERR_Success)
                {
                  if ((ObtainInfo(ge, OT_GlyphMap, &gm, TAG_END)) == OTERR_Success)
                  {
                    oldx = x;               /* Calculate the dimension and position */
                    oldy = y;               /* of the new glyph's bitmap and save   */
                    olddx = dx;             /* the old values so we can erase the   */
                    olddy = dy;             /* glyph that is still on the screen.   */
                    x = centerx - gm->glm_X0;
                    y = centery - gm->glm_Y0;
                    dx = gm->glm_BMModulo * 8;
                    dy = gm->glm_BMRows;

                    CopyMem(gm->glm_BitMap,/* Copy the glyph's bitmap into Chip RAM */
                            tempbitmap,    /* so we can blit it into a RastPort.    */
                            gm->glm_BMModulo * gm->glm_BMRows);

                                                            /* Erase the old glyph. */
                    RectFill(rp, oldx, oldy, oldx + olddx, oldy + olddy);

                    WaitBlit();                 /* Wait for the old glyph to erase. */

                    BltTemplate(                   /* Blit the new glyph into the   */
                                 tempbitmap,       /* window's RastPort.            */
                                 0,
                                 gm->glm_BMModulo,
                                 w->RPort,
                                 x,
                                 y,
                                 dx,
                                 dy);          /* Running several instances of this */
                                               /* example simultaneously can really */
                                               /* slow the system, so we give other */
                    TimeDelay(UNIT_VBLANK, 0, 250000);  /*   tasks a chance to run. */
                    ReleaseInfo(ge, OT_GlyphMap, gm, TAG_END);
                  }
                }                               /* Check for a CLOSEWINDOW message. */
                while (mymsg = (struct IntuiMessage *) GetMsg(w->UserPort))
                {
                  ReplyMsg((struct Message *) mymsg);
                  done = TRUE;
                }
              }
            }
            FreeRaster(tempbitmap, 640, 200);
          }
        }
      }
      DisposeRegion(region);
    }
    CloseLibrary(LayersBase);
  }
}
