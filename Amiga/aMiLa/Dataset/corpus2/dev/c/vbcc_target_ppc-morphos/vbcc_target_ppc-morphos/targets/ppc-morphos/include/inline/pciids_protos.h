#ifndef _VBCCINLINE_PCIIDS_H
#define _VBCCINLINE_PCIIDS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

CONST_STRPTR __PCIIDS_GetVendorName(void *, ULONG vendorid) =
	"\tlwz\t0,-28(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PCIIDS_GetVendorName(vendorid) __PCIIDS_GetVendorName(PCIIDSBase, (vendorid))

CONST_STRPTR __PCIIDS_GetDeviceName(void *, ULONG vendorid, ULONG deviceid) =
	"\tlwz\t0,-34(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PCIIDS_GetDeviceName(vendorid, deviceid) __PCIIDS_GetDeviceName(PCIIDSBase, (vendorid), (deviceid))

CONST_STRPTR __PCIIDS_GetSubDeviceName(void *, ULONG vendorid, ULONG deviceid, ULONG subvendorid, ULONG subdeviceid) =
	"\tlwz\t0,-40(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PCIIDS_GetSubDeviceName(vendorid, deviceid, subvendorid, subdeviceid) __PCIIDS_GetSubDeviceName(PCIIDSBase, (vendorid), (deviceid), (subvendorid), (subdeviceid))

CONST_STRPTR __PCIIDS_GetClassName(void *, ULONG classid) =
	"\tlwz\t0,-46(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PCIIDS_GetClassName(classid) __PCIIDS_GetClassName(PCIIDSBase, (classid))

CONST_STRPTR __PCIIDS_GetSubClassName(void *, ULONG classid, ULONG subclassid) =
	"\tlwz\t0,-52(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PCIIDS_GetSubClassName(classid, subclassid) __PCIIDS_GetSubClassName(PCIIDSBase, (classid), (subclassid))

CONST_STRPTR __PCIIDS_GetProgIfName(void *, ULONG classid, ULONG subclassid, ULONG progifid) =
	"\tlwz\t0,-58(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PCIIDS_GetProgIfName(classid, subclassid, progifid) __PCIIDS_GetProgIfName(PCIIDSBase, (classid), (subclassid), (progifid))

LONG __PCIIDS_LoadFile(void *, CONST_STRPTR filename) =
	"\tlwz\t0,-64(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PCIIDS_LoadFile(filename) __PCIIDS_LoadFile(PCIIDSBase, (filename))

#endif /*  _VBCCINLINE_PCIIDS_H  */
