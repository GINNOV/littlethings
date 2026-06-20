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

#include <stdio.h>

const char* fileHeader = "/*\n * This file generated from MakeTab (source file MakeTab.c)\n */\n\n";

int StringValueCmp(const void* arg1, const void* arg2)
{
    return strcmp(*((char**)arg1),*((char**)arg2));
}

main(int argc, char **argv)
{
    const int numEntriesInc = 10;
    int numEntries = 0;
    int maxEntries = numEntriesInc;
    char** symbolTable;
    char *tableName, *ptr, *symbolPtr;
    int i;
    #define BUFFER_LENGTH 1024
    char buffer[BUFFER_LENGTH];
    char symbolName[BUFFER_LENGTH];
    if (argc < 2) {
	fprintf(stderr, "MakeTab: no table name given on command line\n");
	exit(1);
    } else {
	tableName = argv[1];
    }
    symbolTable = (char**)malloc(sizeof(char*) * maxEntries);
    while (fgets(buffer, BUFFER_LENGTH, stdin)) {
	for (ptr = buffer; *ptr == ' ' || *ptr == '\t'; ptr++);
	if (strncmp(ptr, "#define", 7) == 0 && strchr(ptr, '(') == 0) {
	    for (ptr = ptr + 7; *ptr == ' ' || *ptr == '\t'; ptr++);
	    symbolPtr = symbolName;
	    for (; *ptr != ' ' && *ptr != '\t' && *ptr != '\n'; *symbolPtr++ = *ptr++);
	    *symbolPtr = 0;
	    for (; *ptr == ' ' || *ptr == '\t' || *ptr == '\n'; ptr++);
	    if (*ptr && strchr(ptr, '.') == 0) {
		if (numEntries == maxEntries) {
		    maxEntries += maxEntries;
		    symbolTable = (char**)realloc(symbolTable, sizeof(char*) * maxEntries);
		}
		symbolTable[numEntries++] = (char*)strdup(symbolName);
	    }
	}
    }
    qsort(symbolTable, (size_t)numEntries, (size_t)sizeof(char*), StringValueCmp);
    printf(fileHeader);
    printf("const int Num%s = %d;\n", tableName, numEntries);
    printf("StringValue %s[] = {\n", tableName);
    for (i = 0; i < numEntries; i++) {
	printf("  { \"%s\", (int)(%s) },\n", symbolTable[i], symbolTable[i]);
	free(symbolTable[i]);
    }
    printf("};\n", tableName);
    free(symbolTable);
    return 0;
}
