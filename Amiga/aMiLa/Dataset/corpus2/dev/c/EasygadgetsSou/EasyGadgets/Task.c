/*
 *	File:					Task.c
 *	Description:	
 *
 *	(C) 1994,1995 Ketil Hunn
 *
 */

#ifndef	EG_TASK_C
#define	EG_TASK_C

/*** PRIVATE INCLUDES ****************************************************************/
#include <intuition/intuition.h>

/*** DEFINES *************************************************************************/
#define	EG_EGWINDOW				~0
#define IM(o) ((struct Image *)o)

/*** FUNCTIONS ***********************************************************************/

__asm __saveds BYTE egOpenTaskA(register __a1 struct egTask				*task,
																register __a0 struct TagItem			*taglist)
{
	struct TagItem	*tstate=taglist;
	register struct TagItem	*tag;
	register BYTE success=FALSE,zoom=FALSE, depth=FALSE, iconify=FALSE, helpmenu=FALSE, lendmenu=FALSE;
	register ULONG idcmp=0L;
	struct Menu		*menu=NULL;
	UWORD					minwidth=0, minheight=0;

	if(task->openguifunc)
		egCallHook(task->openguifunc, task->eg_UserData);

	if(egTaskToFront(task))
		return FALSE;

	task->screen=NULL;
	if(	NULL==(task->screen=(struct Screen *)GetTagData(WA_CustomScreen,	NULL, taglist)) ||
			NULL==(task->screen=(struct Screen *)GetTagData(WA_PubScreen,			NULL, taglist)))
		;
	if(task->screen==NULL)
		task->screen=task->eg->screen;

	task->eg->ng.ng_TextAttr=task->eg->screen->Font;

	if(task->eg->dri=task->dri=GetScreenDrawInfo(task->screen))
		if(task->eg->ng.ng_VisualInfo=task->VisualInfo=GetVisualInfo(task->screen, NULL))
		{
			while(tag=NextTagItem(&tstate))
				switch(tag->ti_Tag)
				{
					case WA_Left:
						task->coords.LeftEdge=(WORD)tag->ti_Data;
						break;
					case WA_Top:
						task->coords.TopEdge=(WORD)tag->ti_Data;
						break;
					case WA_Width:
						task->coords.Width=(WORD)tag->ti_Data;
						break;
					case WA_Height:
						task->coords.Height=(WORD)tag->ti_Data;
						break;
					case EG_InitialCentre:
						if(ISBITSET(task->flags, TASK_NOSIZE))
						{
							task->coords.LeftEdge	=(task->screen->Width-task->coords.Width)/2;
							task->coords.TopEdge	=(task->screen->Height-task->coords.Height)/2;
						}
						break;
					case EG_InitialUpperLeft:
						if(ISBITSET(task->flags, TASK_NOSIZE))
						{
							task->coords.LeftEdge	=0;
							task->coords.TopEdge	=task->eg->ScreenBarHeight;
						}
						break;
					case EG_IDCMP:
						idcmp	=	(ULONG)(tag->ti_Data);
						idcmp|=	IDCMP_REFRESHWINDOW 	|	IDCMP_SIZEVERIFY	|	IDCMP_NEWSIZE			|	
										IDCMP_CLOSEWINDOW			|	IDCMP_MENUHELP		|	IDCMP_RAWKEY			|	
										IDCMP_CHANGEWINDOW		| IDCMP_INACTIVEWINDOW;
						break;
					case WA_MinWidth:
						minwidth=(UWORD)tag->ti_Data;
						zoom=TRUE;
						break;
					case WA_MinHeight:
						minheight=(UWORD)tag->ti_Data;
						zoom=TRUE;
						break;
					case EG_LendMenu:
						lendmenu=TRUE;
					case EG_Menu:
						menu=(struct Menu *)tag->ti_Data;
						break;
					case EG_HelpMenu:
						helpmenu=(BYTE)tag->ti_Data;
						break;
					case EG_RefreshFunc:
						task->refreshfunc=(void *)tag->ti_Data;
						break;
					case EG_RenderFunc:
						task->renderfunc=(void *)tag->ti_Data;
						break;
					case EG_OpenFunc:
						task->openfunc=(void *)tag->ti_Data;
						break;
					case EG_CloseFunc:
						task->closefunc=(void *)tag->ti_Data;
						break;
					case EG_HandleFunc:
						task->handlefunc=(void *)tag->ti_Data;
						break;
					case WA_DepthGadget:
						depth=(BYTE)tag->ti_Data;
						break;
					case WA_SizeGadget:
						zoom=(BYTE)tag->ti_Data;
						break;
					case EG_IconifyGadget:
						iconify=(BYTE)tag->ti_Data;
						idcmp|=GADGETUP;
						break;
					case EG_GhostWhenBlocked:
						IFTRUESETBIT(tag->ti_Data, task->flags, TASK_GHOSTWHENBLOCKED);
						break;
					case EG_Blocked:
						IFTRUESETBIT(tag->ti_Data, task->flags, TASK_BLOCKED);
						break;
					case EG_HelpNode:
						task->eg->lasthelpnode=task->helpnode=(UBYTE *)tag->ti_Data;
						break;
					case EG_OpenGUIFunc:
						task->openguifunc=(void *)tag->ti_Data;
						break;
					case EG_CloseGUIFunc:
						task->closeguifunc=(void *)tag->ti_Data;
						break;
					case EG_ScreenNotify:
						if(task->eg->notifyport && tag->ti_Data)
							task->screenhandle=AddCloseScreenClient((struct Screen *)tag->ti_Data,
																											task->eg->notifyport,
																											0);
						break;
					case EG_PubScreenNotify:
						if(task->eg->notifyport && tag->ti_Data)
							task->screenhandle=AddPubScreenClient(task->eg->notifyport, 0);
						break;
				}

			if(iconify && task->eg->iconifyclass)
			{
				register WORD		relpos=0;
				register int		resolution=(task->eg->screen->Flags & SCREENHIRES ? SYSISIZE_MEDRES : SYSISIZE_LOWRES);
				register Object	*depthimage, *zoomimage;
				
				if(depthimage=NewObject(NULL, SYSICLASS,
																SYSIA_DrawInfo, task->eg->dri,
																SYSIA_Which,		DEPTHIMAGE,
																SYSIA_Size,			resolution,
																TAG_DONE))
				{
					if(zoomimage=NewObject(	NULL, SYSICLASS,
																	SYSIA_DrawInfo, task->eg->dri,
																	SYSIA_Which,		ZOOMIMAGE,
																	SYSIA_Size,			resolution,
																	TAG_DONE))
					{
						if(depth)
							relpos=-IM(depthimage)->Width+1;
						if(zoom)
							relpos-=IM(zoomimage)->Width-1;
						if(iconify)
							relpos-=IM(depthimage)->Width-1;
	
						task->iconifygadget=(struct Gadget *)NewObject(task->eg->iconifyclass,	NULL,
																		GA_TopBorder,		TRUE,
																		GA_RelRight,		relpos,
																		GA_Width,				IM(zoomimage)->Width,
																		GA_Height,			task->screen->BarHeight,
																		GA_RelVerify,		TRUE,
																		TAG_DONE);

						DisposeObject(zoomimage);
					}
					DisposeObject(depthimage);
				}
			}

			if(task->window=OpenWindowTags(NULL,
																WA_Left,					task->coords.LeftEdge,
																WA_Top,						task->coords.TopEdge,
																WA_Width,					MAX(minwidth, task->coords.Width),
																WA_Height,				MAX(minheight, task->coords.Height),
																WA_NewLookMenus,	TRUE,
																WA_MenuHelp,			TRUE,
																TAG_MORE,					taglist,
																TAG_DONE))
			{
				if(iconify && task->iconifygadget)
				{
					AddGadget(task->window, task->iconifygadget, 0);
					RefreshGList(task->iconifygadget, task->window, NULL, 1);
				}

				if(idcmp)
				{
					task->window->UserPort=task->eg->msgport;
					ModifyIDCMP(task->window,	idcmp);
				}

				if(task->renderfunc)
				{
					egCallHook(task->renderfunc, task->eg_UserData);
					egRenderGadgets(task);
				}
				if(task->refreshfunc)
					egCallHook(task->refreshfunc, task->eg_UserData);

				task->status=STATUS_OPEN;
				if(ISBITSET(task->flags, TASK_BLOCKED))
					egLockTaskA(task, NULL);

				if(menu)
				{
					if(!lendmenu)
					{
						LayoutMenus(menu, task->VisualInfo,
															GTMN_NewLookMenus,	TRUE,
															TAG_END);
						if(helpmenu)
							egMakeHelpMenu(menu, task->screen);
					}
					SetMenuStrip(task->window, menu);
				}

				task->window->UserData=(APTR)EG_EGWINDOW;
				CLEARBIT(task->flags, TASK_NOSIZE);
				success=TRUE;
			}
		}
	return success;
}

__asm __saveds void egCloseTask(register __a0 struct egTask *task)
{
	register struct Window *window=task->window;
	register ULONG close=TRUE;

#ifdef MYDEBUG_H
	DebugOut("egCloseTask");
#endif

	if(window)
	{
#ifdef MYDEBUG_H
	DebugOut("freed glist");
#endif

		if(task->screenhandle)
		{
			while(!RemPubScreenClient(task->screenhandle))
				Delay(10);
			task->screenhandle=NULL;
		}
		if(task->pubhandle)
		{
			while(!RemPubScreenClient(task->pubhandle))
				Delay(10);
			task->pubhandle=NULL;
		}

		if(task->closefunc)
			close=egCallHook(task->closefunc, (APTR)task->window);

		if(close)
		{
			egFreeGList(task);

			if(ISBITSET(task->flags, TASK_BLOCKED))
			{
				egUnlockTaskA(task, NULL);
				SETBIT(task->flags, TASK_BLOCKED);
			}

			ClearMenuStrip(window);
			task->coords.LeftEdge	=window->LeftEdge;
			task->coords.TopEdge	=window->TopEdge;
			task->coords.Width		=window->Width;
			task->coords.Height		=window->Height;
			egCloseWindowSafely(window);
#ifdef MYDEBUG_H
			DebugOut("closed window safely");
#endif
			if(task->iconifygadget)
			{
				DisposeObject(task->iconifygadget);
				task->iconifygadget=NULL;
			}

			if(task->closeguifunc)
				egCallHook(task->closeguifunc, task->eg_UserData);

			task->iconifygadget=NULL;
			task->window=NULL;
			if(	ISBITSET(task->eg->flags, EG_ICONIFIED) |
					ISBITSET(task->eg->flags, EG_RESET))
				task->status=STATUS_RESET;
			else
				task->status=STATUS_CLOSED;

			if(task->VisualInfo)
				FreeVisualInfo(task->VisualInfo);
			if(task->dri)
				FreeScreenDrawInfo(task->screen, task->dri);
		}
	}
}

__asm __saveds void egOpenAllTasks(register __a0 struct EasyGadgets	*eg)
{
	register struct egTask *task;

	for(task=eg->tasklist; task; task=task->nexttask)
		if(task->status>STATUS_CLOSED && task->openfunc)
			egCallHook(task->openfunc, (APTR)eg->tasklist);

	if(ISBITSET(eg->flags, EG_OPENHELPDOCUMENT))
	{
		egShowAmigaGuide(eg, eg->GuideMsg);
		CLEARBIT(eg->flags, EG_OPENHELPDOCUMENT);
	}
}

__asm __inline void closealltasks(register __a0 struct egTask	*task)
{
	if(task->nexttask!=NULL)
		closealltasks(task->nexttask);
	egCloseTask(task);
}

__asm __saveds void egCloseAllTasks(register __a0 struct EasyGadgets	*eg)
{
	if(eg->AG_Context)
	{
		CloseAmigaGuide(eg->AG_Context);
		eg->AG_Context=NULL;
//		SETBIT(eg->flags, EG_OPENHELPDOCUMENT);
	}
	closealltasks(eg->tasklist);
}

__asm __saveds void egResetAllTasks(register __a0 struct EasyGadgets *eg)
{
	SETBIT(eg->flags, EG_RESET);
	egCloseAllTasks(eg);
	egOpenAllTasks(eg);
	CLEARBIT(eg->flags, EG_RESET);
}

__asm __saveds BYTE egTaskToFront(register __a0 struct egTask *task)
{
#ifdef MYDEBUG_H
	DebugOut("egTaskToFront");
#endif
	if(task->window)
	{
		WindowToFront(task->window);
		ActivateWindow(task->window);
		return TRUE;
	}
	return FALSE;
}

__asm __saveds void egLinkTasksA(	register __a1 struct EasyGadgets	*eg,
																	register __a0 struct egTask				**tasks)
{
	register ULONG i=0;
	struct egTask *task=tasks[0];

#ifdef MYDEBUG_H
	DebugOut("egLinkTasksA");
#endif

	eg->tasklist=task;
	while(task!=NULL)
	{
		SETBIT(task->flags, TASK_NOSIZE);
		task->eg						=eg;
		task->screen				=NULL;
		task->status				=STATUS_CLOSED;
		task->window				=NULL;
		task->iconifygadget	=NULL;

		task->nexttask=tasks[++i];
		task					=tasks[i];
	}
}

#endif
