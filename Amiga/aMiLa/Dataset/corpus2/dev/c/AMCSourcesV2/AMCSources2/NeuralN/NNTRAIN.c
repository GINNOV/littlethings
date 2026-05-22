/*
*-----------------------------------------------------------------------------
*	file:	nntrain.c
*	desc:	train a fully connected neural net by backpropagation
*	by:	patrick ko
*	date:	2 aug 91
*	revi:	v1.2b - 15 jan 92, adaptive coefficients
*		v1.3u - 18 jan 92, revised data structures
*		v1.31u - 20 jan 92, periodic dump, weights retrieval
*-----------------------------------------------------------------------------
*/
#include <stdio.h>
#include <math.h>
#ifdef AMIGA
#include <float.h>
#define MAXFLOAT FLT_MAX
#else
#include <values.h>
#endif
#include <time.h>

#include "nntype.h"
#include "nnmath.h"
#include "nntrain.h"
#include "nndump.h"

#define	global
#define	LAMBDA0	0.1

static REAL	ETA = ETA_DEFAULT;
static REAL	MOMENTUM = ALPHA_DEFAULT;
static REAL	LAMBDA = LAMBDA_DEFAULT;
static INTEGER	REPINTERVAL = 0;
global REAL	TOLER = TOLER_DEFAULT;

/*
*=============================================================================
*	funct:	nnbp_train
*	dscpt:	train a neural net using backpropagation
*	given:	net = the neural net
*		inpvect = 1 input vector ( 1 train pattern )
*		tarvect = 1 target vector ( 1 target pattern )
*		np = number of patterns
*		err = error
*		eta, momentum
*		report = dump info interval (no.of train cycles), 0=not dump
*		tdump = no of seconds for periodic dump, 0=not dump
*		dfilename = period dump file name
*	retrn:	measure of error
*=============================================================================
*/
REAL nnbp_train( net, inpvect, tarvect, np, err, eta, momentum, report, tdump, dfilename )
NET	*net;
VECTOR	**inpvect;
VECTOR	**tarvect;
REAL	err, eta, momentum;
INTEGER	np, report;
long int tdump;
char	*dfilename;
{
	REAL	Error;
	INTEGER	cnt;
	time_t	lasttime, thistime;
	FILE	*fdump;


	cnt = 0;
	REPINTERVAL = report;
	ETA = eta;
	MOMENTUM = momentum;
	Error = MAXFLOAT;
	if (tdump)
		time(&lasttime);

	while (Error > err)
		{
		cnt++;
		Error = nnbp_train1( net, inpvect, tarvect, np, Error );

		if (report)
			nnbp_report(cnt, Error);
		if (tdump)
			{
			if (((thistime = time(&thistime)) - lasttime) >= tdump)
				{
				fdump = fopen( dfilename, "w" );
				nn_dump( fdump, net );
				fclose(fdump);
				lasttime = thistime;
				}
			}
		}
	return (Error);
}

/*
*=============================================================================
*	funct:	nnbp_report
*	dscpt:	print report lines to terminal
*	given:	cnt = number of train cycles
*		error = overall energy
*	retrn:	nothing
*=============================================================================
*/
void nnbp_report( cnt, error )
INTEGER	cnt;
REAL	error;
{
	if (!(cnt%REPINTERVAL))
		{
		printf("nntrain: cycle= %d, MSE/Unit =%f\n", cnt, error );
		fflush(stdout);
		}
}

/*
*=============================================================================
*	funct:	nnbp_train1
*	dscpt:	train a neural net 1 cycle using backpropagation
*	given:	net = the neural net
*		inpvect = 1 set of input vectors
*		tarvect = 1 set of target vectors
*		np = number of patterns
*		LastError = energy at last cycle
*	retrn:	measure of error after this train cycle
*=============================================================================
*/
REAL nnbp_train1( net, inpvect, tarvect, np, LastError )
NET	*net;
VECTOR	**inpvect;
VECTOR 	**tarvect;
INTEGER	np;
REAL	LastError;
{
	REAL	Error;
	INTEGER	i;
	INTEGER	fire=0;

	Error = 0.0;
	nnbp_init( net );
	for (i=0; i<np; i++)
		{
		nnbp_forward( net, *(inpvect + i));
		Error += nnbp_backward( net, *(inpvect + i), *(tarvect + i));
		}
	Error = Error / np / DimNetOut(net);
	/*
	* coefficients adaptation and dWeight calculations
	*/
	if (Error <= LastError + TOLER )
		{

		/* weights will be updated, go ahead */

		fire = 1;
		nnbp_coeffadapt( net );
		nnbp_dweightcalc( net, np, fire );
		return (Error);
		}
	else
		{

		/* weights will not be updated, backtrack */

		fire = 0;
		ETA *= BACKTRACK_STEP;		/* half the ETA */
		ETA = ground(ETA,ETA_FLOOR);
		MOMENTUM = ETA * LAMBDA;
		nnbp_dweightcalc( net, np, fire );
		return (LastError);
		}
}

/*
*=============================================================================
*	funct:	nnbp_forward (pass)
*	dscpt:	forward pass calculation
*	given:	net = the neural net
*		inpvect = 1 input vector ( 1 train pattern )
*	retrn:	nothing
*	cmmnt:	net's output Out(J) calculated at every unit
*=============================================================================
*/
void nnbp_forward( net, inpvect )
NET	*net;
VECTOR	*inpvect;
{
	LAYER	*I, *input;
	UNIT	*J;
	INTEGER	i, j, k;
//	REAL	sum;
        REAL    out;

	/* phase 1 - forward compute output value Out's */

	input = NULL;

	/* For each layer I in the network */

	for (i=0; i<DimNet(net); i++)
		{
		I = Layer(net,i);

		/* For each unit J in the layer */

		for (j=0; j<DimLayer(I); j++)
			{
			J = Unit(I,j);
			Net(J) = Bias(J) + dBias1(J); /* add bias */
			for (k=0; k<DimvWeight(J); k++)
				{
				if (i==0)
					out = Vi(inpvect,k);
				else
					out = Out(Unit(input,k));

				Net(J) += (Weight(J,k) + dWeight1(J,k)) * out;
				}
			Out(J) = sigmoid(Net(J));
			}
		input = I;
		}
}


void nnbp_init( net )
NET	*net;
{
	LAYER	*I;
	UNIT	*J;
	INTEGER	i, j, k;

	i = DimNet(net);

	while (i--)
		{
		I = Layer(net,i);
		for (j=0; j<DimLayer(I); j++)
			{
			J = Unit(I,j);
			nDlt(J) = 0.0;
			for (k=0; k<DimvWeight(J); k++)
				{
				DO(J,k) = 0.0;
				}
			}
		}
}

/*
*=============================================================================
*	funct:	nnbp_backward
*	dscpt:	backward pass calculation
*	given:	net = the neural net
*		inpvect = 1 input vector ( 1 train pattern )
*		tarvect = 1 target vector
*	retrn:	Ep * 2
*	cmmnt:	net's weight and bias adjusted at every layer
*=============================================================================
*/
REAL nnbp_backward( net, inpvect, tarvect )
NET	*net;
VECTOR	*inpvect;
VECTOR	*tarvect;
{
	LAYER	*I, *F, *B;
	UNIT	*J, *JF;
	INTEGER	i, j, k;
	REAL	sum, out;
	REAL	Ep, diff;

	Ep = 0.0;

	/*
	*	phase 2 - target comparison and back propagation
	*/
	i = DimNet(net) - 1;
	F = I = Layer(net,i);
	B = Layer(net,i - 1);

	/*
	*	Delta rule 1 - OUTPUT LAYER
	*	dpj = (tpj - opj) * f'(netpj)
	*/
	for (j=0; j<DimLayer(I); j++)
		{
		J = Unit(I,j);
		diff = Vi(tarvect,j) - Out(J);
		Dlt(J) = diff * Out(J) * (1.0 - Out(J));

		nDlt(J) += Dlt(J);	/* accumulate Dpj's */

		for (k=0; k<DimvWeight(J); k++)
			{
			if (i==0)
				out = Vi(inpvect,k);
			else
				out = Out(Unit(B,k));
			DO(J,k) += Dlt(J) * out;
			}

		Ep += diff * diff;
		}

	--i;
	while (i >= 0)
		{
		I = Layer(net,i);		/* current layer */
		B = Layer(net,i - 1);
		/*
		*	delta rule 2 - HIDDEN LAYER:
		*	dpj = f'(netpj) * SUMMATEk( Dpk * Wkj )
		*/
		for (j=0; j<DimLayer(I); j++)
			{
			J = Unit(I,j);
			sum = 0.0;
			for (k=0; k<DimLayer(F); k++)
				{
				JF = Unit(F,k);
				sum += Dlt(JF) * (Weight(JF,j)+dWeight1(JF,j));
				}
			Dlt(J) = Out(J) * (1.0 - Out(J)) * sum;
			nDlt(J) += Dlt(J);

			for (k=0; k<DimvWeight(J); k++)
				{
				if (i==0)
					out = Vi(inpvect,k);
				else
					out = Out(Unit(B,k));
				DO(J,k) += Dlt(J) * out;
				}
			}
		F = I;
		i--;
		}

	return (Ep);
}

void nnbp_coeffadapt( net )
NET	*net;
{
	LAYER	*I;
//        LAYER   *B;
	UNIT	*J;
//	INTEGER	n;
        INTEGER i, j, k;
	REAL	EW, ME, MW, costh;

	EW = ME = MW = 0.0;
	i = DimNet(net);

	while (i--)
		{
		I = Layer(net,i);
		for (j=0; j<DimLayer(I); j++)
			{
			J = Unit(I,j);
			for (k=0; k<DimvWeight(J); k++)
				{
				ME += DO(J,k) * DO(J,k);
				MW += dWeight1(J,k) * dWeight1(J,k);
				EW += DO(J,k) * dWeight1(J,k);
				}
			}
		}

	ME = sqrt(ME);		/* modulus of cost funct vector E */
	MW = sqrt(MW);		/* modulus of delta weight vector dWn-1*/

	ME = ground(ME,ME_FLOOR);		/* constraints */
	MW = ground(MW,MW_FLOOR);		/* constraints */

	costh = EW / (ME * MW);

	/* coefficients adaptation !!! */

	ETA = ETA * (1.0 + 0.5 * costh);
	ETA = ground(ETA,ETA_FLOOR);
	LAMBDA = LAMBDA0 * ME / MW;
	MOMENTUM = ETA * LAMBDA;
}

void nnbp_dweightcalc( net, np, fire )
NET	*net;
INTEGER	np;
INTEGER	fire;
{
	LAYER	*I;
	UNIT	*J;
//	INTEGER	n;
        INTEGER i, j, k;

	i = DimNet(net);

	/* calculate dWeights for every unit */

	while (i--)
		{
		I = Layer(net,i);
		for (j=0; j<DimLayer(I); j++)
			{
			J = Unit(I,j);
			nDlt(J) /= np;
			for (k=0; k<DimvWeight(J); k++)
				{
				DO(J,k) /= np;
				if (fire)
					{
					/* commit weight change */
					Weight(J,k) += dWeight1(J,k);

					/* dW n-2 = dW n-1 */
					dWeight2(J,k) = dWeight1(J,k);
					}
				dWeight1(J,k) = ETA * DO(J,k) + MOMENTUM * dWeight2(J,k);
				}
			if (fire)
				{
				Bias(J) += dBias1(J);
				dBias2(J) = dBias1(J);
				}
			dBias1(J) = ETA * nDlt(J) + MOMENTUM * dBias2(J);
			}
		}
}
