/*
**      $VER: reflections.c 1.00 (27.03.1999)
**
**      Creation date : 02.01.1999
**
**      Description       :
**         Standart saver module for meshwriter.library.
**         Saves the mesh as Reflections file.
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
#define Ci_BUFFERS 100	// constant buffer size

/*********************** Type definitions ***************************/

/*
** Private type definitions
*/
typedef struct {
	FLOAT x,y,z;
} REFVector;

typedef struct {
	ULONG p,q,r;
} REFTriangle;

typedef struct {
	UBYTE name[4];
	ULONG size;
} REFChunk;

typedef struct {
	REFChunk chunk;
	UWORD version,revision;
	ULONG nobjects,chksumpt,chksumobj;
} REFInfoChunk;

typedef struct {
	REFChunk chunk;
	UWORD len;
} REFRobjChunk;

typedef struct {
	REFChunk chunk;
	REFVector ursprung,x,y,z;
	FLOAT size;
} REFKsysChunk;

typedef struct {
	REFChunk chunk;
	ULONG npoints;
} REFPktmChunk;

typedef struct {
	REFChunk chunk;
	ULONG dx,dy;
} REFRpicChunk;

/********************** Private functions ***************************/

/********************** Public functions ****************************/

/********************************************************************\
*                                                                    *
* Name         : write3REF4                                          *
*                                                                    *
* Description  : Writes a standart reflections 4.X binary file.      *
*                Revision 9 dated : 01.09.1996                       *
*                                                                    *
* Arguments    : reffile  IN : An already opened file stream.        *
*                mesh     IN : Pointer to the mesh.                  *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      : No default material.                                *
*                                                                    *
\********************************************************************/
ULONG write3REF4(BPTR reffile, TOCLMesh *mesh) {
	REFChunk			form,dre2,rge1,gma1,sur1;
	REFInfoChunk		info;
	REFRobjChunk		robj;
	REFKsysChunk		ksys;
	REFPktmChunk		pktm;
	REFRpicChunk		rpic;
	
	TOCLPolygonNode			*pln=NULL;
	TOCLVertexNode				*ver=NULL;
	TOCLPolygonsVerticesNode	*plvi=NULL,*plv1=NULL,*plv2=NULL,*plv3=NULL;
	TOCLMaterialNode			*mat=NULL;	

	ULONG				ndrei,nmatbodies,nmattriangles,smaterialnames;
	REFVector			vbuffer[Ci_BUFFERS];	// Ci_BUFFERS * sizeof(REFVector)		vector buffer
	REFTriangle		tbuffer[Ci_BUFFERS];	// Ci_BUFFERS * sizeof(REFTriangle)	triangle buffer
	ULONG				lbuffer[Ci_BUFFERS];	// Ci_BUFFERS * sizeof(ULONG)			ulong buffer, for material triangles
	UBYTE				bbuffer[Ci_BUFFERS];	// Ci_BUFFERS * sizeof(UBYTE)			ubyte buffer, for triangle flags
	ULONG				bufferstate;
	ULONG 				i,l;
	// constant glanzkurve including count
	UBYTE glanz[]= {
		0x00,0x00,0x00,0x0D,
		0x3F,0x80,0x00,0x00,
		0x3F,0x73,0x33,0x33,
		0x3F,0x66,0x66,0x66,
		0x3F,0x4C,0xCC,0xCD,
		0x3F,0x19,0x99,0x9A,
		0x3E,0x99,0x99,0x9A,
		0x00,0x00,0x00,0x00,
		0x00,0x00,0x00,0x00,
		0x00,0x00,0x00,0x00,
		0x00,0x00,0x00,0x00,
		0x00,0x00,0x00,0x00,
		0x00,0x00,0x00,0x00,
		0x00,0x00,0x00,0x00
	};

	
	/*
	** Initializing all chunks and theyr sizes and static contents
	*/
	setUBYTEArray(ksys.chunk.name,"KSYS",4);
	ksys.chunk.size=52;				// fixed size
	ksys.ursprung.x=0;					// fixed origin to {0,0,0}
	ksys.ursprung.y=0;
	ksys.ursprung.z=0;
	ksys.x.x=1,ksys.x.y=0,ksys.x.z=0;	// fixed x-unitvector
	ksys.y.x=0,ksys.y.y=1,ksys.y.z=0;	// fixed y-unitvector
	ksys.z.x=0,ksys.z.y=0,ksys.z.z=1;	// fixed z-unitvector
	ksys.size=1;							// fixed to 1, scale factor

	setUBYTEArray(pktm.chunk.name,"PKTM",4);
	pktm.chunk.size=sizeof(pktm.chunk.size) + mesh->vertices.numberOfVertices * sizeof(REFVector);
	pktm.npoints=mesh->vertices.numberOfVertices;

	// this chunk will be used twice, for the object and his materials at the end
	setUBYTEArray(robj.chunk.name,"ROBJ",4);
	robj.len=stringlen(mesh->name);
	// size = 2 for the len field and the len value itselfs
	robj.chunk.size=2+robj.len;

	setUBYTEArray(rge1.name,"RGE1",4);
	// size = sizes of all chunk above and theyr size themselves = 8 for each one
	// and 2 * 4 base material count and father object and 4*number of materials
	rge1.size=ksys.chunk.size+pktm.chunk.size+robj.chunk.size+ 3*8 + 2*4 + 4*mesh->materials.numberOfMaterials;	

	// number of triangles = sum of each polygon (number of vertices - 2)
	// number of material bodies = sum of each polygon which has a color
	// number of material triangles = sum of each polygon with material (number of vertices - 2)
	ndrei=0,nmatbodies=0,nmattriangles=0;
  	if(mesh->polygons.firstNode!=NULL) {             	
		pln=mesh->polygons.firstNode;
		do {
			// we accept only polygons with 3 or more points !
			if (pln->numberOfVertices>=3) {
				ndrei+=pln->numberOfVertices-2;
				if (pln->materialNode) {
					nmatbodies++;
					nmattriangles+=pln->numberOfVertices-2;
				}
			}
			pln=pln->next;
		} while (pln!=NULL);
	} 

	// the size of the material names = for each material (stringlen(name))
	smaterialnames=0;
	if(mesh->materials.firstNode!=NULL) {
		mat=mesh->materials.firstNode;
		do {
			smaterialnames+=stringlen(mat->name);
			
			mat=mat->next;
		} while(mat!=NULL);
	}

	setUBYTEArray(dre2.name,"DRE2",4);
	// size = size of rge1 and its size itself = 8 and rest of this chunk
	// triangles,triangle type,bodies and material bodies
	dre2.size=rge1.size + 8;
	// triangle count size, number of * sizeof(REFTrianlge) and number of for the type flags as UBYTEs
	dre2.size+=4 + ndrei*sizeof(REFTriangle) + ndrei;
	// no bodies, but theyr ULONG size counts too
	dre2.size+=4;
	// size of the matbody count and nmathbodies * 12 and nmattriangles * 4 * 2
	dre2.size+=4 + nmatbodies * 12 + nmattriangles * 4 * 2;
	
	setUBYTEArray(info.chunk.name,"INFO",4);
	info.chunk.size=16;	// fixed size
	info.version=1;		// fixed to 1
	info.revision=2;		// fixed to 2
	// one object and number of materials
	info.nobjects=1+mesh->materials.numberOfMaterials;
	info.chksumpt=0;		// fixed to 0, for future use
	info.chksumobj=0;		// fixed to 0, for future use
	
	setUBYTEArray(form.name,"FORM",4);
	// size = size of info chunk its size = 8 and 4 for REFL and the dre2 chunk size and its size
	// and the size of the materialnames and the number of materials * (sizeof(glanz)+30+28) (gma1 + sur1 + rpic size)
	form.size=info.chunk.size + 12 + dre2.size + 8;
	form.size+=smaterialnames + mesh->materials.numberOfMaterials*(sizeof(glanz)+30+28+16);

	setUBYTEArray(gma1.name,"GMA1",4);

	setUBYTEArray(rpic.chunk.name,"RPIC",4);
	rpic.chunk.size=8;			// fixed size
	rpic.dx=0,rpic.dy=0;		// no rgb preview

	setUBYTEArray(sur1.name,"SUR1",4);

	/*
	** Writing the chunks and theyr dynamic content
	*/
	if(FWrite(reffile,&form,sizeof(form),1)!=1) return(RCWRITEDATA);

	if(FWrite(reffile,"REFL",1,4)!=4) return(RCWRITEDATA);
	
	if(FWrite(reffile,&info,sizeof(info),1)!=1) return(RCWRITEDATA);

	if(FWrite(reffile,&dre2,sizeof(dre2),1)!=1) return(RCWRITEDATA);
	
	if(FWrite(reffile,&rge1,sizeof(rge1),1)!=1) return(RCWRITEDATA);
	
	if(FWrite(reffile,&robj,sizeof(robj),1)!=1) return(RCWRITEDATA);
	if(robj.len) if(FWrite(reffile,mesh->name,1,robj.len)!=robj.len) return(RCWRITEDATA);

	if(FWrite(reffile,&ksys,sizeof(ksys),1)!=1) return(RCWRITEDATA);

	if(FWrite(reffile,&pktm,sizeof(pktm),1)!=1) return(RCWRITEDATA);
	
	// initialize the buffer state
	bufferstate=0;

	// write the points
	// this is a futil test but anyway
	if(mesh->vertices.firstNode!=NULL) {
		ver=mesh->vertices.firstNode;
		do {
			TOCLVertex v=ver->vertex;

			vbuffer[bufferstate].x=v.x;
			vbuffer[bufferstate].y=v.y;
			vbuffer[bufferstate].z=v.z;

			// increment the bufferstate and 
			// check if the buffer is full and write and initialize it
			if (++bufferstate==Ci_BUFFERS) {
				if(FWrite(reffile,&vbuffer,Ci_BUFFERS*sizeof(REFVector),1)!=1) return(RCWRITEDATA);
				bufferstate=0;
			}
				
			ver=ver->next;
		} while(ver!=NULL);
		
		// write the rest of the buffer if there is any
		if (bufferstate!=0) {
			if(FWrite(reffile,&vbuffer,bufferstate*sizeof(REFVector),1)!=1) return(RCWRITEDATA);
			bufferstate=0;
		}			
	}

	// number of materials and theyr indexes
	l=mesh->materials.numberOfMaterials;
	if(FWrite(reffile,&l,sizeof(l),1)!=1) return(RCWRITEDATA);

	for(l=1;l<=mesh->materials.numberOfMaterials;l++) {
		if(FWrite(reffile,&l,sizeof(l),1)!=1) return(RCWRITEDATA);
	}
	
	// no father
	l=-1;
	if(FWrite(reffile,&l,sizeof(l),1)!=1) return(RCWRITEDATA);
	
	// triangles
	if(FWrite(reffile,&ndrei,sizeof(ndrei),1)!=1) return(RCWRITEDATA);
	// only if there are any triangles, write them and theyr type flag
	if(ndrei) {

		// initialize the buffer state
		bufferstate=0;

		// first the triangles
  	  	pln=mesh->polygons.firstNode;
		do {								
			// only if there are 3 or more points in the polygon
			if(pln->numberOfVertices>=3) {
				plv1=pln->firstNode;
			
				plvi=plv1;
				do {	
					plv2=plvi->next;
					plv3=plv2->next;
				
					tbuffer[bufferstate].p=plv1->vertexNode->index-1;
					tbuffer[bufferstate].q=plv2->vertexNode->index-1;
					tbuffer[bufferstate].r=plv3->vertexNode->index-1;

					// check if the buffer is full and write and initialize it
					if (++bufferstate==Ci_BUFFERS) {
						if(FWrite(reffile,&tbuffer,Ci_BUFFERS*sizeof(REFTriangle),1)!=1) return(RCWRITEDATA);
						bufferstate=0;
					}
				
					plvi=plvi->next;
				} while(plv3->next!=NULL);	
					
				// write the rest of the buffer if there is any
				if (bufferstate!=0) {
					if(FWrite(reffile,&tbuffer,bufferstate*sizeof(REFTriangle),1)!=1) return(RCWRITEDATA);
					bufferstate=0;
				}
			}
			pln=pln->next;
		} while(pln!=NULL);
		
		// now the flags
		for(i=0;i<ndrei;i++) {
			bbuffer[bufferstate++]=0;	// fixed to a flat shaded triangle
			
			// check if the buffer is full and write and initialize it
			if (bufferstate==Ci_BUFFERS) {
				if(FWrite(reffile,&bbuffer,Ci_BUFFERS,1)!=1) return(RCWRITEDATA);
				bufferstate=0;
			}
		}
		// write the rest of the buffer if there is any
		if (bufferstate!=0) {
			if(FWrite(reffile,&bbuffer,bufferstate,1)!=1) return(RCWRITEDATA);
			bufferstate=0;
		}
	}

	// we dont use bodies
	l=0;
	if(FWrite(reffile,&l,sizeof(l),1)!=1) return(RCWRITEDATA);

	// material bodies
	if(FWrite(reffile,&nmatbodies,sizeof(nmatbodies),1)!=1) return(RCWRITEDATA);
	// if there are any material bodies, write them down
	if(nmatbodies) {
		ULONG tindex;

		// initialize the buffer state
		bufferstate=0;
		
		// initilaize the triangle index, first = 0
		tindex=0;

	  	if(mesh->polygons.firstNode!=NULL) {
			pln=mesh->polygons.firstNode;
			do {
				// we accept only polygons with 3 or more points and which have a material assigned !
				if (pln->numberOfVertices>=3 && pln->materialNode) {
					// write the number of triangles in this list = 2 * number of triangles (both sides)
					l=(pln->numberOfVertices-2)*2;
					if(FWrite(reffile,&l,sizeof(l),1)!=1) return(RCWRITEDATA);
				  
				  	// write the triangle / material list for this polygon
					for(i=0;i<(pln->numberOfVertices-2);i++) {
					  
						// each triangle has to be written twice, for both sides
						lbuffer[bufferstate++]=tindex;
						lbuffer[bufferstate++]=tindex++;

						// check if the buffer is full and write and initialize it
						if (bufferstate==Ci_BUFFERS) {
							if(FWrite(reffile,&lbuffer,Ci_BUFFERS*sizeof(ULONG),1)!=1) return(RCWRITEDATA);
							bufferstate=0;
						}						
					}

					// write the rest of the buffer if there is any
					if (bufferstate!=0) {
						if(FWrite(reffile,&lbuffer,bufferstate*sizeof(ULONG),1)!=1) return(RCWRITEDATA);
						bufferstate=0;
					}

					l=0; // fix as it is a material
					if(FWrite(reffile,&l,sizeof(l),1)!=1) return(RCWRITEDATA);
					
					// material index = material index in this file !
					l=pln->materialNode->index;
					if(FWrite(reffile,&l,sizeof(l),1)!=1) return(RCWRITEDATA);
				}
				pln=pln->next;
			} while (pln!=NULL);
		} 
	}

	// writing down all materials
	if(mesh->materials.firstNode!=NULL) {
		REFVector	color;
		FLOAT f;

		/* The diffuse color */
		mat=mesh->materials.firstNode;
		do {
			TOCLColor col=mat->diffuseColor;
			color.x=col.r,color.y=col.g,color.z=col.b;
			color.x/=255,color.y/=255,color.z/=255;

			robj.len=stringlen(mat->name);
			// size = 2 for the len field and the len value itselfs
			robj.chunk.size=2+robj.len;

			// size = size of robj and its size self and the size of the vector
			// and the rpic size and its size
			gma1.size=robj.chunk.size+8+sizeof(REFVector)+rpic.chunk.size+8;

			// size = size of gma1 and its size and 5 * 4 (floats) and sizeof(glanz)
			sur1.size=gma1.size + 8 + 5*4 + sizeof(glanz);

			if(FWrite(reffile,&sur1,sizeof(sur1),1)!=1) return(RCWRITEDATA);

			if(FWrite(reffile,&gma1,sizeof(gma1),1)!=1) return(RCWRITEDATA);
			
			if(FWrite(reffile,&robj,sizeof(robj),1)!=1) return(RCWRITEDATA);
			if(robj.len) if(FWrite(reffile,mat->name,1,robj.len)!=robj.len) return(RCWRITEDATA);
			
			if(FWrite(reffile,&color,sizeof(color),1)!=1) return(RCWRITEDATA);
			
			if(FWrite(reffile,&rpic,sizeof(rpic),1)!=1) return(RCWRITEDATA);
			
			// diffuse reflection
			f=1-mat->transparency-mat->shininess;
			if(FWrite(reffile,&f,sizeof(f),1)!=1) return(RCWRITEDATA);

			// reflections
			f=0;
			if(FWrite(reffile,&f,sizeof(f),1)!=1) return(RCWRITEDATA);

			// transparency
			f=mat->transparency;
			if(FWrite(reffile,&f,sizeof(f),1)!=1) return(RCWRITEDATA);

			// shininess
			f=mat->shininess;
			if(FWrite(reffile,&f,sizeof(f),1)!=1) return(RCWRITEDATA);

			// index of refraction
			f=0;
			if(FWrite(reffile,&f,sizeof(f),1)!=1) return(RCWRITEDATA);

			// glanzlichtkurve including its size
			if(FWrite(reffile,&glanz,sizeof(glanz),1)!=1) return(RCWRITEDATA);

			mat=mat->next;
		} while(mat!=NULL);
	}

	return(RCNOERROR);
}

/************************* End of file ******************************/
