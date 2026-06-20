#ifndef _VBCCINLINE_XPKMASTER_H
#define _VBCCINLINE_XPKMASTER_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

LONG __XpkExamine(void *, struct XpkFib * fib, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define XpkExamine(fib, tags) __XpkExamine(XpkBase, (fib), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __XpkExamineTags(void *, struct XpkFib * fib, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define XpkExamineTags(fib, ...) __XpkExamineTags(XpkBase, (fib), __VA_ARGS__)
#endif

LONG __XpkPack(void *, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define XpkPack(tags) __XpkPack(XpkBase, (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __XpkPackTags(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define XpkPackTags(...) __XpkPackTags(XpkBase, __VA_ARGS__)
#endif

LONG __XpkUnpack(void *, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define XpkUnpack(tags) __XpkUnpack(XpkBase, (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __XpkUnpackTags(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define XpkUnpackTags(...) __XpkUnpackTags(XpkBase, __VA_ARGS__)
#endif

LONG __XpkOpen(void *, struct XpkFib ** xbuf, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define XpkOpen(xbuf, tags) __XpkOpen(XpkBase, (xbuf), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __XpkOpenTags(void *, struct XpkFib ** xbuf, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define XpkOpenTags(xbuf, ...) __XpkOpenTags(XpkBase, (xbuf), __VA_ARGS__)
#endif

LONG __XpkRead(void *, struct XpkFib * xbuf, STRPTR buf, ULONG len) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define XpkRead(xbuf, buf, len) __XpkRead(XpkBase, (xbuf), (buf), (len))

LONG __XpkWrite(void *, struct XpkFib * xbuf, STRPTR buf, LONG len) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define XpkWrite(xbuf, buf, len) __XpkWrite(XpkBase, (xbuf), (buf), (len))

LONG __XpkSeek(void *, struct XpkFib * xbuf, LONG len, LONG mode) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define XpkSeek(xbuf, len, mode) __XpkSeek(XpkBase, (xbuf), (len), (mode))

LONG __XpkClose(void *, struct XpkFib * xbuf) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define XpkClose(xbuf) __XpkClose(XpkBase, (xbuf))

LONG __XpkQuery(void *, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define XpkQuery(tags) __XpkQuery(XpkBase, (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __XpkQueryTags(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define XpkQueryTags(...) __XpkQueryTags(XpkBase, __VA_ARGS__)
#endif

APTR __XpkAllocObject(void *, ULONG type, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define XpkAllocObject(type, tags) __XpkAllocObject(XpkBase, (type), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __XpkAllocObjectTags(void *, ULONG type, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define XpkAllocObjectTags(type, ...) __XpkAllocObjectTags(XpkBase, (type), __VA_ARGS__)
#endif

void __XpkFreeObject(void *, ULONG type, APTR object) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define XpkFreeObject(type, object) __XpkFreeObject(XpkBase, (type), (object))

BOOL __XpkPrintFault(void *, LONG code, STRPTR header) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define XpkPrintFault(code, header) __XpkPrintFault(XpkBase, (code), (header))

ULONG __XpkFault(void *, LONG code, STRPTR header, STRPTR buffer, ULONG size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\tstw\t7,4(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define XpkFault(code, header, buffer, size) __XpkFault(XpkBase, (code), (header), (buffer), (size))

LONG __XpkPassRequest(void *, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define XpkPassRequest(tags) __XpkPassRequest(XpkBase, (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __XpkPassRequestTags(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define XpkPassRequestTags(...) __XpkPassRequestTags(XpkBase, __VA_ARGS__)
#endif

#endif /*  _VBCCINLINE_XPKMASTER_H  */
