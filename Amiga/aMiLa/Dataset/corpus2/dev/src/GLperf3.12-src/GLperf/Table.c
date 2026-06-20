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
#ifdef WIN32
#include <windows.h>
#endif
#include <string.h>
#include "Table.h"
#include "Global.h"
#include <stdlib.h>
#include <malloc.h>

TablePtr new_Table()
{
    TablePtr this = (TablePtr)malloc(sizeof(Table));
    CheckMalloc(this);
    this->num = 0;
    return this;
}

void delete_Table(TablePtr this)
{
    free(this);
}

int Table__Load(TablePtr this, StringValuePtr load, int n)
{
    this->table = load;
    this->num = n;
    return True;
}

#if defined(VACPP) && defined(__OS2__)
#define BSEARCH_CALLBACK_TYPE _Optlink
#else
#define BSEARCH_CALLBACK_TYPE 
#endif

int  BSEARCH_CALLBACK_TYPE StringValueCmp(const void* arg1, const void* arg2)
{
    return strcmp(*((char**)arg1),*((char**)arg2));
}

int Table__Lookup(TablePtr this, const char* string, int* value)
{
    StringValuePtr found;

    found = (StringValue*)bsearch(&string, this->table, (size_t)(this->num), 
				  sizeof(StringValue), StringValueCmp);
    if (found) {
	*value = found->value;
	return True;
    } else {
	return False;
    }
}

int Table__InverseLookup(TablePtr this, char* string, int value)
{
    /* This will only be done when errors occur, so a slow linear */
    /* search will suffice.                                       */
    int i;
    for (i=0; i<this->num && value != this->table[i].value; i++);
    if (i<this->num) {
	strcpy(string, this->table[i].string);
	return True;
    } else {
	return False;
    }
}
