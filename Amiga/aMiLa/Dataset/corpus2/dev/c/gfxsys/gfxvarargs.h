
extern struct GfxView * CreateGfxViewTags (ulong FirstTag, ... );
extern struct GfxWindow * AddGfxWindowTags (struct GfxView * GfxView,ulong FirstTag, ... );
extern struct GfxObject * AddGfxObjectTags (struct GfxWindow *GfxWindow,ulong FirstTag, ... );
extern void ModifyGfxWindowTags(struct GfxWindow * GfxWindow,ulong FirstTag, ...);
extern void ModifyGfxObjectTags(struct GfxObject * GfxObject,ulong FirstTag, ...);
