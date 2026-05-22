;/* MeasureText - Execute me to compile me with Lattice 5.10a
LC -b0 -cfistq -v -y -j73 MeasureText.c
Blink FROM LIB:c.o, MeasureText.o TO MeasureText LIBRARY LIB:LC.lib,LIB:Amiga.lib
quit
*/

#define INTUITION_IOBSOLETE_H
#include <dos/dos.h>
#include <dos/dosextens.h>
#include <graphics/text.h>
#include <graphics/rastport.h>
#include <intuition/intuition.h>
#include <exec/libraries.h>
#include <clib/alib_stdio_protos.h>
#include <clib/graphics_protos.h>
#include <clib/intuition_protos.h>
#include <clib/diskfont_protos.h>
#include <clib/dos_protos.h>
#include <clib/exec_protos.h>
#include <clib/asl_protos.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }
#endif

#define BUFSIZE 32768

UBYTE *vers = "\0$VER: MeasureText 37.1";

UBYTE buffer[BUFSIZE];

void MainLoop(void);
void EOP(void);

struct Library *IntuitionBase;
struct Library *GfxBase;
struct Library *DiskfontBase;
struct Library *AslBase;

BPTR myfile;
UWORD wtbarheight;
struct FontRequester *fr;
struct TextFont *myfont;
struct Window *w;
struct RastPort *myrp;
struct Task *mytask;

void main(int argc, char **argv)
{
  struct TextAttr myta;
  extern struct Library *DOSBase;

  if (DOSBase->lib_Version >35)  /* Run only on 2.0 machines */
  {
    if (argc == 2)
    {
      if (myfile = Open(argv[1], MODE_OLDFILE))                     /* Open the file to print out. */
      {
        if (DiskfontBase = OpenLibrary("diskfont.library", 37L))            /* Open the libraries. */
        {
          if (IntuitionBase = OpenLibrary("intuition.library", 37L))
          {
            if (GfxBase = OpenLibrary("graphics.library", 37L))
            {
              if (AslBase = OpenLibrary("asl.library", 37L))
              {
                if (fr = (struct FontRequester *)                    /* Open an ASL font requester */
                         AllocAslRequestTags(ASL_FontRequest,
                                      /* Supply initial values for requester */
                                      ASL_FontName, (ULONG)"topaz.font",
                                      ASL_FontHeight, 11L,
                                      ASL_FontStyles, FSF_BOLD | FSF_ITALIC,
                                      ASL_FrontPen,  0x01L,
                                      ASL_BackPen,   0x00L,

                                       /* Give us all the gadgetry */
                                      ASL_FuncFlags, FONF_FRONTCOLOR | FONF_BACKCOLOR |
                                                     FONF_DRAWMODE | FONF_STYLES,
                                      TAG_DONE))
                {
                  /* Pop up the requester */
                  if (AslRequest(fr, 0L))
                  {
                    myta.ta_Name       = fr->fo_Attr.ta_Name;              /* extract the font and */
                    myta.ta_YSize      = fr->fo_Attr.ta_YSize;             /* display attributes   */
                    myta.ta_Style      = fr->fo_Attr.ta_Style;             /* from the FontRequest */
                    myta.ta_Flags      = fr->fo_Attr.ta_Flags;             /* structure.           */

                    if (myfont = OpenDiskFont(&myta))
                    {
                      if (w = OpenWindowTags(NULL,WA_SizeGadget,  TRUE,
                                                  WA_MinWidth,    200,
                                                  WA_MinHeight,   200,
                                                  WA_DragBar,     TRUE,
                                                  WA_DepthGadget, TRUE,
                                                  WA_Title,       (ULONG)argv[1],
                                                  TAG_DONE))
                      {
                        myrp = w->RPort;
                                 /* figure out where the baseline of the uppermost line should be. */
                        wtbarheight = w->WScreen->BarHeight + myfont->tf_Baseline + 2;

                            /* Set the font and add software styling to the text if I asked for it */
                            /* in OpenFont() and didn't get it.  Because most Amiga fonts do not   */
                            /* have styling built into them (with the exception of the CG outline  */
                            /* fonts), if the user selected some kind of styling for the text, it  */
                            /* will to be added algorithmically by calling SetSoftStyle().         */

                        SetFont(myrp, myfont);
                        SetSoftStyle(myrp,   myta.ta_Style ^ myfont->tf_Style,
                                      (FSF_BOLD | FSF_UNDERLINED | FSF_ITALIC));
                        SetDrMd(myrp, fr->fo_DrawMode);
                        SetAPen(myrp, fr->fo_FrontPen);
                        SetBPen(myrp, fr->fo_BackPen);
                        Move(myrp, w->WScreen->WBorLeft, wtbarheight);
                        mytask = FindTask(NULL);

                        MainLoop();

                        Delay(25);                         /* short delay to give user a chance to */
                        CloseWindow(w);                   /* see the text before it goes away.    */
                      }
                      CloseFont(myfont);
                    }
                  }
                  else
                    VPrintf("Request Cancelled\n", NULL);
                  FreeAslRequest(fr);
                }
                CloseLibrary(AslBase);
              }
              CloseLibrary(GfxBase);
            }
            CloseLibrary(IntuitionBase);
          }
          CloseLibrary(DiskfontBase);
        }
        Close(myfile);
      }
    }
    else
      VPrintf("template: MeasureText <file name>\n", NULL);
  }

}







void MainLoop(void)
{
  struct TextExtent resulttextent;
  LONG fit, actual, count, printable, crrts;
  BOOL aok = TRUE;

  while (((actual = Read(myfile, buffer, BUFSIZE)) > 0) && aok)    /* while there's something to */
  {                                                                /* read, fill the buffer.     */
    count = 0;

    while(count < actual)
    {
      crrts = 0;

      while ( ((buffer[count] < myfont->tf_LoChar) ||      /* skip non-printable characters, but */
               (buffer[count] > myfont->tf_HiChar)) &&     /* account for newline characters.    */
               (count < actual) )
      {
        if (buffer[count] == '\012') crrts++;   /* is this character a newline?  if it is, bump */
        count++;                                 /* up the newline count.                        */
      }

      if (crrts > 0)                    /* if there where any newlines, be sure to display them. */
      {
        Move(myrp, w->BorderLeft, myrp->cp_y + (crrts * (myfont->tf_YSize + 1)));
        EOP();                                            /* did we go past the end of the page? */
      }

      printable = count;
      while ( (buffer[printable] >= myfont->tf_LoChar) &&        /* find the next non-printables */
              (buffer[printable] <= myfont->tf_HiChar) &&
              (printable < actual) )
      {
        printable++;
      }                                    /* print the string of printable characters wrapping  */
      while (count < printable)            /* lines to the beginning of the next line as needed. */
      {
                                       /* how many characters in the current string of printable */
        fit = TextFit(  myrp,                &(buffer[count]),/* characters will fit between the */
                        (printable - count), &resulttextent,  /* rastport's current X position   */
                        NULL,                1,               /* and the edge of the window?     */
                        (w->Width  - (myrp->cp_x + w->BorderLeft + w->BorderRight)),
                                             myfont->tf_YSize + 1  );
        if ( fit == 0 )
        {
          Move(myrp, w->BorderLeft, myrp->cp_y + myfont->tf_YSize + 1); /* nothing else fits on  */
        }                                           /* this line, need to wrap to the next line. */
        else
        {
           Text(myrp, &(buffer[count]), fit);
           count += fit;
        }
        EOP();
      }

      if (mytask->tc_SigRecvd & SIGBREAKF_CTRL_C)          /* did the user hit CTRL-C (the shell */
      {                                                    /* window has to receive the CTRL-C)? */
        aok = FALSE;
        VPrintf("Ctrl-C Break\n", NULL);
        count = BUFSIZE + 1;
      }
    }
  }
  if (actual < 0)
    VPrintf("Error while reading\n", NULL);
}










void EOP(void)
{
    if (myrp->cp_y > (w->Height - (w->BorderBottom + 2))) /* If we reached page bottom, clear the */
    {                                                     /* rastport and move back to the top.   */
        Delay(25);

        SetAPen(myrp, 0);
        RectFill(myrp, (LONG)w->BorderLeft, (LONG)w->BorderTop, w->Width - (w->BorderRight + 1),
                 w->Height - (w->BorderBottom + 1) );
        SetAPen(myrp, 1);
        Move(myrp, w->BorderLeft + 1, wtbarheight);
        SetAPen(myrp, fr->fo_FrontPen);
    }
}