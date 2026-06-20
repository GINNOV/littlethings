extern void RemoveGfxWindow 
	(struct GfxView * GV,struct GfxWindow *GW);
extern struct GfxWindow * AddGfxWindow 
	(struct GfxView * GV,struct TagItem *TagList);
extern void ModifyGfxWindow
	(struct GfxWindow * GfxWindow,struct TagItem *TagList);
