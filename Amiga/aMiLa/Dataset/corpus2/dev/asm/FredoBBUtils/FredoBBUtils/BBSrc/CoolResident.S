* Installer un programme résistant au reset
* par l'intermédiaire du vecteur CoolCapture

* Install a resident program via CoolCapture Vector


AllocMem	equ	-198
AllocAbs	equ	-204
CopyMemQuick	equ	-630

CoolCapture	equ	46

InstallProg:
	lea	FinProgramme(pc),a0
	lea	ResetProgramme(pc),a1
	suba.l	a1,a0
	move.l	a0,d0
	addq	#4,d0
	moveq	#-4,d1
	and.l	d1,d0		;aligner sur multiple de 4
	move.l	d0,d2
	moveq	#$1,d1		;public mem
	move.l	4.w,a6
	jsr	AllocMem(a6)
	tst.l	d0
	beq.s	fin_inst
	move.l	d0,a1
	move.l	a1,CoolCapture(a6)	;adr programme résident
	lea	ResetProgramme(pc),a0
	move.l	d2,d0
	jsr	CopyMemQuick(a6)
	clr	82(a6)
	lea	34(a6),a0
	moveq	#(82-34)/2,d0
	clr	d1
ok:	add	(a0)+,d1
	dbf	d0,ok
	not	d1
	move	d1,82(a6)
fin_inst:
	moveq	#0,d0
	rts

ResetProgramme:
	lea	ResetProgramme(pc),a1
	lea	FinProgramme(pc),a0
	suba.l	a1,a0
	move.l	a0,d0
	move.l	a6,-(sp)
	move.l	4.w,a6
	jsr	AllocAbs(a6)
	move.l	(sp)+,a6

*********** Entrer ici le programme *********************
* type in program to be executed at system (warm)reboot *


*********************************************************
FinProgramme:
