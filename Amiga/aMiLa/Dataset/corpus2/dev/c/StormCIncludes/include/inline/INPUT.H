#ifndef _INLINE_INPUT_H
#define _INLINE_INPUT_H

#ifndef INPUT_BASE_NAME
#define INPUT_BASE_NAME InputBase
#endif

#define PeekQualifier() \
	((UWORD (*)(struct Library * __asm("a6"))) \
  (((char *) INPUT_BASE_NAME) - 42))((struct Library *) INPUT_BASE_NAME)

#endif /*  _INLINE_INPUT_H  */
