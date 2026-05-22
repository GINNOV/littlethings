/*
 *	File:					EasyGadgets.h
 *	Description:	
 *
 *	(C) 1994,1995, Ketil Hunn
 *
 */

#ifndef LIBRARIES_EASYGADGETS_H
#define LIBRARIES_EASYGADGETS_H

/*** PRIVATE INCLUDES ****************************************************************/
#ifndef LIBRARIES_GADTOOLS_H
#include <libraries/gadtools.h>
#endif

#ifndef INTUITION_GADGETCLASS_H
#include <intuition/gadgetclass.h>
#endif

#ifndef CLIB_EASYGADGETS_PROTOS_H
#include <clib/easygadgets_protos.h>
#endif

#ifndef CLIB_AMIGAGUIDE_PROTOS_H
#include <clib/amigaguide_protos.h>
#endif

#include <intuition/icclass.h>
#include <intuition/classes.h>
#include <graphics/text.h>
#include <graphics/gfxmacros.h>

/*** DEFINES *************************************************************************/

#define	EASYGADGETSNAME						"easygadgets.library"
#define	EASYGADGETSVERSION				2L

//#define NM_IGNORE	64

/*** MACROS **************************************************************************/
#define	egActivateGadget(g,w,r)		ActivateGadget((g)->gadget, w, r);
#define	egTaskActive(t)						((t)->status)
#define	egActivateTask(t)					((t)->status=STATUS_OPEN)

#define	DetachList(g,w)						egSetGadgetAttrs(g, w, NULL, GTLV_Labels,~0,TAG_END)
#define	AttachList(g,w,l)					egSetGadgetAttrs(g, w, NULL, GTLV_Labels, l,TAG_END)

#define egMenuItemUnderPointer(m)	((ULONG)GTMENUITEM_USERDATA(ItemAddress(m->IDCMPWindow->MenuStrip, m->Code)))
/* Use with care */
#define BufferPos(g)							(((struct StringInfo *)(g)->gadget->SpecialInfo)->BufferPos)
#define String(g)									(((struct StringInfo *)(g)->gadget->SpecialInfo)->Buffer)
#define UndoString(g)							(((struct StringInfo *)(g)->gadget->SpecialInfo)->UndoBuffer)
#define Number(g)									(((struct StringInfo *)(g)->gadget->SpecialInfo)->LongInt)
#define KickStart									(IntuitionBase->LibNode.lib_Version)

/*** Layout Macros ***/
#define	egWindowHeight(t)					((t)->window->Height)
#define	egWindowWidth(t)					((t)->window->Width)
#define	X1(g)											((g)->ng.ng_LeftEdge)
#define	Y1(g)											((g)->ng.ng_TopEdge)
#define	W(g)											((g)->ng.ng_Width)
#define	H(g)											((g)->ng.ng_Height)
#define	X2(g)											(X1(g)+W(g))
#define	Y2(g)											(Y1(g)+H(g))
#define	EG_StringBorder						12
#define	EG_LabelSpaceH						8
#define	EG_LabelSpaceV						6
#define	EG_LabelSpace							EG_LabelSpaceH
#define EG_CycleWidth							55
#define EG_GetfileWidth						17
#define EG_GetdirWidth						20
#define EG_PopupWidth							16

/* KEY CODES */
#define RETURN_KEY								13
#define ESC_KEY										27

#define	MAXCHARS									256

#define	EG_LISTVIEW_NONE					65535
#define	EG_LISTVIEW_FIRST					0
#define	EG_LISTVIEW_LAST					-2
#define	EG_LISTVIEW_ACTIVE				-3

/* task status */
#define	STATUS_CLOSED							0
#define	STATUS_OPEN								1
#define	STATUS_RESET							2

/* egGadget flags */
#define	EG_DISABLED									1		// gadget is disabled
#define	EG_LISTVIEWARROWS						2		// add control by cursor up/down
#define	EG_READONLY									4		// this gadget is read-only
#define	EG_PLACETEXT_LEFT						8		// Left-align text on left side
#define	EG_PLACETEXT_RIGHT					16	// Right-align text on right side

/* egTask flags */
#define	TASK_NOSIZE									1		// init task size
#define	TASK_BLOCKED								2		// set when a task is blocked
#define	TASK_GHOSTWHENBLOCKED				4		// will ghost window when blocked

/* eg flags */
#define	EG_ICONIFIED								1		// application is iconified
#define	EG_RESET										2		// application is about to or has reset itself
#define	EG_OPENHELPDOCUMENT					4		// reopen helpdocument when application resets itself

/* for future use */
#define	EG_LIST											(-1)
#define	EG_SUBLIST									(-2)

/* Message types */
#define	EG_INTUIMSG									(NT_USER-1)

/* IDCMPS */
#define	EGIDCMP_NOTIFY							4294967293

/*** GLOBALS *************************************************************************/
struct egImageExt
{
	struct BitMap		ImageBitMap;
	struct BitMap		BitMap;

	struct Image		Image1;
	struct Image		Image2;
};

struct egGadget
{
	ULONG							kind;
	struct NewGadget	ng;
	struct Gadget			*gadget;
	UBYTE							key,
										*helpnode;
	STRPTR						*labels;
	struct List				*list;
	LONG							active;
	ULONG							flags;
	WORD							min,
										max;

	struct egImageExt	*imageext;
	struct egGadget		*NextGadget,
										*link,
										*group;
};

struct egCoords
{
	WORD	LeftEdge, TopEdge, Width, Height;
};

struct egTask
{
	APTR								VisualInfo;
	struct DrawInfo			*dri;
	struct Screen				*screen;
	struct Window 			*window;
	struct Gadget				*glist;
	struct egCoords			coords;
	WORD								oldWidth,
											oldHeight;
	UBYTE								status;
	struct egGadget			*eglist,
											*activegad;

	UBYTE								activekey;
	struct egTask				*nexttask;
	struct Requester		*req;
	ULONG								reqcount;
	APTR								eg_UserData;
	struct Requester		*lock;
	ULONG								flags;
	struct EasyGadgets	*eg;
	void								*refreshfunc,
											*renderfunc,
											*handlefunc,
											*openfunc,
											*closefunc,
											*openguifunc,
											*closeguifunc;
	struct Gadget				*iconifygadget;
	UBYTE								*helpnode;
	APTR								screenhandle,
											pubhandle;
};

struct EasyGadgets
{
	struct Screen					*screen;
	struct Window					*Window;
	struct RastPort				RPort;
	struct TextFont				*font;
	struct DrawInfo				*dri;

	struct Gadget					*gad;
	struct NewGadget			ng;
	struct egGadget				*eggad, *group;
	struct egTask					*tmptask;
	ULONG 								GadgetKind;

	struct MsgPort				*msgport;
	struct IntuiMessage		*msg;
	struct egTask					*tasklist;

	WORD	VInside,	HInside, HSpace, VSpace,
				GroupBorderLeft, GroupBorderTop, GroupBorderRight, GroupBorderBottom,
				SliderWidth,		SliderHeight,
				CheckboxWidth,	CheckboxHeight,
				MXWidth,				MXHeight,
				LeftMargin,			TopMargin, RightMargin, BottomMargin, BottomMarginNoSize,
				FontHeight,
				DefaultHeight,
				ScreenBarHeight;

	UBYTE									*helpdoc,
												*lasthelpnode,
												*basename;
	APTR									AG_Context;
	struct NewAmigaGuide	AG_NewGuide;
	UBYTE									GuideMsg[MAXCHARS];
	ULONG									AmigaGuideSignal;

	struct AppIcon				*appicon;
	struct DiskObject			*diskobj;

	ULONG									flags;
	Class									*iconifyclass,
												*groupframeclass;

	struct MsgPort				*notifyport;
	APTR									wbhandle;
};

/*** TAGS ****************************************************************************/
#define	EG_TagBase						(TAG_USER+10777)

#define EG_GROUP_KIND					(EG_TagBase+1)
#define	EG_GETFILE_KIND				(EG_TagBase+10)
#define	EG_GETDIR_KIND				(EG_TagBase+11)
#define	EG_POPUP_KIND					(EG_TagBase+12)
#define	EG_IMAGE_KIND					(EG_TagBase+13)
#define	EG_DUMMY_KIND					(EG_TagBase+14)

#define	EG_GadgetID						(EG_TagBase+1)
#define	EG_GadgetText					(EG_TagBase+2)
#define	EG_GadgetFrame				(EG_TagBase+3)
#define	EG_LeftEdge						(EG_TagBase+4)
#define	EG_TopEdge						(EG_TagBase+5)
#define	EG_Width							(EG_TagBase+6)
#define	EG_Height							(EG_TagBase+7)
#define	EG_GadgetKind					(EG_TagBase+8)
#define	EG_VisualInfo					(EG_TagBase+9)
#define	EG_TextAttr						(EG_TagBase+10)
#define	EG_Flags							(EG_TagBase+11)
#define	EG_Window							(EG_TagBase+12)
#define	EG_ParentGadget				(EG_TagBase+13)

#define	EG_PlaceLeft					(EG_TagBase+14)
#define	EG_PlaceRight					(EG_TagBase+15)
#define	EG_PlaceBelow					(EG_TagBase+16)
#define	EG_PlaceOver					(EG_TagBase+17)

#define	EG_AlignLeft					(EG_TagBase+18)
#define	EG_AlignTop						(EG_TagBase+19)
#define	EG_AlignRight					(EG_TagBase+20)
#define	EG_AlignBottom				(EG_TagBase+21)

#define	EG_AlignCentreH				(EG_TagBase+22)
#define	EG_AlignCentreV				(EG_TagBase+23)

#define	EG_CloneWidth					(EG_TagBase+24)
#define	EG_CloneHeight				(EG_TagBase+25)
#define	EG_CloneSize					(EG_TagBase+26)

#define	EG_PlaceWindowLeft		(EG_TagBase+27)
#define	EG_PlaceWindowRight		(EG_TagBase+28)
#define	EG_PlaceWindowTop			(EG_TagBase+29)
#define	EG_PlaceWindowBottom	(EG_TagBase+30)

#define	EG_HSpace							(EG_TagBase+31)
#define	EG_VSpace							(EG_TagBase+32)

#define	EG_HelpNode						(EG_TagBase+33)
#define	EG_HelpDocument				(EG_TagBase+34)
#define	EG_VanillaKey					(EG_TagBase+35)

#define	EG_Basename						(EG_TagBase+36)
#define EG_Link								(EG_TagBase+37)
#define EG_Arrows							(EG_TagBase+38)

#define	EG_DefaultHeight			(EG_TagBase+39)
#define	EG_DefaultWidth				(EG_TagBase+40)

#define	EG_InitialCentre			(EG_TagBase+41)
#define	EG_InitialUpperLeft		(EG_TagBase+42)
#define	EG_Menu								(EG_TagBase+43)
#define	EG_Blocked						(EG_TagBase+44)
#define	EG_IDCMP							(EG_TagBase+45)
#define	EG_RefreshFunc				(EG_TagBase+46)
#define	EG_RenderFunc					(EG_TagBase+47)
#define	EG_CloseFunc					(EG_TagBase+48)
#define	EG_HandleFunc					(EG_TagBase+49)
#define	EG_OpenFunc						(EG_TagBase+50)
#define	EG_OpenGUIFunc				(EG_TagBase+51)
#define	EG_CloseGUIFunc				(EG_TagBase+52)

#define	EG_ImageWidth					(EG_TagBase+53)
#define	EG_ImageHeight				(EG_TagBase+54)
#define	EG_Image							(EG_TagBase+55)
#define	EG_ImageDepth					(EG_TagBase+56)

#define	GTLV_SelectedNode			(EG_TagBase+57)

#define	EG_AppIcon						(EG_TagBase+58)
#define	EG_IconifyGadget			(EG_TagBase+59)

#define	EG_Title							(EG_GadgetText)
#define	EG_ThickFrame					(EG_TagBase+60)
#define	EG_PlaceTitleLeft			(EG_TagBase+61)
#define	EG_PlaceTitleRight		(EG_TagBase+62)
#define	EG_Highlight					(EG_TagBase+63)
#define	EG_Shadow							(EG_TagBase+64)
#define	EG_Font								(EG_TagBase+65)

#define	EG_GhostWhenBlocked		(EG_TagBase+66)

#define	EG_LendMenu						(EG_TagBase+67)
#define	EG_HelpMenu						(EG_TagBase+68)

#define	EG_WorkbenchNotify		(EG_TagBase+69)
#define	EG_ScreenNotify				(EG_TagBase+70)
#define	EG_PubScreenNotify		(EG_TagBase+71)

#endif
