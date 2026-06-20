;DOS Macros; SK 14-16 Nov 1990 ; v1.0
;needs Mark`s libs.i file to work
***********************************************************************
;Macros are currently:
;	WRITEDATA	Writes text to an open file
;	READDATA	Reads text from an open file
;	SAVEPTRS	Saves params given by CLI
;	GETHANDLE	Get input and output handles of CLI
;	OPENFILE	Open a file or Con-window
;	CLOSEFILE	Close a file or Con-window
;	RUNPROG	Runs a normal program from within your own
;	ERASEFILE	Deletes a named file
;	RENAMEFILE	Renames a file
;	FILEEXIST	Tests to see if a file exists
*************************************************************** DOS ***
;To call: WRITEDATA FileHandle,TextPointer,TextLength

WRITEDATA MACRO
	move.l	dosbase,a6
	move.l	\1,d1	get file handle
	move.l	\2,d2	get text pointer
	move.l	\3,d3	get text length
	jsr	Write(a6)
	ENDM
;Note that FileHandle can also be a ConsoleWindowHandle,
;and you can output text to a CLI window using this macro.
*************************************************************** DOS ***
;To call: READDATA FileHandle,MemoryAddress,NumberOfBytes

READDATA MACRO
	move.l	dosbase,a6
	move.l	\1,d1	file handle
	move.l	\2,d2	memory pointer
	move.l	\3,d3	no of bytes to read
	jsr	Read(a6)
	move.l	d0,\3	save real no of bytes read
	ENDM
*************************************************************** DOS ***
;To call: SAVEPTRS ParamaterPointer,ParamaterLength

SAVEPTRS MACRO
	move.l	a0,\1
	move.l	d0,\2
	ENDM
*************************************************************** DOS ***
;To call: GETHANDLE InputHandlePointer,OutputHandlePointer

GETHANDLE MACRO
	move.l	dosbase,a6
	jsr	Input(a6)
	move.l	d0,\1	save input handle
	jsr	Output(a6)
	move.l	d0,\2	save output handle
	ENDM
*************************************************************** DOS ***
;To call: OPENFILE Filename,FileHandle,Mode

OPENFILE MACRO
	move.l	dosbase,a6
	move.l	#\1,d1	get filename
	move.l	#\3,d2	get mode
	jsr	Open(a6)
	move.l	d0,\2	save file handle
	ENDM
;Note you can open Console Windows using this macro.
*************************************************************** DOS ***
;To call: CLOSEFILE FileHandle

CLOSEFILE MACRO
	move.l	dosbase,a6
	move.l	\1,d1	get file handle
	jsr	Close(a6)
	ENDM
;Note you can close Console Windows using this macro.
*************************************************************** DOS ***
;To call: RUNPROG Program,InputFile,OutputFile

RUNPROG MACRO
	move.l	dosbase,a6
	move.l	#\1,d1	command to run
	move.l	\2,d2	input file pointer
	move.l	\3,d3	output file pointer
	jsr	Execute(a6)
	ENDM
*************************************************************** DOS ***
;To call: ERASEFILE Filename

ERASEFILE MACRO
	move.l	dosbase,a6
	move.l	#\1,d1	get name
	jsr	DeleteFile(a6)
	ENDM
*************************************************************** DOS ***
;To call: RENAMEFILE OldFilename,NewFilename

RENAMEFILE MACRO
	move.l	dosbase,a6
	move.l	#\1,d1	old name
	move.l	#\2,d2	new name
	jsr	Rename(a6)
	ENDM
*************************************************************** DOS ***
;To call: FILEEXIST Filename

FILEEXIST MACRO
	move.l	dosbase,a6
	move.l	#\1,d1	get name
	move.l	#-2,d2	read mode
	moveq.l	#0,d0
	jsr	Lock(a6)
	ENDM
;Note: if a file does not exist, d0 contains a null
***********************************************************************

