#ifndef _VBCCINLINE_CARDRES_H
#define _VBCCINLINE_CARDRES_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

struct CardHandle * __OwnCard(void *, struct CardHandle * handle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-6\n"
	"\tbctrl";
#define OwnCard(handle) __OwnCard(CardResource, (handle))

VOID __ReleaseCard(void *, struct CardHandle * handle, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-12\n"
	"\tbctrl";
#define ReleaseCard(handle, flags) __ReleaseCard(CardResource, (handle), (flags))

struct CardMemoryMap * __GetCardMap(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-18\n"
	"\tbctrl";
#define GetCardMap() __GetCardMap(CardResource)

BOOL __BeginCardAccess(void *, struct CardHandle * handle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-24\n"
	"\tbctrl";
#define BeginCardAccess(handle) __BeginCardAccess(CardResource, (handle))

BOOL __EndCardAccess(void *, struct CardHandle * handle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define EndCardAccess(handle) __EndCardAccess(CardResource, (handle))

UBYTE __ReadCardStatus(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define ReadCardStatus() __ReadCardStatus(CardResource)

BOOL __CardResetRemove(void *, struct CardHandle * handle, ULONG flag) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define CardResetRemove(handle, flag) __CardResetRemove(CardResource, (handle), (flag))

UBYTE __CardMiscControl(void *, struct CardHandle * handle, ULONG control_bits) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define CardMiscControl(handle, control_bits) __CardMiscControl(CardResource, (handle), (control_bits))

ULONG __CardAccessSpeed(void *, struct CardHandle * handle, ULONG nanoseconds) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define CardAccessSpeed(handle, nanoseconds) __CardAccessSpeed(CardResource, (handle), (nanoseconds))

LONG __CardProgramVoltage(void *, struct CardHandle * handle, ULONG voltage) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define CardProgramVoltage(handle, voltage) __CardProgramVoltage(CardResource, (handle), (voltage))

BOOL __CardResetCard(void *, struct CardHandle * handle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define CardResetCard(handle) __CardResetCard(CardResource, (handle))

BOOL __CopyTuple(void *, CONST struct CardHandle * handle, UBYTE * buffer, ULONG tuplecode, ULONG size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,0(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define CopyTuple(handle, buffer, tuplecode, size) __CopyTuple(CardResource, (handle), (buffer), (tuplecode), (size))

ULONG __DeviceTuple(void *, CONST UBYTE * tuple_data, struct DeviceTData * storage) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define DeviceTuple(tuple_data, storage) __DeviceTuple(CardResource, (tuple_data), (storage))

struct Resident * __IfAmigaXIP(void *, CONST struct CardHandle * handle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,40(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define IfAmigaXIP(handle) __IfAmigaXIP(CardResource, (handle))

BOOL __CardForceChange(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define CardForceChange() __CardForceChange(CardResource)

ULONG __CardChangeCount(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define CardChangeCount() __CardChangeCount(CardResource)

ULONG __CardInterface(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define CardInterface() __CardInterface(CardResource)

#endif /*  _VBCCINLINE_CARDRES_H  */
