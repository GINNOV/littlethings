#ifndef _INLINE_UTILITY_H
#define _INLINE_UTILITY_H

#ifndef UTILITY_BASE_NAME
#define UTILITY_BASE_NAME UtilityBase
#endif

#define FindTagItem(tagVal, tagList) \
	((struct TagItem * (*)(Tag __asm("d0"), CONST struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 30))(tagVal, tagList, (struct Library *) UTILITY_BASE_NAME)

#define GetTagData(tagValue, defaultVal, tagList) \
	((ULONG (*)(Tag __asm("d0"), ULONG __asm("d1"), CONST struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 36))(tagValue, defaultVal, tagList, (struct Library *) UTILITY_BASE_NAME)

#define PackBoolTags(initialFlags, tagList, boolMap) \
	((ULONG (*)(ULONG __asm("d0"), CONST struct TagItem * __asm("a0"), CONST struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 42))(initialFlags, tagList, boolMap, (struct Library *) UTILITY_BASE_NAME)

#define NextTagItem(tagListPtr) \
	((struct TagItem * (*)(struct TagItem ** __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 48))(tagListPtr, (struct Library *) UTILITY_BASE_NAME)

#define FilterTagChanges(changeList, originalList, apply) \
	((VOID (*)(struct TagItem * __asm("a0"), struct TagItem * __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 54))(changeList, originalList, apply, (struct Library *) UTILITY_BASE_NAME)

#define MapTags(tagList, mapList, mapType) \
	((VOID (*)(struct TagItem * __asm("a0"), CONST struct TagItem * __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 60))(tagList, mapList, mapType, (struct Library *) UTILITY_BASE_NAME)

#define AllocateTagItems(numTags) \
	((struct TagItem * (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 66))(numTags, (struct Library *) UTILITY_BASE_NAME)

#define CloneTagItems(tagList) \
	((struct TagItem * (*)(CONST struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 72))(tagList, (struct Library *) UTILITY_BASE_NAME)

#define FreeTagItems(tagList) \
	((VOID (*)(struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 78))(tagList, (struct Library *) UTILITY_BASE_NAME)

#define RefreshTagItemClones(clone, original) \
	((VOID (*)(struct TagItem * __asm("a0"), CONST struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 84))(clone, original, (struct Library *) UTILITY_BASE_NAME)

#define TagInArray(tagValue, tagArray) \
	((BOOL (*)(Tag __asm("d0"), CONST Tag * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 90))(tagValue, tagArray, (struct Library *) UTILITY_BASE_NAME)

#define FilterTagItems(tagList, filterArray, logic) \
	((ULONG (*)(struct TagItem * __asm("a0"), CONST Tag * __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 96))(tagList, filterArray, logic, (struct Library *) UTILITY_BASE_NAME)

#define CallHookPkt(hook, object, paramPacket) \
	((ULONG (*)(struct Hook * __asm("a0"), APTR __asm("a2"), APTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 102))(hook, object, paramPacket, (struct Library *) UTILITY_BASE_NAME)

#define Amiga2Date(seconds, result) \
	((VOID (*)(ULONG __asm("d0"), struct ClockData * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 120))(seconds, result, (struct Library *) UTILITY_BASE_NAME)

#define Date2Amiga(date) \
	((ULONG (*)(CONST struct ClockData * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 126))(date, (struct Library *) UTILITY_BASE_NAME)

#define CheckDate(date) \
	((ULONG (*)(CONST struct ClockData * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 132))(date, (struct Library *) UTILITY_BASE_NAME)

#define SMult32(arg1, arg2) \
	((LONG (*)(LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 138))(arg1, arg2, (struct Library *) UTILITY_BASE_NAME)

#define UMult32(arg1, arg2) \
	((ULONG (*)(ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 144))(arg1, arg2, (struct Library *) UTILITY_BASE_NAME)

#define SDivMod32(dividend, divisor) \
	((LONG (*)(LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 150))(dividend, divisor, (struct Library *) UTILITY_BASE_NAME)

#define UDivMod32(dividend, divisor) \
	((ULONG (*)(ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 156))(dividend, divisor, (struct Library *) UTILITY_BASE_NAME)

#define Stricmp(string1, string2) \
	((LONG (*)(CONST_STRPTR __asm("a0"), CONST_STRPTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 162))(string1, string2, (struct Library *) UTILITY_BASE_NAME)

#define Strnicmp(string1, string2, length) \
	((LONG (*)(CONST_STRPTR __asm("a0"), CONST_STRPTR __asm("a1"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 168))(string1, string2, length, (struct Library *) UTILITY_BASE_NAME)

#define ToUpper(character) \
	((UBYTE (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 174))(character, (struct Library *) UTILITY_BASE_NAME)

#define ToLower(character) \
	((UBYTE (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 180))(character, (struct Library *) UTILITY_BASE_NAME)

#define ApplyTagChanges(list, changeList) \
	((VOID (*)(struct TagItem * __asm("a0"), CONST struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 186))(list, changeList, (struct Library *) UTILITY_BASE_NAME)

#define SMult64(arg1, arg2) \
	((LONG (*)(LONG __asm("d0"), LONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 198))(arg1, arg2, (struct Library *) UTILITY_BASE_NAME)

#define UMult64(arg1, arg2) \
	((ULONG (*)(ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 204))(arg1, arg2, (struct Library *) UTILITY_BASE_NAME)

#define PackStructureTags(pack, packTable, tagList) \
	((ULONG (*)(APTR __asm("a0"), CONST ULONG * __asm("a1"), CONST struct TagItem * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 210))(pack, packTable, tagList, (struct Library *) UTILITY_BASE_NAME)

#define UnpackStructureTags(pack, packTable, tagList) \
	((ULONG (*)(CONST APTR __asm("a0"), CONST ULONG * __asm("a1"), struct TagItem * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 216))(pack, packTable, tagList, (struct Library *) UTILITY_BASE_NAME)

#define AddNamedObject(nameSpace, object) \
	((BOOL (*)(struct NamedObject * __asm("a0"), struct NamedObject * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 222))(nameSpace, object, (struct Library *) UTILITY_BASE_NAME)

#define AllocNamedObjectA(name, tagList) \
	((struct NamedObject * (*)(CONST_STRPTR __asm("a0"), CONST struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 228))(name, tagList, (struct Library *) UTILITY_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define AllocNamedObject(name, tags...) \
	({ULONG _tags[] = {tags}; AllocNamedObjectA((name), (Tag) _tags);})
#endif

#define AttemptRemNamedObject(object) \
	((LONG (*)(struct NamedObject * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 234))(object, (struct Library *) UTILITY_BASE_NAME)

#define FindNamedObject(nameSpace, name, lastObject) \
	((struct NamedObject * (*)(struct NamedObject * __asm("a0"), CONST_STRPTR __asm("a1"), struct NamedObject * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 240))(nameSpace, name, lastObject, (struct Library *) UTILITY_BASE_NAME)

#define FreeNamedObject(object) \
	((VOID (*)(struct NamedObject * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 246))(object, (struct Library *) UTILITY_BASE_NAME)

#define NamedObjectName(object) \
	((STRPTR (*)(struct NamedObject * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 252))(object, (struct Library *) UTILITY_BASE_NAME)

#define ReleaseNamedObject(object) \
	((VOID (*)(struct NamedObject * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 258))(object, (struct Library *) UTILITY_BASE_NAME)

#define RemNamedObject(object, message) \
	((VOID (*)(struct NamedObject * __asm("a0"), struct Message * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 264))(object, message, (struct Library *) UTILITY_BASE_NAME)

#define GetUniqueID() \
	((ULONG (*)(struct Library * __asm("a6"))) \
  (((char *) UTILITY_BASE_NAME) - 270))((struct Library *) UTILITY_BASE_NAME)

#endif /*  _INLINE_UTILITY_H  */
