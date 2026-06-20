#ifndef _INLINE_BUTTON_H
#define _INLINE_BUTTON_H

#ifndef BUTTON_BASE_NAME
#define BUTTON_BASE_NAME ButtonBase
#endif

#define BUTTON_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) BUTTON_BASE_NAME) - 30))((struct Library *) BUTTON_BASE_NAME)

#endif /*  _INLINE_BUTTON_H  */
