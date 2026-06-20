/*
 * (c) Copyright 1995, Silicon Graphics, Inc.
 * ALL RIGHTS RESERVED
 * Permission to use, copy, modify, and distribute this software for
 * any purpose and without fee is hereby granted, provided that the above
 * copyright notice appear in all copies and that both the copyright notice
 * and this permission notice appear in supporting documentation, and that
 * the name of Silicon Graphics, Inc. not be used in advertising
 * or publicity pertaining to distribution of the software without specific,
 * written prior permission.
 *
 * THE MATERIAL EMBODIED ON THIS SOFTWARE IS PROVIDED TO YOU "AS-IS"
 * AND WITHOUT WARRANTY OF ANY KIND, EXPRESS, IMPLIED OR OTHERWISE,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY OR
 * FITNESS FOR A PARTICULAR PURPOSE.  IN NO EVENT SHALL SILICON
 * GRAPHICS, INC.  BE LIABLE TO YOU OR ANYONE ELSE FOR ANY DIRECT,
 * SPECIAL, INCIDENTAL, INDIRECT OR CONSEQUENTIAL DAMAGES OF ANY
 * KIND, OR ANY DAMAGES WHATSOEVER, INCLUDING WITHOUT LIMITATION,
 * LOSS OF PROFIT, LOSS OF USE, SAVINGS OR REVENUE, OR THE CLAIMS OF
 * THIRD PARTIES, WHETHER OR NOT SILICON GRAPHICS, INC.  HAS BEEN
 * ADVISED OF THE POSSIBILITY OF SUCH LOSS, HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, ARISING OUT OF OR IN CONNECTION WITH THE
 * POSSESSION, USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 * US Government Users Restricted Rights
 * Use, duplication, or disclosure by the Government is subject to
 * restrictions set forth in FAR 52.227.19(c)(2) or subparagraph
 * (c)(1)(ii) of the Rights in Technical Data and Computer Software
 * clause at DFARS 252.227-7013 and/or in similar or successor
 * clauses in the FAR or the DOD or NASA FAR Supplement.
 * Unpublished-- rights reserved under the copyright laws of the
 * United States.  Contractor/manufacturer is Silicon Graphics,
 * Inc., 2011 N.  Shoreline Blvd., Mountain View, CA 94039-7311.
 *
 * Author: John Spitzer, SGI Applied Engineering
 *
 */
{
	TYPE *ptr;
	int i,j;
        int elemSize = sizeof(TYPE);
        int rowsize = (iwidth * elemSize + alignment - 1) / alignment * alignment;
	imageSize = rowsize * iheight * sizeof(GLbyte);
        image = (void*)AlignMalloc(imageSize, memAlign);
        CheckMalloc(image);
	for (j = 0; j < iheight; j++) {
            ptr = (TYPE*)((char*)image + j * rowsize);
	    for (i = 0; i < iwidth; i++) {
		GLfloat x =(iwidth==1)?1:((GLfloat)i / (GLfloat)(iwidth-1));
		GLfloat y =(iheight==1)?1:((GLfloat)j / (GLfloat)(iheight-1));
		*ptr++ = (GLuint)(CalcComp(x, y, 0) * 4294967295.) >> RED_SHIFT   & RED_MASK   |
		         (GLuint)(CalcComp(x, y, 1) * 4294967295.) >> GREEN_SHIFT & GREEN_MASK |
		         (GLuint)(CalcComp(x, y, 2) * 4294967295.) >> BLUE_SHIFT  & BLUE_MASK  |
		         (GLuint)(CalcComp(x, y, 3) * 4294967295.) >> ALPHA_SHIFT & ALPHA_MASK;
	    }
	}
}
