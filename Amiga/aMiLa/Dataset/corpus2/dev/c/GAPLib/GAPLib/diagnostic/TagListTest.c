#include <stdio.h>
#include <string.h>
#include <GAP.h>

struct Testyphant {
	long int	foo[4];
};

double	dummy_evaluator(struct Testyphant *);
void	dummy_crosser(struct Testyphant*,struct Testyphant*);

int main(void)
{
int ret=0;
struct Population *Pop;
struct Testyphant *Testy;

struct TagItem TestTags[] = {
	{EVL_Mutator,0L},
	{EVL_Evaluator,0L},
	{TAG_IGNORE,4711L},
	{TAG_MORE,0L},
	{EVL_Stats,FALSE},	/* These two lines should never */
	{TAG_DONE,0L}			/* be used if all is well. */
};

struct TagItem Test2Tags[] = {
	{TAG_IGNORE,17L},
	{EVL_Crosser,(IPTR)dummy_crosser},
	{TAG_DONE,0L}
};

struct TagItem PopTags[] = {
	{POP_Init,ZERO_INIT},
	{POP_Cache,TRUE},
	{TAG_END,0L}
};

Pop = CreatePopulation(24,sizeof(struct Testyphant),PopTags);

if(Pop!=NULL) {
	TestTags[1].ti_Data = (IPTR) dummy_evaluator;
	TestTags[3].ti_Data = (IPTR) Test2Tags;

	Pop = Evolve(Pop,TestTags);

	Testy = PopMember(Pop,1);

	if(Testy->foo[0] == 0) {
		/* Possible error in TAG_MORE handling. */
		ret++;
		if(Pop->Stat.Generation == Pop->Generation) {
			/* Possible error in TAG_IGNORE handling. */
			ret++;
		}
	}

	if(Pop->Stat.Generation != Pop->Generation) {
		/* Possible error in TAG_MORE handling. */
		ret++;	
	}

	DeletePopulation(Pop);
} else {
	printf("***Error: Population Creation Failed.\n");
	ret = 20;
}

if(ret==0) {
	printf("TagList test: %s\n",(ret!=0)?"Failed!":"Ok.");
}

return(0);
}

double	dummy_evaluator(struct Testyphant *t)
{
static int i=0;
return((double)i++);
}

void	dummy_crosser(struct Testyphant *Polly,struct Testyphant *Tweety)
{
memset(Polly,0xff,sizeof(struct Testyphant));
memset(Tweety,0xff,sizeof(struct Testyphant));
}

