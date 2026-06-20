#include <stdio.h>

#ifdef SGI
#include "gl.h"
#include "device.h"
#include "hershey.h"
#else
#include "vogl.h"
#include "vodevice.h"
#endif

/*
 * A program showing basic line drawing, hardware text and (if applicable)
 * colour. We set the coordinate system to -1.0 to 1.0 in X and Y.
 */
int main(
  int ac,
  char **av)
{
	char	*p, tmp[2];
	float	cw, ch;
	short	val;

	prefposition(100L, 700L, 100L, 500L);
	winopen("simple");

	if (ac == 2)
		font(atoi(av[1]));	/* change font to the argument */

	color(BLACK);		/* set current color */
	clear();		/* clear screen to current color */

	ortho2(-1.0, 1.0, -1.0, 1.0);	/* set bounds for drawing */

	color(GREEN);
			/* 2 d move to start where we want drawstr to start */
	cmov2(-0.9, 0.9);

	charstr("A Simple Example");	/* draw string in current color */

	/*
	 * the next four lines draw the x 
	 */
	move2(0.0, 0.0);
	draw2(0.76, 0.76);
	move2(0.0, 0.76);
	draw2(0.76, 0.0);

	cmov2(0.0, 0.5);
	charstr("x done");
	charstr("next sentence");

	cmov(0.0, 0.1, -1.0);
	/*
	 * One character at a time...
	 */
	tmp[1] = '\0';
	for (p = "hello world"; *p; p++) {
		tmp[0] = *p;
		charstr(tmp);     
	}

	/*
	 * the next five lines draw the square
	 */
	move2(0.,0.);
	draw2(.76,0.);
	draw2(.76,.76);
	draw2(0.,.76);
	draw2(0.,0.);

	qdevice(KEYBD);		/* enable the keyboard */
	unqdevice(INPUTCHANGE);

	qread(&val);		/* wait for some input */

	gexit();		/* set the screen back to its original state */
}
