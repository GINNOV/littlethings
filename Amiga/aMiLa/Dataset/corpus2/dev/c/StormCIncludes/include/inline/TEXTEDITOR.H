#ifndef _INLINE_TEXTEDITOR_H
#define _INLINE_TEXTEDITOR_H

#ifndef TEXTEDITOR_BASE_NAME
#define TEXTEDITOR_BASE_NAME TextEditorBase
#endif

#define TEXTEDITOR_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) TEXTEDITOR_BASE_NAME) - 30))((struct Library *) TEXTEDITOR_BASE_NAME)

#endif /*  _INLINE_TEXTEDITOR_H  */
