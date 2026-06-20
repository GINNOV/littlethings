/*
**      $VER: td_private.h 0.1 (20.6.99)
**
**      Creation date     : 11.4.1999
**
**      Description       :
**         Private type definitions and constants for the td library.
**
**      Written by Stephan Bielmann
**
**
*/

#ifndef INCLUDE_TD_PRIVATE_H
#define INCLUDE_TD_PRIVATE_H

/********************************************************************/

#include "td_public.h"

/**************************** Defines *******************************/

// Material arrays
#define Ci_MATBLOCKS		100
#define Ci_MATNODESINBLOCK	100

// Object arrays
#define Ci_OBJECTBLOCKS		100
#define Ci_OBJECTNODESINBLOCK	100

// matgroup arrays
#define Ci_MATGROUPBLOCKS			200
#define Ci_MATGROUPNODESINBLOCK	100

// vertex arrays
#define Ci_VERTEXBLOCKS		100
#define Ci_VERTEXARRAYINBLOCK	100
#define Ci_VERTEXARRAY			100

// polygon arrays
#define Ci_POLYBLOCKS			100
#define Ci_POLYARRAYINBLOCK	100
#define Ci_POLYARRAY			100

// Initial size of a polygon its vertex array
#define Ci_POLYVERARRAYINIT 3
#define Ci_POLYVERARRAYINITQ 4

/***************************** Types ********************************/

/*
** Color structure
*/
typedef struct {
	UBYTE r,g,b;
}TTDOColorub;

/*
** Camera structure
*/
typedef struct {
	TTDOVertexd	position,lookat;
}TTDOCamera;

/*
** Light source structure
*/
typedef struct {
	TTDOVertexd	position;
	TTDOColorub	color;
}TTDOLight;

/*
** Vertex array structure
*/
typedef struct {
	TTDOVertexd *varray[Ci_VERTEXARRAY];	/* Array of vertices */
}TTDOVertexArray;

/*
** Vertex block structure
*/
typedef struct {
	TTDOVertexArray *barray[Ci_VERTEXARRAYINBLOCK];	/* Arrays of vertex arrays */
}TTDOVertexBlock;

/*
** Vertex list structure
*/
typedef struct {
	ULONG				numberOfVertices;			/* Number of vertices in this list	*/
	TTDOVertexBlock	*blocks[Ci_VERTEXBLOCKS];	/* Array of vertex blocks.				*/
} TTDOVertexList;

/*
** Polygon node structure
*/
typedef struct TTDOPolygonNode {
	ULONG numberOfVertices;		/* Number of vertices in this polygon */

	ULONG				*varray;	/* Vertex handle array */
} TTDOPolygonNode;

/*
** Polygon array structure
*/
typedef struct {
	TTDOPolygonNode *parray[Ci_POLYARRAY];	/* Array of polygons */
}TTDOPolygonArray;

/*
** Polygon block structure
*/
typedef struct {
	TTDOPolygonArray *barray[Ci_POLYARRAYINBLOCK];	/* Arrays of polygon arrays */
}TTDOPolygonBlock;

/*
** Polygon list structure
*/
typedef struct {
	ULONG				numberOfVertices;		/* Number of vertices in this list	*/
	ULONG				numberOfPolygons;		/* Number of polygons in this list	*/
	TTDOPolygonBlock *blocks[Ci_POLYBLOCKS];	/* Array of polygon blocks.			*/
} TTDOPolygonList;

/*
** Material node structure, the real material
*/
typedef struct {
	STRPTR name;						/* The material its name 					*/
	
	TTDOColorub ambientColor;			/* The material its ambient color */
	TTDOColorub diffuseColor;			/* The material its diffuse color */
	TTDOFloat   shininess;				/* The material its shininess     */
	TTDOFloat   transparency;			/* The material its transparency  */
}TTDOMaterialNode;

/*
** Material block structure
*/
typedef struct {
	TTDOMaterialNode *nodes[Ci_MATNODESINBLOCK];	/* Array of material nodes */
}TTDOMaterialBlock;

/*
** Material list structure
*/
typedef struct {
	ULONG				numberOfMaterials;		/* Number of materials in this list */
	TTDOMaterialBlock	*blocks[Ci_MATBLOCKS];	/* Array of material blocks */
}TTDOMaterialList;

/*
** Current Transformation Matrix
*/
typedef struct {
	TTDODouble sx,sy,sz;	// Scale, 1 = as it is
	TTDODouble rx,ry,rz;	// Rotation in radian. 0 = no rotation. Needed to 
	                       // compute the ctm.m matrix.
	TTDODouble m[4][4];		// Matrix containing the rotation and transformation
}TTDOCTM;

/*
** Object structure
*/
typedef struct {
	STRPTR  name;                   	/* The name of this  */
	STRPTR  copyright;					/* For the single lined copyright string */
	
	TTDOBBoxd	bBox;					/* The bounding box    */
	TTDOCamera	camera;				/* The camera			*/
	TTDOLight	light;					/* The lightsource		*/
        
	TTDOVertexList   vertices;      	/* The list of vertices of this mesh	*/
	TTDOMaterialList materials;		/* The list of materials of this mesh	*/

	TTDOPolygonNode	*curpoly;		/* Current polygon node to work with */

	TTDOCTM		ctm;				/* The current transformation marix of this mesh */

	APTR	vertexpool;				/* Header of the vertex memory pool of this mesh */
	APTR	vertexarraypool;			/* Header of the vertex array pool of this mesh */
	APTR	vertexblockspool;			/* Header of the vertex block pool of this mesh */
	APTR	polyverpool;				/* Header of the polygon vertex list memory pool of this mesh */
	APTR	polypool;					/* Header of the polygon memory pool of this mesh */
	APTR	polyarraypool;				/* Header of the polygon array pool of this mesh */
	APTR	polyblockspool;			/* Header of the polygon block pool of this mesh */
	APTR	matblockspool;				/* Header of the material block pool of this mesh */
	APTR	partblockspool;			/* Header of the part block pool of this mesh */
} TTDOMesh;






/*
** Object node structure
*/
typedef struct {
	STRPTR name;			// The object its name

	TDvectord	s;			// Scale of the object
	TDvectord	r;			// Rotation in radian. 0 = no rotation, of the object
	TDvectord	o;			// Origin of the object.

	TDenum	type;			// Type of object
	ULONG	handle;		// Handle to the object itself
}TDobjectnode;

/*
** object block structure
*/
typedef struct {
	TDobjectnode *nodes[Ci_OBJECTNODESINBLOCK];	/* Array of object nodes */
}TDobjectblock;

/*
** Object list structure
*/
typedef struct {
	ULONG			numberOfObjects;			/* Number of objects in this list */
	TDobjectblock	*blocks[Ci_OBJECTBLOCKS];	/* Array of objects blocks */
}TDobjectlist;

/*
** Vertex array structure
*/
typedef struct {
	TDvectord *varray[Ci_VERTEXARRAY];	/* Array of vertices */
}TDvertexarray;

/*
** Vertex block structure
*/
typedef struct {
	TDvertexarray *barray[Ci_VERTEXARRAYINBLOCK];	/* Arrays of vertex arrays */
}TDvertexblock;

/*
** Vertex list structure
*/
typedef struct {
	ULONG			numberOfVertices;			/* Number of vertices in this list	*/
	TDvertexblock	*blocks[Ci_VERTEXBLOCKS];	/* Array of vertex blocks.				*/
} TDvertexlist;

/*
** Polygon node structure
*/
typedef struct {
	ULONG numberOfVertices;		/* Number of vertices in this polygon */

	ULONG *varray;					/* Vertex handle array */
} TDpolygonnode;

/*
** Polygon array structure
*/
typedef struct {
	TDpolygonnode *parray[Ci_POLYARRAY];	/* Array of polygons */
}TDpolygonarray;

/*
** Polygon block structure
*/
typedef struct {
	TDpolygonarray *barray[Ci_POLYARRAYINBLOCK];	/* Arrays of polygon arrays */
}TDpolygonblock;

/*
** Polygon list structure
*/
typedef struct {
	ULONG				numberOfVertices;		/* Number of vertices in this list	*/
	ULONG				numberOfPolygons;		/* Number of polygons in this list	*/
	TDpolygonblock 	*blocks[Ci_POLYBLOCKS];	/* Array of polygon blocks.			*/
} TDpolygonlist;

/*
** Surface structure
*/
typedef struct {
	TDcolorub ambientColor;			/* The material its ambient color */
	TDcolorub diffuseColor;			/* The material its diffuse color */
	TDfloat   shininess;				/* The material its shininess     */
	TDfloat   transparency;			/* The material its transparency  */
}TDsurface;

/*
** Texture structure
*/
typedef struct {
// achtung bei meshdelete namens pointer und so freigeben
}TDtexture;

/*
** Material node structure
*/
typedef struct {
	STRPTR name;			// The material its name

	ULONG	index;			// Index of this material, used if node is out of array.

	TDenum	type;			// Type of material
	ULONG	handle;		// Handle to the material itself
}TDmaterialnode;

/*
** Material block structure
*/
typedef struct {
	TDmaterialnode *nodes[Ci_MATNODESINBLOCK];	/* Array of material nodes */
}TDmaterialblock;

/*
** Material list structure
*/
typedef struct {
	ULONG				numberOfMaterials;		/* Number of materials in this list */
	TDmaterialblock	*blocks[Ci_MATBLOCKS];	/* Array of material blocks */
}TDmateriallist;

/*
** Matgroup node structure
*/
typedef struct TDmatgroupnode {
	TDpolygonlist	polygons;		/* Polygon list of this matgroup     */

	TDmaterialnode	*materialnode;	/* Node of the material of this group */
	ULONG			texbindex;		/* Index of the texture binding */
} TDmatgroupnode;

/*
** Matgroup block structure
*/
typedef struct {
	TDmatgroupnode *nodes[Ci_MATGROUPNODESINBLOCK];	/* Array of matgroup nodes */
}TDmatgroupblock;

/*
** Matgroup list structure
*/
typedef struct {
	ULONG numberOfMatGroups;	/* Number of mat groupts in this list	*/
	ULONG numberOfPolygons;	/* Number of polygons in this list	*/

	TDmatgroupblock	*blocks[Ci_MATGROUPBLOCKS];	/* Array of matgroup blocks*/
} TDmatgrouplist;

/*
** Current Transformation Matrix
*/
typedef struct {
	TDdouble sx,sy,sz;		// Scale, 1 = as it is
	TDdouble rx,ry,rz;		// Rotation in radian. 0 = no rotation. Needed to 
	                       // compute the ctm.m matrix.
	TDdouble m[4][4];		// Matrix containing the rotation and transformation
}TDctm;

/*
** Texture binding structure
*/
typedef struct {
} TDtexbinding;

/*
** Cube structure
*/
typedef struct {
	TDvectord size;					/* Size coordinates of the cube */
} TDcube;

/*
** Polymesh structure
*/
typedef struct {
	TDbboxd	bBox;					/* The bounding box    */
        
	TDvertexlist   vertices;      	/* The list of vertices of this mesh	*/
	TDmatgrouplist	matgroups;			/* The list of mat groups of this mesh  	*/ 

	TDpolygonnode	*curpolyn;			/* Current polygon node to work with */
	TDmatgroupnode	*curmatgroupn;		/* Current matgroup node to work with    */

	APTR	vertexpool;				/* Header of the vertex memory pool of this mesh */
	APTR	vertexarraypool;			/* Header of the vertex array pool of this mesh */
	APTR	vertexblockspool;			/* Header of the vertex block pool of this mesh */
	APTR	polyverpool;				/* Header of the polygon vertex list memory pool of this mesh */
	APTR	polypool;					/* Header of the polygon memory pool of this mesh */
	APTR	polyarraypool;				/* Header of the polygon array pool of this mesh */
	APTR	polyblockspool;			/* Header of the polygon block pool of this mesh */
	APTR	matgroupblockspool;		/* Header of the matgroup block pool of this mesh */
} TDpolymesh;

/*
** Space structure
*/
typedef struct {
	STRPTR  name;                   	/* The name of this space */
	
	TDbboxd	bBox;					/* The bounding box    */

	TDobjectlist objects;				/* The list of objects of this space	*/
	TDmateriallist materials;			/* The list of materials of this space	*/

	TDctm		ctm;					/* The current transformation matrix */

	TDmaterialnode	*curmatn;			/* The material to work with */
	TDobjectnode	*curobjn;			/* The object to work with   */

	APTR	objectblockspool;			/* Header of the object block pool */
	APTR	matblockspool;				/* Header of the material block pool */
} TDspace;

/*
** 3d library information structure
*/
typedef struct {
	STRPTR	library;		/* Name of the 3d library, with extension	*/
	STRPTR	name;			/* Name of the format						*/
	STRPTR	ext;			/* Extension of the format					*/
	TDenum	*sups;			/* Supported save functions				*/
	TDenum	*supl;			/* Supported load functions				*/	
} TD3dlibinfo;

/*
** TD library information structure
*/
typedef struct {
	TD3dlibinfo	**lib3dinfos;	/* Array of 3d library informations structures */
} TDlibraryinfo;

#endif

/************************* End of file ******************************/
