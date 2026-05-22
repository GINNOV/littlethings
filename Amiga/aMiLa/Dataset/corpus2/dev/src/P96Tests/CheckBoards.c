#include <exec/types.h>

#include <proto/rtg.h>
#include <proto/exec.h>
#include <proto/dos.h>

#include <stdio.h>

char __stdiowin[]="CON://450/200/";

char *ControllerType[]={
"none","Tseng ET4000","Tseng ET4000W32","Cirrus Logic GD542X","NCR 77C32BLT","Cirrus Logic GD5446","Cirrus Logic GD5434","S3 Trio64","TI 34010","S3 Virge3D","3dfx Voodoo","TexasInstruments TVP4020 Permedia2"
};

char *DACtype[]={
"none","Sierra S11483","Sierra S15025","Cirrus Logic GD542X (internal)","Domino","BrookTree BT482","Music MU9C4910","ICS 5300","Cirrus Logic GD5446 (internal)","Cirrus Logic GD5434 (internal)","S3 Trio64 (internal)","A2410_DAC","S3 Virge3D (internal)","3dfx Voodoo (internal)","TexasInstruments TVP4020 Permedia2 (internal)"
};

char template[] = "CLOCKS=C/S";

void main(int argc,char **argv)
{
	struct RDArgs *rda;
	LONG array[1];
	
	array[0] = 0;
	if(rda = ReadArgs(template, array, NULL)){
		FreeArgs(rda);
	}

	if(FindName(&SysBase->LibList, "rtg.library")){
		struct RTGBase *RTGBase=(struct RTGBase *)OpenLibrary("picasso96/rtg.library",40);
		int i, j, clock;
		if(RTGBase){
			printf("Looking through all boards installed for Picasso96\n");
			if(!RTGBase->BoardCount){
				printf("\nNo board found!\nStart Monitor first!\n");
			}
			for(i=0;i<RTGBase->BoardCount;i++){
				struct BoardInfo *bi = RTGBase->Boards[i];
				BOOL	switchold[MaxNrOfBoards];
				struct p96SemaphoreHandle	Handle;
	
				printf("--------------------------------------------------\n");
				printf("Board %ld:      %s\nChip:         %s\nDAC:          %s\n",i,bi->BoardName,ControllerType[bi->GraphicsControllerType],DACtype[bi->PaletteChipType]);
				printf("RegisterBase: 0x%08lx\n",bi->RegisterBase);
				printf("MemoryIOBase: 0x%08lx\n",bi->MemoryIOBase);
				printf("MemoryBase:   0x%08lx\n",bi->MemoryBase);
				printf("MemorySize:     %8ld\n",bi->MemorySize);
				printf("BitsPerCannon:  %8d\n",bi->BitsPerCannon);
				printf("\nThis board supports:\n");
				printf("\tfollowing rgb formats:\n");
				if(bi->RGBFormats &RGBFF_PLANAR)		printf("\t\tPLANAR\n");
				if(bi->RGBFormats &RGBFF_CHUNKY)		printf("\t\tCHUNKY\n");
				if(bi->RGBFormats &RGBFF_R5G5B5)		printf("\t\tR5G5B5\n");
				if(bi->RGBFormats &RGBFF_R5G5B5PC)	printf("\t\tR5G5B5PC\n");
				if(bi->RGBFormats &RGBFF_B5G5R5PC)	printf("\t\tB5G5R5PC\n");
				if(bi->RGBFormats &RGBFF_R5G6B5)		printf("\t\tR5G6B5\n");
				if(bi->RGBFormats &RGBFF_R5G6B5PC)	printf("\t\tR5G6B5PC\n");
				if(bi->RGBFormats &RGBFF_B5G6R5PC)	printf("\t\tB5G6R5PC\n");
				if(bi->RGBFormats &RGBFF_R8G8B8)		printf("\t\tR8G8B8\n");
				if(bi->RGBFormats &RGBFF_B8G8R8)		printf("\t\tB8G8R8\n");
				if(bi->RGBFormats &RGBFF_A8R8G8B8)	printf("\t\tA8R8G8B8\n");
				if(bi->RGBFormats &RGBFF_A8B8G8R8)	printf("\t\tA8B8G8R8\n");
				if(bi->RGBFormats &RGBFF_R8G8B8A8)	printf("\t\tR8G8B8A8\n");
				if(bi->RGBFormats &RGBFF_B8G8R8A8)	printf("\t\tB8G8R8A8\n");
				if(bi->RGBFormats &RGBFF_Y4U2V2)		printf("\t\tY4U2V2\n");
				if(bi->RGBFormats &RGBFF_Y4U1V1)		printf("\t\tY4U1V1\n");
				printf("\t%shardware sprite,\n",(bi->Flags & BIF_HARDWARESPRITE ? "" : "no "));
				printf("\t%ssoftware sprite buffer,\n",(bi->Flags & BIF_HASSPRITEBUFFER ? "" : "no "));
				printf("\tplanar and chunky memory %s,\n",(bi->Flags & BIF_NOMEMORYMODEMIX ? "exclusive" : "simultaneous"));
				printf("\thardware vblank interrupt can%s be caused,\n",(bi->Flags & BIF_VBLANKINTERRUPT? "" : " not"));
				printf("User selectable flags:\n");
				printf("\toverclocking %s,\n",(bi->Flags & BIF_OVERCLOCK ? "enabled" : "disabled"));
				clock = (bi->MemoryClock+50000)/100000;
				printf("\tmemory clock set to %ld.%1ld MHz,\n",clock/10,clock%10);
				printf("\tbig sprite%s used,\n",(bi->Flags & BIF_BIGSPRITE ? "" : " not"));
				if(bi->SoftSpriteFlags){
					printf("\tsoft sprite in mode depth %s%s%s%s%s%s\n",
						((bi->SoftSpriteFlags & RGBFF_PLANAR) ? "4, " : ""),
						((bi->SoftSpriteFlags & RGBFF_CHUNKY) ? "8, " : ""),
						((bi->SoftSpriteFlags & (RGBFF_R5G5B5PC|RGBFF_R5G5B5|RGBFF_B5G6R5PC)) ? "15, " : ""),
						((bi->SoftSpriteFlags & (RGBFF_R5G6B5PC|RGBFF_R5G6B5|RGBFF_B5G6R5PC)) ? "16, " : ""),
						((bi->SoftSpriteFlags & (RGBFF_R8G8B8|RGBFF_B8G8R8)) ? "24, " : ""),
						((bi->SoftSpriteFlags & (RGBFF_A8R8G8B8|RGBFF_A8B8G8R8|RGBFF_R8G8B8A8|RGBFF_B8G8R8A8)) ? "32, " : ""));
				}
				printf("\tsystem borderblank%s used,\n",(bi->Flags & BIF_BORDEROVERRIDE ? " not" : ""));
				if(bi->Flags & BIF_BORDEROVERRIDE)
					printf("\tforce borderblank %s,\n",(bi->Flags & BIF_BORDERBLANK ? "on" : "off"));
				printf("\tboard is %spart of the display chain,\n",(bi->Flags & BIF_INDISPLAYCHAIN ? "" : "not "));
				
				if(array[0]){
					struct ModeInfo mi;
					if(bi->RGBFormats & RGBFF_PLANAR){
						int cl;
						printf("\tnumber of pixel clocks available for planar modes: %ld\n", bi->PixelClockCount[PLANAR]);
						for(cl = 0; cl < bi->PixelClockCount[PLANAR]; ){
							printf("\t");
							do{
								printf("%10ld, ", bi->GetPixelClock(bi, &mi, cl, RGBFB_PLANAR));
								cl++;
							}while((cl % 5) && (cl < bi->PixelClockCount[PLANAR]));
							printf("\n");
						}
					}
					if(bi->RGBFormats & RGBFF_CLUT){
						int cl;
						printf("\tnumber of pixel clocks available for chunky modes: %ld\n", bi->PixelClockCount[CHUNKY]);
						for(cl = 0; cl < bi->PixelClockCount[CHUNKY]; ){
							printf("\t");
							do{
								printf("%10ld, ", bi->GetPixelClock(bi, &mi, cl, RGBFB_CLUT));
								cl++;
							}while((cl % 5) && (cl < bi->PixelClockCount[CHUNKY]));
							printf("\n");
						}
					}
					if(bi->RGBFormats & (RGBFF_R5G6B5PC|RGBFF_R5G5B5PC|RGBFF_R5G6B5|RGBFF_R5G5B5|RGBFF_B5G6R5PC|RGBFF_B5G5R5PC)){
						int cl;
						printf("\tnumber of pixel clocks available for HiColor modes: %ld\n", bi->PixelClockCount[HICOLOR]);
						for(cl = 0; cl < bi->PixelClockCount[HICOLOR]; ){
							printf("\t");
							do{
								printf("%10ld, ", bi->GetPixelClock(bi, &mi, cl, RGBFB_R5G5B5PC));
								cl++;
							}while((cl % 5) && (cl < bi->PixelClockCount[HICOLOR]));
							printf("\n");
						}
					}
					if(bi->RGBFormats & (RGBFF_R8G8B8|RGBFF_B8G8R8)){
						int cl;
						printf("\tnumber of pixel clocks available for true color modes: %ld\n", bi->PixelClockCount[TRUECOLOR]);
						for(cl = 0; cl < bi->PixelClockCount[TRUECOLOR]; ){
							printf("\t");
							do{
								printf("%10ld, ", bi->GetPixelClock(bi, &mi, cl, RGBFB_R8G8B8));
								cl++;
							}while((cl % 5) && (cl < bi->PixelClockCount[TRUECOLOR]));
							printf("\n");
						}
					}
					if(bi->RGBFormats & (RGBFF_A8R8G8B8|RGBFF_A8B8G8R8|RGBFF_R8G8B8A8|RGBFF_B8G8R8A8)){
						int cl;
						printf("\tnumber of pixel clocks available for true alpha modes: %ld\n", bi->PixelClockCount[TRUEALPHA]);
						for(cl = 0; cl < bi->PixelClockCount[TRUEALPHA]; ){
							printf("\t");
							do{
								printf("%10ld, ", bi->GetPixelClock(bi, &mi, cl, RGBFB_A8R8G8B8));
								cl++;
							}while((cl % 5) && (cl < bi->PixelClockCount[TRUEALPHA]));
							printf("\n");
						}
					}
				}
				printf("\nBringing board %ld to front for about 2 seconds...\n",i);
	
				rtgLock(&Handle, FALSE);
				for(j=0; j<RTGBase->BoardCount; j++){
					struct BoardInfo *sbi = RTGBase->Boards[j];
					switchold[j] = sbi->SetSwitch(sbi, i==j);
				}
				Delay(100);
				for(j=0; j<RTGBase->BoardCount; j++){
					struct BoardInfo *sbi = RTGBase->Boards[j];
					sbi->SetSwitch(sbi, switchold[j]);
				}
				rtgUnlock(&Handle);
			}
			CloseLibrary((struct Library *)RTGBase);
		}else{
			printf("Error accessing Picasso96 software.\nDid you install everything properly?\n");
		}
	}else{
		printf("Picasso96 is not currently running.\nYou have to start the monitors first!\n");
	}
}
