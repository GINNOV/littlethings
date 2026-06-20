#ifndef _INLINE_DISK_H
#define _INLINE_DISK_H

#ifndef DISK_BASE_NAME
#define DISK_BASE_NAME DiskBase
#endif

#define AllocUnit(unitNum) \
	((BOOL (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) DISK_BASE_NAME) - 6))(unitNum, (struct Library *) DISK_BASE_NAME)

#define FreeUnit(unitNum) \
	((VOID (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) DISK_BASE_NAME) - 12))(unitNum, (struct Library *) DISK_BASE_NAME)

#define GetUnit(unitPointer) \
	((struct DiskResourceUnit * (*)(struct DiskResourceUnit * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) DISK_BASE_NAME) - 18))(unitPointer, (struct Library *) DISK_BASE_NAME)

#define GiveUnit() \
	((VOID (*)(struct Library * __asm("a6"))) \
  (((char *) DISK_BASE_NAME) - 24))((struct Library *) DISK_BASE_NAME)

#define GetUnitID(unitNum) \
	((LONG (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) DISK_BASE_NAME) - 30))(unitNum, (struct Library *) DISK_BASE_NAME)

#define ReadUnitID(unitNum) \
	((LONG (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) DISK_BASE_NAME) - 36))(unitNum, (struct Library *) DISK_BASE_NAME)

#endif /*  _INLINE_DISK_H  */
