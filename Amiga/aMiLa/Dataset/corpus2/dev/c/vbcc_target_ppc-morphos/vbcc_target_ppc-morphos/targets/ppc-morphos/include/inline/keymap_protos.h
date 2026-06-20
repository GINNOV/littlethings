#ifndef _VBCCINLINE_KEYMAP_H
#define _VBCCINLINE_KEYMAP_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

VOID __SetKeyMapDefault(void *, CONST struct KeyMap * keyMap) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define SetKeyMapDefault(keyMap) __SetKeyMapDefault(KeymapBase, (keyMap))

struct KeyMap * __AskKeyMapDefault(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define AskKeyMapDefault() __AskKeyMapDefault(KeymapBase)

WORD __MapRawKey(void *, CONST struct InputEvent * event, STRPTR buffer, LONG length, CONST struct KeyMap * keyMap) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,40(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define MapRawKey(event, buffer, length, keyMap) __MapRawKey(KeymapBase, (event), (buffer), (length), (keyMap))

LONG __MapANSI(void *, CONST_STRPTR string, LONG count, STRPTR buffer, LONG length, CONST struct KeyMap * keyMap) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,40(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define MapANSI(string, count, buffer, length, keyMap) __MapANSI(KeymapBase, (string), (count), (buffer), (length), (keyMap))

WORD __MapRawKeyUCS4(void *, CONST struct InputEvent * event, WSTRPTR buffer, LONG length, CONST struct KeyMap * keyMap) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,40(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define MapRawKeyUCS4(event, buffer, length, keyMap) __MapRawKeyUCS4(KeymapBase, (event), (buffer), (length), (keyMap))

LONG __MapUCS4(void *, CONST_WSTRPTR string, LONG count, STRPTR buffer, LONG length, CONST struct KeyMap * keyMap) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,40(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define MapUCS4(string, count, buffer, length, keyMap) __MapUCS4(KeymapBase, (string), (count), (buffer), (length), (keyMap))

char __ToANSI(void *, WCHAR ucs4char, CONST struct KeyMap * keyMap) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define ToANSI(ucs4char, keyMap) __ToANSI(KeymapBase, (ucs4char), (keyMap))

WCHAR __ToUCS4(void *, char asciichar, CONST struct KeyMap * keyMap) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define ToUCS4(asciichar, keyMap) __ToUCS4(KeymapBase, (asciichar), (keyMap))

CONST_STRPTR __GetKeyMapCodepage(void *, CONST struct KeyMap * keyMap) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define GetKeyMapCodepage(keyMap) __GetKeyMapCodepage(KeymapBase, (keyMap))

#endif /*  _VBCCINLINE_KEYMAP_H  */
