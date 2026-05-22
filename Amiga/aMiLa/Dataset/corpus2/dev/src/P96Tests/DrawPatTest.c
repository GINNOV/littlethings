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
			 WA_Title, "DrawPatTest",
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
			 WA_IDCMP,
			 IDCMP_MOUSEBUTTONS|IDCMP_INTUITICKS|IDCMP_CLOSEWINDOW|IDCMP_RAWKEY|IDCMP_CHANGEWINDOW|IDCMP_SIZEVERIFY|IDCMP_NEWSIZE,
			 TAG_END)) {
    BOOL terminate = FALSE;
    struct RastPort *rp = wd->RPort;
    BYTE FillPen = rp->BgPen;
    BOOL mayDraw = FALSE;
    BOOL drawn   = FALSE;
    WORD oldX = 0, oldY = 0, newX = 0, newY = 0;
				
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
	
	switch(class){
	case IDCMP_SIZEVERIFY:
	  break;
	case IDCMP_NEWSIZE:
	  break;
	case IDCMP_INTUITICKS:
	  if (drawn) {
	    SetDrMd(rp, COMPLEMENT);
	    Move(rp, oldX, oldY);
	    Draw(rp, newX, newY);
	    drawn = FALSE;
	  }
	  if (mayDraw) {
	    newX = wd->MouseX;
	    newY = wd->MouseY;
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
	    Move(rp, oldX, oldY);
	    Draw(rp, newX, newY);
	    drawn = TRUE;
	  }
	  break;
	case IDCMP_MOUSEBUTTONS:
	  switch(code){
	  case SELECTUP:
	    drawn = FALSE;
	    printf("stop drawing to (%d,%d)\n",newX,newY);
	    break;
	  case SELECTDOWN:
	    if((mouseX < wd->BorderLeft) || (mouseY < wd->BorderTop) ||
	       (mouseX >= (wd->Width-wd->BorderRight)) || (mouseY >= (wd->Height-wd->BorderBottom))) {
	      mayDraw = FALSE;
	    } else {
	      oldX = mouseX;
	      oldY = mouseY;
	      if(qualifier & IEQUALIFIER_CONTROL){
		rp->LinePtrn = 0xff00;
	      } else {
		rp->LinePtrn = 0xffff;
	      }
	      mayDraw = TRUE;
	      printf("start drawing from (%d,%d)\n",oldX,oldY);
	    }
	    break;
	  case MENUUP:
	    SetDrMd(rp, JAM1);
	    SetAPen(rp, 0);
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
