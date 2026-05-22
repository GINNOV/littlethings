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

#include "Xform.h"
#include "XformX.h"
#ifdef WIN32
#include <windows.h>
#include <gl\glaux.h>
#elif __amigaos__
#include <gl/glaux.h>
#else
#include "aux.h"
#endif

#undef offset
#define offset(v) offsetof(Transform,v)

static InfoItem TransformInfo[] = {
#define INC_REASON INFO_ITEM_ARRAY
#include "Xform.h"
#undef INC_REASON
};
#include <malloc.h>

TransformPtr new_Transform()
{
    TransformPtr this = (TransformPtr)malloc(sizeof(Transform));
    CheckMalloc(this);
    new_Test((TestPtr)this);
    SetDefaults((TestPtr)this, TransformInfo);
    this->testType = TransformTest;
    this->usecPixelPrint = "";
    this->ratePixelPrint = "";
    this->usecPrint = " microseconds per Transform";
    this->ratePrint = " Transforms per second";
    /* Set virtual functions */
    this->SetState = Transform__SetState;
    this->delete = delete_Transform;
    this->Initialize = Transform__Initialize;
    this->Cleanup = Transform__Cleanup;
    this->SetExecuteFunc = Transform__SetExecuteFunc;
    this->Copy = Transform__Copy;
    this->PixelSize = Transform__Size;
    return this;
}

void delete_Transform(TestPtr thisTest)
{
    TransformPtr this = (TransformPtr)thisTest;
    delete_Test(thisTest);
}

TestPtr Transform__Copy(TestPtr thisTest)
{
    TransformPtr this = (TransformPtr)thisTest;
    TransformPtr newTransform = new_Transform();
    FreeStrings((TestPtr)newTransform);
    *newTransform = *this;
    CopyStrings((TestPtr)newTransform, (TestPtr)this);
    return (TestPtr)newTransform;
}

int Transform__SetState(TestPtr thisTest)
{
    TransformPtr this = (TransformPtr)thisTest;

    /* set parent GL state */
    if (Test__SetState(thisTest) == -1) return -1;

    /* set own state */
    if (this->pointDraw) {
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
    }

    return 0;
}

void Transform__Initialize(TestPtr thisTest)
{
    TransformPtr this = (TransformPtr)thisTest;
    int i;
    int loops = this->loopUnroll;
    GLfloat *ptr;
    GLfloat fraction;


    this->numObjects = 1;
    /* Set the transform data */
    /* Just allocate the maximum amount of memory that's going to be */
    /* used, it's not a lot.                                         */
    this->transformData = (GLfloat*)malloc(sizeof(GLfloat) * 6 * 8);
    ptr = this->transformData;
    switch (this->transformType) {
	case Translate:
	case Scale:
	    for (i=0; i<loops; i++) {
	      if(loops==1)
		fraction = (GLfloat)i/(GLfloat)(loops+1);
	      else
		fraction = (GLfloat)i/(GLfloat)(loops-1);

		*ptr++ = .5 + .1 * fraction;
		*ptr++ = .5 + .1 * fraction;
		*ptr++ = .5 + .1 * fraction;
            }
	    break;
	case Rotate:
	    for (i=0; i<loops; i++) {
	      if(loops==1)
		fraction = (GLfloat)i/(GLfloat)(loops+1);
	      else
		fraction = (GLfloat)i/(GLfloat)(loops-1);

		*ptr++ = 10. + 5. * fraction;
		*ptr++ = .5 + .1 * fraction;
		*ptr++ = .5 + .1 * fraction;
		*ptr++ = .5 + .1 * fraction;
	    }
	    break;
	case Perspective:
	    for (i=0; i<loops; i++) {
	      if(loops==1)
		fraction = (GLfloat)i/(GLfloat)(loops+1);
	      else
		fraction = (GLfloat)i/(GLfloat)(loops-1);
		*ptr++ = 1.0;
		*ptr++ = .5 + .5 * fraction;
		*ptr++ = 50. + 50. * fraction;
	    }
	    break;
	case Ortho:
	case Frustum:
	    for (i=0; i<loops; i++) {
	      if(loops==1)
		fraction = (GLfloat)i/(GLfloat)(loops+1);
	      else
		fraction = (GLfloat)i/(GLfloat)(loops-1);

		*ptr++ = -.5 - .5 * fraction;
		*ptr++ =  .5 + .5 * fraction;
		*ptr++ = -.5 - .5 * fraction;
		*ptr++ =  .5 + .5 * fraction;
		*ptr++ =  .5 + .5 * fraction;
		*ptr++ = 50. + 50. * fraction;
	    }
	    break;
	case Ortho2:
	    for (i=0; i<loops; i++) {
	      if(loops==1)
		fraction = (GLfloat)i/(GLfloat)(loops+1);
	      else
		fraction = (GLfloat)i/(GLfloat)(loops-1);

		*ptr++ = -.5 - .5 * fraction;
		*ptr++ =  .5 + .5 * fraction;
		*ptr++ = -.5 - .5 * fraction;
		*ptr++ =  .5 + .5 * fraction;
	    }
	    break;
  }
}

void Transform__Cleanup(TestPtr thisTest)
{
    TransformPtr this = (TransformPtr)thisTest;

    if(this->transformData)
      free(this->transformData);
}

void Transform__SetExecuteFunc(TestPtr thisTest)
{
    TransformPtr this = (TransformPtr)thisTest;
    TransformFunc function;

    function.word = 0;

    function.bits.transform = this->transformType;
    function.bits.pushPop = this->pushPop;
    function.bits.pointDraw = this->pointDraw;
    function.bits.functionPtrs = this->loopFuncPtrs;
    function.bits.unrollAmount  = this->loopUnroll - 1;

    this->Execute = TransformExecuteTable[function.word];
}

float Transform__Size(TestPtr thisTest)
{
    return 0.;
}
