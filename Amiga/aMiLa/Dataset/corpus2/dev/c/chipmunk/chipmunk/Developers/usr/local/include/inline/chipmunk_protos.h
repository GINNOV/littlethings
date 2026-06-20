/* Automatically generated header! Do not edit! */

#ifndef _VBCCINLINE_CHIPMUNK_H
#define _VBCCINLINE_CHIPMUNK_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

cpShape * __cpCircleShapeNew(cpBody *, cpFloat , cpVect ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-646(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpCircleShapeNew(__p0, __p1, __p2) __cpCircleShapeNew((__p0), (__p1), (__p2))

cpCircleShape * __cpCircleShapeAlloc() =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-634(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpCircleShapeAlloc() __cpCircleShapeAlloc()

void  __cpSpaceFree(cpSpace *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-70(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceFree(__p0) __cpSpaceFree((__p0))

void  __cpSpaceAddStaticShape(cpSpace *, cpShape *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-106(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceAddStaticShape(__p0, __p1) __cpSpaceAddStaticShape((__p0), (__p1))

char * __cpvstr(const cpVect ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-208(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpvstr(__p0) __cpvstr((__p0))

cpSegmentShape * __cpSegmentShapeAlloc() =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-652(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSegmentShapeAlloc() __cpSegmentShapeAlloc()

cpVect  __cpBBWrapVect(const cpBB , const cpVect ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-220(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpBBWrapVect(__p0, __p1) __cpBBWrapVect((__p0), (__p1))

void  __cpArbiterDestroy(cpArbiter *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-484(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpArbiterDestroy(__p0) __cpArbiterDestroy((__p0))

cpJoint * __cpPinJointNew(cpBody *, cpBody *, cpVect , cpVect ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-544(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpPinJointNew(__p0, __p1, __p2, __p3) __cpPinJointNew((__p0), (__p1), (__p2), (__p3))

cpPinJoint * __cpPinJointAlloc() =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-532(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpPinJointAlloc() __cpPinJointAlloc()

cpSpace * __cpSpaceNew() =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-58(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceNew() __cpSpaceNew()

cpCircleShape * __cpCircleShapeInit(cpCircleShape *, cpBody *, cpFloat , cpVect ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-640(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpCircleShapeInit(__p0, __p1, __p2, __p3) __cpCircleShapeInit((__p0), (__p1), (__p2), (__p3))

void  __cpSpaceFreeChildren(cpSpace *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-76(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceFreeChildren(__p0) __cpSpaceFreeChildren((__p0))

void  __cpBodyDestroy(cpBody *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-244(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpBodyDestroy(__p0) __cpBodyDestroy((__p0))

void  __cpHashSetDestroy(cpHashSet *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-310(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpHashSetDestroy(__p0) __cpHashSetDestroy((__p0))

void  __cpSpaceResizeActiveHash(cpSpace *, cpFloat , int ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-160(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceResizeActiveHash(__p0, __p1, __p2) __cpSpaceResizeActiveHash((__p0), (__p1), (__p2))

void  __cpSpaceHashRemove(cpSpaceHash *, void *, unsigned int ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-412(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceHashRemove(__p0, __p1, __p2) __cpSpaceHashRemove((__p0), (__p1), (__p2))

cpPinJoint * __cpPinJointInit(cpPinJoint *, cpBody *, cpBody *, cpVect , cpVect ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-538(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpPinJointInit(__p0, __p1, __p2, __p3, __p4) __cpPinJointInit((__p0), (__p1), (__p2), (__p3), (__p4))

cpVect  __cpContactsSumImpulsesWithFriction(cpContact *, int ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-460(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpContactsSumImpulsesWithFriction(__p0, __p1) __cpContactsSumImpulsesWithFriction((__p0), (__p1))

void  __cpSpaceHashQueryRehash(cpSpaceHash *, cpSpaceHashQueryFunc , void *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-442(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceHashQueryRehash(__p0, __p1, __p2) __cpSpaceHashQueryRehash((__p0), (__p1), (__p2))

cpPivotJoint * __cpPivotJointAlloc() =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-568(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpPivotJointAlloc() __cpPivotJointAlloc()

cpGrooveJoint * __cpGrooveJointAlloc() =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-586(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpGrooveJointAlloc() __cpGrooveJointAlloc()

void  __cpSpaceAddBody(cpSpace *, cpBody *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-112(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceAddBody(__p0, __p1) __cpSpaceAddBody((__p0), (__p1))

cpVect  __cpvforangle(const cpFloat ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-196(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpvforangle(__p0) __cpvforangle((__p0))

cpHashSet * __cpHashSetInit(cpHashSet *, int , cpHashSetEqlFunc , cpHashSetTransFunc ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-328(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpHashSetInit(__p0, __p1, __p2, __p3) __cpHashSetInit((__p0), (__p1), (__p2), (__p3))

void  __cpSpaceHashQuery(cpSpaceHash *, void *, cpBB , cpSpaceHashQueryFunc , void *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-436(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceHashQuery(__p0, __p1, __p2, __p3, __p4) __cpSpaceHashQuery((__p0), (__p1), (__p2), (__p3), (__p4))

void  __cpJointFree(cpJoint *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-526(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpJointFree(__p0) __cpJointFree((__p0))

void  __cpBodySlew(cpBody *, cpVect , cpFloat ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-274(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpBodySlew(__p0, __p1, __p2) __cpBodySlew((__p0), (__p1), (__p2))

void  __cpSpaceEachBody(cpSpace *, cpSpaceBodyIterator , void *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-148(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceEachBody(__p0, __p1, __p2) __cpSpaceEachBody((__p0), (__p1), (__p2))

void  __cpBodyFree(cpBody *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-250(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpBodyFree(__p0) __cpBodyFree((__p0))

void  __cpSpaceHashFree(cpSpaceHash *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-394(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceHashFree(__p0) __cpSpaceHashFree((__p0))

void  __cpShapeFree(cpShape *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-622(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpShapeFree(__p0) __cpShapeFree((__p0))

void  __cpInitChipmunk() =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-28(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpInitChipmunk() __cpInitChipmunk()

void  __cpSpaceDestroy(cpSpace *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-64(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceDestroy(__p0) __cpSpaceDestroy((__p0))

cpBody * __cpBodyAlloc() =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-226(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpBodyAlloc() __cpBodyAlloc()

void  __cpSpaceAddJoint(cpSpace *, cpJoint *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-118(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceAddJoint(__p0, __p1) __cpSpaceAddJoint((__p0), (__p1))

cpSpaceHash * __cpSpaceHashNew(cpFloat , int , cpSpaceHashBBFunc ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-382(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceHashNew(__p0, __p1, __p2) __cpSpaceHashNew((__p0), (__p1), (__p2))

cpHashSet * __cpHashSetAlloc() =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-322(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpHashSetAlloc() __cpHashSetAlloc()

void  __cpShapeDestroy(cpShape *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-616(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpShapeDestroy(__p0) __cpShapeDestroy((__p0))

cpArbiter * __cpArbiterInit(cpArbiter *, cpShape *, cpShape *, int ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-472(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpArbiterInit(__p0, __p1, __p2, __p3) __cpArbiterInit((__p0), (__p1), (__p2), (__p3))

void  __cpSpaceRemoveJoint(cpSpace *, cpJoint *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-142(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceRemoveJoint(__p0, __p1) __cpSpaceRemoveJoint((__p0), (__p1))

cpJoint * __cpSlideJointNew(cpBody *, cpBody *, cpVect , cpVect , cpFloat , cpFloat ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-562(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSlideJointNew(__p0, __p1, __p2, __p3, __p4, __p5) __cpSlideJointNew((__p0), (__p1), (__p2), (__p3), (__p4), (__p5))

cpFloat  __cpvtoangle(const cpVect ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-202(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpvtoangle(__p0) __cpvtoangle((__p0))

cpSlideJoint * __cpSlideJointAlloc() =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-550(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSlideJointAlloc() __cpSlideJointAlloc()

cpSpace * __cpSpaceInit(cpSpace *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-52(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceInit(__p0) __cpSpaceInit((__p0))

void  __cpBodySetAngle(cpBody *, cpFloat ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-268(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpBodySetAngle(__p0, __p1) __cpBodySetAngle((__p0), (__p1))

void  __cpSpaceHashEach(cpSpaceHash *, cpSpaceHashIterator , void *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-418(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceHashEach(__p0, __p1, __p2) __cpSpaceHashEach((__p0), (__p1), (__p2))

void  __cpResetShapeIdCounter() =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-604(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpResetShapeIdCounter() __cpResetShapeIdCounter()

void  __cpSpaceSetDefaultCollisionPairFunc(cpSpace *, cpCollFunc , void *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-94(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceSetDefaultCollisionPairFunc(__p0, __p1, __p2) __cpSpaceSetDefaultCollisionPairFunc((__p0), (__p1), (__p2))

void  __cpBodyApplyForce(cpBody *, cpVect , cpVect ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-298(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpBodyApplyForce(__p0, __p1, __p2) __cpBodyApplyForce((__p0), (__p1), (__p2))

void  __cpSpaceHashInsert(cpSpaceHash *, void *, unsigned int , cpBB ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-406(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceHashInsert(__p0, __p1, __p2, __p3) __cpSpaceHashInsert((__p0), (__p1), (__p2), (__p3))

void  __cpSpaceAddShape(cpSpace *, cpShape *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-100(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceAddShape(__p0, __p1) __cpSpaceAddShape((__p0), (__p1))

cpVect  __cpvnormalize(const cpVect ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-190(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpvnormalize(__p0) __cpvnormalize((__p0))

cpFloat  __cpMomentForCircle(cpFloat , cpFloat , cpFloat , cpVect ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-34(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpMomentForCircle(__p0, __p1, __p2, __p3) __cpMomentForCircle((__p0), (__p1), (__p2), (__p3))

cpPolyShape * __cpPolyShapeInit(cpPolyShape *, cpBody *, int , cpVect *, cpVect ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-676(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpPolyShapeInit(__p0, __p1, __p2, __p3, __p4) __cpPolyShapeInit((__p0), (__p1), (__p2), (__p3), (__p4))

cpPivotJoint * __cpPivotJointInit(cpPivotJoint *, cpBody *, cpBody *, cpVect ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-574(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpPivotJointInit(__p0, __p1, __p2, __p3) __cpPivotJointInit((__p0), (__p1), (__p2), (__p3))

cpGrooveJoint * __cpGrooveJointInit(cpGrooveJoint *, cpBody *, cpBody *, cpVect , cpVect , cpVect ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-592(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpGrooveJointInit(__p0, __p1, __p2, __p3, __p4, __p5) __cpGrooveJointInit((__p0), (__p1), (__p2), (__p3), (__p4), (__p5))

void  __cpSpaceHashRehash(cpSpaceHash *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-424(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceHashRehash(__p0) __cpSpaceHashRehash((__p0))

void  __cpSpaceRemoveShape(cpSpace *, cpShape *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-124(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceRemoveShape(__p0, __p1) __cpSpaceRemoveShape((__p0), (__p1))

void  __cpHashSetReject(cpHashSet *, cpHashSetRejectFunc , void *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-364(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpHashSetReject(__p0, __p1, __p2) __cpHashSetReject((__p0), (__p1), (__p2))

void  __cpJointDestroy(cpJoint *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-520(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpJointDestroy(__p0) __cpJointDestroy((__p0))

void  __cpBodySetMass(cpBody *, cpFloat ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-256(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpBodySetMass(__p0, __p1) __cpBodySetMass((__p0), (__p1))

cpShape * __cpSegmentShapeNew(cpBody *, cpVect , cpVect , cpFloat ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-664(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSegmentShapeNew(__p0, __p1, __p2, __p3) __cpSegmentShapeNew((__p0), (__p1), (__p2), (__p3))

void * __cpHashSetFind(cpHashSet *, unsigned int , void *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-352(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpHashSetFind(__p0, __p1, __p2) __cpHashSetFind((__p0), (__p1), (__p2))

void  __cpSpaceRemoveStaticShape(cpSpace *, cpShape *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-130(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceRemoveStaticShape(__p0, __p1) __cpSpaceRemoveStaticShape((__p0), (__p1))

cpSpace * __cpSpaceAlloc() =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-46(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceAlloc() __cpSpaceAlloc()

cpFloat  __cpvlength(const cpVect ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-178(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpvlength(__p0) __cpvlength((__p0))

void  __cpSpaceAddCollisionPairFunc(cpSpace *, unsigned int , unsigned int , cpCollFunc , void *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-82(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceAddCollisionPairFunc(__p0, __p1, __p2, __p3, __p4) __cpSpaceAddCollisionPairFunc((__p0), (__p1), (__p2), (__p3), (__p4))

void  __cpSpaceHashDestroy(cpSpaceHash *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-388(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceHashDestroy(__p0) __cpSpaceHashDestroy((__p0))

cpFloat  __cpvlengthsq(const cpVect ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-184(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpvlengthsq(__p0) __cpvlengthsq((__p0))

void * __cpHashSetRemove(cpHashSet *, unsigned int , void *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-346(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpHashSetRemove(__p0, __p1, __p2) __cpHashSetRemove((__p0), (__p1), (__p2))

void  __cpDampedSpring(cpBody *, cpBody *, cpVect , cpVect , cpFloat , cpFloat , cpFloat , cpFloat ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-304(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpDampedSpring(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7) __cpDampedSpring((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6), (__p7))

void  __cpSpaceRemoveCollisionPairFunc(cpSpace *, unsigned int , unsigned int ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-88(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceRemoveCollisionPairFunc(__p0, __p1, __p2) __cpSpaceRemoveCollisionPairFunc((__p0), (__p1), (__p2))

cpJoint * __cpPivotJointNew(cpBody *, cpBody *, cpVect ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-580(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpPivotJointNew(__p0, __p1, __p2) __cpPivotJointNew((__p0), (__p1), (__p2))

cpJoint * __cpGrooveJointNew(cpBody *, cpBody *, cpVect , cpVect , cpVect ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-598(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpGrooveJointNew(__p0, __p1, __p2, __p3, __p4) __cpGrooveJointNew((__p0), (__p1), (__p2), (__p3), (__p4))

void  __cpSpaceHashRehashObject(cpSpaceHash *, void *, unsigned int ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-430(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceHashRehashObject(__p0, __p1, __p2) __cpSpaceHashRehashObject((__p0), (__p1), (__p2))

void  __cpSpaceHashResize(cpSpaceHash *, cpFloat , int ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-400(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceHashResize(__p0, __p1, __p2) __cpSpaceHashResize((__p0), (__p1), (__p2))

cpBody * __cpBodyInit(cpBody *, cpFloat , cpFloat ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-232(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpBodyInit(__p0, __p1, __p2) __cpBodyInit((__p0), (__p1), (__p2))

cpVect  __cpBBClampVect(const cpBB , const cpVect ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-214(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpBBClampVect(__p0, __p1) __cpBBClampVect((__p0), (__p1))

cpSpaceHash * __cpSpaceHashInit(cpSpaceHash *, cpFloat , int , cpSpaceHashBBFunc ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-376(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceHashInit(__p0, __p1, __p2, __p3) __cpSpaceHashInit((__p0), (__p1), (__p2), (__p3))

cpShape * __cpShapeInit(cpShape *, cpShapeType , cpBody *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-610(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpShapeInit(__p0, __p1, __p2) __cpShapeInit((__p0), (__p1), (__p2))

cpVect  __cpContactsSumImpulses(cpContact *, int ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-454(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpContactsSumImpulses(__p0, __p1) __cpContactsSumImpulses((__p0), (__p1))

void  __cpBodyUpdatePosition(cpBody *, cpFloat ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-286(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpBodyUpdatePosition(__p0, __p1) __cpBodyUpdatePosition((__p0), (__p1))

void  __cpBodySetMoment(cpBody *, cpFloat ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-262(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpBodySetMoment(__p0, __p1) __cpBodySetMoment((__p0), (__p1))

void  __cpSpaceResizeStaticHash(cpSpace *, cpFloat , int ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-154(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceResizeStaticHash(__p0, __p1, __p2) __cpSpaceResizeStaticHash((__p0), (__p1), (__p2))

void  __cpArbiterPreStep(cpArbiter *, cpFloat ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-502(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpArbiterPreStep(__p0, __p1) __cpArbiterPreStep((__p0), (__p1))

void  __cpArbiterApplyImpulse(cpArbiter *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-508(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpArbiterApplyImpulse(__p0) __cpArbiterApplyImpulse((__p0))

void  __cpSpaceRehashStatic(cpSpace *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-166(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceRehashStatic(__p0) __cpSpaceRehashStatic((__p0))

void  __cpArrayEach(cpArray *, cpArrayIter , void *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-688(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpArrayEach(__p0, __p1, __p2) __cpArrayEach((__p0), (__p1), (__p2))

void  __cpHashSetFree(cpHashSet *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-316(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpHashSetFree(__p0) __cpHashSetFree((__p0))

void  __cpBodyResetForces(cpBody *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-292(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpBodyResetForces(__p0) __cpBodyResetForces((__p0))

cpArbiter * __cpArbiterNew(cpShape *, cpShape *, int ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-478(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpArbiterNew(__p0, __p1, __p2) __cpArbiterNew((__p0), (__p1), (__p2))

cpArbiter * __cpArbiterAlloc() =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-466(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpArbiterAlloc() __cpArbiterAlloc()

cpSegmentShape * __cpSegmentShapeInit(cpSegmentShape *, cpBody *, cpVect , cpVect , cpFloat ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-658(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSegmentShapeInit(__p0, __p1, __p2, __p3, __p4) __cpSegmentShapeInit((__p0), (__p1), (__p2), (__p3), (__p4))

cpBody * __cpBodyNew(cpFloat , cpFloat ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-238(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpBodyNew(__p0, __p1) __cpBodyNew((__p0), (__p1))

cpHashSet * __cpHashSetNew(int , cpHashSetEqlFunc , cpHashSetTransFunc ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-334(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpHashSetNew(__p0, __p1, __p2) __cpHashSetNew((__p0), (__p1), (__p2))

cpSpaceHash * __cpSpaceHashAlloc() =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-370(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceHashAlloc() __cpSpaceHashAlloc()

cpFloat  __cpMomentForPoly(cpFloat , int , cpVect *, cpVect ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-40(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpMomentForPoly(__p0, __p1, __p2, __p3) __cpMomentForPoly((__p0), (__p1), (__p2), (__p3))

cpShape * __cpPolyShapeNew(cpBody *, int , cpVect *, cpVect ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-682(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpPolyShapeNew(__p0, __p1, __p2, __p3) __cpPolyShapeNew((__p0), (__p1), (__p2), (__p3))

cpContact * __cpContactInit(cpContact *, cpVect , cpVect , cpFloat , unsigned int ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-448(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpContactInit(__p0, __p1, __p2, __p3, __p4) __cpContactInit((__p0), (__p1), (__p2), (__p3), (__p4))

cpPolyShape * __cpPolyShapeAlloc() =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-670(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpPolyShapeAlloc() __cpPolyShapeAlloc()

void  __cpBodyUpdateVelocity(cpBody *, cpVect , cpFloat , cpFloat ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-280(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpBodyUpdateVelocity(__p0, __p1, __p2, __p3) __cpBodyUpdateVelocity((__p0), (__p1), (__p2), (__p3))

int  __cpCollideShapes(cpShape *, cpShape *, cpContact **) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-514(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpCollideShapes(__p0, __p1, __p2) __cpCollideShapes((__p0), (__p1), (__p2))

void  __cpHashSetEach(cpHashSet *, cpHashSetIterFunc , void *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-358(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpHashSetEach(__p0, __p1, __p2) __cpHashSetEach((__p0), (__p1), (__p2))

void * __cpHashSetInsert(cpHashSet *, unsigned int , void *, void *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-340(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpHashSetInsert(__p0, __p1, __p2, __p3) __cpHashSetInsert((__p0), (__p1), (__p2), (__p3))

void  __cpArbiterInject(cpArbiter *, cpContact *, int ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-496(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpArbiterInject(__p0, __p1, __p2) __cpArbiterInject((__p0), (__p1), (__p2))

void  __cpSpaceRemoveBody(cpSpace *, cpBody *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-136(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceRemoveBody(__p0, __p1) __cpSpaceRemoveBody((__p0), (__p1))

void  __cpSpaceStep(cpSpace *, cpFloat ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-172(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSpaceStep(__p0, __p1) __cpSpaceStep((__p0), (__p1))

cpBB  __cpShapeCacheBB(cpShape *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-628(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpShapeCacheBB(__p0) __cpShapeCacheBB((__p0))

cpSlideJoint * __cpSlideJointInit(cpSlideJoint *, cpBody *, cpBody *, cpVect , cpVect , cpFloat , cpFloat ) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-556(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpSlideJointInit(__p0, __p1, __p2, __p3, __p4, __p5, __p6) __cpSlideJointInit((__p0), (__p1), (__p2), (__p3), (__p4), (__p5), (__p6))

void  __cpArbiterFree(cpArbiter *) =
	"\tlis\t11,ChipmunkBase@ha\n"
	"\tlwz\t12,ChipmunkBase@l(11)\n"
	"\tlwz\t0,-490(12)\n"
	"\tmtlr\t0\n"
	"\tblrl";
#define cpArbiterFree(__p0) __cpArbiterFree((__p0))

#endif /* !_VBCCINLINE_CHIPMUNK_H */
