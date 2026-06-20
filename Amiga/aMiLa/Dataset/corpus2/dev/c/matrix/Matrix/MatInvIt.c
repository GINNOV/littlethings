
/*
 *	Function	MatInvIt
 *	Programmer	N.d'Alterio
 *	Date		02/12/94
 *
 *  Synopsis:	This function uses inverse iteration to find an 
 *		eigenvector and eigenvalue associated with a matrix.
 *		The function requires an initial guess for the 
 *		eigenvalue.
 *
 *  Arguments:	MATRIX *mat	-	matrix to solve
 *		double *evalue	-	initial guess for eigenvalue
 *
 *  Returns:	MATRIX *	-	eigenvector
 *		NULL		- 	if error
 *		returns eigenvalue by altering pointer argument
 *
 *  Variables:	i, j		-	general loop variables
 *		evector		-	eigenvector
 *		new_evector	-	temp vector for iteration
 *		temp1, temp2	-	temp matrices for init
 *		up, low		-	LU decomposed matrices
 *		mod		-	modulus of evector
 *		norm_new_evector - 	normalised new_evector
 *		val		-	dummy vector for LU decomp
 *		sign 		-	sign differnce between (n) (n-1)
 * 
 *  Functions:	MatAlloc	-	allocate a matrix
 *		MatFree		-	free a matrix
 *		MatLUdecomp	-	LU decompose matrix
 *		MatSimul	-	solve simultaneous eqns
 *		VecMod		-	modulus of a vector
 *		MatSub		-	subtract 2 matrices
 *		MatCmp		-	compares 2 matrices
 *		MatConst	-	constant operation on a matrix
 *
 *  $VER: MatInvIt.c 9.6 (11.07.95) $
 *  $Log: MatInvIt.c $
 * Revision 9.6  1995/07/11  12:58:35  daltern
 * fixed some mem alloc bugs
 *
 *
 */


#include <stdio.h>
#include <math.h>
#include "Matrix.h"

#define	DIFF	1e-9
#define MAX_IT  1000
	
MATRIX *MatInvIt( MATRIX *mat, double *evalue )

 {

  int i, j;

  MATRIX *evector;
  MATRIX *new_evector;
  MATRIX *norm_new_evector;

  MATRIX *temp1;
  MATRIX *temp2;
  MATRIX *up;
  MATRIX *low;
  MATRIX *val;

  double mod;	
  double sign;

/*========================================================================*
                     ALLOCATION AND INITIALISATION
 *========================================================================*/


  if ( ( temp1 = MatAlloc( mat->Rows, mat->Cols ) ) == NULL ) {

	return NULL;

  }   /* end if */

	
/*
 *  Set up temp2.
 */

/*
 *  First loop over temp1 to make the matrix kI.
 */

  for ( i = 1; i < ( mat->Rows + 1 ); i++ ) {
	for ( j = 1; j < ( mat->Cols + 1 ); j++ ) {

		if ( i == j ) {

			temp1->Mat[i][i] = *evalue;
	
		}   /* end if */

	}   /* end for j */

  }   /* end for i */

/*
 *  Set up temp2 ready to LU decompose it.
 */

  if ( ( temp2 = MatSub( mat, temp1 ) ) == NULL ) {

	MatFree( temp1 );
	return NULL;

  }   /* end if */ 

  MatFree( temp1 );

/*========================================================================*
              LU DECOMPOSE TEMP2 TO GIVE TRIANGULAR MATRICES
 *========================================================================*/

/*
 *  First deal with allocating mem.
 */

  if ( ( up = MatAlloc( mat->Rows, mat->Cols ) ) == NULL ) {

	MatFree( temp2 );
	return NULL;
	
  }   /* end if */

  if ( ( low = MatAlloc( mat->Rows, mat->Cols ) ) == NULL ) {

	MatFree( temp2 );
	MatFree( up );
	return NULL;

  }   /* end if */

  if ( ( val = MatAlloc( mat->Rows, 1 ) ) == NULL ) {

	MatFree( temp2 );
	MatFree( up );
	MatFree( low );
	return NULL;

  }   /* end if */

/*
 *  LU decompose matrix.
 */

  if ( MatLUdecomp( temp2, low, up, val ) > 0 ) {

	MatFree( temp2 );
	MatFree( up );
	MatFree( low );
	MatFree( val );
	return NULL;
		
  }   /* end if */


/*
 *  Have now finished with the temp matrices.
 */

  MatFree( temp2 );
  MatFree( val );



/*========================================================================*
                       ALLOCATE MEMORY FOR VECTORS
 *========================================================================*/

  if ( ( evector = MatAlloc( mat->Cols, 1 ) ) == NULL ) {

	MatFree( up );
	MatFree( low );
	return NULL;

  }   /* end if */

  if ( ( norm_new_evector = MatAlloc( mat->Cols, 1 ) ) == NULL ) {

	MatFree( up );
	MatFree( low );
	MatFree( evector );
	return NULL;

  }   /* end if */

/*========================================================================*
                             BEGIN THE ITERATION
 *========================================================================*/

/*
 *  Use j to check that we are not in a never ending loop. If
 *  j grows larger than 1000 then exit the routine.
 */

  j = 0;

  do {
		
	if ( j++ > MAX_IT ) {
	  
		fprintf( stderr,"\n **** This iteration is not working\n\n");
		MatFree( up );
		MatFree( low );
		MatFree( evector );
		MatFree( norm_new_evector );
		return NULL;

	}   /* end if */

/*
 *  Copy n th vector to n-1 th vector.
 */

	for ( i = 1; i < ( evector->Rows + 1 ); i++ ) {

		evector->Mat[i][1] = norm_new_evector->Mat[i][1];

	}   /* end  for i */

/*
 *  Free mem for norm_new_evector since will be reallocated.
 */

	MatFree( norm_new_evector );

/*
 *  Solve the simultaneous equations A(n) = (n-1) to get (n)
 */

	if ( ( new_evector = MatSimul( up, low, evector ) ) == NULL ) {

		MatFree( up );
		MatFree( low );
		MatFree( evector );
		return NULL;

	}   /* end if */

/*
 *  Now normalise new_evector and place in norm_new_evector
 */
 
	mod = VecMod( new_evector ); 

	if ( ( norm_new_evector = MatConst( new_evector, mod, 4 ) ) == NULL ) {

		MatFree( up );
		MatFree( low );
		MatFree( evector );
		MatFree( new_evector );
		return NULL;

	}   /* end if */

	MatFree( new_evector );

/*
 *  Find the first non-zero element of evector and then determine
 *  if the new evector is +ve or -ve multiple of it.
 */

	for ( i = 1; i < ( evector->Rows + 1 ); i++ ) {

		if ( evector->Mat[i][1] != 0.0 &&
		     norm_new_evector->Mat[i][1] != 0.0 ) break;
		
	}   /* end for i */

	if ( norm_new_evector->Mat[1][1] * evector->Mat[1][1] > 0.0 ) {

		sign = 1.0;

	} else {

		sign = -1.0;

	}   /* end if */

/*
 *  Iterate until the difference between the matrices 
 *  is less than DIFF.
 */
		
  } while ( MatCmp( norm_new_evector, evector, DIFF ) );


/*
**************************************************************************
*/

/*
 *  We have now found eigenvector, just need the eigenvalue.
 */


/*
 *  Calculate the eigenvalue.
 */


  *evalue = *evalue + ( (1/mod) * sign );

/*========================================================================*
                         FREE MEMORY AND RETURN
 *========================================================================*/


  MatFree( evector );
  MatFree( up );
  MatFree( low );

  return norm_new_evector;

}   /* end function MatInvIt */

/*========================================================================*
                                   END
 *========================================================================*/
 
