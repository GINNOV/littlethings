
* PUSH/POP D0-D6/A0
* ZEROM D0-D6/A0-A6
* ZERO  D0
* ZEROA A0
* MULU10 D5 :NOT D7!
* MOUSE NOTPRESSED
* NOMOUSE WAIT UNTIL RELEASE!
* RMOUSE NOTPRESSED
* BLITWAIT An \
* NOMASK An 	|-An is $dff000
* CATCHVB An  /

PUSH		MACRO
	movem.l \1,-(a7)
	ENDM
POP		MACRO
	movem.l	(a7)+,\1
	ENDM

ZEROM 	MACRO 			* Zero multiple registers
		movem.l		Blanks(a5),\1	* Needs sufficient No. of
		ENDM				* blank long words

ZERO		MACRO 			* Clear data register
		moveq.l		#0,\1
		ENDM

ZEROA 	MACRO 			* Clear address register
		suba.l		\1,\1
		ENDM

*	Multiply a data register (d0-d6) by 10.  A standard Mulu uses
*	74 processor cycles, this macro uses 44, (or 20 without the
*	stack access!)  Quite a saving.
*	Note : D7 cannot be used.	No register corruption

*	MULU10	d5 * Multiply contents of d5 by 10

MULU10		MACRO
		move.l		d7,-(sp)
		move.w		\1,d7
		add.w 	\1,\1
		add.w 	\1,\1
		add.w 	d7,\1
		add.w 	\1,\1
		move.l		(sp)+,d7
		ENDM

mouse Macro
 btst #6,Ciaapra
 bne.s \1
 Endm

nomouse	macro
nm_\@ btst	#6,Ciaapra
 beq.s nm_\@
 endm

rmouse Macro
 btst #10,$16(\1)
 bne.s \2
 Endm


Blitwait MACRO
bw_\@ btst #6,dmaconr(\1)
	bne.s bw_\@
	ENDM

Nomask	MACRO
	move #$ffff,bltafwm(\1)
	move #$ffff,bltalwm(\1)
	ENDM

CatchVB MACRO
vb1_\@:
	btst #0,vposr+1(\1)
	beq.s vb1_\@
vb2_\@:
	btst #0,vposr+1(\1)
	bne.s vb2_\@
	ENDM



