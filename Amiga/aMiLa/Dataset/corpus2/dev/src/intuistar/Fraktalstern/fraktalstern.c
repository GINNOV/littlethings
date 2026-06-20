/*  Fraktalstern
 *  Norman Walter 26.12.2001
 *  Demonstriert rekursive Algorithmen
 *  und die Verwendung der Amiga Grafik-Primitiven
 */

#include <exec/types.h>
#include <intuition/intuition.h>
#include <graphics/gfx.h>

struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;
struct Screen *Screen;
struct Window *Window;
struct RastPort *rp;

#include "stdwindow.h"  /* Eigenes Include-Flie */

void box(int x, int y, int r)

{
   /* Zeichnet ein Quadrat mit Radius r an den Koordinaten x,y */
   /* Es werden die Grafik-Primitiven aus dem ROM verwendet    */

   RectFill(rp,x-r,y-r,x+r,y+r);  // Rechteck zeichnen

}

void star( int x, int y, int r)

   /* Zeichnet Fraktalstern durch rekursive Funktionsaufrufe */

{
    if (r>0)
        {
            star(x-r,y+r,r/2);
            star(x+r,y+r,r/2);
            star(x-r,y-r,r/2);
            star(x+r,y-r,r/2);
            box(x,y,r);
        }

}


void main(void)
	{

		open_libs(); /* Librarys öffnen */

		Window = (struct Window *) open_window(
				  20,20,400,300," Fraktalstern ",
				  WINDOWCLOSE | WINDOWDRAG | WINDOWDEPTH | ACTIVATE | GIMMEZEROZERO,
				  CLOSEWINDOW, NULL);

		/* GIMMEZEROZERO verhindert, daß SystemGadgets übermalt werden */

		if (Window == NULL) exit(FALSE);

		rp = Window->RPort;

		/* Fensterinhalt übermalen */
		SetAPen(rp, 1L);
		RectFill(rp,0,0,400,300);

      SetAPen(rp, 2L);  // Farbe setzen

		/* Fraktalstern zeichnen */
      star(200,150,80);

		/* Warte auf Mausklick in Close-Gadget */
		Wait(1L<< Window->UserPort->mp_SigBit);
		close_all(); /* Alles schließen */
	}
