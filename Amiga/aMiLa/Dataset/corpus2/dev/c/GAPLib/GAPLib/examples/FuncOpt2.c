/*
 *
 * Function Optimization with very high rate of mutation and
 * harsh selection. 
 *
 * Fitness Function : f(x,y) = 21.5 + x*sin(4*PI*x) + y*sin(20*PI*y)
 * For x = ]-3,12.1[ and y = ]4.1,5.8[
 *
 * This program does in no way claim to be optimal, so as an exercise
 * you might consider to try and improve it.
 *
 */

#include <stdio.h>
#include <limits.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <GAP.h>

static long int Polyphant_Size;	/* No. of bits in one Polyphant. */

#ifndef	PI
#define	PI	3.141592653589793238462
#endif

struct   Polyphant {
	unsigned long	x1,x2;
};


double fitfunc(struct Polyphant *);
void mutator(struct Polyphant *,int);
void crosser(struct Polyphant *,struct Polyphant *,int);

/* Mutation frequencies. Higer = MoreCommon */

int   Common;
int   Uncommon;

int isvalid(struct Polyphant *);

int main(int cnt,char *arg[])
{
struct Population *Pop;
struct Polyphant *Polly;
int n,Generations=10;
FILE  *max,*average,*median;

struct   TagItem  EvolveTags[]={ /* Tags for the Evolve() function */
   {EVL_Dump,     0L},
   {EVL_Elite,    0L},
   {EVL_PreMutate,TRUE},
   {EVL_Evaluator,(IPTR)fitfunc},
   {EVL_Mutator,  (IPTR)mutator},
   {EVL_Crosser,  (IPTR)crosser},
   {EVL_Select,   DRANDOM},
   {TAG_DONE,     0L}
};

EnterGAP(2);

InitRand(time(NULL));

Polyphant_Size = sizeof(struct Polyphant) << 3;

if(cnt>2)   /* VERY simple argument parsing */
   fprintf(stderr,"%s [Generations]\n",arg[0]);

if(cnt==2) {
   Generations=atoi(arg[1]);  
   if(!Generations)
      Generations=10;
}

Pop=CreatePopulation(50,sizeof(struct Polyphant),NULL);   /* Create 50 Polyphants, 
																				 use default random init function. */
/* Report files. */

max=fopen("Max","wb");
average=fopen("Average","wb");
median=fopen("Median","wb");

if(Pop && max && average && median) {

   /* Change these to control the rate of mutation. */
	/* Total mutationrate = (10/32 + 10/32)/32 ~= 2% per bit. */
   Common = 10;    /* Rate of common mutations (10/32) */
   Uncommon=10;    /* Rate of uncommon mutations (10/32) */

   for(n=0;n!=Generations;n++) {

      Pop=Evolve(Pop,EvolveTags);

      if(n<((Pop->NumPolys)>>2)) {  /* Change elitism and dumping on the fly. */
         EvolveTags[0].ti_Data=n>>2;   /* Dump */
         EvolveTags[1].ti_Data=n;   /* Elite */
      }

      printf("Generation %ld : Average = %f, Max = %f, Med = %f\n",Pop->Generation,Pop->Stat.AverageFitness,Pop->Stat.MaxFitness,Pop->Stat.MedianFitness);

      fprintf(max,"%ld.0 %f\n",Pop->Generation,Pop->Stat.MaxFitness);
      fprintf(average,"%ld.0 %f\n",Pop->Generation,Pop->Stat.AverageFitness);
      fprintf(median,"%ld.0 %f\n",Pop->Generation,Pop->Stat.MedianFitness);

   } /* n */

	Polly = Pop->Stat.Max;
   printf("Finished: Best individual (%f,%f).\n",IRange(Polly->x1,-3.0,12.1),IRange(Polly->x2,4.1,5.8));

} else { /* (Pop && max && average && median) */
   fprintf(stderr,"Initialization failed!\n");
}

if(Pop) DeletePopulation(Pop); /* Finished */
if(max) fclose(max);
if(average) fclose(average);
if(median) fclose(median);

return(0);
}

double fitfunc(struct Polyphant *Polly)
{
double x1,x2;
x1 = IRange(Polly->x1,-3.0,12.1);
x2 = IRange(Polly->x2,4.1,5.8);
return( 21.5 + x1*sin(4*PI*x1) + x2*sin(20*PI*x2) );
}

void mutator(struct Polyphant *Polly,int Size)
{
int i;

if(Rnd(32)<Common) { /* common mutation */
      Flip(Polly,Rnd(Size<<3));
} else if(Rnd(32)<Uncommon) { /* uncommon mutation */
   for(i=0;i!=Size;i++) {
		((char *)Polly)[i]=Rnd(256);
	}

if(Polly->x1 == 0) {
	Polly->x1+=1;
}
if(Polly->x1 == ULONG_MAX) {
	Polly->x1-=1;
}
if(Polly->x2 == 0) {
	Polly->x2+=1;
}
if(Polly->x2 == ULONG_MAX) {
	Polly->x2-=1;
}


}

}

void crosser(struct Polyphant *Polly,struct Polyphant *Tweety,int Size)
{
Crossover(&(Polly->x1),&(Tweety->x1),Rnd(sizeof(long)<<3),sizeof(long));
Crossover(&(Polly->x2),&(Tweety->x2),Rnd(sizeof(long)<<3),sizeof(long));
if(Rnd(4)==2) {
	Crossover(Polly,Tweety,Rnd(Size<<3),Size);
}

if(Polly->x1 == 0) {
	Polly->x1+=1;
}
if(Polly->x1 == ULONG_MAX) {
	Polly->x1-=1;
}
if(Polly->x2 == 0) {
	Polly->x2+=1;
}
if(Polly->x2 == ULONG_MAX) {
	Polly->x2-=1;
}

if(Tweety->x1 == 0) {
	Tweety->x1+=1;
}
if(Tweety->x1 == ULONG_MAX) {
	Tweety->x1-=1;
}
if(Tweety->x2 == 0) {
	Tweety->x2+=1;
}
if(Tweety->x2 == ULONG_MAX) {
	Tweety->x2-=1;
}

}
