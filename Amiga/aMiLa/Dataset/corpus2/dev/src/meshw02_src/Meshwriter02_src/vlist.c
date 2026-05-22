/*
**      $VER: vlist.c 1.00 (20.03.1999)
**
**      Creation date : 20.03.1999
**
**      Description       :
**         Standart saver module for meshwriter.library.
**         Saves the mesh as list of vertices, only vertices.
**
**
**      Written by Stephan Bielmann
**
*/

/*************************** Includes *******************************/

/*
** Amiga includes
*/
#include <dos/dos.h>
#include <dos/stdio.h>

#include <clib/dos_protos.h>
#include <clib/alib_stdio_protos.h>

/*
** Project includes
*/
#include "meshwriter_private.h"

/**************************** Defines *******************************/

/*********************** Type definitions ***************************/

/********************** Private functions ***************************/

/********************** Public functions ****************************/

/********************************************************************\
*                                                                    *
* Name         : write3VLIST                                         *
*                                                                    *
* Description  : Writes an ASCII vertex list file.                   *
*                                                                    *
* Arguments    : vlistfile IN  : An already opened file stream.      *
*                mesh      IN  : Pointer to the mesh.                *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
ULONG write3VLIST(BPTR vlistfile, TOCLMesh *mesh) {
	TOCLVertex					ver;

	/*
	** Write the vertex list
	*/	  		
  	if(mesh->polygons.firstNode!=NULL) {             	
		pln=mesh->polygons.firstNode;
		do {
			/* Get the first point of the polygon, used to create all triangles with it */
			if(pln->numberOfVertices>=3) {
				plv1=pln->firstNode;
				ver1=plv1->vertexNode->vertex;
			
				plvi=plv1;
				do {	
					plv2=plvi->next;
					plv3=plv2->next;
				
					ver2=plv2->vertexNode->vertex;
					ver3=plv3->vertexNode->vertex;
				
					sprintf(buffer,"%g %g %g\n",ver1.x,ver1.y,ver1.z,
					if(FPuts(rawfile,buffer)!=DOSFALSE) return(RCWRITEDATA);
					
					plvi=plvi->next;
				} while(plv3->next!=NULL);	
			}
		
			/* Get the next polygon */
			pln=pln->next;			
		} while(pln!=NULL);
	}
	
	return(RCNOERROR);
}

/********************************************************************\
*                                                                    *
* Name         : write3RAWB                                          *
*                                                                    *
* Description  : Writes a standart RAW binary file.                  *
*                                                                    *
* Arguments    : rawfile IN  : An already opened file stream.        *
*                mesh    IN  : Pointer to the mesh.                  *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
ULONG write3RAWB(BPTR rawfile, TOCLMesh *mesh) {
	TOCLPolygonNode			*pln=NULL;	
	TOCLPolygonsVerticesNode	*plvi=NULL,*plv1=NULL,*plv2=NULL,*plv3=NULL;
	TOCLVertex					ver1,ver2,ver3;
	RAWTriangle				tbuffer[Ci_BUFFERS]; // Ci_BUFFERS * sizeof(RAWTriangle)	triangle buffer
	ULONG						bufferstate;
	
	/*
	** Write the name of the mesh, including its '\0' at the end
	*/
	if(FWrite(rawfile,mesh->name,stringlen(mesh->name)+1,1)!=1) return(RCWRITEDATA);
	
	/*
	** Write the polygons as triangles, must be convex polygons !
	*/	  		
  	if(mesh->polygons.firstNode!=NULL) {             	
		bufferstate=0;
	
		pln=mesh->polygons.firstNode;
		do {
			/* Get the first point of the polygon, used to create all triangles with it */
			if(pln->numberOfVertices>=3) {
				plv1=pln->firstNode;
				ver1=plv1->vertexNode->vertex;
			
				plvi=plv1;
				do {	
					plv2=plvi->next;
					plv3=plv2->next;
				
					ver2=plv2->vertexNode->vertex;
					ver3=plv3->vertexNode->vertex;
					
					tbuffer[bufferstate].x1=ver1.x;
					tbuffer[bufferstate].y1=ver1.y;
					tbuffer[bufferstate].z1=ver1.z;

					tbuffer[bufferstate].x2=ver2.x;
					tbuffer[bufferstate].y2=ver2.y;
					tbuffer[bufferstate].z2=ver2.z;

					tbuffer[bufferstate].x3=ver3.x;
					tbuffer[bufferstate].y3=ver3.y;
					tbuffer[bufferstate].z3=ver3.z;

					// check if the buffer is full and write and initialize it
					if (++bufferstate==Ci_BUFFERS) {
						if(FWrite(rawfile,&tbuffer,Ci_BUFFERS*sizeof(RAWTriangle),1)!=1) return(RCWRITEDATA);
						bufferstate=0;
					}

					plvi=plvi->next;
				} while(plv3->next!=NULL);	
			}
		
			/* Get the next polygon */
			pln=pln->next;			
		} while(pln!=NULL);

		// check if the buffer has still some elements and write them
		if (bufferstate>0) {
			if(FWrite(rawfile,&tbuffer,bufferstate*sizeof(RAWTriangle),1)!=1) return(RCWRITEDATA);
			bufferstate=0;
		}
	}
	
	return(RCNOERROR);
}

/************************* End of file ******************************/
