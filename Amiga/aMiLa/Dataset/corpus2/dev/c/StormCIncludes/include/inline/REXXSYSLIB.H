#ifndef _INLINE_REXXSYSLIB_H
#define _INLINE_REXXSYSLIB_H

#ifndef REXXSYSLIB_BASE_NAME
#define REXXSYSLIB_BASE_NAME RexxSysBase
#endif

#define CreateArgstring(string, length) \
	((STRPTR (*)(CONST_STRPTR __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) REXXSYSLIB_BASE_NAME) - 126))(string, length, (struct Library *) REXXSYSLIB_BASE_NAME)

#define DeleteArgstring(argstring) \
	((VOID (*)(STRPTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) REXXSYSLIB_BASE_NAME) - 132))(argstring, (struct Library *) REXXSYSLIB_BASE_NAME)

#define LengthArgstring(argstring) \
	((ULONG (*)(CONST_STRPTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) REXXSYSLIB_BASE_NAME) - 138))(argstring, (struct Library *) REXXSYSLIB_BASE_NAME)

#define CreateRexxMsg(port, extension, host) \
	((struct RexxMsg * (*)(CONST struct MsgPort * __asm("a0"), CONST_STRPTR __asm("a1"), CONST_STRPTR __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) REXXSYSLIB_BASE_NAME) - 144))(port, extension, host, (struct Library *) REXXSYSLIB_BASE_NAME)

#define DeleteRexxMsg(packet) \
	((VOID (*)(struct RexxMsg * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) REXXSYSLIB_BASE_NAME) - 150))(packet, (struct Library *) REXXSYSLIB_BASE_NAME)

#define ClearRexxMsg(msgptr, count) \
	((VOID (*)(struct RexxMsg * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) REXXSYSLIB_BASE_NAME) - 156))(msgptr, count, (struct Library *) REXXSYSLIB_BASE_NAME)

#define FillRexxMsg(msgptr, count, mask) \
	((BOOL (*)(struct RexxMsg * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) REXXSYSLIB_BASE_NAME) - 162))(msgptr, count, mask, (struct Library *) REXXSYSLIB_BASE_NAME)

#define IsRexxMsg(msgptr) \
	((BOOL (*)(CONST struct RexxMsg * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) REXXSYSLIB_BASE_NAME) - 168))(msgptr, (struct Library *) REXXSYSLIB_BASE_NAME)

#define LockRexxBase(resource) \
	((VOID (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) REXXSYSLIB_BASE_NAME) - 450))(resource, (struct Library *) REXXSYSLIB_BASE_NAME)

#define UnlockRexxBase(resource) \
	((VOID (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) REXXSYSLIB_BASE_NAME) - 456))(resource, (struct Library *) REXXSYSLIB_BASE_NAME)

#endif /*  _INLINE_REXXSYSLIB_H  */
