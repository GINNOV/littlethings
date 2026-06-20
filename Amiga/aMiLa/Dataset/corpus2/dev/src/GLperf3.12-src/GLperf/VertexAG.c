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

char* colorSuccinct[] = {
    "",
    "Color"
};

char* indexSuccinct[] = {
    "",
    "Index"
};

char* normalSuccinct[] = {
    "",
    "Norm"
};

char* textureSuccinct[] = {
    "",
    "Tex"
};

char* PrintEntry(FILE *fp, int p, int cd, int id, int nd, int td)
{
    char* funcName = (char*)malloc(64);
    sprintf(funcName,"VertArr%s%s%s%s%s",
        pntSuccinct[p], 
        colorSuccinct[cd], 
        indexSuccinct[id], 
        normalSuccinct[nd], 
        textureSuccinct[td]
        );
    fprintf(fp,"#define FUNCTION %s\n", funcName);
    if (p)
        fprintf(fp,"#define FUNCTION_PTRS\n");
    if (cd)
        fprintf(fp,"#define COLOR_DATA\n");
    if (id)
        fprintf(fp,"#define INDEX_DATA\n");
    if (nd)
        fprintf(fp,"#define NORMAL_DATA\n");
    if (td)
        fprintf(fp,"#define TEXTURE_DATA\n");
    fprintf(fp,"#include \"VertexAX.c\"\n");
    fprintf(fp,"#undef FUNCTION\n");
    fprintf(fp,"#undef TEXTURE_DATA\n");
    fprintf(fp,"#undef NORMAL_DATA\n");
    fprintf(fp,"#undef INDEX_DATA\n");
    fprintf(fp,"#undef COLOR_DATA\n");
    fprintf(fp,"#undef FUNCTION_PTRS\n");
    fprintf(fp,"\n");
    return funcName;
}

#define TOTAL_FUNCS 2*2*2*2*2

main()
{
    VertexArrayFunc function;
    int i;
    int p, cd, id, nd, td;
    FILE *fp, *header;
    char* names[TOTAL_FUNCS];

    for (i=0; i<TOTAL_FUNCS; i++)
        names[i] = "Noop";
    header = fopen("VertexAX.h", "w");
    fprintf(header, "/*\n * File VertexAX.h generated from VertexAG (source file VertexAG.c)\n */\n\n");
    fp = fopen("VertexAF.c", "w");
    fprintf(fp, "/*\n * File VertexAF.c generated from VertexAG (source file VertexAG.c)\n */\n\n");
    fprintf(fp, "#include \"Vertex.h\"\n");
#ifdef GL_EXT_vertex_array
#ifndef WIN32 /* The Microsoft header lies! */
    for (p=0;p<=FUNC_PTRS;p++) {
        for (cd=0;cd<2;cd++) {
            for (id=0;id<2;id++) {
                for (nd=0;nd<2;nd++) {
                    for (td=0;td<2;td++) {
                        if (!(cd && id || td && id)) {
                            function.word = 0;
                            function.bits.functionPtrs  = p;
                            function.bits.colorData    = cd;
                            function.bits.indexData    = id;
                            function.bits.normalData    = nd;
                            function.bits.textureData    = td;
                            names[function.word] = PrintEntry(fp, p, cd, id, nd, td);
                            fprintf(header, "void %s(TestPtr);\n", names[function.word]);
                        }
                    }
                }
            }
        }
    }
#endif /* WIN32 */
#endif
    fclose(fp);
    fprintf(header, "void Noop(TestPtr);\n");
    fprintf(header, "typedef void (*VertexArrayExecuteFunc)(TestPtr);\n");
    fprintf(header, "\nVertexArrayExecuteFunc VertexArrayExecuteTable[] = {\n");
    for (i=0; i<TOTAL_FUNCS; i++)
        fprintf(header, "    %s,\n", names[i]);
    fprintf(header, "};\n");
    fclose(header);
    return 0;
}
