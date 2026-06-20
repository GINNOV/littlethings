#ifndef _INLINE_BATTCLOCK_H
#define _INLINE_BATTCLOCK_H

#ifndef BATTCLOCK_BASE_NAME
#define BATTCLOCK_BASE_NAME BattClockBase
#endif

#define ResetBattClock() \
	((VOID (*)(struct Library * __asm("a6"))) \
  (((char *) BATTCLOCK_BASE_NAME) - 6))((struct Library *) BATTCLOCK_BASE_NAME)

#define ReadBattClock() \
	((ULONG (*)(struct Library * __asm("a6"))) \
  (((char *) BATTCLOCK_BASE_NAME) - 12))((struct Library *) BATTCLOCK_BASE_NAME)

#define WriteBattClock(time) \
	((VOID (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) BATTCLOCK_BASE_NAME) - 18))(time, (struct Library *) BATTCLOCK_BASE_NAME)

#endif /*  _INLINE_BATTCLOCK_H  */
