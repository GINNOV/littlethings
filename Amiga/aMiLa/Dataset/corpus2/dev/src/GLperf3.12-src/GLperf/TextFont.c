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

#include "TextFont.h"
#include "Global.h"
#include "AttrName.h"

extern BitmapFontRec bitmap8By13;
extern BitmapFontRec bitmap9By15;
extern BitmapFontRec bitmapTimesRoman10;
extern BitmapFontRec bitmapTimesRoman24;
extern BitmapFontRec bitmapHelvetica10;
extern BitmapFontRec bitmapHelvetica12;
extern BitmapFontRec bitmapHelvetica18;

typedef struct _GLperfFont {
    int name;
    BitmapFontPtr fontPtr;
} GLperfFont, *GLperfFontPtr;

static GLperfFont fonts[] = {
    { f8x13, &bitmap8By13 },
    { f9x15, &bitmap9By15 },
    { timR10, &bitmapTimesRoman10 },
    { timR24, &bitmapTimesRoman24 },
    { helvR10, &bitmapHelvetica10 },
    { helvR12, &bitmapHelvetica12 },
    { helvR18, &bitmapHelvetica18 }
};

TextFontPtr new_TextFont(int fontName)
{
    TextFontPtr this = (TextFontPtr)malloc(sizeof(TextFont));
    int i;
    BitmapFontPtr fontPtr;

    for (i = 0; i < sizeof(fonts) / sizeof(GLperfFont) && fonts[i].name != fontName; i++);
    if (fonts[i].name != fontName) {
	printf("GLperf: error in finding font\n");
	exit(1);
    }

    fontPtr = fonts[i].fontPtr;

    this->base = glGenLists((GLsizei)256);
    if (this->base == 0) {
        printf("GLperf: out of display lists\n");
        exit(1);
    }
    
    for (i = 0; i < fontPtr->first; i++) {
	glNewList(this->base + i, GL_COMPILE);
	/* Empty list */
	glEndList();
    }

    glPixelStorei(GL_UNPACK_SWAP_BYTES, GL_FALSE);
    glPixelStorei(GL_UNPACK_LSB_FIRST, GL_FALSE);
    glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
    glPixelStorei(GL_UNPACK_SKIP_ROWS, 0);
    glPixelStorei(GL_UNPACK_SKIP_PIXELS, 0);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

    for (i = fontPtr->first; i < fontPtr->first + fontPtr->num_chars; i++) {
	BitmapCharPtr ch;

	glNewList(this->base + i, GL_COMPILE);
	if (ch = fontPtr->ch[i - fontPtr->first]) {
	    glBitmap(ch->width, ch->height, (GLfloat)ch->xorig, (GLfloat)ch->yorig,
                     (GLfloat)ch->advance, (GLfloat)0, ch->bitmap);
	}
	glEndList();
    }

    for (i = fontPtr->first + fontPtr->num_chars; i < 256; i++) {
	glNewList(this->base + i, GL_COMPILE);
	/* Empty list */
	glEndList();
    }

    this->fontPtr = fontPtr;

    return this;
}

void delete_TextFont(TextFontPtr this)
{
    glDeleteLists(this->base, 256);
    free(this);
}

GLuint TextFont__GetBase(TextFontPtr this)
{
    return this->base;
}

void TextFont__StringSize(TextFontPtr this, char* string, GLint *width, GLint *widthPad, 
                                        GLint *height, GLint *heightPad)
{
    char *p;
    int leftmost = 9999;
    int lowermost = 9999;
    int rightmost = -9999;
    int uppermost = -9999;
    int x = 0;
    int y = 0;
    BitmapCharPtr ch;

    if (string == 0) {
	*height = 0;
        *heightPad = 0;
        *width = 0;
        *widthPad = 0;
	return;
    }

    for (p = string; *p; p++) {
	if (ch = this->fontPtr->ch[*p]) {
	    leftmost = min(x - ch->xorig, leftmost);
	    lowermost = min(y - ch->yorig, lowermost);
	    rightmost = max(x - ch->xorig + ch->width, rightmost);
	    uppermost = max(y - ch->yorig + ch->height, uppermost);
	    x += ch->advance;
	}
    }

    *height = uppermost - lowermost;
    *heightPad = lowermost;
    *width = rightmost - leftmost + 1;
    *widthPad = leftmost;
}
