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
#include "tdo_public.h"
#include "compiler.h"
#include "tdo.h"

/**************************** Defines *******************************/

/*********************** Type definitions ***************************/

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
	return(RCNOTIMPL);
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

	ULONG mesh;

	mesh=meshhandle;

	// we were asked for implementation
	if(mesh==0) {
		return(RCNOERROR);
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

	return(RCUNKNOWNFORMAT);
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
	static STRPTR ext="dm3";
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
	static STRPTR name="Dummy 3";

	return(name);
}

/************************* End of file ******************************/
