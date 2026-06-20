

void	Init$N(struct $N *Polly)	$2/* Initialization function. */$
{
int	i;

#ifdef	ZINIT$I
for(i=0;i!=SIZE$I;i++) {
	((char *)Polly->Data)[i]=0;	$2/* Zero init */$
}
#else
for(i=0;i!=SIZE$I;i++) {
	((char *)Polly->Data)[i]=Rnd(256);	$2/* Random init */$
}
#endif
}

void Mutate$N(struct $N *Polly)
{
int i;
for(i=0;i!=(SIZE$I<<3);i++) {
	if (Rnd (1024) == 512) {
		Flip(Polly,(long)i);	$3/* Flip a random bit one in 1024 times. */$
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
$	}
}
}

void Cross$N(struct $N *Polly,struct $N *Tweety)
{
#ifdef	MPCROSS$I
int i;

for(i=0;i!=(SIZE$I<<3);i++) {
	if(Rnd(128)==64) {
		Crossover(Polly,Tweety,i,(long)SIZE$I);
	}
}
#else
Crossover(Polly,Tweety,Rnd((long)SIZE$I<<3),(long)SIZE$I);
#endif
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

double Compare$N(struct $N *Polly,struct $N *Tweety,int i)
{
return((double)HammingDist(Polly,Tweety,i));
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

void Kill$N(struct $N *Polly)
{
;
}
