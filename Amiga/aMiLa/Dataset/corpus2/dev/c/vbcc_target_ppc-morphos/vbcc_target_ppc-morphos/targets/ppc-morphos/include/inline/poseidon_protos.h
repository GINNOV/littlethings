#ifndef _VBCCINLINE_POSEIDON_H
#define _VBCCINLINE_POSEIDON_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

APTR __psdAllocVec(void *, ULONG size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define psdAllocVec(size) __psdAllocVec(PsdBase, (size))

VOID __psdFreeVec(void *, APTR memptr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define psdFreeVec(memptr) __psdFreeVec(PsdBase, (memptr))

VOID __psdLockWritePBase(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define psdLockWritePBase() __psdLockWritePBase(PsdBase)

VOID __psdLockReadPBase(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define psdLockReadPBase() __psdLockReadPBase(PsdBase)

VOID __psdUnlockPBase(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define psdUnlockPBase() __psdUnlockPBase(PsdBase)

STRPTR __psdCopyStr(void *, STRPTR name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define psdCopyStr(name) __psdCopyStr(PsdBase, (name))

VOID __psdDelayMS(void *, ULONG milli) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define psdDelayMS(milli) __psdDelayMS(PsdBase, (milli))

APTR __psdAddHardware(void *, STRPTR name, ULONG unit) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define psdAddHardware(name, unit) __psdAddHardware(PsdBase, (name), (unit))

VOID __psdRemHardware(void *, APTR phw) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define psdRemHardware(phw) __psdRemHardware(PsdBase, (phw))

APTR __psdEnumerateHardware(void *, APTR phw) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define psdEnumerateHardware(phw) __psdEnumerateHardware(PsdBase, (phw))

APTR __psdAllocDevice(void *, APTR phw) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define psdAllocDevice(phw) __psdAllocDevice(PsdBase, (phw))

VOID __psdFreeDevice(void *, APTR pd) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define psdFreeDevice(pd) __psdFreeDevice(PsdBase, (pd))

VOID __psdLockReadDevice(void *, APTR pd) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define psdLockReadDevice(pd) __psdLockReadDevice(PsdBase, (pd))

VOID __psdLockWriteDevice(void *, APTR pd) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define psdLockWriteDevice(pd) __psdLockWriteDevice(PsdBase, (pd))

VOID __psdUnlockDevice(void *, APTR pd) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define psdUnlockDevice(pd) __psdUnlockDevice(PsdBase, (pd))

APTR __psdEnumerateDevice(void *, APTR pp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define psdEnumerateDevice(pp) __psdEnumerateDevice(PsdBase, (pp))

APTR __psdGetNextDevice(void *, APTR pd) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define psdGetNextDevice(pd) __psdGetNextDevice(PsdBase, (pd))

LONG __psdGetAttrsA(void *, ULONG type, APTR psdstruct, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define psdGetAttrsA(type, psdstruct, taglist) __psdGetAttrsA(PsdBase, (type), (psdstruct), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __psdGetAttrs(void *, ULONG type, APTR psdstruct, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define psdGetAttrs(type, psdstruct, ...) __psdGetAttrs(PsdBase, (type), (psdstruct), __VA_ARGS__)
#endif

LONG __psdSetAttrsA(void *, ULONG type, APTR psdstruct, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define psdSetAttrsA(type, psdstruct, taglist) __psdSetAttrsA(PsdBase, (type), (psdstruct), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __psdSetAttrs(void *, ULONG type, APTR psdstruct, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define psdSetAttrs(type, psdstruct, ...) __psdSetAttrs(PsdBase, (type), (psdstruct), __VA_ARGS__)
#endif

APTR __psdAllocPipe(void *, APTR pd, struct MsgPort * mp, APTR pep) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define psdAllocPipe(pd, mp, pep) __psdAllocPipe(PsdBase, (pd), (mp), (pep))

APTR __psdFreePipe(void *, APTR pp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define psdFreePipe(pp) __psdFreePipe(PsdBase, (pp))

VOID __psdPipeSetup(void *, APTR pp, ULONG rt, ULONG rq, ULONG val, ULONG idx) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define psdPipeSetup(pp, rt, rq, val, idx) __psdPipeSetup(PsdBase, (pp), (rt), (rq), (val), (idx))

LONG __psdDoPipe(void *, APTR pp, APTR data, ULONG len) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define psdDoPipe(pp, data, len) __psdDoPipe(PsdBase, (pp), (data), (len))

VOID __psdSendPipe(void *, APTR pp, APTR data, ULONG len) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-168\n"
	"\tbctrl";
#define psdSendPipe(pp, data, len) __psdSendPipe(PsdBase, (pp), (data), (len))

VOID __psdAbortPipe(void *, APTR pp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-174\n"
	"\tbctrl";
#define psdAbortPipe(pp) __psdAbortPipe(PsdBase, (pp))

LONG __psdWaitPipe(void *, APTR pp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-180\n"
	"\tbctrl";
#define psdWaitPipe(pp) __psdWaitPipe(PsdBase, (pp))

ULONG __psdGetPipeActual(void *, APTR pp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-186\n"
	"\tbctrl";
#define psdGetPipeActual(pp) __psdGetPipeActual(PsdBase, (pp))

LONG __psdGetPipeError(void *, APTR pp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-192\n"
	"\tbctrl";
#define psdGetPipeError(pp) __psdGetPipeError(PsdBase, (pp))

STRPTR __psdGetStringDescriptor(void *, APTR pp, ULONG idx) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-198\n"
	"\tbctrl";
#define psdGetStringDescriptor(pp, idx) __psdGetStringDescriptor(PsdBase, (pp), (idx))

BOOL __psdSetDeviceConfig(void *, APTR pp, ULONG cfgnum) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-204\n"
	"\tbctrl";
#define psdSetDeviceConfig(pp, cfgnum) __psdSetDeviceConfig(PsdBase, (pp), (cfgnum))

APTR __psdAddClass(void *, STRPTR name, ULONG version) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-210\n"
	"\tbctrl";
#define psdAddClass(name, version) __psdAddClass(PsdBase, (name), (version))

VOID __psdRemClass(void *, APTR puc) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-216\n"
	"\tbctrl";
#define psdRemClass(puc) __psdRemClass(PsdBase, (puc))

VOID __psdClassScan(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-222\n"
	"\tbctrl";
#define psdClassScan() __psdClassScan(PsdBase)

STRPTR __psdNumToStr(void *, ULONG type, LONG idx, STRPTR defstr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,32(2)\n"
	"\tli\t3,-228\n"
	"\tbctrl";
#define psdNumToStr(type, idx, defstr) __psdNumToStr(PsdBase, (type), (idx), (defstr))

struct Task * __psdSpawnSubTask(void *, STRPTR name, APTR initpc, APTR userdata) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-234\n"
	"\tbctrl";
#define psdSpawnSubTask(name, initpc, userdata) __psdSpawnSubTask(PsdBase, (name), (initpc), (userdata))

APTR __psdAddErrorMsgA(void *, ULONG level, STRPTR origin, STRPTR fmtstr, APTR fmtdata) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\tstw\t7,40(2)\n"
	"\tli\t3,-240\n"
	"\tbctrl";
#define psdAddErrorMsgA(level, origin, fmtstr, fmtdata) __psdAddErrorMsgA(PsdBase, (level), (origin), (fmtstr), (fmtdata))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __psdAddErrorMsg(void *, ULONG level, STRPTR origin, STRPTR fmtstr, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-240\n"
	"\tbctrl";
#define psdAddErrorMsg(level, origin, ...) __psdAddErrorMsg(PsdBase, (level), (origin), __VA_ARGS__)
#endif

VOID __psdRemErrorMsg(void *, APTR pem) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-246\n"
	"\tbctrl";
#define psdRemErrorMsg(pem) __psdRemErrorMsg(PsdBase, (pem))

VOID __psdSafeRawDoFmtA(void *, STRPTR buf, ULONG len, STRPTR fmtstr, APTR fmtdata) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tstw\t7,40(2)\n"
	"\tli\t3,-252\n"
	"\tbctrl";
#define psdSafeRawDoFmtA(buf, len, fmtstr, fmtdata) __psdSafeRawDoFmtA(PsdBase, (buf), (len), (fmtstr), (fmtdata))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
VOID __linearvarargs __psdSafeRawDoFmt(void *, STRPTR buf, ULONG len, STRPTR fmtstr, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-252\n"
	"\tbctrl";
#define psdSafeRawDoFmt(buf, len, ...) __psdSafeRawDoFmt(PsdBase, (buf), (len), __VA_ARGS__)
#endif

BOOL __psdSetAltInterface(void *, APTR pp, APTR pif) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-258\n"
	"\tbctrl";
#define psdSetAltInterface(pp, pif) __psdSetAltInterface(PsdBase, (pp), (pif))

APTR __psdFindDeviceA(void *, APTR pd, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-264\n"
	"\tbctrl";
#define psdFindDeviceA(pd, taglist) __psdFindDeviceA(PsdBase, (pd), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __psdFindDevice(void *, APTR pd, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-264\n"
	"\tbctrl";
#define psdFindDevice(...) __psdFindDevice(PsdBase, __VA_ARGS__)
#endif

APTR __psdClaimAppBindingA(void *, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-270\n"
	"\tbctrl";
#define psdClaimAppBindingA(taglist) __psdClaimAppBindingA(PsdBase, (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __psdClaimAppBinding(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-270\n"
	"\tbctrl";
#define psdClaimAppBinding(...) __psdClaimAppBinding(PsdBase, __VA_ARGS__)
#endif

APTR __psdReleaseAppBinding(void *, APTR pab) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-276\n"
	"\tbctrl";
#define psdReleaseAppBinding(pab) __psdReleaseAppBinding(PsdBase, (pab))

APTR __psdAddEventHandler(void *, struct MsgPort * mp, ULONG msgmask) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-282\n"
	"\tbctrl";
#define psdAddEventHandler(mp, msgmask) __psdAddEventHandler(PsdBase, (mp), (msgmask))

VOID __psdRemEventHandler(void *, APTR peh) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-288\n"
	"\tbctrl";
#define psdRemEventHandler(peh) __psdRemEventHandler(PsdBase, (peh))

VOID __psdSendEvent(void *, ULONG ehmt, APTR param1, APTR param2) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-294\n"
	"\tbctrl";
#define psdSendEvent(ehmt, param1, param2) __psdSendEvent(PsdBase, (ehmt), (param1), (param2))

VOID __psdReleaseDevBinding(void *, APTR pd) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-300\n"
	"\tbctrl";
#define psdReleaseDevBinding(pd) __psdReleaseDevBinding(PsdBase, (pd))

VOID __psdReleaseIfBinding(void *, APTR pif) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-306\n"
	"\tbctrl";
#define psdReleaseIfBinding(pif) __psdReleaseIfBinding(PsdBase, (pif))

BOOL __psdReadCfg(void *, APTR pic, APTR formdata) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-312\n"
	"\tbctrl";
#define psdReadCfg(pic, formdata) __psdReadCfg(PsdBase, (pic), (formdata))

APTR __psdWriteCfg(void *, APTR pic) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-318\n"
	"\tbctrl";
#define psdWriteCfg(pic) __psdWriteCfg(PsdBase, (pic))

APTR __psdFindCfgForm(void *, APTR pic, ULONG formid) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-324\n"
	"\tbctrl";
#define psdFindCfgForm(pic, formid) __psdFindCfgForm(PsdBase, (pic), (formid))

APTR __psdNextCfgForm(void *, APTR pic) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-330\n"
	"\tbctrl";
#define psdNextCfgForm(pic) __psdNextCfgForm(PsdBase, (pic))

BOOL __psdRemCfgForm(void *, APTR pic) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-336\n"
	"\tbctrl";
#define psdRemCfgForm(pic) __psdRemCfgForm(PsdBase, (pic))

APTR __psdAddCfgEntry(void *, APTR pic, APTR formdata) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-342\n"
	"\tbctrl";
#define psdAddCfgEntry(pic, formdata) __psdAddCfgEntry(PsdBase, (pic), (formdata))

BOOL __psdRemCfgChunk(void *, APTR pic, ULONG chnkid) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-348\n"
	"\tbctrl";
#define psdRemCfgChunk(pic, chnkid) __psdRemCfgChunk(PsdBase, (pic), (chnkid))

APTR __psdGetCfgChunk(void *, APTR pic, ULONG chnkid) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-354\n"
	"\tbctrl";
#define psdGetCfgChunk(pic, chnkid) __psdGetCfgChunk(PsdBase, (pic), (chnkid))

VOID __psdParseCfg(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-360\n"
	"\tbctrl";
#define psdParseCfg() __psdParseCfg(PsdBase)

VOID __psdUnbindAll(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-366\n"
	"\tbctrl";
#define psdUnbindAll() __psdUnbindAll(PsdBase)

BOOL __psdSetClsCfg(void *, STRPTR owner, APTR form) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-372\n"
	"\tbctrl";
#define psdSetClsCfg(owner, form) __psdSetClsCfg(PsdBase, (owner), (form))

APTR __psdGetClsCfg(void *, STRPTR owner) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-378\n"
	"\tbctrl";
#define psdGetClsCfg(owner) __psdGetClsCfg(PsdBase, (owner))

BOOL __psdSetUsbDevCfg(void *, STRPTR owner, STRPTR devid, STRPTR ifid, APTR form) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,40(2)\n"
	"\tstw\t6,44(2)\n"
	"\tstw\t7,36(2)\n"
	"\tli\t3,-384\n"
	"\tbctrl";
#define psdSetUsbDevCfg(owner, devid, ifid, form) __psdSetUsbDevCfg(PsdBase, (owner), (devid), (ifid), (form))

APTR __psdGetUsbDevCfg(void *, STRPTR owner, STRPTR devid, STRPTR ifid) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,40(2)\n"
	"\tstw\t6,44(2)\n"
	"\tli\t3,-390\n"
	"\tbctrl";
#define psdGetUsbDevCfg(owner, devid, ifid) __psdGetUsbDevCfg(PsdBase, (owner), (devid), (ifid))

APTR __psdFindInterfaceA(void *, APTR pd, APTR pif, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,40(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-396\n"
	"\tbctrl";
#define psdFindInterfaceA(pd, pif, taglist) __psdFindInterfaceA(PsdBase, (pd), (pif), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __psdFindInterface(void *, APTR pd, APTR pif, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,40(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-396\n"
	"\tbctrl";
#define psdFindInterface(pd, ...) __psdFindInterface(PsdBase, (pd), __VA_ARGS__)
#endif

APTR __psdFindEndpointA(void *, APTR pif, APTR pep, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,40(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-402\n"
	"\tbctrl";
#define psdFindEndpointA(pif, pep, taglist) __psdFindEndpointA(PsdBase, (pif), (pep), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __psdFindEndpoint(void *, APTR pif, APTR pep, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,40(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-402\n"
	"\tbctrl";
#define psdFindEndpoint(pif, ...) __psdFindEndpoint(PsdBase, (pif), __VA_ARGS__)
#endif

STRPTR __psdCopyStrFmtA(void *, STRPTR fmtstr, APTR fmtdata) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-408\n"
	"\tbctrl";
#define psdCopyStrFmtA(fmtstr, fmtdata) __psdCopyStrFmtA(PsdBase, (fmtstr), (fmtdata))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
STRPTR __linearvarargs __psdCopyStrFmt(void *, STRPTR fmtstr, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-408\n"
	"\tbctrl";
#define psdCopyStrFmt(...) __psdCopyStrFmt(PsdBase, __VA_ARGS__)
#endif

BOOL __psdSetForcedBinding(void *, STRPTR owner, STRPTR devid, STRPTR ifid) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,40(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-414\n"
	"\tbctrl";
#define psdSetForcedBinding(owner, devid, ifid) __psdSetForcedBinding(PsdBase, (owner), (devid), (ifid))

STRPTR __psdGetForcedBinding(void *, STRPTR devid, STRPTR ifid) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-420\n"
	"\tbctrl";
#define psdGetForcedBinding(devid, ifid) __psdGetForcedBinding(PsdBase, (devid), (ifid))

APTR __psdCheckPipe(void *, APTR pp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-426\n"
	"\tbctrl";
#define psdCheckPipe(pp) __psdCheckPipe(PsdBase, (pp))

APTR __psdOpenStreamA(void *, APTR pep, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-432\n"
	"\tbctrl";
#define psdOpenStreamA(pep, taglist) __psdOpenStreamA(PsdBase, (pep), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __psdOpenStream(void *, APTR pep, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-432\n"
	"\tbctrl";
#define psdOpenStream(...) __psdOpenStream(PsdBase, __VA_ARGS__)
#endif

VOID __psdCloseStream(void *, APTR pps) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-438\n"
	"\tbctrl";
#define psdCloseStream(pps) __psdCloseStream(PsdBase, (pps))

LONG __psdStreamRead(void *, APTR pps, APTR buffer, LONG length) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-444\n"
	"\tbctrl";
#define psdStreamRead(pps, buffer, length) __psdStreamRead(PsdBase, (pps), (buffer), (length))

LONG __psdStreamWrite(void *, APTR pps, APTR buffer, LONG length) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-450\n"
	"\tbctrl";
#define psdStreamWrite(pps, buffer, length) __psdStreamWrite(PsdBase, (pps), (buffer), (length))

LONG __psdStreamFlush(void *, APTR pps) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-456\n"
	"\tbctrl";
#define psdStreamFlush(pps) __psdStreamFlush(PsdBase, (pps))

LONG __psdGetStreamError(void *, APTR pps) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-462\n"
	"\tbctrl";
#define psdGetStreamError(pps) __psdGetStreamError(PsdBase, (pps))

VOID __psdCalculatePower(void *, APTR phw) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-468\n"
	"\tbctrl";
#define psdCalculatePower(phw) __psdCalculatePower(PsdBase, (phw))

BOOL __psdLoadCfgFromDisk(void *, STRPTR filename) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-474\n"
	"\tbctrl";
#define psdLoadCfgFromDisk(filename) __psdLoadCfgFromDisk(PsdBase, (filename))

BOOL __psdSaveCfgToDisk(void *, STRPTR filename, LONG mode) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-480\n"
	"\tbctrl";
#define psdSaveCfgToDisk(filename, mode) __psdSaveCfgToDisk(PsdBase, (filename), (mode))

VOID __psdDebugSemaphores(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-486\n"
	"\tbctrl";
#define psdDebugSemaphores() __psdDebugSemaphores(PsdBase)

VOID __psdHubClassScan(void *, APTR pd) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-492\n"
	"\tbctrl";
#define psdHubClassScan(pd) __psdHubClassScan(PsdBase, (pd))

APTR __psdHubClaimAppBindingA(void *, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-498\n"
	"\tbctrl";
#define psdHubClaimAppBindingA(taglist) __psdHubClaimAppBindingA(PsdBase, (taglist))

VOID __psdHubReleaseDevBinding(void *, APTR pd) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-504\n"
	"\tbctrl";
#define psdHubReleaseDevBinding(pd) __psdHubReleaseDevBinding(PsdBase, (pd))

VOID __psdHubReleaseIfBinding(void *, APTR pif) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-510\n"
	"\tbctrl";
#define psdHubReleaseIfBinding(pif) __psdHubReleaseIfBinding(PsdBase, (pif))

APTR __psdAllocCfgForm(void *, ULONG formid) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-516\n"
	"\tbctrl";
#define psdAllocCfgForm(formid) __psdAllocCfgForm(PsdBase, (formid))

BOOL __psdAddStringChunk(void *, APTR pic, ULONG chunkid, STRPTR contents) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-522\n"
	"\tbctrl";
#define psdAddStringChunk(pic, chunkid, contents) __psdAddStringChunk(PsdBase, (pic), (chunkid), (contents))

BOOL __psdMatchStringChunk(void *, APTR pic, ULONG chunkid, STRPTR contents) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-528\n"
	"\tbctrl";
#define psdMatchStringChunk(pic, chunkid, contents) __psdMatchStringChunk(PsdBase, (pic), (chunkid), (contents))

STRPTR __psdGetStringChunk(void *, APTR pic, ULONG chunkid) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-534\n"
	"\tbctrl";
#define psdGetStringChunk(pic, chunkid) __psdGetStringChunk(PsdBase, (pic), (chunkid))

STRPTR __psdOnlineReport(void *, APTR formdata) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-540\n"
	"\tbctrl";
#define psdOnlineReport(formdata) __psdOnlineReport(PsdBase, (formdata))

APTR __psdFindDescriptorA(void *, APTR pd, APTR pdd, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,40(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-546\n"
	"\tbctrl";
#define psdFindDescriptorA(pd, pdd, taglist) __psdFindDescriptorA(PsdBase, (pd), (pdd), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __psdFindDescriptor(void *, APTR pd, APTR pdd, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,40(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-546\n"
	"\tbctrl";
#define psdFindDescriptor(pd, ...) __psdFindDescriptor(PsdBase, (pd), __VA_ARGS__)
#endif

APTR __psdDoHubMethodA(void *, APTR pd, ULONG methodid, APTR methoddata) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-552\n"
	"\tbctrl";
#define psdDoHubMethodA(pd, methodid, methoddata) __psdDoHubMethodA(PsdBase, (pd), (methodid), (methoddata))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __psdDoHubMethod(void *, APTR pd, ULONG methodid, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-552\n"
	"\tbctrl";
#define psdDoHubMethod(pd, ...) __psdDoHubMethod(PsdBase, (pd), __VA_ARGS__)
#endif

APTR __psdAllocRTIsoHandlerA(void *, APTR pep, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-558\n"
	"\tbctrl";
#define psdAllocRTIsoHandlerA(pep, taglist) __psdAllocRTIsoHandlerA(PsdBase, (pep), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __psdAllocRTIsoHandler(void *, APTR pep, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-558\n"
	"\tbctrl";
#define psdAllocRTIsoHandler(...) __psdAllocRTIsoHandler(PsdBase, __VA_ARGS__)
#endif

VOID __psdFreeRTIsoHandler(void *, APTR prt) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-564\n"
	"\tbctrl";
#define psdFreeRTIsoHandler(prt) __psdFreeRTIsoHandler(PsdBase, (prt))

LONG __psdStartRTIso(void *, APTR prt) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-570\n"
	"\tbctrl";
#define psdStartRTIso(prt) __psdStartRTIso(PsdBase, (prt))

LONG __psdStopRTIso(void *, APTR prt) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-576\n"
	"\tbctrl";
#define psdStopRTIso(prt) __psdStopRTIso(PsdBase, (prt))

ULONG __psdBorrowLocksWait(void *, struct Task * task, ULONG signals) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-582\n"
	"\tbctrl";
#define psdBorrowLocksWait(task, signals) __psdBorrowLocksWait(PsdBase, (task), (signals))

#endif /*  _VBCCINLINE_POSEIDON_H  */
