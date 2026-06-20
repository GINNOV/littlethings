/* Automatically generated header! Do not edit! */

#ifndef _PPCINLINE_CGXVIDEO_H
#define _PPCINLINE_CGXVIDEO_H

#ifndef __PPCINLINE_MACROS_H
#include <powerup/ppcinline/macros.h>
#endif /* !__PPCINLINE_MACROS_H */

#ifndef CGXVIDEO_BASE_NAME
#define CGXVIDEO_BASE_NAME CGXVideoBase
#endif /* !CGXVIDEO_BASE_NAME */

#define AttachVLayerTagList(VLayerHandle_, Window_, Tags) \
	LP3(0x2a, ULONG, AttachVLayerTagList, struct VLayerHandle *, VLayerHandle_, a0, struct Window *, Window_, a1, struct TagItem *, Tags, a2, \
	, CGXVIDEO_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#ifndef NO_PPCINLINE_STDARG
#define AttachVLayerTags(a0, a1, tags...) \
	({ULONG _tags[] = { tags }; AttachVLayerTagList((a0), (a1), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define CreateVLayerHandleTagList(Screen_, Tags) \
	LP2(0x1e, struct VLayerHandle *, CreateVLayerHandleTagList, struct Screen *, Screen_, a0, struct TagItem *, Tags, a1, \
	, CGXVIDEO_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#ifndef NO_PPCINLINE_STDARG
#define CreateVLayerHandleTags(a0, tags...) \
	({ULONG _tags[] = { tags }; CreateVLayerHandleTagList((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define DeleteVLayerHandle(VLayerHandle_) \
	LP1(0x24, ULONG, DeleteVLayerHandle, struct VLayerHandle *, VLayerHandle_, a0, \
	, CGXVIDEO_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define DetachVLayer(VLayerHandle_) \
	LP1(0x30, ULONG, DetachVLayer, struct VLayerHandle *, VLayerHandle_, a0, \
	, CGXVIDEO_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define GetVLayerAttr(VLayerHandle_, AttrNum) \
	LP2(0x36, ULONG, GetVLayerAttr, struct VLayerHandle *, VLayerHandle_, a0, ULONG, AttrNum, d0, \
	, CGXVIDEO_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define LockVLayer(VLayerHandle_) \
	LP1(0x3c, ULONG, LockVLayer, struct VLayerHandle *, VLayerHandle_, a0, \
	, CGXVIDEO_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define SetVLayerAttrTagList(VLayerHandle_, Tags) \
	LP2NR(0x48, SetVLayerAttrTagList, struct VLayerHandle *, VLayerHandle_, a0, struct TagItem *, Tags, a1, \
	, CGXVIDEO_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#ifndef NO_PPCINLINE_STDARG
#define SetVLayerAttrTags(a0, tags...) \
	({ULONG _tags[] = { tags }; SetVLayerAttrTagList((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define UnLockVLayer(VLayerHandle_) \
	LP1(0x42, ULONG, UnLockVLayer, struct VLayerHandle *, VLayerHandle_, a0, \
	, CGXVIDEO_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#endif /* !_PPCINLINE_CGXVIDEO_H */
