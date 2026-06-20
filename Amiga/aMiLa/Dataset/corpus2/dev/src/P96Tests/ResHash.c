#include <exec/types.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/rtg.h>

#include <stdio.h>

char __stdiowin[]="CON://500/400/";

char	*fmtstrings[RGBFB_MaxFormats] = {
	"NONE",
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
	"B5G5R5PC",
	"YUV422",
	"YUV411"
};

int main(int argc, char **argv)
{
	struct RTGBase *RTGBase;

	if(RTGBase=(struct RTGBase *)OpenLibrary("picasso96/rtg.library",40)){
		struct BoardInfo *bi;
		int i;
		struct BitMapExtra *bme;
		struct SpecialFeature *spec;
		struct GfxMemChunk *mem;
//		ULONG handle;

//		handle = rtgLock(TRUE);
		for(i=0;i<RTGBase->BoardCount;i++){
			printf("%ld %08lx %08lx\n",i, (0xfff01000 | (i<<16)), rtgLookUpResolution(0xfff01000 | (i<<16)));
		}
//		rtgUnlock(handle);
		CloseLibrary((struct Library *)RTGBase);
	}
}
