/*
**      $VER: lightwave.c 1.00 (27.03.1999)
**
**      Creation date : 01.01.1999
**
**      Description       :
**         Standart saver module for meshwriter.library.
**         Saves the mesh as Lightwave file.
**
**
**      Written by Stephan Bielmann
**
*/

/*************************** Includes *******************************/

/*
** Amiga includes
*/
#include <dos/stdio.h>

#include <clib/dos_protos.h>

/*
** Project includes
*/
#include "meshwriter_private.h"
#include "utilities.h"

/**************************** Defines *******************************/

/*
** Number of elements in the buffers
*/
#define Ci_BUFFERS  100	// constant buffer size
#define Ci_MAXPOLYS 200	// maximum number of polygons

/*********************** Type definitions ***************************/

/*
** Private type definitions
*/
typedef struct {
	FLOAT x,y,z;
} LWOBVertex;

typedef struct {
	UBYTE name[4];
	ULONG size;
} LWOBChunk;

typedef struct {
	UBYTE name[4];
	UWORD size;
} LWOBSubChunk;

typedef struct {
	LWOBSubChunk chunk;
	UBYTE r,g,b,n;
} LWOBColrChunk;

typedef struct {
	LWOBSubChunk chunk;
	UWORD w;
} LWOBWordChunk;

/********************** Private functions ***************************/

/********************** Public functions ****************************/

/********************************************************************\
*                                                                    *
* Name         : write3LWOB                                          *
*                                                                    *
* Description  : Writes a standart lightwave object binary file.     *
*                Revision date : 28.11.1994                          *
*                                                                    *
* Arguments    : lwobfile  IN : An already opened file stream.       *
*                mesh      IN : Pointer to the mesh.                 *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                RCVERTEXINPOLYGONOVERFLOW                           *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
ULONG write3LWOB(BPTR lwobfile, TOCLMesh *mesh) {
	LWOBChunk			form,pnts,srfs,pols,surf;
	LWOBColrChunk		colr;
	LWOBWordChunk		glos,tran;
	
	TOCLVertexNode				*ver=NULL;
	TOCLMaterialNode			*mat=NULL;	
	TOCLPolygonNode			*pln=NULL;
	TOCLPolygonsVerticesNode	*plvi=NULL;
	
	LWOBVertex			vbuffer[Ci_BUFFERS];	// Ci_BUFFERS  * sizeof(LWOBVertex)	vertices buffer
	UWORD				pbuffer[Ci_MAXPOLYS];	// Ci_MAXPOLYS * sizeof(UWORD)		polygons buffer
	ULONG				bufferstate;
	LONG				polybufstate;
	ULONG				len;

// nicht mehr als uword vertices wegen polygon index = uword !!

	/*
	** Initializing all chunks and theyr sizes and static contents
	*/	
	setUBYTEArray(pnts.name,"PNTS",4);
	pnts.size=mesh->vertices.numberOfVertices*sizeof(FLOAT)*3;
	
	setUBYTEArray(srfs.name,"SRFS",4);
	// compute its size
	srfs.size=0;
	if(mesh->materials.firstNode) {
		mat=mesh->materials.firstNode;
		do {
			srfs.size+=stringlen(mat->name);
		  
		  	// check if odd or not
			if(srfs.size) {
				if ((srfs.size+1)%2) {
					srfs.size+=2;
				} else {
					srfs.size++;
				}
			}
			
			mat=mat->next;
		} while(mat!=NULL);
	}

	setUBYTEArray(surf.name,"SURF",4);

	setUBYTEArray(pols.name,"POLS",4);
	// size = numberOfPolygons * 4 (for the polygon size and surface index)
	// and number of vertex indices * 2
	pols.size=0;
  	if(mesh->polygons.firstNode!=NULL) {             	
		pln=mesh->polygons.firstNode;
		do {
			pols.size+=pln->numberOfVertices*2+4;
			
			pln=pln->next;
		} while (pln!=NULL);
	} 

	setUBYTEArray(colr.chunk.name,"COLR",4);
	colr.chunk.size = 4;		// fixed size
	colr.n = 0;				// fixed value

	setUBYTEArray(glos.chunk.name,"GLOS",4);
	glos.chunk.size = 2;		// fixed size

	setUBYTEArray(tran.chunk.name,"TRAN",4);
	tran.chunk.size = 2;		// fixed size

	setUBYTEArray(form.name,"FORM",4);
	form.size=0;
	// size += 8 for pnts chunk and its size, if existent	
	if(mesh->vertices.firstNode!=NULL) {
  		form.size += 8 + pnts.size;
  	}
	// size += 8 for srfs chunk and its size, if existent
	// size += numberOfMaterials * 8 for surf chunk and its size. if existent
	if(mesh->materials.firstNode!=NULL) {
  		form.size += 8 + srfs.size;
  		
		// size of srfs and number of materials * (size and content of colr,glos,tran and 8 for surf itself)
		form.size += srfs.size + mesh->materials.numberOfMaterials * (10+8+8+8);
  	}
  	// size += 8 for pols chunk and its size, if existent
  	if(mesh->polygons.firstNode!=NULL) {
		form.size += 8 + pols.size;
  	}
  	// size += 4 for LWOB 
  	form.size += 4;
	
	/*
	** Writing the chunks and theyr dynamic content
	*/
	if(FWrite(lwobfile,&form,sizeof(form),1)!=1) return(RCWRITEDATA);

	if(FWrite(lwobfile,"LWOB",1,4)!=4) return(RCWRITEDATA);
		
	// if there are vertices
	if(mesh->vertices.firstNode!=NULL) {
		if(FWrite(lwobfile,&pnts,sizeof(pnts),1)!=1) return(RCWRITEDATA);
	
		// initialize the buffer state
		bufferstate=0;
		
		ver=mesh->vertices.firstNode;
		do {
			TOCLVertex v=ver->vertex;

			vbuffer[bufferstate].x=v.x;
			vbuffer[bufferstate].y=v.z;
			vbuffer[bufferstate].z=v.y;

			// check if the buffer is full and write and initialize it
			if (++bufferstate==Ci_BUFFERS) {
				if(FWrite(lwobfile,&vbuffer,Ci_BUFFERS*sizeof(LWOBVertex),1)!=1) return(RCWRITEDATA);
				bufferstate=0;
			}

			ver=ver->next;
		} while(ver!=NULL);

		// write the rest of the buffer if there is any
		if (bufferstate!=0) {
			if(FWrite(lwobfile,&vbuffer,bufferstate*sizeof(LWOBVertex),1)!=1) return(RCWRITEDATA);
			bufferstate=0;
		}			
	}

	// writing the material names in this object, if there are some
	if(mesh->materials.firstNode) {
		if(FWrite(lwobfile,&srfs,sizeof(srfs),1)!=1) return(RCWRITEDATA);

		mat=mesh->materials.firstNode;
		do {
			len=stringlen(mat->name);
		  
			// write the name, add a '\0' and two of them if the size of the name + \0 is odd
			if(len) {
				if(FWrite(lwobfile,mat->name,len,1)!=1) return(RCWRITEDATA);
				if ((len+1)%2) {
					if(FWrite(lwobfile,"\0\0",2,1)!=1) return(RCWRITEDATA);
				} else {
					if(FWrite(lwobfile,"\0",1,1)!=1) return(RCWRITEDATA);
				}
			}
			
			mat=mat->next;
		} while(mat!=NULL);
	}

	// write the polygons with surface index, if there are any
	// they have to be written clockwise ! and Ci_MAXPOLYS points each polygon "only"
	if (mesh->polygons.firstNode!=NULL) {
		UWORD w;
		
		if(FWrite(lwobfile,&pols,sizeof(pols),1)!=1) return(RCWRITEDATA);

		// initialize the buffer state
		polybufstate=Ci_MAXPOLYS-1;
		
		pln=mesh->polygons.firstNode;
		do {
			plvi=pln->firstNode;
			
			do {	
				// transform from counterclockwise to clockwise
				pbuffer[polybufstate--]=plvi->vertexNode->index-1;
				
				// check if there are to much vertices in this polygon
				if (polybufstate<0) {
					return(RCVERTEXINPOLYGONOVERFLOW);
				}
				
				plvi=plvi->next;
			} while(plvi!=NULL);						

			// write the number of vertices in this polygon
			w=pln->numberOfVertices;
			if(FWrite(lwobfile,&w,sizeof(UWORD),1)!=1) return(RCWRITEDATA);					  
 
			// write down the buffer
			if(FWrite(lwobfile,&pbuffer[polybufstate+1],w*sizeof(UWORD),1)!=1) return(RCWRITEDATA);					  
			polybufstate=Ci_MAXPOLYS-1;

			// add the surface index
			if (pln->materialNode) {
				w=pln->materialNode->index;
			} else {
				// no material => index = 0
				w=0;
			}
			if(FWrite(lwobfile,&w,sizeof(UWORD),1)!=1) return(RCWRITEDATA);					  
			
			pln=pln->next;
		} while (pln!=NULL);		
	}

	// writing the materials if there are some
	if(mesh->materials.firstNode) {

		mat=mesh->materials.firstNode;
		do {
			len=stringlen(mat->name);
		  
			surf.size = len+1;
			// if the size of the name + \0 is odd, we have to pad it => +1
			if (surf.size%2) surf.size++;
			surf.size += colr.chunk.size + glos.chunk.size + tran.chunk.size + 3 * 6;
			
			if(FWrite(lwobfile,&surf,sizeof(surf),1)!=1) return(RCWRITEDATA);

			// write its name, add a '\0' and two of them if the size of the name + \0 is odd
			if(len) {
				if(FWrite(lwobfile,mat->name,len,1)!=1) return(RCWRITEDATA);
				if ((len+1)%2) {
					if(FWrite(lwobfile,"\0\0",2,1)!=1) return(RCWRITEDATA);
				} else {
					if(FWrite(lwobfile,"\0",1,1)!=1) return(RCWRITEDATA);
				}
			}
			
			// diffuse color
			colr.r=mat->diffuseColor.r, colr.g=mat->diffuseColor.g, colr.b=mat->diffuseColor.b;
			if(FWrite(lwobfile,&colr,sizeof(colr),1)!=1) return(RCWRITEDATA);

			// glossiness
			glos.w=(UWORD)(mat->shininess*256);
			if(FWrite(lwobfile,&glos,sizeof(glos),1)!=1) return(RCWRITEDATA);

			// transparecy
			tran.w=(UWORD)(mat->transparency*256);
			if(FWrite(lwobfile,&tran,sizeof(tran),1)!=1) return(RCWRITEDATA);

			mat=mat->next;

		} while(mat!=NULL);
	}

	return(RCNOERROR);
}

/************************* End of file ******************************/
