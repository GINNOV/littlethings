/*==========================================================================*/
#ifdef __amigaos4__
#define OS4
#else
#define OS3
#endif
/*==================================================================================*/
#ifdef OS4
#define __USE_INLINE__
#define __USE_BASETYPE__
#define __USE_OLD_TIMEVAL__
#pragma pack(2)
#endif
/*==================================================================*/
#include <stdio.h>
#include <math.h>
#include <time.h>
#include <stdlib.h>
#include <strings.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/gadtools.h>
#include <proto/asl.h>

#include <dos/dos.h>
#include <dos/dostags.h>

struct IntuitionBase*		IntuitionBase	=NULL;
struct GfxBase*			GfxBase		=NULL;
struct Library*				GadToolsBase=NULL;
struct Library*		AslBase			=NULL;

#ifdef OS4
struct GraphicsIFace*		IGraphics		=NULL;
struct IntuitionIFace*		IIntuition		=NULL;
struct GadToolsIFace*		IGadTools		=NULL;
struct AslIFace*				IAsl 				=NULL;
#endif

#ifdef OS4
#define USEOBJDUMP
#endif
#ifdef OS3
#define USEADIS
#endif
#ifdef __MORPHOS__
#define USEOBJDUMP
#endif
/*==================================================================*/
struct Window  *window		=NULL;

struct Gadget    *glist, *gad;
struct NewGadget *ng;
ULONG *button2funcnum;
void             *vi;
static struct TextAttr Topaz80 = {"topaz.font", 8, 0, 0,};
ULONG winlarge=800;
ULONG winhigh =600;
APTR gadgets;
LONG ok;
BOOL debug=FALSE;
BOOL ReadASM(char* filename);
/*=================================================================*/
#define REM(message)  {printf(#message"\n");}
#define    VAR(var)   {printf(" " #var "=%ld\n", ((ULONG)var)  );}
#define   VARS(var)   {printf(" " #var "=<%s>\n",var); }

ULONG asmline=0;
#define STEP(tex)     {OSAlert(#tex);}
#define ZZ            {OSAlert("OK");}
#define LL            {printf("Line:%ld\n",__LINE__);}
#define AA            { asmline= __LINE__ ;  printf("Line:%ld\n",asmline); asmline= 1234;  }
#define LLL           {printf("Line:%ld\n",__LINE__); OSAlert("OK");}

#define NLOOP(nbre) for(n=0;n<nbre;n++)
#define SWAP(x,y) {temp=x;x=y;y=temp;}
/*=================================================================*/
#define LIBCLOSE(libbase)	 if(libbase!=NULL)	{CloseLibrary( (struct Library  *)libbase );   libbase=NULL; }
#define LIBOPEN(libbase,name,version)  libbase	=(void*)OpenLibrary(#name,version);				if(libbase==NULL) 	return(FALSE);
#ifdef OS4
#define LIBOPEN4(interface,libbase)    interface=(void*)GetInterface((struct Library *)libbase, "main", 1, NULL);	if(interface==NULL)	return(FALSE);
#define LIBCLOSE4(interface) if(interface!=NULL)	{DropInterface((struct Interface*)interface );interface=NULL;}
#else
#define LIBOPEN4(interface,libbase)    ;
#define LIBCLOSE4(interface) ;	
#endif
/*==================================================================*/
void OSAlert(void *p1)
{
UBYTE *t=p1;
void *Data=&t+1L;
struct EasyStruct EasyStruct;
ULONG IDCMPFlags;

	EasyStruct.es_StructSize=sizeof(struct EasyStruct);
	EasyStruct.es_Flags=0L;
	EasyStruct.es_Title=(void *)"Message:";
	EasyStruct.es_TextFormat=(void*)t;
	EasyStruct.es_GadgetFormat=(void*)"OK";

	IDCMPFlags=0L;
	(void)EasyRequestArgs(NULL,&EasyStruct,&IDCMPFlags,Data);
	return;
}
/*=================================================================*/
BOOL MyOpenWin(UBYTE *name,UWORD winwidth, UWORD winheight)
{
struct Screen  *screen		=NULL;
UWORD screenwidth,screenheight;
ULONG Flags =WFLG_ACTIVATE | WFLG_REPORTMOUSE | WFLG_RMBTRAP | WFLG_SIMPLE_REFRESH | WFLG_GIMMEZEROZERO ;
ULONG IDCMPs=IDCMP_CLOSEWINDOW | IDCMP_VANILLAKEY | IDCMP_RAWKEY | IDCMP_MOUSEMOVE | IDCMP_MOUSEBUTTONS | IDCMP_GADGETDOWN  |  IDCMP_GADGETUP;
ULONG ModeID;


	LIBOPEN(IntuitionBase,intuition.library,0)
	LIBOPEN(GfxBase,graphics.library,0)
	LIBOPEN(GadToolsBase,gadtools.library,37)
	LIBOPEN(AslBase,asl.library,37)

	LIBOPEN4(IExec,SysBase)
	LIBOPEN4(IGraphics,GfxBase)
	LIBOPEN4(IIntuition,IntuitionBase)
	LIBOPEN4(IGadTools,GadToolsBase)
	LIBOPEN4(IAsl,AslBase)

	screen 		=LockPubScreen("Workbench") ;
	screenwidth		=screen->Width;
 	screenheight	=screen->Height;
	ModeID = GetVPModeID(&screen->ViewPort);

	vi=GetVisualInfo(screen, TAG_END);

	UnlockPubScreen(NULL, screen);

	window = OpenWindowTags(NULL,
	WA_Activate,	TRUE,
	WA_InnerWidth,	winwidth,
	WA_InnerHeight,	winheight,
	WA_Left,		(screenwidth -  winwidth)/2,
	WA_Top,		(screenheight  -  winheight )/2,
	WA_Title,		(ULONG)name,
	WA_DragBar,		TRUE,
	WA_CloseGadget,	TRUE,
	WA_GimmeZeroZero,	TRUE,
	WA_Backdrop,	FALSE,
	WA_Borderless,	FALSE,
	WA_IDCMP,		IDCMPs,
	WA_Flags,		Flags,
	TAG_DONE);
	if(window==NULL)
		{printf("Cant open window\n");return FALSE;}

	ng=malloc(sizeof(struct NewGadget)*500);
	button2funcnum=malloc(sizeof(ULONG)*500);

	return(TRUE);
}
/*=================================================================*/
void MyCloseWin(void)
{
	RemoveGList(window,glist,-1); 
	FreeGadgets( glist );
	window->FirstGadget=NULL;
	
	FreeVisualInfo(vi);
	if (window)	CloseWindow(window);
	free(ng);
	free(button2funcnum);

	LIBCLOSE4(IGraphics)
	LIBCLOSE4(IIntuition)
	LIBCLOSE4(IGadTools)
	LIBCLOSE4(IAsl)

	LIBCLOSE(IntuitionBase)
	LIBCLOSE(GfxBase)
	LIBCLOSE(GadToolsBase)
	LIBCLOSE(AslBase)
}
/*=================================================================*/
void MyWindowManager(void)
{
struct IntuiMessage *imsg;
struct Gadget *gad;
struct MenuItem   *item=NULL;
UWORD menuNumber,key;

	P.command=0;
	key=0;

	while( (imsg = GT_GetIMsg(window->UserPort)))
	{
		if (imsg == NULL) break;
		switch (imsg->Class)
			{
			case IDCMP_CLOSEWINDOW:
				P.closed=TRUE;		break;
			case IDCMP_VANILLAKEY:
				key=imsg->Code;		break;
			case IDCMP_RAWKEY:
				key=imsg->Code;		break;

				case IDCMP_MENUPICK:
				menuNumber=imsg->Code;
				if(menuNumber != MENUNULL)
					item=ItemAddress(window->MenuStrip,menuNumber);
				if(item)
					P.command=(UBYTE)item->Command;
				break;

			case IDCMP_GADGETUP:
				gad = (struct Gadget *)(imsg->IAddress);
				P.command=gad->GadgetID;
				break;
			case IDCMP_GADGETDOWN:
				gad = (struct Gadget *)(imsg->IAddress);
				P.command=0;
				break;;
			default:
				break;
			}

		switch(key)
		{
		case CURSORUP:
			P.command=9;
			break;
		case CURSORDOWN:
			P.command=8;
			break;
		case 'q':
		case 'Q':
		case 27:
			P.closed=TRUE;
		default:
			break;
		}

		if(imsg)
			{GT_ReplyIMsg(imsg);imsg = NULL;}
	}

}
/*=================================================================*/
void ResizeName(UBYTE *name,ULONG size)
{
ULONG n;

	n=strlen(name);
	while(n<size)
		name[n++]=' ';
	name[size]=0;
}
/*=================================================================*/
void SetButton(ULONG n,ULONG x,ULONG y,ULONG large,ULONG high,UBYTE *name)
{
	ng[n].ng_VisualInfo = vi;
	ng[n].ng_LeftEdge   = x;
	ng[n].ng_TopEdge    = y;
	ng[n].ng_Width      = large;
	ng[n].ng_Height     = high;
	ng[n].ng_GadgetID   = n+1;
	ng[n].ng_Flags      = 0;

	ng[n].ng_TextAttr   = &Topaz80;
	ng[n].ng_GadgetText = name;
	gad = CreateGadget(BUTTON_KIND, gad, &ng[n],TAG_END);

}
/*=================================================================*/
void SetButton2(ULONG n,ULONG x,ULONG y,ULONG large,ULONG high,UBYTE *name,BOOL on)
{
	ng[n].ng_VisualInfo = vi;
	ng[n].ng_LeftEdge   = x;
	ng[n].ng_TopEdge    = y;
	ng[n].ng_Width      = large;
	ng[n].ng_Height     = high;
	ng[n].ng_GadgetID   = n+1;
	ng[n].ng_Flags      = 0;

	ng[n].ng_TextAttr   = &Topaz80;
	ng[n].ng_GadgetText = name;
	gad = CreateGadget(CHECKBOX_KIND, gad, &ng[n],GT_Underscore, '_',GTCB_Scaled, TRUE,GTCB_Checked,on,TAG_DONE);

}
/*=================================================================*/
void DoFuncsMenus(void)
{
ULONG x,y;
UWORD large,large1,large2,large3,high;

//	REM(DoFuncsMenus)
	large1=(15*8);
	large2=winlarge/2 - large1; 
	large3=winlarge/12;
	high=20;
	x=0; y=0;

	SetButton2(13,x-20+large1,y,20,high,"Offset",(P.order=='O') ); x=x+large1;
	SetButton2(12,x-20+large2,y,20,high,"Function Name",(P.order=='N') ); x=x+large2;
	SetButton2(11,x-20+large3,y,20,high,"Size",(P.order=='S') ); x=x+large3;
	SetButton2(10,x-20+large3,y,20,high,"Call",(P.order=='c') ); x=x+large3;
	SetButton2(9,x-20+large3,y,20,high,"Called",(P.order=='C') ); x=x+large3;
	SetButton2(8,x-20+large3,y,20,high,"Branch",(P.order=='B') ); x=x+large3;
	SetButton2(7,x-20+large3,y,20,high,"Stack",(P.order=='p') ); x=x+large3;
	SetButton2(6,x-20+large3,y,20,high,"StackR",(P.order=='P') ); x=x+large3;

	large=30; high=20;
	x=winlarge-6*large; y=winhigh-20;
	SetButton(5 ,x,y,large,high,"|<"); x=x+large;
	SetButton(4 ,x,y,large,high,"<<"); x=x+large;
	SetButton(3 ,x,y,large,high," <"); x=x+large;
	SetButton(2 ,x,y,large,high," >"); x=x+large;
	SetButton(1 ,x,y,large,high,">>"); x=x+large;
	SetButton(0 ,x,y,large,high,">|"); x=x+large;	
	
}	
/*=================================================================*/
void DoFuncsList(void)
{
struct myfunc *func;
struct myfunc *funca;
struct myfunc *funcb;
struct myfunc *a;
struct myfunc *b;
ULONG nb=(P.funcnb-1);
ULONG n,f,x,y;
UWORD large1,large2,large3,high;
APTR temp;


//	REM(DoFuncsList)
	glist=NULL;
	gad=CreateContext(&glist);

	if(!P.sorted)
	NLOOP(P.funcnb)
	{
		func=&P.allfuncs[n];
		func->funcsorted=func;
	}

	nb=(P.funcnb-1);

	if(P.order!='O')
	while(!P.sorted)
	{
	P.sorted=TRUE;
		NLOOP(nb)
		{
		a=&P.allfuncs[n];
		b=&P.allfuncs[n+1];
		funca=a->funcsorted;
		funcb=b->funcsorted;
	
		if(P.order=='N')
		if(strcmp(funca->name,funcb->name)>0)
			{ SWAP(a->funcsorted,b->funcsorted); P.sorted=FALSE; }

		if(P.order=='S')
		if(! (funca->size <= funcb->size) )
			{ SWAP(a->funcsorted,b->funcsorted); P.sorted=FALSE; }
		if(P.order=='c')
		if(! (funca->callnb <= funcb->callnb) )
			{ SWAP(a->funcsorted,b->funcsorted); P.sorted=FALSE; }
		if(P.order=='C')
		if(! (funca->callednb <= funcb->callednb) )
			{ SWAP(a->funcsorted,b->funcsorted); P.sorted=FALSE; }
		if(P.order=='B')
		if(! (funca->branchnb <= funcb->branchnb) )
			{ SWAP(a->funcsorted,b->funcsorted); P.sorted=FALSE; }
		if(P.order=='p')
		if(! (funca->stack <= funcb->stack) )
			{ SWAP(a->funcsorted,b->funcsorted); P.sorted=FALSE; }
		if(P.order=='P')
		if(! (funca->stackr <= funcb->stackr) )
			{ SWAP(a->funcsorted,b->funcsorted); P.sorted=FALSE; }
		}
	}

	DoFuncsMenus();
	
	large1=(15*8);
	large2=winlarge/2 - large1; high=20;
	large3=winlarge/12;
	x=0; y=2+30;

	f=P.funcstart;
	n=P.guinb;
	P.funclistnb=(winhigh-y-30)/20+1;
	while( y < (winhigh-30) )
	{	
	if( f < P.funcnb)
		{
		func=&P.allfuncs[f];
		func=func->funcsorted;

		x=0;
		button2funcnum[n]=func->funcnum;
		SetButton(n++,x,y,large1,high,func->offsetname);	x=x+large1;

		button2funcnum[n]=func->funcnum;
		SetButton(n++,x,y,large2,high,func->name);			x=x+large2;

		button2funcnum[n]=func->funcnum;
		SetButton(n++,x,y,large3,high,func->sizename);		x=x+large3;
			
		button2funcnum[n]=func->funcnum;
		SetButton(n++,x,y,large3,high,func->callname);		x=x+large3;

		button2funcnum[n]=func->funcnum;
		SetButton(n++,x,y,large3,high,func->calledname);	x=x+large3;
		
		button2funcnum[n]=func->funcnum;
		SetButton(n++,x,y,large3,high,func->branchname);	x=x+large3;
		
		button2funcnum[n]=func->funcnum;
		SetButton(n++,x,y,large3,high,func->stackname);		x=x+large3;
		
		button2funcnum[n]=func->funcnum;
		SetButton(n++,x,y,large3,high,func->stackrname);	x=x+large3;
		}
	f++;
	y=y+high;
	}

	AddGList(window,glist,0,-1,NULL);
	RefreshGList(glist,window,NULL,-1);

}
/*=================================================================*/
void DoFuncCalls(void)
{
struct myfunc *func;
struct myfunc *currentfunc;
struct mycall *call;
ULONG c,n,callnum;
UWORD x,y,large,high;

	if(debug) REM(DoFuncCalls)
	glist=NULL;
	gad=CreateContext(&glist);

	DoFuncsMenus();

	large=winlarge/3;	high=20;
	x=2+large-20;	y=2+30;
	n=P.guinb;

	currentfunc=&P.allfuncs[P.funcnum];
	sprintf(P.currentfuncbuttonname,"%s (%ld bytes)Stack:%ld",currentfunc->name,currentfunc->size,currentfunc->stack);
	button2funcnum[n]=currentfunc->funcnum;
	SetButton(n++,x,y,large+40,high,P.currentfuncbuttonname);

	x=2+large*2;	y=2+30+20;
	large=winlarge/3;	high=20;
	callnum=0;
	
	for(c=0;c<P.callnb;c++)
	{
		call=&P.allcalls[c];
		if(currentfunc==call->currentfunc)
		if(!call->IsBranch)
		if(call->callnb)		/* ???? */
		if( y <= (winhigh-40) )
		{

		if(P.callstart<=callnum)
		{	
		func=call->func;
		sprintf(call->buttonname,"-%ld-> %s",call->callnb,func->name);
		ResizeName(call->buttonname,20);
		button2funcnum[n]=func->funcnum;
		SetButton(n++,x,y,large,high,call->buttonname);y=y+high;
		}
		callnum++;
		}
	}

	large=winlarge/3;	high=20;
	x=2;	y=2+30+20;
	callnum=0;
	for(c=0;c<P.callnb;c++)
	{
		call=&P.allcalls[c];
		if(currentfunc==call->func)
		if(!call->IsBranch)
		if(call->callnb)		/* ???? */
		if( y <= (winhigh-40) )
		{

		if(P.callstart<=callnum)
		{
		func=call->currentfunc;
		sprintf(call->buttonname,"%s -%ld->",func->name,call->callnb);
		ResizeName(call->buttonname,20);
		button2funcnum[n]=func->funcnum;
		SetButton(n++,x,y,large,high,call->buttonname);y=y+high;
		}
		callnum++;
		}
	}
	
	AddGList(window,glist,0,-1,NULL);
	RefreshGList(glist,window,NULL,-1); 

}
/*==================================================================*/
void OSFileRequester(UBYTE *FileName,UBYTE *Title)
{
struct FileRequester *fr;
BOOL done;
ULONG n;	

#ifdef OS4
	if((fr = (struct FileRequester *)AllocAslRequest(ASL_FileRequest,NULL)))
	{
	done=AslRequestTags(fr,
					ASLFR_TitleText,(ULONG)Title,
                             	ASLFR_DoPatterns,TRUE,
                 			TAG_DONE);
	if(done)
		{
		strcpy(FileName, fr->fr_Drawer);n=strlen(FileName);
		if ((n>0) && (FileName[n-1] != ':')) strcat(FileName,"/");
		strcat(FileName, fr->fr_File);
		}
	FreeAslRequest(fr);
	}

#else		/* for OS3 */
ULONG frtags[] =
	{
	ASL_Hail, (ULONG)Title,
	ASL_Height, 200,
	ASL_Width,320,
	ASL_LeftEdge, 0,
	ASL_TopEdge,0,
	ASL_OKText, (ULONG)"OK",
	ASL_CancelText, (ULONG)"Cancel",
	ASL_File, (ULONG)"",
	TAG_DONE
	};

	FileName[0]=0;
	fr = (struct FileRequester *) AllocAslRequest(ASL_FileRequest,(struct TagItem *)frtags);

	if(fr)
	{
	done=AslRequest(fr, NULL);
	if(done)
		{
		strcpy(FileName, fr->rf_Dir);n=strlen(FileName);
		if ((n>0) && (FileName[n-1] != ':')) strcat(FileName,"/");
		strcat(FileName, fr->rf_File);
		}
	FreeAslRequest(fr);
	}
#endif

}
/*=================================================================*/
void DoDisasm(void)
{
UBYTE filename[512];
UBYTE name[512];
ULONG result=0;
ULONG n;	

		OSFileRequester(filename,"File to dissasemble");
#ifdef USEOBJDUMP
	sprintf(name,"objdump -d %s > RAM:dump.asm",filename);
#endif
#ifdef USEADIS
	sprintf(name,"adis -c4 -c8 -a %s -o RAM:dump.asm",filename);
	n=strlen(filename)-1;

	if(filename[n-7]=='.')
		if(filename[n-6]=='l')
		if(filename[n-5]=='i')
		if(filename[n-4]=='b')
		if(filename[n-3]=='r')
		if(filename[n-2]=='a')
		if(filename[n-1]=='r')
		if(filename[n-0]=='y')
			sprintf(name,"adis -c4 -c8 -dl -a %s > RAM:dump.asm",filename);
#endif
		if(debug) printf("SystemTags <%s>\n",name);		

		printf("DISASSEMBLING, PLEASE WAIT ...\n");

		result = SystemTags(name,
         NP_Name,		(ULONG)"Disassembling:",
         SYS_Asynch,     FALSE,	
         NP_CloseError,  TRUE,
         TAG_END);
	
		strcpy(P.filename,"RAM:dump.asm");
}
/*==========================================================================*/
void OSDrawText(WORD x,WORD y,UBYTE *text)
{						/* draw a text in the window */
struct RastPort *rp;
ULONG size;

	rp=window->RPort;
	size=strlen(text);
	SetAPen(rp, 1);
	Move(rp,x,y);
	Text(rp,(void*)text,size);
}
/*=================================================================*/
void AmigaGui(void)
{
BOOL ok;
UBYTE text[256];	
	
	ok=MyOpenWin("ObjDumpFuncs",winlarge,winhigh);
	if(!ok) goto panic;

	DoDisasm();
	ok=ReadASM(P.filename);
	if(!ok) goto panic;
	
	P.sorted=FALSE;
	P.order='O';
	P.gui='L';
	P.guinb=14;
	P.funclistnb=10;
	P.funcstart=0;
	P.calllistnb=10;
	P.callstart=0;
	P.closed=FALSE;
	
	P.gui='L'; /* will list functions */

	DoFuncsList();

	while(!P.closed)
	{
	Delay(2);	
	MyWindowManager();

		if(P.command!=0 )
		{
			RemoveGList(window,glist,-1); 
			FreeGadgets( glist );
			window->FirstGadget=NULL;
			SetRast(window->RPort,0);

			if(P.command>=7)		/* sort buttons */
			if(P.command<=14)
				P.gui='L';

			if((!P.closed))
			if(14<P.command)
			{
			P.gui='C';
			P.funcnum=button2funcnum[P.command-1];			
			}
			
			if(P.command==14) {P.sorted=FALSE;P.order='O';}
			if(P.command==13) {P.sorted=FALSE;P.order='N';}
			if(P.command==12) {P.sorted=FALSE;P.order='S';}
			if(P.command==11) {P.sorted=FALSE;P.order='c';}
			if(P.command==10) {P.sorted=FALSE;P.order='C';}
			if(P.command== 9) {P.sorted=FALSE;P.order='B';}
			if(P.command== 8) {P.sorted=FALSE;P.order='p';}
			if(P.command== 7) {P.sorted=FALSE;P.order='P';}	

			if(P.gui=='L')
				{
				if(P.command== 6) P.funcstart=0;
				if(P.command== 5) P.funcstart=P.funcstart-P.funclistnb;
				if(P.command== 4) P.funcstart=P.funcstart-1;
				if(P.command== 3) P.funcstart=P.funcstart+1;
				if(P.command== 2) P.funcstart=P.funcstart+P.funclistnb;
				if(P.command== 1) P.funcstart=P.funcnb-P.funclistnb;

				if(P.funcstart<0) P.funcstart=0;
				if(P.funcstart>(P.funcnb-P.funclistnb)) P.funcstart=P.funcnb-P.funclistnb;
				sprintf(text,"Function %ld/%ld",P.funcstart,P.funcnb);
				OSDrawText(2,winhigh-20,text);					
			
				DoFuncsList();
				}
		
			if(P.gui=='C')
				{
				if(P.command== 6) P.callstart=0;
				if(P.command== 5) P.callstart=P.callstart-P.calllistnb;
				if(P.command== 4) P.callstart=P.callstart-1;
				if(P.command== 3) P.callstart=P.callstart+1;
				if(P.command== 2) P.callstart=P.callstart+P.calllistnb;
				if(P.command== 1) P.callstart=P.callnb-P.calllistnb;

				if(P.callstart<0) P.callstart=0;
				if(P.callstart>(P.callnb-P.calllistnb)) P.callstart=P.callnb-P.calllistnb;
				sprintf(text,"Call %ld/%ld",P.callstart,P.callnb);
				OSDrawText(2,winhigh-20,text);		

				DoFuncCalls();
				}				
			
		}

	}

panic:
	MyCloseWin();						/* close all */
}
/*=================================================================*/
