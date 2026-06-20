/*
*-----------------------------------------------------------------------------
*	file:	nntrain.h
*	desc:	nntrain.c header file
*	by:		patrick ko
*	date:	2 aug 91
*-----------------------------------------------------------------------------
*/

#include	"nntype.h"

#ifdef	__TURBOC__

REAL	nnbp_train	(/*NET *,VECTOR **,VECTOR **,INTEGER,REAL,REAL,REAL*,long int,char */);
REAL 	nnbp_train1	(/*NET *,VECTOR **,VECTOR **,INTEGER,REAL*/);
void	nnbp_init	(NET *);
void	nnbp_forward	(NET *, VECTOR *);
REAL 	nnbp_backward	(NET *, VECTOR *, VECTOR *);
void	nnbp_report	(/*INTEGER, REAL*/);
void	nnbp_coeffadapt	(NET *);
void	nnbp_dweightcalc(NET *, INTEGER, INTEGER);

#else

REAL 	nnbp_train	( );
REAL	nnbp_train1	( );
void	nnbp_init	( );
void	nnbp_forward	( );
REAL	nnbp_backward	( );
void	nnbp_report	( );
void	nnbp_coeffadapt ( );
void	nnbp_dweightcalc( );
#endif
