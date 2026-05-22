/*
**      $VER: ground.c 1.00 (20.3.1999)
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
* Name         : ground                                              *
*                                                                    *
* Description  : Draws a multicolored ground mesh. By setting all    *
*                vertice values direct as fixed values.              *
*                                                                    *
* Arguments    : mesh    IN  : An initialized mesh handle.           *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
void ground(ULONG mesh) {
  ULONG mat1,mat2;
  TOCLColor color;
  TOCLVertex v1,v2,v3;
    
  MWLMeshMaterialAdd(mesh,&mat1);
  color.r=255,color.g=0,color.b=0;
  MWLMeshMaterialDiffuseColorSet(mesh,mat1,&color);
  MWLMeshMaterialNameSet(mesh,mat1,"rot");
  MWLMeshMaterialShininessSet(mesh,mat1,1);
  MWLMeshMaterialTransparencySet(mesh,mat1,0);

  MWLMeshMaterialAdd(mesh,&mat2);
  color.r=0,color.g=0,color.b=255;
  MWLMeshMaterialDiffuseColorSet(mesh,mat2,&color);
  MWLMeshMaterialNameSet(mesh,mat2,"blau");
  MWLMeshMaterialShininessSet(mesh,mat2,1);
  MWLMeshMaterialTransparencySet(mesh,mat2,0);

  MWLMeshNameSet(mesh,"Ground");

  v1.x=-10,v1.y=-10,v1.z=0;v2.x=10,v2.y=10,v2.z=0;v3.x=-10,v3.y=10,v3.z=0;
  MWLMeshTriangleAdd(mesh,mat1,&v1,&v2,&v3);
  v1.x=-10,v1.y=-10,v1.z=0;v2.x=10,v2.y=-10,v2.z=0;v3.x=10,v3.y=10,v3.z=0;
  MWLMeshTriangleAdd(mesh,mat2,&v1,&v2,&v3);
}

/************************* End of file ******************************/
