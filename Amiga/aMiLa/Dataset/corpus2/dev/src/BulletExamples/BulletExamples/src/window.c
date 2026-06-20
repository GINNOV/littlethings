#include <proto/dos.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <string.h>

struct Window *openwindow(STRPTR vpmodeid, STRPTR bitdepth, STRPTR colors)
{
  struct Screen *wbscreen, *screen;
  struct DrawInfo *drawinfo;
  ULONG wbmodeid, modeid = ~0, depth = 0;
  UWORD pens[] = {(UWORD)~0};
  struct ColorSpec cspecs[3];
  struct Window *w = NULL;

  if ((wbscreen = LockPubScreen("Workbench")))
  {
    drawinfo = GetScreenDrawInfo(wbscreen);
    if ((wbmodeid = GetVPModeID(&(wbscreen->ViewPort))))
    {
      if (vpmodeid && stch_l(vpmodeid, (LONG *)&modeid) != strlen(vpmodeid))
        modeid = ~0;
      if (bitdepth && StrToLong(bitdepth, (LONG *)&depth) <= 0)
        depth = 0;
      cspecs[0].ColorIndex = ~0;
      if (colors && strlen(colors) == 6)
      {
        LONG rgb;
        if (stch_l(colors, (LONG *)&rgb) == strlen(colors))
        {
          cspecs[0].ColorIndex = 0;
          cspecs[0].Red = (rgb & 0xf00000) >> 20;
          cspecs[0].Green = (rgb & 0xf0000) >> 16;
          cspecs[0].Blue = (rgb & 0xf000) >> 12;
          cspecs[1].ColorIndex = 1;
          cspecs[1].Red = (rgb & 0xf00) >> 8;
          cspecs[1].Green = (rgb & 0xf0) >> 4;
          cspecs[1].Blue = rgb & 0x0f;
          cspecs[2].ColorIndex = ~0;
        }
      }
      if ((screen = (struct Screen *)OpenScreenTags(NULL,
              SA_DisplayID,     (modeid != ~0 ? modeid : wbmodeid),
              SA_Depth,         (depth ? depth : wbscreen->RastPort.BitMap->Depth),
              SA_Pens,          pens,
              SA_Colors,        cspecs,
              SA_Title,         "Bullet Example Screen",
              TAG_END)))
      {
        w = OpenWindowTags(NULL,
                WA_Left,          0,
                WA_Top,           screen->BarHeight + 1,
                WA_Width,         screen->Width,
                WA_Height,        screen->Height - screen->BarHeight - 1,
                WA_SmartRefresh,  TRUE,
                WA_SizeGadget,    FALSE,
                WA_CloseGadget,   TRUE,
                WA_IDCMP,         NULL,
                WA_DragBar,       TRUE,
                WA_DepthGadget,   TRUE,
                WA_Activate,      TRUE,
                WA_CustomScreen,  screen,
                TAG_END);
      }
    }
    FreeScreenDrawInfo(wbscreen, drawinfo);
    UnlockPubScreen(NULL, wbscreen);
  }

  return w;
}
