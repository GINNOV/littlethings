/*
*-----------------------------------------------------------------------------
*	file:		random.c
*	desc:		routine for a very-long-cycle random-number sequences
*	by:		patrick ko shu pui
*	date:		6 sep 1991
*	comment:
*
*	this random number generator was proved to generate random sequences
*	between 0 to 1 which if 100 numbers were calculated every second, it
*	would NOT repeat itself for over 220 years.
*
*	reference:
*
*	Wichmann B.A. and I.D. Hill. "Building A Random Number Generator."
*	Byte Magazine. March 1987. pp.127.
*
*	remark:		this C routine is a freeware
*
*	ko053@cucs19.cs.cuhk.hk	Internet 
*	BiG Programming Club (since 1987), Hong Kong, 6:700/132 FidoNet
*	[852] 654-8751
*-----------------------------------------------------------------------------
*/
#include	<time.h>
#ifdef AMIGA
#include <float.h>
#include <limits.h>
#define MAXFLOAT FLT_MAX
#define MAXINT   INT_MAX
#else
#include <values.h>
#endif


#include	"random.h"

#define	REAL	double
#define	INT	int

/*
*	default seed values
*/
static INT	x = 1;
static INT	y = 10000;
static INT	z = 3000;

/*
*=============================================================================
*	funct:		rndmize
*	dscpt:		generating random number seeds
*	given:		nothing
*	retrn:		nothing
*=============================================================================
*/
INT rndmize()
{
	time_t	timer;

	x = time( &timer ) % MAXINT;
	y = (x * x) % MAXINT;
	z = (y * y) % MAXINT;
}

/*
*=============================================================================
*	funct:		rnd
*	dscpt:		return a random number of range 0-1
*	given:		nothing
*	retrn:		the random number
*	cmmnt:		you may use prandomize to change the seeds
*=============================================================================
*/
REAL rnd()
{
	REAL	temp;

	/*
	*	first generator
	*/
	x = 171 * (x % 177) - 2 * (x / 177);
	if (x < 0)
		{
		x += 30269;
		}

	/*
	*	second generator
	*/
	y = 172 * (y % 176) - 35 * (y / 176);
	if (y < 0)
		{
		y += 30307;
		}

	/*
	*	third generator
	*/
	z = 170 * (z % 178) - 63 * (z / 178);
	if (z < 0)
		{
		z += 30323;
		}

	/*
	*	combine to give function value
	*/
	temp = x/30269.0 + y/30307.0 + z/30323.0;

	return (temp - (INT)temp);
}


/*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* * *				E X A M P L E
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*/
/*
int main()
{
	int 	i;

	rndmize();

	for (i=0; i<100; i++)
		{
		printf("%f,", rnd() );
		}
}
*/
