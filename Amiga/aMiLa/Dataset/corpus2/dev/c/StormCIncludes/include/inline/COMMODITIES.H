#ifndef _INLINE_COMMODITIES_H
#define _INLINE_COMMODITIES_H

#ifndef COMMODITIES_BASE_NAME
#define COMMODITIES_BASE_NAME CxBase
#endif

#define CreateCxObj(type, arg1, arg2) \
	((CxObj * (*)(ULONG __asm("d0"), LONG __asm("a0"), LONG __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) COMMODITIES_BASE_NAME) - 30))(type, arg1, arg2, (struct Library *) COMMODITIES_BASE_NAME)

#define CxBroker(nb, error) \
	((CxObj * (*)(CONST struct NewBroker * __asm("a0"), LONG * __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) COMMODITIES_BASE_NAME) - 36))(nb, error, (struct Library *) COMMODITIES_BASE_NAME)

#define ActivateCxObj(co, true) \
	((LONG (*)(CxObj * __asm("a0"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) COMMODITIES_BASE_NAME) - 42))(co, true, (struct Library *) COMMODITIES_BASE_NAME)

#define DeleteCxObj(co) \
	((VOID (*)(CxObj * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) COMMODITIES_BASE_NAME) - 48))(co, (struct Library *) COMMODITIES_BASE_NAME)

#define DeleteCxObjAll(co) \
	((VOID (*)(CxObj * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) COMMODITIES_BASE_NAME) - 54))(co, (struct Library *) COMMODITIES_BASE_NAME)

#define CxObjType(co) \
	((ULONG (*)(CONST CxObj * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) COMMODITIES_BASE_NAME) - 60))(co, (struct Library *) COMMODITIES_BASE_NAME)

#define CxObjError(co) \
	((LONG (*)(CONST CxObj * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) COMMODITIES_BASE_NAME) - 66))(co, (struct Library *) COMMODITIES_BASE_NAME)

#define ClearCxObjError(co) \
	((VOID (*)(CxObj * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) COMMODITIES_BASE_NAME) - 72))(co, (struct Library *) COMMODITIES_BASE_NAME)

#define SetCxObjPri(co, pri) \
	((LONG (*)(CxObj * __asm("a0"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) COMMODITIES_BASE_NAME) - 78))(co, pri, (struct Library *) COMMODITIES_BASE_NAME)

#define AttachCxObj(headObj, co) \
	((VOID (*)(CxObj * __asm("a0"), CxObj * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) COMMODITIES_BASE_NAME) - 84))(headObj, co, (struct Library *) COMMODITIES_BASE_NAME)

#define EnqueueCxObj(headObj, co) \
	((VOID (*)(CxObj * __asm("a0"), CxObj * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) COMMODITIES_BASE_NAME) - 90))(headObj, co, (struct Library *) COMMODITIES_BASE_NAME)

#define InsertCxObj(headObj, co, pred) \
	((VOID (*)(CxObj * __asm("a0"), CxObj * __asm("a1"), CxObj * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) COMMODITIES_BASE_NAME) - 96))(headObj, co, pred, (struct Library *) COMMODITIES_BASE_NAME)

#define RemoveCxObj(co) \
	((VOID (*)(CxObj * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) COMMODITIES_BASE_NAME) - 102))(co, (struct Library *) COMMODITIES_BASE_NAME)

#define SetTranslate(translator, events) \
	((VOID (*)(CxObj * __asm("a0"), struct InputEvent * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) COMMODITIES_BASE_NAME) - 114))(translator, events, (struct Library *) COMMODITIES_BASE_NAME)

#define SetFilter(filter, text) \
	((VOID (*)(CxObj * __asm("a0"), CONST_STRPTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) COMMODITIES_BASE_NAME) - 120))(filter, text, (struct Library *) COMMODITIES_BASE_NAME)

#define SetFilterIX(filter, ix) \
	((VOID (*)(CxObj * __asm("a0"), CONST IX * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) COMMODITIES_BASE_NAME) - 126))(filter, ix, (struct Library *) COMMODITIES_BASE_NAME)

#define ParseIX(description, ix) \
	((LONG (*)(CONST_STRPTR __asm("a0"), IX * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) COMMODITIES_BASE_NAME) - 132))(description, ix, (struct Library *) COMMODITIES_BASE_NAME)

#define CxMsgType(cxm) \
	((ULONG (*)(CONST CxMsg * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) COMMODITIES_BASE_NAME) - 138))(cxm, (struct Library *) COMMODITIES_BASE_NAME)

#define CxMsgData(cxm) \
	((APTR (*)(CONST CxMsg * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) COMMODITIES_BASE_NAME) - 144))(cxm, (struct Library *) COMMODITIES_BASE_NAME)

#define CxMsgID(cxm) \
	((LONG (*)(CONST CxMsg * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) COMMODITIES_BASE_NAME) - 150))(cxm, (struct Library *) COMMODITIES_BASE_NAME)

#define DivertCxMsg(cxm, headObj, returnObj) \
	((VOID (*)(CxMsg * __asm("a0"), CxObj * __asm("a1"), CxObj * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) COMMODITIES_BASE_NAME) - 156))(cxm, headObj, returnObj, (struct Library *) COMMODITIES_BASE_NAME)

#define RouteCxMsg(cxm, co) \
	((VOID (*)(CxMsg * __asm("a0"), CxObj * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) COMMODITIES_BASE_NAME) - 162))(cxm, co, (struct Library *) COMMODITIES_BASE_NAME)

#define DisposeCxMsg(cxm) \
	((VOID (*)(CxMsg * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) COMMODITIES_BASE_NAME) - 168))(cxm, (struct Library *) COMMODITIES_BASE_NAME)

#define InvertKeyMap(ansiCode, event, km) \
	((BOOL (*)(ULONG __asm("d0"), struct InputEvent * __asm("a0"), CONST struct KeyMap * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) COMMODITIES_BASE_NAME) - 174))(ansiCode, event, km, (struct Library *) COMMODITIES_BASE_NAME)

#define AddIEvents(events) \
	((VOID (*)(struct InputEvent * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) COMMODITIES_BASE_NAME) - 180))(events, (struct Library *) COMMODITIES_BASE_NAME)

#define MatchIX(event, ix) \
	((BOOL (*)(CONST struct InputEvent * __asm("a0"), CONST IX * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) COMMODITIES_BASE_NAME) - 204))(event, ix, (struct Library *) COMMODITIES_BASE_NAME)

#endif /*  _INLINE_COMMODITIES_H  */
