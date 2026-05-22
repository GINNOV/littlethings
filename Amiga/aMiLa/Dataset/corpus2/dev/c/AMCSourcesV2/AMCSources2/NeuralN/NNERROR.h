/*
*----------------------------------------------------------------------------
*	file:	nnerror.h
*	desc:	define all errors
*	by:	patrick ko
*	date:	2 aug 91
*----------------------------------------------------------------------------
*/

#define	NNMALLOC	0
#define NNTFRERR	1
#define NNTFIERR	2
#define NNIOLAYER	3
#define NN2MANYLAYER	4
#define NN2FEWPATT	5
#define	NN2MANYHIDDEN	6
#define	NNOUTNOTOPEN	7
#define	NNRFRERR	8

/*
*	prototype
*/
#ifdef	__TURBOC__

int	error	(int);
void	verbose	(char *, char *);

#else

int	error 	( );
void	verbose	( );

#endif
