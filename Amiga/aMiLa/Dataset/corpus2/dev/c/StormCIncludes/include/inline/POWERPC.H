#ifndef _INLINE_POWERPC_H
#define _INLINE_POWERPC_H

#ifndef POWERPC_BASE_NAME
#define POWERPC_BASE_NAME PowerPCBase
#endif

#define RunPPC(PPStruct) \
	((ULONG (*)(struct PPCArgs * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) POWERPC_BASE_NAME) - 30))(PPStruct, (struct Library *) POWERPC_BASE_NAME)

#define WaitForPPC(PPStruct) \
	((ULONG (*)(struct PPCArgs * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) POWERPC_BASE_NAME) - 36))(PPStruct, (struct Library *) POWERPC_BASE_NAME)

#define GetCPU() \
	((ULONG (*)(struct Library * __asm("a6"))) \
  (((char *) POWERPC_BASE_NAME) - 42))((struct Library *) POWERPC_BASE_NAME)

#define PowerDebugMode(debuglevel) \
	((VOID (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) POWERPC_BASE_NAME) - 48))(debuglevel, (struct Library *) POWERPC_BASE_NAME)

#define AllocVec32(memsize, attributes) \
	((APTR (*)(ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) POWERPC_BASE_NAME) - 54))(memsize, attributes, (struct Library *) POWERPC_BASE_NAME)

#define FreeVec32(memblock) \
	((VOID (*)(APTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) POWERPC_BASE_NAME) - 60))(memblock, (struct Library *) POWERPC_BASE_NAME)

#define SPrintF68K(Formatstring, values) \
	((VOID (*)(STRPTR __asm("a0"), APTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) POWERPC_BASE_NAME) - 66))(Formatstring, values, (struct Library *) POWERPC_BASE_NAME)

#define AllocXMsg(bodysize, replyport) \
	((struct Message * (*)(ULONG __asm("d0"), struct MsgPort * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) POWERPC_BASE_NAME) - 72))(bodysize, replyport, (struct Library *) POWERPC_BASE_NAME)

#define FreeXMsg(message) \
	((VOID (*)(struct Message * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) POWERPC_BASE_NAME) - 78))(message, (struct Library *) POWERPC_BASE_NAME)

#define PutXMsg(MsgPortPPC, message) \
	((VOID (*)(struct MsgPortPPC * __asm("a0"), struct Message * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) POWERPC_BASE_NAME) - 84))(MsgPortPPC, message, (struct Library *) POWERPC_BASE_NAME)

#define GetPPCState() \
	((ULONG (*)(struct Library * __asm("a6"))) \
  (((char *) POWERPC_BASE_NAME) - 90))((struct Library *) POWERPC_BASE_NAME)

#define SetCache68K(flags, addr, length) \
	((void (*)(ULONG __asm("d0"), void * __asm("a0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) POWERPC_BASE_NAME) - 96))(flags, addr, length, (struct Library *) POWERPC_BASE_NAME)

#define CreatePPCTask(taglist) \
	((struct TaskPPC * (*)(struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) POWERPC_BASE_NAME) - 102))(taglist, (struct Library *) POWERPC_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define CreatePPCTaskTags(tags...) \
	({ULONG _tags[] = {tags}; CreatePPCTask((Tag) _tags);})
#endif

#define CausePPCInterrupt() \
	((void (*)(struct Library * __asm("a6"))) \
  (((char *) POWERPC_BASE_NAME) - 108))((struct Library *) POWERPC_BASE_NAME)

#endif /*  _INLINE_POWERPC_H  */
