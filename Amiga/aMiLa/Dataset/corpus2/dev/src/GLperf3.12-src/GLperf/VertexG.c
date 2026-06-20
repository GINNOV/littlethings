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
#include <stdio.h>
#include <stdlib.h>
#ifdef WIN32
#include <windows.h>
#endif
#include <GL/gl.h>
#include "FuncEnum.h"
#include <malloc.h>

/* This will be set by compile time #defines                     */
/* They control the size and functionality of the code generated */
#ifdef FULL_TEXTURE_PATHS
  #define MIN_TEX_DIM 1
 #if defined(GL_SGIS_texture4D)
  #define MAX_TEX_DIM 4
 #elif defined(GL_EXT_texture3D)
  #define MAX_TEX_DIM 3
 #else
  #define MAX_TEX_DIM 2
 #endif
#else
  #define MIN_TEX_DIM 2
  #define MAX_TEX_DIM 2
#endif
#ifdef FULL_COLOR_PATHS
  #define MAX_COLOR_DIM 4
#else
  #define MAX_COLOR_DIM 3
#endif
#ifdef FULL_VERTEX_PATHS
  #define MIN_VERT_DIM 2
#else
  #define MIN_VERT_DIM 3
#endif
#ifdef FULL_FUNCPTR_PATHS
  #define FUNC_PTRS 1
#else
  #define FUNC_PTRS 0
#endif
#ifdef FULL_UNROLL_PATHS
  #define MAX_UNROLL 8
#else
  #define MAX_UNROLL 1
#endif

char* visualSuccinct[] = {
    "Idx",
    "RGB"
};

char* pntSuccinct[] = {
    "Pf",
    "Pt"
};

char* colorSuccinct[] = {
    "n",
    "v",
    "f",
};

char* normalSuccinct[] = {
    "n",
    "v",
    "f",
};

char* textureSuccinct[] = {
    "n",
    "v"
};

char* visualVerbose[] = {
    "CI",
    "RGB"
};

char* pntVerbose[] = {
    "NoPtrs",
    "Ptrs"
};

char* colorVerbose[] = {
    "NONE",
    "PER_VERTEX",
    "PER_FACET",
};

char* normalVerbose[] = {
    "NONE",
    "PER_VERTEX",
    "PER_FACET",
};

char* textureVerbose[] = {
    "NONE",
    "PER_VERTEX"
};

char* PrintEntry(FILE *fp, int vis, int p, int c, int n, int t, int u, int v, int vd, int cd, int td)
{
    char* funcName = (char*)malloc(64);
    sprintf(funcName,"%s%sC%sN%sT%sU%dV%d_%d%d%d", visualSuccinct[vis], pntSuccinct[p], colorSuccinct[c], normalSuccinct[n], textureSuccinct[t], u, v, vd, cd, td);
    fprintf(fp,"#define FUNCTION %s\n", funcName);
    fprintf(fp,"#define VISUAL %s\n", visualVerbose[vis]);
    if (p) {
        fprintf(fp,"#define FUNCTION_PTRS\n");
    }
    fprintf(fp,"#define COLOR %s\n", colorVerbose[c]);
    fprintf(fp,"#define NORMAL %s\n", normalVerbose[n]);
    fprintf(fp,"#define TEXTURE %s\n", textureVerbose[t]);
    fprintf(fp,"#define UNROLL          %d\n", u);
    fprintf(fp,"#define VERTS_PER_FACET %d\n", v);
    fprintf(fp,"#define VERTEX_DIM %d\n", vd);
    fprintf(fp,"#define COLOR_DIM %d\n", cd);
    fprintf(fp,"#define TEX_DIM %d\n", td);
    fprintf(fp,"#include \"VertexX.c\"\n");
    fprintf(fp,"#undef FUNCTION\n");
    fprintf(fp,"#undef UNROLL\n");
    fprintf(fp,"#undef VERTS_PER_FACET\n");
    fprintf(fp,"#undef VISUAL\n");
    fprintf(fp,"#undef FUNCTION_PTRS\n");
    fprintf(fp,"#undef COLOR\n");
    fprintf(fp,"#undef NORMAL\n");
    fprintf(fp,"#undef TEXTURE\n");
    fprintf(fp,"#undef VERTEX_DIM\n");
    fprintf(fp,"#undef COLOR_DIM\n");
    fprintf(fp,"#undef TEX_DIM\n");
    fprintf(fp,"\n");
    return funcName;
}

FILE* OpenSrcFile(int fileNum)
{
    FILE* fp;
    char filename[64];

    sprintf(filename, "Vert%02dF.c", fileNum);
    fp = fopen(filename, "w");
    fprintf(fp, "/*\n * File %s generated from VertexG (source file VertexG.c)\n */\n\n", filename);
    fprintf(fp, "#include \"Vert%02dF.h\"\n", fileNum);
    return fp;
}

FILE* OpenHeaderFile(int fileNum)
{
    FILE* fp;
    char filename[64];

    sprintf(filename, "Vert%02dF.h", fileNum);
    fp = fopen(filename, "w");
    fprintf(fp, "/*\n * File %s generated from VertexG (source file VertexG.c)\n */\n\n", filename);
    return fp;
}

#if ((defined(GL_EXT_texture3D) || defined(GL_SGIS_texture4D)) && defined (FULL_TEXTURE_PATHS))
  #define TEX_DIM_BITS 4
#else
  #define TEX_DIM_BITS 2
#endif

#define TOTAL_FUNCS TEX_DIM_BITS*2*9*8*2*2*2
#define TOTAL_FILES 2*4*4

main()
{
  VertexFile file;
  VertexFunc function;
  int i;
  int vis,p,c,n,t;
  int v,u;
  int vd, cd, td;
  FILE *fp_src, *fp_header, *fp_table;
  char* funcnames[TOTAL_FUNCS];
  char* filenames[TOTAL_FILES];

  for (i=0; i<TOTAL_FILES; i++)
    filenames[i] = "0";

  fp_table = fopen("VertexX.h", "w");
  fprintf(fp_table, "/*\n * File VertexX.h generated from VertexG (source file VertexG.c)\n */\n\n");
  fprintf(fp_table, "typedef void (*ExecuteFunc)(TestPtr);\n");

  for (vis=0;vis<2;vis++) {
    for (c=0;c<3;c++) {
      for (n=0;n<3;n++) {

	file.word = 0;
	file.bits.normalData    = n;
	file.bits.colorData     = c;
	file.bits.visual        = vis;

        fp_src = OpenSrcFile(file.word);
	filenames[file.word] = (char*)malloc(64);
	sprintf(filenames[file.word], "VertexExecuteTable%02d", file.word);
	fprintf(fp_table, "extern ExecuteFunc %s[];\n", filenames[file.word]);
        fp_header = OpenHeaderFile(file.word);
	fprintf(fp_header, "#include \"Vertex.h\"\n");
	for (i=0; i<TOTAL_FUNCS; i++)
	  funcnames[i] = "Noop";

        for (p=0;p<=FUNC_PTRS;p++) {
          for (vd=MIN_VERT_DIM;vd<=3;vd++) {
            if (vis==0) { /* Color index */
              for (v=1;v<=9;v++) {
                for (u=1;u<=MAX_UNROLL;u++) {
                  if (((u%v==0) || (v%u==0)) && ((v==9)?(u==1):1)) {
                    function.word = 0;
                    function.bits.vertsPerFacet = v-1;
                    function.bits.unrollAmount  = u-1;
                    function.bits.textureData   = 0;
                    function.bits.functionPtrs  = p;
                    function.bits.vertexDim     = vd-2;
                    funcnames[function.word] = PrintEntry(fp_src, vis, p, c, n, 0 /* t */, 
                                                    u, v, vd, 0 /* cd */, 0 /* td */);
                    fprintf(fp_header, "void %s(TestPtr);\n", 
                                    funcnames[function.word]);
                  }
                }
              }
            } else { /* RGB */
              for (t=0;t<2;t++) {
                for (td=MIN_TEX_DIM;td<=MAX_TEX_DIM;td++) {
                  for (cd=3;cd<=MAX_COLOR_DIM;cd++) {
                    for (v=1;v<=9;v++) {
                      for (u=1;u<=MAX_UNROLL;u++) {
                        if (((u%v==0) || (v%u==0)) && ((v==9)?(u==1):1)) {
                          function.word = 0;
                          function.bits.vertsPerFacet = v-1;
                          function.bits.unrollAmount  = u-1;
                          function.bits.textureData   = t;
                          function.bits.functionPtrs  = p;
                          function.bits.vertexDim     = vd-2;
                          function.bits.colorDim      = cd-3;
                          function.bits.textureDim    = td-1;
                          funcnames[function.word] = PrintEntry(fp_src, vis, p, c, n, t, 
                                                            u, v, vd, cd, td);
                          fprintf(fp_header, "void %s(TestPtr);\n", 
                                          funcnames[function.word]);
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }

        fclose(fp_src);
	fprintf(fp_header, "void Noop(TestPtr);\n");
	fprintf(fp_header, "typedef void (*ExecuteFunc)(TestPtr);\n");
	fprintf(fp_header, "\nExecuteFunc VertexExecuteTable%02d[] = {\n", file.word);
	for (i=0; i<TOTAL_FUNCS; i++)
	  fprintf(fp_header, "    %s,\n", funcnames[i]);
	fprintf(fp_header, "};\n");
        fclose(fp_header);
      }
    }
  }

  fprintf(fp_table, "ExecuteFunc* VertexExecuteTableTable[%d];\n", TOTAL_FILES);
  fclose(fp_table);
  return 0;
}
