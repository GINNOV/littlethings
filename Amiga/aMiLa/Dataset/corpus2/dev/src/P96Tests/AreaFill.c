#include <intuition/screens.h>
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/Picasso96.h>

#include	<stdio.h>
#include	<string.h>

UWORD Muster[]= { 0x00ff };

#define	WIDTH		4*32+8*32
#define	HEIGHT	32+32+64+32
#define	DEPTH		8

char	ScreenTitle[] = "Picasso96 AreaFill Test";
char	Template[] = "Width=W/N,Height=H/N,Depth=D/N";
LONG	Array[] = { 0, 0, 0 };
WORD	Pens[] = {~0};

Point inner[] = {
	{ 20, 20},
	{ 100, 30},
	{ 30, 80},
};

#define NUMVECTORS (sizeof(inner)/sizeof(Point))

WORD buffer[(((NUMVECTORS/2+1)*5)+1) & ~1];

main(void)
{
	ULONG	DisplayID;
	void *TmpBuf;
	struct TmpRas tmpras;
	
	memset(buffer, 0, sizeof(buffer));
	
	if(INVALID_ID != (DisplayID = p96RequestModeIDTags(TAG_DONE))){
		struct Screen		*sc;

		if(TmpBuf = AllocRaster(WIDTH, HEIGHT)){
			InitTmpRas(&tmpras, TmpBuf, ((WIDTH+7)/8) * HEIGHT);

			if(sc=OpenScreenTags(NULL,
										SA_DisplayID,DisplayID,SA_Depth,8,SA_Width,640,SA_Height,480,SA_Pens,Pens,SA_FullPalette,TRUE,SA_Title,(ULONG)ScreenTitle,TAG_DONE)){

				struct Window		*wd;

				if(wd=OpenWindowTags(NULL,WA_Left,0,WA_Width,WIDTH,WA_Height,HEIGHT,
											WA_DragBar,TRUE,WA_DragBar,TRUE,WA_Activate,TRUE,WA_CloseGadget,TRUE,WA_IDCMP,IDCMP_CLOSEWINDOW|IDCMP_RAWKEY,WA_CustomScreen,sc,WA_Title,(ULONG)ScreenTitle,TAG_DONE)){
					struct RastPort	*rp, prp;
					struct Message		*msg;
					Point p;
					int i, j, res;
					struct AreaInfo area, *ai;

					rp = wd->RPort;
					prp = *rp;

					ai = &area;
					
					InitArea(ai, buffer, NUMVECTORS+1);
					rp->AreaInfo = ai;
					rp->TmpRas = &tmpras;

					printf("AreaInfo %08lx\n",rp->AreaInfo);
					
					SetAPen(rp,4);
					j = sizeof(inner)/sizeof(p);
					AreaMove(rp, inner[j-1].x, inner[j-1].y);
					for(i = 0; i<j; i++){
						res = AreaDraw(rp, inner[i].x, inner[i].y);
						if(res) printf("Res(%ld)=%ld\n",i,res);
					}
					AreaEnd(rp);
					
					WaitPort(wd->UserPort);
					Forbid();
					while(msg = GetMsg(wd->UserPort)) ReplyMsg(msg);
					Permit();

					CloseWindow(wd);
				}
				CloseScreen(sc);
			}
			FreeRaster(TmpBuf, WIDTH, HEIGHT);
		}
	}
}
