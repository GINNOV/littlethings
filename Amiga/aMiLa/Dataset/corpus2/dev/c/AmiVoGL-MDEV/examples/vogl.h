/* vogl.h: */
#include <stdio.h>
#include <math.h>
#include <stdlib.h>

#ifdef AZTEC_C
# ifndef AMIGA
#  define AMIGA
# endif
#else
# ifdef AMIGA
#  ifndef AZTEC_C
#   define AZTEC_C
#  endif
# endif
#endif

#if defined(PC) || defined(AMIGA) || defined(AZTEC_C)
#include <string.h>
#else
#include <strings.h>
#endif

#ifdef PC	/* Stupid pox head crap */
char	*vallocate();
char	*malloc();
#endif

#if defined(AMIGA) || defined(sgi)
# ifndef __PROTOTYPE__
#  define __PROTOTYPE__
# endif
#include "hershey.h"
#endif

/*
 * VOGL is always defined if a header file is from the 
 * VOGL library. In cases where you do use some VOGL
 * initialisation routines like vinit, just put #ifdef VOGL...
 * around.
 */
#ifndef VOGL
#define	VOGL
#endif

#ifndef TRUE
#define	TRUE	1
#endif

#ifndef FALSE
#define	FALSE	0
#endif

/*
 * Misc defines...
 */
#define	FLAT	0
#define SMOOTH	1
#define GD_XPMAX 1
#define GD_YPMAX 2

/*
 * standard colour indices
 */
#define	BLACK		0
#define	RED		1
#define	GREEN		2
#define	YELLOW		3
#define	BLUE		4
#define	MAGENTA		5
#define	CYAN		6
#define	WHITE		7

/*
 * when (if ever) we need the precision
 */
#ifdef DOUBLE
#define	float	double
#endif

/*
 * How to convert degrees to radians
 */
#define	PI	3.14159265358979
#define D2R	(PI / 180.0)

/*
 * miscellaneous typedefs and type defines
 */
typedef float	Vector[4];
typedef float	Matrix[4][4];
typedef float	Tensor[4][4][4];
typedef short	Angle;
typedef float	Coord;
typedef long	Icoord;
typedef short	Scoord;
// typedef long	Object;
typedef short	Screencoord;
typedef long	Boolean;

typedef unsigned short	Device;

typedef unsigned short	Colorindex;


/*
 * when register variables get us into trouble
 */
#ifdef NOREGISTER
#define	register
#endif

/*
 * max number of vertices in a ploygon
 */
#define	MAXVERTS	128

/*
 * object definitions
 */
#define MAXENTS		101		/* size of object table */
#define	MAXTOKS		100		/* num. of tokens alloced at once in
					   an object  */

/*
 * Polygon fill modes for "polymode"
 */
#define PYM_POINT	0
#define PYM_LINE	0
#define PYM_FILL	1
#define PYM_HOLLOW	1

/*
 * functions which can appear in objects
 */
#define	ARC		1
#define	CALLOBJ		3
#define	CIRCLE		5
#define	CLEAR		6
#define	COLOR		7
#define	DRAW		8
#define	DRAWSTR		10
#define	FONT		12
#define	LOADMATRIX	15
#define	MAPCOLOR	16
#define	MOVE		17
#define	MULTMATRIX	18
#define	POLY		19
#define	POPATTRIBUTES	22
#define	POPMATRIX	23
#define	POPVIEWPORT	24
#define	PUSHATTRIBUTES	25
#define	PUSHMATRIX	26
#define	PUSHVIEWPORT	27
#define	RCURVE		28
#define	RPATCH		29
#define	SECTOR		30
#define	VIEWPORT	33
#define	BACKBUFFER	34
#define	FRONTBUFFER	35
#define	SWAPBUFFERS	36
#define	BACKFACING	37
#define	TRANSLATE	38
#define	ROTATE		39
#define	SCALE		40

#define	ARCF		41
#define	CIRCF		42
#define	POLYF		43
#define	RECTF		44

#define	CMOV		45

/*
 * States for bgn* and end* calls
 */
#define	NONE		0	/* Just set current spot */
#define	VPNT		1	/* Draw dots		 */
#define	VLINE		2	/* Draw lines		 */
#define	VCLINE		3	/* Draw closed lines	 */
#define	VPOLY		4	/* Draw a polygon 	 */

/*
 * data types for object tokens
 */
typedef union tk {
	char    *s;
	int      i;
	float    f;
	} Token;

typedef struct tls {
	int         count;
	Token      *toks;
	struct tls *next;
	} TokList;

/*
 * double buffering modes.
 */
#define	SINGLEBUF		1

/*
 * attributes
 */
typedef struct {
	char    backface,
		mode;			/* Which mode are we in */
	int     color;
	float   fontheight;
	float   fontwidth;
	int	fontnum;
	} Attribute;

/*
 * viewport
 */
typedef struct vp {
	float	left;
	float	right;
	float	bottom;
	float	top;
	} Viewport; 

/*
 * stacks
 */
typedef	struct	ms {	/* Matrix stack entries	*/
	Matrix		m;
	struct	ms	*back;
	} Mstack;

typedef	struct	as {	/* Attribute stack entries */
	Attribute	a;
	struct	as	*back;
	} Astack;

typedef	struct	vs {	/* Viewport stack entries */
	Viewport	v;
	struct	vs	*back;
	} Vstack;

/*
 * vogle device structures
 */

#ifdef AMIGA
typedef struct dev {
	char	*devname;				/* name of device						*/
	char	*large,					/* name of large font					*/
		*small;						/* name of small font					*/
	int	(*Vbackb)(void),			/* Set drawing in back buffer			*/
		(*Vchar)(char),				/* Draw a hardware character			*/
		(*Vcheckkey)(void),			/* Ckeck if a key was hit				*/
		(*Vclear)(void),			/* Clear the screen to current color	*/
		(*Vcolor)(int),				/* Set current color					*/
		(*Vdraw)(int,int),			/* Draw a line							*/
		(*Vexit)(void),				/* Exit graphics						*/
		(*Vfill)(int,int[],int[]),	/* Fill a polygon						*/
		(*Vfont)(char *),			/* Set hardware font					*/
		(*Vfrontb)(void),			/* Set drawing in front buffer			*/
		(*Vgetkey)(void),			/* Wait for and get the next key hit	*/
		(*Vinit)(void),				/* Initialise the device				*/
		(*Vlocator)(int *,int*),	/* Get mouse/cross hair position		*/
		(*Vmapcolor)(int,int,int,int),/* Set color indicies					*/
		(*Vstring)(char *),			/* Draw a hardware string				*/
		(*Vswapb)(void);			/* Swap front and back buffers			*/
	} DevEntry;
#else
typedef struct dev {
	char	*devname;		/* name of device						*/
	char	*large,			/* name of large font					*/
		*small;				/* name of small font					*/
	int	(*Vbackb)(),		/* Set drawing in back buffer			*/
		(*Vchar)(),			/* Draw a hardware character			*/
		(*Vcheckkey)(),		/* Ckeck if a key was hit				*/
		(*Vclear)(),		/* Clear the screen to current color	*/
		(*Vcolor)(),		/* Set current color					*/
		(*Vdraw)(),			/* Draw a line							*/
		(*Vexit)(),			/* Exit graphics						*/
		(*Vfill)(),			/* Fill a polygon						*/
		(*Vfont)(),			/* Set hardware font					*/
		(*Vfrontb)(),		/* Set drawing in front buffer			*/
		(*Vgetkey)(),		/* Wait for and get the next key hit	*/
		(*Vinit)(),			/* Initialise the device				*/
		(*Vlocator)(),		/* Get mouse/cross hair position		*/
		(*Vmapcolor)(),		/* Set color indicies					*/
		(*Vstring)(),		/* Draw a hardware string				*/
		(*Vswapb)();		/* Swap front and back buffers			*/
	} DevEntry;
#endif

typedef struct vdev {
	char		initialised,
				clipoff,
				inobject,
				inpolygon,
				fill,			/* polygon filling						*/
				cpVvalid,		/* is the current device position valid */
				inbackbuffer,	/* are we in the backbuffer				*/
				clipplanes;		/* active clipping planes				*/
	void		(*pmove)(),		/* Polygon moves						*/
				(*pdraw)();		/* Polygon draws						*/
	TokList		*tokens;		/* ptr 2 list of tokens for current object */
	Mstack		*transmat;		/* top of transformation stack			*/
	Astack		*attr;			/* top of attribute stack				*/
	Vstack		*viewport;		/* top of viewport stack				*/
	float		hheight, hwidth;/* hardware character height, width		*/
	Vector		cpW,			/* current postion in world coords		*/
				cpWtrans,		/* current world coords transformed		*/
				upvector;		/* world up								*/
	int			depth,			/* # bit planes on screen				*/
				maxVx, minVx,
				maxVy, minVy,
				sizeX, sizeY, 	/* size of square on screen				*/
				sizeSx, sizeSy,	/* side in x, side in y (# pixels)		*/
				cpVx, cpVy;
	DevEntry	dev;
	float		savex,			/* Where we started for v*()			*/
				savey,
				savez;
	char		bgnmode;		/* What to do with v*() calls			*/
	char		save;			/* Do we save 1st v*() point			*/

	char		*wintitle;		/* window title							*/

	char		*devname;		/* pointer to device name				*/

	Matrix		tbasis, ubasis, *bases; /* Patch stuff					*/
	
	char		*enabled;		/* pointer to enabled devices mask		*/
	int			maxfontnum;

	char		alreadyread;	/* queue device stuff					*/
	char		kbdmode;		/* are we in keyboard mode				*/
	char		mouseevents;	/* are mouse events enabled				*/
	char		kbdevents;		/* are kbd events enabled				*/
	int			devno, data;

	int			concave;		/* concave polygons?					*/

	} VDevice;

extern VDevice	vdevice;		/* device structure						*/

#define	V_X	0			/* x axis in cpW */
#define	V_Y	1			/* y axis in cpW */
#define	V_Z	2			/* z axis in cpW */
#define	V_W	3			/* w axis in cpW */

#ifdef __PROTOTYPE__

void arcprecision(int);                                /* arcs.c          */
void circleprecision(int);                             /* arcs.c          */
void arc( Coord, Coord, Coord, Angle, Angle);          /* arcs.c          */
void arcs( Scoord, Scoord, Scoord, Angle, Angle);      /* arcs.c          */
void arci( Icoord, Icoord, Icoord, Angle, Angle);      /* arcs.c          */
void arcf( Coord, Coord, Coord, Angle, Angle);         /* arcs.c          */
void arcfs( Scoord, Scoord, Scoord, Angle, Angle);     /* arcs.c          */
void arcfi( Icoord, Icoord, Icoord, Angle, Angle);     /* arcs.c          */
void circ( Coord, Coord, Coord);                       /* arcs.c          */
void circs( Scoord, Scoord, Scoord);                   /* arcs.c          */
void circi( Icoord, Icoord, Icoord);                   /* arcs.c          */
void circf( Coord, Coord, Coord);                      /* arcs.c          */
void circfs( Scoord, Scoord, Scoord);                  /* arcs.c          */
void circfi( Icoord, Icoord, Icoord);                  /* arcs.c          */
void pushattributes(void);                             /* attr.c          */
void popattributes(void);                              /* attr.c          */
int printattribs(char *);                              /* attr.c          */
void backbuffer(int);                                  /* buffer.c        */
void frontbuffer(int);                                 /* buffer.c        */
void swapbuffers(void);                                /* buffer.c        */
void doublebuffer(void);                               /* buffer.c        */
void singlebuffer(void);                               /* buffer.c        */
void clip( register Vector, register Vector);          /* clip.c          */
int MakeEdgeCoords( int, Vector);                      /* clip.c          */
void quickclip( register Vector, register Vector);     /* clip.c          */
void curvebasis(short);                                /* curves.c        */
void curveprecision(short);                            /* curves.c        */
void rcrv(Coord[4][4]);                                /* curves.c        */
void crv(Coord[4][3]);                                 /* curves.c        */
void drcurve( int, Matrix);                            /* curves.c        */
void crvn( long, Coord[][3]);                          /* curves.c        */
void rcrvn( long, Coord[][4]);                         /* curves.c        */
void curveit(short);                                   /* curves.c        */
void draw( float, float, float);                       /* draw.c          */
void draws( Scoord, Scoord, Scoord);                   /* draw.c          */
void drawi( Icoord, Icoord, Icoord);                   /* draw.c          */
void draw2( float, float);                             /* draw.c          */
void draw2s( Scoord, Scoord);                          /* draw.c          */
void draw2i( Icoord, Icoord);                          /* draw.c          */
void rdr( float, float, float);                        /* draw.c          */
void rdrs( Scoord, Scoord, Scoord);                    /* draw.c          */
void rdri( Icoord, Icoord, Icoord);                    /* draw.c          */
void rdr2( float, float);                              /* draw.c          */
void rdr2s( Scoord, Scoord);                           /* draw.c          */
void rdr2i( Icoord, Icoord);                           /* draw.c          */
void bgnline(void);                                    /* draw.c          */
void endline(void);                                    /* draw.c          */
void bgnclosedline(void);                              /* draw.c          */
void endclosedline(void);                              /* draw.c          */
void voutput(char *);                                  /* drivers.c       */
FILE * _voutfile(void);                                /* drivers.c       */
void verror(char *);                                   /* drivers.c       */
void gexit(void);                                      /* drivers.c       */
void vinit(char *);                                    /* drivers.c       */
long winopen(char *);                                  /* drivers.c       */
void ginit(void);                                      /* drivers.c       */
void gconfig(void);                                    /* drivers.c       */
void vnewdev(char *);                                  /* drivers.c       */
char * vgetdev(char *);                                /* drivers.c       */
long getvaluator(Device);                              /* drivers.c       */
Boolean getbutton(Device);                             /* drivers.c       */
void clear(void);                                      /* drivers.c       */
void colorf(float);                                    /* drivers.c       */
void color(int);                                       /* drivers.c       */
void mapcolor( Colorindex, short, short, short);       /* drivers.c       */
long getplanes(void);                                  /* drivers.c       */
void reshapeviewport(void);                            /* drivers.c       */
void winconstraints(void);                             /* drivers.c       */
void keepaspect(void);                                 /* drivers.c       */
void shademodel(long);                                 /* drivers.c       */
long getgdesc(long);                                   /* drivers.c       */
void getgp( Coord *, Coord *, Coord *);                /* getgp.c         */
void getgpos( Coord *, Coord *, Coord *, Coord *);     /* getgp.c         */
void VtoWxy( float, float, float *, float *);          /* mapping.c       */
void _mapmsave(Matrix);                                /* mapping.c       */
void CalcW2Vcoeffs(void);                              /* mapping.c       */
int WtoVx(float[]);                                    /* mapping.c       */
int WtoVy(float[]);                                    /* mapping.c       */
void copyvector( register Vector, register Vector);    /* matrix.c        */
void copymatrix( register Matrix, register Matrix);    /* matrix.c        */
void copytranspose( register Matrix,                   /* matrix.c        */
   register Matrix);
void getmatrix(Matrix);                                /* matrix.c        */
void pushmatrix(void);                                 /* matrix.c        */
void popmatrix(void);                                  /* matrix.c        */
void loadmatrix(Matrix);                               /* matrix.c        */
void mult4x4( register Matrix, register Matrix,        /* matrix.c        */
   register Matrix);
void multmatrix(Matrix);                               /* matrix.c        */
void identmatrix(Matrix);                              /* matrix.c        */
void multvector( register Vector, register Vector,     /* matrix.c        */
   register Matrix);
void premultvector( Vector, Vector, Matrix);           /* matrix.c        */
int printmat( char *, Matrix);                         /* matrix.c        */
int printvect( char *, Vector);                        /* matrix.c        */
void move( Coord, Coord, Coord);                       /* move.c          */
void moves( Scoord, Scoord, Scoord);                   /* move.c          */
void movei( Icoord, Icoord, Icoord);                   /* move.c          */
void move2( Coord, Coord);                             /* move.c          */
void move2s( Scoord, Scoord);                          /* move.c          */
void move2i( Icoord, Icoord);                          /* move.c          */
void rmv( Coord, Coord, Coord);                        /* move.c          */
void rmvs( Scoord, Scoord, Scoord);                    /* move.c          */
void rmvi( Icoord, Icoord, Icoord);                    /* move.c          */
void rmv2( float, float);                              /* move.c          */
void rmv2s( Scoord, Scoord);                           /* move.c          */
void rmv2i( Icoord, Icoord);                           /* move.c          */
Token * newtokens(int);                                /* newtoken.c      */
Token * newtokens(int);                                /* newtokens.c     */
void makeobj(long);                                    /* objects.c       */
void closeobj(void);                                   /* objects.c       */
void delobj(long);                                     /* objects.c       */
long genobj(void);                                     /* objects.c       */
long getopenobj(void);                                 /* objects.c       */
void callobj(long);                                    /* objects.c       */
Boolean isobj(long);                                   /* objects.c       */
void defbasis( short, Matrix);                         /* patches.c       */
void patchbasis( long, long);                          /* patches.c       */
void patchcurves( long, long);                         /* patches.c       */
void patchprecision( long, long);                      /* patches.c       */
void patch( Matrix, Matrix, Matrix);                   /* patches.c       */
void rpatch( Matrix, Matrix, Matrix, Matrix);          /* patches.c       */
void transformtensor( Tensor, Matrix);                 /* patches.c       */
void drpatch( Tensor, int, int, int, int, int, int);   /* patches.c       */
void pnt( float, float, float);                        /* points.c        */
void pnts( Scoord, Scoord, int);                       /* points.c        */
void pnti( Icoord, Icoord, Icoord);                    /* points.c        */
void pnt2( Coord, Coord);                              /* points.c        */
void pnt2s( Scoord, Scoord);                           /* points.c        */
void pnt2i( Icoord, Icoord);                           /* points.c        */
void bgnpoint(void);                                   /* points.c        */
void endpoint(void);                                   /* points.c        */
void concave(Boolean);                                 /* polygons.c      */
void backface(int);                                    /* polygons.c      */
void frontface(int);                                   /* polygons.c      */
void polymode(long);                                   /* polygons.c      */
void polyobj( int, Token[], int);                      /* polygons.c      */
void poly2( long, float[][2]);                         /* polygons.c      */
void poly2i( long, Icoord[][2]);                       /* polygons.c      */
void poly2s( long, Scoord[][2]);                       /* polygons.c      */
void polyi( long, Icoord[][3]);                        /* polygons.c      */
void polys( long, Scoord[][3]);                        /* polygons.c      */
void polf2( long, float[][2]);                         /* polygons.c      */
void polf2i( long, Icoord[][2]);                       /* polygons.c      */
void polf2s( long, Scoord[][2]);                       /* polygons.c      */
void polfi( long, Icoord[][3]);                        /* polygons.c      */
void polfs( long, Scoord[][3]);                        /* polygons.c      */
void poly( long, float[][3]);                          /* polygons.c      */
void polf( long, float[][3]);                          /* polygons.c      */
void pmv( float, float, float);                        /* polygons.c      */
void pmvi( Icoord, Icoord, Icoord);                    /* polygons.c      */
void pmv2i( Icoord, Icoord);                           /* polygons.c      */
void pmvs( Scoord, Scoord, Scoord);                    /* polygons.c      */
void pmv2s( Scoord, Scoord);                           /* polygons.c      */
void pmv2( float, float);                              /* polygons.c      */
void pdr( Coord, Coord, Coord);                        /* polygons.c      */
void rpdr( Coord, Coord, Coord);                       /* polygons.c      */
void rpdr2( Coord, Coord);                             /* polygons.c      */
void rpdri( Icoord, Icoord, Icoord);                   /* polygons.c      */
void rpdr2i( Icoord, Icoord);                          /* polygons.c      */
void rpdrs( Scoord, Scoord, Scoord);                   /* polygons.c      */
void rpdr2s( Scoord, Scoord);                          /* polygons.c      */
void rpmv( Coord, Coord, Coord);                       /* polygons.c      */
void rpmv2( Coord, Coord);                             /* polygons.c      */
void rpmvi( Icoord, Icoord, Icoord);                   /* polygons.c      */
void rpmv2i( Icoord, Icoord);                          /* polygons.c      */
void rpmvs( Scoord, Scoord, Scoord);                   /* polygons.c      */
void rpmv2s( Scoord, Scoord);                          /* polygons.c      */
void pdri( Icoord, Icoord, Icoord);                    /* polygons.c      */
void pdr2i( Icoord, Icoord);                           /* polygons.c      */
void pdrs( Scoord, Scoord);                            /* polygons.c      */
void pdr2s( Scoord, Scoord);                           /* polygons.c      */
void pdr2( float, float);                              /* polygons.c      */
void pclos(void);                                      /* polygons.c      */
void bgnpolygon(void);                                 /* polygons.c      */
void endpolygon(void);                                 /* polygons.c      */
void prefposition( long, long, long, long);            /* pref.c          */
void prefsize( long, long);                            /* pref.c          */
void getprefposandsize( int *, int *, int *, int *);   /* pref.c          */
void qdevice(Device);                                  /* queue.c         */
void unqdevice(Device);                                /* queue.c         */
long qread(short *);                                   /* queue.c         */
void qreset(void);                                     /* queue.c         */
long qtest(void);                                      /* queue.c         */
Boolean isqueued(Device);                              /* queue.c         */
void qenter( Device, short);                           /* queue.c         */
void rect( Coord, Coord, Coord, Coord);                /* rect.c          */
void recti( Icoord, Icoord, Icoord, Icoord);           /* rect.c          */
void rects( Scoord, Scoord, Scoord, Scoord);           /* rect.c          */
void rectf( Coord, Coord, Coord, Coord);               /* rect.c          */
void rectfi( Icoord, Icoord, Icoord, Icoord);          /* rect.c          */
void rectfs( Scoord, Scoord, Scoord, Scoord);          /* rect.c          */
void scale( float, float, float);                      /* scale.c         */
void premulttensor( Tensor, Matrix, Tensor);           /* tensor.c        */
void multtensor( Tensor, Matrix, Tensor);              /* tensor.c        */
void copytensor( Tensor, Tensor);                      /* tensor.c        */
void copytensortrans( Tensor, Tensor);                 /* tensor.c        */
void font(short);                                      /* text.c          */
void charstr(char *);                                  /* text.c          */
void cmov( float, float, float);                       /* text.c          */
void cmov2( float, float);                             /* text.c          */
void cmovi( Icoord, Icoord, Icoord);                   /* text.c          */
void cmovs( Scoord, Scoord, Scoord);                   /* text.c          */
void cmov2i( Icoord, Icoord);                          /* text.c          */
void cmov2s( Scoord, Scoord);                          /* text.c          */
long getwidth(void);                                   /* text.c          */
long getheight(void);                                  /* text.c          */
void translate( float, float, float);                  /* trans.c         */
void rot( float, char);                                /* trans.c         */
void rotate( Angle, char);                             /* trans.c         */
char * vallocate(unsigned);                            /* valloc.c        */
void vcall( float[], int);                             /* vcalls.c        */
void v4f(float[4]);                                    /* vcalls.c        */
void v3f(float[3]);                                    /* vcalls.c        */
void v2f(float[2]);                                    /* vcalls.c        */
void v4d(double[4]);                                   /* vcalls.c        */
void v3d(double[3]);                                   /* vcalls.c        */
void v2d(long[2]);                                     /* vcalls.c        */
void v4i(long[4]);                                     /* vcalls.c        */
void v3i(long[3]);                                     /* vcalls.c        */
void v2i(long[2]);                                     /* vcalls.c        */
void v4s(short[4]);                                    /* vcalls.c        */
void v3s(short[3]);                                    /* vcalls.c        */
void v2s(short[2]);                                    /* vcalls.c        */
void polarview( Coord, Angle, Angle, Angle);           /* viewing.c       */
void lookat( Coord, Coord, Coord, Coord, Coord, Coord, /* viewing.c       */
   Angle);
void perspective( Angle, float, Coord, Coord);         /* viewing.c       */
void window( Coord, Coord, Coord, Coord, Coord,        /* viewing.c       */
   Coord);
void ortho( Coord, Coord, Coord, Coord, Coord,         /* viewing.c       */
   Coord);
void ortho2( Coord, Coord, Coord, Coord);              /* viewing.c       */
void pushviewport(void);                               /* viewp.c         */
void popviewport(void);                                /* viewp.c         */
void viewport( Screencoord, Screencoord, Screencoord,  /* viewp.c         */
   Screencoord);
void getviewport( Screencoord *, Screencoord *,        /* viewp.c         */
   Screencoord *, Screencoord *);
void yobbarays(int);                                   /* yobbarays.c     */

#else	/* __PROTOTYPE__ */

/*
 * function definitions
 */

/*
 * arc routines
 */
extern void	arcprecision();
extern void	circleprecision();
extern void	arc();
extern void	arcs();
extern void	arci();
extern void	arcf();
extern void	arcfs();
extern void	arcfi();
extern void	circ();
extern void	circs();
extern void	circi();
extern void	circf();
extern void	circfs();
extern void	circfi();

/*
 * attr routines
 */
extern void	popattributes();
extern void	pushattributes();

/*
 * curve routines
 */
extern void	curvebasis();
extern void	curveprecision();
extern void	rcrv();
extern void	crv();
extern void	crvn();
extern void	rcrvn();
extern void	curveit();

/*
 * draw routines
 */
extern void	draw();
extern void	draws();
extern void	drawi();
extern void	draw2();
extern void	draw2s();
extern void	draw2i();
extern void	rdr();
extern void	rdrs();
extern void	rdri();
extern void	rdr2();
extern void	rdr2s();
extern void	rdr2i();
extern void	bgnline();
extern void	endline();
extern void	bgnclosedline();
extern void	endclosedline();

/*
 * device routines
 */
extern void	qdevice();
extern void	unqdevice();
extern long	qread();
extern void	qreset();
extern long	qtest();
extern Boolean	isqueued();

extern void	gexit();
extern void	gconfig();
extern void	shademodel();
extern long	getgdesc();
extern long	winopen();
extern void	ginit();
extern void	gconfig();
extern long	getvaluator();
extern Boolean	getbutton();
extern void	clear();
extern void	colorf();
extern void	color();
extern void	mapcolor();
extern long	getplanes();

extern void	vinit();
extern void	voutput();
extern void	verror();
extern void	vnewdev();
extern char	*vgetdev();

/*
 * mapping routines
 */
extern int	WtoVx();
extern int	WtoVy();
extern void	VtoWxy();
extern void	CalcW2Vcoeffs();

/*
 * general matrix and vector routines
 */
extern void	mult4x4();
extern void	copymatrix();
extern void	identmatrix();
extern void	copytranspose();

extern void	multvector();
extern void	copyvector();
extern void	premultvector();

/*
 * matrix stack routines
 */
extern void	getmatrix();
extern void	popmatrix();
extern void	loadmatrix();
extern void	pushmatrix();
extern void	multmatrix();

/*
 * move routines
 */
extern void	move();
extern void	moves();
extern void	movei();
extern void	move2();
extern void	move2s();
extern void	move2i();
extern void	rmv();
extern void	rmvs();
extern void	rmvi();
extern void	rmv2();
extern void	rmv2s();
extern void	rmv2i();

/*
 * object routines
 */
extern Boolean	isobj();
extern long	genobj();
extern void	delobj();
extern void	makeobj();
extern void	callobj();
extern void	closeobj();
extern long	getopenobj();
extern Token	*newtokens();

/*
 * patch routines.
 */
extern void	defbasis();
extern void	patchbasis();
extern void	patchcurves();
extern void	patchprecision();
extern void	patch();
extern void	rpatch();

/*
 * point routines
 */
extern void	pnt();
extern void	pnts();
extern void	pnti();
extern void	pnt2();
extern void	pnt2s();
extern void	pnt2i();
extern void	bgnpoint();
extern void	endpoint();

/*
 * v routines
 */
extern void	v4f();
extern void	v3f();
extern void	v2f();
extern void	v4d();
extern void	v3d();
extern void	v2d();
extern void	v4i();
extern void	v3i();
extern void	v2i();
extern void	v4s();
extern void	v3s();
extern void	v2s();

/*
 * polygon routines.
 */
extern void	concave();
extern void	backface();
extern void	frontface();
extern void	polymode();
extern void	poly2();
extern void	poly2i();
extern void	poly2s();
extern void	polyi();
extern void	polys();
extern void	polf2();
extern void	polf2i();
extern void	polf2s();
extern void	polfi();
extern void	polfs();
extern void	poly();
extern void	polf();
extern void	pmv();
extern void	pmvi();
extern void	pmv2i();
extern void	pmvs();
extern void	pmv2s();
extern void	pmv2();
extern void	pdr();
extern void	rpdr();
extern void	rpdr2();
extern void	rpdri();
extern void	rpdr2i();
extern void	rpdrs();
extern void	rpdr2s();
extern void	rpmv();
extern void	rpmv2();
extern void	rpmvi();
extern void	rpmv2i();
extern void	rpmvs();
extern void	rpmv2s();
extern void	pdri();
extern void	pdr2i();
extern void	pdrs();
extern void	pdr2s();
extern void	pdr2();
extern void	pclos();
extern void	bgnpolygon();
extern void	endpolygon();

/*
 * rectangle routines
 */
extern void	rect();
extern void	recti();
extern void	rects();
extern void	rectf();
extern void	rectfi();
extern void	rectfs();

/*
 * tensor routines
 */
extern void multtensor();
extern void copytensor();
extern void premulttensor();
extern void copytensortrans();

/*
 * text routines
 */
extern void	font();
extern void	charstr();
extern void	cmov();
extern void	cmov2();
extern void	cmovi();
extern void	cmovs();
extern void	cmov2i();
extern void	cmov2s();
extern long	getwidth();
extern long	getheight();

/*
 * transformation routines
 */
extern void	scale();
extern void	translate();
extern void	rotate();
extern void	rot();

/*
 * window definition routines
 */
extern void	ortho();
extern void	ortho2();
extern void	lookat();
extern void	window();
extern void	polarview();
extern void	perspective();

/*
 * routines for manipulating the viewport
 */
extern void	viewport();
extern void	popviewport();
extern void	pushviewport();

/*
 * routines for retrieving the graphics position
 */
extern void	getgp();
extern void	getgpos();

/*
 * routines for handling the buffering
 */
extern void	backbuffer();
extern void	frontbuffer();
extern void	swapbuffers();
extern void	doublebuffer();

/*
 * routines for window sizing and positioning
 */
extern void	prefsize();
extern void	prefposition();
#endif

