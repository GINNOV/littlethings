
/*
 *	Function	MatSimul
 *	Programmer	N.d'Alterio
 *	Date		28/11/94
 *
 *  Synopsis:	This function solves a set of simulataneous equations
 *		given the LU decomposed matrices and a RHS of the eqn.
 *
 *  Arguments:	MATRIX *up	-	upper tri matrix
 *		MATRIX *low	-	lower tri matrix
 *		MATRIX *val	-	RHS of eqn
 *
 *  Returns:	MATRIX *	-	solution of eqn
 *		NULL		-	if error
 *
 *  Variables:	vec		-	matrix solution
 *		inter		-	intermediate matrix
 *		i, j		-	general loop variables
 * 
 *  Functions:	MatForSub	-	forwards substitution
 *		MatBackSub	-	back substitution
 *		MatAlloc	-	allocates matrix
 *		MatFree		-	frees matrix
 *
 *  $VER: MatSimul.c 1.5 (11.07.95) $
 *  $Log: MatSimul.c $
 * Revision 1.5  1995/07/11  00:04:37  daltern
 * code tidy up
 *
 *
 */

#include "Matrix.h"

MATRIX *MatSimul( MATRIX *up, MATRIX *low, MATRIX *val )

 {

  MATRIX *vec;
  MATRIX *inter;

/*========================================================================*
                           ALLOCATE MATRICES
 *========================================================================*/


  if ( ( vec = MatAlloc( up->Rows, 1 ) ) == NULL ) {

	return NULL;

  }   /* end if */

  if ( ( inter = MatAlloc( up->Rows, 1 ) ) == NULL ) {

	return NULL;

  }   /* end if */

/*========================================================================*
               FIND INTERMEDIATE VECTOR y SUCH THAT Ly = b 
 *========================================================================*/


  if ( MatForSub( low, val, inter ) > 0 ) {

	return NULL;

  }   /* end if */

/*========================================================================*
                        FIND ANSWER SINCE Ux = y
 *========================================================================*/

  if ( MatBackSub( up, inter, vec ) > 0 ) {

	return NULL;

  }   /* end if */

/*
 *  Free up matrices and return answer.
 */

  MatFree( inter );

  return vec;

}   /* end function MatSimul */

/*========================================================================*
                                   END
 *========================================================================*/





