/*
//   (C) COPYRIGHT International Business Machines Corp. 1993
//   All Rights Reserved
//   Licensed Materials - Property of IBM
//   US Government Users Restricted Rights - Use, duplication or
//   disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
//

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

#include "Attr.h"
#include <malloc.h>
#include <math.h>

AttributePtr new_Attribute_Int(int i)
{
    AttributePtr this = (AttributePtr)malloc(sizeof(Attribute));
    CheckMalloc(this);
    this->type = Int;
    this->value.i = i;
    this->linenum = 0;
    return this;
}

AttributePtr new_Attribute_Float(GLfloat f)
{
    AttributePtr this = (AttributePtr)malloc(sizeof(Attribute));
    CheckMalloc(this);
    this->type = Float;
    this->value.f = f;
    this->linenum = 0;
    return this;
}

AttributePtr new_Attribute_String(char* s)
{
    AttributePtr this = (AttributePtr)malloc(sizeof(Attribute));
    CheckMalloc(this);
    this->type = String;
    this->value.s = (char*)malloc(strlen(s)+1);
    CheckMalloc(this->value.s);
    strcpy(this->value.s, s);
    this->linenum = 0;
    return this;
}

AttributePtr new_Attribute_PrintfString(PrintfStringPtr printfString)
{
    AttributePtr this = (AttributePtr)malloc(sizeof(Attribute));
    CheckMalloc(this);
    this->type = PrintFString;
    this->value.ps = PrintfString__Copy(printfString);
    this->linenum = 0;
    return this;
}

void delete_Attribute(AttributePtr this)
{
    if (this->type == String) free(this->value.s);
    if (this->type == PrintFString) {
        if (this->value.ps) delete_PrintfString(this->value.ps);
    }
    free(this);
}

Attribute* Attribute__Copy(AttributePtr this)
{
    AttributePtr newAttribute = new_Attribute_Int((int)0);
    newAttribute->type = this->type;
    switch(this->type){
    case Int:
      newAttribute->value.i = this->value.i;
      break;
    case Float:
      newAttribute->value.f = this->value.f;
      break;
    case Unsigned:
      newAttribute->value.u = this->value.u;
      break;
    case String:
      newAttribute->value.s = strdup(this->value.s);
      break;
    case PrintFString:
      newAttribute->value.ps = PrintfString__Copy(this->value.ps);
      break;
    default:
      fprintf(stderr, "Attribute__Copy: unknown type = %d, exiting...\n",
              this->type);
      exit(1);
      break;
    }
    newAttribute->linenum = 0;
    return newAttribute;
}

int Attribute__IntOf(AttributePtr this, int* i)
{
    switch (this->type) {
	case Float:
	    if (floor(this->value.f)-this->value.f==0.0) {
		*i = (int)this->value.f;
		return True;
	    } else {
		return False;
	    }
	case Int:
	    *i = this->value.i;
	    return True;
	case Unsigned:
	    *i = (int)this->value.u;
	    return True;
    }
    return False;
}

int Attribute__FloatOf(AttributePtr this, GLfloat* f)
{
    switch (this->type) {
	case Float:
	    *f = this->value.f;
	    return True;
	case Int:
	    *f = (GLfloat)this->value.i;
	    return True;
	case Unsigned:
	    return False;
    }
    return False;
}

int Attribute__StringOf(AttributePtr this, char** s)
{
    if (this->type==String) {
	*s = this->value.s;
	return True;
    } else {
	return False;
    }
}

int Attribute__PrintfStringOf(AttributePtr this, PrintfStringPtr* printfString)
{
    if (this->type==PrintFString) {
	*printfString = this->value.ps;
	return True;
    } else {
	return False;
    }
}

void Attribute__SetLineNum(AttributePtr this, int linenum)
{
    if (this) this->linenum = linenum;
}

int Attribute__GetLineNum(AttributePtr this)
{
    return this ? this->linenum : 0;
}
