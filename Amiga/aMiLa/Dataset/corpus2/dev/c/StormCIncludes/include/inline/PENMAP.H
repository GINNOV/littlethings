#ifndef _INLINE_PENMAP_H
#define _INLINE_PENMAP_H

#ifndef PENMAP_BASE_NAME
#define PENMAP_BASE_NAME PenMapBase
#endif

#define PENMAP_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) PENMAP_BASE_NAME) - 30))((struct Library *) PENMAP_BASE_NAME)

#endif /*  _INLINE_PENMAP_H  */
