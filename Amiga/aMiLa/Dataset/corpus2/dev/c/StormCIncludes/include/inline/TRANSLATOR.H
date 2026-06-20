#ifndef _INLINE_TRANSLATOR_H
#define _INLINE_TRANSLATOR_H

#ifndef TRANSLATOR_BASE_NAME
#define TRANSLATOR_BASE_NAME TranslatorBase
#endif

#define Translate(inputString, inputLength, outputBuffer, bufferSize) \
	((LONG (*)(CONST_STRPTR __asm("a0"), LONG __asm("d0"), STRPTR __asm("a1"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) TRANSLATOR_BASE_NAME) - 30))(inputString, inputLength, outputBuffer, bufferSize, (struct Library *) TRANSLATOR_BASE_NAME)

#endif /*  _INLINE_TRANSLATOR_H  */
