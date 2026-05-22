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

#include "TestList.h"
#include <malloc.h>

const int testListInc = 10;

TestListPtr new_TestList()
{
    TestListPtr this = (TestListPtr)malloc(sizeof(TestList));
    CheckMalloc(this);
    this->num = 0;
    this->max = testListInc;
    this->list = (TestPtr*)malloc(sizeof(TestPtr)*this->max);
    CheckMalloc(this->list);
    return this;
}

void delete_TestList(TestListPtr this)
{
    int i;
    for (i=0; i<this->num; i++)
	(*this->list[i]->delete)(this->list[i]);
    free(this->list);
    free(this);
}

int TestList__Size(TestListPtr this)
{
    return this->num;
}

void TestList__AddTest(TestListPtr this, TestPtr t)
{
    if (this->num == this->max) {
	/* Extend list size by testListInc amount */
	this->max += testListInc;
	this->list = (TestPtr*)realloc(this->list, sizeof(TestPtr)*this->max);
    }
    this->list[this->num++] = t;
}

void TestList__AddTestList(TestListPtr this, TestListPtr t1)
{
    int i;
    if (this->num + t1->num > this->max) {
	/* Extend list size to accommodate new list */
	this->max += t1->max;
	this->list = (TestPtr*)realloc(this->list, sizeof(TestPtr)*this->max);
    }
    for (i=0; i<t1->num; i++)
        this->list[i+this->num] = (*t1->list[i]->Copy)(t1->list[i]);
    this->num += t1->num;
}

void TestList__Copy(TestListPtr this, TestListPtr t1)
{
    int i;
    if (t1->num > this->max) {
	/* Extend list size to accommodate copied list */
	this->max = t1->max;
	this->list = (TestPtr*)realloc(this->list, sizeof(TestPtr)*this->max);
    }
    /* We're not freeing the Tests in the destination TestList.here,
       so watch out for memory leakage in the usage of this call */
    for (i=0; i<t1->num; i++)
        this->list[i] = (*t1->list[i]->Copy)(t1->list[i]);
    this->num = t1->num;
}
