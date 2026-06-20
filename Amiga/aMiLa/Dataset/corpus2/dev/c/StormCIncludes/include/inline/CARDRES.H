#ifndef _INLINE_CARDRES_H
#define _INLINE_CARDRES_H

#ifndef CARDRES_BASE_NAME
#define CARDRES_BASE_NAME CardResource
#endif

#define OwnCard(handle) \
	((struct CardHandle * (*)(struct CardHandle * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) CARDRES_BASE_NAME) - 6))(handle, (struct Library *) CARDRES_BASE_NAME)

#define ReleaseCard(handle, flags) \
	((VOID (*)(struct CardHandle * __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) CARDRES_BASE_NAME) - 12))(handle, flags, (struct Library *) CARDRES_BASE_NAME)

#define GetCardMap() \
	((struct CardMemoryMap * (*)(struct Library * __asm("a6"))) \
  (((char *) CARDRES_BASE_NAME) - 18))((struct Library *) CARDRES_BASE_NAME)

#define BeginCardAccess(handle) \
	((BOOL (*)(struct CardHandle * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) CARDRES_BASE_NAME) - 24))(handle, (struct Library *) CARDRES_BASE_NAME)

#define EndCardAccess(handle) \
	((BOOL (*)(struct CardHandle * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) CARDRES_BASE_NAME) - 30))(handle, (struct Library *) CARDRES_BASE_NAME)

#define ReadCardStatus() \
	((UBYTE (*)(struct Library * __asm("a6"))) \
  (((char *) CARDRES_BASE_NAME) - 36))((struct Library *) CARDRES_BASE_NAME)

#define CardResetRemove(handle, flag) \
	((BOOL (*)(struct CardHandle * __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) CARDRES_BASE_NAME) - 42))(handle, flag, (struct Library *) CARDRES_BASE_NAME)

#define CardMiscControl(handle, control_bits) \
	((UBYTE (*)(struct CardHandle * __asm("a1"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) CARDRES_BASE_NAME) - 48))(handle, control_bits, (struct Library *) CARDRES_BASE_NAME)

#define CardAccessSpeed(handle, nanoseconds) \
	((ULONG (*)(struct CardHandle * __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) CARDRES_BASE_NAME) - 54))(handle, nanoseconds, (struct Library *) CARDRES_BASE_NAME)

#define CardProgramVoltage(handle, voltage) \
	((LONG (*)(struct CardHandle * __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) CARDRES_BASE_NAME) - 60))(handle, voltage, (struct Library *) CARDRES_BASE_NAME)

#define CardResetCard(handle) \
	((BOOL (*)(struct CardHandle * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) CARDRES_BASE_NAME) - 66))(handle, (struct Library *) CARDRES_BASE_NAME)

#define CopyTuple(handle, buffer, tuplecode, size) \
	((BOOL (*)(CONST struct CardHandle * __asm("a1"), UBYTE * __asm("a0"), ULONG __asm("d1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) CARDRES_BASE_NAME) - 72))(handle, buffer, tuplecode, size, (struct Library *) CARDRES_BASE_NAME)

#define DeviceTuple(tuple_data, storage) \
	((ULONG (*)(CONST UBYTE * __asm("a0"), struct DeviceTData * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) CARDRES_BASE_NAME) - 78))(tuple_data, storage, (struct Library *) CARDRES_BASE_NAME)

#define IfAmigaXIP(handle) \
	((struct Resident * (*)(CONST struct CardHandle * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) CARDRES_BASE_NAME) - 84))(handle, (struct Library *) CARDRES_BASE_NAME)

#define CardForceChange() \
	((BOOL (*)(struct Library * __asm("a6"))) \
  (((char *) CARDRES_BASE_NAME) - 90))((struct Library *) CARDRES_BASE_NAME)

#define CardChangeCount() \
	((ULONG (*)(struct Library * __asm("a6"))) \
  (((char *) CARDRES_BASE_NAME) - 96))((struct Library *) CARDRES_BASE_NAME)

#define CardInterface() \
	((ULONG (*)(struct Library * __asm("a6"))) \
  (((char *) CARDRES_BASE_NAME) - 102))((struct Library *) CARDRES_BASE_NAME)

#endif /*  _INLINE_CARDRES_H  */
