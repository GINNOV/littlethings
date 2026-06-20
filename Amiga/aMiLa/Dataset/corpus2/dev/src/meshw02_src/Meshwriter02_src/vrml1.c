/*
**      $VER: vrml1.c 1.00 (27.03.1999)
**
**      Creation date : 29.11.1998
**
**      Description       :
**         Standart saver module for meshwriter.library.
**         Saves the mesh as VRML 1 ascii file.
**
**
**      Written by Stephan Bielmann
**
*/

/*************************** Includes *******************************/

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

/********************** Private functions ***************************/

/********************** Public functions ****************************/

/********************************************************************\
*                                                                    *
* Name         : write3VRML1                                         *
*                                                                    *
* Description  : Writes a standart VRML1 ascii file.                 *
*                                                                    *
* Arguments    : vrmlfile IN : An already opened file stream.        *
*                mesh     IN : Pointer to the mesh.                  *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      : Default material is the first.                      *
*                                                                    *
\********************************************************************/
ULONG write3VRML1(BPTR vrmlfile, TOCLMesh *mesh) {
	UBYTE 						buffer[200];
	TOCLVertexNode				*ver=NULL;
	TOCLMaterialNode			*mat=NULL;
	TOCLPolygonNode 			*pln=NULL;
	TOCLPolygonsVerticesNode	*plv=NULL;
	TOCLFloat					r,g,b;
			
	/*
	** Write the header, the copyright, default separator and info node
	*/
	if (FPuts(vrmlfile,"#VRML V1.0 ascii\n")!=DOSFALSE) return(RCWRITEDATA);
	if (mesh->copyright) {
		if (FPrintf(vrmlfile,"#\n#%s\n",mesh->copyright)==ENDSTREAMCH) return(RCWRITEDATA);	  
	}
	if (FPrintf(vrmlfile,"\nDEF ROOT Separator {\n   Info {\n      string \"%s\"\n   }\n",mesh->name)==ENDSTREAMCH) return(RCWRITEDATA);

	/*
	** Write the light source
	*/
	r=mesh->light.color.r;
	g=mesh->light.color.g;
	b=mesh->light.color.b;
	r/=255,g/=255,b/=255;
	sprintf(buffer,"   PointLight {\n      on TRUE\n      intensity  1.00\n      color %g %g %g\n      location  %g %g %G\n   }\n",
			r,g,b,mesh->light.position.x,mesh->light.position.y,mesh->light.position.z);
	if(FPuts(vrmlfile,buffer)!=DOSFALSE) return(RCWRITEDATA);

	/*
	** Write the vertices
	*/              
	if(mesh->vertices.firstNode!=NULL) {
		ver=mesh->vertices.firstNode;
		if (FPuts(vrmlfile,"   Coordinate3 {\n      point [\n")!=DOSFALSE) return(RCWRITEDATA);
		do {
			TOCLVertex v=ver->vertex;
			sprintf(buffer,"         %g %g %g,\n",v.x,v.y,v.z);
			if(FPuts(vrmlfile,buffer)!=DOSFALSE) return(RCWRITEDATA);
			ver=ver->next;
		} while(ver!=NULL);
		if (FPuts(vrmlfile,"      ]\n   }\n")!=DOSFALSE) return(RCWRITEDATA);
	}
	
	/*
	** Write the materials
	*/
	if(mesh->materials.firstNode!=NULL) {
		if (FPuts(vrmlfile,"   Material {\n")!=DOSFALSE) return(RCWRITEDATA);
		  
		/* The ambient color */
		mat=mesh->materials.firstNode;
		if (FPuts(vrmlfile,"      ambientColor [\n")!=DOSFALSE) return(RCWRITEDATA);
		do {
			TOCLColor col=mat->ambientColor;
			r=col.r,g=col.g,b=col.b;
			sprintf(buffer,"         %g %g %g,\n",r/255,g/255,b/255);
			if (FPuts(vrmlfile,buffer)!=DOSFALSE) return(RCWRITEDATA);
			mat=mat->next;
		} while(mat!=NULL);
		if (FPuts(vrmlfile,"      ]\n")!=DOSFALSE) return(RCWRITEDATA);

		/* The diffuse color */
		mat=mesh->materials.firstNode;
		if (FPuts(vrmlfile,"      diffuseColor [\n")!=DOSFALSE) return(RCWRITEDATA);
		do {
			TOCLColor col=mat->diffuseColor;
			r=col.r,g=col.g,b=col.b;
			sprintf(buffer,"         %g %g %g,\n",r/255,g/255,b/255);
			if (FPuts(vrmlfile,buffer)!=DOSFALSE) return(RCWRITEDATA);
			mat=mat->next;
		} while(mat!=NULL);
		if (FPuts(vrmlfile,"      ]\n")!=DOSFALSE) return(RCWRITEDATA);
				
		/* The specular color */
		mat=mesh->materials.firstNode;
		if (FPuts(vrmlfile,"      specularColor [\n")!=DOSFALSE) return(RCWRITEDATA);
		do {
			if (FPuts(vrmlfile,"         0. 0. 0.,\n")!=DOSFALSE) return(RCWRITEDATA);
					  
			mat=mat->next;
		} while(mat!=NULL);
		if (FPuts(vrmlfile,"      ]\n")!=DOSFALSE) return(RCWRITEDATA);
		
		/* The emissive color */
		mat=mesh->materials.firstNode;
		if (FPuts(vrmlfile,"      emissiveColor [\n")!=DOSFALSE) return(RCWRITEDATA);
		do {
			if (FPuts(vrmlfile,"         0. 0. 0.,\n")!=DOSFALSE) return(RCWRITEDATA);
		  
			mat=mat->next;
		} while(mat!=NULL);
		if (FPuts(vrmlfile,"      ]\n")!=DOSFALSE) return(RCWRITEDATA);
		
		/* The shininess */
		mat=mesh->materials.firstNode;
		if (FPuts(vrmlfile,"      shininess [\n")!=DOSFALSE) return(RCWRITEDATA);
		do {
			sprintf(buffer,"         %g,\n",mat->shininess);
			if (FPuts(vrmlfile,buffer)!=DOSFALSE) return(RCWRITEDATA);
			mat=mat->next;
		} while(mat!=NULL);
		if (FPuts(vrmlfile,"      ]\n")!=DOSFALSE) return(RCWRITEDATA);

		/* The transparency */
		mat=mesh->materials.firstNode;
		if (FPuts(vrmlfile,"      transparency [\n")!=DOSFALSE) return(RCWRITEDATA);
		do {
			sprintf(buffer,"         %g,\n",mat->transparency);
			if (FPuts(vrmlfile,buffer)!=DOSFALSE) return(RCWRITEDATA);
		  
			mat=mat->next;
		} while(mat!=NULL);
		if (FPuts(vrmlfile,"      ]\n")!=DOSFALSE) return(RCWRITEDATA);

		/*
		** End of material node
		*/			
		if (FPuts(vrmlfile,"   }\n")!=DOSFALSE) return(RCWRITEDATA);

		/*
		** Set the material binding
		*/
		if (FPuts(vrmlfile,"   MaterialBinding {\n      value PER_FACE_INDEXED\n   }\n")!=DOSFALSE) return(RCWRITEDATA);
	}
	
	/*
	** Write the polygons
	*/
  	if(mesh->polygons.firstNode!=NULL) {             
  	  	pln=mesh->polygons.firstNode;
		if (FPuts(vrmlfile,"   IndexedFaceSet {\n      coordIndex [\n")!=DOSFALSE) return(RCWRITEDATA);
		do {				
			if(pln->firstNode!=NULL) {  
				plv=pln->firstNode;
				if (FPuts(vrmlfile,"         ")!=DOSFALSE) return(RCWRITEDATA);
				do {
					if (FPrintf(vrmlfile,"%ld,",plv->vertexNode->index-1)==ENDSTREAMCH) return(RCWRITEDATA);

					plv=plv->next;
				} while(plv!=NULL);
				if (FPuts(vrmlfile,"-1,\n")!=DOSFALSE) return(RCWRITEDATA);
			}
			pln=pln->next;
		} while(pln!=NULL);
		if (FPuts(vrmlfile,"      ]\n")!=DOSFALSE) return(RCWRITEDATA);
		
		/*
		** Write the material index, if there are some
		** Default material is 0.
		*/
		if(mesh->materials.firstNode!=NULL) {
			UBYTE i=0;
			pln=mesh->polygons.firstNode;
			if (FPuts(vrmlfile,"     materialIndex [\n         ")!=DOSFALSE) return(RCWRITEDATA);
		  
			do {
				mat=pln->materialNode;
				
				if(mat!=NULL) {
					if (FPrintf(vrmlfile,"%ld,",mat->index-1)==ENDSTREAMCH) return(RCWRITEDATA);
				}
				else {
					if (FPuts(vrmlfile,"0,")!=DOSFALSE) return(RCWRITEDATA);
				}
		  
		  		if(++i==10) { 
					if (FPuts(vrmlfile,"\n         ")!=DOSFALSE) return(RCWRITEDATA);
					i=0;
				}
				pln=pln->next;
			} while(pln!=NULL);
		}
		if (FPuts(vrmlfile,"\n      ]\n")!=DOSFALSE) return(RCWRITEDATA);
	}
	
	/*
	** Write the end of the file
	*/
	if (FPuts(vrmlfile,"   }\n}\n")!=DOSFALSE) return(RCWRITEDATA);

	return(RCNOERROR);
}

/************************* End of file ******************************/
