#ifndef _INLINE_RAMDRIVE_H
#define _INLINE_RAMDRIVE_H

#ifndef RAMDRIVE_BASE_NAME
#define RAMDRIVE_BASE_NAME RamdriveDevice
#endif

#define KillRAD0() \
	((STRPTR (*)(struct Library * __asm("a6"))) \
  (((char *) RAMDRIVE_BASE_NAME) - 42))((struct Library *) RAMDRIVE_BASE_NAME)

#define KillRAD(unit) \
	((STRPTR (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) RAMDRIVE_BASE_NAME) - 48))(unit, (struct Library *) RAMDRIVE_BASE_NAME)

#endif /*  _INLINE_RAMDRIVE_H  */
