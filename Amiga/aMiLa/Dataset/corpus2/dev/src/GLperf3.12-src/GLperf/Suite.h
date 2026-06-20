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

#ifndef _Suite_h
#define _Suite_h

#include "Table.h"
#include "Test.h"
#include "TestList.h"
#include "Attr.h"
#include "AttrList.h"
#include "Prop.h"
#include "PropList.h"
#include "Clear.h"
#include "LineLoop.h"
#include "LineStrp.h"
#include "Lines.h"
#include "Points.h"
#include "Polygon.h"
#include "QuadStrp.h"
#include "Quads.h"
#include "Xform.h"
#include "TriFan.h"
#include "TriStrp.h"
#include "Tris.h"
#include "DrawPix.h"
#include "ReadPix.h"
#include "CopyPix.h"
#include "Text.h"
#include "Bitmap.h"
#include "Tex.h"
#include "General.h"
#include "Print.h"
#include "TestName.h"
#include "PropName.h"
#include "Global.h"
#include "AttrName.h"

#define NumLeafClasses 18

typedef struct _Suite {
    TestListPtr masterList[NumLeafClasses];
    TestListPtr sortList[NumLeafClasses];
/* not used 
    TestListPtr suiteList;
*/
} Suite, *SuitePtr;

SuitePtr new_Suite();
void delete_Suite(SuitePtr);
void Suite__ParseGlobal(SuitePtr, PropertyPtr);
void Suite__ParseTest(SuitePtr, int, PropertyListPtr);
void Suite__Run(SuitePtr, int);

extern TablePtr attributes;
extern TablePtr properties;
extern TablePtr tests;
#endif
