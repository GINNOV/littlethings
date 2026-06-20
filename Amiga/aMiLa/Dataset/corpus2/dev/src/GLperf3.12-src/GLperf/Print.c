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

#include "Print.h"
#include <malloc.h>
#include <stdarg.h>

#include <math.h>


static void PrintInt(int value, int width)
{
    char src[128];
    char dst[128];

    sprintf(src, "%d                                                                 ", value);
    memcpy(dst, src, width);
    dst[width] = (char)0;
    printf(dst);
}

static void PrintString(char* string, int width)
{
    char src[1024];
    char dst[1024];

    sprintf(src, "%s                                                                ", string);
    memcpy(dst, src, width);
    dst[width] = (char)0;
    printf(dst);
}

static void PrintFloat(GLfloat value, int width, int decimal)
{
    char src[128];
    char dst[128];
    char *pos;

    sprintf(src, "              %f                                ", value);
    pos = strchr(src, '.');
    if (pos) {
    pos -= decimal - 1;
    memcpy(dst, pos, width);
    } else {
        memset(dst, ' ', width);
    }
    dst[width] = (char)0;
    printf(dst);
}

#define GetInt(test, offset)    (*(int*)((char*)(test) + (offset)))
#define GetFloat(test, offset)  (*(GLfloat*)((char*)(test) + (offset)))
#define GetString(test, offset) (*(char**)((char*)(test) + (offset)))
#define GetPrintfString(test, offset) (*(PrintfStringPtr*)((char*)(test) + (offset)))

static void PrintRound(GLfloat v, int s)
/* Rounds GLfloating point value v to s significant digits */
{
    const int decimalPlace = 8;
    const int measuredWidth = 10;
    int right, left, left_padding;
    char format[64];
    char buffer[64];
    char dst[64];
    int d;
    if (v == 0.0) {
    d = 1;
    } else {
    d = ceil(log10(v));
    }
    v *= pow(10.0,s-d);
    v = floor(v+0.5);
    v *= pow(10.0,d-s);

    left = d;
    if (left < 1) left = 1;
    if (left > decimalPlace - 1) left = decimalPlace - 1;

    right = s - d;
    if (right < 0) right = 0;
    if (right > measuredWidth - decimalPlace) right = measuredWidth - decimalPlace;
    left_padding = decimalPlace - left - 1;

    memset(buffer, ' ', measuredWidth+1);
    buffer[measuredWidth+1] = (char) 0;

    sprintf(format, "%%%d.%df", left, right);
    sprintf(dst, format, v);
    memcpy(buffer + left_padding, dst, strlen(dst));

    printf(buffer);
}

char* PrintArg(char** start)
{
    char *str, *ptr, ch, save, *returnString;

    ptr = str = *start;
    while (ptr = strchr(ptr, '%')) {
	if (*(ptr+1) == '%') ptr+=2; else break;
    }
    if (ptr == 0) {
	*start = str + strlen(str);
	return strdup(str);
    }
        
    for (ptr = ptr+1; ch = *ptr; ptr++) {
        switch (ch) {
        case 'd':
        case 'i':
        case 'o':
        case 'u':
        case 'x':
        case 'X':
        case 'e':
        case 'E':
        case 'f':
        case 'g':
        case 'G':
        case 'c':
        case 's':
	    ptr++;
            save = *ptr;
            *ptr = 0;
            returnString = strdup(str);
            *ptr = save;
            *start = ptr;
            return returnString;
        default:
            break;
        }
    }
    *start = ptr;
    return strdup(str);
}

char* CreatePrintfString(TestPtr this, PrintfStringPtr printfString)
{
    InfoItemPtr infoItems = this->infoItems;
    InfoItemPtr currentItem;
    int i, j;
    char* string = PrintfString__String(printfString);
    char* marker = string;
    char* returnString;
    char* newString;
    PropNameListPtr propNameList = PrintfString__PropNameList(printfString);

    if (PropNameList__Size(propNameList) > 16) {
	printf("GLperf: cannot have more than 16 arguments in a printf string!\n");
	exit(1);
    }
    returnString = (char*)malloc(512);
    *returnString = 0;
    for (i = 0; i < PropNameList__Size(propNameList); i++) {
        for (currentItem = infoItems;
             currentItem->propName != 0 && currentItem->propName != propNameList->list[i];
             currentItem++);
	if (currentItem->propName == 0) {
	    printf("GLperf: property in printf string does not exist!\n");
	    exit(1);
	}
        switch (currentItem->type & ~(NoPrint | NotSettable)) {
            case RangedFloatOrInt:
            case UnrangedFloatOrInt:
            case RangedFloat:
            case UnrangedFloat:
		newString = PrintArg(&marker);
		sprintf(returnString + strlen(returnString), newString, (double)GetFloat(this, currentItem->offset));
		free(newString);
                break;
            case RangedInteger:
            case UnrangedInteger:
            case RangedHexInteger:
            case UnrangedHexInteger:
		newString = PrintArg(&marker);
		sprintf(returnString + strlen(returnString), newString, GetInt(this, currentItem->offset));
		free(newString);
                break;
            case StringType:
		newString = PrintArg(&marker);
		sprintf(returnString + strlen(returnString), newString, GetString(this, currentItem->offset));
		free(newString);
                break;
            case PrintfStringType:
		printf("GLperf: Not allowed to include printf string properties inside printf strings!\n");
		exit(1);
            case Enumerated:
                for (j=0; (int)currentItem->typeDependentData[j].value != End; j++) {
                    if (GetInt(this, currentItem->offset) == currentItem->typeDependentData[j].value) {
			newString = PrintArg(&marker);
			sprintf(returnString + strlen(returnString), newString, currentItem->typeDependentData[j].verbose);
			free(newString);
                        break;
                    }
                }
                break;
        }
    }
    strcat(returnString, marker);
    return returnString;
}

void PrintResults(TestPtr this, TestPtr prev, float elapsed, int printMode)
{
    int i, j;
    char buffer[4];
    char *s1, *s2;
    InfoItemPtr currentItem;
    int same;
    InfoItemPtr infoItems = this->infoItems;
    unsigned int testPrintMode = 0;
    float rate, usec;
    int sigDigits;
    float size;

    /* Set global Print Mode flags as set on the command line */
    if (printMode & Delta) this->printModeDelta = True;
    if (printMode & MicroSec) this->printModeMicrosec = True;
    if (printMode & Pixels) this->printModePixels = True;
    if (printMode & StateDelta) this->printModeStateDelta = True;

    /* Compute Print Mode for this test */
    testPrintMode |= this->printModeDelta ? Delta : 0;
    testPrintMode |= this->printModeMicrosec  ? MicroSec : 0;
    testPrintMode |= this->printModePixels ? Pixels : 0;
    testPrintMode |= this->printModeStateDelta ? StateDelta : 0;

    /* Print results */
    if (elapsed == 0.0) {
        sigDigits = 2;
        rate = 0.0;
        usec = 0.0;
    } else {
        sigDigits = ceil(log10(elapsed))+2;
        rate = (GLfloat)this->iterations*(GLfloat)this->numObjects*(GLfloat)this->TimesRun(this)/elapsed;
        usec = 1000000.0/rate;
    }

    if (testPrintMode & Pixels && (size = this->PixelSize(this)) > 0.) {
	rate *= size;
	usec /= size;
    }

    if (testPrintMode & MicroSec)
        PrintRound(usec, sigDigits);
    else
        PrintRound(rate, sigDigits);

    if (testPrintMode & Pixels && size > 0.) {
	printf(testPrintMode&MicroSec ? this->usecPixelPrint : this->ratePixelPrint);
    } else {
	printf(testPrintMode&MicroSec ? this->usecPrint : this->ratePrint);
    }

    if (strcmp(PrintfString__String(this->userString), "None") == 0) {
	printf("\n");
    } else {
	char *s = CreatePrintfString(this, this->userString);
	printf(" -- %s\n", s);
	free(s);
    }

    if (!prev && testPrintMode & Delta) testPrintMode &= ~Delta;

    for (currentItem = infoItems; currentItem->propName != 0; currentItem++) {
        if (currentItem->type & NoPrint) continue;
        same = 0;
        if (testPrintMode & Delta) {
            switch (currentItem->type & ~NotSettable) {
            case RangedFloatOrInt:
            case UnrangedFloatOrInt:
            case RangedFloat:
            case UnrangedFloat:
                if (GetFloat(this, currentItem->offset) == GetFloat(prev, currentItem->offset))
                    same = 1;
                break;
            case RangedInteger:
            case UnrangedInteger:
            case RangedHexInteger:
            case UnrangedHexInteger:
            case Enumerated:
                if (GetInt(this, currentItem->offset) == GetInt(prev, currentItem->offset))
                    same = 1;
                break;
            case StringType:
                s1 = GetString(this, currentItem->offset);
                s2 = GetString(prev, currentItem->offset);
                if ((s1 == NULL && s2 == NULL) ||
                    (s1 != NULL && s2 != NULL && strcmp(s1, s2) == 0))
                    same = 1;
                break;
            case PrintfStringType:
                s1 = CreatePrintfString(this, GetPrintfString(this, currentItem->offset));
                s2 = CreatePrintfString(prev, GetPrintfString(prev, currentItem->offset));
                if ((s1 == NULL && s2 == NULL) ||
                    (s1 != NULL && s2 != NULL && strcmp(s1, s2) == 0))
                    same = 1;
		free(s1);
		free(s2);
                break;
            }
        }
        if (testPrintMode & StateDelta) {
            switch (currentItem->type & ~NotSettable) {
            case RangedFloatOrInt:
            case UnrangedFloatOrInt:
            case RangedFloat:
            case UnrangedFloat:
                if (GetFloat(this, currentItem->offset) == currentItem->defaultData.floatValue)
                    same = 1;
                break;
            case RangedInteger:
            case UnrangedInteger:
            case RangedHexInteger:
            case UnrangedHexInteger:
            case Enumerated:
                if (GetInt(this, currentItem->offset) == currentItem->defaultData.intValue)
                    same = 1;
                break;
            case StringType:
                s1 = GetString(this, currentItem->offset);
                s2 = currentItem->defaultData.stringValue;
                if ((s1 == NULL && s2 == NULL) ||
                    (s1 != NULL && s2 != NULL && strcmp(s1, s2) == 0))
                    same = 1;
                break;
            case PrintfStringType:
                s1 = CreatePrintfString(this, GetPrintfString(this, currentItem->offset));
                s2 = currentItem->defaultData.stringValue;
                if ((s1 == NULL && s2 == NULL) ||
                    (s1 != NULL && s2 != NULL && strcmp(s1, s2) == 0))
                    same = 1;
		free(s1);
		free(s2);
                break;
            }
        }
        if (!same) {
            PrintString("", 4);
            PrintString(currentItem->verbose, 50);
            PrintString("", 1);
            switch (currentItem->type & ~NotSettable) {
            case RangedFloatOrInt:
            case UnrangedFloatOrInt:
            case RangedFloat:
            case UnrangedFloat:
                printf("%f", GetFloat(this, currentItem->offset));
                break;
            case RangedInteger:
            case UnrangedInteger:
                printf("%d", GetInt(this, currentItem->offset));
                break;
            case RangedHexInteger:
            case UnrangedHexInteger:
                printf("0x%x", GetInt(this, currentItem->offset));
                break;
            case StringType:
                printf("%s", GetString(this, currentItem->offset));
                break;
            case PrintfStringType:
		s1 = CreatePrintfString(this, GetPrintfString(this, currentItem->offset));
                printf("%s", s1);
		free(s1);
                break;
            case Enumerated:
                for (i=0; (int)currentItem->typeDependentData[i].value != End; i++) {
                    if (GetInt(this, currentItem->offset) == currentItem->typeDependentData[i].value) {
                        printf("%s", currentItem->typeDependentData[i].verbose);
                        break;
                    }
                }
                break;
            }
            PrintString("\n", 1);
        }
    }
    fflush(stdout);
}
