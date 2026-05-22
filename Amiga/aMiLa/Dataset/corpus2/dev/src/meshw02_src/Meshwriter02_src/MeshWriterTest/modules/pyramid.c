/*
**      $VER: pyramid.c 1.00 (20.3.1999)
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
* Description  : Draws a multicolored cube mesh. By setting all      *
*                vertice values direct as fixed values.              *
*                                                                    *
* Arguments    : mesh    IN  : An initialized mesh handle.           *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
void pyramid (ULONG mesh) {
 ULONG mat1,mat2,mat3,mat4;
 TOCLColor color;
 TOCLVertex v1,v2,v3;
  
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

 MWLMeshMaterialAdd(mesh,&mat4);
 color.r=255,color.g=0,color.b=255;
 MWLMeshMaterialDiffuseColorSet(mesh,mat4,&color);
 MWLMeshMaterialShininessSet(mesh,mat4,1);
 MWLMeshMaterialTransparencySet(mesh,mat4,0);

 MWLMeshNameSet(mesh,"Pyramid");
	
 v1.x=-10,v1.y=-10,v1.z=-10;v2.x=10,v2.y=-10,v2.z=-10;v3.x=0,v3.y=0,v3.z=10;
 MWLMeshTriangleAdd(mesh,mat1,&v1,&v2,&v3);
 v1.x=10,v1.y=-10,v1.z=-10;v2.x=10,v2.y=10,v2.z=-10;v3.x=0,v3.y=0,v3.z=10;
 MWLMeshTriangleAdd(mesh,mat2,&v1,&v2,&v3);
 v1.x=10,v1.y=10,v1.z=-10;v2.x=-10,v2.y=10,v2.z=-10;v3.x=0,v3.y=0,v3.z=10;
 MWLMeshTriangleAdd(mesh,mat3,&v1,&v2,&v3);
 v1.x=-10,v1.y=10,v1.z=-10;v2.x=-10,v2.y=-10,v2.z=-10;v3.x=0,v3.y=0,v3.z=10;
 MWLMeshTriangleAdd(mesh,mat4,&v1,&v2,&v3);
 v1.x=-10,v1.y=-10,v1.z=-10;v2.x=10,v2.y=10,v2.z=-10;v3.x=-10,v3.y=10,v3.z=-10;
 MWLMeshTriangleAdd(mesh,mat1,&v1,&v2,&v3);
 v1.x=10,v1.y=10,v1.z=-10;v2.x=-10,v2.y=-10,v2.z=-10;v3.x=10,v3.y=-10,v3.z=-10;
 MWLMeshTriangleAdd(mesh,mat1,&v1,&v2,&v3);
}

/************************* End of file ******************************/
