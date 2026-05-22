#ifndef _INLINE_GETSCREENMODE_H
#define _INLINE_GETSCREENMODE_H

#ifndef GETSCREENMODE_BASE_NAME
#define GETSCREENMODE_BASE_NAME GetScreenModeBase
#endif

#define GETSCREENMODE_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) GETSCREENMODE_BASE_NAME) - 30))((struct Library *) GETSCREENMODE_BASE_NAME)

#endif /*  _INLINE_GETSCREENMODE_H  */
