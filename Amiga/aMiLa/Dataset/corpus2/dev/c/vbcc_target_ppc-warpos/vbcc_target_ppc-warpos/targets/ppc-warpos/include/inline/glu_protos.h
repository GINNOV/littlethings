 void __gluLookAt( GLdouble eyex, GLdouble eyey, GLdouble eyez,
                                GLdouble centerx, GLdouble centery,
                                GLdouble centerz,
                                GLdouble upx, GLdouble upy, GLdouble upz ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-34(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluLookAt(x1,x2,x3,x4,x5,x6,x7,x8,x9) __gluLookAt((x1),(x2),(x3),(x4),(x5),(x6),(x7),(x8),(x9))

 void __gluOrtho2D( GLdouble left, GLdouble right,
                                 GLdouble bottom, GLdouble top ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-40(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluOrtho2D(x1,x2,x3,x4) __gluOrtho2D((x1),(x2),(x3),(x4))

 void __gluPerspective( GLdouble fovy, GLdouble aspect,
                                     GLdouble zNear, GLdouble zFar ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-46(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluPerspective(x1,x2,x3,x4) __gluPerspective((x1),(x2),(x3),(x4))

 void __gluPickMatrix( GLdouble x, GLdouble y,
                                    GLdouble width, GLdouble height,
                                    const GLint viewport[4] ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-52(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluPickMatrix(x1,x2,x3,x4,x5) __gluPickMatrix((x1),(x2),(x3),(x4),(x5))

 GLint __gluProject( GLdouble objx, GLdouble objy, GLdouble objz,
                                  const GLdouble modelMatrix[16],
                                  const GLdouble projMatrix[16],
                                  const GLint viewport[4],
                                  GLdouble *winx, GLdouble *winy,
                                  GLdouble *winz ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-58(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluProject(x1,x2,x3,x4,x5,x6,x7,x8,x9) __gluProject((x1),(x2),(x3),(x4),(x5),(x6),(x7),(x8),(x9))

 GLint __gluUnProject( GLdouble winx, GLdouble winy,
                                    GLdouble winz,
                                    const GLdouble modelMatrix[16],
                                    const GLdouble projMatrix[16],
                                    const GLint viewport[4],
                                    GLdouble *objx, GLdouble *objy,
                                    GLdouble *objz ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-64(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluUnProject(x1,x2,x3,x4,x5,x6,x7,x8,x9) __gluUnProject((x1),(x2),(x3),(x4),(x5),(x6),(x7),(x8),(x9))

 const GLubyte* __gluErrorString( GLenum errorCode ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-70(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluErrorString(x1) __gluErrorString((x1))

 GLint __gluScaleImage( GLenum format,
                                     GLint widthin, GLint heightin,
                                     GLenum typein, const void *datain,
                                     GLint widthout, GLint heightout,
                                     GLenum typeout, void *dataout ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-76(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluScaleImage(x1,x2,x3,x4,x5,x6,x7,x8,x9) __gluScaleImage((x1),(x2),(x3),(x4),(x5),(x6),(x7),(x8),(x9))

 GLint __gluBuild1DMipmaps( GLenum target, GLint components,
                                         GLint width, GLenum format,
                                         GLenum type, const void *data ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-82(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluBuild1DMipmaps(x1,x2,x3,x4,x5,x6) __gluBuild1DMipmaps((x1),(x2),(x3),(x4),(x5),(x6))

 GLint __gluBuild2DMipmaps( GLenum target, GLint components,
                                         GLint width, GLint height,
                                         GLenum format,
                                         GLenum type, const void *data ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-88(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluBuild2DMipmaps(x1,x2,x3,x4,x5,x6,x7) __gluBuild2DMipmaps((x1),(x2),(x3),(x4),(x5),(x6),(x7))

 GLUquadricObj* __gluNewQuadric( void ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-94(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluNewQuadric() __gluNewQuadric()

 void __gluDeleteQuadric( GLUquadricObj *state ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-100(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluDeleteQuadric(x1) __gluDeleteQuadric((x1))

 void __gluQuadricDrawStyle( GLUquadricObj *quadObject,
                                          GLenum drawStyle ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-106(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluQuadricDrawStyle(x1,x2) __gluQuadricDrawStyle((x1),(x2))

 void __gluQuadricOrientation( GLUquadricObj *quadObject,
                                            GLenum orientation ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-112(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluQuadricOrientation(x1,x2) __gluQuadricOrientation((x1),(x2))

 void __gluQuadricNormals( GLUquadricObj *quadObject,
                                        GLenum normals ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-118(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluQuadricNormals(x1,x2) __gluQuadricNormals((x1),(x2))

 void __gluQuadricTexture( GLUquadricObj *quadObject,
                                        GLboolean textureCoords ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-124(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluQuadricTexture(x1,x2) __gluQuadricTexture((x1),(x2))

 void __gluQuadricCallback( GLUquadricObj *qobj,
                                         GLenum which, void ( *fn)() ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-130(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluQuadricCallback(x1,x2,x3) __gluQuadricCallback((x1),(x2),(x3))

 void __gluCylinder( GLUquadricObj *qobj,
                                  GLdouble baseRadius,
                                  GLdouble topRadius,
                                  GLdouble height,
                                  GLint slices, GLint stacks ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-136(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluCylinder(x1,x2,x3,x4,x5,x6) __gluCylinder((x1),(x2),(x3),(x4),(x5),(x6))

 void __gluSphere( GLUquadricObj *qobj,
                                GLdouble radius, GLint slices, GLint stacks ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-142(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluSphere(x1,x2,x3,x4) __gluSphere((x1),(x2),(x3),(x4))

 void __gluDisk( GLUquadricObj *qobj,
                              GLdouble innerRadius, GLdouble outerRadius,
                              GLint slices, GLint loops ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-148(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluDisk(x1,x2,x3,x4,x5) __gluDisk((x1),(x2),(x3),(x4),(x5))

 void __gluPartialDisk( GLUquadricObj *qobj, GLdouble innerRadius,
                                     GLdouble outerRadius, GLint slices,
                                     GLint loops, GLdouble startAngle,
                                     GLdouble sweepAngle ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-154(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluPartialDisk(x1,x2,x3,x4,x5,x6,x7) __gluPartialDisk((x1),(x2),(x3),(x4),(x5),(x6),(x7))

 GLUnurbsObj* __gluNewNurbsRenderer( void ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-160(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluNewNurbsRenderer() __gluNewNurbsRenderer()

 void __gluDeleteNurbsRenderer( GLUnurbsObj *nobj ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-166(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluDeleteNurbsRenderer(x1) __gluDeleteNurbsRenderer((x1))

 void __gluLoadSamplingMatrices( GLUnurbsObj *nobj,
                                              const GLfloat modelMatrix[16],
                                              const GLfloat projMatrix[16],
                                              const GLint viewport[4] ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-172(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluLoadSamplingMatrices(x1,x2,x3,x4) __gluLoadSamplingMatrices((x1),(x2),(x3),(x4))

 void __gluNurbsProperty( GLUnurbsObj *nobj, GLenum property,
                                       GLfloat value ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-178(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluNurbsProperty(x1,x2,x3) __gluNurbsProperty((x1),(x2),(x3))

 void __gluGetNurbsProperty( GLUnurbsObj *nobj, GLenum property,
                                          GLfloat *value ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-184(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluGetNurbsProperty(x1,x2,x3) __gluGetNurbsProperty((x1),(x2),(x3))

 void __gluBeginCurve( GLUnurbsObj *nobj ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-190(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluBeginCurve(x1) __gluBeginCurve((x1))

 void __gluEndCurve( GLUnurbsObj * nobj ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-196(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluEndCurve(x1) __gluEndCurve((x1))

 void __gluNurbsCurve( GLUnurbsObj *nobj, GLint nknots,
                                    GLfloat *knot, GLint stride,
                                    GLfloat *ctlarray, GLint order,
                                    GLenum type ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-202(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluNurbsCurve(x1,x2,x3,x4,x5,x6,x7) __gluNurbsCurve((x1),(x2),(x3),(x4),(x5),(x6),(x7))

 void __gluBeginSurface( GLUnurbsObj *nobj ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-208(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluBeginSurface(x1) __gluBeginSurface((x1))

 void __gluEndSurface( GLUnurbsObj * nobj ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-214(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluEndSurface(x1) __gluEndSurface((x1))

 void __gluNurbsSurface( GLUnurbsObj *nobj,
                                      GLint sknot_count, GLfloat *sknot,
                                      GLint tknot_count, GLfloat *tknot,
                                      GLint s_stride, GLint t_stride,
                                      GLfloat *ctlarray,
                                      GLint sorder, GLint torder,
                                      GLenum type ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-220(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluNurbsSurface(x1,x2,x3,x4,x5,x6,x7,x8,x9,xa,xb) __gluNurbsSurface((x1),(x2),(x3),(x4),(x5),(x6),(x7),(x8),(x9),(xa),(xb))

 void __gluBeginTrim( GLUnurbsObj *nobj ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-226(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluBeginTrim(x1) __gluBeginTrim((x1))

 void __gluEndTrim( GLUnurbsObj *nobj ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-232(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluEndTrim(x1) __gluEndTrim((x1))

 void __gluPwlCurve( GLUnurbsObj *nobj, GLint count,
                                  GLfloat *array, GLint stride, GLenum type ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-238(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluPwlCurve(x1,x2,x3,x4,x5) __gluPwlCurve((x1),(x2),(x3),(x4),(x5))

 void __gluNurbsCallback( GLUnurbsObj *nobj, GLenum which,
                                       void ( *fn)() ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-244(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluNurbsCallback(x1,x2,x3) __gluNurbsCallback((x1),(x2),(x3))

 GLUtriangulatorObj* __gluNewTess( void ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-250(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluNewTess() __gluNewTess()

 void __gluTessCallback( GLUtriangulatorObj *tobj, GLenum which,
                                      void ( *fn)() ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-256(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluTessCallback(x1,x2,x3) __gluTessCallback((x1),(x2),(x3))

 void __gluDeleteTess( GLUtriangulatorObj *tobj ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-262(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluDeleteTess(x1) __gluDeleteTess((x1))

 void __gluBeginPolygon( GLUtriangulatorObj *tobj ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-268(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluBeginPolygon(x1) __gluBeginPolygon((x1))

 void __gluEndPolygon( GLUtriangulatorObj *tobj ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-274(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluEndPolygon(x1) __gluEndPolygon((x1))

 void __gluNextContour( GLUtriangulatorObj *tobj, GLenum type ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-280(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluNextContour(x1,x2) __gluNextContour((x1),(x2))

 void __gluTessVertex( GLUtriangulatorObj *tobj, GLdouble v[3],
                                    void *data ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-286(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluTessVertex(x1,x2,x3) __gluTessVertex((x1),(x2),(x3))

 const GLubyte* __gluGetString( GLenum name ) = "\tstw\tr2,20(r1)\n\t.extern\t_gluppcBase\n\tlwz\tr2,_gluppcBase(r2)\n\tlwz\tr0,-292(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gluGetString(x1) __gluGetString((x1))

