
; Macro and structure defenition file for hardware programming.

; M.Meany, Sept 1992.

		LIST
*** Macros.i v1.00, by M.Meany ***
		NOLIST

*****	Structures

; list head structure

lh_head		=		0
lh_tail		=		4
lh_tailpred	=		8
lh_SIZEOF	=		12

; list node structure

ln_succ		=		0
ln_pred		=		4
ln_size		=		8
ln_SIZEOF	=		12


*****	Macros

**	General purpose macros

; Push registers contents onto stack -- use for > 3 registers only

PUSH		macro
		movem.l		\1,-(sp)
		endm

PUSHALL		macro
		PUSH		d0-d7/a0-a6
		endm
		
; Retrieve registers contents from stack

PULL		macro
		movem.l		(sp)+,\1
		endm

PULLALL		macro
		PULL		d0-d7/a0-a6
		endm
		
; fast multiply by 10

TIMES10		macro		dn
		add.l		\1,\1			x2
		move.l		\1,-(sp)
		asl.l		#2,\1			x8
		add.l		(sp),\1
		addq.l		#4,sp
		endm

**	Copper Macros

CMOVE		macro		register,value
		dc.w		\1,\2
		endm

CWAIT		macro		x,y		0<=x<=127, 0<=y<=255
		dc.w		(\2<<8)!(\1<<1)!1,$fffe
		endm

CEND		macro
		dc.w		$ffff,$fffe
		endm
		
; example copper list:
;
;CopList	CWAIT		0,200		wait for line 200
;		CMOVE		COLOR00,$0f00	background to red
;		CEND				end of list

; wait for copper to request an interrupt

WAITCOP		macro
_wc\@		btst.b		#4,$dff01f		copper interrupt?
		beq.s		_wc\@			no, keep waiting
		move.w		#COPER,$dff000+INTREQ	clear request
		endm

; Start a specified copper list

STARTCOP	macro		addr
		move.l		\1,$dff000+COP1LCH
		move.w		#0,$dff000+COPJMP1
		endm

; Put bitplane pointers into a copper list

COPBPL		macro		cop, bpl, size, depth

		lea		2+\1,a0
		move.l		#\2,d2
		move.l		#\3,d1
		moveq.l		#\4-1,d0
		
.copb\@		swap		d2
		move.w		d2,(a0)
		addq.l		#4,a0
		swap		d2
		move.w		d2,(a0)
		addq.l		#4,a0
		add.l		d1,d2
		dbra		d0,.copb\@
		
		endm

; Put bitplane pointers into a copper list

RCOPBPL		macro		cop, bpl, size, depth

		lea		2+\1,a0
		move.l		\2,d2
		move.l		#\3,d1
		moveq.l		#\4-1,d0
		
.copb\@		swap		d2
		move.w		d2,(a0)
		addq.l		#4,a0
		swap		d2
		move.w		d2,(a0)
		addq.l		#4,a0
		add.l		d1,d2
		dbra		d0,.copb\@
		
		endm

; Put bitplane pointers and colour information into a copper list

; CMAP must be behind the bitplanes.

COPBPLC		macro		cop, bpl, size, depth
		lea		2+\1,a0
		move.l		#\2,d2
		move.l		#\3,d1
		moveq.l		#\4-1,d0
		
.copb\@		swap		d2
		move.w		d2,(a0)
		addq.l		#4,a0
		swap		d2
		move.w		d2,(a0)
		addq.l		#4,a0
		add.l		d1,d2
		dbra		d0,.copb\@

		subq.l		#2,a0
		move.l		d2,a1
		moveq.l		#2<<(\4-1)-1,d0		num colours
		move.l		#$180,d1		1st colour reg offset
.copc\@		move.w		d1,(a0)+
		addq.w		#2,d1			bump offset
		move.w		(a1)+,(a0)+
		dbra		d0,.copc\@
		endm

; Put colour information into a copper list

COPCMAP		macro		cop, cmap, depth
		lea		\1,a0
		move.l		#\2,a1
		moveq.l		#2<<(\3-1)-1,d0		num colours
		move.l		#$180,d1		1st colour reg offset
.copc\@		move.w		d1,(a0)+
		addq.w		#2,d1			bump offset
		move.w		(a1)+,(a0)+
		dbra		d0,.copc\@
		endm

; Wait for start of vertical blank interrupt --- disables VBL interrupts!

CATCHVBL	macro
		move.w		#VERTB,$dff000+INTENA
		move.w		#VERTB,$dff000+INTREQ
.vbl\@		btst		#5,$dff01f
		beq.s		.vbl\@
		move.w		#VERTB,$dff000+INTREQ
		endm

; Busy-wait for blitter to finish

QBLITTER	macro
.QBlit\@	btst		#6,$dff002
		bne.s		.QBlit\@
		endm

; Set and start a level 3 interrupt

SETVERTB	macro		address
		move.w	#VERTB!COPER!BLIT,INTENA+$dff000  stop current L3 int
		move.l	\1,$6c
		move.w	#SETIT!INTEN!VERTB,INTENA+$dff000 start new vertb int
		endm

**	List handling macros, promarily for bobs and memory management

NEWLIST		macro				a0->head
		move.l		a0,(a0)
		addq.l		#lh_tail,(a0)
		clr.l		lh_tail(a0)
		move.l		a0,lh_tail+ln_pred(a0)
		endm

TSTLIST		macro				a0->head
		cmp.l		lh_tail+ln_pred(a0),a0
		endm

IFEMPTY		macro				a0->head, \1=label
		cmp.l		lh_tail+ln_pred(a0),a0
		beq		\1
		endm

ADDHEAD		macro				a0->head, a1->node
		move.l		(a0),d0
		move.l		a1,(a0)
		movem.l		d0/a0,(a1)
		move.l		d0,a0
		move.l		a1,ln_pred(a0)
		endm

REMHEAD		macro				a0->head
		move.l		(a0),a1
		move.l		(a1),d0
		beq.s		_remH\@
		move.l		d0,(a0)
		exg.l		d0,a1
		move.l		a0,ln_pred(a1)
_remH\@		endm

REMOVE		macro				a0->node
		move.l		(a0),a1
		move.l		ln_pred(a0),a0
		move.l		a1,(a0)
		move.l		a0,ln_pred(a1)
		endm


**	Font Equates & Macros	**

; font control codes.

FEND		=		0		end of text
FEXIT		=		1		soft exit from routine
FCOLOUR		=		2		change colour
FPOS		=		3		change position
FFONT		=		4		change font
FCENTER		=		5		centralise text
FMODE		=		6		change draw mode
FSINGLE		=		7		toggle print 1 char per call
FSTRING		=		8		switch off 1 char mode

SPLAT		=		0		drawing mode 0
BLEND		=		1		drawing mode 1

; font macros to help initialise things

FONTSCREEN	macro		addr, {w}, {h}, {d}

		move.l		\1,_FontBpl		set address
		
		IFNC		'','\2'
		move.l		\2,_BplW
		ENDC

		IFNC		'','\3'
		move.l		#\3,_BplH

		IFNC		'','\2'
		move.l		#\2*\3,_BplSize
		ENDC

		ENDC

		IFNC		'','\4'
		move.l		#\4,_BplD
		ENDC

		ENDM

SETFONT		macro		number, address

		move.l		\2,_Font1Ptr+(\1-1)*4
		
		endm

*****	Useful equates

ANYMEM		=		0
CHIPMEM		=		2
FASTMEM		=		4
CLEARMEM	=		$10000

OLDFILE		=		1005
NEWFILE		=		1006
ACCESS_READ	=		-2
ACCESS_WRITE	=		-1
