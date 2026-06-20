/*
 *	File:					
 *	Description:	
 *
 *	(C) 1994,1995 Ketil Hunn
 *
 */

#ifndef EG_WINDOWS_H
#define EG_WINDOWS_H

/*** DEFINES *************************************************************************/
#define	EG_EGWINDOW	~0

/*** GLOBALS *************************************************************************/
UWORD __chip EG_waitPointer[] =
{
	0x0000,	0x0000,
	0x0400, 0x07C0,
	0x0000, 0x07C0,
	0x0100, 0x0380,
	0x0000, 0x07E0,
	0x07C0, 0x1FF8,
	0x1FF0, 0x3FEC,
	0x3FF8, 0x7FDE,
	0x3FF8, 0x7FBE,
	0x7FFC, 0xFF7F,
	0x7EFC, 0xFFFF,
	0x7FFC, 0xFFFF,
	0x3FF8, 0x7FFE,
	0x3FF8, 0x7FFE,
	0x1FF0, 0x3FFC,
	0x07C0, 0x1FF8,
	0x0000, 0x07E0,
	0x0000, 0x0000
};

/*** FUNCTIONS ***********************************************************************/
__asm __saveds int egCountVisitors(register __a0 struct Screen *screen)
{
	register int n=0;
	register struct Window	*window;
	ULONG IntuiLock=LockIBase(0);

#ifdef MYDEBUG_H
	DebugOut("egCountVisitors");
#endif

	for(window=screen->FirstWindow; window!=NULL; window=window->NextWindow)
	{
		if(window->UserData!=(APTR)EG_EGWINDOW)
			++n;
		n-=window->ReqCount;
	}
	UnlockIBase(IntuiLock);
	return n;
}

__asm __saveds ULONG egIsDisplay(	register __a0 struct Screen *screen,
																	register __d0 ULONG is_property)
{
	DisplayInfoHandle handle=FindDisplayInfo(GetVPModeID(&(screen->ViewPort)));

#ifdef MYDEBUG_H
	DebugOut("egIsDisplay");
#endif

	if(handle)
	{
		struct DisplayInfo	di;

		GetDisplayInfoData(handle, (UBYTE *)&di, sizeof(di), DTAG_DISP, NULL);
		if(di.PropertyFlags)
			return (di.PropertyFlags & is_property);
		else
			return 0L;
	}
}

__asm __saveds void egGhostRect(register __a0 struct RastPort	*rp,
																register __d0	SHORT						x,
																register __d1 SHORT 					y,
																register __d2 SHORT 					w,
																register __d3 SHORT 					h,
																register __d4 UBYTE						pen)
{
	register USHORT patterndata[2];

	patterndata[0]=0x2222; patterndata[1]=0x8888;
	SetDrMd(rp, JAM1);
	SetAPen(rp, pen);
	SetAfPt(rp, patterndata, 1);
	RectFill(rp,	x, y, w, h);
	SetAfPt(rp, NULL, 0);
}

__asm __saveds BYTE egLockTaskA(register __a0 struct egTask		*task,
																register __a1 struct TagItem	*taglist)
{
#ifdef MYDEBUG_H
	DebugOut("egLockTask");
#endif

	
	if(task && ++task->reqcount && task->lock==NULL)
	{
		if(task->lock=AllocVec(sizeof(struct Requester), 0))
		{
			InitRequester(task->lock);
			Request(task->lock, task->window);

			if(IntuitionBase->LibNode.lib_Version>=39)
				SetWindowPointer( task->window,
													WA_BusyPointer, TRUE,
													WA_PointerDelay,TRUE,
													TAG_END);
			else
				SetPointer(task->window, EG_waitPointer, 16, 16, -6, 0);

			if(task->status && ISBITSET(task->flags, TASK_GHOSTWHENBLOCKED))
				egGhostRect(task->window->RPort,
										task->window->BorderLeft,	task->window->BorderTop,
										task->window->Width-task->window->BorderRight-1,
										task->window->Height-task->window->BorderBottom-1,
										1);
			SETBIT(task->flags, TASK_BLOCKED);
		}
	}
	return FALSE;
}

__asm __saveds void egUnlockTaskA(register __a0 struct egTask *task,
																	register __a1 struct TagItem *taglist)
{
#ifdef MYDEBUG_H
	DebugOut("UnlockTask");
#endif

	if(task && task->lock && 0==(task->reqcount=MAX(0, task->reqcount-1)))
	{
		if(ISBITSET(task->flags, TASK_GHOSTWHENBLOCKED))
		{
			egGhostRect(task->window->RPort,
								task->window->BorderLeft,	task->window->BorderTop,
								task->window->Width-task->window->BorderRight-1,
								task->window->Height-task->window->BorderBottom-1,
								0);
			RefreshGList(task->glist, task->window, NULL, -1);
			GT_RefreshWindow(task->window, NULL);
		}

		EndRequest(task->lock, task->window);
		FreeVec(task->lock);
		task->lock=NULL;

		if(IntuitionBase->LibNode.lib_Version>=39)
			SetWindowPointer(task->window, TAG_END);
		else
			ClearPointer(task->window);

		CLEARBIT(task->flags, TASK_BLOCKED);
	}
}

__asm __saveds void egLockAllTasks(register __a0 struct EasyGadgets *eg)
{
	register struct egTask	*task;

	for(task=eg->tasklist; task; task=task->nexttask)
		if(task->status==STATUS_OPEN)
			egLockTaskA(task, NULL);
}

__asm __saveds void egUnlockAllTasks(register __a0 struct EasyGadgets *eg)
{
	register struct egTask	*task;

	for(task=eg->tasklist; task; task=task->nexttask)
		if(task->status==STATUS_OPEN)
			egUnlockTaskA(task, NULL);
}

#endif
