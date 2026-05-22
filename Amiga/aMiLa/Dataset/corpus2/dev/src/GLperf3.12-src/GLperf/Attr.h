/*
 *   (C) COPYRIGHT International Business Machines Corp. 1993
 *   All Rights Reserved
 *   Licensed Materials - Property of IBM
 *   US Government Users Restricted Rights - Use, duplication or
 *   disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

//
// Permission to use, copy, modify, and distribute this software and its
// documentation for any purpose and without fee is hereby granted, provided
// that the above copyright notice appear in all copies and that both that
// copyright notice and this permission notice appear in supporting
// documentation, and that the name of I.B.M. not be used in advertising
// or publicity pertaining to distribution of the software without specific,
// written prior permission. I.B.M. makes no representations about the
// suitability of this software for any purpose.  It is provided "as is"
// without express or implied warranty.
//
// I.B.M. DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING ALL
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL I.B.M.
// BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
// WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
// OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
// CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//
// Author:  John Spitzer, IBM AWS Graphics Systems (Austin)
//
*/

#ifndef _Attr_h
#define _Attr_h

#include "Global.h"
#include "AttrName.h"
#include "Printf.h"
#ifdef WIN32
#include <windows.h>
#endif
#include <GL/gl.h>

typedef struct _Attribute {
    int type; 
    union {
	int i;
	GLfloat f;
	unsigned u;
	char* s;
	PrintfStringPtr ps;
    } value;
    int linenum;
} Attribute, *AttributePtr;

AttributePtr new_Attribute_Int(int);
AttributePtr new_Attribute_Float(GLfloat);
AttributePtr new_Attribute_String(char*);
AttributePtr new_Attribute_PrintfString(PrintfStringPtr);
void delete_Attribute(AttributePtr);
AttributePtr Attribute__Copy(AttributePtr);
int Attribute__IntOf(AttributePtr, int*);
int Attribute__FloatOf(AttributePtr, GLfloat*);
int Attribute__StringOf(AttributePtr, char**);
int Attribute__PrintfStringOf(AttributePtr, PrintfStringPtr*);
void Attribute__SetLineNum(AttributePtr, int);
int Attribute__GetLineNum(AttributePtr);

#endif
