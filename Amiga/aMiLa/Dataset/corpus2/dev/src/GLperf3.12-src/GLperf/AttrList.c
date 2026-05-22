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

#include "AttrList.h"
#include <malloc.h>

const int attrListInc = 10;

AttributeListPtr new_AttributeList()
{
    AttributeListPtr this = (AttributeListPtr)malloc(sizeof(AttributeList));
    CheckMalloc(this);
    this->num = 0;
    this->max = attrListInc;
    this->list = (AttributePtr*)malloc(sizeof(AttributePtr)*this->max);
    CheckMalloc(this->list);
    return this;
}

void delete_AttributeList(AttributeListPtr this)
{
    int i;
    for (i=0; i<this->num; i++)
        delete_Attribute(this->list[i]);
    free(this->list);
    free(this);
}

int AttributeList__Size(AttributeListPtr this)
{
    return this->num;
}

AttributeListPtr AttributeList__Copy(AttributeListPtr this)
{
    int i;
    AttributeListPtr newthis = (AttributeListPtr)malloc(sizeof(AttributeList));
    CheckMalloc(this);
    newthis->num = this->num;
    newthis->max = this->max;
    newthis->list = (AttributePtr*)malloc(sizeof(AttributePtr)*newthis->max);
    CheckMalloc(newthis->list);
    for (i=0; i<this->num; i++)
	newthis->list[i] = Attribute__Copy(this->list[i]);
    return newthis;
}

void AttributeList__AddAttribute(AttributeListPtr this, AttributePtr t)
{
    if (this->num == this->max) {
        /* Extend list size by attrListInc amount */
        this->max += attrListInc;
        this->list = (AttributePtr*)realloc(this->list, sizeof(AttributePtr)*this->max);
    }
    this->list[this->num++] = t;
}
