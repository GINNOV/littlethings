#include <intuition/screens.h>
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>
#include <graphics/clip.h>
#include <graphics/scale.h>
#include <exec/alerts.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/dos.h>

#include <stdio.h>
#include <math.h>

#define	WIDTH		(8+1)*40
#define	HEIGHT	(8+1)*10
#define	DEPTH		2

#define	ID			HIRESLACE_KEY
//#define	ID			0x50021100		/* HiColor */
//#define	ID			0x55011200		/* TrueColor */
//#define	ID			0x55021300		/* TrueAlpha */
void KPrintF(char *, ...);

#define BSAF_XSCALE 1
#define BSAF_YSCALE 2

main(void)
{
	struct Screen		*sc;
	struct Window		*wd;
	struct RastPort	*rp;
	struct Message		*msg;

	if(sc=OpenScreenTags(NULL,SA_DisplayID,ID,SA_Depth,DEPTH,SA_LikeWorkbench,TRUE,TAG_END))
	{
		if(wd=OpenWindowTags(NULL,WA_MinWidth,500,WA_MinHeight,350,WA_SizeGadget,TRUE,WA_DragBar,TRUE,WA_CloseGadget,TRUE,WA_IDCMP,IDCMP_CLOSEWINDOW,WA_CustomScreen,sc,WA_Activate,TRUE,TAG_DONE))
		{
			struct BitScaleArgs	bsa;

			rp = &(sc->RastPort);

			Delay(50);

			SetDrMd(rp, JAM1);
			SetAPen(rp, 1);
			SetBPen(rp, 0);

			Move(rp,32,32+8);
			Text(rp,"Test",4);
			Move(rp,24,32+8+20);
			Text(rp,"BitMapScale",11);

	    	bsa.bsa_SrcX = 0;
			bsa.bsa_SrcY = 0;
	    	bsa.bsa_SrcWidth = 120;
			bsa.bsa_SrcHeight = 80;
			bsa.bsa_SrcBitMap = rp->BitMap;
			bsa.bsa_DestBitMap = rp->BitMap;
			bsa.bsa_Flags = 0;

	    	bsa.bsa_DestX = 120;
			bsa.bsa_XSrcFactor = 4;
			bsa.bsa_XDestFactor = 3;
	    	bsa.bsa_DestY = 80;
			bsa.bsa_YSrcFactor = 4;
			bsa.bsa_YDestFactor = 3;
			BitMapScale(&bsa);
			printf("Scale down: %ld x %ld\n", bsa.bsa_DestWidth, bsa.bsa_DestHeight);
	    	bsa.bsa_DestY = 140;
			bsa.bsa_YSrcFactor = 1;
			bsa.bsa_YDestFactor = 1;
			BitMapScale(&bsa);
	    	bsa.bsa_DestY = 220;
			bsa.bsa_YSrcFactor = 4;
			bsa.bsa_YDestFactor = 5;
			BitMapScale(&bsa);

	    	bsa.bsa_DestX = 210;
			bsa.bsa_XSrcFactor = 1;
			bsa.bsa_XDestFactor = 1;
	    	bsa.bsa_DestY = 80;
			bsa.bsa_YSrcFactor = 4;
			bsa.bsa_YDestFactor = 3;
			BitMapScale(&bsa);
	    	bsa.bsa_DestY = 140;
			bsa.bsa_YSrcFactor = 1;
			bsa.bsa_YDestFactor = 1;
			BitMapScale(&bsa);
			printf("Scale no: %ld x %ld\n", bsa.bsa_DestWidth, bsa.bsa_DestHeight);
	    	bsa.bsa_DestY = 220;
			bsa.bsa_YSrcFactor = 4;
			bsa.bsa_YDestFactor = 5;
			BitMapScale(&bsa);

	    	bsa.bsa_DestX = 330;
			bsa.bsa_XSrcFactor = 4;
			bsa.bsa_XDestFactor = 5;
	    	bsa.bsa_DestY = 80;
			bsa.bsa_YSrcFactor = 4;
			bsa.bsa_YDestFactor = 3;
			BitMapScale(&bsa);
	    	bsa.bsa_DestY = 140;
			bsa.bsa_YSrcFactor = 1;
			bsa.bsa_YDestFactor = 1;
			BitMapScale(&bsa);
	    	bsa.bsa_DestY = 220;
			bsa.bsa_YSrcFactor = 4;
			bsa.bsa_YDestFactor = 5;
			BitMapScale(&bsa);
			printf("Scale up: %ld x %ld\n", bsa.bsa_DestWidth, bsa.bsa_DestHeight);

			WaitPort(wd->UserPort);
			
			Forbid();
			while(msg = GetMsg(wd->UserPort)) ReplyMsg(msg);
			Permit();

			CloseWindow(wd);
		}
		CloseScreen(sc);
	}
}
