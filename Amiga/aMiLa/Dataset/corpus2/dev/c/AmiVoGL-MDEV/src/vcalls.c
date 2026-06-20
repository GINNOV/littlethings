#include "vogl.h"

/*
 * Handles all the v4f v3f v2f calls
 */


/*
 *  vcall
 *
 *	Specify a generic point.
 */
void vcall(
  float vector[],
  int len)
{
Vector	vec;

vec[0] = vector[0];
vec[1] = vector[1];
vec[2] = 0.0;
vec[3] = 1.0;

if (len == 3) {
	vec[2] = vector[2];
	vec[3] = 1.0;
	}
else if (len == 4) {
	vec[2] = vector[2];
	vec[3] = vector[3];
	}

if (vdevice.save) {
	vdevice.savex = vec[V_X];
	vdevice.savey = vec[V_Y];
	vdevice.savez = vec[V_Z];
	} 

switch (vdevice.bgnmode) {
case VLINE:
	if (vdevice.save) {
		vdevice.save = 0;
		move(vec[V_X], vec[V_Y], vec[V_Z]);
		break;
		}

	draw(vec[V_X], vec[V_Y], vec[V_Z]);
	break;
case VPNT:
	pnt(vec[V_X], vec[V_Y], vec[V_Z]);
	break;
case VCLINE:
	if (vdevice.save) {
		vdevice.save = 0;
		move(vec[V_X], vec[V_Y], vec[V_Z]);
		break;
		}

	draw(vec[V_X], vec[V_Y], vec[V_Z]);
	break;
case VPOLY:
	if (vdevice.save) {
		vdevice.save = 0;
		pmv(vec[V_X], vec[V_Y], vec[V_Z]);
		break;
		} 

	pdr(vec[V_X], vec[V_Y], vec[V_Z]);
	break;
default:
	move(vec[V_X], vec[V_Y], vec[V_Z]);
	}
}

/* ------------------------------------------------------------------------ */

/*
 * v4f	
 * 	Adds a 4D point to our fake point buffer
 */
void v4f(float vec[4])
{
vcall(vec, 4);
}

/* ------------------------------------------------------------------------ */

/*
 * v3f	
 * 	Adds a 3D point to our fake point buffer
 */
void v3f(float vec[3])
{
vcall(vec, 3);
}

/* ------------------------------------------------------------------------ */

/*
 * v2f	
 * 	Adds a 2D point to our fake point buffer
 */
void v2f(float vec[2])
{
vcall(vec, 2);
}

/* ------------------------------------------------------------------------ */


/*
 * v4d	
 * 	Adds a 4D point to our fake point buffer
 */
void v4d(double vec[4])
{
float	v[4];

v[0] = vec[0];
v[1] = vec[1];
v[2] = vec[2];
v[3] = vec[3];

vcall(v, 4);
}

/* ------------------------------------------------------------------------ */

/*
 * v3d	
 * 	Adds a 3D point to our fake point buffer
 */
void v3d(double vec[3])
{
float	v[3];

v[0] = vec[0];
v[1] = vec[1];
v[2] = vec[2];

vcall(v, 3);
}

/* ------------------------------------------------------------------------ */

/*
 * v2d	
 * 	Adds a 2D point to our fake point buffer
 */
void v2d(long vec[2])
{
float	v[2];

v[0] = vec[0];
v[1] = vec[1];

vcall(v, 2);
}

/* ------------------------------------------------------------------------ */



/*
 * v4i	
 * 	Adds a 4D point to our fake point buffer
 */
void v4i(long vec[4])
{
float	v[4];

v[0] = vec[0];
v[1] = vec[1];
v[2] = vec[2];
v[3] = vec[3];

vcall(v, 4);
}

/* ------------------------------------------------------------------------ */

/*
 * v3i	
 * 	Adds a 3D point to our fake point buffer
 */
void v3i(long vec[3])
{
float	v[3];

v[0] = vec[0];
v[1] = vec[1];
v[2] = vec[2];

vcall(v, 3);
}

/* ------------------------------------------------------------------------ */

/*
 * v2i	
 * 	Adds a 2D point to our fake point buffer
 */
void v2i(long vec[2])
{
float	v[2];

v[0] = vec[0];
v[1] = vec[1];

vcall(v, 2);
}

/* ------------------------------------------------------------------------ */

/*
 * v4s	
 * 	Adds a 4D point to our fake point buffer
 */
void v4s(short vec[4])
{
float	v[4];

v[0] = vec[0];
v[1] = vec[1];
v[2] = vec[2];
v[3] = vec[3];

vcall(v, 4);
}

/* ------------------------------------------------------------------------ */

/*
 * v3s	
 * 	Adds a 3D point to our fake point buffer
 */
void v3s(short vec[3])
{
float	v[3];

v[0] = vec[0];
v[1] = vec[1];
v[2] = vec[2];

vcall(v, 3);
}

/* ------------------------------------------------------------------------ */

/*
 * v2s	
 * 	Adds a 2D point to our fake point buffer
 */
void v2s(short vec[2])
{
float	v[2];

v[0] = vec[0];
v[1] = vec[1];

vcall(v, 2);
}

/* ------------------------------------------------------------------------ */

