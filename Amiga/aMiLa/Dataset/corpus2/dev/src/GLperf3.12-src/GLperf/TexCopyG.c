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
#ifdef WIN32
#include <windows.h>
#endif
#include <GL/gl.h>
#include <malloc.h>

/* This will be set by compile time #defines                     */
/* They control the size and functionality of the code generated */
#ifdef FULL_FUNCPTR_PATHS
  #define FUNC_PTRS 1
#else
  #define FUNC_PTRS 0
#endif

char* pntSuccinct[] = {
    "",
    "Ptr"
};

char* objDrawSuccinct[] = {
    "",
    "Point",
    "Tri"
};

char* subtSuccinct[] = {
    "Ta",
    "Ts"
};

char* PrintEntry(FILE *fp, int td, int p, int od, int subt)
{
    char* funcName = (char*)malloc(64);
    sprintf(funcName,"TexCopy%dD%s%s%s",
            td,
            pntSuccinct[p], 
            objDrawSuccinct[od], 
            subtSuccinct[subt]
           );
    fprintf(fp,"#define FUNCTION %s\n", funcName);
    if (p)
        fprintf(fp,"#define FUNCTION_PTRS\n");
    if (subt)
        fprintf(fp,"#define SUBTEXTURE\n");
    if (od == 1)
        fprintf(fp,"#define POINT_DRAW\n");
    else if (od == 2)
        fprintf(fp,"#define TRI_DRAW\n");
    fprintf(fp,"#define TEX_DIM %d\n", td);
    fprintf(fp,"#include \"TexCopyX.c\"\n");
    fprintf(fp,"#undef FUNCTION\n");
    fprintf(fp,"#undef SUBTEXTURE\n");
    fprintf(fp,"#undef FUNCTION_PTRS\n");
    fprintf(fp,"#undef POINT_DRAW\n");
    fprintf(fp,"#undef TRI_DRAW\n");
    fprintf(fp,"#undef TEX_DIM\n");
    fprintf(fp,"\n");
    return funcName;
}

#define TOTAL_FUNCS 2*2*4*4

#if defined (GL_EXT_texture3D)
  #define MAX_TEX_DIM 3
#else
  #define MAX_TEX_DIM 2
#endif

#ifdef GL_EXT_subtexture
  #define SUBTEX 1
#else
  #define SUBTEX 0
#endif

main()
{
    TexImageCopyFunc function;
    int i;
    int td, p, od, subt;
    FILE *fp, *header;
    char* names[TOTAL_FUNCS];

    for (i=0; i<TOTAL_FUNCS; i++)
        names[i] = "Noop";
    header = fopen("TexCopyX.h", "w");
    fprintf(header, "/*\n * File TexCopyX.h generated from TexCopyG (source file TexCopyG.c)\n */\n\n");
    fp = fopen("TexCopyF.c", "w");
    fprintf(fp, "/*\n * File TexCopyF.c generated from TexCopyG (source file TexCopyG.c)\n */\n\n");
    fprintf(fp, "#include \"Tex.h\"\n");
#ifdef GL_EXT_copy_texture
    for (td=1;td<=MAX_TEX_DIM;td++) {
        for (p=0;p<=FUNC_PTRS;p++) {
            for (od=0;od<3;od++) {
                for (subt=0;subt<=SUBTEX;subt++) {
		    if (!(td==3 && subt==0)) {
                        function.word = 0;
                        function.bits.texDim  = td-1;
                        function.bits.functionPtrs  = p;
                        function.bits.objDraw     = od;
                        function.bits.subtexture    = subt;
                        names[function.word] = PrintEntry(fp, td, p, od, subt);
                        fprintf(header, "void %s(TestPtr);\n", names[function.word]);
		    }
                }
            }
        }
    }
#endif
    fclose(fp);
    fprintf(header, "void Noop(TestPtr);\n");
    fprintf(header, "typedef void (*CopyExecuteFunc)(TestPtr);\n");
    fprintf(header, "\nCopyExecuteFunc TexImageCopyExecuteTable[] = {\n");
    for (i=0; i<TOTAL_FUNCS; i++)
        fprintf(header, "    %s,\n", names[i]);
    fprintf(header, "};\n");
    fclose(header);
    return 0;
}
