/*
**      $VER: geo.c 1.00 (27.03.1999)
**
**      Creation date : 19.02.1999
**
**      Description       :
**         Standart saver module for meshwriter.library.
**         Saves the mesh as Videoscape file.
**
**
**      Written by Stephan Bielmann
**
*/

/*************************** Includes *******************************/

/*
** Ansi C includes
*/
#include <math.h>

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
#include "utilities.h"

/**************************** Defines *******************************/

/*
** Number of elements in the buffers
*/
#define Ci_MAXVERINPOLY 200	// maximum vertices in a polygon
#define Ci_BUFFERV      100	// vector buffer

/*********************** Type definitions ***************************/

/*
** This struct is created just for storing Videoscape default
** color palette table.
*/
typedef struct {
        UBYTE  red, green, blue;
} GEOColor;

/*
** Vector structure for the binary format
*/
typedef struct {
	FLOAT x,y,z;
} GEOVector;

typedef struct {
	UBYTE name[4];
	UWORD nvertices;
} GEOHead;

/*************************** Variables ******************************/

/*
** Videoscape equivalent rgb colors.
*/
static const GEOColor colorTbl[] = {
{  0,  0,  0},{  0,  0,178},{  0,178,  0},{  0,178,178},{178,  0,  0},{255,127,255},
{204,153,102},{127,127,127},{  0,  0,  0},{102,102,255},{102,255,102},{  0,255,100},
{255,102,102},{255,204,255},{255,255,  0},{255,255,255}
};

/********************** Private functions ***************************/

/********************************************************************\
*                                                                    *
* Name         : magnitude                                           *
*                                                                    *
* Description  : Calculates the magnitude of a color vector.         *
*                                                                    *
* Arguments    : x,y,z : Color vector.                               *
*                                                                    *
* Return Value : Vector its magnitude.                               *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static ULONG magnitude(LONG x, LONG y, LONG z)
{
	return(sqrt(x*x + y*y + z*z));
}

/********************************************************************\
*                                                                    *
* Name         : index2Color                                         *
*                                                                    *
* Description  : Converts a GEO color index into a RGB color.        *
*                                                                    *
* Arguments    : index : The color index.                            *
*                                                                    *
* Return Value : Vector its magnitude.                               *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static GEOColor index2Color(ULONG index)
{
	static GEOColor col;
	
	/*
	** Check range
	*/
	if (index >= 0 && index < sizeof(colorTbl)/sizeof(GEOColor)) {
		/*
		** return table entry
		*/
		col.red = colorTbl[index].red;
		col.green= colorTbl[index].green;
		col.blue= colorTbl[index].blue;

		return (col);
	}

	/*
	** Out-of-range color is white, like undefined.
	*/
	col.red = 255;
	col.green= 255;
	col.blue= 255;
                
	return (col);
}

/********************************************************************\
*                                                                    *
* Name         : color2GEO                                           *
*                                                                    *
* Description  : Matches the nearest color available in the GEO      *
*                color palette.                                      *
*                                                                    *
* Arguments    : red,green,blue : Color values.                      *
*                                                                    *
* Return Value : GEO color index.                                    *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static ULONG color2GEO (UBYTE red, UBYTE green, UBYTE blue)
{
	ULONG		i;
	ULONG		index = 1;
	GEOColor	current;
	LONG		best;
	LONG		difference;
  
	current = index2Color(index);
	best =  magnitude(current.red-red,current.green-green,current.blue-blue);

	for (i = 0; i < sizeof(colorTbl)/sizeof(GEOColor); i++) {
		current = index2Color(i);
		difference = magnitude(current.red-red,current.green-green,current.blue-blue);
		if (difference < best) {
			best = difference;
			index = i;
		}
	}

	return (index);
}

/********************** Public functions ****************************/

/********************************************************************\
*                                                                    *
* Name         : write3GEOA                                          *
*                                                                    *
* Description  : Writes a standart Videoscape ASCII file.            *
*                                                                    *
* Arguments    : geofile IN  : An already opened file stream.        *
*                mesh    IN  : Pointer to the mesh.                  *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                RCVERTEXINPOLYGONOVERFLOW                           *
*                                                                    *
* Comment      : #Vertices per polygon limited to 100 by myself !    *
*                                                                    *
\********************************************************************/
ULONG write3GEOA(BPTR geofile, TOCLMesh *mesh) {
	UBYTE 						buffer[500];
	ULONG						pbuffer[Ci_MAXVERINPOLY];	// Ci_MAXVERINPOLY * sizeof(ULONG)	polygon vertex buffer
	TOCLVertexNode				*ver=NULL;
	TOCLPolygonNode 			*pln=NULL;
	TOCLPolygonsVerticesNode	*plv=NULL;
	LONG						polybufstate;

/* As the binary is limmited with words for the vertex counts I suppose the ASCII too */

	/*
	** Write the header and the number of vertices
	*/
	if (FPrintf(geofile,"3DG1\n%ld\n",mesh->vertices.numberOfVertices)==ENDSTREAMCH) return(RCWRITEDATA);

	/*
	** Write the vertices
	*/              
	if(mesh->vertices.firstNode!=NULL) {
		ver=mesh->vertices.firstNode;
		do {
			TOCLVertex v=ver->vertex;
			sprintf(buffer,"%g %g %g\n",v.x,v.z,v.y);
			if(FPuts(geofile,buffer)!=DOSFALSE) return(RCWRITEDATA);
			ver=ver->next;
		} while(ver!=NULL);
	}

	/*
	** Write the polygons
	*/
  	if(mesh->polygons.firstNode!=NULL) {             
  	  	pln=mesh->polygons.firstNode;
		do {				
			if(pln->firstNode!=NULL) {  
				TOCLColor col=pln->materialNode->diffuseColor;

				plv=pln->firstNode;
				if (FPrintf(geofile,"%ld ",pln->numberOfVertices)==ENDSTREAMCH) return(RCWRITEDATA);

				// initialize the buffer state
				polybufstate=Ci_MAXVERINPOLY-1;

				// transform from counterclockwise to clockwise
				do {
					pbuffer[polybufstate--]=plv->vertexNode->index-1;

					// check if there are to much vertices in this polygon
					if (polybufstate<0) {
						return(RCVERTEXINPOLYGONOVERFLOW);
					}

					plv=plv->next;
				} while(plv!=NULL);

				// write the indexes
				while(++polybufstate<Ci_MAXVERINPOLY) {
					if (FPrintf(geofile,"%ld ",pbuffer[polybufstate])==ENDSTREAMCH) return(RCWRITEDATA);
				}

				// write the material index
				if (FPrintf(geofile,"%ld\n",color2GEO(col.r,col.g,col.b))==ENDSTREAMCH) return(RCWRITEDATA);
			}
			pln=pln->next;
		} while(pln!=NULL);	
	}

	return(RCNOERROR);
}

/********************************************************************\
*                                                                    *
* Name         : write3GEOB                                          *
*                                                                    *
* Description  : Writes a standart Videoscape binary file.           *
*                                                                    *
* Arguments    : geofile IN  : An already opened file stream.        *
*                mesh    IN  : Pointer to the mesh.                  *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                RCVERTEXINPOLYGONOVERFLOW                           *
*                                                                    *
* Comment      : #Vertices per polygon limited to 100 by myself !    *
*                                                                    *
\********************************************************************/
ULONG write3GEOB(BPTR geofile, TOCLMesh *mesh) {
	UWORD						pbuffer[Ci_MAXVERINPOLY];	// Ci_MAXVERINPOLY * sizeof(UWORD)	polygon vertex buffer
	GEOVector					vbuffer[Ci_BUFFERV];		// Ci_BUFFERV * sizeof(GeoVector)	vector buffer
	TOCLVertexNode				*ver=NULL;
	TOCLPolygonNode 			*pln=NULL;
	TOCLPolygonsVerticesNode	*plv=NULL;
	GEOHead					gh;
	LONG						polybufstate;
	ULONG						bufferstate;
	UWORD 						w;

/* As the binary is limmited with words for the vertex counts I suppose the ASCII too */

	/*
	** Write the header and the number of vertices
	*/
	setUBYTEArray(gh.name,"3DB1",4);
	gh.nvertices=mesh->vertices.numberOfVertices;
	if(FWrite(geofile,&gh,sizeof(gh),1)!=1) return(RCWRITEDATA);	

	/*
	** Write the vertices
	*/              
	if(mesh->vertices.firstNode!=NULL) {
		ver=mesh->vertices.firstNode;

		// initialize the buffer state
		bufferstate=0;

		do {
			TOCLVertex v=ver->vertex;

			vbuffer[bufferstate].x=v.x;
			vbuffer[bufferstate].y=v.y;
			vbuffer[bufferstate].z=v.z;

			// increment the bufferstate and 
			// check if the buffer is full and write and initialize it
			if (++bufferstate==Ci_BUFFERV) {
				if(FWrite(geofile,&vbuffer,Ci_BUFFERV*sizeof(GEOVector),1)!=1) return(RCWRITEDATA);
				bufferstate=0;
			}

			ver=ver->next;
		} while(ver!=NULL);

			// write the rest of the buffer if there is any
			if (bufferstate!=0) {
				if(FWrite(geofile,&vbuffer,bufferstate*sizeof(GEOVector),1)!=1) return(RCWRITEDATA);
			}			
	}

	/*
	** Write the polygons
	*/
  	if(mesh->polygons.firstNode!=NULL) {             
  	  	pln=mesh->polygons.firstNode;
		do {				
			if(pln->firstNode!=NULL) {  
				TOCLColor col=pln->materialNode->diffuseColor;

				plv=pln->firstNode;

				// initialize the buffer state
				polybufstate=Ci_MAXVERINPOLY-1;

				// transform from counterclockwise to clockwise
				do {
					pbuffer[polybufstate--]=plv->vertexNode->index-1;

					// check if there are to much vertices in this polygon
					if (polybufstate<0) {
						return(RCVERTEXINPOLYGONOVERFLOW);
					}

					plv=plv->next;
				} while(plv!=NULL);

				// write the number of vertices in this polygon
				w=pln->numberOfVertices;
				if(FWrite(geofile,&w,sizeof(UWORD),1)!=1) return(RCWRITEDATA);					  
 
				// write down the buffer
				if(FWrite(geofile,&pbuffer[polybufstate+1],w*sizeof(UWORD),1)!=1) return(RCWRITEDATA);					  

				// write the material index
				w=color2GEO(col.r,col.g,col.b);
				if(FWrite(geofile,&w,sizeof(UWORD),1)!=1) return(RCWRITEDATA);					  
			}
			pln=pln->next;
		} while(pln!=NULL);	
	}

	return(RCNOERROR);
}

/************************* End of file ******************************/
