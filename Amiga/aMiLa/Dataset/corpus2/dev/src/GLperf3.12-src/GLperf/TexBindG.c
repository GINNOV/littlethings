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

char* texSrcSuccinct[] = {
    "DL",
    "TO"
};

char* texSrcVerbose[] = {
    "DISPLAY_LIST",
    "TEXTURE_OBJ"
};

char* miSuccinct[] = {
    "Io",
    "Im"
};

char* PrintEntry(FILE *fp, int ts, int p, int od, int mi)
{
    char* funcName = (char*)malloc(64);
    sprintf(funcName,"TexBind%s%s%s%s",
            texSrcSuccinct[ts],
            pntSuccinct[p], 
            objDrawSuccinct[od], 
            miSuccinct[mi]
           );
    fprintf(fp,"#define FUNCTION %s\n", funcName);
    fprintf(fp,"#define TEX_SRC %s\n", texSrcVerbose[ts]);
    if (p)
        fprintf(fp,"#define FUNCTION_PTRS\n");
    if (mi)
        fprintf(fp,"#define MULTIIMAGE\n");
    if (od == 1)
        fprintf(fp,"#define POINT_DRAW\n");
    else if (od == 2)
        fprintf(fp,"#define TRI_DRAW\n");
    fprintf(fp,"#include \"TexBindX.c\"\n");
    fprintf(fp,"#undef FUNCTION\n");
    fprintf(fp,"#undef MULTIIMAGE\n");
    fprintf(fp,"#undef TEX_SRC\n");
    fprintf(fp,"#undef FUNCTION_PTRS\n");
    fprintf(fp,"#undef POINT_DRAW\n");
    fprintf(fp,"#undef TRI_DRAW\n");
    fprintf(fp,"\n");
    return funcName;
}

#define TOTAL_FUNCS 2*2*4*2

#ifdef GL_EXT_texture_object
  #define MAX_TEX_SRC 1
#else
  #define MAX_TEX_SRC 0
#endif

main()
{
    TexImageBindFunc function;
    int i;
    int ts, p, od, mi;
    FILE *fp, *header;
    char* names[TOTAL_FUNCS];

    for (i=0; i<TOTAL_FUNCS; i++)
        names[i] = "Noop";
    header = fopen("TexBindX.h", "w");
    fprintf(header, "/*\n * File TexBindX.h generated from TexBindG (source file TexBindG.c)\n */\n\n");
    fp = fopen("TexBindF.c", "w");
    fprintf(fp, "/*\n * File TexBindF.c generated from TexBindG (source file TexBindG.c)\n */\n\n");
    fprintf(fp, "#include \"Tex.h\"\n");
    for (ts=0;ts<=MAX_TEX_SRC;ts++) {
        for (p=0;p<=FUNC_PTRS;p++) {
            for (od=0;od<3;od++) {
                    for (mi=0;mi<2;mi++) {
                                        function.word = 0;
                                        function.bits.texSrc  = ts;
                                        function.bits.functionPtrs  = p;
                                        function.bits.multiimage    = mi;
                                        function.bits.objDraw       = od;
                                        names[function.word] = PrintEntry(fp, ts, p, od, mi);
                                        fprintf(header, "void %s(TestPtr);\n", names[function.word]);
                    }
            }
        }
    }
    fclose(fp);
    fprintf(header, "void Noop(TestPtr);\n");
    fprintf(header, "typedef void (*BindExecuteFunc)(TestPtr);\n");
    fprintf(header, "\nBindExecuteFunc TexImageBindExecuteTable[] = {\n");
    for (i=0; i<TOTAL_FUNCS; i++)
        fprintf(header, "    %s,\n", names[i]);
    fprintf(header, "};\n");
    fclose(header);
    return 0;
}
