 void __glutInit(int *argcp, char **argv) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-34(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutInit(x1,x2) __glutInit((x1),(x2))

 void __glutInitDisplayMode(unsigned int mode) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-40(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutInitDisplayMode(x1) __glutInitDisplayMode((x1))

 void __glutInitDisplayString(const char *string) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-46(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutInitDisplayString(x1) __glutInitDisplayString((x1))

 void __glutInitWindowPosition(int x, int y) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-52(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutInitWindowPosition(x1,x2) __glutInitWindowPosition((x1),(x2))

 void __glutInitWindowSize(int width, int height) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-58(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutInitWindowSize(x1,x2) __glutInitWindowSize((x1),(x2))

 void __glutMainLoop(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-64(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutMainLoop() __glutMainLoop()

 int __glutCreateWindow(const char *title) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-70(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutCreateWindow(x1) __glutCreateWindow((x1))

 int __glutCreateSubWindow(int win, int x, int y, int width, int height) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-76(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutCreateSubWindow(x1,x2,x3,x4,x5) __glutCreateSubWindow((x1),(x2),(x3),(x4),(x5))

 void __glutDestroyWindow(int win) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-82(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutDestroyWindow(x1) __glutDestroyWindow((x1))

 void __glutPostRedisplay(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-88(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutPostRedisplay() __glutPostRedisplay()

 void __glutSwapBuffers(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-94(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutSwapBuffers() __glutSwapBuffers()

 int __glutGetWindow(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-100(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutGetWindow() __glutGetWindow()

 void __glutSetWindow(int win) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-106(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutSetWindow(x1) __glutSetWindow((x1))

 void __glutSetWindowTitle(const char *title) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-112(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutSetWindowTitle(x1) __glutSetWindowTitle((x1))

 void __glutSetIconTitle(const char *title) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-118(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutSetIconTitle(x1) __glutSetIconTitle((x1))

 void __glutPositionWindow(int x, int y) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-124(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutPositionWindow(x1,x2) __glutPositionWindow((x1),(x2))

 void __glutReshapeWindow(int width, int height) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-130(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutReshapeWindow(x1,x2) __glutReshapeWindow((x1),(x2))

 void __glutPopWindow(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-136(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutPopWindow() __glutPopWindow()

 void __glutPushWindow(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-142(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutPushWindow() __glutPushWindow()

 void __glutIconifyWindow(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-148(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutIconifyWindow() __glutIconifyWindow()

 void __glutShowWindow(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-154(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutShowWindow() __glutShowWindow()

 void __glutHideWindow(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-160(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutHideWindow() __glutHideWindow()

 void __glutFullScreen(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-166(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutFullScreen() __glutFullScreen()

 void __glutSetCursor(int cursor) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-172(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutSetCursor(x1) __glutSetCursor((x1))

 void __glutWarpPointer(int x, int y) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-178(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutWarpPointer(x1,x2) __glutWarpPointer((x1),(x2))

 void __glutEstablishOverlay(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-184(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutEstablishOverlay() __glutEstablishOverlay()

 void __glutRemoveOverlay(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-190(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutRemoveOverlay() __glutRemoveOverlay()

 void __glutUseLayer(GLenum layer) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-196(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutUseLayer(x1) __glutUseLayer((x1))

 void __glutPostOverlayRedisplay(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-202(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutPostOverlayRedisplay() __glutPostOverlayRedisplay()

 void __glutShowOverlay(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-208(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutShowOverlay() __glutShowOverlay()

 void __glutHideOverlay(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-214(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutHideOverlay() __glutHideOverlay()

 int __glutCreateMenu(void (*)(int)) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-220(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutCreateMenu(x1) __glutCreateMenu((x1))

 void __glutDestroyMenu(int menu) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-226(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutDestroyMenu(x1) __glutDestroyMenu((x1))

 int __glutGetMenu(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-232(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutGetMenu() __glutGetMenu()

 void __glutSetMenu(int menu) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-238(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutSetMenu(x1) __glutSetMenu((x1))

 void __glutAddMenuEntry(const char *label, int value) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-244(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutAddMenuEntry(x1,x2) __glutAddMenuEntry((x1),(x2))

 void __glutAddSubMenu(const char *label, int submenu) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-250(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutAddSubMenu(x1,x2) __glutAddSubMenu((x1),(x2))

 void __glutChangeToMenuEntry(int item, const char *label, int value) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-256(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutChangeToMenuEntry(x1,x2,x3) __glutChangeToMenuEntry((x1),(x2),(x3))

 void __glutChangeToSubMenu(int item, const char *label, int submenu) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-262(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutChangeToSubMenu(x1,x2,x3) __glutChangeToSubMenu((x1),(x2),(x3))

 void __glutRemoveMenuItem(int item) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-268(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutRemoveMenuItem(x1) __glutRemoveMenuItem((x1))

 void __glutAttachMenu(int button) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-274(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutAttachMenu(x1) __glutAttachMenu((x1))

 void __glutDetachMenu(int button) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-280(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutDetachMenu(x1) __glutDetachMenu((x1))

 void __glutDisplayFunc(void (*func)(void)) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-286(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutDisplayFunc(x1) __glutDisplayFunc((x1))

 void __glutReshapeFunc(void (*func)(int width, int height)) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-292(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutReshapeFunc(x1) __glutReshapeFunc((x1))

 void __glutKeyboardFunc(void (*func)(unsigned char key, int x, int y)) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-298(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutKeyboardFunc(x1) __glutKeyboardFunc((x1))

 void __glutMouseFunc(void (*func)(int button, int state, int x, int y)) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-304(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutMouseFunc(x1) __glutMouseFunc((x1))

 void __glutMotionFunc(void (*func)(int x, int y)) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-310(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutMotionFunc(x1) __glutMotionFunc((x1))

 void __glutPassiveMotionFunc(void (*func)(int x, int y)) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-316(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutPassiveMotionFunc(x1) __glutPassiveMotionFunc((x1))

 void __glutEntryFunc(void (*func)(int state)) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-322(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutEntryFunc(x1) __glutEntryFunc((x1))

 void __glutVisibilityFunc(void (*func)(int state)) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-328(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutVisibilityFunc(x1) __glutVisibilityFunc((x1))

 void __glutIdleFunc(void (*func)(void)) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-334(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutIdleFunc(x1) __glutIdleFunc((x1))

 void __glutTimerFunc(unsigned int millis, void (*func)(int value), int value) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-340(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutTimerFunc(x1,x2,x3) __glutTimerFunc((x1),(x2),(x3))

 void __glutMenuStateFunc(void (*func)(int state)) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-346(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutMenuStateFunc(x1) __glutMenuStateFunc((x1))

 void __glutSpecialFunc(void (*func)(int key, int x, int y)) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-352(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutSpecialFunc(x1) __glutSpecialFunc((x1))

 void __glutSpaceballMotionFunc(void (*func)(int x, int y, int z)) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-358(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutSpaceballMotionFunc(x1) __glutSpaceballMotionFunc((x1))

 void __glutSpaceballRotateFunc(void (*func)(int x, int y, int z)) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-364(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutSpaceballRotateFunc(x1) __glutSpaceballRotateFunc((x1))

 void __glutSpaceballButtonFunc(void (*func)(int button, int state)) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-370(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutSpaceballButtonFunc(x1) __glutSpaceballButtonFunc((x1))

 void __glutButtonBoxFunc(void (*func)(int button, int state)) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-376(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutButtonBoxFunc(x1) __glutButtonBoxFunc((x1))

 void __glutDialsFunc(void (*func)(int dial, int value)) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-382(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutDialsFunc(x1) __glutDialsFunc((x1))

 void __glutTabletMotionFunc(void (*func)(int x, int y)) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-388(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutTabletMotionFunc(x1) __glutTabletMotionFunc((x1))

 void __glutTabletButtonFunc(void (*func)(int button, int state, int x, int y)) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-394(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutTabletButtonFunc(x1) __glutTabletButtonFunc((x1))

 void __glutMenuStatusFunc(void (*func)(int status, int x, int y)) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-400(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutMenuStatusFunc(x1) __glutMenuStatusFunc((x1))

 void __glutOverlayDisplayFunc(void (*func)(void)) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-406(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutOverlayDisplayFunc(x1) __glutOverlayDisplayFunc((x1))

 void __glutWindowStatusFunc(void (*func)(int state)) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-412(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutWindowStatusFunc(x1) __glutWindowStatusFunc((x1))

 void __glutSetColor(int, GLfloat red, GLfloat green, GLfloat blue) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-418(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutSetColor(x1,x2,x3,x4) __glutSetColor((x1),(x2),(x3),(x4))

 GLfloat __glutGetColor(int ndx, int component) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-424(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutGetColor(x1,x2) __glutGetColor((x1),(x2))

 void __glutCopyColormap(int win) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-430(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutCopyColormap(x1) __glutCopyColormap((x1))

 int __glutGet(GLenum type) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-436(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutGet(x1) __glutGet((x1))

 int __glutDeviceGet(GLenum type) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-442(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutDeviceGet(x1) __glutDeviceGet((x1))

 int __glutExtensionSupported(const char *name) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-448(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutExtensionSupported(x1) __glutExtensionSupported((x1))

 int __glutGetModifiers(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-454(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutGetModifiers() __glutGetModifiers()

 int __glutLayerGet(GLenum type) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-460(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutLayerGet(x1) __glutLayerGet((x1))

 void __glutBitmapCharacter(void *font, int character) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-466(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutBitmapCharacter(x1,x2) __glutBitmapCharacter((x1),(x2))

 int __glutBitmapWidth(void *font, int character) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-472(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutBitmapWidth(x1,x2) __glutBitmapWidth((x1),(x2))

 void __glutStrokeCharacter(void *font, int character) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-478(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutStrokeCharacter(x1,x2) __glutStrokeCharacter((x1),(x2))

 int __glutStrokeWidth(void *font, int character) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-484(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutStrokeWidth(x1,x2) __glutStrokeWidth((x1),(x2))

 int __glutBitmapLength(void *font, const unsigned char *string) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-490(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutBitmapLength(x1,x2) __glutBitmapLength((x1),(x2))

 int __glutStrokeLength(void *font, const unsigned char *string) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-496(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutStrokeLength(x1,x2) __glutStrokeLength((x1),(x2))

 void __glutWireSphere(GLdouble radius, GLint slices, GLint stacks) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-502(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutWireSphere(x1,x2,x3) __glutWireSphere((x1),(x2),(x3))

 void __glutSolidSphere(GLdouble radius, GLint slices, GLint stacks) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-508(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutSolidSphere(x1,x2,x3) __glutSolidSphere((x1),(x2),(x3))

 void __glutWireCone(GLdouble base, GLdouble height, GLint slices, GLint stacks) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-514(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutWireCone(x1,x2,x3,x4) __glutWireCone((x1),(x2),(x3),(x4))

 void __glutSolidCone(GLdouble base, GLdouble height, GLint slices, GLint stacks) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-520(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutSolidCone(x1,x2,x3,x4) __glutSolidCone((x1),(x2),(x3),(x4))

 void __glutWireCube(GLdouble size) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-526(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutWireCube(x1) __glutWireCube((x1))

 void __glutSolidCube(GLdouble size) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-532(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutSolidCube(x1) __glutSolidCube((x1))

 void __glutWireTorus(GLdouble innerRadius, GLdouble outerRadius, GLint sides, GLint rings) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-538(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutWireTorus(x1,x2,x3,x4) __glutWireTorus((x1),(x2),(x3),(x4))

 void __glutSolidTorus(GLdouble innerRadius, GLdouble outerRadius, GLint sides, GLint rings) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-544(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutSolidTorus(x1,x2,x3,x4) __glutSolidTorus((x1),(x2),(x3),(x4))

 void __glutWireDodecahedron(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-550(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutWireDodecahedron() __glutWireDodecahedron()

 void __glutSolidDodecahedron(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-556(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutSolidDodecahedron() __glutSolidDodecahedron()

 void __glutWireTeapot(GLdouble size) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-562(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutWireTeapot(x1) __glutWireTeapot((x1))

 void __glutSolidTeapot(GLdouble size) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-568(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutSolidTeapot(x1) __glutSolidTeapot((x1))

 void __glutWireOctahedron(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-574(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutWireOctahedron() __glutWireOctahedron()

 void __glutSolidOctahedron(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-580(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutSolidOctahedron() __glutSolidOctahedron()

 void __glutWireTetrahedron(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-586(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutWireTetrahedron() __glutWireTetrahedron()

 void __glutSolidTetrahedron(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-592(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutSolidTetrahedron() __glutSolidTetrahedron()

 void __glutWireIcosahedron(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-598(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutWireIcosahedron() __glutWireIcosahedron()

 void __glutSolidIcosahedron(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-604(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutSolidIcosahedron() __glutSolidIcosahedron()

 int __glutVideoResizeGet(GLenum param) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-610(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutVideoResizeGet(x1) __glutVideoResizeGet((x1))

 void __glutSetupVideoResizing(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-616(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutSetupVideoResizing() __glutSetupVideoResizing()

 void __glutStopVideoResizing(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-622(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutStopVideoResizing() __glutStopVideoResizing()

 void __glutVideoResize(int x, int y, int width, int height) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-628(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutVideoResize(x1,x2,x3,x4) __glutVideoResize((x1),(x2),(x3),(x4))

 void __glutVideoPan(int x, int y, int width, int height) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-634(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutVideoPan(x1,x2,x3,x4) __glutVideoPan((x1),(x2),(x3),(x4))

 void __glutReportErrors(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-640(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutReportErrors() __glutReportErrors()

 void __glutKeyboardUpFunc(void (*func)(unsigned char key, int x, int y)) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-646(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutKeyboardUpFunc(x1) __glutKeyboardUpFunc((x1))

 void __glutSpecialUpFunc(void (*func)(int key, int x, int y)) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-652(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutSpecialUpFunc(x1) __glutSpecialUpFunc((x1))

 void __glutJoystickFunc(void (*func)(unsigned int buttonMask, int x, int y, int z), int pollInterval) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-658(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutJoystickFunc(x1,x2) __glutJoystickFunc((x1),(x2))

 void __glutIgnoreKeyRepeat(int ignore) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-664(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutIgnoreKeyRepeat(x1) __glutIgnoreKeyRepeat((x1))

 void __glutSetKeyRepeat(int repeatMode) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-670(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutSetKeyRepeat(x1) __glutSetKeyRepeat((x1))

 void __glutForceJoystickFunc(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-676(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutForceJoystickFunc() __glutForceJoystickFunc()

 int __glutEnterGameMode(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-682(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutEnterGameMode() __glutEnterGameMode()

 void __glutLeaveGameMode(void) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-688(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutLeaveGameMode() __glutLeaveGameMode()

 int __glutGameModeGet(GLenum mode) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-694(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutGameModeGet(x1) __glutGameModeGet((x1))

 void __glutGameModeString(const char *string) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-700(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutGameModeString(x1) __glutGameModeString((x1))

 void __glutPostWindowRedisplay(int win) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-706(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutPostWindowRedisplay(x1) __glutPostWindowRedisplay((x1))

 void __glutPostWindowOverlayRedisplay(int win) = "\tstw\tr2,20(r1)\n\t.extern\t_glutppcBase\n\tlwz\tr2,_glutppcBase(r2)\n\tlwz\tr0,-712(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glutPostWindowOverlayRedisplay(x1) __glutPostWindowOverlayRedisplay((x1))

