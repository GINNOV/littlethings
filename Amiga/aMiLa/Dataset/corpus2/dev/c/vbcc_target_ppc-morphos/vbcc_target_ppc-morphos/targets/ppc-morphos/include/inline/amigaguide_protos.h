#ifndef _VBCCINLINE_AMIGAGUIDE_H
#define _VBCCINLINE_AMIGAGUIDE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

LONG __LockAmigaGuideBase(void *, APTR handle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define LockAmigaGuideBase(handle) __LockAmigaGuideBase(AmigaGuideBase, (handle))

VOID __UnlockAmigaGuideBase(void *, LONG key) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define UnlockAmigaGuideBase(key) __UnlockAmigaGuideBase(AmigaGuideBase, (key))

APTR __OpenAmigaGuideA(void *, struct NewAmigaGuide * nag, struct TagItem * attr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define OpenAmigaGuideA(nag, attr) __OpenAmigaGuideA(AmigaGuideBase, (nag), (attr))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __OpenAmigaGuide(void *, struct NewAmigaGuide * nag, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define OpenAmigaGuide(nag, ...) __OpenAmigaGuide(AmigaGuideBase, (nag), __VA_ARGS__)
#endif

APTR __OpenAmigaGuideAsyncA(void *, struct NewAmigaGuide * nag, struct TagItem * attrs) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define OpenAmigaGuideAsyncA(nag, attrs) __OpenAmigaGuideAsyncA(AmigaGuideBase, (nag), (attrs))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __OpenAmigaGuideAsync(void *, struct NewAmigaGuide * nag, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,0(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define OpenAmigaGuideAsync(nag, ...) __OpenAmigaGuideAsync(AmigaGuideBase, (nag), __VA_ARGS__)
#endif

VOID __CloseAmigaGuide(void *, APTR cl) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define CloseAmigaGuide(cl) __CloseAmigaGuide(AmigaGuideBase, (cl))

ULONG __AmigaGuideSignal(void *, APTR cl) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define AmigaGuideSignal(cl) __AmigaGuideSignal(AmigaGuideBase, (cl))

struct AmigaGuideMsg * __GetAmigaGuideMsg(void *, APTR cl) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define GetAmigaGuideMsg(cl) __GetAmigaGuideMsg(AmigaGuideBase, (cl))

VOID __ReplyAmigaGuideMsg(void *, struct AmigaGuideMsg * amsg) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define ReplyAmigaGuideMsg(amsg) __ReplyAmigaGuideMsg(AmigaGuideBase, (amsg))

LONG __SetAmigaGuideContextA(void *, APTR cl, ULONG id, struct TagItem * attrs) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define SetAmigaGuideContextA(cl, id, attrs) __SetAmigaGuideContextA(AmigaGuideBase, (cl), (id), (attrs))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __SetAmigaGuideContext(void *, APTR cl, ULONG id, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,4(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define SetAmigaGuideContext(cl, id, ...) __SetAmigaGuideContext(AmigaGuideBase, (cl), (id), __VA_ARGS__)
#endif

LONG __SendAmigaGuideContextA(void *, APTR cl, struct TagItem * attrs) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define SendAmigaGuideContextA(cl, attrs) __SendAmigaGuideContextA(AmigaGuideBase, (cl), (attrs))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __SendAmigaGuideContext(void *, APTR cl, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,0(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define SendAmigaGuideContext(cl, ...) __SendAmigaGuideContext(AmigaGuideBase, (cl), __VA_ARGS__)
#endif

LONG __SendAmigaGuideCmdA(void *, APTR cl, STRPTR cmd, struct TagItem * attrs) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define SendAmigaGuideCmdA(cl, cmd, attrs) __SendAmigaGuideCmdA(AmigaGuideBase, (cl), (cmd), (attrs))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __SendAmigaGuideCmd(void *, APTR cl, STRPTR cmd, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,4(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define SendAmigaGuideCmd(cl, cmd, ...) __SendAmigaGuideCmd(AmigaGuideBase, (cl), (cmd), __VA_ARGS__)
#endif

LONG __SetAmigaGuideAttrsA(void *, APTR cl, struct TagItem * attrs) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define SetAmigaGuideAttrsA(cl, attrs) __SetAmigaGuideAttrsA(AmigaGuideBase, (cl), (attrs))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __SetAmigaGuideAttrs(void *, APTR cl, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define SetAmigaGuideAttrs(cl, ...) __SetAmigaGuideAttrs(AmigaGuideBase, (cl), __VA_ARGS__)
#endif

LONG __GetAmigaGuideAttr(void *, Tag d0arg, APTR cl, ULONG * storage) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define GetAmigaGuideAttr(d0arg, cl, storage) __GetAmigaGuideAttr(AmigaGuideBase, (d0arg), (cl), (storage))

LONG __LoadXRef(void *, BPTR lock, STRPTR name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define LoadXRef(lock, name) __LoadXRef(AmigaGuideBase, (lock), (name))

VOID __ExpungeXRef(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define ExpungeXRef() __ExpungeXRef(AmigaGuideBase)

APTR __AddAmigaGuideHostA(void *, struct Hook * h, STRPTR name, struct TagItem * attrs) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define AddAmigaGuideHostA(h, name, attrs) __AddAmigaGuideHostA(AmigaGuideBase, (h), (name), (attrs))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __AddAmigaGuideHost(void *, struct Hook * h, STRPTR name, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define AddAmigaGuideHost(h, name, ...) __AddAmigaGuideHost(AmigaGuideBase, (h), (name), __VA_ARGS__)
#endif

LONG __RemoveAmigaGuideHostA(void *, APTR hh, struct TagItem * attrs) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define RemoveAmigaGuideHostA(hh, attrs) __RemoveAmigaGuideHostA(AmigaGuideBase, (hh), (attrs))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __RemoveAmigaGuideHost(void *, APTR hh, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define RemoveAmigaGuideHost(hh, ...) __RemoveAmigaGuideHost(AmigaGuideBase, (hh), __VA_ARGS__)
#endif

STRPTR __GetAmigaGuideString(void *, LONG id) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-210\n"
	"\tbctrl";
#define GetAmigaGuideString(id) __GetAmigaGuideString(AmigaGuideBase, (id))

VOID __AG_UpdateLink(CONST_STRPTR link, void *) =
	"\tlwz\t0,-220(4)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define AG_UpdateLink(link) __AG_UpdateLink((link), AmigaGuideBase)

BOOL __AG_LinkExists(CONST_STRPTR link, void *) =
	"\tlwz\t0,-226(4)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define AG_LinkExists(link) __AG_LinkExists((link), AmigaGuideBase)

#endif /*  _VBCCINLINE_AMIGAGUIDE_H  */
