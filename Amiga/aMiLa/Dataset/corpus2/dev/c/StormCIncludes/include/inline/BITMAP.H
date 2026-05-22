#ifndef _INLINE_BITMAP_H
#define _INLINE_BITMAP_H

#ifndef BITMAP_BASE_NAME
#define BITMAP_BASE_NAME BitMapBase
#endif

#define BITMAP_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) BITMAP_BASE_NAME) - 30))((struct Library *) BITMAP_BASE_NAME)

#endif /*  _INLINE_BITMAP_H  */
