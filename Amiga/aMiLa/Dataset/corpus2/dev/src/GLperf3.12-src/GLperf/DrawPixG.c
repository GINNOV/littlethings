/*
 * (c) Copyright 1995, Silicon Graphics, Inc.
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
 * Author: John Spitzer, SGI Applied Engineering
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include "FuncEnum.h"
#include <malloc.h>

/* This will be set by compile time #defines                     */
/* They control the size and functionality of the code generated */
#ifdef FULL_RASTERPOS_PATHS
  #define MIN_RPOS_DIM 2
#else
  #define MIN_RPOS_DIM 3
#endif
#ifdef FULL_FUNCPTR_PATHS
  #define FUNC_PTRS 1
#else
  #define FUNC_PTRS 0
#endif

char* pntSuccinct[] = {
    "Pf",
    "Pt"
};

char* subSuccinct[] = {
    "All",
    "Sub"
};

char* miSuccinct[] = {
    "One",
    "Multi"
};

char* PrintEntry(FILE *fp, int p, int sub, int rd, int mi)
{
    char* funcName = (char*)malloc(64);
    sprintf(funcName,"DrawPix%s%s%s%d", pntSuccinct[p], subSuccinct[sub], miSuccinct[mi], rd);
    fprintf(fp,"#define FUNCTION %s\n", funcName);
    if (p)
        fprintf(fp,"#define FUNCTION_PTRS\n");
    if (sub)
        fprintf(fp,"#define SUBIMAGE\n");
    if (mi)
        fprintf(fp,"#define MULTIIMAGE\n");
    fprintf(fp,"#define RASTERPOS_DIM %d\n", rd);
    fprintf(fp,"#include \"DrawPixX.c\"\n");
    fprintf(fp,"#undef FUNCTION\n");
    fprintf(fp,"#undef MULTIIMAGE\n");
    fprintf(fp,"#undef SUBIMAGE\n");
    fprintf(fp,"#undef FUNCTION_PTRS\n");
    fprintf(fp,"#undef RASTERPOS_DIM\n");
    fprintf(fp,"\n");
    return funcName;
}

#define TOTAL_FUNCS 2*2*2*2

main()
{
    DrawPixelsFunc function;
    int i;
    int p,sub,rd,mi;
    FILE *fp, *header;
    char* names[TOTAL_FUNCS];

    for (i=0; i<TOTAL_FUNCS; i++)
        names[i] = "Noop";
    header = fopen("DrawPixX.h", "w");
    fprintf(header, "/*\n * File DrawPixX.h generated from DrawPixG (source file DrawPixG.c)\n */\n\n");
    fp = fopen("DrawPixF.c", "w");
    fprintf(fp, "/*\n * File DrawPixF.c generated from DrawPixG (source file DrawPixG.c)\n */\n\n");
    fprintf(fp, "#include \"DrawPix.h\"\n");
    for (mi=0;mi<2;mi++) {
        for (sub=0;sub<2;sub++) {
            for (p=0;p<=FUNC_PTRS;p++) {
                for (rd=MIN_RPOS_DIM;rd<=3;rd++) {
                    function.word = 0;
                    function.bits.rasterPosDim  = rd-2;
                    function.bits.functionPtrs  = p;
                    function.bits.subimage      = sub;
                    function.bits.multiimage    = mi;
                    names[function.word] = PrintEntry(fp, p, sub, rd, mi);
                    fprintf(header, "void %s(TestPtr);\n", names[function.word]);
                }
            }
        }
    }
    fclose(fp);
    fprintf(header, "void Noop(TestPtr);\n");
    fprintf(header, "typedef void (*ExecuteFunc)(TestPtr);\n");
    fprintf(header, "\nExecuteFunc DrawPixelsExecuteTable[] = {\n");
    for (i=0; i<TOTAL_FUNCS; i++)
        fprintf(header, "    %s,\n", names[i]);
    fprintf(header, "};\n");
    fclose(header);
    return 0;
}
