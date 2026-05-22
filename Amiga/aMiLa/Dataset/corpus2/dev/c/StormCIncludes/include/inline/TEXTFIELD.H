#ifndef _INLINE_TEXTFIELD_H
#define _INLINE_TEXTFIELD_H

#ifndef TEXTFIELD_BASE_NAME
#define TEXTFIELD_BASE_NAME TextFieldBase
#endif

#define TEXTFIELD_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) TEXTFIELD_BASE_NAME) - 30))((struct Library *) TEXTFIELD_BASE_NAME)

#endif /*  _INLINE_TEXTFIELD_H  */
