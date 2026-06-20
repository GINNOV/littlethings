#ifndef _VBCCINLINE_OPENURL_H
#define _VBCCINLINE_OPENURL_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

ULONG __URL_OpenA(void *, STRPTR url, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define URL_OpenA(url, tags) __URL_OpenA(OpenURLBase, (url), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __URL_Open(void *, STRPTR url, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define URL_Open(url, ...) __URL_Open(OpenURLBase, (url), __VA_ARGS__)
#endif

struct URL_Prefs * __URL_GetPrefsA(void *, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define URL_GetPrefsA(tags) __URL_GetPrefsA(OpenURLBase, (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct URL_Prefs * __linearvarargs __URL_GetPrefs(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define URL_GetPrefs(...) __URL_GetPrefs(OpenURLBase, __VA_ARGS__)
#endif

void __URL_FreePrefsA(void *, struct URL_Prefs * prefs, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define URL_FreePrefsA(prefs, tags) __URL_FreePrefsA(OpenURLBase, (prefs), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void __linearvarargs __URL_FreePrefs(void *, struct URL_Prefs * prefs, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define URL_FreePrefs(prefs, ...) __URL_FreePrefs(OpenURLBase, (prefs), __VA_ARGS__)
#endif

ULONG __URL_SetPrefsA(void *, struct URL_Prefs * up, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define URL_SetPrefsA(up, tags) __URL_SetPrefsA(OpenURLBase, (up), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __URL_SetPrefs(void *, struct URL_Prefs * up, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define URL_SetPrefs(up, ...) __URL_SetPrefs(OpenURLBase, (up), __VA_ARGS__)
#endif

ULONG __URL_LaunchPrefsAppA(void *, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define URL_LaunchPrefsAppA(tags) __URL_LaunchPrefsAppA(OpenURLBase, (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __URL_LaunchPrefsApp(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define URL_LaunchPrefsApp(...) __URL_LaunchPrefsApp(OpenURLBase, __VA_ARGS__)
#endif

ULONG __URL_GetAttr(void *, ULONG attr, ULONG * storage) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define URL_GetAttr(attr, storage) __URL_GetAttr(OpenURLBase, (attr), (storage))

#endif /*  _VBCCINLINE_OPENURL_H  */
