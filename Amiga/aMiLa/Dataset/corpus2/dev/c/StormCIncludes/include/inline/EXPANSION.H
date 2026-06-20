#ifndef _INLINE_EXPANSION_H
#define _INLINE_EXPANSION_H

#ifndef EXPANSION_BASE_NAME
#define EXPANSION_BASE_NAME ExpansionBase
#endif

#define AddConfigDev(configDev) \
	((VOID (*)(struct ConfigDev * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXPANSION_BASE_NAME) - 30))(configDev, (struct Library *) EXPANSION_BASE_NAME)

#define AddBootNode(bootPri, flags, deviceNode, configDev) \
	((BOOL (*)(LONG __asm("d0"), ULONG __asm("d1"), struct DeviceNode * __asm("a0"), struct ConfigDev * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXPANSION_BASE_NAME) - 36))(bootPri, flags, deviceNode, configDev, (struct Library *) EXPANSION_BASE_NAME)

#define AllocBoardMem(slotSpec) \
	((VOID (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXPANSION_BASE_NAME) - 42))(slotSpec, (struct Library *) EXPANSION_BASE_NAME)

#define AllocConfigDev() \
	((struct ConfigDev * (*)(struct Library * __asm("a6"))) \
  (((char *) EXPANSION_BASE_NAME) - 48))((struct Library *) EXPANSION_BASE_NAME)

#define AllocExpansionMem(numSlots, slotAlign) \
	((APTR (*)(ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) EXPANSION_BASE_NAME) - 54))(numSlots, slotAlign, (struct Library *) EXPANSION_BASE_NAME)

#define ConfigBoard(board, configDev) \
	((VOID (*)(APTR __asm("a0"), struct ConfigDev * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXPANSION_BASE_NAME) - 60))(board, configDev, (struct Library *) EXPANSION_BASE_NAME)

#define ConfigChain(baseAddr) \
	((VOID (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXPANSION_BASE_NAME) - 66))(baseAddr, (struct Library *) EXPANSION_BASE_NAME)

#define FindConfigDev(oldConfigDev, manufacturer, product) \
	((struct ConfigDev * (*)(CONST struct ConfigDev * __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) EXPANSION_BASE_NAME) - 72))(oldConfigDev, manufacturer, product, (struct Library *) EXPANSION_BASE_NAME)

#define FreeBoardMem(startSlot, slotSpec) \
	((VOID (*)(ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) EXPANSION_BASE_NAME) - 78))(startSlot, slotSpec, (struct Library *) EXPANSION_BASE_NAME)

#define FreeConfigDev(configDev) \
	((VOID (*)(struct ConfigDev * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXPANSION_BASE_NAME) - 84))(configDev, (struct Library *) EXPANSION_BASE_NAME)

#define FreeExpansionMem(startSlot, numSlots) \
	((VOID (*)(ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) EXPANSION_BASE_NAME) - 90))(startSlot, numSlots, (struct Library *) EXPANSION_BASE_NAME)

#define ReadExpansionByte(board, offset) \
	((UBYTE (*)(CONST APTR __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXPANSION_BASE_NAME) - 96))(board, offset, (struct Library *) EXPANSION_BASE_NAME)

#define ReadExpansionRom(board, configDev) \
	((VOID (*)(CONST APTR __asm("a0"), struct ConfigDev * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXPANSION_BASE_NAME) - 102))(board, configDev, (struct Library *) EXPANSION_BASE_NAME)

#define RemConfigDev(configDev) \
	((VOID (*)(struct ConfigDev * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXPANSION_BASE_NAME) - 108))(configDev, (struct Library *) EXPANSION_BASE_NAME)

#define WriteExpansionByte(board, offset, byte) \
	((VOID (*)(APTR __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) EXPANSION_BASE_NAME) - 114))(board, offset, byte, (struct Library *) EXPANSION_BASE_NAME)

#define ObtainConfigBinding() \
	((VOID (*)(struct Library * __asm("a6"))) \
  (((char *) EXPANSION_BASE_NAME) - 120))((struct Library *) EXPANSION_BASE_NAME)

#define ReleaseConfigBinding() \
	((VOID (*)(struct Library * __asm("a6"))) \
  (((char *) EXPANSION_BASE_NAME) - 126))((struct Library *) EXPANSION_BASE_NAME)

#define SetCurrentBinding(currentBinding, bindingSize) \
	((VOID (*)(struct CurrentBinding * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXPANSION_BASE_NAME) - 132))(currentBinding, bindingSize, (struct Library *) EXPANSION_BASE_NAME)

#define GetCurrentBinding(currentBinding, bindingSize) \
	((ULONG (*)(CONST struct CurrentBinding * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXPANSION_BASE_NAME) - 138))(currentBinding, bindingSize, (struct Library *) EXPANSION_BASE_NAME)

#define MakeDosNode(parmPacket) \
	((struct DeviceNode * (*)(CONST APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXPANSION_BASE_NAME) - 144))(parmPacket, (struct Library *) EXPANSION_BASE_NAME)

#define AddDosNode(bootPri, flags, deviceNode) \
	((BOOL (*)(LONG __asm("d0"), ULONG __asm("d1"), struct DeviceNode * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXPANSION_BASE_NAME) - 150))(bootPri, flags, deviceNode, (struct Library *) EXPANSION_BASE_NAME)

#endif /*  _INLINE_EXPANSION_H  */
