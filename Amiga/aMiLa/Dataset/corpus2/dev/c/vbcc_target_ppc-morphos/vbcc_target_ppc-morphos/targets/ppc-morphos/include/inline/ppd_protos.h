#ifndef _VBCCINLINE_PPD_H
#define _VBCCINLINE_PPD_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

PPD * __OpenPPDFromPPD(void *, STRPTR Arg1, PPD_ERROR * Arg2) =
	"\tlwz\t0,-28(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define OpenPPDFromPPD(Arg1, Arg2) __OpenPPDFromPPD(PPDBase, (Arg1), (Arg2))

PPD * __OpenPPDFromIFF(void *, STRPTR Arg1, PPD_ERROR * Arg2) =
	"\tlwz\t0,-34(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define OpenPPDFromIFF(Arg1, Arg2) __OpenPPDFromIFF(PPDBase, (Arg1), (Arg2))

PPD_ERROR __PPDWritePPDToIFF(void *, STRPTR Arg1, PPD * Arg2) =
	"\tlwz\t0,-40(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PPDWritePPDToIFF(Arg1, Arg2) __PPDWritePPDToIFF(PPDBase, (Arg1), (Arg2))

OPTION_NODE * __FindPPD_Option(void *, PPD * Arg1, STRPTR Arg2) =
	"\tlwz\t0,-46(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FindPPD_Option(Arg1, Arg2) __FindPPD_Option(PPDBase, (Arg1), (Arg2))

PAGE_SIZE_NODE * __FindPPD_PageSize(void *, PPD * Arg1, STRPTR Arg2) =
	"\tlwz\t0,-52(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FindPPD_PageSize(Arg1, Arg2) __FindPPD_PageSize(PPDBase, (Arg1), (Arg2))

void __ClosePPD(void *, PPD * Arg1) =
	"\tlwz\t0,-58(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ClosePPD(Arg1) __ClosePPD(PPDBase, (Arg1))

OPTION_ITEM_NODE * __FindPPD_OptionItem(void *, OPTION_NODE * Arg1, STRPTR Arg2) =
	"\tlwz\t0,-64(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FindPPD_OptionItem(Arg1, Arg2) __FindPPD_OptionItem(PPDBase, (Arg1), (Arg2))

ATTRIBUTE_NODE * __FindPPD_Attribute(void *, PPD * Arg1, STRPTR Arg2, STRPTR Arg3) =
	"\tlwz\t0,-70(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FindPPD_Attribute(Arg1, Arg2, Arg3) __FindPPD_Attribute(PPDBase, (Arg1), (Arg2), (Arg3))

PPD * __OpenPPD(void *, STRPTR Arg1, PPD_ERROR * Arg2) =
	"\tlwz\t0,-76(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define OpenPPD(Arg1, Arg2) __OpenPPD(PPDBase, (Arg1), (Arg2))

CUSTOM_OPTION_NODE * __FindPPD_CustomOption(void *, PPD * Arg1, STRPTR Arg2) =
	"\tlwz\t0,-82(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FindPPD_CustomOption(Arg1, Arg2) __FindPPD_CustomOption(PPDBase, (Arg1), (Arg2))

CUSTOM_ITEM_NODE * __FindPPD_CustomOptionItem(void *, CUSTOM_OPTION_NODE * Arg1, STRPTR Arg2) =
	"\tlwz\t0,-88(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FindPPD_CustomOptionItem(Arg1, Arg2) __FindPPD_CustomOptionItem(PPDBase, (Arg1), (Arg2))

#endif /*  _VBCCINLINE_PPD_H  */
