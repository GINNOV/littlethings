#ifndef _VBCCINLINE_THUMBNAILS_H
#define _VBCCINLINE_THUMBNAILS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

APTR __ThbGenerateThumbnailA(CONST_STRPTR arg1, struct TagItem * arg2) =
	"\tlis\t11,ThumbnailsBase@ha\n"
	"\tlwz\t12,ThumbnailsBase@l(11)\n"
	"\tlwz\t0,-28(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ThbGenerateThumbnailA(arg1, arg2) __ThbGenerateThumbnailA((arg1), (arg2))

VOID __ThbDeleteThumbnail(APTR arg1) =
	"\tlis\t11,ThumbnailsBase@ha\n"
	"\tlwz\t12,ThumbnailsBase@l(11)\n"
	"\tlwz\t0,-34(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ThbDeleteThumbnail(arg1) __ThbDeleteThumbnail((arg1))

ULONG __ThbGetAttrsA(APTR arg1, struct TagItem * arg2) =
	"\tlis\t11,ThumbnailsBase@ha\n"
	"\tlwz\t12,ThumbnailsBase@l(11)\n"
	"\tlwz\t0,-40(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ThbGetAttrsA(arg1, arg2) __ThbGetAttrsA((arg1), (arg2))

ULONG __ThbNextFrame(APTR arg1) =
	"\tlis\t11,ThumbnailsBase@ha\n"
	"\tlwz\t12,ThumbnailsBase@l(11)\n"
	"\tlwz\t0,-46(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ThbNextFrame(arg1) __ThbNextFrame((arg1))

#endif /*  _VBCCINLINE_THUMBNAILS_H  */
