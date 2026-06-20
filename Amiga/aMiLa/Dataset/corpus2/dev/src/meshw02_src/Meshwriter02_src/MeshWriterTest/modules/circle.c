/*
**      $VER: circle.c 1.00 (20.3.1999)
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

#define PI            3.14159265359
#define ROTSTEPS      12

/*********************** Type definitions ***************************/

/********************** Private functions ***************************/

/********************** Public functions ****************************/

/********************************************************************\
*                                                                    *
* Name         : circle                                              *
*                                                                    *
* Description  : Draws a circle with the help of the rotation        *
*                function.                                           *
*                                                                    *
* Arguments    : mesh    IN  : An initialized mesh handle.           *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
void circle(ULONG mesh) {
  TOCLVertex v1,vr;
  TOCLColor  color;
  ULONG blue;

  MWLMeshMaterialAdd(mesh,&blue);
  color.r=0,color.g=0,color.b=255;
  MWLMeshMaterialNameSet(mesh,blue,"Blue");
  MWLMeshMaterialDiffuseColorSet(mesh,blue,&color);
  MWLMeshMaterialShininessSet(mesh,blue,0);
  MWLMeshMaterialTransparencySet(mesh,blue,0);

  MWLMeshNameSet(mesh,"Circle");

  v1.x=1,v1.y=0,v1.z=0;
  vr.x=0,vr.y=0;
  MWLMeshPolygonAdd(mesh,blue);
  for(vr.z=0;vr.z<2*PI;vr.z+=PI/ROTSTEPS) {
    MWLMeshPolygonVertexAdd(mesh,&v1);
    MWLMeshRotationChange(mesh,&vr,CTMSET);
  }
}

/************************* End of file ******************************/
