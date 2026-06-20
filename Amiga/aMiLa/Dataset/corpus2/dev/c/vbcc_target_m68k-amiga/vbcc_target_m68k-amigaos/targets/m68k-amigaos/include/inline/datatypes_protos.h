#ifndef _VBCCINLINE_DATATYPES_H
#define _VBCCINLINE_DATATYPES_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

struct DataType * __ObtainDataTypeA(__reg("a6") void *, __reg("d0") ULONG type, __reg("a0") APTR handle, __reg("a1") CONST struct TagItem * attrs)="\tjsr\t-36(a6)";
#define ObtainDataTypeA(type, handle, attrs) __ObtainDataTypeA(DataTypesBase, (type), (handle), (attrs))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct DataType * __ObtainDataType(__reg("a6") void *, __reg("d0") ULONG type, __reg("a0") APTR handle, ...)="\tmove.l\ta1,-(a7)\n\tlea\t4(a7),a1\n\tjsr\t-36(a6)\n\tmovea.l\t(a7)+,a1";
#define ObtainDataType(type, ...) __ObtainDataType(DataTypesBase, (type), __VA_ARGS__)
#endif

VOID __ReleaseDataType(__reg("a6") void *, __reg("a0") struct DataType * dt)="\tjsr\t-42(a6)";
#define ReleaseDataType(dt) __ReleaseDataType(DataTypesBase, (dt))

Object * __NewDTObjectA(__reg("a6") void *, __reg("d0") CONST_STRPTR name, __reg("a0") CONST struct TagItem * attrs)="\tjsr\t-48(a6)";
#define NewDTObjectA(name, attrs) __NewDTObjectA(DataTypesBase, (name), (attrs))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
Object * __NewDTObject(__reg("a6") void *, __reg("d0") CONST_STRPTR name, ...)="\tmove.l\ta0,-(a7)\n\tlea\t4(a7),a0\n\tjsr\t-48(a6)\n\tmovea.l\t(a7)+,a0";
#define NewDTObject(...) __NewDTObject(DataTypesBase, __VA_ARGS__)
#endif

VOID __DisposeDTObject(__reg("a6") void *, __reg("a0") Object * o)="\tjsr\t-54(a6)";
#define DisposeDTObject(o) __DisposeDTObject(DataTypesBase, (o))

ULONG __SetDTAttrsA(__reg("a6") void *, __reg("a0") Object * o, __reg("a1") struct Window * win, __reg("a2") struct Requester * req, __reg("a3") CONST struct TagItem * attrs)="\tjsr\t-60(a6)";
#define SetDTAttrsA(o, win, req, attrs) __SetDTAttrsA(DataTypesBase, (o), (win), (req), (attrs))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __SetDTAttrs(__reg("a6") void *, __reg("a0") Object * o, __reg("a1") struct Window * win, __reg("a2") struct Requester * req, ...)="\tmove.l\ta3,-(a7)\n\tlea\t4(a7),a3\n\tjsr\t-60(a6)\n\tmovea.l\t(a7)+,a3";
#define SetDTAttrs(o, win, ...) __SetDTAttrs(DataTypesBase, (o), (win), __VA_ARGS__)
#endif

ULONG __GetDTAttrsA(__reg("a6") void *, __reg("a0") Object * o, __reg("a2") CONST struct TagItem * attrs)="\tjsr\t-66(a6)";
#define GetDTAttrsA(o, attrs) __GetDTAttrsA(DataTypesBase, (o), (attrs))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __GetDTAttrs(__reg("a6") void *, __reg("a0") Object * o, ...)="\tmove.l\ta2,-(a7)\n\tlea\t4(a7),a2\n\tjsr\t-66(a6)\n\tmovea.l\t(a7)+,a2";
#define GetDTAttrs(...) __GetDTAttrs(DataTypesBase, __VA_ARGS__)
#endif

LONG __AddDTObject(__reg("a6") void *, __reg("a0") struct Window * win, __reg("a1") struct Requester * req, __reg("a2") Object * o, __reg("d0") LONG pos)="\tjsr\t-72(a6)";
#define AddDTObject(win, req, o, pos) __AddDTObject(DataTypesBase, (win), (req), (o), (pos))

VOID __RefreshDTObjectA(__reg("a6") void *, __reg("a0") Object * o, __reg("a1") struct Window * win, __reg("a2") struct Requester * req, __reg("a3") CONST struct TagItem * attrs)="\tjsr\t-78(a6)";
#define RefreshDTObjectA(o, win, req, attrs) __RefreshDTObjectA(DataTypesBase, (o), (win), (req), (attrs))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
VOID __RefreshDTObjects(__reg("a6") void *, __reg("a0") Object * o, __reg("a1") struct Window * win, __reg("a2") struct Requester * req, ...)="\tmove.l\ta3,-(a7)\n\tlea\t4(a7),a3\n\tjsr\t-78(a6)\n\tmovea.l\t(a7)+,a3";
#define RefreshDTObjects(o, win, ...) __RefreshDTObjects(DataTypesBase, (o), (win), __VA_ARGS__)
#endif

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
#define RefreshDTObject(o, win, req, attrs) __RefreshDTObjectA(DataTypesBase, (o), (win), (req), (attrs))
#endif

ULONG __DoAsyncLayout(__reg("a6") void *, __reg("a0") Object * o, __reg("a1") struct gpLayout * gpl)="\tjsr\t-84(a6)";
#define DoAsyncLayout(o, gpl) __DoAsyncLayout(DataTypesBase, (o), (gpl))

ULONG __DoDTMethodA(__reg("a6") void *, __reg("a0") Object * o, __reg("a1") struct Window * win, __reg("a2") struct Requester * req, __reg("a3") Msg msg)="\tjsr\t-90(a6)";
#define DoDTMethodA(o, win, req, msg) __DoDTMethodA(DataTypesBase, (o), (win), (req), (msg))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __DoDTMethod(__reg("a6") void *, __reg("a0") Object * o, __reg("a1") struct Window * win, __reg("a2") struct Requester * req, ULONG msg, ...)="\tmove.l\ta3,-(a7)\n\tlea\t4(a7),a3\n\tjsr\t-90(a6)\n\tmovea.l\t(a7)+,a3";
#define DoDTMethod(o, win, req, ...) __DoDTMethod(DataTypesBase, (o), (win), (req), __VA_ARGS__)
#endif

LONG __RemoveDTObject(__reg("a6") void *, __reg("a0") struct Window * win, __reg("a1") Object * o)="\tjsr\t-96(a6)";
#define RemoveDTObject(win, o) __RemoveDTObject(DataTypesBase, (win), (o))

ULONG * __GetDTMethods(__reg("a6") void *, __reg("a0") CONST Object * object)="\tjsr\t-102(a6)";
#define GetDTMethods(object) __GetDTMethods(DataTypesBase, (object))

struct DTMethods * __GetDTTriggerMethods(__reg("a6") void *, __reg("a0") Object * object)="\tjsr\t-108(a6)";
#define GetDTTriggerMethods(object) __GetDTTriggerMethods(DataTypesBase, (object))

ULONG __PrintDTObjectA(__reg("a6") void *, __reg("a0") Object * o, __reg("a1") struct Window * w, __reg("a2") struct Requester * r, __reg("a3") struct dtPrint * msg)="\tjsr\t-114(a6)";
#define PrintDTObjectA(o, w, r, msg) __PrintDTObjectA(DataTypesBase, (o), (w), (r), (msg))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __PrintDTObject(__reg("a6") void *, __reg("a0") Object * o, __reg("a1") struct Window * w, __reg("a2") struct Requester * r, ULONG msg, ...)="\tmove.l\ta3,-(a7)\n\tlea\t4(a7),a3\n\tjsr\t-114(a6)\n\tmovea.l\t(a7)+,a3";
#define PrintDTObject(o, w, r, ...) __PrintDTObject(DataTypesBase, (o), (w), (r), __VA_ARGS__)
#endif

STRPTR __GetDTString(__reg("a6") void *, __reg("d0") ULONG id)="\tjsr\t-138(a6)";
#define GetDTString(id) __GetDTString(DataTypesBase, (id))

ULONG * __FindMethod(__reg("a6") void *, __reg("a0") CONST ULONG * methods, __reg("a1") void * searchmethodid)="\tjsr\t-258(a6)";
#define FindMethod(methods, searchmethodid) __FindMethod(DataTypesBase, (methods), (void *)(searchmethodid))

struct DTMethod * __FindTriggerMethod(__reg("a6") void *, __reg("a0") CONST struct DTMethod * dtm, __reg("a1") CONST_STRPTR command, __reg("d0") ULONG method)="\tjsr\t-264(a6)";
#define FindTriggerMethod(dtm, command, method) __FindTriggerMethod(DataTypesBase, (dtm), (command), (method))

ULONG * __CopyDTMethods(__reg("a6") void *, __reg("a0") CONST ULONG * methods, __reg("a1") CONST ULONG * include, __reg("a2") CONST ULONG * exclude)="\tjsr\t-270(a6)";
#define CopyDTMethods(methods, include, exclude) __CopyDTMethods(DataTypesBase, (methods), (include), (exclude))

struct DTMethod * __CopyDTTriggerMethods(__reg("a6") void *, __reg("a0") CONST struct DTMethod * methods, __reg("a1") CONST struct DTMethod * include, __reg("a2") CONST struct DTMethod * exclude)="\tjsr\t-276(a6)";
#define CopyDTTriggerMethods(methods, include, exclude) __CopyDTTriggerMethods(DataTypesBase, (methods), (include), (exclude))

VOID * __FreeDTMethods(__reg("a6") void *, __reg("a0") APTR methods)="\tjsr\t-282(a6)";
#define FreeDTMethods(methods) __FreeDTMethods(DataTypesBase, (methods))

ULONG __GetDTTriggerMethodDataFlags(__reg("a6") void *, __reg("d0") ULONG triggermethod)="\tjsr\t-288(a6)";
#define GetDTTriggerMethodDataFlags(triggermethod) __GetDTTriggerMethodDataFlags(DataTypesBase, (triggermethod))

#if !defined(__SMALL_DATA__)
ULONG __SaveDTObjectA(__reg("a6") void *, __reg("a0") Object * o, __reg("a1") struct Window * win, __reg("a2") struct Requester * req, __reg("a3") CONST_STRPTR file, __reg("d0") ULONG mode, __reg("d1") LONG saveicon, __reg("a4") struct TagItem * attrs)="\tjsr\t-294(a6)";
#define SaveDTObjectA(o, win, req, file, mode, saveicon, attrs) __SaveDTObjectA(DataTypesBase, (o), (win), (req), (file), (mode), (saveicon), (attrs))
#endif

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
#if !defined(__SMALL_DATA__)
ULONG __SaveDTObject(__reg("a6") void *, __reg("a0") Object * o, __reg("a1") struct Window * win, __reg("a2") struct Requester * req, __reg("a3") CONST_STRPTR file, __reg("d0") ULONG mode, __reg("d1") LONG saveicon, ...)="\tmove.l\ta4,-(a7)\n\tlea\t4(a7),a4\n\tjsr\t-294(a6)\n\tmovea.l\t(a7)+,a4";
#define SaveDTObject(o, win, req, file, mode, ...) __SaveDTObject(DataTypesBase, (o), (win), (req), (file), (mode), __VA_ARGS__)
#endif
#endif

ULONG __StartDragSelect(__reg("a6") void *, __reg("a0") Object * o)="\tjsr\t-300(a6)";
#define StartDragSelect(o) __StartDragSelect(DataTypesBase, (o))

#endif /*  _VBCCINLINE_DATATYPES_H  */
