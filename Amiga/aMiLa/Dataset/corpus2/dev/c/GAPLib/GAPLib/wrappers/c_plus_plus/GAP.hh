
#ifndef	__GAP_HH__
#define	__GAP_HH__

extern "C" {
#include <GAP.h>
}

/* Taglist object */

class TagSet {
public:
	TagSet();
	TagSet(struct TagItem *);
	~TagSet();

	void	Set(Tag,IPTR);
	IPTR	Get(Tag);
	void	Del(Tag);
	int	Exists(Tag);
	struct TagItem *List();

private:
	int	MIdx,CIdx;	/* MaxIndex & CurrentIndex */
	struct TagItem *Find(Tag);
	struct TagItem *TagList;
};

/* Population object */

class GPopulation {
public:
	GPopulation(int,int,struct TagItem *);
	GPopulation(int,int);
	~GPopulation();

	struct Popstat *GetStats(void);
	void	*GetMember(int);
	int GetSize(void);
	void SetSize(int);
	int GetGeneration(void);

	void Evolve(struct TagItem *);
	void Evolve(TagSet *);

private:
	struct Population *Pop;
};


#endif
