#ifndef _VBCCINLINE_CGXVIDEO_H
#define _VBCCINLINE_CGXVIDEO_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

struct VLayerHandle * __CreateVLayerHandleTagList(void *, struct Screen * screen, struct TagItem * Tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define CreateVLayerHandleTagList(screen, Tags) __CreateVLayerHandleTagList(CGXVideoBase, (screen), (Tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct VLayerHandle * __linearvarargs __CreateVLayerHandleTags(void *, struct Screen * screen, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define CreateVLayerHandleTags(screen, ...) __CreateVLayerHandleTags(CGXVideoBase, (screen), __VA_ARGS__)
#endif

ULONG __DeleteVLayerHandle(void *, struct VLayerHandle * VLayerHandle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define DeleteVLayerHandle(VLayerHandle) __DeleteVLayerHandle(CGXVideoBase, (VLayerHandle))

ULONG __AttachVLayerTagList(void *, struct VLayerHandle * VLayerHandle, struct Window * window, struct TagItem * Tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define AttachVLayerTagList(VLayerHandle, window, Tags) __AttachVLayerTagList(CGXVideoBase, (VLayerHandle), (window), (Tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __AttachVLayerTags(void *, struct VLayerHandle * VLayerHandle, struct Window * window, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define AttachVLayerTags(VLayerHandle, window, ...) __AttachVLayerTags(CGXVideoBase, (VLayerHandle), (window), __VA_ARGS__)
#endif

ULONG __DetachVLayer(void *, struct VLayerHandle * VLayerHandle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define DetachVLayer(VLayerHandle) __DetachVLayer(CGXVideoBase, (VLayerHandle))

ULONG __GetVLayerAttr(void *, struct VLayerHandle * VLayerHandle, ULONG AttrID) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define GetVLayerAttr(VLayerHandle, AttrID) __GetVLayerAttr(CGXVideoBase, (VLayerHandle), (AttrID))

ULONG __LockVLayer(void *, struct VLayerHandle * VLayerHandle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define LockVLayer(VLayerHandle) __LockVLayer(CGXVideoBase, (VLayerHandle))

ULONG __UnlockVLayer(void *, struct VLayerHandle * VLayerHandle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define UnlockVLayer(VLayerHandle) __UnlockVLayer(CGXVideoBase, (VLayerHandle))

void __SetVLayerAttrTagList(void *, struct VLayerHandle * VLayerHandle, struct TagItem * Tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define SetVLayerAttrTagList(VLayerHandle, Tags) __SetVLayerAttrTagList(CGXVideoBase, (VLayerHandle), (Tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void __linearvarargs __SetVLayerAttrTags(void *, struct VLayerHandle * VLayerHandle, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define SetVLayerAttrTags(VLayerHandle, ...) __SetVLayerAttrTags(CGXVideoBase, (VLayerHandle), __VA_ARGS__)
#endif

void __SwapVLayerBuffer(void *, struct VLayerHandle * VLayerHandle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define SwapVLayerBuffer(VLayerHandle) __SwapVLayerBuffer(CGXVideoBase, (VLayerHandle))

ULONG __WriteSPLine(void *, struct VLayerHandle * VLayerHandle, unsigned char * buffer, int x, int y, int w) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,8(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define WriteSPLine(VLayerHandle, buffer, x, y, w) __WriteSPLine(CGXVideoBase, (VLayerHandle), (buffer), (x), (y), (w))

ULONG __QueryVLayerAttr(void *, struct Screen * screen, ULONG AttrID) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define QueryVLayerAttr(screen, AttrID) __QueryVLayerAttr(CGXVideoBase, (screen), (AttrID))

#endif /*  _VBCCINLINE_CGXVIDEO_H  */
