/*
** Routines for drawing a progress bar
** By Tom Bampton
**
** © 1996 Eden Software
*/

#define Prototype extern

#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include <libraries/gadtools.h>
#include <graphics/gfx.h>
#include <utility/tagitem.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/graphics_protos.h>
#include <clib/utility_protos.h>

#include "PBar.h"

/* Private structures */
struct PBar
{
	int pb_XPos;			/* X Position */
	int pb_YPos;			/* Y Position */
	int pb_Width;			/* Width */
	int pb_Height;			/* Height */
	UBYTE pb_BarCol;		/* Bar colour */
	
	int pb_Current;			/* Current percentage */
	
	APTR pb_VisInfo;		/* Visual Info (for gadtools) */
	struct Window *pb_Win;	/* Window */
};

/* Protos */
Prototype APTR CreatePBarA(struct TagList *taglist);
Prototype APTR CreatePBar(Tag *ft, ...);
Prototype void UpdatePBarA(APTR pbar, struct TagList *taglist);
Prototype void UpdatePBar(APTR pbar, Tag *ft, ...);
Prototype void RefreshPBar(APTR pb);
Prototype void FreePBar(APTR pb);
Prototype void ClearPBar(APTR pbar);
Prototype void DrawPBar(struct PBar *pb);

/****** pbar.lib/CreatePBar ******************************************
*
*   NAME	
*		CreatePBarA -- Create a new progress bar
*		CreatePBar -- Varargs stub for CreatePBarA()
*
*   SYNOPSIS
*		pbar = CreatePBarA(taglist)
*		APTR CreatePBarA(struct TagList *)
*
*		pbar = CreatePBar(firsttag, ...)
*		APTR CreatePBar(Tag *, ...)
*		
*   FUNCTION
*		Creates a new progress bar. You _MUST_ specify _ALL_ the tags.
*
*   INPUTS
*		taglist		- pointer to a tag list.
*			PB_VisualInfo		Visual Info (see gadtools.library/GetVisualInfo())
*			PB_LeftEdge			X position of progress bar
*			PB_TopEdge			Y position of progress bar
*			PB_Width			Width of progress bar
*			PB_Height			Height of progress bar
*			PB_BarColour		Progress bar colour
*			PB_Window			Window for progress bar
*
*   RESULT
*		Pointer to a progress bar. NULL if failed.
*
*   BUGS
*		None known
*
*   SEE ALSO
*		gadtools.library/GetVisualInfo() intuition.library/OpenWindow()
******************************************************************************
*
* Have you read the docs ? It says you may not make this into a runtime shared
* library. 
*/
APTR CreatePBarA(struct TagList *taglist)
{
	struct PBar *pb;
	struct TagItem *tag = NULL;
	
	if(!(pb = AllocVec(sizeof(struct PBar), MEMF_CLEAR|MEMF_ANY)))
		return(NULL);
	
	if(tag = FindTagItem(PB_VisualInfo, taglist))
	{
		pb->pb_VisInfo = (APTR)tag->ti_Data;
	}
	
	if(tag = FindTagItem(PB_LeftEdge, taglist))
	{
		pb->pb_XPos = (int)tag->ti_Data;
	}
	
	if(tag = FindTagItem(PB_TopEdge, taglist))
	{
		pb->pb_YPos = (int)tag->ti_Data;
	}
	
	if(tag = FindTagItem(PB_Width, taglist))
	{
		pb->pb_Width = (int)tag->ti_Data;
	}
	
	if(tag = FindTagItem(PB_Height, taglist))
	{
		pb->pb_Height = (int)tag->ti_Data;
	}
	
	if(tag = FindTagItem(PB_BarColour, taglist))
	{
		pb->pb_BarCol = (UBYTE)tag->ti_Data;
	}
	
	if(tag = FindTagItem(PB_Window, taglist))
	{
		pb->pb_Win = (struct Window *)tag->ti_Data;
	}
	
	/* Data structure setup, now we draw it :) */
	DrawPBar(pb);
	
	return(pb);
}

APTR CreatePBar(Tag *ft, ...)
{	
	return(CreatePBarA(&ft));
}

/****** pbar.lib/UpdatePBar ******************************************
*
*   NAME	
*		UpdatePBarA -- Update a progress bar
*		UpdatePBar -- Varargs stub for UpdatePBarA()
*
*   SYNOPSIS
*		void UpdatePBarA(pbar, taglist)
*		void CreatePBarA(APTR, struct TagList *)
*
*		void UpdatePBar(pbar, firsttag, ...)
*		void UpdatePBar(APTR, Tag *, ...)
*		
*   FUNCTION
*		Updates the progress bar, changing its current value. 
*
*   INPUTS
*		pbar		- pointer to pbar as returned by CreatePBarA()
*		taglist		- pointer to a tag list.
*			PB_NewValue			New value for progress bar (in percent)
*			PB_NewColour		New colour for progress bar
*
*	NOTES
*		No range checking is done on the value you supply. if its over 100
*       or less then 0 the display will look wrong.
*
*   BUGS
*		None known
*
*   SEE ALSO
*		CreatePBar() RefreshPBar()
******************************************************************************
*
* Have you read the docs ? It says you may not make this into a runtime shared
* library. 
*/
void UpdatePBarA(APTR pbar, struct TagList *taglist)
{
	struct TagItem *tag;
	struct PBar *pb;
	
	pb = (struct PBar *)pbar;
	
	if(tag = FindTagItem(PB_NewValue, taglist))
	{
		pb->pb_Current = (int)tag->ti_Data;
	}
	
	if(tag = FindTagItem(PB_NewColour, taglist))
	{
		pb->pb_BarCol = (int)tag->ti_Data;
	}
	
	DrawPBar(pb);
	
	return;
}

void UpdatePBar(APTR pbar, Tag *ft, ...)
{	
	return(UpdatePBarA(pbar, &ft));
}

/****** pbar.lib/RefreshPBar ******************************************
*
*   NAME	
*		RefreshPBar -- Refresh a progress bar
*
*   SYNOPSIS
*		void RefreshPBar(pbar)
*		void RefreshPBar(APTR)
*		
*   FUNCTION
*		Refreshes a progress bar's imagery.
*
*   INPUTS
*		pbar		- pointer to pbar as returned by CreatePBarA()
*
*   BUGS
*		None known
*
*   SEE ALSO
*		CreatePBar() UpdatePBar()
******************************************************************************
*
* Have you read the docs ? It says you may not make this into a runtime shared
* library. 
*/
void RefreshPBar(APTR pb)
{
	DrawPBar((struct PBar *)pb);
	
	return;
}

/****** pbar.lib/FreePBar ******************************************
*
*   NAME	
*		FreePBar -- Free a progress bar
*
*   SYNOPSIS
*		void FreePBar(pbar)
*		void FreePBar(APTR)
*		
*   FUNCTION
*		Frees memory taken by a progress bar.
*
*   INPUTS
*		pbar		- pointer to pbar as returned by CreatePBarA()
*
*   BUGS
*		None known
*
*   SEE ALSO
*		CreatePBar() UpdatePBar() RefreshPBar()
******************************************************************************
*
* Have you read the docs ? It says you may not make this into a runtime shared
* library. 
*/
void FreePBar(APTR pb)
{
	FreeVec(pb);
	
	return;
}

/****** pbar.lib/ClearPBar ******************************************
*
*   NAME	
*		ClearPBar -- Clears a progress bar
*
*   SYNOPSIS
*		void ClearPBar(pbar)
*		void ClearPBar(APTR)
*		
*   FUNCTION
*		Clears the progress bar.
*
*   INPUTS
*		pbar		- pointer to pbar as returned by CreatePBarA()
*
*   BUGS
*		None known
*
*   SEE ALSO
*		CreatePBar() UpdatePBar() RefreshPBar()
******************************************************************************
*
* Have you read the docs ? It says you may not make this into a runtime shared
* library. 
*/
void ClearPBar(APTR pbar)
{
	struct PBar *pb = (struct PBar *)pbar;
	
	int col, cur;
	
	col = pb->pb_BarCol;
	cur = pb->pb_Current;
	
	pb->pb_BarCol = 0;
	pb->pb_Current = 100;
	
	DrawPBar(pb);
	
	pb->pb_BarCol = col;
	pb->pb_Current = cur;
}

/* Private routine to draw the Pbar */
void DrawPBar(struct PBar *pb)
{
	int drwidth = 0;
	
	DrawBevelBox(pb->pb_Win->RPort, pb->pb_XPos, pb->pb_YPos, pb->pb_Width, pb->pb_Height,
					GT_VisualInfo,	pb->pb_VisInfo,
					GTBB_Recessed,	TRUE,
					TAG_DONE);
	
	SetAPen(pb->pb_Win->RPort, pb->pb_BarCol);
	
	/* Calculate width from percentage */
	drwidth = (pb->pb_Current * (pb->pb_Width / 100)) - 4;
	
	RectFill(pb->pb_Win->RPort,
		pb->pb_XPos + 2, pb->pb_YPos + 1,
		(pb->pb_XPos + 2) + drwidth, ((pb->pb_YPos) + pb->pb_Height) - 2);
}
