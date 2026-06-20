#include	<exec/types.h>
#include	<intuition/intuitionbase.h>
#include	<rtgBase.h>

#include	<proto/exec.h>
#include	<proto/dos.h>
#include	<proto/intuition.h>
#include	<proto/graphics.h>
#include	<proto/rtg.h>

#include	<stdio.h>

int main(int argc, char **argv)
{
	struct View *actiview = GfxBase->ActiView;
	
	struct RTGBase *RTGBase = (struct RTGBase *)FindName(&(SysBase->LibList), "rtg.library");
	
	printf("IntuitionBase->ViewLord $%08lx  GfxBase->ActiView $%08lx\n", &(IntuitionBase->ViewLord), GfxBase->ActiView);
	
	RTGBase->GlobalFlags |= RTGF_Debug;
	LoadView(NULL);
	RTGBase->GlobalFlags &= ~RTGF_Debug;
	
	Delay(250);

	RTGBase->GlobalFlags |= RTGF_Debug;
	LoadView(actiview);
	RTGBase->GlobalFlags &= ~RTGF_Debug;
//	RemakeDisplay();
	return(0);
}
