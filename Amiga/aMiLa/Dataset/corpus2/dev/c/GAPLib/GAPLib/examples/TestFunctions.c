/*
 * Five functions which can be used for testing GA:s.
 *
 * Note that the functions negate their value before returning it,
 * this is because GAP-Lib sees higher fitness as better.
 *
 * See also the Images/DeJong?.png
 *
 */

#include <GAP.h>
#include <math.h>

/* DeJong Function #1 
 * Global minimum at (0,0)
 */

struct Polyphant1 {
	unsigned long	x[3];
};

double DeJong1(struct Polyphant1 *Polly)
{
int i;
double d=0;
for(i=0;i!=3;i++) {
	d += pow(IRange(Polly->x[i],-5.12,5.12),2.0);	
}
return(-d);
}

/* DeJong Function #2 
 * Global minimum at (1,1)
 */

struct Polyphant2 {
	unsigned long	x,y;
};

double DeJong2(struct Polyphant2 *Polly)
{
double x,y,d;
x = IRange(Polly->x,-2.048,2.048);
y = IRange(Polly->y,-2.048,2.048);
d=100.0*pow((pow(x,2.0)-y),2.0)+pow((1.0-x),2.0);
return(-d);
}

/* DeJong Function #3 
 * Global minimum when x<-5.0 and y<-5.0
 */

struct Polyphant3 {
	unsigned long	x[5];
};

double DeJong3(struct Polyphant3 *Polly)
{
int i;
double d=0;
for(i=0;i!=5;i++) {
	d += floor(IRange(Polly->x[i],-5.12,5.12));	
}
return(-d);
}

/* DeJong Function #4
 * Global minimum at (0,0,0,...,0)
 * (Disregarding noise)
 */

struct Polyphant4 {
	unsigned long	x[30];
};

double DeJong4(struct Polyphant4 *Polly)
{
int i;
double d=0;
for(i=0;i!=30;i++) {
	d += i*pow(IRange(Polly->x[i],-1.28,1.28),4.0)+GaussRand(0.0,1.0);
}
return(-d);
}

/* DeJong Function #5
 * Global minimum at (-32,-32)
 */

struct Polyphant5 {
	unsigned long	x[2];
};

double DeJong5(struct Polyphant5 *Polly)
{
const double K = 500.0;
const double a[2][25] = {
	{-32,-16,  0, 16, 32,
	 -32,-16,  0, 16, 32,
	 -32,-16,  0, 16, 32,
	 -32,-16,  0, 16, 32,
	 -32,-16,  0, 16, 32},

	{-32,-32,-32,-32,-32,
	 -16,-16,-16,-16,-16,
	   0,  0,  0,  0,  0,
	  16, 16, 16, 16, 16,
	  32, 32, 32, 32, 32}
};
double d,o,u;
int i,n;

o = 0.0;

for(i=0;i!=25;i++) {
	u = (double)i;
	for(n=0;n!=2;n++) {
		u += 1.0/pow(IRange(Polly->x[n],-65.536,65.536)-a[n][i],6.0);
	}
	o += u;
}

d = 1.0/(1.0/K+o);

return(-d);
}
