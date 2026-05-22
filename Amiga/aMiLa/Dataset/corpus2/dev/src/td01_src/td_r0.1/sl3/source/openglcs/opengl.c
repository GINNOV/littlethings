/*
**      $VER: opengl.c 1.00 (10.4.1999)
**
**      Creation date : 10.4.1999
**
**      Description       :
**         Standart saver module for meshwriter.library.
**         Saves the mesh as OpenGL C-source code.
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
* Name         : write3OPENGL                                        *
*                                                                    *
* Description  : Writes a standart OpenGL C-source code.             *
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
ULONG write3OPENGL(BPTR openglfile, TOCLMesh *mesh) {
	UBYTE 						buffer[200];
	TOCLVertexNode				*ver=NULL;
	TOCLMaterialNode			*mat=NULL;
	TOCLPolygonNode 			*pln=NULL;
	TOCLPolygonsVerticesNode	*plv=NULL;
	TOCLFloat					r,g,b;
			
	/*
	** Write the header, the copyright, default separator and info node
	*/
	if (FPuts(openglfile,"/*\n**\n** MeshWriter OpenGL C-source output\n**\n")!=DOSFALSE) return(RCWRITEDATA);
	if (mesh->name) {
		if (FPrintf(openglfile,"** Mesh      : %s\n**\n",mesh->name)==ENDSTREAMCH) return(RCWRITEDATA);	  
	}
	if (mesh->copyright) {
		if (FPrintf(openglfile,"** Copyright : %s\n**\n",mesh->copyright)==ENDSTREAMCH) return(RCWRITEDATA);	  
	}
	if (FPrintf(openglfile,"**\n*/\n\n")==ENDSTREAMCH) return(RCWRITEDATA);

	/*
	** Function header
	*/
	if (FPuts(openglfile,"static void mesh () {\n")!=DOSFALSE) return(RCWRITEDATA);	

	/*
	** Write the light and camera position
	*/
	sprintf(buffer,"  static GLfloat lp[4] = {%g,%g,%g,0.0};\n",mesh->light.position.x,mesh->light.position.z,mesh->light.position.y);
	if (FPuts(openglfile,buffer)!=DOSFALSE) return(RCWRITEDATA);

	/*
	** Write the material array
	*/
	if(mesh->materials.firstNode!=NULL) {
		  
		mat=mesh->materials.firstNode;
		if (FPuts(openglfile,"  static GLfloat m[] = {\n")!=DOSFALSE) return(RCWRITEDATA);
		do {
			TOCLColor col=mat->diffuseColor;
			r=col.r,g=col.g,b=col.b;
			sprintf(buffer,"    %g,%g,%g,1.0,\n",r/255,g/255,b/255);
			if (FPuts(openglfile,buffer)!=DOSFALSE) return(RCWRITEDATA);
			mat=mat->next;
		} while(mat!=NULL);
		if (FPuts(openglfile,"  };\n\n")!=DOSFALSE) return(RCWRITEDATA);				
	}

	/*
	** Write the vertice array
	*/              
	if(mesh->vertices.firstNode!=NULL) {
		ver=mesh->vertices.firstNode;
		if (FPuts(openglfile,"  static GLfloat v[] = {\n")!=DOSFALSE) return(RCWRITEDATA);
		do {
			TOCLVertex v=ver->vertex;
			sprintf(buffer,"    %g,%g,%g,\n",v.x,v.y,v.z);
			if(FPuts(openglfile,buffer)!=DOSFALSE) return(RCWRITEDATA);
			ver=ver->next;
		} while(ver!=NULL);
		if (FPuts(openglfile,"  };\n\n")!=DOSFALSE) return(RCWRITEDATA);
	}

//!!!!!!!!!!!
	/*
	** Write the light source
	*/
	r=mesh->light.color.r;
	g=mesh->light.color.g;
	b=mesh->light.color.b;
	r/=255,g/=255,b/=255;
	sprintf(buffer,"  glLightfv(GL_LIGHT0,GL_POSITION,lp);\n",
			r,g,b,mesh->light.position.x,mesh->light.position.y,mesh->light.position.z);
	if(FPuts(openglfile,buffer)!=DOSFALSE) return(RCWRITEDATA);



	/*
	** Write the polygons with theyr material binding
	*/
  	if(mesh->polygons.firstNode!=NULL) {             
  	  	pln=mesh->polygons.firstNode;
		do {				
			if(pln->firstNode!=NULL) {  

				if (pln->materialNode!=NULL) {
					if (FPrintf(openglfile,"  glMaterialfv(GL_FRONT,GL_AMBIENT_AND_DIFFUSE,&m[%ld]);\n",4*(pln->materialNode->index-1))==ENDSTREAMCH) return(RCWRITEDATA);
				}

				if (FPuts(openglfile,"  glBegin(GL_POLYGON);\n")!=DOSFALSE) return(RCWRITEDATA);
				plv=pln->firstNode;
				do {
					if (FPrintf(openglfile,"    glVertex3fv(&v[%ld]);\n",3*(plv->vertexNode->index-1))==ENDSTREAMCH) return(RCWRITEDATA);

					plv=plv->next;
				} while(plv!=NULL);
				if (FPuts(openglfile,"  glEnd();\n\n")!=DOSFALSE) return(RCWRITEDATA);
			}
			pln=pln->next;
		} while(pln!=NULL);
	}
	
	/*
	** Write the shae model and end of function and file
	*/
	if (FPuts(openglfile,"  glShadeModel(GL_SMOOTH);\n}\n")!=DOSFALSE) return(RCWRITEDATA);

	return(RCNOERROR);
}

/************************* End of file ******************************/
