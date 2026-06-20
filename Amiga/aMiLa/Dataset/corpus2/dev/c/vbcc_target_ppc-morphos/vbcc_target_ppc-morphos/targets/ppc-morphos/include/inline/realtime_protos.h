#ifndef _VBCCINLINE_REALTIME_H
#define _VBCCINLINE_REALTIME_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

APTR __LockRealTime(void *, ULONG lockType) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define LockRealTime(lockType) __LockRealTime(RealTimeBase, (lockType))

VOID __UnlockRealTime(void *, APTR lock) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define UnlockRealTime(lock) __UnlockRealTime(RealTimeBase, (lock))

struct Player * __CreatePlayerA(void *, CONST struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define CreatePlayerA(tagList) __CreatePlayerA(RealTimeBase, (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct Player * __linearvarargs __CreatePlayer(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define CreatePlayer(...) __CreatePlayer(RealTimeBase, __VA_ARGS__)
#endif

VOID __DeletePlayer(void *, struct Player * player) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define DeletePlayer(player) __DeletePlayer(RealTimeBase, (player))

BOOL __SetPlayerAttrsA(void *, struct Player * player, CONST struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define SetPlayerAttrsA(player, tagList) __SetPlayerAttrsA(RealTimeBase, (player), (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __SetPlayerAttrs(void *, struct Player * player, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define SetPlayerAttrs(player, ...) __SetPlayerAttrs(RealTimeBase, (player), __VA_ARGS__)
#endif

LONG __SetConductorState(void *, struct Player * player, ULONG state, LONG time) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define SetConductorState(player, state, time) __SetConductorState(RealTimeBase, (player), (state), (time))

BOOL __ExternalSync(void *, struct Player * player, LONG minTime, LONG maxTime) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define ExternalSync(player, minTime, maxTime) __ExternalSync(RealTimeBase, (player), (minTime), (maxTime))

struct Conductor * __NextConductor(void *, CONST struct Conductor * previousConductor) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define NextConductor(previousConductor) __NextConductor(RealTimeBase, (previousConductor))

struct Conductor * __FindConductor(void *, CONST_STRPTR name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define FindConductor(name) __FindConductor(RealTimeBase, (name))

ULONG __GetPlayerAttrsA(void *, CONST struct Player * player, CONST struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define GetPlayerAttrsA(player, tagList) __GetPlayerAttrsA(RealTimeBase, (player), (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __GetPlayerAttrs(void *, CONST struct Player * player, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define GetPlayerAttrs(player, ...) __GetPlayerAttrs(RealTimeBase, (player), __VA_ARGS__)
#endif

#endif /*  _VBCCINLINE_REALTIME_H  */
