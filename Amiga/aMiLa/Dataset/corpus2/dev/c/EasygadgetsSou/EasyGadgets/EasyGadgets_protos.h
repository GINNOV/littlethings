/*
 *	File:					EasyGadget_protos.h
 *	Description:	
 *
 *	(C) 1995 Ketil Hunn
 *
 */

#ifndef CLIB_EASYGADGETS_PROTOS_H
#define	CLIB_EASYGADGETS_PROTOS_H

#ifndef INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif

#ifndef  CLIB_EXEC_PROTOS_H
#include <clib/exec_protos.h>
#endif

#ifndef	EG_LIB
#ifndef PRAGMAS_EASYGADGETS_PRAGMAS_H
#include <pragmas/EasyGadgets_pragmas.h>
#endif
#endif

#ifndef EASYGADGETS_H
#include <libraries/easygadgets.h>
#endif

/*** EasyGadgets.c ******************************************************************/
__asm __saveds struct EasyGadgets *egAllocEasyGadgetsA(register __a0 struct TagItem *taglist);
__asm __saveds void egFreeEasyGadgets(register __a0 struct EasyGadgets *eg);

__asm __saveds WORD egTextWidth(register __a0 struct EasyGadgets	*eg,
																register __a1 STRPTR							text);
__asm __saveds WORD egMaxLenA(register __a1 struct EasyGadgets		*eg,
															register __a0 UBYTE									**array);
__asm __saveds void egSpreadGadgets(	register __a0 WORD *posarray,
														register __a1 WORD *sizearray,
														register __d0 WORD x1,
														register __d1 WORD x2,
														register __d2 ULONG count,
														register __d3 BYTE space);
__asm __saveds struct egGadget *egCreateGadgetA(register __a1 struct EasyGadgets *eg,
																							register __a0 struct TagItem *taglist);
__asm __saveds int egCountVisitors(register __a0 struct Screen *screen);
__asm __saveds ULONG egIsDisplay(	register __a0 struct Screen *screen,
																	register __d0 ULONG is_property);
__asm __saveds void egInitialize(	register __a0 struct EasyGadgets	*eg,
																	register __a1 struct Screen				*screen,
																	register __a2 struct TextFont			*font);
__asm __saveds BYTE egIconify(register __a0 struct EasyGadgets	*eg,
															register __d0 BYTE								doit);
/*** Menu.c **************************************************************************/
__asm __saveds struct MenuItem *egFindMenuItem(	register __a0 struct Menu *mymenu,
																								register __d0 ULONG idcmp);
__asm __saveds BYTE egIsMenuItemChecked(register __a0 struct Menu *menu,
																				register __d0 ULONG idcmp);
/*
**	__asm __saveds void egCheckMenuItem(register __a0 struct Window	*window,
**																		register __a1 struct Menu		*menu,
**																		register __d0 ULONG					idcmp,
**																		register __d1 BYTE					check);
**	__asm __saveds void egDisableMenuItemA(	register __a0 struct Window	*window,
**																					register __a1 struct Menu		*menu,
**																					register __d0 ULONG					*array);
*/
__asm __saveds struct Menu *egCreateMenuA(register __a0 int *menudata);

__asm __saveds void egSetMenuBitA(register __a0 struct Window	*window,
																	register __a1 struct Menu		*menu,
																	register __d0 ULONG					bit,
																	register __d1 ULONG					*array);
__asm __saveds void egSetMenuItem(register __a0 struct NewMenu	*menuitem,
																	register __d0 UBYTE						type,
																	register __a1 STRPTR					label,
																	register __d1 UWORD						flags,
																	register __d2 LONG						exclude,
																	register __a2 APTR						userdata);

__asm __saveds void egMakeHelpMenu(	register __a0 struct Menu		*menu,
																		register __a1 struct Screen	*screen);
__asm __saveds struct Menu *egCreateMenuA(register __a0 int *menudata);

/*** HandleKeys.c ********************************************************************/
__asm __saveds struct IntuiMessage *egGetMsg(register __a0 struct EasyGadgets	*eg);
__asm __saveds ULONG egWait(register __a0 struct EasyGadgets *eg,
														register __d0 ULONG								signals);
__asm __saveds void egSetGadgetState(	register __a0 struct egGadget *gadget,
																			register __a1 struct Window 	*window,
																			register __d0 BYTE						state);
__asm LONG egHandleListviewArrows(	register __a1 struct egGadget 		*listview,
																		register __a0 struct Window				*window,
																		register __a2 struct IntuiMessage *msg);
__asm __saveds UBYTE egConvertRawKey(register __a0 struct IntuiMessage *msg);
__asm __saveds UBYTE egFindVanillaKey(register __a0 char *text);
__asm __saveds void egGetGadgetAttrsA(register __a0 struct egGadget 	*newgad,
																			register __a1 struct Window			*win,
																			register __a2 struct Requester	*req,
																			register __a3 struct TagItem		*taglist);
__asm __saveds LONG egSetGadgetAttrsA(register __a0 struct egGadget 	*newgad,
																			register __a1 struct Window			*win,
																			register __a2 struct Requester	*req,
																			register __a3 struct TagItem		*taglist);
__asm __saveds struct Node *egGetNode(register __a0 struct List *list,
																			register __d0 ULONG				selected);
__asm __saveds UWORD egCountList(register __a0 struct List *list);

/*** Requesters.c ********************************************************************/
__asm __saveds LONG egDisplayAlert(	register __d0 ULONG alertType,
																		register __a0 UBYTE *msg,
																		register __d1	ULONG timeout);
__asm __saveds LONG egRequestA(	register __a0 struct Window *window,
																register __a1 UBYTE					*title,
																register __a2 UBYTE					*format,
																register __a4 UBYTE					*gadgets,
																register __a3 APTR	 				*args);

/*** Windows.c ***********************************************************************/
__asm __saveds void egCloseWindowSafely(register __a0 struct Window *win);
__asm __saveds BYTE egLockTaskA(register __a0 struct egTask *task, register __a1 struct TagItem *taglist);
__asm __saveds void egUnlockTaskA(register __a0 struct egTask *task, register __a1 struct TagItem *taglist);
__asm __saveds void egLockAllTasks(register __a0 struct EasyGadgets *eg);
__asm __saveds void egUnlockAllTasks(register __a0 struct EasyGadgets *eg);

/*** Task.c **************************************************************************/
__asm __saveds BYTE egOpenTaskA(register __a1 struct egTask				*task,
																register __a0 struct TagItem			*taglist);
__asm __saveds void egCloseTask(register __a0 struct egTask *task);
__asm __saveds BYTE egTaskToFront(register __a0 struct egTask *task);
__asm __saveds void egLinkTasksA(	register __a1 struct EasyGadgets	*eg,
																	register __a0 struct egTask				**tasks);
__asm __saveds void egResetAllTasks(register __a0 struct EasyGadgets *eg);
__asm __saveds void egOpenAllTasks(register __a0 struct EasyGadgets	*eg);
__asm __saveds void egCloseAllTasks(register __a0 struct EasyGadgets	*eg);

/*** Gadgets.c ***********************************************************************/
__asm void egFreeGList(register __a0 struct egTask *task);
__asm __saveds void egRenderGadgets(register __a0 struct egTask *task);
__asm __saveds void egRenderGadgets(register __a0 struct egTask *task);
__asm __saveds struct egGadget *egCreateGadgetA(register __a1 struct EasyGadgets *eg,
																							register __a0 struct TagItem *taglist);
__asm __saveds void egCreateContext(register __a0 struct EasyGadgets	*eg,
																		register __a1 struct egTask				*task);


/*** Help.c **************************************************************************/
__asm __saveds BYTE egShowAmigaGuide(	register __a0 struct EasyGadgets	*eg,
																			register __a1 char								*node);
__asm __saveds void egHandleAmigaGuide(register __a0 struct EasyGadgets *eg);
__asm __saveds void egCloseAmigaGuide(register __a0 struct EasyGadgets *eg);

__asm __saveds void egMakeHelpMenu(	register __a0 struct Menu		*menu,
																		register __a1 struct Screen	*screen);
__asm __saveds void egGhostRect(register __a0 struct RastPort	*rp,
																register __d0	SHORT						x,
																register __d1 SHORT 					y,
																register __d2 SHORT 					w,
																register __d3 SHORT 					h,
																register __d4 UBYTE						pen);

/*** Prototypes for tagcalls *********************************************************/
struct EasyGadgets *egAllocEasyGadgets(Tag tag1, ...);
LONG egRequest(struct Window *window, UBYTE *title, UBYTE *format, UBYTE *gadgets, APTR arg1, ...);
WORD egMaxLen(struct EasyGadgets *eg, UBYTE *text1, ...);
struct egGadget *egCreateGadget(struct EasyGadgets *eg, Tag tag1, ...);
void egLinkTasks(	struct EasyGadgets	*eg,
									struct egTask				*task, ...);
LONG egSetGadgetAttrs(struct egGadget 	*gad,
											struct Window			*win,
											struct Requester	*req,
											Tag tag1, ...);
void egGetGadgetAttrs(struct egGadget 	*gad,
											struct Window			*win,
											struct Requester	*req,
											Tag tag1, ...);
BYTE egOpenTask(struct egTask	*task,
								Tag						tag1, ...);
void egSetMenuBit(struct Window	*window,
									struct Menu		*menu,
									ULONG					bit,
									ULONG					array, ...);
struct Menu *egCreateMenu(int menudata, ...);
BYTE egLockTask(struct egTask *task, Tag tag1, ...);
BYTE egUnlockTask(struct egTask *task, Tag tag1, ...);

#endif
