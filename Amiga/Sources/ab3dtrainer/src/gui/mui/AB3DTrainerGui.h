#include <libraries/mui.h>
#include <proto/muimaster.h>
#include <clib/exec_protos.h>
#include <exec/memory.h>
#include <clib/alib_protos.h>

struct ObjApp
{
	APTR	App;
	APTR	WI_Main;
	APTR	CH_ENERGY;
	APTR	CH_AMMO;
	APTR	CH_HACK;
	APTR	CY_CONTROL;
	APTR	BT_PLAY;
	APTR	BT_CANCEL;
	char *	CY_CONTROLContent[4];
};


extern struct ObjApp * CreateApp(void);
extern void DisposeApp(struct ObjApp *);
