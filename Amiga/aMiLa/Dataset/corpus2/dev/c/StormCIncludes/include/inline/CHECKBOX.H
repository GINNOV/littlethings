#ifndef _INLINE_CHECKBOX_H
#define _INLINE_CHECKBOX_H

#ifndef CHECKBOX_BASE_NAME
#define CHECKBOX_BASE_NAME CheckBoxBase
#endif

#define CHECKBOX_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) CHECKBOX_BASE_NAME) - 30))((struct Library *) CHECKBOX_BASE_NAME)

#endif /*  _INLINE_CHECKBOX_H  */
