#ifndef _INLINE_DTCLASS_H
#define _INLINE_DTCLASS_H

#ifndef DTCLASS_BASE_NAME
#define DTCLASS_BASE_NAME DTClassBase
#endif

#define ObtainEngine() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) DTCLASS_BASE_NAME) - 30))((struct Library *) DTCLASS_BASE_NAME)

#endif /*  _INLINE_DTCLASS_H  */
