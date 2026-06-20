#include <stdio.h>
#include "vogl.h"

/* ---------------------------------------------------------------------
 * Prototypes:
 */
#ifdef __PROTOTYPE__
static void copyattributes( Attribute *,               /* attr.c          */
   Attribute *);
#else
static void copyattributes();                          /* attr.c          */
#endif

/* ---------------------------------------------------------------------
 * Local Variables:
 */
static	Astack	*asfree =  (Astack *) NULL;

/* --------------------------------------------------------------------- */

/*
 * copyattributes
 *
 *  Copies attribute stack entries from b to a
 */
static void copyattributes(
  Attribute *a,
  Attribute *b)
{
a->color = b->color;
a->fontwidth = b->fontwidth;
a->fontheight = b->fontheight;
a->fontnum = b->fontnum;
}

/* ------------------------------------------------------------------------ */

/*
 * pushattributes
 *
 * save the current attributes on the matrix stack
 *
 */
void pushattributes(void)
{
Astack	*nattr;
Token	*p;

if (!vdevice.initialised)
verror("pushattributes:  vogl not initialised");

if (vdevice.inobject) {
	p = newtokens(1);

	p[0].i = PUSHATTRIBUTES;

	return;
	}

if (asfree != (Astack *)NULL) {
	nattr = vdevice.attr;
	vdevice.attr = asfree;
	asfree = asfree->back;
	vdevice.attr->back = nattr;
	copyattributes(&vdevice.attr->a, &nattr->a);
	}
else {
	nattr = (Astack *)vallocate(sizeof(Astack));
	nattr->back = vdevice.attr;
	copyattributes(&nattr->a, &vdevice.attr->a);
	vdevice.attr = nattr;
	}
}

/* ------------------------------------------------------------------------ */

/*
 * popattributes
 *
 * pop the top entry on the attribute stack 
 *
 */
void popattributes(void)
{
Astack	*nattr;
Token	*p;

if (!vdevice.initialised)
verror("popattributes: vogl not initialised");

if (vdevice.inobject) {
	p = newtokens(1);

	p[0].i = POPATTRIBUTES;

	return;
	}

if (vdevice.attr->back == (Astack *)NULL) 
verror("popattributes: attribute stack is empty");
else {
	font((short) vdevice.attr->back->a.fontnum);
	nattr = vdevice.attr;
	vdevice.attr = vdevice.attr->back;
	nattr->back = asfree;
	asfree = nattr;
	}

color(vdevice.attr->a.color);
}

/* ------------------------------------------------------------------------ */

#ifdef	DEBUG

int printattribs(char *s)
{
printf("%s\n", s);
printf("clipoff    = %d\n", vdevice.clipoff);
printf("color      = %d\n", vdevice.attr->a.color);
printf("textcos    = %f\n", vdevice.attr->a.textcos);
printf("textsin    = %f\n", vdevice.attr->a.textsin);
printf("fontwidth  = %f\n", vdevice.attr->a.fontwidth);
printf("fontwidth  = %f\n", vdevice.attr->a.fontheight);
printf("fontnum    = %d\n", vdevice.attr->a.fontnum);
printf("mode       = %d\n", vdevice.attr->a.mode);
}

/* ------------------------------------------------------------------------ */

#endif
