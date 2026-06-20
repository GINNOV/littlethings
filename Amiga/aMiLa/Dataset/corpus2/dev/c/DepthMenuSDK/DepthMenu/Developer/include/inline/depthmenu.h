/* Automatically generated header! Do not edit! */

#ifndef _INLINE_DEPTHMENU_H
#define _INLINE_DEPTHMENU_H

#ifndef __INLINE_MACROS_H
#include <inline/macros.h>
#endif /* !__INLINE_MACROS_H */

#ifndef DEPTHMENU_BASE_NAME
#define DEPTHMENU_BASE_NAME DepthMenuBase
#endif /* !DEPTHMENU_BASE_NAME */

#define DM_AddModule(dmmodule) \
	LP1(0x1e, ULONG, DM_AddModule, struct DM_Module *, dmmodule, a0, \
	, DEPTHMENU_BASE_NAME)

#define DM_CreateItemsNewMenuA(newmenu, tags) \
	LP2(0x30, APTR, DM_CreateItemsNewMenuA, struct NewMenu *, newmenu, a0, struct TagItem *, tags, a1, \
	, DEPTHMENU_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define DM_CreateItemsNewMenu(a0, tags...) \
	({ULONG _tags[] = { tags }; DM_CreateItemsNewMenuA((a0), (struct TagItem *)_tags);})
#endif /* !NO_INLINE_STDARG */

#define DM_FreeItems(items) \
	LP1NR(0x2a, DM_FreeItems, APTR, items, a0, \
	, DEPTHMENU_BASE_NAME)

#define DM_RemModule(dmmodule) \
	LP1(0x24, ULONG, DM_RemModule, struct DM_Module *, dmmodule, a0, \
	, DEPTHMENU_BASE_NAME)

#endif /* !_INLINE_DEPTHMENU_H */
