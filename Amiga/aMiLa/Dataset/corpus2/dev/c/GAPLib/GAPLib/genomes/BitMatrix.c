#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <GAP.h>

/*
 * Example bit-matrix genome and functions for Crossover, Mutation,
 * Comparing, Initizlization and Displaying.
 *
 */

#define	WIDTH		64
#define	HEIGHT	64

struct BMPolyphant {
	unsigned char	matrix[HEIGHT][WIDTH>>3];	/* Rows x Columns, 1 Byte = 8 Bits */
	int	x,y,xb;
};

void BMCross(struct BMPolyphant *,struct BMPolyphant *);
void BMInit(struct BMPolyphant *);
void BMMutate(struct BMPolyphant *);
void BMDisplay(struct BMPolyphant *);
double BMDist(struct Polyphant *,struct Polyphant *);

void BMInit(struct BMPolyphant *Polly)
{
int	x,y;

Polly->x = WIDTH;	/* Width in bits. */
Polly->y = HEIGHT;	/* Height in bits. */
Polly->xb = WIDTH>>3;	/* Width in bytes. */

for(x=0;x!=(WIDTH>>3);x++) {
	for(y=0;y!=HEIGHT;y++) {
		Polly->matrix[y][x] = Rnd(256);
	}
}

}

void BMMutate(struct BMPolyphant *Polly)
{
int fx,fy;

if(Rnd(1024)<(Polly->x*Polly->y)) {
	fx = Rnd(Polly->x);
	fy = Rnd(Polly->y);
	Flip(&Polly->matrix[fy][fx>>3],fx&7);
}

}

void BMCross(struct BMPolyphant *Polly,struct BMPolyphant *Tweety)
{
int	x,y,i,size=Polly->xb;
char	*tmp;

if((tmp=malloc(size))!=NULL) {

	x = Rnd(Polly->x);
	y = Rnd(Polly->y);

	for(i=0;i<y;i++) {	/* Swap rows. */
		memcpy(tmp,Polly->matrix[i],size);
		memcpy(Polly->matrix[i],Tweety->matrix[i],size);
		memcpy(Tweety->matrix[i],tmp,size);
	}

	free(tmp);

	for(i=0;i<Polly->y;i++) {	/* Swap columns. */
		Crossover(Polly->matrix[i],Tweety->matrix[i],x,size);
	}
}

}

void BMDisplay(struct BMPolyphant *Polly)
{
int x,y;

for(y=0;y<Polly->y;y++) {
	for(x=0;x<Polly->x;x++) {
		fputc((TestBit(Polly->matrix[y],x))?'*':' ',stdout);
	}
	fputc('\n',stdout);
}

}

double BMDist(struct BMPolyphant *Polly,struct BMPolyphant *Tweety)
{
return(HammingDist(Polly.matrix,Tweety.matrix,(WIDTH>>3)*HEIGHT));
}
