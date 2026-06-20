/*
 * Minimal Example Function Optimization.
 *
 * Lots of improvements could be made such as adding a wee bit of
 * elitism and using a mutator with higher mutational probability, but
 * it really is only meant as an example of how short you can make
 * this program with GAP-Lib. (Though adding less than one line of code
 * will make it several times as good. :-)
 *
 * Fitness function: f(x) = x
 *
 * Population : 20 Individuals
 *
 */

#include <time.h>
#include <stdio.h>
#include <GAP.h>

/* The representation of the individuals. */

struct Polyphant {
   unsigned char  v;
};

double fitfunc(struct Polyphant *);

int main(void)
{
struct Population *Pop;
int i;

EnterGAP(2); /* Initialize environment. */
InitRand(time(NULL));   /* Initialize random number generator. */

Pop = CreatePopulation(20,sizeof(struct Polyphant),NULL); /* Create a population. */

if(Pop!=NULL) {
   printf("Created %ld individuals.\n",Pop->NumPolys);
   for(i=0;i!=25;i++) { /* Evolve 25 generations. */
      Pop = EvolveT(Pop,EVL_Evaluator,fitfunc,TAG_DONE);
      printf("Generation %ld: Best value = %.03f, Avg = %.03f, Median = %.03f\n",Pop->Generation,Pop->Stat.MaxFitness,Pop->Stat.AverageFitness,Pop->Stat.MedianFitness);
   }

   printf("After 25 generations: Best individual = %ld\n",((struct Polyphant *)Pop->Stat.Max)->v);
   DeletePopulation(Pop);
} else {
   fprintf(stderr,"Unable to create population.\n");
}

return(0);
}

double fitfunc(struct Polyphant *p)
{
return((double)p->v);
}
