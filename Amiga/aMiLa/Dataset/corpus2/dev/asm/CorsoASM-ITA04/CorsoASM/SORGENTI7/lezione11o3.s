
; Lezione11o3.s   Caricamento di un file dati usando la dos.library
;		  nota: non occorre sapere la lunghezza del file!
;		  Premere il tasto sinistro per caricare, destro per uscire

	Section DosLoad,code

;	Include	"DaWorkBench.s"	; togliere il ; prima di salvare con "WO"

*****************************************************************************
	include	"startup2.s"	; salva interrupt, dma eccetera.
*****************************************************************************

; Con DMASET decidiamo quali canali DMA aprire e quali chiudere

		;5432109876543210
DMASET	EQU	%1000001110000000	; copper,bitplane DMA abilitati

WaitDisk	EQU	30	; 50-150 al salvataggio (secondo i casi)

START:

; Puntiamo la PIC

	MOVE.L	#PICTURE2,d0
	LEA	BPLPOINTERS2,A1
	MOVEQ	#5-1,D1			; num di bitplanes
POINTBT2:
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	swap	d0
	add.l	#34*40,d0		; lunghezza del bitplane
	addq.w	#8,a1
	dbra	d1,POINTBT2	; Rifai D1 volte (D1=num do bitplanes)

; Puntiamo ad un buffer vuoto, che rimarra' sempre vuoto...

	LEA	bplpointers,A0
	MOVE.L	#LOGO+40*40,d0	; indirizzo logo (un po' ribassato)
	MOVEQ	#6-1,D7		; 6 bitplanes HAM.
pointloop:
	MOVE.W	D0,6(A0)
	SWAP	D0
	MOVE.W	D0,2(A0)
	SWAP	D0
	ADDQ.w	#8,A0
	ADD.L	#176*40,D0	; lunghezza plane
	DBRA	D7,pointloop


; Puntiamo il nostro int di livello 3

	move.l	BaseVBR(PC),a0	     ; In a0 il valore del VBR
	move.l	oldint6c(PC),crappyint	; Per DOS LOAD - salteremo all'oldint
	move.l	#MioInt6c,$6c(a0)	; metto la mia rout. int. livello 3.

	MOVE.W	#DMASET,$96(a5)		; DMACON - abilita bitplane, copper
					; e sprites.
	move.l	#COPPERLIST,$80(a5)	; Puntiamo la nostra COP
	move.w	d0,$88(a5)		; Facciamo partire la COP
	move.w	#0,$1fc(a5)		; Disattiva l'AGA
	move.w	#$c00,$106(a5)		; Disattiva l'AGA
	move.w	#$11,$10c(a5)		; Disattiva l'AGA

	movem.l	d0-d7/a0-a6,-(SP)
	bsr.w	mt_init		; inizializza la routine musicale
	movem.l	(SP)+,d0-d7/a0-a6

	move.w	#$c020,$9a(a5)	; INTENA - abilito interrupt "VERTB"
				; del livello 3 ($6c)

mouse:
	btst	#6,$bfe001	; Mouse premuto? (il processore esegue questo
	bne.s	mouse		; loop in modo utente, e ogni vertical blank
				; nonche' ogni WAIT della linea raster $a0
				; lo interrompe per suonare la musica!).


	lea	FileName1(PC),a0 	; Nome del file da caricare
	lea	Buffile1(PC),a1		; In che label salvo l'indirizzo
					; del file caricato in mem
	lea	Grandezz1(PC),a2	; In che label salvo la grandezza
	moveq	#2,d0			; Tipo di mem. destinaz.: CHIP RAM!

	bsr.w	DosLoad2	; Carica un file legalmente con la dos.lib
				; mentre stiamo visualizzando una nostra
				; copperlist e eseguendo un nostro interrupt.
				; Definire prima "TypeOfMem", con "2" per CHIP
				; o "1" per PUBLIC, e gli altri parametri.
	TST.B	d1		; Abbiamo Allocato memoria da liberare?
	beq.s	NonFreeMemare	; d1=0, allora non allocato
	st.b	FreeMema1	; Se si, setta FreeMema1
NonFreeMemare
	TST.L	d0		; Controlla se ci sono stati errori...
	bne.s	ErroreLoad	; File non caricato?? Non usiamolo allora!
				; d0=0, allora va tutto bene

; Ora puntiamo alla figura caricata:

	LEA	bplpointers,A0
	move.l	Buffile1(PC),d0 ; indirizzo del file caricato
	ADD.L	#40*40,d0	; logo un po' ribassato (centriamolo...)
	MOVEQ	#6-1,D7		; 6 bitplanes HAM.
pointloop2:
	MOVE.W	D0,6(A0)
	SWAP	D0
	MOVE.W	D0,2(A0)
	SWAP	D0
	ADDQ.w	#8,A0
	ADD.L	#176*40,D0	; lunghezza plane
	DBRA	D7,pointloop2

ErroreLoad:
mouse2:
	btst	#2,$dff016	; Mouse premuto? (il processore esegue questo
	bne.s	mouse2		; loop in modo utente, e ogni vertical blank

	bsr.w	mt_end		; fine del replay!

; RICORDATEVI SEMPRE DI LIBERARE TUTTA LA MEMORIA ALLOCATA!
; Ma anche di non chiamare il FreeMem se non abbiamo veramente allocato
; la memoria, pena super guru meditation - software failure - casini vari.

	tst.b	FreeMema1	; c'e' stato un errore prima dell'AllocMem?
	beq.s	NonEraAllocata1	; se si, non fare il FreeMem!

	move.l	Grandezz1(PC),d0 ; Grandezza del blocco in bytes
	move.l	Buffile1(PC),a1 ; Indirizzo del blocco di mem. allocata
	move.l	4.w,a6
	jsr	-$d2(a6)	; FreeMem
NonEraAllocata1:
	rts			; esci


; Variabili che abbiamo usato per salvare grandezza e indirizzo del file da
; usare e deallocare alla fine

Buffile1:
	dc.l	0
Grandezz1:
	dc.l	0
FreeMema1:
	dc.l	0

*****************************************************************************
*	ROUTINE IN INTERRUPT $6c (livello 3) - usato il VERTB e COPER.
*****************************************************************************

MioInt6c:
	btst.b	#5,$dff01f	; INTREQR - il bit 5, VERTB, e' azzerato?
	beq.s	NointVERTB		; Se si, non e' un "vero" int VERTB!
	movem.l	d0-d7/a0-a6,-(SP)	; salvo i registri nello stack
	bsr.w	mt_music		; suono la musica
	bsr.w	ColorCicla		; Cicla i colori della pic
	movem.l	(SP)+,d0-d7/a0-a6	; riprendo i reg. dallo stack
NointVERTB:
	move.w	#$70,$dff09c	; INTREQ - int eseguito, cancello la richiesta
				; dato che il 680x0 non la cancella da solo!!!
	rte			; Uscita dall'int VERTB

*****************************************************************************
*	Routine che "cicla" i colori di tutta la palette.		    *
*	Questa routine cicla i primi 15 colori separatamente dal secondo    *
*	secondo blocco di colori. Funziona come i "RANGE" del Dpaint.       *
*****************************************************************************

;	Il contatore "cont" serve a far aspettare 3 fotogrammi prima di
;	eseguire la routine cont. In pratica a "rallentare" l'esecuzione

cont:
	dc.w	0

ColorCicla:
	addq.b	#1,cont
	cmp.b	#3,cont		; Agisci 1 volta ogni 3 fotogrammi solamente
	bne.s	NonAncora	; Non siamo ancora al terzo? Esci!
	clr.b	cont		; Siamo al terzo, azzera il contatore

; Roteazione all'indietro dei primi 15 colori

	lea	cols+2,a0	; Indirizzo primo colore del primo gruppo
	move.w	(a0),d0		; Salva il primo colore in d0
	moveq	#15-1,d7	; 15 colori da "roteare" nel primo gruppo
cloop1:
	move.w	4(a0),(a0)	; Copia il colore avanti in quello prima
	addq.w	#4,a0		; salta alla prossimo col. da "indietreggiare"
	dbra	d7,cloop1	; ripeti d7 volte
	move.w	d0,(a0)		; Sistema il primo colore salvato come ultimo.

; Roteazione in avanti dei secondi 15 colori

	lea	cole-2,a0	; Indirizzo ultimo colore del secondo gruppo
	move.w	(a0),d0		; Salva l'ultimo colore in d0
	moveq	#15-1,d7	; Altri 15 colori da "roteare" separatamente
cloop2:	
	move.w	-4(a0),(a0)	; Copia il colore indietro in quello dopo
	subq.w	#4,a0		; salta al precedente col. da "avanzare"
	dbra	d7,cloop2	; ripeti d7 volte
	move.w	d0,(a0)		; Sistema l'ultimo colore salvato come primo
NonAncora:
	rts


*****************************************************************************
; Routine che carica un file mentre stiamo battendo nel metallo.
;
; Parametri in entrata:
;
; a0	= Indirizzo della stringa col nome del file da caricare
; a1	= Indirizzo della label (.L) dove salvare l'indirizzo del file
; a2	= Indirizzo della label (.L) dove salvare la lunghezza del file
;
; Parametri in uscita:
;
; d0.l	= Se = 0, non ci sono problemi, se = -1 c'e' stato qualche errore
; d1.b	= Se = 0 non abbiamo eseguito AllocMem, se = 1 dobbiamo fare FreeMem!
;
*****************************************************************************

DosLoad2:
	movem.l	d2-d7/a3-a6,-(SP)
	move.l	a0,FileName 	; Nome del file da caricare
	move.l	a1,DestinazLoad	; In che label salvo l'indirizzo
	move.l	a2,SalvGrandezz	; In che label salvo la grandezza file
	move.l	d0,TypeOfMem	; Tipo di mem. destinaz.: CHIP RAM!

	bsr.w	PreparaLoad	; Rispristina multitask e setta interrupt load

	moveq	#5,d1		; num. di frames da aspettare
	bsr.w	AspettaBlanks	; aspetta 5 frames

	bsr.s	CaricaFile2	; Carica il file con la dos.library, di
				; qualunque lunghezza "sconosciuta".
	move.l	d0,ErrorFlag	; Salva lo stato di successo o di errore

; nota: ora dobbiamo attendere che il motore del disk drive, o la spia del
; povero Hard Disk o CD-ROM si spenga, prima di bloccare tutto, o causiamo
; un crash del sistema spettacolare.

	move.w	#150,d1		; num. di frames da aspettare
	bsr.w	AspettaBlanks	; aspetta 150 frames

	bsr.w	DopoLoad	; Disabilita multitask e rimetti interrupt
	move.l	ErrorFlag(PC),d0 ; metti il segnalatore di errore/successo
	moveq	#0,d1
	move.b	FreeMemFlag(PC),d1 ; metti il segnalatore di freemem da fare
	clr.b	FreeMemFlag	   ; azzeralo (non allocated) per la prossima
	movem.l	(SP)+,d2-d7/a3-a6
	rts

ErrorFlag:
	dc.l	0

*****************************************************************************
; Routine che carica un file di lunghezza "sconosciuta" qualsiasi in un
; buffer di memoria CHIP o PUBLIC, allocato con AllocMem.
; Definire prima "TypeOfMem", con "2" per CHIP RAM o "1" per PUBLIC.
; In uscita, d0=0 se ha avuto successo, oppure -1 se ci sono stati problemi
*****************************************************************************

;        ''~``
;       ( o o )
;+-.oooO--(_)--Oooo.---------------------------------------------------------+
;|									     |
;|   Oooo           	SCUSATE SE LA ROUTINE E' UN PO' TROPPO INCASINATA    |
;|   (   )   Oooo.                         				     |
;+----\ (----(   )-----------------------------------------------------------+
;      \_)    ) /
;            (_/

CaricaFile2:
	move.l	filename(PC),d1	; indirizzo con stringa "file name + path"
	MOVE.L	#$3ED,D2	; AccessMode: MODE_OLDFILE - File che esiste
				; gia', e che quindi potremo leggere.
	MOVE.L	DosBase(PC),A6
	JSR	-$1E(A6)	; LVOOpen - "Apri" il file
	MOVE.L	D0,FileHandle	; Salva il suo handle
	BEQ.W	ErrorOpen	; Se d0 = 0 allora c'e' un errore!

; Ora Facciamo il lock del file, per poterci poi fare l'examine

	move.l	filename(pc),d1	; nome del file
	moveq	#-2,d2		; AccessMode = ACCESS_READ
	jsr	-$54(a6)	; lock del file
	move.l	d0,filelock	; Salviamo il puntatore al lock del file
	beq.w	ErroreLock	; d0 = 0? Allora errore!

; Allochiamo memoria per il FileInfoBlock di Examine()

	move.l	#$104,d0	; Grandezza del blocco in bytes
	move.l	#1,d1		; Tipo di Memoria: public
	move.l	4.w,a6
	jsr	-$c6(a6)	; Allocmem
	move.l	d0,FibAdr	; Indirizzo inizio del blocco di mem. allocata
	beq.s	ErroreAlFib	; d0=0? Allora errore!

; Ora eseguiamo l'Examine del file, per sapere la sua lunghezza

	move.l	FileLock(PC),d1	; lock ptr in d1 per examine
	move.l	FibAdr(PC),d2	; File Info Block per examine
	MOVE.L	DosBase(PC),A6
	jsr	-$66(a6)	; examine che riempie il buffer fib ($104 byte)
				; di infos sul file(nome, dir/file, size, date)
	tst.l	d0		; Problemi con Examine?
	beq.s	ErroreExamine
	move.l	FibAdr(pc),a0
	move.l	$7c(a0),d3	; offset del size (lunghezza)
	move.l	d3,SizeFile

; Ora possiamo anche liberare la memoria usata per il FileInfoBlock

	bsr.w	LiberaFib

; Allochiamo la memoria per il file

	move.l	SizeFile(PC),d0	 ; Grandezza del blocco in bytes
	move.l	TypeOfMem(PC),d1 ; Tipo di Memoria
	move.l	4.w,a6
	jsr	-$c6(a6)	; Allocmem
	move.l	d0,FileAdr	; Indirizzo inizio del blocco di mem. allocata
	beq.s	ErroreAllFile	; d0=0? Allora errore!

; Facciamo una copia dell'indirizzo del file per noi e il freemem

	move.l	DestinazLoad(PC),a0
	move.l	d0,(a0)
	move.l	SalvGrandezz(PC),a0	; e salviamo anche la lunghezza
	move.l	SizeFile(PC),(a0)

	st.b	FreeMemFlag	; Ricordiamoci di fare il freemem

; Carichiamo il file nel blocco di memoria allocato:

	MOVE.L	FileHandle(PC),D1 ; FileHandle in d1 per il Read
	MOVE.L	FileAdr(PC),D2	; Indirizzo Destinazione in d2
	MOVE.L	SizeFile(PC),D3	; Lunghezza del file (ESATTA!)
	MOVE.L	DosBase(PC),A6
	JSR	-$2A(A6)	; LVORead - leggi il file e copialo nel buffer
	cmp.l	#-1,d0		; Errore? (qua e' indicato con -1)
	beq.s	ErroreRead

; Unlockiamo il file

	bsr.s	UnlockFile

; E chiudiamolo

	bsr.s	CloseFile

; Attenzione al fatto che se non CHIUDETE il file, gli altri programmi non
; potranno accedere a tale file (non potrete ne' cancellarlo, ne' spostarlo).

	moveq	#0,d0	; segnala il successo totale!
	rts


; Ecco la compilation degli errori possibili:


ErroreExamine:
	bsr.s	LiberaFib
ErroreAllFile:
ErroreAlFib:
	bsr.s	UnlockFile
ErroreLock:
	bsr.s	CloseFile
ErrorOpen:
	moveq	#-1,d0		; segnala l'errore
	rts

ErroreRead:
	bsr.s	UnlockFile
	bsr.s	CloseFile
	st.b	FreeMemFlag	; Ricordiamoci di fare il freemem
	moveq	#-1,d0		; Segnala l'errore
	rts

; Routines chiamate da piu' parti:

CloseFile:
	MOVE.L	DosBase(PC),A6
	MOVE.L	FileHandle(pc),D1 ; FileHandle in d1
	JSR	-$24(A6)	; LVOClose - chiudi il file.
	rts

UnlockFile:
	MOVE.L	DosBase(PC),A6
	move.l	FileLock(PC),d1	; lock ptr in d1 per unlock
	jsr	-$5a(a6)	; Unlock del file
	rts

LiberaFib:
	move.l	4.w,a6
	move.l	#$104,d0	; Grandezza del blocco in bytes
	move.l	FibAdr(PC),a1	; Indirizzo del blocco di mem. allocata
	jsr	-$d2(a6)	; FreeMem
	rts

SalvGrandezz:
	dc.l	0
DestinazLoad:
	dc.l	0
FileHandle:
	dc.l	0
TypeOfMem:
	dc.l	0
FileName:
	dc.l	0
FileLock:
	dc.l	0
FibAdr:
	dc.l	0
SizeFile:
	dc.l	0
FileAdr
	dc.l	0
FreeMemFlag:
	dc.l	0

; Stringa di testo, da terminare con uno 0, a cui dovra' puntare d1 prima di
; fare l'OPEN della dos.lib. Conviene mettere l'intero path.


Filename1:
	dc.b	"assembler3:sorgenti7/amiet.raw",0	; path+nomefile
	even

*****************************************************************************
; Routine di interrupt da mettere durante il caricamento. Le routines che
; saranno messe in questo interrupt saranno eseguite anche durante il
; caricamento, sia che avvenga da floppy disk, da Hard Disk, o CD ROM.
; DA NOTARE CHE STIAMO USANDO L'INTERRUPT COPER, E NON QUELLO VBLANK,
; QUESTO PERCHE' DURANTE IL CARICAMENTO DA DISCO, SPECIALMENTE SOTTO KICK 1.3,
; L'INTERRUPT VERTB NON E' STABILE, tanto che la musica avrebbe dei sobbalzi.
; Invece, se mettiamo un "$9c,$8010" nella nostra copperlist, siamo sicuri
; che questa routine sara' eseguita una volta sola per fotogramma.
*****************************************************************************

myint6cLoad:
	btst.b	#4,$dff01f	; INTREQR - il bit 4, COPER, e' azzerato?
	beq.s	nointL		; Se si, non e' un "vero" int COPER!
	move.w	#%10000,$dff09c	; Se no, e' la volta buona, togliamo il req!
	movem.l	d0-d7/a0-a6,-(SP)
	bsr.w	mt_music	; Suona la musica
	movem.l	(SP)+,d0-d7/a0-a6
nointL:
	dc.w	$4ef9		; val esadecimale di JMP
Crappyint:
	dc.l	0		; Indirizzo dove Jumpare, da AUTOMODIFICARE...
				; ATTENZIONE: il codice automodificante non
				; andrebbe usato. Comunque se si chiama un
				; ClearMyCache prima e dopo, funziona!

*****************************************************************************
; Routine che ripristina il sistema operativo, tranne la copperlist, e in
; piu' setta un interrupt $6c nostro, che poi salta a quello di sistema.
; Da notare che durante il load l'interrupt e' gestito dall'int "COPER"
*****************************************************************************

PreparaLoad:
	LEA	$DFF000,A5		; Base dei registri CUSTOM per Offsets
	MOVE.W	$2(A5),OLDDMAL		; Salva il vecchio status di DMACON
	MOVE.W	$1C(A5),OLDINTENAL	; Salva il vecchio status di INTENA
	MOVE.W	$1E(A5),OLDINTREQL	; Salva il vecchio status di INTREQ
	MOVE.L	#$80008000,d0		; Prepara la maschera dei bit alti
	OR.L	d0,OLDDMAL		; Setta il bit 15 dei valori salvati
	OR.W	d0,OLDINTREQL		; dei registri, per poterli rimettere.

	bsr.w	ClearMyCache

	MOVE.L	#$7FFF7FFF,$9A(a5)	; DISABILITA GLI INTERRUPTS & INTREQS

	move.l	BaseVBR(PC),a0	     ; In a0 il valore del VBR
	move.l	OldInt64(PC),$64(a0) ; Sys int liv1 salvato (softint,dskblk)
	move.l	OldInt68(PC),$68(a0) ; Sys int liv2 salvato (I/O,ciaa,int2)
	move.l	#myint6cLoad,$6c(a0) ; Int che poi salta a quello di sys. 
	move.l	OldInt70(PC),$70(a0) ; Sys int liv4 salvato (audio)
	move.l	OldInt74(PC),$74(a0) ; Sys int liv5 salvato (rbf,dsksync)
	move.l	OldInt78(PC),$78(a0) ; Sys int liv6 salvato (exter,ciab,inten)

	MOVE.W	#%1000001001010000,$96(A5) ; Abilita blit e disk per sicurezza
	MOVE.W	OLDINTENA(PC),$9A(A5)	; INTENA STATUS
	MOVE.W	OLDINTREQ(PC),$9C(A5)	; INTREQ
	move.w	#$c010,$9a(a5)		; dobbiamo essere sicuri che COPER
					; (interrupt via copperlist) sia ON!

	move.l	4.w,a6
	JSR	-$7e(A6)	; Enable
	JSR	-$8a(a6)	; Permit

	MOVE.L	GfxBase(PC),A6
	jsr	-$E4(A6)	; Aspetta la fine di eventuali blittate
	JSR	-$E4(A6)	; WaitBlit
	jsr	-$1ce(a6)	; DisOwnBlitter, il sistema operativo ora
				; puo' nuovamente usare il blitter
				; (nel kick 1.3 serve per caricare da disk)
	MOVE.L	4.w,A6
	SUBA.L	A1,A1		; NULL task - trova questo task
	JSR	-$126(A6)	; findtask (Task(name) in a1, -> d0=task)
	MOVE.L	D0,A1		; Task in a1
	MOVEQ	#0,D0		; Priorita' in d0 (-128, +127) - NORMALE
				; (Per permettere ai drives di respirare)
	JSR	-$12C(A6)	;_LVOSetTaskPri (d0=priorita', a1=task)
	rts

OLDDMAL:
	dc.w	0
OLDINTENAL:		; Vecchio status INTENA
	dc.w	0
OLDINTREQL:		; Vecchio status INTREQ
	DC.W	0

*****************************************************************************
; Routine che richiude il sistema operativo e rimette il nostro interrupt
*****************************************************************************

DopoLoad:
	MOVE.L	4.w,A6
	SUBA.L	A1,A1		; NULL task - trova questo task
	JSR	-$126(A6)	; findtask (Task(name) in a1, -> d0=task)
	MOVE.L	D0,A1		; Task in a1
	MOVEQ	#127,D0		; Priorita' in d0 (-128, +127) - MASSIMA
	JSR	-$12C(A6)	;_LVOSetTaskPri (d0=priorita', a1=task)

	JSR	-$84(a6)	; Forbid
	JSR	-$78(A6)	; Disable

	MOVE.L	GfxBase(PC),A6
	jsr	-$1c8(a6)	; OwnBlitter, che ci da l'esclusiva sul blitter
				; impedendone l'uso al sistema operativo.
	jsr	-$E4(A6)	; WaitBlit - Attende la fine di ogni blittata
	JSR	-$E4(A6)	; WaitBlit

	bsr.w	ClearMyCache

	LEA	$dff000,a5		; Custom base per offsets
AspettaF:
	MOVE.L	4(a5),D0	; VPOSR e VHPOSR - $dff004/$dff006
	AND.L	#$1ff00,D0	; Seleziona solo i bit della pos. verticale
	CMP.L	#$12d00,D0	; aspetta la linea $12d per evitare che
	BEQ.S	AspettaF	; spegnendo i DMA si abbiano sfarfallamenti

	MOVE.L	#$7FFF7FFF,$9A(A5)	; DISABILITA GLI INTERRUPTS & INTREQS

		; 5432109876543210
	MOVE.W	#%0000010101110000,d0	; DISABILITA DMA

	btst	#8-8,olddmal	; test bitplane
	beq.s	NoPlanesA
	bclr.l	#8,d0		; non spengere planes
NoPlanesA:
	btst	#5,olddmal+2	; test sprite
	beq.s	NoSpritez
	bclr.l	#5,d0		; non spengere sprite
NoSpritez:
	MOVE.W	d0,$96(A5) ; DISABILITA DMA

	move.l	BaseVBR(PC),a0		; In a0 il valore del VBR
	move.l	#MioInt6c,$6c(a0)	; metto la mia rout. int. livello 3.
	MOVE.W	OLDDMAL(PC),$96(A5)	; Rimetti il vecchio status DMA
	MOVE.W	OLDINTENAL(PC),$9A(A5)	; INTENA STATUS
	MOVE.W	OLDINTREQL(PC),$9C(A5)	; INTREQ
	rts

*****************************************************************************
; Questa routine aspetta D1 fotogrammi. Ogni 50 fotogrammi passa 1 secondo.
;
; d1 = numero di fotogrammi da attendere
;
*****************************************************************************

AspettaBlanks:
	LEA	$DFF000,A5	; CUSTOM REG per OFFSETS
WBLAN1xb:
	MOVE.w	#$80,D0
WBLAN1bxb:
	CMP.B	6(A5),D0	; vhposr
	BNE.S	WBLAN1bxb
WBLAN2xb:
	CMP.B	6(A5),D0	; vhposr
	Beq.S	WBLAN2xb
	DBRA	D1,WBLAN1xb
	rts

*****************************************************************************
;	Routine di replay del protracker/soundtracker/noisetracker
;
	include	"assembler3:sorgenti4/music.s"
*****************************************************************************

	SECTION	GRAPHIC,DATA_C

COPPERLIST:
	dc.w	$8E,$2c81	; DiwStrt
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

BPLPOINTERS:
	dc.w $e0,0,$e2,0		;primo 	 bitplane
	dc.w $e4,0,$e6,0		;secondo    "
	dc.w $e8,0,$ea,0		;terzo      "
	dc.w $ec,0,$ee,0		;quarto     "
	dc.w $f0,0,$f2,0		;quinto     "
	dc.w $f4,0,$f6,0		;sesto      "

	dc.w	$180,0	; Color0 nero


		     ;5432109876543210
	dc.w	$100,%0110101000000000	; bplcon0 - 320*256 HAM!

	dc.w $180,$0000,$182,$134,$184,$531,$186,$443
	dc.w $188,$0455,$18a,$664,$18c,$466,$18e,$973
	dc.w $190,$0677,$192,$886,$194,$898,$196,$a96
	dc.w $198,$0ca6,$19a,$9a9,$19c,$bb9,$19e,$dc9
	dc.w $1a0,$0666

	dc.w	$9707,$FFFE	; wait linea $97

	dc.w	$100,$200	; BPLCON0 - no bitplanes
	dc.w	$180,$00e	; color0 BLU

	dc.w	$b907,$fffe	; WAIT - attendi linea $b9
BPLPOINTERS2:
	dc.w $e0,0,$e2,0		;primo 	 bitplane
	dc.w $e4,0,$e6,0		;secondo    "
	dc.w $e8,0,$ea,0		;terzo	    "
	dc.w $ec,0,$ee,0		;quarto	    "
	dc.w $f0,0,$f2,0		;quinto	    "

	dc.w	$100,%0101001000000000	; BPLCON0 - 5 bitplanes LOWRES

; La palette, che sara' "ruotata" in 2 gruppi di 16 colori.

cols:
	dc.w $180,$040,$182,$050,$184,$060,$186,$080	; tono verde
	dc.w $188,$090,$18a,$0b0,$18c,$0c0,$18e,$0e0
	dc.w $190,$0f0,$192,$0d0,$194,$0c0,$196,$0a0
	dc.w $198,$090,$19a,$070,$19c,$060,$19e,$040

	dc.w $1a0,$029,$1a2,$02a,$1a4,$13b,$1a6,$24b	; tono blu
	dc.w $1a8,$35c,$1aa,$36d,$1ac,$57e,$1ae,$68f
	dc.w $1b0,$79f,$1b2,$68f,$1b4,$58e,$1b6,$37e
	dc.w $1b8,$26d,$1ba,$15d,$1bc,$04c,$1be,$04c
cole:

	dc.w	$da07,$fffe	; WAIT - attendi la linea $da
	dc.w	$100,$200	; BPLCON0 - disabilita i bitplanes
	dc.w	$180,$00e	; color0 BLU

	dc.w	$ff07,$fffe	; WAIT - attendi la linea $ff
	dc.w	$9c,$8010	; INTREQ - Richiedo un interrupt COPER, per
				; suonare la musica (anche mentre stiamo
				; caricando con la dos.library).

	dc.w	$FFFF,$FFFE	; Fine della copperlist


*****************************************************************************
; 		DISEGNO 320*34 a 5 bitplanes (32 colori)
*****************************************************************************

PICTURE2:
	INCBIN	"pic320*34*5.raw"

*****************************************************************************
;				MUSICA
*****************************************************************************

mt_data:
	dc.l	mt_data1

mt_data1:
	incbin	"assembler3:sorgenti7/Mod.Prova"

******************************************************************************
; Buffer che rimane vuoto, qua serve solo come "nero" prima del caricamento.
; Avremmo potuto anche semplicemente disabilitare i bitplanes, ed attivarli
; solo a figura caricata, per risparmiare questo spazio azzerato!
******************************************************************************

	section	mioplanaccio,bss_C

buffer:
LOGO:
	ds.b	6*40*176	; 6 bitplanes * 176 lines * 40 bytes (HAM)


	end

Questo listato locka il file, lo EXAMINA per averne la lunghezza, alloca la
memoria con AllocMem, lo carica, e alla fine libera il blocco di memoria
con FreeMem. Vi prego di notare l'attenzione posta alle varie possibilita'
di errore, per non eseguire FreeMem quando non si e' allocato niente, e
per non usare il file quando non lo si e' caricato bene. Occorre SEMPRE
controllare tutto, e preparare le routine ad eventuali insuccessi.
La routine e' stata resa piu' parametrica, infatti si puo' specificare ogni
volta il nome del file e il tipo di memoria richiesto. Basta che in caso
voleste caricare piu' files, non vi confondiate con i vari FreeMem alla fine!
Ecco un esempio in cui carichiamo 2 files:

; Primo file:

	lea	FileName1(PC),a0 	; Nome del file da caricare
	lea	Buffile1(PC),a1		; In che label salvo l'indirizzo
					; del file caricato in mem
	lea	Grandezz1(PC),a2	; In che label salvo la grandezza
	moveq	#2,d0			; Tipo di mem. destinaz.: CHIP RAM!

	bsr.w	DosLoad2	; Carica un file legalmente con la dos.lib
				; mentre stiamo visualizzando una nostra
				; copperlist e eseguendo un nostro interrupt
				; Definire prima "TypeOfMem", con "2" per CHIP
				; o "1" per PUBLIC, e gli altri parametri.
	TST.B	d1		; Abbiamo Allocato memoria da liberare?
	beq.s	NonFreeMemare	; d1=0, allora non allocato
	st.b	FreeMema1	; Se si, setta FreeMema1
NonFreeMemare
	TST.L	d0		; Controlla se ci sono stati errori...
	bne.s	ErroreLoad	; File non caricato?? Non usiamolo allora!
				; d0=0, allora va tutto bene
	....

; Secondo file:

	lea	FileName2(PC),a0 	; Nome del file da caricare
	lea	Buffile2(PC),a1		; In che label salvo l'indirizzo
					; del file caricato in mem
	lea	Grandezz2(PC),a2	; In che label salvo la grandezza
	moveq	#2,d0			; Tipo di mem. destinaz.: CHIP RAM!

	bsr.w	DosLoad2	; Carica un file legalmente con la dos.lib
				; mentre stiamo visualizzando una nostra
				; copperlist e eseguendo un nostro interrupt
				; Definire prima "TypeOfMem", con "2" per CHIP
				; o "1" per PUBLIC, e gli altri parametri.
	TST.B	d1		; Abbiamo Allocato memoria da liberare?
	beq.s	NonFreeMemare2	; d1=0, allora non allocato
	st.b	FreeMema2	; Se si, setta FreeMema1
NonFreeMemare2
	TST.L	d0		; Controlla se ci sono stati errori...
	bne.s	ErroreLoad2	; File non caricato?? Non usiamolo allora!
	...			; d0=0, allora va tutto bene


E alla fine, dovremo fare 2 FreeMem:

	tst.b	FreeMema1	; c'e' stato un errore prima dell'AllocMem?
	beq.s	NonEraAllocata1	; se si, non fare il FreeMem!

	move.l	Grandezz1(PC),d0 ; Grandezza del blocco in bytes
	move.l	Buffile1(PC),a1 ; Indirizzo del blocco di mem. allocata
	move.l	4.w,a6
	jsr	-$d2(a6)	; FreeMem
NonEraAllocata1:

	tst.b	FreeMema2	; c'e' stato un errore prima dell'AllocMem?
	beq.s	NonEraAllocata2	; se si, non fare il FreeMem!

	move.l	Grandezz2(PC),d0 ; Grandezza del blocco in bytes
	move.l	Buffile2(PC),a1 ; Indirizzo del blocco di mem. allocata
	move.l	4.w,a6
	jsr	-$d2(a6)	; FreeMem
NonEraAllocata2:

	rts			; esci


Naturalmente potete cambiare la routine come volete, o rendere parametrica
quella che carica files con lunghezza specificata... fate come vi pare, ma
controllate bene di non fare errori!

