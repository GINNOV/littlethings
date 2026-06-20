	IFND	ASX_I
ASX_I	SET	1

**
**	$VER: asx.i 1.12 (10.08.93) $
**
**	$Filename: asx.i $
**	$Author:   Daniel Weber $
**	$Release:  1.12 $
**	$Date:     93/08/10  17:16:00 $
**
**	Definition of ASX/ProAsm Interface
**
**	Copyright © 1993-1996 Daniel Weber
**	All Rights Reserved
**

*
* ASX Interface structure
*
		RSRESET
ax_ID		RS.L	1	; Magic... (Pro68Magic)
ax_ArgStr	RS.L	1	; command line string
ax_ArgLen	RS.L	1	; length of command line given in ax_ArgStr
ax_Source	RS.L	1	;+pointer of source code
ax_Residents	RS.L	1	; pointer to residents
ax_IncDir	RS.L	1	; pointer to Incdir list
ax_StdOut	RS.L	1	;+standard output
ax_StdIn	RS.L	1	; standard input (*currently not used*)
ax_ErrAddRoutine RS.L	1	; pointer to error text handler
ax_ErrorList	RS.L	1	; *PRIVAT* (pointer to error list)

ax_Errors	RS.L	1	;\  #of errors occured       (return value)
ax_Warnings	RS.L	1	; | #of warnings occured     (return value)
ax_Optims	RS.L	1	; | #of optimizations        (return value)
ax_OptimBytes	RS.L	1	; | #of bytes saved          (return value)
ax_Objectsize	RS.L	1	; | objectcode size          (return value)
ax_Workspace	RS.L	1	;/  #of bytes workspace used (return value)

ax_Symbols	RS.L	1	; pointer to symbol structure
ax_ErrFile	RS.L	1	; pointer to error file name
ax_HeaderFile	RS.L	1	; pointer to header file name
ax_ConfigFile	RS.L	1	; pointer to config file name

ax_privat01	RS.L	1	; MUST BE SET TO ZERO (PRIVAT)
ax_privat02	RS.L	1	; MUST BE SET TO ZERO (PRIVAT)
ax_SIZEOF	RSVAL


* Miscellaneous

Pro68Magic	EQU	"P_68"

axi_OKER	EQU	-4		; offset to 'OKER' string
axi_OKERname	EQUR	'ERR!'

axi_filenamelen	EQU	160		; max length of pathes and filenames


	ENDC
 END

