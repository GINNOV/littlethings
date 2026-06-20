/*
 * $Id: matrix.h 37 2005-01-10 14:06:19Z tfrieden $
 *
 * $Date: 2005-01-10 09:06:19 -0359ÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐÐ $
 * $Revision: 37 $
 *
 * (C) 1999 by Hyperion
 * All rights reserved
 *
 * This file is part of the MiniGL library project
 * See the file Licence.txt for more details
 *
 */

#ifndef _MATRIX_H
#define _MATRIX_H

typedef struct Matrix_t
{
	float v[16];
	int flags;                  // Matrix flags
	struct Matrix_t *Inverse;   // optional inverse
} Matrix;

#define OF_11 0
#define OF_12 4
#define OF_13 8
#define OF_14 12

#define OF_21 1
#define OF_22 5
#define OF_23 9
#define OF_24 13

#define OF_31 2
#define OF_32 6
#define OF_33 10
#define OF_34 14

#define OF_41 3
#define OF_42 7
#define OF_43 11
#define OF_44 15




#define  MGLMAT_IDENTITY         0x01
#define  MGLMAT_ROTATION         0x02
#define  MGLMAT_TRANSLATION      0x04
#define  MGLMAT_UNIFORM_SCALE    0x08
#define  MGLMAT_GENERAL_SCALE    0x10
#define  MGLMAT_PERSPECTIVE      0x20
#define  MGLMAT_GENERAL          0x40
#define  MGLMAT_GENERAL_3D       0x80
#define  MGLMAT_ORTHO            0x100
#define  MGLMAT_0001             0x200


#define MGLMASK_0001 (MGLMAT_IDENTITY|MGLMAT_ROTATION|\
		MGLMAT_TRANSLATION|MGLMAT_UNIFORM_SCALE|MGLMAT_GENERAL_SCALE|MGLMAT_ORTHO|MGLMAT_0001)


#endif
