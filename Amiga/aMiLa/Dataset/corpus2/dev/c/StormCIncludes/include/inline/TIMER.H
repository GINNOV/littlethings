#ifndef _INLINE_TIMER_H
#define _INLINE_TIMER_H

#ifndef TIMER_BASE_NAME
#define TIMER_BASE_NAME TimerBase
#endif

#define AddTime(dest, src) \
	((VOID (*)(struct timeval * __asm("a0"), CONST struct timeval * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) TIMER_BASE_NAME) - 42))(dest, src, (struct Library *) TIMER_BASE_NAME)

#define SubTime(dest, src) \
	((VOID (*)(struct timeval * __asm("a0"), CONST struct timeval * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) TIMER_BASE_NAME) - 48))(dest, src, (struct Library *) TIMER_BASE_NAME)

#define CmpTime(dest, src) \
	((LONG (*)(CONST struct timeval * __asm("a0"), CONST struct timeval * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) TIMER_BASE_NAME) - 54))(dest, src, (struct Library *) TIMER_BASE_NAME)

#define ReadEClock(dest) \
	((ULONG (*)(struct EClockVal * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) TIMER_BASE_NAME) - 60))(dest, (struct Library *) TIMER_BASE_NAME)

#define GetSysTime(dest) \
	((VOID (*)(struct timeval * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) TIMER_BASE_NAME) - 66))(dest, (struct Library *) TIMER_BASE_NAME)

#endif /*  _INLINE_TIMER_H  */
