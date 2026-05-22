/*
**      $VER: meshwriter.c 0.02 (28.3.1999)
**
**      Creation date     : 18.10.1998
**
**      Description       :
**         Mesh writer functions module
**
**
**      Written by Stephan Bielmann
**
*/

#define __USE_SYSBASE        // perhaps only recognized by SAS/C

/*************************** Includes *******************************/

/*
** ANSI standart includes
*/
#include <string.h>
#include <math.h>

/*
** Amiga includes
*/
#include <exec/types.h>
#include <exec/memory.h>
#include <dos/stdio.h>

#include <clib/dos_protos.h>
#include <clib/alib_stdio_protos.h>

#include <pragma/exec_lib.h>

/*
** Project includes
*/
#include <meshwriter_private.h>

#include "raw.h"
#include "vrml1.h"
#include "dxf.h"
#include "pov3.h"
#include "imagine.h"
#include "reflections.h"
#include "lightwave.h"
#include "geo.h"
//#include "real.h"
//#include "postscript.h"

#include "compiler.h"

/********************** Private constants ***************************/

/*
** The constant supported file format arrays
*/
static ULONG  c3dFFIDs [] = {
	T3DFDXF,
	T3DFTDDD,
	T3DFTDDDH,
	T3DFLWOB,
	T3DFPOV3,
	T3DFRAWA,
	T3DFRAWB,
//	T3DFREAL,
	T3DFREF4,
	T3DFGEOA,
	T3DFVRML1,
	0
};

static STRPTR c3dFFNames [] = {
	"AutoCAD DXF",
	"Imagine original",
	"Imagine huge",
	"Lightwave",
	"POVRay 3.X",
	"RAW ASCII",
	"RAW binary",
//	"Real 3D",
	"Reflections 4.X",
	"Videoscape ASCII",
	"VRML 1",
	NULL
};

static STRPTR c3dFFExtensions [] = {
	"dxf",
	"iob",
	"iob",
	"lwob",
	"pov",
	"raw",
	"raw",
//	"real",
	"r4",
	"geo",
	"wrl",
	NULL
};

static ULONG  c2dFFIDs   [] = {
//	T2DFEPS,
//	T2DFPSP,
//	T2DFPSL,
	0
};

static STRPTR c2dFFNames [] = {
//	"Encapsulated PostScript",
//	"PostScript portrait",
//	"PostScript landscape",
	NULL
};

static STRPTR c2dFFExtensions [] = {
//	"eps",
//	"ps",
//	"ps",
	NULL
};


/*
** The constant supported drawing mode arrays
*/
static ULONG  cDMIDs   [] = {
//	TDMPOINTS,
//	TDMGRIDBW,
//	TDMGRIDGR,
//	TDMGRIDCL,
//	TDMSURFBW,
//	TDMSURFGR,
//	TDMSURFCL,
	0
};

static STRPTR  cDMNames   [] = {
//	"Points, black and white",
//	"Grid, black and white",
//	"Grid, gray scales",
//	"Grid, colors",
//	"Surface, black and white",
//	"Surface, gray scales",
//	"Surface, colors",
	0
};

/*
** Definition of PI
*/
#define PI 3.14159265359

/********************** Private functions ***************************/

/********************************************************************\
*                                                                    *
* Name         : hash                                                *
*                                                                    *
* Description  : Calculates the hashcode of a vertex.                *
*                                                                    *
* Arguments    : vertex IN : The vertex to hash.                     *
*                                                                    *
* Return Value : hashcode                                            *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static ULONG hash(TOCLVertex vertex) {
	DOUBLE  hx = vertex.x*12.3;
	DOUBLE  hy = vertex.y*23.4;
	DOUBLE  hz = vertex.z*34.5;

	return (((ULONG) (pow(hx*hx + hy*hy + hz*hz,0.5) * 9.87)) % HASHSIZE);
}

/********************************************************************\
*                                                                    *
* Name         : addVertex                                           *
*                                                                    *
* Description  : Adds the vertex to the mesh, if not already in its  *
*                internal list. And returns the pointer to it.       *
*                The vertex will be transformed according the mehs   *
*                its CTM.
*                                                                    *
* Arguments    : mesh   IN : Pointer to the mesh.                    *
*                vertex IN : The vertex to add.                      *
*                                                                    *
* Return Value : Pointer to the "new" vertex or NULL if no more      *
*                memory is available.                                *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static TOCLVertexNode *addVertex(TOCLMesh *mesh,
                                 TOCLVertex vertex) {

	ULONG	hashcode		=hash(vertex);
	TOCLHashsVerticesNode	*hlvindex=NULL;
	TOCLVertexNode			*ver=NULL;
	TOCLCTM				ctm;
	TOCLVertex 			rvertex;

	ctm=mesh->ctm;

	/*
	** Transforming the the vertex according the CTM
	*/
	// Scaling
	vertex.x*=ctm.sx,vertex.y*=ctm.sy,vertex.z*=ctm.sz;

	//Rotation and translation
	rvertex.x=ctm.m[0][0]*vertex.x+ctm.m[1][0]*vertex.y+ctm.m[2][0]*vertex.z+ctm.m[3][0]; 
	rvertex.y=ctm.m[0][1]*vertex.x+ctm.m[1][1]*vertex.y+ctm.m[2][1]*vertex.z+ctm.m[3][1]; 
	rvertex.z=ctm.m[0][2]*vertex.x+ctm.m[1][2]*vertex.y+ctm.m[2][2]*vertex.z+ctm.m[3][2]; 

	/*
	** Check if the vertex is already in our internal list
	*/
	hlvindex=mesh->hashTable[hashcode];
	while(hlvindex!=NULL)
	{
	  	ver=hlvindex->vertexNode;

		if(rvertex.x==ver->vertex.x &&
		   rvertex.y==ver->vertex.y &&
		   rvertex.z==ver->vertex.z ) {
			/*
			** Yes, return its pointer
			*/
			return (ver);
		}
		hlvindex=hlvindex->next;
	}
	
	/*
	** No it was not. Add a new one to the list and hash and return it
	*/
	ver = AllocPooled(mesh->vertexpool,sizeof(TOCLVertexNode));
	if (ver==NULL) return(NULL);
	
	/* The index begins at 1 ! */
	mesh->vertices.numberOfVertices++;			/* increment the list counter */
	ver->index=mesh->vertices.numberOfVertices;	/* Set the index */
	ver->vertex = rvertex;
	ver->next=NULL;

	if(mesh->vertices.firstNode!=NULL) {   /* Check if this is the first vertex to insert or not */
		mesh->vertices.lastNode->next=ver;
		mesh->vertices.lastNode=ver;
	}
	else {
		mesh->vertices.lastNode=ver;
		mesh->vertices.firstNode=ver;
	}

	/*
	** Recalculate the bounding box
	*/
	if(vertex.x<mesh->bBox.left)   mesh->bBox.left=rvertex.x;
	if(vertex.x>mesh->bBox.right)  mesh->bBox.right=rvertex.x;
	if(vertex.y<mesh->bBox.rear)   mesh->bBox.rear=rvertex.y;
	if(vertex.y>mesh->bBox.front)  mesh->bBox.front=rvertex.y;
	if(vertex.z<mesh->bBox.bottom) mesh->bBox.bottom=rvertex.z;
	if(vertex.z>mesh->bBox.top)    mesh->bBox.top=rvertex.z;
	
	/*
	** Add the vertex to the hash table
	*/
	hlvindex = AllocMem(sizeof(TOCLHashsVerticesNode),MEMF_FAST);
	if (hlvindex==NULL) {
		FreePooled(mesh->vertexpool,ver,sizeof(TOCLVertexNode));
		return(NULL);
	}
	
	hlvindex->vertexNode=ver;
	hlvindex->next=mesh->hashTable[hashcode];
	mesh->hashTable[hashcode]=hlvindex;
	
	return(ver);
}

/********************************************************************\
*                                                                    *
* Name         : getVertex                                           *
*                                                                    *
* Description  : Search a vertex in the list with its index.         *
*                                                                    *
* Arguments    : mesh   IN : Pointer to the mesh.                    *
*                index  IN : The vertex its index.                   *
*                                                                    *
* Return Value : Pointer to the vertex or NULL if not found.         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static TOCLVertexNode *getVertex(TOCLMesh *mesh,
								ULONG index) {

	TOCLVertexNode			*ver=NULL;

	if(index==0) return(NULL);

	ver=mesh->vertices.firstNode;
	while(ver!=NULL && ver->index!=index) {
		ver=ver->next;
	}

	return(ver);
}

/********************************************************************\
*                                                                    *
* Name         : getVertexIndex                                      *
*                                                                    *
* Description  : Search the index of a vertex in the list with its   *
*                coordinates.                                        *
*                                                                    *
* Arguments    : mesh   IN : Pointer to the mesh.                    *
*                vertex IN : The vertex to search for.               *
*                                                                    *
* Return Value : Index to the vertex or 0 if not found.              *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static ULONG getVertexIndex(TOCLMesh *mesh,
							TOCLVertex vertex) {

	ULONG	hashcode		=hash(vertex);
	TOCLHashsVerticesNode	*hlvindex=NULL;
	TOCLVertexNode			*ver=NULL;

	/*
	** Check if the vertex is already in our internal list
	*/
	hlvindex=mesh->hashTable[hashcode];
	while(hlvindex!=NULL)
	{
	  	ver=hlvindex->vertexNode;

		if(vertex.x==ver->vertex.x &&
		   vertex.y==ver->vertex.y &&
		   vertex.z==ver->vertex.z ) {
			/*
			** Yes, return its index
			*/
			return (ver->index);
		}
		hlvindex=hlvindex->next;
	}
	
	/*
	** No it was not.
	*/
	return(0);
}

/********************************************************************\
*                                                                    *
* Name         : getMaterialNode                                     *
*                                                                    *
* Description  : Search the material its node with its index, in     *
*                the given mesh. If the index=0 or not valid, NULL   *
*                will be returned.                                   *
*                                                                    *
* Arguments    : mesh          IN : Pointer to the mesh.             *
*                materialindex IN : Material index.                  *
*                                                                    *
* Return Value : Pointer to the material or NULL if not found.       *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static TOCLMaterialNode *getMaterialNode(TOCLMesh *mesh, ULONG materialindex) {
	TOCLMaterialNode	*mindex=NULL;
	
	if(materialindex==0 || materialindex>mesh->materials.numberOfMaterials) return(NULL);
	
	/*
	** Search the material
	*/
	mindex=mesh->materials.firstNode;
	while(mindex!=NULL) {
		if(mindex->index==materialindex) return(mindex);
		
		mindex=mindex->next;
	}

	/*
	** Not found
	*/	
	return(NULL);
}

/********************************************************************\
*                                                                    *
* Name         : setCameraLight                                      *
*                                                                    *
* Description  : Sets the default position of the camera and the     *
*                light and the camera its view point and the color   *
*                of the light source.                                *
*                                                                    *
* Arguments    : mesh      IN/OUT : Pointer to the mesh.             *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static VOID setCameraLight(TOCLMesh *mesh) {
	TOCLVertex ver1;
		
	if (mesh==NULL) return;

	/* camera its look at position */
	mesh->camera.lookat.x = (mesh->bBox.left + mesh->bBox.right) / 2;
	mesh->camera.lookat.y = (mesh->bBox.front + mesh->bBox.rear) / 2;
	mesh->camera.lookat.z = (mesh->bBox.top + mesh->bBox.bottom) / 2;
	
	/* direction vector */
	ver1.x = mesh->bBox.right - mesh->camera.lookat.x;
	ver1.y = mesh->bBox.front - mesh->camera.lookat.y;
	ver1.z = mesh->bBox.top - mesh->camera.lookat.z;
	
	ver1.x*=2.5;
	ver1.y*=2.5;	
	ver1.z*=2.5;
	
	/* camera its position */
	mesh->camera.position.x = ver1.x + mesh->camera.lookat.x;
	mesh->camera.position.y = ver1.y + mesh->camera.lookat.y;
	mesh->camera.position.z = ver1.z + mesh->camera.lookat.z;

	/* light source its position */
	mesh->light.position.x = ver1.x + mesh->camera.lookat.x;
	mesh->light.position.y = ver1.x + mesh->camera.lookat.x;
	mesh->light.position.z = ver1.x + mesh->camera.lookat.x;
	
	/* light source its color */
	mesh->light.color.r=255;
	mesh->light.color.g=255;
	mesh->light.color.b=255;
}

/********************************************************************\
*                                                                    *
* Name         : mul33Matrix                                         *
*                                                                    *
* Description  : Multiplicates two 3x3 matrix structures.            *
*                                                                    *
* Arguments    : m1  IN/OUT : The first matrix, contains the result  *
*                m2  IN     : The second matrix.                     *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
void mulMatrix (double m1[3][3], double m2[3][3]) {
	double m[3][3];
	int x,y,yy;

	for(x=0;x<3;x++) {
		for(y=0;y<3;y++) {
			m[x][y]=0;
		}
	}

	for(x=0;x<3;x++) {
		for(y=0;y<3;y++) {
			for(yy=0;yy<3;yy++) {
				m[x][y]+=m1[yy][y]*m2[x][yy];
			}
		}
	}

	m1[0][0]=m[0][0];
	m1[1][0]=m[1][0];
	m1[2][0]=m[2][0];
	m1[0][1]=m[0][1];
	m1[1][1]=m[1][1];
	m1[2][1]=m[2][1];
	m1[0][2]=m[0][2];
	m1[1][2]=m[1][2];
	m1[2][2]=m[2][2];
}

/********************** Public functions ****************************/

/****** meshwriter.library/MWLMeshNew ******************************************
* 
*   NAME	
* 	MWLMeshNew -- Creates a new mesh
* 
*   SYNOPSIS
*	meshhandle = MWLMeshNew( )
*	          
*
*	ULONG MWLMeshNew
*	     ( );
*
*   FUNCTION
*	Allocates the memory for a new mesh, initializes all its contents and
*	returns a handle to the new mesh. The mesh has to be deleted after usage
*	with MWLMeshDelete().   
*
*   INPUTS
* 
*   RESULT
* 	meshhandle - A handle to the new mesh, or 0 in error case, which means
*	             that there is not enough memory available.
* 
*   EXAMPLE
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshDelete()
*
*****************************************************************************
*
*/
ULONG __saveds ASM MWLMeshNew() {
	TOCLMesh 	*mesh=NULL;
	LONG		i;
	UBYTE		buffer[10];

	mesh = AllocMem(sizeof(TOCLMesh),MEMF_FAST);
	if (mesh==NULL) return(0);

	// create a memory pool for the vertices of this this header
	// ground size of a pool is to get 100 vertices
	mesh->vertexpool=CreatePool(MEMF_FAST,100*sizeof(TOCLVertexNode),100*sizeof(TOCLVertexNode));
	if(mesh->vertexpool==NULL) {
		FreeMem(mesh,sizeof(TOCLMesh));
		return(0);
	}

	// create a memory pool for the polygon nodes of this this header
	// ground size of a pool is to get 100 polygons
	mesh->polygonpool=CreatePool(MEMF_FAST,100*sizeof(TOCLPolygonNode),100*sizeof(TOCLPolygonNode));
	if(mesh->polygonpool==NULL) {
		DeletePool(mesh->vertexpool);
		FreeMem(mesh,sizeof(TOCLMesh));
		return(0);
	}

	// create a memory pool for the polygon vertex nodes of this this header
	// ground size of a pool is to get 100 polygon vertices
	mesh->polygonverticespool=CreatePool(MEMF_FAST,100*sizeof(TOCLPolygonsVerticesNode),100*sizeof(TOCLPolygonsVerticesNode));
	if(mesh->polygonverticespool==NULL) {
		DeletePool(mesh->polygonpool);
		DeletePool(mesh->vertexpool);
		FreeMem(mesh,sizeof(TOCLMesh));
		return(0);
	}

	mesh->name=NULL;
	strcpy(buffer,"NONAME");
	mesh->name = AllocVec(strlen(buffer)+1,MEMF_FAST);
	if (mesh->name==NULL) {
		DeletePool(mesh->polygonverticespool);
		DeletePool(mesh->polygonpool);
		DeletePool(mesh->vertexpool);
		FreeMem(mesh,sizeof(TOCLMesh));
		return(0);
	}
	strcpy(mesh->name,buffer);
	
	mesh->copyright=NULL;

	mesh->bBox.left=0.0;
	mesh->bBox.right=0.0;
	mesh->bBox.front=0.0;
	mesh->bBox.rear=0.0;
	mesh->bBox.top=0.0;
	mesh->bBox.bottom=0.0;
	
	mesh->camera.position.x=0.0;
	mesh->camera.position.y=0.0;
	mesh->camera.position.z=0.0;
	mesh->camera.lookat.x=0.0;
	mesh->camera.lookat.y=0.0;
	mesh->camera.lookat.z=0.0;
	
	mesh->light.position.x=0.0;
	mesh->light.position.y=0.0;
	mesh->light.position.z=0.0;
	mesh->light.color.r=255;
	mesh->light.color.g=255;
	mesh->light.color.b=255;
        
	mesh->vertices.numberOfVertices=0;
	mesh->vertices.firstNode=NULL;
	mesh->vertices.lastNode=NULL;
        
	mesh->polygons.numberOfPolygons=0;
	mesh->polygons.firstNode=NULL;
	mesh->polygons.lastNode=NULL;
	
	mesh->materials.numberOfMaterials=0;
	mesh->materials.firstNode=NULL;
	mesh->materials.lastNode=NULL;

	mesh->ctm.sx=1,mesh->ctm.sy=1,mesh->ctm.sz=1;
	mesh->ctm.rx=0,mesh->ctm.ry=0,mesh->ctm.rz=0;
	mesh->ctm.m[0][0]=1,mesh->ctm.m[1][0]=0,mesh->ctm.m[2][0]=0,mesh->ctm.m[3][0]=0;
	mesh->ctm.m[0][1]=0,mesh->ctm.m[1][1]=1,mesh->ctm.m[2][1]=0,mesh->ctm.m[3][1]=0;
	mesh->ctm.m[0][2]=0,mesh->ctm.m[1][2]=0,mesh->ctm.m[2][2]=1,mesh->ctm.m[3][2]=0;
	mesh->ctm.m[0][3]=0,mesh->ctm.m[1][3]=0,mesh->ctm.m[2][3]=0,mesh->ctm.m[3][3]=1;
	
	for(i=0;i<HASHSIZE;i++) mesh->hashTable[i]=NULL;
	
	return(ULONG)mesh;
}

/****** meshwriter.library/MWLMeshDelete ******************************************
* 
*   NAME	
* 	MWLMeshDelete -- Delete a mesh which was created whith MWLMeshNew() before.
* 
*   SYNOPSIS
*	error = MWLMeshDelete( meshhandle )
*	                       D1
*
*	ULONG MWLMeshDelete
*	     ( ULONG );
*
*   FUNCTION
*	Free the memory occupied by the mesh, and delete the mesh itself.
* 
*   INPUTS
* 	meshhandle    - A valid handle of a mesh.
*	
*   RESULT
* 	error - RCNOERROR if all went well.
*	        RCNOMESH  if the handle is not valid.
*
*   EXAMPLE
* 
*   NOTES
*	Can take some time.
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshNew()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshDelete(register __d1 ULONG meshhandle) {
	TOCLMesh					*mesh=NULL;
	TOCLVertexNode				*ver=NULL, *vindex=NULL;
	TOCLPolygonNode			*pln=NULL, *plnindex=NULL;
	TOCLPolygonsVerticesNode	*plv=NULL, *plvindex=NULL;
	TOCLMaterialNode			*mat=NULL, *mindex=NULL;
	TOCLHashsVerticesNode		*hlv=NULL, *hlvindex=NULL;
	ULONG						i;
        
	mesh=(TOCLMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);

	/*
	** Free the name string
	*/
	FreeVec(mesh->name);

	/*
	** Free the copyright string
	*/ 
	FreeVec(mesh->copyright);

	/*
	** Free the vertices
	*/
	DeletePool(mesh->vertexpool);

	/*
	** Free the polygon vertices
	*/
	DeletePool(mesh->polygonverticespool);

	/*
	** Free the polygons
	*/
	DeletePool(mesh->polygonpool);
	
	/*
	** Free the materials
	*/
	mindex=mesh->materials.firstNode;
	while(mindex!=NULL) {
		mat=mindex;
		mindex=mindex->next;
		
		/*
		** Free the name string
		*/
		FreeVec(mat->name);
		
		FreeMem(mat,sizeof(TOCLMaterialNode));
	}

	/*
	** Free the hashtable entries
	*/
	for(i=0;i<HASHSIZE;i++) {
		hlvindex=mesh->hashTable[i];
		while(hlvindex!=NULL) {
			hlv=hlvindex;
			hlvindex=hlvindex->next;
			FreeMem(hlv,sizeof(TOCLHashsVerticesNode));
		}		
	}

	/*
	** Free the mesh itself
	*/
	FreeMem(mesh,sizeof(TOCLMesh));

	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshNameSet ******************************************
* 
*   NAME	
* 	MWLMeshNameSet -- Set the name of the mesh.
* 
*   SYNOPSIS
*	error = MWLMeshNameSet( meshhandle,name )
*	                        D1         D2
*
*	ULONG MWLMeshNameSet
*	     ( ULONG,STRPTR );
*
*   FUNCTION
*	A copy of the passed string will be made and assigned to the mesh its
*	name string.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	name            - String which contains the name.
*	
*   RESULT
* 	error - RCNOERROR  if all went well.
*	        RCNOMESH   if the handle is not valid.
* 	        RCNOMEMORY if there is not enough memory.
*
*   EXAMPLE
*	error = MWLMeshNameSet(meshhandle,"GreatShape");
*
*   NOTES
*	This function can be called as often as you need, which will
*	replace the old value.
*
*	Not all formats support names, and the written length of the
*	string depends of the format too.
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshNameGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshNameSet(register __d1 ULONG meshhandle,register __d2 STRPTR name ) {
	TOCLMesh *mesh=NULL;
  
	mesh=(TOCLMesh *) meshhandle;
	if (mesh==NULL) return(RCNOMESH);

	/*
	** If the name was already set before, free it
	*/
	if (mesh->name) FreeVec(mesh->name);
	mesh->name=NULL;

	mesh->name=(STRPTR) AllocVec(strlen(name)+1,MEMF_FAST);
	if(mesh->name==NULL) return(RCNOMEMORY);
  
	strcpy(mesh->name,name);
  
	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshNameGet ******************************************
* 
*   NAME	
* 	MWLMeshNameGet -- Get the name of a mesh.
*
*   SYNOPSIS
*	error = MWLMeshNameGet( meshhandle,name )
*	                        D1         D2
*
*	ULONG MWLMeshNameGet
*	     ( ULONG,STRPTR * );
*
*   FUNCTION
*	You will get a pointer to the name of the mesh. This string is READ_ONLY
*	and only valid as long the as mesh exists.
* 
*   INPUTS
* 	meshhandle    - A valid handle of a mesh.
*	name          - Pointer to the name of the mesh.
*	
*   RESULT
* 	error - RCNOERROR if all went well.
*	        RCNOMESH  if the handle is not valid.
* 
*   EXAMPLE
*	error = MWLMeshNameGet(meshhandle,&mystring);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshNameSet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshNameGet(register __d1 ULONG meshhandle, register __d2 STRPTR *name) {
	TOCLMesh *mesh=NULL;
  
	mesh=(TOCLMesh *) meshhandle;
	if (mesh==NULL) return(RCNOMESH);

	(*name)=mesh->name;

	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshCopyrightSet ******************************************
* 
*   NAME	
* 	MWLMeshCopyrightSet -- Set the copyright of the mesh.
* 
*   SYNOPSIS
*	error = MWLMeshCopyrightSet( meshhandle,copyright )
*	                             D1         D2
*
*	ULONG MWLMeshCopyrightSet
*	     ( ULONG,STRPTR );
*
*   FUNCTION
*	A copy of the passed string will be made and assigned to the mesh its
*	copyright string.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	copyright       - String which contains the copyright.
*	
*   RESULT
* 	error - RCNOERROR  if all went well.
*	        RCNOMESH   if the handle is not valid.
* 	        RCNOMEMORY if there is not enough memory.
*
*   EXAMPLE
*	error = MWLMeshCopyrightSet(meshhandle,"This mesh was created with GreatShaper V2.0 for Beethoven");
*
*   NOTES
*	This should be only a single line !
*
*	This function can be called as often as you need, which will replace
*	the old value.
*
*	Not all formats support copyrights, and the written length of the
*	string depends of the format too.
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshCopyrightGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshCopyrightSet(register __d1 ULONG meshhandle,register __d2 STRPTR copyright) {
	TOCLMesh *mesh=NULL;
  
	mesh=(TOCLMesh *) meshhandle;
	if (mesh==NULL) return(RCNOMESH);
	
	/*
	** If the copyright was already set before, free it
	*/
	if (mesh->copyright) FreeVec(mesh->copyright);
	mesh->copyright=NULL;
  
	mesh->copyright=(STRPTR) AllocVec(strlen(copyright)+1,MEMF_FAST);
	if(mesh->copyright==NULL) return(RCNOMEMORY);
  
	strcpy(mesh->copyright,copyright);
  
	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshCopyrightGet ******************************************
* 
*   NAME	
* 	MWLMeshCopyrightGet -- Get the copyright of a mesh.
*
*   SYNOPSIS
*	error = MWLMeshCopyrightGet( meshhandle,copyright )
*	                             D1         D2
*
*	ULONG MWLMeshCopyrightGet
*	     ( ULONG,STRPTR * );
*
*   FUNCTION
*	You will get a pointer to the copyright of the mesh. This string is READ_ONLY
*	and only valid as long as the mesh exists.
* 
*   INPUTS
* 	meshhandle    - A valid handle of a mesh.
*	copyright     - Pointer to the copyright of the mesh.
*	
*   RESULT
* 	error - RCNOERROR if all went well.
*	        RCNOMESH  if the handle is not valid.
* 
*   EXAMPLE
*	error = MWLMeshCopyrightGet(meshhandle,&mystring);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshCopyrightSet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshCopyrightGet(register __d1 ULONG meshhandle, register __d2 STRPTR *copyright) {
	TOCLMesh *mesh=NULL;
  
	mesh=(TOCLMesh *) meshhandle;
	if (mesh==NULL) return(RCNOMESH);
	
	(*copyright)=mesh->copyright;
	
	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshMaterialAdd ******************************************
* 
*   NAME	
* 	MWLMeshMaterialAdd -- Add a new material to the mesh.
*
*   SYNOPSIS
*	error = MWLMeshMaterialAdd( meshhandle,materialhandle )
*	                            D1         D2
*
*	ULONG MWLMeshMaterialAdd
*	     ( ULONG,ULONG * );
*
*   FUNCTION
*	A new material will be created and added to the mesh. You will get a handle to it.
*	All material properties will be set to 0.
* 
*   INPUTS
* 	meshhandle     - A valid handle of a mesh.
*	materialhandle - Pointer to a variable which will contain 
*	                 the handle to the new material.
*	
*   RESULT
* 	error - RCNOERROR  if all went well.
*	        RCNOMESH   if the handle is not valid.
*	        RCNOMEMORY if there is not enough memory. 
* 
*   EXAMPLE
*	error = MWLMeshMaterialAdd(meshhandle,&mylong);
*
*   NOTES
*	A default name will be assigned to the new material.
*	Like MWLMATX, where X is an internal count of the material.
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshMaterialNameSet(),MWLMeshMaterialAmbientColorSet(),
*   MWLMeshMaterialDiffuseColorSet(),MWLMeshMaterialShininessSet()
*	MWLMeshMaterialTransparencySet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshMaterialAdd(register __d1 ULONG meshhandle, register __d2 ULONG *materialhandle) {
	TOCLMesh			*mesh=NULL;
	TOCLMaterialNode	*mat=NULL;
	UBYTE				buffer[100];
	
	mesh=(TOCLMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);

	(*materialhandle)=0;

	mat = AllocMem(sizeof(TOCLMaterialNode),MEMF_FAST);
	if (mat==NULL) return(RCNOMEMORY);

	mat->index=++mesh->materials.numberOfMaterials; /*Index begins at 1 */
   (*materialhandle)=mat->index;

	mat->name=NULL;
	sprintf(buffer,"MWLMAT%ld",mat->index);
	mat->name = AllocVec(strlen(buffer)+1,MEMF_FAST);
	if (mat->name==NULL) {
		FreeMem(mat,sizeof(TOCLMaterialNode));
		return(RCNOMEMORY);
	}
	strcpy(mat->name,buffer);
	
	mat->ambientColor.r=0;
	mat->ambientColor.g=0;
	mat->ambientColor.b=0;
	mat->diffuseColor.r=0;
	mat->diffuseColor.g=0;
	mat->diffuseColor.b=0;
	mat->shininess=0;
	mat->transparency=0;
	mat->next=NULL;

	if(mesh->materials.firstNode!=NULL) {   /* Check if this is the first material to insert or not */
		mesh->materials.lastNode->next=mat;
		mesh->materials.lastNode=mat;
	}
	else {
		mesh->materials.lastNode=mat;
		mesh->materials.firstNode=mat;
	}

	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshMaterialNameSet ******************************************
* 
*   NAME	
* 	MWLMeshMaterialNameSet -- Set the name of the material.
* 
*   SYNOPSIS
*	error = MWLMeshMaterialNameSet( meshhandle,materialhandle,materialname )
*	                                D1         D2             D3
*
*	ULONG MWLMeshMaterialNameSet
*	     ( ULONG,ULONG,STRPTR );
*
*   FUNCTION
*	A copy of the passed string will be made and assigned to the material its
*	name string.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	materialhandle  - A valid handle of a material.
*	materialname    - String which contains the name.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*	        RCNOMATERIAL if the handle is not valid.
* 	        RCNOMEMORY   if there is not enough memory.
*
*   EXAMPLE
*	error = MWLMeshMaterialNameSet(meshhandle,materialhandle,"DeepBlue");
*
*   NOTES
*	This function can be called as often as you need which will
*	replace the old value.
*
*	Not all formats support names, and the written length of the
*	string depends of the format too.
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshMaterialNameGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshMaterialNameSet(register __d1 ULONG meshhandle,
												register __d2 ULONG materialhandle,
												register __d3 STRPTR materialname) {
	TOCLMesh			*mesh=NULL;
	TOCLMaterialNode	*mat=NULL;
  
	mesh=(TOCLMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);

	mat=getMaterialNode(mesh,materialhandle);
	if(mat==NULL) return(RCNOMATERIAL);

	/*
	** If the name was already set before, free it
	*/
	if (mat->name) FreeVec(mat->name);
	mat->name=NULL;
	
	mat->name=(STRPTR) AllocVec(strlen(materialname)+1,MEMF_FAST);
	if(mat->name==NULL) return(RCNOMEMORY);
  
	strcpy(mat->name,materialname);

	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshMaterialNameGet ******************************************
* 
*   NAME	
* 	MWLMeshMaterialNameGet -- Get the name of a material.
*
*   SYNOPSIS
*	error = MWLMeshMaterialNameGet( meshhandle,materialhandle,name )
*	                                D1         D2             D3
*
*	ULONG MWLMeshMaterialNameGet
*	     ( ULONG,ULONG,STRPTR * );
*
*   FUNCTION
*	You will get a pointer to the name of the material. This string is READ_ONLY
*	and only valid as long as the mesh exists.
* 
*   INPUTS
* 	meshhandle     - A valid handle of a mesh.
*	materialhandle - A valid handle of a material.
*	name           - Pointer to the name of the material.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*	        RCNOMATERIAL if the handle is not valid.
* 
*   EXAMPLE
*	error = MWLMeshMaterialNameGet(meshhandle,materialhandle,&mystring);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshMaterialNameSet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshMaterialNameGet(register __d1 ULONG meshhandle,
												register __d2 ULONG materialhandle,
												register __d3 STRPTR *name) {
	TOCLMesh			*mesh=NULL;
	TOCLMaterialNode	*mat=NULL;
	
	mesh=(TOCLMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);

	mat=getMaterialNode(mesh,materialhandle);
	if(mat==NULL) return(RCNOMATERIAL);

	(*name)=mat->name;
	
	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshMaterialAmbientColorSet ******************************************
* 
*   NAME	
* 	MWLMeshMaterialAmbientColorSet -- Set the ambient color of a material.
* 
*   SYNOPSIS
*	error = MWLMeshMaterialAmbientColorSet( meshhandle,materialhandle,color )
*	                                        D1         D2              A0
*
*	ULONG MWLMeshMaterialAmbientColorSet
*	     ( ULONG,ULONG,TOCLColor * );
*
*   FUNCTION
*	The ambient color of the material will be set to the values passed by the
*	color structure.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	materialhandle  - A valid handle of a material.
*	color           - Pointer to a color structure containing the color information.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*	        RCNOMATERIAL if the handle is not valid.
*
*   EXAMPLE
*	error = MWLMeshMaterialAmbientColorSet(meshhandle,materialhandle,&mycolor);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshMaterialAmbientColorGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshMaterialAmbientColorSet(register __d1 ULONG meshhandle,
														register __d2 ULONG materialhandle,
														register __a0 TOCLColor *color) {
	TOCLMesh			*mesh=NULL;
	TOCLMaterialNode	*mat=NULL;
	TOCLColor			*mcolor=NULL;

	// make a copy of color, because a0 is a scratch register
	mcolor = color;
	
	mesh=(TOCLMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);
  
	mat=getMaterialNode(mesh,materialhandle);
	if(mat==NULL) return(RCNOMATERIAL);
  
	mat->ambientColor=(*mcolor);
	
	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshMaterialAmbientColorGet ******************************************
* 
*   NAME	
* 	MWLMeshMaterialAmbientColorGet -- Get the ambient color of a material.
* 
*   SYNOPSIS
*	error = MWLMeshMaterialAmbientColorGet( meshhandle,materialhandle,color )
*	                                        D1         D2              A0
*
*	ULONG MWLMeshMaterialAmbientColorGet
*	     ( ULONG,ULONG,TOCLColor * );
*
*   FUNCTION
*	The ambient color of the material will be written in the passed color structure.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	materialhandle  - A valid handle of a material.
*	color           - Pointer to a color structure which will contain
*	                  the color information.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*	        RCNOMATERIAL if the handle is not valid.
*
*   EXAMPLE
*	error = MWLMeshMaterialAmbientColorGet(meshhandle,materialhandle,&mycolor);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshMaterialAmbientColorSet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshMaterialAmbientColorGet(register __d1 ULONG meshhandle,
														register __d2 ULONG materialhandle,
														register __a0 TOCLColor *color) {
	TOCLMesh			*mesh=NULL;
	TOCLMaterialNode	*mat=NULL;
	TOCLColor			*mcolor=NULL;
	
	// make a copy of color, a0 is a scratch register
	mcolor=color;
	
	mesh=(TOCLMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);
  
	mat=getMaterialNode(mesh,materialhandle);
	if(mat==NULL) return(RCNOMATERIAL);
  
	(*mcolor)=mat->ambientColor;
	
	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshMaterialShininessSet ******************************************
* 
*   NAME	
* 	MWLMeshMaterialShininessSet -- Set the shininess of a material.
* 
*   SYNOPSIS
*	error = MWLMeshMaterialShininessSet( meshhandle,materialhandle,shininess )
*	                                     D1         D2             D3
*
*	ULONG MWLMeshMaterialShininessSet
*	     ( ULONG,ULONG,TOCLFloat );
*
*   FUNCTION
*	The shininess of the material will be set to the value passed by
*	shininess.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	materialhandle  - A valid handle of a material.
*	shininess       - Value of the shininess between 0.0 and 1.0.
*	
*   RESULT
* 	error - RCNOERROR         if all went well.
*	        RCNOMESH          if the handle is not valid.
*	        RCNOMATERIAL      if the handle is not valid.
*	        RCVALUEOUTOFRANGE if the value is out of range.
*
*   EXAMPLE
*	error = MWLMeshMaterialShininessSet(meshhandle,materialhandle,0.34);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshMaterialShininessGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshMaterialShininessSet(register __d1 ULONG meshhandle,
													register __d2 ULONG materialhandle,
													register __d3 TOCLFloat shininess) {
	TOCLMesh			*mesh=NULL;
	TOCLMaterialNode	*mat=NULL;
  
	mesh=(TOCLMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);

	mat=getMaterialNode(mesh,materialhandle);
	if(mat==NULL) return(RCNOMATERIAL);
	
	if(shininess>=0 && shininess <=1) mat->shininess=shininess;
	else return(RCVALUEOUTOFRANGE);
	
	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshMaterialShininessGet ******************************************
* 
*   NAME	
* 	MWLMeshMaterialShininessGet -- Get the shininess of a material.
* 
*   SYNOPSIS
*	error = MWLMeshMaterialShininessGet( meshhandle,materialhandle,shininess )
*	                                     D1         D2             D3
*
*	ULONG MWLMeshMaterialShininessGet
*	     ( ULONG,ULONG,TOCLFloat * );
*
*   FUNCTION
*	The shininess of the material will be put into the variable pointed by shininess.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	materialhandle  - A valid handle of a material.
*	shininess       - Pointer to the variable which will contain the shininess.
*	
*   RESULT
* 	error - RCNOERROR         if all went well.
*	        RCNOMESH          if the handle is not valid.
*	        RCNOMATERIAL      if the handle is not valid.
*
*   EXAMPLE
*	error = MWLMeshMaterialShininessGet(meshhandle,materialhandle,&myfloat);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshMaterialShininessSet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshMaterialShininessGet(register __d1 ULONG meshhandle,
													register __d2 ULONG materialhandle,
													register __d3 TOCLFloat *shininess) {
	TOCLMesh			*mesh=NULL;
	TOCLMaterialNode	*mat=NULL;
  
	mesh=(TOCLMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);

	mat=getMaterialNode(mesh,materialhandle);
	if(mat==NULL) return(RCNOMATERIAL);
	
	(*shininess)=mat->shininess;
	
	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshMaterialTransparencySet ******************************************
* 
*   NAME	
* 	MWLMeshMaterialTransparencySet -- Set the transparency of a material.
* 
*   SYNOPSIS
*	error = MWLMeshMaterialTransparencySet( meshhandle,materialhandle,transparency )
*	                                        D1         D2             D3
*
*	ULONG MWLMeshMaterialTransparencySet
*	     ( ULONG,ULONG,TOCLFloat );
*
*   FUNCTION
*	The transparency of the material will be set to the value passed by
*	transparency.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	materialhandle  - A valid handle of a material.
*	transparency    - Value of the transparency between 0.0 and 1.0.
*	
*   RESULT
* 	error - RCNOERROR         if all went well.
*	        RCNOMESH          if the handle is not valid.
*	        RCNOMATERIAL      if the handle is not valid.
*	        RCVALUEOUTOFRANGE if the value is out of range.
*
*   EXAMPLE
*	error = MWLMeshMaterialTransparencySet(meshhandle,materialhandle,0.9);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshMaterialTransparencyGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshMaterialTransparencySet(register __d1 ULONG meshhandle,
														register __d2 ULONG materialhandle,
														register __d3 TOCLFloat transparency) {
	TOCLMesh			*mesh=NULL;
	TOCLMaterialNode	*mat=NULL;
  
	mesh=(TOCLMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);
	
	mat=getMaterialNode(mesh,materialhandle);
	if(mat==NULL) return(RCNOMATERIAL);
	
	if(transparency>=0 && transparency<=1) mat->transparency=transparency;
	else return(RCVALUEOUTOFRANGE);
	
	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshMaterialTransparencyGet ******************************************
* 
*   NAME	
* 	MWLMeshMaterialTransparencyGet -- Get the transparency of a material.
* 
*   SYNOPSIS
*	error = MWLMeshMaterialTransparencyGet( meshhandle,materialhandle,transparency )
*	                                        D1         D2             D3
*
*	ULONG MWLMeshMaterialTransparencyGet
*	     ( ULONG,ULONG,TOCLFloat * );
*
*   FUNCTION
*	The transparency of the material will be put into the variable pointed by transparency.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	materialhandle  - A valid handle of a material.
*	transparency    - Pointer to the variable which will contain the transparency.
*	
*   RESULT
* 	error - RCNOERROR         if all went well.
*	        RCNOMESH          if the handle is not valid.
*	        RCNOMATERIAL      if the handle is not valid.
*
*   EXAMPLE
*	error = MWLMeshMaterialTransparencyGet(meshhandle,materialhandle,&myfloat);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshMaterialTransparencySet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshMaterialTransparencyGet(register __d1 ULONG meshhandle,
														register __d2 ULONG materialhandle,
														register __d3 TOCLFloat *transparency) {
	TOCLMesh			*mesh=NULL;
	TOCLMaterialNode	*mat=NULL;
  
	mesh=(TOCLMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);
	
	mat=getMaterialNode(mesh,materialhandle);
	if(mat==NULL) return(RCNOMATERIAL);
	
	(*transparency)=mat->transparency;
	
	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshPolygonAdd ******************************************
* 
*   NAME	
* 	MWLMeshPolygonAdd -- Add a new polygon to the mesh.
*
*   SYNOPSIS
*	error = MWLMeshPolygonAdd( meshhandle,materialhandle )
*	                           D1         D2
*
*	ULONG MWLMeshPolygonAdd
*	     ( ULONG,ULONG );
*
*   FUNCTION
*	A new polygon will be created and added to the mesh.
*	With MWLMeshPolygonVertexAdd you can add vertices to this polygon.
* 
*   INPUTS
* 	meshhandle     - A valid handle of a mesh.
*	materialhandle - A valid handle of a material or 0 if you wont
*	                 assign a material to this polygon now.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*	        RCNOMATERIAL if the handle is not valid.
*	        RCNOMEMORY   if there is not enough memory. 
* 
*   EXAMPLE
*	error = MWLMeshPolygonAdd(meshhandle,materialhandle);
*
*   NOTES
*	Only convex polygons are supported.
*
*	    Correct              Incorrect
*
*	    *-----*              *----*
*	   / \   /                \  /
*	  /   \ /                  \/
*	 / __--*                   /\
*	*--                       /  \
*	                         *----*
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshPolygonMaterialSet(),MWLMeshPolygonVertexAdd()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshPolygonAdd(register __d1 ULONG meshhandle,
										register __d2 ULONG materialhandle) {
	TOCLMesh			*mesh=NULL;
	TOCLMaterialNode	*mat=NULL;
	TOCLPolygonNode	*pln=NULL;
        
	mesh=(TOCLMesh *) meshhandle;
	if (mesh==NULL) return(RCNOMESH);

	mat=getMaterialNode(mesh,materialhandle);
	if(materialhandle!=0 && mat==NULL) return(RCNOMATERIAL);

	/*
	** Creat a new polygon, add it to the internal list
	*/
	pln = AllocPooled(mesh->polygonpool,sizeof(TOCLPolygonNode));
	if (pln==NULL) return(RCNOMEMORY);
        
	pln->numberOfVertices=0;
	pln->firstNode=NULL;
	pln->lastNode=NULL;
	pln->next=NULL;
	pln->materialNode=mat;
        
	if(mesh->polygons.firstNode!=NULL) {   /* Check if this is the first polygon to insert or not */
		mesh->polygons.lastNode->next=pln;
		mesh->polygons.lastNode=pln;
	}
	else {
		mesh->polygons.lastNode=pln;
		mesh->polygons.firstNode=pln;
	}

	/*
	** Increment the polygon counter
	*/
	mesh->polygons.numberOfPolygons++;
        
	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshPolygonMaterialSet ******************************************
* 
*   NAME	
* 	MWLMeshPolygonMaterialSet -- Set the material of the most recent polygon.
* 
*   SYNOPSIS
*	error = MWLMeshPolygonMaterialSet( meshhandle,materialhandle )
*	                                   D1         D2
*
*	ULONG MWLMeshPolygonMaterialSet
*	     ( ULONG,ULONG );
*
*   FUNCTION
*	The material of the most recent polygon will be set to the one you
*	pass by the handle.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	materialhandle  - A valid handle of a material.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*	        RCNOMATERIAL if the handle is not valid.
*	        RCNOPOLYGON  if there is no polygon to work with.     
*
*   EXAMPLE
*	error = MWLMeshPolygonMaterialSet(meshhandle,materialhandle);
*
*   NOTES
*	As all is a polygon, after calling MWLMeshTriangleAdd() with this
*	function you can set the material of the new triangle too.
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshPolygonAdd(),MWLMeshTriangleAdd()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshPolygonMaterialSet(register __d1 ULONG meshhandle,
												register __d2 ULONG materialhandle) {
	TOCLMesh			*mesh=NULL;
	TOCLMaterialNode	*mat=NULL;
        
	mesh=(TOCLMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);

   if(mesh->polygons.lastNode==NULL) return(RCNOPOLYGON); /* There is no polygon to work with */

	/*
	** Set the material to this polygon
	*/
	mat=getMaterialNode(mesh,materialhandle);
	if(materialhandle!=0 && mat==NULL) return(RCNOMATERIAL);
	
	mesh->polygons.lastNode->materialNode=mat;

	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshPolygonVertexAdd ******************************************
* 
*   NAME	
* 	MWLMeshPolygonVertexAdd -- Add a new vertex to the most recent polygon,
*	                           according the CTM.
*
*   SYNOPSIS
*	error = MWLMeshPolygonVertexAdd( meshhandle,vertex )
*	                                 D1          A0
*
*	ULONG MWLMeshPolygonAdd
*	     ( ULONG,TOCLVertex * );
*
*   FUNCTION
*	A new vertex will be added to the polygon. A copy of the contents passed
*	by the vertex pointer will be made.
* 
*   INPUTS
* 	meshhandle   - A valid handle of a mesh.
*	vertex       - Pointer to a vertex structure which contains the coordinates
*	               of the new vertex.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*	        RCNOMEMORY   if there is not enough memory. 
*	        RCNOPOLYGON  if there is no polygon to work with.
* 
*   EXAMPLE
*	error = MWLMeshPolygonVertexAdd(meshhandle,&myvertex);
*
*   NOTES
*	Vertices have to be added in counterclock wise direction.
*
*	      v3
*	     / |
*	    /  |
*	   /   |
*	  /    |
*	 /     |
*	v1--->v2
*
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshPolygonAdd()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshPolygonVertexAdd(register __d1 ULONG meshhandle,
												register __a0 TOCLVertex *vertex) {
                                
	TOCLMesh					*mesh=NULL;
	TOCLVertexNode				*ver=NULL;
	TOCLPolygonsVerticesNode	*plv=NULL;
	TOCLPolygonNode			*pln=NULL;
	TOCLVertex					*mvertex=NULL;
      
	// make a copy of vertex, a0 is a scratch register
	mvertex=vertex;
	
	mesh=(TOCLMesh *) meshhandle;
	if (mesh==NULL) return(RCNOMESH);

	if(mesh->polygons.lastNode==NULL) return(RCNOPOLYGON); /* There is no polygon to work with */

	/*
	** Add a new vertice to the internal vertice list
	*/
	ver = addVertex(mesh,(*mvertex));
	if (ver==NULL) {
		return(RCNOMEMORY);
	}
	
	/*
	** Add a new polygon vertex node to the polygon list its last element
	*/
	plv = AllocPooled(mesh->polygonverticespool,sizeof(TOCLPolygonsVerticesNode));
	if (plv==NULL) {
		return(RCNOMEMORY);
	}
        
	plv->vertexNode=ver;
	plv->next=NULL;

	pln=mesh->polygons.lastNode;
     
	if(pln->firstNode!=NULL) {   /* Check if this is the first vertex to insert or not */
		pln->lastNode->next=plv;
		pln->lastNode=plv;
	}
	else {
		pln->lastNode=plv;
		pln->firstNode=plv;
	}
	
	/*
	** Increment the number of vertices counter of the polygon
	*/
	pln->numberOfVertices++;
        
	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshTriangleAdd ******************************************
* 
*   NAME	
* 	MWLMeshTriangleAdd -- Add a new triangle to the mesh according the CTM.
*
*   SYNOPSIS
*	error = MWLMeshTriangleAdd( meshhandle,materialhandle,vertex1,vertex2,vertex3 )
*	                            D1         D2              A0       A1      A2
*
*	ULONG MWLMeshTriangleAdd
*	     ( ULONG,ULONG,TOCLVertex *,TOCLVertex *,TOCLVertex * );
*
*   FUNCTION
*	A new triangle will be added to the mesh.
*	This means a new polygon with 3 vertices.
*	A copy of the contents passed by the vertex pointers will be made.
* 
*   INPUTS
* 	meshhandle     - A valid handle of a mesh.
*	materialhandle - A valid handle of a material or 0 if you wont
*	                 assign a material to this polygon now.
*	vertex1        - Pointer to the first vertex structure.
*	vertex2        - Pointer to the second vertex structure.
*	vertex3        - Pointer to the third vertex structure.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*	        RCNOMATERIAL if the handle is not valid.
*	        RCNOMEMORY   if there is not enough memory. 
* 
*   EXAMPLE
*	error = MWLMeshTriangleAdd(meshhandle,materialhandle,&v1,&v2,&v3);
*
*   NOTES
*	Vertices have to be added in counterclock wise direction.
*
*	      v3
*	     / |
*	    /  |
*	   /   |
*	  /    |
*	 /     |
*	v1--->v2
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshPolygonMaterialSet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshTriangleAdd(register __d1 ULONG meshhandle,
										register __d2 ULONG materialhandle,
										register __a0 TOCLVertex *vertex1,
										register __a1 TOCLVertex *vertex2,
										register __a2 TOCLVertex *vertex3) {

	TOCLMesh					*mesh=NULL;
	TOCLMaterialNode			*mat=NULL;
	TOCLPolygonNode			*pln=NULL;
	TOCLVertexNode				*ver1=NULL,*ver2=NULL,*ver3=NULL;
	TOCLPolygonsVerticesNode	*plv1=NULL,*plv2=NULL;
	TOCLVertex					*mvertex1=NULL,*mvertex2=NULL,*mvertex3=NULL;
	
	// make a copy of vertex1 to 3, a0 and a1 are a scratch registers
	mvertex1=vertex1;
	mvertex2=vertex2;
	mvertex3=vertex3;

	mesh=(TOCLMesh *) meshhandle;
	if (mesh==NULL) return(RCNOMESH);

	mat=getMaterialNode(mesh,materialhandle);
	if(materialhandle!=0 && mat==NULL) return(RCNOMATERIAL);

	/*
	** Create a new polygon, add it to the internal list
	*/
	pln = AllocPooled(mesh->polygonpool,sizeof(TOCLPolygonNode));
	if (pln==NULL) {
		return(RCNOMEMORY);
	}
        
	pln->numberOfVertices=0;
	pln->firstNode=NULL;
	pln->lastNode=NULL;
	pln->next=NULL;
	pln->materialNode=mat;
        
	if(mesh->polygons.firstNode!=NULL) {   /* Check if this is the first polygon to insert or not */
		mesh->polygons.lastNode->next=pln;
		mesh->polygons.lastNode=pln;
	}
	else {
		mesh->polygons.lastNode=pln;
		mesh->polygons.firstNode=pln;
	}

	/*
	** Increment the polygon counter
	*/
	mesh->polygons.numberOfPolygons++;

	/*
	** Add the 3 new vertices to the internal vertice list,
	** and add the number of vertices counter of the polygon
	*/
	ver1 = addVertex(mesh,(*mvertex1));
	if (ver1==NULL) return(RCNOMEMORY);
	pln->numberOfVertices++;
	ver2 = addVertex(mesh,(*mvertex2));
	if (ver2==NULL) return(RCNOMEMORY);
	pln->numberOfVertices++;
	ver3 = addVertex(mesh,(*mvertex3));
	if (ver3==NULL) return(RCNOMEMORY);
	pln->numberOfVertices++;

	/*
	** Add the 3 new polygon vertices node to the polygon list its last element
	*/
	plv1 = AllocPooled(mesh->polygonverticespool,sizeof(TOCLPolygonsVerticesNode));
	if (plv1==NULL) return(RCNOMEMORY);
	
	plv1->vertexNode=ver3;
	plv1->next=NULL;

	plv2 = AllocPooled(mesh->polygonverticespool,sizeof(TOCLPolygonsVerticesNode));
	if (plv2==NULL) return(RCNOMEMORY);
	
	plv2->vertexNode=ver2;
	plv2->next=plv1;

	plv1 = AllocPooled(mesh->polygonverticespool,sizeof(TOCLPolygonsVerticesNode));
	if (plv1==NULL) return(RCNOMEMORY);        
	
	plv1->vertexNode=ver1;
	plv1->next=plv2;


	pln=mesh->polygons.lastNode;
     
	if(pln->firstNode!=NULL) {   /* Check if this is the first vertex to insert or not */
		pln->lastNode->next=plv1;
		pln->lastNode=plv1;
	}
	else {
		pln->lastNode=plv1;
		pln->firstNode=plv1;
	}
	
	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshNumberOfMaterialsGet ******************************************
* 
*   NAME	
* 	MWLMeshNumberOfMaterialsGet -- Get the number of materials in a mesh.
* 
*   SYNOPSIS
*	number = MWLMeshNumberOfMaterialsGet( meshhandle )
*	                                      D1
*
*	ULONG MWLMeshNumberOfMaterialsGet
*	     ( ULONG )
*
*   FUNCTION
*	The current number of materials found in the mesh will be returned.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	
*   RESULT
* 	number - Number of materials, 0 if any or no valid mesh.
*
*   EXAMPLE
*	number = MWLMeshNumberOfMaterialsGet(meshhandle);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshNumberOfPolygonsGet(),MWLMeshNumberOfVerticesGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshNumberOfMaterialsGet(register __d1 ULONG meshhandle) {
	TOCLMesh *mesh=NULL;
	
	mesh = (TOCLMesh *) meshhandle;
	if(mesh==NULL) return(0);
	
	return(mesh->materials.numberOfMaterials);
}

/****** meshwriter.library/MWLMeshNumberOfPolygonsGet ******************************************
* 
*   NAME	
* 	MWLMeshNumberOfPolygonsGet -- Get the number of polygons in a mesh.
* 
*   SYNOPSIS
*	number = MWLMeshNumberOfPolygonsGet( meshhandle )
*	                                     D1
*
*	ULONG MWLMeshNumberOfPolygonsGet
*	     ( ULONG )
*
*   FUNCTION
*	The current number of polygons found in the mesh will be returned.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	
*   RESULT
* 	number - Number of polygons, 0 if any or no valid mesh.
*
*   EXAMPLE
*	number = MWLMeshNumberOfPolygonsGet(meshhandle);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshNumberOfMaterialsGet(),MWLMeshNumberOfVerticesGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshNumberOfPolygonsGet(register __d1 ULONG meshhandle) {
	TOCLMesh *mesh=NULL;
	
	mesh = (TOCLMesh *) meshhandle;
	if(mesh==NULL) return(0);
	
	return(mesh->polygons.numberOfPolygons);
}

/****** meshwriter.library/MWLMeshNumberOfVerticesGet ******************************************
* 
*   NAME	
* 	MWLMeshNumberOfVerticesGet -- Get the number of vertices in a mesh.
* 
*   SYNOPSIS
*	number = MWLMeshNumberOfVerticesGet( meshhandle )
*	                                     D1
*
*	ULONG MWLMeshNumberOfVerticesGet
*	     ( ULONG )
*
*   FUNCTION
*	The current number of vertices found in the mesh will be returned.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	
*   RESULT
* 	number - Number of vertices, 0 if any or no valid mesh.
*
*   EXAMPLE
*	number = MWLMeshNumberOfVerticesGet(meshhandle);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshNumberOfMaterialsGet(),MWLMeshNumberOfPolygonsGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshNumberOfVerticesGet(register __d1 ULONG meshhandle) {
	TOCLMesh *mesh=NULL;
	
	mesh = (TOCLMesh *) meshhandle;
	if(mesh==NULL) return(0);
	
	return(mesh->vertices.numberOfVertices);
}

/****** meshwriter.library/MWLMeshCameraLightDefaultSet ******************************************
* 
*   NAME	
* 	MWLMeshCameraLightDefaultSet -- Set the camera and light to defaults.
* 
*   SYNOPSIS
*	error = MWLMeshCameraLightDefaultSet( meshhandle )
*	                                      D1
*
*	ULONG MWLMeshCameraLightDefaultSet
*	     ( ULONG )
*
*   FUNCTION
*	This function sets the camera and light properties as follows :
*	Camera looks to the center of the mesh and is positioned to view the whole mesh.
*	Light is positioned at the same point than the camera and gets a white color.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*
*   EXAMPLE
*	error= MWLMeshCameraLightDefaultSet(meshhandle);
*
*   NOTES
*	Camera and light will be used by some file formats only,
*	and for 2D or display functions.
*
*	If no values are set, this function will be called internally before
*	using functions which need a camera or a light source.
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshCameraPositionSet(),MWLMeshCameraLookAtSet(),
*	MWLMeshLightPositionSet(),MWLMeshLightColorSet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshCameraLightDefaultSet(register __d1 ULONG meshhandle) {
	TOCLMesh *mesh=NULL;
  
	mesh=(TOCLMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);
	
	setCameraLight(mesh);
	
	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshCameraPositionSet ******************************************
* 
*   NAME	
* 	MWLMeshCameraPositionSet -- Set the camera position.
* 
*   SYNOPSIS
*	error = MWLMeshCameraPositionSet( meshhandle,position )
*	                                  D1          A0
*
*	ULONG MWLMeshCameraPositionSet
*	     ( ULONG,TOCLVertex * );
*
*   FUNCTION
*	The position of the camera will be set to the values passed by the
*	vertex structure.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	position        - Pointer to a vertex structure containing the position information.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*`	        RCNOMESH     if the handle is not valid.
*
*   EXAMPLE
*	error = MWLMeshCameraPositionSet(meshhandle,&myvertex);
*
*   NOTES
*	The camera will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshCameraPositionGet(),MWLMeshCameraLookAtSet(),
*	MWLMeshCameraLookAtGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshCameraPositionSet(register __d1 ULONG meshhandle,
												register __a0 TOCLVertex *position) {
	TOCLMesh		*mesh=NULL;
	TOCLVertex		*mposition=NULL;
	
	// make a copy of position, a0 is a scratch register
	mposition=position;
  
	mesh=(TOCLMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);
	
	mesh->camera.position=(*mposition);
	
	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshCameraPositionGet ******************************************
* 
*   NAME	
* 	MWLMeshCameraPositionGet -- Get the position of the camera.
* 
*   SYNOPSIS
*	error = MWLMeshCameraPositionGet( meshhandle,position )
*	                                  D1          A0
*
*	ULONG MWLMeshCameraPositionGet
*	     ( ULONG,TOCLVertex * );
*
*   FUNCTION
*	The position of the camera will be written in the passed vertex structure.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	position        - Pointer to a vertex structure which will contain
*	                  the position information.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*
*   EXAMPLE
*	error = MWLMeshCameraPositionGet(meshhandle,&myvertex);
*
*   NOTES
*	The camera will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshCameraPositionSet(),MWLMeshCameraLookAtSet()
*	MWLMeshCameraLookAtGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshCameraPositionGet(register __d1 ULONG meshhandle,
												register __a0 TOCLVertex *position) {
	TOCLMesh		*mesh=NULL;
	TOCLVertex	*mposition=NULL;
	
	// make a copy of position, a0 is a scratch register
	mposition=position;

	mesh = (TOCLMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);

	(*mposition)=mesh->camera.position;
	
	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshCameraLookAtSet ******************************************
* 
*   NAME	
* 	MWLMeshCameraLookAtSet -- Set the camera its view point.
* 
*   SYNOPSIS
*	error = MWLMeshCameraLookAtSet( meshhandle,lookat )
*	                                D1          A0
*
*	ULONG MWLMeshCameraLookAtSet
*	     ( ULONG,TOCLVertex * );
*
*   FUNCTION
*	The view point of the camera will be set to the values passed by the
*	vertex structure.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	lookat          - Pointer to a vertex structure containing the position information.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*
*   EXAMPLE
*	error = MWLMeshCameraLookAtSet(meshhandle,&myvertex);
*
*   NOTES
*	The camera will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshCameraLookAtGet(),MWLMeshCameraPositionSet()
*	MWLMeshCameraPositionSet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshCameraLookAtSet(register __d1 ULONG meshhandle,
											register __a0 TOCLVertex *lookat) {
	TOCLMesh		*mesh=NULL;
	TOCLVertex		*mlookat=NULL;

	// make a copy of lookat, a0 is a scratch register
	mlookat=lookat;

	mesh=(TOCLMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);
	
	mesh->camera.lookat=(*mlookat);
	
	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshCameraLookAtGet ******************************************
* 
*   NAME	
* 	MWLMeshCameraLookAtGet -- Get the view point of the camera.
* 
*   SYNOPSIS
*	error = MWLMeshCameraLookAtGet( meshhandle,lookat )
*	                                D1          A0
*
*	ULONG MWLMeshCameraLookAtGet
*	     ( ULONG,TOCLVertex * );
*
*   FUNCTION
*	The view point of the camera will be written in the passed vertex structure.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	lookat          - Pointer to a vertex structure which will contain
*	                  the position information.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*
*   EXAMPLE
*	error = MWLMeshCameraLookAtGet(meshhandle,&myvertex);
*
*   NOTES
*	The camera will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshCameraLookAtSet(),MWLMeshCameraPositionSet()
*	MWLMeshCameraPositionGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshCameraLookAtGet(register __d1 ULONG meshhandle,
											register __a0 TOCLVertex *lookat) {
	TOCLMesh		*mesh=NULL;
	TOCLVertex		*mlookat=NULL;
	
	// make a copy of lookat, a0 is a scratch register
	mlookat=lookat;
  
	mesh=(TOCLMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);

	(*mlookat)=mesh->camera.lookat;
	
	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshLightPositionSet ******************************************
* 
*   NAME	
* 	MWLMeshLightPositionSet -- Set the light source its position.
* 
*   SYNOPSIS
*	error = MWLMeshLightPositionSet( meshhandle,position )
*	                                 D1          A0
*
*	ULONG MWLMeshLightPositionSet
*	     ( ULONG,TOCLVertex * );
*
*   FUNCTION
*	The position of the light source will be set to the values passed by the
*	vertex structure.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	position        - Pointer to a vertex structure containing the position information.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*
*   EXAMPLE
*	error = MWLMeshLightPositionSet(meshhandle,&myvertex);
*
*   NOTES
*	The light will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshLightPositionGet(),MWLMeshLightColorSet()
*	MWLMeshLightColorGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshLightPositionSet(register __d1 ULONG meshhandle,
												register __a0 TOCLVertex *position) {
	TOCLMesh		*mesh=NULL;
	TOCLVertex		*mposition=NULL;

	// make a copy of position, a0 is a scratch register
	mposition=position;

	mesh=(TOCLMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);
	
	mesh->light.position=(*mposition);
	
	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshLightPositionGet ******************************************
* 
*   NAME	
* 	MWLMeshLightPositionGet -- Get the position of the light source.
* 
*   SYNOPSIS
*	error = MWLMeshLightPositionGet( meshhandle,position )
*	                                 D1          A0
*
*	ULONG MWLMeshLightPositionGet
*	     ( ULONG,TOCLVertex * );
*
*   FUNCTION
*	The position of the light source will be written in the passed vertex structure.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	position        - Pointer to a vertex structure which will contain
*	                  the position information.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*
*   EXAMPLE
*	error = MWLMeshLightPositionGet(meshhandle,&myvertex);
*
*   NOTES
*	The light will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshLightPositionSet(),MWLMeshLightColorSet()
*	MWLMeshLightColorGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshLightPositionGet(register __d1 ULONG meshhandle,
												register __a0 TOCLVertex *position) {
	TOCLMesh		*mesh=NULL;
	TOCLVertex		*mposition=NULL;
	
	// make a copy of position, a0 is a scratch register
	mposition=position;
  
	mesh=(TOCLMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);

	(*mposition)=mesh->light.position;
	
	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshLightColorSet ******************************************
* 
*   NAME	
* 	MWLMeshLightColorSet -- Set the light source its color.
* 
*   SYNOPSIS
*	error = MWLMeshLightColorSet( meshhandle,color )
*	                              D1          A0
*
*	ULONG MWLMeshLightColorSet
*	     ( ULONG,TOCLColor * );
*
*   FUNCTION
*	The color of the light source will be set to the values passed by the
*	color structure.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	color           - Pointer to a color structure containing the color information.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*
*   EXAMPLE
*	error = MWLMeshLightColorSet(meshhandle,&mycolor);
*
*   NOTES
*	The light will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshLightColorGet(),MWLMeshLightPositionSet()
*	MWLMeshLightPositionGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshLightColorSet(register __d1 ULONG meshhandle,
											register __a0 TOCLColor *color) {
	TOCLMesh	*mesh=NULL;
	TOCLColor	*mcolor=NULL;
	
	// make a copy of color, a0 is a scratch register
	mcolor=color;
  
	mesh=(TOCLMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);
	
	mesh->light.color=(*mcolor);

	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshLightColorGet ******************************************
* 
*   NAME	
* 	MWLMeshLightColorGet -- Get the color of the light source.
* 
*   SYNOPSIS
*	error = MWLMeshLightColorGet( meshhandle,color )
*	                              D1          A0
*
*	ULONG MWLMeshLightColorGet
*	     ( ULONG,TOCLColor * );
*
*   FUNCTION
*	The color of the light source will be written in the passed color structure.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	color           - Pointer to a color structure which will contain
*	                  the color information.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*
*   EXAMPLE
*	error = MWLMeshLightColorGet(meshhandle,&mycolor);
*
*   NOTES
*	The light will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshLightColorSet(),MWLMeshLightPositionSet()
*	MWLMeshLightPositionGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshLightColorGet(register __d1 ULONG meshhandle,
											register __a0 TOCLColor *color) {
	TOCLMesh	*mesh=NULL;
	TOCLColor	*mcolor=NULL;
	
	// make a copy of color, a0 is a scratch register
	mcolor=color;

	mesh=(TOCLMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);

	(*color)=mesh->light.color;
	
	return(RCNOERROR);
}

/****** meshwriter.library/MWL3DFileFormatNamesGet ******************************************
* 
*   NAME	
* 	MWL3DFileFormatNamesGet -- Get a name list of all supported 3D file formats.
* 
*   SYNOPSIS
*	list = MWL3DFileFormatNamesGet(  )
*
*	STRPTR * MWL3DFileFormatNamesGet
*	     (  );
*
*   FUNCTION
*	You will get a pointer to the namelist of all supported 3D file formats.
*	This strings are READ_ONLY and only valid as long as the library is opened.
*
*	The list is sorted alphabetically.
*
*	The resulting pointer can directly be used to fill up cycle or list gadgets
*	for example.
* 
*   INPUTS
*	
*   RESULT
* 	list - A NULL terminated array of string pointers. Or NULL if no
*	       files are supported.
*
*   EXAMPLE
*	list = MWL3DFileFormatNamesGet();
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	MWL3DFileFormatIDGet(),MWL3DFileFormatExtensionGet()
*	MWL3DFileFormatNumberOfGet()
* 
******************************************************************************
*
*/
STRPTR * __saveds ASM MWL3DFileFormatNamesGet() {
	if(c3dFFNames[0]!=NULL) return(c3dFFNames);
	return(NULL);
}

/****** meshwriter.library/MWL3DFileFormatIDGet ******************************************
* 
*   NAME	
* 	MWL3DFileFormatIDGet -- Get the ID of a specific 3D file format.
* 
*   SYNOPSIS
*	id = MWL3DFileFormatIDGet( ffname )
*	                            D1
*
*	ULONG MWL3DFileFormatIDGet
*	     ( STRPTR );
*
*   FUNCTION
*	You will get the ID of the 3D file format of which you passed its name.
* 
*   INPUTS
*	ffname - Name of the format you search the ID for.
*	
*   RESULT
* 	id - The ID of the 3D file format or 0 if not found/supported.
*
*   EXAMPLE
*	id = MWL3DFileFormatIDGet("Lightwave");
*
*   NOTES
*	Even if the values of the IDs wont change in future versions, it is
*	recomended to show the list of all names to the user and let him choose
*	the format. With the help of this function you will get the correct
*	ID which is needed for further function calls.
*
*   BUGS
* 
*   SEE ALSO
* 	MWL3DFileFormatNamesGet(),MWL3DFileFormatExtensionGet()
*	MWL3DFileFormatNumberOfGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWL3DFileFormatIDGet(register __d1 STRPTR ffname) {
	ULONG i;
        
	i=0;
	while(strcmp(c3dFFNames[i],ffname) && c3dFFNames[i]!=NULL) {i++};
	
	// check if we got it or not
	if(!strcmp(c3dFFNames[i],ffname)) return(c3dFFIDs[i]);
	else return(0);
}

/****** meshwriter.library/MWL3DFileFormatExtensionGet ******************************************
* 
*   NAME	
* 	MWL3DFileFormatExtensionGet -- Get the file extension of a specific 3D file format.
* 
*   SYNOPSIS
*	ext = MWL3DFileFormatExtensionGet( ffid )
*	                                   D1
*
*	STRPTR MWL3DFileFormatExtensionGet
*	     ( ULONG );
*
*   FUNCTION
*	You will get a pointer to the extension of the specified 3D file format.
*	This strings are READ_ONLY and only valid as long as the library is opened.
* 
*   INPUTS
*	ffid - ID of the file format you search the extension for.
*	
*   RESULT
* 	ext - Pointer to the file extension string or NULL if the format is unknown.
*
*   EXAMPLE
*	ext = MWL3DFileFormatExtensionGet(id);
*
*   NOTES
*	This extensions are proposals of the format creators, but you are free
*	to use them.
*
*   BUGS
* 
*   SEE ALSO
* 	MWL3DFileFormatNamesGet(),MWL3DFileFormatIDGet()
*	MWL3DFileFormatNumberOfGet()
* 
******************************************************************************
*
*/
STRPTR __saveds ASM MWL3DFileFormatExtensionGet(register __d1 ULONG ffid) {
	ULONG i,mffid;
        
	// make a copy of ffid, because d1 is a scratch register
	mffid=ffid;
        
	i=0;
	while(c3dFFIDs[i]!=mffid && c3dFFIDs[i]!=0) {i++};
	
	// check if we got it or not
	if(c3dFFIDs[i]==mffid) return(c3dFFExtensions[i]);
	else return(NULL);
}

/****** meshwriter.library/MWL3DFileFormatNumberOfGet ******************************************
* 
*   NAME	
* 	MWL3DFileFormatNumberOfGet -- Get the number of supported 3D file formats.
* 
*   SYNOPSIS
*	number = MWL3DFileFormatNumberOfGet( )
*
*	ULONG MWL3DFileFormatNumberOfGet
*	     ( );
*
*   FUNCTION
*	You will get the number of supported 3D file formats of this library version.
* 
*   INPUTS
*	
*   RESULT
* 	number - Number of supported file formats or 0 if none.
*
*   EXAMPLE
*	number = MWL3DFileFormatNumberOfGet();
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	MWL3DFileFormatNamesGet(),MWL3DFileFormatIDGet()
*	MWL3DFileFormatNumberExtensionGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWL3DFileFormatNumberOfGet() {
	ULONG  i;
	STRPTR *sIndex=NULL;

	i=0;
	sIndex=c3dFFNames;
	while (sIndex[i]!=NULL) i++;
	
	return(i);
}

/****** meshwriter.library/MWLMeshSave3D ******************************************
* 
*   NAME	
* 	MWLMeshSave3D -- Saves the mesh as 3D file..
*
*   SYNOPSIS
*	error = MWLMeshSave3D( meshhandle,id,filename,taglist )
*	                       D1         D2 D3        A0
*
*	ULONG MWLMeshSave3D
*	     ( ULONG,ULONG,STRPTR,struct TagItem * );
*
*   FUNCTION
*	The mesh, this means vertices, polygons, materials, camera and light will
*	be saved in the specified 3d file format.
* 
*   INPUTS
* 	meshhandle  - A valid handle of a mesh.
*	id          - A valid 3D file format id, to spedify the output format.
*	filename    - Name and path of the file.
*	taglist     - NULL, for future use.
*	
*   RESULT
*	error - RCNOERROR                  if all went well.
*	        RCNOMESH                   if the handle is not valid.
*	        RCUNKNOWNFTYPE             if the id is not known.
*	        RCNOPOLYGON                if there are no polygons to save.
*	        RCCHGBUF                   if an error occured to allocate the save buffer.
*	        RCWRITEDATA                if an error occured while writing data, no more space...
*	        RCVERTEXOVERFLOW           if the format does not support as much vertices.
*	        RCVERTEXINPOLYGONOVERFLOW  if the format does not support as much vertices in a polygon.
*	        IoErr()                    if possible to catch it, you will get its codes.
*
*   EXAMPLE
*	error = MWLMeshSave3D(meshhandle,id,"ram:test",NULL);
*
*   NOTES
*	No file existence tests are made here! Existent files will be overwritten.
*
*   BUGS
* 
*   SEE ALSO
* 	MWL3DFileFormatIDGet(),MWLMeshSave2D()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshSave3D(register __d1 ULONG meshhandle,
									register __d2 ULONG id,
									register __d3 STRPTR filename,
									register __a0 struct TagItem *taglist) {
	TOCLMesh		*mesh;
	BPTR			filehandle=NULL;
	ULONG			retcode=RCNOERROR;
	UBYTE			i;
	struct TagItem	*mtaglist=NULL;
	
	// make a copy of taglist, a0 is a scratch register
	mtaglist=taglist;

	mesh = (TOCLMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);	
 
  	/*
  	** If there are no polygons, so leave
  	*/
	if(mesh->polygons.firstNode==NULL) return(RCNOPOLYGON);
	
	/*
	** Check if the filetype is valid
	*/
	i=0;
	while(c3dFFIDs[i]!=id && c3dFFIDs[i]!=0) {i++};
	if(c3dFFIDs[i]!=id || id==0) return(RCUNKNOWNFTYPE);
	
	/*
	** If no camera and light position was given, set it to default now
	*/
	if (!(mesh->camera.position.x &&
	     mesh->camera.position.y &&
	     mesh->camera.position.z &&
	     mesh->camera.lookat.x &&
	     mesh->camera.lookat.y &&
	     mesh->camera.lookat.z &&
	     mesh->light.position.x &&
	     mesh->light.position.y &&
	     mesh->light.position.z)) setCameraLight(mesh);

	/*
	** Open the file 
	*/
	/* Open the file for text output */
	if((filehandle=Open(filename,MODE_NEWFILE))==NULL) return(IoErr());

	/* Change the buffer size of the filehandle to 10k */
	if (SetVBuf(filehandle,NULL,BUF_FULL,10000)!=DOSFALSE) {
		Close(filehandle);
		return(RCCHGBUF);
	}

	/*
	** Write the mesh
	*/
	switch(id) {
		case T3DFRAWA :
			retcode = write3RAWA(filehandle,mesh);
			break;
		case T3DFRAWB :
			retcode = write3RAWB(filehandle,mesh);
			break;
		case T3DFDXF :
			retcode = write3DXF(filehandle,mesh);
			break;
		case T3DFVRML1 :
			retcode = write3VRML1(filehandle,mesh);
			break;
		case T3DFPOV3 :
			retcode = write3POV3(filehandle,mesh);
			break;
		case T3DFTDDD :
			retcode = write3TDDD(filehandle,mesh);
			break;
		case T3DFTDDDH :
			retcode = write3TDDDH(filehandle,mesh);
			break;
		case T3DFREF4 :
			retcode = write3REF4(filehandle,mesh);
			break;
		case T3DFLWOB :
			retcode = write3LWOB(filehandle,mesh);
			break;
		case T3DFGEOA :
			retcode = write3GEOA(filehandle,mesh);
			break;
//		case T3DFREAL :
//			retcode = write3REAL(filehandle,mesh);
//			break;
	}
	
	/*
	** Close the file
	*/
	Close(filehandle);
	
	return(retcode);
}

/****** meshwriter.library/MWL2DFileFormatNamesGet ******************************************
* 
*   NAME	
* 	MWL2DFileFormatNamesGet -- Get a name list of all supported 2D file formats.
* 
*   SYNOPSIS
*	list = MWL2DFileFormatNamesGet(  )
*
*	STRPTR * MWL2DFileFormatNamesGet
*	     (  );
*
*   FUNCTION
*	You will get a pointer to the namelist of all supported 2D file formats.
*	This strings are READ_ONLY and only valid as long as the library is opened.
*
*	The list is sorted alphabetically.
*
*	The resulting pointer can directly be used to fill up cycle or list gadgets
*	for example.
* 
*   INPUTS
*	
*   RESULT
* 	list - A NULL terminated array of string pointers. Or NULL if no
*	       files are supported.
*
*   EXAMPLE
*	list = MWL2DFileFormatNamesGet();
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	MWL2DFileFormatIDGet(),MWL2DFileFormatExtensionGet()
*	MWL2DFileFormatNumberOfGet()
* 
******************************************************************************
*
*/
STRPTR * __saveds ASM MWL2DFileFormatNamesGet() {
	if(c2dFFNames[0]!=NULL) return(c2dFFNames);
	return(NULL);
}

/****** meshwriter.library/MWL2DFileFormatIDGet ******************************************
* 
*   NAME	
* 	MWL2DFileFormatIDGet -- Get the ID of a specific 2D file format.
* 
*   SYNOPSIS
*	id = MWL2DFileFormatIDGet( ffname )
*	                           D1
*
*	ULONG MWL2DFileFormatIDGet
*	     ( STRPTR );
*
*   FUNCTION
*	You will get the ID of the 2D file format of which you passed its name.
* 
*   INPUTS
*	ffname - Name of the format you search the ID for.
*	
*   RESULT
* 	id - The ID of the 2D file format or 0 if not found/supported.
*
*   EXAMPLE
*	id = MWL2DFileFormatIDGet("PostScript");
*
*   NOTES
*	Even if the values of the IDs wont change in future versions, it is
*	recomended to show the list of all names to the user and let him choose
*	the format. With the help of this function you will get the correct
*	ID which is needed for further function calls.
*
*   BUGS
* 
*   SEE ALSO
* 	MWL2DFileFormatNamesGet(),MWL2DFileFormatExtensionGet()
*	MWL2DFileFormatNumberOfGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWL2DFileFormatIDGet(register __d1 STRPTR ffname) {
	ULONG i;
	STRPTR mffname=NULL;

	// make a copy of ffname, d1 is a scratch register
	mffname=ffname;

	i=0;
	while(strcmp(c2dFFNames[i],mffname) && c2dFFNames[i]!=NULL) {i++};
	
	// check if we got it or not
	if(!strcmp(c2dFFNames[i],mffname)) return(c2dFFIDs[i]);
	else return(0);
}

/****** meshwriter.library/MWL2DFileFormatExtensionGet ******************************************
* 
*   NAME	
* 	MWL2DFileFormatExtensionGet -- Get the file extension of a specific 2D file format.
* 
*   SYNOPSIS
*	ext = MWL2DFileFormatExtensionGet( ffid )
*	                                   D1
*
*	STRPTR MWL2DFileFormatExtensionGet
*	     ( ULONG );
*
*   FUNCTION
*	You will get a pointer to the extension of the specified 2D file format.
*	This strings are READ_ONLY and only valid as long as the library is opened.
* 
*   INPUTS
*	ffid - ID of the format you search the extension for.
*	
*   RESULT
* 	ext - Pointer to the file extension string or NULL if the format is unknown.
*
*   EXAMPLE
*	ext = MWL2DFileFormatExtensionGet(id);
*
*   NOTES
*	This extensions are proposals of the format creators, but you are free
*	to use them.
*
*   BUGS
* 
*   SEE ALSO
* 	MWL2DFileFormatNamesGet(),MWL2DFileFormatIDGet()
*	MWL2DFileFormatNumberOfGet()
* 
******************************************************************************
*
*/
STRPTR __saveds ASM MWL2DFileFormatExtensionGet(register __d1 ULONG ffid) {
	ULONG i,mffid;

	// make a copy of ffid, d1 is a scratch register
	mffid=ffid;
	
	i=0;
	while(c2dFFIDs[i]!=mffid && c2dFFIDs[i]!=0) {i++};
	
	// check if we got it or not
	if(c2dFFIDs[i]==mffid) return(c2dFFExtensions[i]);
	else return(NULL);
}

/****** meshwriter.library/MWL2DFileFormatNumberOfGet ******************************************
* 
*   NAME	
* 	MWL2DFileFormatNumberOfGet -- Get the number of supported 2D file formats.
* 
*   SYNOPSIS
*	number = MWL2DFileFormatNumberOfGet( )
*
*	ULONG MWL2DFileFormatNumberOfGet
*	     ( );
*
*   FUNCTION
*	You will get the number of supported 2D file formats of this library version.
* 
*   INPUTS
*	
*   RESULT
* 	number - Number of supported file formats or 0 if none.
*
*   EXAMPLE
*	number = MWL2DFileFormatNumberOfGet();
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	MWL2DFileFormatNamesGet(),MWL2DFileFormatIDGet()
*	MWL2DFileFormatNumberExtensionGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWL2DFileFormatNumberOfGet() {
	ULONG  i;
	STRPTR *sIndex=NULL;

	i=0;
	sIndex=c2dFFNames;
	while (sIndex[i]!=NULL) i++;
	
	return(i);
}

/****** meshwriter.library/MWLMeshSave2D ******************************************
* 
*   NAME	
* 	MWLMeshSave2D -- Saves the mesh as 2D file.
*
*   SYNOPSIS
*	error = MWLMeshSave2D( meshhandle,id,filename,viewtype,drawmode,taglist )
*	                       D1         D2 D3       D4       D5        A0
*
*	ULONG MWLMeshSave2D
*	     ( ULONG,ULONG,STRPTR,ULONG,ULONG,struct TagItem * );
*
*   FUNCTION
*	The mesh, this means vertices, polygons, materials, camera and light will
*	be used to generate and save a 2D file from a specific view point and
*	drawing mode.
* 
*   INPUTS
* 	meshhandle  - A valid handle of a mesh.
*	id          - A valid 2D file format id, to specify the output format.
*	filename    - Name and path of the file.
*	viewtype    - Type of view, like perspective, or top ...
*	drawmode    - Type of drawing, points, lines, surfaces ...
*	taglist     - NULL, for future use.
*	
*   RESULT
*	error - RCNOERROR         if all went well.
*	        RCNOMESH          if the handle is not valid.
*	        RCUNKNOWNFTYPE    if the id is not known.
*	        RCUNKNOWNDMODE    if the view mode in not known.
*	        RCNOPOLYGON       if there are no polygons to save.
*	        RCCHGBUF          if an error occured to allocate the save buffer.
*	        RCWRITEDATA       if an error occured while writing data, no more space...
*	        RCVERTEXOVERFLOW  if the format does not support as much vertices.
*	        IoErr()           if possible to catch it, you will get its codes.
*
*   EXAMPLE
*	error = MWLMeshSave2D(meshhandle,id,"ram:test",TVWPERSP,dm,NULL);
*
*   NOTES
*	No file existence tests are made here! Existent files will be overwritten.
*
*   BUGS
* 
*   SEE ALSO
* 	MWL2DFileFormatIDGet(),MWLDrawModeGet(),MWLMeshSave3D()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshSave2D(register __d1 ULONG meshhandle,
									register __d2 ULONG id,
									register __d3 STRPTR filename,
									register __d4 ULONG viewtype,
									register __d5 ULONG drawmode,
									register __a0 struct TagItem *taglist) {
	TOCLMesh		*mesh;
	BPTR			filehandle=NULL;
	ULONG			retcode=RCNOERROR;
	UBYTE			i;
	struct TagItem	*mtaglist=NULL;
	
	// make a copy of taglist, a0 is a scratch register
	mtaglist=taglist;

	mesh = (TOCLMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);	
 
  	/*
  	** If there are no polygons, so leave
  	*/
	if(mesh->polygons.firstNode==NULL) return(RCNOPOLYGON);
	
	/*
	** Check if the filetype is valid
	*/
	i=0;
	while(c2dFFIDs[i]!=id && c2dFFIDs[i]!=0) {i++};
	if(c2dFFIDs[i]!=id || id==0) return(RCUNKNOWNFTYPE);
	
	/*
	** Check if the viewtype is valid
	*/
	if(!(viewtype==TVWTOP ||
		viewtype==TVWBOTTOM ||
		viewtype==TVWLEFT ||
		viewtype==TVWRIGHT ||
		viewtype==TVWFRONT ||
		viewtype==TVWBACK ||
		viewtype==TVWPERSP)) return(RCUNKNOWNVTYPE);

	/*
	** Check if the drawmode is valid
	*/
	i=0;
	while(cDMIDs[i]!=drawmode && cDMIDs[i]!=0) {i++};
	if(cDMIDs[i]!=drawmode || drawmode==0) return(RCUNKNOWNDMODE);
	
	/*
	** If no camera and light position was given, set it to default now
	*/
	if (!(mesh->camera.position.x &&
	     mesh->camera.position.y &&
	     mesh->camera.position.z &&
	     mesh->camera.lookat.x &&
	     mesh->camera.lookat.y &&
	     mesh->camera.lookat.z &&
	     mesh->light.position.x &&
	     mesh->light.position.y &&
	     mesh->light.position.z)) setCameraLight(mesh);

	/*
	** Open the file 
	*/
	/* Open the file for text output */
	if((filehandle=Open(filename,MODE_NEWFILE))==NULL) return(IoErr());

	/* Change the buffer size of the filehandle to 10k */
	if (SetVBuf(filehandle,NULL,BUF_FULL,10000)!=DOSFALSE) {
		Close(filehandle);
		return(RCCHGBUF);
	}

	/*
	** Write the mesh
	*/
	switch(id) {
//		case T2DFEPS :
//			retcode = write2EPS(filehandle,mesh,viewtype,drawmode);
//			break;		
//		case T2DFPSP :
//			retcode = write2PSP(filehandle,mesh,viewtype,drawmode);
//			break;		
//		case T2DFPSL :
//			retcode = write2PSL(filehandle,mesh,viewtype,drawmode);
//			break;		
	}
	
	/*
	** Close the file
	*/
	Close(filehandle);
	
	return(retcode);
}
 
/****** meshwriter.library/MWLDrawModeNamesGet ******************************************
* 
*   NAME 
*        MWLDrawModeNamesGet -- Get a name list of all supported drawing modes.
* 
*   SYNOPSIS
*        list = MWLDrawModeNamesGet(  )
*
*        STRPTR * MWLDrawModeNamesGet
*             (  );
*
*   FUNCTION
*        You will get a pointer to the namelist of all supported drawing modes.
*        This strings are READ_ONLY and only valid as long as the library is opened.
*
*        The resulting pointer can directly be used to fill up cycle or list gadgets
*        for example.
*
*   INPUTS
*        
*   RESULT
*        list - A NULL terminated array of string pointers. Or NULL if no
*               modes are supported.
*
*   EXAMPLE
*        list = MWLDrawModeNamesGet();
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
*        MWLDrawModeIDGet(),MWLDrawModeNumberOfGet()
* 
******************************************************************************
*
*/
STRPTR * __saveds ASM MWLDrawModeNamesGet() {
	if(cDMNames[0]!=NULL) return(cDMNames);
	return(NULL);
}

/****** meshwriter.library/MWLDrawModeIDGet ******************************************
* 
*   NAME 
*        MWLDrawModeIDGet -- Get the ID of a specific drawing mode.
* 
*   SYNOPSIS
*        id = MWLDrawModeIDGet( dmname )
*                               D1
*
*        ULONG MWLDrawModeIDGet
*             ( STRPTR );
*
*   FUNCTION
*        You will get the ID of the drawing mode of which you passed its name.
* 
*   INPUTS
*        dm - Name of the drawing mode you search the ID for.
*        
*   RESULT
*        id - The ID of the drawing mode or 0 if not found/supported.
*
*   EXAMPLE
*        id = MWLDrawModeIDGet("Points");
*
*   NOTES
*        Even if the values of the IDs wont change in future versions, it is
*        recomended to show the list of all names to the user and let him choose
*        the format. With the help of this function you will get the correct
*        ID which is needed for further function calls.
*
*   BUGS
* 
*   SEE ALSO
*        MWLDrawModeNamesGet(),MWLDrawModeNumberOfGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLDrawModeIDGet(register __d1 STRPTR ffname) {
	ULONG i;
	STRPTR mffname=NULL;

	// make a copy of ffname, d1 is a scratch register
	mffname=ffname;

	i=0;
	while(strcmp(cDMNames[i],mffname) && cDMNames[i]!=NULL) {i++};
	
	// check if we got it or not
	if(!strcmp(cDMNames[i],mffname)) return(cDMIDs[i]);
	else return(0);
}

/****** meshwriter.library/MWLDrawModeNumberOfGet ******************************************
* 
*   NAME 
*        MWLDrawModeNumberOfGet -- Get the number of supported drawing modes.
* 
*   SYNOPSIS
*        number = MWLDrawModeNumberOfGet( )
*
*        ULONG MWLDrawModeNumberOfGet
*             ( );
*
*   FUNCTION
*        You will get the number of supported drawing modes of this library version.
* 
*   INPUTS
*        
*   RESULT
*        number - Number of supported drawing modes or 0 if none.
*
*   EXAMPLE
*        number = MWLDrawModeNumberOfGet();
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
*        MWLDrawModeNamesGet(),MWLDrawModeIDGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLDrawModeNumberOfGet() {
	ULONG  i;
	STRPTR *sIndex=NULL;

	i=0;
	sIndex=cDMNames;
	while (sIndex[i]!=NULL) i++;
	
	return(i);
}

/****** meshwriter.library/MWLMeshVertexAdd *************************************************
* 
*   NAME	
* 	MWLMeshVertexAdd -- Add a new vertex to the mesh its vertex list according the CTM.
*
*   SYNOPSIS
*	error = MWLMeshVertexAdd( meshhandle,vertex,index )
*	                          D1          A0    D2
*
*	ULONG MWLMeshVertexAdd
*	     ( ULONG,TOCLVertex *,ULONG * );
*
*   FUNCTION
*	A new vertex will be added to the mesh its vertex list, without binding it to any
*	polygon, which can be made later.
* 
*   INPUTS
* 	meshhandle   - A valid handle of a mesh.
*	vertex       - Pointer to a vertex structure which contains the coordinates
*	               of the new vertex.
*	index        - Pointer to a variable which will contain the index of the vertex,
*	               which will be needed for further use.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*	        RCNOMEMORY   if there is not enough memory. 
* 
*   EXAMPLE
*	error = MWLMeshVertexAdd(meshhandle,&myvertex,&myindex);
*
*   NOTES
*	File formats which have an internal vertex list will get all vertices
*	of the mesh, even if they were never used in a polygon.
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshPolygonVertexAssign()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshVertexAdd(register __d1 ULONG meshhandle,
									register __a0 TOCLVertex *vertex,
									register __d2 ULONG *index) {
                                
	TOCLMesh					*mesh=NULL;
	TOCLVertexNode				*ver=NULL;
	TOCLVertex					*mvertex=NULL;
      
	// make a copy of vertex, a0 is a scratch register
	mvertex=vertex;
	
	mesh=(TOCLMesh *) meshhandle;
	if (mesh==NULL) return(RCNOMESH);

	/*
	** Add a new vertice to the internal vertice list
	*/
	ver = addVertex(mesh,(*mvertex));
	if (ver==NULL) {
		return(RCNOMEMORY);
	}

	(*index)=ver->index;

	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshPolygonVertexAssign ***************************************
* 
*   NAME	
* 	MWLMeshPolygonVertexAssign -- Assigns an existing vertex to the most recent polygon.
*
*   SYNOPSIS
*	error = MWLMeshPolygonVertexAssign ( meshhandle,index )
*	                                     D1         D2
*
*	ULONG MWLMeshPolygonAssign
*	     ( ULONG,ULONG );
*
*   FUNCTION
*	An already existing vertex will be assigned to the polygon.
* 
*   INPUTS
* 	meshhandle   - A valid handle of a mesh.
*	index        - The index of the vertex.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*	        RCNOMEMORY   if there is not enough memory. 
*	        RCNOPOLYGON  if there is no polygon to work with.
*	        RCNOVERTEX   if the vertex is not existing.
* 
*   EXAMPLE
*	error = MWLMeshPolygonVertexAssign(meshhandle,index);
*
*   NOTES
*	Vertices have to be assigned in counterclock wise direction.
*
*	      v3
*	     / |
*	    /  |
*	   /   |
*	  /    |
*	 /     |
*	v1--->v2
*
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshVertexAdd()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshPolygonVertexAssign(register __d1 ULONG meshhandle,
												register __d2 ULONG index) {
                                
	TOCLMesh					*mesh=NULL;
	TOCLVertexNode				*ver=NULL;
	TOCLPolygonsVerticesNode	*plv=NULL;
	TOCLPolygonNode			*pln=NULL;
      
	mesh=(TOCLMesh *) meshhandle;
	if (mesh==NULL) return(RCNOMESH);

	if(mesh->polygons.lastNode==NULL) return(RCNOPOLYGON); /* There is no polygon to work with */

	ver=getVertex(mesh,index);
	if(ver==NULL) return(RCNOVERTEX); /* The vertex does not exist */

	/*
	** Add a new polygon vertex node to the polygon list its last element
	*/
	plv = AllocPooled(mesh->polygonverticespool,sizeof(TOCLPolygonsVerticesNode));
	if (plv==NULL) {
		return(RCNOMEMORY);
	}
        
	plv->vertexNode=ver;
	plv->next=NULL;

	pln=mesh->polygons.lastNode;
     
	if(pln->firstNode!=NULL) {   /* Check if this is the first vertex to insert or not */
		pln->lastNode->next=plv;
		pln->lastNode=plv;
	}
	else {
		pln->lastNode=plv;
		pln->firstNode=plv;
	}
	
	/*
	** Increment the number of vertices counter of the polygon
	*/
	pln->numberOfVertices++;
        
	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshCTMReset **********************************************
* 
*   NAME	
* 	MWLMeshCTMReset -- Resets the current transformation matrix and the scale.
*
*   SYNOPSIS
*	error = MWLMeshCTMReset( meshhandle )
*	                         D1
*
*	ULONG MWLMeshCTMReset
*	     ( ULONG );
*
*   FUNCTION
*	The translation, rotation and scale factors will be set to the default values.
*	Translation is 0, rotation is 0 and scale is 1, for all axis.
*
* 
*   INPUTS
* 	meshhandle   - A valid handle of a mesh.
*	
*   RESULT
* 	error - RCNOERROR          if all went well.
*	        RCNOMESH           if the handle is not valid.
* 
*   EXAMPLE
*	error = MWLMeshCTMReset(meshhandle);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshTranslationChange(), MWLMeshTranslationGet()
*	MWLMeshRotationChange(),MWLMeshRotationGet()
*	MWLMeshScaleChange(),MWLMeshScaleGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshCTMReset(register __d1 ULONG meshhandle) {
	TOCLMesh					*mesh=NULL;
      
	mesh=(TOCLMesh *) meshhandle;
	if (mesh==NULL) return(RCNOMESH);

	mesh->ctm.sx=1,mesh->ctm.sy=1,mesh->ctm.sz=1;
	mesh->ctm.rx=0,mesh->ctm.ry=0,mesh->ctm.rz=0;
	mesh->ctm.m[0][0]=1,mesh->ctm.m[1][0]=0,mesh->ctm.m[2][0]=0,mesh->ctm.m[3][0]=0;
	mesh->ctm.m[0][1]=0,mesh->ctm.m[1][1]=1,mesh->ctm.m[2][1]=0,mesh->ctm.m[3][1]=0;
	mesh->ctm.m[0][2]=0,mesh->ctm.m[1][2]=0,mesh->ctm.m[2][2]=1,mesh->ctm.m[3][2]=0;
	mesh->ctm.m[0][3]=0,mesh->ctm.m[1][3]=0,mesh->ctm.m[2][3]=0,mesh->ctm.m[3][3]=1;
	
	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshTranslationChange *****************************************
* 
*   NAME	
* 	MWLMeshTranslationChange -- Changes the translation of the CTM of the mesh.
*
*   SYNOPSIS
*	error = MWLMeshTranslationChange( meshhandle,translation,operation )
*	                                  D1          A0         D2
*
*	ULONG MWLMeshTranslationChange
*	     ( ULONG,TOCLVertex *,ULONG );
*
*   FUNCTION
*	The translation of the CTM will be modified in function of the translation
*	and the operation to perform.
* 
*   INPUTS
* 	meshhandle  - A valid handle of a mesh.
*	translation - Pointer to a vertex structure which contains the coordinates
*	              of the translation.
*	operation   - A valid CTM operation.
* 	              CTMADD,CTMSUB,CTMMUL
*	              CTMDIV,CTMSET,CTMRESET
*
*   RESULT
* 	error - RCNOERROR          if all went well.
*	        RCNOMESH           if the handle is not valid.
*	        RCINVALIDOPERATION if the operation is not value.
* 
*   EXAMPLE
*	error = MWLMeshTranslationChange(meshhandle,&mytranslation,myoperation);
*
*   NOTES
*	If you pass 0 values for a division operation,
*	the corresponding CTM entry will be set to 0.
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshCTMReset(), MWLMeshTranslationGet()
*	MWLMeshRotationChange(),MWLMeshRotationGet()
*	MWLMeshScaleChange(),MWLMeshScaleGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshTranslationChange(register __d1 ULONG meshhandle,
											register __a0 TOCLVertex *translation,
											register __d2 ULONG operation) {
                                
	TOCLMesh	*mesh=NULL;
	TOCLVertex	*tvertex=NULL;
      
	// make a copy of translation vertex, a0 is a scratch register
	tvertex=translation;
	
	mesh=(TOCLMesh *) meshhandle;
	if (mesh==NULL) return(RCNOMESH);

	switch (operation) {
		case CTMADD :
			mesh->ctm.m[3][0]+=tvertex->x;
			mesh->ctm.m[3][1]+=tvertex->y;
			mesh->ctm.m[3][2]+=tvertex->z;
		break;
		case CTMSUB :
			mesh->ctm.m[3][0]-=tvertex->x;
			mesh->ctm.m[3][1]-=tvertex->y;
			mesh->ctm.m[3][2]-=tvertex->z;
		break;
		case CTMMUL :
			mesh->ctm.m[3][0]*=tvertex->x;
			mesh->ctm.m[3][1]*=tvertex->y;
			mesh->ctm.m[3][2]*=tvertex->z;
		break;
		case CTMDIV :
			if(tvertex->x!=0) mesh->ctm.m[3][0]/=tvertex->x;
			else mesh->ctm.m[3][0]=0;
			if(tvertex->y!=0) mesh->ctm.m[3][1]/=tvertex->y;
			else mesh->ctm.m[3][1]=0;
			if(tvertex->z!=0) mesh->ctm.m[3][2]/=tvertex->z;
			else mesh->ctm.m[3][2]=0;
		break;
		case CTMSET :
			mesh->ctm.m[3][0]=tvertex->x;
			mesh->ctm.m[3][1]=tvertex->y;
			mesh->ctm.m[3][2]=tvertex->z;
		break;
		case CTMRESET :
			mesh->ctm.m[3][0]=0;
			mesh->ctm.m[3][1]=0;
			mesh->ctm.m[3][2]=0;
			mesh->ctm.m[3][3]=1;
		break;
		default :
			return(RCINVALIDOPERATION);
	}

	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshTranslationGet ********************************************
* 
*   NAME	
* 	MWLMeshTranslationGet -- Get the translation of the mesh its CTM.
*
*   SYNOPSIS
*	error = MWLMeshTranslationGet( meshhandle,translation )
*	                               D1          A0
*
*	ULONG MWLMeshTranslationGet
*	     ( ULONG,TOCLVertex * );
*
*   FUNCTION
*	The translation of the CTM will be returned in the passed vertex structure.
* 
*   INPUTS
* 	meshhandle  - A valid handle of a mesh.
*	translation - Pointer to a vertex structure which will contain the translation.
*
*   RESULT
* 	error - RCNOERROR          if all went well.
*	        RCNOMESH           if the handle is not valid.
* 
*   EXAMPLE
*	error = MWLMeshTranslationGet(meshhandle,&mytranslation);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshCTMReset(), MWLMeshTranslationChange()
*	MWLMeshRotationChange(),MWLMeshRotationGet()
*	MWLMeshScaleChange(),MWLMeshScaleGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshTranslationGet(register __d1 ULONG meshhandle,
											register __a0 TOCLVertex *translation) {
                                
	TOCLMesh	*mesh=NULL;
	TOCLVertex	*tvertex=NULL;
      
	// make a copy of translation vertex, a0 is a scratch register
	tvertex=translation;
	
	mesh=(TOCLMesh *) meshhandle;
	if (mesh==NULL) return(RCNOMESH);

	tvertex->x=mesh->ctm.m[3][0];
	tvertex->y=mesh->ctm.m[3][1];
	tvertex->z=mesh->ctm.m[3][2];
	
	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshScaleChange ***********************************************
* 
*   NAME	
* 	MWLMeshScaleChange -- Changes the scale of the CTM of the mesh.
*
*   SYNOPSIS
*	error = MWLMeshScaleChange( meshhandle,scale,operation )
*	                            D1          A0   D2
*
*	ULONG MWLMeshScaleChange
*	     ( ULONG,TOCLVertex *,ULONG );
*
*   FUNCTION
*	The scale of the CTM will be modified in function of the scale
*	and the operation to perform.
* 
*   INPUTS
* 	meshhandle  - A valid handle of a mesh.
*	scale       - Pointer to a vertex structure which contains the factor
*	              of the scaling.
*	operation   - A valid CTM operation.
* 	              CTMADD,CTMSUB,CTMMUL
*	              CTMDIV,CTMSET,CTMRESET
*
*   RESULT
* 	error - RCNOERROR          if all went well.
*	        RCNOMESH           if the handle is not valid.
*	        RCINVALIDOPERATION if the operation is not value.
* 
*   EXAMPLE
*	error = MWLMeshScaleChange(meshhandle,&myscale,myoperation);
*
*   NOTES
*	If you pass 0 values for a division operation,
*	the corresponding CTM entry will be set to 0.
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshTranslationChange(), MWLMeshTranslationGet()
*	MWLMeshRotationChange(),MWLMeshRotationGet()
*	MWLMeshCTMReset(),MWLMeshScaleGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshScaleChange(register __d1 ULONG meshhandle,
											register __a0 TOCLVertex *scale,
											register __d2 ULONG operation) {
                                
	TOCLMesh	*mesh=NULL;
	TOCLVertex	*svertex=NULL;
      
	// make a copy of scale vertex, a0 is a scratch register
	svertex=scale;
	
	mesh=(TOCLMesh *) meshhandle;
	if (mesh==NULL) return(RCNOMESH);

	switch (operation) {
		case CTMADD :
			mesh->ctm.sx+=svertex->x;
			mesh->ctm.sy+=svertex->y;
			mesh->ctm.sz+=svertex->z;
		break;
		case CTMSUB :
			mesh->ctm.sx-=svertex->x;
			mesh->ctm.sy-=svertex->y;
			mesh->ctm.sz-=svertex->z;
		break;
		case CTMMUL :
			mesh->ctm.sx*=svertex->x;
			mesh->ctm.sy*=svertex->y;
			mesh->ctm.sz*=svertex->z;
		break;
		case CTMDIV :
			if(svertex->x!=0) mesh->ctm.sx/=svertex->x;
			else mesh->ctm.sx=0;
			if(svertex->y!=0) mesh->ctm.sy/=svertex->y;
			else mesh->ctm.sy=0;
			if(svertex->z!=0) mesh->ctm.sz/=svertex->z;
			else mesh->ctm.sz=0;
		break;
		case CTMSET :
			mesh->ctm.sx=svertex->x;
			mesh->ctm.sy=svertex->y;
			mesh->ctm.sz=svertex->z;
		break;
		case CTMRESET :
			mesh->ctm.sx=1;
			mesh->ctm.sy=1;
			mesh->ctm.sz=1;
		break;
		default :
			return(RCINVALIDOPERATION);
	}

	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshScaleGet **************************************************
* 
*   NAME	
* 	MWLMeshScaleGet -- Get the scale of the mesh its CTM.
*
*   SYNOPSIS
*	error = MWLMeshScaleGet( meshhandle,scale )
*	                         D1          A0
*
*	ULONG MWLMeshScaleGet
*	     ( ULONG,TOCLVertex * );
*
*   FUNCTION
*	The scale of the CTM will be returned in the passed vertex structure.
* 
*   INPUTS
* 	meshhandle  - A valid handle of a mesh.
*	scale       - Pointer to a vertex structure which will contain the scale factors.
*
*   RESULT
* 	error - RCNOERROR          if all went well.
*	        RCNOMESH           if the handle is not valid.
* 
*   EXAMPLE
*	error = MWLMeshScaleGet(meshhandle,&myscale);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshTranslationChange(), MWLMeshTranslationChange()
*	MWLMeshRotationChange(),MWLMeshRotationGet()
*	MWLMeshScaleChange(),MWLMeshCTMReset()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshScaleGet(register __d1 ULONG meshhandle,
									register __a0 TOCLVertex *scale) {
                                
	TOCLMesh	*mesh=NULL;
	TOCLVertex	*svertex=NULL;
      
	// make a copy of scale vertex, a0 is a scratch register
	svertex=scale;
	
	mesh=(TOCLMesh *) meshhandle;
	if (mesh==NULL) return(RCNOMESH);

	svertex->x=mesh->ctm.sx;
	svertex->y=mesh->ctm.sy;
	svertex->z=mesh->ctm.sz;
	
	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshRotationChange ********************************************
* 
*   NAME	
* 	MWLMeshRotationChange -- Changes the rotation of the CTM of the mesh.
*
*   SYNOPSIS
*	error = MWLMeshRotationChange( meshhandle,rotation,operation )
*	                               D1          A0      D2
*
*	ULONG MWLMeshRotationChange
*	     ( ULONG,TOCLVertex *,ULONG );
*
*   FUNCTION
*	The rotation of the CTM will be modified in function of the rotation
*	and the operation to perform.
* 
*   INPUTS
* 	meshhandle - A valid handle of a mesh.
*	rotation   - Pointer to a vertex structure which contains the angles in radian
*	             of the rotation.
*	operation  - A valid CTM operation.
* 	             CTMADD,CTMSUB,CTMMUL
*	             CTMDIV,CTMSET,CTMRESET
*
*   RESULT
* 	error - RCNOERROR          if all went well.
*	        RCNOMESH           if the handle is not valid.
*	        RCINVALIDOPERATION if the operation is not value.
* 
*   EXAMPLE
*	error = MWLMeshRotationChange(meshhandle,&myrotation,myoperation);
*
*   NOTES
*	If you pass 0 values for a division operation,
*	the corresponding CTM entry will be set to 0.
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshTranslationChange(), MWLMeshTranslationGet()
*	MWLMeshCTMReset(),MWLMeshRotationGet()
*	MWLMeshScaleChange(),MWLMeshScaleGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshRotationChange(register __d1 ULONG meshhandle,
											register __a0 TOCLVertex *rotation,
											register __d2 ULONG operation) {
                                
	TOCLMesh	*mesh=NULL;
	TOCLVertex	*rvertex=NULL;
	double		m1[3][3],m2[3][3];
      
	// make a copy of rotation vertex, a0 is a scratch register
	rvertex=rotation;
	
	mesh=(TOCLMesh *) meshhandle;
	if (mesh==NULL) return(RCNOMESH);

	switch (operation) {
		case CTMADD :
			mesh->ctm.rx+=rvertex->x;
			mesh->ctm.ry+=rvertex->y;
			mesh->ctm.rz+=rvertex->z;
		break;
		case CTMSUB :
			mesh->ctm.rx-=rvertex->x;
			mesh->ctm.ry-=rvertex->y;
			mesh->ctm.rz-=rvertex->z;
		break;
		case CTMMUL :
			mesh->ctm.rx*=rvertex->x;
			mesh->ctm.ry*=rvertex->y;
			mesh->ctm.rz*=rvertex->z;
		break;
		case CTMDIV :
			if(rvertex->x!=0) mesh->ctm.rx/=rvertex->x;
			else mesh->ctm.rx=0;
			if(rvertex->y!=0) mesh->ctm.ry/=rvertex->y;
			else mesh->ctm.ry=0;
			if(rvertex->z!=0) mesh->ctm.rz/=rvertex->z;
			else mesh->ctm.rz=0;
		break;
		case CTMSET :
			mesh->ctm.rx=rvertex->x;
			mesh->ctm.ry=rvertex->y;
			mesh->ctm.rz=rvertex->z;
		break;
		case CTMRESET :
			mesh->ctm.rx=0;
			mesh->ctm.ry=0;
			mesh->ctm.rz=0;
		break;
		default :
			return(RCINVALIDOPERATION);
	}

	// If equal to 2*PI set to 0
	if(mesh->ctm.rx==2*PI) mesh->ctm.rx=0;
	if(mesh->ctm.ry==2*PI) mesh->ctm.ry=0;
	if(mesh->ctm.rz==2*PI) mesh->ctm.rz=0;

	// Recalculating the CTM
	m1[0][0]=1;
	m1[1][0]=0;
	m1[2][0]=0;
	m1[0][1]=0;
	m1[1][1]=1;
	m1[2][1]=0;
	m1[0][2]=0;
	m1[1][2]=0;
	m1[2][2]=1;

	m2[0][0]=cos(mesh->ctm.rz);
	m2[1][0]=-sin(mesh->ctm.rz);
	m2[2][0]=0;
	m2[0][1]=sin(mesh->ctm.rz);
	m2[1][1]=cos(mesh->ctm.rz);
	m2[2][1]=0;
	m2[0][2]=0;
	m2[1][2]=0;
	m2[2][2]=1;

	mulMatrix(m1,m2);

	m2[0][0]=cos(mesh->ctm.ry);
	m2[1][0]=0;
	m2[2][0]=sin(mesh->ctm.ry);
	m2[0][1]=0;
	m2[1][1]=1;
	m2[2][1]=0;
	m2[0][2]=-sin(mesh->ctm.ry);
	m2[1][2]=0;
	m2[2][2]=cos(mesh->ctm.ry);

	mulMatrix(m1,m2);

	m2[0][0]=1;
	m2[1][0]=0;
	m2[2][0]=0;
	m2[0][1]=0;
	m2[1][1]=cos(mesh->ctm.rx);
	m2[2][1]=-sin(mesh->ctm.rx);
	m2[0][2]=0;
	m2[1][2]=sin(mesh->ctm.rx);
	m2[2][2]=cos(mesh->ctm.rx);

	mulMatrix(m1,m2);

	mesh->ctm.m[0][0]=(TOCLFloat)m1[0][0];
	mesh->ctm.m[1][0]=(TOCLFloat)m1[1][0];
	mesh->ctm.m[2][0]=(TOCLFloat)m1[2][0];
	mesh->ctm.m[0][1]=(TOCLFloat)m1[0][1];
	mesh->ctm.m[1][1]=(TOCLFloat)m1[1][1];
	mesh->ctm.m[2][1]=(TOCLFloat)m1[2][1];
	mesh->ctm.m[0][2]=(TOCLFloat)m1[0][2];
	mesh->ctm.m[1][2]=(TOCLFloat)m1[1][2];
	mesh->ctm.m[2][2]=(TOCLFloat)m1[2][2];

	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshRotationGet ***********************************************
* 
*   NAME	
* 	MWLMeshRotationGet -- Get the rotation of the mesh its CTM.
*
*   SYNOPSIS
*	error = MWLMeshRotationGet( meshhandle,rotation )
*	                            D1          A0
*
*	ULONG MWLMeshRotationGet
*	     ( ULONG,TOCLVertex * );
*
*   FUNCTION
*	The rotation of the CTM will be returned in the passed vertex structure.
* 
*   INPUTS
* 	meshhandle - A valid handle of a mesh.
*	rotation   - Pointer to a vertex structure which will contain the
*	             rotation angles in radian.
*
*   RESULT
* 	error - RCNOERROR          if all went well.
*	        RCNOMESH           if the handle is not valid.
* 
*   EXAMPLE
*	error = MWLMeshRotationGet(meshhandle,&myrotation);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshtranslationChange(), MWLMeshTranslationChange()
*	MWLMeshRotationChange(),MWLMeshCTMReset()
*	MWLMeshScaleChange(),MWLMeshScaleGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshRotationGet(register __d1 ULONG meshhandle,
										register __a0 TOCLVertex *rotation) {
                                
	TOCLMesh	*mesh=NULL;
	TOCLVertex	*rvertex=NULL;
      
	// make a copy of rotation vertex, a0 is a scratch register
	rvertex=rotation;
	
	mesh=(TOCLMesh *) meshhandle;
	if (mesh==NULL) return(RCNOMESH);

	rvertex->x=mesh->ctm.rx;
	rvertex->y=mesh->ctm.ry;
	rvertex->z=mesh->ctm.rz;
	
	return(RCNOERROR);
}
/****** meshwriter.library/MWLMeshMaterialDiffuseColorSet ******************************************
* 
*   NAME	
* 	MWLMeshMaterialDiffuseColorSet -- Set the diffuse color of a material.
* 
*   SYNOPSIS
*	error = MWLMeshMaterialDiffuseColorSet( meshhandle,materialhandle,color )
*	                                        D1         D2              A0
*
*	ULONG MWLMeshMaterialDiffuseColorSet
*	     ( ULONG,ULONG,TOCLColor * );
*
*   FUNCTION
*	The diffuse color of the material will be set to the values passed by the
*	color structure.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	materialhandle  - A valid handle of a material.
*	color           - Pointer to a color structure containing the color information.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*	        RCNOMATERIAL if the handle is not valid.
*
*   EXAMPLE
*	error = MWLMeshMaterialDiffuseColorSet(meshhandle,materialhandle,&mycolor);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshMaterialDiffuseColorGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshMaterialDiffuseColorSet(register __d1 ULONG meshhandle,
														register __d2 ULONG materialhandle,
														register __a0 TOCLColor *color) {
	TOCLMesh			*mesh=NULL;
	TOCLMaterialNode	*mat=NULL;
	TOCLColor			*mcolor=NULL;

	// make a copy of color, because a0 is a scratch register
	mcolor = color;
	
	mesh=(TOCLMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);
  
	mat=getMaterialNode(mesh,materialhandle);
	if(mat==NULL) return(RCNOMATERIAL);
  
	mat->diffuseColor=(*mcolor);
	
	return(RCNOERROR);
}

/****** meshwriter.library/MWLMeshMaterialDiffuseColorGet ******************************************
* 
*   NAME	
* 	MWLMeshMaterialDiffuseColorGet -- Get the diffuse color of a material.
* 
*   SYNOPSIS
*	error = MWLMeshMaterialDiffuseColorGet( meshhandle,materialhandle,color )
*	                                        D1         D2              A0
*
*	ULONG MWLMeshMaterialDiffuseColorGet
*	     ( ULONG,ULONG,TOCLColor * );
*
*   FUNCTION
*	The diffuse color of the material will be written in the passed color structure.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	materialhandle  - A valid handle of a material.
*	color           - Pointer to a color structure which will contain
*	                  the color information.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*	        RCNOMATERIAL if the handle is not valid.
*
*   EXAMPLE
*	error = MWLMeshMaterialDiffuseColorGet(meshhandle,materialhandle,&mycolor);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	MWLMeshMaterialDiffuseColorSet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM MWLMeshMaterialDiffuseColorGet(register __d1 ULONG meshhandle,
														register __d2 ULONG materialhandle,
														register __a0 TOCLColor *color) {
	TOCLMesh			*mesh=NULL;
	TOCLMaterialNode	*mat=NULL;
	TOCLColor			*mcolor=NULL;
	
	// make a copy of color, a0 is a scratch register
	mcolor=color;
	
	mesh=(TOCLMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);
  
	mat=getMaterialNode(mesh,materialhandle);
	if(mat==NULL) return(RCNOMATERIAL);
  
	(*mcolor)=mat->diffuseColor;
	
	return(RCNOERROR);
}

/*
TODO

Lightwave,Imagine,Videoscape  groessen/anzahl checks fertigmachen !!

Material mehr parameter, brechungsindex, reflektion, ...

*/

/************************* End of file ******************************/

