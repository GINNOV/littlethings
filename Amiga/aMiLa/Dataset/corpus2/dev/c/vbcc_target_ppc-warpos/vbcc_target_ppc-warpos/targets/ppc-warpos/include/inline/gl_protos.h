 void __glClearIndex( GLfloat c ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-178(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glClearIndex(x1) __glClearIndex((x1))

 void __glClearColor( GLclampf red,
                          GLclampf green,
                          GLclampf blue,
                          GLclampf alpha ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-184(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glClearColor(x1,x2,x3,x4) __glClearColor((x1),(x2),(x3),(x4))

 void __glClear( GLbitfield mask ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-190(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glClear(x1) __glClear((x1))

 void __glIndexMask( GLuint mask ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-196(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glIndexMask(x1) __glIndexMask((x1))

 void __glColorMask( GLboolean red, GLboolean green,
                         GLboolean blue, GLboolean alpha ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-202(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColorMask(x1,x2,x3,x4) __glColorMask((x1),(x2),(x3),(x4))

 void __glAlphaFunc( GLenum func, GLclampf ref ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-208(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glAlphaFunc(x1,x2) __glAlphaFunc((x1),(x2))

 void __glBlendFunc( GLenum sfactor, GLenum dfactor ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-214(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glBlendFunc(x1,x2) __glBlendFunc((x1),(x2))

 void __glLogicOp( GLenum opcode ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-220(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glLogicOp(x1) __glLogicOp((x1))

 void __glCullFace( GLenum mode ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-226(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glCullFace(x1) __glCullFace((x1))

 void __glFrontFace( GLenum mode ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-232(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glFrontFace(x1) __glFrontFace((x1))

 void __glPointSize( GLfloat size ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-238(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glPointSize(x1) __glPointSize((x1))

 void __glLineWidth( GLfloat width ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-244(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glLineWidth(x1) __glLineWidth((x1))

 void __glLineStipple( GLint factor, GLushort pattern ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-250(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glLineStipple(x1,x2) __glLineStipple((x1),(x2))

 void __glPolygonMode( GLenum face, GLenum mode ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-256(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glPolygonMode(x1,x2) __glPolygonMode((x1),(x2))

 void __glPolygonOffset( GLfloat factor, GLfloat units ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-262(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glPolygonOffset(x1,x2) __glPolygonOffset((x1),(x2))

 void __glPolygonStipple( const GLubyte *mask ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-268(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glPolygonStipple(x1) __glPolygonStipple((x1))

 void __glGetPolygonStipple( GLubyte *mask ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-274(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetPolygonStipple(x1) __glGetPolygonStipple((x1))

 void __glEdgeFlag( GLboolean flag ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-280(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glEdgeFlag(x1) __glEdgeFlag((x1))

 void __glEdgeFlagv( const GLboolean *flag ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-286(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glEdgeFlagv(x1) __glEdgeFlagv((x1))

 void __glScissor( GLint x, GLint y,
                                   GLsizei width, GLsizei height) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-292(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glScissor(x1,x2,x3,x4) __glScissor((x1),(x2),(x3),(x4))

 void __glClipPlane( GLenum plane, const GLdouble *equation ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-298(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glClipPlane(x1,x2) __glClipPlane((x1),(x2))

 void __glGetClipPlane( GLenum plane, GLdouble *equation ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-304(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetClipPlane(x1,x2) __glGetClipPlane((x1),(x2))

 void __glDrawBuffer( GLenum mode ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-310(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glDrawBuffer(x1) __glDrawBuffer((x1))

 void __glReadBuffer( GLenum mode ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-316(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glReadBuffer(x1) __glReadBuffer((x1))

 void __glEnable( GLenum cap ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-322(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glEnable(x1) __glEnable((x1))

 void __glDisable( GLenum cap ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-328(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glDisable(x1) __glDisable((x1))

 GLboolean __glIsEnabled( GLenum cap ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-334(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glIsEnabled(x1) __glIsEnabled((x1))

 void __glEnableClientState( GLenum cap ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-340(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glEnableClientState(x1) __glEnableClientState((x1))

 void __glDisableClientState( GLenum cap ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-346(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glDisableClientState(x1) __glDisableClientState((x1))

 void __glGetBooleanv( GLenum pname, GLboolean *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-352(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetBooleanv(x1,x2) __glGetBooleanv((x1),(x2))

 void __glGetDoublev( GLenum pname, GLdouble *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-358(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetDoublev(x1,x2) __glGetDoublev((x1),(x2))

 void __glGetFloatv( GLenum pname, GLfloat *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-364(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetFloatv(x1,x2) __glGetFloatv((x1),(x2))

 void __glGetIntegerv( GLenum pname, GLint *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-370(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetIntegerv(x1,x2) __glGetIntegerv((x1),(x2))

 void __glPushAttrib( GLbitfield mask ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-376(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glPushAttrib(x1) __glPushAttrib((x1))

 void __glPopAttrib( void ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-382(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glPopAttrib() __glPopAttrib()

 void __glPushClientAttrib( GLbitfield mask ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-388(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glPushClientAttrib(x1) __glPushClientAttrib((x1))

 void __glPopClientAttrib( void ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-394(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glPopClientAttrib() __glPopClientAttrib()

 GLint __glRenderMode( GLenum mode ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-400(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRenderMode(x1) __glRenderMode((x1))

 GLenum __glGetError( void ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-406(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetError() __glGetError()

 const GLubyte* __glGetString( GLenum name ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-412(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetString(x1) __glGetString((x1))

 void __glFinish( void ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-418(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glFinish() __glFinish()

 void __glFlush( void ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-424(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glFlush() __glFlush()

 void __glHint( GLenum target, GLenum mode ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-430(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glHint(x1,x2) __glHint((x1),(x2))

 void __glClearDepth( GLclampd depth ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-436(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glClearDepth(x1) __glClearDepth((x1))

 void __glDepthFunc( GLenum func ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-442(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glDepthFunc(x1) __glDepthFunc((x1))

 void __glDepthMask( GLboolean flag ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-448(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glDepthMask(x1) __glDepthMask((x1))

 void __glDepthRange( GLclampd near_val, GLclampd far_val ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-454(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glDepthRange(x1,x2) __glDepthRange((x1),(x2))

 void __glClearAccum( GLfloat red, GLfloat green,
                                      GLfloat blue, GLfloat alpha ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-460(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glClearAccum(x1,x2,x3,x4) __glClearAccum((x1),(x2),(x3),(x4))

 void __glAccum( GLenum op, GLfloat value ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-466(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glAccum(x1,x2) __glAccum((x1),(x2))

 void __glMatrixMode( GLenum mode ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-472(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMatrixMode(x1) __glMatrixMode((x1))

 void __glOrtho( GLdouble left, GLdouble right,
                                 GLdouble bottom, GLdouble top,
                                 GLdouble near_val, GLdouble far_val ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-478(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glOrtho(x1,x2,x3,x4,x5,x6) __glOrtho((x1),(x2),(x3),(x4),(x5),(x6))

 void __glFrustum( GLdouble left, GLdouble right,
                                   GLdouble bottom, GLdouble top,
                                   GLdouble near_val, GLdouble far_val ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-484(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glFrustum(x1,x2,x3,x4,x5,x6) __glFrustum((x1),(x2),(x3),(x4),(x5),(x6))

 void __glViewport( GLint x, GLint y,
                                    GLsizei width, GLsizei height ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-490(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glViewport(x1,x2,x3,x4) __glViewport((x1),(x2),(x3),(x4))

 void __glPushMatrix( void ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-496(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glPushMatrix() __glPushMatrix()

 void __glPopMatrix( void ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-502(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glPopMatrix() __glPopMatrix()

 void __glLoadIdentity( void ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-508(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glLoadIdentity() __glLoadIdentity()

 void __glLoadMatrixd( const GLdouble *m ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-514(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glLoadMatrixd(x1) __glLoadMatrixd((x1))

 void __glLoadMatrixf( const GLfloat *m ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-520(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glLoadMatrixf(x1) __glLoadMatrixf((x1))

 void __glMultMatrixd( const GLdouble *m ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-526(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultMatrixd(x1) __glMultMatrixd((x1))

 void __glMultMatrixf( const GLfloat *m ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-532(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultMatrixf(x1) __glMultMatrixf((x1))

 void __glRotated( GLdouble angle,
                                   GLdouble x, GLdouble y, GLdouble z ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-538(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRotated(x1,x2,x3,x4) __glRotated((x1),(x2),(x3),(x4))

 void __glRotatef( GLfloat angle,
                                   GLfloat x, GLfloat y, GLfloat z ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-544(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRotatef(x1,x2,x3,x4) __glRotatef((x1),(x2),(x3),(x4))

 void __glScaled( GLdouble x, GLdouble y, GLdouble z ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-550(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glScaled(x1,x2,x3) __glScaled((x1),(x2),(x3))

 void __glScalef( GLfloat x, GLfloat y, GLfloat z ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-556(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glScalef(x1,x2,x3) __glScalef((x1),(x2),(x3))

 void __glTranslated( GLdouble x, GLdouble y, GLdouble z ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-562(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTranslated(x1,x2,x3) __glTranslated((x1),(x2),(x3))

 void __glTranslatef( GLfloat x, GLfloat y, GLfloat z ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-568(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTranslatef(x1,x2,x3) __glTranslatef((x1),(x2),(x3))

 GLboolean __glIsList( GLuint list ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-574(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glIsList(x1) __glIsList((x1))

 void __glDeleteLists( GLuint list, GLsizei range ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-580(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glDeleteLists(x1,x2) __glDeleteLists((x1),(x2))

 GLuint __glGenLists( GLsizei range ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-586(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGenLists(x1) __glGenLists((x1))

 void __glNewList( GLuint list, GLenum mode ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-592(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glNewList(x1,x2) __glNewList((x1),(x2))

 void __glEndList( void ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-598(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glEndList() __glEndList()

 void __glCallList( GLuint list ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-604(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glCallList(x1) __glCallList((x1))

 void __glCallLists( GLsizei n, GLenum type,
                                     const GLvoid *lists ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-610(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glCallLists(x1,x2,x3) __glCallLists((x1),(x2),(x3))

 void __glListBase( GLuint base ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-616(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glListBase(x1) __glListBase((x1))

 void __glBegin( GLenum mode ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-622(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glBegin(x1) __glBegin((x1))

 void __glEnd( void ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-628(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glEnd() __glEnd()

 void __glVertex2d( GLdouble x, GLdouble y ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-634(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glVertex2d(x1,x2) __glVertex2d((x1),(x2))

 void __glVertex2f( GLfloat x, GLfloat y ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-640(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glVertex2f(x1,x2) __glVertex2f((x1),(x2))

 void __glVertex2i( GLint x, GLint y ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-646(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glVertex2i(x1,x2) __glVertex2i((x1),(x2))

 void __glVertex2s( GLshort x, GLshort y ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-652(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glVertex2s(x1,x2) __glVertex2s((x1),(x2))

 void __glVertex3d( GLdouble x, GLdouble y, GLdouble z ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-658(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glVertex3d(x1,x2,x3) __glVertex3d((x1),(x2),(x3))

 void __glVertex3f( GLfloat x, GLfloat y, GLfloat z ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-664(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glVertex3f(x1,x2,x3) __glVertex3f((x1),(x2),(x3))

 void __glVertex3i( GLint x, GLint y, GLint z ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-670(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glVertex3i(x1,x2,x3) __glVertex3i((x1),(x2),(x3))

 void __glVertex3s( GLshort x, GLshort y, GLshort z ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-676(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glVertex3s(x1,x2,x3) __glVertex3s((x1),(x2),(x3))

 void __glVertex4d( GLdouble x, GLdouble y, GLdouble z, GLdouble w ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-682(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glVertex4d(x1,x2,x3,x4) __glVertex4d((x1),(x2),(x3),(x4))

 void __glVertex4f( GLfloat x, GLfloat y, GLfloat z, GLfloat w ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-688(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glVertex4f(x1,x2,x3,x4) __glVertex4f((x1),(x2),(x3),(x4))

 void __glVertex4i( GLint x, GLint y, GLint z, GLint w ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-694(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glVertex4i(x1,x2,x3,x4) __glVertex4i((x1),(x2),(x3),(x4))

 void __glVertex4s( GLshort x, GLshort y, GLshort z, GLshort w ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-700(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glVertex4s(x1,x2,x3,x4) __glVertex4s((x1),(x2),(x3),(x4))

 void __glVertex2dv( const GLdouble *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-706(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glVertex2dv(x1) __glVertex2dv((x1))

 void __glVertex2fv( const GLfloat *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-712(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glVertex2fv(x1) __glVertex2fv((x1))

 void __glVertex2iv( const GLint *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-718(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glVertex2iv(x1) __glVertex2iv((x1))

 void __glVertex2sv( const GLshort *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-724(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glVertex2sv(x1) __glVertex2sv((x1))

 void __glVertex3dv( const GLdouble *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-730(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glVertex3dv(x1) __glVertex3dv((x1))

 void __glVertex3fv( const GLfloat *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-736(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glVertex3fv(x1) __glVertex3fv((x1))

 void __glVertex3iv( const GLint *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-742(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glVertex3iv(x1) __glVertex3iv((x1))

 void __glVertex3sv( const GLshort *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-748(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glVertex3sv(x1) __glVertex3sv((x1))

 void __glVertex4dv( const GLdouble *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-754(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glVertex4dv(x1) __glVertex4dv((x1))

 void __glVertex4fv( const GLfloat *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-760(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glVertex4fv(x1) __glVertex4fv((x1))

 void __glVertex4iv( const GLint *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-766(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glVertex4iv(x1) __glVertex4iv((x1))

 void __glVertex4sv( const GLshort *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-772(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glVertex4sv(x1) __glVertex4sv((x1))

 void __glNormal3b( GLbyte nx, GLbyte ny, GLbyte nz ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-778(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glNormal3b(x1,x2,x3) __glNormal3b((x1),(x2),(x3))

 void __glNormal3d( GLdouble nx, GLdouble ny, GLdouble nz ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-784(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glNormal3d(x1,x2,x3) __glNormal3d((x1),(x2),(x3))

 void __glNormal3f( GLfloat nx, GLfloat ny, GLfloat nz ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-790(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glNormal3f(x1,x2,x3) __glNormal3f((x1),(x2),(x3))

 void __glNormal3i( GLint nx, GLint ny, GLint nz ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-796(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glNormal3i(x1,x2,x3) __glNormal3i((x1),(x2),(x3))

 void __glNormal3s( GLshort nx, GLshort ny, GLshort nz ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-802(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glNormal3s(x1,x2,x3) __glNormal3s((x1),(x2),(x3))

 void __glNormal3bv( const GLbyte *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-808(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glNormal3bv(x1) __glNormal3bv((x1))

 void __glNormal3dv( const GLdouble *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-814(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glNormal3dv(x1) __glNormal3dv((x1))

 void __glNormal3fv( const GLfloat *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-820(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glNormal3fv(x1) __glNormal3fv((x1))

 void __glNormal3iv( const GLint *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-826(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glNormal3iv(x1) __glNormal3iv((x1))

 void __glNormal3sv( const GLshort *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-832(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glNormal3sv(x1) __glNormal3sv((x1))

 void __glIndexd( GLdouble c ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-838(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glIndexd(x1) __glIndexd((x1))

 void __glIndexf( GLfloat c ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-844(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glIndexf(x1) __glIndexf((x1))

 void __glIndexi( GLint c ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-850(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glIndexi(x1) __glIndexi((x1))

 void __glIndexs( GLshort c ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-856(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glIndexs(x1) __glIndexs((x1))

 void __glIndexub( GLubyte c ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-862(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glIndexub(x1) __glIndexub((x1))

 void __glIndexdv( const GLdouble *c ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-868(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glIndexdv(x1) __glIndexdv((x1))

 void __glIndexfv( const GLfloat *c ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-874(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glIndexfv(x1) __glIndexfv((x1))

 void __glIndexiv( const GLint *c ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-880(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glIndexiv(x1) __glIndexiv((x1))

 void __glIndexsv( const GLshort *c ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-886(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glIndexsv(x1) __glIndexsv((x1))

 void __glIndexubv( const GLubyte *c ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-892(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glIndexubv(x1) __glIndexubv((x1))

 void __glColor3b( GLbyte red, GLbyte green, GLbyte blue ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-898(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor3b(x1,x2,x3) __glColor3b((x1),(x2),(x3))

 void __glColor3d( GLdouble red, GLdouble green, GLdouble blue ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-904(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor3d(x1,x2,x3) __glColor3d((x1),(x2),(x3))

 void __glColor3f( GLfloat red, GLfloat green, GLfloat blue ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-910(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor3f(x1,x2,x3) __glColor3f((x1),(x2),(x3))

 void __glColor3i( GLint red, GLint green, GLint blue ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-916(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor3i(x1,x2,x3) __glColor3i((x1),(x2),(x3))

 void __glColor3s( GLshort red, GLshort green, GLshort blue ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-922(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor3s(x1,x2,x3) __glColor3s((x1),(x2),(x3))

 void __glColor3ub( GLubyte red, GLubyte green, GLubyte blue ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-928(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor3ub(x1,x2,x3) __glColor3ub((x1),(x2),(x3))

 void __glColor3ui( GLuint red, GLuint green, GLuint blue ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-934(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor3ui(x1,x2,x3) __glColor3ui((x1),(x2),(x3))

 void __glColor3us( GLushort red, GLushort green, GLushort blue ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-940(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor3us(x1,x2,x3) __glColor3us((x1),(x2),(x3))

 void __glColor4b( GLbyte red, GLbyte green,
                                   GLbyte blue, GLbyte alpha ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-946(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor4b(x1,x2,x3,x4) __glColor4b((x1),(x2),(x3),(x4))

 void __glColor4d( GLdouble red, GLdouble green,
                                   GLdouble blue, GLdouble alpha ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-952(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor4d(x1,x2,x3,x4) __glColor4d((x1),(x2),(x3),(x4))

 void __glColor4f( GLfloat red, GLfloat green,
                                   GLfloat blue, GLfloat alpha ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-958(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor4f(x1,x2,x3,x4) __glColor4f((x1),(x2),(x3),(x4))

 void __glColor4i( GLint red, GLint green,
                                   GLint blue, GLint alpha ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-964(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor4i(x1,x2,x3,x4) __glColor4i((x1),(x2),(x3),(x4))

 void __glColor4s( GLshort red, GLshort green,
                                   GLshort blue, GLshort alpha ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-970(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor4s(x1,x2,x3,x4) __glColor4s((x1),(x2),(x3),(x4))

 void __glColor4ub( GLubyte red, GLubyte green,
                                    GLubyte blue, GLubyte alpha ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-976(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor4ub(x1,x2,x3,x4) __glColor4ub((x1),(x2),(x3),(x4))

 void __glColor4ui( GLuint red, GLuint green,
                                    GLuint blue, GLuint alpha ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-982(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor4ui(x1,x2,x3,x4) __glColor4ui((x1),(x2),(x3),(x4))

 void __glColor4us( GLushort red, GLushort green,
                                    GLushort blue, GLushort alpha ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-988(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor4us(x1,x2,x3,x4) __glColor4us((x1),(x2),(x3),(x4))

 void __glColor3bv( const GLbyte *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-994(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor3bv(x1) __glColor3bv((x1))

 void __glColor3dv( const GLdouble *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1000(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor3dv(x1) __glColor3dv((x1))

 void __glColor3fv( const GLfloat *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1006(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor3fv(x1) __glColor3fv((x1))

 void __glColor3iv( const GLint *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1012(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor3iv(x1) __glColor3iv((x1))

 void __glColor3sv( const GLshort *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1018(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor3sv(x1) __glColor3sv((x1))

 void __glColor3ubv( const GLubyte *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1024(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor3ubv(x1) __glColor3ubv((x1))

 void __glColor3uiv( const GLuint *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1030(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor3uiv(x1) __glColor3uiv((x1))

 void __glColor3usv( const GLushort *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1036(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor3usv(x1) __glColor3usv((x1))

 void __glColor4bv( const GLbyte *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1042(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor4bv(x1) __glColor4bv((x1))

 void __glColor4dv( const GLdouble *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1048(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor4dv(x1) __glColor4dv((x1))

 void __glColor4fv( const GLfloat *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1054(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor4fv(x1) __glColor4fv((x1))

 void __glColor4iv( const GLint *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1060(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor4iv(x1) __glColor4iv((x1))

 void __glColor4sv( const GLshort *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1066(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor4sv(x1) __glColor4sv((x1))

 void __glColor4ubv( const GLubyte *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1072(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor4ubv(x1) __glColor4ubv((x1))

 void __glColor4uiv( const GLuint *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1078(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor4uiv(x1) __glColor4uiv((x1))

 void __glColor4usv( const GLushort *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1084(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColor4usv(x1) __glColor4usv((x1))

 void __glTexCoord1d( GLdouble s ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1090(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord1d(x1) __glTexCoord1d((x1))

 void __glTexCoord1f( GLfloat s ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1096(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord1f(x1) __glTexCoord1f((x1))

 void __glTexCoord1i( GLint s ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1102(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord1i(x1) __glTexCoord1i((x1))

 void __glTexCoord1s( GLshort s ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1108(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord1s(x1) __glTexCoord1s((x1))

 void __glTexCoord2d( GLdouble s, GLdouble t ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1114(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord2d(x1,x2) __glTexCoord2d((x1),(x2))

 void __glTexCoord2f( GLfloat s, GLfloat t ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1120(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord2f(x1,x2) __glTexCoord2f((x1),(x2))

 void __glTexCoord2i( GLint s, GLint t ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1126(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord2i(x1,x2) __glTexCoord2i((x1),(x2))

 void __glTexCoord2s( GLshort s, GLshort t ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1132(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord2s(x1,x2) __glTexCoord2s((x1),(x2))

 void __glTexCoord3d( GLdouble s, GLdouble t, GLdouble r ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1138(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord3d(x1,x2,x3) __glTexCoord3d((x1),(x2),(x3))

 void __glTexCoord3f( GLfloat s, GLfloat t, GLfloat r ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1144(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord3f(x1,x2,x3) __glTexCoord3f((x1),(x2),(x3))

 void __glTexCoord3i( GLint s, GLint t, GLint r ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1150(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord3i(x1,x2,x3) __glTexCoord3i((x1),(x2),(x3))

 void __glTexCoord3s( GLshort s, GLshort t, GLshort r ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1156(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord3s(x1,x2,x3) __glTexCoord3s((x1),(x2),(x3))

 void __glTexCoord4d( GLdouble s, GLdouble t, GLdouble r, GLdouble q ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1162(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord4d(x1,x2,x3,x4) __glTexCoord4d((x1),(x2),(x3),(x4))

 void __glTexCoord4f( GLfloat s, GLfloat t, GLfloat r, GLfloat q ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1168(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord4f(x1,x2,x3,x4) __glTexCoord4f((x1),(x2),(x3),(x4))

 void __glTexCoord4i( GLint s, GLint t, GLint r, GLint q ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1174(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord4i(x1,x2,x3,x4) __glTexCoord4i((x1),(x2),(x3),(x4))

 void __glTexCoord4s( GLshort s, GLshort t, GLshort r, GLshort q ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1180(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord4s(x1,x2,x3,x4) __glTexCoord4s((x1),(x2),(x3),(x4))

 void __glTexCoord1dv( const GLdouble *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1186(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord1dv(x1) __glTexCoord1dv((x1))

 void __glTexCoord1fv( const GLfloat *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1192(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord1fv(x1) __glTexCoord1fv((x1))

 void __glTexCoord1iv( const GLint *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1198(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord1iv(x1) __glTexCoord1iv((x1))

 void __glTexCoord1sv( const GLshort *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1204(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord1sv(x1) __glTexCoord1sv((x1))

 void __glTexCoord2dv( const GLdouble *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1210(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord2dv(x1) __glTexCoord2dv((x1))

 void __glTexCoord2fv( const GLfloat *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1216(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord2fv(x1) __glTexCoord2fv((x1))

 void __glTexCoord2iv( const GLint *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1222(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord2iv(x1) __glTexCoord2iv((x1))

 void __glTexCoord2sv( const GLshort *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1228(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord2sv(x1) __glTexCoord2sv((x1))

 void __glTexCoord3dv( const GLdouble *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1234(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord3dv(x1) __glTexCoord3dv((x1))

 void __glTexCoord3fv( const GLfloat *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1240(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord3fv(x1) __glTexCoord3fv((x1))

 void __glTexCoord3iv( const GLint *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1246(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord3iv(x1) __glTexCoord3iv((x1))

 void __glTexCoord3sv( const GLshort *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1252(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord3sv(x1) __glTexCoord3sv((x1))

 void __glTexCoord4dv( const GLdouble *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1258(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord4dv(x1) __glTexCoord4dv((x1))

 void __glTexCoord4fv( const GLfloat *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1264(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord4fv(x1) __glTexCoord4fv((x1))

 void __glTexCoord4iv( const GLint *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1270(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord4iv(x1) __glTexCoord4iv((x1))

 void __glTexCoord4sv( const GLshort *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1276(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoord4sv(x1) __glTexCoord4sv((x1))

 void __glRasterPos2d( GLdouble x, GLdouble y ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1282(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRasterPos2d(x1,x2) __glRasterPos2d((x1),(x2))

 void __glRasterPos2f( GLfloat x, GLfloat y ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1288(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRasterPos2f(x1,x2) __glRasterPos2f((x1),(x2))

 void __glRasterPos2i( GLint x, GLint y ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1294(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRasterPos2i(x1,x2) __glRasterPos2i((x1),(x2))

 void __glRasterPos2s( GLshort x, GLshort y ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1300(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRasterPos2s(x1,x2) __glRasterPos2s((x1),(x2))

 void __glRasterPos3d( GLdouble x, GLdouble y, GLdouble z ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1306(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRasterPos3d(x1,x2,x3) __glRasterPos3d((x1),(x2),(x3))

 void __glRasterPos3f( GLfloat x, GLfloat y, GLfloat z ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1312(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRasterPos3f(x1,x2,x3) __glRasterPos3f((x1),(x2),(x3))

 void __glRasterPos3i( GLint x, GLint y, GLint z ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1318(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRasterPos3i(x1,x2,x3) __glRasterPos3i((x1),(x2),(x3))

 void __glRasterPos3s( GLshort x, GLshort y, GLshort z ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1324(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRasterPos3s(x1,x2,x3) __glRasterPos3s((x1),(x2),(x3))

 void __glRasterPos4d( GLdouble x, GLdouble y, GLdouble z, GLdouble w ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1330(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRasterPos4d(x1,x2,x3,x4) __glRasterPos4d((x1),(x2),(x3),(x4))

 void __glRasterPos4f( GLfloat x, GLfloat y, GLfloat z, GLfloat w ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1336(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRasterPos4f(x1,x2,x3,x4) __glRasterPos4f((x1),(x2),(x3),(x4))

 void __glRasterPos4i( GLint x, GLint y, GLint z, GLint w ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1342(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRasterPos4i(x1,x2,x3,x4) __glRasterPos4i((x1),(x2),(x3),(x4))

 void __glRasterPos4s( GLshort x, GLshort y, GLshort z, GLshort w ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1348(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRasterPos4s(x1,x2,x3,x4) __glRasterPos4s((x1),(x2),(x3),(x4))

 void __glRasterPos2dv( const GLdouble *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1354(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRasterPos2dv(x1) __glRasterPos2dv((x1))

 void __glRasterPos2fv( const GLfloat *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1360(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRasterPos2fv(x1) __glRasterPos2fv((x1))

 void __glRasterPos2iv( const GLint *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1366(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRasterPos2iv(x1) __glRasterPos2iv((x1))

 void __glRasterPos2sv( const GLshort *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1372(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRasterPos2sv(x1) __glRasterPos2sv((x1))

 void __glRasterPos3dv( const GLdouble *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1378(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRasterPos3dv(x1) __glRasterPos3dv((x1))

 void __glRasterPos3fv( const GLfloat *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1384(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRasterPos3fv(x1) __glRasterPos3fv((x1))

 void __glRasterPos3iv( const GLint *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1390(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRasterPos3iv(x1) __glRasterPos3iv((x1))

 void __glRasterPos3sv( const GLshort *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1396(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRasterPos3sv(x1) __glRasterPos3sv((x1))

 void __glRasterPos4dv( const GLdouble *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1402(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRasterPos4dv(x1) __glRasterPos4dv((x1))

 void __glRasterPos4fv( const GLfloat *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1408(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRasterPos4fv(x1) __glRasterPos4fv((x1))

 void __glRasterPos4iv( const GLint *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1414(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRasterPos4iv(x1) __glRasterPos4iv((x1))

 void __glRasterPos4sv( const GLshort *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1420(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRasterPos4sv(x1) __glRasterPos4sv((x1))

 void __glRectd( GLdouble x1, GLdouble y1, GLdouble x2, GLdouble y2 ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1426(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRectd(x1,x2,x3,x4) __glRectd((x1),(x2),(x3),(x4))

 void __glRectf( GLfloat x1, GLfloat y1, GLfloat x2, GLfloat y2 ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1432(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRectf(x1,x2,x3,x4) __glRectf((x1),(x2),(x3),(x4))

 void __glRecti( GLint x1, GLint y1, GLint x2, GLint y2 ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1438(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRecti(x1,x2,x3,x4) __glRecti((x1),(x2),(x3),(x4))

 void __glRects( GLshort x1, GLshort y1, GLshort x2, GLshort y2 ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1444(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRects(x1,x2,x3,x4) __glRects((x1),(x2),(x3),(x4))

 void __glRectdv( const GLdouble *v1, const GLdouble *v2 ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1450(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRectdv(x1,x2) __glRectdv((x1),(x2))

 void __glRectfv( const GLfloat *v1, const GLfloat *v2 ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1456(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRectfv(x1,x2) __glRectfv((x1),(x2))

 void __glRectiv( const GLint *v1, const GLint *v2 ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1462(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRectiv(x1,x2) __glRectiv((x1),(x2))

 void __glRectsv( const GLshort *v1, const GLshort *v2 ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1468(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glRectsv(x1,x2) __glRectsv((x1),(x2))

 void __glVertexPointer( GLint size, GLenum type,
                                         GLsizei stride, const GLvoid *ptr ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1474(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glVertexPointer(x1,x2,x3,x4) __glVertexPointer((x1),(x2),(x3),(x4))

 void __glNormalPointer( GLenum type, GLsizei stride,
                                         const GLvoid *ptr ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1480(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glNormalPointer(x1,x2,x3) __glNormalPointer((x1),(x2),(x3))

 void __glColorPointer( GLint size, GLenum type,
                                        GLsizei stride, const GLvoid *ptr ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1486(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColorPointer(x1,x2,x3,x4) __glColorPointer((x1),(x2),(x3),(x4))

 void __glIndexPointer( GLenum type, GLsizei stride,
                                        const GLvoid *ptr ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1492(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glIndexPointer(x1,x2,x3) __glIndexPointer((x1),(x2),(x3))

 void __glTexCoordPointer( GLint size, GLenum type,
                                           GLsizei stride, const GLvoid *ptr ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1498(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoordPointer(x1,x2,x3,x4) __glTexCoordPointer((x1),(x2),(x3),(x4))

 void __glEdgeFlagPointer( GLsizei stride,
                                           const GLboolean *ptr ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1504(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glEdgeFlagPointer(x1,x2) __glEdgeFlagPointer((x1),(x2))

 void __glGetPointerv( GLenum pname, void **params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1510(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetPointerv(x1,x2) __glGetPointerv((x1),(x2))

 void __glArrayElement( GLint i ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1516(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glArrayElement(x1) __glArrayElement((x1))

 void __glDrawArrays( GLenum mode, GLint first,
                                      GLsizei count ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1522(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glDrawArrays(x1,x2,x3) __glDrawArrays((x1),(x2),(x3))

 void __glDrawElements( GLenum mode, GLsizei count,
                                        GLenum type, const GLvoid *indices ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1528(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glDrawElements(x1,x2,x3,x4) __glDrawElements((x1),(x2),(x3),(x4))

 void __glInterleavedArrays( GLenum format, GLsizei stride,
                                             const GLvoid *pointer ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1534(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glInterleavedArrays(x1,x2,x3) __glInterleavedArrays((x1),(x2),(x3))

 void __glShadeModel( GLenum mode ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1540(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glShadeModel(x1) __glShadeModel((x1))

 void __glLightf( GLenum light, GLenum pname, GLfloat param ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1546(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glLightf(x1,x2,x3) __glLightf((x1),(x2),(x3))

 void __glLighti( GLenum light, GLenum pname, GLint param ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1552(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glLighti(x1,x2,x3) __glLighti((x1),(x2),(x3))

 void __glLightfv( GLenum light, GLenum pname,
                                   const GLfloat *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1558(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glLightfv(x1,x2,x3) __glLightfv((x1),(x2),(x3))

 void __glLightiv( GLenum light, GLenum pname,
                                   const GLint *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1564(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glLightiv(x1,x2,x3) __glLightiv((x1),(x2),(x3))

 void __glGetLightfv( GLenum light, GLenum pname,
                                      GLfloat *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1570(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetLightfv(x1,x2,x3) __glGetLightfv((x1),(x2),(x3))

 void __glGetLightiv( GLenum light, GLenum pname,
                                      GLint *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1576(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetLightiv(x1,x2,x3) __glGetLightiv((x1),(x2),(x3))

 void __glLightModelf( GLenum pname, GLfloat param ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1582(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glLightModelf(x1,x2) __glLightModelf((x1),(x2))

 void __glLightModeli( GLenum pname, GLint param ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1588(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glLightModeli(x1,x2) __glLightModeli((x1),(x2))

 void __glLightModelfv( GLenum pname, const GLfloat *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1594(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glLightModelfv(x1,x2) __glLightModelfv((x1),(x2))

 void __glLightModeliv( GLenum pname, const GLint *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1600(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glLightModeliv(x1,x2) __glLightModeliv((x1),(x2))

 void __glMaterialf( GLenum face, GLenum pname, GLfloat param ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1606(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMaterialf(x1,x2,x3) __glMaterialf((x1),(x2),(x3))

 void __glMateriali( GLenum face, GLenum pname, GLint param ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1612(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMateriali(x1,x2,x3) __glMateriali((x1),(x2),(x3))

 void __glMaterialfv( GLenum face, GLenum pname, const GLfloat *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1618(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMaterialfv(x1,x2,x3) __glMaterialfv((x1),(x2),(x3))

 void __glMaterialiv( GLenum face, GLenum pname, const GLint *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1624(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMaterialiv(x1,x2,x3) __glMaterialiv((x1),(x2),(x3))

 void __glGetMaterialfv( GLenum face, GLenum pname, GLfloat *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1630(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetMaterialfv(x1,x2,x3) __glGetMaterialfv((x1),(x2),(x3))

 void __glGetMaterialiv( GLenum face, GLenum pname, GLint *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1636(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetMaterialiv(x1,x2,x3) __glGetMaterialiv((x1),(x2),(x3))

 void __glColorMaterial( GLenum face, GLenum mode ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1642(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColorMaterial(x1,x2) __glColorMaterial((x1),(x2))

 void __glPixelZoom( GLfloat xfactor, GLfloat yfactor ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1648(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glPixelZoom(x1,x2) __glPixelZoom((x1),(x2))

 void __glPixelStoref( GLenum pname, GLfloat param ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1654(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glPixelStoref(x1,x2) __glPixelStoref((x1),(x2))

 void __glPixelStorei( GLenum pname, GLint param ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1660(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glPixelStorei(x1,x2) __glPixelStorei((x1),(x2))

 void __glPixelTransferf( GLenum pname, GLfloat param ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1666(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glPixelTransferf(x1,x2) __glPixelTransferf((x1),(x2))

 void __glPixelTransferi( GLenum pname, GLint param ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1672(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glPixelTransferi(x1,x2) __glPixelTransferi((x1),(x2))

 void __glPixelMapfv( GLenum map, GLint mapsize,
                                      const GLfloat *values ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1678(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glPixelMapfv(x1,x2,x3) __glPixelMapfv((x1),(x2),(x3))

 void __glPixelMapuiv( GLenum map, GLint mapsize,
                                       const GLuint *values ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1684(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glPixelMapuiv(x1,x2,x3) __glPixelMapuiv((x1),(x2),(x3))

 void __glPixelMapusv( GLenum map, GLint mapsize,
                                       const GLushort *values ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1690(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glPixelMapusv(x1,x2,x3) __glPixelMapusv((x1),(x2),(x3))

 void __glGetPixelMapfv( GLenum map, GLfloat *values ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1696(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetPixelMapfv(x1,x2) __glGetPixelMapfv((x1),(x2))

 void __glGetPixelMapuiv( GLenum map, GLuint *values ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1702(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetPixelMapuiv(x1,x2) __glGetPixelMapuiv((x1),(x2))

 void __glGetPixelMapusv( GLenum map, GLushort *values ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1708(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetPixelMapusv(x1,x2) __glGetPixelMapusv((x1),(x2))

 void __glBitmap( GLsizei width, GLsizei height,
                                  GLfloat xorig, GLfloat yorig,
                                  GLfloat xmove, GLfloat ymove,
                                  const GLubyte *bitmap ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1714(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glBitmap(x1,x2,x3,x4,x5,x6,x7) __glBitmap((x1),(x2),(x3),(x4),(x5),(x6),(x7))

 void __glReadPixels( GLint x, GLint y,
                                      GLsizei width, GLsizei height,
                                      GLenum format, GLenum type,
                                      GLvoid *pixels ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1720(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glReadPixels(x1,x2,x3,x4,x5,x6,x7) __glReadPixels((x1),(x2),(x3),(x4),(x5),(x6),(x7))

 void __glDrawPixels( GLsizei width, GLsizei height,
                                      GLenum format, GLenum type,
                                      const GLvoid *pixels ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1726(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glDrawPixels(x1,x2,x3,x4,x5) __glDrawPixels((x1),(x2),(x3),(x4),(x5))

 void __glCopyPixels( GLint x, GLint y,
                                      GLsizei width, GLsizei height,
                                      GLenum type ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1732(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glCopyPixels(x1,x2,x3,x4,x5) __glCopyPixels((x1),(x2),(x3),(x4),(x5))

 void __glStencilFunc( GLenum func, GLint ref, GLuint mask ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1738(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glStencilFunc(x1,x2,x3) __glStencilFunc((x1),(x2),(x3))

 void __glStencilMask( GLuint mask ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1744(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glStencilMask(x1) __glStencilMask((x1))

 void __glStencilOp( GLenum fail, GLenum zfail, GLenum zpass ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1750(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glStencilOp(x1,x2,x3) __glStencilOp((x1),(x2),(x3))

 void __glClearStencil( GLint s ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1756(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glClearStencil(x1) __glClearStencil((x1))

 void __glTexGend( GLenum coord, GLenum pname, GLdouble param ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1762(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexGend(x1,x2,x3) __glTexGend((x1),(x2),(x3))

 void __glTexGenf( GLenum coord, GLenum pname, GLfloat param ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1768(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexGenf(x1,x2,x3) __glTexGenf((x1),(x2),(x3))

 void __glTexGeni( GLenum coord, GLenum pname, GLint param ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1774(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexGeni(x1,x2,x3) __glTexGeni((x1),(x2),(x3))

 void __glTexGendv( GLenum coord, GLenum pname, const GLdouble *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1780(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexGendv(x1,x2,x3) __glTexGendv((x1),(x2),(x3))

 void __glTexGenfv( GLenum coord, GLenum pname, const GLfloat *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1786(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexGenfv(x1,x2,x3) __glTexGenfv((x1),(x2),(x3))

 void __glTexGeniv( GLenum coord, GLenum pname, const GLint *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1792(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexGeniv(x1,x2,x3) __glTexGeniv((x1),(x2),(x3))

 void __glGetTexGendv( GLenum coord, GLenum pname, GLdouble *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1798(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetTexGendv(x1,x2,x3) __glGetTexGendv((x1),(x2),(x3))

 void __glGetTexGenfv( GLenum coord, GLenum pname, GLfloat *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1804(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetTexGenfv(x1,x2,x3) __glGetTexGenfv((x1),(x2),(x3))

 void __glGetTexGeniv( GLenum coord, GLenum pname, GLint *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1810(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetTexGeniv(x1,x2,x3) __glGetTexGeniv((x1),(x2),(x3))

 void __glTexEnvf( GLenum target, GLenum pname, GLfloat param ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1816(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexEnvf(x1,x2,x3) __glTexEnvf((x1),(x2),(x3))

 void __glTexEnvi( GLenum target, GLenum pname, GLint param ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1822(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexEnvi(x1,x2,x3) __glTexEnvi((x1),(x2),(x3))

 void __glTexEnvfv( GLenum target, GLenum pname, const GLfloat *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1828(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexEnvfv(x1,x2,x3) __glTexEnvfv((x1),(x2),(x3))

 void __glTexEnviv( GLenum target, GLenum pname, const GLint *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1834(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexEnviv(x1,x2,x3) __glTexEnviv((x1),(x2),(x3))

 void __glGetTexEnvfv( GLenum target, GLenum pname, GLfloat *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1840(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetTexEnvfv(x1,x2,x3) __glGetTexEnvfv((x1),(x2),(x3))

 void __glGetTexEnviv( GLenum target, GLenum pname, GLint *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1846(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetTexEnviv(x1,x2,x3) __glGetTexEnviv((x1),(x2),(x3))

 void __glTexParameterf( GLenum target, GLenum pname, GLfloat param ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1852(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexParameterf(x1,x2,x3) __glTexParameterf((x1),(x2),(x3))

 void __glTexParameteri( GLenum target, GLenum pname, GLint param ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1858(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexParameteri(x1,x2,x3) __glTexParameteri((x1),(x2),(x3))

 void __glTexParameterfv( GLenum target, GLenum pname,
                                          const GLfloat *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1864(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexParameterfv(x1,x2,x3) __glTexParameterfv((x1),(x2),(x3))

 void __glTexParameteriv( GLenum target, GLenum pname,
                                          const GLint *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1870(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexParameteriv(x1,x2,x3) __glTexParameteriv((x1),(x2),(x3))

 void __glGetTexParameterfv( GLenum target,
                                             GLenum pname, GLfloat *params) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1876(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetTexParameterfv(x1,x2,x3) __glGetTexParameterfv((x1),(x2),(x3))

 void __glGetTexParameteriv( GLenum target,
                                             GLenum pname, GLint *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1882(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetTexParameteriv(x1,x2,x3) __glGetTexParameteriv((x1),(x2),(x3))

 void __glGetTexLevelParameterfv( GLenum target, GLint level,
                                                  GLenum pname, GLfloat *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1888(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetTexLevelParameterfv(x1,x2,x3,x4) __glGetTexLevelParameterfv((x1),(x2),(x3),(x4))

 void __glGetTexLevelParameteriv( GLenum target, GLint level,
                                                  GLenum pname, GLint *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1894(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetTexLevelParameteriv(x1,x2,x3,x4) __glGetTexLevelParameteriv((x1),(x2),(x3),(x4))

 void __glTexImage1D( GLenum target, GLint level,
                                      GLint internalFormat,
                                      GLsizei width, GLint border,
                                      GLenum format, GLenum type,
                                      const GLvoid *pixels ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1900(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexImage1D(x1,x2,x3,x4,x5,x6,x7,x8) __glTexImage1D((x1),(x2),(x3),(x4),(x5),(x6),(x7),(x8))

 void __glTexImage2D( GLenum target, GLint level,
                                      GLint internalFormat,
                                      GLsizei width, GLsizei height,
                                      GLint border, GLenum format, GLenum type,
                                      const GLvoid *pixels ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1906(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexImage2D(x1,x2,x3,x4,x5,x6,x7,x8,x9) __glTexImage2D((x1),(x2),(x3),(x4),(x5),(x6),(x7),(x8),(x9))

 void __glGetTexImage( GLenum target, GLint level,
                                       GLenum format, GLenum type,
                                       GLvoid *pixels ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1912(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetTexImage(x1,x2,x3,x4,x5) __glGetTexImage((x1),(x2),(x3),(x4),(x5))

 void __glGenTextures( GLsizei n, GLuint *textures ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1918(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGenTextures(x1,x2) __glGenTextures((x1),(x2))

 void __glDeleteTextures( GLsizei n, const GLuint *textures) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1924(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glDeleteTextures(x1,x2) __glDeleteTextures((x1),(x2))

 void __glBindTexture( GLenum target, GLuint texture ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1930(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glBindTexture(x1,x2) __glBindTexture((x1),(x2))

 void __glPrioritizeTextures( GLsizei n,
                                              const GLuint *textures,
                                              const GLclampf *priorities ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1936(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glPrioritizeTextures(x1,x2,x3) __glPrioritizeTextures((x1),(x2),(x3))

 GLboolean __glAreTexturesResident( GLsizei n,
                                                    const GLuint *textures,
                                                    GLboolean *residences ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1942(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glAreTexturesResident(x1,x2,x3) __glAreTexturesResident((x1),(x2),(x3))

 GLboolean __glIsTexture( GLuint texture ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1948(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glIsTexture(x1) __glIsTexture((x1))

 void __glTexSubImage1D( GLenum target, GLint level,
                                         GLint xoffset,
                                         GLsizei width, GLenum format,
                                         GLenum type, const GLvoid *pixels ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1954(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexSubImage1D(x1,x2,x3,x4,x5,x6,x7) __glTexSubImage1D((x1),(x2),(x3),(x4),(x5),(x6),(x7))

 void __glTexSubImage2D( GLenum target, GLint level,
                                         GLint xoffset, GLint yoffset,
                                         GLsizei width, GLsizei height,
                                         GLenum format, GLenum type,
                                         const GLvoid *pixels ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1960(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexSubImage2D(x1,x2,x3,x4,x5,x6,x7,x8,x9) __glTexSubImage2D((x1),(x2),(x3),(x4),(x5),(x6),(x7),(x8),(x9))

 void __glCopyTexImage1D( GLenum target, GLint level,
                                          GLenum internalformat,
                                          GLint x, GLint y,
                                          GLsizei width, GLint border ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1966(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glCopyTexImage1D(x1,x2,x3,x4,x5,x6,x7) __glCopyTexImage1D((x1),(x2),(x3),(x4),(x5),(x6),(x7))

 void __glCopyTexImage2D( GLenum target, GLint level,
                                          GLenum internalformat,
                                          GLint x, GLint y,
                                          GLsizei width, GLsizei height,
                                          GLint border ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1972(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glCopyTexImage2D(x1,x2,x3,x4,x5,x6,x7,x8) __glCopyTexImage2D((x1),(x2),(x3),(x4),(x5),(x6),(x7),(x8))

 void __glCopyTexSubImage1D( GLenum target, GLint level,
                                             GLint xoffset, GLint x, GLint y,
                                             GLsizei width ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1978(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glCopyTexSubImage1D(x1,x2,x3,x4,x5,x6) __glCopyTexSubImage1D((x1),(x2),(x3),(x4),(x5),(x6))

 void __glCopyTexSubImage2D( GLenum target, GLint level,
                                             GLint xoffset, GLint yoffset,
                                             GLint x, GLint y,
                                             GLsizei width, GLsizei height ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1984(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glCopyTexSubImage2D(x1,x2,x3,x4,x5,x6,x7,x8) __glCopyTexSubImage2D((x1),(x2),(x3),(x4),(x5),(x6),(x7),(x8))

 void __glMap1d( GLenum target, GLdouble u1, GLdouble u2,
                                 GLint stride,
                                 GLint order, const GLdouble *points ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1990(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMap1d(x1,x2,x3,x4,x5,x6) __glMap1d((x1),(x2),(x3),(x4),(x5),(x6))

 void __glMap1f( GLenum target, GLfloat u1, GLfloat u2,
                                 GLint stride,
                                 GLint order, const GLfloat *points ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-1996(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMap1f(x1,x2,x3,x4,x5,x6) __glMap1f((x1),(x2),(x3),(x4),(x5),(x6))

 void __glMap2d( GLenum target,
                     GLdouble u1, GLdouble u2, GLint ustride, GLint uorder,
                     GLdouble v1, GLdouble v2, GLint vstride, GLint vorder,
                     const GLdouble *points ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2002(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMap2d(x1,x2,x3,x4,x5,x6,x7,x8,x9,xa) __glMap2d((x1),(x2),(x3),(x4),(x5),(x6),(x7),(x8),(x9),(xa))

 void __glMap2f( GLenum target,
                     GLfloat u1, GLfloat u2, GLint ustride, GLint uorder,
                     GLfloat v1, GLfloat v2, GLint vstride, GLint vorder,
                     const GLfloat *points ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2008(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMap2f(x1,x2,x3,x4,x5,x6,x7,x8,x9,xa) __glMap2f((x1),(x2),(x3),(x4),(x5),(x6),(x7),(x8),(x9),(xa))

 void __glGetMapdv( GLenum target, GLenum query, GLdouble *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2014(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetMapdv(x1,x2,x3) __glGetMapdv((x1),(x2),(x3))

 void __glGetMapfv( GLenum target, GLenum query, GLfloat *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2020(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetMapfv(x1,x2,x3) __glGetMapfv((x1),(x2),(x3))

 void __glGetMapiv( GLenum target, GLenum query, GLint *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2026(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetMapiv(x1,x2,x3) __glGetMapiv((x1),(x2),(x3))

 void __glEvalCoord1d( GLdouble u ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2032(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glEvalCoord1d(x1) __glEvalCoord1d((x1))

 void __glEvalCoord1f( GLfloat u ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2038(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glEvalCoord1f(x1) __glEvalCoord1f((x1))

 void __glEvalCoord1dv( const GLdouble *u ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2044(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glEvalCoord1dv(x1) __glEvalCoord1dv((x1))

 void __glEvalCoord1fv( const GLfloat *u ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2050(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glEvalCoord1fv(x1) __glEvalCoord1fv((x1))

 void __glEvalCoord2d( GLdouble u, GLdouble v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2056(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glEvalCoord2d(x1,x2) __glEvalCoord2d((x1),(x2))

 void __glEvalCoord2f( GLfloat u, GLfloat v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2062(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glEvalCoord2f(x1,x2) __glEvalCoord2f((x1),(x2))

 void __glEvalCoord2dv( const GLdouble *u ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2068(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glEvalCoord2dv(x1) __glEvalCoord2dv((x1))

 void __glEvalCoord2fv( const GLfloat *u ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2074(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glEvalCoord2fv(x1) __glEvalCoord2fv((x1))

 void __glMapGrid1d( GLint un, GLdouble u1, GLdouble u2 ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2080(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMapGrid1d(x1,x2,x3) __glMapGrid1d((x1),(x2),(x3))

 void __glMapGrid1f( GLint un, GLfloat u1, GLfloat u2 ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2086(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMapGrid1f(x1,x2,x3) __glMapGrid1f((x1),(x2),(x3))

 void __glMapGrid2d( GLint un, GLdouble u1, GLdouble u2,
                                     GLint vn, GLdouble v1, GLdouble v2 ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2092(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMapGrid2d(x1,x2,x3,x4,x5,x6) __glMapGrid2d((x1),(x2),(x3),(x4),(x5),(x6))

 void __glMapGrid2f( GLint un, GLfloat u1, GLfloat u2,
                                     GLint vn, GLfloat v1, GLfloat v2 ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2098(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMapGrid2f(x1,x2,x3,x4,x5,x6) __glMapGrid2f((x1),(x2),(x3),(x4),(x5),(x6))

 void __glEvalPoint1( GLint i ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2104(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glEvalPoint1(x1) __glEvalPoint1((x1))

 void __glEvalPoint2( GLint i, GLint j ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2110(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glEvalPoint2(x1,x2) __glEvalPoint2((x1),(x2))

 void __glEvalMesh1( GLenum mode, GLint i1, GLint i2 ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2116(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glEvalMesh1(x1,x2,x3) __glEvalMesh1((x1),(x2),(x3))

 void __glEvalMesh2( GLenum mode, GLint i1, GLint i2, GLint j1, GLint j2 ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2122(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glEvalMesh2(x1,x2,x3,x4,x5) __glEvalMesh2((x1),(x2),(x3),(x4),(x5))

 void __glFogf( GLenum pname, GLfloat param ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2128(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glFogf(x1,x2) __glFogf((x1),(x2))

 void __glFogi( GLenum pname, GLint param ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2134(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glFogi(x1,x2) __glFogi((x1),(x2))

 void __glFogfv( GLenum pname, const GLfloat *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2140(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glFogfv(x1,x2) __glFogfv((x1),(x2))

 void __glFogiv( GLenum pname, const GLint *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2146(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glFogiv(x1,x2) __glFogiv((x1),(x2))

 void __glFeedbackBuffer( GLsizei size, GLenum type, GLfloat *buffer ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2152(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glFeedbackBuffer(x1,x2,x3) __glFeedbackBuffer((x1),(x2),(x3))

 void __glPassThrough( GLfloat token ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2158(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glPassThrough(x1) __glPassThrough((x1))

 void __glSelectBuffer( GLsizei size, GLuint *buffer ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2164(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glSelectBuffer(x1,x2) __glSelectBuffer((x1),(x2))

 void __glInitNames( void ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2170(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glInitNames() __glInitNames()

 void __glLoadName( GLuint name ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2176(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glLoadName(x1) __glLoadName((x1))

 void __glPushName( GLuint name ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2182(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glPushName(x1) __glPushName((x1))

 void __glPopName( void ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2188(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glPopName() __glPopName()

 void __glBlendEquationEXT( GLenum mode ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2194(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glBlendEquationEXT(x1) __glBlendEquationEXT((x1))

 void __glBlendColorEXT( GLclampf red, GLclampf green,
                                         GLclampf blue, GLclampf alpha ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2200(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glBlendColorEXT(x1,x2,x3,x4) __glBlendColorEXT((x1),(x2),(x3),(x4))

 void __glPolygonOffsetEXT( GLfloat factor, GLfloat bias ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2206(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glPolygonOffsetEXT(x1,x2) __glPolygonOffsetEXT((x1),(x2))

 void __glVertexPointerEXT( GLint size, GLenum type,
                                            GLsizei stride,
                                            GLsizei count, const GLvoid *ptr ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2212(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glVertexPointerEXT(x1,x2,x3,x4,x5) __glVertexPointerEXT((x1),(x2),(x3),(x4),(x5))

 void __glNormalPointerEXT( GLenum type, GLsizei stride,
                                            GLsizei count, const GLvoid *ptr ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2218(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glNormalPointerEXT(x1,x2,x3,x4) __glNormalPointerEXT((x1),(x2),(x3),(x4))

 void __glColorPointerEXT( GLint size, GLenum type,
                                           GLsizei stride,
                                           GLsizei count, const GLvoid *ptr ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2224(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColorPointerEXT(x1,x2,x3,x4,x5) __glColorPointerEXT((x1),(x2),(x3),(x4),(x5))

 void __glIndexPointerEXT( GLenum type, GLsizei stride,
                                           GLsizei count, const GLvoid *ptr ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2230(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glIndexPointerEXT(x1,x2,x3,x4) __glIndexPointerEXT((x1),(x2),(x3),(x4))

 void __glTexCoordPointerEXT( GLint size, GLenum type,
                                              GLsizei stride, GLsizei count,
                                              const GLvoid *ptr ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2236(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexCoordPointerEXT(x1,x2,x3,x4,x5) __glTexCoordPointerEXT((x1),(x2),(x3),(x4),(x5))

 void __glEdgeFlagPointerEXT( GLsizei stride, GLsizei count,
                                              const GLboolean *ptr ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2242(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glEdgeFlagPointerEXT(x1,x2,x3) __glEdgeFlagPointerEXT((x1),(x2),(x3))

 void __glGetPointervEXT( GLenum pname, void **params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2248(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetPointervEXT(x1,x2) __glGetPointervEXT((x1),(x2))

 void __glArrayElementEXT( GLint i ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2254(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glArrayElementEXT(x1) __glArrayElementEXT((x1))

 void __glDrawArraysEXT( GLenum mode, GLint first,
                                         GLsizei count ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2260(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glDrawArraysEXT(x1,x2,x3) __glDrawArraysEXT((x1),(x2),(x3))

 void __glGenTexturesEXT( GLsizei n, GLuint *textures ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2266(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGenTexturesEXT(x1,x2) __glGenTexturesEXT((x1),(x2))

 void __glDeleteTexturesEXT( GLsizei n,
                                             const GLuint *textures) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2272(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glDeleteTexturesEXT(x1,x2) __glDeleteTexturesEXT((x1),(x2))

 void __glBindTextureEXT( GLenum target, GLuint texture ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2278(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glBindTextureEXT(x1,x2) __glBindTextureEXT((x1),(x2))

 void __glPrioritizeTexturesEXT( GLsizei n,
                                                 const GLuint *textures,
                                                 const GLclampf *priorities ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2284(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glPrioritizeTexturesEXT(x1,x2,x3) __glPrioritizeTexturesEXT((x1),(x2),(x3))

 GLboolean __glAreTexturesResidentEXT( GLsizei n,
                                                       const GLuint *textures,
                                                       GLboolean *residences ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2290(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glAreTexturesResidentEXT(x1,x2,x3) __glAreTexturesResidentEXT((x1),(x2),(x3))

 GLboolean __glIsTextureEXT( GLuint texture ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2296(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glIsTextureEXT(x1) __glIsTextureEXT((x1))

 void __glTexImage3DEXT( GLenum target, GLint level,
                                         GLenum internalFormat,
                                         GLsizei width, GLsizei height,
                                         GLsizei depth, GLint border,
                                         GLenum format, GLenum type,
                                         const GLvoid *pixels ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2302(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexImage3DEXT(x1,x2,x3,x4,x5,x6,x7,x8,x9,xa) __glTexImage3DEXT((x1),(x2),(x3),(x4),(x5),(x6),(x7),(x8),(x9),(xa))

 void __glTexSubImage3DEXT( GLenum target, GLint level,
                                            GLint xoffset, GLint yoffset,
                                            GLint zoffset, GLsizei width,
                                            GLsizei height, GLsizei depth,
                                            GLenum format,
                                            GLenum type, const GLvoid *pixels) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2308(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexSubImage3DEXT(x1,x2,x3,x4,x5,x6,x7,x8,x9,xa,xb) __glTexSubImage3DEXT((x1),(x2),(x3),(x4),(x5),(x6),(x7),(x8),(x9),(xa),(xb))

 void __glCopyTexSubImage3DEXT( GLenum target, GLint level,
                                                GLint xoffset, GLint yoffset,
                                                GLint zoffset, GLint x,
                                                GLint y, GLsizei width,
                                                GLsizei height ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2314(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glCopyTexSubImage3DEXT(x1,x2,x3,x4,x5,x6,x7,x8,x9) __glCopyTexSubImage3DEXT((x1),(x2),(x3),(x4),(x5),(x6),(x7),(x8),(x9))

 void __glColorTableEXT( GLenum target, GLenum internalformat,
                                         GLsizei width, GLenum format,
                                         GLenum type, const GLvoid *table ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2320(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColorTableEXT(x1,x2,x3,x4,x5,x6) __glColorTableEXT((x1),(x2),(x3),(x4),(x5),(x6))

 void __glColorSubTableEXT( GLenum target,
                                            GLsizei start, GLsizei count,
                                            GLenum format, GLenum type,
                                            const GLvoid *data ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2326(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glColorSubTableEXT(x1,x2,x3,x4,x5,x6) __glColorSubTableEXT((x1),(x2),(x3),(x4),(x5),(x6))

 void __glGetColorTableEXT( GLenum target, GLenum format,
                                            GLenum type, GLvoid *table ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2332(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetColorTableEXT(x1,x2,x3,x4) __glGetColorTableEXT((x1),(x2),(x3),(x4))

 void __glGetColorTableParameterfvEXT( GLenum target,
                                                       GLenum pname,
                                                       GLfloat *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2338(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetColorTableParameterfvEXT(x1,x2,x3) __glGetColorTableParameterfvEXT((x1),(x2),(x3))

 void __glGetColorTableParameterivEXT( GLenum target,
                                                       GLenum pname,
                                                       GLint *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2344(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glGetColorTableParameterivEXT(x1,x2,x3) __glGetColorTableParameterivEXT((x1),(x2),(x3))

 void __glMultiTexCoord1dSGIS(GLenum target, GLdouble s) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2350(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord1dSGIS(x1,x2) __glMultiTexCoord1dSGIS((x1),(x2))

 void __glMultiTexCoord1dvSGIS(GLenum target, const GLdouble *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2356(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord1dvSGIS(x1,x2) __glMultiTexCoord1dvSGIS((x1),(x2))

 void __glMultiTexCoord1fSGIS(GLenum target, GLfloat s) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2362(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord1fSGIS(x1,x2) __glMultiTexCoord1fSGIS((x1),(x2))

 void __glMultiTexCoord1fvSGIS(GLenum target, const GLfloat *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2368(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord1fvSGIS(x1,x2) __glMultiTexCoord1fvSGIS((x1),(x2))

 void __glMultiTexCoord1iSGIS(GLenum target, GLint s) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2374(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord1iSGIS(x1,x2) __glMultiTexCoord1iSGIS((x1),(x2))

 void __glMultiTexCoord1ivSGIS(GLenum target, const GLint *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2380(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord1ivSGIS(x1,x2) __glMultiTexCoord1ivSGIS((x1),(x2))

 void __glMultiTexCoord1sSGIS(GLenum target, GLshort s) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2386(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord1sSGIS(x1,x2) __glMultiTexCoord1sSGIS((x1),(x2))

 void __glMultiTexCoord1svSGIS(GLenum target, const GLshort *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2392(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord1svSGIS(x1,x2) __glMultiTexCoord1svSGIS((x1),(x2))

 void __glMultiTexCoord2dSGIS(GLenum target, GLdouble s, GLdouble t) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2398(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord2dSGIS(x1,x2,x3) __glMultiTexCoord2dSGIS((x1),(x2),(x3))

 void __glMultiTexCoord2dvSGIS(GLenum target, const GLdouble *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2404(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord2dvSGIS(x1,x2) __glMultiTexCoord2dvSGIS((x1),(x2))

 void __glMultiTexCoord2fSGIS(GLenum target, GLfloat s, GLfloat t) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2410(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord2fSGIS(x1,x2,x3) __glMultiTexCoord2fSGIS((x1),(x2),(x3))

 void __glMultiTexCoord2fvSGIS(GLenum target, const GLfloat *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2416(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord2fvSGIS(x1,x2) __glMultiTexCoord2fvSGIS((x1),(x2))

 void __glMultiTexCoord2iSGIS(GLenum target, GLint s, GLint t) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2422(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord2iSGIS(x1,x2,x3) __glMultiTexCoord2iSGIS((x1),(x2),(x3))

 void __glMultiTexCoord2ivSGIS(GLenum target, const GLint *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2428(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord2ivSGIS(x1,x2) __glMultiTexCoord2ivSGIS((x1),(x2))

 void __glMultiTexCoord2sSGIS(GLenum target, GLshort s, GLshort t) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2434(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord2sSGIS(x1,x2,x3) __glMultiTexCoord2sSGIS((x1),(x2),(x3))

 void __glMultiTexCoord2svSGIS(GLenum target, const GLshort *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2440(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord2svSGIS(x1,x2) __glMultiTexCoord2svSGIS((x1),(x2))

 void __glMultiTexCoord3dSGIS(GLenum target, GLdouble s, GLdouble t, GLdouble r) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2446(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord3dSGIS(x1,x2,x3,x4) __glMultiTexCoord3dSGIS((x1),(x2),(x3),(x4))

 void __glMultiTexCoord3dvSGIS(GLenum target, const GLdouble *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2452(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord3dvSGIS(x1,x2) __glMultiTexCoord3dvSGIS((x1),(x2))

 void __glMultiTexCoord3fSGIS(GLenum target, GLfloat s, GLfloat t, GLfloat r) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2458(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord3fSGIS(x1,x2,x3,x4) __glMultiTexCoord3fSGIS((x1),(x2),(x3),(x4))

 void __glMultiTexCoord3fvSGIS(GLenum target, const GLfloat *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2464(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord3fvSGIS(x1,x2) __glMultiTexCoord3fvSGIS((x1),(x2))

 void __glMultiTexCoord3iSGIS(GLenum target, GLint s, GLint t, GLint r) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2470(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord3iSGIS(x1,x2,x3,x4) __glMultiTexCoord3iSGIS((x1),(x2),(x3),(x4))

 void __glMultiTexCoord3ivSGIS(GLenum target, const GLint *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2476(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord3ivSGIS(x1,x2) __glMultiTexCoord3ivSGIS((x1),(x2))

 void __glMultiTexCoord3sSGIS(GLenum target, GLshort s, GLshort t, GLshort r) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2482(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord3sSGIS(x1,x2,x3,x4) __glMultiTexCoord3sSGIS((x1),(x2),(x3),(x4))

 void __glMultiTexCoord3svSGIS(GLenum target, const GLshort *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2488(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord3svSGIS(x1,x2) __glMultiTexCoord3svSGIS((x1),(x2))

 void __glMultiTexCoord4dSGIS(GLenum target, GLdouble s, GLdouble t, GLdouble r, GLdouble q) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2494(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord4dSGIS(x1,x2,x3,x4,x5) __glMultiTexCoord4dSGIS((x1),(x2),(x3),(x4),(x5))

 void __glMultiTexCoord4dvSGIS(GLenum target, const GLdouble *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2500(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord4dvSGIS(x1,x2) __glMultiTexCoord4dvSGIS((x1),(x2))

 void __glMultiTexCoord4fSGIS(GLenum target, GLfloat s, GLfloat t, GLfloat r, GLfloat q) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2506(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord4fSGIS(x1,x2,x3,x4,x5) __glMultiTexCoord4fSGIS((x1),(x2),(x3),(x4),(x5))

 void __glMultiTexCoord4fvSGIS(GLenum target, const GLfloat *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2512(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord4fvSGIS(x1,x2) __glMultiTexCoord4fvSGIS((x1),(x2))

 void __glMultiTexCoord4iSGIS(GLenum target, GLint s, GLint t, GLint r, GLint q) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2518(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord4iSGIS(x1,x2,x3,x4,x5) __glMultiTexCoord4iSGIS((x1),(x2),(x3),(x4),(x5))

 void __glMultiTexCoord4ivSGIS(GLenum target, const GLint *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2524(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord4ivSGIS(x1,x2) __glMultiTexCoord4ivSGIS((x1),(x2))

 void __glMultiTexCoord4sSGIS(GLenum target, GLshort s, GLshort t, GLshort r, GLshort q) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2530(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord4sSGIS(x1,x2,x3,x4,x5) __glMultiTexCoord4sSGIS((x1),(x2),(x3),(x4),(x5))

 void __glMultiTexCoord4svSGIS(GLenum target, const GLshort *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2536(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord4svSGIS(x1,x2) __glMultiTexCoord4svSGIS((x1),(x2))

 void __glMultiTexCoordPointerSGIS(GLenum target, GLint size, GLenum type, GLsizei stride, const GLvoid *pointer) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2542(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoordPointerSGIS(x1,x2,x3,x4,x5) __glMultiTexCoordPointerSGIS((x1),(x2),(x3),(x4),(x5))

 void __glSelectTextureSGIS(GLenum target) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2548(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glSelectTextureSGIS(x1) __glSelectTextureSGIS((x1))

 void __glSelectTextureCoordSetSGIS(GLenum target) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2554(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glSelectTextureCoordSetSGIS(x1) __glSelectTextureCoordSetSGIS((x1))

 void __glMultiTexCoord1dEXT(GLenum target, GLdouble s) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2560(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord1dEXT(x1,x2) __glMultiTexCoord1dEXT((x1),(x2))

 void __glMultiTexCoord1dvEXT(GLenum target, const GLdouble *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2566(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord1dvEXT(x1,x2) __glMultiTexCoord1dvEXT((x1),(x2))

 void __glMultiTexCoord1fEXT(GLenum target, GLfloat s) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2572(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord1fEXT(x1,x2) __glMultiTexCoord1fEXT((x1),(x2))

 void __glMultiTexCoord1fvEXT(GLenum target, const GLfloat *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2578(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord1fvEXT(x1,x2) __glMultiTexCoord1fvEXT((x1),(x2))

 void __glMultiTexCoord1iEXT(GLenum target, GLint s) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2584(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord1iEXT(x1,x2) __glMultiTexCoord1iEXT((x1),(x2))

 void __glMultiTexCoord1ivEXT(GLenum target, const GLint *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2590(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord1ivEXT(x1,x2) __glMultiTexCoord1ivEXT((x1),(x2))

 void __glMultiTexCoord1sEXT(GLenum target, GLshort s) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2596(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord1sEXT(x1,x2) __glMultiTexCoord1sEXT((x1),(x2))

 void __glMultiTexCoord1svEXT(GLenum target, const GLshort *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2602(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord1svEXT(x1,x2) __glMultiTexCoord1svEXT((x1),(x2))

 void __glMultiTexCoord2dEXT(GLenum target, GLdouble s, GLdouble t) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2608(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord2dEXT(x1,x2,x3) __glMultiTexCoord2dEXT((x1),(x2),(x3))

 void __glMultiTexCoord2dvEXT(GLenum target, const GLdouble *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2614(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord2dvEXT(x1,x2) __glMultiTexCoord2dvEXT((x1),(x2))

 void __glMultiTexCoord2fEXT(GLenum target, GLfloat s, GLfloat t) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2620(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord2fEXT(x1,x2,x3) __glMultiTexCoord2fEXT((x1),(x2),(x3))

 void __glMultiTexCoord2fvEXT(GLenum target, const GLfloat *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2626(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord2fvEXT(x1,x2) __glMultiTexCoord2fvEXT((x1),(x2))

 void __glMultiTexCoord2iEXT(GLenum target, GLint s, GLint t) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2632(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord2iEXT(x1,x2,x3) __glMultiTexCoord2iEXT((x1),(x2),(x3))

 void __glMultiTexCoord2ivEXT(GLenum target, const GLint *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2638(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord2ivEXT(x1,x2) __glMultiTexCoord2ivEXT((x1),(x2))

 void __glMultiTexCoord2sEXT(GLenum target, GLshort s, GLshort t) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2644(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord2sEXT(x1,x2,x3) __glMultiTexCoord2sEXT((x1),(x2),(x3))

 void __glMultiTexCoord2svEXT(GLenum target, const GLshort *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2650(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord2svEXT(x1,x2) __glMultiTexCoord2svEXT((x1),(x2))

 void __glMultiTexCoord3dEXT(GLenum target, GLdouble s, GLdouble t, GLdouble r) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2656(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord3dEXT(x1,x2,x3,x4) __glMultiTexCoord3dEXT((x1),(x2),(x3),(x4))

 void __glMultiTexCoord3dvEXT(GLenum target, const GLdouble *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2662(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord3dvEXT(x1,x2) __glMultiTexCoord3dvEXT((x1),(x2))

 void __glMultiTexCoord3fEXT(GLenum target, GLfloat s, GLfloat t, GLfloat r) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2668(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord3fEXT(x1,x2,x3,x4) __glMultiTexCoord3fEXT((x1),(x2),(x3),(x4))

 void __glMultiTexCoord3fvEXT(GLenum target, const GLfloat *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2674(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord3fvEXT(x1,x2) __glMultiTexCoord3fvEXT((x1),(x2))

 void __glMultiTexCoord3iEXT(GLenum target, GLint s, GLint t, GLint r) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2680(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord3iEXT(x1,x2,x3,x4) __glMultiTexCoord3iEXT((x1),(x2),(x3),(x4))

 void __glMultiTexCoord3ivEXT(GLenum target, const GLint *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2686(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord3ivEXT(x1,x2) __glMultiTexCoord3ivEXT((x1),(x2))

 void __glMultiTexCoord3sEXT(GLenum target, GLshort s, GLshort t, GLshort r) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2692(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord3sEXT(x1,x2,x3,x4) __glMultiTexCoord3sEXT((x1),(x2),(x3),(x4))

 void __glMultiTexCoord3svEXT(GLenum target, const GLshort *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2698(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord3svEXT(x1,x2) __glMultiTexCoord3svEXT((x1),(x2))

 void __glMultiTexCoord4dEXT(GLenum target, GLdouble s, GLdouble t, GLdouble r, GLdouble q) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2704(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord4dEXT(x1,x2,x3,x4,x5) __glMultiTexCoord4dEXT((x1),(x2),(x3),(x4),(x5))

 void __glMultiTexCoord4dvEXT(GLenum target, const GLdouble *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2710(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord4dvEXT(x1,x2) __glMultiTexCoord4dvEXT((x1),(x2))

 void __glMultiTexCoord4fEXT(GLenum target, GLfloat s, GLfloat t, GLfloat r, GLfloat q) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2716(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord4fEXT(x1,x2,x3,x4,x5) __glMultiTexCoord4fEXT((x1),(x2),(x3),(x4),(x5))

 void __glMultiTexCoord4fvEXT(GLenum target, const GLfloat *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2722(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord4fvEXT(x1,x2) __glMultiTexCoord4fvEXT((x1),(x2))

 void __glMultiTexCoord4iEXT(GLenum target, GLint s, GLint t, GLint r, GLint q) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2728(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord4iEXT(x1,x2,x3,x4,x5) __glMultiTexCoord4iEXT((x1),(x2),(x3),(x4),(x5))

 void __glMultiTexCoord4ivEXT(GLenum target, const GLint *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2734(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord4ivEXT(x1,x2) __glMultiTexCoord4ivEXT((x1),(x2))

 void __glMultiTexCoord4sEXT(GLenum target, GLshort s, GLshort t, GLshort r, GLshort q) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2740(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord4sEXT(x1,x2,x3,x4,x5) __glMultiTexCoord4sEXT((x1),(x2),(x3),(x4),(x5))

 void __glMultiTexCoord4svEXT(GLenum target, const GLshort *v) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2746(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glMultiTexCoord4svEXT(x1,x2) __glMultiTexCoord4svEXT((x1),(x2))

 void __glInterleavedTextureCoordSetsEXT( GLint factor ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2752(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glInterleavedTextureCoordSetsEXT(x1) __glInterleavedTextureCoordSetsEXT((x1))

 void __glSelectTextureEXT( GLenum target ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2758(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glSelectTextureEXT(x1) __glSelectTextureEXT((x1))

 void __glSelectTextureCoordSetEXT( GLenum target ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2764(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glSelectTextureCoordSetEXT(x1) __glSelectTextureCoordSetEXT((x1))

 void __glSelectTextureTransformEXT( GLenum target ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2770(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glSelectTextureTransformEXT(x1) __glSelectTextureTransformEXT((x1))

 void __glPointParameterfEXT( GLenum pname, GLfloat param ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2776(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glPointParameterfEXT(x1,x2) __glPointParameterfEXT((x1),(x2))

 void __glPointParameterfvEXT( GLenum pname,
                                               const GLfloat *params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2782(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glPointParameterfvEXT(x1,x2) __glPointParameterfvEXT((x1),(x2))

 void __glWindowPos2iMESA( GLint x, GLint y ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2788(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glWindowPos2iMESA(x1,x2) __glWindowPos2iMESA((x1),(x2))

 void __glWindowPos2sMESA( GLshort x, GLshort y ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2794(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glWindowPos2sMESA(x1,x2) __glWindowPos2sMESA((x1),(x2))

 void __glWindowPos2fMESA( GLfloat x, GLfloat y ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2800(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glWindowPos2fMESA(x1,x2) __glWindowPos2fMESA((x1),(x2))

 void __glWindowPos2dMESA( GLdouble x, GLdouble y ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2806(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glWindowPos2dMESA(x1,x2) __glWindowPos2dMESA((x1),(x2))

 void __glWindowPos2ivMESA( const GLint *p ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2812(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glWindowPos2ivMESA(x1) __glWindowPos2ivMESA((x1))

 void __glWindowPos2svMESA( const GLshort *p ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2818(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glWindowPos2svMESA(x1) __glWindowPos2svMESA((x1))

 void __glWindowPos2fvMESA( const GLfloat *p ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2824(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glWindowPos2fvMESA(x1) __glWindowPos2fvMESA((x1))

 void __glWindowPos2dvMESA( const GLdouble *p ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2830(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glWindowPos2dvMESA(x1) __glWindowPos2dvMESA((x1))

 void __glWindowPos3iMESA( GLint x, GLint y, GLint z ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2836(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glWindowPos3iMESA(x1,x2,x3) __glWindowPos3iMESA((x1),(x2),(x3))

 void __glWindowPos3sMESA( GLshort x, GLshort y, GLshort z ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2842(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glWindowPos3sMESA(x1,x2,x3) __glWindowPos3sMESA((x1),(x2),(x3))

 void __glWindowPos3fMESA( GLfloat x, GLfloat y, GLfloat z ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2848(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glWindowPos3fMESA(x1,x2,x3) __glWindowPos3fMESA((x1),(x2),(x3))

 void __glWindowPos3dMESA( GLdouble x, GLdouble y, GLdouble z ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2854(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glWindowPos3dMESA(x1,x2,x3) __glWindowPos3dMESA((x1),(x2),(x3))

 void __glWindowPos3ivMESA( const GLint *p ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2860(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glWindowPos3ivMESA(x1) __glWindowPos3ivMESA((x1))

 void __glWindowPos3svMESA( const GLshort *p ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2866(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glWindowPos3svMESA(x1) __glWindowPos3svMESA((x1))

 void __glWindowPos3fvMESA( const GLfloat *p ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2872(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glWindowPos3fvMESA(x1) __glWindowPos3fvMESA((x1))

 void __glWindowPos3dvMESA( const GLdouble *p ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2878(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glWindowPos3dvMESA(x1) __glWindowPos3dvMESA((x1))

 void __glWindowPos4iMESA( GLint x, GLint y, GLint z, GLint w ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2884(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glWindowPos4iMESA(x1,x2,x3,x4) __glWindowPos4iMESA((x1),(x2),(x3),(x4))

 void __glWindowPos4sMESA( GLshort x, GLshort y, GLshort z, GLshort w ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2890(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glWindowPos4sMESA(x1,x2,x3,x4) __glWindowPos4sMESA((x1),(x2),(x3),(x4))

 void __glWindowPos4fMESA( GLfloat x, GLfloat y, GLfloat z, GLfloat w ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2896(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glWindowPos4fMESA(x1,x2,x3,x4) __glWindowPos4fMESA((x1),(x2),(x3),(x4))

 void __glWindowPos4dMESA( GLdouble x, GLdouble y, GLdouble z, GLdouble w) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2902(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glWindowPos4dMESA(x1,x2,x3,x4) __glWindowPos4dMESA((x1),(x2),(x3),(x4))

 void __glWindowPos4ivMESA( const GLint *p ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2908(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glWindowPos4ivMESA(x1) __glWindowPos4ivMESA((x1))

 void __glWindowPos4svMESA( const GLshort *p ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2914(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glWindowPos4svMESA(x1) __glWindowPos4svMESA((x1))

 void __glWindowPos4fvMESA( const GLfloat *p ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2920(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glWindowPos4fvMESA(x1) __glWindowPos4fvMESA((x1))

 void __glWindowPos4dvMESA( const GLdouble *p ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2926(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glWindowPos4dvMESA(x1) __glWindowPos4dvMESA((x1))

 void __glResizeBuffersMESA( void ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2932(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glResizeBuffersMESA() __glResizeBuffersMESA()

 void __glDrawRangeElements( GLenum mode, GLuint start,
        GLuint end, GLsizei count, GLenum type, const GLvoid *indices ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2938(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glDrawRangeElements(x1,x2,x3,x4,x5,x6) __glDrawRangeElements((x1),(x2),(x3),(x4),(x5),(x6))

 void __glTexImage3D( GLenum target, GLint level,
                                      GLenum internalFormat,
                                      GLsizei width, GLsizei height,
                                      GLsizei depth, GLint border,
                                      GLenum format, GLenum type,
                                      const GLvoid *pixels ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2944(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexImage3D(x1,x2,x3,x4,x5,x6,x7,x8,x9,xa) __glTexImage3D((x1),(x2),(x3),(x4),(x5),(x6),(x7),(x8),(x9),(xa))

 void __glTexSubImage3D( GLenum target, GLint level,
                                         GLint xoffset, GLint yoffset,
                                         GLint zoffset, GLsizei width,
                                         GLsizei height, GLsizei depth,
                                         GLenum format,
                                         GLenum type, const GLvoid *pixels) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2950(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glTexSubImage3D(x1,x2,x3,x4,x5,x6,x7,x8,x9,xa,xb) __glTexSubImage3D((x1),(x2),(x3),(x4),(x5),(x6),(x7),(x8),(x9),(xa),(xb))

 void __glCopyTexSubImage3D( GLenum target, GLint level,
                                             GLint xoffset, GLint yoffset,
                                             GLint zoffset, GLint x,
                                             GLint y, GLsizei width,
                                             GLsizei height ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-2956(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glCopyTexSubImage3D(x1,x2,x3,x4,x5,x6,x7,x8,x9) __glCopyTexSubImage3D((x1),(x2),(x3),(x4),(x5),(x6),(x7),(x8),(x9))

