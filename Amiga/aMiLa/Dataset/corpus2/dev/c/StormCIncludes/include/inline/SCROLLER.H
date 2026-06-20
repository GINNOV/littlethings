#ifndef _INLINE_SCROLLER_H
#define _INLINE_SCROLLER_H

#ifndef SCROLLER_BASE_NAME
#define SCROLLER_BASE_NAME ScrollerBase
#endif

#define SCROLLER_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) SCROLLER_BASE_NAME) - 30))((struct Library *) SCROLLER_BASE_NAME)

#endif /*  _INLINE_SCROLLER_H  */
