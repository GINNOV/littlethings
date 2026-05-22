*******************************************************************************
******   CODED BY THE TROG IN JULY 1991 YET ANOTHER PIROSOFT UTILITY   ********
*****************************************************************************************
*INCLUDE FILES AND OPTIONS
***************************************************************************************
	OPT C-			      *NO CASESENSATIVE
	INCDIR	DF1:Trog/INCLUDE/	      *DIRECTORY TO LOOK FOR ANY EXTERNAL FILES
	INCLUDE LIBOFFSETS.I     *EQATES AND EXTERNAL REFERENCES
*************************************************************************************
*MAIN PROGRAME START
*********************************************************************************
MAINPRG:
	JSR	OPENLIBRARYS	* THE FOLLOWING SUBROUTINES
	JSR	ALLOCATEMEM	* OPEN VARIOUS LIBRARYS AND A SCREEN
	JSR	SETUPBITMAP     * WITH A WINDOW IN IT WITH A MENUATTACHED
	JSR	OPENNEWSCREEN	* COPY A PICTURE TO THE SCREEN
	JSR	COPYCOLORS	* COPY COLORS INTO BITMAP
	JSR	WINDOPEN	* AND ALSO RESERVE SOME MEMORY FOR A 	
	JSR	OPENMENU	* BUFFER AND OPEN THE TRACKDISK DEVICE
	

WAIT:	JSR	MENUTEST	* WAIT TO SEE WHICH MENU'S WERE CHOSEN IF ANY
	
	
TRACKE:	JSR	CLOSEMENU	* THEASE SUBROUTINES CLOSE DOWN THE
	JSR	WINDCLOSE	* MENU WINDOW SCREEN AND RETURN MEMORY
	JSR	CLOSENEWSCREEN	* BACK TO THE SYSTEM POOL AND ALSO
	JSR	DEALLOCATEMEM	* CLOSES THE LIBRARYS 
	JSR	CLOSELIBRARYS	* NOTE * CLOSE DOWN IN THE ORDER YOU
	RTS			* OPENEND STUFF ELSE PROBLEMS COULD OCCUR
*****************************************************************************
*MAIN PROGRAME FINISH FOLLOWING CODE SUBROTINES
*******************************************************************************

*****************************************************************************
*	
*		I have added the following lines to make
*		assembling the code easier, no longer a
*		need to use script files. MM.
*
*******************************************************************************

		incdir		source:trog/menuboot/

		include		libs.s
		include		screen.s
		include		window.s
		include		bmenu.s
		include		tmenu.s
		include		allmem.s
		include		about.s
		include		qreq.s
		include		wstring.s
		include		tdisk.s
		include		bmap.s
		include		wloader.s
		include		boot.s

