/*
 *	File:					Listview_kind.h
 *	Description:	
 *
 *	(C) 1994, Ketil Hunn
 *
 */


#ifndef LISTVIEW_KIND_H
#define LISTVIEW_KIND_H

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/lists.h>
#include <exec/libraries.h>

#include <graphics/gfxmacros.h>
#include <graphics/regions.h>

#include <intuition/intuition.h>
#include <intuition/classusr.h>
#include <intuition/gadgetclass.h>
#include <intuition/icclass.h>
#include <intuition/imageclass.h>

#include <utility/tagitem.h>

#include <stdlib.h>

#include <proto/all.h>

extern  Class *CreateListviewClass(void);
extern  BOOL DisposeListviewClass(Class *cl);

#define EGLV_TAGBASE			(TAG_USER + 700)
#define EGLV_Labels				(EGLV_TAGBASE)
#define EGLV_Selected			(EGLV_TAGBASE+1)
#define EGLV_TextFont			(EGLV_TAGBASE+2)
#define EGLV_MinWidth			28
#define EGLV_MinHeight		8

/*****************************************************/
/* Private data, do NOT USE this outside class code. */
/*****************************************************/
#ifdef LISTVIEWCLASS_PRIVATE

#define EGLV_SetTagArg(tag, id, data)   {tag.ti_Tag = (ULONG)(id);\
                                        tag.ti_Data = (ULONG)(data);}

typedef ULONG (*HookFunction)(void);

struct ListviewData {
	struct  List *Labels;
	UWORD   Active;
	UWORD   Count;
	BOOL    NewLook;

	/* For rendering. */
	struct  Image *FrameImage;
	struct  TextFont *Font;

	/* Temporary data for Listview. */
	UWORD   ItemHeight;
	UWORD   FitsItems;
	BOOL    ActiveFromMouse;
	UWORD   Temp_Active;
	struct  Window *popup_window;
	struct  Rectangle rect;
};

#endif

#endif
