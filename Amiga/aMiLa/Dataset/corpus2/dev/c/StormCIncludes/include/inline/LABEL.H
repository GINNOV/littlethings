#ifndef _INLINE_LABEL_H
#define _INLINE_LABEL_H

#ifndef LABEL_BASE_NAME
#define LABEL_BASE_NAME LabelBase
#endif

#define LABEL_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) LABEL_BASE_NAME) - 30))((struct Library *) LABEL_BASE_NAME)

#endif /*  _INLINE_LABEL_H  */
