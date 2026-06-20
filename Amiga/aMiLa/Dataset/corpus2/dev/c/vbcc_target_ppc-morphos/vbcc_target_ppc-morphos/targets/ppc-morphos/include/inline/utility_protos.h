#ifndef _VBCCINLINE_UTILITY_H
#define _VBCCINLINE_UTILITY_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

struct TagItem * __FindTagItem(void *, Tag tagVal, CONST struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define FindTagItem(tagVal, tagList) __FindTagItem(UtilityBase, (tagVal), (tagList))

ULONG __GetTagData(void *, Tag tagValue, ULONG defaultVal, CONST struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define GetTagData(tagValue, defaultVal, tagList) __GetTagData(UtilityBase, (tagValue), (defaultVal), (tagList))

ULONG __PackBoolTags(void *, ULONG initialFlags, CONST struct TagItem * tagList, CONST struct TagItem * boolMap) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define PackBoolTags(initialFlags, tagList, boolMap) __PackBoolTags(UtilityBase, (initialFlags), (tagList), (boolMap))

struct TagItem * __NextTagItem(void *, struct TagItem ** tagListPtr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define NextTagItem(tagListPtr) __NextTagItem(UtilityBase, (tagListPtr))

VOID __FilterTagChanges(void *, struct TagItem * changeList, struct TagItem * originalList, ULONG apply) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define FilterTagChanges(changeList, originalList, apply) __FilterTagChanges(UtilityBase, (changeList), (originalList), (apply))

VOID __MapTags(void *, struct TagItem * tagList, CONST struct TagItem * mapList, ULONG mapType) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define MapTags(tagList, mapList, mapType) __MapTags(UtilityBase, (tagList), (mapList), (mapType))

struct TagItem * __AllocateTagItems(void *, ULONG numTags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define AllocateTagItems(numTags) __AllocateTagItems(UtilityBase, (numTags))

struct TagItem * __CloneTagItems(void *, CONST struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define CloneTagItems(tagList) __CloneTagItems(UtilityBase, (tagList))

VOID __FreeTagItems(void *, struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define FreeTagItems(tagList) __FreeTagItems(UtilityBase, (tagList))

VOID __RefreshTagItemClones(void *, struct TagItem * clone, CONST struct TagItem * original) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define RefreshTagItemClones(clone, original) __RefreshTagItemClones(UtilityBase, (clone), (original))

BOOL __TagInArray(void *, Tag tagValue, CONST Tag * tagArray) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define TagInArray(tagValue, tagArray) __TagInArray(UtilityBase, (tagValue), (tagArray))

ULONG __FilterTagItems(void *, struct TagItem * tagList, CONST Tag * filterArray, ULONG logic) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define FilterTagItems(tagList, filterArray, logic) __FilterTagItems(UtilityBase, (tagList), (filterArray), (logic))

ULONG __CallHookPkt(void *, struct Hook * hook, APTR object, APTR paramPacket) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,40(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define CallHookPkt(hook, object, paramPacket) __CallHookPkt(UtilityBase, (hook), (object), (paramPacket))

VOID __Amiga2Date(void *, ULONG seconds, struct ClockData * result) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define Amiga2Date(seconds, result) __Amiga2Date(UtilityBase, (seconds), (result))

ULONG __Date2Amiga(void *, CONST struct ClockData * date) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define Date2Amiga(date) __Date2Amiga(UtilityBase, (date))

ULONG __CheckDate(void *, CONST struct ClockData * date) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define CheckDate(date) __CheckDate(UtilityBase, (date))

LONG __SMult32(void *, LONG arg1, LONG arg2) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define SMult32(arg1, arg2) __SMult32(UtilityBase, (arg1), (arg2))

ULONG __UMult32(void *, ULONG arg1, ULONG arg2) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define UMult32(arg1, arg2) __UMult32(UtilityBase, (arg1), (arg2))

LONG __SDivMod32(void *, LONG dividend, LONG divisor) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define SDivMod32(dividend, divisor) __SDivMod32(UtilityBase, (dividend), (divisor))

ULONG __UDivMod32(void *, ULONG dividend, ULONG divisor) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define UDivMod32(dividend, divisor) __UDivMod32(UtilityBase, (dividend), (divisor))

LONG __Stricmp(void *, CONST_STRPTR string1, CONST_STRPTR string2) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define Stricmp(string1, string2) __Stricmp(UtilityBase, (string1), (string2))

LONG __Strnicmp(void *, CONST_STRPTR string1, CONST_STRPTR string2, LONG length) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-168\n"
	"\tbctrl";
#define Strnicmp(string1, string2, length) __Strnicmp(UtilityBase, (string1), (string2), (length))

UBYTE __ToUpper(void *, ULONG character) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-174\n"
	"\tbctrl";
#define ToUpper(character) __ToUpper(UtilityBase, (character))

UBYTE __ToLower(void *, ULONG character) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-180\n"
	"\tbctrl";
#define ToLower(character) __ToLower(UtilityBase, (character))

VOID __ApplyTagChanges(void *, struct TagItem * list, CONST struct TagItem * changeList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-186\n"
	"\tbctrl";
#define ApplyTagChanges(list, changeList) __ApplyTagChanges(UtilityBase, (list), (changeList))

LONG __SMult64(void *, LONG arg1, LONG arg2) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-198\n"
	"\tbctrl";
#define SMult64(arg1, arg2) __SMult64(UtilityBase, (arg1), (arg2))

ULONG __UMult64(void *, ULONG arg1, ULONG arg2) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-204\n"
	"\tbctrl";
#define UMult64(arg1, arg2) __UMult64(UtilityBase, (arg1), (arg2))

ULONG __PackStructureTags(void *, APTR pack, CONST ULONG * packTable, CONST struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-210\n"
	"\tbctrl";
#define PackStructureTags(pack, packTable, tagList) __PackStructureTags(UtilityBase, (pack), (packTable), (tagList))

ULONG __UnpackStructureTags(void *, CONST APTR pack, CONST ULONG * packTable, struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-216\n"
	"\tbctrl";
#define UnpackStructureTags(pack, packTable, tagList) __UnpackStructureTags(UtilityBase, (pack), (packTable), (tagList))

BOOL __AddNamedObject(void *, struct NamedObject * nameSpace, struct NamedObject * object) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-222\n"
	"\tbctrl";
#define AddNamedObject(nameSpace, object) __AddNamedObject(UtilityBase, (nameSpace), (object))

struct NamedObject * __AllocNamedObjectA(void *, CONST_STRPTR name, CONST struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-228\n"
	"\tbctrl";
#define AllocNamedObjectA(name, tagList) __AllocNamedObjectA(UtilityBase, (name), (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct NamedObject * __linearvarargs __AllocNamedObject(void *, CONST_STRPTR name, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-228\n"
	"\tbctrl";
#define AllocNamedObject(name, ...) __AllocNamedObject(UtilityBase, (name), __VA_ARGS__)
#endif

LONG __AttemptRemNamedObject(void *, struct NamedObject * object) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-234\n"
	"\tbctrl";
#define AttemptRemNamedObject(object) __AttemptRemNamedObject(UtilityBase, (object))

struct NamedObject * __FindNamedObject(void *, struct NamedObject * nameSpace, CONST_STRPTR name, struct NamedObject * lastObject) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-240\n"
	"\tbctrl";
#define FindNamedObject(nameSpace, name, lastObject) __FindNamedObject(UtilityBase, (nameSpace), (name), (lastObject))

VOID __FreeNamedObject(void *, struct NamedObject * object) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-246\n"
	"\tbctrl";
#define FreeNamedObject(object) __FreeNamedObject(UtilityBase, (object))

STRPTR __NamedObjectName(void *, struct NamedObject * object) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-252\n"
	"\tbctrl";
#define NamedObjectName(object) __NamedObjectName(UtilityBase, (object))

VOID __ReleaseNamedObject(void *, struct NamedObject * object) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-258\n"
	"\tbctrl";
#define ReleaseNamedObject(object) __ReleaseNamedObject(UtilityBase, (object))

VOID __RemNamedObject(void *, struct NamedObject * object, struct Message * message) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-264\n"
	"\tbctrl";
#define RemNamedObject(object, message) __RemNamedObject(UtilityBase, (object), (message))

ULONG __GetUniqueID(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-270\n"
	"\tbctrl";
#define GetUniqueID() __GetUniqueID(UtilityBase)

#endif /*  _VBCCINLINE_UTILITY_H  */
