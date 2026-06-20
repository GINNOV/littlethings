#include <exec/types.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/rtg.h>

#include <stdio.h>

char __stdiowin[]="CON://500/400/";

char	*fmtstrings[RGBFB_MaxFormats] = {
	"PLANAR",
	"CHUNKY",
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
			ULONG	used=0, free=0;
			bi=RTGBase->Boards[i];
			printf("********************************************************\n");
			printf("%s (Board Number %ld)\n",bi->BoardName,i);
			printf("********************************************************\n");
			printf("\tMaxMemorySize: %ld, MaxChunkSize: %ld\n", bi->MaxMemorySize, bi->MaxChunkSize);
			printf("--------------------------------------------------------\n");
			printf("BitMapExtras:\n",i);
			for(bme=(struct BitMapExtra *)bi->BitMapList.mlh_Head;bme->BoardNode.mln_Succ;bme=(struct BitMapExtra *)bme->BoardNode.mln_Succ){
				printf("\tBitMapExtra: $%08lx  @: $%08lx ($%08lx)\n",bme,bme->RenderInfo.Memory,bme->BitMap->Planes[1]);
				printf("\t             (%4ld[%5ld]x%4ld %s)\n",bme->Width,bme->RenderInfo.BytesPerRow,bme->Height,fmtstrings[bme->RenderInfo.RGBFormat]);
			}
			printf("SpecialFeature:\n",i);
			for(spec=(struct SpecialFeature *)bi->SpecialFeatures.mlh_Head;spec->Node.mln_Succ;spec=(struct SpecialFeature *)spec->Node.mln_Succ){
				printf("\tSpecialFeature: $%08lx  Type: %s\n",spec,(spec->Type==SFT_FLICKERFIXER) ? "FlickerFixer" : (((spec->Type==SFT_VIDEOCAPTURE) ? "VideoCapture" : ((spec->Type==SFT_VIDEOWINDOW) ? "VideoWindow" : ((spec->Type==SFT_MEMORYWINDOW) ? "MemoryWindow" : "Unknown")))));
			}
			printf("MemoryChunks:\n",i);
			for(mem=(struct GfxMemChunk *)bi->MemList.mlh_Head;mem->Node.mln_Succ;mem=(struct GfxMemChunk *)mem->Node.mln_Succ){
				printf("\tMemory: $%08lx  Size: %7ld %s\n",mem->Ptr,mem->Size,(mem->Used ? "Used" : "Free"));
				if(mem->Used){
					used += mem->Size;
				}else{
					free += mem->Size;
				}
			}
			printf("--------------------------------------------------------\n");
			printf("\tUsed: %7ld  Free: %7ld\n",used,free);
			printf("--------------------------------------------------------\n\n");
		}
//		rtgUnlock(handle);
		CloseLibrary((struct Library *)RTGBase);
	}
}
