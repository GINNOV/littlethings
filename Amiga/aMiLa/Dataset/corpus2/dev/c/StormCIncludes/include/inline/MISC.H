#ifndef _INLINE_MISC_H
#define _INLINE_MISC_H

#ifndef MISC_BASE_NAME
#define MISC_BASE_NAME MiscBase
#endif

#define AllocMiscResource(unitNum, name) \
	((UBYTE * (*)(ULONG __asm("d0"), CONST_STRPTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) MISC_BASE_NAME) - 6))(unitNum, name, (struct Library *) MISC_BASE_NAME)

#define FreeMiscResource(unitNum) \
	((VOID (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) MISC_BASE_NAME) - 12))(unitNum, (struct Library *) MISC_BASE_NAME)

#endif /*  _INLINE_MISC_H  */
