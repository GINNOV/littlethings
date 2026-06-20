*** IFF-ILBM Ripper V1.0 bootblock ***
*
* Coded by Frédéric BASSALER (April '96)
*
* Cherche des données IFF-ILBM dans la mémoire
* et sauve les images les unes à la suite des autres
* sur un disque (avec le trackdisk.device).
* Il faut ensuite utiliser l'utilitaire PicRestore (inclus) pour récupérer
* ces images sous forme de fichiers.
*
* Special bootblock: finds IFF-ILBM pictures in memory
* and writes them onto disk (in trackload format, no DOS!).
* Use the supplied utility 'PicRestore' in order to obtain the files from
* the disk.

	incdir	asm:/Include/
	include	equ.s
	include	exec/types.i
	include	exec/memory.i
	include	exec/execbase.i

	rsreset
ioreq	rs.l	1
lomem	rs.l	1
himem	rs.l	1
intbase	rs.l	1
piclen	rs.l	1
lastadr	rs.l	1
lastblk	rs.l	1
hashbuf	rs.l	1
numpics	rs.w	1
VARSIZE	rs.w	0

;uncomment this to run in debug mode (that is, to test the program
;from AsmOne)

;DBUG=0

;Start of bootblock
Start:
	IFND	DBUG
	dc.b	"DOS",0		;replace 0 by 1 for FFS
	dc.l	0,$370		;sum, rootblock
	ENDC
;Start of bootblock code
Main:
	IFD	DBUG
	move.l	4.w,a6
	ENDC

	movem.l	d0-a6,-(sp)	;save regs
	lea	-VARSIZE(sp),sp	;allocate variables onto the stack
	move.l	sp,a5		;variable base address is in A5

	IFND	DBUG
	move.l	a1,ioreq(a5)
	ELSE			;debug mode: open trackdisk unit 0
	lea	tdport(pc),a1
	move.l	a1,-(sp)
	move.l	4.w,a6
	move.l	ThisTask(a6),$10(a1)
	jsr	AddPort(a6)
	lea	tdreq(pc),a1
	move.l	a1,ioreq(a5)
	move.l	(sp)+,14(a1)
	lea	trackname(pc),a0
	moveq	#0,d0		;unit=0	(DF0)
	moveq	#0,d1		;flags: no
	jsr	OpenDevice(a6)
	ENDC

	clr.l	hashbuf(a5)
	bsr.w	MotOff		;turn drive's motor off

	lea	intname(pc),a1
	jsr	OldOpenLibrary(a6)
	move.l	d0,intbase(a5)

	lea	alert.txt(pc),a0
	bsr.w	MyAlert		;show 'alert' message
	beq.w	xit

* begin the search

.search
	clr	numpics(a5)
	moveq	#3,d0		;bloc de départ de sauvegarde des images
	move.l	d0,lastblk(a5)	;(le bloc 2 sert de Hash table)
	move.l	#512,d0		;1 bloc
	move.l	#$10002,d1	;chip+clear
	jsr	AllocMem(a6)
	move.l	d0,hashbuf(a5)
	beq.s	.err
	move.l	d0,a3
;put header
	move.l	#'PICS',(a3)+	;Identificateur
	clr	(a3)+

* rechercher des images dans toutes les zones mémoire disponibles
* look for pictures in all available memory zones
	move.l	MemList(a6),a4	;Execbase->MemList
.loop	tst.l	(a4)
	beq.s	.done		;no more memory zone
	move.l	MH_LOWER(a4),lastadr(a5)	;memory zone lower limit
	move.l	MH_UPPER(a4),himem(a5)		;memory zone upper limit

	clr	$dff180

	move.l	a4,-(sp)
	bsr.b	SearchPic	;scan memory
	move.l	(sp)+,a4
	tst.l	d7		;an error occured during last disk write?
	bne.s	.err		;if yes...
				;if no, continue

	move.l	LN_SUCC(a4),a4	;next memory zone
	move.l	a4,d0		;no more?
	bne.s	.loop
.done
	move.l	hashbuf(a5),d0
	beq.s	.nobuf
	move.l	d0,a0
	move.l	d0,-(sp)
	move	numpics(a5),4(a0);nbre d'images sauvées
	bsr.w	WriteHash	;sauver hashtable (save hashtable)
	move.l	(sp)+,a1
	move.l	#512,d0
	jsr	FreeMem(a6)	;and free buffer
.nobuf

* display results (number of pics found and saved to disk)
	lea	num.txt(pc),a0
	moveq	#0,d0
	move	numpics(a5),d0
	moveq	#$30,d1
	divu	#10,d0
	add.b	d1,d0
	move.b	d0,(a0)+
	swap	d0
	add.b	d1,d0
	move.b	d0,(a0)+
	lea	noerr.txt(pc),a0	;afficher le nbre d'images sauvées
	bra.s	.al			;ou si une erreur est survenue
.err
	lea	err.txt(pc),a0
.al	bsr.w	MyAlert		;show error message
xit:
	bsr.w	MotOff		;turn drive's motor off
	IFD	DBUG
	move.l	ioreq(a5),a1
	jsr	CloseDevice(a6)
	lea	tdport(pc),a1
	jsr	RemPort(a6)
	ENDC

	move.l	intbase(a5),a1
	jsr	CloseLibrary(a6)

	lea	VARSIZE(sp),sp	;restore stack
	movem.l	(sp)+,d0-a6	;restore regs

* finally, boot the system (A6 already contains Execbase)
	lea	dos.name(pc),a1
	jsr	FindResident(a6)
	move.l	d0,a0
	move.l	22(a0),a0
	moveq	#0,d0
	rts

*** Chercher des images en mémoire & les sauver sur disk
*** Search pics in memory & save to disk
SearchPic:
	move.l	lastadr(a5),a4		;address of the last pic found
.bcl0
	lea	form.txt(pc),a0
	moveq	#4-1,d0
.bcl
	add	#$0111,$dff180		;un peu d'animation! (some animation)
	cmp	#$fff,$dff180
	bne.s	.skip
	clr	$dff180
.skip
	cmpa.l	himem(a5),a4
	bhi.s	.f
	cmpm.b	(a0)+,(a4)+
	bne.s	.bcl0
	btst	#10,$dff016		;RMB to skip
	beq.s	.f
	dbf	d0,.bcl
	move.l	a4,d0
	and.b	#~1,d0		;adresse paire (even address)
	move.l	d0,a4
	cmp.l	#'ILBM',4(a4)
	bne.s	.bcl0
	cmp.l	#'BMHD',8(a4)
	bne.s	.bcl0

	addq	#1,numpics(a5)	;incrémenter compteur (numpics++)
	move.l	(a4),d0		;picture length (in bytes)
	addq.l	#8,d0		;add 8 bytes
	move.l	d0,piclen(a5)
	subq.l	#4,a4
	move.l	a4,lastadr(a5)

	move.l	d0,d6
	moveq	#9,d1
	lsr.l	d1,d6		;d6=d6/512
	addq.l	#1,d6		;nbre de blocs à sauver+1
				;(number of blocks to save+1)

	bsr.s	WriteBlk	;write the blocks
	tst.l	d0		;error occured?
	bne.s	.write_err	;yes!
	add.l	d6,lastadr(a5)	;no, search next pic
	bra.s	SearchPic
.f	moveq	#0,d7		;return flag: no error
	rts
.write_err
	moveq	#-1,d7		;return flag: error
	rts

* Write hashtable on disk block number 2 (length: 1 block (512 bytes))
* Hashtable format is:
*
* offset	identifier		value
*-------------------------------------------------------
*	0	header			'PICS' (longword)
*	4	number of pics saved	(word)
*	6	disk offset of 1st pic	(longword)
*	10	length of pic (in bytes)(longword)
*	14	disk offset of 2nd pic	(longword)
*	18	length of pic		(longword)
* and so on...
WriteHash:
	move.l	hashbuf(a5),a4
	moveq	#2,d0		;offset=2
	move.l	d0,lastblk(a5)
	moveq	#1,d6		;length=1 bloc
* écrire d6 blocks à partir de l'offset d7
* Write disk blocks:
*	d6 contains the number of blocks to write
*	d7 contains the disk offset
WriteBlk:
	move.l	ioreq(a5),a1
	move	#3,28(a1)
	move.l	a1,-(sp)
	move.l	a4,40(a1)	;io_data
	move.l	d6,d0
	moveq	#9,d1
	lsl.l	d1,d0		;d0=d0*512
	move.l	d0,36(a1)	;io_length
	move.l	lastblk(a5),d7
	add.l	d6,lastblk(a5)
	move.l	d7,(a3)+	;put offset in hash table
	move.l	piclen(a5),(a3)+;piclen (in bytes)
	lsl.l	d1,d7
	move.l	d7,44(a1)	;io_offset
	jsr	DoIO(a6)
	move.l	(sp)+,a1
	move	#4,28(a1)
	jmp	DoIO(a6)
;	rts

MotOff:	* stop the drive's motor
	move.l	ioreq(a5),a1
	move	#9,28(a1)
	clr.l	36(a1)
	jmp	DoIO(a6)
;	rts

* Display 'guru' alert
* a0 must contain the address of the text to display
MyAlert:
	movem.l	d1-a6,-(sp)
	moveq	#0,d0		;alert number
	moveq	#$7f,d1		;alert height
	move.l	intbase(a5),a6
	jsr	DisplayAlert(a6)
	movem.l	(sp)+,d1-a6
	tst.l	d0
	rts

dos.name	dc.b "dos.library",0
intname		dc.b "intuition.library",0

;1st 4 bytes of an IFF file
form.txt	dc.b "FORM"

* Format of text:
* 0,x,y,'text',0,1
*	 or
* 0,x,y,'text',0,0 (last line of text)

alert.txt:
 dc.b 0,20,20,"IFF-ILBM Ripper 1.0 by Frédéric BASSALER",0,1
 dc.b 0,20,40,"Searches memory for IFF-ILBM pictures"
 dc.b " & writes them on disk sectors",0,1
 dc.b 0,20,50,"Use PicRestore to restore them.",0,1
 dc.b 0,20,75,">> INSERT TARGET DISK <<",0,1
 dc.b 0,20,90,"WARNING - All datas on disk will be lost!",0,1
 dc.b 0,20,110,"Left = Search *** Right = Abort",0,0

noerr.txt	 dc.b 0,20,50,"Found "
num.txt		 dc.b "xx pics!",0,0
err.txt		 dc.b 0,20,50,"Error!",0,0

	IFD	DBUG
trackname dc.b	"trackdisk.device",0
	even
tdport	dcb.b	34,0
tdreq	dcb.b	56,0
	ENDC

End:
	dcb.b	512*2,0
