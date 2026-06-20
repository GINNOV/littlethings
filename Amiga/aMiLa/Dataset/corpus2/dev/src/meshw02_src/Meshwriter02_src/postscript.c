/*
**      $VER: postscript.c 1.00 (07.03.1999)
**
**      Creation date : 23.01.1999
**
**      Description       :
**         Standart saver module for meshwriter.library.
**         Saves the mesh as PostScript file.
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
#include "utilities.h"

/**************************** Defines *******************************/

// The scale to size for EPS files.
#define Ci_EPSSCALETOSIZE 1000

/*********************** Type definitions ***************************/

typedef struct {
	FLOAT x,y;
} PSVector;

/********************** Private functions ***************************/

/********************************************************************\
*                                                                    *
* Name         : computebboxandscale                                 *
*                                                                    *
* Description  : Computes the PS bounding box and the scale factor.  *
*                                                                    *
* Arguments    : mesh         IN : The mesh to work with.            *
*                viewtype     IN : The type of view.                 *
*                scaletosize  IN : Scale ot size factor.             *
*                x,y,w,h     OUT : Bounding box coordinates.         *
*                scale       OUT : Scaling factor.                   *
*                                                                    *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static VOID computebboxandscale(TOCLMesh *mesh,ULONG viewtype,
						ULONG scaletosize,
						TOCLFloat *x,TOCLFloat *y, TOCLFloat *w,TOCLFloat *h,
						FLOAT *scale) {

	// calculate the PS bounding box
	switch(viewtype) {
		case TVWTOP :
		case TVWBOTTOM : {
			(*x)=mesh->bBox.left;
			(*y)=mesh->bBox.rear;
			(*w)=mesh->bBox.right-mesh->bBox.left;
			(*h)=mesh->bBox.front-mesh->bBox.rear;
			break;
		}

		case TVWLEFT :
		case TVWRIGHT : {
			(*x)=mesh->bBox.bottom;
			(*y)=mesh->bBox.rear;
			(*w)=mesh->bBox.top-mesh->bBox.bottom;
			(*h)=mesh->bBox.front-mesh->bBox.rear;
			break;
		}

		case TVWFRONT :
		case TVWBACK : {
			(*x)=mesh->bBox.left;
			(*y)=mesh->bBox.bottom;
			(*w)=mesh->bBox.right-mesh->bBox.left;
			(*h)=mesh->bBox.top-mesh->bBox.bottom;
			break;
		}

		case TVWPERSP : {
//urgl !? ;-)
// => projektion der bounding box auf die ebene => 2d bbox
			break;
		}
	}

	// calculating the scaling factor
	if(((*w)-(*x))>((*h)-(*y))) {
		(*scale) = scaletosize/((*w)-(*x));
	} else {
		(*scale) = scaletosize/((*h)-(*y));
	}

	// scaling the bounding box
	(*x)*=(*scale),(*y)*=(*scale),(*w)*=(*scale),(*h)*=(*scale);
}

/********************************************************************\
*                                                                    *
* Name         : writeepsheader                                      *
*                                                                    *
* Description  : Writes the Encapsulated PostScript header.          *
*                                                                    *
* Arguments    : psfile      IN : An already opened file stream.     *
*                mesh        IN : Pointer to the mesh.               *
*                x,y,h,w     IN : The PS bounding box.               *
*                drawmode    IN : Drawing mode.                      *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static ULONG writeepsheader(BPTR epsfile,TOCLMesh *mesh,TOCLFloat x,
					TOCLFloat y,TOCLFloat w,TOCLFloat h, ULONG drawmode) {

	UBYTE 	buffer[100];
	TOCLMaterialNode	*mat=NULL;
	TOCLFloat			r,g,b;

	if (FPuts(epsfile,"%!PS-Adobe-2.0 EPSF-1.2\n%%Creator: (MeshWriterLibrary)\n")!=DOSFALSE) return(RCWRITEDATA);

	if (FPrintf(epsfile,"%%%%For: (%s)\n%%%%Title: (%s)\n",
				mesh->copyright,mesh->name)==ENDSTREAMCH) return(RCWRITEDATA);

	sprintf(buffer,"%%%%BoundingBox: %g %g %g %g\n",x,y,w,h);

	if (FPuts(epsfile,buffer)!=DOSFALSE) return(RCWRITEDATA);

	if (FPuts(epsfile,"%%EndComments\n\n%%BeginProlog\n")!=DOSFALSE) return(RCWRITEDATA);

	// write the prolog in function of the drawing mode
	switch (drawmode) {
		case TDMPOINTS : {
			if (FPuts(epsfile,"/p {1 360 0 arcn closepath fill} bind def")!=DOSFALSE) return(RCWRITEDATA);
			break;
		}
		case TDMGRIDBW : {
			if (FPuts(epsfile,"/p {moveto lineto lineto closepath stroke} bind def")!=DOSFALSE) return(RCWRITEDATA);
			break;
		}
		case TDMGRIDCL : {
			if (FPuts(epsfile,"/p {moveto lineto lineto closepath gsave 0 setgray stroke grestore c exch get aload pop setrgbcolor} bind def\n")!=DOSFALSE) return(RCWRITEDATA);

			if(mesh->materials.firstNode!=NULL) {
				if (FPuts(epsfile,"/c [\n")!=DOSFALSE) return(RCWRITEDATA);
		  
				mat=mesh->materials.firstNode;
				do {
					TOCLColor col=mat->ambientColor;
					r=col.r,g=col.g,b=col.b;
					sprintf(buffer,"[%g %g %g]\n",r/255,g/255,b/255);
					if (FPuts(epsfile,buffer)!=DOSFALSE) return(RCWRITEDATA);
					mat=mat->next;
				} while(mat!=NULL);

				if (FPuts(epsfile,"] def\n")!=DOSFALSE) return(RCWRITEDATA);
			} else {
				if (FPuts(epsfile,"/c [[1 1 1]] def\n")!=DOSFALSE) return(RCWRITEDATA);
			}
			break;
		}
	}

	if (FPuts(epsfile,"\n%%EndProlog\n\n0 setgray 0 setlinecap 0.1 setlinewidth 2 setlinejoin [] 0 setdash newpath\n\n")!=DOSFALSE) return(RCWRITEDATA);

	return(RCNOERROR);
}

/********************************************************************\
*                                                                    *
* Name         : writeepsfooter                                      *
*                                                                    *
* Description  : Writes the Encapsulated PostScript footer.          *
*                                                                    *
* Arguments    : psfile      IN : An already opened file stream.     *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static ULONG writeepsfooter(BPTR epsfile) {

	if (FPuts(epsfile,"\nshowpage\n\n%%EOF\n")!=DOSFALSE) return(RCWRITEDATA);

	return(RCNOERROR);
}

/********************************************************************\
*                                                                    *
* Name         : writepsheader                                       *
*                                                                    *
* Description  : Writes the PostScript header.                       *
*                                                                    *
* Arguments    : psfile      IN : An already opened file stream.     *
*                mesh        IN : Pointer to the mesh.               *
*                orientation IN : True for landscape and False for   *
*                                 portrait.                          *
*                dx,dy       IN : Displacemen from the origin, for   *
*                                 a correct translation.             *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static ULONG writepsheader(BPTR psfile,TOCLMesh *mesh,BOOL orientation,
							FLOAT dx, FLOAT dy) {
	UBYTE buffer[50];
//
//
// Noch nicht gut so, machen dass ohne eps sondern direkt portrait und
// landscape output.
//
//


	if (FPuts(psfile,"%!PS-Adobe-2.0\n%%Creator: (MeshWriterLibrary)\n")!=DOSFALSE) return(RCWRITEDATA);

	if (FPrintf(psfile,"%%%%For: (%s)\n%%%%Title: (%s)\n%%%%EndComments\n\n",
				mesh->copyright,mesh->name)==ENDSTREAMCH) return(RCWRITEDATA);

	if (FPuts(psfile,"initclip clippath pathbbox /DupHeight exch def /DupWidth exch def pop pop\n")!=DOSFALSE) return(RCWRITEDATA);

	if (FPuts(psfile,"save mark\n")!=DOSFALSE) return(RCWRITEDATA);

	// translating to the middle of the display
	if (FPuts(psfile,"DupWidth 2 div DupHeight 2 div translate\n")!=DOSFALSE) return(RCWRITEDATA);

	// scaling according the scale to size factor
//	if (FPrintf(psfile,"DupWidth DupHeight lt {DupWidth %ld div dup scale}{DupHeight %ld div dup scale}ifelse\n",
//			Ci_SCALETOSIZE,Ci_SCALETOSIZE)==ENDSTREAMCH) return(RCWRITEDATA);

	// rotating according the orientation
	if(orientation==TRUE) {
		if (FPuts(psfile,"90 rotate\n")!=DOSFALSE) return(RCWRITEDATA);
	} else {
		if (FPuts(psfile,"0 rotate\n")!=DOSFALSE) return(RCWRITEDATA);
	}

	// translating the displacement of the EPS origin
	if(orientation==TRUE) {
		sprintf(buffer,"%g %g translate\n\n",dy,dx);
	} else {
		sprintf(buffer,"%g %g translate\n\n",dx,dy);
	}
	if (FPuts(psfile,buffer)!=DOSFALSE) return(RCWRITEDATA);

	return(RCNOERROR);
}

/********************************************************************\
*                                                                    *
* Name         : writepsfooter                                       *
*                                                                    *
* Description  : Writes the PostScript footer.                       *
*                                                                    *
* Arguments    : psfile      IN : An already opened file stream.     *
*                mesh        IN : Pointer to the mesh.               *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static ULONG writepsfooter(BPTR psfile) {

	if (FPuts(psfile,"\n\ncleartomark restore showpage\n%%EOF\n")!=DOSFALSE) return(RCWRITEDATA);

	return(RCNOERROR);
}


/********************************************************************\
*                                                                    *
* Name         : writepoints                                         *
*                                                                    *
* Description  : Writes all vertices of the mesh with the p macro in *
*                a specific view.                                    *
*                                                                    *
* Arguments    : psfile      IN : An already opened file stream.     *
*                mesh        IN : Pointer to the mesh.               *
*                viewtype    IN : Type of view.                      *
*                scale       IN : Scaling factor.                    *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static ULONG writepoints(BPTR psfile,TOCLMesh *mesh,ULONG viewtype,
							FLOAT scale) {

	UBYTE 					buffer[100];
	TOCLVertexNode			*ver=NULL;
	TOCLVertex 			v;
	TOCLFloat				x,y;

  	if(mesh->vertices.firstNode!=NULL) {
		ver=mesh->vertices.firstNode;
		do {
			v=ver->vertex;

			switch(viewtype) {
				case TVWTOP : {
					x=v.x*scale,y=v.y*scale;
					break;
				}
				case TVWBOTTOM : {
					x=v.x*scale,y=-v.y*scale;
					break;
				}
				case TVWLEFT : {
					x=v.y*scale,y=v.z*scale;
					break;
				}
				case TVWRIGHT : {
					x=v.y*scale,y=-v.z*scale;
					break;
				}
				case TVWFRONT : {
					x=v.x*scale,y=v.z*scale;
					break;
				}
				case TVWBACK : {
					x=v.x*scale,y=-v.z*scale;
					break;
				}
				case TVWPERSP : {
					//urgl !? ;-)
					break;
				}
			}

			sprintf(buffer,"%g %g p\n",x,y);
			if(FPuts(psfile,buffer)!=DOSFALSE) return(RCWRITEDATA);
			ver=ver->next;
		} while(ver!=NULL);
	}

	return(RCNOERROR);
}

/********************************************************************\
*                                                                    *
* Name         : writegrid                                           *
*                                                                    *
* Description  : Writes the mesh as grid with the p macro in a       *
*                specific view.                                      *
*                                                                    *
* Arguments    : psfile      IN : An already opened file stream.     *
*                mesh        IN : Pointer to the mesh.               *
*                viewtype    IN : Type of view.                      *
*                scale       IN : Scaling factor.                    *
*                colors      IN : True if with colors, else b/w.     *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static ULONG writegrid(BPTR psfile,TOCLMesh *mesh,ULONG viewtype,
							FLOAT scale, BOOL colors) {

	UBYTE 						buffer[200];
	TOCLPolygonNode			*pln=NULL;	
	TOCLPolygonsVerticesNode	*plvi=NULL,*plv1=NULL,*plv2=NULL,*plv3=NULL;
	TOCLVertex					ver1,ver2,ver3;
	TOCLFloat					x1,y1,x2,y2,x3,y3;


  	if(mesh->polygons.firstNode!=NULL) {             	
		pln=mesh->polygons.firstNode;
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

					switch(viewtype) {
						case TVWTOP : {
							x1=ver1.x*scale,y1=ver1.y*scale;
							x2=ver2.x*scale,y2=ver2.y*scale;
							x3=ver3.x*scale,y3=ver3.y*scale;
							break;
						}
						case TVWBOTTOM : {
							x1=ver1.x*scale,y1=-ver1.y*scale;
							x2=ver2.x*scale,y2=-ver2.y*scale;
							x3=ver3.x*scale,y3=-ver3.y*scale;
							break;
						}
						case TVWLEFT : {
							x1=ver1.y*scale,y1=ver1.z*scale;
							x2=ver2.y*scale,y2=ver2.z*scale;
							x3=ver3.y*scale,y3=ver3.z*scale;
							break;
						}
						case TVWRIGHT : {
							x1=ver1.y*scale,y1=-ver1.z*scale;
							x2=ver2.y*scale,y2=-ver2.z*scale;
							x3=ver3.y*scale,y3=-ver3.z*scale;
							break;
						}
						case TVWFRONT : {
							x1=ver1.x*scale,y1=ver1.z*scale;
							x2=ver2.x*scale,y2=ver2.z*scale;
							x3=ver3.x*scale,y3=ver3.z*scale;
							break;
						}
						case TVWBACK : {
							x1=ver1.x*scale,y1=-ver1.z*scale;
							x2=ver2.x*scale,y2=-ver2.z*scale;
							x3=ver3.x*scale,y3=-ver3.z*scale;
							break;
						}
						case TVWPERSP : {
							//urgl !? ;-)
							break;
						}
					}

					sprintf(buffer,"%g %g %g %g %g %g p\n",x1,y1,x2,y2,x3,y3);
					if(colors) {
						if(pln->materialNode->index) {
							sprintf(buffer,"%ld %g %g %g %g %g %g p\n",pln->materialNode->index-1,x1,y1,x2,y2,x3,y3);
						} else {
							sprintf(buffer,"0 %g %g %g %g %g %g p\n",x1,y1,x2,y2,x3,y3);
						}
					}
					if(FPuts(psfile,buffer)!=DOSFALSE) return(RCWRITEDATA);
				
					plvi=plvi->next;
				} while(plv3->next!=NULL);	
			}
		
			/* Get the next polygon */
			pln=pln->next;			
		} while(pln!=NULL);
	}

	return(RCNOERROR);
}

/********************************************************************\
*                                                                    *
* Name         : writepostscript                                     *
*                                                                    *
* Description  : Writes the mesh itself as PostScript ascii file.    *
*                                                                    *
* Arguments    : psfile   IN : An already opened file stream.        *
*                mesh     IN : Pointer to the mesh.                  *
*                viewtype IN : Type of view.                         *
*                drawmode IN : Drawing mode.                         *
*                scale    IN : Scaling factor.                       *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static writepostscript(BPTR psfile,TOCLMesh *mesh,
						ULONG viewtype,ULONG drawmode, FLOAT scale) {

	

/*
	switch (drawmode) {
		case TDMPOINTS : {
			retval=writepoints(psfile,mesh,viewtype,scale);
			if(retval!=RCNOERROR) return(retval);
			break;
		}
		case TDMGRIDBW : {
			retval=writegrid(psfile,mesh,viewtype,scale,FALSE);
			if(retval!=RCNOERROR) return(retval);
			break;
		}
		case TDMGRIDCL : {
			retval=writegrid(psfile,mesh,viewtype,scale,TRUE);
			if(retval!=RCNOERROR) return(retval);
			break;
		}
	}
*/
	return(RCNOERROR);
}

/********************** Public functions ****************************/

/********************************************************************\
*                                                                    *
* Name         : write2EPS                                           *
*                                                                    *
* Description  : Writes a standart Encapsulated PostScript ASCII     *
*                file.                                               *
*                                                                    *
* Arguments    : epsfile  IN : An already opened file stream.        *
*                mesh     IN : Pointer to the mesh.                  *
*                viewtype IN : Type of view.                         *
*                drawmode IN : Drawing mode.                         *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
ULONG write2EPS(BPTR epsfile,TOCLMesh *mesh,ULONG viewtype,ULONG drawmode) {

	ULONG				retval;
	TOCLFloat			x,y,w,h;
	FLOAT				scale;

	// get the bounding box and the scale factor
	computebboxandscale(mesh,viewtype,Ci_EPSSCALETOSIZE,&x,&y,&w,&h,&scale);

	retval=writeepsheader(epsfile,mesh,x,y,w,h,drawmode);
	if(retval!=RCNOERROR) return(retval);

	retval=writepostscript(epsfile,mesh,viewtype,drawmode,scale);
	if(retval!=RCNOERROR) return(retval);

	retval=writeepsfooter(epsfile);

	return(RCNOERROR);
}

/********************************************************************\
*                                                                    *
* Name         : write2PSP                                           *
*                                                                    *
* Description  : Writes a standart PostScript ASCII file, for a      *
*                portrait visualisation, A4 portrait for example.    *
*                But this one is independent of the page/display     *
*                size.                                               *
*                                                                    *
* Arguments    : psfile   IN : An already opened file stream.        *
*                mesh     IN : Pointer to the mesh.                  *
*                viewtype IN : Type of view.                         *
*                drawmode IN : Drawing mode.                         *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
ULONG write2PSP(BPTR psfile,TOCLMesh *mesh,ULONG viewtype,ULONG drawmode) {
//	ULONG		retval;
//	FLOAT		dx,dy;
//	TOCLFloat	x,y,w,h;
//	FLOAT		scale;

	// get the bounding box and the scale factor
//	computebboxandscale(mesh,viewtype,Ci_PSPSCALE&x,&y,&w,&h,&scale);

	// compute the translation displacements from the origin
/*	dx=x-w/2;
	dy=y-h/2;

	retval=writepsheader(psfile,mesh,FALSE,dx,dy);
	if(retval!=RCNOERROR) return(retval);

	retval=write2EPS(psfile,mesh,viewtype,drawmode);
	if(retval!=RCNOERROR) return(retval);

	retval=writepsfooter(psfile);
	if(retval!=RCNOERROR) return(retval);
*/
	return(RCNOERROR);
}

/********************************************************************\
*                                                                    *
* Name         : write2PSL                                           *
*                                                                    *
* Description  : Writes a standart PostScript ASCII file, for a      *
*                landscape visualisation, A4 landscape for example.  *
*                But this one is independent of the page/display     *
*                size.                                               *
*                                                                    *
* Arguments    : psfile   IN : An already opened file stream.        *
*                mesh     IN : Pointer to the mesh.                  *
*                viewtype IN : Type of view.                         *
*                drawmode IN : Drawing mode.                         *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
ULONG write2PSL(BPTR psfile,TOCLMesh *mesh,ULONG viewtype,ULONG drawmode) {
//	ULONG		retval;
//	FLOAT		dx,dy;
//	TOCLFloat	x,y,w,h;
//	FLOAT		scale;

	// get the bounding box and the scale factor
//	computebboxandscale(mesh,viewtype,&x,&y,&w,&h,&scale);

	// compute the translation displacements from the origin
/*	dx=x-w/2;
	dy=y-h/2;

	retval=writepsheader(psfile,mesh,TRUE,dx,dy);
	if(retval!=RCNOERROR) return(retval);

	retval=write2EPS(psfile,mesh,viewtype,drawmode);
	if(retval!=RCNOERROR) return(retval);

	retval=writepsfooter(psfile);
	if(retval!=RCNOERROR) return(retval);
*/
	return(RCNOERROR);
}

/************************* End of file ******************************/
