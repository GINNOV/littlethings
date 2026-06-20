#ifndef _VBCCINLINE_LOWLEVEL_H
#define _VBCCINLINE_LOWLEVEL_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

ULONG __ReadJoyPort(void *, ULONG port) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define ReadJoyPort(port) __ReadJoyPort(LowLevelBase, (port))

UBYTE __GetLanguageSelection(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define GetLanguageSelection() __GetLanguageSelection(LowLevelBase)

ULONG __GetKey(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define GetKey() __GetKey(LowLevelBase)

VOID __QueryKeys(void *, struct KeyQuery * queryArray, ULONG arraySize) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define QueryKeys(queryArray, arraySize) __QueryKeys(LowLevelBase, (queryArray), (arraySize))

APTR __AddKBInt(void *, CONST APTR intRoutine, CONST APTR intData) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define AddKBInt(intRoutine, intData) __AddKBInt(LowLevelBase, (intRoutine), (intData))

VOID __RemKBInt(void *, APTR intHandle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define RemKBInt(intHandle) __RemKBInt(LowLevelBase, (intHandle))

ULONG __SystemControlA(void *, CONST struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define SystemControlA(tagList) __SystemControlA(LowLevelBase, (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __SystemControl(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define SystemControl(...) __SystemControl(LowLevelBase, __VA_ARGS__)
#endif

APTR __AddTimerInt(void *, CONST APTR intRoutine, CONST APTR intData) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define AddTimerInt(intRoutine, intData) __AddTimerInt(LowLevelBase, (intRoutine), (intData))

VOID __RemTimerInt(void *, APTR intHandle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define RemTimerInt(intHandle) __RemTimerInt(LowLevelBase, (intHandle))

VOID __StopTimerInt(void *, APTR intHandle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define StopTimerInt(intHandle) __StopTimerInt(LowLevelBase, (intHandle))

VOID __StartTimerInt(void *, APTR intHandle, ULONG timeInterval, LONG continuous) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define StartTimerInt(intHandle, timeInterval, continuous) __StartTimerInt(LowLevelBase, (intHandle), (timeInterval), (continuous))

ULONG __ElapsedTime(void *, struct EClockVal * context) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define ElapsedTime(context) __ElapsedTime(LowLevelBase, (context))

APTR __AddVBlankInt(void *, CONST APTR intRoutine, CONST APTR intData) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define AddVBlankInt(intRoutine, intData) __AddVBlankInt(LowLevelBase, (intRoutine), (intData))

VOID __RemVBlankInt(void *, APTR intHandle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define RemVBlankInt(intHandle) __RemVBlankInt(LowLevelBase, (intHandle))

BOOL __SetJoyPortAttrsA(void *, ULONG portNumber, CONST struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define SetJoyPortAttrsA(portNumber, tagList) __SetJoyPortAttrsA(LowLevelBase, (portNumber), (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __SetJoyPortAttrs(void *, ULONG portNumber, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define SetJoyPortAttrs(portNumber, ...) __SetJoyPortAttrs(LowLevelBase, (portNumber), __VA_ARGS__)
#endif

#endif /*  _VBCCINLINE_LOWLEVEL_H  */
