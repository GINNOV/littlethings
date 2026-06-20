#ifndef _INLINE_WINDOW_H
#define _INLINE_WINDOW_H

#ifndef WINDOW_BASE_NAME
#define WINDOW_BASE_NAME WindowBase
#endif

#define WINDOW_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) WINDOW_BASE_NAME) - 30))((struct Library *) WINDOW_BASE_NAME)

#endif /*  _INLINE_WINDOW_H  */
