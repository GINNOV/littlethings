/*
**      $VER: cubetower.c 1.00 (20.3.1999)
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
static void cube(ULONG mesh, ULONG color) {
  TOCLVertex v1,v2,v3,v4,v5,v6,v7,v8;

  v1.x=-0.5,v1.y=-0.5,v1.z=-0.5;
  v2.x=0.5,v2.y=-0.5,v2.z=-0.5;
  v3.x=0.5,v3.y=0.5,v3.z=-0.5;
  v4.x=-0.5,v4.y=0.5,v4.z=-0.5;
  v5.x=-0.5,v5.y=-0.5,v5.z=0.5;
  v6.x=0.5,v6.y=-0.5,v6.z=0.5;
  v7.x=0.5,v7.y=0.5,v7.z=0.5;
  v8.x=-0.5,v8.y=0.5,v8.z=0.5;

  MWLMeshTriangleAdd(mesh,color,&v1,&v2,&v3);
  MWLMeshTriangleAdd(mesh,color,&v1,&v3,&v4);

  MWLMeshTriangleAdd(mesh,color,&v5,&v6,&v7);
  MWLMeshTriangleAdd(mesh,color,&v5,&v7,&v8);

  MWLMeshTriangleAdd(mesh,color,&v4,&v1,&v5);
  MWLMeshTriangleAdd(mesh,color,&v4,&v5,&v8);

  MWLMeshTriangleAdd(mesh,color,&v7,&v6,&v2);
  MWLMeshTriangleAdd(mesh,color,&v7,&v2,&v3);

  MWLMeshTriangleAdd(mesh,color,&v1,&v6,&v5);
  MWLMeshTriangleAdd(mesh,color,&v1,&v2,&v6);

  MWLMeshTriangleAdd(mesh,color,&v4,&v8,&v7);
  MWLMeshTriangleAdd(mesh,color,&v4,&v7,&v3);
}

/********************** Public functions ****************************/

/********************************************************************\
*                                                                    *
* Name         : cubetower                                           *
*                                                                    *
* Description  : Draws a tower of cubes with the help of the scaling *
*                and translation functions.                          *
*                                                                    *
* Arguments    : mesh    IN  : An initialized mesh handle.           *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
void cubetower (ULONG mesh) {
  ULONG red,green,blue,white,black;
  TOCLColor color;
  TOCLVertex vt,vs;
  
  MWLMeshMaterialAdd(mesh,&red);
  color.r=255,color.g=0,color.b=0;
  MWLMeshMaterialNameSet(mesh,red,"Red");
  MWLMeshMaterialDiffuseColorSet(mesh,red,&color);
  MWLMeshMaterialShininessSet(mesh,red,0);
  MWLMeshMaterialTransparencySet(mesh,red,0);

  MWLMeshMaterialAdd(mesh,&green);
  color.r=0,color.g=255,color.b=0;
  MWLMeshMaterialNameSet(mesh,green,"Green");
  MWLMeshMaterialDiffuseColorSet(mesh,green,&color);
  MWLMeshMaterialShininessSet(mesh,green,0);
  MWLMeshMaterialTransparencySet(mesh,green,0);

  MWLMeshMaterialAdd(mesh,&blue);
  color.r=0,color.g=0,color.b=255;
  MWLMeshMaterialNameSet(mesh,blue,"Blue");
  MWLMeshMaterialDiffuseColorSet(mesh,blue,&color);
  MWLMeshMaterialShininessSet(mesh,blue,0);
  MWLMeshMaterialTransparencySet(mesh,blue,0);

  MWLMeshMaterialAdd(mesh,&white);
  color.r=255,color.g=255,color.b=255;
  MWLMeshMaterialNameSet(mesh,white,"White");
  MWLMeshMaterialDiffuseColorSet(mesh,white,&color);
  MWLMeshMaterialShininessSet(mesh,white,0);
  MWLMeshMaterialTransparencySet(mesh,white,0);

  MWLMeshMaterialAdd(mesh,&black);
  color.r=0,color.g=0,color.b=0;
  MWLMeshMaterialNameSet(mesh,black,"Black");
  MWLMeshMaterialDiffuseColorSet(mesh,black,&color);
  MWLMeshMaterialShininessSet(mesh,black,0);
  MWLMeshMaterialTransparencySet(mesh,black,0);

  MWLMeshNameSet(mesh,"Cubetower");

  vs.x=10,vs.y=10,vs.z=10;

  MWLMeshScaleChange(mesh,&vs,CTMSET);
  cube(mesh,black);

  vs.x=2,vs.y=2,vs.z=2;

  MWLMeshScaleGet(mesh,&vt);
  vt.x=0;vt.y=0;vt.z-=1;

  MWLMeshScaleChange(mesh,&vs,CTMSUB);
  MWLMeshTranslationChange(mesh,&vt,CTMSET);
  cube(mesh,red);

  MWLMeshScaleGet(mesh,&vt);
  vt.x=0;vt.y=0;vt.z-=1;

  MWLMeshScaleChange(mesh,&vs,CTMSUB);
  MWLMeshTranslationChange(mesh,&vt,CTMADD);
  cube(mesh,blue);

  MWLMeshScaleGet(mesh,&vt);
  vt.x=0;vt.y=0;vt.z-=1;

  MWLMeshScaleChange(mesh,&vs,CTMSUB);
  MWLMeshTranslationChange(mesh,&vt,CTMADD);
  cube(mesh,green);

  MWLMeshScaleGet(mesh,&vt);
  vt.x=0;vt.y=0;vt.z-=1;

  MWLMeshScaleChange(mesh,&vs,CTMSUB);
  MWLMeshTranslationChange(mesh,&vt,CTMADD);
  cube(mesh,white);
}

/************************* End of file ******************************/
