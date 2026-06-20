/*
 * (c) Copyright 1996, Silicon Graphics, Inc.
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
 * Author: John Spitzer, SGI Desktop Performance Engineering
 *
 */

#include "Printf.h"
#include <malloc.h>

PrintfStringPtr new_PrintfString(char* stringArg, PropNameListPtr propNameListArg)
{
    PrintfStringPtr this = (PrintfStringPtr)malloc(sizeof(PrintfString));
    CheckMalloc(this);
    this->s = stringArg;
    this->propNameList = propNameListArg;
    return this;
}

void delete_PrintfString(PrintfStringPtr this)
{
  if (this) {
    if (this->s) free(this->s);
    if (this->propNameList) delete_PropNameList(this->propNameList);
    free(this);
  }
}

PrintfStringPtr PrintfString__Copy(PrintfStringPtr this)
{
    PrintfStringPtr newthis = (PrintfStringPtr)malloc(sizeof(PrintfString));
    CheckMalloc(newthis);
    newthis->s = strdup(this->s);
    newthis->propNameList = this->propNameList ? PropNameList__Copy(this->propNameList) : 0;
    return newthis;
}

char* PrintfString__String(PrintfStringPtr this)
{
    return this ? this->s : (char*)0;
}

PropNameListPtr PrintfString__PropNameList(PrintfStringPtr this)
{
    return this ? this->propNameList : (PropNameListPtr)0;
}
