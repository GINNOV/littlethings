
/*
 *	Function	VecDot
 *	Programmer	N.d'Alterio
 *	Date		06/12/94
 *
 *  Synopsis:	This function calculates the dot product of two vectors.
 *
 *  Arguments:	MATRIX *vec1	-	first vector
 *		MATRIX *vec2	-	second vector
 *
 *  Returns:	double		-	dot product of vectors
 *		DBL_MAX		-	if error
 *
 *  Variables:	sum		-	running total of dot product
 *		rows		-	min number of vector rows
 *		i		-	general loop variables
 * 
 *  Functions:
 *
 *  $VER: VecDot.c 1.1 (11.07.95) $
 *  $Log: VecDot.c $
 * Revision 1.1  1995/07/11  12:44:05  daltern
 * Initial revision
 *
 *
 */

#include <float.h>
#include "Matrix.h"


double VecDot( MATRIX *vec1, MATRIX *vec2 )

{

  int i;
  int rows;
		
  double sum;

/*
 *  First check for valid arguments.
 */

  if ( ( vec1->Cols != 1 ) || ( vec2->Cols != 1 ) ) {

	return DBL_MAX;

  }   /* end if */


/*
 *  Find min number of rows. 
 */

  if ( vec1->Rows < vec2->Rows ) {

	rows = vec1->Rows;

  } else {

	rows = vec2->Rows;

  }   /* end if */

/*
 *  Now loop calculating dot product
 */

  sum = 0.0;

  for ( i = 1; i < ( rows + 1 ); i++ ) {

	sum = sum + ( vec1->Mat[i][1] * vec2->Mat[i][1] );

  }   /* end for i */

  return sum;

}   /* end function VecDot */

/*========================================================================*
                                   END
 *========================================================================*/
