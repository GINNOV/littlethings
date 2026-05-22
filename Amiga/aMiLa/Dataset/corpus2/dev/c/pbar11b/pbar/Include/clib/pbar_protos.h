
#include <utility/tagitem.h>

APTR CreatePBarA(struct TagList *taglist);
APTR CreatePBar(Tag *ft, ...);
void UpdatePBarA(APTR pbar, struct TagList *taglist);
void UpdatePBar(APTR pbar, Tag *ft, ...);
void RefreshPBar(APTR pb);
void FreePBar(APTR pb);
void ClearPBar(APTR pbar);
