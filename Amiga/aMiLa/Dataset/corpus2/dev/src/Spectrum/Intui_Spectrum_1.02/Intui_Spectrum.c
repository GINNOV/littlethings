/*  Intui_Spectrum
 *  Autor: Norman Walter
 *  Version 1.02
 *  Datum: 19.7.2004
 **
 */

#include <exec/types.h>
#include <exec/exec.h>
#include <intuition/intuition.h>
#include <graphics/gfx.h>
#include <dos/dos.h>
#include <math.h>

#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/dos.h>
#include <proto/exec.h>

// Symbolische Konstanten
#define WIDTH 300   // Breite des Fensters
#define HEIGHT 300  // Höhe des Fensters

// Makro für die Umrechnung eines float-Werts
// in eine 32 Bit Farbkomponente
#define FACTOR 0x7FE00000
#define F2COLOR32(f) ((ULONG)(f*FACTOR) << 1L)

struct Window *Fenster;               // Zeiger auf Window-Struktur
struct IntuitionBase *IntuitionBase;  // Zeiger auf IntuitionBase-Struktur
struct GfxBase *GfxBase;              // Zeiger auf GfxBase-Struktur
struct RastPort *rp;                  // Zeiger auf RastPort-Struktur

// Die verschiedenen Pens
LONG red_pen,green_pen,blue_pen,white_pen,rb_pen;

// Struktur für Kurvenparameter
struct curve_parameters
{
   double center;
   double amplitude;
   double sigma;
};

struct curve_parameters red_curve = {650.0,2.0,70.0};
struct curve_parameters green_curve = {550.0,1.5,65.0};
struct curve_parameters blue_curve = {450.0,0.75,60.0};

// Funktionsprototypen
double gauss(double x, double center, double height, double sigma);
void close_all(void);

int main(void)
{
  double wavelength; // in nanometer
  int x;
  double red,green,blue,brightness;

  // Intuition Library öffnen
  IntuitionBase = (struct IntuitionBase *) OpenLibrary("intuition.library",39L);

  if (IntuitionBase == NULL) close_all();

  // Graphics Library öffnen
  GfxBase = (struct GfxBase *) OpenLibrary("graphics.library",39L);

  if (GfxBase == NULL) close_all();

    // Fenster mittels Tags öffnen
    Fenster = OpenWindowTags(NULL,
                             WA_Left, 100,    // Abstand vom linken Rand
                             WA_Top, 100,     // Abstand vom oberen Rand
                             WA_Width, WIDTH,    // Breite
                             WA_Height, HEIGHT,  // Höhe
                             WA_Title, "Intui Spectrum",         // Fenstertitel
                             WA_ScreenTitle, "Intui Spectrum",   // Screen-Titel
                             WA_CloseGadget, TRUE,           // Close-Gadget
                             WA_DragBar, TRUE,               // Ziehleiste
                             WA_DepthGadget, TRUE,           // Depth-Gadget
                             WA_GimmeZeroZero, TRUE,         // Ursprung 0/0
                             WA_IDCMP, IDCMP_CLOSEWINDOW,
                             WA_Activate, TRUE,              // Fenster aktivieren
                             TAG_DONE);

    if (Fenster != NULL)
    {

      rp = Fenster->RPort;

      red_pen = ObtainBestPen(Fenster->WScreen->ViewPort.ColorMap,
                              0xFFFFFFFF,0x00000000,0x00000000,
                              TAG_DONE);

      green_pen = ObtainBestPen(Fenster->WScreen->ViewPort.ColorMap,
                                0x00000000,0xFFFFFFFF,0x00000000,
                                TAG_DONE);

      blue_pen = ObtainBestPen(Fenster->WScreen->ViewPort.ColorMap,
                               0x00000000,0x00000000,0xFFFFFFFF,
                               TAG_DONE);

      white_pen = ObtainBestPen(Fenster->WScreen->ViewPort.ColorMap,
                                0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF,
                                TAG_DONE);

	   SetRast(rp, 1L);   // Fensterinhalt löschen

      /*  Durch das Farbspektrum iterieren:
       *  Wir fangen bei 400nm an und gehen bis 700nm.
       */
      for (x=0; x < 300; x++)
      {
         wavelength = (double)(x+401); // Wellenlänge

         /*  Die Farbkomponenten zur aktuellen Wellenlänge
          *  lassen sich näherungsweise durch die Gauss'sche
          *  Fehlverteilungskurve berechnen.
          */
         red   = gauss(wavelength, red_curve.center, red_curve.amplitude, red_curve.sigma);
         green = gauss(wavelength, green_curve.center, green_curve.amplitude, green_curve.sigma);
         blue  = gauss(wavelength, blue_curve.center, blue_curve.amplitude, blue_curve.sigma);
         brightness = red + green + blue;

         // Passenden Pen finden
         rb_pen = ObtainBestPen(Fenster->WScreen->ViewPort.ColorMap,
                                F2COLOR32(red),
                                F2COLOR32(green),
                                F2COLOR32(blue),
                                OBP_Precision, PRECISION_EXACT,
                                OBP_FailIfBad, FALSE,
                                TAG_DONE, NULL);

         // Spektrallinien zeichnen

         SetAPen(rp,rb_pen);  // Farbe setzen
         Move(rp,x,0);
			Draw(rp,x,20);

         // Den Pen wieder freigeben
			ReleasePen(Fenster->WScreen->ViewPort.ColorMap,rb_pen);

         // Die Kurven für Rot, Grün und Blau zeichnen

         SetAPen(rp,red_pen);
	      WritePixel (rp,x,HEIGHT-(int)(100.0*red));

         SetAPen(rp,green_pen);
	      WritePixel (rp,x,HEIGHT-(int)(100.0*green));

         SetAPen(rp,blue_pen);
	      WritePixel (rp,x,HEIGHT-(int)(100.0*blue));

         SetAPen(rp,white_pen);
	      WritePixel (rp,x,HEIGHT-(int)(100.0*brightness));

      }

      // Auf Close-Gadget warten
      Wait(1L << Fenster->UserPort->mp_SigBit);

      // Die restlichen Pens wieder freigeben
	   ReleasePen(Fenster->WScreen->ViewPort.ColorMap,red_pen);
		ReleasePen(Fenster->WScreen->ViewPort.ColorMap,green_pen);
		ReleasePen(Fenster->WScreen->ViewPort.ColorMap,blue_pen);
		ReleasePen(Fenster->WScreen->ViewPort.ColorMap,white_pen);

      CloseWindow(Fenster);   // Fenster schließen
    } // end if

  close_all();

  return 0;

}

/* Gauss'sche Fehlverteilungskurve */
double gauss(double x, double center, double height, double sigma)
{
  return height * exp(- (x - center) * (x - center) / (2.0 * sigma * sigma));
}

void close_all(void)
{
  // Libraries schließen
  if (GfxBase != NULL) CloseLibrary((struct Library *)GfxBase);
  if (IntuitionBase != NULL) CloseLibrary((struct Library *)IntuitionBase);
}




