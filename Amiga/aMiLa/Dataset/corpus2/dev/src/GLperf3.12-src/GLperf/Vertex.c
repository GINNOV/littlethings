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
// Authors:  Barry Minor, John Spitzer, IBM AWS Graphics Systems (Austin)
//
*/

#include <math.h>
#include "Vertex.h"
#include "VertexX.h"
#include "VertexAX.h"
#include "VertA11X.h"
#include <malloc.h>

void new_Vertex(VertexPtr this)
{
    new_Primitive((PrimitivePtr)this);

    this->layoutSides = 4;
    this->layoutLeft = -1.;
    this->layoutRight = 1.;
    this->layoutTop = 1.;
    this->layoutBottom = -1.;
    this->traversalData = 0;
    /* Set virtual functions */
    this->SetState = Vertex__SetState;
    this->delete = delete_Vertex;
    this->Initialize = Vertex__Initialize;
    this->Cleanup = Vertex__Cleanup;
    this->SetExecuteFunc = Vertex__SetExecuteFunc;
    this->PixelSize = Vertex__Size;
}

void delete_Vertex(TestPtr thisTest)
{
    VertexPtr this = (VertexPtr)thisTest;

    delete_Primitive(thisTest);
}

void Vertex__Initialize(TestPtr thisTest)
{
    VertexPtr this = (VertexPtr)thisTest;
    this->numBgnEnds = (int)ceil((GLfloat)this->numObjects/(GLfloat)this->objsPerBgnEnd);
    this->numObjects = this->numBgnEnds * this->objsPerBgnEnd;
    this->Layout(this);
    Vertex__AddTraversalData(this);
}

void Vertex__Cleanup(TestPtr thisTest)
{
    VertexPtr this = (VertexPtr)thisTest;

    if (this->traversalData) AlignFree(this->traversalData);
}

static void InitializeJumpTable( void)
{
    VertexExecuteTableTable[0] = VertexExecuteTable00;
    VertexExecuteTableTable[1] = VertexExecuteTable01;
    VertexExecuteTableTable[2] = VertexExecuteTable02;
    VertexExecuteTableTable[3] = VertexExecuteTable03;
    VertexExecuteTableTable[4] = VertexExecuteTable04;
    VertexExecuteTableTable[5] = VertexExecuteTable05;
    VertexExecuteTableTable[8] = VertexExecuteTable08;
    VertexExecuteTableTable[9] = VertexExecuteTable09;
    VertexExecuteTableTable[10] = VertexExecuteTable10;
    VertexExecuteTableTable[11] = VertexExecuteTable11;
    VertexExecuteTableTable[12] = VertexExecuteTable12;
    VertexExecuteTableTable[13] = VertexExecuteTable13;
    VertexExecuteTableTable[16] = VertexExecuteTable16;
    VertexExecuteTableTable[17] = VertexExecuteTable17;
    VertexExecuteTableTable[18] = VertexExecuteTable18;
    VertexExecuteTableTable[19] = VertexExecuteTable19;
    VertexExecuteTableTable[20] = VertexExecuteTable20;
    VertexExecuteTableTable[21] = VertexExecuteTable21;
}

void Vertex__SetExecuteFunc(TestPtr thisTest)
{
    VertexPtr this = (VertexPtr)thisTest;
    VertexFunc function;
    VertexFile file;
    VertexArrayFunc arrayfunction;
    ExecuteFunc* VertexExecuteTable;

#ifdef GL_EXT_vertex_array
    if (this->vertexArray) {
	arrayfunction.word = 0;
	arrayfunction.bits.colorData = (this->environ.bufConfig.rgba) ?
				       (this->colorData == PER_VERTEX) : 0;
	arrayfunction.bits.indexData = (this->environ.bufConfig.rgba) ?
				       0 : (this->colorData == PER_VERTEX);
	arrayfunction.bits.normalData = (this->normalData == PER_VERTEX);
	arrayfunction.bits.textureData = (this->environ.bufConfig.rgba) ? 
                                       (this->textureData == PER_VERTEX) : 0;
	arrayfunction.bits.functionPtrs = this->loopFuncPtrs;
       
	this->Execute = VertexArrayExecuteTable[arrayfunction.word];
	return;
    }
#endif

#ifdef GL_VERSION_1_1
    if (this->vertexArray11) {
	VertexArray11Func arrayfunction;

	arrayfunction.word = 0;
	arrayfunction.bits.colorData = (this->environ.bufConfig.rgba) ?
				       (this->colorData == PER_VERTEX) : 0;
	arrayfunction.bits.indexData = (this->environ.bufConfig.rgba) ?
				       0 : (this->colorData == PER_VERTEX);
	arrayfunction.bits.normalData = (this->normalData == PER_VERTEX);
	arrayfunction.bits.textureData = (this->environ.bufConfig.rgba) ? 
                                       (this->textureData == PER_VERTEX) : 0;
	arrayfunction.bits.functionPtrs = this->loopFuncPtrs;
	arrayfunction.bits.drawElements = this->drawElements;
#ifdef GL_SGI_compiled_vertex_array
	arrayfunction.bits.lockArrays = this->lockArrays;
#endif
	arrayfunction.bits.interleaved = this->interleavedData;
       
	this->Execute = VertexArray11ExecuteTable[arrayfunction.word];
	return;
    }
#endif

    InitializeJumpTable();

    file.word = 0;
    function.word = 0;

    function.bits.functionPtrs = this->loopFuncPtrs;
    if (this->environ.bufConfig.rgba)
        file.bits.visual        = RGB;
    else
        file.bits.visual        = CI;
    switch(this->colorData) {
        case None:
            file.bits.colorData     = NONE;
            break;
        case PerFacet:
            file.bits.colorData     = PER_FACET;
            break;
        case PerVertex:
            file.bits.colorData     = PER_VERTEX;
            break;
    }
    switch(this->normalData) {
        case None:
            file.bits.normalData    = NONE;
            break;
        case PerFacet:
            file.bits.normalData    = PER_FACET;
            break;
        case PerVertex:
            file.bits.normalData    = PER_VERTEX;
            break;
    }
    if (this->environ.bufConfig.rgba) {
        switch(this->textureData) {
            case None:
                function.bits.textureData   = NONE;
                break;
            case PerVertex:
                function.bits.textureData   = PER_VERTEX;
                break;
        }
    }

    if (this->vertsPerFacet > 8) {
	/* Special case, only used for many-sided polygons */
	function.bits.vertsPerFacet = 9 - 1;
	function.bits.unrollAmount  = 1 - 1;
    } else {
	function.bits.vertsPerFacet = this->vertsPerFacet - 1;
	function.bits.unrollAmount  = this->loopUnroll - 1;
    }

    /* Dimensions of data to be traversed */
    if (this->environ.bufConfig.rgba) {
	switch (this->texture) {
	    case GL_TEXTURE_1D: 
		function.bits.textureDim = 0; break;
	    case Off:
		/* This may seem bizarre, but this path always exists */
	    case GL_TEXTURE_2D: 
		function.bits.textureDim = 1; break;
#ifdef GL_EXT_texture3D
	    case GL_TEXTURE_3D_EXT: 
		function.bits.textureDim = 2; break;
#endif
#ifdef GL_SGIS_texture4D
	    case GL_TEXTURE_4D_SGIS: 
		function.bits.textureDim = 3; break;
#endif
	}
        function.bits.colorDim = this->colorDim - 3;
    }
    function.bits.vertexDim = this->vertexDim - 2;

    /* This looks nasty with two levels of function pointer
     * indirection (and it is!)  This nastiness is necessitated
     * by some compilers' inabilities to compile files with very
     * large (i.e. >64K entries) arrays.  We have split this
     * large jump table into 18 arrays.  Each array has an
     * entry in the "TableTable" which is located in VertexX.h
     * The jump tables themselves are located in Vert00F.h,
     * Vert01F.h, Vert02F.h, ..., Vert21F.h
     */
    VertexExecuteTable = VertexExecuteTableTable[file.word];
    this->Execute = VertexExecuteTable[function.word];
}

float Vertex__Size(TestPtr thisTest)
{
    VertexPtr this = (VertexPtr)thisTest;
    return this->size;
}

int Vertex__SetState(TestPtr thisTest)
{
    VertexPtr this = (VertexPtr)thisTest;
    GLfloat light[4];
    GLfloat material[4];
    int currentLight;
    GLfloat theta;
    int i;
    int numLights = 0;
    const GLfloat pi = 3.141592654;
    const GLfloat two_pi = 2.0 * pi;

    /* set parent state */
    if (Primitive__SetState(thisTest) == -1) return -1;
    Primitive__SetProjection((PrimitivePtr)this, this->vertexDim);

    /* set own state */
    if(min(this->environ.windowWidth, this->environ.windowHeight)==0)
      this->layoutPadding = 1.0;
    else
      this->layoutPadding = 1./min(this->environ.windowWidth, this->environ.windowHeight);

#ifdef GL_EXT_vertex_array
    if (this->vertexArray && (this->colorData == PerFacet || this->normalData == PerFacet))
	return -1;
#endif

#ifdef GL_VERSION_1_1
    if (this->vertexArray11 && (this->colorData == PerFacet || this->normalData == PerFacet))
	return -1;
#endif

    if (this->loopUnroll % this->vertsPerFacet != 0 &&
        this->vertsPerFacet % this->loopUnroll != 0)
        return -1;

    /* set lighting stuff */
    if (this->numLocalLights==0 && this->numInfiniteLights==0) { /* Lighting turned off */
	glDisable(GL_LIGHTING);
	if (this->environ.bufConfig.rgba) {
	    glColor3f(1.0,1.0,1.0);
	} else {
	    glIndexi((1 << this->environ.bufConfig.indexSize) - 1);
	}
    } else { /* Lighting on */
        numLights = this->numInfiniteLights + this->numLocalLights;
        if (numLights > 8) 
            return -1;
	/* Compute light colors and positions */
	theta = 0.0;
        /* First, define the infinite lights */
        for (currentLight=0; currentLight<this->numInfiniteLights; currentLight++) {
	    CalcRGBColor(theta/two_pi, &light[0], &light[1], &light[2]);
	    light[3] = 1.0;
	    glLightfv(GL_LIGHT0 + currentLight, GL_DIFFUSE, light);
	    light[0] = 1.0;
	    light[1] = 1.0;
	    light[2] = 1.0;
	    light[3] = 1.0;
	    glLightfv(GL_LIGHT0 + currentLight, GL_SPECULAR, light);
	    light[0] = cos(theta);
	    light[1] = sin(theta);
	    light[2] = 0.5;
            light[3] = 0.0;
	    glLightfv(GL_LIGHT0 + currentLight, GL_POSITION, light);
	    theta += two_pi/numLights;
	}
        /* Next, define the local lights */
        for (; currentLight<numLights; currentLight++) {
            CalcRGBColor(theta/two_pi, &light[0], &light[1], &light[2]);
            light[3] = 1.0;
            glLightfv(GL_LIGHT0 + currentLight, GL_DIFFUSE, light);
            light[0] = 1.0;
            light[1] = 1.0;
            light[2] = 1.0;
            light[3] = 1.0;
            glLightfv(GL_LIGHT0 + currentLight, GL_SPECULAR, light);
            light[0] = cos(theta);
            light[1] = sin(theta);
            light[2] = 0.5;
            light[3] = 1.0;
            glLightfv(GL_LIGHT0 + currentLight, GL_POSITION, light);
            theta += two_pi/numLights;
        }
	glEnable(GL_LIGHTING);

	/* Load materials */
	glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, this->shininess);
	if (!this->environ.bufConfig.rgba) {
	    GLint colorIndexes[3];
	    int maxIndex = (1 << this->environ.bufConfig.indexSize) - 1;
	    colorIndexes[0] = 0;
	    colorIndexes[1] = maxIndex;
	    colorIndexes[2] = maxIndex;
	    glMaterialiv(GL_FRONT_AND_BACK, GL_COLOR_INDEXES, colorIndexes);
	} else {
	    if (this->specComp) {
		GLfloat specular[] = { 1., 1., 1., 1. };
		glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, specular);
	    } else {
		GLfloat specular[] = { 0., 0., 0., 1. };
		glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, specular);
	    }
	}

	/* Set local viewer */
	glLightModeli(GL_LIGHT_MODEL_LOCAL_VIEWER, this->localViewer);
    }
    for (i=0; i<numLights; i++)
	glEnable(GL_LIGHT0 + i);
    for (i=numLights; i<8; i++)
	glDisable(GL_LIGHT0 + i);

    if (this->normalData!=None && this->colorData!=None) {
        glColorMaterial(this->colorMatSide, this->colorMaterial);
	glEnable(GL_COLOR_MATERIAL);
    } else {
	glDisable(GL_COLOR_MATERIAL);
    }

    glShadeModel(this->shadeModel);

#ifdef GL_EXT_vertex_array
    if (this->vertexArray && strstr(this->environ.glExtensions, "GL_EXT_vertex_array")) {
	if (this->colorData == PerVertex)
	    if (this->environ.bufConfig.rgba) {
		glEnable(GL_COLOR_ARRAY_EXT);
		glDisable(GL_INDEX_ARRAY_EXT);
	    } else {
		glDisable(GL_COLOR_ARRAY_EXT);
		glEnable(GL_INDEX_ARRAY_EXT);
	    }
	if (this->normalData == PerVertex)
	    glEnable(GL_NORMAL_ARRAY_EXT);
	else
	    glDisable(GL_NORMAL_ARRAY_EXT);
	if (this->textureData == PerVertex && this->environ.bufConfig.rgba)
	    glEnable(GL_TEXTURE_COORD_ARRAY_EXT);
	else
	    glDisable(GL_TEXTURE_COORD_ARRAY_EXT);
	glEnable(GL_VERTEX_ARRAY_EXT);
    } else {
	glDisable(GL_INDEX_ARRAY_EXT);
	glDisable(GL_COLOR_ARRAY_EXT);
	glDisable(GL_NORMAL_ARRAY_EXT);
	glDisable(GL_TEXTURE_COORD_ARRAY_EXT);
	glDisable(GL_VERTEX_ARRAY_EXT);
    }
#endif

#ifdef GL_VERSION_1_1
    if (this->vertexArray11) {
	if (this->colorData == PerVertex)
	    if (this->environ.bufConfig.rgba) {
		glEnableClientState(GL_COLOR_ARRAY);
		glDisableClientState(GL_INDEX_ARRAY);
	    } else {
		glDisableClientState(GL_COLOR_ARRAY);
		glEnableClientState(GL_INDEX_ARRAY);
	    }
	if (this->normalData == PerVertex)
	    glEnableClientState(GL_NORMAL_ARRAY);
	else
	    glDisableClientState(GL_NORMAL_ARRAY);
	if (this->textureData == PerVertex && this->environ.bufConfig.rgba)
	    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	else
	    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnableClientState(GL_VERTEX_ARRAY);
    } else {
	glDisableClientState(GL_INDEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);
    }
#endif

    return 0;
}

static void AddNormalData(GLfloat* data, const GLfloat x, const GLfloat y)
{
    const GLfloat root2 = sqrt(2.0);

    if (x < -1.0 || 1.0 < x || y < -1.0 || 1.0 < y) {
	*data++ = 0.0;
	*data++ = 0.0;
	*data++ = 1.0;
    } else {
	*data++ = x/root2;
	*data++ = y/root2;
	*data++ = sqrt(2.0 - x*x - y*y)/root2;
    }
}

void Vertex__AddTraversalData(VertexPtr this)
/*
// This will take numVertices of 3d float coordinates pointed to by traversalData, and
// add the appropriate facet/vertex color, normal, and texture data.
*/
{
    GLfloat x, y;
    int i, j, k;
    int facetDataSize, vertexDataSize, dataSize;
    GLfloat* newTraverseData; 
    GLfloat* newptr;
    GLfloat* ptr = this->traversalData;
    int rgba = this->environ.bufConfig.rgba;
    int colorData = this->colorData;
    int normalData = this->normalData;
    int textureData = this->textureData;
    int numBgnEnds = this->numBgnEnds;
    int facetsPerBgnEnd = this->facetsPerBgnEnd;
    int vertsPerFacet = this->vertsPerFacet;
    const GLfloat colorFactor = 0.8;
    GLfloat texFactorX, texFactorY, texFactorZ;
    int windowDim = min(this->environ.windowWidth, this->environ.windowHeight);
    int vertexColorSize, vertexNormalSize, vertexTexSize;
    int rampsize = rgba ? 0 : (1 << this->environ.bufConfig.indexSize);

    /* These variables are for ordering depth values */
    GLdouble modelMatrix[16];
    GLdouble projMatrix[16];
    GLint viewport[4];
    GLdouble xd, yd, zd;
    GLdouble depthBits, epsilon;
    GLdouble base, range, delta;

    facetDataSize = (colorData == PerFacet) ? ((rgba) ? this->colorDim : 1) : 0;
    facetDataSize += (normalData == PerFacet) ? 3 : 0;
    vertexColorSize = (colorData == PerVertex) ? ((rgba) ? this->colorDim : 1) : 0;
    vertexNormalSize = (normalData == PerVertex) ? 3 : 0;
    switch (this->texture) {
    case Off:
	vertexTexSize = 0;
	break;
    case GL_TEXTURE_1D:
	vertexTexSize = (textureData == PerVertex) ? 1 : 0;
	break;
    case GL_TEXTURE_2D:
	vertexTexSize = (textureData == PerVertex) ? 2 : 0;
	break;
#ifdef GL_EXT_texture3D
    case GL_TEXTURE_3D_EXT:
	vertexTexSize = (textureData == PerVertex) ? 3 : 0;
	break;
#endif
#ifdef GL_SGIS_texture4D
    case GL_TEXTURE_4D_SGIS:
	vertexTexSize = (textureData == PerVertex) ? 4 : 0;
	break;
#endif
    }
    vertexTexSize = rgba ? vertexTexSize : 0;
    vertexDataSize = vertexColorSize + vertexNormalSize + vertexTexSize + this->vertexDim;
    dataSize = numBgnEnds * ( facetsPerBgnEnd * (facetDataSize + vertsPerFacet * vertexDataSize));
    newTraverseData = (GLfloat*)AlignMalloc(dataSize * sizeof(GLfloat), this->memAlignment);
    newptr = newTraverseData;

#ifdef GL_EXT_vertex_array
    if (this->vertexArray) {
	this->vertexStride = vertexDataSize * sizeof(GLfloat);
	this->bgnendSize = this->vertsPerBgnEnd * vertexDataSize * sizeof(GLfloat);
	this->colorPtr = (void*)newTraverseData;
	this->indexPtr = (void*)newTraverseData;
	this->normalPtr = (void*)(newTraverseData + vertexColorSize);
	this->texPtr = (void*)(newTraverseData + vertexColorSize + vertexNormalSize);
	this->vertexPtr = (void*)(newTraverseData + vertexColorSize + vertexNormalSize + vertexTexSize);
    }
#endif

#ifdef GL_VERSION_1_1
    if (this->vertexArray11) {
	this->vertexStride = vertexDataSize * sizeof(GLfloat);
	this->bgnendSize = this->vertsPerBgnEnd * vertexDataSize * sizeof(GLfloat);
	this->colorPtr = (void*)newTraverseData;
	this->indexPtr = (void*)newTraverseData;
	this->normalPtr = (void*)(newTraverseData + vertexColorSize);
	this->texPtr = (void*)(newTraverseData + vertexColorSize + vertexNormalSize);
	this->vertexPtr = (void*)(newTraverseData + vertexColorSize + vertexNormalSize + vertexTexSize);
    }
#endif

    if (this->vertexDim == 3 && this->zOrder != Coplanar) {
	GLdouble numVertices = numBgnEnds * facetsPerBgnEnd * vertsPerFacet;
        glGetDoublev(GL_MODELVIEW_MATRIX, modelMatrix);
        glGetDoublev(GL_PROJECTION_MATRIX, projMatrix);
        glGetIntegerv(GL_VIEWPORT, viewport);
        glGetDoublev(GL_DEPTH_BITS, &depthBits);
	epsilon = pow(2.0, -depthBits);
        mysrand(15000);

	switch (this->zOrder) {
	case Random:
	    range = 1. - epsilon;
	    base = epsilon;
	    delta = 0.;
	    break;
	case BackToFront:
	    range = (1. - epsilon) / numVertices;
	    base = 1. - range - epsilon;
	    delta = -range;
	    break;
	case FrontToBack:
	    range = (1. - epsilon) / numVertices;
	    base = epsilon;
	    delta = range;
	    break;
	}
    }

    /* Figure out texture scaling factors given desired texture LOD */
    if (textureData == PerVertex && this->environ.bufConfig.rgba) {
        texFactorX = pow(2., this->texLOD) * 
                     (float)this->environ.windowWidth / (float)this->texWidth;
        texFactorY = pow(2., this->texLOD) * 
                     (float)this->environ.windowHeight / (float)this->texHeight;
#ifdef GL_EXT_texture3D
        /* This will need to be fixed at some point... */
        texFactorZ = pow(2., this->texLOD);
#endif
    }

    for (i=0; i<numBgnEnds; i++) {
	x = *ptr++;
	y = *ptr++;
	for (j=0; j<facetsPerBgnEnd; j++) {
	    if (j != 0) {
	        x = *ptr++;
	        y = *ptr++;
	    }
	    if (colorData == PerFacet)
		if (rgba) {
		    if (this->colorDim == 3) {
			AddColorRGBData(newptr, x, y, colorFactor);
			newptr += 3;
		    } else {
			AddColorRGBAData(newptr, x, y, colorFactor);
			newptr += 4;
		    }
		} else {
#ifdef GL_SGI_array_formats
		    if (this->vertexArray11 && this->interleavedData) {
			AddColorCIDataUI(newptr, x, y, windowDim, rampsize);
		    } else
#endif
		    AddColorCIData(newptr, x, y, windowDim, rampsize);
		    newptr += 1;
		}
	    if (normalData == PerFacet) {
		AddNormalData(newptr, x, y);
		newptr += 3;
	    }
	    for (k=0; k<vertsPerFacet; k++) {
		if (k != 0) {
		    x = *ptr++;
		    y = *ptr++;
		}
		if (colorData == PerVertex)
		    if (rgba) {
			if (this->colorDim == 3) {
			    AddColorRGBData(newptr, x, y, colorFactor);
			    newptr += 3;
			} else {
			    AddColorRGBAData(newptr, x, y, colorFactor);
			    newptr += 4;
			}
		    } else {
#ifdef GL_SGI_array_formats
			if (this->vertexArray11 && this->interleavedData) {
			    AddColorCIDataUI(newptr, x, y, windowDim, rampsize);
			} else
#endif
			AddColorCIData(newptr, x, y, windowDim, rampsize);
			newptr += 1;
		    }
		if (normalData == PerVertex) {
		    AddNormalData(newptr, x, y);
		    newptr += 3;
		}
		if (textureData == PerVertex && this->environ.bufConfig.rgba) {
		    if (this->texture == GL_TEXTURE_1D) {
		        AddTexture1DData(newptr, x, y, texFactorX);
		        newptr += 1;
		    } else if (this->texture == GL_TEXTURE_2D) {
		        AddTexture2DData(newptr, x, y, texFactorX, texFactorY);
		        newptr += 2;
#ifdef GL_EXT_texture3D
		    } else if (this->texture == GL_TEXTURE_3D_EXT) {
		        AddTexture3DData(newptr, x, y, texFactorX, texFactorY, texFactorZ);
		        newptr += 3;
#endif
		    }
		}
		if (this->vertexDim == 2) {
		    *newptr++ = x;
		    *newptr++ = y;
		} else { /* vertexDim == 3 */
		    if (this->zOrder != Coplanar) {
			GLdouble vertex = k + vertsPerFacet * (j + i * facetsPerBgnEnd);
	                GLdouble z = base + 
                                     delta * vertex +
                                     range * (GLdouble)myrand()/(GLdouble)MY_RAND_MAX;
		        gluUnProject((x+1.)/2.*(GLfloat)windowDim,
			 	     (y+1.)/2.*(GLfloat)windowDim,
				     z,
				     modelMatrix,
				     projMatrix,
				     viewport,
				     &xd, &yd, &zd);
		        *newptr++ = (GLfloat)xd;
		        *newptr++ = (GLfloat)yd;
		        *newptr++ = (GLfloat)zd;
		    } else {
		        *newptr++ = x;
		        *newptr++ = y;
		        *newptr++ = -1.;
		    }
		}
	    }
	}
    }
    free(this->traversalData);
    this->traversalData = newTraverseData;
}

void Vertex__Layout(VertexPtr this)
/*
 * Expected inputs to this routine (elements set in Vertex struct):
 *   layoutPoints
 *   layoutLeft
 *   layoutRight
 *   layoutBottom
 *   layoutTop
 *   layoutPadding
 *   layoutSides
 *   acceptObjs
 *   rejectObjs
 *   clipObjs
 * Expected outputs:
 *   traversalData
 *
 * This will produce layoutPoints 2d float coords with the appropriate number trivially
 * accepted, trivially rejected, and clipped (on the boundary) as determined by the
 * acceptObjs, rejectObjs, and clipObjs variables, respectively.  
 *
 * Trivially accepted points will have coordinates:
 *   layoutLeft + layoutPadding <= x <= layoutRight - layoutPadding
 *   layoutBottom + layoutPadding <= y <= layoutTop - layoutPadding
 *   (the visible region of the screen is from -1.0 to 1.0 in each coordinates,
 *    so set these left,right,top,bottom,padding to appropriate values)
 *
 * Clipped objects are put on the boundary of 1 to 4 sides, as determined by the
 * layoutSides variable.  This enables accurate clipping to non-square windows,
 * when it's best to have (layoutSides==2), and have all the clipped points lie 
 * on the left and bottom edges of the window.  This is because the viewport may 
 * not line up with the right and top sides of the window.
 *
 * This function will malloc the appropriate amount of space and snap the 
 * traversalData variable to it.
 */
{
    int             numacc, numrej, numclip;
    int             i;
    int             sidecount;
    GLfloat         acceptObjs = this->acceptObjs;
    GLfloat         rejectObjs = this->rejectObjs;
    GLfloat         clipObjs = this->clipObjs;
    int             layoutPoints = this->layoutPoints;
    GLfloat*        traversalData;
    GLfloat         xstep, ystep;
    GLfloat         left = this->layoutLeft;
    GLfloat         right = this->layoutRight;
    GLfloat         bottom = this->layoutBottom;
    GLfloat         top = this->layoutTop;
    int             sides = this->layoutSides;
    int             side;
    GLfloat         cx0[4], cx1[4], cy0[4], cy1[4];
    GLfloat         segments;
    GLfloat         p;
    
    if (fabs(1.0 - acceptObjs - rejectObjs - clipObjs) > .01) {
        printf("AcceptObjs + RejectObjs + ClipObjs not equal to 1\n");
        exit(1);
    }

    this->traversalData = (GLfloat*)malloc(layoutPoints * sizeof(GLfloat) * 2);
    CheckMalloc(this->traversalData);
    traversalData = this->traversalData;

    numacc = (int) (acceptObjs * ((GLfloat) layoutPoints));
    numrej = (int) (rejectObjs * ((GLfloat) layoutPoints));
    numclip = (int) (clipObjs * ((GLfloat) layoutPoints));

    numacc += layoutPoints - numacc - numrej - numclip;

    /* Set variables and coefficients for finding points on boundary */
    segments = (GLfloat)((numclip + sides - 1)/sides + 1);
    xstep = (right - left)/segments;
    ystep = (top - bottom)/segments;
    cx0[0] = left;
    cx1[0] = xstep;
    cy0[0] = bottom;
    cy1[0] = 0.;
    cx0[1] = left;
    cx1[1] = 0.;
    cy0[1] = top;
    cy1[1] = -ystep;
    cx0[2] = right;
    cx1[2] = -xstep;
    cy0[2] = top;
    cy1[2] = 0.;
    cx0[3] = right;
    cx1[3] = 0.;
    cy0[3] = bottom;
    cy1[3] = ystep;
    
    for (i = 0; i < numclip; i++) {
        p = (GLfloat)((i + sides) / sides);
        side = i % sides;
        *traversalData++ = cx1[side] * p + cx0[side];
        *traversalData++ = cy1[side] * p + cy0[side];
    }

    for (i = 0; i < numrej; i++) {
        *traversalData++ = -2.0;
        *traversalData++ = 2.0;
    }

    /* Set variables for finding points in the interior */
    left   += this->layoutPadding;
    right  -= this->layoutPadding;
    bottom += this->layoutPadding;
    top    -= this->layoutPadding;
    sidecount = (int)ceil(sqrt((double)numacc));
    segments = (sidecount==1) ? 1. : (GLfloat)(sidecount - 1);
    xstep = (right - left)/segments;
    ystep = (top - bottom)/segments;

    for (i = 0; i < numacc; i++) {
	*traversalData++ = left   + (GLfloat)(i % sidecount) * xstep;
	*traversalData++ = bottom + (GLfloat)(i / sidecount) * ystep;
    }
}
