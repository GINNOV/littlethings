
/*
 *	Header		Matrix.h
 *	Programmer	N.d'Alterio
 *	Date		17/11/94
 *
 *  Synopsis:	This header defines the matrix data structure and contains the
 *		prototypes for the matrix manipulation routines.
 *
 * $VER: Matrix.h 1.6 (10.07.95) $
 * $Log: Matrix.h $
 * Revision 1.6  1995/07/10  23:14:12  daltern
 * pushed prototypes to end for compiler
 *
 *
 */

/*========================================================================*
                              DATATYPES
 *========================================================================*/

/*
 *  Matrix structure.
 */

  struct Matrix{

	int Rows;
	int Cols;

	double **Mat;

	};

  typedef struct Matrix MATRIX;

/*
 *  Index structure to refer to particular element of a matrix.
 */

  struct Index{

	int R;
	int C;

	};

  typedef struct Index INDEX;

/*========================================================================*
                               INCLUDES
 *========================================================================*/


#include <math.h>
#include <stdlib.h>


/*========================================================================*
                              DEFINITIONS
 *========================================================================*/

#define		SMALL		1.0e-20

/*========================================================================*
                              PROTOTYPES
 *========================================================================*/

  MATRIX 	*MatAlloc( int, int );
  void		MatFree( MATRIX *);

  void		MatSwapRow( MATRIX *, int, int );
  int		MatPPivot( MATRIX *, MATRIX *, MATRIX *,INDEX * );

  int		MatLUdecomp( MATRIX *, MATRIX *, MATRIX *, MATRIX * );
  int		MatBackSub( MATRIX *, MATRIX *, MATRIX * );
  int 		MatForSub( MATRIX *, MATRIX *, MATRIX * );

  double	MatDet( MATRIX * );
  double 	VecMod( MATRIX * );

  MATRIX	*MatAdd( MATRIX *, MATRIX * );
  MATRIX	*MatSub( MATRIX *, MATRIX * );

  MATRIX	*MatMul( MATRIX *, MATRIX * );

  MATRIX 	*MatSimul( MATRIX *, MATRIX *, MATRIX * );
  MATRIX	*MatInv( MATRIX * );
  MATRIX	*MatInvIt( MATRIX *, double * );

  MATRIX 	*MatConst( MATRIX *, double, int );
  int		MatCmp( MATRIX *, MATRIX *, double );

  double	VecDot( MATRIX *, MATRIX * );

  void          MatPrint( MATRIX * );

/*========================================================================*
                                  END
 *========================================================================*/












