/* TextStuff.cpp
 * Routinen für die ausgerichtete Platzierung von Strings
 * Weitere Beschreibung in TextStuff.h
 * Autor: Norman Walter
 * Datum: 5.6.2003
 */

#ifndef TEXTSTUFF_H
#include "TextStuff.h"
#endif

void PlaceText(RastPort *ThisRastPort, char* TextString, Rectangle Area) 
{
  // Länge des Strings "TextString" in Zeichen
  int StringLength = strlen(TextString);

  // Breite in Pixel, die der String einnehmen würde
  // Die Breite hängt vom verwendeten Font ab
  int PixelWidth = TextLength(ThisRastPort,TextString,StringLength);

  int xOffset, yOffset;  // Verschiebung des Textes in x und y Achse

  // Horizontale Ausrichtung des TextString
  switch (align)
  {
    case CENTER:   // Horizontal zentriert
         xOffset = (Area.MinX+Area.MaxX)/2-(PixelWidth/2);
         break;
    case RIGHT:    // Rechtsbündig
         xOffset = Area.MinX+Area.MaxX-PixelWidth-cellpadding;
         break;
    default:       // Default: Linksbündig
         xOffset = Area.MinX+cellpadding;
         break;
  }

  // Vertikale Ausrichtung des TextString
  switch (valign)
  {
    case TOP:      // Oben
         yOffset = Area.MinY+MyTextFont->tf_YSize+cellpadding;
         break;
    case MIDDLE:   // Mittig
         yOffset = Area.MinY+(Area.MaxY/2)+((MyTextFont->tf_YSize/2)-(MyTextFont->tf_YSize-MyTextFont->tf_Baseline));    
         break;
    default:       // Default: Unten
         yOffset = Area.MinY+Area.MaxY-(MyTextFont->tf_YSize-MyTextFont->tf_Baseline)-cellpadding;
         break;
  }

  Move(ThisRastPort, xOffset, yOffset);
  Text(ThisRastPort, TextString, StringLength);

}