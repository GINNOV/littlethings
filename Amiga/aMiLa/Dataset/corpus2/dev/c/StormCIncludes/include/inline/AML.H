#ifndef _INLINE_AML_H
#define _INLINE_AML_H

#ifndef AML_BASE_NAME
#define AML_BASE_NAME AmlBase
#endif

#define RexxDispatcher(rxm) \
	((LONG (*)(struct RexxMsg * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 30))(rxm, (struct Library *) AML_BASE_NAME)

#define CreateServerA(tags) \
	((APTR (*)(struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 36))(tags, (struct Library *) AML_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define CreateServer(tags...) \
	({ULONG _tags[] = {tags}; CreateServerA((Tag) _tags);})
#endif

#define DisposeServer(server) \
	((VOID (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 42))(server, (struct Library *) AML_BASE_NAME)

#define SetServerAttrsA(server, tags) \
	((ULONG (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 48))(server, tags, (struct Library *) AML_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SetServerAttrs(server, tags...) \
	({ULONG _tags[] = {tags}; SetServerAttrsA((server), () _tags);})
#endif

#define GetServerAttrsA(server, tags) \
	((ULONG (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 54))(server, tags, (struct Library *) AML_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define GetServerAttrs(server, tags...) \
	({ULONG _tags[] = {tags}; GetServerAttrsA((server), () _tags);})
#endif

#define GetServerHeaders(server, flags) \
	((ULONG (*)(APTR __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 60))(server, flags, (struct Library *) AML_BASE_NAME)

#define GetServerArticles(server, folder, hook, flags) \
	((LONG (*)(APTR __asm("a0"), APTR __asm("a1"), struct Hook * __asm("a2"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 66))(server, folder, hook, flags, (struct Library *) AML_BASE_NAME)

#define CreateFolderA(server, tags) \
	((APTR (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 72))(server, tags, (struct Library *) AML_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define CreateFolder(server, tags...) \
	({ULONG _tags[] = {tags}; CreateFolderA((server), () _tags);})
#endif

#define DisposeFolder(folder) \
	((BOOL (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 78))(folder, (struct Library *) AML_BASE_NAME)

#define OpenFolderA(server, tags) \
	((APTR (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 84))(server, tags, (struct Library *) AML_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define OpenFolder(server, tags...) \
	({ULONG _tags[] = {tags}; OpenFolderA((server), () _tags);})
#endif

#define SaveFolder(folder) \
	((BOOL (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 90))(folder, (struct Library *) AML_BASE_NAME)

#define RemFolder(folder) \
	((BOOL (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 96))(folder, (struct Library *) AML_BASE_NAME)

#define SetFolderAttrsA(folder, tags) \
	((ULONG (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 102))(folder, tags, (struct Library *) AML_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SetFolderAttrs(folder, tags...) \
	({ULONG _tags[] = {tags}; SetFolderAttrsA((folder), () _tags);})
#endif

#define GetFolderAttrsA(folder, tags) \
	((ULONG (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 108))(folder, tags, (struct Library *) AML_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define GetFolderAttrs(folder, tags...) \
	({ULONG _tags[] = {tags}; GetFolderAttrsA((folder), () _tags);})
#endif

#define AddFolderArticle(folder, type, data) \
	((BOOL (*)(APTR __asm("a0"), ULONG __asm("d0"), APTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 114))(folder, type, data, (struct Library *) AML_BASE_NAME)

#define RemFolderArticle(folder, article) \
	((BOOL (*)(APTR __asm("a0"), APTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 120))(folder, article, (struct Library *) AML_BASE_NAME)

#define ReadFolderSpool(folder, importfile, flags) \
	((ULONG (*)(APTR __asm("a0"), STRPTR __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 126))(folder, importfile, flags, (struct Library *) AML_BASE_NAME)

#define WriteFolderSpool(folder, exportfile, flags) \
	((ULONG (*)(APTR __asm("a0"), STRPTR __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 132))(folder, exportfile, flags, (struct Library *) AML_BASE_NAME)

#define ScanFolderIndex(folder, hook, flags) \
	((ULONG (*)(APTR __asm("a0"), struct Hook * __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 138))(folder, hook, flags, (struct Library *) AML_BASE_NAME)

#define ExpungeFolder(folder, trash, hook) \
	((BOOL (*)(APTR __asm("a0"), APTR __asm("a1"), struct Hook * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 144))(folder, trash, hook, (struct Library *) AML_BASE_NAME)

#define CreateFolderIndex(folder) \
	((ULONG (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 150))(folder, (struct Library *) AML_BASE_NAME)

#define SortFolderIndex(folder, field) \
	((ULONG (*)(APTR __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 156))(folder, field, (struct Library *) AML_BASE_NAME)

#define CreateArticleA(folder, tags) \
	((APTR (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 162))(folder, tags, (struct Library *) AML_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define CreateArticle(folder, tags...) \
	({ULONG _tags[] = {tags}; CreateArticleA((folder), () _tags);})
#endif

#define DisposeArticle(article) \
	((BOOL (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 168))(article, (struct Library *) AML_BASE_NAME)

#define OpenArticle(server, folder, msgID, flags) \
	((APTR (*)(APTR __asm("a0"), APTR __asm("a1"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 174))(server, folder, msgID, flags, (struct Library *) AML_BASE_NAME)

#define CopyArticle(folder, article) \
	((BOOL (*)(APTR __asm("a0"), APTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 180))(folder, article, (struct Library *) AML_BASE_NAME)

#define SetArticleAttrsA(article, tags) \
	((ULONG (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 186))(article, tags, (struct Library *) AML_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SetArticleAttrs(article, tags...) \
	({ULONG _tags[] = {tags}; SetArticleAttrsA((article), () _tags);})
#endif

#define GetArticleAttrsA(article, tags) \
	((ULONG (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 192))(article, tags, (struct Library *) AML_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define GetArticleAttrs(article, tags...) \
	({ULONG _tags[] = {tags}; GetArticleAttrsA((article), () _tags);})
#endif

#define SendArticle(server, article, from_file) \
	((BOOL (*)(APTR __asm("a0"), APTR __asm("a1"), STRPTR __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 198))(server, article, from_file, (struct Library *) AML_BASE_NAME)

#define AddArticlePartA(article, part, tags) \
	((BOOL (*)(APTR __asm("a0"), APTR __asm("a1"), struct TagItem * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 204))(article, part, tags, (struct Library *) AML_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define AddArticlePart(article, part, tags...) \
	({ULONG _tags[] = {tags}; AddArticlePartA((article), (part), () _tags);})
#endif

#define RemArticlePart(article, part) \
	((VOID (*)(APTR __asm("a0"), APTR __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 210))(article, part, (struct Library *) AML_BASE_NAME)

#define GetArticlePart(article, partnum) \
	((APTR (*)(APTR __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 216))(article, partnum, (struct Library *) AML_BASE_NAME)

#define GetArticlePartAttrsA(part, tags) \
	((ULONG (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 222))(part, tags, (struct Library *) AML_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define GetArticlePartAttrs(part, tags...) \
	({ULONG _tags[] = {tags}; GetArticlePartAttrsA((part), () _tags);})
#endif

#define SetArticlePartAttrsA(part, tags) \
	((ULONG (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 228))(part, tags, (struct Library *) AML_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SetArticlePartAttrs(part, tags...) \
	({ULONG _tags[] = {tags}; SetArticlePartAttrsA((part), () _tags);})
#endif

#define CreateArticlePartA(article, tags) \
	((APTR (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 234))(article, tags, (struct Library *) AML_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define CreateArticlePart(article, tags...) \
	({ULONG _tags[] = {tags}; CreateArticlePartA((article), () _tags);})
#endif

#define DisposeArticlePart(part) \
	((VOID (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 240))(part, (struct Library *) AML_BASE_NAME)

#define GetArticlePartDataA(article, part, tags) \
	((BOOL (*)(APTR __asm("a0"), APTR __asm("a1"), struct TagItem * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 246))(article, part, tags, (struct Library *) AML_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define GetArticlePartData(article, part, tags...) \
	({ULONG _tags[] = {tags}; GetArticlePartDataA((article), (part), () _tags);})
#endif

#define SetArticlePartDataA(part, tags) \
	((BOOL (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 252))(part, tags, (struct Library *) AML_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SetArticlePartData(part, tags...) \
	({ULONG _tags[] = {tags}; SetArticlePartDataA((part), () _tags);})
#endif

#define CreateAddressEntryA(tags) \
	((APTR (*)(struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 258))(tags, (struct Library *) AML_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define CreateAddressEntry(tags...) \
	({ULONG _tags[] = {tags}; CreateAddressEntryA((Tag) _tags);})
#endif

#define DisposeAddressEntry(addr) \
	((BOOL (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 264))(addr, (struct Library *) AML_BASE_NAME)

#define OpenAddressEntry(server, fileid) \
	((APTR (*)(APTR __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 270))(server, fileid, (struct Library *) AML_BASE_NAME)

#define SaveAddressEntry(server, addr) \
	((LONG (*)(APTR __asm("a0"), APTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 276))(server, addr, (struct Library *) AML_BASE_NAME)

#define RemAddressEntry(server, addr) \
	((BOOL (*)(APTR __asm("a0"), APTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 282))(server, addr, (struct Library *) AML_BASE_NAME)

#define GetAddressEntryAttrsA(addr, tags) \
	((ULONG (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 288))(addr, tags, (struct Library *) AML_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define GetAddressEntryAttrs(addr, tags...) \
	({ULONG _tags[] = {tags}; GetAddressEntryAttrsA((addr), () _tags);})
#endif

#define SetAddressEntryAttrsA(addr, tags) \
	((ULONG (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 294))(addr, tags, (struct Library *) AML_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SetAddressEntryAttrs(addr, tags...) \
	({ULONG _tags[] = {tags}; SetAddressEntryAttrsA((addr), () _tags);})
#endif

#define MatchAddressA(addr, tags) \
	((BOOL (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 300))(addr, tags, (struct Library *) AML_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define MatchAddress(addr, tags...) \
	({ULONG _tags[] = {tags}; MatchAddressA((addr), () _tags);})
#endif

#define FindAddressEntryA(server, tags) \
	((APTR (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 306))(server, tags, (struct Library *) AML_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define FindAddressEntry(server, tags...) \
	({ULONG _tags[] = {tags}; FindAddressEntryA((server), () _tags);})
#endif

#define HuntAddressEntryA(server, tags) \
	((APTR (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 312))(server, tags, (struct Library *) AML_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define HuntAddressEntry(server, tags...) \
	({ULONG _tags[] = {tags}; HuntAddressEntryA((server), () _tags);})
#endif

#define ScanAddressIndex(server, hook, type, flags) \
	((ULONG (*)(APTR __asm("a0"), struct Hook * __asm("a1"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 318))(server, hook, type, flags, (struct Library *) AML_BASE_NAME)

#define AddCustomField(addr, field, data) \
	((BOOL (*)(APTR __asm("a0"), STRPTR __asm("a1"), STRPTR __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 324))(addr, field, data, (struct Library *) AML_BASE_NAME)

#define RemCustomField(addr, field) \
	((BOOL (*)(APTR __asm("a0"), STRPTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 330))(addr, field, (struct Library *) AML_BASE_NAME)

#define GetCustomFieldData(addr, field) \
	((STRPTR (*)(APTR __asm("a0"), STRPTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 336))(addr, field, (struct Library *) AML_BASE_NAME)

#define CreateDecoderA(tags) \
	((APTR (*)(struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 342))(tags, (struct Library *) AML_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define CreateDecoder(tags...) \
	({ULONG _tags[] = {tags}; CreateDecoderA((Tag) _tags);})
#endif

#define DisposeDecoder(dec) \
	((VOID (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 348))(dec, (struct Library *) AML_BASE_NAME)

#define GetDecoderAttrsA(dec, tags) \
	((ULONG (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 354))(dec, tags, (struct Library *) AML_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define GetDecoderAttrs(dec, tags...) \
	({ULONG _tags[] = {tags}; GetDecoderAttrsA((dec), () _tags);})
#endif

#define SetDecoderAttrsA(dec, tags) \
	((ULONG (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 360))(dec, tags, (struct Library *) AML_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SetDecoderAttrs(dec, tags...) \
	({ULONG _tags[] = {tags}; SetDecoderAttrsA((dec), () _tags);})
#endif

#define Decode(dec, type) \
	((LONG (*)(APTR __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 366))(dec, type, (struct Library *) AML_BASE_NAME)

#define Encode(dec, type) \
	((LONG (*)(APTR __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) AML_BASE_NAME) - 372))(dec, type, (struct Library *) AML_BASE_NAME)

#endif /*  _INLINE_AML_H  */
