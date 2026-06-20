/*
**      $VER: imagine.c 1.00 (27.03.1999)
**
**      Creation date : 17.11.1998
**
**      Description       :
**         Standart saver module for meshwriter.library.
**         Saves the mesh as Imagine TDDD file.
**
**
**      Written by Stephan Bielmann
**
*/

/*************************** Includes *******************************/

/*
** Amiga includes
*/

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
#define Ci_BUFFERC 99	// color buffer must be dividable by 3 !
#define Ci_BUFFERV 100	// vector buffer
#define Ci_BUFFERE 100	// edge buffer must be dividable by 4 !
#define Ci_BUFFERF 99	// face buffer must be dividable by 3 !

/*********************** Type definitions ***************************/

/*
** Private type definitions
*/
typedef struct {
	LONG x,y,z;
} TDDDVector;

typedef struct {
	UBYTE name[4];
	ULONG size;
} TDDDChunk;

typedef struct {
	TDDDChunk chunk;
	UBYTE oname[18];
} TDDDNameChunk;

typedef struct {
	TDDDChunk chunk;
	UWORD shape;
	UWORD lamp;
} TDDDShapChunk;

typedef struct {
	TDDDChunk chunk;
	TDDDVector vector;
} TDDDVectorChunk;

typedef struct {
	TDDDChunk chunk;
	TDDDVector xaxis,yaxis,zaxis;
} TDDDAxisChunk;

typedef struct {
	TDDDChunk chunk;
	TDDDVector mins,maxs;
} TDDDBBoxChunk;

typedef struct {
	TDDDChunk chunk;
	UWORD count;
} TDDDCountChunk;

typedef struct {
	TDDDChunk chunk;
	ULONG count;
} TDDDCountChunk2;

typedef struct {
	TDDDChunk chunk;
	UBYTE pad;
	UBYTE r,g,b;
} TDDDColorChunk;

/********************** Private functions ***************************/

/********************************************************************\
*                                                                    *
* Name         : float2long                                          *
*                                                                    *
* Description  : Converts a float value into an Imagine long value.  *
*                                                                    *
* Arguments    : f IN : The float value to convert.                  *
*                                                                    *
* Return Value : The converted value as LONG                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static LONG float2long(TOCLFloat f) {
	if (f<0) return(-(LONG)(-65536.0*f+0.5));
	else return((LONG)(65536.0*f+0.5));
}

/********************** Public functions ****************************/

/********************************************************************\
*                                                                    *
* Name         : write3TDDD                                          *
*                                                                    *
* Description  : Writes a standart imagine < 3.0 binary file.        *
*                                                                    *
* Arguments    : tdddfile IN : An already opened file stream.        *
*                mesh     IN : Pointer to the mesh.                  *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      : Default material is white !                         *
*                                                                    *
\********************************************************************/
ULONG write3TDDD(BPTR tdddfile, TOCLMesh *mesh) {
	TDDDChunk			form,obj,desc,tobj;
	TDDDNameChunk		name;
	TDDDAxisChunk		axis;
	TDDDShapChunk		shap;
	TDDDVectorChunk	posi,size;
	TDDDBBoxChunk		bbox;
	TDDDCountChunk		pnts,edge,face,clst,tlst;	
	TDDDColorChunk		colr,refl,tran,spc1;
	
	TOCLPolygonNode			*pln=NULL;
	TOCLPolygonsVerticesNode	*plvi=NULL,*plv1=NULL,*plv2=NULL,*plv3=NULL;
	TOCLVertexNode				*ver=NULL;
	TOCLMaterialNode			*mat=NULL;	

	TDDDVector			vbuffer[Ci_BUFFERV];	// Ci_BUFFERV * sizeof(TDDDVector)	vector buffer
	UWORD				ebuffer[Ci_BUFFERE];	// Ci_BUFFERE * sizeof(UWORD)			edge buffer
	UWORD				fbuffer[Ci_BUFFERF];	// Ci_BUFFERF * sizeof(UWORD)			face buffer
	UBYTE				cbuffer[Ci_BUFFERC];	// Ci_BUFFERB							byte buffer
	ULONG				bufferstate;
	ULONG				edgeoffset;

// werte check fract : -32767.5 bis 32767.5 => neuer rueckgabe wert !!
// counts nicht groesser als 32k !!

	/*
	** Initializing all chunks and theyr sizes and static contents
	*/
	setUBYTEArray(name.chunk.name,"NAME",4);
	name.chunk.size = 18; 	// fixed size
	setUBYTEArray(name.oname,mesh->name,18);

	setUBYTEArray(shap.chunk.name,"SHAP",4);
	shap.chunk.size=4; 	// fixed size
	shap.shape=2;			// an axis object
	shap.lamp=0;			// not a lamp

	setUBYTEArray(posi.chunk.name,"POSI",4);
	posi.chunk.size=12;					// fixed size
	posi.vector.x=float2long(0.0);		// origin of the object is fixed to {0,0,0}
	posi.vector.y=float2long(0.0);
	posi.vector.z=float2long(0.0);

	setUBYTEArray(axis.chunk.name,"AXIS",4);
	axis.chunk.size=36;							// fixed size
	axis.xaxis.x=1,axis.xaxis.y=0,axis.xaxis.z=0;	// fixed x-axis unit vector
	axis.yaxis.x=0,axis.yaxis.y=1,axis.yaxis.z=0;	// fixed y-axis unit vector
	axis.zaxis.x=0,axis.zaxis.y=0,axis.zaxis.z=1;	// fixwd z-axis unit vector

	setUBYTEArray(size.chunk.name,"SIZE",4);
	size.chunk.size=12;												// fixed size
	size.vector.x=float2long(mesh->bBox.right - mesh->bBox.left);	// bbox length x axis
	size.vector.y=float2long(mesh->bBox.front - mesh->bBox.rear);	// bbox length y axis
	size.vector.z=float2long(mesh->bBox.top - mesh->bBox.bottom);	// bbox length z axis

	setUBYTEArray(bbox.chunk.name,"BBOX",4);
	bbox.chunk.size=24;							// fixed size
	bbox.mins.x=float2long(mesh->bBox.left);		// bbox min x size
	bbox.mins.y=float2long(mesh->bBox.rear);		// bbox min y size
	bbox.mins.z=float2long(mesh->bBox.bottom);	// bbox min z size
	bbox.maxs.x=float2long(mesh->bBox.right);		// bbox max x size
	bbox.maxs.y=float2long(mesh->bBox.front);		// bbox max y size
	bbox.maxs.z=float2long(mesh->bBox.top);		// bbox max z size

	setUBYTEArray(pnts.chunk.name,"PNTS",4);
	// number of points = number of vertices
	pnts.count=mesh->vertices.numberOfVertices;
	pnts.chunk.size=sizeof(pnts.count) + pnts.count * sizeof(TDDDVector);	

	// number of faces = sum of each polygon (number of vertices - 2)
	// number of edges = sum of each polygon ((number of vertices-3)*2 +3)
	face.count=0;
	edge.count=0;
  	if(mesh->polygons.firstNode!=NULL) {             	
		pln=mesh->polygons.firstNode;
		do {
			// we accept only polygons with 3 or more points !
			if (pln->numberOfVertices>=3) {
				face.count+=pln->numberOfVertices-2;
				edge.count+=(pln->numberOfVertices-3)*2+3;
			}
			pln=pln->next;
		} while (pln!=NULL);
	} 

	setUBYTEArray(face.chunk.name,"FACE",4);
	face.chunk.size=sizeof(face.count) + face.count * 3 * sizeof(UWORD);
	
	setUBYTEArray(edge.chunk.name,"EDGE",4);
	edge.chunk.size=sizeof(edge.count) + edge.count * 2 * sizeof(UWORD);

	setUBYTEArray(colr.chunk.name,"COLR",4);
	colr.chunk.size=4;					// fixed size
	colr.pad=0;						// default value
	colr.r=255,colr.g=255,colr.b=255;	// default color is white

	setUBYTEArray(refl.chunk.name,"REFL",4);
	refl.chunk.size=4;						// fixed size
	refl.pad=0;							// default value
	refl.r=0,colr.g=0,colr.b=0;			// default reflection is black

	setUBYTEArray(tran.chunk.name,"TRAN",4);
	tran.chunk.size=4;						// fixed size
	tran.pad=0;							// default value
	tran.r=0,colr.g=0,colr.b=0;			// default transparency is none

	setUBYTEArray(spc1.chunk.name,"SPC2",4);
	spc1.chunk.size=4;					// fixed size
	spc1.pad=0;						// default value
	spc1.r=255,colr.g=255,colr.b=255;	// default specularity is white

	setUBYTEArray(clst.chunk.name,"CLST",4);
	// each face has its color so count = #faces
	clst.count=face.count;
	clst.chunk.size=sizeof(clst.count) + clst.count * 3 * sizeof(UBYTE);
	// if an odd we have an odd count, size must be incremented to insert a pad
	if (clst.count%2) clst.chunk.size++;

	setUBYTEArray(tlst.chunk.name,"TLST",4);
	// each face has its transparency so count = #faces
	tlst.count=face.count;
	tlst.chunk.size=sizeof(tlst.count) + tlst.count * 3 * sizeof(UBYTE);
	// if an odd we have an odd count, size must be incremented to insert a pad
	if (tlst.count%2) tlst.chunk.size++;

	setUBYTEArray(desc.name,"DESC",4);
	// size = sizes of all above and the size of themselves, = 8 Bytes each
	// pnts,edge,face only if there are polygons and edges and faces
	// clst,tlst only if there are materials and faces
	
	desc.size = name.chunk.size+axis.chunk.size+shap.chunk.size+posi.chunk.size+size.chunk.size;
	desc.size += bbox.chunk.size+colr.chunk.size+refl.chunk.size+tran.chunk.size+spc1.chunk.size;
	desc.size += 10 * 8;

	if(mesh->polygons.firstNode && edge.count && face.count) {
		desc.size += pnts.chunk.size+edge.chunk.size+face.chunk.size;
		desc.size += 3 * 8;
	}
	if(mesh->materials.firstNode && face.count) {
		desc.size += clst.chunk.size+tlst.chunk.size;
		desc.size += 2 * 8;
	}

	setUBYTEArray(obj.name,"OBJ ",4);
	// size = desc.size + 8 for desc itself and 8 for tobj
	obj.size = desc.size + 16;

	setUBYTEArray(form.name,"FORM",4);
	// size = obj.size + 8 for obj itself and 4 for tddd
	form.size = obj.size + 12;

	setUBYTEArray(tobj.name,"TOBJ",4);
	tobj.size=0;		// fixed size


	/*
	** Writing the chunks and theyr dynamic content
	*/
	if(FWrite(tdddfile,&form,sizeof(form),1)!=1) return(RCWRITEDATA);

	if(FWrite(tdddfile,"TDDD",1,4)!=4) return(RCWRITEDATA);
	
	if(FWrite(tdddfile,&obj,sizeof(obj),1)!=1) return(RCWRITEDATA);
	
	if(FWrite(tdddfile,&desc,sizeof(desc),1)!=1) return(RCWRITEDATA);

	if(FWrite(tdddfile,&name,sizeof(name),1)!=1) return(RCWRITEDATA);

	if(FWrite(tdddfile,&shap,sizeof(shap),1)!=1) return(RCWRITEDATA);

	if(FWrite(tdddfile,&posi,sizeof(posi),1)!=1) return(RCWRITEDATA);	

	if(FWrite(tdddfile,&axis,sizeof(axis),1)!=1) return(RCWRITEDATA);	

	if(FWrite(tdddfile,&size,sizeof(size),1)!=1) return(RCWRITEDATA);	
	
	if(FWrite(tdddfile,&bbox,sizeof(bbox),1)!=1) return(RCWRITEDATA);	

	// only if there are polygons to write, and edge and faces
	if (mesh->polygons.firstNode && edge.count && face.count) {
		if(FWrite(tdddfile,&pnts,sizeof(pnts),1)!=1) return(RCWRITEDATA);	

		// initialize the buffer state
		bufferstate=0;

		// write the points
		// this is a futil test but anyway
		if(mesh->vertices.firstNode!=NULL) {
			ver=mesh->vertices.firstNode;
			do {
				TOCLVertex v=ver->vertex;

				vbuffer[bufferstate].x=float2long(v.x);
				vbuffer[bufferstate].y=float2long(v.y);
				vbuffer[bufferstate].z=float2long(v.z);

				// increment the bufferstate and 
				// check if the buffer is full and write and initialize it
				if (++bufferstate==Ci_BUFFERV) {
					if(FWrite(tdddfile,&vbuffer,Ci_BUFFERV*sizeof(TDDDVector),1)!=1) return(RCWRITEDATA);
					bufferstate=0;
				}
				
				ver=ver->next;
			} while(ver!=NULL);
		
			// write the rest of the buffer if there is any
			if (bufferstate!=0) {
				if(FWrite(tdddfile,&vbuffer,bufferstate*sizeof(TDDDVector),1)!=1) return(RCWRITEDATA);
			}			
		}

		if(FWrite(tdddfile,&edge,sizeof(edge),1)!=1) return(RCWRITEDATA);	
	
		// initialize the buffer state
		bufferstate=0;

  	  	pln=mesh->polygons.firstNode;
		do {								
			// only if there are 3 or more points in the polygon
			if(pln->numberOfVertices>=3) {
				plv1=pln->firstNode;
			
				plvi=plv1;
				do {	
					plv2=plvi->next;
					plv3=plv2->next;
				
					ebuffer[bufferstate++]=plv1->vertexNode->index-1;
					ebuffer[bufferstate++]=plv2->vertexNode->index-1;
					ebuffer[bufferstate++]=plv2->vertexNode->index-1;
					ebuffer[bufferstate++]=plv3->vertexNode->index-1;

					// check if the buffer is full and write and initialize it
					if (bufferstate==Ci_BUFFERE) {
						if(FWrite(tdddfile,&ebuffer,Ci_BUFFERE*sizeof(UWORD),1)!=1) return(RCWRITEDATA);					  
						bufferstate=0;
					}
				
					plvi=plvi->next;
				} while(plv3->next!=NULL);	
					
				ebuffer[bufferstate++]=plv1->vertexNode->index-1;
				ebuffer[bufferstate++]=plv3->vertexNode->index-1;

				// write the rest of the buffer
				if(FWrite(tdddfile,&ebuffer,bufferstate*sizeof(UWORD),1)!=1) return(RCWRITEDATA);					  
				bufferstate=0;
			}
			pln=pln->next;
		} while(pln!=NULL);
		
		if(FWrite(tdddfile,&face,sizeof(face),1)!=1) return(RCWRITEDATA);	

		// initialize the buffer state
		bufferstate=0;

		// initialize the edge offset
		edgeoffset=0;

		pln=mesh->polygons.firstNode;
		do {								
			ULONG i;
			
			// only if there are 3 or more points in the polygon
			if(pln->numberOfVertices>=3) {
			  	// do this for each edge - 1
				for(i=0;i<((pln->numberOfVertices-3)*2+2);i+=2) {
					fbuffer[bufferstate++]=edgeoffset+i;
					fbuffer[bufferstate++]=edgeoffset+i+1;
					fbuffer[bufferstate++]=edgeoffset+i+2;
					
					// check if the buffer is full and write and initialize it
					if (bufferstate==Ci_BUFFERF) {
						if(FWrite(tdddfile,&fbuffer,Ci_BUFFERF*sizeof(UWORD),1)!=1) return(RCWRITEDATA);					  
						bufferstate=0;
					}
				}
				edgeoffset+=i+1;
			}
			pln=pln->next;
		} while(pln!=NULL);

		// write he rest of the buffer if there is any
		if (bufferstate!=0) {
			if(FWrite(tdddfile,&fbuffer,bufferstate*sizeof(UWORD),1)!=1) return(RCWRITEDATA);					  
			bufferstate=0;
		}
	}
	
	if(FWrite(tdddfile,&colr,sizeof(colr),1)!=1) return(RCWRITEDATA);

	if(FWrite(tdddfile,&refl,sizeof(refl),1)!=1) return(RCWRITEDATA);

	if(FWrite(tdddfile,&tran,sizeof(tran),1)!=1) return(RCWRITEDATA);
	
	if(FWrite(tdddfile,&spc1,sizeof(spc1),1)!=1) return(RCWRITEDATA);
	
	// writing the materials if there are some, and if there are any faces
	if(mesh->materials.firstNode && face.count) {
		if(FWrite(tdddfile,&clst,sizeof(clst),1)!=1) return(RCWRITEDATA);		  

		// initialize the buffer state
		bufferstate=0;

		// The diffuse color, per face
		pln=mesh->polygons.firstNode;

		do {
			TOCLColor col=pln->materialNode->diffuseColor;
			// we accept only polygons with 3 or more points !
			if (pln->numberOfVertices>=3) {
				ULONG i;
				for(i=0;i<(pln->numberOfVertices-2);i++) {
					cbuffer[bufferstate++]=col.r;
					cbuffer[bufferstate++]=col.g;
					cbuffer[bufferstate++]=col.b;

					// check if the buffer is full and write and initialize it
					if (bufferstate==Ci_BUFFERC) {
						if(FWrite(tdddfile,&cbuffer,Ci_BUFFERC*sizeof(UBYTE),1)!=1) return(RCWRITEDATA);
						bufferstate=0;
					}
				}
			}
						
			pln=pln->next;
		} while(pln!=NULL);

		// if we have an odd count a pad has to be added at the end
		if (clst.count%2) {
			cbuffer[bufferstate++]=0;
		}
		
		// write the rest of the buffer if any
		if (bufferstate!=0) {
			if(FWrite(tdddfile,&cbuffer,bufferstate*sizeof(UBYTE),1)!=1) return(RCWRITEDATA);
			bufferstate=0;
		}

		if(FWrite(tdddfile,&tlst,sizeof(tlst),1)!=1) return(RCWRITEDATA);		  

		// initialize the buffer state
		bufferstate=0;

		// The transparency, per face
		pln=mesh->polygons.firstNode;
		do {
			// we accept only polygons with 3 or more points !
			if (pln->numberOfVertices>=3) {
				ULONG i;
				
				for(i=0;i<(pln->numberOfVertices-2);i++) {  
					cbuffer[bufferstate++]=UBYTE(255*mat->transparency);
					cbuffer[bufferstate++]=UBYTE(255*mat->transparency);
					cbuffer[bufferstate++]=UBYTE(255*mat->transparency);

					// check if the buffer is full and write and initialize it
					if (bufferstate==Ci_BUFFERC) {
						if(FWrite(tdddfile,&cbuffer,Ci_BUFFERC*sizeof(UBYTE),1)!=1) return(RCWRITEDATA);
						bufferstate=0;
					}
				}
			}
			
			pln=pln->next;
		} while(pln!=NULL);

		// if we have an odd count a pad has to be added at the end
		if (tlst.count%2) {
			cbuffer[bufferstate++]=0;
		}
		
		// write the rest of the buffer if any
		if (bufferstate!=0) {
			if(FWrite(tdddfile,&cbuffer,bufferstate*sizeof(UBYTE),1)!=1) return(RCWRITEDATA);
			bufferstate=0;
		}
	}

	if(FWrite(tdddfile,&tobj,sizeof(tobj),1)!=1) return(RCWRITEDATA);
  
	return(RCNOERROR);
}

/********************************************************************\
*                                                                    *
* Name         : write3TDDDH                                         *
*                                                                    *
* Description  : Writes a huge imagine binary file.                  *
*                                                                    *
* Arguments    : tdddfile IN : An already opened file stream.        *
*                mesh     IN : Pointer to the mesh.                  *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      : Default material is white !                         *
*                                                                    *
\********************************************************************/
ULONG write3TDDDH(BPTR tdddfile, TOCLMesh *mesh) {
	TDDDChunk			form,obj,desc,tobj;
	TDDDNameChunk		name;
	TDDDAxisChunk		axis;
	TDDDShapChunk		shp2;
	TDDDVectorChunk	posi,size;
	TDDDBBoxChunk		bbox;
	TDDDCountChunk2	pnt2,edg2,fac2,cls2,tls2;	
	TDDDColorChunk		colr,refl,tran,spc2;
	
	TOCLPolygonNode			*pln=NULL;
	TOCLPolygonsVerticesNode	*plvi=NULL,*plv1=NULL,*plv2=NULL,*plv3=NULL;
	TOCLVertexNode				*ver=NULL;
	TOCLMaterialNode			*mat=NULL;	

	TDDDVector			vbuffer[Ci_BUFFERV];	// Ci_BUFFERV * sizeof(TDDDVector)	vector buffer
	ULONG				ebuffer[Ci_BUFFERE];	// Ci_BUFFERE * sizeof(ULONG)			edge buffer
	ULONG				fbuffer[Ci_BUFFERF];	// Ci_BUFFERF * sizeof(ULONG)			face buffer
	UBYTE				bbuffer[Ci_BUFFERC];	// Ci_BUFFERB							byte buffer
	ULONG				bufferstate;
	ULONG				edgeoffset;

// werte check fract : -32767.5 bis 32767.5 => neuer rueckgabe wert !!

	/*
	** Initializing all chunks and theyr sizes and static contents
	*/
	setUBYTEArray(name.chunk.name,"NAME",4);
	name.chunk.size = 18; 	// fixed size
	setUBYTEArray(name.oname,mesh->name,18);

	setUBYTEArray(shp2.chunk.name,"SHP2",4);
	shp2.chunk.size=4; 	// fixed size
	shp2.shape=2;			// an axis object
	shp2.lamp=0;			// not a lamp

	setUBYTEArray(posi.chunk.name,"POSI",4);
	posi.chunk.size=12;					// fixed size
	posi.vector.x=float2long(0.0);		// origin of the object is fixed to {0,0,0}
	posi.vector.y=float2long(0.0);
	posi.vector.z=float2long(0.0);

	setUBYTEArray(axis.chunk.name,"AXIS",4);
	axis.chunk.size=36;							// fixed size
	axis.xaxis.x=1,axis.xaxis.y=0,axis.xaxis.z=0;	// fixed x-axis unit vector
	axis.yaxis.x=0,axis.yaxis.y=1,axis.yaxis.z=0;	// fixed y-axis unit vector
	axis.zaxis.x=0,axis.zaxis.y=0,axis.zaxis.z=1;	// fixwd z-axis unit vector

	setUBYTEArray(size.chunk.name,"SIZE",4);
	size.chunk.size=12;												// fixed size
	size.vector.x=float2long(mesh->bBox.right - mesh->bBox.left);	// bbox length x axis
	size.vector.y=float2long(mesh->bBox.front - mesh->bBox.rear);	// bbox length y axis
	size.vector.z=float2long(mesh->bBox.top - mesh->bBox.bottom);	// bbox length z axis

	setUBYTEArray(bbox.chunk.name,"BBOX",4);
	bbox.chunk.size=24;							// fixed size
	bbox.mins.x=float2long(mesh->bBox.left);		// bbox min x size
	bbox.mins.y=float2long(mesh->bBox.rear);		// bbox min y size
	bbox.mins.z=float2long(mesh->bBox.bottom);	// bbox min z size
	bbox.maxs.x=float2long(mesh->bBox.right);		// bbox max x size
	bbox.maxs.y=float2long(mesh->bBox.front);		// bbox max y size
	bbox.maxs.z=float2long(mesh->bBox.top);		// bbox max z size

	setUBYTEArray(pnt2.chunk.name,"PNT2",4);
	// number of points = number of vertices
	pnt2.count=mesh->vertices.numberOfVertices;
	pnt2.chunk.size=sizeof(pnt2.count) + pnt2.count * sizeof(TDDDVector);	

	// number of faces = sum of each polygon (number of vertices - 2)
	// number of edges = sum of each polygon ((number of vertices-3)*2 +3)
	fac2.count=0;
	edg2.count=0;
  	if(mesh->polygons.firstNode!=NULL) {             	
		pln=mesh->polygons.firstNode;
		do {
			// we accept only polygons with 3 or more points !
			if (pln->numberOfVertices>=3) {
				fac2.count+=pln->numberOfVertices-2;
				edg2.count+=(pln->numberOfVertices-3)*2+3;
			}
			pln=pln->next;
		} while (pln!=NULL);
	} 

	setUBYTEArray(fac2.chunk.name,"FAC2",4);
	fac2.chunk.size=sizeof(fac2.count) + fac2.count * 3 * sizeof(ULONG);
	
	setUBYTEArray(edg2.chunk.name,"EDG2",4);
	edg2.chunk.size=sizeof(edg2.count) + edg2.count * 2 * sizeof(ULONG);

	setUBYTEArray(colr.chunk.name,"COLR",4);
	colr.chunk.size=4;					// fixed size
	colr.pad=0;						// default value
	colr.r=255,colr.g=255,colr.b=255;	// default color is white

	setUBYTEArray(refl.chunk.name,"REFL",4);
	refl.chunk.size=4;						// fixed size
	refl.pad=0;							// default value
	refl.r=0,colr.g=0,colr.b=0;			// default reflection is black

	setUBYTEArray(tran.chunk.name,"TRAN",4);
	tran.chunk.size=4;						// fixed size
	tran.pad=0;							// default value
	tran.r=0,colr.g=0,colr.b=0;			// default transparency is none

	setUBYTEArray(spc2.chunk.name,"SPC2",4);
	spc2.chunk.size=4;					// fixed size
	spc2.pad=0;						// default value
	spc2.r=255,colr.g=255,colr.b=255;	// default specularity is white

	setUBYTEArray(cls2.chunk.name,"CLS2",4);
	// each face has its color so count = #faces
	cls2.count=fac2.count;
	cls2.chunk.size=sizeof(cls2.count) + cls2.count * 3 * sizeof(UBYTE);
	// if an odd we have an odd count, size must be incremented to insert a pad
	if (cls2.count%2) cls2.chunk.size++;

	setUBYTEArray(tls2.chunk.name,"TLS2",4);
	// each face has its transparency so count = #faces
	tls2.count=fac2.count;
	tls2.chunk.size=sizeof(tls2.count) + tls2.count * 3 * sizeof(UBYTE);
	// if an odd we have an odd count, size must be incremented to insert a pad
	if (tls2.count%2) tls2.chunk.size++;

	setUBYTEArray(desc.name,"DESC",4);
	// size = sizes of all above and the size of them selves, = 8 Bytes each
	// pnt2,edg2,fac2 only if there are polygons and edges and faces
	// cls2,tls2 only if there are materials and faces
	
	desc.size = name.chunk.size+axis.chunk.size+shp2.chunk.size+posi.chunk.size+size.chunk.size;
	desc.size += bbox.chunk.size+colr.chunk.size+refl.chunk.size+tran.chunk.size+spc2.chunk.size;
	desc.size += 10 * 8;

	if(mesh->polygons.firstNode && edg2.count && fac2.count) {
		desc.size += pnt2.chunk.size+edg2.chunk.size+fac2.chunk.size;
		desc.size += 3 * 8;
	}
	if(mesh->materials.firstNode && fac2.count) {
		desc.size += cls2.chunk.size+tls2.chunk.size;
		desc.size += 2 * 8;
	}

	setUBYTEArray(obj.name,"OBJ ",4);
	// size = desc.size + 8 for desc itself and 8 for tobj
	obj.size = desc.size + 16;

	setUBYTEArray(form.name,"FORM",4);
	// size = obj.size + 8 for obj itself and 4 for tddd
	form.size = obj.size + 12;

	setUBYTEArray(tobj.name,"TOBJ",4);
	tobj.size=0;		// fixed size


	/*
	** Writing the chunks and theyr dynamic content
	*/
	if(FWrite(tdddfile,&form,sizeof(form),1)!=1) return(RCWRITEDATA);

	if(FWrite(tdddfile,"TDDD",1,4)!=4) return(RCWRITEDATA);
	
	if(FWrite(tdddfile,&obj,sizeof(obj),1)!=1) return(RCWRITEDATA);
	
	if(FWrite(tdddfile,&desc,sizeof(desc),1)!=1) return(RCWRITEDATA);

	if(FWrite(tdddfile,&name,sizeof(name),1)!=1) return(RCWRITEDATA);

	if(FWrite(tdddfile,&shp2,sizeof(shp2),1)!=1) return(RCWRITEDATA);

	if(FWrite(tdddfile,&posi,sizeof(posi),1)!=1) return(RCWRITEDATA);	

	if(FWrite(tdddfile,&axis,sizeof(axis),1)!=1) return(RCWRITEDATA);	

	if(FWrite(tdddfile,&size,sizeof(size),1)!=1) return(RCWRITEDATA);	
	
	if(FWrite(tdddfile,&bbox,sizeof(bbox),1)!=1) return(RCWRITEDATA);	

	// only if there are polygons to write and edges and faces
	if (mesh->polygons.firstNode && edg2.count && fac2.count) {
		if(FWrite(tdddfile,&pnt2,sizeof(pnt2),1)!=1) return(RCWRITEDATA);	

		// initialize the buffer state
		bufferstate=0;

		// write the points
		// this is a futil test but anyway
		if(mesh->vertices.firstNode!=NULL) {
			ver=mesh->vertices.firstNode;
			do {
				TOCLVertex v=ver->vertex;

				vbuffer[bufferstate].x=float2long(v.x);
				vbuffer[bufferstate].y=float2long(v.y);
				vbuffer[bufferstate].z=float2long(v.z);

				// increment the bufferstate and 
				// check if the buffer is full and write and initialize it
				if (++bufferstate==Ci_BUFFERV) {
					if(FWrite(tdddfile,&vbuffer,Ci_BUFFERV*sizeof(TDDDVector),1)!=1) return(RCWRITEDATA);
					bufferstate=0;
				}
				
				ver=ver->next;
			} while(ver!=NULL);
		
			// write the rest of the buffer if there is any
			if (bufferstate!=0) {
				if(FWrite(tdddfile,&vbuffer,bufferstate*sizeof(TDDDVector),1)!=1) return(RCWRITEDATA);
			}			
		}

		if(FWrite(tdddfile,&edg2,sizeof(edg2),1)!=1) return(RCWRITEDATA);	
	
		// initialize the buffer state
		bufferstate=0;

  	  	pln=mesh->polygons.firstNode;
		do {								
			// only if there are 3 or more points in the polygon
			if(pln->numberOfVertices>=3) {
				plv1=pln->firstNode;
			
				plvi=plv1;
				do {	
					plv2=plvi->next;
					plv3=plv2->next;
				
					ebuffer[bufferstate++]=plv1->vertexNode->index-1;
					ebuffer[bufferstate++]=plv2->vertexNode->index-1;
					ebuffer[bufferstate++]=plv2->vertexNode->index-1;
					ebuffer[bufferstate++]=plv3->vertexNode->index-1;

					// check if the buffer is full and write and initialize it
					if (bufferstate==Ci_BUFFERE) {
						if(FWrite(tdddfile,&ebuffer,Ci_BUFFERE*sizeof(ULONG),1)!=1) return(RCWRITEDATA);					  
						bufferstate=0;
					}
				
					plvi=plvi->next;
				} while(plv3->next!=NULL);	
					
				ebuffer[bufferstate++]=plv1->vertexNode->index-1;
				ebuffer[bufferstate++]=plv3->vertexNode->index-1;

				// write the rest of the buffer
				if(FWrite(tdddfile,&ebuffer,bufferstate*sizeof(ULONG),1)!=1) return(RCWRITEDATA);					  
				bufferstate=0;
			}
			pln=pln->next;
		} while(pln!=NULL);
  
		if(FWrite(tdddfile,&fac2,sizeof(fac2),1)!=1) return(RCWRITEDATA);	

		// initialize the buffer state
		bufferstate=0;

		// initialize the edge offset
		edgeoffset=0;

  	  	pln=mesh->polygons.firstNode;
		do {								
			ULONG i;
			
			// only if there are 3 or more points in the polygon
			if(pln->numberOfVertices>=3) {
			  	// do this for each edge - 1
				for(i=0;i<((pln->numberOfVertices-3)*2+2);i+=2) {
					fbuffer[bufferstate++]=edgeoffset+i;
					fbuffer[bufferstate++]=edgeoffset+i+1;
					fbuffer[bufferstate++]=edgeoffset+i+2;
					
					// check if the buffer is full and write and initialize it
					if (bufferstate==Ci_BUFFERF) {
						if(FWrite(tdddfile,&fbuffer,Ci_BUFFERF*sizeof(ULONG),1)!=1) return(RCWRITEDATA);					  
						bufferstate=0;
					}
				}
				edgeoffset+=i+1;
			}
			pln=pln->next;
		} while(pln!=NULL);

		// write he rest of the buffer if there is any
		if (bufferstate!=0) {
			if(FWrite(tdddfile,&fbuffer,bufferstate*sizeof(ULONG),1)!=1) return(RCWRITEDATA);					  
			bufferstate=0;
		}
	}
	
	if(FWrite(tdddfile,&colr,sizeof(colr),1)!=1) return(RCWRITEDATA);

	if(FWrite(tdddfile,&refl,sizeof(refl),1)!=1) return(RCWRITEDATA);

	if(FWrite(tdddfile,&tran,sizeof(tran),1)!=1) return(RCWRITEDATA);
	
	if(FWrite(tdddfile,&spc2,sizeof(spc2),1)!=1) return(RCWRITEDATA);
	
	// writing the materials if there are some and faces
	if(mesh->materials.firstNode && fac2.count) {
		if(FWrite(tdddfile,&cls2,sizeof(cls2),1)!=1) return(RCWRITEDATA);		  

		// initialize the buffer state
		bufferstate=0;

		// The diffuse color, per face
		pln=mesh->polygons.firstNode;
		do {
			TOCLColor col=pln->materialNode->diffuseColor;

			// we accept only polygons with 3 or more points !
			if (pln->numberOfVertices>=3) {
				ULONG i;
				
				for(i=0;i<(pln->numberOfVertices-2);i++) {
					bbuffer[bufferstate++]=col.r;
					bbuffer[bufferstate++]=col.g;
					bbuffer[bufferstate++]=col.b;

					// check if the buffer is full and write and initialize it
					if (bufferstate==Ci_BUFFERC) {
						if(FWrite(tdddfile,&bbuffer,Ci_BUFFERC*sizeof(UBYTE),1)!=1) return(RCWRITEDATA);
						bufferstate=0;
					}
				}
			}
						
			pln=pln->next;
		} while(pln!=NULL);

		// if we have an odd count a pad has to be added at the end
		if (cls2.count%2) {
			bbuffer[bufferstate++]=0;
		}


		// write the rest of the buffer if any
		if (bufferstate!=0) {
			if(FWrite(tdddfile,&bbuffer,bufferstate*sizeof(UBYTE),1)!=1) return(RCWRITEDATA);
			bufferstate=0;
		}

		if(FWrite(tdddfile,&tls2,sizeof(tls2),1)!=1) return(RCWRITEDATA);		  

		// initialize the buffer state
		bufferstate=0;

		// The transparency, per face
		pln=mesh->polygons.firstNode;
		do {
			// we accept only polygons with 3 or more points !
			if (pln->numberOfVertices>=3) {
				ULONG i;
				
				for(i=0;i<(pln->numberOfVertices-2);i++) {  
					bbuffer[bufferstate++]=UBYTE(255*mat->transparency);
					bbuffer[bufferstate++]=UBYTE(255*mat->transparency);
					bbuffer[bufferstate++]=UBYTE(255*mat->transparency);

					// check if the buffer is full and write and initialize it
					if (bufferstate==Ci_BUFFERC) {
						if(FWrite(tdddfile,&bbuffer,Ci_BUFFERC*sizeof(UBYTE),1)!=1) return(RCWRITEDATA);
						bufferstate=0;
					}
				}
			}
			
			pln=pln->next;
		} while(pln!=NULL);

		// if we have an odd count a pad has to be added at the end
		if (tls2.count%2) {
			bbuffer[bufferstate++]=0;
		}
		
		// write the rest of the buffer if any
		if (bufferstate!=0) {
			if(FWrite(tdddfile,&bbuffer,bufferstate*sizeof(UBYTE),1)!=1) return(RCWRITEDATA);
			bufferstate=0;
		}
	}

	if(FWrite(tdddfile,&tobj,sizeof(tobj),1)!=1) return(RCWRITEDATA);
  
	return(RCNOERROR);
}

/************************* End of file ******************************/
