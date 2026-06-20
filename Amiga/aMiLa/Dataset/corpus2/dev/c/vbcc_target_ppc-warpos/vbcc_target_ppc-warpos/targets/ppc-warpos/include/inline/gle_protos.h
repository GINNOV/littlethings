 int __gleGetJoinStyle (void) = "\tstw\tr2,20(r1)\n\t.extern\t_gleppcBase\n\tlwz\tr2,_gleppcBase(r2)\n\tlwz\tr0,-34(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gleGetJoinStyle() __gleGetJoinStyle()

 void __gleSetJoinStyle (int style) = "\tstw\tr2,20(r1)\n\t.extern\t_gleppcBase\n\tlwz\tr2,_gleppcBase(r2)\n\tlwz\tr0,-40(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gleSetJoinStyle(x1) __gleSetJoinStyle((x1))

 int __gleGetNumSlices(void) = "\tstw\tr2,20(r1)\n\t.extern\t_gleppcBase\n\tlwz\tr2,_gleppcBase(r2)\n\tlwz\tr0,-46(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gleGetNumSlices() __gleGetNumSlices()

 void __gleSetNumSlices(int slices) = "\tstw\tr2,20(r1)\n\t.extern\t_gleppcBase\n\tlwz\tr2,_gleppcBase(r2)\n\tlwz\tr0,-52(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gleSetNumSlices(x1) __gleSetNumSlices((x1))

 void __glePolyCylinder (int npoints,
 double point_array[][3],
                   float color_array[][3],
 double radius) = "\tstw\tr2,20(r1)\n\t.extern\t_gleppcBase\n\tlwz\tr2,_gleppcBase(r2)\n\tlwz\tr0,-58(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glePolyCylinder(x1,x2,x3,x4) __glePolyCylinder((x1),(x2),(x3),(x4))

 void __glePolyCone (int npoints,
 double point_array[][3],
                   float color_array[][3],
 double radius_array[]) = "\tstw\tr2,20(r1)\n\t.extern\t_gleppcBase\n\tlwz\tr2,_gleppcBase(r2)\n\tlwz\tr0,-64(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define glePolyCone(x1,x2,x3,x4) __glePolyCone((x1),(x2),(x3),(x4))

 void __gleExtrusion (int ncp,
 double contour[][2],
 double cont_normal[][2],
 double up[3],
                int npoints,
 double point_array[][3],
                float color_array[][3]) = "\tstw\tr2,20(r1)\n\t.extern\t_gleppcBase\n\tlwz\tr2,_gleppcBase(r2)\n\tlwz\tr0,-70(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gleExtrusion(x1,x2,x3,x4,x5,x6,x7) __gleExtrusion((x1),(x2),(x3),(x4),(x5),(x6),(x7))

 void __gleTwistExtrusion (int ncp,
 double contour[][2],
 double cont_normal[][2],
 double up[3],
                int npoints,
 double point_array[][3],
                float color_array[][3],
 double twist_array[]) = "\tstw\tr2,20(r1)\n\t.extern\t_gleppcBase\n\tlwz\tr2,_gleppcBase(r2)\n\tlwz\tr0,-76(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gleTwistExtrusion(x1,x2,x3,x4,x5,x6,x7,x8) __gleTwistExtrusion((x1),(x2),(x3),(x4),(x5),(x6),(x7),(x8))

 void __gleSuperExtrusion (int ncp,
 double contour[][2],
 double cont_normal[][2],
 double up[3],
                int npoints,
 double point_array[][3],
                float color_array[][3],
 double xform_array[][2][3]) = "\tstw\tr2,20(r1)\n\t.extern\t_gleppcBase\n\tlwz\tr2,_gleppcBase(r2)\n\tlwz\tr0,-82(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gleSuperExtrusion(x1,x2,x3,x4,x5,x6,x7,x8) __gleSuperExtrusion((x1),(x2),(x3),(x4),(x5),(x6),(x7),(x8))

 void __gleSpiral (int ncp,
 double contour[][2],
 double cont_normal[][2],
 double up[3],
 double startRadius,
 double drdTheta,
 double startZ,
 double dzdTheta,
 double startXform[2][3],
 double dXformdTheta[2][3],
 double startTheta,
 double sweepTheta) = "\tstw\tr2,20(r1)\n\t.extern\t_gleppcBase\n\tlwz\tr2,_gleppcBase(r2)\n\tlwz\tr0,-88(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gleSpiral(x1,x2,x3,x4,x5,x6,x7,x8,x9,xa,xb,xc) __gleSpiral((x1),(x2),(x3),(x4),(x5),(x6),(x7),(x8),(x9),(xa),(xb),(xc))

 void __gleLathe (int ncp,
 double contour[][2],
 double cont_normal[][2],
 double up[3],
 double startRadius,
 double drdTheta,
 double startZ,
 double dzdTheta,
 double startXform[2][3],
 double dXformdTheta[2][3],
 double startTheta,
 double sweepTheta) = "\tstw\tr2,20(r1)\n\t.extern\t_gleppcBase\n\tlwz\tr2,_gleppcBase(r2)\n\tlwz\tr0,-94(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gleLathe(x1,x2,x3,x4,x5,x6,x7,x8,x9,xa,xb,xc) __gleLathe((x1),(x2),(x3),(x4),(x5),(x6),(x7),(x8),(x9),(xa),(xb),(xc))

 void __gleHelicoid (double rToroid,
 double startRadius,
 double drdTheta,
 double startZ,
 double dzdTheta,
 double startXform[2][3],
 double dXformdTheta[2][3],
 double startTheta,
 double sweepTheta) = "\tstw\tr2,20(r1)\n\t.extern\t_gleppcBase\n\tlwz\tr2,_gleppcBase(r2)\n\tlwz\tr0,-100(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gleHelicoid(x1,x2,x3,x4,x5,x6,x7,x8,x9) __gleHelicoid((x1),(x2),(x3),(x4),(x5),(x6),(x7),(x8),(x9))

 void __gleToroid (double rToroid,
 double startRadius,
 double drdTheta,
 double startZ,
 double dzdTheta,
 double startXform[2][3],
 double dXformdTheta[2][3],
 double startTheta,
 double sweepTheta) = "\tstw\tr2,20(r1)\n\t.extern\t_gleppcBase\n\tlwz\tr2,_gleppcBase(r2)\n\tlwz\tr0,-106(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gleToroid(x1,x2,x3,x4,x5,x6,x7,x8,x9) __gleToroid((x1),(x2),(x3),(x4),(x5),(x6),(x7),(x8),(x9))

 void __gleScrew (int ncp,
 double contour[][2],
 double cont_normal[][2],
 double up[3],
 double startz,
 double endz,
 double twist) = "\tstw\tr2,20(r1)\n\t.extern\t_gleppcBase\n\tlwz\tr2,_gleppcBase(r2)\n\tlwz\tr0,-112(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gleScrew(x1,x2,x3,x4,x5,x6,x7) __gleScrew((x1),(x2),(x3),(x4),(x5),(x6),(x7))

 void __gleTextureMode (int mode) = "\tstw\tr2,20(r1)\n\t.extern\t_gleppcBase\n\tlwz\tr2,_gleppcBase(r2)\n\tlwz\tr0,-118(r2)\n\tmtlr\tr0\n\tblrl\n\tlwz\tr2,20(r1)";
#define gleTextureMode(x1) __gleTextureMode((x1))

