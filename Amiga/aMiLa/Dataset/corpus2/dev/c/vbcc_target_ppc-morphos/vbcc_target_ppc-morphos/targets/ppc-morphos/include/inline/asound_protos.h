#ifndef _VBCCINLINE_ASOUND_H
#define _VBCCINLINE_ASOUND_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

APTR __ASound_Create(ULONG mode, struct TagItem * tags) =
	"\tlis\t11,ASoundBase@ha\n"
	"\tlwz\t12,ASoundBase@l(11)\n"
	"\tlwz\t0,-28(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ASound_Create(mode, tags) __ASound_Create((mode), (tags))

APTR __ASound_CreateTags(ULONG mode, ...) =
	"\tlis\t11,ASoundBase@ha\n"
	"\tlwz\t12,ASoundBase@l(11)\n"
	"\tlwz\t0,-28(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ASound_CreateTags(mode, ...) __ASound_CreateTags((mode), __VA_ARGS__)

void __ASound_Delete(APTR ctx) =
	"\tlis\t11,ASoundBase@ha\n"
	"\tlwz\t12,ASoundBase@l(11)\n"
	"\tlwz\t0,-34(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ASound_Delete(ctx) __ASound_Delete((ctx))

ULONG __ASound_PlaySync(APTR ctx, APTR buf, ULONG len) =
	"\tlis\t11,ASoundBase@ha\n"
	"\tlwz\t12,ASoundBase@l(11)\n"
	"\tlwz\t0,-40(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ASound_PlaySync(ctx, buf, len) __ASound_PlaySync((ctx), (buf), (len))

ULONG __ASound_PlayAsync(APTR ctx, APTR buf, ULONG len) =
	"\tlis\t11,ASoundBase@ha\n"
	"\tlwz\t12,ASoundBase@l(11)\n"
	"\tlwz\t0,-46(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ASound_PlayAsync(ctx, buf, len) __ASound_PlayAsync((ctx), (buf), (len))

ULONG __ASound_Wait(APTR ctx) =
	"\tlis\t11,ASoundBase@ha\n"
	"\tlwz\t12,ASoundBase@l(11)\n"
	"\tlwz\t0,-52(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ASound_Wait(ctx) __ASound_Wait((ctx))

void __ASound_Abort(APTR ctx) =
	"\tlis\t11,ASoundBase@ha\n"
	"\tlwz\t12,ASoundBase@l(11)\n"
	"\tlwz\t0,-58(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ASound_Abort(ctx) __ASound_Abort((ctx))

APTR __ASound_GetAttr(APTR ctx, ULONG attr) =
	"\tlis\t11,ASoundBase@ha\n"
	"\tlwz\t12,ASoundBase@l(11)\n"
	"\tlwz\t0,-64(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ASound_GetAttr(ctx, attr) __ASound_GetAttr((ctx), (attr))

#endif /*  _VBCCINLINE_ASOUND_H  */
