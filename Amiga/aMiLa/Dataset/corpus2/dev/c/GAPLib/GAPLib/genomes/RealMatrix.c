#include <stdio.h>
#include <stdlib.h>
#include <GAP.h>

/*
 * Example real-matrix genome and functions for Crossover, Mutation,
 * Comparing, Initizlization and Displaying.
 *
 */

#define	WIDTH		8
#define	HEIGHT	8

struct	RMPolyphant {
	double	matrix[HEIGHT][WIDTH];
	int	x,y;
};

void RMInit(struct RMPolyphant * );
void RMMutate(struct RMPolyphant * );
void RMCross(struct RMPolyphant * , struct RMPolyphant *);
void RMDisplay(struct RMPolyphant * );
double RMDist(struct RMPolyphant *,struct RMPolyphant *);

void RMInit(struct RMPolyphant *Polly) 
{
int x,y;

Polly->x = WIDTH;
Polly->y = HEIGHT;

for(x=0;x!=WIDTH;x++) {
	for(y=0;y!=HEIGHT;y++) {
		Polly->matrix[y][x] = Rnd(0x7ffffffe)/(double)Rnd(0x7ffffffe);
		if(Rnd(16)<8) {
			Polly->matrix[y][x] = -Polly->matrix[y][x];
		}
	}
}
	
}

void RMMutate(struct RMPolyphant *Polly)
{
int fx,fy;

fx = Rnd(Polly->x);
fy = Rnd(Polly->y);

Polly->matrix[fy][fx] = Rnd(0x7ffffffe)/(double)Rnd(0x7ffffffe);
if(Rnd(16)<8) {
	Polly->matrix[fy][fx] = -Polly->matrix[y][x];
}

}

void RMCross(struct RMPolyphant *Polly,struct RMPolyphant *Tweety)
{
int x,y,px,py;
double	t;

px = Rnd(Polly->x);
py = Rnd(Polly->y);

for(x=0;x!=Polly->x;x++) {
	for(y=0;y!=Polly->y;y++) {
		if((x<px && y<py) || (x>=px && y>=py)) {
			t = Polly->matrix[y][x];
			Polly->matrix[y][x] = Tweety->matrix[y][x];
			Tweety->matrix[y][x] = t;
		}
	}
}

}

void RMDisplay(struct RMPolyphant *Polly)
{
int x,y;

for(y=0;y!=Polly->y;y++) {
	printf("#");
	for(x=0;x!=Polly->x;x++) {
		printf("%+ 7.2lf #",Polly->matrix[y][x]);
	}
	printf("\n");
}

}

double RMDist(struct RMPolyphant *Polly,struct RMPolyphant *Tweety)
{
double sum=0.0,temp;
int x,y;

for(x=0;x!=WIDTH;x++) {
	for(y=0;y!=HEIGHT;y++) {
		temp = (Polly->matrix[y][x]-Tweety->matrix[y][x]);
		sum += temp*temp;
	}
}

return(sqrt(sum));
}
