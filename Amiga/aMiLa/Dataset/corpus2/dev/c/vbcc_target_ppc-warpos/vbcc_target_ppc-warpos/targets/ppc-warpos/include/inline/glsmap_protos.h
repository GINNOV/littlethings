 SphereMap  __smapCreateSphereMap(SphereMap *shareSmap) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-34(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapCreateSphereMap(x1) __smapCreateSphereMap((x1))

 void __smapDestroySphereMap(SphereMap *smap) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-40(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapDestroySphereMap(x1) __smapDestroySphereMap((x1))

 void __smapConfigureSphereMapMesh(SphereMap *smap, int steps, int rings, int edgeExtend) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-46(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapConfigureSphereMapMesh(x1,x2,x3,x4) __smapConfigureSphereMapMesh((x1),(x2),(x3),(x4))

 void __smapSetSphereMapTexObj(SphereMap *smap, GLuint texobj) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-52(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapSetSphereMapTexObj(x1,x2) __smapSetSphereMapTexObj((x1),(x2))

 void __smapSetViewTexObj(SphereMap *smap, GLuint texobj) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-58(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapSetViewTexObj(x1,x2) __smapSetViewTexObj((x1),(x2))

 void __smapSetViewTexObjs(SphereMap *smap, GLuint texobjs[6]) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-64(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapSetViewTexObjs(x1,x2) __smapSetViewTexObjs((x1),(x2))

 void __smapGetSphereMapTexObj(SphereMap *smap, GLuint *texobj) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-70(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapGetSphereMapTexObj(x1,x2) __smapGetSphereMapTexObj((x1),(x2))

 void __smapGetViewTexObj(SphereMap *smap, GLuint *texobj) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-76(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapGetViewTexObj(x1,x2) __smapGetViewTexObj((x1),(x2))

 void __smapGetViewTexObjs(SphereMap *smap, GLuint texobjs[6]) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-82(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapGetViewTexObjs(x1,x2) __smapGetViewTexObjs((x1),(x2))

 void __smapSetFlags(SphereMap *smap, SphereMapFlags flags) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-88(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapSetFlags(x1,x2) __smapSetFlags((x1),(x2))

 void __smapGetFlags(SphereMap *smap, SphereMapFlags *flags) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-94(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapGetFlags(x1,x2) __smapGetFlags((x1),(x2))

 void __smapSetViewOrigin(SphereMap *smap, GLint x, GLint y) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-100(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapSetViewOrigin(x1,x2,x3) __smapSetViewOrigin((x1),(x2),(x3))

 void __smapSetSphereMapOrigin(SphereMap *smap, GLint x, GLint y) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-106(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapSetSphereMapOrigin(x1,x2,x3) __smapSetSphereMapOrigin((x1),(x2),(x3))

 void __smapGetViewOrigin(SphereMap *smap, GLint *x, GLint *y) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-112(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapGetViewOrigin(x1,x2,x3) __smapGetViewOrigin((x1),(x2),(x3))

 void __smapGetSphereMapOrigin(SphereMap *smap, GLint *x, GLint *y) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-118(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapGetSphereMapOrigin(x1,x2,x3) __smapGetSphereMapOrigin((x1),(x2),(x3))

 void __smapSetEye(SphereMap *smap, GLfloat eyex, GLfloat eyey,     GLfloat eyez) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-124(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapSetEye(x1,x2,x3,x4) __smapSetEye((x1),(x2),(x3),(x4))

 void __smapSetEyeVector(SphereMap *smap, GLfloat *eye) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-130(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapSetEyeVector(x1,x2) __smapSetEyeVector((x1),(x2))

 void __smapSetUp(SphereMap *smap, GLfloat upx, GLfloat upy, GLfloat upz) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-136(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapSetUp(x1,x2,x3,x4) __smapSetUp((x1),(x2),(x3),(x4))

 void __smapSetUpVector(SphereMap *smap, GLfloat *up) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-142(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapSetUpVector(x1,x2) __smapSetUpVector((x1),(x2))

 void __smapSetObject(SphereMap *smap, GLfloat objx, GLfloat objy, GLfloat objz) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-148(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapSetObject(x1,x2,x3,x4) __smapSetObject((x1),(x2),(x3),(x4))

 void __smapSetObjectVector(SphereMap *smap, GLfloat *obj) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-154(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapSetObjectVector(x1,x2) __smapSetObjectVector((x1),(x2))

 void __smapGetEye(SphereMap *smap, GLfloat *eyex, GLfloat *eyey, GLfloat *eyez) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-160(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapGetEye(x1,x2,x3,x4) __smapGetEye((x1),(x2),(x3),(x4))

 void __smapGetEyeVector(SphereMap *smap, GLfloat *eye) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-166(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapGetEyeVector(x1,x2) __smapGetEyeVector((x1),(x2))

 void __smapGetUp(SphereMap *smap, GLfloat *upx, GLfloat *upy, GLfloat *upz) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-172(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapGetUp(x1,x2,x3,x4) __smapGetUp((x1),(x2),(x3),(x4))

 void __smapGetUpVector(SphereMap *smap, GLfloat *up) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-178(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapGetUpVector(x1,x2) __smapGetUpVector((x1),(x2))

 void __smapGetObject(SphereMap *smap, GLfloat *objx, GLfloat *objy, GLfloat *objz) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-184(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapGetObject(x1,x2,x3,x4) __smapGetObject((x1),(x2),(x3),(x4))

 void __smapGetObjectVector(SphereMap *smap, GLfloat *obj) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-190(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapGetObjectVector(x1,x2) __smapGetObjectVector((x1),(x2))

 void __smapSetNearFar(SphereMap *smap, GLfloat viewNear, GLfloat viewFar) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-196(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapSetNearFar(x1,x2,x3) __smapSetNearFar((x1),(x2),(x3))

 void __smapGetNearFar(SphereMap *smap, GLfloat *viewNear, GLfloat *viewFar) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-202(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapGetNearFar(x1,x2,x3) __smapGetNearFar((x1),(x2),(x3))

 void __smapSetSphereMapTexDim(SphereMap *smap, GLsizei texdim) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-208(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapSetSphereMapTexDim(x1,x2) __smapSetSphereMapTexDim((x1),(x2))

 void __smapSetViewTexDim(SphereMap *smap, GLsizei texdim) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-214(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapSetViewTexDim(x1,x2) __smapSetViewTexDim((x1),(x2))

 void __smapGetSphereMapTexDim(SphereMap *smap, GLsizei *texdim) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-220(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapGetSphereMapTexDim(x1,x2) __smapGetSphereMapTexDim((x1),(x2))

 void __smapGetViewTexDim(SphereMap *smap, GLsizei *texdim) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-226(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapGetViewTexDim(x1,x2) __smapGetViewTexDim((x1),(x2))

 void __smapSetContextData(SphereMap *smap, void *context) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-232(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapSetContextData(x1,x2) __smapSetContextData((x1),(x2))

 void __smapGetContextData(SphereMap *smap, void **context) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-238(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapGetContextData(x1,x2) __smapGetContextData((x1),(x2))

 void __smapSetPositionLightsFunc(SphereMap *smap, void (*positionLights)(int view, void *context)) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-244(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapSetPositionLightsFunc(x1,x2) __smapSetPositionLightsFunc((x1),(x2))

 void __smapSetDrawViewFunc(SphereMap *smap, void (*drawView)(int view, void *context)) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-250(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapSetDrawViewFunc(x1,x2) __smapSetDrawViewFunc((x1),(x2))

 void __smapGetPositionLightsFunc(SphereMap *smap, void (**positionLights)(int view, void *context)) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-256(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapGetPositionLightsFunc(x1,x2) __smapGetPositionLightsFunc((x1),(x2))

 void __smapGetDrawViewFunc(SphereMap *smap, void (**drawView)(int view, void *context)) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-262(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapGetDrawViewFunc(x1,x2) __smapGetDrawViewFunc((x1),(x2))

 void __smapGenViewTex(SphereMap *smap, int view) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-268(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapGenViewTex(x1,x2) __smapGenViewTex((x1),(x2))

 void __smapGenViewTexs(SphereMap *smap) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-274(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapGenViewTexs(x1) __smapGenViewTexs((x1))

 void __smapGenSphereMapFromViewTexs(SphereMap *smap) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-280(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapGenSphereMapFromViewTexs(x1) __smapGenSphereMapFromViewTexs((x1))

 void __smapGenSphereMap(SphereMap *smap) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-286(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapGenSphereMap(x1) __smapGenSphereMap((x1))

 void __smapGenSphereMapWithOneViewTex(SphereMap *smap) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-292(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapGenSphereMapWithOneViewTex(x1) __smapGenSphereMapWithOneViewTex((x1))

 int __smapRvecToSt(float rvec[3], float st[2]) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-298(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapRvecToSt(x1,x2) __smapRvecToSt((x1),(x2))

 void __smapStToRvec(float *st, float *rvec) = "\tstw\tr2,20(r1)\n\t.extern\t_glsmapppcBase\n\tlwz\tr2,_glsmapppcBase(r2)\n\tlwz\tr0,-304(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define smapStToRvec(x1,x2) __smapStToRvec((x1),(x2))

