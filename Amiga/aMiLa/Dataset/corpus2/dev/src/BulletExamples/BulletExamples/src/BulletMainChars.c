/* BulletMainFile.c - Execute me to compile me with SAS/C 5.10a LC -cfistq -v -y -j73 BulletMainFile.c
quit */

/* (c)  Copyright 1992 Commodore-Amiga, Inc.   All rights reserved.       */
/* The information contained herein is subject to change without notice,  */
/* and is provided "as is" without warranty of any kind, either expressed */
/* or implied.  The entire risk as to the use of this information is      */
/* assumed by the user.                                                   */

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <string.h>
#include "window.h"

#define OTAG_ID 0x0f03
#define BUFSIZE     256

long __min_oslibver = 37;

static UBYTE *readargsstring = "StartCode,EndCode,FontName,Size/N,Leading/N,Descender/N,XDPI/N,YDPI/N,V=VPModeID/K,B=BitDepth/K,C=Colors/K\n";
static UBYTE *fontstring     = "FONTS:CGTimes.font";
static UBYTE *dpivarname = "XYDPI";   /* Name of an X/Y DPI environment variable. */
                                   /* If this ENV: variable exists, this code  */
                                   /* will use the X and Y DPI stored there.   */
                                   /* This code will also save the X and Y DPI */
                                   /* in XYDPI if the user supplies a DPI.     */
                                   /* XYDPI encodes the DPI just like the      */
                                   /* OT_DeviceDPI tag.                        */

extern struct TagItem *AllocOtag(STRPTR);
extern void   FreeOtag(void *);
extern struct Library *OpenScalingLibrary(struct TagItem *);
extern void   CloseScalingLibrary(struct Library *);
extern struct GlyphEngine *GetGlyphEngine(struct TagItem *, STRPTR);
extern void   ReleaseGlyphEngine(struct GlyphEngine *);
extern void   BulletExample(struct GlyphEngine *,
                  struct Window *,
                  struct RastPort *,
                  ULONG, ULONG, ULONG, ULONG, ULONG, ULONG, ULONG);

#define NUM_ARGS    11 /* Arguments for ReadArgs(). */
#define STARTCODE   0
#define ENDCODE     1
#define FONT_NAME   2
#define SIZE        3
#define LEADING     4
#define DESCENDER   5
#define XDPI        6
#define YDPI        7
#define VPMODEID    8
#define BITDEPTH    9
#define COLORS      10
static LONG         args[NUM_ARGS];
static struct RDArgs *myrda;

struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;
struct Library *BulletBase, *UtilityBase;

static UBYTE    buf[BUFSIZE];
static BPTR     fontfile, dpifile;
static UBYTE    *otagname;
static UWORD    fchid;

static struct DrawInfo *drawinfo;
static struct RastPort rp;

int main(void)
{
  struct TagItem *ti;
  struct GlyphEngine *ge;
  struct Window  *w;

  UBYTE           xydpi[5];

  LONG           startcode, endcode;
  LONG           defstartcode = 0x21;
  LONG           defendcode = 0x7e;
  LONG           defpointheight = 3600;
  LONG           defleading = 120;
  LONG           defdescender = 25;
  LONG           defxdpi = 68;
  LONG           defydpi = 27;

  if (GfxBase = (struct GfxBase *)OpenLibrary("graphics.library", 37L))
  {
    if (IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library", 37L))
    {
      if (myrda = ReadArgs(readargsstring, args, NULL))
      {
        if (args[XDPI] && args[YDPI]) /* If the user sets the DPI from the command  */
        {            /* line, make sure the environment variable also gets changed. */
          *(ULONG *)xydpi = ( (*(LONG *)args[XDPI]) << 16 | (*(ULONG *)args[YDPI]) );
          SetVar(dpivarname, xydpi, 5,
              GVF_GLOBAL_ONLY | GVF_BINARY_VAR | GVF_DONT_NULL_TERM);
        }
        else                           /* If the user did NOT set the X OR Y DPI... */
        {
          args[XDPI] = (LONG) &defxdpi;/* ...set to default values and see if there */
          args[YDPI] = (LONG) &defydpi;/* there is an environment variable "XYDPI". */
                                                  /* Read the environment variable, */
          if ((GetVar(dpivarname, xydpi, 5,       /* XYDPI, if it exists.           */
              GVF_GLOBAL_ONLY | GVF_BINARY_VAR | GVF_DONT_NULL_TERM)) != -1)

/* BUG! In the original publication of this code, the line above erroneously tested */
/* tested for the wrong return value.  It caused unexpected results when using the  */
/* default X and Y DPI values.  This bug was also present in BulletMain.c.          */

          {
            if ( (*(ULONG *)xydpi & 0xFFFF0000) && (*(ULONG *)xydpi & 0x0000FFFF) )
            {          /* Make sure the environment variable is OK to use by making */
                       /* sure that neither X or YDPI is zero. If XYDPI is OK, use  */
              defxdpi = ((*(ULONG *)xydpi) & 0xFFFF0000) >> 16; /* it as a default. */
              defydpi = (*(ULONG *)xydpi) & 0x0000FFFF;
            }
          }
        }

        if (args[STARTCODE] && stch_l((STRPTR) args[STARTCODE], &startcode) ==
                strlen((STRPTR) args[STARTCODE]))
          args[STARTCODE] = (LONG) &startcode;
        else
          args[STARTCODE] = (LONG) &defstartcode;
        if (args[ENDCODE] && stch_l((STRPTR) args[ENDCODE], &endcode) ==
                strlen((STRPTR) args[ENDCODE]))
          args[ENDCODE] = (LONG) &endcode;
        else
          args[ENDCODE] = (LONG) &defendcode;
        if (! args[SIZE])
          args[SIZE] = (LONG) &defpointheight;
        if (! args[LEADING])
          args[LEADING] = (LONG) &defleading;
        if (! args[DESCENDER])
          args[DESCENDER] = (LONG) &defdescender;
        if (! args[FONT_NAME])
          args[FONT_NAME] = (LONG) fontstring;
                                           /* Open the ".font" file which contains  */
                                           /* the FontContentsHeader for this font. */

        if (fontfile = Open((STRPTR) args[FONT_NAME], MODE_OLDFILE))
        {
          if (Read(fontfile, &fchid, sizeof(UWORD)))
          {
            if (fchid == OTAG_ID)            /* Does this font have an .otag file? */
            {
              strcpy(buf, (STRPTR) args[FONT_NAME]);   /* Put together the .otag   */
              if (otagname = &(buf[strlen(buf) - 4]))  /* file name from the .font */
              {                                        /* file name.               */
                strcpy(otagname, "otag");
                if (UtilityBase = OpenLibrary("utility.library", 37L))
                {
                  if (ti = AllocOtag(buf))      /* open the otag file and copy its */
                  {                             /* tags into memory.               */
                    if (BulletBase = OpenScalingLibrary(ti)) /* Pass the function  */
                    {                                  /* the OTAG tag list which  */
                      if (ge = GetGlyphEngine(ti, buf))/* it needs to open the     */
                      {                              /* scaling library.  Open the */
                                                     /* library's scaling engine.  */
                        if (w = openwindow((STRPTR)args[VPMODEID],
                                (STRPTR)args[BITDEPTH], (STRPTR)args[COLORS]))
                        {
                          struct Screen *screen = w->WScreen;

                          rp = *(w->RPort);    /* Clone window's RastPort.  The    */
                                               /* second Rastport is for rendering */
                                               /* with the background color.       */
                          if (drawinfo = GetScreenDrawInfo(screen))     /* Get the */
                          {            /* screen's DrawInfo to get its pen colors. */
                            SetAPen(w->RPort, drawinfo->dri_Pens[TEXTPEN]);
                            SetAPen(&rp, drawinfo->dri_Pens[BACKGROUNDPEN]);
                            FreeScreenDrawInfo(screen, drawinfo);
                          }

                          BulletExample(ge, w, &rp, *(ULONG *) args[SIZE],
                                  *(ULONG *) args[LEADING],
                                  *(ULONG *) args[DESCENDER],
                                  *(ULONG *) args[XDPI],
                                  *(ULONG *) args[YDPI],
                                  *(ULONG *) args[STARTCODE],
                                  *(ULONG *) args[ENDCODE]);

                          CloseWindow(w);
                          CloseScreen(screen);
                        }
                        ReleaseGlyphEngine(ge);
                      }
                      CloseScalingLibrary(BulletBase);
                    }
                    FreeOtag(ti);
                  }
                  CloseLibrary(UtilityBase);
                }
              }
            }
          }
          Close(fontfile);
        }
        FreeArgs(myrda);
      }
      CloseLibrary((struct Library *)IntuitionBase);
    }
    CloseLibrary((struct Library *)GfxBase);
  }

  return RETURN_OK;
}
