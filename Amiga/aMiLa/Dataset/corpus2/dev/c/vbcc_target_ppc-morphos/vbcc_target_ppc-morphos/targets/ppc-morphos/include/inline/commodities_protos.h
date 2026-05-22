#ifndef _VBCCINLINE_COMMODITIES_H
#define _VBCCINLINE_COMMODITIES_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

CxObj * __CreateCxObj(void *, ULONG type, LONG arg1, LONG arg2) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define CreateCxObj(type, arg1, arg2) __CreateCxObj(CxBase, (type), (arg1), (arg2))

CxObj * __CxBroker(void *, CONST struct NewBroker * nb, LONG * error) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define CxBroker(nb, error) __CxBroker(CxBase, (nb), (error))

LONG __ActivateCxObj(void *, CxObj * co, LONG doIt) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define ActivateCxObj(co, doIt) __ActivateCxObj(CxBase, (co), (doIt))

VOID __DeleteCxObj(void *, CxObj * co) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define DeleteCxObj(co) __DeleteCxObj(CxBase, (co))

VOID __DeleteCxObjAll(void *, CxObj * co) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define DeleteCxObjAll(co) __DeleteCxObjAll(CxBase, (co))

ULONG __CxObjType(void *, CONST CxObj * co) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define CxObjType(co) __CxObjType(CxBase, (co))

LONG __CxObjError(void *, CONST CxObj * co) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define CxObjError(co) __CxObjError(CxBase, (co))

VOID __ClearCxObjError(void *, CxObj * co) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define ClearCxObjError(co) __ClearCxObjError(CxBase, (co))

LONG __SetCxObjPri(void *, CxObj * co, LONG pri) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define SetCxObjPri(co, pri) __SetCxObjPri(CxBase, (co), (pri))

VOID __AttachCxObj(void *, CxObj * headObj, CxObj * co) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define AttachCxObj(headObj, co) __AttachCxObj(CxBase, (headObj), (co))

VOID __EnqueueCxObj(void *, CxObj * headObj, CxObj * co) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define EnqueueCxObj(headObj, co) __EnqueueCxObj(CxBase, (headObj), (co))

VOID __InsertCxObj(void *, CxObj * headObj, CxObj * co, CxObj * pred) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define InsertCxObj(headObj, co, pred) __InsertCxObj(CxBase, (headObj), (co), (pred))

VOID __RemoveCxObj(void *, CxObj * co) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define RemoveCxObj(co) __RemoveCxObj(CxBase, (co))

VOID __SetTranslate(void *, CxObj * translator, struct InputEvent * events) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define SetTranslate(translator, events) __SetTranslate(CxBase, (translator), (events))

VOID __SetFilter(void *, CxObj * filter, CONST_STRPTR text) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define SetFilter(filter, text) __SetFilter(CxBase, (filter), (text))

VOID __SetFilterIX(void *, CxObj * filter, CONST IX * ix) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define SetFilterIX(filter, ix) __SetFilterIX(CxBase, (filter), (ix))

LONG __ParseIX(void *, CONST_STRPTR description, IX * ix) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define ParseIX(description, ix) __ParseIX(CxBase, (description), (ix))

ULONG __CxMsgType(void *, CONST CxMsg * cxm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define CxMsgType(cxm) __CxMsgType(CxBase, (cxm))

APTR __CxMsgData(void *, CONST CxMsg * cxm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define CxMsgData(cxm) __CxMsgData(CxBase, (cxm))

LONG __CxMsgID(void *, CONST CxMsg * cxm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define CxMsgID(cxm) __CxMsgID(CxBase, (cxm))

VOID __DivertCxMsg(void *, CxMsg * cxm, CxObj * headObj, CxObj * returnObj) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define DivertCxMsg(cxm, headObj, returnObj) __DivertCxMsg(CxBase, (cxm), (headObj), (returnObj))

VOID __RouteCxMsg(void *, CxMsg * cxm, CxObj * co) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define RouteCxMsg(cxm, co) __RouteCxMsg(CxBase, (cxm), (co))

VOID __DisposeCxMsg(void *, CxMsg * cxm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-168\n"
	"\tbctrl";
#define DisposeCxMsg(cxm) __DisposeCxMsg(CxBase, (cxm))

BOOL __InvertKeyMap(void *, ULONG ansiCode, struct InputEvent * event, CONST struct KeyMap * km) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-174\n"
	"\tbctrl";
#define InvertKeyMap(ansiCode, event, km) __InvertKeyMap(CxBase, (ansiCode), (event), (km))

VOID __AddIEvents(void *, struct InputEvent * events) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-180\n"
	"\tbctrl";
#define AddIEvents(events) __AddIEvents(CxBase, (events))

BOOL __MatchIX(void *, CONST struct InputEvent * event, CONST IX * ix) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-204\n"
	"\tbctrl";
#define MatchIX(event, ix) __MatchIX(CxBase, (event), (ix))

#endif /*  _VBCCINLINE_COMMODITIES_H  */
