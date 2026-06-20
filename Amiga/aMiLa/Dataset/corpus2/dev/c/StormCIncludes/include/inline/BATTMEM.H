#ifndef _INLINE_BATTMEM_H
#define _INLINE_BATTMEM_H

#ifndef BATTMEM_BASE_NAME
#define BATTMEM_BASE_NAME BattMemBase
#endif

#define ObtainBattSemaphore() \
	((VOID (*)(struct Library * __asm("a6"))) \
  (((char *) BATTMEM_BASE_NAME) - 6))((struct Library *) BATTMEM_BASE_NAME)

#define ReleaseBattSemaphore() \
	((VOID (*)(struct Library * __asm("a6"))) \
  (((char *) BATTMEM_BASE_NAME) - 12))((struct Library *) BATTMEM_BASE_NAME)

#define ReadBattMem(buffer, offset, length) \
	((ULONG (*)(APTR __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) BATTMEM_BASE_NAME) - 18))(buffer, offset, length, (struct Library *) BATTMEM_BASE_NAME)

#define WriteBattMem(buffer, offset, length) \
	((ULONG (*)(CONST APTR __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) BATTMEM_BASE_NAME) - 24))(buffer, offset, length, (struct Library *) BATTMEM_BASE_NAME)

#endif /*  _INLINE_BATTMEM_H  */
