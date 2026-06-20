#include <stdio.h>

#if defined(PC) || defined(AZTEC_C)  || defined(AMIGA)
#include <string.h>
#else
#include <strings.h>
#endif
#include "vogl.h"

/* ---------------------------------------------------------------------
 * Local Variables:
 */
static	float	c_x, c_y, c_z;	/* Current character position */

/* ---------------------------------------------------------------------
 * Prototypes:
 */
#ifdef __PROTOTYPE__
static float getcharwidth(void);                       /* text.c          */
#else	/* __PROTOTYPE__ */
static float getcharwidth();                           /* text.c          */
#endif	/* __PROTOTYPE__ */

/* ---------------------------------------------------------------------
 * Source Code:
 */

/*
 * font
 * 	assigns a font.
 */
void font(short id)
{
Token	*tok;

if (!vdevice.initialised)
verror("font: vogl not initialised");

if (id < 0 || id >= vdevice.maxfontnum)
verror("font: font number is out of range");

if (vdevice.inobject) {
	tok = newtokens(2);
	tok[0].i = FONT;
	tok[1].i = id;
	return;
	}

if (id == 1) {
	if (!(*vdevice.dev.Vfont)(vdevice.dev.large)) 
	verror("font: unable to open large font");
	}
else if (id == 0) {
	if (!(*vdevice.dev.Vfont)(vdevice.dev.small))
	verror("font: unable to open small font");
	}

vdevice.attr->a.fontnum = id;
}

/* ------------------------------------------------------------------------ */

/*
 * getcharwidth
 *
 * 	Gets the width of one char on world coords.
 */
static float getcharwidth(void)
{
float           a, b, c, d;

VtoWxy(vdevice.hwidth, vdevice.hheight, &c, &d);
VtoWxy(0.0, 0.0, &a, &b);
c -= a;
return(c);
}

/* ------------------------------------------------------------------------ */

/*
 * charstr
 *
 * Draw a string from the current character position.
 *
 */
void charstr(char *str)
{
float	cx, cy, cz;
char	c;
Token	*tok;
int	oldclipoff = vdevice.clipoff;
int	sl = strlen(str);

if(!vdevice.initialised) 
verror("charstr: vogl not initialized");

if (vdevice.inobject) {
	tok = newtokens(2 + strlen(str) / sizeof(Token));

	tok[0].i = DRAWSTR;
	strcpy((char *)&tok[1], str);

	return;
	}

cx = vdevice.cpW[V_X];
cy = vdevice.cpW[V_Y];
cz = vdevice.cpW[V_Z];

vdevice.clipoff = 1;	/* Forces update of device coords */
move(c_x, c_y, c_z);	/* Updates device coords	  */

/*   If not clipping then simply display text and return  */

if (oldclipoff) {
	(*vdevice.dev.Vstring)(str);
	}
else { /* Check if string is within viewport */
	int	left_s = vdevice.cpVx;
	int	bottom_s = vdevice.cpVy - (int)vdevice.hheight;
	int	top_s = bottom_s + (int)vdevice.hheight;
	int	right_s = left_s + (int)((sl + 1) * vdevice.hwidth);

	if (left_s > vdevice.minVx &&
	    bottom_s < vdevice.maxVy &&
	    top_s > vdevice.minVy &&
	    right_s < vdevice.maxVx) {
		(*vdevice.dev.Vstring)(str);
		}
	else {
		while (c = *str++) {
			if (vdevice.cpVx > vdevice.minVx &&
			    vdevice.cpVx < vdevice.maxVx - (int)vdevice.hwidth) {
				(*vdevice.dev.Vchar)(c);
				}
			vdevice.cpVx += vdevice.hwidth;
			}
		}
	}

c_x += getcharwidth() * sl;

move(cx, cy, cz);
vdevice.clipoff = oldclipoff;
}

/* ------------------------------------------------------------------------ */

/*
 * cmov
 *
 *	Sets the current character position.
 */
void cmov(
  float x,
  float y,
  float z)
{
Token	*tok;

if (vdevice.inobject) {
	tok = newtokens(4);

	tok[0].i = CMOV;
	tok[1].f = x;
	tok[2].f = y;
	tok[3].f = z;

	return;
	}

c_x = x;
c_y = y;
c_z = z;
}

/* ------------------------------------------------------------------------ */

 
/*
 * cmov2
 *
 *	Sets the current character position. Ignores the Z coord.
 *	
 *
 */
void cmov2(
  float x,
  float y)
{
c_x = x;
c_y = y;
c_z = 0.0;
}

/* ------------------------------------------------------------------------ */

/*
 * cmovi
 *
 *	Same as cmov but with integer arguments....
 */
void cmovi(
  Icoord x,
  Icoord y,
  Icoord z)
{
c_x = (Coord)x;
c_y = (Coord)y;
c_z = (Coord)z;
}

/* ------------------------------------------------------------------------ */

/*
 * cmovs
 *
 *	Same as cmov but with short integer arguments....
 */
void cmovs(
  Scoord x,
  Scoord y,
  Scoord z)
{
c_x = (Coord)x;
c_y = (Coord)y;
c_z = (Coord)z;
}

/* ------------------------------------------------------------------------ */

/*
 * cmov2i
 *
 *	Same as cmov2 but with integer arguments....
 */
void cmov2i(
  Icoord x,
  Icoord y)
{
c_x = (Coord)x;
c_y = (Coord)y;
c_z = 0.0;
}

/* ------------------------------------------------------------------------ */

/*
 * cmov2s
 *
 *	Same as cmov but with short integer arguments....
 */
void cmov2s(
  Scoord x,
  Scoord y)
{
c_x = (Coord)x;
c_y = (Coord)y;
c_z = 0.0;
}

/* ------------------------------------------------------------------------ */

/*
 * getwidth
 *
 * Return the maximum Width of the current font.
 *
 */
long getwidth(void)
{
if (!vdevice.initialised)
verror("getwidth: vogl not initialised");


return((long)vdevice.hwidth);
}

/* ------------------------------------------------------------------------ */

/* 
 * getheight
 *
 * Return the maximum Height of the current font
 */
long getheight(void)
{
if (!vdevice.initialised)
verror("getheight: vogl not initialized");

return((long)vdevice.hheight);
}

/* ------------------------------------------------------------------------ */

