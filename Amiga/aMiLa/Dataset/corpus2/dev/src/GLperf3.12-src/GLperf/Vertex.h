/*
 *   (C) COPYRIGHT International Business Machines Corp. 1993
 *   All Rights Reserved
 *   Licensed Materials - Property of IBM
 *   US Government Users Restricted Rights - Use, duplication or
 *   disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

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

#if (defined(INC_REASON)) && (INC_REASON == INFO_ITEM_STRUCT)
#include "Primitve.h"
    int numInfiniteLights;/* [0,8]                                                        */
    int numLocalLights; /* [0,8]                                                          */
    GLfloat shininess;  /* [0.0,128.0]                                                    */
    GLfloat specComp;   /* On or Off */
    int colorMaterial;  /* GL_DIFFUSE, GL_AMBIENT_DIFFUSE, ...                            */
    int colorMatSide;   /* GL_FRONT, GL_BACK, GL_FRONT_AND_BACK                           */
    int localViewer;    /* On or Off                                                      */
    int shadeModel;     /* GL_FLAT or GL_SMOOTH                                           */
    int numVertices;    /* this should equal numBgnEnds * vertsPerBgnEnd                  */
                        /*          OR       numBgnEnds * facetsPerBgnEnd * vertsPerFacet */
    int orientation;    /* Can be Vertical, Horizontal, or Random                         */
    float size;         /* Size of primitive in pixels must be > 0.0                      */
    int antiAlias;      /* On or Off                                                      */
    int primitiveType;  /* GL_POINTS, GL_LINES...                                         */
    int vertexDim;      /* Dimension of vertex data (i.e. 2 or 3 D) [2, 3]   */
 #ifdef GL_EXT_vertex_array
    int vertexArray;    /* Use the vertex_array */
 #endif
 #ifdef GL_VERSION_1_1
    int vertexArray11;	/* 1.1 vertex arrays */
    int drawElements;
    int interleavedData;
 #endif
 #ifdef GL_SGI_compiled_vertex_array
    int lockArrays;
 #endif
    /* Members below this line aren't user settable */
    int vertsPerFacet;
    int vertsPerBgnEnd;
    int facetsPerBgnEnd;
    int objsPerBgnEnd;  /* number of objects drawn within glBegin/glEnd pair              */
    int numBgnEnds;
    float layoutPadding;/* amount of space in NDC from edge to first primitive center     */
    float layoutLeft;
    float layoutRight;
    float layoutBottom;
    float layoutTop;
    int layoutPoints;
    int layoutSides;
 #if defined(GL_EXT_vertex_array) || defined(GL_VERSION_1_1)
    GLsizei vertexStride;
    int bgnendSize;
    void* colorPtr;
    void* indexPtr;
    void* normalPtr;
    void* texPtr;
    void* vertexPtr;
 #endif
    /* void Initialize(TestPtr); */               /* virtual function */
    /* void Cleanup(TestPtr); */                  /* virtual function */
    /* void Execute(TestPtr);   */                /* virtual function */
    /* int SetState(TestPtr);  */                 /* virtual function */
    /* void SetExecuteFunc(TestPtr); */           /* virtual function */
    /* float Size(TestPtr); */                    /* virtual function */
    void (*Layout)(struct _Vertex *);             /* virtual function */
#elif (defined(INC_REASON)) && (INC_REASON == INFO_ITEM_ARRAY)
#include "Primitve.h"
#ifdef GL_EXT_vertex_array
    {
        VertexArray,
        "Use Vertex Array Extension",
        offset(vertexArray),
        Enumerated,
        {
            { False,                    "False" },
            { True,                     "True" },
            { End }
        },
        { False }
    },
#endif
#ifdef GL_VERSION_1_1 
    {
	VertexArray11,
	"Use 1.1 Vertex Arrays",
	offset(vertexArray11),
	Enumerated,
        {
            { False,                    "False" },
            { True,                     "True" },
            { End }
        },
        { False }
    },
#endif
    {
        Size,
        "Primitive Size",
        offset(size),
        RangedFloatOrInt,
        {
            { .01 },
            { 10000000 }
        },
        { NotUsed, 10.0 }
    },
    {
        ObjsPerBeginEnd,
        "Objects Per Begin/End Structure",
        offset(objsPerBgnEnd),
        RangedInteger,
        {
            { 1 },
            { 100000 },
        },
        { 120 }
    },
    {
        VertexDim,
        "Dimension of Vertex Data",
        offset(vertexDim),
        RangedInteger,
        {
#ifdef FULL_VERTEX_PATHS
            { 2 },
#else
	    { 3 },
#endif
            { 3 },
        },
        { 3 }
    },
    {
        Orientation,
        "Orientation",
        offset(orientation),
        Enumerated,
        {
            { Random,                   "Random" },
            { Vertical,                 "Vertical" },
            { Horizontal,               "Horizontal" },
            { End }
        },
        { Random }
    },
    {
        Antialias,
        "Antialiasing",
        offset(antiAlias),
        Enumerated,
        {
            { Off,                      "Off" },
            { On,                       "On: GL_DONT_CARE" },
            { GL_DONT_CARE,             "On: GL_DONT_CARE" },
            { GL_FASTEST,               "On: GL_FASTEST" },
            { GL_NICEST,                "On: GL_NICEST" },
            { End }
        },
        { Off }
    },
    {
        ColorData,
        "Color/Index Data",
        offset(colorData),
        Enumerated,
        {
            { None,                     "None" },
            { PerFacet,                 "PerFacet" },
            { PerVertex,                "PerVertex" },
            { End }
        },
        { None }
    },
    {
        NormalData,
        "Normal Data",
        offset(normalData),
        Enumerated,
        {
            { None,                     "None" },
            { PerFacet,                 "PerFacet" },
            { PerVertex,                "PerVertex" },
            { End }
        },
        { None }
    },
    {
        TexData,
        "Texture Coordinate Data",
        offset(textureData),
        Enumerated,
        {
            { None,                     "None" },
            { PerVertex,                "PerVertex" },
            { End }
        },
        { None }
    },
#ifdef GL_SGI_compiled_vertex_array
    {
        LockArrays,
        "Use LockArraysSGI",
        offset(lockArrays),
        Enumerated,
        {
            { False,                    "False" },
            { True,                     "True" },
            { End }
        },
        { None }
    },
#endif
#ifdef GL_VERSION_1_1
    {
        DrawElements,
        "Use DrawElements",
        offset(drawElements),
        Enumerated,
        {
            { False,                    "False" },
            { True,                     "True" },
            { End }
        },
        { None }
    },
    {
        InterleavedData,
        "Interleaved Data",
        offset(interleavedData),
        Enumerated,
        {
            { False,                    "False" },
            { True,                     "True" },
            { End }
        },
        { None }
    },
#endif
    {
        ShadeModel,
        "Shading Model",
        offset(shadeModel),
        Enumerated,
        {
            { GL_SMOOTH,        "GL_SMOOTH" },
            { GL_FLAT,          "GL_FLAT" },
            { End }
        },
        { GL_SMOOTH }
    },
    {
        LocalLights,
        "Number of Local Lights",
        offset(numLocalLights),
        RangedInteger,
        {
            { 0 },
            { 8 }
        },
        { 0 }
    },
    {
        InfiniteLights,
        "Number of Infinite Lights",
        offset(numInfiniteLights),
        RangedInteger,
        {
            { 0 },
            { 8 }
        },
        { 0 }
    },
    {
        SpecularComponent,
        "Specular Component",
        offset(specComp),
        Enumerated,
        {
	    { On,  "On" },
	    { Off, "Off" },
	    { End }
        },
        { On }
    },
    {
        Shininess,
        "Shininess",
        offset(shininess),
        RangedFloatOrInt,
        {
            { 0.0 },
            { 128.0 }
        },
        { NotUsed, 10.0 }
    },
    {
        LocalViewer,
        "Local Viewer",
        offset(localViewer),
        Enumerated,
        {
            { Off,                      "Off" },
            { On,                       "On" },
            { End }
        },
        { Off }
    },
    {
        ColorMaterialMode,
        "Color Material Properties",
        offset(colorMaterial),
        Enumerated,
        {
            { GL_EMISSION,              "GL_EMISSION" },
            { GL_AMBIENT,               "GL_AMBIENT" },
            { GL_DIFFUSE,               "GL_DIFFUSE" },
            { GL_SPECULAR,              "GL_SPECULAR" },
            { GL_AMBIENT_AND_DIFFUSE,   "GL_AMBIENT_AND_DIFFUSE" },
            { End }
        },
        { GL_AMBIENT_AND_DIFFUSE }
    },
    {
        ColorMaterialSide,
	"Color Material Side",
	offset(colorMatSide),
	Enumerated,
	{
	    { GL_FRONT,			"GL_FRONT" },
	    { GL_BACK,			"GL_BACK" },
	    { GL_FRONT_AND_BACK,	"GL_FRONT_AND_BACK" },
            { End }
	},
        { GL_FRONT }
    },
#else  /* INC_REASON not defined, treat as plain include */
#ifndef _Vertex_h
#define _Vertex_h

#include "Primitve.h"
#include "General.h"
#include "Print.h"
#include "TestName.h"
#include "PropName.h"
#include "Global.h"
#include "AttrName.h"
#ifdef WIN32
#include <windows.h>
#endif
#include <GL/gl.h>
#include <GL/glu.h>
#include "Random.h"
#include "FuncEnum.h"

typedef struct _Vertex {
#define INC_REASON INFO_ITEM_STRUCT
#include "Vertex.h"
#undef INC_REASON
} Vertex, *VertexPtr;

void new_Vertex(VertexPtr);
void delete_Vertex(TestPtr);
void Vertex__AddTraversalData(VertexPtr);
int Vertex__SetState(TestPtr);
void Vertex__Initialize(TestPtr);
void Vertex__Cleanup(TestPtr);
void Vertex__SetExecuteFunc(TestPtr);
void Vertex__Layout(VertexPtr);
float Vertex__Size(TestPtr);

#ifdef WIN32
    /* The copy of VC++ that I have has no prototypes for these functions!!! */
    WINGDIAPI void APIENTRY glVertexPointerEXT(GLint, GLenum, GLsizei, GLsizei, const GLvoid*);
    WINGDIAPI void APIENTRY glDrawArraysEXT(GLenum, GLint, GLsizei);
    WINGDIAPI void APIENTRY glNormalPointerEXT(GLenum, GLsizei, GLsizei, const GLvoid*);
    WINGDIAPI void APIENTRY glColorPointerEXT(GLint, GLenum, GLsizei, GLsizei, const GLvoid*);
    WINGDIAPI void APIENTRY glIndexPointerEXT(GLenum, GLsizei, GLsizei, const GLvoid*);
    WINGDIAPI void APIENTRY glTexCoordPointerEXT(GLint, GLenum, GLsizei, GLsizei, const GLvoid*);
#endif

/* These constants are used in the function enumeration scheme */
#define NONE 0
#define PER_VERTEX 1
#define PER_FACET 2
#define CI 0
#if defined(WIN32)
  #undef RGB
#endif
#define RGB 1

#endif /* file not already included */
#endif /* INC_REASON not defined */
