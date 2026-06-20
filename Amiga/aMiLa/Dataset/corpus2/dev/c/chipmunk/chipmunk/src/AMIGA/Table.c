/*
 *  chipmunk.library
 *
 *  Copyright © 2006 Ilkka Lehtoranta <ilkleht@isoveli.org>
 *  All rights reserved.
 *  
 *  $Id: Table.c,v 1.2 2006/11/02 00:20:58 itix Exp $
 */

#include <stdarg.h>

#include <exec/libraries.h>

#include "Startup.h"

/* This function must preserve all registers except r13 */
asm("
	.section \".text\"
	.align 2
	.type __restore_r13, @function
__restore_r13:
	lwz 13, 36(12)
	blr
__end__restore_r13:
	.size __restore_r13, __end__restore_r13 - __restore_r13
");

#define	PROTO(name) VOID name(); static VOID __saveds STUB_##name(void) { return name(); }
#define	TABLE(name) (APTR)STUB_##name##,

/* Jump table */

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

VOID LibOpen(void);
VOID LibClose(void);
VOID LibExpunge(void);
VOID LibReserved(void);

PROTO(cpInitChipmunk)
PROTO(cpMomentForCircle)
PROTO(cpMomentForPoly)

PROTO(cpSpaceAlloc)
PROTO(cpSpaceInit)
PROTO(cpSpaceNew)
PROTO(cpSpaceDestroy)
PROTO(cpSpaceFree)
PROTO(cpSpaceFreeChildren)
PROTO(cpSpaceAddCollisionPairFunc)
PROTO(cpSpaceRemoveCollisionPairFunc)
PROTO(cpSpaceSetDefaultCollisionPairFunc)
PROTO(cpSpaceAddShape)
PROTO(cpSpaceAddStaticShape)
PROTO(cpSpaceAddBody)
PROTO(cpSpaceAddJoint)
PROTO(cpSpaceRemoveShape)
PROTO(cpSpaceRemoveStaticShape)
PROTO(cpSpaceRemoveBody)
PROTO(cpSpaceRemoveJoint)
PROTO(cpSpaceEachBody)
PROTO(cpSpaceResizeStaticHash)
PROTO(cpSpaceResizeActiveHash)
PROTO(cpSpaceRehashStatic)
PROTO(cpSpaceStep)

PROTO(cpvlength)
PROTO(cpvlengthsq)
PROTO(cpvnormalize)
PROTO(cpvforangle)
PROTO(cpvtoangle)
PROTO(cpvstr)

PROTO(cpBBClampVect)
PROTO(cpBBWrapVect)

PROTO(cpBodyAlloc)
PROTO(cpBodyInit)
PROTO(cpBodyNew)

PROTO(cpBodyDestroy)
PROTO(cpBodyFree)

PROTO(cpBodySetMass)
PROTO(cpBodySetMoment)
PROTO(cpBodySetAngle)
PROTO(cpBodySlew)
PROTO(cpBodyUpdateVelocity)
PROTO(cpBodyUpdatePosition)
PROTO(cpBodyResetForces)
PROTO(cpBodyApplyForce)
PROTO(cpDampedSpring)

PROTO(cpHashSetDestroy)
PROTO(cpHashSetFree)

PROTO(cpHashSetAlloc)
PROTO(cpHashSetInit)
PROTO(cpHashSetNew)

PROTO(cpHashSetInsert)
PROTO(cpHashSetRemove)
PROTO(cpHashSetFind)

PROTO(cpHashSetEach)
PROTO(cpHashSetReject)
PROTO(cpSpaceHashAlloc)
PROTO(cpSpaceHashInit)
PROTO(cpSpaceHashNew)
PROTO(cpSpaceHashDestroy)
PROTO(cpSpaceHashFree)
PROTO(cpSpaceHashResize)
PROTO(cpSpaceHashInsert)
PROTO(cpSpaceHashRemove)
PROTO(cpSpaceHashEach)
PROTO(cpSpaceHashRehash)
PROTO(cpSpaceHashRehashObject)
PROTO(cpSpaceHashQuery)
PROTO(cpSpaceHashQueryRehash)
PROTO(cpContactInit)

PROTO(cpContactsSumImpulses)
PROTO(cpContactsSumImpulsesWithFriction)
PROTO(cpArbiterAlloc)
PROTO(cpArbiterInit)
PROTO(cpArbiterNew)

PROTO(cpArbiterDestroy)
PROTO(cpArbiterFree)

PROTO(cpArbiterInject)
PROTO(cpArbiterPreStep)
PROTO(cpArbiterApplyImpulse)
PROTO(cpCollideShapes)
PROTO(cpJointDestroy)
PROTO(cpJointFree)
PROTO(cpPinJointAlloc)
PROTO(cpPinJointInit)
PROTO(cpPinJointNew)
PROTO(cpSlideJointAlloc)
PROTO(cpSlideJointInit)
PROTO(cpSlideJointNew)
PROTO(cpPivotJointAlloc)
PROTO(cpPivotJointInit)
PROTO(cpPivotJointNew)
PROTO(cpGrooveJointAlloc)
PROTO(cpGrooveJointInit)
PROTO(cpGrooveJointNew)
PROTO(cpResetShapeIdCounter)
PROTO(cpShapeInit)
PROTO(cpShapeDestroy)
PROTO(cpShapeFree)
PROTO(cpShapeCacheBB)
PROTO(cpCircleShapeAlloc)
PROTO(cpCircleShapeInit)
PROTO(cpCircleShapeNew)
PROTO(cpSegmentShapeAlloc)
PROTO(cpSegmentShapeInit)
PROTO(cpSegmentShapeNew)
PROTO(cpPolyShapeAlloc)
PROTO(cpPolyShapeInit)
PROTO(cpPolyShapeNew)

PROTO(cpArrayEach)

APTR FuncTable[] =
{
	(APTR)	FUNCARRAY_BEGIN,
	(APTR)	FUNCARRAY_32BIT_NATIVE, 

	(APTR)	LibOpen,
	(APTR)	LibClose,
	(APTR)	LibExpunge,
	(APTR)	LibReserved,
	(APTR)	-1,

	(APTR)	FUNCARRAY_32BIT_SYSTEMV,

TABLE(cpInitChipmunk)
TABLE(cpMomentForCircle)
TABLE(cpMomentForPoly)
TABLE(cpSpaceAlloc)
TABLE(cpSpaceInit)
TABLE(cpSpaceNew)
TABLE(cpSpaceDestroy)
TABLE(cpSpaceFree)

TABLE(cpSpaceFreeChildren)
TABLE(cpSpaceAddCollisionPairFunc)
TABLE(cpSpaceRemoveCollisionPairFunc)
TABLE(cpSpaceSetDefaultCollisionPairFunc)
TABLE(cpSpaceAddShape)
TABLE(cpSpaceAddStaticShape)
TABLE(cpSpaceAddBody)
TABLE(cpSpaceAddJoint)
TABLE(cpSpaceRemoveShape)
TABLE(cpSpaceRemoveStaticShape)
TABLE(cpSpaceRemoveBody)
TABLE(cpSpaceRemoveJoint)
TABLE(cpSpaceEachBody)
TABLE(cpSpaceResizeStaticHash)
TABLE(cpSpaceResizeActiveHash)
TABLE(cpSpaceRehashStatic)
TABLE(cpSpaceStep)

TABLE(cpvlength)
TABLE(cpvlengthsq)
TABLE(cpvnormalize)
TABLE(cpvforangle)
TABLE(cpvtoangle)
TABLE(cpvstr)

TABLE(cpBBClampVect)
TABLE(cpBBWrapVect)

TABLE(cpBodyAlloc)
TABLE(cpBodyInit)
TABLE(cpBodyNew)

TABLE(cpBodyDestroy)
TABLE(cpBodyFree)

TABLE(cpBodySetMass)
TABLE(cpBodySetMoment)
TABLE(cpBodySetAngle)
TABLE(cpBodySlew)
TABLE(cpBodyUpdateVelocity)
TABLE(cpBodyUpdatePosition)
TABLE(cpBodyResetForces)
TABLE(cpBodyApplyForce)
TABLE(cpDampedSpring)

TABLE(cpHashSetDestroy)
TABLE(cpHashSetFree)

TABLE(cpHashSetAlloc)
TABLE(cpHashSetInit)
TABLE(cpHashSetNew)

TABLE(cpHashSetInsert)
TABLE(cpHashSetRemove)
TABLE(cpHashSetFind)

TABLE(cpHashSetEach)
TABLE(cpHashSetReject)
TABLE(cpSpaceHashAlloc)
TABLE(cpSpaceHashInit)
TABLE(cpSpaceHashNew)

TABLE(cpSpaceHashDestroy)
TABLE(cpSpaceHashFree)

TABLE(cpSpaceHashResize)

TABLE(cpSpaceHashInsert)
TABLE(cpSpaceHashRemove)

TABLE(cpSpaceHashEach)

TABLE(cpSpaceHashRehash)
TABLE(cpSpaceHashRehashObject)

TABLE(cpSpaceHashQuery)
TABLE(cpSpaceHashQueryRehash)
TABLE(cpContactInit)

TABLE(cpContactsSumImpulses)
TABLE(cpContactsSumImpulsesWithFriction)
TABLE(cpArbiterAlloc)
TABLE(cpArbiterInit)
TABLE(cpArbiterNew)

TABLE(cpArbiterDestroy)
TABLE(cpArbiterFree)

TABLE(cpArbiterInject)
TABLE(cpArbiterPreStep)
TABLE(cpArbiterApplyImpulse)
TABLE(cpCollideShapes)
TABLE(cpJointDestroy)
TABLE(cpJointFree)
TABLE(cpPinJointAlloc)
TABLE(cpPinJointInit)
TABLE(cpPinJointNew)
TABLE(cpSlideJointAlloc)
TABLE(cpSlideJointInit)
TABLE(cpSlideJointNew)
TABLE(cpPivotJointAlloc)
TABLE(cpPivotJointInit)
TABLE(cpPivotJointNew)
TABLE(cpGrooveJointAlloc)
TABLE(cpGrooveJointInit)
TABLE(cpGrooveJointNew)
TABLE(cpResetShapeIdCounter)
TABLE(cpShapeInit)
TABLE(cpShapeDestroy)
TABLE(cpShapeFree)
TABLE(cpShapeCacheBB)
TABLE(cpCircleShapeAlloc)
TABLE(cpCircleShapeInit)
TABLE(cpCircleShapeNew)
TABLE(cpSegmentShapeAlloc)
TABLE(cpSegmentShapeInit)
TABLE(cpSegmentShapeNew)
TABLE(cpPolyShapeAlloc)
TABLE(cpPolyShapeInit)
TABLE(cpPolyShapeNew)

TABLE(cpArrayEach)

	(APTR)	-1,
	(APTR)	FUNCARRAY_END
};

#ifdef __cplusplus
}
#endif /* __cplusplus */
