#ifndef _INLINE_STRING_H
#define _INLINE_STRING_H

#ifndef STRING_BASE_NAME
#define STRING_BASE_NAME StringBase
#endif

#define STRING_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) STRING_BASE_NAME) - 30))((struct Library *) STRING_BASE_NAME)

#endif /*  _INLINE_STRING_H  */
