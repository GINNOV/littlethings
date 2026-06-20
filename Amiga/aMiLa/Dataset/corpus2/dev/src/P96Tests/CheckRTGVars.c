#include <exec/types.h>

#include <proto/rtg.h>
#include <proto/exec.h>
#include <proto/dos.h>

#include <stdio.h>

char __stdiowin[]="CON://450/200/";

void main(int argc,char **argv)
{
	if(FindName(&SysBase->LibList, "rtg.library")){
		struct RTGBase *RTGBase=(struct RTGBase *)OpenLibrary("picasso96/rtg.library",40);
		if(RTGBase){
			printf("Amiga31kHz          : %s\n", (RTGBase->GlobalFlags & RTGF_Amiga31kHz) ? "Yes" : "No");
//			printf("FlickerFixerChanged : %s\n", (RTGBase->GlobalFlags & RTGF_FlickerFixerChanged) ? "Yes" : "No");
			printf("BlackSwitching      : %s\n", (RTGBase->GlobalFlags & RTGF_BlackSwitching) ? "Yes" : "No");
			printf("DirectColorMask     : %s\n", (RTGBase->GlobalFlags & RTGF_DirectColorMask) ? "Yes" : "No");
			printf("EssentialModes      : %s\n", (RTGBase->GlobalFlags & RTGF_EssentialModes) ? "Yes" : "No");
			printf("PlanarOnlyDBuf      : %s\n", (RTGBase->GlobalFlags & RTGF_PlanarOnlyDBuf) ? "Yes" : "No");
			printf("DisableAmigaBlitter : %s\n", (RTGBase->GlobalFlags & RTGF_DisableAmigaBlitter) ? "Yes" : "No");
			printf("PlanesToFast        : %s\n", (RTGBase->GlobalFlags & RTGF_PlanesToFast) ? "Yes" : "No");
			printf("Experimental        : %s\n", (RTGBase->GlobalFlags & RTGF_Experimental) ? "Yes" : "No");
			printf("Debug               : %s\n", (RTGBase->GlobalFlags & RTGF_Debug) ? "Yes" : "No");
		}
	}else{
		printf("Picasso96 is not currently running.\nYou have to start the monitors first!\n");
	}
}
