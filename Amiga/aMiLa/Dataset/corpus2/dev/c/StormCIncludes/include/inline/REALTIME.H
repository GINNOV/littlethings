#ifndef _INLINE_REALTIME_H
#define _INLINE_REALTIME_H

#ifndef REALTIME_BASE_NAME
#define REALTIME_BASE_NAME RealTimeBase
#endif

#define LockRealTime(lockType) \
	((APTR (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) REALTIME_BASE_NAME) - 30))(lockType, (struct Library *) REALTIME_BASE_NAME)

#define UnlockRealTime(lock) \
	((VOID (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) REALTIME_BASE_NAME) - 36))(lock, (struct Library *) REALTIME_BASE_NAME)

#define CreatePlayerA(tagList) \
	((struct Player * (*)(CONST struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) REALTIME_BASE_NAME) - 42))(tagList, (struct Library *) REALTIME_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define CreatePlayer(tags...) \
	({ULONG _tags[] = {tags}; CreatePlayerA((Tag) _tags);})
#endif

#define DeletePlayer(player) \
	((VOID (*)(struct Player * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) REALTIME_BASE_NAME) - 48))(player, (struct Library *) REALTIME_BASE_NAME)

#define SetPlayerAttrsA(player, tagList) \
	((BOOL (*)(struct Player * __asm("a0"), CONST struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) REALTIME_BASE_NAME) - 54))(player, tagList, (struct Library *) REALTIME_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SetPlayerAttrs(player, tags...) \
	({ULONG _tags[] = {tags}; SetPlayerAttrsA((player), (Tag) _tags);})
#endif

#define SetConductorState(player, state, time) \
	((LONG (*)(struct Player * __asm("a0"), ULONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) REALTIME_BASE_NAME) - 60))(player, state, time, (struct Library *) REALTIME_BASE_NAME)

#define ExternalSync(player, minTime, maxTime) \
	((BOOL (*)(struct Player * __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) REALTIME_BASE_NAME) - 66))(player, minTime, maxTime, (struct Library *) REALTIME_BASE_NAME)

#define NextConductor(previousConductor) \
	((struct Conductor * (*)(CONST struct Conductor * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) REALTIME_BASE_NAME) - 72))(previousConductor, (struct Library *) REALTIME_BASE_NAME)

#define FindConductor(name) \
	((struct Conductor * (*)(CONST_STRPTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) REALTIME_BASE_NAME) - 78))(name, (struct Library *) REALTIME_BASE_NAME)

#define GetPlayerAttrsA(player, tagList) \
	((ULONG (*)(CONST struct Player * __asm("a0"), CONST struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) REALTIME_BASE_NAME) - 84))(player, tagList, (struct Library *) REALTIME_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define GetPlayerAttrs(player, tags...) \
	({ULONG _tags[] = {tags}; GetPlayerAttrsA((player), (Tag) _tags);})
#endif

#endif /*  _INLINE_REALTIME_H  */
