#ifndef _VBCCINLINE_ASL_H
#define _VBCCINLINE_ASL_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

struct FileRequester * __AllocFileRequest(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define AllocFileRequest() __AllocFileRequest(AslBase)

VOID __FreeFileRequest(void *, struct FileRequester * fileReq) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define FreeFileRequest(fileReq) __FreeFileRequest(AslBase, (fileReq))

BOOL __RequestFile(void *, struct FileRequester * fileReq) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define RequestFile(fileReq) __RequestFile(AslBase, (fileReq))

APTR __AllocAslRequest(void *, ULONG reqType, struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define AllocAslRequest(reqType, tagList) __AllocAslRequest(AslBase, (reqType), (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __AllocAslRequestTags(void *, ULONG reqType, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define AllocAslRequestTags(reqType, ...) __AllocAslRequestTags(AslBase, (reqType), __VA_ARGS__)
#endif

VOID __FreeAslRequest(void *, APTR requester) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define FreeAslRequest(requester) __FreeAslRequest(AslBase, (requester))

BOOL __AslRequest(void *, APTR requester, struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define AslRequest(requester, tagList) __AslRequest(AslBase, (requester), (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __AslRequestTags(void *, APTR requester, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define AslRequestTags(requester, ...) __AslRequestTags(AslBase, (requester), __VA_ARGS__)
#endif

VOID __AbortAslRequest(void *, APTR requester) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define AbortAslRequest(requester) __AbortAslRequest(AslBase, (requester))

VOID __ActivateAslRequest(void *, APTR requester) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define ActivateAslRequest(requester) __ActivateAslRequest(AslBase, (requester))

#endif /*  _VBCCINLINE_ASL_H  */
