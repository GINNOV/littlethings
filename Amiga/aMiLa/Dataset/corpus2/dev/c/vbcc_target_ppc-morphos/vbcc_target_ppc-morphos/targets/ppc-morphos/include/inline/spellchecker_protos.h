#ifndef _VBCCINLINE_SPELLCHECKER_H
#define _VBCCINLINE_SPELLCHECKER_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

APTR __OpenDictionary(void *, STRPTR Arg1, struct TagItem * Arg2) =
	"\tlwz\t0,-28(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define OpenDictionary(Arg1, Arg2) __OpenDictionary(SpellCheckerBase, (Arg1), (Arg2))

void __CloseDictionary(void *, APTR Arg1) =
	"\tlwz\t0,-34(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define CloseDictionary(Arg1) __CloseDictionary(SpellCheckerBase, (Arg1))

STRPTR* __Suggest(void *, APTR Arg1, STRPTR Arg2, struct TagItem * Arg3) =
	"\tlwz\t0,-40(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define Suggest(Arg1, Arg2, Arg3) __Suggest(SpellCheckerBase, (Arg1), (Arg2), (Arg3))

BOOL __Learn(void *, APTR Arg1, STRPTR Arg2) =
	"\tlwz\t0,-46(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define Learn(Arg1, Arg2) __Learn(SpellCheckerBase, (Arg1), (Arg2))

#endif /*  _VBCCINLINE_SPELLCHECKER_H  */
