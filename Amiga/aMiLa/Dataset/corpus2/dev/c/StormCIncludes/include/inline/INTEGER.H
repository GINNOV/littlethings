#ifndef _INLINE_INTEGER_H
#define _INLINE_INTEGER_H

#ifndef INTEGER_BASE_NAME
#define INTEGER_BASE_NAME IntegerBase
#endif

#define INTEGER_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) INTEGER_BASE_NAME) - 30))((struct Library *) INTEGER_BASE_NAME)

#endif /*  _INLINE_INTEGER_H  */
