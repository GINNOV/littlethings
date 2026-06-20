
/*
 *	Function	MatFree
 *	Programmer	N.d'Alterio
 *	Date		17/11/94
 *
 *  Synopsis:	This function frees the memory allocated for matrix mat.
 *
 *  Arguments:	MATRIX *mat	-	matrix to be freed
 *
 *  Variables:	i		-	general loop variable
 * 
 *  Functions:	free		-	free memory allocated to pointer
 *
 *  $VER: MatFree.c 1.1 (10.07.95) $
 *  $Log: MatFree.c $
 * Revision 1.1  1995/07/10  22:33:15  daltern
 * Initial revision
 *
 *
 */

#include "Matrix.h"


void MatFree( MATRIX *mat )

{

  int i;

/*
 * Free matrix columns.
 */

  for ( i = 0; i < ( mat->Rows + 1 ); i++  ) {

 	free( mat->Mat[i] );

  }  /* end for i: free matrix columns */

/*
 * Free matrix rows.
 */

  free( mat->Mat );

/*
 * Free matrix
 */

  free( mat );

  return;

}   /* end function MatFree */

/*========================================================================*
                                   END
 *========================================================================*/
