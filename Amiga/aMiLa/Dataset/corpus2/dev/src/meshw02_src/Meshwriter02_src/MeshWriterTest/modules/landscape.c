/*
**      $VER: landscape.c 1.00 (27.3.1999)
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

#define GRID_SIZE     32

/*********************** Type definitions ***************************/

/********************** Private functions ***************************/

static TOCLFloat randomHeight (FLOAT range)
{
  return (TOCLFloat) (range * ((TOCLFloat) (2.0 * rand () / RAND_MAX) - 1.0));
}

/********************** Public functions ****************************/

/********************************************************************\
*                                                                    *
* Name         : landscape                                           *
*                                                                    *
* Description  : Draws a landscape.                                  *
*                                                                    *
* Arguments    : mesh    IN  : An initialized mesh handle.           *
*                                                                    *
* Comment      : This function is a "remake" of the Amiga-Magzin its *
*                landscape sample code used in theyr Cyber-GL        *
*                workshop.                                           *
*                                                                    *
\********************************************************************/
void landscape(ULONG mesh) {
  TOCLVertex grid[GRID_SIZE+1][GRID_SIZE+1];
  TOCLColor color;
  ULONG c[3];
  int x, z;       /* x/z index */
  int gridStep;   /* actual grid index distance */
  int step;       /* actual generation step */
  int seed,steps,i,j;
  float maxHeight,minh,maxh;
  int xl,xr,zl,zr;

  seed=rand();
  steps=5;
  maxHeight=5;

  MWLMeshMaterialAdd(mesh,&c[0]);
  color.r=0,color.g=0,color.b=255;
  MWLMeshMaterialDiffuseColorSet(mesh,c[0],&color);

  MWLMeshMaterialAdd(mesh,&c[1]);
  color.r=0,color.g=255,color.b=0;
  MWLMeshMaterialDiffuseColorSet(mesh,c[1],&color);

  MWLMeshMaterialAdd(mesh,&c[2]);
  color.r=255,color.g=255,color.b=255;
  MWLMeshMaterialDiffuseColorSet(mesh,c[2],&color);

  for(i=0;i<(GRID_SIZE+1);i++) {
    for(j=0;j<(GRID_SIZE+1);j++) {
      grid[i][j].x=i;
      grid[i][j].y=j;
      grid[i][j].z=0;
    }
  }

  srand (seed);
  grid [        0][        0].z = randomHeight (maxHeight);
  grid [GRID_SIZE][        0].z = randomHeight (maxHeight);
  grid [        0][GRID_SIZE].z = randomHeight (maxHeight);
  grid [GRID_SIZE][GRID_SIZE].z = randomHeight (maxHeight);

  gridStep = GRID_SIZE / 2;

  for (step = 1; step <= steps; step++) {
    maxHeight /= 2.0;
    for (x = gridStep / 2; x < GRID_SIZE; x += gridStep) {
      xl = x - gridStep / 2;
      xr = x + gridStep / 2;

      for (z = gridStep / 2; z < GRID_SIZE; z += gridStep) {
        zl = z - gridStep / 2;
        zr = z + gridStep / 2;

        grid [x][z].z = (grid [xl][zl].z +
                         grid [xl][zr].z +
                         grid [xr][zl].z +
                         grid [xr][zr].z) / 4.0 + randomHeight (maxHeight);
        grid [xl][z].z = (grid [xl][zl].z +
                          grid [xl][zr].z) / 2.0 + randomHeight (maxHeight);
        grid [x][zl].z = (grid [xl][zl].z +
                          grid [xr][zl].z) / 2.0 + randomHeight (maxHeight);
      }
      grid [x][GRID_SIZE].z = (grid [xl][GRID_SIZE].z +
                               grid [xr][GRID_SIZE].z) / 2.0 + randomHeight (maxHeight);

    }
    for (z = gridStep / 2; z < GRID_SIZE; z += gridStep) {
      grid [GRID_SIZE][z].z = (grid [GRID_SIZE][z - gridStep / 2].z +
                               grid [GRID_SIZE][z + gridStep / 2].z) / 2.0 + randomHeight (maxHeight);
    }
    gridStep /= 2;
  }

  maxh=-1000;minh=1000;
  for(i=0;i<(GRID_SIZE);i++) {
    for(j=0;j<(GRID_SIZE);j++) {
		if(maxh<grid[i][j].z) maxh=grid[i][j].z;
		if(minh>grid[i][i].z) minh=grid[i][j].z;
    }
  }

  for(i=0;i<(GRID_SIZE);i++) {
    for(j=0;j<(GRID_SIZE);j++) {
 		ULONG col;
		
		if(minh<0) {
			col=ULONG(((grid[i][j].z-minh))/((maxh-minh)/3));
		} else {
			col=ULONG(((grid[i][j].z+minh))/((maxh-minh)/3));
		}
		if(col>2)col=2;if(col<0)col=0;

		MWLMeshPolygonAdd(mesh,c[col]);
		MWLMeshPolygonVertexAdd(mesh,&grid[i][j]);
		MWLMeshPolygonVertexAdd(mesh,&grid[i+1][j]);
		MWLMeshPolygonVertexAdd(mesh,&grid[i+1][j+1]);
		MWLMeshPolygonVertexAdd(mesh,&grid[i][j+1]);
    }
  }

  MWLMeshNameSet(mesh,"Landscape");
}

/************************* End of file ******************************/
