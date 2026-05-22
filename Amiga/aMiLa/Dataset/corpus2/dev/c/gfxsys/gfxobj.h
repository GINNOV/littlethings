extern void RemoveGfxObject
	(struct GfxWindow *GfxWindow,struct GfxObject *GfxObject);

extern struct GfxObject * AddGfxObject
	(struct GfxWindow *GfxWindow,struct TagItem *TagList);

extern void ModifyGfxObject
	(struct GfxObject *GfxObject,struct TagItem *TagList);
