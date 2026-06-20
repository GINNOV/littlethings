/*
 * GAP-Lib tutorial source.
 *
 */

#include <stdio.h>
#include <GAP.h>
#include <math.h>
#include <limits.h>
#include <time.h>

struct Polyphant {
   unsigned long value;
};

void init(struct Polyphant *);
double fitfunc(struct Polyphant *);

#ifndef	PI
#define	PI	3.14159265
#endif

int main(void)
{
int i;
struct Population *Pop;
struct Polyphant *Individual;
struct TagItem EvolveTags[]={
   {EVL_Evaluator,(IPTR)fitfunc},
   {TAG_DONE,0L}
};


EnterGAP(2);

InitRand(time(NULL));

Pop = CreatePopulationT(20,sizeof(struct Polyphant),POP_Init,init,TAG_DONE);

for(i=0;i!=50;i++) {
   Pop = Evolve(Pop,EvolveTags);
   printf("Generation %d: Max = %lf\n",i+1,Pop->Stat.MaxFitness);
}

Individual = Pop->Stat.Max;

printf("After %d generations:\n",i);
printf("Best value = %lf.\n",Pop->Stat.MaxFitness);
printf("For f(%lf).\n",IRange(Individual->value,0.0,PI));

DeletePopulation(Pop);

return(0);
}

void init(struct Polyphant *Polly)
{
/* Rnd() only returns values between 0 and max 2147483646 (30 bits) */
Polly->value = Rnd(0x7ffffffe)^(Rnd(0x7ffffffe)<<2);
}

double fitfunc(struct Polyphant *Polly)
{
double x;
x = IRange(Polly->value,0.0,PI);
return(x+sin(32*x));
}



