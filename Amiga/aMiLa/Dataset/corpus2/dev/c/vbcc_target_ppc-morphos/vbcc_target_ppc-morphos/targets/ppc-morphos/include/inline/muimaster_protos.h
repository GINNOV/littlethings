#ifndef _VBCCINLINE_MUIMASTER_H
#define _VBCCINLINE_MUIMASTER_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

Boopsiobject * __MUI_NewObjectA(void *, char * a0arg, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define MUI_NewObjectA(a0arg, tags) __MUI_NewObjectA(MUIMasterBase, (a0arg), (tags))

VOID __MUI_DisposeObject(void *, Boopsiobject * obj) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define MUI_DisposeObject(obj) __MUI_DisposeObject(MUIMasterBase, (obj))

LONG __MUI_RequestA(void *, APTR app, APTR win, LONGBITS flags, char * title, char * gadgets, char * format, APTR params) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tstw\t7,32(2)\n"
	"\tstw\t8,36(2)\n"
	"\tstw\t9,40(2)\n"
	"\tstw\t10,44(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define MUI_RequestA(app, win, flags, title, gadgets, format, params) __MUI_RequestA(MUIMasterBase, (app), (win), (flags), (title), (gadgets), (format), (params))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __MUI_Request(void *, APTR app, APTR win, LONGBITS flags, char * title, char * gadgets, char * format, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tstw\t7,32(2)\n"
	"\tstw\t8,36(2)\n"
	"\tstw\t9,40(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,44(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define MUI_Request(app, win, flags, title, gadgets, ...) __MUI_Request(MUIMasterBase, (app), (win), (flags), (title), (gadgets), __VA_ARGS__)
#endif

APTR __MUI_AllocAslRequest(void *, unsigned long type, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define MUI_AllocAslRequest(type, tags) __MUI_AllocAslRequest(MUIMasterBase, (type), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __MUI_AllocAslRequestTags(void *, unsigned long type, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define MUI_AllocAslRequestTags(type, ...) __MUI_AllocAslRequestTags(MUIMasterBase, (type), __VA_ARGS__)
#endif

BOOL __MUI_AslRequest(void *, APTR req, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define MUI_AslRequest(req, tags) __MUI_AslRequest(MUIMasterBase, (req), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __MUI_AslRequestTags(void *, APTR req, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define MUI_AslRequestTags(req, ...) __MUI_AslRequestTags(MUIMasterBase, (req), __VA_ARGS__)
#endif

VOID __MUI_FreeAslRequest(void *, APTR req) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define MUI_FreeAslRequest(req) __MUI_FreeAslRequest(MUIMasterBase, (req))

LONG __MUI_Error(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define MUI_Error() __MUI_Error(MUIMasterBase)

LONG __MUI_SetError(void *, LONG errnum) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define MUI_SetError(errnum) __MUI_SetError(MUIMasterBase, (errnum))

struct IClass * __MUI_GetClass(void *, char * name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define MUI_GetClass(name) __MUI_GetClass(MUIMasterBase, (name))

VOID __MUI_FreeClass(void *, struct IClass * cl) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define MUI_FreeClass(cl) __MUI_FreeClass(MUIMasterBase, (cl))

VOID __MUI_RequestIDCMP(void *, Boopsiobject * obj, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define MUI_RequestIDCMP(obj, flags) __MUI_RequestIDCMP(MUIMasterBase, (obj), (flags))

VOID __MUI_RejectIDCMP(void *, Boopsiobject * obj, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define MUI_RejectIDCMP(obj, flags) __MUI_RejectIDCMP(MUIMasterBase, (obj), (flags))

VOID __MUI_Redraw(void *, Boopsiobject * obj, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define MUI_Redraw(obj, flags) __MUI_Redraw(MUIMasterBase, (obj), (flags))

struct MUI_CustomClass * __MUI_CreateCustomClass(void *, struct Library * base, char * supername, struct MUI_CustomClass * supermcc, int datasize, APTR dispatcher) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,0(2)\n"
	"\tstw\t8,44(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define MUI_CreateCustomClass(base, supername, supermcc, datasize, dispatcher) __MUI_CreateCustomClass(MUIMasterBase, (base), (supername), (supermcc), (datasize), (dispatcher))

BOOL __MUI_DeleteCustomClass(void *, struct MUI_CustomClass * mcc) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define MUI_DeleteCustomClass(mcc) __MUI_DeleteCustomClass(MUIMasterBase, (mcc))

Boopsiobject * __MUI_MakeObjectA(void *, LONG type, ULONG * params) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define MUI_MakeObjectA(type, params) __MUI_MakeObjectA(MUIMasterBase, (type), (params))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
Boopsiobject * __linearvarargs __MUI_MakeObject(void *, LONG type, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define MUI_MakeObject(...) __MUI_MakeObject(MUIMasterBase, __VA_ARGS__)
#endif

BOOL __MUI_Layout(void *, Boopsiobject * obj, LONG l, LONG t, LONG w, LONG h, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tstw\t9,16(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define MUI_Layout(obj, l, t, w, h, flags) __MUI_Layout(MUIMasterBase, (obj), (l), (t), (w), (h), (flags))

LONG __MUI_ObtainPen(void *, struct MUI_RenderInfo * mri, struct MUI_PenSpec * spec, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define MUI_ObtainPen(mri, spec, flags) __MUI_ObtainPen(MUIMasterBase, (mri), (spec), (flags))

VOID __MUI_ReleasePen(void *, struct MUI_RenderInfo * mri, LONG pen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define MUI_ReleasePen(mri, pen) __MUI_ReleasePen(MUIMasterBase, (mri), (pen))

APTR __MUI_AddClipping(void *, struct MUI_RenderInfo * mri, WORD l, WORD t, WORD w, WORD h) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tli\t3,-168\n"
	"\tbctrl";
#define MUI_AddClipping(mri, l, t, w, h) __MUI_AddClipping(MUIMasterBase, (mri), (l), (t), (w), (h))

VOID __MUI_RemoveClipping(void *, struct MUI_RenderInfo * mri, APTR h) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-174\n"
	"\tbctrl";
#define MUI_RemoveClipping(mri, h) __MUI_RemoveClipping(MUIMasterBase, (mri), (h))

APTR __MUI_AddClipRegion(void *, struct MUI_RenderInfo * mri, struct Region * region) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-180\n"
	"\tbctrl";
#define MUI_AddClipRegion(mri, region) __MUI_AddClipRegion(MUIMasterBase, (mri), (region))

VOID __MUI_RemoveClipRegion(void *, struct MUI_RenderInfo * mri, APTR region) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-186\n"
	"\tbctrl";
#define MUI_RemoveClipRegion(mri, region) __MUI_RemoveClipRegion(MUIMasterBase, (mri), (region))

BOOL __MUI_BeginRefresh(void *, struct MUI_RenderInfo * mri, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-192\n"
	"\tbctrl";
#define MUI_BeginRefresh(mri, flags) __MUI_BeginRefresh(MUIMasterBase, (mri), (flags))

VOID __MUI_EndRefresh(void *, struct MUI_RenderInfo * mri, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-198\n"
	"\tbctrl";
#define MUI_EndRefresh(mri, flags) __MUI_EndRefresh(MUIMasterBase, (mri), (flags))

#endif /*  _VBCCINLINE_MUIMASTER_H  */
