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
#include "General.h"
#ifdef WIN32 
#include <gl\glaux.h>
#elif __amigaos__
#include <gl/glaux.h>
#else
#include "aux.h"
#endif

#include <malloc.h>

void SetDefaults(TestPtr this, InfoItemPtr infoItems)
{
    TypeDependentDataPtr currentEnum;
    int enumValue, intValue;
    GLfloat floatValue;
    char** stringAddress;
    PrintfStringPtr* printfStringAddress;
    GLfloat* floatAddress;
    int* intAddress;
    char* stringValue;
    InfoItemPtr currentItem;

    this->infoItems = infoItems;
    for (currentItem = infoItems; currentItem->propName; currentItem++) {
	switch (currentItem->type & ~(NoPrint | NotSettable)) {
	    case Enumerated:
	    case RangedInteger:
	    case UnrangedInteger:
	    case RangedHexInteger:
	    case UnrangedHexInteger:
		intAddress = (int*)((char*)this + currentItem->offset);
		*intAddress = (int)currentItem->defaultData.intValue;
		break;
	    case RangedFloat:
	    case UnrangedFloat:
	    case RangedFloatOrInt:
	    case UnrangedFloatOrInt:
		floatAddress = (GLfloat*)((char*)this + currentItem->offset);
		*floatAddress = (GLfloat)currentItem->defaultData.floatValue;
		break;
	    case StringType:
                stringAddress = (char**)((char*)this + currentItem->offset);
                *stringAddress = strdup(currentItem->defaultData.stringValue);
		break;
	    case PrintfStringType:
                printfStringAddress = (PrintfStringPtr*)((char*)this + currentItem->offset);
                *printfStringAddress = new_PrintfString(strdup(currentItem->defaultData.stringValue), 0);
		break;
	}
    }
}

/* This function does not free any of the strings in the dst Test.        */
/* You must ensure that you free these strings prior to this, if need be. */ 
void CopyStrings(TestPtr dst, TestPtr src)
{
    InfoItemPtr infoItems = src->infoItems;
    char** dstStringAddress;
    char** srcStringAddress;
    PrintfStringPtr* dstPrintfStringAddress;
    PrintfStringPtr* srcPrintfStringAddress;
    InfoItemPtr currentItem;

    for (currentItem = infoItems; currentItem->propName; currentItem++) {
	if ((currentItem->type & ~(NoPrint | NotSettable)) == StringType) {
            dstStringAddress = (char**)((char*)dst + currentItem->offset);
            srcStringAddress = (char**)((char*)src + currentItem->offset);
	    if (*srcStringAddress)
                *dstStringAddress = strdup(*srcStringAddress);
	} else if ((currentItem->type & ~(NoPrint | NotSettable)) == PrintfStringType) {
            dstPrintfStringAddress = (PrintfStringPtr*)((char*)dst + currentItem->offset);
            srcPrintfStringAddress = (PrintfStringPtr*)((char*)src + currentItem->offset);
	    if (*srcPrintfStringAddress)
                *dstPrintfStringAddress = PrintfString__Copy(*srcPrintfStringAddress);
	}
    }
}

void FreeStrings(TestPtr this)
{
    InfoItemPtr infoItems = this->infoItems;
    char** stringAddress;
    PrintfStringPtr* printfStringAddress;
    InfoItemPtr currentItem;

    for (currentItem = infoItems; currentItem->propName; currentItem++) {
	if ((currentItem->type & ~(NoPrint | NotSettable)) == StringType) {
            stringAddress = (char**)((char*)this + currentItem->offset);
	    if (*stringAddress) {
		free(*stringAddress);
		*stringAddress = 0;
	    }
	} else if ((currentItem->type & ~(NoPrint | NotSettable)) == PrintfStringType) {
            printfStringAddress = (PrintfStringPtr*)((char*)this + currentItem->offset);
	    if (*printfStringAddress) {
		delete_PrintfString(*printfStringAddress);
		*printfStringAddress = 0;
	    }
	}
    }
}

int Apply(TestPtr this, int propName, AttributePtr attr)
{
    InfoItemPtr infoItems = this->infoItems;
    TypeDependentDataPtr currentEnum;
    int enumValue, intValue;
    GLfloat floatValue;
    char* stringValue;
    PrintfStringPtr printfStringValue;
    int minIntValue, maxIntValue;
    GLfloat minFltValue, maxFltValue;
    InfoItemPtr currentItem;

    for (currentItem = infoItems; 
         currentItem->propName && propName != currentItem->propName; 
         currentItem++);

    if (currentItem->propName) {
	if (currentItem->type & NotSettable)
	    return PropertyNotSettable;
	switch (currentItem->type & ~NoPrint) {
	    case Enumerated:
		if (!Attribute__IntOf(attr, &enumValue)) return InvalidValue;
		for (currentEnum = currentItem->typeDependentData;
		     (int)currentEnum->value != End && enumValue != (int)currentEnum->value;
		     currentEnum++);
		if ((int)currentEnum->value != End) {
		    int* dataAddress = (int*)((char*)this + currentItem->offset);
		    *dataAddress = enumValue;
		    return ApplySuccessful;
		} else {
		    return InvalidValue;
		}
		break;
	    case RangedInteger:
	    case RangedHexInteger:
		if (!Attribute__IntOf(attr, &intValue)) return InvalidValue;
		minIntValue = (int)currentItem->typeDependentData[0].value;
		maxIntValue = (int)currentItem->typeDependentData[1].value;
		if (maxIntValue >= intValue && intValue >= minIntValue) {
		    int* dataAddress = (int*)((char*)this + currentItem->offset);
		    *dataAddress = intValue;
		    return ApplySuccessful;
		} else {
		    return InvalidValue;
		}
		break;
	    case UnrangedInteger:
	    case UnrangedHexInteger:
		if (!Attribute__IntOf(attr, &intValue)) {
		    return InvalidValue;
		} else {
		    int* dataAddress = (int*)((char*)this + currentItem->offset);
		    *dataAddress = intValue;
		    return ApplySuccessful;
		}
		break;
	    case RangedFloat:
		if (!Attribute__FloatOf(attr, &floatValue)) return InvalidValue;
		minFltValue = currentItem->typeDependentData[0].value;
		maxFltValue = currentItem->typeDependentData[1].value;
		if (maxFltValue >= floatValue && floatValue >= minFltValue) {
		    GLfloat* dataAddress = (GLfloat*)((char*)this + currentItem->offset);
		    *dataAddress = floatValue;
		    return ApplySuccessful;
		} else {
		    return InvalidValue;
		}
		break;
	    case UnrangedFloat:
		if (!Attribute__FloatOf(attr, &floatValue)) {
		    return InvalidValue;
		} else {
		    GLfloat* dataAddress = (GLfloat*)((char*)this + currentItem->offset);
		    *dataAddress = floatValue;
		    return ApplySuccessful;
		}
		break;
	    case RangedFloatOrInt:
		if (Attribute__FloatOf(attr, &floatValue)) {
		    minFltValue = currentItem->typeDependentData[0].value;
		    maxFltValue = currentItem->typeDependentData[1].value;
		    if (maxFltValue >= floatValue && floatValue >= minFltValue) {
		        GLfloat* dataAddress = (GLfloat*)((char*)this + currentItem->offset);
		        *dataAddress = floatValue;
		        return ApplySuccessful;
		    } else {
		        return InvalidValue;
		    }
		} else if (Attribute__IntOf(attr, &intValue)) {
		    minIntValue = (int)currentItem->typeDependentData[0].value;
		    maxIntValue = (int)currentItem->typeDependentData[1].value;
		    if (maxIntValue >= intValue && intValue >= minIntValue) {
		        int* dataAddress = (int*)((char*)this + currentItem->offset);
		        *dataAddress = intValue;
		        return ApplySuccessful;
		    } else {
		        return InvalidValue;
		    }
		} else {
		    return InvalidValue;
		}
		break;
	    case UnrangedFloatOrInt:
		if (Attribute__FloatOf(attr, &floatValue)) {
		    GLfloat* dataAddress = (GLfloat*)((char*)this + currentItem->offset);
		    *dataAddress = floatValue;
		    return ApplySuccessful;
		} else if (Attribute__IntOf(attr, &intValue)) {
                    int* dataAddress = (int*)((char*)this + currentItem->offset);
                    *dataAddress = intValue;
                    return ApplySuccessful;
		} else {
		    return InvalidValue;
		}
		break;
	    case StringType:
		if (!Attribute__StringOf(attr, &stringValue)) {
		    return InvalidValue;
		} else {
		    char** dataAddress = (char**)((char*)this + currentItem->offset);
                    if (*dataAddress) free(*dataAddress);
                    *dataAddress = strdup(stringValue);
		    return ApplySuccessful;
		}
		break;
	    case PrintfStringType:
		if (Attribute__StringOf(attr, &stringValue)) {
		    PrintfStringPtr* dataAddress = (PrintfStringPtr*)((char*)this + currentItem->offset);
                    if (*dataAddress) delete_PrintfString(*dataAddress);
		    *dataAddress = new_PrintfString(strdup(stringValue), 0);
		    return ApplySuccessful;
		} else if (Attribute__PrintfStringOf(attr, &printfStringValue)) {
		    PrintfStringPtr* dataAddress = (PrintfStringPtr*)((char*)this + currentItem->offset);
                    if (*dataAddress) delete_PrintfString(*dataAddress);
                    *dataAddress = PrintfString__Copy(printfStringValue);
		    return ApplySuccessful;
		} else {
		    return InvalidValue;
		}
		break;
	    default:
		return InvalidValue;
	}
    } else {
	return InvalidProperty;
    }
}

#if defined(XWINDOWS)
#include <GL/glx.h>
static int
GetAllVisuals(AttributeListPtr attrList)
{
  extern int xScreen;           /* XXX - better way to get screen ?? */
  Display *dpy;
  int screen;
  XVisualInfo visTemplate, *vis;
  int nVis, useGL, i;

  dpy = auxXDisplay();
  if (!dpy) {
    fprintf(stderr, "GetAllVisuals: no display set\n");
    return(0);
  }

  screen = xScreen;             /* XXX - better way to get screen ?? */
  

  visTemplate.screen = screen;
  vis = XGetVisualInfo(dpy, VisualScreenMask, &visTemplate, &nVis);

  for (i = 0; i < nVis; i++) {
    glXGetConfig(dpy, &vis[i], GLX_USE_GL, &useGL);
    if (useGL) {
      AttributeList__AddAttribute(attrList,
                                  new_Attribute_Int((int)vis[i].visualid));
    }
  }

  XFree((void *)vis);
  return(1);
}
#elif defined(WIN32)
#include <windows.h>
static int
GetAllVisuals(AttributeListPtr attrList)
{
    HWND hwnd;   
    HDC hdc;    
    PIXELFORMATDESCRIPTOR pfd;    
    int nVis, i;

    hwnd = GetActiveWindow();
    if (hwnd == NULL) {
        fprintf(stderr, "GetAllVisuals: could not get a handle to the window\n");
        return(0);
    }

    hdc = GetDC(hwnd);
    if (hdc == NULL) {
        fprintf(stderr, "GetAllVisuals: could not get a handle to the DC\n");
        return(0);
    }

    nVis = DescribePixelFormat(hdc, 1, sizeof( PIXELFORMATDESCRIPTOR), NULL);
    if (nVis == 0) {
        fprintf(stderr, "GetAllVisuals:  could not get any pixel formats\n");
        return(0);
    }

    for (i = 0; i < nVis; i++) {
        DescribePixelFormat(hdc, i, sizeof( PIXELFORMATDESCRIPTOR), &pfd);
        if (pfd.dwFlags && PFD_SUPPORT_OPENGL) {
            AttributeList__AddAttribute(attrList,
                new_Attribute_Int(i));
        }
    }
    return(1);
}
#elif defined(__OS2__)
#include <os2.h>
static int
GetAllVisuals(AttributeListPtr attrList)
{
    HAB hab = WinQueryAnchorBlock( HWND_DESKTOP);
    PVISUALCONFIG* pvc = pglQueryConfigs( hab);
    PVISUALCONFIG* p;

    for ( p = pvc; *p; p++)
    {
printf( "Found visual %d\n", (*pvc)->vid);
	AttributeList__AddAttribute( attrList, new_Attribute_Int(( *pvc)->vid));
    }

    free( pvc);
}
#elif defined(__amigaos__)
static int
GetAllVisuals(AttributeListPtr attrList)
{
  return 1;
}
#elif defined(SOME_OTHER_WINDOW_SYSTEM)
#else
#error "unknown window system"
#endif

AttributeListPtr GetAllAttrs(TestPtr this, int propName)
{
    AttributeListPtr attrList = new_AttributeList();
    InfoItemPtr infoItems = this->infoItems;
    InfoItemPtr currentItem;
    TypeDependentDataPtr currentEnum;
    int enumValue;
    int i;
    int type;

    for (currentItem = infoItems; 
         currentItem->propName && propName != currentItem->propName; 
         currentItem++);

    type = currentItem->type & ~(NoPrint | NotSettable);

    if (!currentItem->propName) {
        delete_AttributeList(attrList);
        return 0;
    }

    if (propName == VisualId) {
        if (GetAllVisuals(attrList)) {
            return attrList;
        } else {
            delete_AttributeList(attrList);
            return 0;
        }
    } else if (type == Enumerated) {
        for (currentEnum = currentItem->typeDependentData;
             (int)currentEnum->value != End;
             currentEnum++) {
            AttributeList__AddAttribute(attrList, new_Attribute_Int((int)currentEnum->value));
        }
        return attrList;
    } else if ((type == RangedInteger || type == RangedHexInteger) &&
               (int)currentItem->typeDependentData[1].value - 
               (int)currentItem->typeDependentData[0].value <= 10) {
        int minIntValue = (int)currentItem->typeDependentData[0].value;
        int maxIntValue = (int)currentItem->typeDependentData[1].value;
        int i;
        for (i=minIntValue; i<=maxIntValue; i++) {
            AttributeList__AddAttribute(attrList, new_Attribute_Int(i));
        }
	return attrList;
    } else {
	delete_AttributeList(attrList);
	return 0;
    }
}

/* This section provides support functions for special alignment of memory */

  const unsigned long  modulo = 4096;

typedef struct _AddressList {
    void* fakeValue;
    void* realValue;
    struct _AddressList *next;
} AddressList, *AddressListPtr;

static AddressListPtr addressList = 0;

void* AlignMalloc(int size, int modalignment)
{
    void *realAddr, *fakeAddr;
    AddressListPtr newEntry;

    realAddr = malloc(size + 2 * modulo);
    CheckMalloc(realAddr);


    fakeAddr = (void*)((((unsigned long)realAddr + modulo - 1) & (~(modulo-1))) +(unsigned long) modalignment);

    /* save this value away so we can free it later */
    newEntry = (AddressListPtr)malloc(sizeof(AddressList));
    CheckMalloc(newEntry);
    newEntry->realValue = realAddr;
    newEntry->fakeValue = fakeAddr;
    newEntry->next = addressList;
    addressList = newEntry;
    return fakeAddr;
}

void AlignFree(void* addr)
{
    AddressListPtr list = addressList;
    AddressListPtr prev;
    if (list == 0) {
	printf("GLperf malloc'd memory list empty, you're in BIG trouble!\n");
	exit(1);
    }
    prev = addressList;
    for (list = addressList; list && list->fakeValue != addr; prev = list, list = list->next);
    if (list) {
	free(list->realValue);
	if (addressList == list) {
	    addressList = list->next;
	} else {
	    prev->next = list->next;
	}
	free(list);
    } else {
	printf("GLperf malloc'd memory list corrupted!\n");
	exit(1);
    }
}

void DefineTexImage(int target, int level, int comps, int width, int height, int depth, int extent, int border, int format, int type, void* pixels)
{
    switch (target) {
    case GL_TEXTURE_1D:
        glTexImage1D(target, level, comps, width, border, format, type, pixels);
        break;
    case GL_TEXTURE_2D:
#ifdef GL_SGIS_detail_texture
    case GL_DETAIL_TEXTURE_2D_SGIS:
#endif
        glTexImage2D(target, level, comps, width, height, border, format, type, pixels);
        break;
#ifdef GL_EXT_texture3D
    case GL_TEXTURE_3D_EXT:
        glTexImage3DEXT(target, level, comps, width, height, depth, border, format, type, pixels);
        break;
#endif
#ifdef GL_SGIS_texture4D
    case GL_TEXTURE_4D_SGIS:
        glTexImage4DSGIS(target, level, comps, width, height, depth, extent, border, format, type, pixels);
        break;
#endif
    }
}

