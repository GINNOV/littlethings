/* ********************************************** **
**       protos for wizard.library                **
**                                                **
**       © 1996 HAAGE & Partner                   **
**       Autor: Thomas Mittelsdorf                **
**                                                **
** ********************************************** */

#ifndef _INCLUDE_PROTOS_WIZARD_LIB_H
#define _INCLUDE_PROTOS_WIZARD_LIB_H

#ifndef	EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef UTILITY_TAGITEM_H
#include	<utility/tagitem.h>
#endif

#ifndef LIBRARIES_WIZARD_H
#include <libraries/wizard.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

struct WizardWindowHandle *WZ_AllocWindowHandleA(struct Screen *scr,ULONG usersize,APTR surface,struct TagItem *tags);
struct WizardWindowHandle *WZ_AllocWindowHandle(struct Screen *scr,ULONG usersize,APTR surface,Tag Tag1, ... );
void WZ_CloseSurface(APTR surface);
void WZ_CloseWindow(struct WizardWindowHandle *winhandle);
struct NewWindow *WZ_CreateWindowObjA(struct WizardWindowHandle *winhandle,ULONG id,struct TagItem *tags);
struct NewWindow *WZ_CreateWindowObj(struct WizardWindowHandle *winhandle,ULONG id,Tag Tag1, ... );
BOOL WZ_DrawVImageA(struct WizardVImage *vimage,WORD x,WORD y, WORD w,WORD h,WORD type,struct RastPort *rp,struct DrawInfo *dri,struct TagItem *tags);
BOOL WZ_DrawVImage(struct WizardVImage *vimage,WORD x,WORD y, WORD w,WORD h,WORD type,struct RastPort *rp,struct DrawInfo *dri,Tag Tag1, ... );
LONG WZ_EasyRequestArgs(APTR surface,struct Window *win,ULONG id,void *args);
void WZ_FreeWindowHandle(struct WizardWindowHandle *winhandle);
STRPTR WZ_GadgetConfig(struct WizardWindowHandle *winhandle,struct Gadget *gad);
STRPTR WZ_GadgetHelp(struct WizardWindowHandle *winhandle,APTR iaddress);
BOOL WZ_GadgetHelpMsg(struct WizardWindowHandle *winhandle,struct WizardWindowHandle **winhaddress,APTR *IAddress,WORD MouseX,WORD MouseY,UWORD flags);
BOOL WZ_GadgetKeyA(struct WizardWindowHandle *winhandle,ULONG code,ULONG qualifier,struct TagItem *tags);
BOOL WZ_GadgetKey(struct WizardWindowHandle *winhandle,ULONG code,ULONG qualifier,Tag Tag1, ... );
struct WizardNode *WZ_GetNode(struct MinList *list,ULONG number);
struct EasyStruct *WZ_InitEasyStruct(APTR surface,struct EasyStruct *easy,ULONG id,ULONG size);
void WZ_InitNodeA(struct WizardNode *wnode,ULONG entrys,struct TagItem *tags);
void WZ_InitNode(struct WizardNode *wnode,ULONG entrys,Tag Tag1, ... );
void WZ_InitNodeEntryA(struct WizardNode *wnode,ULONG entry,struct TagItem *tags);
void WZ_InitNodeEntry(struct WizardNode *wnode,ULONG entry,Tag Tag1, ... );
ULONG WZ_ListCount(struct MinList *list);
void WZ_LockWindow(struct WizardWindowHandle *winhandle);
void WZ_LockWindows(APTR surface);
STRPTR WZ_MenuConfig(struct WizardWindowHandle *winhandle, ULONG code);
STRPTR WZ_MenuHelp(struct WizardWindowHandle *winhandle,ULONG code);
struct Gadget *WZ_NewObjectA(APTR surface, ULONG Class, struct TagItem *tags);
struct Gadget *WZ_NewObject(APTR surface, ULONG Class, Tag Tag1, ... );
BOOL WZ_ObjectID(APTR surface,ULONG *id,STRPTR name);
APTR WZ_OpenSurfaceA(STRPTR name,APTR memadr,struct TagItem *);
APTR WZ_OpenSurface(STRPTR name,APTR memadr,Tag Tag1, ... );
struct Window *WZ_OpenWindowA(struct WizardWindowHandle *winhandle,struct NewWindow *newwin,struct TagItem *tags);
struct Window *WZ_OpenWindow(struct WizardWindowHandle *winhandle,struct NewWindow *newwin,Tag Tag1, ... );
BOOL WZ_SnapShotA(APTR surface,struct TagItem *tags);
BOOL WZ_SnapShot(APTR surface,Tag Tag1, ... );
ULONG WZ_UnlockWindow(struct WizardWindowHandle *winhandle);
void WZ_UnlockWindows(APTR surface);
struct BitMap *WZ_CreateImageBitMap(UWORD TransPen,struct DrawInfo *DrInfo,struct WizardNewImage *newimage,struct Screen *screen,UBYTE *reg);
void WZ_DeleteImageBitMap(struct BitMap *bm,struct WizardNewImage *newimage,struct Screen *screen,UBYTE *reg);
APTR WZ_GetDataAddress(APTR surface,ULONG Type,ULONG ID);
STRPTR WZ_GadgetObjectname(struct WizardWindowHandle *winhandle,struct Gadget *gad);
STRPTR WZ_MenuObjectname(struct WizardWindowHandle *winhandle,ULONG code);

#ifdef __cplusplus
}
#endif

#ifdef STORMPRAGMAS
#ifndef _INCLUDE_PRAGMA_WIZARD_LIB_H
#include <pragma/wizard_lib.h>
#endif
#endif

#endif
