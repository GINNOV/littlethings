#include <intuition/screens.h>
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/layers.h>
#include <proto/dos.h>
#include <proto/rtg.h>

#include	<stdio.h>
#include	<math.h>

char template[] = "Pubscreen=PS/K";
char *array[] = {"Workbench"};

LONG	pen;

main(void)
{
  struct RTGBase *RTGBase;
  struct RDArgs	*rda = NULL;
  
  rda = ReadArgs(template,(LONG *)array,NULL);
  
  /*
  ** the memory window is currently still a feature of the rtg.library, not
  ** the P96APILibrary, i.e. it is a private feature. This should really
  ** be migrated to the P96APILibrary.
  */
  
  if(RTGBase=(struct RTGBase *)OpenLibrary("picasso96/rtg.library",40)){

    struct Screen		*sc;
    
    if(sc = LockPubScreen(array[0])){
      struct Window		*wd;
      
      pen = ObtainPen(sc->ViewPort.ColorMap, -1, 0x11111111, 0, 0x11111111, PEN_EXCLUSIVE);
      if(pen != -1){
	struct SpecialFeature	*spec;
	
	spec = rtgCreateSpecialFeatureTags(sc, SFT_MEMORYWINDOW,
					   FA_Format, RGBFB_R5G6B5PC,
					   FA_Color, pen,
					   FA_SourceWidth, 320,
					   FA_SourceHeight, 200,
					   TAG_DONE);
	/*
	** Ok, if that did not work, it might be that the apperture is not right. Try with non-PC
	** as mode.
	*/
	if (!spec) {
	  spec = rtgCreateSpecialFeatureTags(sc, SFT_MEMORYWINDOW,
					     FA_Format, RGBFB_R5G6B5,
					     FA_Color, pen,
					     FA_SourceWidth, 320,
					     FA_SourceHeight, 200,
					     TAG_DONE);
	}

	if (spec) {
	  ULONG	MinWidth = 320, MinHeight = 200, MaxWidth = 320, MaxHeight = 200;
	  struct BitMap		*bm = NULL;
	  
	  rtgGetSpecialFeatureAttrsTags(spec,
					FA_MinWidth, &MinWidth,
					FA_MinHeight, &MinHeight,
					FA_MaxWidth, &MaxWidth,
					FA_MaxHeight, &MaxHeight,
					FA_BitMap, &bm,
					TAG_DONE);
	  
	  if(wd=OpenWindowTags(NULL,
			       WA_Title, "PicassoIV PIP Test",
			       WA_Activate, TRUE,
			       WA_RMBTrap, TRUE,
			       WA_Left, (sc->Width-320)/2,
			       WA_Top, (sc->Height-200)/2,
			       WA_InnerWidth, max(MinWidth,320),
			       WA_InnerHeight, max(MinHeight,200),
			       WA_DragBar, TRUE,
			       WA_NotifyDepth, TRUE,
			       WA_DepthGadget, TRUE,
			       WA_SimpleRefresh, TRUE,
			       WA_SizeGadget, TRUE,
			       WA_CloseGadget, TRUE,
			       WA_IDCMP, IDCMP_REFRESHWINDOW|IDCMP_CLOSEWINDOW|IDCMP_CHANGEWINDOW|IDCMP_ACTIVEWINDOW|IDCMP_INACTIVEWINDOW,
			       WA_PubScreen, sc, TAG_DONE)){
	    
	    struct Message		*msg;
	    struct RastPort	rp;
	    BOOL	goahead = TRUE;
	    BOOL	front = TRUE;
	    
	    InitRastPort(&rp);
	    WindowToFront(wd);
	    WindowLimits(wd,
			 max(MinWidth,320)+wd->BorderLeft+wd->BorderRight,
			 max(MinHeight,200)+wd->BorderTop+wd->BorderBottom,
			 MaxWidth+wd->BorderLeft+wd->BorderRight,
			 MaxHeight+wd->BorderTop+wd->BorderBottom);
	    
	    SetAPen(wd->RPort, pen);
	    RectFill(wd->RPort,
		     wd->BorderLeft, wd->BorderTop,
		     wd->Width - 1 - wd->BorderRight, wd->Height - 1 - wd->BorderBottom);
	    
	    rtgSetSpecialFeatureAttrsTags(spec,
					  FA_Active, TRUE,
					  FA_Onboard, TRUE,
					  FA_Left, wd->LeftEdge + wd->BorderLeft,
					  FA_Top, wd->TopEdge + wd->BorderTop,
					  FA_Width, wd->Width - wd->BorderLeft - wd->BorderRight,
					  FA_Height, wd->Height - wd->BorderTop - wd->BorderBottom,
					  TAG_DONE);
	    
	    rp.BitMap = bm;						
	    
	    /* time to draw something (or maybe later) */
	    
	    if(bm)
	      DrawEllipse(&rp, 160, 100, 60, 40);
	    
	    
	    do{
	      BOOL	size = FALSE;
	      
	      WaitPort(wd->UserPort);
	      while(msg = GetMsg(wd->UserPort)){
		struct IntuiMessage	*imsg = (struct IntuiMessage *)msg;
		switch(imsg->Class){
		case	IDCMP_CLOSEWINDOW:
		  goahead = FALSE;
		  break;
		case	IDCMP_ACTIVEWINDOW:
		  // This is a layer v45 call. Works from 3.1.4 above.
		  front = !LayerOccluded(wd->WLayer);
		  break;
		case	IDCMP_INACTIVEWINDOW:
		  front = FALSE;
		  break;
		case	IDCMP_CHANGEWINDOW:
		  switch(imsg->Code){
		  case	CWCODE_MOVESIZE:
		    size = TRUE;	
		  case	CWCODE_DEPTH:
		    front = !LayerOccluded(wd->WLayer);
		    break;
		  }
		  break;
		case	IDCMP_REFRESHWINDOW:
		  BeginRefresh(wd);
		  RectFill(wd->RPort,
			   wd->BorderLeft, wd->BorderTop,
			   wd->Width - 1 - wd->BorderRight, wd->Height - 1 - wd->BorderBottom);
		  EndRefresh(wd, TRUE);
		  break;
		}
		ReplyMsg(msg);
	      }
	      rtgSetSpecialFeatureAttrsTags(spec,
					    FA_Occlusion, !front,
					    FA_Left, wd->LeftEdge + wd->BorderLeft,
					    FA_Top, wd->TopEdge + wd->BorderTop,
					    FA_Width, wd->Width - wd->BorderLeft - wd->BorderRight,
					    FA_Height, wd->Height - wd->BorderTop - wd->BorderBottom,
					    TAG_DONE);
	    }while(goahead);
	    
	    rtgSetSpecialFeatureAttrsTags(spec, FA_Active, FALSE, TAG_DONE);
	    
	    SetAPen(wd->RPort, 0);
	    RectFill(wd->RPort,
		     wd->BorderLeft, wd->BorderTop,
		     wd->Width - 1 - wd->BorderRight, wd->Height - 1 - wd->BorderBottom);
	    
	    Forbid();
	    while(msg = GetMsg(wd->UserPort)) ReplyMsg(msg);
	    Permit();
	    
	    CloseWindow(wd);
	  }
	  rtgDeleteSpecialFeature(spec);
	}
	ReleasePen(sc->ViewPort.ColorMap, pen);
      }
      UnlockPubScreen(NULL, sc);
    }
    CloseLibrary((struct Library *)RTGBase);
  }
  if(rda)
    FreeArgs(rda);
}
