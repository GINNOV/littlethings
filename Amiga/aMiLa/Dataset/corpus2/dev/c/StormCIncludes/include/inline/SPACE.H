#ifndef _INLINE_SPACE_H
#define _INLINE_SPACE_H

#ifndef SPACE_BASE_NAME
#define SPACE_BASE_NAME SpaceBase
#endif

#define SPACE_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) SPACE_BASE_NAME) - 30))((struct Library *) SPACE_BASE_NAME)

#endif /*  _INLINE_SPACE_H  */
