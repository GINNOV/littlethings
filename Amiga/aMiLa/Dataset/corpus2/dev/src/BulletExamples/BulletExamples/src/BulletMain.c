/* BulletMain.c - Execute me to compile me with SAS/C 5.10a
LC -cfistq -v -y -j73 BulletMain.c
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

long __min_oslibver = 37;

static UBYTE *readargsstring = "FontName,Size/N,XDPI/N,YDPI/N,CharCode/N,CharCode2/N,V=VPModeID/K,B=BitDepth/K,C=Colors/K\n";
static UBYTE *fontstring     = "FONTS:CGTimes.font";
static UBYTE *dpivarname = "XYDPI";  /* Name of an X/Y DPI environment variable. */
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
              struct RastPort *, ULONG, ULONG, ULONG, ULONG, ULONG);

#define BUFSIZE     256

#define NUM_ARGS     9    /* Arguments for ReadArgs(). */
#define FONT_NAME    0
#define SIZE         1
#define XDPI         2
#define YDPI         3
#define CODE         4
#define CODE2        5
#define VPMODEID     6
#define BITDEPTH     7
#define COLORS       8
static LONG          args[NUM_ARGS];
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

  ULONG           defpointheight = 3600; /* Default values for ReadArgs() */
  ULONG           defxdpi = 68;          /* variables.                    */
  ULONG           defydpi = 27;
  ULONG           defcode = (ULONG) 'A';
  ULONG           defcode2 = 0;

  if (GfxBase = (struct GfxBase *)OpenLibrary("graphics.library", 37L))
  {
    if (IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library", 37L))
    {
      if (myrda = ReadArgs(readargsstring, args, NULL))
      {
        if (args[XDPI] && args[YDPI]) /* If the user sets the DPI from the command  */
        {            /* line, make sure the environment variable also gets changed. */
          *(ULONG *)xydpi = ( (*(LONG *) args[XDPI]) << 16 | (*(ULONG *) args[YDPI]) );
          SetVar(dpivarname, xydpi, 5,
              GVF_GLOBAL_ONLY | GVF_BINARY_VAR | GVF_DONT_NULL_TERM);
        }
        else                            /* If the user did NOT set the X OR Y DPI...*/
        {
          args[XDPI] = (LONG) &defxdpi; /* ...set to default values and look for    */
          args[YDPI] = (LONG) &defydpi; /* an environment variable called "XYDPI".  */
                                                  /* Read the environment variable, */
          if ((GetVar(dpivarname, xydpi, 5,        /* XYDPI, if it exists.          */
              GVF_GLOBAL_ONLY | GVF_BINARY_VAR | GVF_DONT_NULL_TERM)) != -1)

     /* BUG!: In the original publication of this code, the line above erroneously  */
     /* tested for the wrong return value.  It caused unexpected results when using */
     /* the default X and Y DPI values.  This bug was also present in BulletMain.c. */

          {
            if ( (*(ULONG *)xydpi & 0xFFFF0000) && (*(ULONG *)xydpi & 0x0000FFFF) )
            {     /* Make sure the environment variable is OK to use by making sure */
                  /* that neither X or YDPI is zero. If XYDPI is OK, use it as the  */
              defxdpi = ((*(ULONG *)xydpi) & 0xFFFF0000) >> 16;        /* default.  */
              defydpi = (*(ULONG *)xydpi) & 0x0000FFFF;
            }
          }
        }
        if (! args[SIZE])
          args[SIZE] = (LONG) &defpointheight;
        if (! args[CODE])
          args[CODE] = (LONG) &defcode;
        if (! args[CODE2])
          args[CODE2] = (LONG) &defcode2;
        if (! args[FONT_NAME])
          args[FONT_NAME] = (LONG) fontstring;
                                           /* Open the ".font" file which contains  */
                                           /* the FontContentsHeader for this font. */
        if (fontfile = Open((STRPTR) args[FONT_NAME], MODE_OLDFILE))
        {
          if (Read(fontfile, &fchid, sizeof(UWORD)))
          {
            if (fchid == OTAG_ID)             /* Does this font have an .otag file? */
            {
              strcpy(buf, (STRPTR) args[FONT_NAME]); /* Put together the otag file  */
              if (otagname = &(buf[strlen(buf) - 4]))/* name from the .font file.   */
              {
                strcpy(otagname, "otag");
                if (UtilityBase = OpenLibrary("utility.library", 37L))
                {
                  if (ti = AllocOtag(buf))      /* open the otag file and copy its  */
                  {                             /* tags into memory.                */
                    if (BulletBase = OpenScalingLibrary(ti)) /* Pass the function   */
                    {                                  /* the OTAG tag list which it*/
                                                       /* needs to open the scaling */
                      if (ge = GetGlyphEngine(ti, buf))/* library.  Open the        */
                      {                                /* library's scaling engine. */
                        if (w = openwindow((STRPTR)args[VPMODEID],
                                (STRPTR)args[BITDEPTH], (STRPTR)args[COLORS]))
                        {
                          struct Screen *screen = w->WScreen;

                          rp = *(w->RPort); /* Clone window's RastPort.  The second */
                                            /* Rastport is for rendering with the   */
                                            /* background color.                    */
                          if (drawinfo = GetScreenDrawInfo(screen))     /* Get the */
                          {            /* screen's DrawInfo to get its pen colors. */
                            SetAPen(w->RPort, drawinfo->dri_Pens[TEXTPEN]);
                            SetAPen(&rp, drawinfo->dri_Pens[BACKGROUNDPEN]);
                            FreeScreenDrawInfo(screen, drawinfo);
                          }

                          BulletExample(ge, w, &rp, *(ULONG *) args[SIZE],
                                  *(ULONG *) args[XDPI],
                                  *(ULONG *) args[YDPI],
                                  *(ULONG *) args[CODE],
                                  *(ULONG *) args[CODE2]);

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
