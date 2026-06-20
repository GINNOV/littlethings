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
#include <assert.h>

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

char* interleavedSuccinct[] = {
    "",
    "Interlv"
};

char* drawElementsSuccinct[] = {
    "",
    "Drawels"
};

char* lockArraysSuccinct[] = {
    "",
    "Locked"
};

char* vertexFormat[] = {
    "",
    "",
    "V2F",
    "V3F",
    "V4F",
};

char* colorFormat[] = {
    "",
    "C3F_"
};

char* indexFormat[] = {
    "",
    "IUI_",
};

char* normalFormat[] = {
    "",
    "N3F_"
};

char* textureFormat[] = {
    "",
    "T2F_"
};

char* PrintEntry(FILE *fp, int p, int cd, int id, int nd, int td, int ld, int de, int la, int vf)
{
    char* funcName = (char*)malloc(64);
    char* interleavedFormat = (char*)malloc(64);

    /* Reject illegal combinations */
    if ((cd && id)
	|| (cd && (td || nd))
#ifndef GL_SGI_index_texture
	|| (id && td)
#endif
#ifndef GL_SGI_array_formats
	|| (ld && id)
#endif
	)
	return NULL;

    sprintf(funcName,"VertArr11%s%s%s%s%s%s%s%s",
        pntSuccinct[p], 
        colorSuccinct[cd], 
        indexSuccinct[id], 
        normalSuccinct[nd], 
        textureSuccinct[td],
	interleavedSuccinct[ld],
	drawElementsSuccinct[de],
	lockArraysSuccinct[la]
        );
    fprintf(fp,"#define FUNCTION %s\n", funcName);


    if (p)
        fprintf(fp,"#define FUNCTION_PTRS\n");
    if (ld) {
	sprintf(interleavedFormat, "GL_%s%s%s%s%s",
	    colorFormat[cd],
	    indexFormat[id],
	    textureFormat[td],
	    normalFormat[nd],
	    vertexFormat[vf]);
	if (id) {
	    sprintf(interleavedFormat, "%s_SGI", interleavedFormat);
	}
	fprintf(fp,"#define INTERLEAVED_FORMAT %s\n", interleavedFormat);
	fprintf(fp, "#define INTERLEAVED_DATA\n");
    } else {
	if (cd)
	    fprintf(fp,"#define COLOR_DATA\n");
	if (id)
	    fprintf(fp,"#define INDEX_DATA\n");
	if (nd)
	    fprintf(fp,"#define NORMAL_DATA\n");
	if (td)
	    fprintf(fp,"#define TEXTURE_DATA\n");
    }
    if (de)
	fprintf(fp, "#define DRAW_ELEMENTS\n");
#ifdef GL_SGI_compiled_vertex_array
    if (la)
	fprintf(fp, "#define LOCK_ARRAYS\n");
#endif
    fprintf(fp,"#include \"VertA11X.c\"\n");
    fprintf(fp,"#undef FUNCTION\n");
    fprintf(fp,"#undef TEXTURE_DATA\n");
    fprintf(fp,"#undef NORMAL_DATA\n");
    fprintf(fp,"#undef INDEX_DATA\n");
    fprintf(fp,"#undef COLOR_DATA\n");
    fprintf(fp,"#undef FUNCTION_PTRS\n");
    fprintf(fp,"#undef INTERLEAVED_FORMAT\n");
    fprintf(fp,"#undef INTERLEAVED_DATA\n");
    fprintf(fp,"#undef DRAW_ELEMENTS\n");
#ifdef GL_SGI_compiled_vertex_array
    fprintf(fp,"#undef LOCK_ARRAYS\n");
#endif
    fprintf(fp,"\n");
    return funcName;
}

#ifdef GL_SGI_compiled_vertex_array
#define LA 2
#else
#define LA 1
#endif

#define TOTAL_FUNCS 2*2*2*2*2*2*2*LA

main()
{
#ifdef GL_VERSION_1_1
    VertexArray11Func function;
#endif
    int i;
    int p, cd, id, nd, td, de, la, ld;
    FILE *fp, *header;
    char* names[TOTAL_FUNCS];
    char* funcName;

    for (i=0; i<TOTAL_FUNCS; i++)
        names[i] = "Noop";
    header = fopen("VertA11X.h", "w");
    fp = fopen("VertA11F.c", "w");
    fprintf(fp, "#include \"Vertex.h\"\n");
#ifdef GL_VERSION_1_1
    for (p=0;p<=FUNC_PTRS;p++) {
	for (de=0; de<2; de++) {
	    for (la=0; la<LA; la++) {
		for (ld=0; ld<2; ld++) {
		    for (cd=0;cd<2;cd++) {
			for (id=0;id<2;id++) {
			    for (nd=0;nd<2;nd++) {
				for (td=0;td<2;td++) {
				    function.word = 0;
				    function.bits.functionPtrs 	= p;
				    function.bits.colorData 	= cd;
				    function.bits.indexData 	= id;
				    function.bits.normalData 	= nd;
				    function.bits.textureData 	= td;
				    function.bits.interleaved	= ld;
				    function.bits.drawElements 	= de;
				    function.bits.lockArrays 	= la;
				    funcName = PrintEntry(fp, p, cd, id, nd,
							  td, ld, de, la, 3);
				    if (funcName) {
					assert(function.word < TOTAL_FUNCS);
					names[function.word] = funcName;
					fprintf(header, "void %s(TestPtr);\n",
						names[function.word]);
				    }
				}
			    }
			}
		    }
		}
	    }
        }
    }
#endif
    fclose(fp);
    fprintf(header, "void Noop(TestPtr);\n");
    fprintf(header, "typedef void (*VertexArray11ExecuteFunc)(TestPtr);\n\n");
    fprintf(header, "VertexArray11ExecuteFunc VertexArray11ExecuteTable[] = {\n");
    for (i=0; i<TOTAL_FUNCS; i++)
        fprintf(header, "    %s,\n", names[i]);
    fprintf(header, "};\n");
    fclose(header);
    return 0;
}
