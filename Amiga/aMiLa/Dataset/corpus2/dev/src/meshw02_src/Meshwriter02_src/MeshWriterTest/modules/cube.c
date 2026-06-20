/*
**      $VER: cube.c 1.00 (27.3.1999)
**
**      Creation date     : 20.3.1999
**
**      Description       :
**         MeshWriter testprogram shape module.
**
**
**      Written by Stephan Bielmann
**
*/

/*************************** Includes *******************************/

#ifndef WITHMWLLIB
#include "//meshlib.h"
#else
#include <meshwriter/meshwriter.h>
#include <pragma/meshwriter_lib.h>
#endif

/**************************** Defines *******************************/

/*********************** Type definitions ***************************/

/********************** Private functions ***************************/

/********************** Public functions ****************************/

/********************************************************************\
*                                                                    *
* Name         : cube                                                *
*                                                                    *
* Description  : Draws a multicolored pyramid mesh. By setting all   *
*                vertice values direct as fixed values.              *
*                                                                    *
* Arguments    : mesh    IN  : An initialized mesh handle.           *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
void cube (ULONG mesh) {
 ULONG mat1,mat2,mat3;
 TOCLColor color;
 TOCLVertex v1,v2,v3,v4,v5,v6,v7,v8;

 v1.x=-10,v1.y=-10,v1.z=-10;
 v2.x=10,v2.y=-10,v2.z=-10;
 v3.x=10,v3.y=10,v3.z=-10;
 v4.x=-10,v4.y=10,v4.z=-10;
 v5.x=-10,v5.y=-10,v5.z=10;
 v6.x=10,v6.y=-10,v6.z=10;
 v7.x=10,v7.y=10,v7.z=10;
 v8.x=-10,v8.y=10,v8.z=10;

 MWLMeshMaterialAdd(mesh,&mat1);
 color.r=0,color.g=0,color.b=255;
 MWLMeshMaterialDiffuseColorSet(mesh,mat1,&color);
 MWLMeshMaterialShininessSet(mesh,mat1,1);
 MWLMeshMaterialTransparencySet(mesh,mat1,0);

 MWLMeshMaterialAdd(mesh,&mat2);
 color.r=0,color.g=255,color.b=0;
 MWLMeshMaterialDiffuseColorSet(mesh,mat2,&color);
 MWLMeshMaterialShininessSet(mesh,mat2,1);
 MWLMeshMaterialTransparencySet(mesh,mat2,0);

 MWLMeshMaterialAdd(mesh,&mat3);
 color.r=255,color.g=0,color.b=0;
 MWLMeshMaterialDiffuseColorSet(mesh,mat3,&color);
 MWLMeshMaterialShininessSet(mesh,mat3,1);
 MWLMeshMaterialTransparencySet(mesh,mat3,0);

 MWLMeshNameSet(mesh,"Cube");

 MWLMeshPolygonAdd(mesh,mat1);
 MWLMeshPolygonVertexAdd(mesh,&v1);
 MWLMeshPolygonVertexAdd(mesh,&v2);
 MWLMeshPolygonVertexAdd(mesh,&v6);
 MWLMeshPolygonVertexAdd(mesh,&v5);

 MWLMeshPolygonAdd(mesh,mat1);        
 MWLMeshPolygonVertexAdd(mesh,&v8);
 MWLMeshPolygonVertexAdd(mesh,&v7);
 MWLMeshPolygonVertexAdd(mesh,&v3);
 MWLMeshPolygonVertexAdd(mesh,&v4);

 MWLMeshPolygonAdd(mesh,mat2);        
 MWLMeshPolygonVertexAdd(mesh,&v5);
 MWLMeshPolygonVertexAdd(mesh,&v6);
 MWLMeshPolygonVertexAdd(mesh,&v7);
 MWLMeshPolygonVertexAdd(mesh,&v8);

 MWLMeshPolygonAdd(mesh,mat2);        
 MWLMeshPolygonVertexAdd(mesh,&v4);
 MWLMeshPolygonVertexAdd(mesh,&v3);
 MWLMeshPolygonVertexAdd(mesh,&v2);
 MWLMeshPolygonVertexAdd(mesh,&v1);

 MWLMeshPolygonAdd(mesh,mat3);
 MWLMeshPolygonVertexAdd(mesh,&v4);
 MWLMeshPolygonVertexAdd(mesh,&v1);
 MWLMeshPolygonVertexAdd(mesh,&v5);
 MWLMeshPolygonVertexAdd(mesh,&v8);

 MWLMeshPolygonAdd(mesh,mat3);
 MWLMeshPolygonVertexAdd(mesh,&v2);
 MWLMeshPolygonVertexAdd(mesh,&v3);
 MWLMeshPolygonVertexAdd(mesh,&v7);
 MWLMeshPolygonVertexAdd(mesh,&v6);
}

/************************* End of file ******************************/
