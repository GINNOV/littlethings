#ifndef CLIB_MATHFFP_PROTOS_H
#define CLIB_MATHFFP_PROTOS_H


/*
**	$VER: mathffp_protos.h 34.106 (21.05.2022)
**
**	C prototypes.
**
**	Copyright © 2022 
**	All Rights Reserved
*/

#ifndef  EXEC_TYPES_H
#include <exec/types.h>
#endif

LONG SPFix(FLOAT parm);
FLOAT SPFlt(LONG integer);
LONG SPCmp(FLOAT leftParm, FLOAT rightParm);
LONG SPTst(FLOAT parm);
FLOAT SPAbs(FLOAT parm);
FLOAT SPNeg(FLOAT parm);
FLOAT SPAdd(FLOAT leftParm, FLOAT rightParm);
FLOAT SPSub(FLOAT leftParm, FLOAT rightParm);
FLOAT SPMul(FLOAT leftParm, FLOAT rightParm);
FLOAT SPDiv(FLOAT leftParm, FLOAT rightParm);
FLOAT SPFloor(FLOAT parm);
FLOAT SPCeil(FLOAT parm);

#endif	/*  CLIB_MATHFFP_PROTOS_H  */
