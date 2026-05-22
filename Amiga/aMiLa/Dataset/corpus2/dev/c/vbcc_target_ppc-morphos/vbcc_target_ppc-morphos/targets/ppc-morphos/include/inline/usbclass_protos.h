#ifndef _VBCCINLINE_USBCLASS_H
#define _VBCCINLINE_USBCLASS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

APTR __usbAttemptInterfaceBinding(void *, APTR pif) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define usbAttemptInterfaceBinding(pif) __usbAttemptInterfaceBinding(UsbClsBase, (pif))

VOID __usbReleaseInterfaceBinding(void *, APTR uifb) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define usbReleaseInterfaceBinding(uifb) __usbReleaseInterfaceBinding(UsbClsBase, (uifb))

APTR __usbAttemptDeviceBinding(void *, APTR pd) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define usbAttemptDeviceBinding(pd) __usbAttemptDeviceBinding(UsbClsBase, (pd))

VOID __usbReleaseDeviceBinding(void *, APTR udb) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define usbReleaseDeviceBinding(udb) __usbReleaseDeviceBinding(UsbClsBase, (udb))

APTR __usbForceInterfaceBinding(void *, APTR pif) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define usbForceInterfaceBinding(pif) __usbForceInterfaceBinding(UsbClsBase, (pif))

APTR __usbForceDeviceBinding(void *, APTR pd) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define usbForceDeviceBinding(pd) __usbForceDeviceBinding(UsbClsBase, (pd))

LONG __usbGetAttrsA(void *, ULONG type, APTR usbstruct, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define usbGetAttrsA(type, usbstruct, taglist) __usbGetAttrsA(UsbClsBase, (type), (usbstruct), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __usbGetAttrs(void *, ULONG type, APTR usbstruct, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define usbGetAttrs(type, usbstruct, ...) __usbGetAttrs(UsbClsBase, (type), (usbstruct), __VA_ARGS__)
#endif

LONG __usbSetAttrsA(void *, ULONG type, APTR usbstruct, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define usbSetAttrsA(type, usbstruct, taglist) __usbSetAttrsA(UsbClsBase, (type), (usbstruct), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __usbSetAttrs(void *, ULONG type, APTR usbstruct, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define usbSetAttrs(type, usbstruct, ...) __usbSetAttrs(UsbClsBase, (type), (usbstruct), __VA_ARGS__)
#endif

LONG __usbDoMethodA(void *, ULONG methodid, APTR methoddata) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define usbDoMethodA(methodid, methoddata) __usbDoMethodA(UsbClsBase, (methodid), (methoddata))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __usbDoMethod(void *, ULONG methodid, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define usbDoMethod(...) __usbDoMethod(UsbClsBase, __VA_ARGS__)
#endif

#endif /*  _VBCCINLINE_USBCLASS_H  */
