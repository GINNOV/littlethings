#include <intuition/intuition.h>
#include <graphics/rastport.h>
#include <devices/inputevent.h>

#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/exec.h>

#include <stdio.h>
#include <stdlib.h>

int main(void)
{
	struct Window *wd;
	
	if(wd = OpenWindowTags(NULL,
						WA_Width, 400,
						WA_Height, 300,
						WA_Title, "InvertTest",
						WA_SizeGadget, TRUE,
						WA_DragBar, TRUE,
						WA_CloseGadget, TRUE,
						WA_DepthGadget, TRUE,
						WA_SizeGadget, TRUE,
						WA_RMBTrap, TRUE,
//						WA_SimpleRefresh, TRUE,
						WA_SmartRefresh, TRUE,
						WA_MinWidth, 100,
						WA_MinHeight, 100,
						WA_MaxWidth, 1000,
						WA_MaxHeight, 750,
						WA_IDCMP, IDCMP_MOUSEBUTTONS|IDCMP_CLOSEWINDOW|IDCMP_RAWKEY|IDCMP_CHANGEWINDOW|IDCMP_SIZEVERIFY|IDCMP_NEWSIZE,
						TAG_END)){
		BOOL terminate = FALSE;
		struct RastPort *rp = wd->RPort;
		BYTE FillPen = rp->BgPen;
		BOOL mayDraw = FALSE;
		WORD oldX = 0, oldY = 0, newX = 0, newY = 0;
		WORD numcolors = (1<<wd->WScreen->RastPort.BitMap->Depth);
				
		while(!terminate){
			struct IntuiMessage *imsg;
			WaitPort(wd->UserPort);
			while(imsg = (struct IntuiMessage *)GetMsg(wd->UserPort)){
				ULONG class;
				UWORD code;
				UWORD qualifier;
				WORD mouseX, mouseY;
				
				class = imsg->Class;
				code = imsg->Code;
				qualifier = imsg->Qualifier;
				mouseX = imsg->MouseX;
				mouseY = imsg->MouseY;
				
				ReplyMsg((struct Message *)imsg);
				
//				printf("class %ld code %ld qualifier %ld mouseX %ld mouseY %ld\n",class, code, qualifier, mouseX, mouseY);

				switch(class){
				case IDCMP_SIZEVERIFY:
					break;
				case IDCMP_NEWSIZE:
					break;
				case IDCMP_MOUSEBUTTONS:
					switch(code){
					case SELECTUP:
//						printf("up\n");
						if(mayDraw){
							if((mouseX < wd->BorderLeft)
							|| (mouseY < wd->BorderTop)
							|| (mouseX >= (wd->Width-wd->BorderRight))
							|| (mouseY >= (wd->Height-wd->BorderBottom))){
							}else{
								newX = mouseX;
								newY = mouseY;
								if(qualifier & IEQUALIFIER_LSHIFT){
									WORD deltaX, deltaY;
									deltaX = abs(newX - oldX);
									deltaY = abs(newY - oldY);
									
									if(deltaX > deltaY){
										newY = oldY;
									}else if(deltaX < deltaY){
										newX = oldX;
									}
								}
								
								SetDrMd(rp, COMPLEMENT);
								printf("Flags: %04lx - before\n", rp->Flags);
								Draw(rp, newX, newY);
								printf("Flags: %04lx - after\n", rp->Flags);
								mayDraw = FALSE;
							}
						};
						break;
					case SELECTDOWN:
//						printf("down\n");
						if((mouseX < wd->BorderLeft)
						|| (mouseY < wd->BorderTop)
						|| (mouseX >= (wd->Width-wd->BorderRight))
						|| (mouseY >= (wd->Height-wd->BorderBottom))){
							mayDraw = FALSE;
						}else{
							Move(rp, oldX = mouseX, oldY = mouseY);
							if(qualifier & IEQUALIFIER_CONTROL){
								printf("Flags: %04lx - Clear FRST_DOT\n", rp->Flags);
								rp->Flags &= ~FRST_DOT;
								printf("Flags: %04lx\n", rp->Flags);
							}
							mayDraw = TRUE;
						}
						break;
					case MENUUP:
//						printf("right\n");
						SetDrMd(rp, JAM1);
//						EraseRect(rp, wd->BorderLeft, wd->BorderTop, (wd->Width-wd->BorderRight-1), (wd->Height-wd->BorderBottom-1));
						RectFill(rp, wd->BorderLeft, wd->BorderTop, (wd->Width-wd->BorderRight-1), (wd->Height-wd->BorderBottom-1));
						break;
					case MIDDLEUP:
//						printf("middle\n");
						if(qualifier & IEQUALIFIER_LSHIFT){
							FillPen--;
						}else{
							FillPen++;
						}
						FillPen = (FillPen+numcolors) % numcolors;
						SetAPen(rp, FillPen);
//						printf("FillPen %ld FgPen %ld BgPen %ld\n", FillPen, rp->FgPen, rp->BgPen);
//						EraseRect(rp, wd->BorderLeft, wd->BorderTop, (wd->Width-wd->BorderRight-1), (wd->Height-wd->BorderBottom-1));
						SetDrMd(rp, JAM1);
						RectFill(rp, wd->BorderLeft, wd->BorderTop, (wd->Width-wd->BorderRight-1), (wd->Height-wd->BorderBottom-1));
						break;
					}
					break;
				case IDCMP_CLOSEWINDOW:
					terminate = TRUE;
					break;
				case IDCMP_RAWKEY:
					break;
				case IDCMP_CHANGEWINDOW:
					break;
				}
			}
		}
		
		CloseWindow(wd);
	}
}
