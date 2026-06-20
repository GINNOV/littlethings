
#include <stdlib.h>
#include <GAP.h>

int CreateTagList(void);
int AddTag(int,int,int);
void DeleteTagList(int);


struct TagLink {
	struct TagItem	tags[2];
};

static void AddItem(int id,int tagid,int data);
static struct TagLink *MakeTagLink(void);


int CreateTagList(void)
{
struct TagLink *tl;
tl = MakeTagLink();

tl->tags[0].ti_Tag = TAG_IGNORE;

return((int)tl);
}

int AddTag(int id,int tagid,int data)
{
if(id!=0) {
	AddItem(id,tagid,data);
}
return(id);
}

void DeleteTagList(int id)
{
struct TagLink *tl,*ttl;

tl = (struct TagLink *)id;

while(tl!=0) {
	ttl = (struct TagLink *)tl->tags[1].ti_Data;
	free(tl);
	tl = ttl;
}

}

static void AddItem(int id,int tagid,int data)
{
struct TagLink *tl,*ttl;

tl = MakeTagLink();

tl->tags[0].ti_Tag = tagid;
tl->tags[0].ti_Data = data;

ttl = (struct TagLink *)id;

while(ttl->tags[1].ti_Data!=0) {
	ttl = (struct TagLink *)ttl->tags[1].ti_Data;
}

ttl->tags[1].ti_Data = (IPTR) tl;

}

static struct TagLink *MakeTagLink(void)
{
struct TagLink *tl;
tl = malloc(sizeof(struct TagLink));
tl->tags[1].ti_Tag = TAG_MORE;
tl->tags[1].ti_Data = 0;
return(tl);
}
