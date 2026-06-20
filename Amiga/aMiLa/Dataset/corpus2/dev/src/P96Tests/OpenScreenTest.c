/***********************************************************************
* This is an example that shows how to open a p96 Screen and a Window 
* to get input events and how to paint on that screen.
* Program terminates when space bar or any mouse button is pressed!
*
* alex (Sun Dec 29 01:42:59 1996)
***********************************************************************/

#include	<proto/exec.h>
#include	<proto/dos.h>
#include	<proto/intuition.h>
#include	<proto/timer.h>
#include	<proto/graphics.h>
#include <proto/picasso96.h>

#include	<intuition/screens.h>

#include	<math.h>
#include	<stdio.h>
#include	<stdlib.h>

char	ScreenTitle[] = "Picasso96 OpenScreen Test";
char	Template[] = "Width=W/N,Height=H/N,Depth=D/N";
LONG	Array[] = { 0, 0, 0 };
WORD	Pens[] = {~0};

struct Library	*P96Base;

struct TagItem	WindowTags[] = {
	WA_Width, 200,
	WA_Height, 300,
	WA_MinWidth, 100,
	WA_MinHeight, 100,
	WA_MaxWidth, -1,
	WA_MaxHeight, -1,
	WA_SimpleRefresh, TRUE,
	WA_RMBTrap, TRUE,
	WA_Activate, TRUE,
	WA_CloseGadget, TRUE,
	WA_DepthGadget, TRUE,
	WA_DragBar, TRUE,
	WA_SizeGadget, TRUE,
	WA_SizeBBottom, TRUE,
	WA_GimmeZeroZero, TRUE,
	WA_ScreenTitle, (ULONG)ScreenTitle,
	WA_IDCMP, IDCMP_RAWKEY|IDCMP_CLOSEWINDOW,
	TAG_END
};

#define	random(x)	(rand()/(RAND_MAX/x))

void main(void)
{
	if(P96Base=OpenLibrary("Picasso96API.library",2)){
		struct RDArgs	*rda;
		struct Screen	*sc;

		LONG	Width = 640, Height = 480, Depth = 8;
		ULONG	DisplayID;
		
		if(rda = ReadArgs(Template, Array, NULL)){
			if(Array[0])	Width =*((LONG *)Array[0]);
			if(Array[1])	Height=*((LONG *)Array[1]);
			if(Array[2])	Depth =*((LONG *)Array[2]);
			FreeArgs(rda);
		}

		if(DisplayID = p96RequestModeIDTags(
										P96MA_MinWidth, Width,
										P96MA_MinHeight, Height,
										P96MA_MinDepth, Depth,
										P96MA_WindowTitle, "OpenScreen Test",
//										P96MA_FormatsAllowed, (RGBFF_CLUT|RGBFF_R5G6B5|RGBFF_R8G8B8|RGBFF_A8R8G8B8),
										TAG_DONE)){
			if(sc = OpenScreenTags(NULL,
											SA_DisplayID, DisplayID,
											SA_Width, Width,
											SA_Height, Height,
											SA_Depth, Depth,
											SA_AutoScroll, TRUE,
											SA_Pens, Pens,
											SA_Title, (ULONG)ScreenTitle,
											TAG_DONE)){

				struct Window	*wdf, *wdp;
				WORD	Dimensions[4];
				
				Dimensions[0] = 0;
				Dimensions[1] = sc->BarHeight+1;
				Dimensions[2] = sc->Width;
				Dimensions[3] = sc->Height-sc->BarHeight-1;

				wdp = OpenWindowTags(NULL,	WA_CustomScreen, sc,
													WA_Title, "WritePixel",
													WA_Left,(sc->Width/2-200)/2 + sc->Width/2,
													WA_Top,(sc->Height-sc->BarHeight-300)/2,
													WA_Zoom, &Dimensions,
													TAG_MORE, WindowTags);

				wdf = OpenWindowTags(NULL,	WA_CustomScreen, sc,
													WA_Title, "FillRect",
													WA_Left,(sc->Width/2-200)/2,
													WA_Top,(sc->Height-sc->BarHeight-300)/2,
													WA_Zoom, &Dimensions,
													TAG_MORE, WindowTags);

				if(wdf && wdp){
					struct RastPort	*rpf = wdf->RPort;
					struct RastPort	*rpp = wdp->RPort;
					BOOL	terminate = FALSE;
					ULONG	signals = ((1<<wdf->UserPort->mp_SigBit) | (1<<wdp->UserPort->mp_SigBit));
					RGBFTYPE	format = (RGBFTYPE)p96GetBitMapAttr(sc->RastPort.BitMap, P96BMA_RGBFORMAT);
					BYTE	oldPri;

					srand((unsigned int)wdf + (unsigned int)wdp);

					oldPri = SetTaskPri(FindTask(NULL), -100);
					do{
						WORD x1, y1, x2, y2, x3, y3;

						x1 = random(wdf->Width);
						y1 = random(wdf->Height);
						x2 = random(wdf->Width);
						y2 = random(wdf->Height);
						x3 = random(wdp->Width);
						y3 = random(wdp->Height);

						if(format == RGBFB_CLUT){
							SetAPen(rpf, random(255));
							RectFill(rpf, min(x1,x2), min(y1,y2), max(x1,x2), max(y1,y2));

							SetAPen(rpp, random(255));
							WritePixel(rpp, x3, y3);
						}else{
							p96RectFill(rpf, min(x1,x2), min(y1,y2), max(x1,x2), max(y1,y2),
											((random(255))<<16)|((random(255))<<8)|(random(255)));
							p96WritePixel(rpp, x3, y3,
											((random(255))<<16)|((random(255))<<8)|(random(255)));
						}
						if(SetSignal(0L, signals) & signals){
							struct IntuiMessage	*imsg;

							while(imsg=(struct IntuiMessage *)GetMsg(wdf->UserPort)){
								if((imsg->Class==IDCMP_CLOSEWINDOW) ||
									((imsg->Class==IDCMP_RAWKEY) && ((imsg->Code==0x40) || (imsg->Code==0x45)))){
									// Close window, press SPACE bar or ESCAPE key to end program
									terminate=TRUE;
								}
								ReplyMsg((struct Message *)imsg);
							}

							while(imsg=(struct IntuiMessage *)GetMsg(wdp->UserPort)){
								if((imsg->Class==IDCMP_CLOSEWINDOW) ||
									((imsg->Class==IDCMP_RAWKEY) && ((imsg->Code==0x40) || (imsg->Code==0x45)))){
									// Close window, press SPACE bar or ESCAPE key to end program
									terminate=TRUE;
								}
								ReplyMsg((struct Message *)imsg);
							}
						}
					}while(!terminate);
					SetTaskPri(FindTask(NULL), oldPri);

					Forbid();
					{
						struct Message	*msg;
						while(msg = GetMsg(wdf->UserPort)) ReplyMsg(msg);
						while(msg = GetMsg(wdp->UserPort)) ReplyMsg(msg);
					}
					Permit();

				}
				if(wdf) CloseWindow(wdf);
				if(wdp) CloseWindow(wdp);

				CloseScreen(sc);
			}
		}
		CloseLibrary(P96Base);
	}
}
