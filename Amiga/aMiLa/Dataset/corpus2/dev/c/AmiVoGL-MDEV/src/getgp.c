#include "vogl.h"

/*
 * getgp
 *
 *	return the current (x, y, z) graphics position
 */
void getgp(
  Coord *x,
  Coord *y,
  Coord *z)
{
*x = vdevice.cpW[V_X];
*y = vdevice.cpW[V_Y];
*z = vdevice.cpW[V_Z];
}

/* ------------------------------------------------------------------------ */

/*
 * getgpos
 *
 *	Get the current graphics position after transformation by
 *	the current matrix.
 */
void getgpos(
  Coord *x,
  Coord *y,
  Coord *z,
  Coord *w)
{
*x = vdevice.cpWtrans[V_X];
*y = vdevice.cpWtrans[V_Y];
*z = vdevice.cpWtrans[V_Z];
*w = vdevice.cpWtrans[V_W];
}

/* ------------------------------------------------------------------------ */

