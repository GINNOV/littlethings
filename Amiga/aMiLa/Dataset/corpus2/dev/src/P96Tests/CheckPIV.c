#include <exec/types.h>

#include <proto/rtg.h>
#include <proto/exec.h>
#include <proto/dos.h>

#include <stdio.h>

char __stdiowin[]="CON://450/200/";

char *ControllerType[]={
"none","Tseng ET4000","Tseng ET4000W32","Cirrus Logic GD542X","NCR 77C32BLT","Cirrus Logic GD5446","Cirrus Logic GD5434","S3 Trio64","TI 34010","S3 Virge3D"
};

char *DACtype[]={
"none","Sierra S11483","Sierra S15025","Cirrus Logic GD542X (intern)","Domino","BrookTree BT482","Music MU9C4910","ICS 5300","Cirrus Logic GD5446 (intern)","Cirrus Logic GD5434 (intern)","S3 Trio64 (intern)","A2410_DAC","S3 Virge3D (intern)"
};

void main(int argc,char **argv)
{
	if(FindName(&SysBase->LibList, "rtg.library")){
		struct RTGBase *RTGBase=(struct RTGBase *)OpenLibrary("picasso96/rtg.library",40);
		int i;
		if(RTGBase){
			printf("Looking through all boards installed for Picasso96\n");
			if(!RTGBase->BoardCount){
				printf("\nNo board found!\nStart Monitor first!\n");
			}
			for(i=0;i<RTGBase->BoardCount;i++){
				struct BoardInfo *bi = RTGBase->Boards[i];
				
				if(bi->BoardType != BT_PicassoIV)	continue;
	
				printf("--------------------------------------------------\n");
				printf("Board %ld:      %s\nChip:         %s\nDAC:          %s\n",i,bi->BoardName,ControllerType[bi->GraphicsControllerType],DACtype[bi->PaletteChipType]);
				printf("RegisterBase: 0x%08lx\n",bi->RegisterBase);
				printf("MemoryBase:   0x%08lx\n",bi->MemoryBase);
				printf("MemorySize:     %8ld\n",bi->MemorySize);
				printf("BitsPerCannon:  %8d\n",bi->BitsPerCannon);

				printf("NumNormalClocks: %ld\n",bi->ChipData[2]);
				printf("NumDoubleClocks: %ld\n",bi->ChipData[3]);
				printf("MaxStandardClock: %ld\n",bi->ChipData[4]);
				printf("MaxDoubleClock: %ld\n",bi->ChipData[5]);
				printf("FirstDoubleClock: %ld\n",bi->ChipData[6]);
				printf("OverClockRate: %ld\n",bi->ChipData[7]);
			}
			CloseLibrary((struct Library *)RTGBase);
		}else{
			printf("Error accessing Picasso96 software.\nDid you install everything properly?\n");
		}
	}else{
		printf("Picasso96 is not currently running.\nYou have to start the monitors first!\n");
	}
}
