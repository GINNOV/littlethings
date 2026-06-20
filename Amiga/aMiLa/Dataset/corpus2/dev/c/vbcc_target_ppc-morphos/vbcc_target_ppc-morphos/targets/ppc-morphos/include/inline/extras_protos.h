#ifndef _VBCCINLINE_EXTRAS_H
#define _VBCCINLINE_EXTRAS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

struct BitMap* __LoadImageToBitMapA(void *, CONST_STRPTR path, struct TagItem* taglist) =
	"\tlwz\t0,-28(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LoadImageToBitMapA(path, taglist) __LoadImageToBitMapA(ExtrasBase, (path), (taglist))

struct BitMap* __LoadImageToBitMap(void *, CONST_STRPTR path, ...) =
	"\tlwz\t0,-28(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LoadImageToBitMap(path, ...) __LoadImageToBitMap(ExtrasBase, (path), __VA_ARGS__)

APTR __LoadFileA(void *, CONST_STRPTR path, struct TagItem* taglist) =
	"\tlwz\t0,-34(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LoadFileA(path, taglist) __LoadFileA(ExtrasBase, (path), (taglist))

APTR __LoadFile(void *, CONST_STRPTR path, ...) =
	"\tlwz\t0,-34(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LoadFile(path, ...) __LoadFile(ExtrasBase, (path), __VA_ARGS__)

APTR __LoadImageToArrayA(void *, CONST_STRPTR path, struct TagItem* taglist) =
	"\tlwz\t0,-40(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LoadImageToArrayA(path, taglist) __LoadImageToArrayA(ExtrasBase, (path), (taglist))

APTR __LoadImageToArray(void *, CONST_STRPTR path, ...) =
	"\tlwz\t0,-40(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LoadImageToArray(path, ...) __LoadImageToArray(ExtrasBase, (path), __VA_ARGS__)

#endif /*  _VBCCINLINE_EXTRAS_H  */
