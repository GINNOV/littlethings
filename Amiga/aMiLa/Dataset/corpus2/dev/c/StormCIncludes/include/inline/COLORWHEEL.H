#ifndef _INLINE_COLORWHEEL_H
#define _INLINE_COLORWHEEL_H

#ifndef COLORWHEEL_BASE_NAME
#define COLORWHEEL_BASE_NAME ColorWheelBase
#endif

#define ConvertHSBToRGB(hsb, rgb) \
	((VOID (*)(struct ColorWheelHSB * __asm("a0"), struct ColorWheelRGB * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) COLORWHEEL_BASE_NAME) - 30))(hsb, rgb, (struct Library *) COLORWHEEL_BASE_NAME)

#define ConvertRGBToHSB(rgb, hsb) \
	((VOID (*)(struct ColorWheelRGB * __asm("a0"), struct ColorWheelHSB * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) COLORWHEEL_BASE_NAME) - 36))(rgb, hsb, (struct Library *) COLORWHEEL_BASE_NAME)

#endif /*  _INLINE_COLORWHEEL_H  */
