#ifndef _INLINE_LOWLEVEL_H
#define _INLINE_LOWLEVEL_H

#ifndef LOWLEVEL_BASE_NAME
#define LOWLEVEL_BASE_NAME LowLevelBase
#endif

#define ReadJoyPort(port) \
	((ULONG (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) LOWLEVEL_BASE_NAME) - 30))(port, (struct Library *) LOWLEVEL_BASE_NAME)

#define GetLanguageSelection() \
	((UBYTE (*)(struct Library * __asm("a6"))) \
  (((char *) LOWLEVEL_BASE_NAME) - 36))((struct Library *) LOWLEVEL_BASE_NAME)

#define GetKey() \
	((ULONG (*)(struct Library * __asm("a6"))) \
  (((char *) LOWLEVEL_BASE_NAME) - 48))((struct Library *) LOWLEVEL_BASE_NAME)

#define QueryKeys(queryArray, arraySize) \
	((VOID (*)(struct KeyQuery * __asm("a0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) LOWLEVEL_BASE_NAME) - 54))(queryArray, arraySize, (struct Library *) LOWLEVEL_BASE_NAME)

#define AddKBInt(intRoutine, intData) \
	((APTR (*)(CONST APTR __asm("a0"), CONST APTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) LOWLEVEL_BASE_NAME) - 60))(intRoutine, intData, (struct Library *) LOWLEVEL_BASE_NAME)

#define RemKBInt(intHandle) \
	((VOID (*)(APTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) LOWLEVEL_BASE_NAME) - 66))(intHandle, (struct Library *) LOWLEVEL_BASE_NAME)

#define SystemControlA(tagList) \
	((ULONG (*)(CONST struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) LOWLEVEL_BASE_NAME) - 72))(tagList, (struct Library *) LOWLEVEL_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SystemControl(tags...) \
	({ULONG _tags[] = {tags}; SystemControlA((Tag) _tags);})
#endif

#define AddTimerInt(intRoutine, intData) \
	((APTR (*)(CONST APTR __asm("a0"), CONST APTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) LOWLEVEL_BASE_NAME) - 78))(intRoutine, intData, (struct Library *) LOWLEVEL_BASE_NAME)

#define RemTimerInt(intHandle) \
	((VOID (*)(APTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) LOWLEVEL_BASE_NAME) - 84))(intHandle, (struct Library *) LOWLEVEL_BASE_NAME)

#define StopTimerInt(intHandle) \
	((VOID (*)(APTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) LOWLEVEL_BASE_NAME) - 90))(intHandle, (struct Library *) LOWLEVEL_BASE_NAME)

#define StartTimerInt(intHandle, timeInterval, continuous) \
	((VOID (*)(APTR __asm("a1"), ULONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) LOWLEVEL_BASE_NAME) - 96))(intHandle, timeInterval, continuous, (struct Library *) LOWLEVEL_BASE_NAME)

#define ElapsedTime(context) \
	((ULONG (*)(struct EClockVal * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) LOWLEVEL_BASE_NAME) - 102))(context, (struct Library *) LOWLEVEL_BASE_NAME)

#define AddVBlankInt(intRoutine, intData) \
	((APTR (*)(CONST APTR __asm("a0"), CONST APTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) LOWLEVEL_BASE_NAME) - 108))(intRoutine, intData, (struct Library *) LOWLEVEL_BASE_NAME)

#define RemVBlankInt(intHandle) \
	((VOID (*)(APTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) LOWLEVEL_BASE_NAME) - 114))(intHandle, (struct Library *) LOWLEVEL_BASE_NAME)

#define SetJoyPortAttrsA(portNumber, tagList) \
	((BOOL (*)(ULONG __asm("d0"), CONST struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) LOWLEVEL_BASE_NAME) - 132))(portNumber, tagList, (struct Library *) LOWLEVEL_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SetJoyPortAttrs(portNumber, tags...) \
	({ULONG _tags[] = {tags}; SetJoyPortAttrsA((portNumber), (Tag) _tags);})
#endif

#endif /*  _INLINE_LOWLEVEL_H  */
