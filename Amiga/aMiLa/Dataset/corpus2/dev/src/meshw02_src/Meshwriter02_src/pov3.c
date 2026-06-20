/*
**      $VER: pov3.c 1.00 (27.03.1999)
**
**      Creation date : 29.11.1998
**
**      Description       :
**         Standart saver module for meshwriter.library.
**         Saves the mesh as POV3 ascii file.
**         POV z = Mesh y and POV y = Mesh z
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
* Name         : write3POV3                                          *
*                                                                    *
* Description  : Writes a standart POV3 ascii file.                  *
*                                                                    *
* Arguments    : povfile IN : An already opened file stream.         *
*                mesh    IN : Pointer to the mesh.                   *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      : No default material !                               *
*                                                                    *
\********************************************************************/
ULONG write3POV3(BPTR povfile, TOCLMesh *mesh) {
	UBYTE 						buffer[200];
	TOCLMaterialNode			*mat=NULL;
	TOCLPolygonNode			*pln=NULL;	
	TOCLPolygonsVerticesNode	*plvi=NULL,*plv1=NULL,*plv2=NULL,*plv3=NULL;
	TOCLVertex					ver1,ver2,ver3;
	TOCLFloat					r,g,b;


	/*
	** Write the header, default separator and info node
	*/
	if (FPrintf(povfile,"/*\n** POV3-Scenefile.\n** Object name : %s\n",mesh->name)==ENDSTREAMCH) return(RCWRITEDATA);
	if (mesh->copyright) {
		if (FPrintf(povfile,"**\n** %s\n",mesh->copyright)==ENDSTREAMCH) return(RCWRITEDATA);
	}
	
	if (FPuts(povfile,"*/\n\n#version 3.0\n\n")!=DOSFALSE) return(RCWRITEDATA);

	/*
	** Write the materials
	*/
	if(mesh->materials.firstNode!=NULL) {
		/* Declare each material as texture */
		mat=mesh->materials.firstNode;
		do {	  
			TOCLColor col=mat->diffuseColor;
			TOCLFloat r=col.r,g=col.g,b=col.b;
			
			if (FPrintf(povfile,"#declare %s = texture {",mat->name)==ENDSTREAMCH) return(RCWRITEDATA);

			sprintf(buffer,"\n pigment {\n  color rgb <%g, %g, %g>\n  filter %g\n }\n",r/255,g/255,b/255,mat->transparency);
			if (FPuts(povfile,buffer)!=DOSFALSE) return(RCWRITEDATA);

			sprintf(buffer," finish {\n  brilliance %g\n",mat->shininess);
			if (FPuts(povfile,buffer)!=DOSFALSE) return(RCWRITEDATA);

			if(mat->transparency>0.0) {
				if (FPuts(povfile,"  refraction 1\n }\n}\n")!=DOSFALSE) return(RCWRITEDATA);
			}
			else {
			  if (FPuts(povfile,"  refraction 0\n }\n}\n")!=DOSFALSE) return(RCWRITEDATA);
			}
			
			mat=mat->next;
		} while(mat!=NULL);
	}

	/*
	** Write the camera
	*/
	sprintf(buffer,"\ncamera {\n location  <%g, %g, %g>\n look_at <%g, %g, %g>\n}\n",
			mesh->camera.position.x,mesh->camera.position.y,mesh->camera.position.z,
			mesh->camera.lookat.x,mesh->camera.lookat.y,mesh->camera.lookat.z);
	if (FPuts(povfile,buffer)!=DOSFALSE) return(RCWRITEDATA);

	/*
	** Write the lightsource
	*/
	r=mesh->light.color.r,g=mesh->light.color.g,b=mesh->light.color.b;	
	r/=255,g/=255,b/=255;	
	sprintf(buffer,"\nlight_source {\n <%g, %g, %g>\n color rgb <%g,%g,%g>\n}\n",
			mesh->light.position.x,mesh->light.position.y,mesh->light.position.z,
			r,g,b);
	if (FPuts(povfile,buffer)!=DOSFALSE) return(RCWRITEDATA);
	
	/*
	** Write the mesh
	** The polygons as triangles, must be convex polygons !
	*/	  		
	pln=mesh->polygons.firstNode;
	if (pln!=NULL) {
		if (FPuts(povfile,"\nmesh {\n")!=DOSFALSE) return(RCWRITEDATA);
	
		do {
			/* Get the first point of the polygon, used to create all triangles with it */
			if(pln->numberOfVertices>=3) {
				plv1=pln->firstNode;
				ver1=plv1->vertexNode->vertex;
			
				plvi=plv1;
				do {	
					plv2=plvi->next;
					plv3=plv2->next;
				
					ver2=plv2->vertexNode->vertex;
					ver3=plv3->vertexNode->vertex;
				
					sprintf(buffer," triangle {\n  <%g, %g, %g>, <%g, %g, %g>, <%g, %g, %g>\n",ver1.x,ver1.z,ver1.y,
					ver2.x,ver2.z,ver2.y,ver3.x,ver3.z,ver3.y);
					if(FPuts(povfile,buffer)!=DOSFALSE) return(RCWRITEDATA);
				
					if(pln->materialNode!=NULL) {
						if (FPrintf(povfile,"  texture {\n   %s\n  }\n",pln->materialNode->name)==ENDSTREAMCH) return(RCWRITEDATA);
					}
				
					if (FPuts(povfile," }\n")!=DOSFALSE) return(RCWRITEDATA);
					
					plvi=plvi->next;
				} while(plv3->next!=NULL);
			}
			pln=pln->next;
		} while(pln!=NULL);
		if (FPuts(povfile,"}\n")!=DOSFALSE) return(RCWRITEDATA);
	}

	return(RCNOERROR);
}

/************************* End of file ******************************/ 