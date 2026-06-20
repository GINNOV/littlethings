/*
 * ViewDiskfont - Display a text string with a chosen font using
 *                diskfont.library and the Text() function.
 *
 * NOTE: The Text() function doesn't seem to make use of any kerning
 * information.
 */

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/diskfont.h>
#include <string.h>
#include "window.h"
#include "rev/ViewDiskfont_rev.h"

static char *version = VERSTAG;

#define MIN_OSLIBVER 37

long __min_oslibver = MIN_OSLIBVER;

static char *template = "Text,Font,Size/N,XDPI/N,YDPI/N,V=VPModeID/K,B=BitDepth/K,C=Colors/K\n";
static char *text = "The quick brown fox jumps over the lazy dog.";
static char *font= "FONTS:CGTimes.font";
static LONG size = 40;
static LONG xdpi = 72;
static LONG ydpi = 72;

static UBYTE *dpivarname = "XYDPI";
static UBYTE xydpi[5];

#define NUM_OPTS       8
#define OPT_TEXT       0
#define OPT_FONT       1
#define OPT_SIZE       2
#define OPT_XDPI       3
#define OPT_YDPI       4
#define OPT_VPMODEID   5
#define OPT_BITDEPTH   6
#define OPT_COLORS     7
static LONG opts[NUM_OPTS];
static struct RDArgs *args;

struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;
struct Library *DiskfontBase;

static void waitclose(struct Window *w)
{
    int done = FALSE;

    while (! done) {
        struct IntuiMessage *msg;
        Wait(1L << w->UserPort->mp_SigBit);
        while (msg = (struct IntuiMessage *)GetMsg(w->UserPort)) {                                       /* Did the user hit the */
            if (msg->Class == CLOSEWINDOW)
                done = TRUE;
            ReplyMsg((struct Message *)msg);
        }
    }
}

int main(void)
{
  struct Window *w;
  struct DrawInfo *drawinfo;

  if ((IntuitionBase = (struct IntuitionBase *)
          OpenLibrary("intuition.library", MIN_OSLIBVER)))
  {
    if ((GfxBase = (struct GfxBase *)
            OpenLibrary("graphics.library", MIN_OSLIBVER)))
    {
      if ((DiskfontBase = OpenLibrary("diskfont.library", MIN_OSLIBVER)))
      {
        if ((args = ReadArgs(template, opts, NULL)))
        {
          if (opts[OPT_TEXT])
              text = (char *)opts[OPT_TEXT];
          if (opts[OPT_FONT])
              font = (char *)opts[OPT_FONT];
          if (opts[OPT_SIZE])
              size = *((LONG *)opts[OPT_SIZE]);
          if (opts[OPT_XDPI] && opts[OPT_YDPI])
          {
            *(ULONG *)xydpi = ((*(LONG *)opts[OPT_XDPI]) << 16 |
                    (*(ULONG *)opts[OPT_YDPI]));
            SetVar(dpivarname, xydpi, 5,
                    GVF_GLOBAL_ONLY | GVF_BINARY_VAR | GVF_DONT_NULL_TERM);
          }
          else
          {
            opts[OPT_XDPI] = (LONG)&xdpi;
            opts[OPT_YDPI] = (LONG)&ydpi;
            if ((GetVar(dpivarname, xydpi, 5,
                    GVF_GLOBAL_ONLY | GVF_BINARY_VAR | GVF_DONT_NULL_TERM)) != -1)
            {
              if ((*(ULONG *)xydpi & 0xFFFF0000) &&
                      (*(ULONG *)xydpi & 0x0000FFFF))
              {
                xdpi = ((*(ULONG *)xydpi) & 0xFFFF0000) >> 16;
                ydpi = (*(ULONG *)xydpi) & 0x0000FFFF;
              }
            }
          }

          if ((w = openwindow((STRPTR)opts[OPT_VPMODEID],
                  (STRPTR)opts[OPT_BITDEPTH], (STRPTR)opts[OPT_COLORS])))
          {
            struct Screen *screen = w->WScreen;

            SetWindowTitles(w, VERS, VERS);

            if (ModifyIDCMP(w, IDCMP_CLOSEWINDOW))  /* Turn on the Close gadget.  */
            {
              struct TTextAttr ttattr;
              struct TagItem tagitem[2];
              struct TextFont *tfont;

              ttattr.tta_Name = font;
              ttattr.tta_YSize = size;
              ttattr.tta_Style = FSF_TAGGED;
              ttattr.tta_Flags = 0;

              tagitem[0].ti_Tag = TA_DeviceDPI;
              tagitem[0].ti_Data = (*(ULONG *)opts[OPT_XDPI] << 16) |
                      (*(ULONG *)opts[OPT_YDPI]);
              tagitem[1].ti_Tag = TAG_END;
              ttattr.tta_Tags = tagitem;

              if ((tfont = OpenDiskFont((struct TextAttr *)&ttattr)))
              {
                int x, y;

                Printf("Font size: %lu pixels\n", tfont->tf_YSize);
                Printf("Distance from top to baseline: %lu pixels\n",
                        tfont->tf_Baseline);
                Printf("Descender (font size - baseline): %lu pixels\n",
                        tfont->tf_YSize - tfont->tf_Baseline);
                Printf("Descender in percent of the font size: %lu%%\n",
                        (tfont->tf_YSize - tfont->tf_Baseline) * 100 /
                        tfont->tf_YSize);

                SetFont(w->RPort, tfont);
                if ((drawinfo = GetScreenDrawInfo(screen)))
                {
                  SetAPen(w->RPort, drawinfo->dri_Pens[TEXTPEN]);
                  FreeScreenDrawInfo(screen, drawinfo);
                }

                x = w->BorderLeft + 5;
                y = w->BorderTop + 5 + tfont->tf_Baseline;
                Move(w->RPort, x, y);

                Text(w->RPort, text, strlen(text));

                CloseFont(tfont);
              }

              waitclose(w);
            }

            CloseWindow(w);
            CloseScreen(screen);
          }
          FreeArgs(args);
        } 
        CloseLibrary((struct Library *)DiskfontBase);
      }
      CloseLibrary((struct Library *)GfxBase);
    }
    CloseLibrary((struct Library *)IntuitionBase);
  }

  return RETURN_OK;
}
