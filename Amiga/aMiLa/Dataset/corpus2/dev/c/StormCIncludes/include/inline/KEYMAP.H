#ifndef _INLINE_KEYMAP_H
#define _INLINE_KEYMAP_H

#ifndef KEYMAP_BASE_NAME
#define KEYMAP_BASE_NAME KeymapBase
#endif

#define SetKeyMapDefault(keyMap) \
	((VOID (*)(CONST struct KeyMap * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) KEYMAP_BASE_NAME) - 30))(keyMap, (struct Library *) KEYMAP_BASE_NAME)

#define AskKeyMapDefault() \
	((struct KeyMap * (*)(struct Library * __asm("a6"))) \
  (((char *) KEYMAP_BASE_NAME) - 36))((struct Library *) KEYMAP_BASE_NAME)

#define MapRawKey(event, buffer, length, keyMap) \
	((WORD (*)(CONST struct InputEvent * __asm("a0"), STRPTR __asm("a1"), LONG __asm("d1"), CONST struct KeyMap * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) KEYMAP_BASE_NAME) - 42))(event, buffer, length, keyMap, (struct Library *) KEYMAP_BASE_NAME)

#define MapANSI(string, count, buffer, length, keyMap) \
	((LONG (*)(CONST_STRPTR __asm("a0"), LONG __asm("d0"), STRPTR __asm("a1"), LONG __asm("d1"), CONST struct KeyMap * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) KEYMAP_BASE_NAME) - 48))(string, count, buffer, length, keyMap, (struct Library *) KEYMAP_BASE_NAME)

#endif /*  _INLINE_KEYMAP_H  */
