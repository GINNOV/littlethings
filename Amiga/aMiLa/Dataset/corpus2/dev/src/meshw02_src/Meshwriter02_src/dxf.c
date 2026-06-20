/*
**      $VER: dxf.c 1.00 (27.03.1999)
**
**      Creation date : 06.12.1998
**
**      Description       :
**         Standart saver module for meshwriter.library.
**         Saves the mesh as DXF ascii file.
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

/*********************** Type definitions ***************************/

/*
** This struct is created just for storing AutoCAD default
** color palette table.
*/
typedef struct {
        UBYTE  red, green, blue;
} DXFColor;

/*************************** Variables ******************************/

/*
** AutoCAD equivalent rgb colors.
*/
static const DXFColor colorTbl[] = {
{  0,  0,  0},{255,  0,  0},{255,255,  0},{  0,255,  0},{  0,255,255},{  0,  0,255},{255,  0,255},
{255,255,255},{  0,  0,  0},{  0,  0,  0},{255,  0,  0},{255,128,128},{166,  0,  0},{166, 83, 83},
{128,  0,  0},{128, 64, 64},{ 77,  0,  0},{ 77, 38, 38},{ 38,  0,  0},{ 38, 19, 19},{255, 64,  0},
{255,159,128},{166, 41,  0},{166,104, 83},{128, 32,  0},{128, 80, 64},{ 77, 19,  0},{ 77, 48, 38},
{ 38, 10,  0},{ 38, 24, 19},{255,128,  0},{255,191,128},{166, 83,  0},{166,124, 83},{128, 64,  0},
{128, 96, 64},{ 77, 38,  0},{ 77, 57, 38},{ 38, 19,  0},{ 38, 29, 19},{255,191,  0},{255,223,128},
{166,124,  0},{166,145, 83},{128, 96,  0},{128,112, 64},{ 77, 57,  0},{ 77, 67, 38},{ 38, 29,  0},
{ 38, 33, 19},{255,255,  0},{255,255,128},{166,166,  0},{166,166, 83},{128,128,  0},{128,128, 64},
{ 77, 77,  0},{ 77, 77, 38},{ 38, 38,  0},{ 38, 38, 19},{191,255,  0},{223,255,128},{124,166,  0},
{145,166, 83},{ 96,128,  0},{112,128, 64},{ 57, 77,  0},{ 67, 77, 38},{ 29, 38,  0},{ 33, 38, 19},
{128,255,  0},{191,255,128},{ 83,166,  0},{124,166, 83},{ 64,128,  0},{ 96,128, 64},{ 38, 77,  0},
{ 57, 77, 38},{ 19, 38,  0},{ 29, 38, 19},{ 64,255,  0},{159,255,128},{ 41,166,  0},{104,166, 83},
{ 32,128,  0},{ 80,128, 64},{ 19, 77,  0},{ 48, 77, 38},{ 10, 38,  0},{ 24, 38, 19},{  0,255,  0},
{128,255,128},{  0,166,  0},{ 83,166, 83},{  0,128,  0},{ 64,128, 64},{  0, 77,  0},{ 38, 77, 38},
{  0, 38,  0},{ 19, 38, 19},{  0,255, 64},{128,255,159},{  0,166, 41},{ 83,166,104},{  0,128, 32},
{ 64,128, 80},{  0, 77, 19},{ 38, 77, 48},{  0, 38, 10},{ 19, 38, 24},{  0,255,128},{128,255,191},
{  0,166, 83},{ 83,166,124},{  0,128, 64},{ 64,128, 96},{  0, 77, 38},{ 38, 77, 57},{  0, 38, 19},
{ 19, 38, 29},{  0,255,191},{128,255,223},{  0,166,124},{ 83,166,145},{  0,128, 96},{ 64,128,112},
{  0, 77, 57},{ 38, 77, 67},{  0, 38, 29},{ 19, 38, 33},{  0,255,255},{128,255,255},{  0,166,166},
{ 83,166,166},{  0,128,128},{ 64,128,128},{  0, 77, 77},{ 38, 77, 77},{  0, 38, 38},{ 19, 38, 38},
{  0,191,255},{128,223,255},{  0,124,166},{ 83,145,166},{  0, 96,128},{ 64,112,128},{  0, 57, 77},
{ 38, 67, 77},{  0, 29, 38},{ 19, 33, 38},{  0,128,255},{128,191,255},{  0, 83,166},{ 83,124,166},
{  0, 64,128},{ 64, 96,128},{  0, 38, 77},{ 38, 57, 77},{  0, 19, 38},{ 19, 29, 38},{  0, 64,255},
{128,159,255},{  0, 41,166},{ 83,104,166},{  0, 32,128},{ 64, 80,128},{  0, 19, 77},{ 38, 48, 77},
{  0, 10, 38},{ 19, 24, 38},{  0,  0,255},{128,128,255},{  0,  0,166},{ 83, 83,166},{  0,  0,128},
{ 64, 64,128},{  0,  0, 77},{ 38, 38, 77},{  0,  0, 38},{ 19, 19, 38},{ 64,  0,255},{159,128,255},
{ 41,  0,166},{104, 83,166},{ 32,  0,128},{ 80, 64,128},{ 19,  0, 77},{ 48, 38, 77},{ 10,  0, 38},
{ 24, 19, 38},{128,  0,255},{191,128,255},{ 83,  0,166},{124, 83,166},{ 64,  0,128},{ 96, 64,128},
{ 38,  0, 77},{ 57, 38, 77},{ 19,  0, 38},{ 29, 19, 38},{191,  0,255},{223,128,255},{124,  0,166},
{145, 83,166},{ 96,  0,128},{112, 64,128},{ 57,  0, 77},{ 67, 38, 77},{ 29,  0, 38},{ 33, 19, 38},
{255,  0,255},{255,128,255},{166,  0,166},{166, 83,166},{128,  0,128},{128, 64,128},{ 77,  0, 77},
{ 77, 38, 77},{ 38,  0, 38},{ 38, 19, 38},{255,  0,191},{255,128,223},{166,  0,124},{166, 83,145},
{128,  0, 96},{128, 64,112},{ 77,  0, 57},{ 77, 38, 67},{ 38,  0, 29},{ 38, 19, 33},{255,  0,128},
{255,128,191},{166,  0, 83},{166, 83,124},{128,  0, 64},{128, 64, 96},{ 77,  0, 38},{ 77, 38, 57},
{ 38,  0, 19},{ 38, 19, 29},{255,  0, 64},{255,128,159},{166,  0, 41},{166, 83,104},{128,  0, 32},
{128, 64, 80},{ 77,  0, 19},{ 77, 38, 48},{ 38,  0, 10},{ 38, 19, 24},{ 84, 84, 84},{118,118,118},
{152,152,152},{187,187,187},{221,221,221},{255,255,255}
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
* Description  : Converts a DXF color index into a RGB color.        *
*                                                                    *
* Arguments    : index : The color index.                            *
*                                                                    *
* Return Value : Vector its magnitude.                               *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static DXFColor index2Color(ULONG index)
{
	static DXFColor col;
	
	/*
	** Check range
	*/
	if (index >= 0 && index < sizeof(colorTbl)/sizeof(DXFColor)) {
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
* Name         : color2DXF                                           *
*                                                                    *
* Description  : Matches the nearest color available in the DXF      *
*                color palette.                                      *
*                                                                    *
* Arguments    : red,green,blue : Color values.                      *
*                                                                    *
* Return Value : DXF color index.                                    *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static ULONG color2DXF (UBYTE red, UBYTE green, UBYTE blue)
{
	ULONG		i;
	ULONG		index = 1;
	DXFColor	current;
	LONG		best;
	LONG		difference;
  
	current = index2Color(index);
	best =  magnitude(current.red-red,current.green-green,current.blue-blue);

	for (i = 0; i < sizeof(colorTbl)/sizeof(DXFColor); i++) {
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
* Name         : write3DXF                                           *
*                                                                    *
* Description  : Writes a standart DXF ascii file.                   *
*                                                                    *
* Arguments    : dxffile IN  : An already opened file stream.        *
*                mesh    IN  : Pointer to the mesh.                  *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
ULONG write3DXF(BPTR dxffile, TOCLMesh *mesh) {
	UBYTE 						buffer[500];
	TOCLVertex					ver;
	TOCLMaterialNode			*mat=NULL;
	TOCLPolygonNode 			*pln=NULL;
	TOCLPolygonsVerticesNode	*plv=NULL;
	ULONG l;

	/*
	** Write the header
	*/
	if (FPuts(dxffile,"  0\nSECTION\n  2\nHEADER\n  9\n$ACADVER\n  1\nAC1009\n  0\nENDSEC\n")!=DOSFALSE) return(RCWRITEDATA);

	/*
	** Write the name and the copyright string if there are any
	*/
	if (mesh->name!=NULL && mesh->name[0]!='\n') {
		if (FPrintf(dxffile,"  0\n%s\n",mesh->name)==ENDSTREAMCH) return(RCWRITEDATA);
	}
	if (mesh->copyright!=NULL && mesh->copyright[0]!='\0') {
		if (FPrintf(dxffile,"999\n%s\n",mesh->copyright)==ENDSTREAMCH) return(RCWRITEDATA);	  
	}

	/*
	** Begin the tables section and write the different materials as layers, an NOLAYERDEFINED layer with color WHITE will be defined for polygons without material
	*/
	if (FPuts(dxffile,"  0\nSECTION\n  2\nTABLES\n  0\nTABLE\n  2\nLAYER\n 70\n2\n")!=DOSFALSE) return(RCWRITEDATA);
	if (FPuts(dxffile,"  0\nLAYER\n  2\nNOLAYERDEFINED\n 70\n0\n 62\n7\n  6\nCONTINUOUS\n")!=DOSFALSE) return(RCWRITEDATA);	

	/* Write the materials */
	if(mesh->materials.firstNode!=NULL) {
		  
		/* The diffuse color is the only thing to translate */
		mat=mesh->materials.firstNode;
		do {
			TOCLColor col=mat->diffuseColor;
			
			if (FPrintf(dxffile,"  0\nLAYER\n  2\n%s\n 70\n0\n 62\n%ld\n  6\nCONTINUOUS\n",mat->name,color2DXF(col.r,col.g,col.b))==ENDSTREAMCH) return(RCWRITEDATA);

			mat=mat->next;
		} while(mat!=NULL);
	}
	if (FPuts(dxffile,"  0\nENDTAB\n  0\nENDSEC\n")!=DOSFALSE) return(RCWRITEDATA);

	/*
	** Write the entities section header
	*/
	if(FPuts(dxffile,"  0\nSECTION\n  2\nENTITIES\n")!=DOSFALSE) return(RCWRITEDATA);

	/*
	** Write the polylines, if a polygon has no material a NOLAYERDEFINED layer will be used instead
	*/
  	if(mesh->polygons.firstNode!=NULL) {             
  	  	pln=mesh->polygons.firstNode;
		do {				
			if(pln->firstNode!=NULL) {  			  			  	  			  			  			  
				if(pln->numberOfVertices>=3) {	
					/* Check if there is a material */
					if (pln->materialNode!=NULL) {
						if (FPrintf(dxffile,"  0\nPOLYLINE\n  8\n%s\n 66\n1\n 70\n64\n 71\n%ld\n 72\n1\n",pln->materialNode->name,pln->numberOfVertices)==ENDSTREAMCH) return(RCWRITEDATA);
					} else {
						if (FPrintf(dxffile,"  0\nPOLYLINE\n  8\nNOLAYERDEFINED\n 66\n1\n 70\n64\n 71\n%ld\n 72\n1\n",pln->numberOfVertices)==ENDSTREAMCH) return(RCWRITEDATA);
					}
					/* First write the vertices */
					plv=pln->firstNode;
					do {
					    ver=plv->vertexNode->vertex;
    					/* Check if there is a material */
    					if (pln->materialNode!=NULL) {
							sprintf(buffer,"  0\nVERTEX\n  8\n%s\n 10\n%g\n 20\n%g\n 30\n%g\n 70\n192\n",pln->materialNode->name,ver.x,ver.y,ver.z);
						} else {
							sprintf(buffer,"  0\nVERTEX\n  8\nNOLAYERDEFINED\n 10\n%g\n 20\n%g\n 30\n%g\n 70\n192\n",ver.x,ver.y,ver.z);
						}
						if(FPuts(dxffile,buffer)!=DOSFALSE) return(RCWRITEDATA);

						plv=plv->next;
					} while(plv!=NULL);
					/* Second write the polyline connection vertices */					
					for(l=2;l<pln->numberOfVertices;l++) {
    					/* Check if there is a material */
    					if (pln->materialNode!=NULL) {
							if (FPrintf(dxffile,"  0\nVERTEX\n  8\n%s\n 10\n0\n 20\n0\n 30\n0\n 70\n128\n 71\n1\n 72\n%ld\n 73\n%ld\n",pln->materialNode->name,l,l+1)==ENDSTREAMCH) return(RCWRITEDATA);
						} else {
							if (FPrintf(dxffile,"  0\nVERTEX\n  8\nNOLAYERDEFINED\n 10\n0\n 20\n0\n 30\n0\n 70\n128\n 71\n1\n 72\n%ld\n 73\n%ld\n",l,l+1)==ENDSTREAMCH) return(RCWRITEDATA);
						}
					}
					
					/* Write the end of the sequence */
					if (FPrintf(dxffile,"  0\nSEQEND\n")==ENDSTREAMCH) return(RCWRITEDATA);
				}
			}
			pln=pln->next;
		} while(pln!=NULL);
	}

	/*
	** Write the end of the file
	*/
	if (FPrintf(dxffile,"  0\nENDSEC\n  0\nEOF\n")==ENDSTREAMCH) return(RCWRITEDATA);

	return(RCNOERROR);
}

/************************* End of file ******************************/
