
; File i/o routines. Rely on dos.library functions. M.Meany, Sept 1992.

; dos.library must be open and base pointer stored at label _DOSBase. See
;HW_Start.i for particulars.

; Error handling is rather sketchy at this stage.

; error=LoadData( filename, buffer, size )	d0=0 if error occurs
;  d0                a0       a1     d0

; error=LoadFile( filename, mem_type )		d0=0 if error or size of
;  d0                a0        d0		     buffer.
;						a0->allocated buffer

; error=SaveData( filename, memory, size )	d0=0 if file not created
;   d0		     a0       a1     d0

		LIST
*** Disk.i v1.00, by M.Meany ***
		NOLIST

*****
*****	Load data from a file into a buffer
*****

; Entry		a0->filename
;		a1->buffer
;		d0=bytes to read

; Exit		d0=0 if an error occured

; Corrupt	d0

LoadData	PUSH		d1-d7/a0-a6

		move.l		a1,d4
		move.l		d0,d3

		bsr		_GetDos

; Open the file

		move.l		a0,d1			filename
		move.l		#OLDFILE,d2		access mode
		move.l		_DOSBase,a6
		jsr		-$01e(a6)		Open()
		move.l		d0,d5			save handle
		beq		.done			exit on error		

; Read in data, d3 already holds size of file

		move.l		d5,d1			handle
		move.l		d4,d2			buffer
		jsr		-$02a(a6)		Read()

; Close the file

		move.l		d5,d1			handle
		jsr		-$024(a6)		Close()
		moveq.l		#1,d0

.done		bsr		_NoDos
		PULL		d1-d7/a0-a6
		rts
*****
*****	Load a file into a block of memory
*****

; Entry		a0->filename
;		d0=requirements

; Exit		a0=addr of data
;		d0=size of buffer or 0 if an error occurred

; Corrupt	d0

LoadFile	PUSH		d1-d7/a1-a6

		move.l		d0,d1			save mem type
		moveq.l		#0,d6
		move.l		d6,d7

; Allow dos to function

		bsr		_GetDos			enable dos

; Determine length of file

		bsr		FileLen			determine size of file
		move.l		d0,d7			save length
		beq		.done

; Allocate some memory, d0 and d1 already initialised

		bsr		GetMem
		move.l		d0,d6			buffer
		beq.s		.done

; Open the file

		move.l		a0,d1			filename
		move.l		#OLDFILE,d2		access mode
		move.l		_DOSBase,a6
		jsr		-$01e(a6)		Open()
		move.l		d0,d5			save handle
		bne.s		.get_data		

		move.l		d6,d0
		bsr		FreMem
		moveq.l		#0,d0
		bra		.done

; Read in data

.get_data	move.l		d5,d1			handle
		move.l		d6,d2			buffer
		move.l		d7,d3			size
		jsr		-$02a(a6)		Read()

; Close the file

		move.l		d5,d1			handle
		jsr		-$024(a6)		Close()

; Set up return values

		move.l		d6,a0			buffer
		move.l		d7,d0			size

.done		bsr		_NoDos
		PULL		d1-d7/a1-a6
		rts

*****
*****	Save contents of memory to disk
*****

; Entry		a0->filename
;		a1->memory
;		d0=number of bytes

; Exit		d0=0 if an error occurred

; Corrupt	d0

SaveData	PUSH		d1-d7/a0-a6

		move.l		a1,d4
		move.l		d0,d3

		bsr		_GetDos

; Open the file

		move.l		a0,d1			filename
		move.l		#NEWFILE,d2		access mode
		move.l		_DOSBase,a6
		jsr		-$01e(a6)		Open()
		move.l		d0,d5			save handle
		beq		.done			exit on error		

; Read in data, d3 already holds size of file

		move.l		d5,d1			handle
		move.l		d4,d2			buffer
		jsr		-$030(a6)		Write()

; Close the file

		move.l		d5,d1			handle
		jsr		-$024(a6)		Close()
		moveq.l		#1,d0

.done		bsr		_NoDos
		PULL		d1-d7/a0-a6
		rts

*****
*****	Determine the length of a file
*****

; Entry		a0->filename

; Exit		d0=length of file, 0 => an error occurred

; Corrupt	d0

FileLen		PUSH		d1-d7/a0-a6

		moveq.l		#0,d7
		
; Open the file

		move.l		a0,d1			filename
		move.l		#OLDFILE,d2		access mode
		move.l		_DOSBase,a6
		jsr		-$01e(a6)		Open()
		move.l		d0,d5			save handle
		beq.s		.done			exit on error

; Determine it's length

		move.l		d5,d1			handle
		moveq.l		#0,d2			distance
		moveq.l		#1,d3			OFFSET_END
		jsr		-$042(a6)		Seek()
		
		move.l		d5,d1			handle
		moveq.l		#0,d2			distance
		moveq.l		#-1,d3			OFFSET_BEGINNING
		jsr		-$042(a6)		Seek()
		move.l		d0,d7			save size

; Close the file

		move.l		d5,d1			handle
		jsr		-$024(a6)		Close()

.done		move.l		d7,d0
		PULL		d1-d7/a0-a6
		rts

*****
*****	Awaken enough of the system to allow dos routines to function
*****

_GetDos		PUSH	a0-a1

; Copy interrupt and dma settings

		move.w		$dff002,_tdma		DMACONR
		move.w		$dff01c,_tint		INTENAR

; Disable interrupts

		move.w		#$7fff,$dff09a

; Preserve current autovectors

		lea		$64,a0			autovectors
		lea		_tVects,a1		storage area
		move.l		(a0)+,(a1)+		level 1
		move.l		(a0)+,(a1)+		level 2
		move.l		(a0)+,(a1)+		level 3
		move.l		(a0)+,(a1)+		level 4
		move.l		(a0)+,(a1)+		level 5
		move.l		(a0)+,(a1)		level 6

; restore required system vectors

		lea		_sysVECTS,a0		a0->system autovects
		lea		$64,a1
		move.l		(a0),(a1)		level 1
		move.l		4(a0),4(a1)		level 2
		move.l		8(a0),8(a1)		level 3
		move.l		16(a0),16(a1)		level 5
		move.l		20(a0),20(a1)		level 6

; Restore system interrupt requirements

		move.w		_sysINTS,d0		get bits
		or.w		#SETIT!INTEN,d0		set bits 14 & 15
		move.w		d0,$dff09a		set requirements

; Restore system DMA requirements

		move.w		_sysDMA,d0		DMA settings
		or.w		#SETIT!DMAEN,d0		set enable bits
		move.w		d0,$dff096		restore DMA

.done		PULL	a0-a1
		rts

*****
*****	Restore system to programs requirements
*****

_NoDos		PUSH	d0/a0-a1

; stop interrupts

		move.w		#$4000,$dff09a
		
; Restore autovectors

		lea		$64,a1			autovectors
		lea		_tVects,a0		storage area
		move.l		(a0)+,(a1)+		level 1
		move.l		(a0)+,(a1)+		level 2
		move.l		(a0)+,(a1)+		level 3
		move.l		(a0)+,(a1)+		level 4
		move.l		(a0)+,(a1)+		level 5
		move.l		(a0)+,(a1)		level 6

; Enable DMA

		move.w		#$7fff,$dff096		kill all DMA
		move.w		_tdma,d0
		or.w		#8200,d0
		move.w		d0,$dff096		restore original DMA

; Enable interrupts

		move.w		#$7fff,$dff09a		kill interrupts
		move.w		_tint,d0
		or.w		#$c000,d0
		move.w		d0,$dff09a		restore original ints

.done		PULL	d0/a0-a1
		rts

_tVects		ds.l	6
_tdma		ds.l	1
_tint		ds.l	1
