#ifndef POWERTOOLS_H
#define POWERTOOLS_H
/*
**	$VER: PowerTools.h 1.1 (04.04.94)
**
**	C prototypes. For use with 32 bit integers only.
**
**	(C) Copyright 1994 Quadra Development, written by Bart Vanhaeren.
**	    All Rights Reserved
*/
#ifndef  EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef  INTUITION_INTUITION_H
#include <intuition/intuition.h>
#include <exec/nodes.h>
#endif

/* PowerTools flags */
#define PT_USERT	1	/* Use ReqTools ©Nico François */
#define PT_SAVEMODE	2	/* FileRequester is for save/write operation */
#define PT_PERCENT      3       /* Render percent in middle of progressindicator */

/* protos */
/* public */
void pt_BusyPointer(struct Window *,BOOL);
LONG pt_SimpleRequest(struct Window *,STRPTR,STRPTR,STRPTR,WORD);
BOOL pt_FileRequest(struct Window *,STRPTR,STRPTR,STRPTR,WORD);
void pt_SplitPath(STRPTR,STRPTR,STRPTR);
struct pt_Progress *pt_AllocProgress(struct Window *,UWORD,UWORD,UWORD,UWORD,LONG,UWORD);
void pt_UpdateProgress(struct pt_Progress *,LONG);
void pt_FreeProgress(struct pt_Progress *,UWORD);
struct pt_ListRequest *pt_AllocListRequest(struct Window *window,struct TextAttr *font,UWORD flags);
WORD pt_ListRequest(struct pt_ListRequest *listreq,STRPTR title,struct MinList *list,UWORD flags);
void pt_FreeListRequest(struct pt_ListRequest *listreq);
/* private, internal use only */
struct ReqToolsBase *pt_OpenReqTools(void);
void pt_CloseReqTools(void);

/*****************************************************************************/

struct pt_Progress
{
   struct RastPort *pt_rp;     /* Pointer to a RastPort to render in */
   UWORD pt_X;                 /* x-coord upper left */
   UWORD pt_Y;                 /* y-coord upper left */
   UWORD pt_height;            /* height of progress bar */
   UWORD pt_width;             /* width of progress bar */
   LONG  pt_max;               /* maximum value */
   FLOAT pt_progress;          /* current value */
   FLOAT pt_scale;             /* scale factor  */
   UWORD pt_flags;             /* extra info */
};

/* NOTE: ALL OF THE pt_Progress FIELDS ARE PRIVATE AND MAY ONLY BE CHANGED BY
   THE POWERTOOLS FUNCTIONS ! */

/*****************************************************************************/

struct pt_ListRequest
{
   struct Window   *lr_wnd;     /* Pointer to parent Window */
   struct Node     *lr_node;    /* Selected node after exit */
   struct TextAttr *lr_font;    /* Optional font for ListView Gadget */
   UWORD            lr_X;       /* x-coord upper left */
   UWORD            lr_Y;       /* y-coord upper left */
   UWORD            lr_height;  /* height of ListRequest */
   UWORD            lr_width;   /* width of ListRequest */
};

/******************************************************************************/

#endif	 /* POWERTOOLS_H */
