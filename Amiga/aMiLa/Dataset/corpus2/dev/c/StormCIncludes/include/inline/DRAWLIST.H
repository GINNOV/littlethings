#ifndef _INLINE_DRAWLIST_H
#define _INLINE_DRAWLIST_H

#ifndef DRAWLIST_BASE_NAME
#define DRAWLIST_BASE_NAME DrawListBase
#endif

#define DRAWLIST_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) DRAWLIST_BASE_NAME) - 30))((struct Library *) DRAWLIST_BASE_NAME)

#endif /*  _INLINE_DRAWLIST_H  */
