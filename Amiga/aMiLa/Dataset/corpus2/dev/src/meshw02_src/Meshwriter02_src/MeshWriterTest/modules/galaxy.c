/*
**      $VER: galaxy.c 1.00 (27.3.1999)
**
**      Creation date     : 27.3.1999
**
**      Description       :
**         MeshWriter testprogram shape module.
**
**
**      Written by Stephan Bielmann
**
*/

/*************************** Includes *******************************/

#include <stdlib.h>
#include <math.h>

#ifndef WITHMWLLIB
#include "//meshlib.h"
#else
#include <meshwriter/meshwriter.h>
#include <pragma/meshwriter_lib.h>
#endif

/**************************** Defines *******************************/

#define PI            3.14159265359

/*********************** Type definitions ***************************/

/********************** Private functions ***************************/

static VOID particleadd(ULONG mesh,ULONG material,TOCLFloat size,TOCLVertex position){
  TOCLVertex x,y,z;

  x.x=position.x;
  x.y=position.y-size;
  x.z=position.z;

  y.x=position.x+size;
  y.y=position.y+size;
  y.z=position.z;

  z.x=position.x-size;
  z.y=position.y+size;
  z.z=position.z;

  MWLMeshTriangleAdd(mesh,material,&x,&y,&z);
}

static FLOAT random(FLOAT range) {
  return((range * rand () / RAND_MAX)-(range/2));
}

/********************** Public functions ****************************/

/********************************************************************\
*                                                                    *
* Name         : galaxy                                              *
*                                                                    *
* Description  : Draws a galaxy like shape with the help of the      *
*	             rotation function.                                  *
*                                                                    *
* Arguments    : mesh    IN  : An initialized mesh handle.           *
*                                                                    *
* Comment      : This function is an implementation of Nikola        *
*                Smolenski his GalaxyCreator algorithm.              *
*                                                                    *
\********************************************************************/
void galaxy (ULONG mesh) {
  TOCLVertex v,v2;
  TOCLColor color;
  ULONG j,angle,c[25];
  FLOAT Ri,Si,R1,R,i,h;

  srand(rand());

  for(j=0;j<5;j++) {
    MWLMeshMaterialAdd(mesh,&c[j]);
    color.r=255-j*10,color.g=255-j*10,color.b=255-j*10;
    MWLMeshMaterialDiffuseColorSet(mesh,c[j],&color);
  }

  for(j=5;j<25;j++) {
    MWLMeshMaterialAdd(mesh,&c[j]);
    color.r=255-j*10,color.g=255-j*10,color.b=255;
    MWLMeshMaterialDiffuseColorSet(mesh,c[j],&color);
  }

  angle=5;
  Ri=0;
  Si=5;
  R1=10;
  h=0;
  for(i=0.2;i<=angle;i+=0.2) {
    Ri+=Si;
    R=random(6)+R1;
    v.x=cos(i)*Ri;v.y=sin(i)*Ri,v.z=0;
    for(j=1;j<=R;j++) {
      v2.x=v.x-random(5);v2.y=v.y-random(5);
      v2.z=random(cos(h)*20);h+=PI/50;
      particleadd(mesh,c[(ULONG)(i/0.2)-1],2,v2);
      v.x+=random(10);v.y+=random(10);
    }
  }

  angle=5;
  Ri=0;
  Si=5;
  R1=10;
  h=0;
  for(i=0.2;i<=angle;i+=0.2) {
    Ri+=Si;
    R=random(6)+R1;
    v.x=-cos(i)*Ri;v.y=-sin(i)*Ri,v.z=0;
    for(j=1;j<=R;j++) {
      v2.x=v.x-random(5);v2.y=v.y-random(5);
      v2.z=random(cos(h)*20);h+=PI/50;
      particleadd(mesh,c[(ULONG)(i/0.2)-1],2,v2);
      v.x+=random(10);v.y+=random(10);
    }
  }
}

/************************* End of file ******************************/
