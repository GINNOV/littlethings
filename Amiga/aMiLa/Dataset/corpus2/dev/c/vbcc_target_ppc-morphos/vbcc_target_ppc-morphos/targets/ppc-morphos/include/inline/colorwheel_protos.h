#ifndef _VBCCINLINE_COLORWHEEL_H
#define _VBCCINLINE_COLORWHEEL_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

VOID __ConvertHSBToRGB(void *, struct ColorWheelHSB * hsb, struct ColorWheelRGB * rgb) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define ConvertHSBToRGB(hsb, rgb) __ConvertHSBToRGB(ColorWheelBase, (hsb), (rgb))

VOID __ConvertRGBToHSB(void *, struct ColorWheelRGB * rgb, struct ColorWheelHSB * hsb) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define ConvertRGBToHSB(rgb, hsb) __ConvertRGBToHSB(ColorWheelBase, (rgb), (hsb))

#endif /*  _VBCCINLINE_COLORWHEEL_H  */
