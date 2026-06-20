/*
**      $VER: postscript.c 1.00 (5.4.1999)
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

// Margin percent factor
#define Ci_MARGINPERFAC 0.025

// Extraspace to fit the object in the drawing box
#define Ci_EXTRASPACE 0.95

/*********************** Type definitions ***************************/

typedef struct {
	FLOAT x,y;
} PSVector;

/********************** Private functions ***************************/

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
*                xo,yo,yb    IN : Offsets and bottom of display.     *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static ULONG writepoints(BPTR psfile,TOCLMesh *mesh,ULONG viewtype,
							FLOAT scale,FLOAT xo,FLOAT yo,FLOAT yb) {

	UBYTE 					buffer[100];
	TOCLVertexNode			*ver=NULL;
	TOCLVertex 			v;
	TOCLFloat				x,y;

  	if(mesh->vertices.firstNode!=NULL) {
		ver=mesh->vertices.firstNode;
		do {
			v=ver->vertex;

			switch(viewtype) {
				case TVWTOP:
					x=xo+scale*(v.x-mesh->bBox.left);
					y=yo+scale*(v.y-mesh->bBox.rear);
					break;
				case TVWBOTTOM:
					x=xo+scale*(v.x-mesh->bBox.left);
					y=yo+scale*(-v.y+mesh->bBox.front);
					break;
				case TVWRIGHT:
					x=xo+scale*(v.y-mesh->bBox.rear);
					y=yo+scale*(v.z-mesh->bBox.bottom);
					break;
				case TVWLEFT:
					x=xo+scale*(-v.y+mesh->bBox.front);
					y=yo+scale*(v.z-mesh->bBox.bottom);
					break;
				case TVWFRONT:
					x=xo+scale*(v.x-mesh->bBox.left);
					y=yo+scale*(v.z-mesh->bBox.bottom);
					break;
				case TVWREAR:
					x=xo+scale*(-v.x+mesh->bBox.right);
					y=yo+scale*(v.z-mesh->bBox.bottom);
					break;
				case TVWPERSP:
					break;
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
* Name         : writeview                                           *
*                                                                    *
* Description  : Writes a specific view of the mesh.                 *
*                                                                    *
* Arguments    : epsfile     IN : An already opened file stream.     *
*                mesh        IN : Pointer to the mesh.               *
*                viewtype    IN : Type of view.                      *
*                drawmode    IN : Drawing mode.                      *
*                xsize,ysize IN : Size of the box to draw.           *
*
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static ULONG writeview(BPTR epsfile,TOCLMesh *mesh,ULONG viewtype,
                       ULONG drawmode,FLOAT xsize,FLOAT ysize) {
	UBYTE 	buffer[80];
	FLOAT	scale,xratio,yratio,zratio,xoffset,yoffset,ybottom;
	ULONG					retval;

	// with the bbox compute the scaling factor and he offsets
	if(mesh->bBox.right-mesh->bBox.left>0.0) {
		xratio=1.0/(mesh->bBox.right-mesh->bBox.left)
	} else {
		xratio=1.0;
	}
	if(mesh->bBox.front-mesh->bBox.rear>0.0) {
		yratio=1.0/(mesh->bBox.front-mesh->bBox.rear)
	} else {
		yratio=1.0;
	}
	if(mesh->bBox.top-mesh->bBox.bottom>0.0) {
		zratio=1.0/(mesh->bBox.top-mesh->bBox.bottom)
	} else {
		zratio=1.0;
	}
	scale=(ysize*yratio<xsize*yratio?ysize*yratio:xsize*yratio);
	scale=(scale<ysize*zratio?scale:ysize*zratio);
	scale=(scale<xsize*xratio?scale:xsize*xratio);
	// expand it a little
	scale*=Ci_EXTRASPACE;

	switch(viewtype) {
		case TVWTOP:
		case TVWBOTTOM:
			xoffset=(xsize-scale/xratio)/2.0;
			yoffset=(ysize-scale/yratio)/2.0;
			break;
		case TVWFRONT:
		case TVWREAR:
			xoffset=(xsize-scale/xratio)/2.0;
			yoffset=(ysize-scale/zratio)/2.0;			
			break;
		case TVWRIGHT:
		case TVWLEFT:
			xoffset=(xsize-scale/yratio)/2.0;
			yoffset=(ysize-scale/zratio)/2.0;			
			break;
		case TVWPERSP:

			break;
	}

	// draw a box around this view
	sprintf(buffer,"0 0 m %g 0 r 0 %g r %g 0 r cp s\n",xsize,ysize,-xsize);
	if (FPuts(epsfile,buffer)!=DOSFALSE) return(RCWRITEDATA);

	retval=RCNOERROR;

	switch(drawmode) {
		case TDMPOINTS:
			retval=writepoints(epsfile,mesh,viewtype,scale,xoffset,yoffset,ybottom);
			break;

		case TDMWIREBW:
		case TDMWIREGR:
		case TDMWIRECL:
			//writewire;
			break;
/*
case TDMHIDDBW
case TDMHIDDGR
case TDMHIDDCL

case TDMSURFBW
case TDMSURFGR
case TDMSURFCL
*/
	}

	return(retval);
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

	// write the static prolog
	if (FPuts(epsfile,"/bd {bind def} bind def\n")!=DOSFALSE) return(RCWRITEDATA);
	if (FPuts(epsfile,"/m {moveto} bd\n")!=DOSFALSE) return(RCWRITEDATA);
	if (FPuts(epsfile,"/l {lineto} bd\n")!=DOSFALSE) return(RCWRITEDATA);
	if (FPuts(epsfile,"/r {rlineto} bd\n")!=DOSFALSE) return(RCWRITEDATA);
	if (FPuts(epsfile,"/cp {closepath} bd\n")!=DOSFALSE) return(RCWRITEDATA);
	if (FPuts(epsfile,"/s {stroke} bd\n")!=DOSFALSE) return(RCWRITEDATA);

	// write the dynamic prolog in function of the drawing mode
	switch (drawmode) {
		case TDMPOINTS : {
			if (FPuts(epsfile,"/p {1 360 0 arcn cp fill} bd\n")!=DOSFALSE) return(RCWRITEDATA);
			break;
		}
		case TDMWIREBW : {
			if (FPuts(epsfile,"/p {m l l cp s} bd\n")!=DOSFALSE) return(RCWRITEDATA);
			break;
		}
		case TDMWIRECL : {
			if (FPuts(epsfile,"/p {m l l cp gsave 0 setgray s grestore c exch get aload pop setrgbcolor} bd\n")!=DOSFALSE) return(RCWRITEDATA);

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

	if (FPuts(epsfile,"%%EndProlog\n\n0 setgray 0 setlinecap 0.1 setlinewidth 2 setlinejoin [] 0 setdash newpath\n\n")!=DOSFALSE) return(RCWRITEDATA);

	return(RCNOERROR);
}

/********************************************************************\
*                                                                    *
* Name         : writeepsbody                                        *
*                                                                    *
* Description  : Writes the body of the eps file.                    *
*                                                                    *
* Arguments    : epsfile  IN : An already opened file stream.        *
*                mesh     IN : Pointer to the mesh.                  *
*                viewtype IN : Type of view.                         *
*                drawmode IN : Drawing mode.                         *
*                x,y,w,h  IN : X/Y position and width/height of box. *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static writeepsbody(BPTR epsfile,TOCLMesh *mesh,
					ULONG viewtype,ULONG drawmode,
					FLOAT x,FLOAT y,FLOAT w,FLOAT h) {

	UBYTE 	buffer[50];
	FLOAT	tx,ty,w2,h2;
	ULONG	retval;

	if(viewtype==TVW4SIDES) {
		w2=w/2,h2=h/2;

		tx=x,ty=y;
		sprintf(buffer,"gsave %g %g translate\n",tx,ty);
		if (FPuts(epsfile,buffer)!=DOSFALSE) return(RCWRITEDATA);
		retval=writeview(epsfile,mesh,TVWFRONT,drawmode,w2,h2);
		if(retval!=RCNOERROR) return(retval);
		if (FPuts(epsfile,"grestore\n")!=DOSFALSE) return(RCWRITEDATA);
		tx=x,ty=y+h2;
		sprintf(buffer,"gsave %g %g translate\n",tx,ty);
		if (FPuts(epsfile,buffer)!=DOSFALSE) return(RCWRITEDATA);
		retval=writeview(epsfile,mesh,TVWTOP,drawmode,w2,h2);
		if(retval!=RCNOERROR) return(retval);
		if (FPuts(epsfile,"grestore\n")!=DOSFALSE) return(RCWRITEDATA);
		tx=x+w2,ty=y+h2;
		sprintf(buffer,"gsave %g %g translate\n",tx,ty);
		if (FPuts(epsfile,buffer)!=DOSFALSE) return(RCWRITEDATA);
		retval=writeview(epsfile,mesh,TVWPERSP,drawmode,w2,h2);
		if(retval!=RCNOERROR) return(retval);
		if (FPuts(epsfile,"grestore\n")!=DOSFALSE) return(RCWRITEDATA);
		tx=x+w2,ty=y;
		sprintf(buffer,"gsave %g %g translate\n",tx,ty);
		if (FPuts(epsfile,buffer)!=DOSFALSE) return(RCWRITEDATA);
		retval=writeview(epsfile,mesh,TVWRIGHT,drawmode,w2,h2);
		if(retval!=RCNOERROR) return(retval);
		if (FPuts(epsfile,"grestore\n")!=DOSFALSE) return(RCWRITEDATA);
	} else {
		tx=x,ty=y;
		sprintf(buffer,"gsave %g %g translate\n",tx,ty);
		if (FPuts(epsfile,buffer)!=DOSFALSE) return(RCWRITEDATA);
		retval=writeview(epsfile,mesh,viewtype,drawmode,w,h);
		if(retval!=RCNOERROR) return(retval);
		if (FPuts(epsfile,"grestore\n")!=DOSFALSE) return(RCWRITEDATA);		
	}

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
						case TVWREAR : {
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
*                width    IN : Width of output media.                *
*                height   IN : Height of output media.               *
*                                                                    *
* Return Value : RCNOERROR                                           *
*                RCWRITEDATA                                         *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
ULONG write2EPS(BPTR epsfile,TOCLMesh *mesh,
                ULONG viewtype,ULONG drawmode,
                ULONG width,ULONG height) {

	ULONG				retval;
	TOCLFloat			x,y,w,h;

	retval=writeepsheader(epsfile,mesh,0,0,width,height,drawmode);
	if(retval!=RCNOERROR) return(retval);

	// compute the drawing box of the postscript output
	x=width*Ci_MARGINPERFAC;
	w=width-2*x;
	y=height*Ci_MARGINPERFAC;
	h=height-2*y;

	retval=writeepsbody(epsfile,mesh,viewtype,drawmode,x,y,w,h);
	if(retval!=RCNOERROR) return(retval);

	retval=writeepsfooter(epsfile);

	return(RCNOERROR);
}

/************************* End of file ******************************/
