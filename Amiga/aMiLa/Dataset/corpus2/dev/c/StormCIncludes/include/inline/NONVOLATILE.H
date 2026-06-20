#ifndef _INLINE_NONVOLATILE_H
#define _INLINE_NONVOLATILE_H

#ifndef NONVOLATILE_BASE_NAME
#define NONVOLATILE_BASE_NAME NVBase
#endif

#define GetCopyNV(appName, itemName, killRequesters) \
	((APTR (*)(CONST_STRPTR __asm("a0"), CONST_STRPTR __asm("a1"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) NONVOLATILE_BASE_NAME) - 30))(appName, itemName, killRequesters, (struct Library *) NONVOLATILE_BASE_NAME)

#define FreeNVData(data) \
	((VOID (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) NONVOLATILE_BASE_NAME) - 36))(data, (struct Library *) NONVOLATILE_BASE_NAME)

#define StoreNV(appName, itemName, data, length, killRequesters) \
	((UWORD (*)(CONST_STRPTR __asm("a0"), CONST_STRPTR __asm("a1"), CONST APTR __asm("a2"), ULONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) NONVOLATILE_BASE_NAME) - 42))(appName, itemName, data, length, killRequesters, (struct Library *) NONVOLATILE_BASE_NAME)

#define DeleteNV(appName, itemName, killRequesters) \
	((BOOL (*)(CONST_STRPTR __asm("a0"), CONST_STRPTR __asm("a1"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) NONVOLATILE_BASE_NAME) - 48))(appName, itemName, killRequesters, (struct Library *) NONVOLATILE_BASE_NAME)

#define GetNVInfo(killRequesters) \
	((struct NVInfo * (*)(LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) NONVOLATILE_BASE_NAME) - 54))(killRequesters, (struct Library *) NONVOLATILE_BASE_NAME)

#define GetNVList(appName, killRequesters) \
	((struct MinList * (*)(CONST_STRPTR __asm("a0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) NONVOLATILE_BASE_NAME) - 60))(appName, killRequesters, (struct Library *) NONVOLATILE_BASE_NAME)

#define SetNVProtection(appName, itemName, mask, killRequesters) \
	((BOOL (*)(CONST_STRPTR __asm("a0"), CONST_STRPTR __asm("a1"), LONG __asm("d2"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) NONVOLATILE_BASE_NAME) - 66))(appName, itemName, mask, killRequesters, (struct Library *) NONVOLATILE_BASE_NAME)

#endif /*  _INLINE_NONVOLATILE_H  */
