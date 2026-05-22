#ifndef _VBCCINLINE_GTLAYOUT_H
#define _VBCCINLINE_GTLAYOUT_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

VOID __LT_LevelWidth(void *, struct LayoutHandle * handle, STRPTR levelFormat, APTR dispFunc, LONG min, LONG max, LONG * maxWidth, LONG * maxLen, LONG fullCheck) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,0(2)\n"
	"\tstw\t8,4(2)\n"
	"\tstw\t9,44(2)\n"
	"\tstw\t10,52(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,8(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define LT_LevelWidth(handle, levelFormat, dispFunc, min, max, maxWidth, maxLen, fullCheck) __LT_LevelWidth(GTLayoutBase, (handle), (levelFormat), (dispFunc), (min), (max), (maxWidth), (maxLen), (fullCheck))

VOID __LT_DeleteHandle(void *, struct LayoutHandle * handle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define LT_DeleteHandle(handle) __LT_DeleteHandle(GTLayoutBase, (handle))

struct LayoutHandle * __LT_CreateHandle(void *, struct Screen * screen, struct TextAttr * font) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define LT_CreateHandle(screen, font) __LT_CreateHandle(GTLayoutBase, (screen), (font))

struct LayoutHandle * __LT_CreateHandleTagList(void *, struct Screen * screen, struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define LT_CreateHandleTagList(screen, tagList) __LT_CreateHandleTagList(GTLayoutBase, (screen), (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct LayoutHandle * __linearvarargs __LT_CreateHandleTags(void *, struct Screen * screen, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define LT_CreateHandleTags(...) __LT_CreateHandleTags(GTLayoutBase, __VA_ARGS__)
#endif

BOOL __LT_Rebuild(void *, struct LayoutHandle * handle, struct IBox * bounds, LONG extraWidth, LONG extraHeight, LONG clear) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,0(2)\n"
	"\tstw\t8,4(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define LT_Rebuild(handle, bounds, extraWidth, extraHeight, clear) __LT_Rebuild(GTLayoutBase, (handle), (bounds), (extraWidth), (extraHeight), (clear))

VOID __LT_HandleInput(void *, struct LayoutHandle * handle, ULONG msgQualifier, ULONG * msgClass, UWORD * msgCode, struct Gadget ** msgGadget) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tstw\t7,40(2)\n"
	"\tstw\t8,44(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define LT_HandleInput(handle, msgQualifier, msgClass, msgCode, msgGadget) __LT_HandleInput(GTLayoutBase, (handle), (msgQualifier), (msgClass), (msgCode), (msgGadget))

VOID __LT_BeginRefresh(void *, struct LayoutHandle * handle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define LT_BeginRefresh(handle) __LT_BeginRefresh(GTLayoutBase, (handle))

VOID __LT_EndRefresh(void *, struct LayoutHandle * handle, LONG complete) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define LT_EndRefresh(handle, complete) __LT_EndRefresh(GTLayoutBase, (handle), (complete))

LONG __LT_GetAttributesA(void *, struct LayoutHandle * handle, LONG id, struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define LT_GetAttributesA(handle, id, tagList) __LT_GetAttributesA(GTLayoutBase, (handle), (id), (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __LT_GetAttributes(void *, struct LayoutHandle * handle, LONG id, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define LT_GetAttributes(handle, ...) __LT_GetAttributes(GTLayoutBase, (handle), __VA_ARGS__)
#endif

VOID __LT_SetAttributesA(void *, struct LayoutHandle * handle, LONG id, struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define LT_SetAttributesA(handle, id, tagList) __LT_SetAttributesA(GTLayoutBase, (handle), (id), (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
VOID __linearvarargs __LT_SetAttributes(void *, struct LayoutHandle * handle, LONG id, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define LT_SetAttributes(handle, ...) __LT_SetAttributes(GTLayoutBase, (handle), __VA_ARGS__)
#endif

VOID __LT_AddA(void *, struct LayoutHandle * handle, LONG type, STRPTR label, LONG id, struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,36(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define LT_AddA(handle, type, label, id, tagList) __LT_AddA(GTLayoutBase, (handle), (type), (label), (id), (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
VOID __linearvarargs __LT_Add(void *, struct LayoutHandle * handle, LONG type, STRPTR label, LONG id, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define LT_Add(handle, type, label, ...) __LT_Add(GTLayoutBase, (handle), (type), (label), __VA_ARGS__)
#endif

VOID __LT_NewA(void *, struct LayoutHandle * handle, struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define LT_NewA(handle, tagList) __LT_NewA(GTLayoutBase, (handle), (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
VOID __linearvarargs __LT_New(void *, struct LayoutHandle * handle, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define LT_New(...) __LT_New(GTLayoutBase, __VA_ARGS__)
#endif

VOID __LT_EndGroup(void *, struct LayoutHandle * handle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define LT_EndGroup(handle) __LT_EndGroup(GTLayoutBase, (handle))

struct Window * __LT_LayoutA(void *, struct LayoutHandle * handle, STRPTR title, struct IBox * bounds, LONG extraWidth, LONG extraHeight, ULONG idcmp, LONG align, struct TagItem * tagParams) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,0(2)\n"
	"\tstw\t8,4(2)\n"
	"\tstw\t9,8(2)\n"
	"\tstw\t10,12(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,44(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define LT_LayoutA(handle, title, bounds, extraWidth, extraHeight, idcmp, align, tagParams) __LT_LayoutA(GTLayoutBase, (handle), (title), (bounds), (extraWidth), (extraHeight), (idcmp), (align), (tagParams))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct Window * __linearvarargs __LT_Layout(void *, struct LayoutHandle * handle, STRPTR title, struct IBox * bounds, LONG extraWidth, LONG extraHeight, ULONG idcmp, LONG align, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,0(2)\n"
	"\tstw\t8,4(2)\n"
	"\tstw\t9,8(2)\n"
	"\tstw\t10,12(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,44(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define LT_Layout(handle, title, bounds, extraWidth, extraHeight, idcmp, ...) __LT_Layout(GTLayoutBase, (handle), (title), (bounds), (extraWidth), (extraHeight), (idcmp), __VA_ARGS__)
#endif

struct Menu * __LT_LayoutMenusA(void *, struct LayoutHandle * handle, struct NewMenu * menuTemplate, struct TagItem * tagParams) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define LT_LayoutMenusA(handle, menuTemplate, tagParams) __LT_LayoutMenusA(GTLayoutBase, (handle), (menuTemplate), (tagParams))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct Menu * __linearvarargs __LT_LayoutMenus(void *, struct LayoutHandle * handle, struct NewMenu * menuTemplate, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define LT_LayoutMenus(handle, ...) __LT_LayoutMenus(GTLayoutBase, (handle), __VA_ARGS__)
#endif

LONG __LT_LabelWidth(void *, struct LayoutHandle * handle, STRPTR label) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define LT_LabelWidth(handle, label) __LT_LabelWidth(GTLayoutBase, (handle), (label))

LONG __LT_LabelChars(void *, struct LayoutHandle * handle, STRPTR label) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define LT_LabelChars(handle, label) __LT_LabelChars(GTLayoutBase, (handle), (label))

VOID __LT_LockWindow(void *, struct Window * window) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define LT_LockWindow(window) __LT_LockWindow(GTLayoutBase, (window))

VOID __LT_UnlockWindow(void *, struct Window * window) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define LT_UnlockWindow(window) __LT_UnlockWindow(GTLayoutBase, (window))

VOID __LT_DeleteWindowLock(void *, struct Window * window) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define LT_DeleteWindowLock(window) __LT_DeleteWindowLock(GTLayoutBase, (window))

VOID __LT_ShowWindow(void *, struct LayoutHandle * handle, LONG activate) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-168\n"
	"\tbctrl";
#define LT_ShowWindow(handle, activate) __LT_ShowWindow(GTLayoutBase, (handle), (activate))

VOID __LT_Activate(void *, struct LayoutHandle * handle, LONG id) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-174\n"
	"\tbctrl";
#define LT_Activate(handle, id) __LT_Activate(GTLayoutBase, (handle), (id))

BOOL __LT_PressButton(void *, struct LayoutHandle * handle, LONG id) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-180\n"
	"\tbctrl";
#define LT_PressButton(handle, id) __LT_PressButton(GTLayoutBase, (handle), (id))

LONG __LT_GetCode(void *, ULONG msgQualifier, ULONG msgClass, ULONG msgCode, struct Gadget * msgGadget) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tstw\t7,32(2)\n"
	"\tli\t3,-186\n"
	"\tbctrl";
#define LT_GetCode(msgQualifier, msgClass, msgCode, msgGadget) __LT_GetCode(GTLayoutBase, (msgQualifier), (msgClass), (msgCode), (msgGadget))

struct IntuiMessage * __LT_GetIMsg(void *, struct LayoutHandle * handle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-192\n"
	"\tbctrl";
#define LT_GetIMsg(handle) __LT_GetIMsg(GTLayoutBase, (handle))

VOID __LT_ReplyIMsg(void *, struct IntuiMessage * msg) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-198\n"
	"\tbctrl";
#define LT_ReplyIMsg(msg) __LT_ReplyIMsg(GTLayoutBase, (msg))

struct Window * __LT_BuildA(void *, struct LayoutHandle * handle, struct TagItem * tagParams) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-204\n"
	"\tbctrl";
#define LT_BuildA(handle, tagParams) __LT_BuildA(GTLayoutBase, (handle), (tagParams))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct Window * __linearvarargs __LT_Build(void *, struct LayoutHandle * handle, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-204\n"
	"\tbctrl";
#define LT_Build(...) __LT_Build(GTLayoutBase, __VA_ARGS__)
#endif

BOOL __LT_RebuildTagList(void *, struct LayoutHandle * handle, LONG clear, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-210\n"
	"\tbctrl";
#define LT_RebuildTagList(handle, clear, tags) __LT_RebuildTagList(GTLayoutBase, (handle), (clear), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __LT_RebuildTags(void *, struct LayoutHandle * handle, LONG clear, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-210\n"
	"\tbctrl";
#define LT_RebuildTags(handle, ...) __LT_RebuildTags(GTLayoutBase, (handle), __VA_ARGS__)
#endif

VOID __LT_UpdateStrings(void *, struct LayoutHandle * handle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-216\n"
	"\tbctrl";
#define LT_UpdateStrings(handle) __LT_UpdateStrings(GTLayoutBase, (handle))

VOID __LT_DisposeMenu(void *, struct Menu * menu) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-222\n"
	"\tbctrl";
#define LT_DisposeMenu(menu) __LT_DisposeMenu(GTLayoutBase, (menu))

struct Menu * __LT_NewMenuTemplate(void *, struct Screen * screen, struct TextAttr * textAttr, struct Image * amigaGlyph, struct Image * checkGlyph, LONG * error, struct NewMenu * menuTemplate) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tstw\t8,0(2)\n"
	"\tstw\t9,4(2)\n"
	"\tli\t3,-228\n"
	"\tbctrl";
#define LT_NewMenuTemplate(screen, textAttr, amigaGlyph, checkGlyph, error, menuTemplate) __LT_NewMenuTemplate(GTLayoutBase, (screen), (textAttr), (amigaGlyph), (checkGlyph), (error), (menuTemplate))

struct Menu * __LT_NewMenuTagList(void *, struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-234\n"
	"\tbctrl";
#define LT_NewMenuTagList(tagList) __LT_NewMenuTagList(GTLayoutBase, (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct Menu * __linearvarargs __LT_NewMenuTags(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-234\n"
	"\tbctrl";
#define LT_NewMenuTags(...) __LT_NewMenuTags(GTLayoutBase, __VA_ARGS__)
#endif

VOID __LT_MenuControlTagList(void *, struct Window * window, struct Menu * intuitionMenu, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-240\n"
	"\tbctrl";
#define LT_MenuControlTagList(window, intuitionMenu, tags) __LT_MenuControlTagList(GTLayoutBase, (window), (intuitionMenu), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
VOID __linearvarargs __LT_MenuControlTags(void *, struct Window * window, struct Menu * intuitionMenu, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-240\n"
	"\tbctrl";
#define LT_MenuControlTags(window, ...) __LT_MenuControlTags(GTLayoutBase, (window), __VA_ARGS__)
#endif

struct MenuItem * __LT_GetMenuItem(void *, struct Menu * menu, ULONG id) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-246\n"
	"\tbctrl";
#define LT_GetMenuItem(menu, id) __LT_GetMenuItem(GTLayoutBase, (menu), (id))

struct MenuItem * __LT_FindMenuCommand(void *, struct Menu * menu, ULONG msgCode, ULONG msgQualifier, struct Gadget * msgGadget) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tli\t3,-252\n"
	"\tbctrl";
#define LT_FindMenuCommand(menu, msgCode, msgQualifier, msgGadget) __LT_FindMenuCommand(GTLayoutBase, (menu), (msgCode), (msgQualifier), (msgGadget))

VOID __LT_NewLevelWidth(void *, struct LayoutHandle * handle, STRPTR levelFormat, APTR dispFunc, LONG min, LONG max, LONG * maxWidth, LONG * maxLen, LONG fullCheck) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,0(2)\n"
	"\tstw\t8,4(2)\n"
	"\tstw\t9,44(2)\n"
	"\tstw\t10,12(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,8(2)\n"
	"\tli\t3,-258\n"
	"\tbctrl";
#define LT_NewLevelWidth(handle, levelFormat, dispFunc, min, max, maxWidth, maxLen, fullCheck) __LT_NewLevelWidth(GTLayoutBase, (handle), (levelFormat), (dispFunc), (min), (max), (maxWidth), (maxLen), (fullCheck))

VOID __LT_Refresh(void *, struct LayoutHandle * handle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-264\n"
	"\tbctrl";
#define LT_Refresh(handle) __LT_Refresh(GTLayoutBase, (handle))

VOID __LT_CatchUpRefresh(void *, struct LayoutHandle * handle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-270\n"
	"\tbctrl";
#define LT_CatchUpRefresh(handle) __LT_CatchUpRefresh(GTLayoutBase, (handle))

APTR __LT_GetWindowUserData(void *, struct Window * window, APTR defaultValue) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-276\n"
	"\tbctrl";
#define LT_GetWindowUserData(window, defaultValue) __LT_GetWindowUserData(GTLayoutBase, (window), (defaultValue))

VOID __LT_Redraw(void *, struct LayoutHandle * handle, LONG id) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-282\n"
	"\tbctrl";
#define LT_Redraw(handle, id) __LT_Redraw(GTLayoutBase, (handle), (id))

#endif /*  _VBCCINLINE_GTLAYOUT_H  */
