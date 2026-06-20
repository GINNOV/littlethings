#include "headers.h"

#include "buttonclass.h"


LONG StartUpCode(void)
{
  struct Library *SysBase;
  struct Library *IntuitionBase, *UtilityBase, *GfxBase, *DOSBase;
  struct Window *w;
  Class *buttonCl;
  Class *progressCl;
  struct IntuiMessage *msg;
  struct Gadget *glist=NULL;
  struct DrawInfo *drinfo;
  ULONG done=FALSE;
  struct Gadget *pro;
  ULONG get;


	SysBase=*((void **)4L);
	if(DOSBase=OpenLibrary("dos.library",37))
		{
		if(IntuitionBase=OpenLibrary("intuition.library",37))
			{
			if(UtilityBase=OpenLibrary("utility.library",37))
				{
				if(GfxBase=OpenLibrary("graphics.library",37))
					{
					if(w=OpenWindowTags(NULL,
								WA_Flags,	WFLG_DEPTHGADGET | WFLG_DRAGBAR |
											WFLG_CLOSEGADGET | WFLG_SIZEGADGET,
								WA_IDCMP,	IDCMP_CLOSEWINDOW | IDCMP_GADGETUP | IDCMP_GADGETDOWN | IDCMP_MOUSEBUTTONS | IDCMP_RAWKEY,
								WA_Top,		15,
								WA_Left,	150,
								WA_Width,	300,
								WA_Height,	300,
								WA_MinWidth,100,
								WA_MinHeight,50,
								WA_MaxWidth,~0,
								WA_MaxHeight,~0,
								WA_Activate,TRUE,
								TAG_END) )
						{
						if( drinfo=GetScreenDrawInfo(w->WScreen) )
							{
							if(buttonCl = initButtonGadgetClass(IntuitionBase, UtilityBase, GfxBase))
								{
							if(progressCl = initProgressGadgetClass(IntuitionBase, UtilityBase, GfxBase))
								{
								struct Gadget *tmpgad,*gad;
								WORD i;

								tmpgad= (struct Gadget *)&glist;
								for(i=0;i<16;i++)
									{
									NewObject(buttonCl, NULL,
											GA_ID,			1L,
											GA_Top,			w->BorderTop + 2 + i*13,
											GA_Left,		20,
											GA_Width,		100,
											GA_Height,		11,
											GA_Immediate,	TRUE,
											GA_RelVerify,	TRUE,
											GA_Previous,	tmpgad,
											BUT_Text,		"All",
											BUT_Color,		(i<8?(i==1?0:1):i%8),
											BUT_BackColor,	(i<8?i%8:~0),
											TAG_DONE);
									}
								NewObject(buttonCl, NULL,
										GA_ID,			1L,
										GA_Top,			w->BorderTop + 2 + i*13,
										GA_Left,		20,
										GA_Width,		150,
										GA_Height,		12,
										GA_Immediate,	TRUE,
										GA_RelVerify,	TRUE,
										GA_Previous,	tmpgad,
										//GA_Disabled,	TRUE,
										BUT_Text,		"_Press a Key",
										TAG_DONE);
								pro=NewObject(progressCl, NULL,
										GA_ID,			1L,
										GA_Top,			w->BorderTop + 2 + ++i*13,
										GA_Left,		20,
										GA_Width,		200,
										GA_Height,		12,
										GA_Previous,	tmpgad,
										PRO_Min,		100,
										PRO_Max,		200,
										PRO_ShowPercent,TRUE,
										TAG_DONE);

								NewObject(buttonCl, NULL,
										GA_ID,			1L,
										GA_Top,			w->BorderTop + 5 + ++i*13,
										GA_Left,		20,
										GA_Width,		20,
										GA_Height,		14,
										GA_Immediate,	TRUE,
										GA_RelVerify,	TRUE,
										GA_Previous,	tmpgad,
										BUT_Drawer,		TRUE,
										TAG_DONE);


								AddGList(w, glist, -1, -1, NULL);
								RefreshGList(glist, w, NULL, -1);

								for( i=100; i<=200; i++ )
									{
									SetGadgetAttrs(pro, w, NULL,
										PRO_Current, i,
										TAG_DONE);
									Delay(2);
									}
								if( GetAttr(PRO_Current, pro, &get) )
									{
									kprintf("current: %ld\n", get);
									}
								if( GetAttr(PRO_ShowPercent, pro, &get) )
									{
									kprintf("showpercent: %ld\n", get);
									}
								SetGadgetAttrs(pro, w, NULL,
									PRO_ShowPercent, FALSE,
									TAG_DONE);
								if( GetAttr(PRO_ShowPercent, pro, &get) )
									{
									kprintf("showpercent: %ld\n", get);
									}
								for( i=200; i>=100; i-- )
									{
									SetGadgetAttrs(pro, w, NULL,
										PRO_Current, i,
										TAG_DONE);
									Delay(2);
									}

								while(done==FALSE)
									{
									WaitPort(w->UserPort);
									while(msg=(struct IntuiMessage *)GetMsg(w->UserPort))
										{
										switch( msg->Class )
											{
											case IDCMP_GADGETDOWN:
												kprintf("Gadget down\n");
												break;
											case IDCMP_GADGETUP:
												kprintf("Gadget up\n");
												break;
											case IDCMP_MOUSEBUTTONS:
												kprintf("Mouse buttons\n");
												break;
											case IDCMP_CLOSEWINDOW:
												done=TRUE;
												break;
											case IDCMP_RAWKEY:
												if( msg->Code & IECODE_UP_PREFIX )
													{
													SetGadgetAttrs(glist, w, NULL,
														GA_Selected,	FALSE,
														TAG_DONE);
													}
												else if( !(msg->Qualifier & IEQUALIFIER_REPEAT) )
													{
													SetGadgetAttrs(glist, w, NULL,
														GA_Selected,	TRUE,
														TAG_DONE);
													}
												break;
											}
										ReplyMsg(msg);
										}
									}

								RemoveGList(w, glist, -1);

								gad=glist;
								while(gad)
									{
									tmpgad= gad->NextGadget;
									DisposeObject(gad);
									gad= tmpgad;
									}

								freeProgressGadgetClass(progressCl);
								}
								freeButtonGadgetClass(buttonCl);
								}
							FreeScreenDrawInfo(w->WScreen,drinfo);
							}
						CloseWindow(w);
						}
					CloseLibrary(GfxBase);
					}
				CloseLibrary(UtilityBase);
				}
			CloseLibrary(IntuitionBase);
			}
		CloseLibrary(DOSBase);
		}
	return( 0 );
}
