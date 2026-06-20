#include "shuttlewheel.c"

extern struct SysBase	*SysBase;
struct Library 	*UtilityBase,
		*MathIeeeSingTransBase,
		*MathIeeeSingBasBase;
struct Window  	*win;
struct RastPort *Rasty;

struct TagItem toint[] = { SW_Current, PGA_Top, TAG_END };
struct TagItem tojgs[] = { PGA_Top, SW_Current, TAG_END };

void main(void)
{
 Class 			*gclass;
 struct DrawInfo	*dri;
 BOOL 			 quit = FALSE;	
 
 SysBase = (*(struct SysBase **)4L);
 
 UtilityBase = (struct Library *)OldOpenLibrary((STRPTR)"utility.library");
 MathIeeeSingTransBase = (struct Library *)OldOpenLibrary((STRPTR)"mathieeesingtrans.library");
 MathIeeeSingBasBase   = (struct Library *)OldOpenLibrary((STRPTR)"mathieeesingbas.library");

 gclass = InitShuttleWheelClass();
 
 win = OpenWindowTags(NULL, WA_Height, 200, WA_Width, 400,
			    WA_IDCMP, IDCMP_CLOSEWINDOW|IDCMP_GADGETUP|IDCMP_IDCMPUPDATE
				     |IDCMP_VANILLAKEY, 
			    WA_Flags, WFLG_GIMMEZEROZERO|WFLG_CLOSEGADGET, 
			    TAG_END);
 Rasty = win->RPort;
 dri = GetScreenDrawInfo(win->WScreen);

 if(win) 
 { 
  void *obj, *obj2; UBYTE buff[20];

  obj = NewObject( gclass, NULL, GA_Left, 15,
				 GA_Top, 30,
				 GA_Width, 160,
				 GA_Height, 140,
				 GA_DrawInfo, dri,
				 ICA_MAP, toint,
			  	 SW_Min, 0,
				 SW_Max, 400,
				 SW_Current, 200,				
				 TAG_DONE);

  obj2 = NewObject( NULL, "propgclass", 
				 GA_Left, 180,
				 GA_Top, 30, 
				 GA_Width, 30,
				 GA_Height, 140,				 	
				 GA_Previous, obj,
				 PGA_Top, 0,
				 PGA_Visible, 1,
				 PGA_Total, 400,
				 PGA_NewLook, TRUE,/*
				 STRINGA_LongVal, 90,
				 STRINGA_MaxChars, 11,
				 STRINGA_WorkBuffer, buff,*/
				 ICA_MAP, tojgs,
				 ICA_TARGET, obj ,
				 TAG_DONE);
 
  AddGList(win, obj, -1, -1, NULL);
  RefreshGadgets(obj, win, NULL); SetAPen(win->RPort, 1); 

  SetGadgetAttrs(obj, win, NULL, ICA_TARGET, obj2, TAG_DONE);

  while(!quit) {
   struct IntuiMessage *imsg;

   WaitPort(win->UserPort);
   while(imsg = (struct IntuiMessage *)GetMsg(win->UserPort)) {
    if(imsg->Class == IDCMP_CLOSEWINDOW) quit = TRUE;

	if(imsg->Class == IDCMP_IDCMPUPDATE) 
		Printf("%3ld\r", imsg->Code);
		
    ReplyMsg((struct Message *)imsg);
   }
  }

  DisposeObject(obj);  DisposeObject(obj2);  
  FreeShuttleWheelClass(gclass);
  CloseWindow(win);
 }

 FreeScreenDrawInfo(win->WScreen, dri);
 CloseLibrary( UtilityBase );
 CloseLibrary( MathIeeeSingTransBase );
 CloseLibrary( MathIeeeSingBasBase );
}
