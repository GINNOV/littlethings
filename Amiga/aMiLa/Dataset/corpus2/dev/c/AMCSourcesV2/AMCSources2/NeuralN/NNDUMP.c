/*
*-----------------------------------------------------------------------------
*	file:	nndump.c
*	desc:	dump structures in nntype.h
*	by:	patrick ko
*	date:	13 aug 1991
*	revi:	v1.2b - 15 jan 1992, coefficient adaptation
*		v1.3u - 18 jan 1992, revised data structures
*-----------------------------------------------------------------------------
*/
#include <stdio.h>

#include "nntype.h"

void	v_dump( fp, vp )
FILE	*fp;
VECTOR	*vp;
{
	INTEGER	i;

	for (i=0; i<DimVect(vp); i++)
		{
		fprintf( fp, "%f ", vp->vect[i] );
		}

	fprintf( fp, "\n" );
}

void	v_load( fp, vp )
FILE	*fp;
VECTOR	*vp;
{
	INTEGER	i;

	for (i=0; i<DimVect(vp); i++)
		{
		fscanf( fp, "%lf ", &vp->vect[i] );
		}
}

void	u_dumpweight( fp, unit )
FILE	*fp;
UNIT	*unit;
{
	v_dump( fp, vWeight(unit) );
	fprintf(fp, "%f \n", Bias(unit));
}

void	u_loadweight( fp, unit )
FILE	*fp;
UNIT	*unit;
{
	v_load( fp, vWeight(unit) );
	fscanf(fp, "%lf \n", &Bias(unit));
}

void	l_dump( fp, ly )
FILE	*fp;
LAYER	*ly;
{
	INTEGER	i;

	for (i=0; i<DimLayer(ly); i++)
		{
		u_dumpweight( fp, Unit(ly,i) );
		}
}

void	l_load( fp, ly )
FILE	*fp;
LAYER	*ly;
{
	INTEGER	i;

	for (i=0; i<DimLayer(ly); i++)
		{
		u_loadweight( fp, Unit(ly,i) );
		}
}

void	nn_dump( fp, nn )
FILE	*fp;
NET	*nn;
{
	INTEGER	i;


	for (i=0; i<DimNet(nn); i++)
		{
		l_dump( fp, Layer(nn,i) );
		}
}

void	nn_load( fp, nn )
FILE	*fp;
NET	*nn;
{
	INTEGER	i;

	for (i=0; i<DimNet(nn); i++)
		{
		l_load( fp, Layer(nn,i) );
		}
}

void	nn_dumpout( fp, nn )
FILE	*fp;
NET	*nn;
{
//	INTEGER	i;
        INTEGER j;
	LAYER	*I;
	UNIT	*J;

	I = Layer(nn,DimNet(nn)-1);

	for (j=0; j<DimLayer(I); j++)
		{
		J = Unit(I,j);
		fprintf( fp, "%f ", Out(J) );
		}
	fprintf( fp, "\n" );
}
