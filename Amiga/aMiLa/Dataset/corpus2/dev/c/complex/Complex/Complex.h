
/*
 *	Header		Complex.h
 *	Programmer	N.d'Alterio
 *	Date		31/10/94	
 *
 *  Synopsis:	This header defines the Complex data strucure and the prototypes
 *  		for the various complex number manipulation routines.
 *
 * $VER: Complex.h 1.1 (10.07.95) $
 * $Log: Complex.h $
 * Revision 1.2  1995/07/10  18:43:27  daltern
 * Fixed silly compile time error
 *
 * Revision 1.1  1995/07/10  18:26:10  daltern
 * Initial revision
 *
 *
 */

/*========================================================================*
                               DATATYPES
 *========================================================================*/

    struct Complex {

        double  Real;
        double  Imag;

    };

    typedef struct Complex COMPLEX;

/*========================================================================*
                              PROTOTYPES
 *========================================================================*/

    COMPLEX ComAdd( COMPLEX, COMPLEX );

    COMPLEX ComSub( COMPLEX, COMPLEX );

    COMPLEX ComMul( COMPLEX, COMPLEX );

    COMPLEX ComDiv( COMPLEX, COMPLEX );

    double  ComMod( COMPLEX );

    double  ComArg( COMPLEX );

/*========================================================================*
                                  END
 *========================================================================*/


