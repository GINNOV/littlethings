#ifndef _INLINE_SLIDER_H
#define _INLINE_SLIDER_H

#ifndef SLIDER_BASE_NAME
#define SLIDER_BASE_NAME SliderBase
#endif

#define SLIDER_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) SLIDER_BASE_NAME) - 30))((struct Library *) SLIDER_BASE_NAME)

#endif /*  _INLINE_SLIDER_H  */
