#ifndef _VBCCINLINE_XFDMASTER_H
#define _VBCCINLINE_XFDMASTER_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

struct xfdBufferInfo * __xfdAllocBufferInfo(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define xfdAllocBufferInfo() __xfdAllocBufferInfo(xfdMasterBase)

void __xfdFreeBufferInfo(void *, struct xfdBufferInfo * bufferinfo) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define xfdFreeBufferInfo(bufferinfo) __xfdFreeBufferInfo(xfdMasterBase, (bufferinfo))

struct xfdSegmentInfo * __xfdAllocSegmentInfo(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define xfdAllocSegmentInfo() __xfdAllocSegmentInfo(xfdMasterBase)

void __xfdFreeSegmentInfo(void *, struct xfdSegmentInfo * segmentinfo) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define xfdFreeSegmentInfo(segmentinfo) __xfdFreeSegmentInfo(xfdMasterBase, (segmentinfo))

BOOL __xfdRecogBuffer(void *, struct xfdBufferInfo * bufferinfo) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define xfdRecogBuffer(bufferinfo) __xfdRecogBuffer(xfdMasterBase, (bufferinfo))

BOOL __xfdDecrunchBuffer(void *, struct xfdBufferInfo * bufferinfo) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define xfdDecrunchBuffer(bufferinfo) __xfdDecrunchBuffer(xfdMasterBase, (bufferinfo))

BOOL __xfdRecogSegment(void *, struct xfdSegmentInfo * segmentinfo) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define xfdRecogSegment(segmentinfo) __xfdRecogSegment(xfdMasterBase, (segmentinfo))

BOOL __xfdDecrunchSegment(void *, struct xfdSegmentInfo * segmentinfo) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define xfdDecrunchSegment(segmentinfo) __xfdDecrunchSegment(xfdMasterBase, (segmentinfo))

STRPTR __xfdGetErrorText(void *, ULONG error) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define xfdGetErrorText(error) __xfdGetErrorText(xfdMasterBase, (error))

BOOL __xfdTestHunkStructure(void *, APTR buffer, ULONG length) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define xfdTestHunkStructure(buffer, length) __xfdTestHunkStructure(xfdMasterBase, (buffer), (length))

UWORD __xfdTestHunkStructureNew(void *, APTR buffer, ULONG length) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define xfdTestHunkStructureNew(buffer, length) __xfdTestHunkStructureNew(xfdMasterBase, (buffer), (length))

UWORD __xfdRelocate(void *, APTR buffer, ULONG length, ULONG * result, ULONG mode) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tstw\t7,4(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define xfdRelocate(buffer, length, result, mode) __xfdRelocate(xfdMasterBase, (buffer), (length), (result), (mode))

UWORD __xfdTestHunkStructureFlags(void *, APTR buffer, ULONG length, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define xfdTestHunkStructureFlags(buffer, length, flags) __xfdTestHunkStructureFlags(xfdMasterBase, (buffer), (length), (flags))

UWORD __xfdStripHunks(void *, APTR buffer, ULONG length, ULONG * result, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tstw\t7,4(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define xfdStripHunks(buffer, length, result, flags) __xfdStripHunks(xfdMasterBase, (buffer), (length), (result), (flags))

APTR __xfdAllocObject(void *, ULONG objecttype) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define xfdAllocObject(objecttype) __xfdAllocObject(xfdMasterBase, (objecttype))

void __xfdFreeObject(void *, APTR object) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define xfdFreeObject(object) __xfdFreeObject(xfdMasterBase, (object))

BOOL __xfdRecogLinker(void *, struct xfdLinkerInfo * linkerinfo) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define xfdRecogLinker(linkerinfo) __xfdRecogLinker(xfdMasterBase, (linkerinfo))

BOOL __xfdUnlink(void *, struct xfdLinkerInfo * linkerinfo) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define xfdUnlink(linkerinfo) __xfdUnlink(xfdMasterBase, (linkerinfo))

UWORD __xfdScanData(void *, APTR buffer, ULONG length, ULONG * result, ULONG flags, struct xfdScanHook * scanhook) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,40(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define xfdScanData(buffer, length, result, flags, scanhook) __xfdScanData(xfdMasterBase, (buffer), (length), (result), (flags), (scanhook))

void __xfdFreeScanList(void *, struct xfdScanNode * scannode) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define xfdFreeScanList(scannode) __xfdFreeScanList(xfdMasterBase, (scannode))

ULONG __xfdObjectType(void *, APTR object) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define xfdObjectType(object) __xfdObjectType(xfdMasterBase, (object))

struct xfdScanHook * __xfdInitScanHook(void *, BOOL (*entry)(void), APTR data) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define xfdInitScanHook(entry, data) __xfdInitScanHook(xfdMasterBase, (entry), (data))

#endif /*  _VBCCINLINE_XFDMASTER_H  */
