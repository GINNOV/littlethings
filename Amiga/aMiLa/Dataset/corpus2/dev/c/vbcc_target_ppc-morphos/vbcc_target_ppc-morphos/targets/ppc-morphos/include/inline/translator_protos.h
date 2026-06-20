#ifndef _VBCCINLINE_TRANSLATOR_H
#define _VBCCINLINE_TRANSLATOR_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

LONG __Translate(void *, CONST_STRPTR inputString, LONG inputLength, STRPTR outputBuffer, LONG bufferSize) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tstw\t7,4(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define Translate(inputString, inputLength, outputBuffer, bufferSize) __Translate(TranslatorBase, (inputString), (inputLength), (outputBuffer), (bufferSize))

#endif /*  _VBCCINLINE_TRANSLATOR_H  */
