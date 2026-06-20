ùúùúÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ;File-Loader
;Revdate: 17.2.03
;Ostyl of Mankind!

	INCDIR	INCLUDES:
	INCLUDE	MISC/DEVPACMACROS.i
	INCLUDE	EXEC/EXECBASE.i
	INCLUDE	DOS/DOS.i
	INCLUDE	EXEC/MEMORY.i

	INCLUDE	MACROS/POWERPC.i

	XDEF	LoadFile
	XDEF	FileSave
	XDEF	FreeFile

	XREF	_DosBase
	XREF	_PowerPCBase	

	XREF	HappenMsg

;-------------------------------------
;-------------------------------------
;
LoadFile:
	Move.L	a0,FilenamePTR
	Move.L	d0,MemCondition

	Movem.L	d2-a6,-(sp)

	;---- Ouvre le fichier
 
	Move.L	_DosBase,a6
	Move.L	FilenamePTR(pc),d1
	Move.L	#MODE_OLDFILE,d2
	Jsr	_LVOOpen(a6)
	Move.L	d0,FileHandle
	Beq.W	LoadError

	Move.L	_DosBase,a6
	Move.L	FileHandle(pc),d1
	Move.L	#FileInfos,d2
	Jsr	_LVOExamineFH(a6)

	Lea	FileInfos(pc),a0
	Move.L	fib_Size(a0),d0
	Move.L	d0,FileLength
	Beq.W	LoadError

	;---- Reserve la memoire

	Move.L	_PowerPCBase,a6
	Move.L	FileLength(pc),d0
	Move.L	MemCondition(pc),d1
	Jsr	_LVOAllocVec32(a6)
	Move.L	d0,DestinationPTR
	Beq.B	MemError

	;---- Lecture du fichier

DosRead	Move.L	_DosBase,a6
	Move.L	FileHandle(pc),d1
	Move.L	DestinationPTR(pc),d2
	Move.L	FileLength(pc),d3
	Jsr	_LVORead(a6)

	Cmp.L	FileLength(pc),d0
	Bne.B	LoadError

	Move.L	_DosBase,a6
	Move.L	FileHandle(pc),d1
	Jsr	_LVOClose(a6)

	Movem.L	(sp)+,d2-a6		
	Move.L	DestinationPTR(pc),d0
	Move.L	FileLength(pc),d1
	Rts

	;----

LoadError:
	Lea	LoadErr(pc),a0
	Jsr	HappenMsg
	Movem.L	(sp)+,d2-a6
	Moveq	#0,d0
	Rts

MemError:
	Lea	MemErr(pc),a0
	Jsr	HappenMsg
	Movem.L	(sp)+,d2-a6
	Moveq	#0,d0
	Rts

;-------------------------------------
;-------------------------------------
;
FreeFile
	Tst.L	a1
	Beq.B	Leav
	Move.L	_PowerPCBase,a6
	Jsr	_LVOFreeVec32(a6)
Leav	Rts

;-------------------------------------
;-------------------------------------
;
FileSave
	Move.L	d0,FileLength
	Move.L	a0,FilenamePTR
	Move.L	a1,SaveBufferPTR

;- ouvre le fichier ----------------
 
	Move.L	_DosBase,a6
	Move.L	FilenamePTR(pc),d1
	Move.L	#MODE_NEWFILE,d2
	Jsr	_LVOOpen(a6)
	Move.L	d0,FileHandle
	Beq.W	SaveError

;- écriture dans le fichier

	Move.L	_DosBase,a6
	Move.L	FileHandle(pc),d1
	Move.L	SaveBufferPTR(pc),d2
	Move.L	FileLength(pc),d3
	Jsr	_LVOWrite(a6)

	Move.L	_DosBase,a6
	Move.L	FileHandle(pc),d1
	Jsr	_LVOClose(a6)
		
SaveError
	Rts

	;----

LoadErr		Dc.B	'File not found',0
MemErr		Dc.B	'No enought mem for loading',0

MemCondition	Ds.L	1

FilenamePTR	Ds.L	1
FileHandle	Ds.L	1
FileLength	Ds.L	1

AllocMemPPC_PP	Ds.B	PP_SIZE	
DestinationPTR	Ds.L	1
SaveBufferPTR	Ds.L	1

		CNOP	0,8

FileInfos	Ds.B	fib_SIZEOF
