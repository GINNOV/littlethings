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

#include "PropList.h"
#include <malloc.h>

const int propListInc = 10;

PropertyListPtr new_PropertyList()
{
    PropertyListPtr this = (PropertyListPtr)malloc(sizeof(PropertyList));
    CheckMalloc(this);
    this->num = 0;
    this->max = propListInc;
    this->list = (PropertyPtr*)malloc(sizeof(PropertyPtr)*this->max);
    CheckMalloc(this->list);
    return this;
}

void delete_PropertyList(PropertyListPtr this)
{
    int i;
    for (i=0; i<this->num; i++)
	delete_Property(this->list[i]);
    free(this->list);
    free(this);
}

int PropertyList__Size(PropertyListPtr this)
{
    return this->num;
}

void PropertyList__AddProperty(PropertyListPtr this, PropertyPtr p)
{
    if (this->num == this->max) {
        /* Extend list size by propListInc amount */
        this->max += propListInc;
        this->list = (PropertyPtr*)realloc(this->list, sizeof(PropertyPtr)*this->max);
    }
    this->list[this->num++] = p;
}
