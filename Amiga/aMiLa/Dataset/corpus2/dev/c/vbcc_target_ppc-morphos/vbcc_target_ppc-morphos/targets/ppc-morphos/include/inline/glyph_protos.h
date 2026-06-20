#ifndef _VBCCINLINE_GLYPH_H
#define _VBCCINLINE_GLYPH_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

Class * __GLYPH_GetClass(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define GLYPH_GetClass() __GLYPH_GetClass(GlyphBase)

#endif /*  _VBCCINLINE_GLYPH_H  */
