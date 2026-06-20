
; Lezione11o1.s   Caricamento di un file dati usando la dos.library

	Section DosLoad,code

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

Maincode:
	movem.l	d0-d7/a0-a6,-(SP)	; Salva i registri nello stack
	move.l	4.w,a6			; ExecBase in a6
	LEA	DosName(PC),A1		; Dos.library
	JSR	-$198(A6)		; OldOpenlib
	MOVE.L	D0,DosBase
	BEQ.s	EXIT			; Se zero, esci! Errore!

Mouse:
	btst.b	#6,$bfe001	; ciaapra - tasto sin. del mouse
	bne.s	Mouse

	bsr.s	CaricaFile	; Carica un file con la dos.library

	MOVE.L	DosBase(PC),A1	; DosBase in A1 per chiudere la libreria
	move.l	4.w,a6		; ExecBase in A6
	jsr	-$19E(a6)	; CloseLibrary - dos.library CHIUSA
EXIT:
	movem.l	(SP)+,d0-d7/a0-a6 ; Riprendi i vecchi valori dei registri
	RTS			  ; Torna all'ASMONE o al Dos/WorkBench


DosName:
	dc.b	"dos.library",0
	even

DosBase:		; Puntatore alla Base della Dos Library
	dc.l	0

*****************************************************************************
; Routine che carica un file di una lunghezza specificata e con un nome
; specificato. Occorre mettere l'intero path, se questo esiste!
*****************************************************************************

CaricaFile:
	move.l	#filename,d1	; indirizzo con stringa "file name + path"
	MOVE.L	#$3ED,D2	; AccessMode: MODE_OLDFILE - File che esiste
				; gia', e che quindi potremo leggere.
	MOVE.L	DosBase(PC),A6
	JSR	-$1E(A6)	; LVOOpen - "Apri" il file
	MOVE.L	D0,FileHandle	; Salva il suo handle
	BEQ.S	ErrorOpen	; Se d0 = 0 allora c'e' un errore!

	MOVE.L	D0,D1		; FileHandle in d1 per il Read
	MOVE.L	#buffer,D2	; Indirizzo Destinazione in d2
	MOVE.L	#42240,D3	; Lunghezza del file (ESATTA!)
	MOVE.L	DosBase(PC),A6
	JSR	-$2A(A6)	; LVORead - leggi il file e copialo nel buffer

	MOVE.L	FileHandle(pc),D1 ; FileHandle in d1
	MOVE.L	DosBase(PC),A6
	JSR	-$24(A6)	; LVOClose - chiudi il file.
ErrorOpen:
	rts


FileHandle:
	dc.l	0

; Stringa di testo, da terminare con uno 0, a cui dovra' puntare d1 prima di
; fare l'OPEN della dos.lib. Conviene mettere l'intero path.

Filename:
	dc.b	"assembler2:sorgenti7/amiet.raw",0	; path+nomefile
	even

******************************************************************************
; Buffer dove viene caricata l'immagine da disco (o hard disk) tramite doslib
******************************************************************************

	section	mioplanaccio,bss

buffer:
LOGO:
	ds.b	6*40*176	; 6 bitplanes * 176 lines * 40 bytes (HAM)

	end

