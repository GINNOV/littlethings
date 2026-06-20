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
#include <gl\glaux.h>
#elif __amigaos__
#include <gl/glaux.h>
#else
#include "aux.h"
#endif

#include "Suite.h"
#include <malloc.h>

extern int yylineno;

SuitePtr new_Suite()
{
    SuitePtr this = (SuitePtr)malloc(sizeof(Suite));
    int i;
    CheckMalloc(this);
    /* initialize masterList to one instantiation of each leaf class */
    for (i=0; i<NumLeafClasses; i++) {
	this->masterList[i] = new_TestList();
	this->sortList[i] = new_TestList();
    }
    TestList__AddTest(this->masterList[ClearTest         - ClearTest], (TestPtr) new_Clear());
    TestList__AddTest(this->masterList[TransformTest     - ClearTest], (TestPtr) new_Transform());
    TestList__AddTest(this->masterList[PointsTest        - ClearTest], (TestPtr) new_Points());
    TestList__AddTest(this->masterList[LinesTest         - ClearTest], (TestPtr) new_Lines());
    TestList__AddTest(this->masterList[LineLoopTest      - ClearTest], (TestPtr) new_LineLoop());
    TestList__AddTest(this->masterList[LineStripTest     - ClearTest], (TestPtr) new_LineStrip());
    TestList__AddTest(this->masterList[TrianglesTest     - ClearTest], (TestPtr) new_Triangles());
    TestList__AddTest(this->masterList[TriangleStripTest - ClearTest], (TestPtr) new_TriangleStrip());
    TestList__AddTest(this->masterList[TriangleFanTest   - ClearTest], (TestPtr) new_TriangleFan());
    TestList__AddTest(this->masterList[QuadsTest         - ClearTest], (TestPtr) new_Quads());
    TestList__AddTest(this->masterList[QuadStripTest     - ClearTest], (TestPtr) new_QuadStrip());
    TestList__AddTest(this->masterList[PolygonTest       - ClearTest], (TestPtr) new_Polygon());
    TestList__AddTest(this->masterList[DrawPixelsTest    - ClearTest], (TestPtr) new_DrawPixels());
    TestList__AddTest(this->masterList[CopyPixelsTest    - ClearTest], (TestPtr) new_CopyPixels());
    TestList__AddTest(this->masterList[BitmapTest        - ClearTest], (TestPtr) new_Bitmap());
    TestList__AddTest(this->masterList[TextTest          - ClearTest], (TestPtr) new_Text());
    TestList__AddTest(this->masterList[ReadPixelsTest    - ClearTest], (TestPtr) new_ReadPixels());
    TestList__AddTest(this->masterList[TexImageTest      - ClearTest], (TestPtr) new_TexImage());
    return this;
}

void delete_Suite(SuitePtr this)
{
    int i;
    for (i=0; i<NumLeafClasses; i++) {
	delete_TestList(this->masterList[i]);
	delete_TestList(this->sortList[i]);
    }
    free(this);
    auxQuit();
}

void Suite__ParseGlobal(SuitePtr this, PropertyPtr prop)
{
    int i, j, k, l;
    TestPtr t, t_new;
    TestListPtr oldList,newList;
    AttributePtr attr;
    int invalidProperty;
    int validProperty = False;
    int ivalue;
    PropNameListPtr propNameList = prop->propNameList;
    AttributeListPtr attrList = prop->attrList;
    AttributeListPtr allAttrList;
    TestListPtr *masterList = this->masterList;
    char badProp[128];

    for (i=ClearTest; i<ClearTest+NumLeafClasses; i++) {
	oldList = masterList[i];
	newList = new_TestList();
	invalidProperty = False;
        t = NULL;
	for (j=0; j < TestList__Size(oldList) && !invalidProperty; j++) {
	    t = oldList->list[j];
	    if (AttributeList__Size(attrList) == 1 && 
                Attribute__IntOf(attrList->list[0], &ivalue) && 
                ivalue == WildCard) {
		if (PropNameList__Size(propNameList) > 1) {
		    printf("GLperf: Line %d, wildcard not valid for multiple properties\n", Attribute__GetLineNum(attrList->list[0]));
		    exit(1);
		}
		if (!(allAttrList = GetAllAttrs(t, propNameList->list[0]))) {
		    invalidProperty = True;
		} else {
		    delete_AttributeList(attrList);
		    attrList = prop->attrList = allAttrList;
		    validProperty = True;
		}
	    }
	    for (k=0; k < AttributeList__Size(attrList) && !invalidProperty; k++) {
		int addTest = -1; /* Neither True nor False */
		attr = attrList->list[k];
		t_new = (*t->Copy)(t);
		for (l = 0; l < PropNameList__Size(propNameList); l++) {
                    switch (Apply(t_new, propNameList->list[l], attr)) {
                        case InvalidProperty:
                            invalidProperty = True;
			    addTest = False;
			    /* Delay deleting test until all properties are done */
                            break;
                        case InvalidValue:
                            if (Table__InverseLookup(properties, badProp, propNameList->list[l])) {
                                printf("GLperf: Line %d, value not valid for property \"%s\"\n", propNameList->linenum[l], badProp);
                            } else {
                                printf("GLperf: Line %d, value not valid for unknown property\n", propNameList->linenum[l]);
                            }
                            exit(1);
                            break;
                        case ApplySuccessful:
                            validProperty = True;
			    addTest = (addTest == False) ? False : True;
			    /* Delay adding test until all properties are done */
                            break;
                        case PropertyNotSettable:
                            printf("GLperf: Line %d, property not user settable\n", propNameList->linenum[l]);
			    exit(1);
                            break;
                    }
                }
		if (addTest == True) {
		    TestList__AddTest(newList, t_new);
		} else if (addTest == False) {
		    (*t_new->delete)(t_new);
		}
	    }
	}
	if (TestList__Size(newList)) {
	    delete_TestList(oldList);
	    masterList[i] = newList;
	} else {
	    delete_TestList(newList);
	}
    }
    if (!validProperty) {
	if (Table__InverseLookup(properties, badProp, propNameList->list[0])) {
	    printf("GLperf: Line %d, wildcard attribute not valid for property \"%s\"\n", propNameList->linenum[l], badProp);
	} else {
	    printf("GLperf: Line %d, wildcard attribute not valid for unknown property\n", propNameList->linenum[l]); 
	}
	exit(1);
    }
    delete_Property(prop);
}

void Suite__ParseTest(SuitePtr this, int testType, PropertyListPtr propList)
{
    int i, j, k, l;
    TestPtr t, t_new;
    TestListPtr oldList,newList;
    PropertyPtr property;
    PropNameListPtr propNameList;
    int ivalue;
    AttributePtr attr;
    AttributeListPtr attrList;
    TestListPtr *sortList = this->sortList;
    TestListPtr *masterList = this->masterList;
    char badProp[128];
    char badTest[128];
    char badAttr[128];

    oldList = new_TestList();
    TestList__Copy(oldList, masterList[testType - ClearTest]);
    if (propList) {
        for (i=0; i<PropertyList__Size(propList); i++) {
            property = propList->list[i];
            propNameList = property->propNameList;
            attrList = property->attrList;
            newList = new_TestList();
            for (j=0; j < TestList__Size(oldList); j++) {
                t = oldList->list[j];
                if (AttributeList__Size(attrList) == 1 && 
                    Attribute__IntOf(attrList->list[0], &ivalue) && 
                    ivalue == WildCard) {
                    if (PropNameList__Size(propNameList) > 1) {
                        printf("GLperf: Line %d, wildcard not valid for multiple properties\n", propNameList->linenum[0]);
                        exit(1);
                    }
                    delete_AttributeList(attrList);
                    if (!(attrList = property->attrList = GetAllAttrs(t, propNameList->list[0]))) {
			if (Table__InverseLookup(properties, badProp, propNameList->list[0])) {
	    		    printf("GLperf: Line %d, wildcard attribute not valid for property \"%s\"\n", propNameList->linenum[0], badProp);
			} else {
	    		    printf("GLperf: Line %d, wildcard attribute not valid for unknown property\n", propNameList->linenum[0]); 
			}
                        exit(1);
                    }
                }
                for (k=0; k < AttributeList__Size(attrList); k++) {
                    attr = attrList->list[k];
                    t_new = t->Copy(t);
		    for (l = 0; l < PropNameList__Size(propNameList); l++) {
                        switch (Apply(t_new, propNameList->list[l], attr)) {
                            case InvalidProperty:
			        if (Table__InverseLookup(properties, badProp, propNameList->list[l]) &&
                                    Table__InverseLookup(tests, badTest, testType)) {
	    		            printf("GLperf: Line %d, property \"%s\" not valid for %s\n", propNameList->linenum[l], badProp, badTest);
			        } else {
	    		            printf("GLperf: Line %d, invalid property\n", propNameList->linenum[l]); 
			        }
                                exit(1);
                                break;
                            case InvalidValue:
			        if (Table__InverseLookup(properties, badProp, propNameList->list[l])) {
	    		            printf("GLperf: Line %d, value not valid for property \"%s\"\n", propNameList->linenum[l], badProp);
			        } else {
	    		            printf("GLperf: Line %d, value not valid for unknown property\n", propNameList->linenum[l]); 
			        }
                                exit(1);
                                break;
                            case ApplySuccessful:
				/* Don't add list yet, wait for all properties to complete */
                                break;
                            case PropertyNotSettable:
                                printf("GLperf: Line %d, property not user settable\n", propNameList->linenum[l]);
			        exit(1);
                                break;
		        }
                    }
                    TestList__AddTest(newList, t_new);
                }
            }
            if (TestList__Size(newList)) {
                delete_TestList(oldList);
                oldList = newList;
            } else {
                delete_TestList(newList);
            }   
        }  /* end for */
        delete_PropertyList(propList);
    } /* end if */
    TestList__AddTestList(sortList[testType - ClearTest], oldList);
    delete_TestList(oldList);
}
 
void Suite__Run(SuitePtr this, int printMode)
{
    Visual_ID prevVisual = NoVisual; /* This data must be maintained across tests */
    GLenum prevWindType = -1;
    int prevWinW   = -1;       /* Ditto                                     */
    int prevWinH   = -1;       /* Ditto                                     */
    TestPtr prevTest;
    int i, j;
    TestListPtr *sortList = this->sortList;

    for (i=0; i<NumLeafClasses; i++) {
        if (TestList__Size(sortList[i])) {
            prevTest = 0;
            for (j=0; j<TestList__Size(sortList[i]); j++) {
                TestPtr currentTest = sortList[i]->list[j];
                currentTest->previousWindType = prevWindType;
                currentTest->previousVisual = prevVisual;
                currentTest->previousWinW = prevWinW;
                currentTest->previousWinH = prevWinH;
                if (Test__SetupRunPrint(currentTest, prevTest, printMode)) {
                    prevTest = currentTest;
                    prevWindType = currentTest->windType;
#if defined(XWINDOWS) || defined( __OS2__)
                    prevVisual = currentTest->environ.bufConfig.visualId;
#elif defined(WIN32)
		    prevVisual = currentTest->environ.bufConfig.ipfd;
#elif defined(__amigaos__)
		    
#else
#error Window system undefined
#endif
                    prevWinW   = currentTest->environ.windowWidth;
                    prevWinH   = currentTest->environ.windowHeight;
		}
            }
        }
    }
}
