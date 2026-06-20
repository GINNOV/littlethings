/*
**      $VER: rawa.c 1.00 (15.05.1999)
**
**      Creation date : 15.05.1999
**
**      Description       :
**         Standart 3d extension module for tdo.library.
**         Loads and saves the mesh as RAW ASCII file.
**
**
**      Written by Stephan Bielmann
**
*/

/*************************** Includes *******************************/

/*
** Ansi C includes
*/
#include <string.h>

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
#include "tdo_public.h"
#include "compiler.h"
#include "tdo.h"

/**************************** Defines *******************************/

#define Ci_BUFFERS 100	// constant size of all used buffers in this mudule

/*********************** Type definitions ***************************/

typedef struct {
	TTDOFloat x1,y1,z1,x2,y2,z2,x3,y3,z3;
}RAWTriangle;

/*************************** Variables ******************************/

/********************** Private functions ***************************/

/********************** Public functions ****************************/

/****** geoa.library/tdo3XSave ******************************************
* 
*   NAME	
* 	tdo3XSave -- Saves the mesh as a 3D file.
*
*   SYNOPSIS
*	error = tdo3XSave( meshhandle,filename,screen)
*	                   D1         D2        A0
*
*	ULONG tdo3XSave
*	     ( ULONG,STRPTR,struct Screen " );
*
*   FUNCTION
*	The mesh will be saved in a 3 dimensional representation in the
*	filename, without existence checks.
*	The screen parameter is optional and only used if non-NULL, to
*	display a window with additional or special parameters needed to
*	save the mesh, or messages.
* 
*   INPUTS
* 	meshhandle    - A valid handle of a mesh.
*	filename      - Name of the file to create.
*	screen        - Pointer to the work screen.
*	
*   RESULT
* 	error - RCNOERROR      if all went well.
*	        RCNOTIMPL      if the function is not implemented.
*	        RCNOMEMORY     if there is not enough memory. 
*	        RCWRITEDATA    if an error occured while writing data, no more space.
*	        RCOVERFLOW     if the mesh is to extensive for this format.
*	        RCNOMATERIAL   if there are no materials, but they are expected.
*           RCNOPART       if there are no parts, but they are expected.
*	        RCNOPOLYGON    if there are no polygons, but they are expected.
*	        RCNOVERTEX     if there are no vertices, but they are expected.
*	        IoErr()        if possible you will get this.
*	        tdo errors     if a tdo call failed.
* 
*   EXAMPLE
*	error = tdo3XSave(meshhandle,"ram:test",NULL);
*
*   NOTES
*	By setting the meshhandle to 0 the function returns RCNOERROR if
*	it is implemented or RCNOTIMPL if not !
*
*   BUGS
* 
*   SEE ALSO
* 
******************************************************************************
*
*/
ULONG __saveds ASM tdo3XSave(register __d1 ULONG meshhandle,
							register __d2 STRPTR filename,
							register __a0 struct Screen *screen) {

	BPTR			rawfile=NULL;
	ULONG			mesh,nofv,nofpo,nofpa,i,j,n;
	TTDOVertexf	v1,v2,v3;
	RAWTriangle	tbuffer[Ci_BUFFERS]; // Ci_BUFFERS * sizeof(RAWTriangle)	triangle buffer
	ULONG			bufferstate;

	mesh=meshhandle;

	// we were asked for implementation
	if(mesh==0) {
		return(RCNOERROR);
	}

	// Ensure that no current polygon is set
	meshPartPolygonEnd(mesh);

	nofv=meshNofVerticesGet(mesh);
	nofpo=meshNofPolygonsGet(mesh);
	nofpa=meshNofPartsGet(mesh);

	// Check if there are some vertices
	if(nofv==0) {
		return(RCNOVERTEX);
	}

	// Check if there are some polygons
	if(nofpo==0) {
		return(RCNOPOLYGON);
	}

	// Check if there are some parts
	if(nofpa==0) {
		return(RCNOPART);
	}

	/* Open the file for output */
	if((rawfile=Open(filename,MODE_NEWFILE))==NULL) return(IoErr());

	/* Change the buffer size of the filehandle to 10k */
	if (SetVBuf(rawfile,NULL,BUF_FULL,10000)!=DOSFALSE) {
		Close(rawfile);
		return(RCNOMEMORY);
	}

	// Write the header
	if(FWrite(rawfile,"RAWB",4,1)!=1) {
		Close(rawfile);
		return(RCWRITEDATA);
	}

	bufferstate=0;

	// Get all parts and write down theyr polygons with material
	for(i=1;i<=nofpa;i++) {
		if((nofpo=meshPartNofPolygonsGet(mesh,i))>0) {
			for(j=1;j<=nofpo;j++) {
				meshPartPolygonCurrentSet(mesh,i,j);
				// we are saving triangles, so at least 3 vertices must be there

				if((nofv=meshNofVerticesGet(mesh))>2) {
					meshVertexGetfv(mesh,1,&v1);

					n=2;
					while(n<nofv) {

						meshVertexGetfv(mesh,n++,&v2);
						meshVertexGetfv(mesh,n,&v3);

						tbuffer[bufferstate].x1=v1.x;
						tbuffer[bufferstate].y1=v1.y;
						tbuffer[bufferstate].z1=v1.z;

						tbuffer[bufferstate].x2=v2.x;
						tbuffer[bufferstate].y2=v2.y;
						tbuffer[bufferstate].z2=v2.z;

						tbuffer[bufferstate].x3=v3.x;
						tbuffer[bufferstate].y3=v3.y;
						tbuffer[bufferstate].z3=v3.z;

						// check if the buffer is full and write and initialize it
						if (++bufferstate==Ci_BUFFERS) {
							if(FWrite(rawfile,&tbuffer,Ci_BUFFERS*sizeof(RAWTriangle),1)!=1) {
								Close(rawfile);
								return(RCWRITEDATA);
							}
							bufferstate=0;
						}
					}
				}
			}
		}
	}

	// check if the buffer has still some elements and write them
	if (bufferstate>0) {
		if(FWrite(rawfile,&tbuffer,bufferstate*sizeof(RAWTriangle),1)!=1) {
			Close(rawfile);
			return(RCWRITEDATA);
		}
		bufferstate=0;
	}

	// Close the file
	Close(rawfile);

	return(RCNOERROR);
}

/****** geoa.library/tdo3XLoad ******************************************
* 
*   NAME	
* 	tdo3XLoad -- Load a 3D file and creates a mesh.
*
*   SYNOPSIS
*	error = tdo3XLoad( meshhandle,filename,erroffset,screen)
*	                   D1         D2       D3         A0
*
*	ULONG tdo3XLoad
*	     ( ULONG,STRPTR,ULONG *,struct Screen " );
*
*   FUNCTION
*	A file which contains a 3 dimensional representation
*	will be examined for all known elements and converted into the
*	mesh.
*	The screen parameter is optional and only used if non-NULL, to
*	display a window with additional or special parameters needed to
*	save the mesh or messages.
*	If an error occurs, erroffset contains the file offset in lines for
*	ascii files and bytes for binary formats.
* 
*   INPUTS
* 	meshhandle    - A valid handle of a mesh.
*	filename      - Name of the file to load.
*	erroffset     - Offset where a read error occured.
*	screen        - Pointer to the work screen.
*	
*   RESULT
* 	error - RCNOERROR       if all went well.
*	        RCNOTIMPL       if the function is not implemented.
*	        RCNOMEMORY      if there is not enough memory. 
*	        RCUNKNOWNFORMAT if the file format is unknown.
*	        RCNOFILE        if the file is not found.
*	        RCREADDATA      if an error occured while reading data.
*	        RCNOMATERIAL    if there are no materials, but they are expected.
*           RCNOPART        if there are no parts, but they are expected.
*	        RCNOPOLYGON     if there are no polygons, but they are expected.
*	        RCNOVERTEX      if there are no vertices, but they are expected.
*	        IoErr()         if possible you will get this.
*	        tdo errors      if a tdo call failed.
* 
*   EXAMPLE
*	error = tdo3XLoad(meshhandle,"ram:test",NULL);
*
*   NOTES
*	By setting the meshhandle to 0 the function returns RCNOERROR if
*	it is implemented or RCNOTIMPL if not !
*
*   BUGS
* 
*   SEE ALSO
* 
******************************************************************************
*
*/
ULONG __saveds ASM tdo3XLoad(register __d1 ULONG meshhandle,
							register __d2 STRPTR filename,
							register __d3 ULONG *erroffset,
							register __a0 struct Screen *screen) {

	ULONG			mesh;
	BPTR			rawfile=NULL;
	UBYTE			header[5];
	TTDOFloat		af[9];
	TTDOColorub color;


	mesh=meshhandle;

	// we were asked for implementation
	if(mesh==0) {
		return(RCNOERROR);
	}

	// we have one white material and one part
	meshMaterialAdd(mesh);
	color.r=255,color.g=255,color.b=255;
	meshMaterialDiffuseColorSetubc(mesh,1,&color);
	meshPartAdd(mesh);
	meshPartMaterialSet(mesh,1,1);
	
	// check if all went well
	if(meshNofMaterialsGet(mesh)!=1 || meshNofPartsGet(mesh)!=1) {
		return(RCNOMEMORY);
	}

	/* Open the file for input */
	if((rawfile=Open(filename,MODE_OLDFILE))==NULL) return(RCNOFILE);

	// initializing the offset counter
	(*erroffset)=1;

	// Read the header
	if(FRead(rawfile,header,4,1)!=1) {
		Close(rawfile);
		return(RCREADDATA);
	}

	(*erroffset)+=4;

	if(strncmp(header,"RAWB",4)!=0) {
		Close(rawfile);
		return(RCUNKNOWNFORMAT);
	}

	// ensure no current polygon
	meshPartPolygonEnd(mesh);

	while(FRead(rawfile,af,sizeof(af),1)==1) {
		meshPartTriangleAdd9fa(mesh,1,af);
		(*erroffset)+=sizeof(af);
	}
	
	return(RCNOERROR);
}

/****** geoa.library/tdo3XCheckFile ******************************************
* 
*   NAME	
* 	tdo3XCheckFile -- Checks if the file is in the format we expected to load.
*
*   SYNOPSIS
*	error = tdo3XLoad( filename )
*	                   D1
*
*	ULONG tdo3XCheckFile
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
* 	error - RCNOERROR       if all went well.
*	        RCUNKNOWNFORMAT if the file format is unknown.
*	        RCNOFILE        if the file is not found.
*	        RCREADDATA      if an error occured while reading data.
*	        IoErr()         if possible you will get this.
* 
*   EXAMPLE
*	error = tdo3XCheckFile("ram:test");
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
ULONG __saveds ASM tdo3XCheckFile(register __d2 STRPTR filename) {

	BPTR	rawfile;
	UBYTE	header[5];

	/* Open the file for input */
	if((rawfile=Open(filename,MODE_OLDFILE))==NULL) return(RCNOFILE);

	// Read the header
	if(FRead(rawfile,header,4,1)!=1) {
		Close(rawfile);
		return(RCREADDATA);
	}

	Close(rawfile);

	if(strncmp(header,"RAWB",4)!=0) {
		return(RCUNKNOWNFORMAT);
	}

	return(RCNOERROR);
}

/****** geoa.library/tdo3XExt ******************************************
* 
*   NAME	
* 	tdo3XExt -- Returns the default extension of the file format.
*
*   SYNOPSIS
*	ext = tdo3XExt ( )
*
*	SRPTR tdo3XExt
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
*	ext = tdo3XExt();
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
STRPTR __saveds ASM tdo3XExt () {
	static STRPTR ext="raw";

	return(ext);
}

/****** geoa.library/tdo3XName ******************************************
* 
*   NAME	
* 	tdo3XName -- Returns the file format name string.
*
*   SYNOPSIS
*	name = tdo3XName ( )
*
*	SRPTR tdo3XName
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
*	name = tdo3XName();
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
STRPTR __saveds ASM tdo3XName () {
	static STRPTR name="TDO RAW binary";

	return(name);
}

/************************* End of file ******************************/
