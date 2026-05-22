/* TextStuff.h
 * Routinen für die ausgerichtete Platzierung von Strings
 * Autor: Norman Walter
 * Datum: 5.6.2003
 */

#ifndef	TEXTSTUFF_H
#define	TEXTSTUFF_H

#ifndef GRAPHICS_GFX_H
#include <graphics/gfx.h>
#endif

// enum-Listen für horizontale und vertikale Ausrichtung des Textes
// bezüglich eines rechteckigen Rahmens
enum align_keyword { RIGHT, CENTER, LEFT};  // Mögliche Schlüsselwörter für align
enum valign_keyword { TOP, MIDDLE, BOTTOM}; // Mögliche Schlüsselwörter für valign

// align und valign sind globale Variablen
align_keyword align = LEFT;     // Default-Wert setzen : Linksbündig
valign_keyword valign = BOTTOM; // Defaust-Wert setzen : Unten

// Zusätzlicher horizontaler Abstand des Textes vom Rand des Rahmens
int cellpadding = 0;  // Default: Kein zusätzlicher Abstand

// Zeiger auf TextFont Struktur
struct TextFont *MyTextFont = NULL;

// Funktionsprototypen:

/* PlaceText - Platzliert einen String innerhalb eines Rechtecks
 *
 * Parameter: 
 *
 * ThisRastPort - Der RastPort, auf den der Text platzliert werden soll.
 * TextString   - Der Text
 * Area         - Ein rechteckiger Bereich, anhand dessen der Text ausgerichtet wird.
 *
 * Hinweis: Die Komponenten von Area sind wie folgt aufgebaut:
 *          MinX , MinY : Linke, ober Ecke
 *          MaxX        : Breite des Rechtecks
 *          MaxY        : Höhe des Rechtecks
 */

void PlaceText(RastPort ThisRastPort, char* TextString, Rectangle Area);

#endif