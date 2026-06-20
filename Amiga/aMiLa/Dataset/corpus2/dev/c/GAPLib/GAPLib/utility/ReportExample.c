/*
 * Modified Minimal Example Function Optimization.
 *
 * This example has been modified to show the useage of
 * the report generation utility code accompanying GAP-Lib.
 */

#include <time.h>
#include <stdio.h>
#include <GAP.h>

#include "report.h"

/* The representation of the individuals. */

struct Polyphant {
   unsigned char  v;
};

double fitfunc(struct Polyphant *);

int main(void)
{
struct Population *Pop;
struct Report *Rep;
int i,n;

struct TagItem RepTags[] = {
	{REP_Multipass,TRUE},	/* Generate averages from several runs. */
	{REP_Generations,25},	/* 25 generations in each run.  */
	{TAG_DONE,0L}
};

struct TagItem EvolveTags[] = {
	{EVL_Evaluator,(IPTR)fitfunc},
	{TAG_DONE,0L}
};

EnterGAP(2); /* Initialize environment. */
InitRand(time(NULL));   /* Initialize random number generator. */

Rep = MakeReport("Example",RepTags);	/* Create a report structure. */

for(n=0;n!=8;n++) {	/* Perform 8 runs of this GA. */

	Pop = CreatePopulation(20,sizeof(struct Polyphant),NULL); /* Create a population. */

	if(Pop!=NULL) {
	   printf("Run %d, created %ld individuals.\n",n,Pop->NumPolys);
	   for(i=0;i!=25;i++) { /* Evolve 25 generations. */
	      Pop = Evolve(Pop,EvolveTags);
			DoReport(Rep,Pop,AVERAGE|MAX);
	   }
	   DeletePopulation(Pop);

	} else {
	   fprintf(stderr,"Unable to create population.\n");
	}
}

EndReport(Rep);

return(0);
}

double fitfunc(struct Polyphant *p)
{
return((double)p->v);
}
