/* objects.c: */
#include <stdio.h>
#include "vogl.h"

/* ---------------------------------------------------------------------
 * Typedefs and Variables:
 */
typedef struct o{
	int		obno;
	TokList		*tlist;
	struct o	*next;
	} VObject;

static VObject		*object_table[MAXENTS];

static long		obno = -1, omax = 0;

/* ---------------------------------------------------------------------
 * Prototypes:
 */
#ifdef __PROTOTYPE__
static void doarc( float, float, float, float, float,  /* objects.c       */
   float, int);
static void doarcf( float, float, float, float, float, /* objects.c       */
   float, int);
#else
static void doarc();                                   /* objects.c       */
static void doarcf();                                  /* objects.c       */
#endif

/* ---------------------------------------------------------------------
 * Source Code:
 */

/*
 * makeobj
 *
 *	start a new object.
 *
 */
void makeobj(long ob)
{
VObject	*o;
int	n = ob;

if (!vdevice.initialised)
verror("makeobj: vogl not initialised");

for (o = object_table[n % MAXENTS]; o != (VObject *)NULL; o = o->next)
if (o->obno == n) {
	delobj((long)n);
	break;
	}

obno = n;
vdevice.tokens = (TokList *)NULL;

vdevice.inobject = 1;

if (omax <= n)
omax = n + 1;
}

/* ------------------------------------------------------------------------ */

/*
 * closeobj
 *
 *	close an object
 */
void closeobj(void)
{
VObject	*o;

if (!vdevice.inobject)
verror("closeobj: not in an object");

vdevice.inobject = 0;

o = (VObject *)vallocate(sizeof(VObject));
o->obno = obno;
o->tlist = vdevice.tokens;
o->next = object_table[obno % MAXENTS];

object_table[obno % MAXENTS] = o;

obno = -1;
}

/* ------------------------------------------------------------------------ */

/*
 * delobj
 *
 *	deletes an object, freeing its memory
 */
void delobj(long ob)
{
VObject	*o, *lo;
TokList	*tl, *ntl;
int	n = ob;

for (lo = o = object_table[n % MAXENTS]; o != (VObject *)NULL; lo = o, o = o->next)
if (o->obno == n)
break;

if (o != (VObject *)NULL) {
	for (tl = o->tlist; tl != (TokList *)NULL; tl = ntl) {
		ntl = tl->next;
		if (tl->toks)
		free(tl->toks);

		free(tl);
		}
	if (lo == object_table[n % MAXENTS])
	object_table[n % MAXENTS] = (VObject *)NULL;
	else
	lo->next = o->next;
	free(o);
	}
}

/* ------------------------------------------------------------------------ */

/*
 * genobj
 *
 *	generates a unique object identifier
 */
long genobj(void)
{
return((long)omax++);
}

/* ------------------------------------------------------------------------ */

/*
 * getopenobj
 *
 *	returns the object currently being edited, -1 if none.
 */
long getopenobj(void)
{
return((long)obno);
}

/* ------------------------------------------------------------------------ */

/*
 * doarc
 *
 *	draw an arc or circle.
 */
static void doarc(
  float x,
  float y,
  float xoff,
  float yoff,
  float cosine,
  float sine,
  int nsegs)
{
float	cx, cy, dx, dy;
int	i;

cx = x + xoff;
cy = y + yoff;
move2(cx, cy);

for (i = 0; i < nsegs; i++) {
	dx = cx - x;
	dy = cy - y;
	cx = x + dx * cosine - dy * sine;
	cy = y + dx * sine + dy * cosine;
	draw2(cx, cy);
	}
}

/* ------------------------------------------------------------------------ */

/*
 * doarcf
 *
 *	draw a filled arc or circle.
 */
static void doarcf(
  float x,
  float y,
  float xoff,
  float yoff,
  float cosine,
  float sine,
  int nsegs)
{
float	cx, cy, dx, dy;
int	i;

cx = x + xoff;
cy = y + yoff;
pmv2(cx, cy);

for (i = 0; i < nsegs; i++) {
	dx = cx - x;
	dy = cy - y;
	cx = x + dx * cosine - dy * sine;
	cy = y + dx * sine + dy * cosine;
	pdr2(cx, cy);
	}

pclos();
}

/* ------------------------------------------------------------------------ */

/*
 * callobj
 *
 *	draws an object
 */
void callobj(long ob)
{
int	n = ob;
char	buf[BUFSIZ];

VObject        *o;
TokList        *tl;
Matrix          prod, tmpmat;
Tensor          S;
int             i, j;
float           cx, cy, cz, *m;
register Token *t, *et, *pt;

if (!vdevice.initialised)
verror("callobj: vogl not initialised");

if (vdevice.inobject) {
	t = newtokens(2);

	t[0].i = CALLOBJ;
	t[1].i = n;

	return;
	}

for (o = object_table[n % MAXENTS]; o != (VObject *)NULL; o = o->next)
if (o->obno == n)
break;

if (o == (VObject *)NULL)
return;

for (tl = o->tlist; tl != (TokList *)NULL; tl = tl->next) {
	t = tl->toks;
	et = &tl->toks[tl->count];
	while (t != et) {
		switch (t->i) {
		case ARC:
			doarc(t[1].f, t[2].f, t[3].f, t[4].f, t[5].f, t[6].f, t[7].i);
			t += 8;
			break;
		case ARCF:
			doarcf(t[1].f, t[2].f, t[3].f, t[4].f, t[5].f, t[6].f, t[7].i);
			t += 8;
			break;
		case BACKBUFFER:
			backbuffer(t[1].i);
			t += 2;
			break;
		case FRONTBUFFER:
			frontbuffer(t[1].i);
			t += 2;
			break;
		case SWAPBUFFERS:
			swapbuffers();
			t += 1;
			break;
		case BACKFACING:
			backface(t[1].i);
			t += 2;
			break;
		case CALLOBJ:
			callobj(t[1].i);
			t += 2;
			break;
		case CIRCLE:
			doarc(t[1].f, t[2].f, t[3].f, 0.0, t[4].f, t[5].f, t[6].i);
			draw2(t[1].f + t[3].f, t[2].f);
			t += 7;
			break;
		case CIRCF:
			doarcf(t[1].f, t[2].f, t[3].f, 0.0, t[4].f, t[5].f, t[6].i);
			t += 7;
			break;
		case RECTF:
			pmv2(t[1].f, t[2].f);
			pdr2(t[3].f, t[2].f);
			pdr2(t[3].f, t[4].f);
			pdr2(t[1].f, t[4].f);
			pdr2(t[1].f, t[2].f);
			pclos();
			t += 5;
			break;
		case CLEAR:
			(*vdevice.dev.Vclear)();
			t++;
			break;
		case COLOR:
			color(t[1].i);
			t += 2;
			break;
		case DRAW:
			draw(t[1].f, t[2].f, t[3].f);
			t += 4;
			break;
		case DRAWSTR:
			charstr((char *) &t[1]);
			t += 2 + strlen((char *) &t[1]) / sizeof(Token);
			break;
		case FONT:
			font((short) t[1].i);
			t += 2;
			break;
		case LOADMATRIX:
			m = (float *)vdevice.transmat->m;
			for (i = 0; i < 16; i++)
			*m++ = (++t)->f;

			/* may have changed mapping from world to device coords */
			vdevice.cpVvalid = 0;
			t++;

			break;
		case MAPCOLOR:
			mapcolor((Colorindex) t[1].i,
			  (short) t[2].i,
			  (short) t[3].i,
			  (short) t[4].i);
			t += 5;
			break;
		case MOVE:
			move(t[1].f, t[2].f, t[3].f);
			t += 4;
			break;
		case MULTMATRIX:
			m = (float *)tmpmat;
			for (i = 0; i < 16; i++)
			*m++ = (++t)->f;

			mult4x4(prod, tmpmat, vdevice.transmat->m);
			loadmatrix(prod);
			t++;
			break;
		case POLY:
			polyobj(t[1].i, &t[2], 0);
			t += 2 + 3 * t[1].i;
			break;
		case POLYF:
			polyobj(t[1].i, &t[2], 1);
			t += 2 + 3 * t[1].i;
			break;
		case CMOV:
			cmov(t[1].f, t[2].f, t[3].f);
			t += 4;
			break;
		case POPATTRIBUTES:
			popattributes();
			t++;
			break;
		case POPMATRIX:
			popmatrix();
			t++;
			break;
		case POPVIEWPORT:
			popviewport();
			t++;
			break;
		case PUSHATTRIBUTES:
			pushattributes();
			t++;
			break;
		case PUSHMATRIX:
			pushmatrix();
			t++;
			break;
		case PUSHVIEWPORT:
			pushviewport();
			t++;
			break;
		case RCURVE:
			i = (++t)->i;
			cx = (++t)->f;
			cy = (++t)->f;
			cz = (++t)->f;
			m = (float *)tmpmat;
			for (j = 0; j < 16; j++)
			*m++ = (++t)->f;
			mult4x4(prod, tmpmat, vdevice.transmat->m);
			drcurve(i, prod);
			vdevice.cpW[V_X] = cx;
			vdevice.cpW[V_Y] = cy;
			vdevice.cpW[V_Z] = cz;
			t++;
			break;
		case RPATCH:
			pt = t + 10;
			cx = (++t)->f;
			cy = (++t)->f;
			cz = (++t)->f;
			for (i = 0; i < 4; i++)
			for (j = 0; j < 4; j++) {
				S[0][i][j] = (pt++)->f;
				S[1][i][j] = (pt++)->f;
				S[2][i][j] = (pt++)->f;
				S[3][i][j] = (pt++)->f;
				}

			transformtensor(S, vdevice.transmat->m);
			drpatch(S, t[1].i, t[2].i, t[3].i, t[4].i, t[5].i, t[6].i);

			vdevice.cpW[V_X] = cx;
			vdevice.cpW[V_Y] = cy;
			vdevice.cpW[V_Z] = cz;
			t = pt;
			break;
		case VIEWPORT:
			viewport(
			  (Screencoord) t[1].i,
			  (Screencoord) t[2].i,
			  (Screencoord) t[3].i,
			  (Screencoord) t[4].i);
			t += 5;
			break;
		case TRANSLATE:
			translate(t[1].f, t[2].f, t[3].f);
			t += 4;
			break;
		case SCALE:
			/*
			 * Do the operations directly on the top matrix of
			 * the stack to speed things up.
			 */

			vdevice.transmat->m[0][0] *= t[1].f;
			vdevice.transmat->m[0][1] *= t[1].f;
			vdevice.transmat->m[0][2] *= t[1].f;
			vdevice.transmat->m[0][3] *= t[1].f;

			vdevice.transmat->m[1][0] *= t[2].f;
			vdevice.transmat->m[1][1] *= t[2].f;
			vdevice.transmat->m[1][2] *= t[2].f;
			vdevice.transmat->m[1][3] *= t[2].f;

			vdevice.transmat->m[2][0] *= t[3].f;
			vdevice.transmat->m[2][1] *= t[3].f;
			vdevice.transmat->m[2][2] *= t[3].f;
			vdevice.transmat->m[2][3] *= t[3].f;

			t += 4;
			break;
		case ROTATE:
			rot(t[1].f, (char)t[2].i);
			t += 3;
			break;
		default:
			sprintf(buf, "vogl: internal error in callobj (Token type %d used)", t->i);
			verror(buf);
			exit(1);
			}
		}
	}
}

/* ------------------------------------------------------------------------ */

/*
 * isobj
 *
 *	returns 1 if there is an object n, 0 otherwise.
 */
Boolean isobj(long ob)
{
long	n = ob;

VObject	*o;

for (o = object_table[n % MAXENTS]; o != (VObject *)NULL; o = o->next)
if (o->obno == n)
break;

return(o != (VObject *)NULL);
}

/* ------------------------------------------------------------------------ */

