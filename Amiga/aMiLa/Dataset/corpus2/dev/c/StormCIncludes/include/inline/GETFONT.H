#ifndef _INLINE_GETFONT_H
#define _INLINE_GETFONT_H

#ifndef GETFONT_BASE_NAME
#define GETFONT_BASE_NAME GetFontBase
#endif

#define GETFONT_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) GETFONT_BASE_NAME) - 30))((struct Library *) GETFONT_BASE_NAME)

#endif /*  _INLINE_GETFONT_H  */
