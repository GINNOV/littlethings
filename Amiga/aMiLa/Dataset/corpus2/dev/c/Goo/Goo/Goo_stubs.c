// Goo.library stubs

#include <exec/types.h>
#include <intuition/intuition.h>
#include <utility/tagitem.h>
#include <stdarg.h>

#include "Goo.h"

BOOL GOO_NewObjectTags(struct GOOWindow *GOOWindow, ...)
{
  BOOL Result;
  va_list Args;
  
  va_start(Args, GOOWindow);
  Result = GOO_NewObject(GOOWindow, (struct TagItem *)Args);
  va_end(Args);
  return(Result);
}

struct GOOWindow *GOO_OpenWindowTags(struct Screen *Screen, ...)
{
  struct GOOWindow *Win;
  va_list Args;
  
  va_start(Args, Screen);
  Win = GOO_OpenWindow(Screen, (struct TagItem *)Args);
  va_end(Args);
  return(Win);
}

BOOL GOO_SetObjectAttrTags(struct GOOWindow *GOOWindow, ULONG ID, ...)
{
  BOOL Result;
  va_list Args;
  
  va_start(Args, ID);
  Result = GOO_SetObjectAttr(GOOWindow, ID, (struct TagItem *)Args);
  va_end(Args);
  return(Result);
}

