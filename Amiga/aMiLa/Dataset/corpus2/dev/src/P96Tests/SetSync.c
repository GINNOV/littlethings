#include <exec/types.h>

#include <proto/rtg.h>
#include <proto/exec.h>
#include <proto/dos.h>

char template[] = "SYNC/N";

LONG main(int argc,char **argv)
{
	struct RDArgs *rda;
	LONG array[1];
	LONG val = 0;
	
	array[0] = 0;
	if(rda = ReadArgs(template, array, NULL)){
	  if (array[0]) 
	    val  = *(LONG *)(array[0]);
	  FreeArgs(rda);
	}

	if(array[0] && FindName(&SysBase->LibList, "rtg.library")){
	  struct RTGBase *RTGBase=(struct RTGBase *)OpenLibrary("picasso96/rtg.library",40);
	  int i;
	  if(RTGBase){
	    for(i=0;i<RTGBase->BoardCount;i++){
	      struct BoardInfo *bi = RTGBase->Boards[i];
	      if (bi->GraphicsControllerType == GCT_IMSG364) {
		LONG *ctrl = &bi->ChipData[0];
		LONG *sync = &bi->ChipData[5];
		LONG *reg  = (LONG *)bi->RegisterBase;
		LONG flags = (1<<4)|(1<<5)|(1<<6)|(1<<7);

		val      &= flags;
		*sync     = (*sync & ~flags) | val;
		*ctrl     = (*ctrl & ~flags) | val;
		reg[0x60] = *ctrl;
	      }
	    }
	  }
	  CloseLibrary((struct Library *)RTGBase);
	}

	return 0;
}

