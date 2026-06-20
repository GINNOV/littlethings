/*
**      $VER: checkboard.c 1.00 (20.3.1999)
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
static void drawFace(ULONG mesh, ULONG color) {
  TOCLVertex v1,v2,v3,v4;

  v1.x=-0.5,v1.y=-0.5,v1.z=0;
  v2.x=0.5,v2.y=-0.5,v2.z=0;
  v3.x=0.5,v3.y=0.5,v3.z=0;
  v4.x=-0.5,v4.y=0.5,v4.z=0;
  
  MWLMeshTriangleAdd(mesh,color,&v1,&v2,&v3);
  MWLMeshTriangleAdd(mesh,color,&v1,&v3,&v4);
}

/********************** Public functions ****************************/

/********************************************************************\
*                                                                    *
* Name         : checkboard                                          *
*                                                                    *
* Description  : Draws a black/white checkboard. With the help of    *
*                the translation function.                           *
*                                                                    *
* Arguments    : mesh    IN  : An initialized mesh handle.           *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
void checkboard(ULONG mesh) {
  ULONG black,white,i,j;
  TOCLColor color;
  TOCLVertex vt;


  MWLMeshMaterialAdd(mesh,&black);
  color.r=0,color.g=0,color.b=0;
  MWLMeshMaterialDiffuseColorSet(mesh,black,&color);
  MWLMeshMaterialNameSet(mesh,black,"black");
  MWLMeshMaterialShininessSet(mesh,black,0);
  MWLMeshMaterialTransparencySet(mesh,black,0);

  MWLMeshMaterialAdd(mesh,&white);
  color.r=255,color.g=255,color.b=255;
  MWLMeshMaterialDiffuseColorSet(mesh,white,&color);
  MWLMeshMaterialNameSet(mesh,white,"white");
  MWLMeshMaterialShininessSet(mesh,white,0);
  MWLMeshMaterialTransparencySet(mesh,white,0);

  MWLMeshNameSet(mesh,"Checkboard");

  vt.z=0;

  for(i=0;i<8;i++) {
    for(j=0;j<8;j++) {
      vt.x=i,vt.y=j;
      MWLMeshTranslationChange(mesh,&vt,CTMSET);
      if((i+j)%2) {
        drawFace(mesh,black);
      } else {
        drawFace(mesh,white);
      }
    }
  }
}

/************************* End of file ******************************/
