/* Automatically generated header! Do not edit! */

#ifndef _PPCINLINE_CHIPMUNK_H
#define _PPCINLINE_CHIPMUNK_H

#ifndef __PPCINLINE_MACROS_H
#include <ppcinline/macros.h>
#endif /* !__PPCINLINE_MACROS_H */

#ifndef CHIPMUNK_BASE_NAME
#define CHIPMUNK_BASE_NAME ChipmunkBase
#endif /* !CHIPMUNK_BASE_NAME */

#define cpCircleShapeNew(__p0, __p1, __p2) \
	({ \
		cpBody * __t__p0 = __p0;\
		cpFloat  __t__p1 = __p1;\
		cpVect  __t__p2 = __p2;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpShape *(*)(cpBody *, cpFloat , cpVect ))*(void**)(__base - 646))(__t__p0, __t__p1, __t__p2));\
	})

#define cpCircleShapeAlloc() \
	({ \
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpCircleShape *(*)(void))*(void**)(__base - 634))());\
	})

#define cpSpaceFree(__p0) \
	({ \
		cpSpace * __t__p0 = __p0;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpace *))*(void**)(__base - 70))(__t__p0));\
	})

#define cpSpaceAddStaticShape(__p0, __p1) \
	({ \
		cpSpace * __t__p0 = __p0;\
		cpShape * __t__p1 = __p1;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpace *, cpShape *))*(void**)(__base - 106))(__t__p0, __t__p1));\
	})

#define cpvstr(__p0) \
	({ \
		const cpVect  __t__p0 = __p0;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((char *(*)(const cpVect ))*(void**)(__base - 208))(__t__p0));\
	})

#define cpSegmentShapeAlloc() \
	({ \
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpSegmentShape *(*)(void))*(void**)(__base - 652))());\
	})

#define cpBBWrapVect(__p0, __p1) \
	({ \
		const cpBB  __t__p0 = __p0;\
		const cpVect  __t__p1 = __p1;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpVect (*)(const cpBB , const cpVect ))*(void**)(__base - 220))(__t__p0, __t__p1));\
	})

#define cpArbiterDestroy(__p0) \
	({ \
		cpArbiter * __t__p0 = __p0;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpArbiter *))*(void**)(__base - 484))(__t__p0));\
	})

#define cpPinJointNew(__p0, __p1, __p2, __p3) \
	({ \
		cpBody * __t__p0 = __p0;\
		cpBody * __t__p1 = __p1;\
		cpVect  __t__p2 = __p2;\
		cpVect  __t__p3 = __p3;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpJoint *(*)(cpBody *, cpBody *, cpVect , cpVect ))*(void**)(__base - 544))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define cpPinJointAlloc() \
	({ \
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpPinJoint *(*)(void))*(void**)(__base - 532))());\
	})

#define cpSpaceNew() \
	({ \
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpSpace *(*)(void))*(void**)(__base - 58))());\
	})

#define cpCircleShapeInit(__p0, __p1, __p2, __p3) \
	({ \
		cpCircleShape * __t__p0 = __p0;\
		cpBody * __t__p1 = __p1;\
		cpFloat  __t__p2 = __p2;\
		cpVect  __t__p3 = __p3;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpCircleShape *(*)(cpCircleShape *, cpBody *, cpFloat , cpVect ))*(void**)(__base - 640))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define cpSpaceFreeChildren(__p0) \
	({ \
		cpSpace * __t__p0 = __p0;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpace *))*(void**)(__base - 76))(__t__p0));\
	})

#define cpBodyDestroy(__p0) \
	({ \
		cpBody * __t__p0 = __p0;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpBody *))*(void**)(__base - 244))(__t__p0));\
	})

#define cpHashSetDestroy(__p0) \
	({ \
		cpHashSet * __t__p0 = __p0;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpHashSet *))*(void**)(__base - 310))(__t__p0));\
	})

#define cpSpaceResizeActiveHash(__p0, __p1, __p2) \
	({ \
		cpSpace * __t__p0 = __p0;\
		cpFloat  __t__p1 = __p1;\
		int  __t__p2 = __p2;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpace *, cpFloat , int ))*(void**)(__base - 160))(__t__p0, __t__p1, __t__p2));\
	})

#define cpSpaceHashRemove(__p0, __p1, __p2) \
	({ \
		cpSpaceHash * __t__p0 = __p0;\
		void * __t__p1 = __p1;\
		unsigned int  __t__p2 = __p2;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpaceHash *, void *, unsigned int ))*(void**)(__base - 412))(__t__p0, __t__p1, __t__p2));\
	})

#define cpPinJointInit(__p0, __p1, __p2, __p3, __p4) \
	({ \
		cpPinJoint * __t__p0 = __p0;\
		cpBody * __t__p1 = __p1;\
		cpBody * __t__p2 = __p2;\
		cpVect  __t__p3 = __p3;\
		cpVect  __t__p4 = __p4;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpPinJoint *(*)(cpPinJoint *, cpBody *, cpBody *, cpVect , cpVect ))*(void**)(__base - 538))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define cpContactsSumImpulsesWithFriction(__p0, __p1) \
	({ \
		cpContact * __t__p0 = __p0;\
		int  __t__p1 = __p1;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpVect (*)(cpContact *, int ))*(void**)(__base - 460))(__t__p0, __t__p1));\
	})

#define cpSpaceHashQueryRehash(__p0, __p1, __p2) \
	({ \
		cpSpaceHash * __t__p0 = __p0;\
		cpSpaceHashQueryFunc  __t__p1 = __p1;\
		void * __t__p2 = __p2;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpaceHash *, cpSpaceHashQueryFunc , void *))*(void**)(__base - 442))(__t__p0, __t__p1, __t__p2));\
	})

#define cpPivotJointAlloc() \
	({ \
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpPivotJoint *(*)(void))*(void**)(__base - 568))());\
	})

#define cpGrooveJointAlloc() \
	({ \
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpGrooveJoint *(*)(void))*(void**)(__base - 586))());\
	})

#define cpSpaceAddBody(__p0, __p1) \
	({ \
		cpSpace * __t__p0 = __p0;\
		cpBody * __t__p1 = __p1;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpace *, cpBody *))*(void**)(__base - 112))(__t__p0, __t__p1));\
	})

#define cpvforangle(__p0) \
	({ \
		const cpFloat  __t__p0 = __p0;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpVect (*)(const cpFloat ))*(void**)(__base - 196))(__t__p0));\
	})

#define cpHashSetInit(__p0, __p1, __p2, __p3) \
	({ \
		cpHashSet * __t__p0 = __p0;\
		int  __t__p1 = __p1;\
		cpHashSetEqlFunc  __t__p2 = __p2;\
		cpHashSetTransFunc  __t__p3 = __p3;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpHashSet *(*)(cpHashSet *, int , cpHashSetEqlFunc , cpHashSetTransFunc ))*(void**)(__base - 328))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define cpSpaceHashQuery(__p0, __p1, __p2, __p3, __p4) \
	({ \
		cpSpaceHash * __t__p0 = __p0;\
		void * __t__p1 = __p1;\
		cpBB  __t__p2 = __p2;\
		cpSpaceHashQueryFunc  __t__p3 = __p3;\
		void * __t__p4 = __p4;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpaceHash *, void *, cpBB , cpSpaceHashQueryFunc , void *))*(void**)(__base - 436))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define cpJointFree(__p0) \
	({ \
		cpJoint * __t__p0 = __p0;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpJoint *))*(void**)(__base - 526))(__t__p0));\
	})

#define cpBodySlew(__p0, __p1, __p2) \
	({ \
		cpBody * __t__p0 = __p0;\
		cpVect  __t__p1 = __p1;\
		cpFloat  __t__p2 = __p2;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpBody *, cpVect , cpFloat ))*(void**)(__base - 274))(__t__p0, __t__p1, __t__p2));\
	})

#define cpSpaceEachBody(__p0, __p1, __p2) \
	({ \
		cpSpace * __t__p0 = __p0;\
		cpSpaceBodyIterator  __t__p1 = __p1;\
		void * __t__p2 = __p2;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpace *, cpSpaceBodyIterator , void *))*(void**)(__base - 148))(__t__p0, __t__p1, __t__p2));\
	})

#define cpBodyFree(__p0) \
	({ \
		cpBody * __t__p0 = __p0;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpBody *))*(void**)(__base - 250))(__t__p0));\
	})

#define cpSpaceHashFree(__p0) \
	({ \
		cpSpaceHash * __t__p0 = __p0;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpaceHash *))*(void**)(__base - 394))(__t__p0));\
	})

#define cpShapeFree(__p0) \
	({ \
		cpShape * __t__p0 = __p0;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpShape *))*(void**)(__base - 622))(__t__p0));\
	})

#define cpInitChipmunk() \
	({ \
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(void))*(void**)(__base - 28))());\
	})

#define cpSpaceDestroy(__p0) \
	({ \
		cpSpace * __t__p0 = __p0;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpace *))*(void**)(__base - 64))(__t__p0));\
	})

#define cpBodyAlloc() \
	({ \
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpBody *(*)(void))*(void**)(__base - 226))());\
	})

#define cpSpaceAddJoint(__p0, __p1) \
	({ \
		cpSpace * __t__p0 = __p0;\
		cpJoint * __t__p1 = __p1;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpace *, cpJoint *))*(void**)(__base - 118))(__t__p0, __t__p1));\
	})

#define cpSpaceHashNew(__p0, __p1, __p2) \
	({ \
		cpFloat  __t__p0 = __p0;\
		int  __t__p1 = __p1;\
		cpSpaceHashBBFunc  __t__p2 = __p2;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpSpaceHash *(*)(cpFloat , int , cpSpaceHashBBFunc ))*(void**)(__base - 382))(__t__p0, __t__p1, __t__p2));\
	})

#define cpHashSetAlloc() \
	({ \
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpHashSet *(*)(void))*(void**)(__base - 322))());\
	})

#define cpShapeDestroy(__p0) \
	({ \
		cpShape * __t__p0 = __p0;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpShape *))*(void**)(__base - 616))(__t__p0));\
	})

#define cpArbiterInit(__p0, __p1, __p2, __p3) \
	({ \
		cpArbiter * __t__p0 = __p0;\
		cpShape * __t__p1 = __p1;\
		cpShape * __t__p2 = __p2;\
		int  __t__p3 = __p3;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpArbiter *(*)(cpArbiter *, cpShape *, cpShape *, int ))*(void**)(__base - 472))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define cpSpaceRemoveJoint(__p0, __p1) \
	({ \
		cpSpace * __t__p0 = __p0;\
		cpJoint * __t__p1 = __p1;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpace *, cpJoint *))*(void**)(__base - 142))(__t__p0, __t__p1));\
	})

#define cpSlideJointNew(__p0, __p1, __p2, __p3, __p4, __p5) \
	({ \
		cpBody * __t__p0 = __p0;\
		cpBody * __t__p1 = __p1;\
		cpVect  __t__p2 = __p2;\
		cpVect  __t__p3 = __p3;\
		cpFloat  __t__p4 = __p4;\
		cpFloat  __t__p5 = __p5;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpJoint *(*)(cpBody *, cpBody *, cpVect , cpVect , cpFloat , cpFloat ))*(void**)(__base - 562))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5));\
	})

#define cpvtoangle(__p0) \
	({ \
		const cpVect  __t__p0 = __p0;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpFloat (*)(const cpVect ))*(void**)(__base - 202))(__t__p0));\
	})

#define cpSlideJointAlloc() \
	({ \
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpSlideJoint *(*)(void))*(void**)(__base - 550))());\
	})

#define cpSpaceInit(__p0) \
	({ \
		cpSpace * __t__p0 = __p0;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpSpace *(*)(cpSpace *))*(void**)(__base - 52))(__t__p0));\
	})

#define cpBodySetAngle(__p0, __p1) \
	({ \
		cpBody * __t__p0 = __p0;\
		cpFloat  __t__p1 = __p1;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpBody *, cpFloat ))*(void**)(__base - 268))(__t__p0, __t__p1));\
	})

#define cpSpaceHashEach(__p0, __p1, __p2) \
	({ \
		cpSpaceHash * __t__p0 = __p0;\
		cpSpaceHashIterator  __t__p1 = __p1;\
		void * __t__p2 = __p2;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpaceHash *, cpSpaceHashIterator , void *))*(void**)(__base - 418))(__t__p0, __t__p1, __t__p2));\
	})

#define cpResetShapeIdCounter() \
	({ \
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(void))*(void**)(__base - 604))());\
	})

#define cpSpaceSetDefaultCollisionPairFunc(__p0, __p1, __p2) \
	({ \
		cpSpace * __t__p0 = __p0;\
		cpCollFunc  __t__p1 = __p1;\
		void * __t__p2 = __p2;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpace *, cpCollFunc , void *))*(void**)(__base - 94))(__t__p0, __t__p1, __t__p2));\
	})

#define cpBodyApplyForce(__p0, __p1, __p2) \
	({ \
		cpBody * __t__p0 = __p0;\
		cpVect  __t__p1 = __p1;\
		cpVect  __t__p2 = __p2;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpBody *, cpVect , cpVect ))*(void**)(__base - 298))(__t__p0, __t__p1, __t__p2));\
	})

#define cpSpaceHashInsert(__p0, __p1, __p2, __p3) \
	({ \
		cpSpaceHash * __t__p0 = __p0;\
		void * __t__p1 = __p1;\
		unsigned int  __t__p2 = __p2;\
		cpBB  __t__p3 = __p3;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpaceHash *, void *, unsigned int , cpBB ))*(void**)(__base - 406))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define cpSpaceAddShape(__p0, __p1) \
	({ \
		cpSpace * __t__p0 = __p0;\
		cpShape * __t__p1 = __p1;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpace *, cpShape *))*(void**)(__base - 100))(__t__p0, __t__p1));\
	})

#define cpvnormalize(__p0) \
	({ \
		const cpVect  __t__p0 = __p0;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpVect (*)(const cpVect ))*(void**)(__base - 190))(__t__p0));\
	})

#define cpMomentForCircle(__p0, __p1, __p2, __p3) \
	({ \
		cpFloat  __t__p0 = __p0;\
		cpFloat  __t__p1 = __p1;\
		cpFloat  __t__p2 = __p2;\
		cpVect  __t__p3 = __p3;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpFloat (*)(cpFloat , cpFloat , cpFloat , cpVect ))*(void**)(__base - 34))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define cpPolyShapeInit(__p0, __p1, __p2, __p3, __p4) \
	({ \
		cpPolyShape * __t__p0 = __p0;\
		cpBody * __t__p1 = __p1;\
		int  __t__p2 = __p2;\
		cpVect * __t__p3 = __p3;\
		cpVect  __t__p4 = __p4;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpPolyShape *(*)(cpPolyShape *, cpBody *, int , cpVect *, cpVect ))*(void**)(__base - 676))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define cpPivotJointInit(__p0, __p1, __p2, __p3) \
	({ \
		cpPivotJoint * __t__p0 = __p0;\
		cpBody * __t__p1 = __p1;\
		cpBody * __t__p2 = __p2;\
		cpVect  __t__p3 = __p3;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpPivotJoint *(*)(cpPivotJoint *, cpBody *, cpBody *, cpVect ))*(void**)(__base - 574))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define cpGrooveJointInit(__p0, __p1, __p2, __p3, __p4, __p5) \
	({ \
		cpGrooveJoint * __t__p0 = __p0;\
		cpBody * __t__p1 = __p1;\
		cpBody * __t__p2 = __p2;\
		cpVect  __t__p3 = __p3;\
		cpVect  __t__p4 = __p4;\
		cpVect  __t__p5 = __p5;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpGrooveJoint *(*)(cpGrooveJoint *, cpBody *, cpBody *, cpVect , cpVect , cpVect ))*(void**)(__base - 592))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5));\
	})

#define cpSpaceHashRehash(__p0) \
	({ \
		cpSpaceHash * __t__p0 = __p0;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpaceHash *))*(void**)(__base - 424))(__t__p0));\
	})

#define cpSpaceRemoveShape(__p0, __p1) \
	({ \
		cpSpace * __t__p0 = __p0;\
		cpShape * __t__p1 = __p1;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpace *, cpShape *))*(void**)(__base - 124))(__t__p0, __t__p1));\
	})

#define cpHashSetReject(__p0, __p1, __p2) \
	({ \
		cpHashSet * __t__p0 = __p0;\
		cpHashSetRejectFunc  __t__p1 = __p1;\
		void * __t__p2 = __p2;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpHashSet *, cpHashSetRejectFunc , void *))*(void**)(__base - 364))(__t__p0, __t__p1, __t__p2));\
	})

#define cpJointDestroy(__p0) \
	({ \
		cpJoint * __t__p0 = __p0;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpJoint *))*(void**)(__base - 520))(__t__p0));\
	})

#define cpBodySetMass(__p0, __p1) \
	({ \
		cpBody * __t__p0 = __p0;\
		cpFloat  __t__p1 = __p1;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpBody *, cpFloat ))*(void**)(__base - 256))(__t__p0, __t__p1));\
	})

#define cpSegmentShapeNew(__p0, __p1, __p2, __p3) \
	({ \
		cpBody * __t__p0 = __p0;\
		cpVect  __t__p1 = __p1;\
		cpVect  __t__p2 = __p2;\
		cpFloat  __t__p3 = __p3;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpShape *(*)(cpBody *, cpVect , cpVect , cpFloat ))*(void**)(__base - 664))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define cpHashSetFind(__p0, __p1, __p2) \
	({ \
		cpHashSet * __t__p0 = __p0;\
		unsigned int  __t__p1 = __p1;\
		void * __t__p2 = __p2;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void *(*)(cpHashSet *, unsigned int , void *))*(void**)(__base - 352))(__t__p0, __t__p1, __t__p2));\
	})

#define cpSpaceRemoveStaticShape(__p0, __p1) \
	({ \
		cpSpace * __t__p0 = __p0;\
		cpShape * __t__p1 = __p1;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpace *, cpShape *))*(void**)(__base - 130))(__t__p0, __t__p1));\
	})

#define cpSpaceAlloc() \
	({ \
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpSpace *(*)(void))*(void**)(__base - 46))());\
	})

#define cpvlength(__p0) \
	({ \
		const cpVect  __t__p0 = __p0;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpFloat (*)(const cpVect ))*(void**)(__base - 178))(__t__p0));\
	})

#define cpSpaceAddCollisionPairFunc(__p0, __p1, __p2, __p3, __p4) \
	({ \
		cpSpace * __t__p0 = __p0;\
		unsigned int  __t__p1 = __p1;\
		unsigned int  __t__p2 = __p2;\
		cpCollFunc  __t__p3 = __p3;\
		void * __t__p4 = __p4;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpace *, unsigned int , unsigned int , cpCollFunc , void *))*(void**)(__base - 82))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define cpSpaceHashDestroy(__p0) \
	({ \
		cpSpaceHash * __t__p0 = __p0;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpaceHash *))*(void**)(__base - 388))(__t__p0));\
	})

#define cpvlengthsq(__p0) \
	({ \
		const cpVect  __t__p0 = __p0;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpFloat (*)(const cpVect ))*(void**)(__base - 184))(__t__p0));\
	})

#define cpHashSetRemove(__p0, __p1, __p2) \
	({ \
		cpHashSet * __t__p0 = __p0;\
		unsigned int  __t__p1 = __p1;\
		void * __t__p2 = __p2;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void *(*)(cpHashSet *, unsigned int , void *))*(void**)(__base - 346))(__t__p0, __t__p1, __t__p2));\
	})

#define cpDampedSpring(__p0, __p1, __p2, __p3, __p4, __p5, __p6, __p7) \
	({ \
		cpBody * __t__p0 = __p0;\
		cpBody * __t__p1 = __p1;\
		cpVect  __t__p2 = __p2;\
		cpVect  __t__p3 = __p3;\
		cpFloat  __t__p4 = __p4;\
		cpFloat  __t__p5 = __p5;\
		cpFloat  __t__p6 = __p6;\
		cpFloat  __t__p7 = __p7;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpBody *, cpBody *, cpVect , cpVect , cpFloat , cpFloat , cpFloat , cpFloat ))*(void**)(__base - 304))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5, __t__p6, __t__p7));\
	})

#define cpSpaceRemoveCollisionPairFunc(__p0, __p1, __p2) \
	({ \
		cpSpace * __t__p0 = __p0;\
		unsigned int  __t__p1 = __p1;\
		unsigned int  __t__p2 = __p2;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpace *, unsigned int , unsigned int ))*(void**)(__base - 88))(__t__p0, __t__p1, __t__p2));\
	})

#define cpPivotJointNew(__p0, __p1, __p2) \
	({ \
		cpBody * __t__p0 = __p0;\
		cpBody * __t__p1 = __p1;\
		cpVect  __t__p2 = __p2;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpJoint *(*)(cpBody *, cpBody *, cpVect ))*(void**)(__base - 580))(__t__p0, __t__p1, __t__p2));\
	})

#define cpGrooveJointNew(__p0, __p1, __p2, __p3, __p4) \
	({ \
		cpBody * __t__p0 = __p0;\
		cpBody * __t__p1 = __p1;\
		cpVect  __t__p2 = __p2;\
		cpVect  __t__p3 = __p3;\
		cpVect  __t__p4 = __p4;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpJoint *(*)(cpBody *, cpBody *, cpVect , cpVect , cpVect ))*(void**)(__base - 598))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define cpSpaceHashRehashObject(__p0, __p1, __p2) \
	({ \
		cpSpaceHash * __t__p0 = __p0;\
		void * __t__p1 = __p1;\
		unsigned int  __t__p2 = __p2;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpaceHash *, void *, unsigned int ))*(void**)(__base - 430))(__t__p0, __t__p1, __t__p2));\
	})

#define cpSpaceHashResize(__p0, __p1, __p2) \
	({ \
		cpSpaceHash * __t__p0 = __p0;\
		cpFloat  __t__p1 = __p1;\
		int  __t__p2 = __p2;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpaceHash *, cpFloat , int ))*(void**)(__base - 400))(__t__p0, __t__p1, __t__p2));\
	})

#define cpBodyInit(__p0, __p1, __p2) \
	({ \
		cpBody * __t__p0 = __p0;\
		cpFloat  __t__p1 = __p1;\
		cpFloat  __t__p2 = __p2;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpBody *(*)(cpBody *, cpFloat , cpFloat ))*(void**)(__base - 232))(__t__p0, __t__p1, __t__p2));\
	})

#define cpBBClampVect(__p0, __p1) \
	({ \
		const cpBB  __t__p0 = __p0;\
		const cpVect  __t__p1 = __p1;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpVect (*)(const cpBB , const cpVect ))*(void**)(__base - 214))(__t__p0, __t__p1));\
	})

#define cpSpaceHashInit(__p0, __p1, __p2, __p3) \
	({ \
		cpSpaceHash * __t__p0 = __p0;\
		cpFloat  __t__p1 = __p1;\
		int  __t__p2 = __p2;\
		cpSpaceHashBBFunc  __t__p3 = __p3;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpSpaceHash *(*)(cpSpaceHash *, cpFloat , int , cpSpaceHashBBFunc ))*(void**)(__base - 376))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define cpShapeInit(__p0, __p1, __p2) \
	({ \
		cpShape * __t__p0 = __p0;\
		cpShapeType  __t__p1 = __p1;\
		cpBody * __t__p2 = __p2;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpShape *(*)(cpShape *, cpShapeType , cpBody *))*(void**)(__base - 610))(__t__p0, __t__p1, __t__p2));\
	})

#define cpContactsSumImpulses(__p0, __p1) \
	({ \
		cpContact * __t__p0 = __p0;\
		int  __t__p1 = __p1;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpVect (*)(cpContact *, int ))*(void**)(__base - 454))(__t__p0, __t__p1));\
	})

#define cpBodyUpdatePosition(__p0, __p1) \
	({ \
		cpBody * __t__p0 = __p0;\
		cpFloat  __t__p1 = __p1;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpBody *, cpFloat ))*(void**)(__base - 286))(__t__p0, __t__p1));\
	})

#define cpBodySetMoment(__p0, __p1) \
	({ \
		cpBody * __t__p0 = __p0;\
		cpFloat  __t__p1 = __p1;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpBody *, cpFloat ))*(void**)(__base - 262))(__t__p0, __t__p1));\
	})

#define cpSpaceResizeStaticHash(__p0, __p1, __p2) \
	({ \
		cpSpace * __t__p0 = __p0;\
		cpFloat  __t__p1 = __p1;\
		int  __t__p2 = __p2;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpace *, cpFloat , int ))*(void**)(__base - 154))(__t__p0, __t__p1, __t__p2));\
	})

#define cpArbiterPreStep(__p0, __p1) \
	({ \
		cpArbiter * __t__p0 = __p0;\
		cpFloat  __t__p1 = __p1;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpArbiter *, cpFloat ))*(void**)(__base - 502))(__t__p0, __t__p1));\
	})

#define cpArbiterApplyImpulse(__p0) \
	({ \
		cpArbiter * __t__p0 = __p0;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpArbiter *))*(void**)(__base - 508))(__t__p0));\
	})

#define cpSpaceRehashStatic(__p0) \
	({ \
		cpSpace * __t__p0 = __p0;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpace *))*(void**)(__base - 166))(__t__p0));\
	})

#define cpArrayEach(__p0, __p1, __p2) \
	({ \
		cpArray * __t__p0 = __p0;\
		cpArrayIter  __t__p1 = __p1;\
		void * __t__p2 = __p2;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpArray *, cpArrayIter , void *))*(void**)(__base - 688))(__t__p0, __t__p1, __t__p2));\
	})

#define cpHashSetFree(__p0) \
	({ \
		cpHashSet * __t__p0 = __p0;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpHashSet *))*(void**)(__base - 316))(__t__p0));\
	})

#define cpBodyResetForces(__p0) \
	({ \
		cpBody * __t__p0 = __p0;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpBody *))*(void**)(__base - 292))(__t__p0));\
	})

#define cpArbiterNew(__p0, __p1, __p2) \
	({ \
		cpShape * __t__p0 = __p0;\
		cpShape * __t__p1 = __p1;\
		int  __t__p2 = __p2;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpArbiter *(*)(cpShape *, cpShape *, int ))*(void**)(__base - 478))(__t__p0, __t__p1, __t__p2));\
	})

#define cpArbiterAlloc() \
	({ \
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpArbiter *(*)(void))*(void**)(__base - 466))());\
	})

#define cpSegmentShapeInit(__p0, __p1, __p2, __p3, __p4) \
	({ \
		cpSegmentShape * __t__p0 = __p0;\
		cpBody * __t__p1 = __p1;\
		cpVect  __t__p2 = __p2;\
		cpVect  __t__p3 = __p3;\
		cpFloat  __t__p4 = __p4;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpSegmentShape *(*)(cpSegmentShape *, cpBody *, cpVect , cpVect , cpFloat ))*(void**)(__base - 658))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define cpBodyNew(__p0, __p1) \
	({ \
		cpFloat  __t__p0 = __p0;\
		cpFloat  __t__p1 = __p1;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpBody *(*)(cpFloat , cpFloat ))*(void**)(__base - 238))(__t__p0, __t__p1));\
	})

#define cpHashSetNew(__p0, __p1, __p2) \
	({ \
		int  __t__p0 = __p0;\
		cpHashSetEqlFunc  __t__p1 = __p1;\
		cpHashSetTransFunc  __t__p2 = __p2;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpHashSet *(*)(int , cpHashSetEqlFunc , cpHashSetTransFunc ))*(void**)(__base - 334))(__t__p0, __t__p1, __t__p2));\
	})

#define cpSpaceHashAlloc() \
	({ \
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpSpaceHash *(*)(void))*(void**)(__base - 370))());\
	})

#define cpMomentForPoly(__p0, __p1, __p2, __p3) \
	({ \
		cpFloat  __t__p0 = __p0;\
		int  __t__p1 = __p1;\
		cpVect * __t__p2 = __p2;\
		cpVect  __t__p3 = __p3;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpFloat (*)(cpFloat , int , cpVect *, cpVect ))*(void**)(__base - 40))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define cpPolyShapeNew(__p0, __p1, __p2, __p3) \
	({ \
		cpBody * __t__p0 = __p0;\
		int  __t__p1 = __p1;\
		cpVect * __t__p2 = __p2;\
		cpVect  __t__p3 = __p3;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpShape *(*)(cpBody *, int , cpVect *, cpVect ))*(void**)(__base - 682))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define cpContactInit(__p0, __p1, __p2, __p3, __p4) \
	({ \
		cpContact * __t__p0 = __p0;\
		cpVect  __t__p1 = __p1;\
		cpVect  __t__p2 = __p2;\
		cpFloat  __t__p3 = __p3;\
		unsigned int  __t__p4 = __p4;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpContact *(*)(cpContact *, cpVect , cpVect , cpFloat , unsigned int ))*(void**)(__base - 448))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4));\
	})

#define cpPolyShapeAlloc() \
	({ \
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpPolyShape *(*)(void))*(void**)(__base - 670))());\
	})

#define cpBodyUpdateVelocity(__p0, __p1, __p2, __p3) \
	({ \
		cpBody * __t__p0 = __p0;\
		cpVect  __t__p1 = __p1;\
		cpFloat  __t__p2 = __p2;\
		cpFloat  __t__p3 = __p3;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpBody *, cpVect , cpFloat , cpFloat ))*(void**)(__base - 280))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define cpCollideShapes(__p0, __p1, __p2) \
	({ \
		cpShape * __t__p0 = __p0;\
		cpShape * __t__p1 = __p1;\
		cpContact ** __t__p2 = __p2;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((int (*)(cpShape *, cpShape *, cpContact **))*(void**)(__base - 514))(__t__p0, __t__p1, __t__p2));\
	})

#define cpHashSetEach(__p0, __p1, __p2) \
	({ \
		cpHashSet * __t__p0 = __p0;\
		cpHashSetIterFunc  __t__p1 = __p1;\
		void * __t__p2 = __p2;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpHashSet *, cpHashSetIterFunc , void *))*(void**)(__base - 358))(__t__p0, __t__p1, __t__p2));\
	})

#define cpHashSetInsert(__p0, __p1, __p2, __p3) \
	({ \
		cpHashSet * __t__p0 = __p0;\
		unsigned int  __t__p1 = __p1;\
		void * __t__p2 = __p2;\
		void * __t__p3 = __p3;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void *(*)(cpHashSet *, unsigned int , void *, void *))*(void**)(__base - 340))(__t__p0, __t__p1, __t__p2, __t__p3));\
	})

#define cpArbiterInject(__p0, __p1, __p2) \
	({ \
		cpArbiter * __t__p0 = __p0;\
		cpContact * __t__p1 = __p1;\
		int  __t__p2 = __p2;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpArbiter *, cpContact *, int ))*(void**)(__base - 496))(__t__p0, __t__p1, __t__p2));\
	})

#define cpSpaceRemoveBody(__p0, __p1) \
	({ \
		cpSpace * __t__p0 = __p0;\
		cpBody * __t__p1 = __p1;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpace *, cpBody *))*(void**)(__base - 136))(__t__p0, __t__p1));\
	})

#define cpSpaceStep(__p0, __p1) \
	({ \
		cpSpace * __t__p0 = __p0;\
		cpFloat  __t__p1 = __p1;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpSpace *, cpFloat ))*(void**)(__base - 172))(__t__p0, __t__p1));\
	})

#define cpShapeCacheBB(__p0) \
	({ \
		cpShape * __t__p0 = __p0;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpBB (*)(cpShape *))*(void**)(__base - 628))(__t__p0));\
	})

#define cpSlideJointInit(__p0, __p1, __p2, __p3, __p4, __p5, __p6) \
	({ \
		cpSlideJoint * __t__p0 = __p0;\
		cpBody * __t__p1 = __p1;\
		cpBody * __t__p2 = __p2;\
		cpVect  __t__p3 = __p3;\
		cpVect  __t__p4 = __p4;\
		cpFloat  __t__p5 = __p5;\
		cpFloat  __t__p6 = __p6;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((cpSlideJoint *(*)(cpSlideJoint *, cpBody *, cpBody *, cpVect , cpVect , cpFloat , cpFloat ))*(void**)(__base - 556))(__t__p0, __t__p1, __t__p2, __t__p3, __t__p4, __t__p5, __t__p6));\
	})

#define cpArbiterFree(__p0) \
	({ \
		cpArbiter * __t__p0 = __p0;\
		long __base = (long)(CHIPMUNK_BASE_NAME);\
		__asm volatile("mr 12,%0": :"r"(__base):"r12");\
		(((void (*)(cpArbiter *))*(void**)(__base - 490))(__t__p0));\
	})

#endif /* !_PPCINLINE_CHIPMUNK_H */
