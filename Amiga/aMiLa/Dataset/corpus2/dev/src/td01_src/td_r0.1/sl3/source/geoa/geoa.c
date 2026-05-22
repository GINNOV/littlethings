/*
**      $VER: geoa.c 1.00 (19.6.1999)
**
**      Creation date : 8.5.1999
**
**      Description       :
**         Standart 3d extension module for tdo.library.
**         Loads and saves the mesh as Videoscape ASCII file.
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
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/*
** Amiga includes
*/
#include <dos/dos.h>
#include <dos/stdio.h>

#include <clib/dos_protos.h>

/*
** Project includes
*/
#include "td_public.h"
#include "compiler.h"
#include "td.h"

/**************************** Defines *******************************/

/*
** Number of elements in the buffers
*/
#define Ci_MAXVERINPOLY 200	// maximum vertices in a polygon

/*********************** Type definitions ***************************/

/*
** Color structure
*/
struct TColor {
	UBYTE r,g,b;
};

/*************************** Variables ******************************/

/*
** Videoscape equivalent rgb colors.
*/
static const TColor colorTbl[] = {
{  0,  0,  0},{  0,  0,178},{  0,178,  0},{  0,178,178},{178,  0,  0},{255,127,255},
{204,153,102},{127,127,127},{  0,  0,  0},{102,102,255},{102,255,102},{  0,255,100},
{255,102,102},{255,204,255},{255,255,  0},{255,255,255}
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
* Description  : Converts a GEO color index into a RGB color.        *
*                                                                    *
* Arguments    : index : The color index.                            *
*                                                                    *
* Return Value : Vector its magnitude.                               *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static TColor index2Color(ULONG index)
{
	static TColor col;
	
	/*
	** Check range
	*/
	if (index >= 0 && index < sizeof(colorTbl)/sizeof(TColor)) {
		/*
		** return table entry
		*/
		col.r = colorTbl[index].r;
		col.g= colorTbl[index].g;
		col.b= colorTbl[index].b;

		return (col);
	}

	/*
	** Out-of-range color is white, like undefined.
	*/
	col.r = 255;
	col.g= 255;
	col.b= 255;
                
	return (col);
}

/********************************************************************\
*                                                                    *
* Name         : color2GEO                                           *
*                                                                    *
* Description  : Matches the nearest color available in the GEO      *
*                color palette.                                      *
*                                                                    *
* Arguments    : red,green,blue : Color values.                      *
*                                                                    *
* Return Value : GEO color index.                                    *
*                                                                    *
* Comment      :                                                     *
*                                                                    *
\********************************************************************/
static ULONG color2GEO (UBYTE red, UBYTE green, UBYTE blue)
{
	ULONG			i;
	ULONG			index = 1;
	TColor			current;
	LONG			best;
	LONG			difference;
  
	current = index2Color(index);
	best =  magnitude(current.r-red,current.g-green,current.b-blue);

	for (i = 0; i < sizeof(colorTbl)/sizeof(TColor); i++) {
		current = index2Color(i);
		difference = magnitude(current.r-red,current.g-green,current.b-blue);
		if (difference < best) {
			best = difference;
			index = i;
		}
	}

	return (index);
}

/********************** Public functions ****************************/

/****** geoa.library/td3XSave ******************************************
* 
*   NAME	
* 	td3XSave -- Saves the whole space or one to several
*	            components of it as a 3D file.
*
*   SYNOPSIS
*	error = td3XSave( spacehandle,filename,type,index,screen)
*	                  D1          D2       D3   D4     A0
*
*	TDerrors td3XSave
*	     ( ULONG,STRPTR,TDenum,ULONG,struct Screen " );
*
*   FUNCTION
*	The space will be saved in a 3 dimensional representation in the
*	filename, without existence checks.
*	By specifying type, you can save multiple components, all surfaces
*	for example, and by defining index, a single component. One
*	object for example.
*
*	The screen parameter is optional and this functions uses it
*	only if it is set non-NULL, to display a window with
*	additional or special parameters needed to save the file,
*	or for messages.
* 
*   INPUTS
* 	spacehandle   - A valid handle of a space.
*	filename      - Name of the file to create.
*	type          - Type of component to save.
*	index         - Index of the component.
*	screen        - Pointer to the work screen.
*	
*   RESULT
* 	error - ER_NOERROR      if all went well.
*	        ER_NOTYPE       if the type is not supported.
*	        ER_NOVERTEX     if there are no vertices
*	        ER_NOPOLYGON    if there are no polygons
*	        ER_NOMATGROUP   if there are no material groups
*	        ER_OVERFLOW     if the component is to big to save.
*	        ER_CREATEFILE   if the file can not be created.
*	        ER_WRITEDATA    if an error occured while writing data.



*	        NOTIMPL      if the function is not implemented.
*	        NOMEMORY     if there is not enough memory. 
*	        NOMATERIAL   if there are no materials, but they are expected.
*	        td errors    if a td call failed.


* 
*   EXAMPLE
*	error = td3XSave(spacehandle,"ram:test",TD_OBJECT,4,NULL);
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
TDerrors __saveds ASM td3XSave(register __d1 ULONG spacehandle,
								register __d2 STRPTR filename,
								register __d3 TDenum type,
								register __d4 ULONG index,
								register __a0 struct Screen *screen) {

	BPTR			geofile=NULL;
	ULONG			space,nofv,nofpo,nofmg,mat,i,j,n,vi;
	TDenum			rt;
	TDvectorf		vertex;
	UBYTE			color[3];
	UBYTE			buffer[150];


	space=spacehandle;

	// check the type for the type of output
	switch(type) {
		case TD_OBJECT :
		case TD_POLYMESH :
			tdTypeGet(space,TD_OBJECT,index,&rt);

			if(rt==TD_POLYMESH) {
				tdCurrent(space,TD_OBJECT,index);

				// Check if there are some vertices
				nofv=tdNofGet(space,TD_VERTEX);
				if(nofv==0) {
					return(ER_NOVERTEX);
				}
				// Maximum of 65536 vertices
				if(nofv>65536) {
					return(ER_OVERFLOW);
				}

				// Check if there are some polygons
				nofpo=tdNofGet(space,TD_POLYGON);
				if(nofpo==0) {
					return(ER_NOPOLYGON);
				}

				// Check if there are some matgroups.
				nofmg=tdNofGet(space,TD_MATGROUP);
				if(nofmg==0) {
					return(ER_NOMATGROUP);
				}

				/* Open the file for output */
				if((geofile=Open(filename,MODE_NEWFILE))==NULL) return(ER_CREATEFILE);
	
				/* Change the buffer size of the filehandle to 10k */
				if (SetVBuf(geofile,NULL,BUF_FULL,10000)!=DOSFALSE) {
					Close(geofile);
					return(ER_NOMEMORY);
				}

				// Write the header and the number of vertices
				if (FPrintf(geofile,"3DG1\n%ld\n",nofv)==ENDSTREAMCH) {
					Close(geofile);
					return(ER_WRITEDATA);
				}

				// Write the vertices              
				for(i=1;i<=nofv;i++) {
					tdVertexGetfv(space,i,&vertex);
					sprintf(buffer,"%0.4g %0.4g %0.4g\n",vertex.x,vertex.z,vertex.y);
					if(FPuts(geofile,buffer)!=DOSFALSE) {
						Close(geofile);
						return(ER_WRITEDATA);
					}
				}

				// Get all matgroups and write down theyr polygons with material
				for(i=1;i<=nofmg;i++) {
					tdCurrent(space,TD_MATGROUP,i);
					if((nofpo=tdNofGet(space,TD_POLYGON))>0) {
						for(j=1;j<=nofpo;j++) {
							tdCurrent(space,TD_POLYGON,j);
							if((nofv=tdNofGet(space,TD_VERTEX))>0) {
								// writing the number of vertices in this polygon
								if (FPrintf(geofile,"%ld ",nofv)==ENDSTREAMCH) {
									Close(geofile);
									return(ER_WRITEDATA);
								}
								for(n=nofv;n>0;n--) {
									// handle = index + 1
									tdVertexIndexGet(space,n,&vi);
									if (FPrintf(geofile,"%ld ",vi-1)==ENDSTREAMCH) {
										Close(geofile);
										return(ER_WRITEDATA);
									}
								}
								tdChildGetl(space,TD_MATERIAL,&mat);
								tdMaterialGetuba(space,TD_DIFFUSE,mat,color);
								// write the material index
								if (FPrintf(geofile,"%ld\n",color2GEO(color[0],color[1],color[2]))==ENDSTREAMCH) {
									Close(geofile);
									return(ER_WRITEDATA);
								}
							}
						}
					}
				}

				// Close the file
				Close(geofile);
			} else {
				return(ER_NOTYPE);
			}
            break;
		default :
			return(ER_NOTYPE);
	}

	return(ER_NOERROR);
}

/****** geoa.library/td3XLoad ******************************************
* 
*   NAME	
* 	td3XLoad -- Load the whole 3D file, or components out of
*	            it into a space.
*
*   SYNOPSIS
*	error = td3XLoad( spacehandle,filename,type,screen,erroffset)
*	                  D1          D2       D3    A0    D4
*
*	TDerrors td3XLoad
*	     ( ULONG,STRPTR,TDenum,struct Screen " ,ULONG *);
*
*   FUNCTION
*	A file which contains a 3 dimensional represantation will
*	be examined for known components and loaded into the
*	space.
*	By defining another type you can load single components
*	into the space, materials only, or similar.
*
*	The screen parameter is optional and this functions uses it
*	only if it is set non-NULL, to display a window with
*	additional or special parameters needed to save the file,
*	or for messages.
* 
*   INPUTS
* 	spacehandle   - A valid handle of a space.
*	filename      - Name of the file to load.
*	type          - Type of component to load.
*	screen        - Pointer to the work screen.
*	erroffset     - Offset where a read error occured.
*	
*   RESULT
* 	error - ER_NOERROR       if all went well.
*	        ER_NOFILE        if the file is not found.
*	        ER_READDATA      if an error occured while reading data.
*	        ER_NOMEMORY      if there is not enough memory. 
*	        ER_UNKNOWNFORMAT if the file format is unknown.
*	        ER_NOVERTEX      if there are no vertices.

*	        RCNOTIMPL       if the function is not implemented.
*	        RCNOMATERIAL    if there are no materials, but they are expected.
*           RCNOPART        if there are no parts, but they are expected.
*	        RCNOPOLYGON     if there are no polygons, but they are expected.
*	        tdo errors      if a tdo call failed.
* 
*   EXAMPLE
*	error = td3XLoad(spacehandle,"ram:test",TD_SPACE,NULL);
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
TDerrors __saveds ASM td3XLoad(register __d1 ULONG spacehandle,
								register __d2 STRPTR filename,
								register __d3 TDenum type,
								register __a0 struct Screen *screen,
								register __d4 ULONG *erroffset) {

	ULONG space;
	FILE *fp=NULL;
	char header[10];
	unsigned long vertices=0,polygons=0;
	long material=0,pt=0;
	unsigned long points[1000];
	long i,j,det;
	TDvectorf v;
	TColor color;
	UBYTE ca[3];


	space=spacehandle;

	// check the type for the type of output
	switch(type) {
		case TD_OBJECT :
		case TD_POLYMESH :
			fp=fopen(filename,"r");
			if(fp==NULL) {
				return(ER_NOFILE);
			}

			// initializing the line counter
			(*erroffset)=1;

			fscanf(fp,"%4s",header);
			if(strncmp(header,"3DG1",4)!=0) {
				fclose(fp);
				return(ER_UNKNOWNFORMAT);
			}
        
			(*erroffset)++;

			fscanf(fp,"%ld",&vertices);
			if(vertices==0) {
				fclose(fp);
				return(ER_NOVERTEX);
			}

			(*erroffset)++;
	
			// creating a new polymesh
			if(tdAdd(space,TD_POLYMESH)!=ER_NOERROR) {
				fclose(fp);
				return(ER_NOMEMORY);
			}
			tdCurrent(space,TD_OBJECT,tdNofGet(space,TD_OBJECT));

			// initialize the materials and parts
			for(i=0;i<16;i++) {
				if(tdAdd(space,TD_SURFACE)!=ER_NOERROR) {
					fclose(fp);
					return(ER_NOMEMORY);
				}

				color=colorTbl[i];
				ca[0]=color.r;ca[1]=color.g;ca[2]=color.b;
				tdMaterialSetuba(space,TD_DIFFUSE,j=tdNofGet(space,TD_MATERIAL),ca);

				tdCurrent(space,TD_MATERIAL,j);
				if(tdBegin(space,TD_MATGROUP)!=ER_NOERROR) {
					fclose(fp);
					return(ER_NOMEMORY);
				}
			}

			// ensure no currents
			tdEnd(space,TD_MATERIAL);
			tdEnd(space,TD_MATGROUP);

			for(i=0;i<vertices;i++,(*erroffset)++) {
				// GEO z equals to the libraries y
				if(fscanf(fp,"%f %f %f",&v.x,&v.z,&v.y)==EOF) {
					fclose(fp);
					return(ER_READDATA);
				}

				if(tdVertexAddfv(space,&v)!=ER_NOERROR) {
					fclose(fp);
					return(ER_NOMEMORY);
				}
			}

			// reseting detail polygon indicator and polygon count
			// to be able to catch empty lines.
			det=0;
			polygons=0;

			while(fscanf(fp,"%ld",&polygons)!=EOF) {
				// we limit us to Ci_MAXVERINPOLY points per polygon, and skip detail polygons
				if(polygons>0 && det==0) {
					for(i=0;i<polygons&&i<Ci_MAXVERINPOLY;i++) {
						if(fscanf(fp,"%ld",&(points[i]))==EOF) {
							fclose(fp);
							return(ER_READDATA);
						} else {
							if(points[i]>=vertices) {
								fclose(fp);
								return(ER_READDATA);
							}
						}
					}
				} else {
					// skip all detail polys
					det=polygons;
					for(j=0;j<det;j++) {
						if(fscanf(fp,"%ld",&polygons)!=EOF) {
							for(i=0;i<=polygons;i++) {
								if(fscanf(fp,"%ld",&pt)==EOF) {
									fclose(fp);
									return(ER_READDATA);
								}
							}
							polygons=0;
							(*erroffset)++;
						}
					}

					polygons=0;
					det=0;
					continue;
				}

				if(fscanf(fp,"%ld",&material)==EOF) {
					fclose(fp);
					return(ER_READDATA);
				} else {

					// we are using only 16 out of 256 colors.
					// and we skip detail polygons, color = minus
					if (material<0) {
						material*=-1;
						det=-1;
					}
					tdCurrent(space,TD_MATGROUP,(material%16)+1);
					if(tdBegin(space,TD_POLYGON)!=ER_NOERROR) {
						fclose(fp);
						return(ER_NOMEMORY);
					}
				}

				// remember, GEO is clockwise, the library counterclockwise
				for(i=polygons-1;i>=0;i--) {
					if(tdVertexAssign(space,points[i]+1)!=ER_NOERROR) {
						fclose(fp);
						return(ER_NOMEMORY);
					}
				}
				tdEnd(space,TD_POLYGON);

				(*erroffset)++;
				polygons=0;
			}

			fclose(fp);

			tdEnd(space,TD_OBJECT);
			
			break;
		default :
			return(ER_NOTYPE);
	}

	return(ER_NOERROR);
}

/****** geoa.library/td3XCheckFile ******************************************
* 
*   NAME	
* 	td3XCheckFile -- Checks if the file is in the format we expected to load.
*
*   SYNOPSIS
*	error = td3XLoad( filename )
*	                  D1
*
*	TDerrors td3XCheckFile
*	     ( STRPTR );
*
*   FUNCTION
*	The file its header will be examinated to verify if it is the
*	file format we expect to read with the load function.
* 
*   INPUTS
*	filename      - Name of the file to load.
*	
*   RESULT
* 	error - ER_NOERROR       if all went well.
*	        ER_UNKNOWNFORMAT if the file format is unknown.
*	        ER_NOFILE        if the file is not found.
*	        ER_READDATA      if an error occured while reading data.
* 
*   EXAMPLE
*	error = td3XCheckFile("ram:test");
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
TDerrors __saveds ASM td3XCheckFile(register __d2 STRPTR filename) {

	FILE *fp=NULL;
	char header[10];

	// open the file for input
	fp=fopen(filename,"r");
	if(fp==NULL) {
		return(ER_NOFILE);
	}

	// check the file type
	fscanf(fp,"%4s",header);
	fclose(fp);

	if(strncmp(header,"3DG1",4)!=0) {
		return(ER_UNKNOWNFORMAT);
	}

	return(ER_NOERROR);
}

/****** geoa.library/td3XExt ******************************************
* 
*   NAME	
* 	td3XExt -- Returns the default extension of the file format.
*
*   SYNOPSIS
*	ext = td3XExt ( )
*
*	STRPTR td3XExt
*	     ( );
*
*   FUNCTION
*	The default extension of the file format will be returned
*	as READ_ONLY, NULL terminated string which will be only valid
*	as long as the library is opened.
* 
*   INPUTS
*	
*   RESULT
* 	ext - String pointer to the extension, or NULL no default.
* 
*   EXAMPLE
*	ext = td3XExt();
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
STRPTR __saveds ASM td3XExt () {
	static STRPTR ext="geo";

	return(ext);
}

/****** geoa.library/td3XName ******************************************
* 
*   NAME	
* 	td3XName -- Returns the file format name string.
*
*   SYNOPSIS
*	name = td3XName ( )
*
*	SRPTR td3XName
*	     ( );
*
*   FUNCTION
*	The file format its name will be returned. This string should not 
*	be to large, about 20 characters maximum.
*	The string is READ_ONLY, NULL terminated and only valid as
*	long as the library is opened.
* 
*   INPUTS
*	
*   RESULT
* 	name - String pointer to the name, or NULL no one.
* 
*   EXAMPLE
*	name = td3XName();
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
STRPTR __saveds ASM td3XName () {
	static STRPTR name="Videoscape ASCII (TD)";

	return(name);
}

/****** geoa.library/td3XSaverSupports *************************************
* 
*   NAME	
* 	td3XSaverSupports -- This function has to indicate if the saver
*                        is supporting a type of save functionality
*                        or not.
*
*   SYNOPSIS
*	supported = td3XSaverSupports(type)
*	                              D1
*
*	ULONG td3XSaverSupports
*	     ( TDenum );
*
*   FUNCTION
*	The main library checks with this function, which types of
*	save possibilities can be made in this module.
* 
*   INPUTS
*	type          - Type of save functionality.
*	
*   RESULT
* 	supported - 0 if not and 1 if supported.
* 
*   EXAMPLE
*	supported = td3XSaverSupports(TD_OBJECT);
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
ULONG __saveds ASM td3XSaverSupports(register __d1 TDenum type) {
	switch(type) {
		case TD_OBJECT:
		case TD_POLYMESH:
			return(1);

		default:
			return(0);
	}
}

/****** geoa.library/td3XLoaderSupports *************************************
* 
*   NAME	
* 	td3XLoaderSupports -- This function has to indicate if the loader
*                         is supporting a type of load functionality
*                         or not.
*
*   SYNOPSIS
*	supported = td3XloaderSupports(type)
*	                               D1
*
*	ULONG td3XLoaderSupports
*	     ( TDenum );
*
*   FUNCTION
*	The main library checks with this function, which types of
*	load possibilities can be made in this module.
* 
*   INPUTS
*	type          - Type of save functionality.
*	
*   RESULT
* 	supported - 0 if not and 1 if supported.
* 
*   EXAMPLE
*	supported = td3XLoaderSupports(TD_OBJECT);
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
ULONG __saveds ASM td3XLoaderSupports(register __d1 TDenum type) {
	switch(type) {
		case TD_OBJECT:
		case TD_POLYMESH:
			return(1);

		default:
			return(0);
	}
}

/************************* End of file ******************************/
