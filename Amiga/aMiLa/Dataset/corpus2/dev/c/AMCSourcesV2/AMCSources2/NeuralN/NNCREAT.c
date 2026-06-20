/*
*-----------------------------------------------------------------------------
*	file:	nncreat.c
*	desc:	create a fully connected neural net
*	by:	patrick ko
*	date:	v1.1u - 02 aug 91
*	revi:	v1.2b - 15 jan 92, adaptive coefficients (beta)
*		v1.3u - 17 jan 92, revised data structures
*-----------------------------------------------------------------------------
*/
#include	<stdio.h>
#ifdef		__TURBOC__
#include	<stdarg.h>
#include	<alloc.h>
#endif

#include	"nntype.h"
#include	"nnerror.h"
#include	"nncreat.h"
#include	"random.h"

REAL	UB=1.5;
REAL	LB=0.5;

/*
*=============================================================================
*	funct:	nn_creat
*	dscpt:	creat an nn object
*	given:	totallayer = total number of hidden and output layers
*		diminput = dimension of inputlayer
*		dimother = dimension of other layers
*	retrn:	allocated NET
*=============================================================================
*/
NET * nn_creat( totallayer, diminput, dimoutput, dimother )
INTEGER		totallayer;
INTEGER		diminput;
INTEGER 	dimoutput;
INTEGER		* dimother;
{
	INTEGER	i;
	INTEGER	dimwt;
	NET	*nntmp;
	INTEGER	dimlayer;

	/* malloc the NET struct */

	if ((nntmp= (NET *)malloc(sizeof(NET))) == NULL)
		{
		error( NNMALLOC );
		}
	else
		{

		/* malloc the LAYER *'s	*/

		DimNet(nntmp) = totallayer;
		if ((nntmp->layer = (LAYER **)malloc(sizeof(LAYER *) * DimNet(nntmp))) == NULL)
			{
			error( NNMALLOC );
			}
		else
			{
			/*
			* dimension of first layer's wgt vector
			* is equal to dimension of input vector
			*/
			dimwt = diminput;

			for (i=0; i<DimNet(nntmp); i++)
				{
				if (i == DimNet(nntmp)-1)
					{
					dimlayer = dimoutput;
					}
				else
					{
					dimlayer = *(dimother + i);
					}

				Layer(nntmp,i) = l_creat( dimlayer, dimwt );

				/*
				* dimension of this layer's wgt vector is equal
				* to dimension of previous layer's out vector
				*/
				dimwt = dimlayer;
				}

			return (nntmp);
			}
		}
}

/*
*=============================================================================
*	funct:	v_creat 
*	dscpt:	create an allocated VECTOR object
*	given:	dim = dimension of the vector
*	retrn:	allocated VECTOR
*=============================================================================
*/
VECTOR * v_creat( dim )
INTEGER	dim;
{
	VECTOR	*vtmp;
//	INTEGER	i;

	if ((vtmp = (VECTOR *)malloc(sizeof(VECTOR))) == NULL)
		{
		error( NNMALLOC );
		}
	else
		{
		DimVect(vtmp) = dim;
		if ((Vect(vtmp) = (REAL *)malloc(sizeof(REAL) * dim)) == NULL)
			{
			error( NNMALLOC );
			}
		else
			{
			v_fill(vtmp, 0.0);
			return (vtmp);
			}
		}
}

/*
*=============================================================================
*	funct:	v_fill 
*	dscpt:	fill all dim of a vector with a value
*	given:	v = vector, m = value
*	retrn:	v
*=============================================================================
*/
VECTOR * v_fill( v, m )
VECTOR	*v;
REAL	m;
{
	int	i;

	for (i=0; i<DimVect(v); i++)
		{
		Vi(v,i) = m;
		}
	return (v);
}

/*
*=============================================================================
*	funct:	v_rand
*	dscpt:	fill a vector with random value (default 0.5 - 1.5)
*	given:	v = vector
*	retrn:	v
*=============================================================================
*/
VECTOR *v_rand( v )
VECTOR	*v;
{
	INTEGER	i;

	for (i=0; i<DimVect(v); i++)
		{
		Vi(v,i) = rnd() * (UB-LB) + LB;
		}
	return (v);
}


/*
*=============================================================================
*	funct:	u_creat
*	dscpt:	create an allocated UNIT
*	given:	dimwgtvect = dimension of the unit's weight vector
*	retrn:	allocated UNIT
*=============================================================================
*/
UNIT * u_creat( dimwgtvect )
INTEGER	dimwgtvect;
{
	UNIT	*utmp;

	if ((utmp=(UNIT *)malloc(sizeof(UNIT))) == NULL)
		{
		error(NNMALLOC);
		}
	else
		{
		vWeight(utmp) = v_creat( dimwgtvect );
		v_rand( vWeight(utmp) );
		vdWeight1(utmp) = v_creat( dimwgtvect );
		vdWeight2(utmp) = v_creat( dimwgtvect );
		vDO(utmp) = v_creat( dimwgtvect );

		Out(utmp) = 0.0;
		Net(utmp) = 0.0;
		Dlt(utmp) = 0.0;
		nDlt(utmp)= 0.0;
		Bias(utmp) = rnd() / 5000.0 ;
		dBias1(utmp) = 0.0;
		dBias2(utmp) = 0.0;

		/* allocation successful */
		return (utmp);
		}
}



/*
*=============================================================================
*	funct:	l_creat
*	dscpt:	create an allocated LAYER object
*	given:	dimlayer = number of units in this layer
*		dimwgtvect = dimension of the weight vector of each unit
*	retrn:	allocated LAYER
*=============================================================================
*/
LAYER * l_creat( dimlayer, dimwgtvect )
INTEGER	dimlayer;
INTEGER	dimwgtvect;
{
	LAYER	*ltmp;
	INTEGER	i;

	if ((ltmp= (LAYER *)malloc(sizeof(LAYER))) == NULL)
		{
		error(NNMALLOC);
		}
	else
		{
		DimLayer(ltmp) = dimlayer;
		if ((ltmp->unit= (UNIT **)malloc(sizeof(UNIT *) * dimlayer)) == NULL)
			{
			error(NNMALLOC);
			}
		else
			{
			for (i=0; i<dimlayer; i++)
				{
				Unit(ltmp,i) = u_creat( dimwgtvect );
				}

			/* allocation successful */
			return (ltmp);
			}

		}
}
