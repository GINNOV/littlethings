#include <exec/types.h>

#include <exec/execbase.h>

#include <graphics/view.h>
#include <graphics/displayinfo.h>

#define __USE_SYSBASE
#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/dos.h>

#include <stdio.h>

int main(int argc, char ** argv){
	ULONG ID=INVALID_ID,last=INVALID_ID;
	DisplayInfoHandle dih;

	struct DisplayInfo dis;
	struct NameInfo nam;
	
	do{
		ID=NextDisplayInfo(ID);
		if(ID==INVALID_ID)	break;

		if(last!=INVALID_ID)
			printf("*****************************************************************************************************\n");
		last=ID;

		dih=FindDisplayInfo(ID);
		if(dih){
			GetDisplayInfoData(dih,(UBYTE *)&dis,sizeof(dis),DTAG_DISP,NULL);
			GetDisplayInfoData(dih,(UBYTE *)&nam,sizeof(nam),DTAG_NAME,NULL);

			printf("ID: %08lx  Name: \"%s\"\n", ID, nam.Name);
			printf("NotAvailable: %04x  PropertyFlags: %08lx <=>  ",dis.NotAvailable,dis.PropertyFlags);
				if(dis.PropertyFlags & DIPF_IS_LACE)					printf("LACE ");
				if(dis.PropertyFlags & DIPF_IS_DUALPF)					printf("DUALPF ");
				if(dis.PropertyFlags & DIPF_IS_PF2PRI)					printf("PF2PRI ");
				if(dis.PropertyFlags & DIPF_IS_HAM)						printf("HAM ");
				if(dis.PropertyFlags & DIPF_IS_ECS)						printf("ECS ");
				if(dis.PropertyFlags & DIPF_IS_AA)						printf("AA ");
				if(dis.PropertyFlags & DIPF_IS_PAL)						printf("PAL ");
				if(dis.PropertyFlags & DIPF_IS_SPRITES)				printf("SPRITES ");
				if(dis.PropertyFlags & DIPF_IS_GENLOCK)				printf("GENLOCK ");
				if(dis.PropertyFlags & DIPF_IS_WB)						printf("WB ");
				if(dis.PropertyFlags & DIPF_IS_DRAGGABLE)				printf("DRAGGABLE ");
				if(dis.PropertyFlags & DIPF_IS_PANELLED)				printf("PANELLED ");
				if(dis.PropertyFlags & DIPF_IS_BEAMSYNC)				printf("BEAMSYNC ");
				if(dis.PropertyFlags & DIPF_IS_EXTRAHALFBRITE)		printf("EXTRAHALFBRITE ");
				if(dis.PropertyFlags & DIPF_IS_SPRITES_ATT)			printf("SPRITES_ATT ");
				if(dis.PropertyFlags & DIPF_IS_SPRITES_CHNG_RES)	printf("SPRITES_CHNG_RES ");
				if(dis.PropertyFlags & DIPF_IS_SPRITES_BORDER)		printf("SPRITES_BORDER ");
				if(dis.PropertyFlags & DIPF_IS_SCANDBL)				printf("SCANDBL ");
				if(dis.PropertyFlags & DIPF_IS_SPRITES_CHNG_BASE)	printf("SPRITES_CHNG_BASE ");
				if(dis.PropertyFlags & DIPF_IS_SPRITES_CHNG_PRI)	printf("SPRITES_CHNG_PRI ");
				if(dis.PropertyFlags & DIPF_IS_DBUFFER)				printf("DBUFFER ");
				if(dis.PropertyFlags & DIPF_IS_PROGBEAM)				printf("PROGBEAM ");
				if(dis.PropertyFlags & DIPF_IS_FOREIGN)				printf("FOREIGN ");
				printf("\n");
		}
	}while(1);
	return(0);
}
