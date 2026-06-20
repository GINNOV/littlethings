#ifndef _INLINE_BEVEL_H
#define _INLINE_BEVEL_H

#ifndef BEVEL_BASE_NAME
#define BEVEL_BASE_NAME BevelBase
#endif

#define BEVEL_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) BEVEL_BASE_NAME) - 30))((struct Library *) BEVEL_BASE_NAME)

#endif /*  _INLINE_BEVEL_H  */
