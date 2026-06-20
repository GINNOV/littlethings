/* CC65's tiny graphic interface API */
/* 030/25: */
/* s 37.86 */
/* i 24.86 */
/* f 19.28 */
/* 8 12.12 */

#ifndef _TGI_H
#define _TGI_H

#ifndef __SASC
#include <proto/exec.h>
struct GfxBase *GfxBase;
struct IntuitionBase *IntuitionBase;
#endif
#include <proto/graphics.h>
#include <proto/intuition.h>

const TGI_MODE_160_200_4;

struct Window *window;
struct RastPort *rp;

void tgi_load(int mode)
{
#ifndef __SASC
GfxBase=(struct GfxBase *)OldOpenLibrary("graphics.library");
IntuitionBase=(struct IntuitionBase *)OldOpenLibrary("intuition.library");
#endif
}

void tgi_init(void)
{
static struct NewWindow mywindow={0, 0, 160, 200, 0, 1, CLOSEWINDOW, WINDOWDRAG|ACTIVATE,
NULL, NULL, "Apfelberge    ", NULL, NULL, 0, 0, 0, 0, WBENCHSCREEN};
#ifdef __JOYSTICK__
extern p;

mywindow.Title[11]='(';
mywindow.Title[12]='0'+p;
mywindow.Title[13]=')';
#endif
window=OpenWindow(&mywindow);
rp=window->RPort;
}

__inline void tgi_clear(void)
{
ClearScreen(rp);
}

const palette[]={0, 2, 3, 1};

__inline void tgi_setcolor(int color)
{
SetAPen(rp, palette[color]);
}

__inline void tgi_line(int u, int v, int u1, int v1)
{
Move(rp, u, v);
Draw(rp, u1, v1);
}

void tgi_unload(void)
{
CloseWindow(window);
#ifndef __SASC
CloseLibrary((struct Library *) IntuitionBase);
CloseLibrary((struct Library *) GfxBase);
#endif
}

#endif
