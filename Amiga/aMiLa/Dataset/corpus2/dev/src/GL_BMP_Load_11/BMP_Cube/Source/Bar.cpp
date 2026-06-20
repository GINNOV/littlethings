/*  Bar.cpp
 *  Autor: Norman Walter
 *  Datum: 1.6.2003
 */

#ifndef BAR_H
#include "Bar.h"
#endif

/* Funktion zeichnet Fortschrittsanzeige
 * Parameter: struct RastPort *rp   : Der RastPort, auf den gezeichnet werden soll.
 *            int xpos, int ypos    : Linke, obere Ecke der Füllstandsanzeige
 *            int width, int height : Breite und Höhe
 *            int percent           : Füllstand in Prozent
 */
void draw_progressbar(struct RastPort *rp, int xpos, int ypos, int width, int height, int percent)
{
      int filled = 0;

      // Füllstand berechnen
      filled = (int)(percent/100.0*width);

      // Größe der Bevel Box festlegen
      BBox.MinX = xpos;    // X Komponente der linken, oberen Ecke
      BBox.MinY = ypos;    // Y Komponente der linken, oberen Ecke
      BBox.MaxX = width;   // Breite
      BBox.MaxY = height;  // Höhe

      // BevelBox zeichnen
      DrawBevelBox( rp,
                    xpos,
                    ypos,
                    width,
                    height,
                    GT_VisualInfo, vi,
                    GTBB_Recessed, TRUE,
                    TAG_DONE );

      // Größe des Füllbalkens
      FillBar.MinX = BBox.MinX + 2;               // X Komponente der linken, oberen Ecke
      FillBar.MinY = BBox.MinY + 1;               // Y Komponente der linken, oberen Ecke
      FillBar.MaxX = BBox.MinX + filled - 3;      // Breite
      FillBar.MaxY = BBox.MinY + BBox.MaxY - 2;   // Höhe

      // Hintergrund zeichnen - damit wird der Text überschrieben
      SetAPen(rp, 0L);
      RectFill(rp,
              FillBar.MinX,
              FillBar.MinY,
              BBox.MaxX - 2,
              FillBar.MaxY);


      // Füllbalken zeichnen
      SetAPen(rp, 3L);
      RectFill(rp,
              FillBar.MinX,
              FillBar.MinY,
              FillBar.MaxX,
              FillBar.MaxY);

}

