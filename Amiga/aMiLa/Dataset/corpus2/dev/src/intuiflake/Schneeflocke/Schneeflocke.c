/*  Kochsche Schneeflocke
 *  Norman Walter 25.12.2001
 *  Demonstriert rekursive Algorithmen
 *  und die Verwendung der Amiga Grafik-Primitiven
 */

#include <exec/types.h>
#include <intuition/intuition.h>
#include <graphics/gfx.h>
#include <math.h>

struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;
struct Screen *Screen;
struct Window *Window;
struct RastPort *rp;

#include "stdwindow.h"  /* Eigenes Include-Flie */

void draw_lines(float X0, float Y0, float X1, float Y1)
{

  float AX = X0;
  float AY = Y0;

  float BX = (2.0*X0+X1)/3.0;
  float BY = (2.0*Y0+Y1)/3.0;

  float CX = (X0+X1)/2.0 - sqrt(3.0)/6.0*(Y1-Y0);
  float CY = (Y0+Y1)/2.0 + sqrt(3.0)/6.0*(X1-X0);

  float DX = (X0+2.0*X1)/3.0;
  float DY = (Y0+2.0*Y1)/3.0;

  float EX = X1;
  float EY = Y1;


  /* Es werden nur Linien der Länge < 4 gezeichnet */
  if (pow(X0-X1,2)+pow(Y0-Y1,2)<4.0)
  {
      /* Amiga Grafik-Primitiven aus dem ROM */
		Move(rp, int(X0),int(Y0));  // Cursor bewegen
		Draw(rp, int(X1),int(Y1));  // Linie ziehen
  }

  else

  {
    /* Rekursive Funktionsaufrufe */
    draw_lines(AX,AY,BX,BY); // Linie von a nach b
    draw_lines(BX,BY,CX,CY); // Linie von b nach c
    draw_lines(CX,CY,DX,DY); // Linie von c nach d
    draw_lines(DX,DY,EX,EY); // Linie von d nach e
  }

}

void main(void)
	{

	   /* Koordinaten für drei Punkte */

      float P1X = 100.0;
      float P1Y = 100.0;

      float P2X = 200;
      float P2Y = 150*sqrt(3.0);

      float P3X = 300.0;
      float P3Y = 100.0;

		open_libs(); /* Librarys öffnen */

		Window = (struct Window *) open_window(
				  20,20,400,300," Schneeflocke ",
				  WINDOWCLOSE | WINDOWDRAG | WINDOWDEPTH | ACTIVATE | GIMMEZEROZERO,
				  CLOSEWINDOW, NULL);

		/* GIMMEZEROZERO verhindert, daß SystemGadgets übermalt werden */

		if (Window == NULL) exit(FALSE);

		rp = Window->RPort;

		/* Fensterinhalt übermalen */
		SetAPen(rp, 1L);
		RectFill(rp,0,0,400,300);

      /* Hier wird die Funktion draw_lines aufgerufen */
      /* Eingabefolge : X0, Y0, X1, Y1                */

      /* Wir zeichnen ein gleichseitiges Dreieck */

      SetAPen(rp, 2L);  // Farbe setzen

      draw_lines(P1X,P1Y,P2X,P2Y);
      draw_lines(P2X,P2Y,P3X,P3Y);
      draw_lines(P3X,P3Y,P1X,P1Y);

		/* Warte auf Mausklick in Close-Gadget */
		Wait(1L<< Window->UserPort->mp_SigBit);
		close_all(); /* Alles schließen */
	}
