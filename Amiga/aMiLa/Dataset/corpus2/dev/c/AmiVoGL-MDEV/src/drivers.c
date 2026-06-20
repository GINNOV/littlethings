#include <stdio.h>
#include "vogl.h"
#include "vodevice.h"

/* ---------------------------------------------------------------------
 * Prototypes:
 */
#ifdef __PROTOTYPE__
static void getdev(char *);                            /* drivers.c       */
#else
static void getdev();                                  /* drivers.c       */
#endif

/* ---------------------------------------------------------------------
 * Driver Prototypes:
 */
#ifdef __PROTOTYPE__

#ifdef AMIGA
void _AMIGA_devcpy(void);                              /* amiga.c         */
#endif

#ifdef apollo
int _APOLLO_devcpy(void);                              /* apollo.c        */
#endif

#ifdef CGA
int _cga_devcpy(void);                                 /* cga.c           */
#endif

#ifdef DECX11
int _DECX11_devcpy(void);                              /* decX11.c        */
#endif

#ifdef DXY
int _DXY_devcpy(void);                                 /* hpdxy.c         */
#endif

#ifdef EGA
int _ega_devcpy(void);                                 /* ega.c           */
#endif

#ifdef GRX
int _grx_devcpy(void);                                 /* grx.c           */
#endif

#ifdef HERCULES
#endif

#ifdef HGC
int _hgc_devcpy(void);                                 /* hgc.c           */
#endif

#ifdef HPGL
int _HPGL_A1_devcpy(void);                             /* hpdxy.c         */
int _HPGL_A2_devcpy(void);                             /* hpdxy.c         */
int _HPGL_A3_devcpy(void);                             /* hpdxy.c         */
int _HPGL_A4_devcpy(void);                             /* hpdxy.c         */
#endif

#ifdef NeXT
int _NeXT_devcpy(void);                                /* NeXT.c          */
#endif

#ifdef POSTSCRIPT
int _CPS_devcpy(void);                                 /* ps.c            */
int _PS_devcpy(void);                                  /* ps.c            */
int _PSP_devcpy(void);                                 /* ps.c            */
int _PCPS_devcpy(void);                                /* ps.c            */
int _LASER_devcpy(void);                               /* ps.c            */
#endif

#ifdef SIGMA
int _sigma_devcpy(void);                               /* sigma.c         */
#endif

#ifdef SUN
int _SUN_devcpy(void);                                 /* sun.c           */
#endif

#ifdef TEK
int _TEK_devcpy(void);                                 /* tek.c           */
#endif

#ifdef VGA
int _vga_devcpy(void);                                 /* vga.c           */
#endif

#ifdef X11
int _X11_devcpy(void);                                 /* X11.c           */
#endif

#endif	/* __PROTOTYPE__ */

/* ---------------------------------------------------------------------
 * Local Variables:
 */
static FILE	*fp        = stdout;
static int	 allocated = 0;
struct vdev	 vdevice;

/* --------------------------------------------------------------------- */

/* device-independent function routines */

/*
 * voutput
 *
 *	redirect output - only for postscript, hpgl (this is not a feature)
 */
void voutput(char *path)
{
char	buf[128];

if ((fp = fopen(path, "w")) == (FILE *)NULL) {
	sprintf(buf, "voutput: couldn't open %s", path);
	verror(buf);
	}
}

/* ------------------------------------------------------------------------ */

/*
 * _voutfile
 *
 *	return a pointer to the current output file - designed for internal
 * use only.
 */
FILE * _voutfile(void)
{
return(fp);
}

/* ------------------------------------------------------------------------ */

/*
 * verror
 *
 *	print an error on the graphics device, and then exit. Only called
 * for fatal errors. We assume that stderr is always there.
 *
 */
void verror(char *str)
{
if (vdevice.initialised)
gexit();

fprintf(stderr, "%s\n", str);
exit(1);
}

/* ------------------------------------------------------------------------ */

/*
 * gexit
 *
 *	exit the vogl/vogle system
 *
 */
void gexit(void)
{
if (!vdevice.initialised)
verror("gexit: vogl not initialised");

(*vdevice.dev.Vexit)();

vdevice.devname = (char *)NULL;
vdevice.initialised = 0;
fp = stdout;
}

/* ------------------------------------------------------------------------ */

/*
 * getdev
 *
 *	get the appropriate device table structure
 */
static void getdev(char *device)
{

#ifdef AMIGA
if      (strncmp(device,"amiga",5) == 0) _AMIGA_devcpy();
else if (strncmp(device,"AMIGA",5) == 0) _AMIGA_devcpy();
else
#endif
#ifdef SUN
if (strncmp(device, "sun", 3) == 0)   _SUN_devcpy();
else
#endif
#ifdef X11
if (strncmp(device, "X11", 3) == 0)   _X11_devcpy();
else
#endif
#ifdef DECX11
if (strncmp(device, "decX11", 6) == 0) _DECX11_devcpy();
else
#endif
#ifdef NeXT
if (strncmp(device, "NeXT", 4) == 0)    _NeXT_devcpy();
else
#endif
#ifdef POSTSCRIPT
if (strncmp(device, "postscript", 10) == 0) {
	_PS_devcpy();
	}
else
if (strncmp(device, "ppostscript", 11) == 0) {
	_PSP_devcpy();
	}
else
#endif
#ifdef HPGL
if (strncmp(device, "hpgla1", 6) == 0)      _HPGL_A1_devcpy();
else if (strncmp(device, "hpgla3", 6) == 0) _HPGL_A3_devcpy();
else if (strncmp(device, "hpgla4", 6) == 0) _HPGL_A4_devcpy();
else if (strncmp(device, "hpgla2", 6) == 0 || strncmp(device, "hpgl", 4) == 0)
_HPGL_A2_devcpy();
else
#endif
#ifdef DXY
if (strncmp(device, "dxy", 3) == 0)         _DXY_devcpy();
else
#endif
#ifdef TEK
if (strncmp(device, "tek", 3) == 0)         _TEK_devcpy();
else
#endif
#ifdef HERCULES
if (strncmp(device, "hercules", 8) == 0)     _hgc_devcpy();
else
#endif
#ifdef CGA
if (strncmp(device, "cga", 3) == 0)          _cga_devcpy();
else
#endif
#ifdef EGA
if (strncmp(device, "ega", 3) == 0)          _ega_devcpy();
else
#endif
#ifdef VGA
if (strncmp(device, "vga", 3) == 0)          _vga_devcpy();
else
#endif
#ifdef SIGMA
if (strncmp(device, "sigma", 5) == 0)        _sigma_devcpy();
else
#endif
{
	if(!device || *device == 0)
	fprintf(stderr,
	   "vogl: expected the enviroment variable VDEVICE to be set to the desired device.\n");
	else fprintf(stderr, "vogl: %s is an invalid device type\n", device);

	fprintf(stderr, "The devices compiled into this library are:\n");
#ifdef SUN
	fprintf(stderr, "sun\n");
#endif
#ifdef AMIGA
	fprintf(stderr,"amiga\n");
#endif
#ifdef X11
	fprintf(stderr, "X11\n");
#endif
#ifdef DECX11
	fprintf(stderr, "decX11\n");
#endif
#ifdef NeXT
	fprintf(stderr, "NeXT\n");
#endif
#ifdef POSTSCRIPT
	fprintf(stderr, "postscript\n");
	fprintf(stderr, "ppostscript\n");
#endif
#ifdef HPGL
	fprintf(stderr, "hpgla1\n");
	fprintf(stderr, "hpgla2 (or hpgl)\n");
	fprintf(stderr, "hpgla3\n");
	fprintf(stderr, "hpgla4\n");
#endif
#ifdef DXY
	fprintf(stderr, "dxy\n");
#endif
#ifdef TEK
	fprintf(stderr, "tek\n");
#endif
#ifdef HERCULES
	fprintf(stderr, "hercules\n");
#endif
#ifdef CGA
	fprintf(stderr, "cga\n");
#endif
#ifdef EGA
	fprintf(stderr, "ega\n");
#endif
#ifdef VGA
	fprintf(stderr, "vga\n");
#endif
#ifdef SIGMA
	fprintf(stderr, "sigma\n");
#endif
	exit(1);
	}
}

/* ------------------------------------------------------------------------ */

/*
 * vinit
 *
 * 	Just set the device name. ginit and winopen are basically
 * the same as the VOGLE the vinit function.
 *
 */
void vinit(char *device)
{
vdevice.devname = device;
}

/* ------------------------------------------------------------------------ */

/*
 * winopen
 *
 *	use the more modern winopen call (this really calls ginit),
 * we use the title if we can
 */
long winopen(char *title)
{

vdevice.wintitle = title;

ginit();

return(1L);
}

/* ------------------------------------------------------------------------ */

/*
 * ginit
 *
 *	by default we check the environment variable, if nothing
 * is set we use the value passed to us by the vinit call.
 */
void ginit(void)
{
char	*dev= NULL;
int	i;


if (vdevice.devname == (char *)NULL) {
	if ((dev = getenv("VDEVICE")) == (char *)NULL) getdev("");
	else                                           getdev(dev);
	}
else                                               getdev(vdevice.devname);

if (vdevice.initialised) gexit();

if (!allocated) {
	allocated              = 1;
	vdevice.transmat       = (Mstack *)vallocate(sizeof(Mstack));
	vdevice.transmat->back = (Mstack *)NULL;
	vdevice.attr           = (Astack *)vallocate(sizeof(Astack));
	vdevice.attr->back     = (Astack *)NULL;
	vdevice.viewport       = (Vstack *)vallocate(sizeof(Vstack));
	vdevice.viewport->back = (Vstack *)NULL;
	vdevice.bases          = (Matrix *)vallocate(sizeof(Matrix) * 10);
	vdevice.enabled        = (char *)vallocate(MAXDEVTABSIZE);
	}

for (i = 0; i < MAXDEVTABSIZE; i++) vdevice.enabled[i] = 0;

vdevice.alreadyread      = vdevice.data        = vdevice.devno     = 0;
vdevice.kbdmode          = vdevice.mouseevents = vdevice.kbdevents = 0;

vdevice.clipoff          = 0;
vdevice.cpW[V_W]         = 1.0;			/* never changes */

vdevice.maxfontnum       = 2;

vdevice.attr->a.fontnum  = 0;
vdevice.attr->a.mode     = 0;
vdevice.attr->a.backface = 0;

if ((*vdevice.dev.Vinit)()) {
	vdevice.initialised = 1;

	viewport((Screencoord)0, (Screencoord)vdevice.sizeSx,
	(Screencoord)0, (Screencoord)vdevice.sizeSy);

	ortho2(0.0, (Coord)vdevice.sizeSx, 0.0, (Coord)vdevice.sizeSy);

	/*
	identmatrix(vdevice.transmat->m);
	_mapmsave(vdevice.transmat->m);
	*/

	move(0.0, 0.0, 0.0);

	font((short) 0);	/* set up default font */

	vdevice.inobject = 0;
	vdevice.inpolygon = 0;
	}
else {
	fprintf(stderr, "vogl: error while setting up device\n");
	exit(1);
	}

vdevice.alreadyread = 0;
vdevice.mouseevents = 0;
vdevice.kbdevents = 0;
vdevice.kbdmode = 0;

vdevice.concave = 0;

}

/* ------------------------------------------------------------------------ */

/*
 * gconfig
 *
 *	thankfully a noop.
 */
void gconfig(void)
{
}

/* ------------------------------------------------------------------------ */

/*
 * vnewdev
 *
 * reinitialize vogl to use a new device but don't change any
 * global attributes like the window and viewport settings.
 */
void vnewdev(char *device)
{
if (!vdevice.initialised)
verror("vnewdev: vogl not initialised\n");

pushviewport();	

(*vdevice.dev.Vexit)();

vdevice.initialised = 0;

getdev(device);

(*vdevice.dev.Vinit)();

vdevice.initialised = 1;

/*
 * Need to update font for this device...
 */
font((short) vdevice.attr->a.fontnum);


popviewport();
}

/* ------------------------------------------------------------------------ */

/*
 * vgetdev
 *
 *	Returns the name of the current vogl device 
 *	in the buffer buf. Also returns a pointer to
 *	the start of buf.
 */
char * vgetdev(char *buf)
{
/*
 * Note no exit if not initialized here - so that gexit
 * can be called before printing the name.
 */
if (vdevice.dev.devname)
strcpy(buf, vdevice.dev.devname);
else
strcpy(buf, "(no device)");

return(&buf[0]);
}

/* ------------------------------------------------------------------------ */

/*
 * getvaluator
 *
 *	similar to the VOGLE locator only it returns either x (MOUSEX) or y (MOUSEY).
 */
long getvaluator(Device dev)
{
int	a, b, c;

if (!vdevice.initialised)
verror("getvaluator: vogl not initialised");

c = (*vdevice.dev.Vlocator)(&a, &b);

if (c != -1) {
	if (dev == MOUSEX)
	return((long)a);
	else 
	return((long)b);
	}

return(-1);
}

/* ------------------------------------------------------------------------ */

/*
 * getbutton
 *
 *	returns the up (or down) state of a button. 1 means down, 0 up,
 * -1 invalid.
 */
Boolean getbutton(Device dev)
{
int	a, b, c;

if (dev < 256) {
	c = (*vdevice.dev.Vcheckkey)();
	if (c >= 'a' && c <= 'z')
	c = c - 'a' + 'A';
	if (c == dev)
	return(1);
	return(0);
	}
else if (dev < 261) {
	c = (*vdevice.dev.Vlocator)(&a, &b);
	if (c & 0x01 && dev == MOUSE3)
	return(1);
	if (c & 0x02 && dev == MOUSE2)
	return(1);
	if (c & 0x04 && dev == MOUSE1)
	return(1);
	return(0);
	}

return(-1);
}

/* ------------------------------------------------------------------------ */

/*
 * clear
 *
 *	clears the screen to the current colour, excepting devices
 * like a laser printer where it flushes the page.
 *
 */
void clear(void)
{
Token	*tok;

if (!vdevice.initialised)
verror("clear: vogl not initialised");

if (vdevice.inobject) {
	tok = newtokens(1);
	tok->i = CLEAR;

	return;
	}

(*vdevice.dev.Vclear)();
}

/* ------------------------------------------------------------------------ */

/*
 * colorf
 *
 *	set the current colour to colour index given by
 * the rounded value of f.
 *
 */
void colorf(float f)
{
color((int)(f + 0.5));
}

/* ------------------------------------------------------------------------ */

/*
 * color
 *
 *	set the current colour to colour index number i.
 *
 */
void color(int i)
{
Token	*tok;

if (!vdevice.initialised)
verror("color: vogl not initialised");

if (vdevice.inobject) {
	tok = newtokens(2);

	tok[0].i = COLOR;
	tok[1].i = i;
	return;
	}

vdevice.attr->a.color = i;
(*vdevice.dev.Vcolor)(i);
}

/* ------------------------------------------------------------------------ */

/*
 * mapcolor
 *
 *	set the color of index i.
 */
void mapcolor(
  Colorindex i,
  short r,
  short g,
  short b)
{
Token	*tok;

if (!vdevice.initialised)
verror("mapcolor: vogl not initialised");

if (vdevice.inobject) {
	tok = newtokens(5);

	tok[0].i = MAPCOLOR;
	tok[1].i = i;
	tok[2].i = r;
	tok[3].i = g;
	tok[4].i = b;

	return;
	}

(*vdevice.dev.Vmapcolor)((int) i, (int) r, (int) g, (int) b);
}

/* ------------------------------------------------------------------------ */

/*
 * getplanes
 *
 *	Returns the number if bit planes on a device.
 */
long getplanes(void)
{
if (!vdevice.initialised)
verror("getdepth: vogl not initialised\n");

return((long)vdevice.depth);
}

/* ------------------------------------------------------------------------ */

/*
 * reshapeviewport
 *		- does nothing
 */
void reshapeviewport(void)
{
}

/* ------------------------------------------------------------------------ */

/*
 * winconstraints
 *		- does nothing
 */
void winconstraints(void)
{
}

/* ------------------------------------------------------------------------ */

/*
 * keepaspect
 *		- does nothing
 */
void keepaspect(void)
{
}

/* ------------------------------------------------------------------------ */

/*
 * shademodel
 *		- does nothing
 */
void shademodel(long model)
{
}

/* ------------------------------------------------------------------------ */

/*
 * getgdesc
 *
 *	Inquire about some stuff....
 */
long getgdesc(long inq)
{
/*
 * How can we know before the device is inited??
 */

switch (inq) {
case GD_XPMAX:
	if (vdevice.initialised) return (long)vdevice.sizeSx;
	else                     return 500L;	/* A bullshit number */
case GD_YPMAX:
	if (vdevice.initialised) return((long)vdevice.sizeSy);
	else                     return 500L;
default:
	return -1L;
	}
/* return -1L; statement never reached */
}

/* ------------------------------------------------------------------------ */

