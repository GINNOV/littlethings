/*
** PROGRAMM:  Stars
** AUTOR:     Michael Weiser
** COPYRIGHT: ©1994 Michael Weiser (Giftware)
** COMPILER:  SAS/C 6.5
**
** MODUL:     Stars.c
**
*/

#include <exec/types.h>
#include <exec/memory.h>
#include <graphics/gfx.h>
#include <graphics/gfxbase.h>
#include <graphics/gfxmacros.h>
#include <intuition/intuition.h>
#include <libraries/mathieeesp.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

/*#define DEBUG*/

#ifdef DEBUG
#include <stdio.h>
#define DEBUG_PRINTF(a) printf(a)
#else
#define DEBUG_PRINTF(a)
#endif

#include <clib/dos_protos.h>
#include <clib/exec_protos.h>
#include <clib/graphics_protos.h>
#include <clib/intuition_protos.h>
#include <clib/mathieeedoubtrans_protos.h>

extern struct Library      *SysBase;
extern struct Library      *DOSBase;
       struct Library      *GfxBase;
       struct Library      *IntuitionBase;
       struct Library      *MathIeeeDoubTransBase;

#define STARNUM 50

       struct {
               UWORD w;
               UWORD x,y;
               BYTE  c;
               float d,g;
              }             Stars[STARNUM];

       double               Cos[360],Sin[360];

void main(void)
{
  if (GfxBase=OpenLibrary("graphics.library",37L))
  {
    DEBUG_PRINTF("gfx.lib opened\n");

    if (IntuitionBase=OpenLibrary("intuition.library",37L))
    {
      DEBUG_PRINTF("intui.lib opened\n");

      if (MathIeeeDoubTransBase=OpenLibrary("mathieeedoubtrans.library",0L))
      {
        struct Screen *s;
        struct ColorSpec cs[9]={
                                {0,0,0,0},
                                {1,2,2,2},
                                {2,4,4,4},
                                {3,6,6,6},
                                {4,8,8,8},
                                {5,10,10,10},
                                {6,12,12,12},
                                {7,14,14,14},
                                {~0,0,0,0}
                               };

        DEBUG_PRINTF("mathieeedoubtrans.lib opened\n");

        if (s=OpenScreenTags(NULL,
                             SA_Width,640,
                             SA_Height,512,
                             SA_Depth,3,
                             SA_Overscan,OSCAN_TEXT,
                             SA_Type,CUSTOMSCREEN,
                             SA_DisplayID,HIRESLACE_KEY,
                             SA_ShowTitle,FALSE,
                             SA_Colors,cs,
                             TAG_DONE))
        {
          struct Window *w;

          DEBUG_PRINTF("s opened\n");

          if (w=OpenWindowTags(NULL,
                               WA_Left,0,
                               WA_Top,0,
                               WA_Width,s->Width,
                               WA_Height,s->Height,
                               WA_Flags,WFLG_RMBTRAP|WFLG_BACKDROP|WFLG_BORDERLESS,
                               WA_IDCMP,IDCMP_MOUSEBUTTONS,
                               WA_CustomScreen,s,
                               TAG_DONE))
          {
            struct IntuiMessage *imsg;
            ULONG i;
            ULONG signalmask=SIGBREAKF_CTRL_C|(1L<<w->UserPort->mp_SigBit);
            ULONG signals;
            LONG  hw=w->Width/2,hh=w->Height/2;
            BOOL  goon=TRUE;

            DEBUG_PRINTF("w opened\n");

            srand(clock());

            for (i=0;i<360;i++)
            {
              Cos[i]=IEEEDPCos((i*PI)/180);
              Sin[i]=IEEEDPSin((i*PI)/180);
            }

            for (i=0;i<STARNUM;i++)
            {
              Stars[i].x=Stars[i].y=0;
              Stars[i].g=rand()%3+1;
              Stars[i].d=rand()%hw;
              Stars[i].w=rand()%359;
              Stars[i].c=rand()%6+1;
            }

            DEBUG_PRINTF("randoms set\n");

            while (goon)
            {
              for (i=0;i<STARNUM;i++)
              {
                SetAPen(w->RPort,0);
                RectFill(w->RPort,Stars[i].x,Stars[i].y,Stars[i].x+(LONG)(Stars[i].g/10),Stars[i].y+(LONG)(Stars[i].g/10));

                if (Stars[i].y>w->Height || Stars[i].y<0 ||
                    Stars[i].x>w->Width  || Stars[i].x<0)
                {
                  Stars[i].d=rand()%hw;
                  Stars[i].w=rand()%359;
                  Stars[i].g=rand()%3+1;
                  Stars[i].c=rand()%6+1;
                }

                Stars[i].d+=++Stars[i].g;
                Stars[i].x=hw+(UWORD)(Stars[i].d*Cos[Stars[i].w]);
                Stars[i].y=hh+(UWORD)(Stars[i].d*Sin[Stars[i].w]);

                SetAPen(w->RPort,Stars[i].c);
                RectFill(w->RPort,Stars[i].x,Stars[i].y,Stars[i].x+(LONG)(Stars[i].g/10),Stars[i].y+(LONG)(Stars[i].g/10));
              }

              signals=SetSignal(0,signalmask);

              if (signals&(1L<<w->UserPort->mp_SigBit))
              {
                while(imsg=(struct IntuiMessage *)GetMsg(w->UserPort))
                {
                  if (imsg->Class==IDCMP_MOUSEBUTTONS) goon=FALSE;

                  ReplyMsg((struct Message *)imsg);
                }
              }
            }

            DEBUG_PRINTF("left main loop\n");

            CloseWindow(w);
            DEBUG_PRINTF("w closed\n");
          }

          CloseScreen(s);
          DEBUG_PRINTF("s closed\n");
        }

        CloseLibrary(MathIeeeDoubTransBase);
        DEBUG_PRINTF("mathieeedoubtrans.lib closed\n");
      }

      CloseLibrary(IntuitionBase);
      DEBUG_PRINTF("intui.lib closed\n");
    }

    CloseLibrary(GfxBase);
    DEBUG_PRINTF("gfx.lib closed\n");
  }
}

/* ======================================================================================= End of File
*/
