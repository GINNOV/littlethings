/*
 *	File:					ListviewReqester.h
 *	Version:			1.0 (01.04.95)
 *	Description:	Let the user select an item from a listview-requester.
 *
 *	(C) 1994,1995 Ketil Hunn
 *
 */

#ifndef	LISTVIEWREQUESTER_H
#define	LISTVIEWREQUESTER_H

/*** DEFINES *************************************************************************/
#define	GTLV_Visible				EG_Window
#define	ID_LVREQ_LISTVIEW		65535
#define	ID_LVREQ_CANCEL			0

#define	CLOSEGADGET			1
#define	SIMPLEREFRESH		2
#define	SAMEGADGETWIDTH	4
#define	SLEEPWINDOW			8
#define	PRIVATEIDCMP		16
#define	CENTREH					32
#define	CENTREV					64

#define	DROPDOWN				128		// only applicable to listviewrequesters
#define	READONLY				256

/*** PROTOTYPES **********************************************************************/
UWORD egHandleListviewRequest(struct ListviewRequester *req,
															varWORD *posarray,
															varWORD *sizearray);

/*** FUNCTIONS ***********************************************************************/
__asm void egRenderListviewRequest(	register __a0 struct ListviewRequester *req,
																		register __a1 UWORD **posarray,
																		register __a2 UWORD **sizearray)
{
	struct Gadget		*gad;
	struct NewGadget	ng;
	BYTE lowkick=(IntuitionBase->LibNode.lib_Version<39),
				dropdown=ISBITSET(req->flags, DROPDOWN),
				readonly=ISBITSET(req->flags, READONLY);
	WORD	wborleft	=req->task.window->BorderLeft,
				wbortop		=req->task.window->BorderTop,
				wborright	=req->task.window->BorderRight,
				wborbottom=req->task.window->BorderBottom,
				butheight	=req->textattr->ta_YSize+EG_GadVInside;
	register ULONG i;

#ifdef MYDEBUG_H
	DebugOut("egRenderListviewRequest");
#endif

			gad=CreateContext(&(req->glist));

			ng.ng_TextAttr		=req->textattr;
			ng.ng_VisualInfo	=req->visualinfo;
			ng.ng_Flags				=0;
			ng.ng_Height			=butheight;

		if(req->numgads)
		{
			if(dropdown)
			{
				egSpreadGadgets((WORD *)posarray->val, (WORD *)sizearray->val, 0, req->task.window->Width, req->numgads, !dropdown);
				ng.ng_TopEdge			=req->task.window->Height-butheight;
			}
			else
			{
				egSpreadGadgets((WORD *)posarray->val, (WORD *)sizearray->val, wborleft+EG_LeftMargin,
													req->task.window->Width-EG_RightMargin-wborright, req->numgads, !dropdown);
				ng.ng_TopEdge			=req->task.window->Height-butheight-EG_BottomMargin-wborbottom;
			}

			for(i=0; i<req->numgads; i++)
			{
				ng.ng_LeftEdge		=posarray->val[i];
				ng.ng_Width				=sizearray->val[i];
				ng.ng_GadgetText	=req->gadgettexts->text[i];
				ng.ng_GadgetID		=i+1;
				req->gadgets->gad[i]=gad=CreateGadget(BUTTON_KIND, gad, &ng,
//				gad=CreateGadget(BUTTON_KIND, gad, &ng,
													GT_Underscore,		EG_Underscorechar,
													TAG_END);
			}
			if(req->numgads>1)
				gad->GadgetID=0;
		}

			if(dropdown)
			{
				ng.ng_LeftEdge		=ng.ng_TopEdge=0;
				ng.ng_Width				=req->task.window->Width;
				ng.ng_Height			=req->task.window->Height-(req->numgads ? butheight:0);
			}
			else
			{
				ng.ng_LeftEdge		=wborleft+EG_LeftMargin;
				ng.ng_TopEdge			=wbortop+EG_TopMargin;
				ng.ng_Width				=req->task.window->Width-wborleft-EG_LeftMargin-wborright-EG_RightMargin;
				ng.ng_Height			=req->task.window->Height-(req->numgads ? butheight:0)-wbortop-EG_TopMargin-wborbottom-EG_BottomMargin-INTERHEIGHT;
			}
			ng.ng_GadgetText	=NULL;
			ng.ng_GadgetID		=ID_LVREQ_LISTVIEW;
			req->listview=CreateGadget(LISTVIEW_KIND, gad, &ng,
												GTLV_Labels,				req->list,
												GTLV_Selected,			req->selectednum,
												(readonly | lowkick ? TAG_IGNORE : GTLV_ShowSelected),	NULL,
												(IntuitionBase->LibNode.lib_Version>38 ? GTLV_MakeVisible:GTLV_Top),	req->selectednum,
												GTLV_MakeVisible,		req->selectednum,
												GTLV_ReadOnly,			readonly,
												TAG_END);
			AddGList(req->task.window, req->glist, -1, -1, NULL);

			if(dropdown)
				EraseRect(req->task.window->RPort, 0, 0, req->task.window->Width, req->task.window->Height);
			else
				EraseRect(req->task.window->RPort, wborleft, wbortop,
									req->task.window->Width-wborright-1,
									req->task.window->Height-wborbottom-1);
			RefreshGList(req->glist, req->task.window, NULL, -1);
			GT_RefreshWindow(req->task.window, NULL);

			req->scrollrows=(H(req->listview)/req->textattr->ta_YSize)-1;
			req->selectednode=egGetNode(req->list, req->selectednum);
}

__asm UWORD egRequestA(struct ListviewRequester *req, struct TagItem *taglist)
{
	register WORD minwidth, minheight, butheight, butwidth, allbutwidth=0;
	register BOOL	dropdown, ok=FALSE;
	register varWORD	*posarray=NULL, *sizearray=NULL;
	UWORD retvalue;

#ifdef MYDEBUG_H
	DebugOut("egLVRequestA");
#endif

	if(req==NULL)
		return 0;

	egGetTags(EG_ListviewRequest, (APTR)req, taglist);
	dropdown=req->dropdown;

	req->glist=NULL;

	if(req->numgads)
	{
		if(sizearray=AllocVec(sizeof(varWORD)+sizeof(WORD)*(req->numgads+1), MEMF_CLEAR))
			if(posarray=AllocVec(sizeof(varWORD)+sizeof(WORD)*(req->numgads+1), MEMF_CLEAR))
				ok=TRUE;
	}
	else
		ok=TRUE;

	if(ok)
	{
		register ULONG i;

		if(req->numgads)
		{
			if(req->samegadgetwidth)
			{
				butwidth=egMaxLenA(&req->rp, req->gadgettexts->text)+EG_GadHInside;
				for(i=0; i<req->numgads; i++)
				{
					sizearray->val[i]=butwidth;
					allbutwidth+=sizearray->val[i];
				}
			}
			else
				for(i=0; i<req->numgads; i++)
				{
					sizearray->val[i]=EG_GadHInside+egTextWidth(&req->rp, req->gadgettexts->text[i]);
					allbutwidth+=sizearray->val[i];
				}
		}
		egInitialPercent(req);
		minwidth=allbutwidth+EG_RightMargin+EG_LeftMargin*req->numgads;
		butheight=(req->numgads>0 ? req->textattr->ta_YSize+EG_GadVInside : 0);
		minheight=butheight*4+INTERHEIGHT;

		req->Width	=MAX(minwidth, req->Width);
		req->Height	=MAX(minheight, req->Height);

		if(dropdown==TRUE)
		{
			register WORD rows;

			rows=(req->Height-butheight-4)/req->textattr->ta_YSize;
			req->Height=rows*req->textattr->ta_YSize+butheight+4;

			if(allbutwidth<req->Width & req->numgads>0)
			{
				register WORD addwidth=(req->Width-allbutwidth)/req->numgads;

				for(i=0; i<req->numgads; i++)
					sizearray->val[i]+=addwidth;
				sizearray->val[i-1]+=req->Width-allbutwidth-addwidth*req->numgads;
			}
		}

		egInitialCentre(req);
		if(req->sleepwindow==TRUE & req->pwindow!=NULL)
			req->sleepreq=egLockWindow(req->pwindow);
		else
			req->sleepreq=NULL;

		if(req->task.window=OpenWindowTags(NULL,
								(dropdown ? TAG_IGNORE : WA_Title),					req->titletext,
								WA_Left,					req->LeftEdge,
								WA_Top,						req->TopEdge,
								WA_InnerWidth,		req->Width,
								WA_InnerHeight,		req->Height,
								WA_Flags,					WFLG_ACTIVATE|
																	WFLG_RMBTRAP,
								(dropdown ? TAG_IGNORE : WA_DragBar),				TRUE,
								(dropdown ? TAG_IGNORE : WA_DepthGadget),		TRUE,
								(dropdown ? TAG_IGNORE : WA_CloseGadget),		req->closegadget,
								(dropdown ? TAG_IGNORE : WA_SizeGadget),		req->sizegadget,
								(dropdown ? TAG_IGNORE : WA_SizeBBottom),		TRUE,
								(dropdown ? WA_Borderless : TAG_IGNORE),		TRUE,
								WA_SimpleRefresh,	req->simplerefresh,
								WA_CustomScreen,	req->screen,
								TAG_END))
		{
			register BOOL	portcreated=FALSE;

			if(req->privateidcmp==FALSE & req->pwindow!=NULL)
				req->port=req->task.window->UserPort=req->pwindow->UserPort;
			else
			{
				req->port=req->task.window->UserPort=CreateMsgPort();
				portcreated=TRUE;
			}

			if(req->port)
			{
				ModifyIDCMP(req->task.window,	IDCMP_VANILLAKEY|
																	IDCMP_RAWKEY|
																	IDCMP_NEWSIZE|
																	IDCMP_SIZEVERIFY|
																	IDCMP_REFRESHWINDOW|
																	IDCMP_CLOSEWINDOW|
																	ARROWIDCMP|
																	SCROLLERIDCMP);
				{
					register struct Node	*node=req->list->lh_Head;
					register i=0;

					for(;node->ln_Succ;node=node->ln_Succ)
						++i;
					req->count=i;
				}

				if(req->gadgets=AllocVec(sizeof(varGADGET)+sizeof(struct Gadget *)*(req->numgads+1), MEMF_CLEAR))
				{
					egRenderListviewRequest(req, posarray, sizearray);

					WindowLimits(	req->task.window,
												minwidth+req->task.window->BorderLeft+req->task.window->BorderRight,
												minheight+req->task.window->BorderTop+req->task.window->BorderBottom,
												~0,~0);

					ScreenToFront(req->screen);
					req->status=STATUS_OPEN;
					while(req->status==STATUS_OPEN)
					{
						Wait(1L<<req->task.window->UserPort->mp_SigBit);
						retvalue=egHandleListviewRequest(req, posarray, sizearray);
					}
					if(portcreated)
						DeleteMsgPort(req->port);
					req->privateidcmp=FALSE;

					FreeVec(req->gadgets);
					req->gadgets=NULL;
				}
			}
		}

		if(req->sleepreq!=NULL)
			egUnlockWindow(req->pwindow, req->sleepreq);
	}

	if(posarray)
				FreeVec(posarray);
	if(sizearray)
		FreeVec(sizearray);

	return retvalue;
}

UWORD egLVRequest(struct ListviewRequester *req, Tag tag1, ...)
{
	return egLVRequestA(req, (struct TagItem *)&tag1);
}

__asm UWORD egHandleListviewRequest(register __a2 struct ListviewRequester	*req,
																		register __a1 UWORD											**posarray,
																		register __a0 UWORD											**sizearray)
{
	struct IntuiMessage *msg;
	UWORD								retvalue=0;

#ifdef MYDEBUG_H
	DebugOut("HandleListviewRequest");
#endif

  while((req->task.status==STATUS_OPEN) &&
					(NULL!=(msg=GT_GetIMsg(req->task.window->UserPort))))
	{
		if(msg->IDCMPWindow!=req->task.window)
		{
			switch(msg->Class)
			{
				case IDCMP_CLOSEWINDOW:
				case IDCMP_SIZEVERIFY:
				case IDCMP_NEWSIZE:
				case IDCMP_MOUSEBUTTONS:
				case IDCMP_CHANGEWINDOW:
				case IDCMP_GADGETUP:
					req->status=STATUS_CLOSED;
					retvalue=0;
					break;
/*				default:
					if(egCallHook(req, msg)==0)
					{
						req->status=STATUS_CLOSED;
						retvalue=0;
					}
					break;
*/
			}
		}
		else
		{
			switch(msg->Class)
			{
				case IDCMP_REFRESHWINDOW:
					GT_BeginRefresh(req->task.window);
					GT_EndRefresh(req->task.window, TRUE);
					break;
				case IDCMP_SIZEVERIFY:
					RemoveGList(req->task.window, req->glist, -1);
					FreeGadgets(req->glist);
					req->glist=NULL;
					break;
				case IDCMP_NEWSIZE:
					if(req->glist!=NULL)
					{
						RemoveGList(req->task.window, req->glist, -1);
						FreeGadgets(req->glist);
					}
					RefreshWindowFrame(req->task.window);
					egRenderListviewRequest(req, posarray, sizearray);
					break;
				case IDCMP_CLOSEWINDOW:
					req->status=STATUS_CLOSED;
					retvalue=0;
					break;
				case IDCMP_RAWKEY:
					{
						ULONG top;
						BYTE highkick=(IntuitionBase->LibNode.lib_Version>38);

						if(msg->Code!=CURSORUP & msg->Code!=CURSORDOWN & msg->Code!=95)
							break;

						if(highkick)
							GT_GetGadgetAttrs(req->listview, req->task.window, NULL,
																GTLV_Top,	&top,
																TAG_DONE);

						switch(msg->Code)
						{
							case 95:		// help key
								if(egCallHook(req, msg)==0)
								{
									req->status=STATUS_CLOSED;
									retvalue=0;
								}
								break;
							case CURSORUP:
								if(CTRLPRESSED(msg) | ALTPRESSED(msg))
								{
									req->selectednum=0;
//									req->top=0;
								}
								else if(SHIFTPRESSED(msg))
								{
									if(req->readonly)
										req->selectednum=MIN(0, req->selectednum-req->scrollrows-1);
									else
									{
										if(highkick==TRUE & req->selectednum>top)
											req->selectednum=(UWORD)top;
										else
										{
											req->selectednum=MAX(0, req->selectednum-req->scrollrows);
//											req->top=(req->selectednum<req->top-req->scrollrows ? req->selectednum:req->top);
										}
									}
								}
								else
								{
									if(req->readonly)
										req->selectednum=MAX(0, req->selectednum-1);
									else
									{
										req->selectednum=MAX(0, req->selectednum-1);
//										req->top=(req->selectednum<req->top ? req->top-(req->top-req->selectednum): req->top);
									}
								}
								break;
							case CURSORDOWN:
								if(CTRLPRESSED(msg) | ALTPRESSED(msg))
								{
									req->selectednum=req->count-1;
//									req->top=req->count;
								}
								else if(SHIFTPRESSED(msg))
								{
									if(req->readonly)
										req->selectednum=MIN(req->count-1, req->selectednum+req->scrollrows-1);
									else
									{
										if(highkick==TRUE & req->selectednum!=top+req->scrollrows)
											req->selectednum=MIN(req->count-1, (UWORD)top+req->scrollrows);
										else
										{
											req->selectednum=MIN(req->count-1, req->selectednum+req->scrollrows);
//											req->top=MIN(req->count-1, req->top+req->scrollrows-1);
										}
									}
								}
								else
								{
									if(req->readonly)
										req->selectednum=MIN(req->count-1, req->selectednum+1);
									else
									{
										req->selectednum=MIN(req->count-1, req->selectednum+1);
//										req->top=(req->selectednum>req->top+req->scrollrows ? req->top+1: req->top);
									}
								}
								break;
						}

						GT_SetGadgetAttrs(req->listview, req->task.window, NULL,
												GTLV_Selected,		req->selectednum,
												(req->readonly ? TAG_IGNORE: GTLV_MakeVisible),	req->selectednum,
//												(req->readonly ? GTLV_Top : TAG_IGNORE),				req->top,
												(highkick ? TAG_IGNORE : GTLV_Top), req->selectednum,
												TAG_DONE);
					}
					break;
				case IDCMP_VANILLAKEY:
					switch(msg->Code)
					{
						case 13:		// return key
							retvalue=1;
							req->status=STATUS_CLOSED;
							if(req->numgads>0)
								egHandleButtonKey(req->task.window, req->gadgets->gad[0]);
							break;
						case 27:		// esc key
							retvalue=0;
							req->status=STATUS_CLOSED;
							if(req->numgads)
								egHandleButtonKey(req->task.window, req->gadgets->gad[req->numgads-1]);
							break;
						default:
							retvalue=egMatchVanillaKeyA((int)msg->Code, req->gadgettexts->text);
							if(retvalue)
							{
								req->status=STATUS_CLOSED;
						
								if(req->numgads)
									egHandleButtonKey(req->task.window, req->gadgets->gad[retvalue-1]);

								if(retvalue==req->numgads & req->numgads>1)
									retvalue=0;
							}
							break;
					}
					break;
				case MOUSEMOVE:
				case IDCMP_GADGETUP:
					{
						register UWORD id=((struct Gadget *)msg->IAddress)->GadgetID;

						if(id==ID_LVREQ_LISTVIEW)
						{
							req->selectednum	=msg->Code;
							if(DoubleClick(	req->seconds, req->micros,
															msg->Seconds, msg->Micros)
															& req->selectednum==req->lastselected)
							{
								if(req->numgads)
									egHandleButtonKey(req->task.window, req->gadgets->gad[0]);
								req->status=STATUS_CLOSED;
								retvalue=1;
							}
							else
							{
								req->seconds			=msg->Seconds;
								req->micros				=msg->Micros;
								req->lastselected	=msg->Code;
							}
						}
						else if(id==ID_LVREQ_CANCEL)
						{
							req->status=STATUS_CLOSED;
							retvalue=0;
						}
						else
						{
							req->status=STATUS_CLOSED;
							retvalue=id;
						}
					}
					break;
			}
		}
		GT_ReplyIMsg(msg);
	}
	if(req->status==STATUS_CLOSED)
	{
		egCloseRequester(req);
		req->selectednode	=egGetNode(req->list, req->selectednum);
	}

	return retvalue;
}

#endif
