#include <stdio.h>
#include "vogl.h"

/* --------------------------------------------------------------------- */

#ifdef AZTEC_C
#include <math.h>
#else
extern	double	cos();
extern	double	sin();
#endif

/* ---------------------------------------------------------------------
 * Definitions:
 */

#define MAX(x, y)	((x) > (y) ? (x) : (y))
#define MIN(x, y)	((x) < (y) ? (x) : (y))
#define ABS(x)		((x) < 0 ? -(x) : (x))

/* ---------------------------------------------------------------------
 * Local Variables:
 */
static float	F[6][4], S[6][4], I[4], p[MAXVERTS][4];
static int	nout, first[6], numv;
static long	polymodeflag = PYM_FILL;
static int	ip1[MAXVERTS], ip2[MAXVERTS];

/*
 *  Orientation of backfacing polygons(in screen coords)
 */
static	int	clockwise = 1;

/* ---------------------------------------------------------------------
 * Prototypes:
 */
#ifdef __PROTOTYPE__
 
static void dopoly(int);                               /* polygons.c      */
static void polyoutline( int, int[], int[]);           /* polygons.c      */
static int checkbacki(void);                           /* polygons.c      */
static void polyclip(register int);                    /* polygons.c      */
static void shclip( float[4], int);                    /* polygons.c      */
static void shclose(int);                              /* polygons.c      */
static intersect( int, register Vector,                /* polygons.c      */
   register Vector);
static visible(int);                                   /* polygons.c      */
 
#else	/* __PROTOTYPE__ */
 
static void dopoly();                                  /* polygons.c      */
static void polyoutline();                             /* polygons.c      */
static int checkbacki();                               /* polygons.c      */
static void polyclip();                                /* polygons.c      */
static void shclip();                                  /* polygons.c      */
static void shclose();                                 /* polygons.c      */
static intersect();                                    /* polygons.c      */
static visible();                                      /* polygons.c      */
 
#endif	/* __PROTOTYPE__ */

/*
 * concave
 *
 *	signal wether or not polygons are concave (not a lot of use at the moment).
 */
void concave(Boolean yesno)
{
vdevice.concave = yesno;
}

/* ------------------------------------------------------------------------ */

/*
 * backface
 *
 *	Turns on culling of backfacing polygons. A polygon is
 * backfacing if it's orientation in *screen* coords is clockwise.
 */
void backface(int onoff)
{
vdevice.attr->a.backface = onoff;
clockwise = 1;
}

/* ------------------------------------------------------------------------ */

/*
 * frontface
 *
 *	Turns on culling of frontfacing polygons. A polygon is
 * frontfacing if it's orientation in *screen* coords is anti-clockwise.
 */
void frontface(int onoff)
{
vdevice.attr->a.backface = onoff;
clockwise = 0;
}

/* ------------------------------------------------------------------------ */

/*
 * polymode
 *
 *	Sets the polygon filling mode - only filled or outlined supported
 */
void polymode(long mode)
{
/*
 * On older SGI Machines this call used to work... On the newer
 * boxes it doesn't do anything. If you want the old stuff then
 * #define OLD_SGI_BOXES somewhere.
 */
#ifdef OLD_SGI_BOXES
polymodeflag = mode;
#endif
}

/* ------------------------------------------------------------------------ */

/*
 * dopoly
 *
 *	do a transformed polygon with n edges using fill
 */
static void dopoly(int n)
{
int	i;
char	buf[100];

if (n > MAXVERTS) {
	sprintf(buf, "dopoly: can't fill a polygon with more than %d vertices", MAXVERTS);
	verror(buf);
	}

if (!vdevice.clipoff) {
	polyclip(n);
	}
else {
	nout = n;
	for (i = 0; i < n; i++) {
		ip1[i] = WtoVx(p[i]);
		ip2[i] = WtoVy(p[i]);
		}
	}


if (vdevice.attr->a.backface && checkbacki()) {
	vdevice.fill = 0;
	return;
	}

if (vdevice.fill) {
	if (nout > 2) {
		(*vdevice.dev.Vfill)(nout, ip1, ip2);
		}
	}
else {
	vdevice.cpVx = ip1[0];
	vdevice.cpVy = ip2[0];
	vdevice.cpVvalid = 0;
	polyoutline(nout, ip1, ip2);
	}

vdevice.fill = 0;
}

/* ------------------------------------------------------------------------ */

/*
 * polyoutline
 *
 *	draws a polygon outline from already transformed points.
 */
static void polyoutline(
  int n,
  int ipx[],
  int ipy[])
{
int	i;

if (n > 2) {
	for (i = 1; i < n; i++) {
		(*vdevice.dev.Vdraw)(ipx[i], ipy[i]);

		vdevice.cpVx = ipx[i];
		vdevice.cpVy = ipy[i];
		}
	(*vdevice.dev.Vdraw)(ipx[0], ipy[0]);

	vdevice.cpVx = ipx[0];
	vdevice.cpVy = ipy[0];
	}
}

/* ------------------------------------------------------------------------ */

/*
 * polyobj
 *
 *	construct a polygon from a object token list.
 */
void polyobj(
  int n,
  Token dp[],
  int fill)
{
int	i, j;
float	vect[4], result[4];

for (i = 0, j = 0; i < n; i++, j += 3) {
	vect[V_X] = dp[j + V_X].f;
	vect[V_Y] = dp[j + V_Y].f;
	vect[V_Z] = dp[j + V_Z].f;
	vect[V_W] = 1;
	multvector(result, vect, vdevice.transmat->m);
	p[i][V_X] = result[V_X];
	p[i][V_Y] = result[V_Y];
	p[i][V_Z] = result[V_Z];
	p[i][V_W] = result[V_W];
	}

if (fill)
vdevice.fill = polymodeflag;
else
vdevice.fill = 0;

dopoly(n);

vdevice.cpW[V_X] = dp[V_X].f;
vdevice.cpW[V_Y] = dp[V_Y].f;
vdevice.cpW[V_Z] = dp[V_Z].f;
}

/* ------------------------------------------------------------------------ */

/*
 * poly2
 *
 *	construct a polygon from an (x, y) array of points provided by the user.
 */
void poly2(
  long nv,
  float dp[][2])
{
int	i;
float	np[MAXVERTS][3];

if (!vdevice.initialised)
verror("poly2: vogl not initialised");

vdevice.fill = 0;

for (i = 0; i < (int)nv; i++) {
	np[i][V_X] = dp[i][V_X];
	np[i][V_Y] = dp[i][V_Y];
	np[i][V_Z] = 0.0;
	}

poly(nv, np);
}

/* ------------------------------------------------------------------------ */

/*
 * poly2i
 *
 *	construct a polygon from an (x, y) array of points provided by the user.
 * Icoord version.
 */
void poly2i(
  long nv,
  Icoord dp[][2])
{
int	i;
float	np[MAXVERTS][3];

if (!vdevice.initialised)
verror("poly2i: vogl not initialised");

vdevice.fill = 0;

for (i = 0; i < (int)nv; i++) {
	np[i][V_X] = dp[i][V_X];
	np[i][V_Y] = dp[i][V_Y];
	np[i][V_Z] = 0.0;
	}

poly(nv, np);
}

/* ------------------------------------------------------------------------ */

/*
 * poly2s
 *
 *	construct a polygon from an (x, y) array of points provided by the user.
 * Scoord version.
 */
void poly2s(
  long nv,
  Scoord dp[][2])
{
int	i;
float	np[MAXVERTS][3];

if (!vdevice.initialised)
verror("poly2s: vogl not initialised");

vdevice.fill = 0;

for (i = 0; i < (int)nv; i++) {
	np[i][V_X] = dp[i][V_X];
	np[i][V_Y] = dp[i][V_Y];
	np[i][V_Z] = 0.0;
	}

poly(nv, np);
}

/* ------------------------------------------------------------------------ */

/*
 * polyi
 *
 *	construct a polygon from an (x, y, z) array of points provided by the user.
 * Icoord version.
 */
void polyi(
  long nv,
  Icoord dp[][3])
{
int	i;
float	np[MAXVERTS][3];

if (!vdevice.initialised)
verror("polyi: vogl not initialised");

vdevice.fill = 0;

for (i = 0; i < (int)nv; i++) {
	np[i][V_X] = dp[i][V_X];
	np[i][V_Y] = dp[i][V_Y];
	np[i][V_Z] = dp[i][V_Z];
	}

poly(nv, np);
}

/* ------------------------------------------------------------------------ */

/*
 * polys
 *
 *	construct a polygon from an (x, y, z) array of points provided by the user.
 * Scoord version.
 */
void polys(
  long nv,
  Scoord dp[][3])
{
int	i;
float	np[MAXVERTS][3];

if (!vdevice.initialised)
verror("poly2s: vogl not initialised");

vdevice.fill = 0;

for (i = 0; i < (int)nv; i++) {
	np[i][V_X] = dp[i][V_X];
	np[i][V_Y] = dp[i][V_Y];
	np[i][V_Z] = dp[i][V_Z];
	}

poly(nv, np);
}

/* ------------------------------------------------------------------------ */

/*
 * polf2
 *
 *	construct a filled polygon from an (x, y) array of points provided
 * by the user.
 */
void polf2(
  long nv,
  float dp[][2])
{
int	i;
float	np[MAXVERTS][3];

if (!vdevice.initialised)
verror("polf2: vogl not initialised");

vdevice.fill = polymodeflag;

for (i = 0; i < (int)nv; i++) {
	np[i][V_X] = dp[i][V_X];
	np[i][V_Y] = dp[i][V_Y];
	np[i][V_Z] = 0.0;
	}

poly(nv, np);

vdevice.fill = 0;
}

/* ------------------------------------------------------------------------ */

/*
 * polf2i
 *
 *	construct a filled polygon from an (x, y) array of points provided
 * by the user. Icoord version.
 */
void polf2i(
  long nv,
  Icoord dp[][2])
{
int	i;
float	np[MAXVERTS][3];

if (!vdevice.initialised)
verror("polf2i: vogl not initialised");

vdevice.fill = polymodeflag;

for (i = 0; i < (int)nv; i++) {
	np[i][V_X] = dp[i][V_X];
	np[i][V_Y] = dp[i][V_Y];
	np[i][V_Z] = 0.0;
	}

poly(nv, np);

vdevice.fill = 0;
}

/* ------------------------------------------------------------------------ */

/*
 * polf2s
 *
 *	construct a filled polygon from an (x, y) array of points provided
 * by the user. Scoord version.
 */
void polf2s(
  long nv,
  Scoord dp[][2])
{
int	i;
float	np[MAXVERTS][3];

if (!vdevice.initialised)
verror("polf2s: vogl not initialised");

vdevice.fill = polymodeflag;

for (i = 0; i < (int)nv; i++) {
	np[i][V_X] = dp[i][V_X];
	np[i][V_Y] = dp[i][V_Y];
	np[i][V_Z] = 0.0;
	}

poly(nv, np);

vdevice.fill = 0;
}

/* ------------------------------------------------------------------------ */

/*
 * polfi
 *
 *	construct a filled polygon from an (x, y, z) array of points provided
 * by the user. Icoord version.
 */
void polfi(
  long nv,
  Icoord dp[][3])
{
int	i;
float	np[MAXVERTS][3];

if (!vdevice.initialised)
verror("polfi: vogl not initialised");

vdevice.fill = polymodeflag;

for (i = 0; i < (int)nv; i++) {
	np[i][V_X] = dp[i][V_X];
	np[i][V_Y] = dp[i][V_Y];
	np[i][V_Z] = dp[i][V_Z];
	}

poly(nv, np);

vdevice.fill = 0;
}

/* ------------------------------------------------------------------------ */

/*
 * polfs
 *
 *	construct a filled polygon from an (x, y, z) array of points provided
 * by the user. Scoord version.
 */
void polfs(
  long nv,
  Scoord dp[][3])
{
int	i;
float	np[MAXVERTS][3];

if (!vdevice.initialised)
verror("polfs: vogl not initialised");

vdevice.fill = polymodeflag;

for (i = 0; i < (int)nv; i++) {
	np[i][V_X] = dp[i][V_X];
	np[i][V_Y] = dp[i][V_Y];
	np[i][V_Z] = dp[i][V_Z];
	}

poly(nv, np);

vdevice.fill = 0;
}

/* ------------------------------------------------------------------------ */

/*
 * poly
 *
 *	construct a polygon from an array of points provided by the user.
 */
void poly(
  long nv,
  float dp[][3])
{
int	i, j;
Vector	vect, result;
Token	*tok;
int	n = nv;

if (!vdevice.initialised)
verror("poly: vogl not initialised");

if (vdevice.inobject) {
	tok = newtokens(2 + 3 * n);
	tok[0].i = POLY;
	tok[1].i = n;
	for (i = 0, j = 2; i < n; i++, j += 3) {
		tok[j + V_X].f = dp[i][V_X];
		tok[j + V_Y].f = dp[i][V_Y];
		tok[j + V_Z].f = dp[i][V_Z];
		}
	return;
	}

for (i = 0; i < n; i++) {
	vect[V_X] = dp[i][V_X];
	vect[V_Y] = dp[i][V_Y];
	vect[V_Z] = dp[i][V_Z];
	vect[V_W] = 1;
	multvector(result, vect, vdevice.transmat->m);
	p[i][V_X] = result[V_X];
	p[i][V_Y] = result[V_Y];
	p[i][V_Z] = result[V_Z];
	p[i][V_W] = result[V_W];
	}

dopoly(n);

vdevice.cpW[V_X] = dp[0][V_X];
vdevice.cpW[V_Y] = dp[0][V_Y];
vdevice.cpW[V_Z] = dp[0][V_Z];
}

/* ------------------------------------------------------------------------ */

/*
 * polf
 *
 *	construct a filled polygon from an array of points provided
 * by the user.
 */
void polf(
  long nv,
  float dp[][3])
{
int	i, j;
Vector	vect, result;
Token	*tok;
long	n = nv;

if (!vdevice.initialised)
verror("poly: vogl not initialised");

vdevice.fill = polymodeflag;

if (vdevice.inobject) {
	tok = newtokens(2 + 3 * n);
	tok[0].i = POLYF;
	tok[1].i = n;
	for (i = 0, j = 2; i < n; i++, j += 3) {
		tok[j + V_X].f = dp[i][V_X];
		tok[j + V_Y].f = dp[i][V_Y];
		tok[j + V_Z].f = dp[i][V_Z];
		}
	return;
	}

for (i = 0; i < n; i++) {
	vect[V_X] = dp[i][V_X];
	vect[V_Y] = dp[i][V_Y];
	vect[V_Z] = dp[i][V_Z];
	vect[V_W] = 1;
	multvector(result, vect, vdevice.transmat->m);
	p[i][V_X] = result[V_X];
	p[i][V_Y] = result[V_Y];
	p[i][V_Z] = result[V_Z];
	p[i][V_W] = result[V_W];
	}

dopoly(n);

vdevice.cpW[V_X] = dp[0][V_X];
vdevice.cpW[V_Y] = dp[0][V_Y];
vdevice.cpW[V_Z] = dp[0][V_Z];

vdevice.fill = 0;
}

/* ------------------------------------------------------------------------ */

/*
 * pmv
 *
 *	set the start position of a polygon
 */
void pmv(
  float x,
  float y,
  float z)
{
vdevice.inpolygon = 1;
vdevice.fill = polymodeflag;
numv = 0;
p[numv][V_X] = x;
p[numv][V_Y] = y;
p[numv][V_Z] = z;
p[numv][V_W] = 1.0;
}

/* ------------------------------------------------------------------------ */

/*
 * pmvi
 *
 *	The integer argument version of pmv.
 */
void pmvi(
  Icoord x,
  Icoord y,
  Icoord z)
{
pmv((float)x, (float)y, (float)z);
}

/* ------------------------------------------------------------------------ */

/*
 * pmv2i
 *
 *	The integer argument version of pmv2.
 */
void pmv2i(
  Icoord x,
  Icoord y)
{
pmv((float)x, (float)y, vdevice.cpW[V_Z]);
}

/* ------------------------------------------------------------------------ */

/*
 * pmvs
 *
 *	The integer argument version of pmv.
 */
void pmvs(
  Scoord x,
  Scoord y,
  Scoord z)
{
pmv((float)x, (float)y, (float)z);
}

/* ------------------------------------------------------------------------ */

/*
 * pmv2s
 *
 *	The integer argument version of pmv2.
 */
void pmv2s(
  Scoord x,
  Scoord y)
{
pmv((float)x, (float)y, vdevice.cpW[V_Z]);
}

/* ------------------------------------------------------------------------ */

/*
 * pmv2
 *
 *	set up a polygon which will be constructed by a series of
 * move draws in x, y.
 */
void pmv2(
  float x,
  float y)
{
pmv(x, y, vdevice.cpW[V_Z]);
}

/* ------------------------------------------------------------------------ */


/*
 * pdr
 *
 *	add another vertex to the polygon array
 */
void pdr(
  Coord x,
  Coord y,
  Coord z)
{
char	buf[100];

numv++;

if (numv >= MAXVERTS) {
	sprintf(buf, "pdr: can't draw a polygon with more than %d vertices", MAXVERTS);
	verror(buf);
	}

p[numv][V_X] = x;
p[numv][V_Y] = y;
p[numv][V_Z] = z;
p[numv][V_W] = 1.0;
}

/* ------------------------------------------------------------------------ */

/*
 * rpdr
 *
 *	relative polygon draw.
 */
void rpdr(
  Coord dx,
  Coord dy,
  Coord dz)
{
rpdr((vdevice.cpW[V_X] + dx), (vdevice.cpW[V_Y] + dy), (vdevice.cpW[V_Z] + dz));
}

/* ------------------------------------------------------------------------ */

/*
 * rpdr2
 *
 *	relative polygon draw - only (x, y).
 */
void rpdr2(
  Coord dx,
  Coord dy)
{
rpdr((vdevice.cpW[V_X] + dx), (vdevice.cpW[V_Y] + dy), vdevice.cpW[V_Z]);
}

/* ------------------------------------------------------------------------ */

/*
 * rpdri
 *
 *	relative polygon draw. Icoord version.
 */
void rpdri(
  Icoord dx,
  Icoord dy,
  Icoord dz)
{
rpdr((vdevice.cpW[V_X] + dx), (vdevice.cpW[V_Y] + dy), (vdevice.cpW[V_Z] + dz));
}

/* ------------------------------------------------------------------------ */

/*
 * rpdr2i
 *
 *	relative polygon draw - only (x, y). Icoord version.
 */
void rpdr2i(
  Icoord dx,
  Icoord dy)
{
rpdr((vdevice.cpW[V_X] + dx), (vdevice.cpW[V_Y] + dy), vdevice.cpW[V_Z]);
}

/* ------------------------------------------------------------------------ */

/*
 * rpdrs
 *
 *	relative polygon draw. Icoord version.
 */
void rpdrs(
  Scoord dx,
  Scoord dy,
  Scoord dz)
{
rpdr((vdevice.cpW[V_X] + dx), (vdevice.cpW[V_Y] + dy), (vdevice.cpW[V_Z] + dz));
}

/* ------------------------------------------------------------------------ */

/*
 * rpdr2s
 *
 *	relative polygon draw - only (x, y). Scoord version.
 */
void rpdr2s(
  Scoord dx,
  Scoord dy)
{
rpdr((vdevice.cpW[V_X] + dx), (vdevice.cpW[V_Y] + dy), vdevice.cpW[V_Z]);
}

/* ------------------------------------------------------------------------ */

/*
 * rpmv
 *
 *	relative polygon move.
 */
void rpmv(
  Coord dx,
  Coord dy,
  Coord dz)
{
pmv((vdevice.cpW[V_X] + dx), (vdevice.cpW[V_Y] + dy), (vdevice.cpW[V_Z] + dz));
}

/* ------------------------------------------------------------------------ */

/*
 * rpmv2
 *
 *	relative polygon move - only (x, y).
 */
void rpmv2(
  Coord dx,
  Coord dy)
{
pmv((vdevice.cpW[V_X] + dx), (vdevice.cpW[V_Y] + dy), vdevice.cpW[V_Z]);
}

/* ------------------------------------------------------------------------ */

/*
 * rpmvi
 *
 *	relative polygon move. Icoord version.
 */
void rpmvi(
  Icoord dx,
  Icoord dy,
  Icoord dz)
{
pmv((vdevice.cpW[V_X] + dx), (vdevice.cpW[V_Y] + dy), (vdevice.cpW[V_Z] + dz));
}

/* ------------------------------------------------------------------------ */

/*
 * rpmv2i
 *
 *	relative polygon move - only (x, y). Icoord version.
 */
void rpmv2i(
  Icoord dx,
  Icoord dy)
{
pmv((vdevice.cpW[V_X] + dx), (vdevice.cpW[V_Y] + dy), vdevice.cpW[V_Z]);
}

/* ------------------------------------------------------------------------ */

/*
 * rpmvs
 *
 *	relative polygon move. Icoord version.
 */
void rpmvs(
  Scoord dx,
  Scoord dy,
  Scoord dz)
{
pmv((vdevice.cpW[V_X] + dx), (vdevice.cpW[V_Y] + dy), (vdevice.cpW[V_Z] + dz));
}

/* ------------------------------------------------------------------------ */

/*
 * rpmv2s
 *
 *	relative polygon move - only (x, y). Scoord version.
 */
void rpmv2s(
  Scoord dx,
  Scoord dy)
{
pmv((vdevice.cpW[V_X] + dx), (vdevice.cpW[V_Y] + dy), vdevice.cpW[V_Z]);
}

/* ------------------------------------------------------------------------ */

/*
 * pdri
 *
 *	The integer argument version of pdr.
 */
void pdri(
  Icoord x,
  Icoord y,
  Icoord z)
{
pdr((float)x, (float)y, (float)z);
}

/* ------------------------------------------------------------------------ */

/*
 * pdr2i
 *
 *	The integer argument version of pdr2.
 */
void pdr2i(
  Icoord x,
  Icoord y)
{
pdr((float)x, (float)y, vdevice.cpW[V_Z]);
}

/* ------------------------------------------------------------------------ */

/*
 * pdrs
 *
 *	The short argument version of pdr.
 */
void pdrs(
  Scoord x,
  Scoord y)
{
pdr((float)x, (float)y, vdevice.cpW[V_Z]);
}

/* ------------------------------------------------------------------------ */

/*
 * pdr2s
 *
 *	The short argument version of pdr2.
 */
void pdr2s(
  Scoord x,
  Scoord y)
{
pdr((float)x, (float)y, vdevice.cpW[V_Z]);
}

/* ------------------------------------------------------------------------ */

/*
 * pdr2
 *
 *	add another vertex to the polygon array
 */
void pdr2(
  float x,
  float y)
{
pdr(x, y, vdevice.cpW[V_Z]);
}

/* ------------------------------------------------------------------------ */

/*
 * pclos
 *
 *	draw the polygon started by the above.
 */
void pclos(void)
{
float	lstx, lsty, lstz;
Vector	result;
int	i, j;
Token	*tok;

if (!vdevice.initialised)
verror("pclos: vogl not initialised");

vdevice.inpolygon = 0;

if (vdevice.inobject) {
	tok = newtokens(2 + 3 * (numv + 1));
	tok[0].i = POLYF;
	tok[1].i = numv + 1;
	for (i = 0, j = 2; i <= numv; i++, j += 3) {
		tok[j + V_X].f = p[i][V_X];
		tok[j + V_Y].f = p[i][V_Y];
		tok[j + V_Z].f = p[i][V_Z];
		}

	return;
	}

lstx = p[numv][V_X];
lsty = p[numv][V_Y];
lstz = p[numv][V_Z];

numv++;

for (i = 0; i < numv; i++) {
	multvector(result, p[i], vdevice.transmat->m);
	p[i][V_X] = result[V_X];
	p[i][V_Y] = result[V_Y];
	p[i][V_Z] = result[V_Z];
	p[i][V_W] = result[V_W];
	}

dopoly(numv);

vdevice.cpW[V_X] = lstx;
vdevice.cpW[V_Y] = lsty;
vdevice.cpW[V_Z] = lstz;
}

/* ------------------------------------------------------------------------ */

/*
 * checkbacki
 *
 *	Checks if a transformed polygon is backfacing or not.
 */
static int checkbacki(void)
{

#ifdef	PC	/*	Only has 16 bit ints */
#define	BACKFACE(z)	(clockwise ? ((z) <= 0L) : ((z) > 0L))
long	z;
#else
#define	BACKFACE(z)	(clockwise ? ((z) <= 0) : ((z) > 0))
int	z;
#endif

int	x1, x2, y1, y2;

x1 = ip1[1] - ip1[0];
x2 = ip1[2] - ip1[1];
y1 = ip2[1] - ip2[0];
y2 = ip2[2] - ip2[1];

#ifdef	PC
z = (long)x1 * (long)y2 - (long)y1 * (long)x2;
#else
z = x1 * y2 - y1 * x2;
#endif

return(BACKFACE(z));
}

/* ------------------------------------------------------------------------ */

/*
 * The following routines are an implementation of the Sutherland - Hodgman
 * polygon clipper, as described in "Reentrant Polygon Clipping"
 * Communications of the ACM Jan 1974, Vol 17 No. 1.
 */
static void polyclip(register int n)
{
int	i;

nout = 0;
for (i = 0; i < 6; i++)
first[i] = 1;

for (i = 0; i < n; i++) 
shclip(p[i], 0);

shclose(0);
}

/* ------------------------------------------------------------------------ */

static void shclip(
  float Pnt[4],
  int side)
{
float	P[4];

if (side == 6) {
	ip1[nout] = WtoVx(Pnt);
	ip2[nout++] = WtoVy(Pnt);
	}
else {
	copyvector(P, Pnt);
	if (first[side]) {
		first[side] = 0;
		copyvector(F[side], P);
		}
	else if (intersect(side, I, P)) {
		shclip(I, side + 1);
		}
	copyvector(S[side], P);
	if (visible(side)) 
	shclip(S[side], side + 1);
	}
}

/* ------------------------------------------------------------------------ */

static void shclose(int side)
{
if (side < 6) {
	if (intersect(side, I, F[side]))
	shclip(I, side + 1);

	shclose(side + 1);

	first[side] = 1;
	}
}

/* ------------------------------------------------------------------------ */

static intersect(
  int side,
  register Vector Ip,
  register Vector Pnt)
{
register	float	wc1, wc2, a;

switch (side) {
case 0:		/* x - left */
	wc1 = Pnt[3] + Pnt[0];
	wc2 = S[side][3] + S[side][0];
	break;
case 1:		/* x - right */
	wc1 = Pnt[3] - Pnt[0];
	wc2 = S[side][3] - S[side][0];
	break;
case 2:		/* y - bottom */
	wc1 = Pnt[3] + Pnt[1];
	wc2 = S[side][3] + S[side][1];
	break;
case 3:		/* y - top */
	wc1 = Pnt[3] - Pnt[1];
	wc2 = S[side][3] - S[side][1];
	break;
case 4:		/* z - near */
	wc1 = Pnt[3] + Pnt[2];
	wc2 = S[side][3] + S[side][2];
	break;
case 5:		/* z - far */
	wc1 = Pnt[3] - Pnt[2];
	wc2 = S[side][3] - S[side][2];
	break;
default:
	verror("intersect: ridiculous side value");
	}

if (wc1 * wc2 < 0.0) {	/* Both are opposite in sign - crosses */
	a = wc1 / (wc1 - wc2);
	if (a < 0.0 || a > 1.0) {
		return(0);
		}
	else {
		Ip[0] = Pnt[0] + a * (S[side][0] - Pnt[0]);
		Ip[1] = Pnt[1] + a * (S[side][1] - Pnt[1]);
		Ip[2] = Pnt[2] + a * (S[side][2] - Pnt[2]);
		Ip[3] = Pnt[3] + a * (S[side][3] - Pnt[3]);
		return(1);
		}
	}
return(0);
}

/* ------------------------------------------------------------------------ */

static visible(int side)
{
float	wc;

switch (side) {
case 0:		/* x - left */
	wc = S[side][3] + S[side][0];
	break;
case 1:		/* x - right */
	wc = S[side][3] - S[side][0];
	break;
case 2:		/* y - bottom */
	wc = S[side][3] + S[side][1];
	break;
case 3:		/* y - top */
	wc = S[side][3] - S[side][1];
	break;
case 4:		/* z - near */
	wc = S[side][3] + S[side][2];
	break;
case 5:		/* z - far */
	wc = S[side][3] - S[side][2];
	break;
default:
	verror("visible: ridiculous side value");
	}

return(wc >= 0.0);
}

/* ------------------------------------------------------------------------ */

/*
 * bgnpolygon
 *
 *	Set a flag so that we know what to do with v*() calls.
 */
void bgnpolygon(void)
{
if (vdevice.bgnmode != NONE)
verror("vogl: bgnpolygon mode already belongs to some other bgn routine");

vdevice.bgnmode = VPOLY;
vdevice.fill = polymodeflag;
vdevice.save = 1;
vdevice.inpolygon = 1;
}

/* ------------------------------------------------------------------------ */

/*
 * endpolygon
 *
 *	Set a flag so that we know what to do with v*() calls.
 */
void endpolygon(void)
{
pclos();

vdevice.bgnmode = NONE;
vdevice.fill = 0;
vdevice.inpolygon = 0;
vdevice.save = 0;
}

/* ------------------------------------------------------------------------ */

