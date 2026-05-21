#ifndef _RESOURCES_VAMPIRE_H
#define _RESOURCES_VAMPIRE_H

/*
;******************************************************************************************
;*
;* $id: vampire.h $
;*
;* Unit numbers and library call offsets for vampire.resource
;*
;* (C) 2017 Apollo Team
;*
;* author: Henryk Richter
;*
;******************************************************************************************
*/

#ifndef EXEC_TYPES_H
#include "exec/types.h" 
#endif	/* EXEC_TYPES_H */

#ifndef EXEC_LIBRARIES_H
#include "exec/libraries.h" 
#endif	/* EXEC_LIBRARIES_H */

/*
;* Unit number definitions: Ownership of a resource grants low-level
;* bit access to the hardware registers.  You are still obligated to follow
;* the rules for shared access of the interrupt system.
*/
#define V_SDPORT        0       /* SD port on V500/600 */
#define V_WIFIPORT      1       /* WiFi expansion port on V500+ */
#define V_PAMELA_45	2	/* Pamela channels 4,5 = first two 16 bit capable channels */
#define V_PAMELA_67	3	/* Pamela channels 6,7 = second two 16 bit capable channels */
#define V_PIP		4	/* SAGA Picture In Picture */
#define V_V4NET		5	/* Vampire V4 Net */

/*
;* AMMX enable variants 
;* Supported right now are AMMX1 (and associated checks) and AMMX2
;*
*/
#define V_AMMX_DISABLE  0
#define V_AMMX_V1       1
#define V_AMMX_V2       2

/*
;*
;* AMMX enable return codes
;*
*/
#define VRES_ERROR       0
#define VRES_OK          1
#define VRES_AMMX_WAS_ON 2

/*
;*
;* Name
;*
*/
#define V_VAMPIRENAME "vampire.resource"


#endif	/* RESOURCES_VAMPIRE_H */
