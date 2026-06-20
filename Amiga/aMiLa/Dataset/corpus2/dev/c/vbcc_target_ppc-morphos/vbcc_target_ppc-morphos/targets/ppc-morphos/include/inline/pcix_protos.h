#ifndef _VBCCINLINE_PCIX_H
#define _VBCCINLINE_PCIX_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

APTR __PCIXCreateIntObjectTagList(void *, APTR BoardObject, ULONG (*Code)(void), APTR Data, struct TagItem       * MyTags) =
	"\tlwz\t0,-52(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PCIXCreateIntObjectTagList(BoardObject, Code, Data, MyTags) __PCIXCreateIntObjectTagList(PCIXBase, (BoardObject), (Code), (Data), (MyTags))

APTR __PCIXCreateIntObjectTags(void *, APTR BoardObject, ULONG (*Code)(void), APTR Data, ...) =
	"\tlwz\t0,-52(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PCIXCreateIntObjectTags(BoardObject, Code, ...) __PCIXCreateIntObjectTags(PCIXBase, (BoardObject), (Code), __VA_ARGS__)

void __PCIXDeleteIntObject(void *, APTR IntObject) =
	"\tlwz\t0,-58(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PCIXDeleteIntObject(IntObject) __PCIXDeleteIntObject(PCIXBase, (IntObject))

APTR __PCIXFindBridgeTagList(void *, APTR BoardObject, struct TagItem            * Tags) =
	"\tlwz\t0,-64(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PCIXFindBridgeTagList(BoardObject, Tags) __PCIXFindBridgeTagList(PCIXBase, (BoardObject), (Tags))

APTR __PCIXFindBridgeTags(void *, APTR BoardObject, ...) =
	"\tlwz\t0,-64(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PCIXFindBridgeTags(...) __PCIXFindBridgeTags(PCIXBase, __VA_ARGS__)

ULONG __PCIXGetBridgeAttr(void *, APTR BoardObject, ULONG Attr) =
	"\tlwz\t0,-70(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PCIXGetBridgeAttr(BoardObject, Attr) __PCIXGetBridgeAttr(PCIXBase, (BoardObject), (Attr))

ULONG __PCIXSetBridgeAttr(void *, APTR BoardObject, ULONG Attr, ULONG Data) =
	"\tlwz\t0,-76(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PCIXSetBridgeAttr(BoardObject, Attr, Data) __PCIXSetBridgeAttr(PCIXBase, (BoardObject), (Attr), (Data))

APTR __PCIXFindBoardTagList(void *, APTR BoardObject, struct TagItem             * Tags) =
	"\tlwz\t0,-82(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PCIXFindBoardTagList(BoardObject, Tags) __PCIXFindBoardTagList(PCIXBase, (BoardObject), (Tags))

APTR __PCIXFindBoardTags(void *, APTR BoardObject, ...) =
	"\tlwz\t0,-82(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PCIXFindBoardTags(...) __PCIXFindBoardTags(PCIXBase, __VA_ARGS__)

ULONG __PCIXGetBoardAttr(void *, APTR BoardObject, ULONG Attr) =
	"\tlwz\t0,-88(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PCIXGetBoardAttr(BoardObject, Attr) __PCIXGetBoardAttr(PCIXBase, (BoardObject), (Attr))

ULONG __PCIXSetBoardAttr(void *, APTR BoardObject, ULONG Attr, ULONG Data) =
	"\tlwz\t0,-94(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PCIXSetBoardAttr(BoardObject, Attr, Data) __PCIXSetBoardAttr(PCIXBase, (BoardObject), (Attr), (Data))

ULONG __PCIXReadConfigByte(void *, APTR BoardObject, ULONG Offset) =
	"\tlwz\t0,-100(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PCIXReadConfigByte(BoardObject, Offset) __PCIXReadConfigByte(PCIXBase, (BoardObject), (Offset))

ULONG __PCIXReadConfigWord(void *, APTR BoardObject, ULONG Offset) =
	"\tlwz\t0,-106(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PCIXReadConfigWord(BoardObject, Offset) __PCIXReadConfigWord(PCIXBase, (BoardObject), (Offset))

ULONG __PCIXReadConfigLong(void *, APTR BoardObject, ULONG Offset) =
	"\tlwz\t0,-112(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PCIXReadConfigLong(BoardObject, Offset) __PCIXReadConfigLong(PCIXBase, (BoardObject), (Offset))

ULONG __PCIXWriteConfigByte(void *, APTR BoardObject, ULONG Offset, ULONG Data) =
	"\tlwz\t0,-118(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PCIXWriteConfigByte(BoardObject, Offset, Data) __PCIXWriteConfigByte(PCIXBase, (BoardObject), (Offset), (Data))

ULONG __PCIXWriteConfigWord(void *, APTR BoardObject, ULONG Offset, ULONG Data) =
	"\tlwz\t0,-124(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PCIXWriteConfigWord(BoardObject, Offset, Data) __PCIXWriteConfigWord(PCIXBase, (BoardObject), (Offset), (Data))

ULONG __PCIXWriteConfigLong(void *, APTR BoardObject, ULONG Offset, ULONG Data) =
	"\tlwz\t0,-130(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PCIXWriteConfigLong(BoardObject, Offset, Data) __PCIXWriteConfigLong(PCIXBase, (BoardObject), (Offset), (Data))

ULONG __PCIXModifyConfigByte(void *, APTR BoardObject, ULONG Offset, ULONG Data, ULONG Mask) =
	"\tlwz\t0,-208(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PCIXModifyConfigByte(BoardObject, Offset, Data, Mask) __PCIXModifyConfigByte(PCIXBase, (BoardObject), (Offset), (Data), (Mask))

ULONG __PCIXModifyConfigWord(void *, APTR BoardObject, ULONG Offset, ULONG Data, ULONG Mask) =
	"\tlwz\t0,-214(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PCIXModifyConfigWord(BoardObject, Offset, Data, Mask) __PCIXModifyConfigWord(PCIXBase, (BoardObject), (Offset), (Data), (Mask))

ULONG __PCIXModifyConfigLong(void *, APTR BoardObject, ULONG Offset, ULONG Data, ULONG Mask) =
	"\tlwz\t0,-220(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PCIXModifyConfigLong(BoardObject, Offset, Data, Mask) __PCIXModifyConfigLong(PCIXBase, (BoardObject), (Offset), (Data), (Mask))

#endif /*  _VBCCINLINE_PCIX_H  */
