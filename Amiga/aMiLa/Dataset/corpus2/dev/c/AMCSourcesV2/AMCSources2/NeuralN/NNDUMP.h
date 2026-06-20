/*
*-----------------------------------------------------------------------------
*	file:		nndump.h
*	desc:		nndump.c header
*	by:			patrick ko
*	date:		13 aug 1991
*-----------------------------------------------------------------------------
*/

#ifdef	__TURBOC__

void	v_dump		(FILE *, VECTOR *);
void	v_load		(FILE *, VECTOR *);
void	u_dumpweight	(FILE *, UNIT *);
void	u_loadweight	(FILE *, UNIT *);
void	l_dump		(FILE *, LAYER *);
void	l_load		(FILE *, LAYER *);
void	nn_dump		(FILE *, NET *);
void	nn_load		(FILE *, NET *);

#else

void	v_dump		( );
void	v_load		( );
void	u_dumpweight	( );
void	u_loadweight	( );
void	l_dump		( );
void	l_load		( );
void	nn_dump		( );
void	nn_load		( );

#endif
