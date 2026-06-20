
#include <GAP.hh>

/* Population implementation */

GPopulation::GPopulation(int Num,int Size,struct TagItem *TagList)
{
this->Pop = CreatePopulation(Num,Size,TagList);
}

GPopulation::GPopulation(int Num,int Size)
{
this->Pop = CreatePopulation(Num,Size,0);
}

GPopulation::~GPopulation()
{
DeletePopulation(this->Pop);
}

struct Popstat *GPopulation::GetStats(void)
{
return(&this->Pop->Stat);
}

void *GPopulation::GetMember(int n)
{
return(PopMember(this->Pop,n));
}

void GPopulation::Evolve(struct TagItem *TagList)
{
this->Pop = ::Evolve(this->Pop,TagList);
}

void GPopulation::Evolve(TagSet *Set)
{
this->Pop = ::Evolve(this->Pop,Set->List());
}

int GPopulation::GetSize(void)
{
return(this->Pop->NumPolys);
}

void GPopulation::SetSize(int newsize)
{
if(newsize>0) {
	this->Pop->NumPolys = newsize;
}
}

int GPopulation::GetGeneration(void)
{
return(this->Pop->Generation);
}

/* TagSet implementation */

TagSet::TagSet()
{
TagList = new struct TagItem[8];
TagList[0].ti_Tag = TAG_DONE;
MIdx = 7;
}

TagSet::TagSet(struct TagItem *Tags)
{
int i,n,t;
struct TagItem *tag;

i=n=t=0;
tag=Tags;

while(!n) {	/* Count no. of items in parameter taglist. */
	t++;
	switch(tag[i].ti_Tag) {
	case	TAG_DONE:
		n=1;
	continue;
	case	TAG_MORE:
		tag = (struct TagItem *)tag[i].ti_Data;
		i=0;
		t--;
	continue;
	}
	i++;
}

TagList = new struct TagItem[t];

MIdx = t-1;

i=n=t=0;
tag=Tags;

while(!n) {	/* Copy contents of parameter taglist. */
	TagList[t].ti_Tag = tag[i].ti_Tag;
	TagList[t].ti_Data = tag[i].ti_Data;
	t++;
	switch(tag[i].ti_Tag) {
	case	TAG_DONE:
		n=1;
	continue;
	case	TAG_MORE:
		tag = (struct TagItem *)tag[i].ti_Data;
		i=0;
		t--;
	continue;
	}
	i++;
}

}

TagSet::~TagSet()
{
struct TagItem *tag;

while((tag=Find(TAG_MORE))!=0) {
	tag = (struct TagItem *)tag->ti_Data;
	delete TagList;
	TagList = tag;
}

delete TagList;

}

void TagSet::Del(Tag type)
{
struct TagItem *tag;

tag = Find(type);

if(tag!=0) {
	tag->ti_Tag = TAG_IGNORE;
}

}

void TagSet::Set(Tag type,IPTR data)
{
struct TagItem *tag;

tag = Find(type);

if(tag!=0) {
	tag->ti_Data = data;
} else {
	tag = Find(TAG_DONE);
	if(CIdx<MIdx) {
		tag[1].ti_Tag = TAG_DONE;
		tag->ti_Tag = type;
		tag->ti_Data = data;
	} else {
		tag->ti_Data = (IPTR) new struct TagItem[MIdx+1];
		tag->ti_Tag = TAG_MORE;
		tag = (struct TagItem *)tag->ti_Data;
		tag[1].ti_Tag = TAG_DONE;
		tag->ti_Tag = type;
		tag->ti_Data = data;
	}
}

}

IPTR TagSet::Get(Tag type)
{
struct TagItem *tag;
tag = Find(type);
if(tag!=0) {
	return(tag->ti_Data);
}

return(0);
}

int TagSet::Exists(Tag type)
{
struct TagItem *tag;
tag = Find(type);
if(tag!=0) {
	return(1);
}
return(0);
}

struct TagItem *TagSet::Find(Tag type)
{
int i;
struct TagItem *tag = TagList;

i = -1;
while(tag[++i].ti_Tag!=TAG_DONE) {
	if(tag[i].ti_Tag == type) {
		CIdx = i;
		return(&tag[i]);
	} else if(tag[i].ti_Tag == TAG_MORE) {
		tag = (struct TagItem *)tag[i].ti_Data;
		i = -1;
	}
}

return(0);
}
