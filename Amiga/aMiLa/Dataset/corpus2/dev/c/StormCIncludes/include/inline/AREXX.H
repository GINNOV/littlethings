#ifndef _INLINE_AREXX_H
#define _INLINE_AREXX_H

#ifndef AREXX_BASE_NAME
#define AREXX_BASE_NAME ARexxBase
#endif

#define AREXX_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) AREXX_BASE_NAME) - 30))((struct Library *) AREXX_BASE_NAME)

#endif /*  _INLINE_AREXX_H  */
