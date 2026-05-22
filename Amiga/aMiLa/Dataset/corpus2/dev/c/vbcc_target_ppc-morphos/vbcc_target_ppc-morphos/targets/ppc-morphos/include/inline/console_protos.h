#ifndef _VBCCINLINE_CONSOLE_H
#define _VBCCINLINE_CONSOLE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

struct InputEvent * __CDInputHandler(void *, CONST struct InputEvent * events, struct Library * consoleDevice) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define CDInputHandler(events, consoleDevice) __CDInputHandler(ConsoleDevice, (events), (consoleDevice))

LONG __RawKeyConvert(void *, CONST struct InputEvent * events, STRPTR buffer, LONG length, CONST struct KeyMap * keyMap) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,40(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define RawKeyConvert(events, buffer, length, keyMap) __RawKeyConvert(ConsoleDevice, (events), (buffer), (length), (keyMap))

#endif /*  _VBCCINLINE_CONSOLE_H  */
