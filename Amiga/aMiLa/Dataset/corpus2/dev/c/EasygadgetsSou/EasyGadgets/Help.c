/*
 *	File:					Help.c
 *	Description:	
 *
 *	(C) 1994,1995 Ketil Hunn
 *
 */

#ifndef	HELP_C
#define	HELP_C

/*** DEFINES *************************************************************************/
#define AMIGAGUIDEVERSION	34L


/*** FUNCTIONS ***********************************************************************/
__asm UBYTE *egGetHelpNode(	register __a0 struct egTask				*task,
														register __a1 struct IntuiMessage *msg)
{
	register struct egGadget	*gad=task->eglist;
	register WORD							x=msg->MouseX, y=msg->MouseY;
	UBYTE											*node=NULL, *oldnode;

#ifdef MYDEBUG_H
	DebugOut("egGetHelpNode");
#endif

	while(gad)
	{
		if(	(x>=gad->ng.ng_LeftEdge)	&& 	(x<=(gad->ng.ng_LeftEdge+gad->ng.ng_Width)) &&
				(y>=gad->ng.ng_TopEdge)		&&	(y<=(gad->ng.ng_TopEdge+gad->ng.ng_Height)))
		{
			node=gad->helpnode;
			break;
		}
		gad=gad->NextGadget;
	}

	/* Pointer not over a gadget.  Check if over a gadget title */
	if(node==NULL | (gad && gad->kind==EG_GROUP_KIND))
	{
		register UWORD tmp;

		oldnode=node;
		node=NULL;

		gad=task->eglist;
		while(gad)
		{
			if(gad->ng.ng_GadgetText && gad->helpnode)
				if(	ISBITSET(gad->ng.ng_Flags, PLACETEXT_LEFT) &&
						x<=gad->ng.ng_LeftEdge &&
						x>=gad->ng.ng_LeftEdge-egTextWidth(task->eg, gad->ng.ng_GadgetText)+EG_LabelSpace &&
						y>=gad->ng.ng_TopEdge &&
						y<=gad->ng.ng_TopEdge+gad->ng.ng_Height)
				{
					node=gad->helpnode;
					break;
				}
				else if(ISBITSET(gad->ng.ng_Flags, PLACETEXT_RIGHT) &&
						x>(tmp=gad->ng.ng_LeftEdge+gad->ng.ng_Width) &&
						x<=tmp+egTextWidth(task->eg, gad->ng.ng_GadgetText)+EG_LabelSpace  &&
						y>=gad->ng.ng_TopEdge &&
						y<=gad->ng.ng_TopEdge+gad->ng.ng_Height)
				{
					node=gad->helpnode;
					break;
				}
				else if(ISBITSET(gad->ng.ng_Flags, PLACETEXT_ABOVE) &&
						x<gad->ng.ng_TopEdge																&&
						x>=gad->ng.ng_TopEdge-gad->ng.ng_TextAttr->ta_YSize	&&
						y>=gad->ng.ng_LeftEdge															&&
						y<=gad->ng.ng_LeftEdge+gad->ng.ng_Height+EG_LabelSpaceV)
				{
					node=gad->helpnode;
					break;
				}
				else if(ISBITSET(gad->ng.ng_Flags, PLACETEXT_BELOW) &&
						x>(tmp=gad->ng.ng_TopEdge+gad->ng.ng_Height)		&&
						x<=tmp+gad->ng.ng_TextAttr->ta_YSize						&&
						y>=gad->ng.ng_LeftEdge													&&
						y<=gad->ng.ng_LeftEdge+gad->ng.ng_Height+EG_LabelSpaceV)
				{
					node=gad->helpnode;
					break;
				}
			gad=gad->NextGadget;
		}
		if(node==NULL)
			node=oldnode;
	}
	return (node==NULL ? task->helpnode:node);
}

__asm __saveds BYTE egShowAmigaGuide(	register __a0 struct EasyGadgets	*eg,
																			register __a1 char								*node)
{
	BYTE success=FALSE;
#ifdef MYDEBUG_H
	DebugOut("egShowAmigaGuide");
#endif

	if(AmigaGuideBase==NULL)
		AmigaGuideBase=OpenLibrary("amigaguide.library", AMIGAGUIDEVERSION);

	if(AmigaGuideBase)
	{
		sprintf(eg->GuideMsg, "LINK %s", (char *)(node==NULL ? "Main":node));

		if(eg->AG_Context==NULL)
		{
			eg->AG_NewGuide.nag_Lock			=NULL;
			eg->AG_NewGuide.nag_Name			=eg->helpdoc;
			eg->AG_NewGuide.nag_Screen		=eg->screen;
			eg->AG_NewGuide.nag_ClientPort=eg->basename;
			eg->AG_NewGuide.nag_BaseName	=eg->basename;
			eg->AG_NewGuide.nag_Flags			=HTF_CACHE_NODE|HTF_NOACTIVATE;

			if(eg->AG_Context=OpenAmigaGuideAsync(&eg->AG_NewGuide, TAG_DONE))
			{
				eg->AmigaGuideSignal=AmigaGuideSignal(eg->AG_Context);
				success=TRUE;
			}
		}
		else
		{
			SendAmigaGuideCmd(eg->AG_Context, eg->GuideMsg, NULL);
			success=TRUE;
		}
	}
	return success;
}

__asm __saveds void egHandleAmigaGuide(register __a0 struct EasyGadgets *eg)
{
	register struct AmigaGuideMsg *agm;

#ifdef MYDEBUG_H
	DebugOut("egHandleAmigaGuide");
#endif

	if(AmigaGuideBase && eg->AG_Context)
		while(agm=GetAmigaGuideMsg(eg->AG_Context))
		{
			switch(agm->agm_Type)
			{
				case ActiveToolID:
					SendAmigaGuideCmd(eg->AG_Context, eg->GuideMsg, NULL);
					break;
				case ToolCmdReplyID:
				case ToolStatusID:
				case ShutdownMsgID:
					if(agm->agm_Pri_Ret)
					{
						register struct egTask	*task;

						for(task=eg->tasklist; task; task=task->nexttask)
							if(task->window)
							{
								APTR parms[3];

								parms[0]=(APTR)GetAmigaGuideString(agm->agm_Sec_Ret);
								parms[1]=(APTR)eg->helpdoc;
								parms[2]=NULL;
								egLockAllTasks(eg);
								egRequestA(task->window, task->window->Title, "%s:\n%s", "OK", parms);
								egUnlockAllTasks(eg);
								break;
							}
					}
					break;
				}
			ReplyAmigaGuideMsg(agm);
		}
}

__asm __saveds void egCloseAmigaGuide(register __a0 struct EasyGadgets *eg)
{
#ifdef MYDEBUG_H
	DebugOut("egCloseAmigaGuide");
#endif
	if(eg->AG_Context)
		CloseAmigaGuide(eg->AG_Context);
	if(AmigaGuideBase)
		CloseLibrary(AmigaGuideBase);

	eg->AG_Context=NULL;
	AmigaGuideBase=NULL;
}

#endif
