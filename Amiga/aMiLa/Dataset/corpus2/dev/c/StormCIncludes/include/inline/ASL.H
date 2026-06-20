#ifndef _INLINE_ASL_H
#define _INLINE_ASL_H

#ifndef ASL_BASE_NAME
#define ASL_BASE_NAME AslBase
#endif

#define AllocFileRequest() \
	((struct FileRequester * (*)(struct Library * __asm("a6"))) \
  (((char *) ASL_BASE_NAME) - 30))((struct Library *) ASL_BASE_NAME)

#define FreeFileRequest(fileReq) \
	((VOID (*)(struct FileRequester * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) ASL_BASE_NAME) - 36))(fileReq, (struct Library *) ASL_BASE_NAME)

#define RequestFile(fileReq) \
	((BOOL (*)(struct FileRequester * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) ASL_BASE_NAME) - 42))(fileReq, (struct Library *) ASL_BASE_NAME)

#define AllocAslRequest(reqType, tagList) \
	((APTR (*)(ULONG __asm("d0"), struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) ASL_BASE_NAME) - 48))(reqType, tagList, (struct Library *) ASL_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define AllocAslRequestTags(reqType, tags...) \
	({ULONG _tags[] = {tags}; AllocAslRequest((reqType), (Tag) _tags);})
#endif

#define FreeAslRequest(requester) \
	((VOID (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) ASL_BASE_NAME) - 54))(requester, (struct Library *) ASL_BASE_NAME)

#define AslRequest(requester, tagList) \
	((BOOL (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) ASL_BASE_NAME) - 60))(requester, tagList, (struct Library *) ASL_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define AslRequestTags(requester, tags...) \
	({ULONG _tags[] = {tags}; AslRequest((requester), (Tag) _tags);})
#endif

#define AbortAslRequest(requester) \
	((VOID (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) ASL_BASE_NAME) - 78))(requester, (struct Library *) ASL_BASE_NAME)

#define ActivateAslRequest(requester) \
	((VOID (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) ASL_BASE_NAME) - 84))(requester, (struct Library *) ASL_BASE_NAME)

#endif /*  _INLINE_ASL_H  */
