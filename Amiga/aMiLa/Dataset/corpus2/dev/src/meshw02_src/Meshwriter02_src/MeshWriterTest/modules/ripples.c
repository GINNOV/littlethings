/*
**      $VER: ripples.c 1.00 (20.3.1999)
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
#define RIPPLESSTEPS  20

/*********************** Type definitions ***************************/

/********************** Private functions ***************************/

/********************** Public functions ****************************/

/********************************************************************\
*                                                                    *
* Name         : ripples                                             *
*                                                                    *
* Description  : Draws some ripples with the help of a formula got   *
*                out of Plotter 3D by Sven Steiniger.                *
*                                                                    *
* Arguments    : mesh    IN  : An initialized mesh handle.           *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
void ripples(ULONG mesh) {
  ULONG m[7],i;
  TOCLColor color;
  TOCLVertex matrix[RIPPLESSTEPS+1][RIPPLESSTEPS+1];
  ULONG x,y;
  FLOAT u,v;

  MWLMeshMaterialAdd(mesh,&m[0]);
  color.r=0,color.g=0,color.b=0;
  MWLMeshMaterialDiffuseColorSet(mesh,m[0],&color);

  MWLMeshMaterialAdd(mesh,&m[1]);
  color.r=255,color.g=0,color.b=0;
  MWLMeshMaterialDiffuseColorSet(mesh,m[1],&color);

  MWLMeshMaterialAdd(mesh,&m[2]);
  color.r=255,color.g=255,color.b=0;
  MWLMeshMaterialDiffuseColorSet(mesh,m[2],&color);

  MWLMeshMaterialAdd(mesh,&m[3]);
  color.r=255,color.g=255,color.b=255;
  MWLMeshMaterialDiffuseColorSet(mesh,m[3],&color);

  MWLMeshMaterialAdd(mesh,&m[4]);
  color.r=0,color.g=255,color.b=255;
  MWLMeshMaterialDiffuseColorSet(mesh,m[4],&color);

  MWLMeshMaterialAdd(mesh,&m[5]);
  color.r=255,color.g=0,color.b=255;
  MWLMeshMaterialDiffuseColorSet(mesh,m[5],&color);

  MWLMeshMaterialAdd(mesh,&m[6]);
  color.r=0,color.g=0,color.b=0;
  MWLMeshMaterialDiffuseColorSet(mesh,m[5],&color);

  MWLMeshNameSet(mesh,"Ripples");

  u=0;
  for(x=0;x<RIPPLESSTEPS+1;x++) {
    v=0;
    for(y=0;y<RIPPLESSTEPS+1;y++) {
        matrix[x][y].x=u*cos(v);
        matrix[x][y].y=u*sin(v);
        matrix[x][y].z=2*cos(4*u)*cos(4*u)*exp(-u);

        v+=2*PI/RIPPLESSTEPS;
    }
    u+=PI/RIPPLESSTEPS;
  }

  for(x=0;x<(RIPPLESSTEPS);x++) {
    for(y=0;y<(RIPPLESSTEPS);y++) {
      i=(ULONG)(10*matrix[x][y].z);

      if(i>6) i=6;

      MWLMeshPolygonAdd(mesh,m[i]);
      MWLMeshPolygonVertexAdd(mesh,&matrix[x][y]);
      MWLMeshPolygonVertexAdd(mesh,&matrix[x+1][y]);
      MWLMeshPolygonVertexAdd(mesh,&matrix[x+1][y+1]);
      MWLMeshPolygonVertexAdd(mesh,&matrix[x][y+1]);
    }
  }
}

/************************* End of file ******************************/
