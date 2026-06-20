#include <simple/gen.h>

#include "global.h"
#include "gfxobj.h"
#include "gfxwin.h"
#include "gfxview.h"

struct GfxView * CreateGfxViewTags (ulong FirstTag, ... )
{
return( CreateGfxView ( (struct TagItem *) &FirstTag ) );
}

struct GfxWindow * AddGfxWindowTags (struct GfxView * GfxView,ulong FirstTag, ... )
{
return( AddGfxWindow ( GfxView, (struct TagItem *) &FirstTag ) );
}

struct GfxObject * AddGfxObjectTags (struct GfxWindow *GfxWindow,ulong FirstTag, ... )
{
return( AddGfxObject ( GfxWindow, (struct TagItem *) &FirstTag ) );
}

void ModifyGfxWindowTags(struct GfxWindow * GfxWindow,ulong FirstTag, ...)
{
ModifyGfxWindow ( GfxWindow, (struct TagItem *) &FirstTag );
}

void ModifyGfxObjectTags(struct GfxObject * GfxObject,ulong FirstTag, ...)
{
ModifyGfxObject ( GfxObject, (struct TagItem *) &FirstTag );
}

