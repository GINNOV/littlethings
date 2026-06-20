#ifndef CLIB_CHIPMUNK_PROTOS_H
#define CLIB_CHIPMUNK_PROTOS_H

void cpInitChipmunk(void);
cpFloat cpMomentForCircle(cpFloat m, cpFloat r1, cpFloat r2, cpVect offset);
cpFloat cpMomentForPoly(cpFloat m, int numVerts, cpVect *verts, cpVect offset);
cpFloat cpvlength(const cpVect v);
cpFloat cpvlengthsq(const cpVect v); // no sqrt() call
cpVect cpvnormalize(const cpVect v);
cpVect cpvforangle(const cpFloat a); // convert radians to a normalized vector
cpFloat cpvtoangle(const cpVect v); // convert a vector to radians
char *cpvstr(const cpVect v); // get a string representation of a vector
cpVect cpBBClampVect(const cpBB bb, const cpVect v); // clamps the vector to lie within the bbox
cpVect cpBBWrapVect(const cpBB bb, const cpVect v); // wrap a vector to a bbox
cpBody *cpBodyAlloc(void);
cpBody *cpBodyInit(cpBody *body, cpFloat m, cpFloat i);
cpBody *cpBodyNew(cpFloat m, cpFloat i);

void cpBodyDestroy(cpBody *body);
void cpBodyFree(cpBody *body);

// Setters for some of the special properties (mandatory!)
void cpBodySetMass(cpBody *body, cpFloat m);
void cpBodySetMoment(cpBody *body, cpFloat i);
void cpBodySetAngle(cpBody *body, cpFloat a);

// Modify the velocity of an object so that it will 
void cpBodySlew(cpBody *body, cpVect pos, cpFloat dt);

// Integration functions.
void cpBodyUpdateVelocity(cpBody *body, cpVect gravity, cpFloat damping, cpFloat dt);
void cpBodyUpdatePosition(cpBody *body, cpFloat dt);
void cpBodyResetForces(cpBody *body);
// Apply a force (in world coordinates) to a body.
void cpBodyApplyForce(cpBody *body, cpVect f, cpVect r);

// Apply a damped spring force between two bodies.
void cpDampedSpring(cpBody *a, cpBody *b, cpVect anchr1, cpVect anchr2, cpFloat rlen, cpFloat k, cpFloat dmp, cpFloat dt);
void cpHashSetDestroy(cpHashSet *set);
void cpHashSetFree(cpHashSet *set);

cpHashSet *cpHashSetAlloc(void);
cpHashSet *cpHashSetInit(cpHashSet *set, int size, cpHashSetEqlFunc eqlFunc, cpHashSetTransFunc trans);
cpHashSet *cpHashSetNew(int size, cpHashSetEqlFunc eqlFunc, cpHashSetTransFunc trans);

// Insert an element into the set, returns the element.
// If it doesn't already exist, the transformation function is applied.
void *cpHashSetInsert(cpHashSet *set, unsigned int hash, void *ptr, void *data);
// Remove and return an element from the set.
void *cpHashSetRemove(cpHashSet *set, unsigned int hash, void *ptr);
// Find an element in the set. Returns the default value if the element isn't found.
void *cpHashSetFind(cpHashSet *set, unsigned int hash, void *ptr);

// Iterate over a hashset.
void cpHashSetEach(cpHashSet *set, cpHashSetIterFunc func, void *data);
// Iterate over a hashset while rejecting certain elements.
void cpHashSetReject(cpHashSet *set, cpHashSetRejectFunc func, void *data);
cpSpaceHash *cpSpaceHashAlloc(void);
cpSpaceHash *cpSpaceHashInit(cpSpaceHash *hash, cpFloat celldim, int cells, cpSpaceHashBBFunc bbfunc);
cpSpaceHash *cpSpaceHashNew(cpFloat celldim, int cells, cpSpaceHashBBFunc bbfunc);

void cpSpaceHashDestroy(cpSpaceHash *hash);
void cpSpaceHashFree(cpSpaceHash *hash);

// Resize the hashtable. (Does not rehash! You must call cpSpaceHashRehash() if needed.)
void cpSpaceHashResize(cpSpaceHash *hash, cpFloat celldim, int numcells);

// Add an object to the hash.
void cpSpaceHashInsert(cpSpaceHash *hash, void *obj, unsigned int id, cpBB bb);
// Remove an object from the hash.
void cpSpaceHashRemove(cpSpaceHash *hash, void *obj, unsigned int id);

void cpSpaceHashEach(cpSpaceHash *hash, cpSpaceHashIterator func, void *data);

// Rehash the contents of the hash.
void cpSpaceHashRehash(cpSpaceHash *hash);
// Rehash only a specific object.
void cpSpaceHashRehashObject(cpSpaceHash *hash, void *obj, unsigned int id);

void cpSpaceHashQuery(cpSpaceHash *hash, void *obj, cpBB bb, cpSpaceHashQueryFunc func, void *data);
// Rehashes while querying for each object. (Optimized case) 
void cpSpaceHashQueryRehash(cpSpaceHash *hash, cpSpaceHashQueryFunc func, void *data);
void cpResetShapeIdCounter(void);
cpShape* cpShapeInit(cpShape *shape, cpShapeType type, cpBody *body);

// Basic destructor functions. (allocation functions are not shared)
void cpShapeDestroy(cpShape *shape);
void cpShapeFree(cpShape *shape);
cpBB cpShapeCacheBB(cpShape *shape);
cpCircleShape *cpCircleShapeAlloc(void);
cpCircleShape *cpCircleShapeInit(cpCircleShape *circle, cpBody *body, cpFloat radius, cpVect offset);
cpShape *cpCircleShapeNew(cpBody *body, cpFloat radius, cpVect offset);
cpSegmentShape* cpSegmentShapeAlloc(void);
cpSegmentShape* cpSegmentShapeInit(cpSegmentShape *seg, cpBody *body, cpVect a, cpVect b, cpFloat r);
cpShape* cpSegmentShapeNew(cpBody *body, cpVect a, cpVect b, cpFloat r);
cpPolyShape *cpPolyShapeAlloc(void);
cpPolyShape *cpPolyShapeInit(cpPolyShape *poly, cpBody *body, int numVerts, cpVect *verts, cpVect offset);
cpShape *cpPolyShapeNew(cpBody *body, int numVerts, cpVect *verts, cpVect offset);
cpContact* cpContactInit(cpContact *con, cpVect p, cpVect n, cpFloat dist, unsigned int hash);

// Sum the contact impulses. (Can be used after cpSpaceStep() returns)
cpVect cpContactsSumImpulses(cpContact *contacts, int numContacts);
cpVect cpContactsSumImpulsesWithFriction(cpContact *contacts, int numContacts);
cpArbiter* cpArbiterAlloc(void);
cpArbiter* cpArbiterInit(cpArbiter *arb, cpShape *a, cpShape *b, int stamp);
cpArbiter* cpArbiterNew(cpShape *a, cpShape *b, int stamp);

void cpArbiterDestroy(cpArbiter *arb);
void cpArbiterFree(cpArbiter *arb);

// These functions are all intended to be used internally.
// Inject new contact points into the arbiter while preserving contact history.
void cpArbiterInject(cpArbiter *arb, cpContact *contacts, int numContacts);
// Precalculate values used by the solver.
void cpArbiterPreStep(cpArbiter *arb, cpFloat dt_inv);
// Run an iteration of the solver on the arbiter.
void cpArbiterApplyImpulse(cpArbiter *arb);
int cpCollideShapes(cpShape *a, cpShape *b, cpContact **arr);
void cpJointDestroy(cpJoint *joint);
void cpJointFree(cpJoint *joint);
cpPinJoint *cpPinJointAlloc(void);
cpPinJoint *cpPinJointInit(cpPinJoint *joint, cpBody *a, cpBody *b, cpVect anchr1, cpVect anchr2);
cpJoint *cpPinJointNew(cpBody *a, cpBody *b, cpVect anchr1, cpVect anchr2);
cpSlideJoint *cpSlideJointAlloc(void);
cpSlideJoint *cpSlideJointInit(cpSlideJoint *joint, cpBody *a, cpBody *b, cpVect anchr1, cpVect anchr2, cpFloat min, cpFloat max);
cpJoint *cpSlideJointNew(cpBody *a, cpBody *b, cpVect anchr1, cpVect anchr2, cpFloat min, cpFloat max);
cpPivotJoint *cpPivotJointAlloc(void);
cpPivotJoint *cpPivotJointInit(cpPivotJoint *joint, cpBody *a, cpBody *b, cpVect pivot);
cpJoint *cpPivotJointNew(cpBody *a, cpBody *b, cpVect pivot);
cpGrooveJoint *cpGrooveJointAlloc(void);
cpGrooveJoint *cpGrooveJointInit(cpGrooveJoint *joint, cpBody *a, cpBody *b, cpVect groove_a, cpVect groove_b, cpVect anchr2);
cpJoint *cpGrooveJointNew(cpBody *a, cpBody *b, cpVect groove_a, cpVect groove_b, cpVect anchr2);
cpSpace* cpSpaceAlloc(void);
cpSpace* cpSpaceInit(cpSpace *space);
cpSpace* cpSpaceNew(void);
void cpSpaceDestroy(cpSpace *space);
void cpSpaceFree(cpSpace *space);
void cpSpaceFreeChildren(cpSpace *space);
void cpSpaceAddCollisionPairFunc(cpSpace *space, unsigned int a, unsigned int b, cpCollFunc func, void *data);
void cpSpaceRemoveCollisionPairFunc(cpSpace *space, unsigned int a, unsigned int b);
void cpSpaceSetDefaultCollisionPairFunc(cpSpace *space, cpCollFunc func, void *data);

// Add and remove entities from the system.
void cpSpaceAddShape(cpSpace *space, cpShape *shape);
void cpSpaceAddStaticShape(cpSpace *space, cpShape *shape);
void cpSpaceAddBody(cpSpace *space, cpBody *body);
void cpSpaceAddJoint(cpSpace *space, cpJoint *joint);

void cpSpaceRemoveShape(cpSpace *space, cpShape *shape);
void cpSpaceRemoveStaticShape(cpSpace *space, cpShape *shape);
void cpSpaceRemoveBody(cpSpace *space, cpBody *body);
void cpSpaceRemoveJoint(cpSpace *space, cpJoint *joint);

// Iterator function for iterating the bodies in a space.
void cpSpaceEachBody(cpSpace *space, cpSpaceBodyIterator func, void *data);

// Spatial hash management functions.
void cpSpaceResizeStaticHash(cpSpace *space, cpFloat dim, int count);
void cpSpaceResizeActiveHash(cpSpace *space, cpFloat dim, int count);
void cpSpaceRehashStatic(cpSpace *space);

// Update the space.
void cpSpaceStep(cpSpace *space, cpFloat dt);

void cpArrayEach(cpArray *arr, cpArrayIter iterFunc, void *data);

#endif /* CLIB_CHIPMUNK_PROTOS_H */
