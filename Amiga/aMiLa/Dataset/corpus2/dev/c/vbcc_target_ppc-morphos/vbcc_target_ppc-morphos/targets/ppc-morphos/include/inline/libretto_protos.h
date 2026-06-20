#ifndef _VBCCINLINE_LIBRETTO_H
#define _VBCCINLINE_LIBRETTO_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

Object* __NewGlyphRunA(void *, APTR text, LONG chars, struct TagItem* taglist) =
	"\tlwz\t0,-28(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define NewGlyphRunA(text, chars, taglist) __NewGlyphRunA(LibrettoBase, (text), (chars), (taglist))

Object* __NewGlyphRun(void *, APTR text, LONG chars, ...) =
	"\tlwz\t0,-28(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define NewGlyphRun(text, chars, ...) __NewGlyphRun(LibrettoBase, (text), (chars), __VA_ARGS__)

Object* __NewDrawTargetA(void *, APTR handle, LONG type, struct TagItem* taglist) =
	"\tlwz\t0,-34(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define NewDrawTargetA(handle, type, taglist) __NewDrawTargetA(LibrettoBase, (handle), (type), (taglist))

Object* __NewDrawTarget(void *, APTR handle, LONG type, ...) =
	"\tlwz\t0,-34(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define NewDrawTarget(handle, type, ...) __NewDrawTarget(LibrettoBase, (handle), (type), __VA_ARGS__)

VOID __DrawGlyphRun(void *, Object* target, Object* glrun, LONG x, LONG y) =
	"\tlwz\t0,-40(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define DrawGlyphRun(target, glrun, x, y) __DrawGlyphRun(LibrettoBase, (target), (glrun), (x), (y))

#endif /*  _VBCCINLINE_LIBRETTO_H  */
