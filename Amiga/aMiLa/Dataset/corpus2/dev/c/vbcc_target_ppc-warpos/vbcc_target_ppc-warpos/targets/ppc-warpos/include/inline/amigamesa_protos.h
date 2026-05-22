struct amigamesa_context __saveds *__AmigaMesaCreateContext(struct TagItem *tagList ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-34(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define AmigaMesaCreateContext(x1) __AmigaMesaCreateContext((x1))

void __saveds __AmigaMesaDestroyContext(struct amigamesa_context *c ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-40(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define AmigaMesaDestroyContext(x1) __AmigaMesaDestroyContext((x1))

struct amigamesa_visual __saveds *__AmigaMesaCreateVisual(struct TagItem *tagList) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-46(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define AmigaMesaCreateVisual(x1) __AmigaMesaCreateVisual((x1))

void __saveds __AmigaMesaDestroyVisual(struct amigamesa_visual *v ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-52(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define AmigaMesaDestroyVisual(x1) __AmigaMesaDestroyVisual((x1))

void __saveds __AmigaMesaMakeCurrent(struct amigamesa_context *c ,struct amigamesa_buffer *b) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-58(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define AmigaMesaMakeCurrent(x1,x2) __AmigaMesaMakeCurrent((x1),(x2))

void __saveds __AmigaMesaSwapBuffers(struct amigamesa_context *amesa) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-64(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define AmigaMesaSwapBuffers(x1) __AmigaMesaSwapBuffers((x1))

void __saveds __AmigaMesaSetOneColor(struct amigamesa_context *c,int index,float r,float g,float b) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-70(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define AmigaMesaSetOneColor(x1,x2,x3,x4,x5) __AmigaMesaSetOneColor((x1),(x2),(x3),(x4),(x5))

void __saveds __AmigaMesaSetRast(struct amigamesa_context *c, struct TagItem *tagList ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-76(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define AmigaMesaSetRast(x1,x2) __AmigaMesaSetRast((x1),(x2))

void __saveds __AmigaMesaGetConfig(struct amigamesa_visual *v, GLenum pname, GLint* params ) = "\tstw\tr2,20(r1)\n\t.extern\t_glppcBase\n\tlwz\tr2,_glppcBase(r2)\n\tlwz\tr0,-82(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define AmigaMesaGetConfig(x1,x2,x3) __AmigaMesaGetConfig((x1),(x2),(x3))

