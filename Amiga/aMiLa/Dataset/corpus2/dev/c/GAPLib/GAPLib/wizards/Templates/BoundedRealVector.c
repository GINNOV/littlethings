

void Init$N(struct $N *Polly)	$2/* Initialize but keep within constrints. */$
{
int i;
for(i=0;i!=VLENGTH$I;i++) {
	Polly->v[i] = InRand(Constraints$I[i][0],Constraints$I[i][1]);
}
}

void Mutate$N(struct $N *Polly)	$2/* Mutate by changeing a value in the vector. */$
{
int i;

for(i=0;i!=VLENGTH$I;i++) {
	if(Rnd(1024)==512) {
		Polly->v[i] = InRand(Constraints$I[i][0],Constraints$I[i][1]);
	}
}

$4
   NAME
        InRand -- Generate a bounded floating point pseudo-random number.

   SYNOPSIS
        double InRand(double,double);

        Val = InRand(Lo,Hi);

   FUNCTION
        Generates a pseudo random number between Lo and Hi. The resolution of
        the generated number is in steps of (Hi-Lo)/2147483646.
$

}

$1/* Multipoint crossover for this genome is a numerical crossover. */
$
void Cross$N(struct $N *Polly, struct $N *Tweety)
{
int i;
#ifndef	MPCROSS$I
double t;
i = Rnd(VLENGTH$I+1);
for(;i<VLENGTH$I;i++) {
	t = Polly->v[i];
	Polly->v[i] = Tweety->v[i];
	Tweety->v[i] = t;
}
#else
double	delta,dpos,avg;

for(i=0;i!=VLENGTH$I;i++) {
	delta = fabs(Polly->v[i]-Tweety->v[i]);
	if(delta>DBL_EPSILON) {
		dpos = InRand(-delta,delta);
		avg = (Polly->v[i]+Tweety->v[i])/2.0;	$2/* N-dimensional point between the vectors. */$
		Polly->v[i] = avg+dpos;
		Tweety->v[i] = avg-dpos;
	}
}
#endif
}

$1/* Standard euclidian length of the difference vector. */
$
double Compare$N(struct $N *Polly,struct $N *Tweety)
{
double	l=0,t;
int i;

for(i=0;i!=VLENGTH$I;i++) {
	t = Polly->v[i]-Tweety->v[i];
	l += t*t;
}

return(sqrt(l));	$3/* Not quite necessary, but neater. */$
}

void Kill$N(struct $N *Polly)
{
;
}
