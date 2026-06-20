/*
**----------------------------------------------------------------------------
**	file:	nncreat.h
**	desc:	nncreate.c header file
**	by:		patrick ko
**	date:	2 aug 91
**----------------------------------------------------------------------------
*/
#include	"nntype.h"

#ifdef __TURBOC__

NET *		nn_creat	(INTEGER, INTEGER, INTEGER, INTEGER *);
VECTOR *	v_creat		(INTEGER);
UNIT *		u_creat		(INTEGER);
LAYER *		l_creat		(INTEGER, INTEGER);
VECTOR *	v_rand		(VECTOR *);
VECTOR *	v_fill          (/*VECTOR *, REAL*/);

#else

NET *		nn_creat	();
VECTOR *	v_creat		();
UNIT *		u_creat		();
LAYER *		l_creat		();
VECTOR *	v_rand		();
VECTOR *	v_fill		();

#endif

extern	REAL	UB;
extern	REAL	LB;

