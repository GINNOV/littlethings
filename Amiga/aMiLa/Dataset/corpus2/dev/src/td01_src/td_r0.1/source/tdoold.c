/*
**      $VER: tdo.c 0.1 (17.4.99)
**
**      Creation date     : 11.10.1998
**
**      Description       :
**         tdo library.
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

#include <clib/dos_protos.h>
#include <clib/alib_stdio_protos.h>

#include <pragma/exec_lib.h>

/*
** Project includes
*/
#include "tdo_private.h"
#include "compiler.h"
#include "pragma/s3_lib.h"

/********************** Private constants ***************************/

/*
** The constant supported file format arrays
*/

//dummi hummi
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


/*
** The constant supported drawing mode arrays
*/
static ULONG  cDMIDs   [] = {
	TDMPOINTS,
	TDMWIREBW,
	TDMWIREGR,
	TDMWIRECL,
	TDMHIDDBW,
	TDMHIDDGR,
	TDMHIDDCL,
	TDMSURFBW,
	TDMSURFGR,
	TDMSURFCL,
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

struct s3Base *s3Base = NULL;

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
static ULONG hash(TTDOVertex vertex) {
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
static TTDOVertexNode *addVertex(TTDOMesh *mesh,
                                 TTDOVertex vertex) {

	ULONG	hashcode;
	TTDOHashsVerticesNode	*hlvindex=NULL;
	TTDOVertexNode			*ver=NULL;
	TTDOCTM				ctm;
	TTDOVertex 			rvertex;

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

	// initialize the hashcode
	hashcode=hash(rvertex);

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
	ver = AllocPooled(mesh->vertexpool,sizeof(TTDOVertexNode));
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
	if(rvertex.x<mesh->bBox.left)   mesh->bBox.left=rvertex.x;
	if(rvertex.x>mesh->bBox.right)  mesh->bBox.right=rvertex.x;
	if(rvertex.y<mesh->bBox.rear)   mesh->bBox.rear=rvertex.y;
	if(rvertex.y>mesh->bBox.front)  mesh->bBox.front=rvertex.y;
	if(rvertex.z<mesh->bBox.bottom) mesh->bBox.bottom=rvertex.z;
	if(rvertex.z>mesh->bBox.top)    mesh->bBox.top=rvertex.z;
	
	/*
	** Add the vertex to the hash table
	*/
	hlvindex = AllocMem(sizeof(TTDOHashsVerticesNode),MEMF_FAST);
	if (hlvindex==NULL) {
		FreePooled(mesh->vertexpool,ver,sizeof(TTDOVertexNode));
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
static TTDOVertexNode *getVertex(TTDOMesh *mesh,
								ULONG index) {

	TTDOVertexNode			*ver=NULL;

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
static ULONG getVertexIndex(TTDOMesh *mesh,
							TTDOVertex vertex) {

	ULONG	hashcode		=hash(vertex);
	TTDOHashsVerticesNode	*hlvindex=NULL;
	TTDOVertexNode			*ver=NULL;

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
static TTDOMaterialNode *getMaterialNode(TTDOMesh *mesh, ULONG materialindex) {
	TTDOMaterialNode	*mindex=NULL;
	
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
static VOID setCameraLight(TTDOMesh *mesh) {
	TTDOVertex ver1;
		
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

/****** tdo.library/tdo2DFileFormatNamesGet ******************************************
* 
*   NAME	
* 	tdo2DFileFormatNamesGet -- Get a name list of all supported 2D file formats.
* 
*   SYNOPSIS
*	list = tdo2DFileFormatNamesGet(  )
*
*	STRPTR * tdo2DFileFormatNamesGet
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
*	list = tdo2DFileFormatNamesGet();
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdo2DFileFormatIDGet(),tdo2DFileFormatExtensionGet()
*	tdo2DFileFormatNumberOfGet()
* 
******************************************************************************
*
*/
STRPTR * __saveds ASM tdo2DFileFormatNamesGet() {
	if(c2dFFNames[0]!=NULL) return(c2dFFNames);
	return(NULL);
}

/****** tdo.library/tdo2DFileFormatIDGet ******************************************
* 
*   NAME	
* 	tdo2DFileFormatIDGet -- Get the ID of a specific 2D file format.
* 
*   SYNOPSIS
*	id = tdo2DFileFormatIDGet( ffname )
*	                           D1
*
*	ULONG tdo2DFileFormatIDGet
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
*	id = tdo2DFileFormatIDGet("PostScript");
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
* 	tdo2DFileFormatNamesGet(),tdo2DFileFormatExtensionGet()
*	tdo2DFileFormatNumberOfGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM tdo2DFileFormatIDGet(register __d1 STRPTR ffname) {
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

/****** tdo.library/tdo2DFileFormatExtensionGet ******************************************
* 
*   NAME	
* 	tdo2DFileFormatExtensionGet -- Get the file extension of a specific 2D file format.
* 
*   SYNOPSIS
*	ext = tdo2DFileFormatExtensionGet( ffid )
*	                                   D1
*
*	STRPTR tdo2DFileFormatExtensionGet
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
*	ext = tdo2DFileFormatExtensionGet(id);
*
*   NOTES
*	This extensions are proposals of the format creators, but you are free
*	to use them.
*
*   BUGS
* 
*   SEE ALSO
* 	tdo2DFileFormatNamesGet(),tdo2DFileFormatIDGet()
*	tdo2DFileFormatNumberOfGet()
* 
******************************************************************************
*
*/
STRPTR __saveds ASM tdo2DFileFormatExtensionGet(register __d1 ULONG ffid) {
	ULONG i,mffid;

	// make a copy of ffid, d1 is a scratch register
	mffid=ffid;
	
	i=0;
	while(c2dFFIDs[i]!=mffid && c2dFFIDs[i]!=0) {i++};
	
	// check if we got it or not
	if(c2dFFIDs[i]==mffid) return(c2dFFExtensions[i]);
	else return(NULL);
}

/****** tdo.library/tdo2DFileFormatNumberOfGet ******************************************
* 
*   NAME	
* 	tdo2DFileFormatNumberOfGet -- Get the number of supported 2D file formats.
* 
*   SYNOPSIS
*	number = tdo2DFileFormatNumberOfGet( )
*
*	ULONG tdo2DFileFormatNumberOfGet
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
*	number = tdo2DFileFormatNumberOfGet();
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
* 	tdo2DFileFormatNamesGet(),tdo2DFileFormatIDGet()
*	tdo2DFileFormatNumberExtensionGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM tdo2DFileFormatNumberOfGet() {
	ULONG  i;
	STRPTR *sIndex=NULL;

	i=0;
	sIndex=c2dFFNames;
	while (sIndex[i]!=NULL) i++;
	
	return(i);
}

/****** tdo.library/tdoMeshSave2D ******************************************
* 
*   NAME	
* 	tdoMeshSave2D -- Saves the mesh as 2D file.
*
*   SYNOPSIS
*	error = tdoMeshSave2D( meshhandle,id,filename,parameters )
*	                       D1         D2 D3        A0
*
*	ULONG tdoMeshSave2D
*	     ( ULONG,ULONG,STRPTR,T2DParams );
*
*   FUNCTION
*	The mesh, this means vertices, polygons, materials, camera and light will
*	be used to generate and save a 2D file from a specific view point and
*	drawing mode in a given size.
* 
*   INPUTS
* 	meshhandle  - A valid handle of a mesh.
*	id          - A valid 2D file format id, to specify the output format.
*	filename    - Name and path of the file.
*	parameters  - A 2D parameter sructure containing additional information.
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
*	        RCNOWIDTH         if the width is 0.
*	        RCNOHEIGHT        if the height is 0.
*	        IoErr()           if possible to catch it, you will get its codes.
*
*   EXAMPLE
*	error = tdoMeshSave2D(meshhandle,id,"ram:test",myparams);
*
*   NOTES
*	No file existence tests are made here! Existent files will be overwritten.
*
*   BUGS
* 
*   SEE ALSO
* 	tdo2DFileFormatIDGet(),tdoDrawModeGet(),tdoMeshSave3D()
* 
******************************************************************************
*
*/
ULONG __saveds ASM tdoMeshSave2D(register __d1 ULONG meshhandle,
									register __d2 ULONG id,
									register __d3 STRPTR filename,
									register __a0 T2DParams *parameters) {
	TTDOMesh		*mesh;
	BPTR			filehandle=NULL;
	ULONG			retcode=RCNOERROR;
	UBYTE			i;
	T2DParams		*mparams=NULL;
	
	// make a copy of the parameters, a0 is a scratch register
	mparams=parameters;

	mesh = (TTDOMesh *) meshhandle;
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
	if(!(mparams->viewtype==TVWTOP ||
		mparams->viewtype==TVWBOTTOM ||
		mparams->viewtype==TVWLEFT ||
		mparams->viewtype==TVWRIGHT ||
		mparams->viewtype==TVWFRONT ||
		mparams->viewtype==TVWREAR ||
		mparams->viewtype==TVWPERSP ||
		mparams->viewtype==TVW4SIDES)) return(RCUNKNOWNVTYPE);

	/*
	** Check if the drawmode is valid
	*/
	i=0;
	while(cDMIDs[i]!=mparams->drawmode && cDMIDs[i]!=0) {i++};
	if(cDMIDs[i]!=mparams->drawmode || mparams->drawmode==0) return(RCUNKNOWNDMODE);
	
	/*
	** Check if the width is set
	*/
	if (mparams->width==0) {
		return(RCNOWIDTH);
	}

	/*
	** Check if the height is set
	*/
	if (mparams->height==0) {
		return(RCNOHEIGHT);
	}

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
		case T2DFEPS :
//			retcode = write2EPS(filehandle,mesh,mparams->viewtype,mparams->drawmode,mparams->width,mparams->height);
			break;		
	}
	
	/*
	** Close the file
	*/
	Close(filehandle);
	
	return(retcode);
}
 
/****** tdo.library/tdoDrawModeNamesGet ******************************************
* 
*   NAME 
*        tdoDrawModeNamesGet -- Get a name list of all supported drawing modes.
* 
*   SYNOPSIS
*        list = tdoDrawModeNamesGet(  )
*
*        STRPTR * tdoDrawModeNamesGet
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
*        list = tdoDrawModeNamesGet();
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
*        tdoDrawModeIDGet(),tdoDrawModeNumberOfGet()
* 
******************************************************************************
*
*/
STRPTR * __saveds ASM tdoDrawModeNamesGet() {
	if(cDMNames[0]!=NULL) return(cDMNames);
	return(NULL);
}

/****** tdo.library/tdoDrawModeIDGet ******************************************
* 
*   NAME 
*        tdoDrawModeIDGet -- Get the ID of a specific drawing mode.
* 
*   SYNOPSIS
*        id = tdoDrawModeIDGet( dmname )
*                               D1
*
*        ULONG tdoDrawModeIDGet
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
*        id = tdoDrawModeIDGet("Points");
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
*        tdoDrawModeNamesGet(),tdoDrawModeNumberOfGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM tdoDrawModeIDGet(register __d1 STRPTR ffname) {
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

/****** tdo.library/tdoDrawModeNumberOfGet ******************************************
* 
*   NAME 
*        tdoDrawModeNumberOfGet -- Get the number of supported drawing modes.
* 
*   SYNOPSIS
*        number = tdoDrawModeNumberOfGet( )
*
*        ULONG tdoDrawModeNumberOfGet
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
*        number = tdoDrawModeNumberOfGet();
*
*   NOTES
*
*   BUGS
* 
*   SEE ALSO
*        tdoDrawModeNamesGet(),tdoDrawModeIDGet()
* 
******************************************************************************
*
*/
ULONG __saveds ASM tdoDrawModeNumberOfGet() {
	ULONG  i;
	STRPTR *sIndex=NULL;

	i=0;
	sIndex=cDMNames;
	while (sIndex[i]!=NULL) i++;
	
	return(i);
}

/*
TODO

Lightwave,Imagine,Videoscape  groessen/anzahl checks fertigmachen !!

Material mehr parameter, brechungsindex, reflektion, ...

*/

/************************* End of file ******************************/

