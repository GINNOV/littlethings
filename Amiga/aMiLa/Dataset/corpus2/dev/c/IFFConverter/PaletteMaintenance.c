/*
**     $VER: PaletteMaintenance.c V0.01 (21-06-95)
**
**     Author:  Gerben Venekamp
**     Updates: 21-06-95  Version 0.02     Intial module
**
**  PaletteMaintenanace.c cointains function to control and maintain
**  palettes.
**
*/


#include <exec/memory.h>
#include <graphics/view.h>
#include <intuition/screens.h>
#include <proto/dos.h>
#include <proto/graphics.h>

#include "IFFConverter.h"


// Defining protos

void FadeColours(enum Fade, UWORD, struct Screen*);
BOOL GetNewColourMap(UBYTE *, UWORD);


/*
**  Result = GetNewColourMap(CMapData, PaletteDepth)
**
**     GetNewColourMap makes from 'CMapData' a colour palette, which
**     can be used by 'LoadRGB32.
**
**  pre:  CMapData - Pointer to a ILBM CMAP Chunk.
**        PaletteDepth - Depth of palette. (in planes).
**  post: Result - TRUE if a new colour paltte could be generated,
**                 FALSE if generaion failed.
**
*/
BOOL GetNewColourMap(UBYTE *CMapData, UWORD PaletteDepth)
{
   UWORD i;
   UWORD NumberOfColours = 1<<PaletteDepth;
   UBYTE TColourComponent;
   
   FreeThisMem(&ColourMap,  ColourMapSize);
   FreeThisMem(&SColourMap, ColourMapSize);
   
   ColourMapSize = (NumberOfColours*3*4)+4;
   
   if( AllocThisMem(&ColourMap, ColourMapSize, MEMF_CLEAR) )
   {
      if( AllocThisMem(&SColourMap, ColourMapSize, MEMF_CLEAR) )
      {
         register UBYTE *TColourMap = (UBYTE *)ColourMap;
         register UBYTE *TCMapData = CMapData;
         
         // For a bit of efficiency: First word is the number of colours
         // in your colourmap. Second word is the first colour to use.
         // (See Autodocs3:Graphics/LoadRGB32 for more information)
         // Anyway, Shifting the 'NumberOfColours' 16 times to the left,
         // makes a longword with the lower 16 bit cleared. In other words,
         // this long says the number of colour to use and that the first
         // colour is colour 0. This could be done in two words, now it's
         // done in one longword.
         *(ULONG *)TColourMap = (ULONG) NumberOfColours<<16;
         TColourMap += 4;
         
         for(i = 0; i < NumberOfColours; i++)
         {            
            // Make RED component            
            TColourComponent = *TCMapData++;
            *TColourMap++ = TColourComponent;
            *TColourMap++ = TColourComponent;
            *TColourMap++ = TColourComponent;
            *TColourMap++ = TColourComponent;
            
            // Make GREEN component
            TColourComponent = *TCMapData++;
            *TColourMap++ = TColourComponent;
            *TColourMap++ = TColourComponent;
            *TColourMap++ = TColourComponent;
            *TColourMap++ = TColourComponent;
            
            // Make BLUE component
            TColourComponent = *TCMapData++;
            *TColourMap++ = TColourComponent;
            *TColourMap++ = TColourComponent;
            *TColourMap++ = TColourComponent;
            *TColourMap++ = TColourComponent;
         }
      }
      else
      {
         // Not enough memory for 'SColourMap'
         ErrorHandler( IFFerror_NoMemoryDoReturn, (APTR)ColourMapSize );
         return(FALSE);
      }      
   }
   else
   {
      // Not enough memory for 'ColourMap'
      ErrorHandler( IFFerror_NoMemoryDoReturn, (APTR)ColourMapSize );
      return(FALSE);
   }
   return(TRUE);
}


/*
**  FadeColours(FadeType, Steps, ScreenToFade)
**
**     will fade the colours to the desired values.
**
**  pre:  FadeType - If FADE_UP,   colours will be faded to the desired values.
**                   If FADE_DOWN, colours will be faded to the background colour.
**        Steps - Number of steps to complete the fade process.
**        ScreenToFade - Which screen to fade the colours
**  post: None
**
*/
void FadeColours(enum Fade FadeType, UWORD Steps, struct Screen * ScreenToFade)
{
   UWORD NumberOfColours = 1<<(ScreenToFade->ViewPort.RasInfo->BitMap->Depth);
   struct ViewPort *ScreenViewPort = &(ScreenToFade->ViewPort);
   WORD i, j;
   
   switch(FadeType)
   {
      case FADE_UP:
         for(i=0; i<Steps; i++)
         {
            ULONG *col  = (ULONG*) ColourMap+1;   // Skip first two words *ONE LONG!* (Number of Colours, First Colour).
            ULONG *scol = (ULONG*)SColourMap+1;   // Skip first two words *ONE LONG!* (Number of Colours, First Colour).

            for(j=0; j<NumberOfColours; j++)
            {
               *col++ = *scol++;   // Do Red   Component
               *col++ = *scol++;   // Do Green Component
               *col++ = *scol++;   // Do Blue  Component
            }
            
            LoadRGB32(ScreenViewPort, ColourMap);
            Delay(0);
         }
         break;
      case FADE_DOWN:
         for(i=Steps; i>0; i--)
         {
            ULONG *col  = (ULONG*) ColourMap;
            ULONG *scol = (ULONG*)SColourMap;
            ULONG DestColour;
            
            *scol++ = *col++;

            for(j=0; j<NumberOfColours; j++)
            {
               *scol++ = ((*col++)/Steps)*i;   // Do Red   Component
               *scol++ = ((*col++)/Steps)*i;   // Do Green Component
               *scol++ = ((*col++)/Steps)*i;   // Do Blue  Component
            }
            
            LoadRGB32(ScreenViewPort, SColourMap);
            Delay(0);
         }
         break;
   }
}
