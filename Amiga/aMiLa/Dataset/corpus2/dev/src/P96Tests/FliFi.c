#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <proto/rtg.h>
#include	<libraries/PicassoIVresource.h>

//#include	"h:PicassoIV_FlickerFixer.h"

#include <stdio.h>

char template[]="PAL/S,NTSC/S,FRAMERATE=FR/N";

LONG array[]={	0, 0, 0 };

struct GfxBase *GfxBase;
struct RTGBase *RTGBase;
struct P4Resource *P4Res;

void main(int argc,char **argv)
{
	if(P4Res=(struct P4Resource *)OpenResource(PICASSOIVRESNAME)){
		if((FindName(&SysBase->LibList,"rtg.library")) &&
			(RTGBase=(struct RTGBase *)OpenLibrary("Picasso96/rtg.library",39))){
			struct BoardInfo *bi = NULL;
			int i;

			for(i=0; i<RTGBase->BoardCount; i++){
				bi = RTGBase->Boards[i];
				if(bi->BoardType == BT_PicassoIV)	break;
			}
			if(bi && (i != RTGBase->BoardCount)){

				if(GfxBase=(struct GfxBase *)OpenLibrary("graphics.library",39)){
					struct RDArgs			*rda;
					struct MonitorSpec	*ms;
					BOOL update = FALSE;
					BOOL pal = TRUE, ntsc = TRUE;
					LONG	ffreq = 75, pclock;
					RGBFTYPE	format = ((((struct P4BoardInfo *)(bi->CardData[1]))->p4bi_Modules & P4BIEXF_FF_AA) ? RGBFB_B8G8R8 : RGBFB_R5G5B5PC);

					if(rda=ReadArgs(template,array,NULL)){
						if(array[0] || array[1]){
							pal = array[0] ? TRUE : FALSE;
							ntsc = array[1] ? TRUE : FALSE;
						}
						if(array[2])	ffreq =*((LONG *)array[2]);
						FreeArgs(rda);
					}

					Forbid();
					ms = GfxBase->current_monitor;
					if((ffreq >= 50) && (ffreq <= 160)){
						struct P4Timing		*tim;
						struct ModeInfo mi;

						if(pal){
							if((P4Res->p4res_lib.lib_Version >= 4) &&
								(P4Res->p4res_lib.lib_Revision >= 1)){

								tim = ((struct P4BoardInfo *)(bi->CardData[1]))->p4bi_PALTiming;
							}else{
								tim = P4Res->p4res_PALTiming;
							}	
						
							// parameters ResolvePixelClock() uses
							mi.VerTotal = (tim->VTotal+2);

							pclock = ffreq * tim->HTotal * tim->VTotal;
							
							bi->ResolvePixelClock(bi, &mi, pclock, format);
							
							tim->PixelParam = (mi.Numerator<<8) + mi.Denominator;
							
							printf("PAL:  frame rate: %ldHz, pixel clock: %ldHz\n",mi.PixelClock/(tim->HTotal*tim->VTotal),mi.PixelClock);

							if(ms && (ms->ms_Flags & MSF_REQUEST_PAL)) update = TRUE;

						}
						if(ntsc){
							if((P4Res->p4res_lib.lib_Version >= 4) &&
								(P4Res->p4res_lib.lib_Revision >= 1)){

								tim = ((struct P4BoardInfo *)(bi->CardData[1]))->p4bi_NTSCTiming;
							}else{
								tim = P4Res->p4res_NTSCTiming;
							}	
							
							// parameters ResolvePixelClock() uses
							mi.VerTotal = (tim->VTotal+2);

							pclock = ffreq * tim->HTotal * tim->VTotal;
							
							bi->ResolvePixelClock(bi, &mi, pclock, format);
							
							tim->PixelParam = (mi.Numerator<<8) + mi.Denominator;

							printf("NTSC: frame rate: %ldHz, pixel clock: %ldHz\n",mi.PixelClock/(tim->HTotal*tim->VTotal),mi.PixelClock);

							if(ms && (ms->ms_Flags & MSF_REQUEST_NTSC)) update = TRUE;

						}
						RTGBase->GlobalFlags |= RTGF_FlickerFixerChanged;
					}

					if(update){
						struct View *v=GfxBase->ActiView;
						LoadView(v);
					}

					Permit();
					CloseLibrary((struct Library *)GfxBase);
				}

			}else{
				printf("PicassoIV not activated for Picasso96 yet!\n");
			}
			CloseLibrary((struct Library *)RTGBase);
		}else{
			printf("Could not open Picasso96 rtg.library!\n");
		}
	}else{
		printf("No PicassoIV Resource found!\n");
	}
}
