/*
 *	File:					Requesters.c
 *	Description:	A more friendly front to EasyRequest and DisplayAlert
 *
 *	(C) 1994, Ketil Hunn
 *
 */

#ifndef EG_REQUESTERS_H
#define EG_REQUESTERS_H

__asm __saveds LONG egDisplayAlert(	register __d0 ULONG alertType,
																		register __a0 UBYTE *msg,
																		register __d1	ULONG timeout)
{
	register	LONG	result=-1;
	register	char	*alertMsg;
						int		size=StrLen(msg)+500;

#ifdef MYDEBUG_H
	DebugOut("egDisplayAlert");
#endif

	if(alertMsg=AllocVec(size, MEMF_CLEAR))
	{
		register	UBYTE	*c;
		register	BYTE	ypos=14;
		register	UBYTE	*line, *nextline;
		register	int		length;
		register	BOOL	done=FALSE;

		c=alertMsg;
		line=msg;
		while(!done)
		{
			nextline=StrChr(line, '\n');
			if(nextline==NULL)
				done=TRUE;
			else
			{
				*nextline='\0';
				++nextline;
			}
			length=(80-StrLen(line))<<2;
			*c++=length / 0x100;
			*c++=length & 0x0FF;
			*c++=ypos;
			while(*line!='\0')
				*c++=*line++;
			*c++=0;
			*c++=1;
			ypos+=11;
			line=nextline;
		}
		*(c-1)=0;
		if(timeout>0 && IntuitionBase->LibNode.lib_Version>38)
			result=TimedDisplayAlert(alertType, alertMsg, ypos, timeout);
		else
			result=DisplayAlert(alertType, alertMsg, ypos);

		FreeVec(alertMsg);
	}
	return result;
}

__asm __saveds LONG egRequestA(	register __a0 struct Window *window,
																register __a1 UBYTE					*title,
																register __a2 UBYTE					*format,
																register __a4 UBYTE					*gadgets,
																register __a3 APTR	 				*args)
{
	struct EasyStruct myES;

#ifdef MYDEBUG_H
	DebugOut("egRequestA");
#endif

	myES.es_StructSize		=sizeof(struct EasyStruct);
	myES.es_Title					=title;
	myES.es_TextFormat		=format;
	myES.es_GadgetFormat	=gadgets;

	return EasyRequestArgs(window, &myES, NULL, args);
}

/*
__asm void egGetRequesterTags(register __d0 unsigned long reqType,
															register __a1 APTR req,
															register __a0 struct TagItem *taglist)
{
	struct ListviewRequester	*lvreq=(struct ListviewRequester *)req;
	struct TagItem *tstate;
	struct TagItem *tag;

#ifdef MYDEBUG_H
	DebugOut("egGetRequesterTags");
#endif

		tstate=taglist;
		while(tag=NextTagItem(&tstate))
			switch(tag->ti_Tag)
			{
				case WA_Window:
					lvreq->pwindow=(struct Window *)tag->ti_Data;
					if(lvreq->pwindow)
						lvreq->task.screen	=lvreq->pwindow->WScreen;
					break;
				case WA_Screen:
					lvreq->task.screen=(struct Screen *)tag->ti_Data;
					break;
				case EG_InitialLeftEdge:
					lvreq->LeftEdge	=(WORD)tag->ti_Data;
					break;
				case EG_InitialTopEdge:
					lvreq->TopEdge	=(WORD)tag->ti_Data;
					break;
				case EG_InitialWidth:
					lvreq->Width	=(WORD)tag->ti_Data;
					break;
				case EG_InitialHeight:
					lvreq->Height	=(WORD)tag->ti_Data;
					break;
				case EG_InitialPercentV:
					lvreq->percentv	=(BOOL)tag->ti_Data;
					break;
				case EG_InitialPercentH:
					lvreq->percenth	=(BOOL)tag->ti_Data;
					break;
				case EG_InitialCentreH:
					lvreq->centreh=	(BOOL)tag->ti_Data;
					break;
				case EG_InitialCentreV:
					lvreq->centrev=	(BOOL)tag->ti_Data;
					break;
				case EG_TitleText:
					if(lvreq->titletext)
						Free(lvreq->titletext);
					lvreq->titletext=StrDup((UBYTE *)tag->ti_Data);
					break;
				case EG_CloseGadget:
					lvreq->closegadget=	(BOOL)tag->ti_Data;
					break;
				case EG_SizeGadget:
					lvreq->sizegadget=	(BOOL)tag->ti_Data;
					break;
				case EG_TextAttr:
					egSetReqFont(lvreq, (struct TextAttr *)tag->ti_Data);
					break;
				case EG_SameGadgetWidth:
					lvreq->samegadgetwidth=	(BOOL)tag->ti_Data;
					break;
				case EG_SimpleRefresh:
					lvreq->simplerefresh=	(BOOL)tag->ti_Data;
					break;
				case EG_Gadgets:
					if(lvreq->numgads)
					{
						register ULONG i;

						for(i=0; i<lvreq->numgads; i++)
							Free(lvreq->gadgettexts->text[i]);
						FreeVec(lvreq->gadgettexts);
						lvreq->numgads=0;
					}
					egParseGadgetString(lvreq, (UBYTE *)tag->ti_Data);
					break;
				case EG_SleepWindow:
					lvreq->sleepwindow=	(BOOL)tag->ti_Data;
					break;
				case EG_PrivateIDCMP:
					lvreq->privateidcmp=	(BOOL)tag->ti_Data;
					break;
				case EG_IntuiMsgFunc:
					lvreq->func=(void *)tag->ti_Data;
					break;
				case EG_UserData:
					lvreq->eg_UserData	=(APTR)tag->ti_Data;
					break;
			}

		switch(lvreq->type)
		{
			case EG_ListviewRequest:
				tstate=taglist;
				while(tag=NextTagItem(&tstate))
					switch(tag->ti_Tag)
					{
						case EGLV_Labels:
							lvreq->list	=(struct List *)tag->ti_Data;
							break;
						case EGLV_Selected:
							lvreq->selectednum	=(LONG)tag->ti_Data;
							break;
						case EGLV_ReadOnly:
							lvreq->readonly=	(BOOL)tag->ti_Data;
							break;
						case EGLV_DropDown:
							lvreq->dropdown=	(BOOL)tag->ti_Data;
							break;
					}
				break;
		}
}

__asm __saveds APTR egAllocRequestA(register __d0 unsigned long reqType,
																		register __a0 struct TagItem *taglist)
{
	register struct ListviewRequester		*req=NULL;

#ifdef MYDEBUG_H
	DebugOut("egAllocRequestA");
#endif

	switch(reqType)
	{
		case EG_ListviewRequest:
			req=(struct ListviewRequester *)AllocVec(sizeof(struct ListviewRequester), MEMF_CLEAR|MEMF_PUBLIC);
			egGetRequesterTags(EG_ListviewRequest, req, taglist);
			break;
	}

	if(req!=NULL)
	{
		if(req->task.screen==NULL && req->pwindow)
			req->task.screen=req->pwindow->WScreen;

		if(req->task.screen==NULL)
		{
			struct Screen *wbscreen;

			if(wbscreen=LockPubScreen(NULL))
			{
				req->task.screen=wbscreen;
				UnlockPubScreen(NULL, wbscreen);
			}
		}

//		if(req->font==NULL)
//			mrSetReqFont(req, NULL);

		if(req->titletext==NULL)
			req->titletext=StrDup(EG_DefTitleText);

		req->type=reqType;

		switch(reqType)
		{
			case EG_ListviewRequest:
				{
//					register struct ListviewRequester	*lvreq=(struct ListviewRequester *)req;
//					lvreq->IntuitionBase=(struct IntuitionBase *)OpenLibrary("intuition.library", 37L);
					return (struct ListviewRequester *)req;
				}
				break;
		}	
	}

	return NULL;
}

__asm __saveds void egFreeRequest(register __a0 APTR req)
{
#ifdef MYDEBUG_H
	DebugOut("egFreeRequest");
#endif

	if(req)
	{
		struct ListviewRequester	*tmpreq=(struct ListviewRequester *)req;
		register ULONG i;

		Free(tmpreq->titletext);

		for(i=0; i<tmpreq->numgads; i++)
			Free(tmpreq->gadgettexts[i]);
		FreeVec(tmpreq->gadgettexts);

		CloseFont(tmpreq->font);

		switch(tmpreq->type)
		{
			case EG_ListviewRequest:
				break;
		}
		FreeVec(tmpreq);
	}
}

__asm void egParseGadgetString(	register __a0 APTR req,
																register __a1 UBYTE *string)
{
	register struct ListviewRequester	*lvreq=(struct ListviewRequester *)req;
	register UBYTE *text, *t, *c;
	register ULONG numgads;

#ifdef MYDEBUG_H
	DebugOut("egParseGadgetString");
#endif

	if(string!=NULL)
	{
		numgads=1L;

		if(text=t=StrDup(string))
		{
			while(*t!='\0')
			{
				if(*t=='|')
					numgads++;
				t++;
			}
			lvreq->numgads=numgads;

			if(lvreq->gadgettexts=AllocVec(2*sizeof(UBYTE *)*(numgads+1), MEMF_CLEAR))
			{
				register ULONG i=0;
				t=text;
				while(*t!='\0')
				{
					c=t;
					while(*t!='|' && *t!='\0')
						t++;

					if(*t!='\0')
						*t++='\0';

					lvreq->gadgettexts[i++]=StrDup(c);
				}
			}
			Free(text);
		}
	}
	else
		lvreq->numgads=0;
}

__asm void egCloseRequester(register __a0 APTR inreq)
{
	register struct ListviewRequester *req=(struct ListviewRequester *)inreq;
	register struct Window	*win=req->window;

#ifdef MYDEBUG_H
	DebugOut("egCloseRequester");
#endif
//	RemoveGList(win, req->glist, -1);

	req->LeftEdge	=win->LeftEdge;
	req->TopEdge	=win->TopEdge;
	req->Width		=win->Width-win->BorderLeft-win->BorderRight;
	req->Height		=win->Height-win->BorderTop-win->BorderBottom;

	mrCloseWindowSafely(win);
	FreeGadgets(req->glist);
	req->window=NULL;
}

__asm __saveds UWORD egRequestA(register __a1 APTR req,
																register __a0 struct TagItem *taglist)
{
	struct ListviewRequester *lvreq=(struct ListviewRequester *)req;
	UWORD retvalue=0;

#ifdef MYDEBUG_H
	DebugOut("egRequestA");
#endif

	lvreq->visualinfo=GetVisualInfo(lvreq->task.screen, TAG_END);
	switch(lvreq->type)
	{
		case EG_ListviewRequest:
			retvalue=egLVRequestA(lvreq, taglist);
			break;
	}
	FreeVisualInfo(lvreq->visualinfo);

	return retvalue;
}

__asm void egInitialPercent(register __a0 APTR inreq)
{
	register struct ListviewRequester	*req=(struct ListviewRequester *)inreq;

#ifdef MYDEBUG_H
	DebugOut("egInitialPercent");
#endif

	if(req->percenth)
		req->Width	=req->task.screen->Width/100*req->percenth;
	if(req->percentv)
		req->Height	=req->task.screen->Height/100*req->percentv;

	req->percentv=req->percenth=0;
}

__asm void egInitialCentre(register __a0 APTR inreq)
{
	register struct ListviewRequester	*req=(struct ListviewRequester *)inreq;

#ifdef MYDEBUG_H
	DebugOut("egInitialCentre");
#endif

	if(req->centreh)
		req->LeftEdge	=req->task.screen->Width/2-req->Width/2;
	if(req->centrev)
		req->TopEdge	=req->task.screen->Height/2-req->Height/2;

	req->centrev=req->centreh=FALSE;
}

__asm ULONG egHookEntry(register __a0 struct Hook *hook,
												register __a2 VOID *o,
												register __a1 VOID *msg)
{
#ifdef MYDEBUG_H
	DebugOut("eg_HookEntry");
#endif
	return ((*(ULONG (*)(struct Hook *,VOID *,VOID *))(hook->h_SubEntry))(hook, o, msg));
}

__asm VOID egInitHook(register __a0 struct Hook *h,
											register __a2 ULONG (*func)(),
											register __a1 VOID *data)
{
#ifdef MYDEBUG_H
	DebugOut("egInitHook");
#endif
	if(h)
	{
		h->h_Entry		=(ULONG (*)()) egHookEntry;
		h->h_SubEntry	=func;
		h->h_Data			=data;
	}
}

__asm ULONG egCallHook(	register __a0 APTR req,
												register __a1 struct IntuiMessage *msg)
{
	struct Hook	hook;
	ULONG retvalue=1;

#ifdef MYDEBUG_H
	DebugOut("egCallHook");
#endif

	if(((struct ListviewRequester *)req)->func)
	{
		egInitHook(&hook, ((struct ListviewRequester *)req)->func, msg);
		retvalue=CallHookPkt(&hook, NULL, NULL);
	}
	return retvalue;
}
*/
#endif
