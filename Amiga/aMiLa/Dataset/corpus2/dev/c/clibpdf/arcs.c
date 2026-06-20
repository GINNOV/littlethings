/* Arcs.c -- Test program for arc and circle functions.
 * Copyright (C) 1998 FastIO Systems, All Rights Reserved.
 * For conditions of use, license, and distribution, see LICENSE.txt or LICENSE.pdf.

cc -Wall -o Arcs Arcs.c -I/usr/local/include -lcpdf

*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "cpdflib.h"

void main(int argc, char *argv[])
{
int i;
float radius= 2.2;
float rbump = 0.1;
float xorig = 2.5, yorig = 2.5;
// float xorig = 0.0, yorig = 0.0;
float sangle, eangle;
float greenblue = 1.0;

    /* == Initialization == */
    cpdf_open(0);
    cpdf_enableCompression(YES);		/* use Flate/Zlib compression */
    cpdf_init();
    cpdf_pageInit(1, PORTRAIT, LETTER, LETTER);		/* page orientation */

    /* == Simple graphics drawing example == */
    cpdf_setgrayStroke(0.0);	/* black as stroke color */
    cpdf_comments("\n%% one circle.\n");
    cpdf_circle(xorig, yorig, radius);
    cpdf_stroke();			/* even-odd fill and stroke*/

    /* Just a bunch of blue arcs */
    cpdf_setrgbcolorStroke(0.0, 0.0, 1.0);	/* blue as stroke color */
    cpdf_comments("\n%% Arcs from 30 to various angles in 30 deg steps.\n");
    for(i=11; i>=0; i--) {
	radius -= rbump;
	eangle = (float)(i+1)*30.0;		/* end angle */
	sangle = 0.0;
	cpdf_arc(xorig, yorig, radius, sangle, eangle, 1);	/* moveto to starting point of arc */
	cpdf_stroke();
    }

    yorig = 7.5;
    radius= 2.2;
    cpdf_setgrayStroke(0.0);	/* black as stroke color */
    cpdf_comments("\n%% one circle again.\n");
    cpdf_circle(xorig, yorig, radius);
    cpdf_stroke();			/* even-odd fill and stroke*/

    /* Now, do progressively redder pie shapes from large ones to small */
    cpdf_setrgbcolorStroke(0.7, 0.7, 0.0);	/* yellow as stroke color */
    cpdf_comments("\n%% Pie-shapes from 30 to various angles in 30 deg steps.\n");
    for(i=11; i>=0; i--) {
	radius -= rbump;
	greenblue = (float)i/12.0;
	cpdf_setrgbcolorFill(1.0, greenblue, greenblue);
	eangle = (float)(i+1)*30.0;		/* end angle */
	sangle = 0.0;
	cpdf_moveto(xorig, yorig);
	cpdf_arc(xorig, yorig, radius, sangle, eangle, 0);	/* lineto to start of arc */
	cpdf_closepath();
        cpdf_fillAndStroke();			/* fill and stroke */
    }

    /* Demonstration for non-zero winding rule for fill operator */
    xorig = 6.0;
    yorig = 2.5;
    cpdf_setgrayStroke(0.0);				/* Black */
    cpdf_setrgbcolorFill(0.6, 0.6, 1.0);
    cpdf_arc(xorig, yorig, 0.5, 0.0, 360.0, 1); cpdf_closepath();  /* CCW */
    cpdf_arc(xorig, yorig, 1.0, 0.0, 360.0, 1); cpdf_closepath();  /* CCW */
    cpdf_fillAndStroke();
    cpdf_setgrayFill(0.0);
    cpdf_pointer(xorig+0.5, yorig, PTR_UP, 8.0);
    cpdf_pointer(xorig-0.5, yorig, PTR_DOWN, 8.0);
    cpdf_pointer(xorig+1.0, yorig, PTR_UP, 8.0);
    cpdf_pointer(xorig-1.0, yorig, PTR_DOWN, 8.0);

    xorig = 6.0;
    yorig = 7.5;
    cpdf_setrgbcolorFill(0.6, 0.6, 1.0);
    cpdf_arc(xorig, yorig, 0.5, 360.0, 0.0, 1); cpdf_closepath();  /* CW */
    cpdf_arc(xorig, yorig, 1.0, 0.0, 360.0, 1); cpdf_closepath();  /* CCW */
    cpdf_fillAndStroke();
    cpdf_setgrayFill(0.0);
    cpdf_pointer(xorig+0.5, yorig, PTR_DOWN, 8.0);
    cpdf_pointer(xorig-0.5, yorig, PTR_UP, 8.0);
    cpdf_pointer(xorig+1.0, yorig, PTR_UP, 8.0);
    cpdf_pointer(xorig-1.0, yorig, PTR_DOWN, 8.0);

    /* == Text examples == */
    // cpdf_setgrayFill(0.0);				/* Black */
    cpdf_beginText(0);
    cpdf_setFont("Times-Italic", "MacRomanEncoding", 16.0);
    cpdf_text(1.6, 2.0, 0.0, "Test of arcs and circles");	/* cpdf_text() may be repeatedly used */
    cpdf_text(1.6, 7.0, 0.0, "Color filled pie shapes");	/* cpdf_text() may be repeatedly used */
    cpdf_text(4.7, 5.0, 0.0, "Non-zero winding rule for fill");	/* cpdf_text() may be repeatedly used */
    cpdf_endText();

    cpdf_finalizeAll();			/* PDF file/memstream is actually written here */
    cpdf_savePDFmemoryStreamToFile("arctest.pdf");

    /* == Clean up == */
    cpdf_close();			/* shut down */
    cpdf_launchPreview();		/* launch Acrobat/PDF viewer on the output file */
}

