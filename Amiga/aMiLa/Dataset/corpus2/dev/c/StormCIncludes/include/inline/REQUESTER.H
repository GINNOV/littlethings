#ifndef _INLINE_REQUESTER_H
#define _INLINE_REQUESTER_H

#ifndef REQUESTER_BASE_NAME
#define REQUESTER_BASE_NAME RequesterBase
#endif

#define REQUESTER_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) REQUESTER_BASE_NAME) - 30))((struct Library *) REQUESTER_BASE_NAME)

#endif /*  _INLINE_REQUESTER_H  */
