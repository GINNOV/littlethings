#ifndef _VBCCINLINE_XADMASTER_H
#define _VBCCINLINE_XADMASTER_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

xadPTR __xadAllocObjectA(void *, xadUINT32 type, const struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define xadAllocObjectA(type, tags) __xadAllocObjectA(xadMasterBase, (type), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
xadPTR __linearvarargs __xadAllocObject(void *, xadUINT32 type, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define xadAllocObject(type, ...) __xadAllocObject(xadMasterBase, (type), __VA_ARGS__)
#endif

void __xadFreeObjectA(void *, xadPTR object, const struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define xadFreeObjectA(object, tags) __xadFreeObjectA(xadMasterBase, (object), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void __linearvarargs __xadFreeObject(void *, xadPTR object, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define xadFreeObject(object, ...) __xadFreeObject(xadMasterBase, (object), __VA_ARGS__)
#endif

struct xadClient * __xadRecogFileA(void *, xadSize size, const void * memory, const struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define xadRecogFileA(size, memory, tags) __xadRecogFileA(xadMasterBase, (size), (memory), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct xadClient * __linearvarargs __xadRecogFile(void *, xadSize size, const void * memory, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define xadRecogFile(size, memory, ...) __xadRecogFile(xadMasterBase, (size), (memory), __VA_ARGS__)
#endif

xadERROR __xadGetInfoA(void *, struct xadArchiveInfo * ai, const struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define xadGetInfoA(ai, tags) __xadGetInfoA(xadMasterBase, (ai), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
xadERROR __linearvarargs __xadGetInfo(void *, struct xadArchiveInfo * ai, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define xadGetInfo(ai, ...) __xadGetInfo(xadMasterBase, (ai), __VA_ARGS__)
#endif

void __xadFreeInfo(void *, struct xadArchiveInfo * ai) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define xadFreeInfo(ai) __xadFreeInfo(xadMasterBase, (ai))

xadERROR __xadFileUnArcA(void *, struct xadArchiveInfo * ai, const struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define xadFileUnArcA(ai, tags) __xadFileUnArcA(xadMasterBase, (ai), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
xadERROR __linearvarargs __xadFileUnArc(void *, struct xadArchiveInfo * ai, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define xadFileUnArc(ai, ...) __xadFileUnArc(xadMasterBase, (ai), __VA_ARGS__)
#endif

xadERROR __xadDiskUnArcA(void *, struct xadArchiveInfo * ai, const struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define xadDiskUnArcA(ai, tags) __xadDiskUnArcA(xadMasterBase, (ai), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
xadERROR __linearvarargs __xadDiskUnArc(void *, struct xadArchiveInfo * ai, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define xadDiskUnArc(ai, ...) __xadDiskUnArc(xadMasterBase, (ai), __VA_ARGS__)
#endif

xadSTRPTR __xadGetErrorText(void *, xadERROR errnum) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define xadGetErrorText(errnum) __xadGetErrorText(xadMasterBase, (errnum))

struct xadClient * __xadGetClientInfo(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define xadGetClientInfo() __xadGetClientInfo(xadMasterBase)

xadERROR __xadHookAccess(void *, xadUINT32 command, xadSignSize data, xadPTR buffer, struct xadArchiveInfo * ai) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,32(2)\n"
	"\tstw\t7,36(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define xadHookAccess(command, data, buffer, ai) __xadHookAccess(xadMasterBase, (command), (data), (buffer), (ai))

xadERROR __xadConvertDatesA(void *, const struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define xadConvertDatesA(tags) __xadConvertDatesA(xadMasterBase, (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
xadERROR __linearvarargs __xadConvertDates(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define xadConvertDates(...) __xadConvertDates(xadMasterBase, __VA_ARGS__)
#endif

xadUINT16 __xadCalcCRC16(void *, xadUINT32 id, xadUINT32 init, xadSize size, const xadUINT8 * buffer) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tstw\t7,32(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define xadCalcCRC16(id, init, size, buffer) __xadCalcCRC16(xadMasterBase, (id), (init), (size), (buffer))

xadUINT32 __xadCalcCRC32(void *, xadUINT32 id, xadUINT32 init, xadSize size, const xadUINT8 * buffer) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tstw\t7,32(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define xadCalcCRC32(id, init, size, buffer) __xadCalcCRC32(xadMasterBase, (id), (init), (size), (buffer))

xadPTR __xadAllocVec(void *, xadSize size, xadUINT32 flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define xadAllocVec(size, flags) __xadAllocVec(xadMasterBase, (size), (flags))

void __xadCopyMem(void *, const void * src, xadPTR dest, xadSize size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define xadCopyMem(src, dest, size) __xadCopyMem(xadMasterBase, (src), (dest), (size))

xadERROR __xadHookTagAccessA(void *, xadUINT32 command, xadSignSize data, xadPTR buffer, struct xadArchiveInfo * ai, const struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,32(2)\n"
	"\tstw\t7,36(2)\n"
	"\tstw\t8,40(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define xadHookTagAccessA(command, data, buffer, ai, tags) __xadHookTagAccessA(xadMasterBase, (command), (data), (buffer), (ai), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
xadERROR __linearvarargs __xadHookTagAccess(void *, xadUINT32 command, xadSignSize data, xadPTR buffer, struct xadArchiveInfo * ai, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,32(2)\n"
	"\tstw\t7,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define xadHookTagAccess(command, data, buffer, ai, ...) __xadHookTagAccess(xadMasterBase, (command), (data), (buffer), (ai), __VA_ARGS__)
#endif

xadERROR __xadConvertProtectionA(void *, const struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define xadConvertProtectionA(tags) __xadConvertProtectionA(xadMasterBase, (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
xadERROR __linearvarargs __xadConvertProtection(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define xadConvertProtection(...) __xadConvertProtection(xadMasterBase, __VA_ARGS__)
#endif

xadERROR __xadGetDiskInfoA(void *, struct xadArchiveInfo * ai, const struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define xadGetDiskInfoA(ai, tags) __xadGetDiskInfoA(xadMasterBase, (ai), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
xadERROR __linearvarargs __xadGetDiskInfo(void *, struct xadArchiveInfo * ai, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define xadGetDiskInfo(ai, ...) __xadGetDiskInfo(xadMasterBase, (ai), __VA_ARGS__)
#endif

xadERROR __xadGetHookAccessA(void *, struct xadArchiveInfo * ai, const struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define xadGetHookAccessA(ai, tags) __xadGetHookAccessA(xadMasterBase, (ai), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
xadERROR __linearvarargs __xadGetHookAccess(void *, struct xadArchiveInfo * ai, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define xadGetHookAccess(ai, ...) __xadGetHookAccess(xadMasterBase, (ai), __VA_ARGS__)
#endif

void __xadFreeHookAccessA(void *, struct xadArchiveInfo * ai, const struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define xadFreeHookAccessA(ai, tags) __xadFreeHookAccessA(xadMasterBase, (ai), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void __linearvarargs __xadFreeHookAccess(void *, struct xadArchiveInfo * ai, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define xadFreeHookAccess(ai, ...) __xadFreeHookAccess(xadMasterBase, (ai), __VA_ARGS__)
#endif

xadERROR __xadAddFileEntryA(void *, struct xadFileInfo * fi, struct xadArchiveInfo * ai, const struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define xadAddFileEntryA(fi, ai, tags) __xadAddFileEntryA(xadMasterBase, (fi), (ai), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
xadERROR __linearvarargs __xadAddFileEntry(void *, struct xadFileInfo * fi, struct xadArchiveInfo * ai, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define xadAddFileEntry(fi, ai, ...) __xadAddFileEntry(xadMasterBase, (fi), (ai), __VA_ARGS__)
#endif

xadERROR __xadAddDiskEntryA(void *, struct xadDiskInfo * di, struct xadArchiveInfo * ai, const struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define xadAddDiskEntryA(di, ai, tags) __xadAddDiskEntryA(xadMasterBase, (di), (ai), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
xadERROR __linearvarargs __xadAddDiskEntry(void *, struct xadDiskInfo * di, struct xadArchiveInfo * ai, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define xadAddDiskEntry(di, ai, ...) __xadAddDiskEntry(xadMasterBase, (di), (ai), __VA_ARGS__)
#endif

xadERROR __xadGetFilenameA(void *, xadUINT32 buffersize, xadSTRPTR buffer, const xadSTRING * path, const xadSTRING * name, const struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\tstw\t7,40(2)\n"
	"\tstw\t8,44(2)\n"
	"\tli\t3,-168\n"
	"\tbctrl";
#define xadGetFilenameA(buffersize, buffer, path, name, tags) __xadGetFilenameA(xadMasterBase, (buffersize), (buffer), (path), (name), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
xadERROR __linearvarargs __xadGetFilename(void *, xadUINT32 buffersize, xadSTRPTR buffer, const xadSTRING * path, const xadSTRING * name, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\tstw\t7,40(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,44(2)\n"
	"\tli\t3,-168\n"
	"\tbctrl";
#define xadGetFilename(buffersize, buffer, path, name, ...) __xadGetFilename(xadMasterBase, (buffersize), (buffer), (path), (name), __VA_ARGS__)
#endif

xadSTRPTR __xadConvertNameA(void *, xadUINT32 charset, const struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-174\n"
	"\tbctrl";
#define xadConvertNameA(charset, tags) __xadConvertNameA(xadMasterBase, (charset), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
xadSTRPTR __linearvarargs __xadConvertName(void *, xadUINT32 charset, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-174\n"
	"\tbctrl";
#define xadConvertName(charset, ...) __xadConvertName(xadMasterBase, (charset), __VA_ARGS__)
#endif

xadSTRPTR __xadGetDefaultNameA(void *, const struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-180\n"
	"\tbctrl";
#define xadGetDefaultNameA(tags) __xadGetDefaultNameA(xadMasterBase, (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
xadSTRPTR __linearvarargs __xadGetDefaultName(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-180\n"
	"\tbctrl";
#define xadGetDefaultName(...) __xadGetDefaultName(xadMasterBase, __VA_ARGS__)
#endif

const struct xadSystemInfo * __xadGetSystemInfo(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-186\n"
	"\tbctrl";
#define xadGetSystemInfo() __xadGetSystemInfo(xadMasterBase)

#endif /*  _VBCCINLINE_XADMASTER_H  */
