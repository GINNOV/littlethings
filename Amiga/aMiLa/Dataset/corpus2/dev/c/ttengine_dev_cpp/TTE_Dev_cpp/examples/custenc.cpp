/*
	This file is copyright by Grzegorz Krashewski, changed by Tomasz
    Kaczanowski. You can use it for free, but you must add info about
    using this code and info about author. Remember also, that if you
    want to have new versions of this code and other codes for
    AmigaOS-like systems you should motivate author of this code. You
    can send him a small gift or mail or bug report.

    contact:
       kaczus (at) poczta (_) onet (_) pl
       or
       kaczus (at) wp (_) pl
    (_) replaced dot.
    Don't forget also about Krashan!!! - author of ttengine!
*/

/* test ttengine - custom 8-bit encoding */



#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/ttengine.hpp>
#include <proto/asl.h>

#include <cstring>
#include <string>
//#include <cstdio>
using namespace std;


struct Library   *AslBase;
struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;

UWORD CustomEncodingTable[256];

/*----------------------------------------------------------------------------*/

static std::string get_font_name()
{
    struct FileRequester *freq;
    std::string name = "";
    Tag t[]={ASLFR_TitleText, (ULONG)"Select TrueType font",
          ASLFR_InitialDrawer, (ULONG)"FONTS:",
          ASLFR_DoPatterns, TRUE,
          ASLFR_InitialPattern, (ULONG)"#?.ttf",
          ASLFR_RejectIcons, TRUE,TAG_END};
    if (freq = (struct FileRequester *)AllocAslRequestTags(ASL_FileRequest, TAG_END))
    {
        if (AslRequest(freq,(TagItem *)t))
        {
            name= std::string(freq->fr_Drawer)+string("/")+freq->fr_File;
        }
        FreeAslRequest(freq);
    }
    return name;
  }

/*----------------------------------------------------------------------------*/


VOID fill_table(UWORD *table)
{
    WORD i;

    for (i = 0; i < 256; i++)
    {
        CustomEncodingTable[i] = i ^ 0x0015;
    }
    //return;
}

/*----------------------------------------------------------------------------*/
TTEngine *TTEngine::Base=NULL;

int main ()
{
	struct Window *win;
    std::string fontname;
    APTR font;
    TTEngine TTE;      //it opens library for local use
    if (GfxBase = (struct GfxBase *)OpenLibrary("graphics.library", 39))
    {
        if (IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library", 39))
        {
            if (AslBase = OpenLibrary("asl.library", 38))
            {
                fontname = get_font_name();
                if (fontname.length()>0)
                {
                     // TTEngine::Base=new TTEngine();  <- it is necessary only,
                     //           when You want call global method from ttengine
                    {
                        fill_table(CustomEncodingTable);
                        if (win = OpenWindowTags(NULL,
                                                    WA_Top, 25,
                                                    WA_Left, 0,
                                                    WA_Width, 640,
                                                    WA_Height, 210,
                                                    WA_CloseGadget, TRUE,
                                                    WA_DragBar, TRUE,
                                                    WA_DepthGadget, TRUE,
                                                    WA_IDCMP, IDCMP_CLOSEWINDOW,
                                                    WA_Title, (ULONG)"Custom encoding test",
                                                    TAG_END))
                        {
                            ULONG sigmask, signals;
                            BOOL running = TRUE;
                            struct RastPort *rp = win->RPort;
                            if (font = TTE.TT_OpenFont( TT_FontFile, (ULONG)(fontname.c_str()),
                                                        TT_FontSize, 18,
                                                        TAG_END))
                              
							{
                                if (TTE.TT_SetFont(rp, font))
                                {
                                    TTE.TT_SetAttrs(rp,TT_Window, (ULONG)win,
                                                      	TT_Antialias, TT_Antialias_On,
                                                      	TT_Encoding, TT_Encoding_ISO8859_1,
                                                    	TAG_END);
                                    SetDrMd(rp, JAM1);
                                    SetAPen(rp, 1);

                                    /* alphabet in ISO-8859-1 */

                                    Move (rp, 10, 40);
                                    TTE.TT_Text (rp, "ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz", 53);
                                    /* turn our weird encoding on, also set some Unicode encoding */
                                    /* just to check if custom overrides it as it should */

                                    TTE.TT_SetAttrs(rp,
                                              	TT_CustomEncoding, (ULONG)CustomEncodingTable,
                                              	TT_Encoding, TT_Encoding_UTF32_BE,              /* will be overriden */
                                            	TAG_END);
                                    Move (rp, 10, 58);
                                    TTE.TT_Text (rp, "ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz", 54);
                                }
                                else
                                	PutStr("TT_SetFont() failed.\n");
                                TTE.TT_CloseFont(font);
                            }
                            else
                            	PutStr("Font open failed.\n");
                            sigmask = SIGBREAKF_CTRL_C | (1 << win->UserPort->mp_SigBit);
                            while (running)
                            {
                                signals = Wait(sigmask);
                                if (signals & SIGBREAKF_CTRL_C)
                                	running = FALSE;
                                if (signals & (1 << win->UserPort->mp_SigBit))
                                {
                                    struct IntuiMessage *imsg;

                                    while (imsg = (struct IntuiMessage*)GetMsg(win->UserPort))
                                    {
                                        if (imsg->Class == IDCMP_CLOSEWINDOW) running = FALSE;
                                        ReplyMsg((struct Message*)imsg);
                                    }
                                }
                            }
                            TTE.TT_DoneRastPort(win->RPort);
                            CloseWindow(win);
                        }
                        //delete TTEngine::Base; It is necessary only when you open ttengine for global method
                    }
                }
                CloseLibrary(AslBase);
            }
            CloseLibrary((struct Library *)IntuitionBase);
        }
        CloseLibrary((struct Library *)GfxBase);
    }
    return 0;
}
