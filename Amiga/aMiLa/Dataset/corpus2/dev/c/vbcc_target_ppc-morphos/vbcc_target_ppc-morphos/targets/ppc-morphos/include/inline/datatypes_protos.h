#ifndef _VBCCINLINE_DATATYPES_H
#define _VBCCINLINE_DATATYPES_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

struct DataType * __ObtainDataTypeA(void *, ULONG type, APTR handle, struct TagItem * attrs) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define ObtainDataTypeA(type, handle, attrs) __ObtainDataTypeA(DataTypesBase, (type), (handle), (attrs))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct DataType * __linearvarargs __ObtainDataType(void *, ULONG type, APTR handle, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define ObtainDataType(type, handle, ...) __ObtainDataType(DataTypesBase, (type), (handle), __VA_ARGS__)
#endif

VOID __ReleaseDataType(void *, struct DataType * dt) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define ReleaseDataType(dt) __ReleaseDataType(DataTypesBase, (dt))

Object * __NewDTObjectA(void *, APTR name, struct TagItem * attrs) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define NewDTObjectA(name, attrs) __NewDTObjectA(DataTypesBase, (name), (attrs))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
Object * __linearvarargs __NewDTObject(void *, APTR name, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define NewDTObject(name, ...) __NewDTObject(DataTypesBase, (name), __VA_ARGS__)
#endif

VOID __DisposeDTObject(void *, Object * o) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define DisposeDTObject(o) __DisposeDTObject(DataTypesBase, (o))

ULONG __SetDTAttrsA(void *, Object * o, struct Window * win, struct Requester * req, struct TagItem * attrs) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define SetDTAttrsA(o, win, req, attrs) __SetDTAttrsA(DataTypesBase, (o), (win), (req), (attrs))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __SetDTAttrs(void *, Object * o, struct Window * win, struct Requester * req, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,44(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define SetDTAttrs(o, win, req, ...) __SetDTAttrs(DataTypesBase, (o), (win), (req), __VA_ARGS__)
#endif

ULONG __GetDTAttrsA(void *, Object * o, struct TagItem * attrs) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,40(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define GetDTAttrsA(o, attrs) __GetDTAttrsA(DataTypesBase, (o), (attrs))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __GetDTAttrs(void *, Object * o, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define GetDTAttrs(o, ...) __GetDTAttrs(DataTypesBase, (o), __VA_ARGS__)
#endif

LONG __AddDTObject(void *, struct Window * win, struct Requester * req, Object * o, LONG pos) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,0(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define AddDTObject(win, req, o, pos) __AddDTObject(DataTypesBase, (win), (req), (o), (pos))

VOID __RefreshDTObjectA(void *, Object * o, struct Window * win, struct Requester * req, struct TagItem * attrs) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define RefreshDTObjectA(o, win, req, attrs) __RefreshDTObjectA(DataTypesBase, (o), (win), (req), (attrs))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
VOID __linearvarargs __RefreshDTObject(void *, Object * o, struct Window * win, struct Requester * req, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,44(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define RefreshDTObject(o, win, req, ...) __RefreshDTObject(DataTypesBase, (o), (win), (req), __VA_ARGS__)
#endif

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
#define RefreshDTObjects(o, win, req, attrs) __RefreshDTObjectA((o), (win), (req), (attrs), DataTypesBase)
#endif

ULONG __DoAsyncLayout(void *, Object * o, struct gpLayout * gpl) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define DoAsyncLayout(o, gpl) __DoAsyncLayout(DataTypesBase, (o), (gpl))

ULONG __DoDTMethodA(void *, Object * o, struct Window * win, struct Requester * req, Msg msg) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define DoDTMethodA(o, win, req, msg) __DoDTMethodA(DataTypesBase, (o), (win), (req), (msg))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __DoDTMethod(void *, Object * o, struct Window * win, struct Requester * req, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,44(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define DoDTMethod(o, win, req, ...) __DoDTMethod(DataTypesBase, (o), (win), (req), __VA_ARGS__)
#endif

LONG __RemoveDTObject(void *, struct Window * win, Object * o) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define RemoveDTObject(win, o) __RemoveDTObject(DataTypesBase, (win), (o))

ULONG * __GetDTMethods(void *, Object * object) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define GetDTMethods(object) __GetDTMethods(DataTypesBase, (object))

struct DTMethods * __GetDTTriggerMethods(void *, Object * object) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define GetDTTriggerMethods(object) __GetDTTriggerMethods(DataTypesBase, (object))

ULONG __PrintDTObjectA(void *, Object * o, struct Window * w, struct Requester * r, struct dtPrint * msg) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define PrintDTObjectA(o, w, r, msg) __PrintDTObjectA(DataTypesBase, (o), (w), (r), (msg))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __PrintDTObject(void *, Object * o, struct Window * w, struct Requester * r, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,44(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define PrintDTObject(o, w, r, ...) __PrintDTObject(DataTypesBase, (o), (w), (r), __VA_ARGS__)
#endif

APTR __ObtainDTDrawInfoA(void *, Object * o, struct TagItem * attrs) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define ObtainDTDrawInfoA(o, attrs) __ObtainDTDrawInfoA(DataTypesBase, (o), (attrs))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __ObtainDTDrawInfo(void *, Object * o, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define ObtainDTDrawInfo(o, ...) __ObtainDTDrawInfo(DataTypesBase, (o), __VA_ARGS__)
#endif

LONG __DrawDTObjectA(void *, struct RastPort * rp, Object * o, LONG x, LONG y, LONG w, LONG h, LONG th, LONG tv, struct TagItem * attrs) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,8(2)\n"
	"\tstw\t9,12(2)\n"
	"\tstw\t10,16(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,20(2)\n"
	"\tlwz\t11,12(1)\n"
	"\tstw\t11,40(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define DrawDTObjectA(rp, o, x, y, w, h, th, tv, attrs) __DrawDTObjectA(DataTypesBase, (rp), (o), (x), (y), (w), (h), (th), (tv), (attrs))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __DrawDTObject(void *, struct RastPort * rp, Object * o, LONG x, LONG y, LONG w, LONG h, LONG th, LONG tv, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,8(2)\n"
	"\tstw\t9,12(2)\n"
	"\tstw\t10,16(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,20(2)\n"
	"\taddi\t12,1,12\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define DrawDTObject(rp, o, x, y, w, h, th, tv, ...) __DrawDTObject(DataTypesBase, (rp), (o), (x), (y), (w), (h), (th), (tv), __VA_ARGS__)
#endif

VOID __ReleaseDTDrawInfo(void *, Object * o, APTR handle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define ReleaseDTDrawInfo(o, handle) __ReleaseDTDrawInfo(DataTypesBase, (o), (handle))

STRPTR __GetDTString(void *, ULONG id) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define GetDTString(id) __GetDTString(DataTypesBase, (id))

void __LockDataType(void *, struct DataType * dt) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-240\n"
	"\tbctrl";
#define LockDataType(dt) __LockDataType(DataTypesBase, (dt))

struct ToolNode * __FindToolNodeA(void *, struct List * tl, struct TagItem * attrs) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-246\n"
	"\tbctrl";
#define FindToolNodeA(tl, attrs) __FindToolNodeA(DataTypesBase, (tl), (attrs))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct ToolNode * __linearvarargs __FindToolNode(void *, struct List * tl, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-246\n"
	"\tbctrl";
#define FindToolNode(tl, ...) __FindToolNode(DataTypesBase, (tl), __VA_ARGS__)
#endif

ULONG __LaunchToolA(void *, struct Tool * t, STRPTR project, struct TagItem * attrs) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-252\n"
	"\tbctrl";
#define LaunchToolA(t, project, attrs) __LaunchToolA(DataTypesBase, (t), (project), (attrs))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __LaunchTool(void *, struct Tool * t, STRPTR project, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-252\n"
	"\tbctrl";
#define LaunchTool(t, project, ...) __LaunchTool(DataTypesBase, (t), (project), __VA_ARGS__)
#endif

ULONG           * __FindMethod(void *, ULONG * methods, ULONG id) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-258\n"
	"\tbctrl";
#define FindMethod(methods, id) __FindMethod(DataTypesBase, (methods), (id))

struct DTMethod * __FindTriggerMethod(void *, struct DTMethod * triggermethods, STRPTR command, ULONG method) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-264\n"
	"\tbctrl";
#define FindTriggerMethod(triggermethods, command, method) __FindTriggerMethod(DataTypesBase, (triggermethods), (command), (method))

ULONG           * __CopyDTMethods(void *, ULONG * src, ULONG * include, ULONG * exclude) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-270\n"
	"\tbctrl";
#define CopyDTMethods(src, include, exclude) __CopyDTMethods(DataTypesBase, (src), (include), (exclude))

struct DTMethod * __CopyDTTriggerMethods(void *, struct DTMethod * src, struct DTMethod * include, struct DTMethod * exclude) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-276\n"
	"\tbctrl";
#define CopyDTTriggerMethods(src, include, exclude) __CopyDTTriggerMethods(DataTypesBase, (src), (include), (exclude))

VOID __FreeDTMethods(void *, APTR m) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-282\n"
	"\tbctrl";
#define FreeDTMethods(m) __FreeDTMethods(DataTypesBase, (m))

ULONG __GetDTTriggerMethodDataFlags(void *, ULONG triggermethod) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-288\n"
	"\tbctrl";
#define GetDTTriggerMethodDataFlags(triggermethod) __GetDTTriggerMethodDataFlags(DataTypesBase, (triggermethod))

ULONG __SaveDTObjectA(void *, Object * o, struct Window * win, struct Requester * req, STRPTR file, ULONG mode, BOOL saveicon, struct TagItem * attrs) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tstw\t8,0(2)\n"
	"\tstw\t9,4(2)\n"
	"\tstw\t10,48(2)\n"
	"\tli\t3,-294\n"
	"\tbctrl";
#define SaveDTObjectA(o, win, req, file, mode, saveicon, attrs) __SaveDTObjectA(DataTypesBase, (o), (win), (req), (file), (mode), (saveicon), (attrs))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __SaveDTObject(void *, Object * o, struct Window * win, struct Requester * req, STRPTR file, ULONG mode, BOOL saveicon, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tstw\t8,0(2)\n"
	"\tstw\t9,4(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,48(2)\n"
	"\tli\t3,-294\n"
	"\tbctrl";
#define SaveDTObject(o, win, req, file, mode, saveicon, ...) __SaveDTObject(DataTypesBase, (o), (win), (req), (file), (mode), (saveicon), __VA_ARGS__)
#endif

ULONG __StartDragSelect(void *, Object * o) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-300\n"
	"\tbctrl";
#define StartDragSelect(o) __StartDragSelect(DataTypesBase, (o))

ULONG __DoDTDomainA(void *, Object * o, struct Window * win, struct Requester * req, struct RastPort * rport, ULONG which, struct IBox * domain, struct TagItem * attrs) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tstw\t8,0(2)\n"
	"\tstw\t9,48(2)\n"
	"\tstw\t10,52(2)\n"
	"\tli\t3,-306\n"
	"\tbctrl";
#define DoDTDomainA(o, win, req, rport, which, domain, attrs) __DoDTDomainA(DataTypesBase, (o), (win), (req), (rport), (which), (domain), (attrs))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __DoDTDomain(void *, Object * o, struct Window * win, struct Requester * req, struct RastPort * rport, ULONG which, struct IBox * domain, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tstw\t8,0(2)\n"
	"\tstw\t9,48(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,52(2)\n"
	"\tli\t3,-306\n"
	"\tbctrl";
#define DoDTDomain(o, win, req, rport, which, domain, ...) __DoDTDomain(DataTypesBase, (o), (win), (req), (rport), (which), (domain), __VA_ARGS__)
#endif

#endif /*  _VBCCINLINE_DATATYPES_H  */
