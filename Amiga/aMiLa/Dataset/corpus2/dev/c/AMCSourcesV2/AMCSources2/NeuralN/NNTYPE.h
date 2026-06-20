/*
*----------------------------------------------------------------------------
*	file:	nntype.h
*	desc:	define all types for the neural nets
*	by:	patrick ko
*	date:	2 aug 91
*	revi:	v1.2b - 15 jan 92, adaptive coefficients (beta)
*		v1.2u - 17 jan 92, revised data structures
*		v1.31u -20 jan 92, periodic dump
*----------------------------------------------------------------------------
*/

/*
*	trap multiple nntype include
*/
#ifndef	NNTYPE
#define	NNTYPE

typedef	int		INTEGER;
typedef	int		FLAG;
typedef	double		REAL;

typedef struct	{
	INTEGER	dim;		/* vector dimension */
	REAL	* vect;		/* vector array */
	}	VECTOR;

typedef struct	{
	REAL	out;		/* output of unit */
	REAL	net;		/* net product */
	REAL	dlt;		/* for delta dpj*/
	REAL	ndlt;		/* for dpj accumulation (v1.2) */
	VECTOR	*wgtvect;	/* weight vector */
	VECTOR	*dwgtvect1;	/* dweight vector dW at n-1 */
	VECTOR	*dwgtvect2;	/* dweight vector dW at n-2 */
	VECTOR	*dxo;
	REAL	bias;		/* for bias */
	REAL	dbias1;		/* for bias at n-1 */
	REAL	dbias2;		/* for bias at n-2 */
	}	UNIT;

typedef struct	{
	INTEGER	dim;		/* number of units */
	UNIT	**unit;		/* array of units */
	}	LAYER;

typedef	struct {
	INTEGER	dim;		/* number of layers */
	LAYER	**layer;	/* array of layers */
	}	NET;

#define	DimVect(vector)		((vector)->dim)
#define	Vect(vector)		((vector)->vect)
#define	Vi(vector,i)		((vector)->vect[i])

#define	Out(unit)		((unit)->out)
#define	Net(unit)		((unit)->net)
#define	Dlt(unit)		((unit)->dlt)
#define	nDlt(unit)		((unit)->ndlt)
#define	Weight(unit,i)		Vi((unit)->wgtvect,i)
#define	dWeight1(unit,i)	Vi((unit)->dwgtvect1,i)
#define	dWeight2(unit,i)	Vi((unit)->dwgtvect2,i)
#define	vWeight(unit)		((unit)->wgtvect)
#define	vdWeight1(unit)		((unit)->dwgtvect1)
#define	vdWeight2(unit)		((unit)->dwgtvect2)
#define	DO(unit,i)		Vi((unit)->dxo,i)
#define	vDO(unit)		((unit)->dxo)
#define	Bias(unit)		((unit)->bias)
#define	dBias1(unit)		((unit)->dbias1)
#define	dBias2(unit)		((unit)->dbias2)
#define	DimvWeight(unit)	DimVect(vWeight(unit))

#define	DimLayer(layer)		((layer)->dim)
#define	Unit(layer,i)		((layer)->unit[i])

#define	DimNet(nn)		((nn)->dim)
#define	Layer(nn,i)		((nn)->layer[i])
#define DimNetOut(nn)		(DimLayer(Layer(nn,DimNet(nn)-1)))

#define ground(x,n)		((x)<(n)?(n):(x))

#define	ETA_DEFAULT		0.50
#define	ALPHA_DEFAULT		0.90
#define LAMBDA_DEFAULT		0.50
#define	ERROR_DEFAULT		0.01
#define	TOLER_DEFAULT		0.001
#define	BACKTRACK_STEP		0.50
#define ME_FLOOR		0.0001
#define	MW_FLOOR		0.0001
#define	ETA_FLOOR		0.0001
#endif

