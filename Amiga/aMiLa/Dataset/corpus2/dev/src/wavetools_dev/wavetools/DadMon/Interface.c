/*
** All the interface stuff
** put here
**
**
*/

#include <intuition/intuitionbase.h>
#include <exec/nodes.h>
#include <exec/tasks.h>
#include <libraries/dos.h>
#include <exec/types.h>
#include <exec/memory.h>
#include <stdlib.h>
#include <stdio.h>

#define HASH_PEN	0			/* Pen used for hash lines.*/

#define MaxValue 65536	/* if unsigned 16 bit samples but they could be signed */

/*****************************************************
**  Static variabler som funktionerna kan arbeta på.**
**  Interfacets "state"                             **
*****************************************************/

	static LONG height,width,left,right,top,bottom;
	static ULONG int_steps_per_pixel;
	static int whitepen,blackpen;
	static short pen,minpen,maxpen;
	static unsigned short RGB;
	static int class;
        static struct Window *CustWindow;

#define rp CustWindow->RPort
#define bl CustWindow->BorderLeft
#define bt CustWindow->BorderTop
#define br CustWindow->BorderRight
#define bb CustWindow->BorderBottom
#define ww CustWindow->Width
#define wh CustWindow->Height


struct MsgPort *OpenFace(WIN_LEFT, WIN_TOP, WIN_WIDTH,WIN_HEIGHT){
	struct Screen *PubScreen;
	LONG n;
        WORD zoom_words[4] = {WIN_LEFT, WIN_TOP, WIN_WIDTH, PubScreen->WBorTop + PubScreen->Font->ta_YSize + 1};

	PubScreen = (struct Screen *)LockPubScreen(NULL);
	CustWindow = (struct Window *)OpenWindowTags(NULL,
					WA_Left,	WIN_LEFT,
					WA_Top,		WIN_TOP,
					WA_Width,	WIN_WIDTH,
					WA_Height,	WIN_HEIGHT,
					WA_MinWidth,50,
					WA_MinHeight,25,
					WA_IDCMP,	CLOSEWINDOW | NEWSIZE | CHANGEWINDOW,
					WA_Flags,	ACTIVATE | SMART_REFRESH | WINDOWCLOSE | WINDOWDRAG | WINDOWDEPTH,
					WA_Title,	"DadMon",
					WA_PubScreen,PubScreen,
					WA_Zoom,	zoom_words,
					NULL);
	UnlockPubScreen(NULL,PubScreen);
	CustWindow->MinHeight = bt;
	whitepen = 1;
	blackpen = 0;
	maxpen = 0x000;
	minpen = 0xfff;
	for (n = 0; n < (1 << PubScreen->BitMap.Depth); n++) {
		RGB = GetRGB4(PubScreen->ViewPort.ColorMap,n);
		pen = (RGB & 0x00f) + ((RGB & 0x0f0) >> 4) + ((RGB & 0xf00) >> 8);
		if (pen < minpen) {
			minpen = pen;
			blackpen = n;
		}
		if (pen > maxpen) {
			maxpen = pen;
			whitepen = n;
		}
	}

	height = wh - bt - bb;
	width  = ww - br - bl;
	left   = bl;
	right  = left + width - 1;
	top    = bt;
	bottom = bt + height - 1;

 	/*FreshFace(void);*/	/* fresh up face */
	return(CustWindow->UserPort);
}


void MoveFace(WORD left_sample,WORD right_sample){
	WORD low_base,high_base;
	int left,right;

    	if (wh > bt) {
		height = wh - bt - bb;
		width  = ww - br - bl;
		left   = bl;
		right  = left + width - 1;
		top    = bt;
		bottom = bt + height - 1;
        	int_steps_per_pixel = MaxValue/height; /* Max=65535 */
        	low_base = bottom ;
                high_base= top + height/2;
		ScrollRaster(rp,1,0,left,top,right,bottom);


		left_sample = abs(left_sample);
		Move(rp,right,high_base);
		SetAPen(rp,blackpen);
		Draw(rp, right, high_base - (left_sample/int_steps_per_pixel));
		SetAPen(rp,whitepen);
		Draw(rp,right,top);

		SetAPen(rp,blackpen);
		right_sample = abs(right_sample);
           	Move(rp,right,low_base);
		Draw(rp, right, low_base - (right_sample/int_steps_per_pixel));
		SetAPen(rp,whitepen);
		Draw(rp,right,high_base);


		SetAPen(rp, HASH_PEN);
		Move(rp, left,high_base);
		Draw(rp, right, high_base);
		Move(rp, left, top + height/2);
		Draw(rp, right, top + height/2);
		Move(rp, left, low_base);
		Draw(rp, right, low_base);


	}
}


void FreshFace(void){

  	if (wh > bt) {
		SetAPen(rp,whitepen);
		RectFill(rp,left,top,right,bottom);
		SetAPen(rp, HASH_PEN);
		Move(rp, left, top + height/4);
		Draw(rp, right, top + height/4);
		Move(rp, left, top + height/2);
		Draw(rp, right, top + height/2);
		Move(rp, left, top + 3*height/4);
		Draw(rp, right, top + 3*height/4);
	}

}

void CloseFace(void){
	if (CustWindow)
		CloseWindow(CustWindow);
}
