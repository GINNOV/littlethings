BOOL	MakePath (char *path);		/* MakePath.c	*/
char *	AddToolType (struct DiskObject *dobj, char *tool);		/* AddToolType.c	*/
int	ToolMatch (char *s1, char *s2);		/* AddToolType.c	*/
LONG	FileType (char *file);		/* FileType.c	*/
struct Image *	MakeNewImg (struct Image *img, ULONG *pal);		/* MakeNewImg.c	*/
UBYTE	FCopy (char *source, char *dest, LONG buf);		/* FCopy.c	*/
UBYTE	RecDirInit (struct RecDirInfo *rdi);		/* RecDirInit.c	*/
UBYTE	RecDirNext (struct RecDirInfo *rdi, struct RecDirFIB *rdf);		/* RecDirNext.c	*/
UBYTE	RecDirNextTagList (struct RecDirInfo *rdi, struct RecDirFIB *rdf, struct TagItem *tagList);		/* RecDirTags.c	*/
UBYTE	RecDirNextTags (struct RecDirInfo *rdi, struct RecDirFIB *rdf, ULONG tagItem1, ...);		/* RecDirTags.c	*/
ULONG	ObtPens (struct ColorMap *cm, ULONG *paltab, LONG *pens, struct TagItem *tags);		/* ObtPens.c	*/
void	FreeNewImg (struct Image *img);		/* FreeNewImg.c	*/
void	RecDirFree (struct RecDirInfo *rdi);		/* RecDirFree.c	*/
void	RelPens (struct ColorMap *cm, ULONG *table, ULONG *pal);		/* RelPens.c	*/
