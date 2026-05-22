/*
 *	File:					HandleKeys.c
 *	Description:	Handle vanilla shortcuts for gadgets
 *
 *	(C) 1995, Ketil Hunn
 *
 */

#ifndef EG_HANDLEKEYS_H
#define EG_HANDLEKEYS_H

/*** PRIVATE INCLUDES ****************************************************************/
#ifndef CLIB_INTUITION_PROTOS_H
#include <clib/intuition_protos.h>
#endif

#ifndef CLIB_GADTOOLS_PROTOS_H
#include <clib/gadtools_protos.h>
#endif

/*** DEFINES *************************************************************************/
#define	every_node	node=list->lh_Head;node->ln_Succ;node=node->ln_Succ

#define SHIFTPRESSED(msg)	((msg->Qualifier & IEQUALIFIER_LSHIFT) | (msg->Qualifier & IEQUALIFIER_RSHIFT))
#define ALTPRESSED(msg)		((msg->Qualifier & IEQUALIFIER_LALT) | (msg->Qualifier & IEQUALIFIER_RALT))
#define CTRLPRESSED(msg)	(msg->Qualifier & IEQUALIFIER_CONTROL)

/*** PROTOTYPES **********************************************************************/
__asm void egCloseAllTasks(register __a0 struct EasyGadgets	*eg);

/*** FUNCTIONS ***********************************************************************/

__asm ULONG egCallHook(	register __a0 void	*func,
												register __a1 APTR	msg)
{
	struct Hook	hook;
	ULONG retvalue=1;

#ifdef MYDEBUG_H
	DebugOut("egCallHook");
#endif

	if(func)
	{
		hook.h_Entry		=(HOOKFUNC)func;
		hook.h_SubEntry	=NULL;
		hook.h_Data			=msg;

		retvalue=CallHookA(&hook, NULL, msg);
	}
	return retvalue;
}

__asm __saveds UWORD egCountList(register __a0 struct List *list)
{
	register struct Node *node;
	register UWORD count=0;

	if(!IsNil(list))
		for(every_node)
			++count;

	return count;
}

__asm __saveds LONG egHandleListviewArrows(register __a1 struct egGadget 			*listview,
																						register __a0 struct Window				*window,
																						register __a2 struct IntuiMessage *msg)
{
	register WORD		scrollrows=(H(listview)/listview->ng.ng_TextAttr->ta_YSize)-1,
									addon=1;
	register BYTE		readonly=ISBITSET(listview->flags, EG_READONLY);
	ULONG						top;
	struct TagItem	taglist[3];

	if(listview->active==~0)
	{
		listview->active=0L;
		addon=0;
	}

	SETTAG(taglist[0], GTLV_Top, (ULONG)&top);
	SETTAG(taglist[1], TAG_DONE, TAG_DONE);
	egGetGadgetAttrsA(listview, window, NULL, taglist);

	switch(msg->Code)
	{
		case CURSORUP:
			if(CTRLPRESSED(msg) | ALTPRESSED(msg))
				listview->active=0L;
			else if(SHIFTPRESSED(msg))
			{
				if(readonly)
					listview->active=MIN(0, listview->active-scrollrows-1);
				else
				{
					if(listview->active>top)
						listview->active=(LONG)top;
					else
						listview->active=(LONG)MAX(0L, listview->active-scrollrows);
				}
			}
			else
			{
				if(readonly)
					listview->active=MAX(0, listview->active-1);
				else
					listview->active=(LONG)MAX(0L, listview->active-addon);
			}
			break;
		case CURSORDOWN:
			if(CTRLPRESSED(msg) | ALTPRESSED(msg))
				listview->active=(LONG)listview->max;
			else if(SHIFTPRESSED(msg))
			{
				if(readonly)
					listview->active=MIN(listview->max, listview->active+scrollrows-1);
				else
				{
					if(listview->active!=top+scrollrows)
						listview->active=(LONG)MIN(listview->max, (UWORD)top+scrollrows);
					else
						listview->active=(LONG)MIN(listview->max, listview->active+scrollrows);
				}
			}
			else
			{
				if(readonly)
					listview->active=MIN(listview->max, listview->active+scrollrows);
				else
					listview->active=(LONG)MIN(listview->max, listview->active+addon);
			}
			break;
	}

	SETTAG(taglist[0], GTLV_Selected, listview->active);
	SETTAG(taglist[1], (readonly ? GTLV_Top:GTLV_MakeVisible),	listview->active);
	SETTAG(taglist[2], TAG_DONE, TAG_DONE);
	egSetGadgetAttrsA(listview, window, NULL, taglist);

	return listview->active;
}

__asm __saveds UBYTE egFindVanillaKey(register __a0 char *text)
{
	register UBYTE *c;
#ifdef MYDEBUG_H
	DebugOut("egFindVanillaKey");
#endif

	if(c=StrChr(text, EG_Underscorechar))
			return(ToUpper(*(c+1)));

	return 1;
}

__asm struct egGadget *egMatchKey(register __a0 struct egGadget *gad,
																	register __d0 UBYTE						key)
{
	register struct egGadget *found=NULL;

#ifdef MYDEBUG_H
	DebugOut("egMatchKey");
#endif

	if(key!=NULL)
		while(gad!=NULL)
		{
			if(gad->key==key)
			{
				found=gad;
				break;
			}
			gad=gad->NextGadget;
		}
	return found;
}

__asm struct egGadget *egFindListview(register __a0 struct egGadget *gad)
{
	register struct egGadget *found=NULL;

#ifdef MYDEBUG_H
	DebugOut("egFindListview");
#endif

	while(gad!=NULL)
	{
		if(ISBITSET(gad->flags, EG_LISTVIEWARROWS))
		{
			found=gad;
			break;
		}
		gad=gad->NextGadget;
	}
	return found;
}

__asm struct egGadget *egFindGadget(register __a0 struct egGadget *gad,
																		register __d0 UWORD						id)
{
	register struct egGadget *found=NULL;

#ifdef MYDEBUG_H
	DebugOut("egFindGadget");
#endif

	while(gad)
	{
		if(gad->ng.ng_GadgetID==id)
		{
			found=gad;
			break;
		}
		gad=gad->NextGadget;
	}
	return found;
}

__asm __saveds void egSetGadgetState(	register __a0 struct egGadget *gadget,
																			register __a1 struct Window 	*window,
																			register __d0 BYTE						state)
{
#ifdef MYDEBUG_H
	DebugOut("egSetGadgetState");
#endif

	if(gadget && window)
		if(ISBITSET(gadget->flags, EG_DISABLED)==FALSE)
		{
			UWORD gadpos=RemoveGadget(window, gadget->gadget);
			IFTRUESETBIT(state, gadget->gadget->Flags, GFLG_SELECTED);
			AddGadget(window, gadget->gadget, gadpos);
			RefreshGList(gadget->gadget, window, NULL, 1);
		}
}

__asm __saveds UBYTE egConvertRawKey(register __a0 struct IntuiMessage *msg)
{
	static struct InputEvent ev;
	UBYTE buffer[9];
	int len;

#ifdef MYDEBUG_H
	DebugOut("egConvertRawKey");
#endif

	if(msg->Class!=IDCMP_RAWKEY)
		return 0;

	ev.ie_Class		 	 	=IECLASS_RAWKEY;
	ev.ie_Code  		 	=msg->Code;
	ev.ie_Qualifier 	=msg->Qualifier;
	ev.ie_EventAddress=*(APTR *)msg->IAddress;
	len=MapRawKey(&ev, buffer, 8, NULL);
	if(len!=1)
		return 0;
	return buffer[0];
}

__asm void egHandleMultipleChoiceKind(register __a0 struct IntuiMessage *msg,
																			register __a1 struct egTask				*task,
																			register __d0 BYTE								shift)
{
	if(shift)
	{
		if(task->activegad->active==0L)
		{
			if(task->activegad->kind==PALETTE_KIND)
				;//msg->Code=1<<eg->RPort.BitMap->Depth;
			else
			{
				for(msg->Code=0; task->activegad->labels[msg->Code]!=NULL; msg->Code++)
					;
			}
			--msg->Code;
		}
		else
			msg->Code=task->activegad->active-1;
	}
	else
	{
		if(task->activegad->labels[task->activegad->active+1]==NULL)
			msg->Code=0;
		else
			msg->Code=task->activegad->active+1;
	}
	task->activegad->active=(LONG)msg->Code;
	GT_SetGadgetAttrs(task->activegad->gadget, task->window, task->req,
						GTCY_Active,	msg->Code,
						GTMX_Active,	msg->Code,
						TAG_DONE);
	CLEARBIT(msg->Class, IDCMP_RAWKEY);
	if(task->activegad->kind==MX_KIND)
		SETBIT(msg->Class, IDCMP_GADGETDOWN);
	else
		SETBIT(msg->Class, IDCMP_GADGETUP);
	msg->IAddress=task->activegad->gadget;
}

__asm __saveds ULONG egWait(register __a0 struct EasyGadgets *eg,
														register __d0 ULONG								signals)
{
 	register ULONG signal=Wait(	signals																							|
															eg->AmigaGuideSignal																|
															(eg->notifyport ? 1L<<eg->notifyport->mp_SigBit:0L) |
															1L<<eg->msgport->mp_SigBit);
	if(signal & eg->AmigaGuideSignal)
		egHandleAmigaGuide(eg);
	if(signal & 1L<<eg->msgport->mp_SigBit)
		egGetMsg(eg);

	if(eg->notifyport && (signal & 1L<<eg->notifyport->mp_SigBit))
	{
		register struct ScreenNotifyMessage *snm;
	
		while(snm=(struct ScreenNotifyMessage *)GetMsg(eg->notifyport))
		{
			register struct egTask	*task;

			eg->msg->Class		=EGIDCMP_NOTIFY;
			eg->msg->Code			=(UWORD)snm->snm_Type;
			eg->msg->IAddress	=snm->snm_Value;

			for(every_task)
				if(task->handlefunc)
					egCallHook(task->handlefunc, (APTR)eg);

			ReplyMsg((struct Message *) snm);
		}
	}

	return signal;
}

__asm __saveds struct IntuiMessage *egGetMsg(register __a0 struct EasyGadgets	*eg)
{
	struct IntuiMessage *tmpmsg, *msg=NULL;
	register struct egTask				*task;

#ifdef MYDEBUG_H
	DebugOut("egGetMsg");
#endif

	if(ISBITSET(eg->flags, EG_ICONIFIED))
	{
		register struct Message *msg;

		if(msg=GetMsg(eg->msgport))
		{
			ReplyMsg(msg);
			egIconify(eg, FALSE);
		}
	}

	while(!IsNil(&eg->msgport->mp_MsgList))
	{
		switch(eg->msgport->mp_MsgList.lh_Head->ln_Type)
		{
			case NT_USER:
				break;
			case EG_INTUIMSG:
				if(msg=(struct IntuiMessage *)GetMsg(eg->msgport))
				{
					CopyMem(msg, eg->msg, sizeof(struct IntuiMessage));
					for(task=eg->tasklist; task; task=task->nexttask)
					{
						if(task->status==STATUS_OPEN && task->window==msg->IDCMPWindow && task->handlefunc)
							egCallHook(task->handlefunc, (APTR)eg);
						break;
					}
					FreeVec(msg);
				}
				break;
			default:
				if(tmpmsg=GT_GetIMsg(eg->msgport))
				{
					CopyMem(tmpmsg, eg->msg, sizeof(struct IntuiMessage));
					GT_ReplyIMsg(tmpmsg);
					msg=eg->msg;

		for(task=eg->tasklist; task; task=task->nexttask)
			if(task->status==STATUS_OPEN && task->window==msg->IDCMPWindow)
			{
				switch(msg->Class)
				{
					case IDCMP_REFRESHWINDOW:
						GT_BeginRefresh(task->window);
						if(task->refreshfunc)
							egCallHook(task->refreshfunc, (APTR)msg);
						GT_EndRefresh(task->window, TRUE);
						break;
					case IDCMP_SIZEVERIFY:
						egFreeGList(task);
						RefreshWindowFrame(task->window);
						break;
					case IDCMP_NEWSIZE:
						if(task->renderfunc)
						{
							if(task->glist)
							{
								egFreeGList(task);
								RefreshWindowFrame(task->window);
							}
							eg->dri=task->dri;
							egCallHook(task->renderfunc, (APTR)msg);
							egRenderGadgets(task);
						}
						if(task->refreshfunc)
							egCallHook(task->refreshfunc, (APTR)msg);
						break;
/*					case IDCMP_CLOSEWINDOW:
						if(task==task->eg->tasklist)
							egCloseAllTasks(task->eg);
						else
							egCloseTask(task);
						break;
*/
					case IDCMP_MENUHELP:
						{
							UBYTE title[MAXCHARS];
							register struct Menu *menu=task->window->MenuStrip;
							register ULONG count=MENUNUM(msg->Code);

							for(; menu && count-->0; menu=menu->NextMenu)
								;
							if(menu)
							{
								sprintf(title, "Menu_%ld", MENUNUM(msg->Code)+1);
								egShowAmigaGuide(eg, title);
							}
						}
						break;
					case IDCMP_VANILLAKEY:
					case IDCMP_RAWKEY:
						if(msg->Code==CURSORUP | msg->Code==CURSORDOWN)
						{
							struct egGadget *listview;

							if(listview=egFindListview(task->eglist))
							{
								register UWORD oldactive=(UWORD)listview->active;

								if(oldactive!=(msg->Code=(UWORD)egHandleListviewArrows(listview, task->window, msg)))
								{
									CLEARBIT(msg->Class, IDCMP_RAWKEY);
									SETBIT(msg->Class, IDCMP_GADGETUP);
									msg->IAddress=listview->gadget;
								}
							}
						}
						else if(msg->Code!=95)
						{
							int upstroke=msg->Code & 0x80;
							BYTE shift=(BYTE)((msg->Qualifier & IEQUALIFIER_LSHIFT) | (msg->Qualifier & IEQUALIFIER_RSHIFT));

							if(task->activegad)	// key released
							{
								int samekey=(msg->Code & 0x7f)==task->activekey;

								if(samekey && !upstroke)
									break;

								egSetGadgetState(task->activegad, task->window, FALSE);

								if(samekey)
								{
									switch(task->activegad->kind)
									{
										case CYCLE_KIND:
											egHandleMultipleChoiceKind(msg, task, shift);
											break;
										case BUTTON_KIND:
										case EG_GETFILE_KIND:
										case EG_GETDIR_KIND:
										case EG_POPUP_KIND:
											CLEARBIT(msg->Class, IDCMP_RAWKEY);
											SETBIT(msg->Class, IDCMP_GADGETUP);
											msg->IAddress=task->activegad->gadget;
											break;
									}
								}
								task->activegad=NULL;
								task->activekey=0;
							}
							else // new key pressed
							{
								UBYTE keypress=egConvertRawKey(msg);
								struct egGadget *eggad=egMatchKey(task->eglist, ToUpper(keypress));

								if(eggad==NULL)
									break;
								if(ISBITSET(eggad->flags, EG_DISABLED))
									break;

								switch(eggad->kind)
								{
									case BUTTON_KIND:
									case EG_GETFILE_KIND:
									case EG_GETDIR_KIND:
									case EG_POPUP_KIND:
									case CYCLE_KIND:
										task->activegad=eggad;
										task->activekey=msg->Code;
										egSetGadgetState(eggad, task->window, TRUE);
										msg=NULL;
										break;
									case STRING_KIND:
									case INTEGER_KIND:
										egActivateGadget(eggad, task->window, task->req);
										break;
									case SLIDER_KIND:
									case SCROLLER_KIND:
									case LISTVIEW_KIND:
										{
											register BYTE addon=1;
											register LONG oldactive=eggad->active;

											if(eggad->kind==LISTVIEW_KIND)
											{
												if(eggad->active==EG_LISTVIEW_NONE)
												{
													eggad->active=0L;
													addon=0;
												}
											}

 											if(shift)
												eggad->active=(LONG)MAX(eggad->active-addon, eggad->min);
											else
												eggad->active=(LONG)MIN(eggad->active+addon, eggad->max);

											{
												struct TagItem taglist[6];

												SETTAG(taglist[0], GTSL_Level,				msg->Code=(UWORD)eggad->active);
												SETTAG(taglist[1], GTSC_Top,					msg->Code);
												SETTAG(taglist[2], GTPA_Color,				msg->Code);
												SETTAG(taglist[3], GTLV_Selected,			msg->Code);
												SETTAG(taglist[4], GTLV_MakeVisible,	msg->Code);
												SETTAG(taglist[5], TAG_DONE, TAG_DONE);

												egSetGadgetAttrsA(msg->IAddress=eggad->gadget,
																					task->window,
																					task->req,
																					taglist);
/*
											GT_SetGadgetAttrs(msg->IAddress=eggad->gadget, task->window, task->req,
																				GTSL_Level,				msg->Code=(UWORD)eggad->active,
																				GTSC_Top,					msg->Code,
																				GTPA_Color,				msg->Code,
																				GTLV_Selected,		msg->Code,
//																				(KickStart<39 ? GTLV_Top : GTLV_MakeVisible), msg->Code,
																				GTLV_MakeVisible, msg->Code,
																				TAG_DONE);
*/
											}
											CLEARBIT(msg->Class, IDCMP_RAWKEY);
											if(eggad->kind==LISTVIEW_KIND)
											{
												if(oldactive!=eggad->active)
													SETBIT(msg->Class, IDCMP_GADGETUP);
											}
											else
												SETBIT(msg->Class, IDCMP_MOUSEMOVE);
										}
										break;
									case CHECKBOX_KIND:
										eggad->active=!eggad->active;
										GT_SetGadgetAttrs(msg->IAddress=eggad->gadget, task->window, task->req,
															GTCB_Checked,	msg->Code=(UWORD)eggad->active,
															TAG_DONE);
										CLEARBIT(msg->Class, IDCMP_RAWKEY);
										SETBIT(msg->Class, IDCMP_GADGETUP);
										break;
									case PALETTE_KIND:
									case MX_KIND:
										task->activegad=eggad;
										egHandleMultipleChoiceKind(msg, task, shift);
										break;
								}
							}
						}
						else
							egShowAmigaGuide(eg, egGetHelpNode(task, msg));
						break;
					
					case IDCMP_CHANGEWINDOW:
						task->coords.LeftEdge	=task->window->LeftEdge;
						task->coords.TopEdge	=task->window->TopEdge;
						task->coords.Width		=task->window->Width;
						task->coords.Height		=task->window->Height;
						break;
					case IDCMP_MENUVERIFY:
					case IDCMP_INACTIVEWINDOW:
						if(task->activegad)
						{
							egSetGadgetState(task->activegad, task->window, FALSE);
							task->activegad=NULL;
							task->activekey=0;
						}
						break;
					case IDCMP_GADGETDOWN:
						if(msg->IAddress)
						{
							register struct egGadget *gad=egFindGadget(task->eglist, ((struct Gadget *)msg->IAddress)->GadgetID);

							switch(gad->kind)
							{
								case PALETTE_KIND:
								case MX_KIND:
									gad->active=(LONG)msg->Code;
									break;
							}
						}
						break;
					case IDCMP_GADGETUP:
						if(msg->IAddress)
						{
							register struct egGadget *gad=egFindGadget(task->eglist, ((struct Gadget *)msg->IAddress)->GadgetID);

							if(msg->IAddress==task->iconifygadget)
								egIconify(task->eg, TRUE);
							else
							{
								if(msg->Code==95) // help inside string
									egShowAmigaGuide(eg, egGetHelpNode(task, msg));
								if(gad)
									switch(gad->kind)
									{
										case CYCLE_KIND:
										case LISTVIEW_KIND:
										case CHECKBOX_KIND:
											gad->active=(LONG)msg->Code;
											break;
										case SLIDER_KIND:
										case SCROLLER_KIND:
											gad->active=(LONG)msg->Code;
											break;
									}
							}
						}
						break;
					case IDCMP_MOUSEMOVE:
						if(msg->IAddress)
						{
							register struct egGadget *gad=egFindGadget(task->eglist, ((struct Gadget *)msg->IAddress)->GadgetID);

							if(gad)
								switch(gad->kind)
								{
									case SLIDER_KIND:
									case SCROLLER_KIND:
										gad->active=(LONG)msg->Code;
										break;
								}
						}
				}
				if(msg && task->handlefunc)
					egCallHook(task->handlefunc, (APTR)msg);
				break;
			}
			}
			break;
		}
	}
	return msg;
}

__asm __saveds LONG egSetGadgetAttrsA(register __a0 struct egGadget 	*newgad,
																			register __a1 struct Window			*win,
																			register __a2 struct Requester	*req,
																			register __a3 struct TagItem		*taglist)
{
	struct TagItem					*tstate=taglist;
	register struct TagItem	*tag;
	register BYTE						mark=FALSE, makevisible=FALSE;
	ULONG										newtop=0;

#ifdef MYDEBUG_H
	DebugOut("egSetGadgetAttrsA");
#endif

	if(win==NULL)
		return 0L;
	while(tag=NextTagItem(&tstate))
		switch(tag->ti_Tag)
		{
			case GTCY_Labels:
			case GTMX_Labels:
				newgad->labels=(STRPTR *)tag->ti_Data;
				break;
			case GTLV_Labels:
				if(tag->ti_Data==~0)
				{
					newgad->list=NULL;
					newgad->max=0L;
				}
				else
				{
					newgad->list=(struct List *)tag->ti_Data;
					newgad->max=MAX(0, (egCountList(newgad->list)-1));
				}
				break;
			case GTLV_Top:
				newgad->min=(WORD)tag->ti_Data;
				break;
			case GTCY_Active:
			case GTMX_Active:
			case GTCB_Checked:
			case GTPA_Color:
			case GTLV_Selected:
			case GTSL_Level:
				newgad->active=(LONG)tag->ti_Data;
				break;
			case GTLV_SelectedNode:
				{
					register struct Node *node, *marknode=(struct Node *)tag->ti_Data;
					register LONG select=0;

					if(!IsNil(newgad->list))
						for(node=newgad->list->lh_Head;node->ln_Succ;node=node->ln_Succ)
							if(marknode==node)
							{
								newgad->active=select;
								mark=TRUE;
								tag->ti_Tag=TAG_IGNORE;
//								tag->ti_Data=select;
								break;
							}
							else
								++select;
				}
				break;
			case GTSL_Min:
				newgad->min=(WORD)tag->ti_Data;
				break;
			case GTSL_Max:
				newgad->max=(WORD)tag->ti_Data;
				break;
			case GTPA_Depth:
				newgad->max=(WORD)1<<tag->ti_Data;
				break;
			case GA_Disabled:
				if(tag->ti_Data)
					if(ISBITSET(newgad->flags, EG_DISABLED))
						tag->ti_Tag=TAG_IGNORE;

				IFTRUESETBIT(tag->ti_Data, newgad->flags, EG_DISABLED);

				if(newgad->kind>=EG_GETFILE_KIND)
					if(ISBITSET(newgad->flags, EG_DISABLED))
						OffGadget(newgad->gadget, win, req);
					else
						OnGadget(newgad->gadget, win, req);
				break;
			case GTLV_MakeVisible:
				if(KickStart<39)
				{
					struct TagItem	taglist[2];
					ULONG						top;

					SETTAG(taglist[0], GTLV_Top, (ULONG)&top);
					SETTAG(taglist[1], TAG_DONE, TAG_DONE);
					egGetGadgetAttrsA(newgad, win, req, taglist);

					if(tag->ti_Data<top)
						newtop=tag->ti_Data;
					else
					{
						register ULONG scrollrows=(H(newgad)/newgad->ng.ng_TextAttr->ta_YSize)-1;

						newtop=top;
						if(top+scrollrows<tag->ti_Data)
							newtop=MAX(0, tag->ti_Data-scrollrows);
					}
					mark=makevisible=TRUE;
				}
				break;
		}

	if(mark)
		GT_SetGadgetAttrs(newgad->gadget, win, req,
										GTLV_Selected,												newgad->active,
										(makevisible ? GTLV_Top:TAG_IGNORE),	newtop,
										TAG_MORE, taglist,
										TAG_END);
	else
		GT_SetGadgetAttrsA(newgad->gadget, win, req, taglist);

	return newgad->active;
}

__asm __saveds struct Node *egGetNode(register __a0 struct List *list,
																			register __d0 ULONG				selected)
{
	register struct Node *node;
	register UWORD i=0;

#ifdef MYDEBUG_H
	DebugOut("egGetSelectedNode");
#endif

	if(!IsNil(list))
		for(every_node)
			if(i==selected)
				return node;
			else
				++i;

	return NULL;
}

__asm __saveds void egGetGadgetAttrsA(register __a0 struct egGadget 	*newgad,
																			register __a1 struct Window			*win,
																			register __a2 struct Requester	*req,
																			register __a3 struct TagItem		*taglist)
{
		struct TagItem	*tstate=taglist;
		register struct TagItem	*tag;
		ULONG						*p;

#ifdef MYDEBUG_H
	DebugOut("egGetGadgetAttrsA");
#endif

	if(KickStart>38)
		GT_GetGadgetAttrsA(newgad->gadget, win, req, taglist);
	else
	{
		while(tag=NextTagItem(&tstate))
		{
			p=(ULONG *)tag->ti_Data;

			switch(tag->ti_Tag)
			{
				case GA_Disabled:
					*p=(ULONG)ISBITSET(newgad->flags, EG_DISABLED);
					break;
				case GTCB_Checked:
				case GTCY_Active:
				case GTMX_Active:
				case GTPA_Color:
				case GTLV_Selected:
					*p=(ULONG)newgad->active;
					break;
				case GTCY_Labels:
					*p=(ULONG)newgad->labels;
					break;
				case GTIN_Number:
					*p=(ULONG)Number(newgad);
					break;
				case GTLV_Labels:
					*p=(ULONG)newgad->list;
					break;
				case GTLV_Top:
					*p=(ULONG)*(short *)(((char *)newgad->gadget)+sizeof(struct Gadget)+4);
					break;
				case GTSC_Top:
				case GTSL_Level:
					*p=(ULONG)newgad->active;
					break;
				case GTSC_Total:
					break;
				case GTSC_Visible:
					break;
				case GTSL_Min:
					*p=(ULONG)newgad->min;
					break;
				case GTSL_Max:
					*p=(ULONG)newgad->max;
					break;
				case GTST_String:
					*p=(ULONG)String(newgad);
					break;
			}
		}
	}
	if(tag=FindTagItem(GTLV_SelectedNode, taglist))
	{
		p=(ULONG *)tag->ti_Data;
		*p=(ULONG)egGetNode(newgad->list, newgad->active);
	}
}

#endif
