/*
**      $VER: meshwriter_private.h 1.00 (27.03.1999)
**
**      Creation date     : 18.10.1998
**
**      Description       :
**         Private type definitions and constants for the mesh writer module.
**
**      Written by Stephan Bielmann
**
**
*/

#ifndef INCLUDE_MESHWRITER_PRIVATE_H
#define INCLUDE_MESHWRITER_PRIVATE_H

/********************************************************************/

#include <meshwriter_public.h>

/*********************** Defines and types **************************/

/*
** Hashsize definition
*/
#define HASHSIZE 51

/*
** Bounding box structure
*/
typedef struct {
	TOCLFloat front,rear,left,right,top,bottom;
}TOCLBBox;

/*
** Camera structure
*/
typedef struct {
	TOCLVertex	position,lookat;
}TOCLCamera;

/*
** Light source structure
*/
typedef struct {
	TOCLVertex	position;
	TOCLColor	color;
}TOCLLight;

/*
** Vertex node structure
*/
typedef struct TOCLVertexNode {
	ULONG			index;		/* Index of this vertex, beginning at 1		*/
	TOCLVertex		vertex;	/* Vertex itself							 	*/
	TOCLVertexNode	*next;		/* Next vertex node						 	*/
}TOCLVertexNode;

/*
** Vertex list structure
*/
typedef struct {
	ULONG			numberOfVertices;		/* Number of vertices in this list	*/
	TOCLVertexNode	*firstNode;			/* First vertex node in this list		*/
	TOCLVertexNode	*lastNode;				/* Last vertex node in this list		*/
} TOCLVertexList;

/*
** Material structure, the real material
*/
typedef struct TOCLMaterialNode {
	ULONG  index;						/* Index of this material, beginning at 1	*/
	STRPTR name;						/* The material its name 					*/
	
	TOCLColor ambientColor;			/* The material its ambient color */
	TOCLColor diffuseColor;			/* The material its diffuse color */
	TOCLFloat shininess;				/* The material its shininess     */
	TOCLFloat transparency;			/* The material its transparency  */
	
	TOCLMaterialNode *next;			/* Next material node             */
}TOCLMaterialNode;

/*
** Material list structure
*/
typedef struct {
	ULONG				numberOfMaterials;	/* Number of materials in this list */
	TOCLMaterialNode	*firstNode;		/* First material node in this list */
	TOCLMaterialNode	*lastNode;			/* Last material node in this list  */
}TOCLMaterialList;

/*
** Polygon its vertex list
*/
typedef struct TOCLPolygonsVerticesNode {
	TOCLVertexNode				*vertexNode;	/* Pointer to an existing vertex node	*/
	TOCLPolygonsVerticesNode	*next;			/* Next vertex node in this polygon 	*/
} TOCLPolygonsVerticesNode;

/*
** Polygon node structure, the real polygon
*/
typedef struct TOCLPolygonNode {
	ULONG						numberOfVertices;	/* Number of vertices in this polygon, should be >=3 */
        
	TOCLMaterialNode			*materialNode;		/* Pointer to an existing material node */
        
	TOCLPolygonsVerticesNode	*firstNode;		/* First vertex node in this polygon */
	TOCLPolygonsVerticesNode	*lastNode;			/* Last vertex node in this polygon  */
	
	TOCLPolygonNode			*next;				/* Next polygon node                 */
}TOCLPolygonNode;

/*
** Polygon list structure
*/
typedef struct {
	ULONG				numberOfPolygons;	/* Number of polygons in this list */
	TOCLPolygonNode	*firstNode;		/* First polygon node in this list */
	TOCLPolygonNode	*lastNode;			/* Last polygon node in this list  */
}TOCLPolygonList;

/*
** Hash its vertex list
*/
typedef struct TOCLHashsVerticesNode {
	TOCLVertexNode			*vertexNode;	/* Pointer to an existing vertex node	*/
	TOCLHashsVerticesNode	*next;			/* Next vertex node in this hash		*/
} TOCLHashsVerticesNode;

/*
** Current Transformation Matrix
*/
typedef struct {
	TOCLFloat sx,sy,sz;	// Scale, 1 = as it is
	TOCLFloat rx,ry,rz;	// Rotation in radian. 0 = no rotation. Needed to 
	                       // compute the ctm.m matrix.
	TOCLFloat m[4][4];		// Matrix containing the rotation and transformation
}TOCLCTM;

/*
** Mesh structure
*/
typedef struct {
	APTR	vertexpool;				/* Header of the vertex memory pool of this mesh */
	APTR	polygonverticespool;		/* Header of the polygon vertex memory pool ot this mesh */
	APTR	polygonpool;				/* Header of the polygon memory pool of this mesh */
  
	STRPTR  name;                   	/* The name of this mesh */
	
	STRPTR  copyright;					/* For the single lined copyright string */
	
	TOCLBBox	bBox;					/* The bounding box    */
	TOCLCamera camera;					/* The camera			*/
	TOCLLight  light;					/* The lightsource		*/
        
	TOCLVertexList   vertices;      	/* The list of vertices of this mesh  */
	TOCLPolygonList  polygons;      	/* The list of polygons of this mesh  */ 
	TOCLMaterialList materials;		/* The list of materials of this mehs */

	TOCLCTM		ctm;				/* The current transformation marix of this mesh */

	TOCLHashsVerticesNode *hashTable[HASHSIZE]; /* Internal hashtable for the vertices */
} TOCLMesh;

#endif

/************************* End of file ******************************/
