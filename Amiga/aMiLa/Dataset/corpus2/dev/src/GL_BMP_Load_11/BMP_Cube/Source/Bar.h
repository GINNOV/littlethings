/*  Bar.h
 *  Autor: Norman Walter
 *  Datum: 29.5.2003
 */

#ifndef	BAR_H
#define	BAR_H

#ifndef GRAPHICS_GFX_H
#include <graphics/gfx.h>
#endif

APTR vi = NULL;     // Für VisualInfo

// Die Definition der Struktur Rectangle steht in <graphics/gfx.h>

Rectangle BBox;     // Struktur für die Ecken der BevelBox
Rectangle FillBar;  // Struktur für die Ecken der Füllstandsanzeige

#endif // BAR_H