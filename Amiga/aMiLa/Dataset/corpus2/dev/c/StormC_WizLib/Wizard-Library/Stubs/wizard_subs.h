/* ********************************************** **
**       Stub-Functions for wizard.library        **
**                                                **
**       © 1996 HAAGE & Partner                   **
**       Autor: Thomas Mittelsdorf                **
**                                                **
** ********************************************** */

#ifndef _INCLUDE_STUBS_WIZARD_LIB_H
#define _INCLUDE_STUBS_WIZARD_LIB_H

#ifndef	EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef UTILITY_TAGITEM_H
#include	<utility/tagitem.h>
#endif

#ifndef LIBRARIES_WIZARD_H
#include <libraries/wizard.h>
#endif

#ifndef _INCLUDE_PROTOS_WIZARD_LIB_H
#include <clib/wizard_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

struct WizardWindowHandle *WZ_AllocWindowHandle( struct Screen *scr, ULONG usersize, APTR surface, Tag Tag1, ...)
{
return( WZ_AllocWindowHandleA( scr, usersize, surface, (struct TagItem *)&Tag1));
}

struct NewWindow *WZ_CreateWindowObj( struct WizardWindowHandle *winhandle, ULONG id, Tag Tag1, ...)
{
return(WZ_CreateWindowObjA( winhandle, id, (struct TagItem *)&Tag1));
}

BOOL WZ_DrawVImage(struct WizardVImage *vimage,WORD x,WORD y, WORD w,WORD h,WORD type,struct RastPort *rp,struct DrawInfo *dri,Tag Tag1, ...)
{
return(WZ_DrawVImageA( vimage, x, y, w, h, type, rp, dri, (struct TagItem *)&Tag1));
}

BOOL WZ_GadgetKey(struct WizardWindowHandle *winhandle,ULONG code,ULONG qualifier,Tag Tag1, ... );
{
return(WZ_GadgetKeyA( winhandle, code,qualifier, (struct TagItem *)&Tag1));
}

void WZ_InitNode(struct WizardNode *wnode,ULONG entrys,Tag Tag1, ... );
{
WZ_InitNodeA( wnode, entrys, (struct TagItem *)&Tag1);
}

void WZ_InitNodeEntry(struct WizardNode *wnode,ULONG entry,Tag Tag1, ... );
{
WZ_InitNodeEntryA( wnode, entry, (struct TagItem *)&Tag1);
}

struct Gadget *WZ_NewObject(APTR surface, ULONG Class, Tag Tag1, ... );
{
return(WZ_NewObjectA( surface, Class, (struct TagItem *)&Tag1));
}

APTR WZ_OpenSurface(STRPTR name,APTR memadr,Tag Tag1, ... );
{
return(WZ_OpenSurfaceA( name, memadr, (struct TagItem *)&Tag1));
}

struct Window *WZ_OpenWindow(struct WizardWindowHandle *winhandle,struct NewWindow *newwin,Tag Tag1, ... );
{
return(WZ_OpenWindowA( winhandle, newwin, (struct TagItem *)&Tag1));
}

BOOL WZ_SnapShot(APTR surface,Tag Tag1, ... );
{
return(WZ_SnapShotA( surface, (struct TagItem *)&Tag1));
}

#ifdef __cplusplus
}
#endif

#ifdef STORMPRAGMAS
#ifndef _INCLUDE_PRAGMA_WIZARD_LIB_H
#include <pragma/wizard_lib.h>
#endif
#endif

#endif
