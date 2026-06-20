/*
	Flood Test
	by Tobias Abt
	Sun May 30 17:58:49 1999
	
	:ts=3
*/

#include <exec/types.h>
#include <exec/memory.h>
#include <dos/rdargs.h>
#include <graphics/modeid.h>
#include <graphics/gfx.h>
#include <graphics/gfxmacros.h>
#include <intuition/screens.h>
#include <intuition/intuition.h>

#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>

#include <stdio.h>

static BOOL GetHexBinDecStrValue(char *hexstr, LONG *result);

char template[] = "DisplayID";
LONG array[] = { 0 };

#define LINECNT(x) ((sizeof(x)/sizeof(Point))-1)

#define	PatSize	3
//UWORD Muster[(1L<<PatSize)]= { 0x1010, 0x2828, 0x5454, 0xaaaa, 0x5555, 0xaaaa, 0x5454, 0x2828 };
UWORD Muster[(1L<<PatSize)]= { 0x8080, 0x4040, 0xa0a0, 0x5050, 0xa8a8, 0x5454, 0xaaaa, 0x5555 };

Point outline1[] = {
	55, 10,
	125, 10,
	130, 5,
	140, 5,
	145, 10,
	230, 10,
	250, 30,
	250, 70,
	275, 95,
	275, 170,
	20, 170,
	10, 160,
	10, 140,
	20, 130,
	30, 140,
	240, 140,
	265, 115,
	240, 90,
	210, 120,
	120, 120,
	80, 80,
	60, 80,
	100, 120,
	10, 120,
	10, 20,
	20, 30,
	30, 20,
	55, 45,
	55, 10
};

Point outline2[] = {
	65, 20,
	225, 20,
	240, 35,
	230, 45,
	230, 80,
	215, 95,
	200, 80,
	200, 55,
	190, 45,
	145, 45,
	145, 30,
	100, 30,
	85, 45,
	65, 45,
	65, 20
};

Point outline3[] = {
	120, 40,
	145, 65,
	120, 90,
	95, 65,
	120, 40
};

Point outline4[] = {
	160, 60,
	185, 85,
	160, 110,
	135, 85,
	160, 60
};

Point outline5[] = {
	20, 55,
	75, 110,
	20, 110,
	20, 55
};

struct Figure {
	Point *Points;
	int LineCnt;
};

struct Figure Figures[] = {
	outline1, LINECNT(outline1),
	outline2, LINECNT(outline2),
	outline3, LINECNT(outline3),
	outline4, LINECNT(outline4),
	outline5, LINECNT(outline5)
};

int main(void)
{
	struct RDArgs *rda;
	ULONG DisplayID = INVALID_ID;
	struct Screen *sc;
	struct Window	*wd;
	
	if(rda = ReadArgs(template, array, NULL)){
		if(array[0]){
			GetHexBinDecStrValue((char *)array[0], (LONG *)&DisplayID);
		
			if(DisplayID != INVALID_ID){
				if(sc = OpenScreenTags(NULL, SA_DisplayID, DisplayID, SA_LikeWorkbench, TRUE, TAG_END)){
					if(wd = OpenWindowTags(NULL,
													WA_CustomScreen, sc,
													WA_CloseGadget, TRUE,
													WA_Activate, TRUE,
													WA_IDCMP, IDCMP_MOUSEBUTTONS|IDCMP_CLOSEWINDOW|IDCMP_RAWKEY,
													WA_DragBar, TRUE,
													WA_DepthGadget, TRUE,
													WA_RMBTrap, TRUE,
													WA_SizeGadget, TRUE,
													WA_MinWidth, 320,
													WA_MinHeight, 200,
													TAG_END)){
						BOOL terminate = FALSE;
						int mode = 0;
						UBYTE str[100];
						struct TmpRas TmpRas;
						struct RastPort *rp = wd->RPort;
						SHORT minx = 1024, miny = 1024, maxx = 0, maxy = 0;
						int i, j;
						
						for(i = 0; i < (sizeof(Figures)/sizeof(struct Figure)); i++){
							for(j = 1; j <= Figures[i].LineCnt; j++){
								SHORT x, y;
								x = Figures[i].Points[j].x + wd->BorderLeft;
								y = Figures[i].Points[j].y + wd->BorderTop;
								if(x < minx)	minx = x;
								if(y < miny)	miny = y;
								if(x > maxx)	maxx = x;
								if(y > maxy)	maxy = y;
							}
						}
						
						if(TmpRas.RasPtr = AllocMem(TmpRas.Size = RASSIZE(sc->Width, sc->Height), MEMF_CHIP|MEMF_CLEAR)){
							rp->TmpRas = &TmpRas;
						}
						
						do{
							BOOL redraw = FALSE;
							
							rp->Flags &= ~AREAOUTLINE;
							
							SetAPen(rp, 0);
							SetDrMd(rp, JAM1);
							RectFill(rp, minx, miny, maxx, maxy);

							SetAPen(rp, 1);
							SetDrMd(rp, JAM1);
							for(i = 0; i < (sizeof(Figures)/sizeof(struct Figure)); i++){
								Move(rp, Figures[i].Points[0].x + wd->BorderLeft, Figures[i].Points[0].y + wd->BorderTop);
								for(j = 1; j <= Figures[i].LineCnt; j++){
									Draw(rp, Figures[i].Points[j].x + wd->BorderLeft, Figures[i].Points[j].y + wd->BorderTop);
								}
							}
							
							sprintf(str, "Mode: %ld", mode);
							SetWindowTitles(wd, str, (UBYTE *)-1);

							SetAPen(rp, 2);
							SetDrMd(rp, JAM2);
							SetAfPt(rp, Muster, PatSize);
	//						SetAfPt(rp, NULL, 0);
							do{
								struct IntuiMessage *imsg, im;
								WaitPort(wd->UserPort);
								while(imsg = (struct IntuiMessage *)GetMsg(wd->UserPort)){
									im = *imsg;
									ReplyMsg((struct Message *)imsg);
									
									switch(im.Class){
									case	IDCMP_MOUSEBUTTONS:
										switch(im.Code){
										case SELECTDOWN:
											{
												SHORT x = im.MouseX, y = im.MouseY;
												if((x > minx) && (x < maxx) && (y > miny) && (y < maxy)){

													SetOutlinePen(rp, 1);
													Flood(rp, mode, x, y);
												}
											}
											break;
										case MENUDOWN:
											mode = 1 - mode;
											sprintf(str, "Mode: %ld", mode);
											SetWindowTitles(wd, str, (UBYTE *)-1);
											break;
										}
										break;
									case	IDCMP_RAWKEY:
										switch(im.Code){
										case 0x45:
											terminate = TRUE;
											break;
										case 0x40:
											redraw = TRUE;
											break;
										}
										break;
									case	IDCMP_CLOSEWINDOW:
										terminate = TRUE;
										break;
									}
								}
							}while(!redraw && !terminate);
							SetAfPt(rp, NULL, 0);

						}while(!terminate);
						if(TmpRas.RasPtr){
							FreeMem(TmpRas.RasPtr, TmpRas.Size);
						}
						CloseWindow(wd);
					}
					CloseScreen(sc);
				}
			}
		}else{
					if(wd = OpenWindowTags(NULL,
//													WA_CustomScreen, sc,
													WA_CloseGadget, TRUE,
													WA_Activate, TRUE,
													WA_IDCMP, IDCMP_MOUSEBUTTONS|IDCMP_CLOSEWINDOW|IDCMP_RAWKEY,
													WA_DragBar, TRUE,
													WA_DepthGadget, TRUE,
													WA_RMBTrap, TRUE,
													WA_SizeGadget, TRUE,
													WA_MinWidth, 320,
													WA_MinHeight, 200,
													TAG_END)){
						BOOL terminate = FALSE;
						int mode = 0;
						UBYTE str[100];
						struct TmpRas TmpRas;
						struct RastPort *rp = wd->RPort;
						SHORT minx = 1024, miny = 1024, maxx = 0, maxy = 0;
						int i, j;
						
						for(i = 0; i < (sizeof(Figures)/sizeof(struct Figure)); i++){
							for(j = 1; j <= Figures[i].LineCnt; j++){
								SHORT x, y;
								x = Figures[i].Points[j].x + wd->BorderLeft;
								y = Figures[i].Points[j].y + wd->BorderTop;
								if(x < minx)	minx = x;
								if(y < miny)	miny = y;
								if(x > maxx)	maxx = x;
								if(y > maxy)	maxy = y;
							}
						}
						
						if(TmpRas.RasPtr = AllocMem(TmpRas.Size = RASSIZE(maxx + 1, maxy + 1), MEMF_CHIP|MEMF_CLEAR)){
							rp->TmpRas = &TmpRas;
						}
						
						do{
							BOOL redraw = FALSE;
							
							rp->Flags &= ~AREAOUTLINE;
							
							SetAPen(rp, 0);
							SetDrMd(rp, JAM1);
							RectFill(rp, minx, miny, maxx, maxy);

							SetAPen(rp, 1);
							SetDrMd(rp, JAM1);
							for(i = 0; i < (sizeof(Figures)/sizeof(struct Figure)); i++){
								Move(rp, Figures[i].Points[0].x + wd->BorderLeft, Figures[i].Points[0].y + wd->BorderTop);
								for(j = 1; j <= Figures[i].LineCnt; j++){
									Draw(rp, Figures[i].Points[j].x + wd->BorderLeft, Figures[i].Points[j].y + wd->BorderTop);
								}
							}
							
							sprintf(str, "Mode: %ld", mode);
							SetWindowTitles(wd, str, (UBYTE *)-1);

							SetAPen(rp, 2);
							SetDrMd(rp, JAM2);
							SetAfPt(rp, Muster, PatSize);
	//						SetAfPt(rp, NULL, 0);
							do{
								struct IntuiMessage *imsg, im;
								WaitPort(wd->UserPort);
								while(imsg = (struct IntuiMessage *)GetMsg(wd->UserPort)){
									im = *imsg;
									ReplyMsg((struct Message *)imsg);
									
									switch(im.Class){
									case	IDCMP_MOUSEBUTTONS:
										switch(im.Code){
										case SELECTDOWN:
											{
												SHORT x = im.MouseX, y = im.MouseY;
												if((x > minx) && (x < maxx) && (y > miny) && (y < maxy)){

													SetOutlinePen(rp, 1);
													Flood(rp, mode, x, y);
												}
											}
											break;
										case MENUDOWN:
											mode = 1 - mode;
											sprintf(str, "Mode: %ld", mode);
											SetWindowTitles(wd, str, (UBYTE *)-1);
											break;
										}
										break;
									case	IDCMP_RAWKEY:
										switch(im.Code){
										case 0x45:
											terminate = TRUE;
											break;
										case 0x40:
											redraw = TRUE;
											break;
										}
										break;
									case	IDCMP_CLOSEWINDOW:
										terminate = TRUE;
										break;
									}
								}
							}while(!redraw && !terminate);
							SetAfPt(rp, NULL, 0);

						}while(!terminate);
						if(TmpRas.RasPtr){
							FreeMem(TmpRas.RasPtr, TmpRas.Size);
						}
						CloseWindow(wd);
					}
		}
		FreeArgs(rda);
	}
}

static BOOL GetHexBinDecStrValue(char *str, LONG *result)
{
	BOOL	negative;
	register LONG	z=0L;
	register char	b;
	if(str){
		while( *str == ' ' || *str == '\t' ) str++;		// Leerzeichen überlesen
		if(negative = ( *str=='-' ) )	 str++;				// Negativ ?
		if( *str == '$' ){		// Hex ?
			str++;
			while(b = *str++){
				if( (b >= '0') && (b <= '9') ){
					z *= 16;
					z += (ULONG)(b - '0');
				}else{
					b |= ' ';
					if( (b >= 'a') && (b <= 'f') ){
						z *= 16;
						z += (ULONG)(b - 'a' + 10);
					}else{
						return(FALSE);
					}
				}
			}
		}else if( *str == '%' ){		// Bin ??
			str++;
			while(b = *str++){
				if( (b >= '0') && (b <= '1') ){
					z *= 2;
					z += (ULONG)(b - '0');
				}else{
					return(FALSE);
				}
			}
		}else{		// Dec !
			while(b =* str++){
				if( (b >= '0') && (b <= '9') ){
					z =  (z << 3) + z + z;
					z += (ULONG)(b - '0');
				}else return(FALSE);
			}
		}
		*result = (negative ? -z : z);
		return(TRUE);
	}
	return(FALSE);
}
