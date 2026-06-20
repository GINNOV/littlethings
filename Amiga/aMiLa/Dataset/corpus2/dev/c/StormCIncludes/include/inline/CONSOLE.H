#ifndef _INLINE_CONSOLE_H
#define _INLINE_CONSOLE_H

#ifndef CONSOLE_BASE_NAME
#define CONSOLE_BASE_NAME ConsoleDevice
#endif

#define CDInputHandler(events, consoleDevice) \
	((struct InputEvent * (*)(CONST struct InputEvent * __asm("a0"), struct Library * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) CONSOLE_BASE_NAME) - 42))(events, consoleDevice, (struct Library *) CONSOLE_BASE_NAME)

#define RawKeyConvert(events, buffer, length, keyMap) \
	((LONG (*)(CONST struct InputEvent * __asm("a0"), STRPTR __asm("a1"), LONG __asm("d1"), CONST struct KeyMap * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) CONSOLE_BASE_NAME) - 48))(events, buffer, length, keyMap, (struct Library *) CONSOLE_BASE_NAME)

#endif /*  _INLINE_CONSOLE_H  */
