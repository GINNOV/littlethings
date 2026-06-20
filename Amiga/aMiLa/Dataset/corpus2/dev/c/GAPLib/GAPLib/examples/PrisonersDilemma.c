/*
 * The iterated prisoners dilemma.
 *
 *
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <GAP.h>

struct Polyphant {
	unsigned short int Initial;
	unsigned short int Rules;
};

/*
 * Rules:
 *
 * Bit No. :  15 - 00 represents the combination of Cooperate/Defect for the
 * last two games like below and the bit value is 1 = cooperate, 0 = defect. Example:
 *
 * DDDD DDDC DDCD DDCC DCDD DCDC DCCD DCCC CDDD CDDC CDCD CDCC CCDD CCDC CCCD CCCC
 *   0    0    1    1    0    0    1    1    0    0    1    1    0    0    1    1   
 *
 * Initial is used to set up two hypothetical games for the first match.
 *
 * Scoring:
 *
 *           Defect  | Cooperate
 *    Defect   1/1   |    5/0
 *          ---------+----------
 * Cooperate   0/5   |    3/3
 *
 */

double Play(struct Polyphant *);	/* Fitness function. */

struct Population *Pop;

static const int ScoreMatrix[2][2] = {
	{3,-1},
	{5,1}
};

int main(int cnt,char *arg[])
{
int i,n;
unsigned short int tft = 0x3333;
struct Polyphant *Polly;

struct TagItem CreateTags[] = {
	{POP_Init,RAND_INIT},
	{TAG_DONE,0L}
};

struct TagItem EvolveTags[] = {
	{EVL_Evaluator,(IPTR)Play},
	{EVL_Stats,TRUE},
	{EVL_Crowding,TRUE},
	{TAG_DONE,0L}
};

EnterGAP(2);

InitRand(time(0));

if(cnt>1) {
	n = atoi(arg[1]);
}

Pop = CreatePopulation(20,sizeof(struct Polyphant),CreateTags);


for(i=0;i<n;i++) {
	Pop = Evolve(Pop,EvolveTags);
	printf("Best score after %d generations: %lf\n",Pop->Generation,Play(Pop->Stat.Max));
	printf("Average: %lf\n",Pop->Stat.AverageFitness);
}

Polly = Pop->Stat.Max;

for(i=0;i!=16;i++) {
	printf((Polly->Rules&(32768>>i))?"C":"D");
}
printf("\nDistance from TFT = %d\n",HammingDist(&Polly->Rules,&tft,2));

DeletePopulation(Pop);

return(0);
}


double Play(struct Polyphant *Polly)
{
struct Polyphant *Tweety;
int last0,last1,act0,act1;
int score=0;
int i,n;

for(i=0;i!=Pop->NumPolys;i++) {
	Tweety = PopMember(Pop,i);
	last0 = Polly->Initial;
	last1 = Tweety->Initial;
	for(n=0;n!=16;n++) { /* 16 Matches. */
		act0 = (Polly->Rules&(1<<last0))?0:1;
		act1 = (Tweety->Rules&(1<<last1)?0:1);
		last0<<=1;
		last1<<=1;
		last0|=act0;
		last1|=act1;
		last0&=0xf;
		last1&=0xf;
		score += ScoreMatrix[act0][act1];
	}
}

return(((double)score)/((double)Pop->NumPolys));
}
