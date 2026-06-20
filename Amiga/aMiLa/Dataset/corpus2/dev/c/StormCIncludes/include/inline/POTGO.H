#ifndef _INLINE_POTGO_H
#define _INLINE_POTGO_H

#ifndef POTGO_BASE_NAME
#define POTGO_BASE_NAME PotgoBase
#endif

#define AllocPotBits(bits) \
	((UWORD (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) POTGO_BASE_NAME) - 6))(bits, (struct Library *) POTGO_BASE_NAME)

#define FreePotBits(bits) \
	((VOID (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) POTGO_BASE_NAME) - 12))(bits, (struct Library *) POTGO_BASE_NAME)

#define WritePotgo(word, mask) \
	((VOID (*)(ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) POTGO_BASE_NAME) - 18))(word, mask, (struct Library *) POTGO_BASE_NAME)

#endif /*  _INLINE_POTGO_H  */
