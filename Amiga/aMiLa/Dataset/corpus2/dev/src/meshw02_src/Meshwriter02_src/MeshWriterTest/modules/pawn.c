/*
**      $VER: pawn.c 1.00 (20.3.1999)
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
#define ROTSTEPS      9

/*********************** Type definitions ***************************/

/********************** Private functions ***************************/

/********************** Public functions ****************************/

/********************************************************************\
*                                                                    *
* Name         : pawn                                                *
*                                                                    *
* Description  : Draws a pawn with the help of the rotation function.*
*                                                                    *
* Arguments    : mesh    IN  : An initialized mesh handle.           *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
void pawn(ULONG mesh) {
  TOCLVertex v1,v2,vr;
  TOCLColor color;
  ULONG white,i;
  TOCLFloat apawn[] = {40,40,39,37,38.5,39,38,37,36,34.5,31,28,26,23.6,22,20,18,16,14.5,
                       13,11.5,11.2,11.2,11.5,13.6,15.5,22,28.7,28.5,22,16,16.8,20,22.7,
                       24.5,25.3,25.5,25,24,22,18.5,13.5,0};

  MWLMeshMaterialAdd(mesh,&white);
  color.r=255,color.g=255,color.b=255;
  MWLMeshMaterialNameSet(mesh,white,"White");
  MWLMeshMaterialDiffuseColorSet(mesh,white,&color);
  MWLMeshMaterialShininessSet(mesh,white,0);
  MWLMeshMaterialTransparencySet(mesh,white,0);

  MWLMeshNameSet(mesh,"Pawn");

  // the ground, a circle
  v1.x=40,v1.y=0,v1.z=0;
  vr.x=0,vr.y=0;
  MWLMeshPolygonAdd(mesh,white);
  for(vr.z=0;vr.z<2*PI;vr.z+=PI/ROTSTEPS) {
    MWLMeshPolygonVertexAdd(mesh,&v1);
    MWLMeshRotationChange(mesh,&vr,CTMSET);
  }

  // the body, with the help of the apawn radius array
  v1.y=0;
  v2.y=0;
  vr.x=0,vr.y=0;
  for(i=0;i<43-1;i++) {
    MWLMeshPolygonAdd(mesh,white);
    v2.x=apawn[i+1],v2.z=2*(i+1);
    MWLMeshPolygonVertexAdd(mesh,&v2);
    v1.x=apawn[i],v1.z=(2*i);
    MWLMeshPolygonVertexAdd(mesh,&v1);

    for(vr.z=0;vr.z<2*PI;vr.z+=PI/ROTSTEPS) {
      MWLMeshRotationChange(mesh,&vr,CTMSET);

      v1.x=apawn[i],v1.z=2*i;
      MWLMeshPolygonVertexAdd(mesh,&v1);
      v2.x=apawn[i+1],v2.z=2*(i+1);
      MWLMeshPolygonVertexAdd(mesh,&v2);

      MWLMeshPolygonAdd(mesh,white);
      MWLMeshPolygonVertexAdd(mesh,&v2);
      MWLMeshPolygonVertexAdd(mesh,&v1);
    }
  }
}

/************************* End of file ******************************/
