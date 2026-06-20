;DOS macros ; Simon Knipe ; v1.0

;	WRITEDATA	Writes text to an open file
;	READDATA	Reads text from open file
;	QUICKREADDATA	reads text from open file, doesn`t save bytes read
;	SAVEPTRS	Saves params given by CLI
;	GETHANDLE	Get input and output handles of CLI
;	OPENFILE	Open a file or Con-window
;	SMARTOPENFILE	Open file, jump if error
;	CLOSEFILE	Close a file or Con-window
;	RUNPROG		Runs a normal program from within your own
;	ERASEFILE	Deletes a named file
;	RENAMEFILE	Renames a file
;	FILEEXIST	Tests to see if a file exists
;	LOCKFILE	Locks a file while in use by your program
;	UNLOCKFILE	Undoes above action
;	FILEEXAMINE	Used to get the FileInfoBlock
;	FINDFILESIZE	Get the file size from the FileInfoBlock

*************************************************************** DOS ***
;Purpose: writes text to an open file
;To call: WRITEDATA FileHandle,TextPointer,TextLength

WRITEDATA MACRO
		move.l		dosbase,a6
		move.l		\1,d1		get file handle
		move.l		\2,d2		get text pointer
		move.l		\3,d3		get text length
		jsr		write(a6)
		ENDM
;Note that FileHandle can also be a ConsoleWindowHandle,
;and you can output text to a CLI window using this macro.
*************************************************************** DOS ***
;Purpose: reads text from an open file
;To call: READDATA FileHandle,MemoryAddress,NumberOfBytes,RealBytes

READDATA MACRO
		move.l		dosbase,a6
		move.l		\1,d1		file handle
		move.l		\2,d2		memory pointer
		move.l		#\3,d3		no of bytes to read
		jsr		read(a6)
		move.l		d0,\4		save real no of bytes read
		ENDM
*************************************************************** DOS ***
;Purpose: reads text from open file, doesn`t save bytes read
;To call: QUICKREADDATA FileHandle,MemoryAddress,NumberOfBytes

QUICKREADDATA MACRO
		move.l		dosbase,a6
		move.l		\1,d1		file handle
		move.l		\2,d2		memory pointer
		move.l		\3,d3		no of bytes to read
		jsr		read(a6)
		ENDM
*************************************************************** DOS ***
;Purpose: saves params given by CLI
;To call: SAVEPTRS ParamaterPointer,ParamaterLength

SAVEPTRS MACRO
		move.l		a0,\1
		move.l		d0,\2
		ENDM
*************************************************************** DOS ***
;Purpose: Get input and output handles of CLI
;To call: GETHANDLE InputHandlePointer,OutputHandlePointer

GETHANDLE MACRO
		move.l		dosbase,a6
		jsr		input(a6)
		move.l		d0,\1		save input handle
		jsr		output(a6)
		move.l		d0,\2		save output handle
		ENDM
*************************************************************** DOS ***
;Purpose: Open a file or Con-window
;To call: OPENFILE Filename,FileHandle,Mode

OPENFILE MACRO
		move.l		dosbase,a6
		move.l		\1,d1		get filename
		move.l		#\3,d2		get mode
		jsr		open(a6)
		move.l		d0,\2		save file handle
		ENDM
;Note you can open Console Windows using this macro.
*************************************************************** DOS ***
;Purpose: Open file, jump if error
;To call: SMARTOPENFILE Filename,FileHandle,Mode,BranchIfError

SMARTOPENFILE MACRO
		move.l		dosbase,a6
		move.l		\1,d1		get filename
		move.l		#\3,d2		get mode
		jsr		open(a6)
		move.l		d0,\2		save file handle
		tst.l		d0		check if error
		beq		\4
		ENDM
;Note you can open Console Windows using this macro.
*************************************************************** DOS ***
;Purpose: Close a file or Con-window
;To call: CLOSEFILE FileHandle

CLOSEFILE MACRO
		move.l		dosbase,a6
		move.l		\1,d1		get file handle
		jsr		close(a6)
		ENDM
;Note you can close Console Windows using this macro.
*************************************************************** DOS ***
;Purpose: Runs a normal program from within your own
;To call: RUNPROG Program,InputFile,OutputFile

RUNPROG MACRO
		move.l		dosbase,a6
		move.l		#\1,d1		command to run
		move.l		\2,d2		input file pointer
		move.l		\3,d3		output file pointer
		jsr		execute(a6)
		ENDM
*************************************************************** DOS ***
;Purpose: Deletes a named file
;To call: ERASEFILE Filename

ERASEFILE MACRO
		move.l		dosbase,a6
		move.l		#\1,d1		get name
		jsr		deletefile(a6)
		ENDM
*************************************************************** DOS ***
;Purpose: Renames a file
;To call: RENAMEFILE OldFilename,NewFilename

RENAMEFILE MACRO
		move.l		dosbase,a6
		move.l		#\1,d1		old name
		move.l		#\2,d2		new name
		jsr		rename(a6)
		ENDM
*************************************************************** DOS ***
;Purpose: Tests to see if a file exists
;To call: FILEEXIST Filename

FILEEXIST MACRO
		move.l		dosbase,a6
		move.l		#\1,d1		get name
		move.l		#ACCESS_READ,d2		read mode
		moveq.l		#0,d0
		jsr		lock(a6)
		ENDM
;Note: if a file does not exist, d0 contains a null
*************************************************************** DOS ***
;Purpose: Locks a file while in use by your program
;To call: LOCKFILE Filename,LockType,LockHandle,ErrorJumpAdr

LOCKFILE MACRO
		move.l		\1,d1		filename
		move.l		#\2,d2		lock type
		move.l		dosbase,a6
		jsr		lock(a6)
		move.l		d0,\3		save lock handle
		beq		\4		not locked then jump
		ENDM
*************************************************************** DOS ***
;Purpose: Undoes above action
;To call: UNLOCKFILE LockHandle

UNLOCKFILE MACRO
		move.l		\1,d1		file lock
		move.l		dosbase,a6
		jsr		unlock(a6)
		ENDM
*************************************************************** DOS ***
;Purpose: Used to get the FileInfoBlock
;To call: FILEEXAMINE LockHandle,FileInfo

FILEEXAMINE MACRO
		move.l		\1,d1
		move.l		\2,d2
		move.l		dosbase,a6
		jsr		examine(a6)
		ENDM
*************************************************************** DOS ***
;Purpose: Get the file size from the FileInfoBlock
;To call: FINDFILESIZE FileHandle,LengthStorage

FINDFILESIZE MACRO
		move.l		\1,a0		handle
		move.l		fib_Size(a0),\2	get size
		ENDM

