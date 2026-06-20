
void Init$N(struct $N *Polly)
{
int	x,y;

Polly->x = WIDTH$I;	$1/* Width in bits. */$
Polly->y = HEIGHT$I;	$1/* Height in bits. */$
Polly->xb = WIDTH$I>>3;	$1/* Width in bytes. */$

$2/* Initialize to zero or random depending on the ZINIT macro. */$

#ifdef	ZINIT$I
for(x=0;x!=(WIDTH$I>>3);x++) {
	for(y=0;y!=HEIGHT$I;y++) {
		Polly->matrix[y][x] = 0;
	}
}
#else
for(x=0;x!=(WIDTH$I>>3);x++) {
	for(y=0;y!=HEIGHT$I;y++) {
		Polly->matrix[y][x] = Rnd(256);
	}
}
#endif

}

void Mutate$N(struct $N *Polly)	$3/* Flip a random bit at random. */$
{
int fx,fy;

if(Rnd(1024)==512) {
	fx = Rnd(Polly->x);
	fy = Rnd(Polly->y);
	Flip(&Polly->matrix[fy][fx>>3],fx&7);
$4/*
   NAME
        Flip -- Flip a bit in a bitstring.

   SYNOPSIS
        void Flip(void *,int);

        Flip(Ind,At);

   FUNCTION
        Flips a bit in a bitstring. Bits are counted from lower addresses to
        higher.
*/
$}

}

void Cross$N(struct $N *Polly,struct $N *Tweety)
{
int	x,y,i,size=Polly->xb;
char	*tmp;

$4/*
 *
 * Allocate a temporary buffer for crossover, this could be static
 * if no multithreading is done.
 * This would probably increase efficiency slightly.
 *
*/$

if((tmp=malloc(size))!=NULL) {

	x = Rnd(Polly->x);	$3/* This comment is here just to irritate you! */$
	y = Rnd(Polly->y);

	for(i=0;i<y;i++) {	$1/* Swap rows. */$
		memcpy(tmp,Polly->matrix[i],size);
		memcpy(Polly->matrix[i],Tweety->matrix[i],size);
		memcpy(Tweety->matrix[i],tmp,size);
	}

	free(tmp);

	for(i=0;i<Polly->y;i++) {	$1/* Swap columns. */$
		Crossover(Polly->matrix[i],Tweety->matrix[i],x,size);
	}
$4/*
   NAME
        Crossover -- Perform crossover on two bitstrings.

   SYNOPSIS
        void Crossover(void *,void *,int,int);

        Crossover(void *Ind1,void *Ind2,int At,int Size);

   FUNCTION
        Performs one-point crossover of two bitstrings. The bitstrings must
        have the same length.
*/
$}

#ifdef	MPCROSS$I
if(Rnd(1024)<128) {	$1/* One chance in eight. */$
	Cross$N(Polly,Tweety);
}
#endif

}

$3/* Another meaningless comment. */$

double Compare$N(struct $N *Polly,struct $N *Tweety,int size)
{
return((double)HammingDist(Polly->matrix,Tweety->matrix,Polly->xb*Polly->y));
$4/*
   NAME
        HammingDist -- Measure the Hamming distance between two bitstrings.

   SYNOPSIS
        unsigned long int HammingDist(void *,void *,int);

        distance = HammingDist(Ind1,Ind2,Size);

   FUNCTION
        Counts the number of differings bits in two bitstrings.
*/
$}

void Kill$N(struct $N *Polly) $3/* Free resources if needed (not needed) */$
{
;
}

