#ifndef _INLINE_OWNDEVUNIT_H
#define _INLINE_OWNDEVUNIT_H

#ifndef OWNDEVUNIT_BASE_NAME
#define OWNDEVUNIT_BASE_NAME OwnDevUnitBase
#endif

#define LockDevUnit(device, unit, ownername, notifybit) \
	((STRPTR (*)(STRPTR __asm("a0"), ULONG __asm("d0"), STRPTR __asm("a1"), UBYTE __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) OWNDEVUNIT_BASE_NAME) - 30))(device, unit, ownername, notifybit, (struct Library *) OWNDEVUNIT_BASE_NAME)

#define AttemptDevUnit(device, unit, ownername, notifybit) \
	((STRPTR (*)(STRPTR __asm("a0"), ULONG __asm("d0"), STRPTR __asm("a1"), UBYTE __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) OWNDEVUNIT_BASE_NAME) - 36))(device, unit, ownername, notifybit, (struct Library *) OWNDEVUNIT_BASE_NAME)

#define FreeDevUnit(device, unit) \
	((void (*)(STRPTR __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) OWNDEVUNIT_BASE_NAME) - 42))(device, unit, (struct Library *) OWNDEVUNIT_BASE_NAME)

#define NameDevUnit(device, unit, ownername) \
	((void (*)(STRPTR __asm("a0"), ULONG __asm("d0"), STRPTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) OWNDEVUNIT_BASE_NAME) - 48))(device, unit, ownername, (struct Library *) OWNDEVUNIT_BASE_NAME)

#define AvailDevUnit(device, unit) \
	((BOOL (*)(STRPTR __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) OWNDEVUNIT_BASE_NAME) - 54))(device, unit, (struct Library *) OWNDEVUNIT_BASE_NAME)

#endif /*  _INLINE_OWNDEVUNIT_H  */
