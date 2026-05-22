#include <intuition/screens.h>
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/layers.h>
#include <proto/dos.h>
#include <proto/rtg.h>
#include "/PrivateInclude/rtgBase.h"
#include "/PrivateInclude/boardinfo.h"
#include "/publicinclude/libraries/Picasso96.h"

static const char *FormatNames[] = {
			"Planar",
			"CLUT",
			"R8G8B8",
			"B8G8R8",
			"R5G6B5PC",
			"R5G5B5PC",
			"A8R8G8B8",
			"A8B8G8R8",
			"R8G8B8A8",
			"B8G8R8A8",
			"R5G6B5",
			"R5G5B5",
			"B5G6R5PC",
			"B5G5R5PC"
};			

int main(void)
{
  struct RTGBase *RTGBase;
  
  if(RTGBase=(struct RTGBase *)OpenLibrary("picasso96/rtg.library",40)){
    struct BoardInfo *bi;
    int i;
    for(i = 0;i < MaxNrOfBoards;i++) {
      RGBFTYPE rgb,comp;
      bi = RTGBase->Boards[i];
      if (bi) {
	Printf("Information for board %s\n",bi->BoardName);
	for(rgb = RGBFB_NONE;rgb <= RGBFB_B5G5R5PC;rgb++) {
	  if ((1 << rgb) & (bi->RGBFormats)) {
	    Printf("Formats compatible to format %s:\n",FormatNames[rgb]);
	    for(comp = RGBFB_NONE;comp <= RGBFB_B5G5R5PC;comp++) {
	      if ((1 << comp) & (bi->GetCompatibleFormats(bi,rgb))) {
		Printf("\t%s\n",FormatNames[comp]);
	      }
	    }
	    Printf("\n");
	  }
	}
	Printf("\n");
      }
    }
    CloseLibrary((struct Library *)RTGBase);
  }

  return 0;
}
	    
