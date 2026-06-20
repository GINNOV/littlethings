#include "vogl.h"

/*
 * draw
 *
 * draw a line form the logical graphics position to the
 * the world coordinates x, y, z.
 *
 */
void draw(
  float x,
  float y,
  float z)
{
Token	*tok;
int	vx, vy;
Vector	res;


if (!vdevice.initialised)
verror("draw: vogl not initialised");

if (vdevice.inobject) {
	tok = newtokens(4);

	tok[0].i = DRAW;
	tok[1].f = x;
	tok[2].f = y;
	tok[3].f = z;

	vdevice.cpW[V_X] = x;
	vdevice.cpW[V_Y] = y;
	vdevice.cpW[V_Z] = z;

	vdevice.cpVvalid = 0;

	return;
	}

if (!vdevice.cpVvalid)
multvector(vdevice.cpWtrans, vdevice.cpW, vdevice.transmat->m);

vdevice.cpW[V_X] = x;
vdevice.cpW[V_Y] = y;
vdevice.cpW[V_Z] = z;
multvector(res, vdevice.cpW, vdevice.transmat->m);

if (vdevice.clipoff) {
	vx = WtoVx(res);		/* just draw it */
	vy = WtoVy(res);
	 
	(*vdevice.dev.Vdraw)(vx, vy);

	vdevice.cpVx = vx;
	vdevice.cpVy = vy;

	vdevice.cpVvalid = 0;
	}
else {
	if (vdevice.cpVvalid)
	quickclip(vdevice.cpWtrans, res);
	else
	clip(vdevice.cpWtrans, res);
	}

vdevice.cpWtrans[V_X] = res[V_X];
vdevice.cpWtrans[V_Y] = res[V_Y];
vdevice.cpWtrans[V_Z] = res[V_Z];
vdevice.cpWtrans[V_W] = res[V_W];
}

/* ------------------------------------------------------------------------ */

/*
 * draws
 *
 * draw a line form the logical graphics position to the
 * the world coordinates x, y, z expressed as a short integer data type.
 *
 */
void draws(
  Scoord x,
  Scoord y,
  Scoord z)
{
draw((Coord)x, (Coord)y, (Coord)z);
}

/* ------------------------------------------------------------------------ */


/*
 * drawi
 *
 * draw a line form the logical graphics position to the
 * the world coordinates x, y, z expressed as an integer data type.
 *
 */
void drawi(
  Icoord x,
  Icoord y,
  Icoord z)
{
draw((Coord)x, (Coord)y, (Coord)z);
}

/* ------------------------------------------------------------------------ */



/*
 * draw2
 *
 * draw a line from the logical graphics position  to the
 * the world coordinates x, y.
 *
 */
void draw2(
  float x,
  float y)
{
if (!vdevice.initialised)
verror("draw2: vogl not initialised");

draw(x, y, 0.0);
}

/* ------------------------------------------------------------------------ */

/*
 * draw2s
 *
 * draw a line from the logical graphics position  to the
 * the world coordinates x, y expressed as a short integer data type.
 *
 */
void draw2s(
  Scoord x,
  Scoord y)
{
draw2((Coord)x, (Coord)y);
}

/* ------------------------------------------------------------------------ */


/*
 * draw2i
 *
 * draw a line from the logical graphics position  to the
 * the world coordinates x, y expressed as an integer data type.
 *
 */
void draw2i(
  Icoord x,
  Icoord y)
{
draw2((Coord)x, (Coord)y);
}

/* ------------------------------------------------------------------------ */

/*
 * rdr
 *
 * 3D relative draw from the logical graphics position by dx, dy, dz.
 * This is the same as the VOGLE routine rdraw.
 *
 */
void rdr(
  float dx,
  float dy,
  float dz)
{
if (!vdevice.initialised) 
verror("rdr: vogl not initialised");

draw((vdevice.cpW[V_X] + dx), (vdevice.cpW[V_Y] + dy), (vdevice.cpW[V_Z] + dz));
}

/* ------------------------------------------------------------------------ */

/*
 * rdrs
 *
 * 3D relative draw from the logical graphics position by dx, dy, dz
 * expressed as a short integer data type.
 *
 */
void rdrs(
  Scoord dx,
  Scoord dy,
  Scoord dz)
{
rdr((Coord)dx, (Coord)dy, (Coord)dz);
}

/* ------------------------------------------------------------------------ */

/*
 * rdri
 *
 * 3D relative draw from the logical graphics position by dx, dy, dz
 * expressed as an integer data type.
 *
 */
void rdri(
  Icoord dx,
  Icoord dy,
  Icoord dz)
{
rdr((Coord)dx, (Coord)dy, (Coord)dz);
}

/* ------------------------------------------------------------------------ */


/*
 * rdr2
 *
 * 2D relative draw from the logical graphics position by dx, dy.
 * This is the same as the VOGLE routine rdraw2.
 *
 */
void rdr2(
  float dx,
  float dy)
{
if (!vdevice.initialised) 
verror("rdr2: vogl not initialised");

draw((vdevice.cpW[V_X] + dx), (vdevice.cpW[V_Y] + dy), 0.0);
}

/* ------------------------------------------------------------------------ */


/*
 * rdr2s
 *
 * 3D relative draw from the logical graphics position by dx, dy
 * expressed as a short integer data type.
 *
 */
void rdr2s(
  Scoord dx,
  Scoord dy)
{
rdr2((Coord)dx, (Coord)dy);
}

/* ------------------------------------------------------------------------ */

/*
 * rdr2i
 *
 * 3D relative draw from the logical graphics position by dx, dy
 * expressed as an integer data type.
 *
 */
void rdr2i(
  Icoord dx,
  Icoord dy)
{
rdr2((Coord)dx, (Coord)dy);
}

/* ------------------------------------------------------------------------ */


/*
 * bgnline
 *
 * 	Flags that all v*() routine points will be building up a line list.
 */
void bgnline(void)
{
if (vdevice.bgnmode != NONE)
verror("vogl: bgnline mode already belongs to some other bgn routine");

vdevice.bgnmode = VLINE;
vdevice.save = 1;
}

/* ------------------------------------------------------------------------ */

/*
 * endline
 *
 * 	Flags that all v*() routine points will be simply setting the 
 * 	current position.
 */
void endline(void)
{
vdevice.bgnmode = NONE;
vdevice.save = 0;
}

/* ------------------------------------------------------------------------ */

/*
 * bgnclosedline
 *
 * 	Flags that all v*() routine points will be building up a line list.
 */
void bgnclosedline(void)
{
if (vdevice.bgnmode != NONE)
verror("vogl: bgncloseline mode already belongs to some other bgn routine");

vdevice.bgnmode = VCLINE;
vdevice.save = 1;
}

/* ------------------------------------------------------------------------ */

/*
 * endclosedline
 *
 * 	Flags that all v*() routine points will be simply setting the 
 * 	current position.
 */
void endclosedline(void)
{
vdevice.bgnmode = NONE;
draw(vdevice.savex, vdevice.savey, vdevice.savez);
}

/* ------------------------------------------------------------------------ */

