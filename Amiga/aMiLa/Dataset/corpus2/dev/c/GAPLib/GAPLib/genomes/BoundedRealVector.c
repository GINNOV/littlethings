#include <math.h>
#include <float.h>
#include <stdio.h>
#include <GAP.h>

/*
 * Example bounded real-vector genome and functions for Crossover, Mutation,
 * Comparing, Initizlization and Displaying.
 *
 * A bounded vector is a vector where the elements are constrained to
 * specified ranges.
 */

#define	VLENGTH	3	/* Number of elements in the vector. */
#define	UCROSS	1	/* Crossover considers doubles to be unit length. */

/* Constaint ranges {Low,High} */
/* Note! All ranges are inclusive. */

static double	Constraints[VLENGTH][2] = {
	{-1.0,1.0},	/* v[0] */
	{-1.0,1.0}, /* v[1] */
	{-1.0,1.0}	/* v[2] */
};

struct BRVPolyphant	{
	double	v[VLENGTH];
};

void BRVInit(struct BRVPolyphant * );
void BRVMutate(struct BRVPolyphant * );
void BRVCross(struct BRVPolyphant * , struct BRVPolyphant *);
double BRVDiff(struct BRVPolyphant *,struct BRVPolyphant *);
void BRVDisplay(struct BRVPolyphant * );


void BRVInit(struct BRVPolyphant *Polly)
{
int i;
for(i=0;i!=VLENGTH;i++) {
	Polly->v[i] = InRand(Constraints[i][0],Constraints[i][1]);
}
}

void BRVMutate(struct BRVPolyphant *Polly)
{
int i;
	if(Rnd(1024)<(VLENGTH)) {
		i = Rnd(VLENGTH);
		Polly->v[i] = InRand(Constraints[i][0],Constraints[i][1]);
	}
}

void BRVCross(struct BRVPolyphant *Polly, struct BRVPolyphant *Tweety)
{
int i;
#ifdef	UCROSS
double t;
i = Rnd(VLENGTH+1);
for(;i<VLENGTH;i++) {
	t = Polly->v[i];
	Polly->v[i] = Tweety->v[i];
	Tweety->v[i] = t;
}
#else
double	delta,dpos,avg;

for(i=0;i!=VLENGTH;i++) {
	delta = fabs(Polly->v[i]-Tweety->v[i]);
	if(delta>DBL_EPSILON) {
		dpos = InRand(-delta,delta);
		avg = (Polly->v[i]+Tweety->v[i])/2.0;
		Polly->v[i] = avg+dpos;
		Tweety->v[i] = avg-dpos;
	}
}
#endif
}

double BRVDiff(struct BRVPolyphant *Polly,struct BRVPolyphant *Tweety)
{
double	l=0,t;
int i;

for(i=0;i!=VLENGTH;i++) {
	t = Polly->v[i]-Tweety->v[i];
	l += t*t;
}

return(sqrt(l));
}

void BRVDisplay(struct BRVPolyphant *Polly)
{
int i;
printf("(%.3lf",Polly->v[0]);
for(i=1;i<VLENGTH;i++) {
	printf(",%.3lf",Polly->v[i]);
}
printf(")\n");
}

