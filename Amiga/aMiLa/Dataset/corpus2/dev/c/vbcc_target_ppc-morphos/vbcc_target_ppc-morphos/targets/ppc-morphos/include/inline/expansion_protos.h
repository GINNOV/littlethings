#ifndef _VBCCINLINE_EXPANSION_H
#define _VBCCINLINE_EXPANSION_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

VOID __AddConfigDev(void *, struct ConfigDev * configDev) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define AddConfigDev(configDev) __AddConfigDev(ExpansionBase, (configDev))

BOOL __AddBootNode(void *, LONG bootPri, ULONG flags, struct DeviceNode * deviceNode, struct ConfigDev * configDev) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,32(2)\n"
	"\tstw\t7,36(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define AddBootNode(bootPri, flags, deviceNode, configDev) __AddBootNode(ExpansionBase, (bootPri), (flags), (deviceNode), (configDev))

VOID __AllocBoardMem(void *, ULONG slotSpec) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define AllocBoardMem(slotSpec) __AllocBoardMem(ExpansionBase, (slotSpec))

struct ConfigDev * __AllocConfigDev(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define AllocConfigDev() __AllocConfigDev(ExpansionBase)

APTR __AllocExpansionMem(void *, ULONG numSlots, ULONG slotAlign) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define AllocExpansionMem(numSlots, slotAlign) __AllocExpansionMem(ExpansionBase, (numSlots), (slotAlign))

VOID __ConfigBoard(void *, APTR board, struct ConfigDev * configDev) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define ConfigBoard(board, configDev) __ConfigBoard(ExpansionBase, (board), (configDev))

VOID __ConfigChain(void *, APTR baseAddr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define ConfigChain(baseAddr) __ConfigChain(ExpansionBase, (baseAddr))

struct ConfigDev * __FindConfigDev(void *, CONST struct ConfigDev * oldConfigDev, LONG manufacturer, LONG product) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define FindConfigDev(oldConfigDev, manufacturer, product) __FindConfigDev(ExpansionBase, (oldConfigDev), (manufacturer), (product))

VOID __FreeBoardMem(void *, ULONG startSlot, ULONG slotSpec) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define FreeBoardMem(startSlot, slotSpec) __FreeBoardMem(ExpansionBase, (startSlot), (slotSpec))

VOID __FreeConfigDev(void *, struct ConfigDev * configDev) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define FreeConfigDev(configDev) __FreeConfigDev(ExpansionBase, (configDev))

VOID __FreeExpansionMem(void *, ULONG startSlot, ULONG numSlots) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define FreeExpansionMem(startSlot, numSlots) __FreeExpansionMem(ExpansionBase, (startSlot), (numSlots))

UBYTE __ReadExpansionByte(void *, CONST APTR board, ULONG offset) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define ReadExpansionByte(board, offset) __ReadExpansionByte(ExpansionBase, (board), (offset))

VOID __ReadExpansionRom(void *, CONST APTR board, struct ConfigDev * configDev) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define ReadExpansionRom(board, configDev) __ReadExpansionRom(ExpansionBase, (board), (configDev))

VOID __RemConfigDev(void *, struct ConfigDev * configDev) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define RemConfigDev(configDev) __RemConfigDev(ExpansionBase, (configDev))

VOID __WriteExpansionByte(void *, APTR board, ULONG offset, ULONG byte) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define WriteExpansionByte(board, offset, byte) __WriteExpansionByte(ExpansionBase, (board), (offset), (byte))

VOID __ObtainConfigBinding(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define ObtainConfigBinding() __ObtainConfigBinding(ExpansionBase)

VOID __ReleaseConfigBinding(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define ReleaseConfigBinding() __ReleaseConfigBinding(ExpansionBase)

VOID __SetCurrentBinding(void *, struct CurrentBinding * currentBinding, ULONG bindingSize) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define SetCurrentBinding(currentBinding, bindingSize) __SetCurrentBinding(ExpansionBase, (currentBinding), (bindingSize))

ULONG __GetCurrentBinding(void *, CONST struct CurrentBinding * currentBinding, ULONG bindingSize) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define GetCurrentBinding(currentBinding, bindingSize) __GetCurrentBinding(ExpansionBase, (currentBinding), (bindingSize))

struct DeviceNode * __MakeDosNode(void *, CONST APTR parmPacket) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define MakeDosNode(parmPacket) __MakeDosNode(ExpansionBase, (parmPacket))

BOOL __AddDosNode(void *, LONG bootPri, ULONG flags, struct DeviceNode * deviceNode) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,32(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define AddDosNode(bootPri, flags, deviceNode) __AddDosNode(ExpansionBase, (bootPri), (flags), (deviceNode))

#endif /*  _VBCCINLINE_EXPANSION_H  */
