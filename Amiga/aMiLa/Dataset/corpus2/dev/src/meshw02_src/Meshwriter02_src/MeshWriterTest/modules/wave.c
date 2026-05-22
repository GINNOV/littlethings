/*
**      $VER: wave.c 1.00 (20.3.1999)
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

#include <math.h>

/**************************** Defines *******************************/

#define PI            3.14159265359
#define WAVESTEPS     20

/*********************** Type definitions ***************************/

/********************** Private functions ***************************/

/********************** Public functions ****************************/

/********************************************************************\
*                                                                    *
* Name         : wave                                                *
*                                                                    *
* Description  : Draws a wave with the help of a formula got out of  *
*                Plotter 3D by Sven Steiniger.                       *
*                                                                    *
* Arguments    : mesh    IN  : An initialized mesh handle.           *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
void wave(ULONG mesh) {
  ULONG m[3];
  TOCLColor color;
  TOCLVertex matrix[WAVESTEPS+1][WAVESTEPS+1];
  ULONG x,y;
  FLOAT u,v;

  MWLMeshMaterialAdd(mesh,&m[0]);
  color.r=0,color.g=0,color.b=0;
  MWLMeshMaterialDiffuseColorSet(mesh,m[0],&color);

  MWLMeshMaterialAdd(mesh,&m[1]);
  color.r=255,color.g=0,color.b=0;
  MWLMeshMaterialDiffuseColorSet(mesh,m[1],&color);

  MWLMeshMaterialAdd(mesh,&m[2]);
  color.r=0,color.g=255,color.b=0;
  MWLMeshMaterialDiffuseColorSet(mesh,m[2],&color);

  MWLMeshNameSet(mesh,"Wave");

  u=-PI;
  for(x=0;x<WAVESTEPS+1;x++) {
    v=-PI;
      for(y=0;y<WAVESTEPS+1;y++) {
        matrix[x][y].x=u;
        matrix[x][y].y=v;
        matrix[x][y].z=sin(u)+cos(v);

        v+=2*PI/WAVESTEPS;
    }
    u+=2*PI/WAVESTEPS;
  }

  for(x=0;x<(WAVESTEPS);x++) {
    for(y=0;y<(WAVESTEPS);y++) {
      MWLMeshPolygonAdd(mesh,m[((ULONG)(matrix[x][y].z))+1]);
      MWLMeshPolygonVertexAdd(mesh,&matrix[x][y]);
      MWLMeshPolygonVertexAdd(mesh,&matrix[x+1][y]);
      MWLMeshPolygonVertexAdd(mesh,&matrix[x+1][y+1]);
      MWLMeshPolygonVertexAdd(mesh,&matrix[x][y+1]);
    }
  }
}

/************************* End of file ******************************/
