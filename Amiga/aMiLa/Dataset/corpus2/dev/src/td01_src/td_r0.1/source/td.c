/*
**      $VER: td.c 0.1 (20.6.99)
**
**      Creation date     : 11.4.1999
**
**      Description       :
**         td library.
**
**
**      Written by Stephan Bielmann
**
*/

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
#include <dos/exall.h>

#include <clib/dos_protos.h>
#include <clib/alib_stdio_protos.h>

#include <pragma/exec_lib.h>

/*
** Project includes
*/
#include "td_private.h"
#include "compiler.h"
#include "pragma/x3_lib.h"
//#include "include/td/tdbase.h"

/*************************** Defines ********************************/

#define EXALLBUFFERSIZE 2048	// Buffer size for exall dir scan

/********************** Private constants ***************************/

/*
** The library information structure
*/
TDlibraryinfo *tdlibinfos=NULL;

/*
** The supported file format arrays
*/
static STRPTR 	*c3dsLib=NULL;
static STRPTR	*c3dsNames=NULL;
static STRPTR	*c3dsExt=NULL;
static STRPTR 	*c3dlLib=NULL;
static STRPTR	*c3dlNames=NULL;

//!!!!!!!!!!!!! alles in base !! globales zeug !!!!!!!!!!!!!!!!!!

//dummi hummi
/*
static ULONG c3dFFIDs [] = { 0 };

static STRPTR  c3dFFLib [] = {
	"dxf.library",
	NULL
};

static STRPTR c3dFFNames [] = {
	"AutoCAD DXF",
	NULL
};

static STRPTR c3dFFExtensions [] = {
	"dxf",
	NULL
};

static ULONG  c2dFFIDs   [] = {
	T2DFEPS,
	0
};

static STRPTR c2dFFNames [] = {
	"Encapsulated PostScript",
	NULL
};

static STRPTR c2dFFExtensions [] = {
	"eps",
	NULL
};
*/

/*
** The constant supported drawing mode arrays
*/
static ULONG  cDMIDs   [] = {
	DMPOINTS,
	DMWIREBW,
	DMWIREGR,
	DMWIRECL,
	DMHIDDBW,
	DMHIDDGR,
	DMHIDDCL,
	DMSURFBW,
	DMSURFGR,
	DMSURFCL,
	0
};

static STRPTR  cDMNames   [] = {
	"Points, black and white",
	"Wireframe, black and white",
	"Wireframe, gray scales",
	"Wireframe, colors",
	"Hidden line, black and white",
	"Hidden line, gray scales",
	"Hidden line, colors",
	"Surface, black and white",
	"Surface, gray scales",
	"Surface, colors",
	NULL
};

/*
** Definition of PI
*/
#define PI 3.14159265359

/********************** Global variables ****************************/

struct x3Base *x3Base = NULL;

/********************** Private functions ***************************/

/********************************************************************\
*                                                                    *
* Name         : addMaterialNode                                     *
*                                                                    *
* Description  : Add a new material node to the space.               *
*                                                                    *
* Arguments    : space  IN : Pointer to the space.                   *
*                type   IN : Type of material.                       *
*                                                                    *
* Return Value : Index of the new material or 0 if no more memory.   *
*                                                                    *
* Comment      : The array indices are beginnning at 0, index at 1   *
*                                                                    *
\********************************************************************/
static ULONG addMaterialNode(TDspace *space,TDenum type) {
	TDmaterialnode		*mat=NULL;
	TDsurface			*surf=NULL;
	TDtexture			*tex=NULL;
	UBYTE				buffer[100];
	ULONG				matnode,matblock;
	ULONG				realmat;
	
	// check if we have still place for a material node
	matnode=(space->materials.numberOfMaterials)%Ci_MATNODESINBLOCK;
	matblock=((space->materials.numberOfMaterials)-matnode)/Ci_MATNODESINBLOCK;

	// we are above our internal limit
	if(matblock>=Ci_MATBLOCKS) return(0);

	// check if we have to allocate a new nodes list block
	if(matnode==0) {
		space->materials.blocks[matblock]=AllocPooled(space->matblockspool,sizeof(TDmaterialblock));
		if(space->materials.blocks[matblock]==NULL) return(0);
	}

	mat = AllocMem(sizeof(TDmaterialnode),MEMF_FAST);
	if (mat==NULL) {
		return(0);
	}

	mat->name=NULL;
	sprintf(buffer,"tdMAT%ld",space->materials.numberOfMaterials);
	mat->name = AllocVec(strlen(buffer)+1,MEMF_FAST);
	if (mat->name==NULL) {
		FreeMem(mat,sizeof(TDmaterialnode));
		return(0);
	}
	strcpy(mat->name,buffer);

	//create the desired type of material
	switch(type) {
		case TD_SURFACE :
			surf=AllocVec(sizeof(TDsurface),MEMF_FAST);
			if(surf!=NULL) {
				surf->ambientColor.r=0;
				surf->ambientColor.g=0;
				surf->ambientColor.b=0;
				surf->diffuseColor.r=0;
				surf->diffuseColor.g=0;
				surf->diffuseColor.b=0;
				surf->shininess=0;
				surf->transparency=0;

				realmat=(ULONG)surf;
			} else {
				realmat=0;
			}
			break;

		case TD_TEXTURE :
			tex=AllocVec(sizeof(TDtexture),MEMF_FAST);
			if(tex!=NULL) {
				realmat=(ULONG)tex;
			} else {
				realmat=0;
			}
			break;

		default :
			realmat=0;
			break;
	}

	if(realmat==0) {
		FreeVec(mat->name);
		FreeMem(mat,sizeof(TDmaterialnode));
		return(0);
	}

	mat->handle=realmat;
	mat->type=type;

	// last increment the numberOfMaterials counter and index assignment
	mat->index=++(space->materials.numberOfMaterials);

	// assign the node to the nodes list
	space->materials.blocks[matblock]->nodes[matnode]=mat;

	return(mat->index);
}

/********************************************************************\
*                                                                    *
* Name         : getMaterialNode                                     *
*                                                                    *
* Description  : Search the material its node with its index, in     *
*                the given space. If the index is not valid, NULL    *
*                will be returned.                                   *
*                                                                    *
* Arguments    : space          IN : Pointer to the space            *
*                materialindex  IN : Material index                  *
*                                                                    *
* Return Value : Pointer to the material or NULL if not found.       *
*                                                                    *
* Comment      : The array indices are beginnning at 0, index at 1   *
*                                                                    *
\********************************************************************/
static TDmaterialnode *getMaterialNode(TDspace *space, ULONG materialindex) {
	ULONG matblock,matnode;

	// if we have materials, and the index is between 1 and numberOfMaterials
	if(space->materials.numberOfMaterials==0) return(NULL);
	if(materialindex<1 || materialindex>space->materials.numberOfMaterials) return(NULL);

	// internal index is index - 1
	materialindex--;

	// compute the block and node and return the material node
	matnode=materialindex%Ci_MATNODESINBLOCK;
	matblock=(materialindex-matnode)/Ci_MATNODESINBLOCK;
	return(space->materials.blocks[matblock]->nodes[matnode]);
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
static VOID mulMatrix (double m1[3][3], double m2[3][3]) {
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

/********************************************************************\
*                                                                    *
* Name         : translationChange                                   *
*                                                                    *
* Description  : Changes the translation in function of the operation*
*                                                                    *
* Arguments    : space        IN : Pointer to the space.             *
*	             tvertex      IN : Vertex with coordinates.          *
*                operation    IN : Operation to perform.             *
*                                                                    *
* Return Value : 0 if ok 1 if the operation is invalid.              *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static ULONG translationChange(TDspace *space,TDvectord tvertex, TDenum operation) {

	switch (operation) {
		case TD_ADD :
			space->ctm.m[3][0]+=tvertex.x;
			space->ctm.m[3][1]+=tvertex.y;
			space->ctm.m[3][2]+=tvertex.z;
		break;
		case TD_SUB :
			space->ctm.m[3][0]-=tvertex.x;
			space->ctm.m[3][1]-=tvertex.y;
			space->ctm.m[3][2]-=tvertex.z;
		break;
		case TD_MUL :
			space->ctm.m[3][0]*=tvertex.x;
			space->ctm.m[3][1]*=tvertex.y;
			space->ctm.m[3][2]*=tvertex.z;
		break;
		case TD_DIV :
			if(tvertex.x!=0) space->ctm.m[3][0]/=tvertex.x;
			else space->ctm.m[3][0]=0;
			if(tvertex.y!=0) space->ctm.m[3][1]/=tvertex.y;
			else space->ctm.m[3][1]=0;
			if(tvertex.z!=0) space->ctm.m[3][2]/=tvertex.z;
			else space->ctm.m[3][2]=0;
		break;
		case TD_SET :
			space->ctm.m[3][0]=tvertex.x;
			space->ctm.m[3][1]=tvertex.y;
			space->ctm.m[3][2]=tvertex.z;
		break;
		case TD_RESET :
			space->ctm.m[3][0]=0;
			space->ctm.m[3][1]=0;
			space->ctm.m[3][2]=0;
			space->ctm.m[3][3]=1;
		break;
		default :
			return(1);
	}

	return(0);
}

/********************************************************************\
*                                                                    *
* Name         : scaleChange                                         *
*                                                                    *
* Description  : Changes the scale in function of the operation      *
*                                                                    *
* Arguments    : space        IN : Pointer to the space.             *
*	             svertex      IN : Vertex with coordinates.          *
*                operation    IN : Operation to perform.             *
*                                                                    *
* Return Value : 0 if ok, 1 if the operation is not valid.           *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static ULONG scaleChange(TDspace *space,TDvectord svertex, TDenum operation) {

	switch (operation) {
		case TD_ADD :
			space->ctm.sx+=svertex.x;
			space->ctm.sy+=svertex.y;
			space->ctm.sz+=svertex.z;
		break;
		case TD_SUB :
			space->ctm.sx-=svertex.x;
			space->ctm.sy-=svertex.y;
			space->ctm.sz-=svertex.z;
		break;
		case TD_MUL :
			space->ctm.sx*=svertex.x;
			space->ctm.sy*=svertex.y;
			space->ctm.sz*=svertex.z;
		break;
		case TD_DIV :
			if(svertex.x!=0) space->ctm.sx/=svertex.x;
			else space->ctm.sx=0;
			if(svertex.y!=0) space->ctm.sy/=svertex.y;
			else space->ctm.sy=0;
			if(svertex.z!=0) space->ctm.sz/=svertex.z;
			else space->ctm.sz=0;
		break;
		case TD_SET :
			space->ctm.sx=svertex.x;
			space->ctm.sy=svertex.y;
			space->ctm.sz=svertex.z;
		break;
		case TD_RESET :
			space->ctm.sx=1;
			space->ctm.sy=1;
			space->ctm.sz=1;
		break;
		default :
			return(1);
	}

	return(0);
}

/********************************************************************\
*                                                                    *
* Name         : rotationChange                                      *
*                                                                    *
* Description  : Changes the rotation in function of the operation   *
*                                                                    *
* Arguments    : space        IN : Pointer to the space.             *
*	             rvertex      IN : Vertex with coordinates.          *
*                operation    IN : Operation to perform.             *
*                                                                    *
* Return Value : 0 if ok, 1 if the operation is not valid.           *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static ULONG rotationChange(TDspace *space,TDvectord rvertex, TDenum operation) {
	TDdouble	m1[3][3],m2[3][3];

	switch (operation) {
		case TD_ADD :
			space->ctm.rx+=rvertex.x;
			space->ctm.ry+=rvertex.y;
			space->ctm.rz+=rvertex.z;
		break;
		case TD_SUB :
			space->ctm.rx-=rvertex.x;
			space->ctm.ry-=rvertex.y;
			space->ctm.rz-=rvertex.z;
		break;
		case TD_MUL :
			space->ctm.rx*=rvertex.x;
			space->ctm.ry*=rvertex.y;
			space->ctm.rz*=rvertex.z;
		break;
		case TD_DIV :
			if(rvertex.x!=0) space->ctm.rx/=rvertex.x;
			else space->ctm.rx=0;
			if(rvertex.y!=0) space->ctm.ry/=rvertex.y;
			else space->ctm.ry=0;
			if(rvertex.z!=0) space->ctm.rz/=rvertex.z;
			else space->ctm.rz=0;
		break;
		case TD_SET :
			space->ctm.rx=rvertex.x;
			space->ctm.ry=rvertex.y;
			space->ctm.rz=rvertex.z;
		break;
		case TD_RESET :
			space->ctm.rx=0;
			space->ctm.ry=0;
			space->ctm.rz=0;
		break;
		default :
			return(1);
	}

	// If equal to 2*PI set to 0
	if(space->ctm.rx==2*PI) space->ctm.rx=0;
	if(space->ctm.ry==2*PI) space->ctm.ry=0;
	if(space->ctm.rz==2*PI) space->ctm.rz=0;

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

	m2[0][0]=cos(space->ctm.rz);
	m2[1][0]=-sin(space->ctm.rz);
	m2[2][0]=0;
	m2[0][1]=sin(space->ctm.rz);
	m2[1][1]=cos(space->ctm.rz);
	m2[2][1]=0;
	m2[0][2]=0;
	m2[1][2]=0;
	m2[2][2]=1;

	mulMatrix(m1,m2);

	m2[0][0]=cos(space->ctm.ry);
	m2[1][0]=0;
	m2[2][0]=sin(space->ctm.ry);
	m2[0][1]=0;
	m2[1][1]=1;
	m2[2][1]=0;
	m2[0][2]=-sin(space->ctm.ry);
	m2[1][2]=0;
	m2[2][2]=cos(space->ctm.ry);

	mulMatrix(m1,m2);

	m2[0][0]=1;
	m2[1][0]=0;
	m2[2][0]=0;
	m2[0][1]=0;
	m2[1][1]=cos(space->ctm.rx);
	m2[2][1]=-sin(space->ctm.rx);
	m2[0][2]=0;
	m2[1][2]=sin(space->ctm.rx);
	m2[2][2]=cos(space->ctm.rx);

	mulMatrix(m1,m2);

	space->ctm.m[0][0]=m1[0][0];
	space->ctm.m[1][0]=m1[1][0];
	space->ctm.m[2][0]=m1[2][0];
	space->ctm.m[0][1]=m1[0][1];
	space->ctm.m[1][1]=m1[1][1];
	space->ctm.m[2][1]=m1[2][1];
	space->ctm.m[0][2]=m1[0][2];
	space->ctm.m[1][2]=m1[1][2];
	space->ctm.m[2][2]=m1[2][2];

	return(0);
}

/********************************************************************\
*                                                                    *
* Name         : getMatGroupNode                                     *
*                                                                    *
* Description  : Search the matgroup its node with its index, in     *
*                the given mesh. If the index is not valid, NULL     *
*                will be returned.                                   *
*                                                                    *
* Arguments    : mesh          IN : Pointer to the mesh.             *
*                matgroupindex IN : Matgroup index.                  *
*                                                                    *
* Return Value : Pointer to the matgroup or NULL if not found.       *
*                                                                    *
* Comment      : The array indices are beginnning at 0, index at 1   *
*                                                                    *
\********************************************************************/
static TDmatgroupnode *getMatGroupNode(TDpolymesh *mesh, ULONG matgroupindex) {
	ULONG matgroupblock,matgroupnode;

	// if we have matgroups, and the index is between 1 and numberOfMatGroupss
	if(mesh->matgroups.numberOfMatGroups==0) return(NULL);
	if(matgroupindex<1 || matgroupindex>mesh->matgroups.numberOfMatGroups) return(NULL);

	// internal index is - 1
	matgroupindex--;

	// compute the block and node and return the matgroup node
	matgroupnode=matgroupindex%Ci_MATGROUPNODESINBLOCK;
	matgroupblock=(matgroupindex-matgroupnode)/Ci_MATGROUPNODESINBLOCK;
	return(mesh->matgroups.blocks[matgroupblock]->nodes[matgroupnode]);
}

/********************************************************************\
*                                                                    *
* Name         : cleanPolyMesh                                       *
*                                                                    *
* Description  : If an error occurs while creating a new mesh, call  *
*                this one to delete it.                              *
*                                                                    *
* Arguments    : mesh   IN : Pointer to the mesh.                    *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static VOID cleanPolyMesh(TDpolymesh *mesh) {

	DeletePool(mesh->vertexpool);
	DeletePool(mesh->vertexarraypool);
	DeletePool(mesh->vertexblockspool);
	DeletePool(mesh->polyverpool);
	DeletePool(mesh->polypool);
	DeletePool(mesh->polyarraypool);
	DeletePool(mesh->polyblockspool);
	DeletePool(mesh->matgroupblockspool);
	FreeMem(mesh,sizeof(TDpolymesh));
};

/********************************************************************\
*                                                                    *
* Name         : newPolyMesh                                         *
*                                                                    *
* Description  : Creates and initializes a new polymesh.             *
*                                                                    *
* Return Value : Handle of the new mesh or 0 if no more memory.      *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static ULONG newPolyMesh() {
	TDpolymesh	*mesh=NULL;

	mesh = AllocMem(sizeof(TDpolymesh),MEMF_FAST);
	if (mesh==NULL) return(0);

	// initialize the pool headers and other pointers
	mesh->vertexpool=NULL;
	mesh->vertexarraypool=NULL;
	mesh->vertexblockspool=NULL;
	mesh->polyverpool=NULL;
	mesh->polypool=NULL;
	mesh->polyarraypool=NULL;
	mesh->polyblockspool=NULL;
	mesh->matgroupblockspool=NULL;

	mesh->curpolyn=NULL;
	mesh->curmatgroupn=NULL;

	// create a memory pool for the vertices of this this mesh
	// ground size of a pool is to get 100 vertices
	mesh->vertexpool=CreatePool(MEMF_FAST,100*sizeof(TDvectord),100*sizeof(TDvectord));
	if(mesh->vertexpool==NULL) {
		cleanPolyMesh(mesh);
		return(0);
	}

	// create a memory pool for the vertex arrays of this this mesh
	// ground size of a pool is to get one array of vertices
	mesh->vertexarraypool=CreatePool(MEMF_FAST,sizeof(TDvertexarray),sizeof(TDvertexarray));
	if(mesh->vertexarraypool==NULL) {
		cleanPolyMesh(mesh);
		return(0);
	}

	// create a memory pool for the vertex blocks of this this mesh
	// ground size of a pool is to get one block of vertex arrays
	mesh->vertexblockspool=CreatePool(MEMF_FAST,sizeof(TDvertexblock),sizeof(TDvertexblock));
	if(mesh->vertexblockspool==NULL) {
		cleanPolyMesh(mesh);
		return(0);
	}

	// create a memory pool for the polygon vertex array of this this mesh
	// ground size of a pool is to get one vertex in the array
	mesh->polyverpool=CreatePool(MEMF_FAST,sizeof(ULONG),sizeof(ULONG));
	if(mesh->polyverpool==NULL) {
		cleanPolyMesh(mesh);
		return(0);
	}

	// create a memory pool for the polygons of this this mesh
	// ground size of a pool is to get 100 polygons
	mesh->polypool=CreatePool(MEMF_FAST,100*sizeof(TDpolygonnode),100*sizeof(TDpolygonnode));
	if(mesh->polypool==NULL) {
		cleanPolyMesh(mesh);
		return(0);
	}

	// create a memory pool for the polygon arrays of this this mesh
	// ground size of a pool is to get one array of polygons
	mesh->polyarraypool=CreatePool(MEMF_FAST,sizeof(TDpolygonarray),sizeof(TDpolygonarray));
	if(mesh->polyarraypool==NULL) {
		cleanPolyMesh(mesh);
		return(0);
	}

	// create a memory pool for the polygon blocks of this this mesh
	// ground size of a pool is to get one block of polygon arrays
	mesh->polyblockspool=CreatePool(MEMF_FAST,sizeof(TDpolygonblock),sizeof(TDpolygonblock));
	if(mesh->polyblockspool==NULL) {
		cleanPolyMesh(mesh);
		return(0);
	}

	// create a memory pool for the matgroup block lists of this this mesh
	// ground size of a pool is one block of matgroups
	mesh->matgroupblockspool=CreatePool(MEMF_FAST,sizeof(TDmatgroupblock),sizeof(TDmatgroupblock));
	if(mesh->matgroupblockspool==NULL) {
		cleanPolyMesh(mesh);
		return(0);
	}

	mesh->bBox.left=0.0;
	mesh->bBox.right=0.0;
	mesh->bBox.front=0.0;
	mesh->bBox.rear=0.0;
	mesh->bBox.top=0.0;
	mesh->bBox.bottom=0.0;
	
	mesh->vertices.numberOfVertices=0;
        
	mesh->matgroups.numberOfMatGroups=0;
	mesh->matgroups.numberOfPolygons=0;

	return(ULONG)mesh;
}

/********************************************************************\
*                                                                    *
* Name         : delPolyMesh                                         *
*                                                                    *
* Description  : Deletes a polymesh and sub components.              *
*                                                                    *
* Arguments    : mesh  IN : Pointer to the mesh.                     *
*                                                                    *
\********************************************************************/
static VOID delPolyMesh(TDpolymesh *mesh) {
	TDmatgroupnode	*matgroup;
	ULONG		i;

	/*
	** Free the vertices
	*/
	DeletePool(mesh->vertexpool);
	DeletePool(mesh->vertexarraypool);
	DeletePool(mesh->vertexblockspool);

	/*
	** Free the polygons
	*/
	DeletePool(mesh->polyverpool);
	DeletePool(mesh->polypool);
	DeletePool(mesh->polyarraypool);
	DeletePool(mesh->polyblockspool);

	/*
	** Free the matgroups and the nodeslist
	*/
	for(i=1;i<=mesh->matgroups.numberOfMatGroups;i++) {
		matgroup=getMatGroupNode(mesh,i);

		FreeMem(matgroup,sizeof(TDmatgroupnode));
	}
	DeletePool(mesh->matgroupblockspool);

	/*
	** Free the mesh itself
	*/
	FreeMem(mesh,sizeof(TDpolymesh));
}

/********************************************************************\
*                                                                    *
* Name         : addObjectNode                                       *
*                                                                    *
* Description  : Add a new object node to the space.                 *
*                                                                    *
* Arguments    : space  IN : Pointer to the space.                   *
*                type   IN : Type of object.                         *
*                                                                    *
* Return Value : Index of the new object or 0 if no more memory.     *
*                                                                    *
* Comment      : The array indices are beginnning at 0, index at 1   *
*                                                                    *
\********************************************************************/
static ULONG addObjectNode(TDspace *space,TDenum type) {
	TDobjectnode		*object=NULL;
	TDcube				*cube=NULL;
	TDtexbinding		*texbind=NULL;
	UBYTE				buffer[100];
	ULONG				objectnode,objectblock,realobject;
	
	// check if we have still place for an object node
	objectnode=(space->objects.numberOfObjects)%Ci_OBJECTNODESINBLOCK;
	objectblock=((space->objects.numberOfObjects)-objectnode)/Ci_OBJECTNODESINBLOCK;

	// we are above our internal limit
	if(objectblock>=Ci_OBJECTBLOCKS) return(0);

	// check if we have to allocate a new nodes list block
	if(objectnode==0) {
		space->objects.blocks[objectblock]=AllocPooled(space->objectblockspool,sizeof(TDobjectblock));
		if(space->objects.blocks[objectblock]==NULL) return(0);
	}

	object = AllocMem(sizeof(TDobjectnode),MEMF_FAST);
	if (object==NULL) {
		return(0);
	}

	object->name=NULL;
	sprintf(buffer,"tdMESH%ld",space->objects.numberOfObjects);
	object->name = AllocVec(strlen(buffer)+1,MEMF_FAST);
	if (object->name==NULL) {
		FreeMem(object,sizeof(TDobjectnode));
		return(0);
	}
	strcpy(object->name,buffer);

	// creating the mesh itself
	switch(type) {
		case TD_POLYMESH :
			realobject=newPolyMesh();

			break;
		case TD_CUBE :
			cube=AllocMem(sizeof(TDcube),MEMF_FAST);
			if(cube==NULL) {
				realobject=0;
			} else {
				cube->size.x=0.0;cube->size.y=0,0;cube->size.z=0.0;
				realobject=(ULONG)cube;
			}

			break;
		case TD_TEXBINDING :
			texbind=AllocMem(sizeof(TDtexbinding),MEMF_FAST);
			if(texbind==NULL) {
				realobject=0;
			} else {
				realobject=(ULONG)texbind;
			}

			break;
		default :
			realobject=0;
	}

	if(realobject==0) {
		FreeVec(object->name);
		FreeMem(object,sizeof(TDobjectnode));
		return(0);
	}

	object->type=type;
	object->handle=realobject;

	object->s.x=1.0;
	object->s.y=1.0;
	object->s.z=1.0;

	object->r.x=0.0;
	object->r.y=0.0;
	object->r.z=0.0;

	object->o.x=0.0;
	object->o.y=0.0;
	object->o.z=0.0;
	
	// assign the node to the nodes list
	space->objects.blocks[objectblock]->nodes[objectnode]=object;

	// last increment the numberOfObjects counter
	space->objects.numberOfObjects++;

	return(space->objects.numberOfObjects);
}

/********************************************************************\
*                                                                    *
* Name         : getObjectNode                                       *
*                                                                    *
* Description  : Search the object its node with its index, in       *
*                the given space. If the index is not valid, NULL    *
*                will be returned.                                   *
*                                                                    *
* Arguments    : space          IN : Pointer to the space            *
*                objectindex    IN : Object index                    *
*                                                                    *
* Return Value : Pointer to the object or NULL if not found.         *
*                                                                    *
* Comment      : The array indices are beginnning at 0, index at 1   *
*                                                                    *
\********************************************************************/
static TDobjectnode *getObjectNode(TDspace *space, ULONG objectindex) {
	ULONG objectblock,objectnode;

	// if we have objects, and the index is between 1 and numberOfObjects
	if(space->objects.numberOfObjects==0) return(NULL);
	if(objectindex<1 || objectindex>space->objects.numberOfObjects) return(NULL);

	// internal index is index - 1
	objectindex--;

	// compute the block and node and return the object node
	objectnode=objectindex%Ci_OBJECTNODESINBLOCK;
	objectblock=(objectindex-objectnode)/Ci_OBJECTNODESINBLOCK;
	return(space->objects.blocks[objectblock]->nodes[objectnode]);
}

/********************************************************************\
*                                                                    *
* Name         : vector2CTM                                          *
*                                                                    *
* Description  : Transforms a vector according the CTM.              *
*                                                                    *
* Arguments    : ctm      IN : CTM to use.                           *
*                vector   IN : Vector to transform.                  *
*                                                                    *
* Comment      : This function is for time uncritical use only !     *
*                                                                    *
\********************************************************************/
static VOID vector2CTM(TDctm ctm, TDvectord *vector) {
	TDvectord rvector;

	rvector=(*vector);

	// Scaling
	rvector.x*=ctm.sx,rvector.y*=ctm.sy,rvector.z*=ctm.sz;

	//Rotation and translation
	vector->x=ctm.m[0][0]*rvector.x+ctm.m[1][0]*rvector.y+ctm.m[2][0]*rvector.z+ctm.m[3][0]; 
	vector->y=ctm.m[0][1]*rvector.x+ctm.m[1][1]*rvector.y+ctm.m[2][1]*rvector.z+ctm.m[3][1]; 
	vector->z=ctm.m[0][2]*rvector.x+ctm.m[1][2]*rvector.y+ctm.m[2][2]*rvector.z+ctm.m[3][2]; 
}

/********************************************************************\
*                                                                    *
* Name         : addMatGroupNode                                     *
*                                                                    *
* Description  : Add a new matgroup node to the polymesh.            *
*                                                                    *
* Arguments    : mesh      IN : Pointer to the polymesh.             *
*                matnode   IN : Node of the material.                *
*                                                                    *
* Return Value : Node of the new matgroup or NULL if no more memory. *
*                                                                    *
* Comment      : The array indices are beginnning at 0, index at 1   *
*                                                                    *
\********************************************************************/
static TDmatgroupnode *addMatGroupNode(TDpolymesh *mesh,TDmaterialnode *matnode) {
	static TDmatgroupnode		*matgroup=NULL;
	ULONG	matgroupnode,matgroupblock;
	
	// check if we have still place for a matgroup node
	matgroupnode=(mesh->matgroups.numberOfMatGroups)%Ci_MATGROUPNODESINBLOCK;
	matgroupblock=((mesh->matgroups.numberOfMatGroups)-matgroupnode)/Ci_MATGROUPNODESINBLOCK;

	if(matgroupblock>=Ci_MATGROUPBLOCKS) return(NULL);

	// check if we have to allocate a new nodes list block
	if(matgroupnode==0) {
		mesh->matgroups.blocks[matgroupblock]=AllocPooled(mesh->matgroupblockspool,sizeof(TDmatgroupblock));
		if(mesh->matgroups.blocks[matgroupblock]==NULL) return(NULL);
	}

	matgroup = AllocMem(sizeof(TDmatgroupnode),MEMF_FAST);
	if (matgroup==NULL) {
		return(NULL);
	}

	matgroup->polygons.numberOfPolygons=0;
	matgroup->polygons.numberOfVertices=0;

	matgroup->materialnode=NULL;
	matgroup->texbindex=0;

	switch(matnode->type) {
		case TD_SURFACE :
			matgroup->materialnode=matnode;
			break;
	}

	// assign the node to the nodes list
	mesh->matgroups.blocks[matgroupblock]->nodes[matgroupnode]=matgroup;

	// last increment the numberOfMatGroups counter
	mesh->matgroups.numberOfMatGroups++;

	return(matgroup);
}

/********************************************************************\
*                                                                    *
* Name         : addPolygon                                          *
*                                                                    *
* Description  : Adds the polygon to the matgroup of the mesh,       *
*                The size of the vertex array may be set.            *
*                                                                    *
* Arguments    : mesh     IN : Pointer to the mesh.                  *
*                matgroup IN : Pointer to the matgroup.              *
*	             size     IN : Initial size of the polygon.          *
*                                                                    *
* Return Value : Pointer to the polygon node or NULL if no memory.   *
*                                                                    *
* Comment      : The array indices are beginnning at 0, index at 1   *
*                                                                    *
\********************************************************************/
static TDpolygonnode *addPolygon(TDpolymesh *mesh,TDmatgroupnode *matgroup,ULONG size) {

	TDpolygonnode		*poly=NULL;
	ULONG				polyparray,polybarray,polyblock;

	// check if we have still place for a polygon node
	polyparray=(matgroup->polygons.numberOfPolygons)%Ci_POLYARRAY;
	polybarray=(((matgroup->polygons.numberOfPolygons)-polyparray)/Ci_POLYARRAY)%Ci_POLYARRAYINBLOCK;
	polyblock=(polybarray*Ci_POLYARRAYINBLOCK+polyparray)/(Ci_POLYARRAY*Ci_POLYARRAYINBLOCK);

	if(polyblock>=Ci_POLYBLOCKS) return(NULL);

	// check if we have to allocate a new array of polygon arrays
	if(polybarray==0 && polyparray==0) {
		matgroup->polygons.blocks[polyblock]=AllocPooled(mesh->polyblockspool,sizeof(TDpolygonblock));
		if(matgroup->polygons.blocks[polyblock]==NULL) return(NULL);
	}

	// check if we have to allocate a new array of polygons
	if(polyparray==0) {
		matgroup->polygons.blocks[polyblock]->barray[polybarray]=AllocPooled(mesh->polyarraypool,sizeof(TDpolygonarray));
		if(matgroup->polygons.blocks[polyblock]->barray[polybarray]==NULL) return(NULL);
	}

	// make a new polygon node
	poly = AllocPooled(mesh->polypool,sizeof(TDpolygonnode));
	if (poly==NULL) return(NULL);

	poly->numberOfVertices=0;

	// make a new polygon vertex array node
	poly->varray = AllocPooled(mesh->polyverpool,size*sizeof(ULONG));
	if (poly->varray==NULL) return(NULL);

	// assign the polygon node to the polygon array list
	matgroup->polygons.blocks[polyblock]->barray[polybarray]->parray[polyparray]=poly;

	// last increment the numberOfPolygons counters
	mesh->matgroups.numberOfPolygons++;
	matgroup->polygons.numberOfPolygons++;

	return(poly);
}

/********************************************************************\
*                                                                    *
* Name         : getPolygonNode                                      *
*                                                                    *
* Description  : Search the polygon with its index, in the given     *
*                matgroup. If the index is not valid, NULL will be   *
*                returned.                                           *
*                                                                    *
* Arguments    : matgroup     IN : Pointer to the matgroup.          *
*                polyindex    IN : Polygon index.                    *
*                                                                    *
* Return Value : Pointer to the polygon or NULL if not found.        *
*                                                                    *
* Comment      : The array indices are beginnning at 0, index at 1   *
*                                                                    *
\********************************************************************/
static TDpolygonnode *getPolygonNode(TDmatgroupnode *matgroup, ULONG polyindex) {
	ULONG	polyparray,polybarray,polyblock;

	// if we have polygons, and the index is between 1 and numberOfPolygons
	if(matgroup->polygons.numberOfPolygons==0) return(NULL);
	if(polyindex<1 || polyindex>matgroup->polygons.numberOfPolygons) return(NULL);

	// internal index is - 1
	polyindex--;

	// compute the block, arraylist and array place and return the polygon
	polyparray=(polyindex)%Ci_POLYARRAY;
	polybarray=((polyindex-polyparray)/Ci_POLYARRAY)%Ci_POLYARRAYINBLOCK;
	polyblock=(polybarray*Ci_POLYARRAYINBLOCK+polyparray)/(Ci_POLYARRAY*Ci_POLYARRAYINBLOCK);

	return(matgroup->polygons.blocks[polyblock]->barray[polybarray]->parray[polyparray]);
}

/********************************************************************\
*                                                                    *
* Name         : addVertex                                           *
*                                                                    *
* Description  : Adds the vertex to the mesh, And returns the index  *
*                to it.                                              *
*                The vertex will be transformed according the CTM    *
*                                                                    *
* Arguments    : mesh   IN : Pointer to the mesh.                    *
*                ctm    IN : The current transformation matrix.      *
*                vertex IN : The vertex to add.                      *
*                                                                    *
* Return Value : Index of the vertex. Or 0 if no more memory.        *
*                                                                    *
* Comment      : The array indices are beginnning at 0, index at 1   *
*                                                                    *
\********************************************************************/
static ULONG addVertex(TDpolymesh *mesh,TDctm ctm,TDvectord vertex) {

	TDvectord		rvertex,*ver=NULL;
	ULONG			vervarray,verbarray,verblock;

	// check if we have still place for a vertex node
	vervarray=(mesh->vertices.numberOfVertices)%Ci_VERTEXARRAY;
	verbarray=(((mesh->vertices.numberOfVertices)-vervarray)/Ci_VERTEXARRAY)%Ci_VERTEXARRAYINBLOCK;
	verblock=(verbarray*Ci_VERTEXARRAYINBLOCK+vervarray)/(Ci_VERTEXARRAY*Ci_VERTEXARRAYINBLOCK);

	if(verblock>=Ci_VERTEXBLOCKS) return(0);

	// check if we have to allocate a new array of vertex arrays
	if(verbarray==0 && vervarray==0) {
		mesh->vertices.blocks[verblock]=AllocPooled(mesh->vertexblockspool,sizeof(TDvertexblock));
		if(mesh->vertices.blocks[verblock]==NULL) return(0);
	}

	// check if we have to allocate a new array of vertices
	if(vervarray==0) {
		mesh->vertices.blocks[verblock]->barray[verbarray]=AllocPooled(mesh->vertexarraypool,sizeof(TDvertexarray));
		if(mesh->vertices.blocks[verblock]->barray[verbarray]==NULL) return(0);
	}

	// Transforming the the vertex according the CTM

	// Scaling
	vertex.x*=ctm.sx,vertex.y*=ctm.sy,vertex.z*=ctm.sz;

	//Rotation and translation
	rvertex.x=ctm.m[0][0]*vertex.x+ctm.m[1][0]*vertex.y+ctm.m[2][0]*vertex.z+ctm.m[3][0]; 
	rvertex.y=ctm.m[0][1]*vertex.x+ctm.m[1][1]*vertex.y+ctm.m[2][1]*vertex.z+ctm.m[3][1]; 
	rvertex.z=ctm.m[0][2]*vertex.x+ctm.m[1][2]*vertex.y+ctm.m[2][2]*vertex.z+ctm.m[3][2]; 

	// make a copy of the vertex
	ver = AllocPooled(mesh->vertexpool,sizeof(TDvectord));
	if (ver==NULL) return(0);
	
	(*ver)=rvertex;

	// assign the vertex copy to the vertex array list
	mesh->vertices.blocks[verblock]->barray[verbarray]->varray[vervarray]=ver;

	ver=mesh->vertices.blocks[verblock]->barray[verbarray]->varray[vervarray];

	// Recalculate the bounding box
	if(rvertex.x<mesh->bBox.left)   mesh->bBox.left=rvertex.x;
	if(rvertex.x>mesh->bBox.right)  mesh->bBox.right=rvertex.x;
	if(rvertex.y<mesh->bBox.rear)   mesh->bBox.rear=rvertex.y;
	if(rvertex.y>mesh->bBox.front)  mesh->bBox.front=rvertex.y;
	if(rvertex.z<mesh->bBox.bottom) mesh->bBox.bottom=rvertex.z;
	if(rvertex.z>mesh->bBox.top)    mesh->bBox.top=rvertex.z;

	// last increment the numberOfVertices counter
	mesh->vertices.numberOfVertices++;

	return(mesh->vertices.numberOfVertices);
}

/********************************************************************\
*                                                                    *
* Name         : getVertex                                           *
*                                                                    *
* Description  : Search the vertex with its index, in the given      *
*                mesh. If the index is not valid, NULL will be       *
*                returned.                                           *
*                                                                    *
* Arguments    : mesh           IN : Pointer to the mesh.            *
*                vertexindex    IN : Vertex index                    *
*                                                                    *
* Return Value : Pointer to the vertex or NULL if not found.         *
*                                                                    *
* Comment      : The array indices are beginnning at 0, index at 1   *
*                                                                    *
\********************************************************************/
static TDvectord *getVertex(TDpolymesh *mesh, ULONG vertexindex) {
	ULONG	vervarray,verbarray,verblock;

	// if we have vertices, and the index is between 1 and numberOfVertices
	if(mesh->vertices.numberOfVertices==0) return(NULL);
	if(vertexindex<1 || vertexindex>mesh->vertices.numberOfVertices) return(NULL);

	// internal index is - 1
	vertexindex--;

	// compute the block, arraylist and array place and return the vertex
	vervarray=(vertexindex)%Ci_VERTEXARRAY;
	verbarray=((vertexindex-vervarray)/Ci_VERTEXARRAY)%Ci_VERTEXARRAYINBLOCK;
	verblock=(verbarray*Ci_VERTEXARRAYINBLOCK+vervarray)/(Ci_VERTEXARRAY*Ci_VERTEXARRAYINBLOCK);

	return(mesh->vertices.blocks[verblock]->barray[verbarray]->varray[vervarray]);
}

/********************************************************************\
*                                                                    *
* Name         : assignVertex                                        *
*                                                                    *
* Description  : Assigns a vertex to a polygon node. The array of the*
*                node will be expanded if necessary.                 *
*                Assumed that the polygon has a minimum sized array  *
*                of Ci_POLYVERARRAYINIT.                             *
*                                                                    *
* Arguments    : mesh         IN : Pointer to the mesh.              *
*	             matgroup     IN : Pointer to the matgroup.          *
*                poly         IN : Pointer to the polygon.           *
*	             vertexindex  IN : Index to the vertex to assign.    *
*                                                                    *
* Return Value : 0 if no memory or the polygons count of vertices.   *
*                                                                    *
* Comment      : The array indices are beginnning at 0, index at 1   *
*                                                                    *
\********************************************************************/
static ULONG assignVertex(TDpolymesh *mesh,TDmatgroupnode *matgroup,
							TDpolygonnode *poly,ULONG vertexindex) {

	ULONG	*varray;
	ULONG	nof;

	nof=poly->numberOfVertices;

	// check if we have to expand the vertex array
	if(nof<Ci_POLYVERARRAYINIT) {
		poly->varray[nof]=vertexindex;
	} else {
		// make a new polygon vertex array
		varray = AllocPooled(mesh->polyverpool,(nof+1)*sizeof(ULONG));
		if(varray==NULL) return(0);

		// copy the old array into the new one
		CopyMem(poly->varray,varray,nof*sizeof(ULONG));

		// free the old one
		FreePooled(mesh->polyverpool,poly->varray,nof*sizeof(ULONG));

		// assign the new array to the polygon
		poly->varray=varray;

		// assign the new vertex index
		poly->varray[nof]=vertexindex;
	}

	// last increment the numberOfVertices counters
	matgroup->polygons.numberOfVertices++;
	poly->numberOfVertices++;

	return(poly->numberOfVertices);
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
static VOID setCameraLight(TTDOMesh *mesh) {
	TTDOVertexd ver1;
		
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
* Name         : spaceClean                                          *
*                                                                    *
* Description  : If an error occurs while creating a new space, call *
*                this one to delete it.                              *
*                                                                    *
* Arguments    : space   IN : Pointer to the space.                  *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static VOID spaceClean(TDspace *space) {

	DeletePool(space->objectblockspool);
	DeletePool(space->matblockspool);
	FreeVec(space->name);
	FreeMem(space,sizeof(TDspace));
};

/********************** Public functions ****************************/

/********************************************************************\
*                                                                    *
* Name         : initTDLibrary                                       *
*                                                                    *
* Description  : Initializes the TD library.                         *
*                                                                    *
* Return Value : 0 if all went well or 1 when no memory or file      *
*                accessing errors.                                   *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
ULONG initTDLibrary () {
	TD3dlibinfo *lib3dinfo=NULL;

	if((tdlibinfos=AllocMem(sizeof(TDlibraryinfo),MEMF_FAST))!=NULL) {
		if((tdlibinfos->lib3dinfos=AllocMem(sizeof(TD3dlibinfo *)*5,MEMF_FAST))!=NULL) {

			tdlibinfos->lib3dinfos[0]=AllocMem(sizeof(TD3dlibinfo),MEMF_FAST);
			lib3dinfo=tdlibinfos->lib3dinfos[0];
			lib3dinfo->library=AllocVec(sizeof(UBYTE)*strlen("dxf.library")+1,MEMF_FAST);
			strcpy(lib3dinfo->library,"dxf.library");
			lib3dinfo->name=AllocVec(sizeof(UBYTE)*strlen("Autocad DXF (TD)")+1,MEMF_FAST);
			strcpy(lib3dinfo->name,"Autocad DXF (TD)");
			lib3dinfo->ext=AllocVec(sizeof(UBYTE)*strlen("dxf")+1,MEMF_FAST);
			strcpy(lib3dinfo->ext,"dxf");
			lib3dinfo->supl=AllocVec(sizeof(TDenum)*3,MEMF_FAST);
			lib3dinfo->supl[0]=TD_OBJECT;
			lib3dinfo->supl[1]=TD_MATERIAL;
			lib3dinfo->supl[2]=TD_NOTHING;
			lib3dinfo->sups=AllocVec(sizeof(TDenum)*4,MEMF_FAST);
			lib3dinfo->sups[0]=TD_OBJECT;
			lib3dinfo->sups[1]=TD_MATERIAL;
			lib3dinfo->sups[2]=TD_SURFACE;
			lib3dinfo->sups[3]=TD_NOTHING;

			tdlibinfos->lib3dinfos[1]=AllocMem(sizeof(TD3dlibinfo),MEMF_FAST);
			lib3dinfo=tdlibinfos->lib3dinfos[1];
			lib3dinfo->library=AllocVec(sizeof(UBYTE)*strlen("rawa.library")+1,MEMF_FAST);
			strcpy(lib3dinfo->library,"rawa.library");
			lib3dinfo->name=AllocVec(sizeof(UBYTE)*strlen("RAW ASCII (TD)")+1,MEMF_FAST);
			strcpy(lib3dinfo->name,"RAW ASCII (TD)");
			lib3dinfo->ext=AllocVec(sizeof(UBYTE)*strlen("raw")+1,MEMF_FAST);
			strcpy(lib3dinfo->ext,"raw");
			lib3dinfo->supl=AllocVec(sizeof(TDenum)*2,MEMF_FAST);
			lib3dinfo->supl[0]=TD_OBJECT;
			lib3dinfo->supl[1]=TD_NOTHING;
			lib3dinfo->sups=NULL;

			tdlibinfos->lib3dinfos[2]=AllocMem(sizeof(TD3dlibinfo),MEMF_FAST);
			lib3dinfo=tdlibinfos->lib3dinfos[2];
			lib3dinfo->library=AllocVec(sizeof(UBYTE)*strlen("geoa.library")+1,MEMF_FAST);
			strcpy(lib3dinfo->library,"geoa.library");
			lib3dinfo->name=AllocVec(sizeof(UBYTE)*strlen("Videoscape ASCII (TD)")+1,MEMF_FAST);
			strcpy(lib3dinfo->name,"Videoscape ASCII (TD)");
			lib3dinfo->ext=AllocVec(sizeof(UBYTE)*strlen("geo")+1,MEMF_FAST);
			strcpy(lib3dinfo->ext,"geo");
			lib3dinfo->supl=AllocVec(sizeof(TDenum)*2,MEMF_FAST);
			lib3dinfo->supl[0]=TD_OBJECT;
			lib3dinfo->supl[1]=TD_NOTHING;
			lib3dinfo->sups=AllocVec(sizeof(TDenum)*2,MEMF_FAST);
			lib3dinfo->sups[0]=TD_OBJECT;
			lib3dinfo->sups[1]=TD_NOTHING;

			tdlibinfos->lib3dinfos[3]=AllocMem(sizeof(TD3dlibinfo),MEMF_FAST);
			lib3dinfo=tdlibinfos->lib3dinfos[3];
			lib3dinfo->library=AllocVec(sizeof(UBYTE)*strlen("vrml.library")+1,MEMF_FAST);
			strcpy(lib3dinfo->library,"vrml.library");
			lib3dinfo->name=AllocVec(sizeof(UBYTE)*strlen("VRML 1.0 (TD)")+1,MEMF_FAST);
			strcpy(lib3dinfo->name,"VRML 1.0 (TD)");
			lib3dinfo->ext=AllocVec(sizeof(UBYTE)*strlen("wrl")+1,MEMF_FAST);
			strcpy(lib3dinfo->ext,"wrl");
			lib3dinfo->supl=NULL;
			lib3dinfo->sups=AllocVec(sizeof(TDenum)*3,MEMF_FAST);
			lib3dinfo->sups[0]=TD_SPACE;
			lib3dinfo->sups[1]=TD_MATERIAL;
			lib3dinfo->sups[2]=TD_NOTHING;

			tdlibinfos->lib3dinfos[4]=NULL;

			return(0);
		}
	}
	
	return(1);
}

/********************************************************************\
*                                                                    *
* Name         : freeTDLibrary                                       *
*                                                                    *
* Description  : Free all memory allocated in initTDLibrary.         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
VOID freeTDLibrary () {
	ULONG i=0;
	TD3dlibinfo *lib3dinfo=NULL;

	// free the library information structure
	if(tdlibinfos!=NULL) {
		// free the 3d library informations
		if(tdlibinfos->lib3dinfos!=NULL) {
			i=0;
			while(tdlibinfos->lib3dinfos[i]!=NULL) {
				lib3dinfo=tdlibinfos->lib3dinfos[i];

				FreeVec(lib3dinfo->library);
				FreeVec(lib3dinfo->name);
				FreeVec(lib3dinfo->ext);

				if(lib3dinfo->supl!=NULL) {
					FreeVec(lib3dinfo->supl);
				}

				if(lib3dinfo->sups!=NULL) {
					FreeVec(lib3dinfo->sups);
				}

				FreeMem(lib3dinfo,sizeof(TD3dlibinfo));
				i++;
			}

			i++;
			FreeMem(tdlibinfos->lib3dinfos,sizeof(TD3dlibinfo *)*i);
		}

		FreeMem(tdlibinfos,sizeof(TDlibraryinfo));
	}
}

/********************************************************************\
*                                                                    *
* Name         : fill3DFormatArrays.                                 *
*                                                                    *
* Description  : Fills up all 3D format arrays.                      *
*                                                                    *
* Arguments    : mesh         IN : Pointer to the mesh.              *
*	             rvertex      IN : Vertex with coordinates.          *
*                operation    IN : Operation to perform.             *
*                                                                    *
* Return Value : 0 if all went well or 1 when no memory or file      *
*                accessing errors.                                   *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
ULONG fill3DFormatArrays(){

/*
#include <dos/dos.h>
#include <dos/exall.h>
#include <dos/stdio.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/alib_stdio_protos.h>

#define BUFFERSIZE 2048


	BPTR fl;
	struct ExAllControl *eac;
	struct ExAllData *ed,*p;
	LONG more,res2;
	ULONG n;
	UBYTE pattern[30];


	if((fl=Lock("libs:tdo/3dx",SHARED_LOCK)) != NULL) {
		if((eac=AllocDosObject(DOS_EXALLCONTROL, NULL)) != NULL) {
			if((ed=AllocMem(BUFFERSIZE,0))!=NULL) {
				if(ParsePatternNoCase("#?.library",pattern,30)!=-1) {
					eac->eac_LastKey=0;
					eac->eac_MatchString=pattern;
					eac->eac_MatchFunc=NULL;

					do {
						if((more=ExAll(fl,ed,BUFFERSIZE,ED_NAME,eac))!=DOSFALSE) {
							for(p=ed,n=eac->eac_Entries;n!=0;p=p->ed_Next,--n) {
								printf("%s\n",p->ed_Name);
							}
						} else {
							// fehler, buffer to small oder sonst was
							ExAllEnd(fl,ed,BUFFERSIZE,ED_NAME,eac);
							more=DOSFALSE;
						}
					} while(more!=DOSFALSE);
					FreeMem(ed,BUFFERSIZE);
				}
			}
			FreeDosObject(DOS_EXALLCONTROL,eac);
		}
		UnLock(fl);
	}
*/
// !! nach namen format sortieren, alle arrays !

	BPTR fl;
	struct ExAllControl *eac;
	struct ExAllData *ed,*p;
	LONG more;
	ULONG n;
	UBYTE pattern[30];
	UBYTE libname[200];

	if((fl=Lock("libs:tdo/3x",SHARED_LOCK)) != NULL) {
		if((eac=AllocDosObject(DOS_EXALLCONTROL, NULL)) != NULL) {
			if((ed=AllocMem(EXALLBUFFERSIZE,0))!=NULL) {
				if(ParsePatternNoCase("#?.library",pattern,30)!=-1) {
					eac->eac_LastKey=0;
					eac->eac_MatchString=pattern;
					eac->eac_MatchFunc=NULL;

					do {
						if((more=ExAll(fl,ed,EXALLBUFFERSIZE,ED_NAME,eac))==DOSFALSE) {
							for(p=ed,n=eac->eac_Entries;n!=0;p=p->ed_Next,--n) {
								printf("%s\n",p->ed_Name);

								// we skip corrupt libraries !
								sprintf(libname,"libs:tdo/3x/%s",p->ed_Name);
								if((x3Base=(APTR) OpenLibrary(libname,0))!=NULL) {
// lokales grosses array fuer init, dann copy nach c3... da ja zuerst alles lesen usw...
									printf("impl S %ld L %ld\n",tdo3XSave(0,NULL,NULL),tdo3XLoad(0,NULL,NULL,NULL));

									CloseLibrary((APTR)x3Base);
								}
							}
						} else {
							// buffer to small or dos error
							ExAllEnd(fl,ed,EXALLBUFFERSIZE,ED_NAME,eac);
							more=DOSFALSE;
						}
					} while(more!=DOSFALSE);
					FreeMem(ed,EXALLBUFFERSIZE);
				}
			}
			FreeDosObject(DOS_EXALLCONTROL,eac);
		}
		UnLock(fl);
	}
/*
	c3dsLib=AllocVec(4*sizeof(STRPTR),MEMF_FAST);
	c3dsLib[0]=AllocVec(strlen("rawb.library")+1,MEMF_FAST);
	strcpy(c3dsLib[0],"rawb.library");
	c3dsLib[1]=AllocVec(strlen("geoa.library")+1,MEMF_FAST);
	strcpy(c3dsLib[1],"geoa.library");
	c3dsLib[2]=AllocVec(strlen("rawa.library")+1,MEMF_FAST);
	strcpy(c3dsLib[2],"rawa.library");
	c3dsLib[3]=NULL;

	c3dsNames=AllocVec(4*sizeof(STRPTR),MEMF_FAST);
	c3dsNames[0]=AllocVec(strlen("RAW binary")+1,MEMF_FAST);
	strcpy(c3dsNames[0],"RAW binary");
	c3dsNames[1]=AllocVec(strlen("Videoscape ASCII")+1,MEMF_FAST);
	strcpy(c3dsNames[1],"Videoscape ASCII");
	c3dsNames[2]=AllocVec(strlen("RAW ASCII")+1,MEMF_FAST);
	strcpy(c3dsNames[2],"RAW ASCII");
	c3dsNames[3]=NULL;

	c3dsExt=AllocVec(4*sizeof(STRPTR),MEMF_FAST);
	c3dsExt[0]=AllocVec(strlen("raw")+1,MEMF_FAST);
	strcpy(c3dsExt[0],"raw");
	c3dsExt[1]=AllocVec(strlen("geo")+1,MEMF_FAST);
	strcpy(c3dsExt[1],"geo");
	c3dsExt[2]=AllocVec(strlen("raw")+1,MEMF_FAST);
	strcpy(c3dsExt[2],"raw");
	c3dsExt[3]=NULL;


	c3dlLib=AllocVec(2*sizeof(STRPTR),MEMF_FAST);
	c3dlLib[0]=AllocVec(strlen("dxf.library")+1,MEMF_FAST);
	strcpy(c3dlLib[0],"dxf.library");
	c3dlLib[1]=AllocVec(strlen("ref4.library")+1,MEMF_FAST);
	strcpy(c3dlLib[1],"ref4.library");
	c3dlLib[2]=NULL;

	c3dlNames=AllocVec(2*sizeof(STRPTR),MEMF_FAST);
	c3dlNames[0]=AllocVec(strlen("Autodesk DXF")+1,MEMF_FAST);
	strcpy(c3dlNames[0],"Autodesk DXF");
	c3dlNames[1]=AllocVec(strlen("Reflections 4")+1,MEMF_FAST);
	strcpy(c3dlNames[1],"Reflections 4");
	c3dlNames[2]=NULL;
*/

	return(0);
}

/********************************************************************\
*                                                                    *
* Name         : free3DFormatArrays.                                 *
*                                                                    *
* Description  : Free all 3D format arrays.                          *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
VOID free3DFormatArrays(){
	ULONG i;

	// 3D save libraries
	i=0;
	if(c3dsLib!=NULL) {
		while(c3dsLib[i]!=NULL) {
			FreeVec(c3dsLib[i++]);
		}
		FreeVec(c3dsLib);
		c3dsLib=NULL;
	}

	i=0;
	if(c3dsNames!=NULL) {
		while(c3dsNames[i]!=NULL) {
			FreeVec(c3dsNames[i++]);
		}
		FreeVec(c3dsNames);
		c3dsNames=NULL;
	}

	i=0;
	if(c3dsExt!=NULL) {
		while(c3dsExt[i]!=NULL) {
			FreeVec(c3dsExt[i++]);
		}
		FreeVec(c3dsExt);
		c3dsExt=NULL;
	}

	// 3d load libraries
	i=0;
	if(c3dlLib!=NULL) {
		while(c3dlLib[i]!=NULL) {
			FreeVec(c3dlLib[i++]);
		}
		FreeVec(c3dlLib);
		c3dlLib=NULL;
	}

	i=0;
	if(c3dlNames!=NULL) {
		while(c3dlNames[i]!=NULL) {
			FreeVec(c3dlNames[i++]);
		}
		FreeVec(c3dlNames);
		c3dlNames=NULL;
	}
}

/****** td.library/tdSpaceNew ******************************************
* 
*   NAME	
* 	tdSpaceNew -- Creates a new space
* 
*   SYNOPSIS
*	spacehandle = tdSpaceNew( )
*	          
*
*	ULONG tdSpaceNew
*	     ( );
*
*   FUNCTION
*	Allocates the memory for a new space, initializes all its contents and
*	returns a handle to it.
*	The space becomes a default name and a default copyright.
*
*   You have to delete the space after usage with tdSpaceDelete().
*
*   INPUTS
* 
*   RESULT
* 	spacehandle - A handle to the new space, or 0 in error case, which means
*	              that there is not enough memory available.
* 
*   EXAMPLE
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdSpaceDelete()
*
*****************************************************************************
*
*/
ULONG __saveds ASM tdSpaceNew() {
	TDspace 	*space=NULL;
	UBYTE		buffer[20];

	space = AllocMem(sizeof(TDspace),MEMF_FAST);
	if (space==NULL) return(0);

	// initialize the pool headers and other pointers
	space->matblockspool=NULL;
	space->objectblockspool=NULL;

	space->name=NULL;

	// create a memory pool for the material block lists of this this space
	// ground size of a pool is one block of materials
	space->matblockspool=CreatePool(MEMF_FAST,sizeof(TDmaterialblock),sizeof(TDmaterialblock));
	if(space->matblockspool==NULL) {
		spaceClean(space);
		return(0);
	}

	// create a memory pool for the object block lists of this this space
	// ground size of a pool is one block of object
	space->objectblockspool=CreatePool(MEMF_FAST,sizeof(TDobjectblock),sizeof(TDobjectblock));
	if(space->objectblockspool==NULL) {
		spaceClean(space);
		return(0);
	}

	space->name=NULL;
	strcpy(buffer,"tdSPACE");
	space->name = AllocVec(strlen(buffer)+1,MEMF_FAST);
	if (space->name==NULL) {
		spaceClean(space);
		return(0);
	}
	strcpy(space->name,buffer);
	
	space->bBox.left=0.0;
	space->bBox.right=0.0;
	space->bBox.front=0.0;
	space->bBox.rear=0.0;
	space->bBox.top=0.0;
	space->bBox.bottom=0.0;

	space->curmatn=NULL;
	space->curobjn=NULL;

	space->objects.numberOfObjects=0;	
	space->materials.numberOfMaterials=0;

	space->ctm.sx=1,space->ctm.sy=1,space->ctm.sz=1;
	space->ctm.rx=0,space->ctm.ry=0,space->ctm.rz=0;
	space->ctm.m[0][0]=1,space->ctm.m[1][0]=0,space->ctm.m[2][0]=0,space->ctm.m[3][0]=0;
	space->ctm.m[0][1]=0,space->ctm.m[1][1]=1,space->ctm.m[2][1]=0,space->ctm.m[3][1]=0;
	space->ctm.m[0][2]=0,space->ctm.m[1][2]=0,space->ctm.m[2][2]=1,space->ctm.m[3][2]=0;
	space->ctm.m[0][3]=0,space->ctm.m[1][3]=0,space->ctm.m[2][3]=0,space->ctm.m[3][3]=1;

	return(ULONG)space;
}

/****** td.library/tdSpaceDelete ******************************************
* 
*   NAME	
* 	tdSpaceDelete -- Delete a space which was created whith tdSpaceNew().
* 
*   SYNOPSIS
*	error = tdSpaceDelete( spacehandle )
*	                       D1
*
*	TDerrors tdSpaceDelete
*	     ( ULONG );
*
*   FUNCTION
*	Free the memory occupied by the space and all its components.
* 
*   INPUTS
* 	spacehandle    - A valid handle of a space.
*	
*   RESULT
* 	error - ER_NOERROR if all went well.
*	        ER_NOSPACE if the handle is not valid.
*
*   EXAMPLE
* 
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdSpaceNew()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdSpaceDelete(register __d1 ULONG spacehandle) {
	TDspace					*space=NULL;
	TDmaterialnode				*mat=NULL;
	TDobjectnode				*object=NULL;
	ULONG						i;

	space=(TDspace *) spacehandle;
	if(space==NULL) return(ER_NOSPACE);

	/*
	** Free the name string
	*/
	FreeVec(space->name);

	/*
	** Free the objects and the nodeslist
	*/
	for(i=1;i<=space->objects.numberOfObjects;i++) {
		object=getObjectNode(space,i);

		FreeVec(object->name);

		switch(object->type) {
			case TD_CUBE :
				FreeMem((TDcube *)object->handle,sizeof(TDcube));
				break;
			case TD_POLYMESH :
				delPolyMesh((TDpolymesh *)object->handle);
				break;
			case TD_TEXBINDING :
				FreeMem((TDtexbinding *)object->handle,sizeof(TDtexbinding));
				break;
		}

		FreeMem(object,sizeof(TDobjectnode));
	}
	DeletePool(space->objectblockspool);

	/*
	** Free the materials and the nodeslist
	*/
	for(i=1;i<=space->materials.numberOfMaterials;i++) {
		mat=getMaterialNode(space,i);

		FreeVec(mat->name);

		switch(mat->type) {
			case TD_SURFACE :
				FreeMem((TDsurface *)mat->handle,sizeof(TDsurface));
				break;
			case TD_TEXTURE :
				FreeMem((TDtexture *)mat->handle,sizeof(TDtexture));
				break;
		}

		FreeMem(mat,sizeof(TDmaterialnode));
	}
	DeletePool(space->matblockspool);

	/*
	** Free the space itself
	*/
	FreeMem(space,sizeof(TDspace));

	return(ER_NOERROR);
}

/****** td.library/tdNameSet ******************************************
* 
*   NAME	
* 	tdNameSet -- Set the name of component.
* 
*   SYNOPSIS
*	error = tdNameSet( spacehandle,type,index,name )
*	                   D1          D2   D3    D4
*
*	TDerrors tdSpaceNameSet
*	     ( ULONG,TDenum,ULONG,STRPTR );
*
*   FUNCTION
*	A copy of the passed string will be made and assigned to the
*	name string of the specified component of this space.
* 
*   INPUTS
* 	spacehandle     - A valid handle of a space.
*	type            - The component its type.
*	index           - The component its index.
*	name            - String which contains the name.
*	
*   RESULT
* 	error - ER_NOERROR  if all went well.
*	        ER_NOSPACE  if the handle is not valid.
*	        ER_NOTYPE   if the type is not valid.
*	        ER_NOINDEX  if the index is not valid.
* 	        ER_NOMEMORY if there is not enough memory.
*
*   EXAMPLE
*	error = tdNameSet(spacehandle,TD_MATERIAL,3,"purple red");
*
*   NOTES
*	This function can be called as often as you need, which will
*	replace the old value.
*
*	When changing the name of a space, the index will not be
*	used, as the space is already known.
*
*	Not all formats support names, and the written length of the
*	string depends of the format too.
*
*   BUGS
* 
*   SEE ALSO
* 	tdNameGet()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdNameSet(register __d1 ULONG spacehandle,
								register __d2 TDenum type,
								register __d3 ULONG index,
								register __d4 STRPTR name ) {

	TDspace		*space=NULL;
	TDmaterialnode	*mat=NULL;
	TDobjectnode	*object=NULL;
  
	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	// check which component has to be affected
	switch(type) {
		case TD_SPACE :
			// if the name was already set before, free it
			if(space->name) FreeVec(space->name);
			space->name=NULL;

			space->name=(STRPTR) AllocVec(strlen(name)+1,MEMF_FAST);
			if(space->name==NULL) return(ER_NOMEMORY);
  
			strcpy(space->name,name);

			break;
		case TD_MATERIAL :
			mat=getMaterialNode(space,index);
			if(mat==NULL) return(ER_NOINDEX);

			// If the name was already set before, free it
			if (mat->name) FreeVec(mat->name);
			mat->name=NULL;
	
			mat->name=(STRPTR) AllocVec(strlen(name)+1,MEMF_FAST);
			if(mat->name==NULL) return(ER_NOMEMORY);
  
			strcpy(mat->name,name);

			break;
		case TD_OBJECT :
			object=getObjectNode(space,index);
			if(object==NULL) return(ER_NOINDEX);

			// If the name was already set before, free it
			if (object->name) FreeVec(object->name);
			object->name=NULL;
	
			object->name=(STRPTR) AllocVec(strlen(name)+1,MEMF_FAST);
			if(object->name==NULL) return(ER_NOMEMORY);
  
			strcpy(object->name,name);

			break;
		default :
			return(ER_NOTYPE);
	}

	return(ER_NOERROR);
}

/****** td.library/tdNameGet ******************************************
* 
*   NAME	
* 	tdNameGet -- Get the name of a component.
*
*   SYNOPSIS
*	error = tdNameGet( spacehandle,type,index,name )
*	                   D1          D2   D3    D4
*
*	TDerrors tdNameGet
*	     ( ULONG,TDenum,ULONG,STRPTR * );
*
*   FUNCTION
*	You will get a pointer to the name of the component.
*	This string is READ_ONLY and only valid as long the
*	as the component exists.
* 
*   INPUTS
* 	spacehandle     - A valid handle of a space.
*	type            - The component its type.
*	index           - The component its index.
*	name            - Pointer to the name of the component.
*	
*   RESULT
* 	error - ER_NOERROR  if all went well.
*	        ER_NOSPACE  if the handle is not valid.
*	        ER_NOTYPE   if the type is not valid.
*	        ER_NOINDEX  if the index is not valid.
* 
*   EXAMPLE
*	error = tdNameGet(spacehandle,TD_SPACE,0,&mystring);
*
*   NOTES
*	When you will get the name of a space, the index will not be
*	used, as the space is already known.
*
*   BUGS
* 
*   SEE ALSO
* 	tdNameSet()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdNameGet(register __d1 ULONG spacehandle,
								register __d2 TDenum type,
								register __d3 ULONG index,
								register __d4 STRPTR *name ) {

	TDspace		*space=NULL;
	TDmaterialnode	*mat=NULL;
	TDobjectnode	*object=NULL;

	// initialize the name to NULL
	(*name)=NULL;
  
	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	// check which component has to be affected
	switch(type) {
		case TD_SPACE :
			(*name)=space->name;

			break;
		case TD_MATERIAL :
			mat=getMaterialNode(space,index);
			if(mat==NULL) return(ER_NOINDEX);

			(*name)=mat->name;

			break;
		case TD_OBJECT :
			object=getObjectNode(space,index);
			if(object==NULL) return(ER_NOINDEX);

			(*name)=object->name;

			break;
		default :
			return(ER_NOTYPE);
	}

	return(ER_NOERROR);
}

/****** td.library/tdAdd ******************************************
* 
*   NAME	
* 	tdAdd -- Add a new component to the space.
*
*   SYNOPSIS
*	error = tdAdd( spacehandle,type )
*	               D1          D2
*
*	TDerrors tdAdd
*	     ( ULONG,TDenum );
*
*   FUNCTION
*	A new component will be created and added to the space.
*	You can access the component by its index which will
*	be the last of its type.
*
*	All properties will be set to default, strings too.
* 
*   INPUTS
* 	spacehandle     - A valid handle of a space.
*	type            - The component its type.
*	
*   RESULT
* 	error - ER_NOERROR  if all went well.
*	        ER_NOSPACE  if the handle is not valid.
*	        ER_NOTYPE   if the type is not valid.
*	        ER_NOMEMORY if there is not enough memory. 
* 
*   EXAMPLE
*	error = tdAdd(spacehandle,TD_SURFACE);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdAdd(register __d1 ULONG spacehandle,register __d2 TDenum type) {
	TDspace		*space=NULL;

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	// check which component has to be affected
	switch(type) {
		case TD_SURFACE :
		case TD_TEXTURE :
			if(addMaterialNode(space,type)==0) return(ER_NOMEMORY);

			break;
		case TD_CUBE :
		case TD_POLYMESH :
		case TD_TEXBINDING :
			if(addObjectNode(space,type)==0) return(ER_NOMEMORY);

			break;
		default :
			return(ER_NOTYPE);
	}

	return(ER_NOERROR);
}

/****** td.library/tdNofGet ******************************************
* 
*   NAME	
* 	tdNofGet -- Get the number of specific components in
*	            the space or a child.
* 
*   SYNOPSIS
*	number = tdNofGet( spacehandle,type )
*	                   D1          D2
*
*	ULONG tdNofGet
*	     ( ULONG,TDenum )
*
*   FUNCTION
*	The current number of components of the specified type in the
*	space or a child will be returned.
* 
*   INPUTS
* 	spacehandle     - A valid handle of a space.
*	type            - The component its type.
*	
*   RESULT
* 	number - Number of components, 0 if none or no valid space or
*	         component.
*
*   EXAMPLE
*	number = tdNofGet(spacehandle,TD_MATERIAL);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 
******************************************************************************
*
*/
ULONG __saveds ASM tdNofGet(register __d1 ULONG spacehandle,
							register __d2 TDenum type) {
	TDspace		*space=NULL;
	TDmaterialnode	*mat=NULL;
	TDpolymesh		*polymesh=NULL;

	space=(TDspace *) spacehandle;
	if (space==NULL) return(0);

	// check which component has to be affected
	switch(type) {
		case TD_MATERIAL :
			return(space->materials.numberOfMaterials);

			break;
		case TD_OBJECT :
			return(space->objects.numberOfObjects);

			break;
		case TD_MATGROUP :
			if(space->curobjn==NULL) return(0);
			if(space->curobjn->type!=TD_POLYMESH) return(0);

			polymesh=(TDpolymesh *)(space->curobjn->handle);
			return(polymesh->matgroups.numberOfMatGroups);

			break;
		case TD_POLYGON :
			if(space->curobjn==NULL) return(0);
			if(space->curobjn->type!=TD_POLYMESH) return(0);

			polymesh=(TDpolymesh *)(space->curobjn->handle);
			if(polymesh->curmatgroupn==NULL) return(polymesh->matgroups.numberOfPolygons);
			else return(polymesh->curmatgroupn->polygons.numberOfPolygons);
			
			break;
		case TD_VERTEX :
			if(space->curobjn==NULL) return(0);
			if(space->curobjn->type!=TD_POLYMESH) return(0);

			polymesh=(TDpolymesh *)(space->curobjn->handle);
			if(polymesh->curmatgroupn==NULL) return(polymesh->vertices.numberOfVertices);
			else if(polymesh->curpolyn==NULL) return(polymesh->curmatgroupn->polygons.numberOfVertices);
			else return(polymesh->curpolyn->numberOfVertices);

			break;
	}

	return(0);
}

/****** td.library/tdMaterialSetuba ******************************************
* 
*   NAME	
* 	tdMaterialSetuba -- Set a parameter of the a material.
* 
*   SYNOPSIS
*	error = tdMaterialSetuba( spacehandle,type,index,array )
*	                          D1          D2   D3    A0
*
*	TDerrors tdMaterialSetuba
*	     ( ULONG,TDenum,ULONG,UBYTE * );
*
*   FUNCTION
*	The parameter of the material at index, will be changed.
*	Type specifies which parameter. The array its size is dependend
*	of the type.
* 
*   INPUTS
* 	spacehandle     - A valid handle of a space.
*	type            - The parameter its type.
*	index           - The material its index.
*	array           - Array which contains the values.
*	
*   RESULT
* 	error - ER_NOERROR  if all went well.
*	        ER_NOSPACE  if the handle is not valid.
*	        ER_NOTYPE   if the type is not valid.
*	        ER_NOINDEX  if the index is not valid.
*
*   EXAMPLE
*	error = tdMaterialSetuba(spacehandle,TD_AMBIENT,3,red);
*
*   NOTES
*	If a value is out of range it will be set to its possible
*	maximum or minimum.
*
*   BUGS
* 
*   SEE ALSO
* 	tdMaterialGet()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdMaterialSetuba(register __d1 ULONG spacehandle,
										register __d2 TDenum type,
										register __d3 ULONG index,
										register __a0 UBYTE *array) {
	TDspace		*space=NULL;
	TDmaterialnode	*mat=NULL;
	TDsurface		*surf=NULL;
	TDtexture		*tex=NULL;
	UBYTE			*marray=NULL;
	TDcolorub		color;

	// make a copy of the array, because a0 is a scratch register
	marray = array;

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	mat=getMaterialNode(space,index);
	if(mat==NULL) return(ER_NOINDEX);

	// do this in function of the material type
	switch(mat->type) {
		case TD_SURFACE :
			surf=(TDsurface *)mat->handle;

			// check which parameter has to be changed
			switch(type) {
				case TD_AMBIENT :
					color.r=marray[0];
					color.g=marray[1];
					color.b=marray[2];

					surf->ambientColor=color;

					break;
				case TD_DIFFUSE :
					color.r=marray[0];
					color.g=marray[1];
					color.b=marray[2];

					surf->diffuseColor=color;

					break;
				case TD_SHININESS :
					surf->shininess=marray[0];
					surf->shininess/=255;

					break;
				case TD_TRANSPARENCY :
					surf->transparency=marray[0];
					surf->transparency/=255;

					break;
				default :
					return(ER_NOTYPE);
			}
			break;

		case TD_TEXTURE :
			tex=(TDtexture *)mat->handle;
			break;

	}
	return(ER_NOERROR);
}

/****** td.library/tdMaterialGetuba ******************************************
* 
*   NAME	
* 	tdMaterialGetuba -- Get a parameter of the a material.
* 
*   SYNOPSIS
*	error = tdMaterialGetuba( spacehandle,type,index,array )
*	                          D1          D2   D3    A0
*
*	TDerrors tdMaterialGetuba
*	     ( ULONG,TDenum,ULONG,UBYTE * );
*
*   FUNCTION
*	The parameter of the material at index, will be returned.
*	Type specifies which parameter. The array its size is dependend
*	of the type.
* 
*   INPUTS
* 	spacehandle     - A valid handle of a space.
*	type            - The parameter its type.
*	index           - The material its index.
*	array           - Pointer to a correct sized array, which
*	                  will contain the values.
*	
*   RESULT
* 	error - ER_NOERROR  if all went well.
*	        ER_NOSPACE  if the handle is not valid.
*	        ER_NOTYPE   if the type is not valid.
*	        ER_NOINDEX  if the index is not valid.
*
*   EXAMPLE
*	error = tdMaterialGetuba(spacehandle,TD_AMBIENT,3,colorarray);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdMaterialSet()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdMaterialGetuba(register __d1 ULONG spacehandle,
										register __d2 TDenum type,
										register __d3 ULONG index,
										register __a0 UBYTE *array) {
	TDspace		*space=NULL;
	TDmaterialnode	*mat=NULL;
	TDsurface		*surf=NULL;
	TDtexture		*tex=NULL;
	UBYTE			*marray=NULL;

	// make a copy of the array, because a0 is a scratch register
	marray = array;

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	mat=getMaterialNode(space,index);
	if(mat==NULL) return(ER_NOINDEX);

	// do this in function of the material type
	switch(mat->type) {
		case TD_SURFACE :
			surf=(TDsurface *)mat->handle;

			// check which parameter has to be returned
			switch(type) {
				case TD_AMBIENT :
					marray[0]=surf->ambientColor.r;
					marray[1]=surf->ambientColor.g;
					marray[2]=surf->ambientColor.b;

					break;
				case TD_DIFFUSE :
					marray[0]=surf->diffuseColor.r;
					marray[1]=surf->diffuseColor.g;
					marray[2]=surf->diffuseColor.b;

					break;
				case TD_SHININESS :
					marray[0]=UBYTE(surf->shininess*255);

					break;
				case TD_TRANSPARENCY :
					marray[0]=UBYTE(surf->transparency*255);

					break;
				default :
					return(ER_NOTYPE);
			}
			break;

		case TD_TEXTURE :
			tex=(TDtexture *)mat->handle;
	
			break;

	}

	return(ER_NOERROR);
}

/****** td.library/tdMaterialSetfa ******************************************
* 
*   NAME	
* 	tdMaterialSetfa -- Set a parameter of the a material.
* 
*   SYNOPSIS
*	error = tdMaterialSetfa( spacehandle,type,index,array )
*	                         D1          D2   D3     A0
*
*	TDerrors tdMaterialSetfa
*	     ( ULONG,TDenum,ULONG,TDfloat * );
*
*   FUNCTION
*	The parameter of the material at index, will be changed.
*	Type specifies which parameter. The array its size is dependend
*	of the type.
* 
*   INPUTS
* 	spacehandle     - A valid handle of a space.
*	type            - The parameter its type.
*	index           - The material its index.
*	array           - Array which contains the values.
*	
*   RESULT
* 	error - ER_NOERROR  if all went well.
*	        ER_NOSPACE  if the handle is not valid.
*	        ER_NOTYPE   if the type is not valid.
*	        ER_NOINDEX  if the index is not valid.
*
*   EXAMPLE
*	error = tdMaterialSetfa(spacehandle,TD_DIFFUSE,7,red);
*
*   NOTES
*	If a value is out of range it will be set to its possible
*	maximum or minimum.
*
*   BUGS
* 
*   SEE ALSO
* 	tdMaterialGet()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdMaterialSetfa(register __d1 ULONG spacehandle,
										register __d2 TDenum type,
										register __d3 ULONG index,
										register __a0 TDfloat *array) {
	TDspace		*space=NULL;
	TDmaterialnode	*mat=NULL;
	TDsurface		*surf=NULL;
	TDtexture		*tex=NULL;
	TDfloat		*marray=NULL;
	TDcolorub		color;

	// make a copy of the array, because a0 is a scratch register
	marray = array;

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	mat=getMaterialNode(space,index);
	if(mat==NULL) return(ER_NOINDEX);

	// do this in function of the material type
	switch(mat->type) {
		case TD_SURFACE :
			surf=(TDsurface *)mat->handle;

			// check which parameter has to be changed
			switch(type) {
				case TD_AMBIENT :
					color.r=UBYTE(marray[0]*255);
					color.g=UBYTE(marray[1]*255);
					color.b=UBYTE(marray[2]*255);

					surf->ambientColor=color;

					break;
				case TD_DIFFUSE :
					color.r=UBYTE(marray[0]*255);
					color.g=UBYTE(marray[1]*255);
					color.b=UBYTE(marray[2]*255);

					surf->diffuseColor=color;

					break;
				case TD_SHININESS :
					if(marray[0]>1.0) surf->shininess=1.0;
					else if (marray[0]<0.0) surf->shininess=0.0;
					else surf->shininess=marray[0];

					break;
				case TD_TRANSPARENCY :
					if(marray[0]>1.0) surf->transparency=1.0;
					else if (marray[0]<0.0) surf->transparency=0.0;
					else surf->transparency=marray[0];

					break;
				default :
					return(ER_NOTYPE);
			}
			break;

		case TD_TEXTURE :
			tex=(TDtexture *)mat->handle;

			break;
	}

	return(ER_NOERROR);
}

/****** td.library/tdMaterialGetfa ******************************************
* 
*   NAME	
* 	tdMaterialGetfa -- Get a parameter of the a material.
* 
*   SYNOPSIS
*	error = tdMaterialGetfa( spacehandle,type,index,array )
*	                         D1          D2   D3     A0
*
*	TDerrors tdMaterialGetfa
*	     ( ULONG,TDenum,ULONG,TDfloat * );
*
*   FUNCTION
*	The parameter of the material at index, will be returned.
*	Type specifies which parameter. The array its size is dependend
*	of the type.
* 
*   INPUTS
* 	spacehandle     - A valid handle of a space.
*	type            - The parameter its type.
*	index           - The material its index.
*	array           - Pointer to a correct sized array, which
*	                  will contain the values.
*	
*   RESULT
* 	error - ER_NOERROR  if all went well.
*	        ER_NOSPACE  if the handle is not valid.
*	        ER_NOTYPE   if the type is not valid.
*	        ER_NOINDEX  if the index is not valid.
*
*   EXAMPLE
*	error = tdMaterialGetfa(spacehandle,TD_DIFFUSE,7,colorarray);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdMaterialSet()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdMaterialGetfa(register __d1 ULONG spacehandle,
										register __d2 TDenum type,
										register __d3 ULONG index,
										register __a0 TDfloat *array) {
	TDspace		*space=NULL;
	TDmaterialnode	*mat=NULL;
	TDsurface		*surf=NULL;
	TDtexture		*tex=NULL;
	TDfloat		*marray=NULL;

	// make a copy of the array, because a0 is a scratch register
	marray = array;

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	mat=getMaterialNode(space,index);
	if(mat==NULL) return(ER_NOINDEX);

	// do this in function of the material type
	switch(mat->type) {
		case TD_SURFACE :
			surf=(TDsurface *)mat->handle;

			// check which parameter has to be returned
			switch(type) {
				case TD_AMBIENT :
					marray[0]=surf->ambientColor.r;
					marray[0]/=255;
					marray[1]=surf->ambientColor.g;
					marray[1]/=255;
					marray[2]=surf->ambientColor.b;
					marray[2]/=255;

					break;
				case TD_DIFFUSE :
					marray[0]=surf->diffuseColor.r;
					marray[0]/=255;
					marray[1]=surf->diffuseColor.g;
					marray[1]/=255;
					marray[2]=surf->diffuseColor.b;
					marray[2]/=255;

					break;
				case TD_SHININESS :
					marray[0]=surf->shininess;

					break;
				case TD_TRANSPARENCY :
					marray[0]=surf->transparency;

					break;
				default :
					return(ER_NOTYPE);
			}
			break;

		case TD_TEXTURE :
			tex=(TDtexture *)mat->handle;
	
			break;
	}

	return(ER_NOERROR);
}

/****** td.library/tdMaterialSetf ******************************************
* 
*   NAME	
* 	tdMaterialSetf -- Set a single value parameter of the a material.
* 
*   SYNOPSIS
*	error = tdMaterialSetf( spacehandle,type,index,value )
*	                        D1          D2   D3    D4
*
*	TDerrors tdMaterialSetf
*	     ( ULONG,TDenum,ULONG,TDfloat );
*
*   FUNCTION
*	A single value parameter of the material at index, will be changed.
*	Type specifies which parameter.
* 
*   INPUTS
* 	spacehandle     - A valid handle of a space.
*	type            - The parameter its type.
*	index           - The material its index.
*	value           - New value of the parameter.
*	
*   RESULT
* 	error - ER_NOERROR  if all went well.
*	        ER_NOSPACE  if the handle is not valid.
*	        ER_NOTYPE   if the type is not valid.
*	        ER_NOINDEX  if the index is not valid.
*
*   EXAMPLE
*	error = tdMaterialSetf(spacehandle,TD_SHININESS,23,0.4);
*
*   NOTES
*	If a value is out of range it will be set to its possible
*	maximum or minimum.
*
*   BUGS
* 
*   SEE ALSO
* 	tdMaterialGet()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdMaterialSetf(register __d1 ULONG spacehandle,
									register __d2 TDenum type,
									register __d3 ULONG index,
									register __d4 TDfloat value) {
	TDspace		*space=NULL;
	TDmaterialnode	*mat=NULL;
	TDsurface		*surf=NULL;
	TDtexture		*tex=NULL;

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	mat=getMaterialNode(space,index);
	if(mat==NULL) return(ER_NOINDEX);

	// do this in function of the material type
	switch(mat->type) {
		case TD_SURFACE :
			surf=(TDsurface *)mat->handle;

			// check which parameter has to be changed
			switch(type) {
				case TD_SHININESS :
					if(value>1.0) surf->shininess=1.0;
					else if (value<0.0) surf->shininess=0.0;
					else surf->shininess=value;

					break;
					case TD_TRANSPARENCY :
					if(value>1.0) surf->transparency=1.0;
					else if (value<0.0) surf->transparency=0.0;
					else surf->transparency=value;

					break;
				default :
					return(ER_NOTYPE);
			}
			break;

		case TD_TEXTURE :
			tex=(TDtexture *)mat->handle;

			break;
	}

	return(ER_NOERROR);
}

/****** td.library/tdMaterialGetf ******************************************
* 
*   NAME	
* 	tdMaterialGetf -- Get a single value parameter of the a material.
* 
*   SYNOPSIS
*	error = tdMaterialGetf( spacehandle,type,index,value )
*	                        D1          D2   D3    D4
*
*	TDerrors tdMaterialGetf
*	     ( ULONG,TDenum,ULONG,TDfloat * );
*
*   FUNCTION
*	The single value parameter of the material at index, will be returned.
*	Type specifies which parameter.
* 
*   INPUTS
* 	spacehandle     - A valid handle of a space.
*	type            - The parameter its type.
*	index           - The material its index.
*	value           - Pointer to a variable which will contain
*	                  the value.
*	
*   RESULT
* 	error - ER_NOERROR  if all went well.
*	        ER_NOSPACE  if the handle is not valid.
*	        ER_NOTYPE   if the type is not valid.
*	        ER_NOINDEX  if the index is not valid.
*
*   EXAMPLE
*	error = tdMaterialGetf(spacehandle,TD_SHININESS,23,&shininess);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdMaterialSet()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdMaterialGetf(register __d1 ULONG spacehandle,
									register __d2 TDenum type,
									register __d3 ULONG index,
									register __d4 TDfloat *value) {
	TDspace		*space=NULL;
	TDmaterialnode	*mat=NULL;
	TDsurface		*surf=NULL;
	TDtexture		*tex=NULL;

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	mat=getMaterialNode(space,index);
	if(mat==NULL) return(ER_NOINDEX);

	// do this in function of the material type
	switch(mat->type) {
		case TD_SURFACE :
			surf=(TDsurface *)mat->handle;

			// check which parameter has to be returned
			switch(type) {
				case TD_SHININESS :
					(*value)=surf->shininess;

					break;
				case TD_TRANSPARENCY :
					(*value)=surf->transparency;

					break;
				default :
					return(ER_NOTYPE);
			}
			break;

		case TD_TEXTURE :
			tex=(TDtexture *)mat->handle;

			break;
	}

	return(ER_NOERROR);
}

/****** td.library/tdCTMReset **********************************************
* 
*   NAME	
* 	tdCTMReset -- Resets the transformation matrix and
*	              the scale of the space.
*
*   SYNOPSIS
*	error = tdCTMReset( spacehandle )
*	                    D1
*
*	TDerrors tdCTMReset
*	     ( ULONG );
*
*   FUNCTION
*	The translation, rotation and scale factors will be set to
*	the default values.
*	Translation is 0, rotation is 0 and scale is 1, for all axis.
*
* 
*   INPUTS
* 	spacehandle   - A valid handle of a space.
*	
*   RESULT
* 	error - ER_NOERROR   if all went well.
*	        ER_NOSPACE   if the handle is not valid.
* 
*   EXAMPLE
*	error = tdCTMReset(spacehandle);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdTranslationChange(),tdTranslationGet()
*	tdRotationChange(),tdRotationGet()
*	tdScaleChange(),tdScaleGet()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdCTMReset(register __d1 ULONG spacehandle) {
	TDspace	*space=NULL;
      
	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	space->ctm.sx=1,space->ctm.sy=1,space->ctm.sz=1;
	space->ctm.rx=0,space->ctm.ry=0,space->ctm.rz=0;
	space->ctm.m[0][0]=1,space->ctm.m[1][0]=0,space->ctm.m[2][0]=0,space->ctm.m[3][0]=0;
	space->ctm.m[0][1]=0,space->ctm.m[1][1]=1,space->ctm.m[2][1]=0,space->ctm.m[3][1]=0;
	space->ctm.m[0][2]=0,space->ctm.m[1][2]=0,space->ctm.m[2][2]=1,space->ctm.m[3][2]=0;
	space->ctm.m[0][3]=0,space->ctm.m[1][3]=0,space->ctm.m[2][3]=0,space->ctm.m[3][3]=1;
	
	return(ER_NOERROR);
}

/****** td.library/tdCTMChangedv ****************************************
* 
*   NAME	
* 	tdCTMChangedv -- Changes a parameter of the CTM of the space.
*
*   SYNOPSIS
*	error = tdCTMChangedv( spacehandle,type,vector,operation )
*	                       D1          D2    A0    D3
*
*	TDerrors tdCTMChangedv
*	     ( ULONG,TDenum,TDvectord *,TDenum );
*
*   FUNCTION
*	A parameter of the CTM will be modified in function of the vector
*	and the operation to perform.
* 
*   INPUTS
* 	spacehandle  - A valid handle of a space.
*	type         - Type of the parameter to change.
*	vector       - Pointer to a vector structure which contains
*	               the coordinates..
*	operation    - A valid CTM operation.
*
*   RESULT
* 	error - ER_NOERROR       if all went well.
*	        ER_NOSPACE       if the handle is not valid.
*	        ER_NOTYPE        if the type is not valid.
*	        ER_NOOPERATION   if the operation is not valid.
* 
*   EXAMPLE
*	error = tdCTMChangedv(spacehandle,TD_TRANSLATION,&myvector,myoperation);
*
*   NOTES
*	If you pass 0 values for a division operation,
*	the corresponding CTM entry will be set to 0.
*
*   BUGS
* 
*   SEE ALSO
* 	tdCTMReset(),tdCTMGet()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdCTMChangedv(register __d1 ULONG spacehandle,
									register __d2 TDenum type,
									register __a0 TDvectord *vector,
									register __d3 TDenum operation) {
                                
	TDspace	*space=NULL;
	TDvectord	*tvector=NULL;
      
	// make a copy of vector, a0 is a scratch register
	tvector=vector;
	
	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	// change the parameter
	switch(type) {
		case TD_TRANSLATION :
			if(translationChange(space,(*tvector),operation)) return(ER_NOOPERATION);
			break;
		case TD_ROTATION :
			if(rotationChange(space,(*tvector),operation)) return(ER_NOOPERATION);
			break;
		case TD_SCALE :
			if(scaleChange(space,(*tvector),operation)) return(ER_NOOPERATION);
			break;
		default :
			return(ER_NOTYPE);
	}

	return(ER_NOERROR);
}

/****** td.library/tdCTMChangefv ****************************************
* 
*   NAME	
* 	tdCTMChangefv -- Changes a parameter of the CTM of the space.
*
*   SYNOPSIS
*	error = tdCTMChangefv( spacehandle,type,vector,operation )
*	                       D1          D2    A0    D3
*
*	TDerrors tdCTMChangefv
*	     ( ULONG,TDenum,TDvectorf *,TDenum );
*
*   FUNCTION
*	A parameter of the CTM will be modified in function of the vector
*	and the operation to perform.
* 
*   INPUTS
* 	spacehandle  - A valid handle of a space.
*	type         - Type of the parameter to change.
*	vector       - Pointer to a vector structure which contains
*	               the coordinates..
*	operation    - A valid CTM operation.
*
*   RESULT
* 	error - ER_NOERROR       if all went well.
*	        ER_NOSPACE       if the handle is not valid.
*	        ER_NOTYPE        if the type is not valid.
*	        ER_NOOPERATION   if the operation is not valid.
* 
*   EXAMPLE
*	error = tdCTMChangedv(spacehandle,TD_TRANSLATION,&myvector,myoperation);
*
*   NOTES
*	If you pass 0 values for a division operation,
*	the corresponding CTM entry will be set to 0.
*
*   BUGS
* 
*   SEE ALSO
* 	tdCTMReset(),tdCTMGet()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdCTMChangefv(register __d1 ULONG spacehandle,
									register __d2 TDenum type,
									register __a0 TDvectorf *vector,
									register __d3 TDenum operation) {
                                
	TDspace	*space=NULL;
	TDvectord	tvector;
      
	// make a copy of vector, a0 is a scratch register
	tvector.x=vector->x;
	tvector.y=vector->y;
	tvector.z=vector->z;
	
	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	// change the parameter
	switch(type) {
		case TD_TRANSLATION :
			if(translationChange(space,tvector,operation)) return(ER_NOOPERATION);
			break;
		case TD_ROTATION :
			if(rotationChange(space,tvector,operation)) return(ER_NOOPERATION);
			break;
		case TD_SCALE :
			if(scaleChange(space,tvector,operation)) return(ER_NOOPERATION);
			break;
		default :
			return(ER_NOTYPE);
	}

	return(ER_NOERROR);
}

/****** td.library/tdCTMChange3da ****************************************
* 
*   NAME	
* 	tdCTMChange3da -- Changes a parameter of the CTM of the space.
*
*   SYNOPSIS
*	error = tdCTMChange3da( spacehandle,type,array,operation )
*	                        D1          D2    A0    D3
*
*	TDerrors tdCTMChange3da
*	     ( ULONG,TDenum,TDdouble [3],TDenum );
*
*   FUNCTION
*	A parameter of the CTM will be modified in function of the vector
*	and the operation to perform.
* 
*   INPUTS
* 	spacehandle  - A valid handle of a space.
*	type         - Type of the parameter to change.
*	array        - Array which contains the coordinates..
*	operation    - A valid CTM operation.
*
*   RESULT
* 	error - ER_NOERROR       if all went well.
*	        ER_NOSPACE       if the handle is not valid.
*	        ER_NOTYPE        if the type is not valid.
*	        ER_NOOPERATION   if the operation is not valid.
* 
*   EXAMPLE
*	error = tdCTMChange3da(spacehandle,TD_TRANSLATION,myarray,myoperation);
*
*   NOTES
*	If you pass 0 values for a division operation,
*	the corresponding CTM entry will be set to 0.
*
*   BUGS
* 
*   SEE ALSO
* 	tdCTMReset(),tdCTMGet()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdCTMChange3da(register __d1 ULONG spacehandle,
									register __d2 TDenum type,
									register __a0 TDdouble array[3],
									register __d3 TDenum operation) {
                                
	TDspace	*space=NULL;
	TDvectord	tvector;
      
	// make a copy of vector, a0 is a scratch register
	tvector.x=array[0];
	tvector.y=array[1];
	tvector.z=array[2];
	
	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	// change the parameter
	switch(type) {
		case TD_TRANSLATION :
			if(translationChange(space,tvector,operation)) return(ER_NOOPERATION);
			break;
		case TD_ROTATION :
			if(rotationChange(space,tvector,operation)) return(ER_NOOPERATION);
			break;
		case TD_SCALE :
			if(scaleChange(space,tvector,operation)) return(ER_NOOPERATION);
			break;
		default :
			return(ER_NOTYPE);
	}

	return(ER_NOERROR);
}

/****** td.library/tdCTMChange3fa ****************************************
* 
*   NAME	
* 	tdCTMChange3fa -- Changes a parameter of the CTM of the space.
*
*   SYNOPSIS
*	error = tdCTMChange3fa( spacehandle,type,array,operation )
*	                        D1          D2    A0    D3
*
*	TDerrors tdCTMChange3fa
*	     ( ULONG,TDenum,TDfloat [3],TDenum );
*
*   FUNCTION
*	A parameter of the CTM will be modified in function of the vector
*	and the operation to perform.
* 
*   INPUTS
* 	spacehandle  - A valid handle of a space.
*	type         - Type of the parameter to change.
*	array        - Array which contains the coordinates..
*	operation    - A valid CTM operation.
*
*   RESULT
* 	error - ER_NOERROR       if all went well.
*	        ER_NOSPACE       if the handle is not valid.
*	        ER_NOTYPE        if the type is not valid.
*	        ER_NOOPERATION   if the operation is not valid.
* 
*   EXAMPLE
*	error = tdCTMChange3fa(spacehandle,TD_TRANSLATION,myarray,myoperation);
*
*   NOTES
*	If you pass 0 values for a division operation,
*	the corresponding CTM entry will be set to 0.
*
*   BUGS
* 
*   SEE ALSO
* 	tdCTMReset(),tdCTMGet()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdCTMChange3fa(register __d1 ULONG spacehandle,
									register __d2 TDenum type,
									register __a0 TDfloat array[3],
									register __d3 TDenum operation) {
                                
	TDspace	*space=NULL;
	TDvectord	tvector;
      
	// make a copy of vector, a0 is a scratch register
	tvector.x=array[0];
	tvector.y=array[1];
	tvector.z=array[2];
	
	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	// change the parameter
	switch(type) {
		case TD_TRANSLATION :
			if(translationChange(space,tvector,operation)) return(ER_NOOPERATION);
			break;
		case TD_ROTATION :
			if(rotationChange(space,tvector,operation)) return(ER_NOOPERATION);
			break;
		case TD_SCALE :
			if(scaleChange(space,tvector,operation)) return(ER_NOOPERATION);
			break;
		default :
			return(ER_NOTYPE);
	}

	return(ER_NOERROR);
}

/****** td.library/tdCTMGetdv ******************************************
* 
*   NAME	
* 	tdCTMGetdv -- Get a parameter of the space its CTM.
*
*   SYNOPSIS
*	error = tdCTMGetdv( spacehandle,type,vector )
*	                    D1          D2    A0
*
*	TDerrors tdCTMGetdv
*	     ( ULONG,TDenum,TDvectord * );
*
*   FUNCTION
*	A parameter of the CTM will be returned in the passed
*	vector structure.
* 
*   INPUTS
* 	spacehandle  - A valid handle of a space.
*	type         - The type of the parameter to return.
*	vector       - Pointer to a vertex structure which will
*	               contain the values.
*
*   RESULT
* 	error - ER_NOERROR  if all went well.
*	        ER_NOSPACE  if the handle is not valid.
* 
*   EXAMPLE
*	error = tdCTMGetdv(spacehandle,TD_ROTATION,&myvector);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdCTMReset(),tdCTMChange()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdCTMGetdv(register __d1 ULONG spacehandle,
								register __d2 TDenum type,
								register __a0 TDvectord *vector) {
                                
	TDspace	*space=NULL;
	TDvectord	*tvector=NULL;
      
	// make a copy of translation vertex, a0 is a scratch register
	tvector=vector;
	
	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	switch(type) {
		case TD_TRANSLATION :
			tvector->x=space->ctm.m[3][0];
			tvector->y=space->ctm.m[3][1];
			tvector->z=space->ctm.m[3][2];
			break;
		case TD_SCALE :
			tvector->x=space->ctm.sx;
			tvector->y=space->ctm.sy;
			tvector->z=space->ctm.sz;
			break;
		case TD_ROTATION :
			tvector->x=space->ctm.rx;
			tvector->y=space->ctm.ry;
			tvector->z=space->ctm.rz;
		default :
			return(ER_NOTYPE);
	}

	return(ER_NOERROR);
}

/****** td.library/tdCTMGetfv ******************************************
* 
*   NAME	
* 	tdCTMGetfv -- Get a parameter of the space its CTM.
*
*   SYNOPSIS
*	error = tdCTMGetfv( spacehandle,type,vector )
*	                    D1          D2    A0
*
*	TDerrors tdCTMGetfv
*	     ( ULONG,TDenum,TDvectorf * );
*
*   FUNCTION
*	A parameter of the CTM will be returned in the passed
*	vector structure.
* 
*   INPUTS
* 	spacehandle  - A valid handle of a space.
*	type         - The type of the parameter to return.
*	vector       - Pointer to a vertex structure which will
*	               contain the values.
*
*   RESULT
* 	error - ER_NOERROR  if all went well.
*	        ER_NOSPACE  if the handle is not valid.
* 
*   EXAMPLE
*	error = tdCTMGetfv(spacehandle,TD_ROTATION,&myvector);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdCTMReset(),tdCTMChange()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdCTMGetfv(register __d1 ULONG spacehandle,
								register __d2 TDenum type,
								register __a0 TDvectorf *vector) {
                                
	TDspace	*space=NULL;
	TDvectorf	*tvector=NULL;
      
	// make a copy of translation vertex, a0 is a scratch register
	tvector=vector;
	
	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	switch(type) {
		case TD_TRANSLATION :
			tvector->x=space->ctm.m[3][0];
			tvector->y=space->ctm.m[3][1];
			tvector->z=space->ctm.m[3][2];
			break;
		case TD_SCALE :
			tvector->x=space->ctm.sx;
			tvector->y=space->ctm.sy;
			tvector->z=space->ctm.sz;
			break;
		case TD_ROTATION :
			tvector->x=space->ctm.rx;
			tvector->y=space->ctm.ry;
			tvector->z=space->ctm.rz;
		default :
			return(ER_NOTYPE);
	}

	return(ER_NOERROR);
}

/****** td.library/tdCTMGet3da ******************************************
* 
*   NAME	
* 	tdCTMGet3da -- Get a parameter of the space its CTM.
*
*   SYNOPSIS
*	error = tdCTMGet3da( spacehandle,type,array )
*	                    D1          D2     A0
*
*	TDerrors tdCTMGet3da
*	     ( ULONG,TDenum,TDdouble [3] );
*
*   FUNCTION
*	A parameter of the CTM will be returned in the passed
*	vector structure.
* 
*   INPUTS
* 	spacehandle  - A valid handle of a space.
*	type         - The type of the parameter to return.
*	array        - Array which will contain the values.
*
*   RESULT
* 	error - ER_NOERROR  if all went well.
*	        ER_NOSPACE  if the handle is not valid.
* 
*   EXAMPLE
*	error = tdCTMGet3da(spacehandle,TD_ROTATION,myarray);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdCTMReset(),tdCTMChange()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdCTMGet3da(register __d1 ULONG spacehandle,
								register __d2 TDenum type,
								register __a0 TDdouble array[3]) {
                                
	TDspace	*space=NULL;
	TDdouble	*marray=NULL;
      
	// make a copy of translation vertex, a0 is a scratch register
	marray=array;
	
	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	switch(type) {
		case TD_TRANSLATION :
			marray[0]=space->ctm.m[3][0];
			marray[1]=space->ctm.m[3][1];
			marray[2]=space->ctm.m[3][2];
			break;
		case TD_SCALE :
			marray[0]=space->ctm.sx;
			marray[1]=space->ctm.sy;
			marray[2]=space->ctm.sz;
			break;
		case TD_ROTATION :
			marray[0]=space->ctm.rx;
			marray[1]=space->ctm.ry;
			marray[2]=space->ctm.rz;
		default :
			return(ER_NOTYPE);
	}

	return(ER_NOERROR);
}

/****** td.library/tdCTMGet3fa ******************************************
* 
*   NAME	
* 	tdCTMGet3fa -- Get a parameter of the space its CTM.
*
*   SYNOPSIS
*	error = tdCTMGet3fa( spacehandle,type,array )
*	                    D1          D2     A0
*
*	TDerrors tdCTMGet3fa
*	     ( ULONG,TDenum,TDfloat [3] );
*
*   FUNCTION
*	A parameter of the CTM will be returned in the passed
*	vector structure.
* 
*   INPUTS
* 	spacehandle  - A valid handle of a space.
*	type         - The type of the parameter to return.
*	array        - Array which will contain the values.
*
*   RESULT
* 	error - ER_NOERROR  if all went well.
*	        ER_NOSPACE  if the handle is not valid.
* 
*   EXAMPLE
*	error = tdCTMGet3fa(spacehandle,TD_ROTATION,myarray);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdCTMReset(),tdCTMChange()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdCTMGet3fa(register __d1 ULONG spacehandle,
								register __d2 TDenum type,
								register __a0 TDfloat array[3]) {
                                
	TDspace	*space=NULL;
	TDfloat	*marray=NULL;
      
	// make a copy of translation vertex, a0 is a scratch register
	marray=array;
	
	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	switch(type) {
		case TD_TRANSLATION :
			marray[0]=space->ctm.m[3][0];
			marray[1]=space->ctm.m[3][1];
			marray[2]=space->ctm.m[3][2];
			break;
		case TD_SCALE :
			marray[0]=space->ctm.sx;
			marray[1]=space->ctm.sy;
			marray[2]=space->ctm.sz;
			break;
		case TD_ROTATION :
			marray[0]=space->ctm.rx;
			marray[1]=space->ctm.ry;
			marray[2]=space->ctm.rz;
		default :
			return(ER_NOTYPE);
	}

	return(ER_NOERROR);
}

/****** td.library/tdObjectSetfa ******************************************
* 
*   NAME	
* 	tdObjectSetfa -- Set a parameter of the an object.
* 
*   SYNOPSIS
*	error = tdObjectSetfa( spacehandle,type,index,array )
*	                       D1          D2   D3     A0
*
*	TDerrors tdObjectSetfa
*	     ( ULONG,TDenum,ULONG,TDfloat * );
*
*   FUNCTION
*	The parameter of the object at index, will be changed.
*	Type specifies which parameter. The array its size is dependend
*	of the type.
* 
*   INPUTS
* 	spacehandle     - A valid handle of a space.
*	type            - The parameter its type.
*	index           - The parameter its index.
*	array           - Array which contains the values.
*	
*   RESULT
* 	error - ER_NOERROR  if all went well.
*	        ER_NOSPACE  if the handle is not valid.
*	        ER_NOTYPE   if the type is not valid.
*	        ER_NOINDEX  if the index is not valid.
*
*   EXAMPLE
*	error = tdObjectSetfa(spacehandle,TD_CUBE,7,size);
*
*   NOTES
*	If a value is out of range it will be set to its possible
*	maximum or minimum.
*
*   BUGS
* 
*   SEE ALSO
* 	tdObjectGet()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdObjectSetfa(register __d1 ULONG spacehandle,
									register __d2 TDenum type,
									register __d3 ULONG index,
									register __a0 TDfloat *array) {
	TDspace		*space=NULL;
	TDobjectnode	*object=NULL;
	TDcube			*cube=NULL;
	TDfloat		*marray=NULL;

	// make a copy of the array, because a0 is a scratch register
	marray = array;

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	object=getObjectNode(space,index);
	if(object==NULL) return(ER_NOINDEX);

	// check which parameter has to be changed
	switch(type) {
		case TD_ORIGIN :
			object->o.x=marray[0];
			object->o.y=marray[1];
			object->o.z=marray[2];
			
			break;
		case TD_ROTATION :
			object->r.x=marray[0];
			object->r.y=marray[1];
			object->r.z=marray[2];
			
			break;
		case TD_SCALE :
			object->s.x=marray[0];
			object->s.y=marray[1];
			object->s.z=marray[2];
			
			break;
		case TD_CUBE :
			if(object->type!=TD_CUBE) {
				return(ER_NOTYPE);
			}
			cube=(TDcube *)object->handle;
			
			cube->size.x=marray[0];
			cube->size.y=marray[1];
			cube->size.z=marray[2];

			break;
		default :
			return(ER_NOTYPE);
	}

	return(ER_NOERROR);
}

/****** td.library/tdObjectGetfa ******************************************
* 
*   NAME	
* 	tdObjectGetfa -- Get a parameter of the a object.
* 
*   SYNOPSIS
*	error = tdObjectGetfa( spacehandle,type,index,array )
*	                       D1          D2   D3     A0
*
*	TDerrors tdObjectGetfa
*	     ( ULONG,TDenum,ULONG,TDfloat * );
*
*   FUNCTION
*	The parameter of the object at index, will be returned.
*	Type specifies which parameter. The array its size is dependend
*	of the type.
* 
*   INPUTS
* 	spacehandle     - A valid handle of a space.
*	type            - The parameter its type.
*	index           - The parameter its index.
*	array           - Pointer to a correct sized array, which
*	                  will contain the values.
*	
*   RESULT
* 	error - ER_NOERROR  if all went well.
*	        ER_NOSPACE  if the handle is not valid.
*	        ER_NOTYPE   if the type is not valid.
*	        ER_NOINDEX  if the index is not valid.
*
*   EXAMPLE
*	error = tdObjectGetfa(spacehandle,TD_ORIGIN,12,array);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdObjectSet()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdObjectGetfa(register __d1 ULONG spacehandle,
									register __d2 TDenum type,
									register __d3 ULONG index,
									register __a0 TDfloat *array) {
	TDspace		*space=NULL;
	TDobjectnode	*object=NULL;
	TDcube			*cube=NULL;
	TDfloat		*marray=NULL;

	// make a copy of the array, because a0 is a scratch register
	marray = array;

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	object=getObjectNode(space,index);
	if(object==NULL) return(ER_NOINDEX);

	// check which parameter has to be returned
	switch(type) {
		case TD_ORIGIN :
			marray[0]=object->o.x;
			marray[1]=object->o.y;
			marray[2]=object->o.z;
			
			break;
		case TD_ROTATION :
			marray[0]=object->r.x;
			marray[1]=object->r.y;
			marray[2]=object->r.z;
			
			break;
		case TD_SCALE :
			marray[0]=object->s.x;
			marray[1]=object->s.y;
			marray[2]=object->s.z;
			
			break;
		case TD_CUBE :
			if(object->type!=TD_CUBE) {
				return(ER_NOTYPE);
			}

			cube=(TDcube *)object->handle;

			marray[0]=cube->size.x;
			marray[1]=cube->size.y;
			marray[2]=cube->size.z;

			break;
		default :
			return(ER_NOTYPE);
	}

	return(ER_NOERROR);
}

/****** td.library/tdObjectSetda ******************************************
* 
*   NAME	
* 	tdObjectSetda -- Set a parameter of the a object.
* 
*   SYNOPSIS
*	error = tdObjectSetda( spacehandle,type,index,array )
*	                       D1          D2   D3     A0
*
*	TDerrors tdObjectSetfa
*	     ( ULONG,TDenum,ULONG,TDdouble * );
*
*   FUNCTION
*	The parameter of the object at index, will be changed.
*	Type specifies which parameter. The array its size is dependend
*	of the type.
* 
*   INPUTS
* 	spacehandle     - A valid handle of a space.
*	type            - The parameter its type.
*	index           - The parameter its index.
*	array           - Array which contains the values.
*	
*   RESULT
* 	error - ER_NOERROR  if all went well.
*	        ER_NOSPACE  if the handle is not valid.
*	        ER_NOTYPE   if the type is not valid.
*	        ER_NOINDEX  if the index is not valid.
*
*   EXAMPLE
*	error = tdObjectSetda(spacehandle,TD_ORIGIN,2,origin);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdObjectGet()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdObjectSetda(register __d1 ULONG spacehandle,
									register __d2 TDenum type,
									register __d3 ULONG index,
									register __a0 TDdouble *array) {
	TDspace		*space=NULL;
	TDobjectnode	*object=NULL;
	TDcube			*cube=NULL;
	TDdouble		*marray=NULL;

	// make a copy of the array, because a0 is a scratch register
	marray = array;

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	object=getObjectNode(space,index);
	if(object==NULL) return(ER_NOINDEX);

	// check which parameter has to be changed
	switch(type) {
		case TD_ORIGIN :
			object->o.x=marray[0];
			object->o.y=marray[1];
			object->o.z=marray[2];
			
			break;
		case TD_ROTATION :
			object->r.x=marray[0];
			object->r.y=marray[1];
			object->r.z=marray[2];
			
			break;
		case TD_SCALE :
			object->s.x=marray[0];
			object->s.y=marray[1];
			object->s.z=marray[2];
			
			break;
		case TD_CUBE :
			if(object->type!=TD_CUBE) {
				return(ER_NOTYPE);
			}
			cube=(TDcube *)object->handle;
			
			cube->size.x=marray[0];
			cube->size.y=marray[1];
			cube->size.z=marray[2];

			break;
		default :
			return(ER_NOTYPE);
	}

	return(ER_NOERROR);
}

/****** td.library/tdObjectGetda ******************************************
* 
*   NAME	
* 	tdObjectGetda -- Get a parameter of the a object.
* 
*   SYNOPSIS
*	error = tdObjectGetda( spacehandle,type,index,array )
*	                       D1          D2   D3     A0
*
*	TDerrors tdObjectGetfa
*	     ( ULONG,TDenum,ULONG,TDdouble * );
*
*   FUNCTION
*	The parameter of the object at index, will be returned.
*	Type specifies which parameter. The array its size is dependend
*	of the type.
* 
*   INPUTS
* 	spacehandle     - A valid handle of a space.
*	type            - The parameter its type.
*	index           - The parameter its index.
*	array           - Pointer to a correct sized array, which
*	                  will contain the values.
*	
*   RESULT
* 	error - ER_NOERROR  if all went well.
*	        ER_NOSPACE  if the handle is not valid.
*	        ER_NOTYPE   if the type is not valid.
*	        ER_NOINDEX  if the index is not valid.
*
*   EXAMPLE
*	error = tdObjectGetda(spacehandle,TD_SCALE,3,array);
*
*   NOTES
*	If a value is out of range it will be set to its possible
*	maximum or minimum.
*
*   BUGS
* 
*   SEE ALSO
* 	tdObjectSet()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdObjectGetda(register __d1 ULONG spacehandle,
									register __d2 TDenum type,
									register __d3 ULONG index,
									register __a0 TDdouble *array) {
	TDspace		*space=NULL;
	TDobjectnode	*object=NULL;
	TDcube			*cube=NULL;
	TDdouble		*marray=NULL;

	// make a copy of the array, because a0 is a scratch register
	marray = array;

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	object=getObjectNode(space,index);
	if(object==NULL) return(ER_NOINDEX);

	// check which parameter has to be returned
	switch(type) {
		case TD_ORIGIN :
			marray[0]=object->o.x;
			marray[1]=object->o.y;
			marray[2]=object->o.z;
			
			break;
		case TD_ROTATION :
			marray[0]=object->r.x;
			marray[1]=object->r.y;
			marray[2]=object->r.z;

			break;
		case TD_SCALE :
			marray[0]=object->s.x;
			marray[1]=object->s.y;
			marray[2]=object->s.z;
			
			break;
		case TD_CUBE :
			if(object->type!=TD_CUBE) {
				return(ER_NOTYPE);
			}

			cube=(TDcube *)object->handle;

			marray[0]=cube->size.x;
			marray[1]=cube->size.y;
			marray[2]=cube->size.z;

			break;
		default :
			return(ER_NOTYPE);
	}

	return(ER_NOERROR);
}

/****** td.library/tdTypeGet ******************************************
* 
*   NAME	
* 	tdTypeGet -- Get the real type of a component in the space.
* 
*   SYNOPSIS
*	error = tdGetType( spacehandle,type,index,rtype )
*	                   D1          D2   D3    D4
*
*	TDerrors tdTypeGet
*	     ( ULONG,TDenum,ULONG,TDenum * );
*
*   FUNCTION
*	The component of the space at index its real type will
*	be returned.
*	Type specifies which component.
* 
*   INPUTS
* 	spacehandle     - A valid handle of a space.
*	type            - The component its type.
*	index           - The parameter its index.
*	rtype           - Pointer to a variable, which
*	                  will contain the real type.
*	
*   RESULT
* 	error - ER_NOERROR  if all went well.
*	        ER_NOSPACE  if the handle is not valid.
*	        ER_NOTYPE   if the type is not valid.
*	        ER_NOINDEX  if the index is not valid.
*
*   EXAMPLE
*	error = tdTypeGet(spacehandle,TD_OBJECT,45,type);
*
*   NOTES
*	For example : TD_OBJECT which is the parent type
*	and the real type is TD_CUBE.
*
*   BUGS
* 
*   SEE ALSO
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdTypeGet(register __d1 ULONG spacehandle,
								register __d2 TDenum type,
								register __d3 ULONG index,
								register __d4 TDenum *rtype) {
	TDspace		*space=NULL;
	TDobjectnode	*object=NULL;
	TDmaterialnode	*mat=NULL;

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	// search for the real type
	switch(type) {
		case TD_OBJECT :
			object=getObjectNode(space,index);
			if(object==NULL) return(ER_NOINDEX);

			(*rtype)=object->type;

			break;
		case TD_MATERIAL :
			mat=getMaterialNode(space,index);
			if(mat==NULL) return(ER_NOINDEX);

			(*rtype)=mat->type;

			break;
		default :
			return(ER_NOTYPE);
	}

	return(ER_NOERROR);
}

/****** td.library/tdCurrent ******************************************
* 
*   NAME	
* 	tdCurrent -- Set the component to work with.
* 
*   SYNOPSIS
*	error = tdCurrent( spacehandle,type,index)
*	                   D1          D2   D3
*
*	TDerrors tdCurrent
*	     ( ULONG,TDenum,ULONG );
*
*   FUNCTION
*	The component of the space at index will be used for
*	further special operations.
*	Type specifies which component.
* 
*   INPUTS
* 	spacehandle     - A valid handle of a space.
*	type            - The component its type.
*	index           - The component its index.
*	
*   RESULT
* 	error - ER_NOERROR     if all went well.
*	        ER_NOSPACE     if the handle is not valid.
*	        ER_NOOBJECT    if there is no current object.
*	        ER_NOMATGROUP  if there is no current material group.
*	        ER_NOTYPE      if the type is not valid.
*	        ER_NOINDEX     if the index is not valid.
*
*   EXAMPLE
*	error = tdCurrent(spacehandle,TD_OBJECT,5);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdBegin(),tdEnd()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdCurrent(register __d1 ULONG spacehandle,
								register __d2 TDenum type,
								register __d3 ULONG index ) {
	TDspace		*space=NULL;
	TDpolymesh		*polymesh=NULL;
	TDmatgroupnode	*matgroupn=NULL;
	TDpolygonnode	*polyn=NULL;

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	// set the current component according the type
	switch(type) {
		case TD_OBJECT :
			space->curobjn=getObjectNode(space,index);
			if(space->curobjn==NULL) return(ER_NOINDEX);
			
			switch(space->curobjn->type) {
				case TD_POLYMESH :
					polymesh=(TDpolymesh *)(space->curobjn->handle);

					polymesh->curmatgroupn=NULL;
					polymesh->curpolyn=NULL;

					break;
			}

			break;
		case TD_MATERIAL :
			if(index<1 || index>space->materials.numberOfMaterials) return(ER_NOINDEX);

			space->curmatn=getMaterialNode(space,index);
			if(space->curmatn==NULL) return(ER_NOINDEX);

			break;
		case TD_MATGROUP :
			// check the parent
			if(space->curobjn==NULL) return(ER_NOOBJECT);
			if(space->curobjn->type!=TD_POLYMESH) return(ER_NOOBJECT);

			polymesh=(TDpolymesh *)(space->curobjn->handle);

			// get the matgroup
			matgroupn=getMatGroupNode(polymesh,index);
			if(matgroupn==NULL) return(ER_NOINDEX);

			polymesh->curmatgroupn=matgroupn;

			break;
		case TD_POLYGON :
			// check the parent
			if(space->curobjn==NULL) return(ER_NOOBJECT);
			if(space->curobjn->type!=TD_POLYMESH) return(ER_NOOBJECT);

			polymesh=(TDpolymesh *)(space->curobjn->handle);

			matgroupn=polymesh->curmatgroupn;
			
			if(matgroupn==NULL) return(ER_NOMATGROUP);

			polyn=getPolygonNode(matgroupn,index);
			if(polyn==NULL) return(ER_NOINDEX);

			polymesh->curpolyn=polyn;

			break;
		default :
			return(ER_NOTYPE);
	}

	return(ER_NOERROR);
}

/****** td.library/tdBegin ******************************************
* 
*   NAME	
* 	tdBegin -- Begin of a new child component.
* 
*   SYNOPSIS
*	error = tdBegin( spacehandle,type)
*	                 D1          D2
*
*	TDerrors tdBegin
*	     ( ULONG,TDenum );
*
*   FUNCTION
*	You can start to make a new child component to the
*	current component of the space.
*	In most cases for object components only.
*	Type specifies which child component.
* 
*   INPUTS
* 	spacehandle     - A valid handle of a space.
*	type            - Type of the child component.
*	
*   RESULT
* 	error - ER_NOERROR     if all went well.
*	        ER_NOSPACE     if the handle is not valid.
*	        ER_NOOBJECT    if there is no current object..
*	        ER_NOMATGROUP  if there is no current material group.
*	        ER_NOTYPE      if the type is not valid.
*	        ER_NOMEMORY    if there is not enough memory.
*
*   EXAMPLE
*	error = tdBegin(spacehandle,TD_POLYGON);
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
* 	tdCurrent(),tdEnd()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdBegin(register __d1 ULONG spacehandle,
								register __d2 TDenum type) {
	TDspace		*space=NULL;
	TDpolymesh		*polymesh=NULL;
	TDmatgroupnode	*matgroupnode=NULL;
	TDpolygonnode	*polynode=NULL;

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	// set the current component according the type
	switch(type) {
		case TD_MATGROUP :
			// check the parent
			if(space->curobjn==NULL) return(ER_NOOBJECT);
			if(space->curobjn->type!=TD_POLYMESH) return(ER_NOOBJECT);

			polymesh=(TDpolymesh *)(space->curobjn->handle);

			// create the new matgroup node
			matgroupnode=addMatGroupNode(polymesh,space->curmatn);
			if(matgroupnode==NULL) return(ER_NOMEMORY);

			// assign this matgroup node to the mesh
			polymesh->curmatgroupn=matgroupnode;

			break;

		case TD_POLYGON :
			// check the parent
			if(space->curobjn==NULL) return(ER_NOOBJECT);
			if(space->curobjn->type!=TD_POLYMESH) return(ER_NOOBJECT);

			polymesh=(TDpolymesh *)(space->curobjn->handle);

			// check the current matgroup
			if(polymesh->curmatgroupn==NULL) return(ER_NOMATGROUP);

			matgroupnode=polymesh->curmatgroupn;

			// Create a new polygon, add it to the internal list
			if((polynode=addPolygon(polymesh,matgroupnode,Ci_POLYVERARRAYINIT))==NULL) return(ER_NOMEMORY);

			polymesh->curpolyn=polynode;

			break;
		default :
			return(ER_NOTYPE);
	}

	return(ER_NOERROR);
}

/****** td.library/tdEnd ******************************************
* 
*   NAME	
* 	tdEnd -- Ends a child component started with tdBegin, or
*	         resets a (child) component set with tdCurrent.
* 
*   SYNOPSIS
*	error = tdEnd( spacehandle,type)
*	               D1          D2
*
*	TDerrors tdEnd
*	     ( ULONG,TDenum );
*
*   FUNCTION
*	The component of the space will be reset.
*	Or the child component of a parent.
*	Type specifies which component.
* 
*   INPUTS
* 	spacehandle     - A valid handle of a space.
*	type            - The component its type.
*	
*   RESULT
* 	error - ER_NOERROR     if all went well.
*	        ER_NOSPACE     if the handle is not valid.
*	        ER_NOOBJECT    if there is no current object.
*	        ER_NOTYPE      if the type is not valid.
*
*   EXAMPLE
*	error = tdEnd(spacehandle,TD_POLYGON);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdBegin(),tdCurrent()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdEnd(register __d1 ULONG spacehandle,
							register __d2 TDenum type) {
	TDspace		*space=NULL;
	TDpolymesh		*polymesh=NULL;

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	// reset the current component according the type
	switch(type) {
		case TD_OBJECT :
			space->curobjn=NULL;

			break;
		case TD_MATERIAL :
			space->curmatn=NULL;

			break;
		case TD_MATGROUP :
			// check the parent
			if(space->curobjn==NULL) return(ER_NOOBJECT);
			if(space->curobjn->type!=TD_POLYMESH) return(ER_NOOBJECT);

			polymesh=(TDpolymesh *)(space->curobjn->handle);

			polymesh->curmatgroupn=NULL;

			// no matgroup => no polygon
			polymesh->curpolyn=NULL;

			break;
		case TD_POLYGON :
			// check the parent
			if(space->curobjn==NULL) return(ER_NOOBJECT);
			if(space->curobjn->type!=TD_POLYMESH) return(ER_NOOBJECT);

			polymesh=(TDpolymesh *)(space->curobjn->handle);

			polymesh->curpolyn=NULL;

			break;
		default :
			return(ER_NOTYPE);
	}

	return(ER_NOERROR);
}

/****** td.library/tdVertexAdd3f *************************************************
* 
*   NAME	
* 	tdVertexAdd3f -- Add a new vertex to the current object its
*	                 vertex list or to the current polygon,
*	                 this according the CTM.
*
*   SYNOPSIS
*	error = tdVertexAdd3f( spacehandle,x, y, z )
*	                       D1          D2 D3 D4
*
*	TDerrors tdVertexAdd3f
*	     ( ULONG,TDfloat,TDfloat,TDfloat );
*
*   FUNCTION
*	A new vertex will be added to the current object its vertex list.
*   If tdBegin or tdCurrent was called before it will be assigned
*	to the current polygon, else it will only be added to the object,
*	binding to a polygon can be made later.
*   The index of the new vertex will be the new number of vertices
*	count.
* 
*   INPUTS
* 	spacehandle   - A valid handle of a space.
*	x,y,z         - The coordinates of the new vertex.
*	
*   RESULT
* 	error - ER_NOERROR    if all went well.
*	        ER_NOSPACE    if the handle is not valid.
*	        ER_NOOBJECT   if there is no current object.
*	        ER_NOMEMORY   if there is not enough memory. 
* 
*   EXAMPLE
*	error = tdVertexAdd3f(spacehandle,1.0,2.0,3.0);
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
* 	tdVertexGet(),
*	tdVertexIndexGet(),tdVertexAssign()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdVertexAdd3f(register __d1 ULONG spacehandle,
									register __d2 TDfloat x,
									register __d3 TDfloat y,
									register __d4 TDfloat z) {
                                
	TDspace		*space=NULL;
	TDpolymesh		*mesh=NULL;
	TDvectord		vertex;
	ULONG			vindex;

	vertex.x=x,vertex.y=y,vertex.z=z;
	
	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	if(space->curobjn==NULL) return(ER_NOOBJECT);
	if(space->curobjn->type!=TD_POLYMESH) return(ER_NOOBJECT);

	mesh=(TDpolymesh *)(space->curobjn->handle);

	if((vindex=addVertex(mesh,space->ctm,vertex))==0) return(ER_NOMEMORY);

	// check if we have to assign it to a current polygon
	if(mesh->curpolyn!=NULL) {
		if(assignVertex(mesh,mesh->curmatgroupn,mesh->curpolyn,vindex)==0) return(ER_NOMEMORY);
	}

	return(ER_NOERROR);
}

/****** td.library/tdVertexGet3d *************************************************
* 
*   NAME	
* 	tdVertexGet3d -- Get a vertex of the current object its vertex list. If a
*	                 current polygon is set the vertexindex is assumed
*	                 to be out of the polygon and you will get the vertex
*	                 of the polygon.
*
*   SYNOPSIS
*	error = tdVertexGet3d( spacehandle,vertexindex,x, y, z )
*	                       D1          D2          D3 D4 D5
*
*	TDerrors tdVertexGet3d
*	     ( ULONG,ULONG,TDdouble *,TDdouble *,TDdouble * );
*
*   FUNCTION
*	The vertex of the current object found with vertexindex
*	will be returned in the passed 3 coordinate variables.
*	Or if a current polygon is set you will get
*	the vertex of the polygon.
* 
*   INPUTS
* 	spacehandle  - A valid handle of a space.
*	vertexindex  - A valid index of a vertex.
*	x,y,z        - The double variables which will contain 
*	               the coordinates of the vertex.
*	
*   RESULT
* 	error - ER_NOERROR    if all went well.
*	        ER_NOSPACE    if the handle is not valid.
*	        ER_NOOBJECT   if there is no current object.
*	        ER_NOVERTEX   if the index is not valid.
* 
*   EXAMPLE
*	error = tdVertexGet3d(spacehandle,vertexindex,&x,&y,&z);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdVertexAdd(),
*	tdVertexIndexGet(),tdVertexAssign()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdVertexGet3d(register __d1 ULONG spacehandle,
									register __d2 ULONG vertexindex,
									register __d3 TDdouble *x,
									register __d4 TDdouble *y,
									register __d5 TDdouble *z) {
                                
	TDspace	*space=NULL;
	TDpolymesh	*mesh=NULL;
	TDvectord	*vertex=NULL;
	ULONG		vindex;
      
	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	if(space->curobjn==NULL) return(ER_NOOBJECT);
	if(space->curobjn->type!=TD_POLYMESH) return(ER_NOOBJECT);

	mesh=(TDpolymesh *)(space->curobjn->handle);
	// check if the mesh its vertex or the one of the current polygon
	if(mesh->curpolyn==NULL) {
		vindex=vertexindex;
	} else {
		if(vertexindex<1 || vertexindex>mesh->curpolyn->numberOfVertices) return(ER_NOVERTEX);
		// internal index = - 1
		vindex=mesh->curpolyn->varray[vertexindex-1];
	}

    vertex=getVertex(mesh,vindex);
	if(vertex==NULL) return(ER_NOVERTEX);

	(*x)=vertex->x;
	(*y)=vertex->y;
	(*z)=vertex->z;

	return(ER_NOERROR);
}

/****** td.library/tdVertexGet3f *************************************************
* 
*   NAME	
* 	tdVertexGet3f -- Get a vertex of the current object its vertex list. If a
*	                 current polygon is set the vertexindex is assumed
*	                 to be out of the polygon and you will get the vertex
*	                 of the polygon.
*
*   SYNOPSIS
*	error = tdVertexGet3f( spacehandle,vertexindex,x, y, z )
*	                       D1          D2          D3 D4 D5
*
*	TDerrors tdVertexGet3f
*	     ( ULONG,ULONG,TDfloat *,TDfloat *,TDfloat * );
*
*   FUNCTION
*	The vertex of the current object found with vertexindex
*	will be returned in the passed 3 coordinate variables.
*	Or if a current polygon is set you will get
*	the vertex of the polygon.
* 
*   INPUTS
* 	spacehandle  - A valid handle of a space.
*	vertexindex  - A valid index of a vertex.
*	x,y,z        - The float variables which will contain 
*	               the coordinates of the vertex.
*	
*   RESULT
* 	error - ER_NOERROR    if all went well.
*	        ER_NOSPACE    if the handle is not valid.
*	        ER_NOOBJECT   if there is no current object.
*	        ER_NOVERTEX   if the index is not valid.
* 
*   EXAMPLE
*	error = tdVertexGet3f(spacehandle,vertexindex,&x,&y,&z);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdVertexAdd(),
*	tdVertexIndexGet(),tdVertexAssign()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdVertexGet3f(register __d1 ULONG spacehandle,
									register __d2 ULONG vertexindex,
									register __d3 TDfloat *x,
									register __d4 TDfloat *y,
									register __d5 TDfloat *z) {
                                
	TDspace	*space=NULL;
	TDpolymesh	*mesh=NULL;
	TDvectord	*vertex=NULL;
	ULONG		vindex;
      
	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	if(space->curobjn==NULL) return(ER_NOOBJECT);
	if(space->curobjn->type!=TD_POLYMESH) return(ER_NOOBJECT);

	mesh=(TDpolymesh *)(space->curobjn->handle);
	// check if the mesh its vertex or the one of the current polygon
	if(mesh->curpolyn==NULL) {
		vindex=vertexindex;
	} else {
		if(vertexindex<1 || vertexindex>mesh->curpolyn->numberOfVertices) return(ER_NOVERTEX);
		// internal index = - 1
		vindex=mesh->curpolyn->varray[vertexindex-1];
	}

    vertex=getVertex(mesh,vindex);
	if(vertex==NULL) return(ER_NOVERTEX);

	(*x)=vertex->x;
	(*y)=vertex->y;
	(*z)=vertex->z;

	return(ER_NOERROR);
}

/****** td.library/tdVertexAdddv *************************************************
* 
*   NAME	
* 	tdVertexAdddv -- Add a new vertex to the current object its
*	                 vertex list or to the current polygon,
*	                 this according the CTM.
*
*   SYNOPSIS
*	error = tdVertexAdddv( spacehandle,vertex )
*	                       D1           A0
*
*	TDerrors tdVertexAdddv
*	     ( ULONG,TDvectord * );
*
*   FUNCTION
*	A new vertex will be added to the current object its vertex list.
*	If tdBegin or tdCurrent was called before, it will be assigned
*	to the current polygon, else it will only be added to the object,
*	binding to a polygon can be made later.
*	The index of the new vertex will be the new number of vertices
*	count.
* 
*   INPUTS
* 	spacehandle  - A valid handle of a space.
*	vertex       - Pointer to a vector structure which contains the
*	               coordinates of the new vertex.
*	
*   RESULT
* 	error - ER_NOERROR    if all went well.
*	        ER_NOSPACE    if the handle is not valid.
*	        ER_NOOBJECT   if there is no current object.
*	        ER_NOMEMORY   if there is not enough memory. 
* 
*   EXAMPLE
*	error = tdVertexAdddv(spacehandle,&myvertex);
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
* 	tdVertexGet(),
*	tdVertexIndexGet(),tdVertexAssign()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdVertexAdddv(register __d1 ULONG spacehandle,
									register __a0 TDvectord *vertex) {


	TDspace		*space=NULL;
	TDpolymesh		*mesh=NULL;
	TDvectord		*mvertex=NULL;
	ULONG			vindex;

	mvertex=vertex;
	
	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	if(space->curobjn==NULL) return(ER_NOOBJECT);
	if(space->curobjn->type!=TD_POLYMESH) return(ER_NOOBJECT);

	mesh=(TDpolymesh *)(space->curobjn->handle);

	if((vindex=addVertex(mesh,space->ctm,(*mvertex)))==0) return(ER_NOMEMORY);

	// check if we have to assign it to a current polygon
	if(mesh->curpolyn!=NULL) {
		if(assignVertex(mesh,mesh->curmatgroupn,mesh->curpolyn,vindex)==0) return(ER_NOMEMORY);
	}

	return(ER_NOERROR);
}

/****** td.library/tdVertexAddfv *************************************************
* 
*   NAME	
* 	tdVertexAddfv -- Add a new vertex to the current object its
*	                 vertex list or to the current polygon,
*	                 this according the CTM.
*
*   SYNOPSIS
*	error = tdVertexAddfv( spacehandle,vertex )
*	                       D1           A0
*
*	TDerrors tdVertexAddfv
*	     ( ULONG,TDvectorf * );
*
*   FUNCTION
*	A new vertex will be added to the current object its vertex list.
*	If tdBegin or tdCurrent was called before, it will be assigned
*	to the current polygon, else it will only be added to the object,
*	binding to a polygon can be made later.
*	The index of the new vertex will be the new number of vertices
*	count.
* 
*   INPUTS
* 	spacehandle  - A valid handle of a space.
*	vertex       - Pointer to a vector structure which contains the
*	               coordinates of the new vertex.
*	
*   RESULT
* 	error - ER_NOERROR    if all went well.
*	        ER_NOSPACE    if the handle is not valid.
*	        ER_NOOBJECT   if there is no current object.
*	        ER_NOMEMORY   if there is not enough memory. 
* 
*   EXAMPLE
*	error = tdVertexAddfv(spacehandle,&myvertex);
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
* 	tdVertexGet(),
*	tdVertexIndexGet(),tdVertexAssign()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdVertexAddfv(register __d1 ULONG spacehandle,
									register __a0 TDvectorf *vertex) {


	TDspace		*space=NULL;
	TDpolymesh		*mesh=NULL;
	TDvectord		mvertex;
	ULONG			vindex;

	mvertex.x=vertex->x;
	mvertex.y=vertex->y;
	mvertex.z=vertex->z;

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	if(space->curobjn==NULL) return(ER_NOOBJECT);
	if(space->curobjn->type!=TD_POLYMESH) return(ER_NOOBJECT);

	mesh=(TDpolymesh *)(space->curobjn->handle);

	if((vindex=addVertex(mesh,space->ctm,mvertex))==0) return(ER_NOMEMORY);

	// check if we have to assign it to a current polygon
	if(mesh->curpolyn!=NULL) {
		if(assignVertex(mesh,mesh->curmatgroupn,mesh->curpolyn,vindex)==0) return(ER_NOMEMORY);
	}

	return(ER_NOERROR);
}

/****** td.library/tdVertexAdd3da *************************************************
* 
*   NAME	
* 	tdVertexAdd3da -- Add a new vertex to the current object its
*	                  vertex list or to the current polygon,
*	                  this according the CTM.
*   SYNOPSIS
*	error = tdVertexAdd3da( spacehandle,array )
*	                        D1           A0
*
*	TDerrors tdVertexAdd3da
*	     ( ULONG,TDdouble [3] );
*
*   FUNCTION
*	A new vertex will be added to the current object its vertex list.
*	If tdBegin or tdCurrent was called before, it will be assigned
*	to the current polygon, else it will only be added to the object,
*	binding to a polygon can be made later.
*	The index of the new vertex will be the new number of vertices
*	count.
* 
*   INPUTS
* 	spacehandle  - A valid handle of a space.
*	array        - A double array which contains the coordinates
*	               of the new vertex.
*	
*   RESULT
* 	error - ER_NOERROR    if all went well.
*	        ER_NOSPACE    if the handle is not valid.
*	        ER_NOOBJECT   if there is no current object.
*	        ER_NOMEMORY   if there is not enough memory. 
* 
*   EXAMPLE
*	error = tdVertexAdd3da(spacehandle,myvertex);
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
* 	tdVertexGet(),
*	tdVertexIndexGet(),tdVertexAssign()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdVertexAdd3da(register __d1 ULONG spacehandle,
									register __a0 TDdouble array[3]) {

	TDspace		*space=NULL;
	TDpolymesh		*mesh=NULL;
	TDvectord		mvertex;
	ULONG			vindex;

	mvertex.x=array[0];
	mvertex.y=array[1];
	mvertex.z=array[2];

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	if(space->curobjn==NULL) return(ER_NOOBJECT);
	if(space->curobjn->type!=TD_POLYMESH) return(ER_NOOBJECT);

	mesh=(TDpolymesh *)(space->curobjn->handle);

	if((vindex=addVertex(mesh,space->ctm,mvertex))==0) return(ER_NOMEMORY);

	// check if we have to assign it to a current polygon
	if(mesh->curpolyn!=NULL) {
		if(assignVertex(mesh,mesh->curmatgroupn,mesh->curpolyn,vindex)==0) return(ER_NOMEMORY);
	}

	return(ER_NOERROR);
}

/****** td.library/tdVertexAdd3fa *************************************************
* 
*   NAME	
* 	tdVertexAdd3fa -- Add a new vertex to the current object its
*	                  vertex list or to the current polygon,
*	                  this according the CTM.
*   SYNOPSIS
*	error = tdVertexAdd3fa( spacehandle,array )
*	                        D1           A0
*
*	TDerrors tdVertexAdd3fa
*	     ( ULONG,TDfloat [3] );
*
*   FUNCTION
*	A new vertex will µbe added to the current object its vertex list.
*	If tdBegin or tdCurrent was called before, it will be assigned
*	to the current polygon, else it will only be added to the object,
*	binding to a polygon can be made later.
*	The index of the new vertex will be the new number of vertices
*	count.
* 
*   INPUTS
* 	spacehandle  - A valid handle of a space.
*	array        - A float array which contains the coordinates
*	               of the new vertex.
*	
*   RESULT
* 	error - ER_NOERROR    if all went well.
*	        ER_NOSPACE    if the handle is not valid.
*	        ER_NOOBJECT   if there is no current object.
*	        ER_NOMEMORY   if there is not enough memory. 
* 
*   EXAMPLE
*	error = tdVertexAdd3fa(spacehandle,myvertex);
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
* 	tdVertexGet(),
*	tdVertexIndexGet(),tdVertexAssign()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdVertexAdd3fa(register __d1 ULONG spacehandle,
									register __a0 TDfloat array[3]) {

	TDspace		*space=NULL;
	TDpolymesh		*mesh=NULL;
	TDvectord		mvertex;
	ULONG			vindex;

	mvertex.x=array[0];
	mvertex.y=array[1];
	mvertex.z=array[2];

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	if(space->curobjn==NULL) return(ER_NOOBJECT);
	if(space->curobjn->type!=TD_POLYMESH) return(ER_NOOBJECT);

	mesh=(TDpolymesh *)(space->curobjn->handle);

	if((vindex=addVertex(mesh,space->ctm,mvertex))==0) return(ER_NOMEMORY);

	// check if we have to assign it to a current polygon
	if(mesh->curpolyn!=NULL) {
		if(assignVertex(mesh,mesh->curmatgroupn,mesh->curpolyn,vindex)==0) return(ER_NOMEMORY);
	}

	return(ER_NOERROR);
}

/****** td.library/tdVertexGetdv *************************************************
* 
*   NAME	
* 	tdVertexGetdv -- Get a vertex of the current object its vertex list. If a
*	                 current polygon is set the vertexindex is assumed
*	                 to be out of the polygon and you will get the vertex
*	                 of the polygon.
*
*   SYNOPSIS
*	error = tdVertexGetdv( spacehandle,vertexindex,vertex )
*	                       D1          D2           A0
*
*	TDerrors tdVertexGetdv
*	     ( ULONG,ULONG,TDvectord * );
*
*   FUNCTION
*	The vertex of the current object found with vertexindex
*	will be returned in the passed vector structure.
*	Or if a current polygon is set you will get
*	the vertex of the polygon.
* 
*   INPUTS
* 	spacehandle  - A valid handle of a space.
*	vertexindex  - A valid handle of a vertex
*	vertex       - Pointer to a vector structure which will contain
*	               the coordinates of the vertex.
*	
*   RESULT
* 	error - ER_NOERROR    if all went well.
*	        ER_NOSPACE    if the handle is not valid.
*	        ER_NOOBJECT   if there is no current object.
*	        ER_NOVERTEX   if the index is not valid.
* 
*   EXAMPLE
*	error = tdVertexGetdv(spacehandle,67,&myvertex);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdVertexAdd(),
*	tdVertexIndexGet(),tdVertexAssign()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdVertexGetdv(register __d1 ULONG spacehandle,
									register __d2 ULONG vertexindex,
									register __a0 TDvectord *vertex) {

	TDspace	*space=NULL;
	TDpolymesh	*mesh=NULL;
	TDvectord	*mvertex=NULL;
	ULONG		vindex;
      
	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	if(space->curobjn==NULL) return(ER_NOOBJECT);
	if(space->curobjn->type!=TD_POLYMESH) return(ER_NOOBJECT);

	mesh=(TDpolymesh *)(space->curobjn->handle);
	// check if the mesh its vertex or the one of the current polygon
	if(mesh->curpolyn==NULL) {
		vindex=vertexindex;
	} else {
		if(vertexindex<1 || vertexindex>mesh->curpolyn->numberOfVertices) return(ER_NOVERTEX);
		// internal index = - 1
		vindex=mesh->curpolyn->varray[vertexindex-1];
	}

    mvertex=getVertex(mesh,vindex);
	if(mvertex==NULL) return(ER_NOVERTEX);

	vertex->x=mvertex->x;
	vertex->y=mvertex->y;
	vertex->z=mvertex->z;

	return(ER_NOERROR);
}

/****** td.library/tdVertexGetfv *************************************************
* 
*   NAME	
* 	tdVertexGetfv -- Get a vertex of the current object its vertex list. If a
*	                 current polygon is set the vertexindex is assumed
*	                 to be out of the polygon and you will get the vertex
*	                 of the polygon.
*
*   SYNOPSIS
*	error = tdVertexGetfv( spacehandle,vertexindex,vertex )
*	                       D1          D2           A0
*
*	TDerrors tdVertexGetfv
*	     ( ULONG,ULONG,TDvectorf * );
*
*   FUNCTION
*	The vertex of the current object found with vertexindex
*	will be returned in the passed vector structure.
*	Or if a current polygon is set you will get
*	the vertex of the polygon.
* 
*   INPUTS
* 	spacehandle  - A valid handle of a space.
*	vertexindex  - A valid handle of a vertex
*	vertex       - Pointer to a vector structure which will contain
*	               the coordinates of the vertex.
*	
*   RESULT
* 	error - ER_NOERROR    if all went well.
*	        ER_NOSPACE    if the handle is not valid.
*	        ER_NOOBJECT   if there is no current object.
*	        ER_NOVERTEX   if the index is not valid.
* 
*   EXAMPLE
*	error = tdVertexGetfv(spacehandle,32,&myvertex);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdVertexAdd(),
*	tdVertexIndexGet(),tdVertexAssign()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdVertexGetfv(register __d1 ULONG spacehandle,
									register __d2 ULONG vertexindex,
									register __a0 TDvectorf *vertex) {

	TDspace	*space=NULL;
	TDpolymesh	*mesh=NULL;
	TDvectord	*mvertex=NULL;
	ULONG		vindex;
      
	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	if(space->curobjn==NULL) return(ER_NOOBJECT);
	if(space->curobjn->type!=TD_POLYMESH) return(ER_NOOBJECT);

	mesh=(TDpolymesh *)(space->curobjn->handle);
	// check if the mesh its vertex or the one of the current polygon
	if(mesh->curpolyn==NULL) {
		vindex=vertexindex;
	} else {
		if(vertexindex<1 || vertexindex>mesh->curpolyn->numberOfVertices) return(ER_NOVERTEX);
		// internal index = - 1
		vindex=mesh->curpolyn->varray[vertexindex-1];
	}

    mvertex=getVertex(mesh,vindex);
	if(mvertex==NULL) return(ER_NOVERTEX);

	vertex->x=mvertex->x;
	vertex->y=mvertex->y;
	vertex->z=mvertex->z;

	return(ER_NOERROR);
}

/****** td.library/tdVertexGet3da *************************************************
* 
*   NAME	
* 	tdVertexGet3da -- Get a vertex of the current object its vertex list. If a
*	                  current polygon is set the vertexindex is assumed
*	                  to be out of the polygon and you will get the vertex
*	                  of the polygon.
*
*   SYNOPSIS
*	error = tdVertexGet3da( spacehandle,vertexindex,array )
*	                        D1          D2           A0
*
*	TDerrors tdVertexGet3da
*	     ( ULONG,ULONG,TDdouble [3] );
*
*   FUNCTION
*	The vertex of the current object found with vertexindex
*	will be returned in the passed double array.
*	Or if a current polygon is set you will get
*	the vertex of the polygon.
* 
*   INPUTS
* 	spacehandle  - A valid handle of a space.
*	vertexindex  - A valid handle of a vertex
*	array        - A correct sized double array which will contain
*	               the coordinates of the vertex.
*	
*   RESULT
* 	error - ER_NOERROR    if all went well.
*	        ER_NOSPACE    if the handle is not valid.
*	        ER_NOOBJECT   if there is no current object.
*	        ER_NOVERTEX   if the index is not valid.
* 
*   EXAMPLE
*	error = tdVertexGet3da(spacehandle,17,array);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdVertexAdd(),
*	tdVertexIndexGet(),tdVertexAssign()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdVertexGet3da(register __d1 ULONG spacehandle,
									register __d2 ULONG vertexindex,
									register __a0 TDdouble array[3]) {

	TDspace	*space=NULL;
	TDpolymesh	*mesh=NULL;
	TDvectord	*mvertex=NULL;
	TDdouble	*marray=NULL;
	ULONG		vindex;

	// make a copy of the array, a0 is a scratch register
	marray=array;
      
	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	if(space->curobjn==NULL) return(ER_NOOBJECT);
	if(space->curobjn->type!=TD_POLYMESH) return(ER_NOOBJECT);

	mesh=(TDpolymesh *)(space->curobjn->handle);
	// check if the mesh its vertex or the one of the current polygon
	if(mesh->curpolyn==NULL) {
		vindex=vertexindex;
	} else {
		if(vertexindex<1 || vertexindex>mesh->curpolyn->numberOfVertices) return(ER_NOVERTEX);
		// internal index = - 1
		vindex=mesh->curpolyn->varray[vertexindex-1];
	}

    mvertex=getVertex(mesh,vindex);
	if(mvertex==NULL) return(ER_NOVERTEX);

	marray[0]=mvertex->x;
	marray[1]=mvertex->y;
	marray[2]=mvertex->z;

	return(ER_NOERROR);
}

/****** td.library/tdVertexGet3fa *************************************************
* 
*   NAME	
* 	tdVertexGet3fa -- Get a vertex of the current object its vertex list. If a
*	                  current polygon is set the vertexindex is assumed
*	                  to be out of the polygon and you will get the vertex
*	                  of the polygon.
*
*   SYNOPSIS
*	error = tdVertexGet3fa( spacehandle,vertexindex,array )
*	                        D1          D2           A0
*
*	TDerrors tdVertexGet3fa
*	     ( ULONG,ULONG,TDfloat [3] );
*
*   FUNCTION
*	The vertex of the current object found with vertexindex
*	will be returned in the passed float array.
*	Or if a current polygon is set you will get
*	the vertex of the polygon.
* 
*   INPUTS
* 	spacehandle  - A valid handle of a space.
*	vertexindex  - A valid handle of a vertex
*	array        - A correct sized float array which will contain
*	               the coordinates of the vertex.
*	
*   RESULT
* 	error - ER_NOERROR    if all went well.
*	        ER_NOSPACE    if the handle is not valid.
*	        ER_NOOBJECT   if there is no current object.
*	        ER_NOVERTEX   if the index is not valid.
* 
*   EXAMPLE
*	error = tdVertexGet3fa(spacehandle,17,array);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdVertexAdd(),
*	tdVertexIndexGet(),tdVertexAssign()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdVertexGet3fa(register __d1 ULONG spacehandle,
									register __d2 ULONG vertexindex,
									register __a0 TDfloat array[3]) {

	TDspace	*space=NULL;
	TDpolymesh	*mesh=NULL;
	TDvectord	*mvertex=NULL;
	TDfloat	*marray=NULL;
	ULONG		vindex;

	// make a copy of the array, a0 is a scratch register
	marray=array;
      
	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	if(space->curobjn==NULL) return(ER_NOOBJECT);
	if(space->curobjn->type!=TD_POLYMESH) return(ER_NOOBJECT);

	mesh=(TDpolymesh *)(space->curobjn->handle);
	// check if the mesh its vertex or the one of the current polygon
	if(mesh->curpolyn==NULL) {
		vindex=vertexindex;
	} else {
		if(vertexindex<1 || vertexindex>mesh->curpolyn->numberOfVertices) return(ER_NOVERTEX);
		// internal index = - 1
		vindex=mesh->curpolyn->varray[vertexindex-1];
	}

    mvertex=getVertex(mesh,vindex);
	if(mvertex==NULL) return(ER_NOVERTEX);

	marray[0]=mvertex->x;
	marray[1]=mvertex->y;
	marray[2]=mvertex->z;

	return(ER_NOERROR);
}

/****** td.library/tdQuadAdd4dv ******************************************
* 
*   NAME	
* 	tdQuadAdd4dv -- Add a new polygon with 4 vertices to the
*	                current object, this according the CTM.
*	                The polygon will have the current
*	                material.
*
*   SYNOPSIS
*	error = tdQuadAdd4dv
*	          ( spacehandle,vertex1,vertex2,vertex3,vertex4 )
*	            D1           A0       A1      A2     A3
*
*	TDerrors tdQuadAdd4dv
*	     ( ULONG,TDvectord *,TDvectord *,TDvectord *,TDvectord * );
*
*   FUNCTION
*	A new polygon with 4 vertices will be automatically created.
*	The vertices added to the current object its list and
*	assigned to the new polygon which will have the 
*	current material.
*
*	A copy of the contents passed by the vector pointers will be made.
*	The current polygon of the object will be reset, and not set to this one !
* 
*   INPUTS
* 	spacehandle    - A valid handle of a space.
*	vertex1        - Pointer to the first veretex.
*	vertex2        - Pointer to the second vertex.
*	vertex3        - Pointer to the third vertex.
*	vertex4        - Pointer to the fourth vertex.
*	
*   RESULT
* 	error - ER_NOERROR    if all went well.
*	        ER_NOSPACE    if the handle is not valid.
*	        ER_NOOBJECT   if there is no current object.
*	        ER_NOMATGROUP if there is no current material group.
*	        ER_NOMEMORY   if there is not enough memory. 
* 
*   EXAMPLE
*	error = tdQuadAdd4dv(spacehandle,&v1,&v2,&v3,&v4);
*
*   NOTES
*	Vertices have to be added in counterclock wise direction.
*
*	v4----v3
*	|      |
*	|      |
*	|      |
*	|      |
*	|      |
*	v1--->v2
*
*   BUGS
* 
*   SEE ALSO
* 	tdTriangleAdd()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdQuadAdd4dv(register __d1 ULONG spacehandle,
									register __a0 TDvectord *vertex1,
									register __a1 TDvectord *vertex2,
									register __a2 TDvectord *vertex3,
									register __a3 TDvectord *vertex4) {

	TDspace		*space=NULL;
	TDpolymesh		*polymesh=NULL;
	TDmatgroupnode	*matgroupnode=NULL;
	TDpolygonnode	*polynode=NULL;
	TDvectord		*mvertex1=NULL,*mvertex2=NULL,
					*mvertex3=NULL,*mvertex4=NULL;
	ULONG			vindex;

	// make a copy of vertex1 to 4, a0 and a1 are a scratch registers
	mvertex1=vertex1;
	mvertex2=vertex2;
	mvertex3=vertex3;
	mvertex4=vertex4;

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	if(space->curobjn==NULL) return(ER_NOOBJECT);
	if(space->curobjn->type!=TD_POLYMESH) return(ER_NOOBJECT);

	polymesh=(TDpolymesh *)(space->curobjn->handle);
		
	// get the matgroup
	matgroupnode=polymesh->curmatgroupn;
	if(matgroupnode==NULL) return(ER_NOMATGROUP);

	// Create a new polygon, add it to the internal list
	if((polynode=addPolygon(polymesh,matgroupnode,Ci_POLYVERARRAYINIT))==NULL) return(ER_NOMEMORY);

	polymesh->curpolyn=NULL;

	if((vindex=addVertex(polymesh,space->ctm,(*mvertex1)))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);
	if((vindex=addVertex(polymesh,space->ctm,(*mvertex2)))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);
	if((vindex=addVertex(polymesh,space->ctm,(*mvertex3)))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);
	if((vindex=addVertex(polymesh,space->ctm,(*mvertex4)))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);

	return(ER_NOERROR);
}

/****** td.library/tdQuadAdd4fv ******************************************
* 
*   NAME	
* 	tdQuadAdd4fv -- Add a new polygon with 4 vertices to the
*	                current object, this according the CTM.
*	                The polygon will have the current
*	                material.
*
*   SYNOPSIS
*	error = tdQuadAdd4fv
*	          ( spacehandle,vertex1,vertex2,vertex3,vertex4 )
*	            D1           A0       A1      A2     A3
*
*	TDerrors tdQuadAdd4fv
*	     ( ULONG,TDvectorf *,TDvectorf *,TDvectorf *,TDvectorf * );
*
*   FUNCTION
*	A new polygon with 4 vertices will be automatically created.
*	The vertices added to the current object its list and
*	assigned to the new polygon which will have the 
*	current material.
*
*	A copy of the contents passed by the vector pointers will be made.
*	The current polygon of the object will be reset, and not set to this one !
* 
*   INPUTS
* 	spacehandle    - A valid handle of a space.
*	vertex1        - Pointer to the first veretex.
*	vertex2        - Pointer to the second vertex.
*	vertex3        - Pointer to the third vertex.
*	vertex4        - Pointer to the fourth vertex.
*	
*   RESULT
* 	error - ER_NOERROR    if all went well.
*	        ER_NOSPACE    if the handle is not valid.
*	        ER_NOOBJECT   if there is no current object.
*	        ER_NOMATGROUP if there is no current material group.
*	        ER_NOMEMORY   if there is not enough memory. 
* 
*   EXAMPLE
*	error = tdQuadAdd4fv(spacehandle,&v1,&v2,&v3,&v4);
*
*   NOTES
*	Vertices have to be added in counterclock wise direction.
*
*	v4----v3
*	|      |
*	|      |
*	|      |
*	|      |
*	|      |
*	v1--->v2
*
*   BUGS
* 
*   SEE ALSO
* 	tdTriangleAdd()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdQuadAdd4fv(register __d1 ULONG spacehandle,
									register __a0 TDvectorf *vertex1,
									register __a1 TDvectorf *vertex2,
									register __a2 TDvectorf *vertex3,
									register __a3 TDvectorf *vertex4) {

	TDspace		*space=NULL;
	TDpolymesh		*polymesh=NULL;
	TDmatgroupnode	*matgroupnode=NULL;
	TDpolygonnode	*polynode=NULL;
	TDvectord		mvertex1,mvertex2,
					mvertex3,mvertex4;
	ULONG			vindex;

	// make a copy of vertex1 to 4, a0 and a1 are a scratch registers
	mvertex1.x=vertex1->x;
	mvertex1.y=vertex1->y;
	mvertex1.z=vertex1->z;

	mvertex2.x=vertex2->x;
	mvertex2.y=vertex2->y;
	mvertex2.z=vertex2->z;

	mvertex3.x=vertex3->x;
	mvertex3.y=vertex3->y;
	mvertex3.z=vertex3->z;

	mvertex4.x=vertex4->x;
	mvertex4.y=vertex4->y;
	mvertex4.z=vertex4->z;

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	if(space->curobjn==NULL) return(ER_NOOBJECT);
	if(space->curobjn->type!=TD_POLYMESH) return(ER_NOOBJECT);

	polymesh=(TDpolymesh *)(space->curobjn->handle);
		
	// get the matgroup, must be present if material is set !
	matgroupnode=polymesh->curmatgroupn;
	if(matgroupnode==NULL) return(ER_NOMATGROUP);

	// Create a new polygon, add it to the internal list
	if((polynode=addPolygon(polymesh,matgroupnode,Ci_POLYVERARRAYINIT))==NULL) return(ER_NOMEMORY);

	polymesh->curpolyn=NULL;

	if((vindex=addVertex(polymesh,space->ctm,mvertex1))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);
	if((vindex=addVertex(polymesh,space->ctm,mvertex2))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);
	if((vindex=addVertex(polymesh,space->ctm,mvertex3))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);
	if((vindex=addVertex(polymesh,space->ctm,mvertex4))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);

	return(ER_NOERROR);
}

/****** td.library/tdQuadAdd12da ******************************************
* 
*   NAME	
* 	tdQuadAdd12da -- Add a new polygon with 4 vertices to the
*	                 current object, this according the CTM.
*	                 The polygon will have the current
*	                 material.
*
*   SYNOPSIS
*	error = tdQuadAdd12da
*	          ( spacehandle,array )
*	            D1           A0
*
*	TDerrors tdQuadAdd12da
*	     ( ULONG,TDdouble [12] );
*
*   FUNCTION
*	A new polygon with 4 vertices will be automatically created.
*	The vertices added to the current object its list and
*	assigned to the new polygon which will have the 
*	current material.
*
*	A copy of the contents passed by the vector pointers will be made.
*	The current polygon of the object will be reset, and not set to this one !
* 
*   INPUTS
* 	spacehandle    - A valid handle of a space.
*	array          - Array which contains all 12 coordinates.
*	
*   RESULT
* 	error - ER_NOERROR    if all went well.
*	        ER_NOSPACE    if the handle is not valid.
*	        ER_NOOBJECT   if there is no current object.
*	        ER_NOMATGROUP if there is no current material group.
*	        ER_NOMEMORY   if there is not enough memory. 
* 
*   EXAMPLE
*	error = tdQuadAdd12da(spacehandle,array);
*
*   NOTES
*	Vertices have to be added in counterclock wise direction.
*
*	v4----v3
*	|      |
*	|      |
*	|      |
*	|      |
*	|      |
*	v1--->v2
*
*   BUGS
* 
*   SEE ALSO
* 	tdTriangleAdd()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdQuadAdd12da(register __d1 ULONG spacehandle,
									register __a0 TDdouble array[12]) {

	TDspace		*space=NULL;
	TDpolymesh		*polymesh=NULL;
	TDmatgroupnode	*matgroupnode=NULL;
	TDpolygonnode	*polynode=NULL;
	TDvectord		mvertex1,mvertex2,
					mvertex3,mvertex4;
	ULONG			vindex;

	// make a copy of vertex1 to 4, a0 and a1 are a scratch registers
	mvertex1.x=array[0];
	mvertex1.y=array[1];
	mvertex1.z=array[2];

	mvertex2.x=array[3];
	mvertex2.y=array[4];
	mvertex2.z=array[5];

	mvertex3.x=array[6];
	mvertex3.y=array[7];
	mvertex3.z=array[8];

	mvertex4.x=array[9];
	mvertex4.y=array[10];
	mvertex4.z=array[11];

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	if(space->curobjn==NULL) return(ER_NOOBJECT);
	if(space->curobjn->type!=TD_POLYMESH) return(ER_NOOBJECT);

	polymesh=(TDpolymesh *)(space->curobjn->handle);
		
	// get the matgroup, must be present if material is set !
	matgroupnode=polymesh->curmatgroupn;
	if(matgroupnode==NULL) return(ER_NOMATGROUP);

	// Create a new polygon, add it to the internal list
	if((polynode=addPolygon(polymesh,matgroupnode,Ci_POLYVERARRAYINIT))==NULL) return(ER_NOMEMORY);

	polymesh->curpolyn=NULL;

	if((vindex=addVertex(polymesh,space->ctm,mvertex1))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);
	if((vindex=addVertex(polymesh,space->ctm,mvertex2))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);
	if((vindex=addVertex(polymesh,space->ctm,mvertex3))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);
	if((vindex=addVertex(polymesh,space->ctm,mvertex4))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);

	return(ER_NOERROR);
}

/****** td.library/tdQuadAdd12fa ******************************************
* 
*   NAME	
* 	tdQuadAdd12fa -- Add a new polygon with 4 vertices to the
*	                 current object, this according the CTM.
*	                 The polygon will have the current
*	                 material.
*
*   SYNOPSIS
*	error = tdQuadAdd12fa
*	          ( spacehandle,array )
*	            D1           A0
*
*	TDerrors tdQuadAdd12fa
*	     ( ULONG,TDfloat [12] );
*
*   FUNCTION
*	A new polygon with 4 vertices will be automatically created.
*	The vertices added to the current object its list and
*	assigned to the new polygon which will have the 
*	current material.
*
*	A copy of the contents passed by the vector pointers will be made.
*	The current polygon of the object will be reset, and not set to this one !
* 
*   INPUTS
* 	spacehandle    - A valid handle of a space.
*	array          - Array which contains all 12 coordinates.
*	
*   RESULT
* 	error - ER_NOERROR    if all went well.
*	        ER_NOSPACE    if the handle is not valid.
*	        ER_NOOBJECT   if there is no current object.
*	        ER_NOMATGROUP if there is no current material group.
*	        ER_NOMEMORY   if there is not enough memory. 
* 
*   EXAMPLE
*	error = tdQuadAdd12fa(spacehandle,array);
*
*   NOTES
*	Vertices have to be added in counterclock wise direction.
*
*	v4----v3
*	|      |
*	|      |
*	|      |
*	|      |
*	|      |
*	v1--->v2
*
*   BUGS
* 
*   SEE ALSO
* 	tdTriangleAdd()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdQuadAdd12fa(register __d1 ULONG spacehandle,
									register __a0 TDfloat array[12]) {

	TDspace		*space=NULL;
	TDpolymesh		*polymesh=NULL;
	TDmatgroupnode	*matgroupnode=NULL;
	TDpolygonnode	*polynode=NULL;
	TDvectord		mvertex1,mvertex2,
					mvertex3,mvertex4;
	ULONG			vindex;

	// make a copy of vertex1 to 4, a0 and a1 are a scratch registers
	mvertex1.x=array[0];
	mvertex1.y=array[1];
	mvertex1.z=array[2];

	mvertex2.x=array[3];
	mvertex2.y=array[4];
	mvertex2.z=array[5];

	mvertex3.x=array[6];
	mvertex3.y=array[7];
	mvertex3.z=array[8];

	mvertex4.x=array[9];
	mvertex4.y=array[10];
	mvertex4.z=array[11];

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	if(space->curobjn==NULL) return(ER_NOOBJECT);
	if(space->curobjn->type!=TD_POLYMESH) return(ER_NOOBJECT);

	polymesh=(TDpolymesh *)(space->curobjn->handle);
		
	// get the matgroup, must be present if material is set !
	matgroupnode=polymesh->curmatgroupn;
	if(matgroupnode==NULL) return(ER_NOMATGROUP);

	// Create a new polygon, add it to the internal list
	if((polynode=addPolygon(polymesh,matgroupnode,Ci_POLYVERARRAYINIT))==NULL) return(ER_NOMEMORY);

	polymesh->curpolyn=NULL;

	if((vindex=addVertex(polymesh,space->ctm,mvertex1))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);
	if((vindex=addVertex(polymesh,space->ctm,mvertex2))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);
	if((vindex=addVertex(polymesh,space->ctm,mvertex3))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);
	if((vindex=addVertex(polymesh,space->ctm,mvertex4))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);

	return(ER_NOERROR);
}

/****** td.library/tdTriangleAdd3dv ******************************************
* 
*   NAME	
* 	tdTriangleAdd3dv -- Add a new polygon with 3 vertices to the
*	                    current object, this according the CTM.
*	                    The polygon will have the current
*	                    material.
*
*   SYNOPSIS
*	error = tdTriangleAdd3dv
*	          ( spacehandle,vertex1,vertex2,vertex3 )
*	            D1           A0       A1      A2
*
*	TDerrors tdTriangleAdd3dv
*	     ( ULONG,TDvectord *,TDvectord *,TDvectord * );
*
*   FUNCTION
*	A new polygon with 3 vertices will be automatically created.
*	The vertices added to the current object its list and
*	assigned to the new polygon which will have the 
*	current material.
*
*	A copy of the contents passed by the vector pointers will be made.
*	The current polygon of the object will be reset, and not set to this one !
* 
*   INPUTS
* 	spacehandle    - A valid handle of a space.
*	vertex1        - Pointer to the first veretex.
*	vertex2        - Pointer to the second vertex.
*	vertex3        - Pointer to the third vertex.
*	
*   RESULT
* 	error - ER_NOERROR    if all went well.
*	        ER_NOSPACE    if the handle is not valid.
*	        ER_NOOBJECT   if there is no current object.
*	        ER_NOMATGROUP if there is no current material group.
*	        ER_NOMEMORY   if there is not enough memory. 
* 
*   EXAMPLE
*	error = tdTriangleAdd3dv(spacehandle,&v1,&v2,&v3);
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
* 	tdQuadAdd()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdTriangleAdd3dv(register __d1 ULONG spacehandle,
										register __a0 TDvectord *vertex1,
										register __a1 TDvectord *vertex2,
										register __a2 TDvectord *vertex3) {

	TDspace		*space=NULL;
	TDpolymesh		*polymesh=NULL;
	TDmatgroupnode	*matgroupnode=NULL;
	TDpolygonnode	*polynode=NULL;
	TDvectord		mvertex1,mvertex2,
					mvertex3;
	ULONG			vindex;

	// make a copy of vertex1 to 3, a0 and a1 are a scratch registers
	mvertex1=(*vertex1);
	mvertex2=(*vertex2);
	mvertex3=(*vertex3);

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	if(space->curobjn==NULL) return(ER_NOOBJECT);
	if(space->curobjn->type!=TD_POLYMESH) return(ER_NOOBJECT);

	polymesh=(TDpolymesh *)(space->curobjn->handle);
		
	// get the matgroup, must be present if material is set !
	matgroupnode=polymesh->curmatgroupn;
	if(matgroupnode==NULL) return(ER_NOMATGROUP);

	// Create a new polygon, add it to the internal list
	if((polynode=addPolygon(polymesh,matgroupnode,Ci_POLYVERARRAYINIT))==NULL) return(ER_NOMEMORY);

	polymesh->curpolyn=NULL;

	if((vindex=addVertex(polymesh,space->ctm,mvertex1))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);
	if((vindex=addVertex(polymesh,space->ctm,mvertex2))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);
	if((vindex=addVertex(polymesh,space->ctm,mvertex3))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);

	return(ER_NOERROR);
}

/****** td.library/tdTriangleAdd3fv ******************************************
* 
*   NAME	
* 	tdTriangleAdd3fv -- Add a new polygon with 3 vertices to the
*	                    current object, this according the CTM.
*	                    The polygon will have the current
*	                    material.
*
*   SYNOPSIS
*	error = tdTriangleAdd3fv
*	          ( spacehandle,vertex1,vertex2,vertex3 )
*	            D1           A0       A1      A2
*
*	TDerrors tdTriangleAdd3fv
*	     ( ULONG,TDvectorf *,TDvectorf *,TDvectorf * );
*
*   FUNCTION
*	A new polygon with 3 vertices will be automatically created.
*	The vertices added to the current object its list and
*	assigned to the new polygon which will have the 
*	current material.
*
*	A copy of the contents passed by the vector pointers will be made.
*	The current polygon of the object will be reset, and not set to this one !
* 
*   INPUTS
* 	spacehandle    - A valid handle of a space.
*	vertex1        - Pointer to the first veretex.
*	vertex2        - Pointer to the second vertex.
*	vertex3        - Pointer to the third vertex.
*	
*   RESULT
* 	error - ER_NOERROR    if all went well.
*	        ER_NOSPACE    if the handle is not valid.
*	        ER_NOOBJECT   if there is no current object.
*	        ER_NOMATGROUP if there is no current material group.
*	        ER_NOMEMORY   if there is not enough memory. 
* 
*   EXAMPLE
*	error = tdTriangleAdd3fv(spacehandle,&v1,&v2,&v3);
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
* 	tdQuadAdd()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdTriangleAdd3fv(register __d1 ULONG spacehandle,
										register __a0 TDvectorf *vertex1,
										register __a1 TDvectorf *vertex2,
										register __a2 TDvectorf *vertex3) {

	TDspace		*space=NULL;
	TDpolymesh		*polymesh=NULL;
	TDmatgroupnode	*matgroupnode=NULL;
	TDpolygonnode	*polynode=NULL;
	TDvectord		mvertex1,mvertex2,
					mvertex3;
	ULONG			vindex;

	// make a copy of vertex1 to 3, a0 and a1 are a scratch registers
	mvertex1.x=vertex1->x;
	mvertex1.y=vertex1->y;
	mvertex1.z=vertex1->z;

	mvertex2.x=vertex2->x;
	mvertex2.y=vertex2->y;
	mvertex2.z=vertex2->z;

	mvertex3.x=vertex3->x;
	mvertex3.y=vertex3->y;
	mvertex3.z=vertex3->z;

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	if(space->curobjn==NULL) return(ER_NOOBJECT);
	if(space->curobjn->type!=TD_POLYMESH) return(ER_NOOBJECT);

	polymesh=(TDpolymesh *)(space->curobjn->handle);
		
	// get the matgroup, must be present if material is set !
	matgroupnode=polymesh->curmatgroupn;
	if(matgroupnode==NULL) return(ER_NOMATGROUP);

	// Create a new polygon, add it to the internal list
	if((polynode=addPolygon(polymesh,matgroupnode,Ci_POLYVERARRAYINIT))==NULL) return(ER_NOMEMORY);

	polymesh->curpolyn=NULL;

	if((vindex=addVertex(polymesh,space->ctm,mvertex1))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);
	if((vindex=addVertex(polymesh,space->ctm,mvertex2))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);
	if((vindex=addVertex(polymesh,space->ctm,mvertex3))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);

	return(ER_NOERROR);
}

/****** td.library/tdTriangleAdd9da ******************************************
* 
*   NAME	
* 	tdTriangleAdd9da -- Add a new polygon with 3 vertices to the
*	                    current object, this according the CTM.
*	                    The polygon will have the current
*	                    material.
*
*   SYNOPSIS
*	error = tdTriangleAdd9da
*	          ( spacehandle,array )
*	            D1           A0
*
*	TDerrors tdTriangleAdd9da
*	     ( ULONG,TDdouble [9] );
*
*   FUNCTION
*	A new polygon with 3 vertices will be automatically created.
*	The vertices added to the current object its list and
*	assigned to the new polygon which will have the 
*	current material.
*
*	A copy of the contents passed by the vector pointers will be made.
*	The current polygon of the object will be reset, and not set to this one !
* 
*   INPUTS
* 	spacehandle    - A valid handle of a space.
*	array          - Array which contains the coordinates.
*	
*   RESULT
* 	error - ER_NOERROR    if all went well.
*	        ER_NOSPACE    if the handle is not valid.
*	        ER_NOOBJECT   if there is no current object.
*	        ER_NOMATGROUP if there is no current material group.
*	        ER_NOMEMORY   if there is not enough memory. 
* 
*   EXAMPLE
*	error = tdTriangleAdd9da(spacehandle,array);
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
* 	tdQuadAdd()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdTriangleAdd9da(register __d1 ULONG spacehandle,
										register __a0 TDdouble array[9]) {

	TDspace		*space=NULL;
	TDpolymesh		*polymesh=NULL;
	TDmatgroupnode	*matgroupnode=NULL;
	TDpolygonnode	*polynode=NULL;
	TDvectord		mvertex1,mvertex2,
					mvertex3;
	ULONG			vindex;

	// make a copy of vertex1 to 3, a0 and a1 are a scratch registers
	mvertex1.x=array[0];
	mvertex1.y=array[1];
	mvertex1.z=array[2];

	mvertex2.x=array[3];
	mvertex2.y=array[4];
	mvertex2.z=array[5];

	mvertex3.x=array[6];
	mvertex3.y=array[7];
	mvertex3.z=array[8];

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	if(space->curobjn==NULL) return(ER_NOOBJECT);
	if(space->curobjn->type!=TD_POLYMESH) return(ER_NOOBJECT);

	polymesh=(TDpolymesh *)(space->curobjn->handle);
		
	// get the matgroup, must be present if material is set !
	matgroupnode=polymesh->curmatgroupn;
	if(matgroupnode==NULL) return(ER_NOMATGROUP);

	// Create a new polygon, add it to the internal list
	if((polynode=addPolygon(polymesh,matgroupnode,Ci_POLYVERARRAYINIT))==NULL) return(ER_NOMEMORY);

	polymesh->curpolyn=NULL;

	if((vindex=addVertex(polymesh,space->ctm,mvertex1))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);
	if((vindex=addVertex(polymesh,space->ctm,mvertex2))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);
	if((vindex=addVertex(polymesh,space->ctm,mvertex3))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);

	return(ER_NOERROR);
}

/****** td.library/tdTriangleAdd9fa ******************************************
* 
*   NAME	
* 	tdTriangleAdd9fa -- Add a new polygon with 3 vertices to the
*	                    current object, this according the CTM.
*	                    The polygon will have the current
*	                    material.
*
*   SYNOPSIS
*	error = tdTriangleAdd9fa
*	          ( spacehandle,array )
*	            D1           A0
*
*	TDerrors tdTriangleAdd9fa
*	     ( ULONG,TDfloat [9] );
*
*   FUNCTION
*	A new polygon with 3 vertices will be automatically created.
*	The vertices added to the current object its list and
*	assigned to the new polygon which will have the 
*	current material.
*
*	A copy of the contents passed by the vector pointers will be made.
*	The current polygon of the object will be reset, and not set to this one !
* 
*   INPUTS
* 	spacehandle    - A valid handle of a space.
*	array          - Array which contains the coordinates.
*	
*   RESULT
* 	error - ER_NOERROR    if all went well.
*	        ER_NOSPACE    if the handle is not valid.
*	        ER_NOOBJECT   if there is no current object.
*	        ER_NOMATGROUP if there is no current material group.
*	        ER_NOMEMORY   if there is not enough memory. 
* 
*   EXAMPLE
*	error = tdTriangleAdd9fa(spacehandle,array);
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
* 	tdQuadAdd()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdTriangleAdd9fa(register __d1 ULONG spacehandle,
										register __a0 TDfloat array[9]) {

	TDspace		*space=NULL;
	TDpolymesh		*polymesh=NULL;
	TDmatgroupnode	*matgroupnode=NULL;
	TDpolygonnode	*polynode=NULL;
	TDvectord		mvertex1,mvertex2,
					mvertex3;
	ULONG			vindex;

	// make a copy of vertex1 to 3, a0 and a1 are a scratch registers
	mvertex1.x=array[0];
	mvertex1.y=array[1];
	mvertex1.z=array[2];

	mvertex2.x=array[3];
	mvertex2.y=array[4];
	mvertex2.z=array[5];

	mvertex3.x=array[6];
	mvertex3.y=array[7];
	mvertex3.z=array[8];

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	if(space->curobjn==NULL) return(ER_NOOBJECT);
	if(space->curobjn->type!=TD_POLYMESH) return(ER_NOOBJECT);

	polymesh=(TDpolymesh *)(space->curobjn->handle);
		
	// get the matgroup, must be present if material is set !
	matgroupnode=polymesh->curmatgroupn;
	if(matgroupnode==NULL) return(ER_NOMATGROUP);

	// Create a new polygon, add it to the internal list
	if((polynode=addPolygon(polymesh,matgroupnode,Ci_POLYVERARRAYINIT))==NULL) return(ER_NOMEMORY);

	polymesh->curpolyn=NULL;

	if((vindex=addVertex(polymesh,space->ctm,mvertex1))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);
	if((vindex=addVertex(polymesh,space->ctm,mvertex2))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);
	if((vindex=addVertex(polymesh,space->ctm,mvertex3))==0) return(ER_NOMEMORY);
	if(assignVertex(polymesh,matgroupnode,polynode,vindex)==0) return(ER_NOMEMORY);

	return(ER_NOERROR);
}

/****** td.library/tdVertexAssign *************************************************
* 
*   NAME	
* 	tdVertexAssign -- Assigns an existing vertex out of the object its
*	                  vertex list to the current polygon.
*
*   SYNOPSIS
*	error = tdVertexAssign( spacehandle,index )
*	                          D1        D2
*
*	TDerrors tdVertexAssign
*	     ( ULONG,ULONG );
*
*   FUNCTION
*	An existing vertex, added with a tdVertexAdd or similar function
*	before to the object, can be assigned to the current polygon.
* 
*   INPUTS
* 	spacehandle  - A valid handle of a space.
*	index        - The index of the vertex in the object its list.
*	
*   RESULT
* 	error - ER_NOERROR    if all went well.
*	        ER_NOSPACE    if the handle is not valid.
*	        ER_NOOBJECT   if there is no current object.
*	        ER_NOPOLYGON  if there is no current polygon.
*	        ER_NOINDEX    if the index is not valid.
*	        ER_NOMEMORY   if there is not enough memory. 
* 
*   EXAMPLE
*	error = tdVertexAssign(spacehandle,97);
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
*   BUGS
* 
*   SEE ALSO
* 	tdVertexAdd(),tdVertexGet(),
*	tdVertexIndexGet()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdVertexAssign(register __d1 ULONG spacehandle,
									register __d2 ULONG index) {

	TDspace		*space=NULL;
	TDpolymesh		*mesh=NULL;

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	if(space->curobjn==NULL) return(ER_NOOBJECT);
	if(space->curobjn->type!=TD_POLYMESH) return(ER_NOOBJECT);

	mesh=(TDpolymesh *)(space->curobjn->handle);

	if(mesh->vertices.numberOfVertices<1 || 
		index<1 || index>mesh->vertices.numberOfVertices) {

		return(ER_NOINDEX);
	}

	if(mesh->curpolyn!=NULL) {
		if(assignVertex(mesh,mesh->curmatgroupn,mesh->curpolyn,index)==0) return(ER_NOMEMORY);
	} else {
		return(ER_NOPOLYGON);
	}

	return(ER_NOERROR);
}

/****** td.library/tdVertexIndexGet *************************************************
* 
*   NAME	
* 	tdVertexIndexGet -- Converts the index of a vertex in the current
*	                    polygon to the index in the object its vertex list.
*
*   SYNOPSIS
*	error = tdVertexIndexGet( spacehandle,pindex,index )
*	                          D1          D2     D3
*
*	TDerrors tdVertexIndexGet
*	     ( ULONG,ULONG,ULONG * );
*
*   FUNCTION
*	Vertices in polygons are references to the vertices found
*	in the vertex list of the parent object. To get the index
*	of a vertex in the object with the help of the index in the
*	current polygon just call this function.
* 
*   INPUTS
* 	spacehandle  - A valid handle of a space.
*	pindex       - The index of the vertex in the polygon.
*	index        - Pointer to the variable which will contain
*	               the index of the object list.
*	
*   RESULT
* 	error - ER_NOERROR    if all went well.
*	        ER_NOSPACE    if the handle is not valid.
*	        ER_NOOBJECT   if there is no current object.
*	        ER_NOPOLYGON  if there is no current polygon.
*	        ER_NOINDEX    if the index is not valid.
* 
*   EXAMPLE
*	error = tdVertexIndexGet(spacehandle,97,&index);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdVertexAdd(),tdVertexGet(),
*	tdVertexAssign()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdVertexIndexGet(register __d1 ULONG spacehandle,
									register __d2 ULONG pindex,
									register __d3 ULONG *index) {

	TDspace		*space=NULL;
	TDpolymesh		*mesh=NULL;
	TDpolygonnode	*polynode=NULL;

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	if(space->curobjn==NULL) return(ER_NOOBJECT);
	if(space->curobjn->type!=TD_POLYMESH) return(ER_NOOBJECT);

	mesh=(TDpolymesh *)(space->curobjn->handle);

	polynode=mesh->curpolyn;
	if(polynode==NULL) {
		return(ER_NOPOLYGON);
	}

	if(polynode->numberOfVertices<1 || 
		pindex<1 || pindex>polynode->numberOfVertices) {

		return(ER_NOINDEX);
	}

	(*index)=mesh->curpolyn->varray[pindex-1];

	return(ER_NOERROR);
}

/****** td.library/tdChildSetl ******************************************
* 
*   NAME	
* 	tdChildSetl -- Set a parameter of the current child.
* 
*   SYNOPSIS
*	error = tdChildSetl( spacehandle,type,value )
*	                     D1          D2   D3
*
*	TDerrors tdChildSetl
*	     ( ULONG,TDenum,ULONG );
*
*   FUNCTION
*	The parameter of the current child, will be changed.
*	Type specifies which parameter.
* 
*   INPUTS
* 	spacehandle     - A valid handle of a space.
*	type            - The parameter its type.
*	value           - The new value of the parameter.
*	
*   RESULT
* 	error - ER_NOERROR    if all went well.
*	        ER_NOSPACE    if the handle is not valid.
*	        ER_NOOBJECT   if there is no current object.
*	        ER_NOMATGROUP if there is no current material group.
*	        ER_NOVALUE    if the value is incorrect.
*	        ER_NOTYPE     if the type is not valid.
*
*   EXAMPLE
*	error = tdChildSetl(spacehandle,TD_TEXBINDING,36);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdChildGet(),tdCurrentSet()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdChildSetl(register __d1 ULONG spacehandle,
									register __d2 TDenum type,
									register __d3 ULONG value) {
	TDspace		*space=NULL;
	TDobjectnode	*object=NULL;
	TDobjectnode	*object2=NULL;
	TDpolymesh		*polymesh=NULL;
	TDmatgroupnode	*matgroupn=NULL;
	TDmaterialnode	*matnode=NULL;

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	// set the value of the current child in function of the type
	switch(type) {
		case TD_MATERIAL :
			object=space->curobjn;
			if(object==NULL) return(ER_NOOBJECT);

			switch(object->type) {
				case TD_POLYMESH :
					polymesh=(TDpolymesh *)object->handle;

					matgroupn=polymesh->curmatgroupn;
					if(matgroupn==NULL) return(ER_NOMATGROUP);

					if((matnode=getMaterialNode(space,value))==NULL) return(ER_NOVALUE);
					if(matnode->type==TD_TEXTURE) return(ER_NOVALUE);

					matgroupn->materialnode=matnode;

					break;
			}

			break;
		case TD_TEXBINDING :
			object=space->curobjn;
			if(object==NULL) return(ER_NOOBJECT);

			switch(object->type) {
				case TD_POLYMESH :
					polymesh=(TDpolymesh *)object->handle;

					matgroupn=polymesh->curmatgroupn;
					if(matgroupn==NULL) return(ER_NOMATGROUP);

					if((object2=getObjectNode(space,value))==NULL) return(ER_NOVALUE);
					if(object2->type!=TD_TEXBINDING) return(ER_NOVALUE);

					matgroupn->texbindex=value;

					break;
			}

			break;
		default :
			return(ER_NOTYPE);
	}

	return(ER_NOERROR);
}

/****** td.library/tdChildGetl ******************************************
* 
*   NAME	
* 	tdChildGetl -- Get a parameter of the current child.
* 
*   SYNOPSIS
*	error = tdChildGetl( spacehandle,type,value )
*	                     D1          D2   D3
*
*	TDerrors tdChildGetl
*	     ( ULONG,TDenum,ULONG * );
*
*   FUNCTION
*	The parameter of the current child, will be returned.
*	Type specifies which parameter.
* 
*   INPUTS
* 	spacehandle     - A valid handle of a space.
*	type            - The parameter its type.
*	value           - The variable which will contain the parameter.
*	
*   RESULT
* 	error - ER_NOERROR    if all went well.
*	        ER_NOSPACE    if the handle is not valid.
*	        ER_NOOBJECT   if there is no current object.
*	        ER_NOMATGROUP if there is no current material group.
*	        ER_NOVALUE    if the value is not set.
*	        ER_NOTYPE     if the type is not valid.
*
*   EXAMPLE
*	error = tdChildGetl(spacehandle,TD_SURFACE,&value);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdChildSet(),tdCurrentSet()
* 
******************************************************************************
*
*/
TDerrors __saveds ASM tdChildGetl(register __d1 ULONG spacehandle,
									register __d2 TDenum type,
									register __d3 ULONG *value) {
	TDspace		*space=NULL;
	TDobjectnode	*object=NULL;
	TDpolymesh		*polymesh=NULL;
	TDmatgroupnode	*matgroupn=NULL;

	(*value)=0;

	space=(TDspace *) spacehandle;
	if (space==NULL) return(ER_NOSPACE);

	// get the value of the current child in function of the type
	switch(type) {
		case TD_MATERIAL :
			object=space->curobjn;
			if(object==NULL) return(ER_NOOBJECT);

			switch(object->type) {
				case TD_POLYMESH :
					polymesh=(TDpolymesh *)object->handle;

					matgroupn=polymesh->curmatgroupn;
					if(matgroupn==NULL) return(ER_NOMATGROUP);

					(*value)=matgroupn->materialnode->index;

					if((*value)==0) return(ER_NOVALUE);

					break;
			}

			break;
		case TD_TEXBINDING :
			object=space->curobjn;
			if(object==NULL) return(ER_NOOBJECT);

			switch(object->type) {
				case TD_POLYMESH :
					polymesh=(TDpolymesh *)object->handle;

					matgroupn=polymesh->curmatgroupn;
					if(matgroupn==NULL) return(ER_NOMATGROUP);

					(*value)=matgroupn->texbindex;

					if((*value)==0) return(ER_NOVALUE);

					break;
			}
		default :
			return(ER_NOTYPE);
	}

	return(ER_NOERROR);
}

/****** td.library/tdXNofGet ******************************************
* 
*   NAME	
* 	tdXNofGet -- Returns the number of extensions of a
*	             spedific type.
* 
*   SYNOPSIS
*	number = tdXNofGet(type)
*	                   D1
*
*	ULONG tdXNofGet
*	     ( TDEnum );
*
*   FUNCTION
*	You will get the number of extensions in 
*	function of type.
* 
*   INPUTS
*	type - Type of extension.
*	
*   RESULT
* 	number - Number of extensions.
*
*   EXAMPLE
*	number = tdXNofGet(TD_3X);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdXNameGet(),tdXExtGet(),tdXSupportedGet(),tdXDescGet(),
*	tdXLibGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM tdXNofGet(register __d1 TDenum type) {
	TDenum mtype;
	ULONG i,j;

	// make a copy of type, d1 is a scratch register
	mtype=type;

	switch(mtype) {
		case TD_3X :
			if(tdlibinfos->lib3dinfos!=NULL) {
				i=0;
				while(tdlibinfos->lib3dinfos[i]!=NULL) i++;
				return(i);
			}
			break;
		case TD_3XSAVE :
			if(tdlibinfos->lib3dinfos!=NULL) {
				j=0;
				i=0;
				while(tdlibinfos->lib3dinfos[i]!=NULL) {
					if(tdlibinfos->lib3dinfos[i]->sups!=NULL) j++;
					i++;
				}
				return(j);
			}
			break;
		case TD_3XLOAD :
			if(tdlibinfos->lib3dinfos!=NULL) {
				j=0;
				i=0;
				while(tdlibinfos->lib3dinfos[i]!=NULL) {
					if(tdlibinfos->lib3dinfos[i]->supl!=NULL) j++;
					i++;
				}
				return(j);
			}
			break;
	}

	return(0);
}

/****** td.library/tdXExtGet ******************************************
* 
*   NAME	
* 	tdXExtGet -- Returns the file extension of a specific
*	             extension.
* 
*   SYNOPSIS
*	extension = tdXExtGet(type,name)
*	                      D1   D2
*
*	STRPTR tdXExtGet
*	     ( TDEnum,STRPTR );
*
*   FUNCTION
*	You will get the file extension of the extension
*	with its name and type.
*
*	This strings are READ_ONLY and only valid as
*	long as the library is opened.
* 
*   INPUTS
*	type - Type of extension.
*	name - Name of the extension.
*	
*   RESULT
* 	extension - Name of the extension, or NULL if none.
*
*   EXAMPLE
*	extension = tdXExtGet(TD_3X,"VRML");
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdXNameGet(),tdXNofGet(),tdXSupportedGet(),tdXDescGet(),
*	tdXLibGet()
* 
******************************************************************************
*
*/
STRPTR __saveds ASM tdXExtGet(register __d1 TDenum type,register __d2 STRPTR name) {
	TDenum mtype;
	ULONG i;

	// make a copy of type, d1 is a scratch register
	mtype=type;

	switch(mtype) {
		case TD_3X :
		case TD_3XSAVE :
		case TD_3XLOAD :
			if(tdlibinfos->lib3dinfos!=NULL && name!=NULL) {
				i=0;
				while(tdlibinfos->lib3dinfos[i]!=NULL) {
					if(strcmp(tdlibinfos->lib3dinfos[i]->name,name)==0) {
						return(tdlibinfos->lib3dinfos[i]->ext);
					}
					i++;
				}
			}
			break;
	}

	return(NULL);
}

/****** td.library/tdXNameGet ******************************************
* 
*   NAME	
* 	tdXNameGet -- Returns the name of an extension.
* 
*   SYNOPSIS
*	name = tdXNameGet(type,index)
*	                  D1   D2
*
*	STRPTR tdXNameGet
*	     ( TDEnum,ULONG );
*
*   FUNCTION
*	You will get the name of an extension module by
*	specifying its type and the index of it.
*
*	This strings are READ_ONLY and only valid as
*	long as the library is opened.
* 
*   INPUTS
*	type     - Type of extension.
*	index    - Index of the extension.
*	           0 -> tdXNofGet()-1
*	
*   RESULT
* 	name - Name of NULL if none.
*
*   EXAMPLE
*	name = tdXNameGet(TD_3XSAVE,4);
*
*   NOTES
*	When you get NULL for a correct infex and type,
*	this means that the extension does not at all
*	support this type of function.
*
*   BUGS
* 
*   SEE ALSO
* 	tdXExtGet(),tdXNofGet(),tdXSupportedGet(),tdXGescGet(),
*	tdXLibGet()
* 
******************************************************************************
*
*/
STRPTR __saveds ASM tdXNameGet(register __d1 TDenum type,register __d2 ULONG index) {
	TDenum mtype;

	// make a copy of type, d1 is a scratch register
	mtype=type;

	switch(mtype) {
		case TD_3XSAVE :
			if(tdlibinfos->lib3dinfos!=NULL) {
				if(index>=0 && index<tdXNofGet(TD_3X)) {
					if(tdlibinfos->lib3dinfos[index]->sups!=NULL) {
						return(tdlibinfos->lib3dinfos[index]->name);
					}
				}
			}
			break;
		case TD_3XLOAD :
			if(tdlibinfos->lib3dinfos!=NULL) {
				if(index>=0 && index<tdXNofGet(TD_3X)) {
					if(tdlibinfos->lib3dinfos[index]->supl!=NULL) {
						return(tdlibinfos->lib3dinfos[index]->name);
					}
				}
			}
			break;
		case TD_3X :
			if(tdlibinfos->lib3dinfos!=NULL) {
				if(index>=0 && index<tdXNofGet(TD_3X)) {
					return(tdlibinfos->lib3dinfos[index]->name);
				}
			}
			break;
	}
	return(NULL);
}

/****** td.library/tdXSupportedGet ******************************************
* 
*   NAME	
* 	tdXSupportedGet -- Returns an array of supported functions
*	                   for a specific extension.
* 
*   SYNOPSIS
*	array = tdXSupportedGet(type,name)
*	                        D1   D2
*
*	TDenum * tdXSupportedGet
*	     ( TDEnum,STRPTR );
*
*   FUNCTION
*	You will get an array of all supported functions of the
*	extension.
*
*	This lists are READ_ONLY and only valid as
*	long as the library is opened.
* 
*   INPUTS
*	type     - Type of extension.
*	name     - Name of the extension.
*	
*   RESULT
* 	array - A list of functions, terminated with TD_NOTHING,
*	        or NULL if none.
*
*   EXAMPLE
*	array = tdXSupportedGet(TD_3XSAVE,"VRML");
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdXExtGet(),tdXNofGet(),tdXNameGet(),tdXDescGet(),
*	tdXLibGet()
* 
******************************************************************************
*
*/
TDenum * __saveds ASM tdXSupportedGet(register __d1 TDenum type,register __d2 STRPTR name) {
	TDenum mtype;
	ULONG i;

	// make a copy of type, d1 is a scratch register
	mtype=type;

	switch(mtype) {
		case TD_3XSAVE :
		case TD_3XLOAD :
			if(tdlibinfos->lib3dinfos!=NULL && name!=NULL) {
				i=0;
				while(tdlibinfos->lib3dinfos[i]!=NULL) {
					if(strcmp(tdlibinfos->lib3dinfos[i]->name,name)==0) {
						if(mtype==TD_3XSAVE) {
							return(tdlibinfos->lib3dinfos[i]->sups);
						} else {
							return(tdlibinfos->lib3dinfos[i]->supl);
						}
					}
					i++;
				}
			}
			break;
	}
	return(NULL);
}

/****** td.library/tdXDescGet ******************************************
* 
*   NAME	
* 	tdXDescGet -- Returns a description for the type.
* 
*   SYNOPSIS
*	description = tdXDescGet(type)
*	                         D1
*
*	STRPTR tdXDescGet
*	     ( TDEnum );
*
*   FUNCTION
*	You will get a short description for the specific type.
*
*	This strings are READ_ONLY and only valid as
*	long as the library is opened.
* 
*   INPUTS
*	type     - Type of which you want a description.
*	
*   RESULT
* 	description - A short description of type, or NULL if none.
*
*   EXAMPLE
*	description = tdXDescGet(TD_OJBECT);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdXExtGet(),tdXNofGet(),txXNameGet(),tdXSupportedGet(),
*	tdXLibGet()
* 
******************************************************************************
*
*/
STRPTR __saveds ASM tdXDescGet(register __d1 TDenum type) {
	TDenum mtype;

	// make a copy of type, d1 is a scratch register
	mtype=type;

	switch(mtype) {
		case TD_SPACE :
			return("Space");
		case TD_OBJECT :
			return("Object");
		case TD_MATERIAL :
			return("Material");
		case TD_SURFACE :
			return("Surface");
		case TD_TEXTURE :
			return("Texture");
	}

	return(NULL);
}

/****** td.library/tdXLibGet ******************************************
* 
*   NAME	
* 	tdXLibGet -- Returns the name of the extension library.
* 
*   SYNOPSIS
*	library = tdXLibGet(type,name)
*	                    D1   D2
*
*	STRPTR tdXLibGet
*	     ( TDEnum,STRPTR );
*
*   FUNCTION
*	You will get the name of the extension library
*	with its name and type.
*
*	This strings are READ_ONLY and only valid as
*	long as the library is opened.
* 
*   INPUTS
*	type - Type of extension.
*	name - Name of the extension.
*	
*   RESULT
* 	library - Name of the library, or NULL if none.
*
*   EXAMPLE
*	library = tdXLibGet(TD_3X,"VRML");
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdXNameGet(),tdXNofGet(),tdXSupportedGet(),tdXDescGet(),
*	tdXExtGet()
* 
******************************************************************************
*
*/
STRPTR __saveds ASM tdXLibGet(register __d1 TDenum type,register __d2 STRPTR name) {
	TDenum mtype;
	ULONG i;

	// make a copy of type, d1 is a scratch register
	mtype=type;

	switch(mtype) {
		case TD_3X :
		case TD_3XSAVE :
		case TD_3XLOAD :
			if(tdlibinfos->lib3dinfos!=NULL && name!=NULL) {
				i=0;
				while(tdlibinfos->lib3dinfos[i]!=NULL) {
					if(strcmp(tdlibinfos->lib3dinfos[i]->name,name)==0) {
						return(tdlibinfos->lib3dinfos[i]->library);
					}
					i++;
				}
			}
			break;
	}

	return(NULL);
}























































































































/****** tdo.library/meshCameraLightDefaultSet ******************************************
* 
*   NAME	
* 	meshCameraLightDefaultSet -- Set the camera and light to defaults.
* 
*   SYNOPSIS
*	error = meshCameraLightDefaultSet( meshhandle )
*	                                   D1
*
*	ULONG meshCameraLightDefaultSet
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
* 	error - RCER_NOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*
*   EXAMPLE
*	error= meshCameraLightDefaultSet(meshhandle);
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
* 	meshCameraPositionSet(),meshCameraLookAtSet(),
*	meshLightPositionSet(),meshLightColorSet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshCameraLightDefaultSet(register __d1 ULONG meshhandle) {
	TTDOMesh *mesh=NULL;
  
	mesh=(TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);
	
	setCameraLight(mesh);
	
	return(RCNOERROR);
}

/****** tdo.library/meshCameraPositionSetdv ******************************************
* 
*   NAME	
* 	meshCameraPositionSetdv -- Set the camera position.
* 
*   SYNOPSIS
*	error = meshCameraPositionSetdv( meshhandle,position )
*	                                 D1          A0
*
*	ULONG meshCameraPositionSetdv
*	     ( ULONG,TTDOVertexd * );
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
*	error = meshCameraPositionSetdv(meshhandle,&myvertex);
*
*   NOTES
*	The camera will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	meshCameraPositionGet(),meshCameraLookAtSet(),
*	meshCameraLookAtGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshCameraPositionSetdv(register __d1 ULONG meshhandle,
											register __a0 TTDOVertexd *position) {
	TTDOMesh		*mesh=NULL;
	TTDOVertexd	*mposition=NULL;
	
	// make a copy of position, a0 is a scratch register
	mposition=position;
  
	mesh=(TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);
	
	mesh->camera.position=(*mposition);
	
	return(RCNOERROR);
}

/****** tdo.library/meshCameraPositionSetfv ******************************************
* 
*   NAME	
* 	meshCameraPositionSetfv -- Set the camera position.
* 
*   SYNOPSIS
*	error = meshCameraPositionSetfv( meshhandle,position )
*	                                 D1          A0
*
*	ULONG meshCameraPositionSetfv
*	     ( ULONG,TTDOVertexf * );
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
*	error = meshCameraPositionSetfv(meshhandle,&myvertex);
*
*   NOTES
*	The camera will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	meshCameraPositionGet(),meshCameraLookAtSet(),
*	meshCameraLookAtGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshCameraPositionSetfv(register __d1 ULONG meshhandle,
											register __a0 TTDOVertexf *position) {
	TTDOMesh		*mesh=NULL;
	TTDOVertexd	mposition;
	
	// make a copy of position, a0 is a scratch register
	mposition.x=position->x;
	mposition.y=position->y;
	mposition.z=position->z;
  
	mesh=(TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);
	
	mesh->camera.position=mposition;
	
	return(RCNOERROR);
}

/****** tdo.library/meshCameraPositionSet3da ******************************************
* 
*   NAME	
* 	meshCameraPositionSet3da -- Set the camera position.
* 
*   SYNOPSIS
*	error = meshCameraPositionSet3da( meshhandle,position )
*	                                  D1          A0
*
*	ULONG meshCameraPositionSet3da
*	     ( ULONG,TTDODouble [3] );
*
*   FUNCTION
*	The position of the camera will be set to the values passed by the
*	double array.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	position        - A double array containing the position information.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*`	        RCNOMESH     if the handle is not valid.
*
*   EXAMPLE
*	error = meshCameraPositionSet3da(meshhandle,myvertex);
*
*   NOTES
*	The camera will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	meshCameraPositionGet(),meshCameraLookAtSet(),
*	meshCameraLookAtGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshCameraPositionSet3da(register __d1 ULONG meshhandle,
											register __a0 TTDODouble position[3]) {
	TTDOMesh		*mesh=NULL;
	TTDOVertexd	mposition;
	
	// make a copy of position, a0 is a scratch register
	mposition.x=position[0];
	mposition.y=position[1];
	mposition.z=position[2];
  
	mesh=(TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);
	
	mesh->camera.position=mposition;
	
	return(RCNOERROR);
}

/****** tdo.library/meshCameraPositionSet3fa ******************************************
* 
*   NAME	
* 	meshCameraPositionSet3fa -- Set the camera position.
* 
*   SYNOPSIS
*	error = meshCameraPositionSet3fa( meshhandle,position )
*	                                  D1          A0
*
*	ULONG meshCameraPositionSet3fa
*	     ( ULONG,TTDOFloat [3] );
*
*   FUNCTION
*	The position of the camera will be set to the values passed by the
*	float array.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	position        - A float array containing the position information.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*`	        RCNOMESH     if the handle is not valid.
*
*   EXAMPLE
*	error = meshCameraPositionSet3fa(meshhandle,myvertex);
*
*   NOTES
*	The camera will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	meshCameraPositionGet(),meshCameraLookAtSet(),
*	meshCameraLookAtGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshCameraPositionSet3fa(register __d1 ULONG meshhandle,
											register __a0 TTDOFloat position[3]) {
	TTDOMesh		*mesh=NULL;
	TTDOVertexd	mposition;
	
	// make a copy of position, a0 is a scratch register
	mposition.x=position[0];
	mposition.y=position[1];
	mposition.z=position[2];
  
	mesh=(TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);
	
	mesh->camera.position=mposition;
	
	return(RCNOERROR);
}

/****** tdo.library/meshCameraPositionGetdv ******************************************
* 
*   NAME	
* 	meshCameraPositionGetdv -- Get the position of the camera.
* 
*   SYNOPSIS
*	error = meshCameraPositionGetdv( meshhandle,position )
*	                                 D1          A0
*
*	ULONG meshCameraPositionGetdv
*	     ( ULONG,TTDOVertexd * );
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
*	error = meshCameraPositionGetdv(meshhandle,&myvertex);
*
*   NOTES
*	The camera will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	meshCameraPositionSet(),meshCameraLookAtSet()
*	meshCameraLookAtGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshCameraPositionGetdv(register __d1 ULONG meshhandle,
											register __a0 TTDOVertexd *position) {
	TTDOMesh		*mesh=NULL;
	TTDOVertexd	*mposition=NULL;
	
	// make a copy of position, a0 is a scratch register
	mposition=position;

	mesh = (TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);

	(*mposition)=mesh->camera.position;
	
	return(RCNOERROR);
}

/****** tdo.library/meshCameraPositionGetfv ******************************************
* 
*   NAME	
* 	meshCameraPositionGetfv -- Get the position of the camera.
* 
*   SYNOPSIS
*	error = meshCameraPositionGetfv( meshhandle,position )
*	                                 D1          A0
*
*	ULONG meshCameraPositionGetfv
*	     ( ULONG,TTDOVertexf * );
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
*	error = meshCameraPositionGetfv(meshhandle,&myvertex);
*
*   NOTES
*	The camera will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	meshCameraPositionSet(),meshCameraLookAtSet()
*	meshCameraLookAtGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshCameraPositionGetfv(register __d1 ULONG meshhandle,
											register __a0 TTDOVertexf *position) {
	TTDOMesh		*mesh=NULL;
	TTDOVertexf	*mposition=NULL;
	
	// make a copy of position, a0 is a scratch register
	mposition=position;

	mesh = (TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);

	mposition->x=mesh->camera.position.x;
	mposition->y=mesh->camera.position.y;
	mposition->z=mesh->camera.position.z;
	
	return(RCNOERROR);
}

/****** tdo.library/meshCameraPositionGet3da ******************************************
* 
*   NAME	
* 	meshCameraPositionGet3da -- Get the position of the camera.
* 
*   SYNOPSIS
*	error = meshCameraPositionGet3da( meshhandle,position )
*	                                  D1          A0
*
*	ULONG meshCameraPositionGet3da
*	     ( ULONG,TTDODouble [3] );
*
*   FUNCTION
*	The position of the camera will be written in the passed double array.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	position        - A double array which will contain
*	                  the position information.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*
*   EXAMPLE
*	error = meshCameraPositionGet3da(meshhandle,myvertex);
*
*   NOTES
*	The camera will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	meshCameraPositionSet(),meshCameraLookAtSet()
*	meshCameraLookAtGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshCameraPositionGet3da(register __d1 ULONG meshhandle,
											register __a0 TTDODouble position[3]) {
	TTDOMesh		*mesh=NULL;
	TTDODouble		*mposition=NULL;
	
	// make a copy of position, a0 is a scratch register
	mposition=position;

	mesh = (TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);

	mposition[0]=mesh->camera.position.x;
	mposition[1]=mesh->camera.position.y;
	mposition[2]=mesh->camera.position.z;
	
	return(RCNOERROR);
}

/****** tdo.library/meshCameraPositionGet3fa ******************************************
* 
*   NAME	
* 	meshCameraPositionGet3fa -- Get the position of the camera.
* 
*   SYNOPSIS
*	error = meshCameraPositionGet3fa( meshhandle,position )
*	                                  D1          A0
*
*	ULONG meshCameraPositionGet3fa
*	     ( ULONG,TTDOFloat [3] );
*
*   FUNCTION
*	The position of the camera will be written in the passed float array.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	position        - A float array which will contain
*	                  the position information.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*
*   EXAMPLE
*	error = meshCameraPositionGet3fa(meshhandle,myvertex);
*
*   NOTES
*	The camera will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	meshCameraPositionSet(),meshCameraLookAtSet()
*	meshCameraLookAtGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshCameraPositionGet3fa(register __d1 ULONG meshhandle,
											register __a0 TTDOFloat position[3]) {
	TTDOMesh		*mesh=NULL;
	TTDOFloat		*mposition=NULL;
	
	// make a copy of position, a0 is a scratch register
	mposition=position;

	mesh = (TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);

	mposition[0]=mesh->camera.position.x;
	mposition[1]=mesh->camera.position.y;
	mposition[2]=mesh->camera.position.z;
	
	return(RCNOERROR);
}

/****** tdo.library/meshCameraLookAtSetdv ******************************************
* 
*   NAME	
* 	meshCameraLookAtSetdv -- Set the camera its view point.
* 
*   SYNOPSIS
*	error = meshCameraLookAtSetdv( meshhandle,lookat )
*	                               D1          A0
*
*	ULONG meshCameraLookAtSetdv
*	     ( ULONG,TTDOVertexd * );
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
*	error = meshCameraLookAtSetdv(meshhandle,&myvertex);
*
*   NOTES
*	The camera will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	meshCameraLookAtGet(),meshCameraPositionSet()
*	meshCameraPositionSet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshCameraLookAtSetdv(register __d1 ULONG meshhandle,
										register __a0 TTDOVertexd *lookat) {
	TTDOMesh		*mesh=NULL;
	TTDOVertexd	*mlookat=NULL;

	// make a copy of lookat, a0 is a scratch register
	mlookat=lookat;

	mesh=(TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);
	
	mesh->camera.lookat=(*mlookat);
	
	return(RCNOERROR);
}

/****** tdo.library/meshCameraLookAtSetfv ******************************************
* 
*   NAME	
* 	meshCameraLookAtSetfv -- Set the camera its view point.
* 
*   SYNOPSIS
*	error = meshCameraLookAtSetfv( meshhandle,lookat )
*	                               D1          A0
*
*	ULONG meshCameraLookAtSetfv
*	     ( ULONG,TTDOVertexf * );
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
*	error = meshCameraLookAtSetfv(meshhandle,&myvertex);
*
*   NOTES
*	The camera will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	meshCameraLookAtGet(),meshCameraPositionSet()
*	meshCameraPositionSet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshCameraLookAtSetfv(register __d1 ULONG meshhandle,
										register __a0 TTDOVertexf *lookat) {
	TTDOMesh		*mesh=NULL;
	TTDOVertexf	*mlookat=NULL;

	// make a copy of lookat, a0 is a scratch register
	mlookat=lookat;

	mesh=(TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);
	
	mesh->camera.lookat.x=mlookat->x;
	mesh->camera.lookat.y=mlookat->y;
	mesh->camera.lookat.z=mlookat->z;
	
	return(RCNOERROR);
}

/****** tdo.library/meshCameraLookAtSet3da ******************************************
* 
*   NAME	
* 	meshCameraLookAtSet3da -- Set the camera its view point.
* 
*   SYNOPSIS
*	error = meshCameraLookAtSet3da( meshhandle,lookat )
*	                                D1          A0
*
*	ULONG meshCameraLookAtSet3da
*	     ( ULONG,TTDODouble [3] );
*
*   FUNCTION
*	The view point of the camera will be set to the values passed by the
*	double array.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	lookat          - A double array which contains the position information.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*
*   EXAMPLE
*	error = meshCameraLookAtSet3da(meshhandle,myvertex);
*
*   NOTES
*	The camera will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	meshCameraLookAtGet(),meshCameraPositionSet()
*	meshCameraPositionSet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshCameraLookAtSet3da(register __d1 ULONG meshhandle,
											register __a0 TTDODouble lookat[3]) {
	TTDOMesh		*mesh=NULL;
	TTDODouble		*mlookat=NULL;

	// make a copy of lookat, a0 is a scratch register
	mlookat=lookat;

	mesh=(TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);
	
	mesh->camera.lookat.x=mlookat[0];
	mesh->camera.lookat.y=mlookat[1];
	mesh->camera.lookat.z=mlookat[2];
	
	return(RCNOERROR);
}

/****** tdo.library/meshCameraLookAtSet3fa ******************************************
* 
*   NAME	
* 	meshCameraLookAtSet3fa -- Set the camera its view point.
* 
*   SYNOPSIS
*	error = meshCameraLookAtSet3fa( meshhandle,lookat )
*	                                D1          A0
*
*	ULONG meshCameraLookAtSet3fa
*	     ( ULONG,TTDOFloat [3] );
*
*   FUNCTION
*	The view point of the camera will be set to the values passed by the
*	float array.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	lookat          - A float array which contains the position information.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*
*   EXAMPLE
*	error = meshCameraLookAtSet3fa(meshhandle,myvertex);
*
*   NOTES
*	The camera will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	meshCameraLookAtGet(),meshCameraPositionSet()
*	meshCameraPositionSet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshCameraLookAtSet3fa(register __d1 ULONG meshhandle,
											register __a0 TTDOFloat lookat[3]) {
	TTDOMesh		*mesh=NULL;
	TTDOFloat		*mlookat=NULL;

	// make a copy of lookat, a0 is a scratch register
	mlookat=lookat;

	mesh=(TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);
	
	mesh->camera.lookat.x=mlookat[0];
	mesh->camera.lookat.y=mlookat[1];
	mesh->camera.lookat.z=mlookat[2];
	
	return(RCNOERROR);
}

/****** tdo.library/meshCameraLookAtGetdv ******************************************
* 
*   NAME	
* 	meshCameraLookAtGetdv -- Get the view point of the camera.
* 
*   SYNOPSIS
*	error = meshCameraLookAtGetdv( meshhandle,lookat )
*	                               D1          A0
*
*	ULONG meshCameraLookAtGetdv
*	     ( ULONG,TTDOVertexd * );
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
*	error = meshCameraLookAtGetdv(meshhandle,&myvertex);
*
*   NOTES
*	The camera will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	meshCameraLookAtSet(),meshCameraPositionSet()
*	meshCameraPositionGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshCameraLookAtGetdv(register __d1 ULONG meshhandle,
										register __a0 TTDOVertexd *lookat) {
	TTDOMesh		*mesh=NULL;
	TTDOVertexd	*mlookat=NULL;
	
	// make a copy of lookat, a0 is a scratch register
	mlookat=lookat;
  
	mesh=(TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);

	(*mlookat)=mesh->camera.lookat;
	
	return(RCNOERROR);
}

/****** tdo.library/meshCameraLookAtGetfv ******************************************
* 
*   NAME	
* 	meshCameraLookAtGetfv -- Get the view point of the camera.
* 
*   SYNOPSIS
*	error = meshCameraLookAtGetfv( meshhandle,lookat )
*	                               D1          A0
*
*	ULONG meshCameraLookAtGetfv
*	     ( ULONG,TTDOVertexf * );
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
*	error = meshCameraLookAtGetfv(meshhandle,&myvertex);
*
*   NOTES
*	The camera will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	meshCameraLookAtSet(),meshCameraPositionSet()
*	meshCameraPositionGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshCameraLookAtGetfv(register __d1 ULONG meshhandle,
											register __a0 TTDOVertexf *lookat) {
	TTDOMesh		*mesh=NULL;
	TTDOVertexf	*mlookat=NULL;
	
	// make a copy of lookat, a0 is a scratch register
	mlookat=lookat;
  
	mesh=(TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);

	mlookat->x=mesh->camera.lookat.x;
	mlookat->y=mesh->camera.lookat.y;
	mlookat->z=mesh->camera.lookat.z;
	
	return(RCNOERROR);
}

/****** tdo.library/meshCameraLookAtGet3da ******************************************
* 
*   NAME	
* 	meshCameraLookAtGet3da -- Get the view point of the camera.
* 
*   SYNOPSIS
*	error = meshCameraLookAtGet3da( meshhandle,lookat )
*	                                D1          A0
*
*	ULONG meshCameraLookAtGet3da
*	     ( ULONG,TTDODouble [3] );
*
*   FUNCTION
*	The view point of the camera will be written in the passed double array.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	lookat          - A double array which will contain
*	                  the position information.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*
*   EXAMPLE
*	error = meshCameraLookAtGet3da(meshhandle,myvertex);
*
*   NOTES
*	The camera will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	meshCameraLookAtSet(),meshCameraPositionSet()
*	meshCameraPositionGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshCameraLookAtGet3da(register __d1 ULONG meshhandle,
											register __a0 TTDODouble lookat[3]) {
	TTDOMesh		*mesh=NULL;
	TTDODouble		*mlookat=NULL;
	
	// make a copy of lookat, a0 is a scratch register
	mlookat=lookat;
  
	mesh=(TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);

	mlookat[0]=mesh->camera.lookat.x;
	mlookat[1]=mesh->camera.lookat.y;
	mlookat[2]=mesh->camera.lookat.z;
	
	return(RCNOERROR);
}

/****** tdo.library/meshCameraLookAtGet3fa ******************************************
* 
*   NAME	
* 	meshCameraLookAtGet3fa -- Get the view point of the camera.
* 
*   SYNOPSIS
*	error = meshCameraLookAtGet3fa( meshhandle,lookat )
*	                                D1          A0
*
*	ULONG meshCameraLookAtGet3fa
*	     ( ULONG,TTDOFloat [3] );
*
*   FUNCTION
*	The view point of the camera will be written in the passed float array.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	lookat          - A float array which will contain
*	                  the position information.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*
*   EXAMPLE
*	error = meshCameraLookAtGet3fa(meshhandle,myvertex);
*
*   NOTES
*	The camera will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	meshCameraLookAtSet(),meshCameraPositionSet()
*	meshCameraPositionGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshCameraLookAtGet3fa(register __d1 ULONG meshhandle,
											register __a0 TTDOFloat lookat[3]) {
	TTDOMesh		*mesh=NULL;
	TTDOFloat		*mlookat=NULL;
	
	// make a copy of lookat, a0 is a scratch register
	mlookat=lookat;
  
	mesh=(TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);

	mlookat[0]=mesh->camera.lookat.x;
	mlookat[1]=mesh->camera.lookat.y;
	mlookat[2]=mesh->camera.lookat.z;
	
	return(RCNOERROR);
}

/****** tdo.library/meshLightPositionSetdv ******************************************
* 
*   NAME	
* 	meshLightPositionSetdv -- Set the light source its position.
* 
*   SYNOPSIS
*	error = meshLightPositionSetdv( meshhandle,position )
*	                                D1          A0
*
*	ULONG meshLightPositionSetdv
*	     ( ULONG,TTDOVertexd * );
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
*	error = meshLightPositionSetdv(meshhandle,&myvertex);
*
*   NOTES
*	The light will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	meshLightPositionGet(),meshLightColorSet()
*	meshLightColorGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshLightPositionSetdv(register __d1 ULONG meshhandle,
											register __a0 TTDOVertexd *position) {
	TTDOMesh		*mesh=NULL;
	TTDOVertexd		*mposition=NULL;

	// make a copy of position, a0 is a scratch register
	mposition=position;

	mesh=(TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);
	
	mesh->light.position=(*mposition);
	
	return(RCNOERROR);
}

/****** tdo.library/meshLightPositionSetfv ******************************************
* 
*   NAME	
* 	meshLightPositionSetfv -- Set the light source its position.
* 
*   SYNOPSIS
*	error = meshLightPositionSetfv( meshhandle,position )
*	                                D1          A0
*
*	ULONG meshLightPositionSetfv
*	     ( ULONG,TTDOVertexf * );
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
*	error = meshLightPositionSetfv(meshhandle,&myvertex);
*
*   NOTES
*	The light will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	meshLightPositionGet(),meshLightColorSet()
*	meshLightColorGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshLightPositionSetfv(register __d1 ULONG meshhandle,
											register __a0 TTDOVertexf *position) {
	TTDOMesh		*mesh=NULL;
	TTDOVertexf	*mposition=NULL;

	// make a copy of position, a0 is a scratch register
	mposition=position;

	mesh=(TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);
	
	mesh->light.position.x=mposition->x;
	mesh->light.position.y=mposition->y;
	mesh->light.position.z=mposition->z;
	
	return(RCNOERROR);
}

/****** tdo.library/meshLightPositionSet3da ******************************************
* 
*   NAME	
* 	meshLightPositionSet3da -- Set the light source its position.
* 
*   SYNOPSIS
*	error = meshLightPositionSet3da( meshhandle,position )
*	                                 D1          A0
*
*	ULONG meshLightPositionSet3da
*	     ( ULONG,TTDODouble [3] );
*
*   FUNCTION
*	The position of the light source will be set to the values passed by the
*	double array.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	position        - A double array which containis the position information.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*
*   EXAMPLE
*	error = meshLightPositionSet3da(meshhandle,myvertex);
*
*   NOTES
*	The light will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	meshLightPositionGet(),meshLightColorSet()
*	meshLightColorGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshLightPositionSet3da(register __d1 ULONG meshhandle,
											register __a0 TTDODouble  position[3]) {
	TTDOMesh		*mesh=NULL;
	TTDODouble		*mposition=NULL;

	// make a copy of position, a0 is a scratch register
	mposition=position;

	mesh=(TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);
	
	mesh->light.position.x=mposition[0];
	mesh->light.position.y=mposition[1];
	mesh->light.position.z=mposition[2];
	
	return(RCNOERROR);
}

/****** tdo.library/meshLightPositionSet3fa ******************************************
* 
*   NAME	
* 	meshLightPositionSet3fa -- Set the light source its position.
* 
*   SYNOPSIS
*	error = meshLightPositionSet3fa( meshhandle,position )
*	                                 D1          A0
*
*	ULONG meshLightPositionSet3fa
*	     ( ULONG,TTDOFloat [3] );
*
*   FUNCTION
*	The position of the light source will be set to the values passed by the
*	float array.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	position        - A float array which containis the position information.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*
*   EXAMPLE
*	error = meshLightPositionSet3fa(meshhandle,myvertex);
*
*   NOTES
*	The light will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	meshLightPositionGet(),meshLightColorSet()
*	meshLightColorGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshLightPositionSet3fa(register __d1 ULONG meshhandle,
											register __a0 TTDOFloat  position[3]) {
	TTDOMesh		*mesh=NULL;
	TTDOFloat		*mposition=NULL;

	// make a copy of position, a0 is a scratch register
	mposition=position;

	mesh=(TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);
	
	mesh->light.position.x=mposition[0];
	mesh->light.position.y=mposition[1];
	mesh->light.position.z=mposition[2];
	
	return(RCNOERROR);
}

/****** tdo.library/meshLightPositionGetdv ******************************************
* 
*   NAME	
* 	meshLightPositionGetdv -- Get the position of the light source.
* 
*   SYNOPSIS
*	error = meshLightPositionGetdv( meshhandle,position )
*	                                D1          A0
*
*	ULONG meshLightPositionGetdv
*	     ( ULONG,TTDOVertexd * );
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
*	error = meshLightPositionGetdv(meshhandle,&myvertex);
*
*   NOTES
*	The light will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	meshLightPositionSet(),meshLightColorSet()
*	meshLightColorGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshLightPositionGetdv(register __d1 ULONG meshhandle,
											register __a0 TTDOVertexd *position) {
	TTDOMesh		*mesh=NULL;
	TTDOVertexd	*mposition=NULL;
	
	// make a copy of position, a0 is a scratch register
	mposition=position;
  
	mesh=(TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);

	(*mposition)=mesh->light.position;
	
	return(RCNOERROR);
}

/****** tdo.library/meshLightPositionGetfv ******************************************
* 
*   NAME	
* 	meshLightPositionGetfv -- Get the position of the light source.
* 
*   SYNOPSIS
*	error = meshLightPositionGetfv( meshhandle,position )
*	                                D1          A0
*
*	ULONG meshLightPositionGetfv
*	     ( ULONG,TTDOVertexf * );
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
*	error = meshLightPositionGetfv(meshhandle,&myvertex);
*
*   NOTES
*	The light will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	meshLightPositionSet(),meshLightColorSet()
*	meshLightColorGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshLightPositionGetfv(register __d1 ULONG meshhandle,
											register __a0 TTDOVertexf *position) {
	TTDOMesh		*mesh=NULL;
	TTDOVertexf	*mposition=NULL;
	
	// make a copy of position, a0 is a scratch register
	mposition=position;
  
	mesh=(TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);

	mposition->x=mesh->light.position.x;
	mposition->y=mesh->light.position.y;
	mposition->z=mesh->light.position.z;
	
	return(RCNOERROR);
}

/****** tdo.library/meshLightPositionGet3da ******************************************
* 
*   NAME	
* 	meshLightPositionGet3da -- Get the position of the light source.
* 
*   SYNOPSIS
*	error = meshLightPositionGet3da( meshhandle,position )
*	                                 D1          A0
*
*	ULONG meshLightPositionGet3da
*	     ( ULONG,TTDODouble [3] );
*
*   FUNCTION
*	The position of the light source will be written in the passed double array.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	position        - A double array which will contain
*	                  the position information.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*
*   EXAMPLE
*	error = meshLightPositionGet3da(meshhandle,myvertex);
*
*   NOTES
*	The light will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	meshLightPositionSet(),meshLightColorSet()
*	meshLightColorGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshLightPositionGet3da(register __d1 ULONG meshhandle,
											register __a0 TTDODouble position[3]) {
	TTDOMesh		*mesh=NULL;
	TTDODouble		*mposition=NULL;
	
	// make a copy of position, a0 is a scratch register
	mposition=position;
  
	mesh=(TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);

	mposition[0]=mesh->light.position.x;
	mposition[1]=mesh->light.position.y;
	mposition[2]=mesh->light.position.z;
	
	return(RCNOERROR);
}

/****** tdo.library/meshLightPositionGet3fa ******************************************
* 
*   NAME	
* 	meshLightPositionGet3fa -- Get the position of the light source.
* 
*   SYNOPSIS
*	error = meshLightPositionGet3fa( meshhandle,position )
*	                                 D1          A0
*
*	ULONG meshLightPositionGet3fa
*	     ( ULONG,TTDOFloat [3] );
*
*   FUNCTION
*	The position of the light source will be written in the passed float array.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	position        - A float array which will contain
*	                  the position information.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*
*   EXAMPLE
*	error = meshLightPositionGet3fa(meshhandle,myvertex);
*
*   NOTES
*	The light will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	meshLightPositionSet(),meshLightColorSet()
*	meshLightColorGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshLightPositionGet3fa(register __d1 ULONG meshhandle,
											register __a0 TTDOFloat position[3]) {
	TTDOMesh		*mesh=NULL;
	TTDOFloat		*mposition=NULL;
	
	// make a copy of position, a0 is a scratch register
	mposition=position;
  
	mesh=(TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);

	mposition[0]=mesh->light.position.x;
	mposition[1]=mesh->light.position.y;
	mposition[2]=mesh->light.position.z;
	
	return(RCNOERROR);
}

/****** tdo.library/meshLightColorSetubc ******************************************
* 
*   NAME	
* 	meshLightColorSetubc -- Set the light source its color.
* 
*   SYNOPSIS
*	error = meshLightColorSetubc( meshhandle,color )
*	                              D1          A0
*
*	ULONG meshLightColorSetubc
*	     ( ULONG,TTDOColorub * );
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
*	error = meshLightColorSetubc(meshhandle,&mycolor);
*
*   NOTES
*	The light will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	meshLightColorGet(),meshLightPositionSet()
*	meshLightPositionGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshLightColorSetubc(register __d1 ULONG meshhandle,
										 register __a0 TTDOColorub *color) {
	TTDOMesh		*mesh=NULL;
	TTDOColorub	*mcolor=NULL;
	
	// make a copy of color, a0 is a scratch register
	mcolor=color;
  
	mesh=(TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);
	
	mesh->light.color=(*mcolor);

	return(RCNOERROR);
}

/****** tdo.library/meshLightColorGetubc ******************************************
* 
*   NAME	
* 	meshLightColorGetubc -- Get the color of the light source.
* 
*   SYNOPSIS
*	error = meshLightColorGetubc( meshhandle,color )
*	                              D1          A0
*
*	ULONG meshLightColorGetubc
*	     ( ULONG,TTDOColorub * );
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
*	error = meshLightColorGetubc(meshhandle,&mycolor);
*
*   NOTES
*	The light will be used by some file formats only,
*	and for 2D or display functions.
*
*   BUGS
* 
*   SEE ALSO
* 	meshLightColorSet(),meshLightPositionSet()
*	meshLightPositionGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshLightColorGetubc(register __d1 ULONG meshhandle,
										register __a0 TTDOColorub *color) {
	TTDOMesh		*mesh=NULL;
	TTDOColorub	*mcolor=NULL;
	
	// make a copy of color, a0 is a scratch register
	mcolor=color;

	mesh=(TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);

	(*color)=mesh->light.color;
	
	return(RCNOERROR);
}

/****** tdo.library/meshBoundingBoxGetd ******************************************
* 
*   NAME	
* 	meshBoundingBoxGetd -- Get the bounding box of the mesh.
* 
*   SYNOPSIS
*	error = meshBoundingBoxGetd( meshhandle,bbox )
*	                             D1          A0
*
*	ULONG meshBoundingBoxGetd
*	     ( ULONG,TTDOBBoxd * );
*
*   FUNCTION
*	The bounding box of the mesh will be written in the passed BBox structure.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	bbox            - Pointer to a bbox structure which will contain
*	                  the bounding box informations.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*
*   EXAMPLE
*	error = meshBoundingBoxGetd(meshhandle,&mybbox);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshBoundingBoxGetd(register __d1 ULONG meshhandle,
										register __a0 TTDOBBoxd *bbox) {
	TTDOMesh		*mesh=NULL;
	TTDOBBoxd		*mbbox=NULL;
	
	// make a copy of bbox, a0 is a scratch register
	mbbox=bbox;
  
	mesh=(TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);

	(*mbbox)=mesh->bBox;
	
	return(RCNOERROR);
}

/****** tdo.library/meshBoundingBoxGetf ******************************************
* 
*   NAME	
* 	meshBoundingBoxGetf -- Get the bounding box of the mesh.
* 
*   SYNOPSIS
*	error = meshBoundingBoxGetf( meshhandle,bbox )
*	                             D1          A0
*
*	ULONG meshBoundingBoxGetf
*	     ( ULONG,TTDOBBoxf * );
*
*   FUNCTION
*	The bounding box of the mesh will be written in the passed BBox structure.
* 
*   INPUTS
* 	meshhandle      - A valid handle of a mesh.
*	bbox            - Pointer to a bbox structure which will contain
*	                  the bounding box informations.
*	
*   RESULT
* 	error - RCNOERROR    if all went well.
*	        RCNOMESH     if the handle is not valid.
*
*   EXAMPLE
*	error = meshBoundingBoxGetf(meshhandle,&mybbox);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshBoundingBoxGetf(register __d1 ULONG meshhandle,
										register __a0 TTDOBBoxf *bbox) {
	TTDOMesh		*mesh=NULL;
	TTDOBBoxf		*mbbox=NULL;
	
	// make a copy of bbox, a0 is a scratch register
	mbbox=bbox;
  
	mesh=(TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);

	mbbox->front=mesh->bBox.front;
	mbbox->rear=mesh->bBox.rear;
	mbbox->left=mesh->bBox.left;
	mbbox->right=mesh->bBox.right;
	mbbox->top=mesh->bBox.top;
	mbbox->bottom=mesh->bBox.bottom;

	return(RCNOERROR);
}

/****** tdo.library/meshSave3D ******************************************
* 
*   NAME	
* 	meshSave3D -- Saves the mesh as 3D file..
*
*   SYNOPSIS
*	error = meshSave3D( meshhandle,formatname,filename,screen )
*	                    D1         D2         D3        A0
*
*	ULONG meshSave3D
*	     ( ULONG,STRPTR,STRPTR,struct Screen * );
*
*   FUNCTION
*	The mesh will be saved in the specified 3d file format.
* 
*   INPUTS
* 	meshhandle  - A valid handle of a mesh.
*	formatname  - A valid 3D saver name, which specifies the output format.
*	filename    - Name and path of the file.
*	screen      - The screen of the caller, or NULL if no one or no options.
*	
*   RESULT
*	error - RCNOERROR            if all went well.
*	        RCNOMESH             if the handle is not valid.
*	        RCUNKNOWNFORMAT      if the file format is not known.
*	        RCSAVEROPEN          if the saver library could not be opened.
*	        tdo3X errors         if an error occured in the extension module.
*	        IoErr()              if possible to catch it, you will get its codes.
*
*   EXAMPLE
*	error = meshSave3D(meshhandle,formatname,"ram:test",NULL);
*
*   NOTES
*	No file existence tests are made here! Existent files will be overwritten.
*
*   BUGS
* 
*   SEE ALSO
*	meshLoad3D(),meshSave2D(),
*	meshLoad2D()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshSave3D(register __d1 ULONG meshhandle,
								register __d2 STRPTR formatname,
								register __d3 STRPTR filename,
								register __a0 struct Screen *screen) {
	TTDOMesh		*mesh;
	ULONG			mmeshhandle;
	struct Screen	*mscreen;
	ULONG			retcode=RCNOERROR;
	UBYTE			i;

	// make a copy of screen, a0 is a scratch register
	mmeshhandle=meshhandle;

	// make a copy of screen, a0 is a scratch register
	mscreen=screen;
	
	mesh = (TTDOMesh *) meshhandle;
	if(mesh==NULL) return(RCNOMESH);	
 
	/*
	** Check if the filetype is valid
	*/
	if(c3dsNames==NULL) return(RCUNKNOWNFORMAT);
	i=0;
	while(c3dsNames[i]!=NULL && strcmp(c3dsNames[i],formatname)!=0) {i++};
	if(c3dsNames[i]==NULL) return(RCUNKNOWNFORMAT);
	
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
	** Open the output library and write the mesh
	*/
	if((x3Base=(APTR) OpenLibrary(c3dsLib[i],0))==NULL) {
		return(RCSAVEROPEN);
	}

	retcode=tdo3XSave(mmeshhandle,filename,NULL);

	CloseLibrary((APTR)x3Base);

	return(RCNOERROR);
}

/****** tdo.library/meshLoad3D ******************************************
* 
*   NAME	
* 	meshLoad3D -- Loads a 3D file into a mesh.
*
*   SYNOPSIS
*	error = meshLoad3D( meshhandle,filename,erroffset,screen )
*	                    D1         D3       D4         A0
*
*	ULONG meshLoad3D
*	     ( ULONG *,STRPTR,struct Screen * );
*
*   FUNCTION
*	A new mesh will be created and filled up with the data
*	found in the 3D file.
* 
*   INPUTS
* 	meshhandle  - Pointer which will contain the new mesh.
*	filename    - Name and path of the file.
*	erroffset   - Offset in lines or bytes where an error occured.
*	screen      - The screen of the caller, or NULL if no one or no options.
*	
*   RESULT
*	error - RCNOERROR            if all went well.
*	        RCNOMESH             if no new mesh could be created.
*	        RCUNKNOWNFORMAT      if the file format is not known.
*	        RCLOADEROPEN         if a loader library could not be opened.
*	        tdo3X errors         if an error occured in the extension module.
*	        IoErr()              if possible to catch it, you will get its codes.
*
*   EXAMPLE
*	error = meshLoad3D(&meshhandle,"ram:test",NULL);
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
*	meshSave3D(),meshSave2D(),
*	meshLoad2D()
* 
******************************************************************************
*
*/
ULONG __saveds ASM meshLoad3D(register __d1 ULONG *meshhandle,
								register __d3 STRPTR filename,
								register __d4 ULONG *erroffset,
								register __a0 struct Screen *screen) {
	ULONG			*mmeshhandle;
	struct Screen	*mscreen;
	ULONG			retcode=RCNOERROR;
	UBYTE			i;

	// make a copy of meshhandle, d1 is a scratch register
	mmeshhandle=meshhandle;

	// make a copy of screen, a0 is a scratch register
	mscreen=screen;

	// check if the input file can be recognized by someone
	if(c3dlNames==NULL) return(RCUNKNOWNFORMAT);
	i=0;
	retcode=RCNOERROR+1;
	while(c3dlLib[i]!=NULL && retcode!=RCNOERROR) {
		if((x3Base=(APTR) OpenLibrary(c3dlLib[i],0))==NULL) {
			return(RCLOADEROPEN);
		}

		retcode=tdo3XCheckFile(filename);

		// close the library if it is the false one, and increment i
		if(retcode!=RCNOERROR) {
			CloseLibrary((APTR)x3Base);
			i++;
		}
	};
	
	// did we find something ?
	if(retcode!=RCNOERROR) {
		CloseLibrary((APTR)x3Base);
		return(retcode);
	}

	// create a new mesh
//	if(((*mmeshhandle)=meshNew())==0) {
//		CloseLibrary((APTR)x3Base);
//		return(RCNOMESH);
//	}
	
	retcode=tdo3XLoad((*mmeshhandle),filename,erroffset,mscreen);

	// in error case, delete the mesh
	if(retcode!=RCNOERROR) {
//		meshDelete((*mmeshhandle));
		(*meshhandle)=0;
	}

	CloseLibrary((APTR)x3Base);

	return(retcode);
}


/*
ULONG __saveds ASM tdogetcur(register __a6 struct tdoBase *tdoBase) {
 return(tdoBase->tdb_current);
}
*/


/*
TODO

Lightwave,Imagine,Videoscape  groessen/anzahl checks fertigmachen !!

Material mehr parameter, brechungsindex, reflektion, ...

*/

/************************* End of file ******************************/

