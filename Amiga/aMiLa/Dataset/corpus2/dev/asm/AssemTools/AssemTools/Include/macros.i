; vers. 1.3	07.08.89

strcpy	macro	*srcreg,*dstreg
ps.\@a	move.b	(\1)+,(\2)+
	bne.s	ps.\@a
	endm

strlen	macro	*strreg,len
	move.l	\1,\2
ps.\@a	tst.b	(\1)+
	bne.s	ps.\@a
	sub.l	\2,\1
	exg.l	\1,\2
	subq.l	#1,\2
	endm

pstra	macro	reg,*string
	ifnc	'\2','a1'
	move.l	\2,a1
	endc
ps.\@a	move.b	(a1)+,(\1)+
	bne.s	ps.\@a
	subq.w	#1,\1
	endm

;Example:  pstra   a0,buffer(pc)	-> copies the contents of BUFFER
;	   pstra   a0,(a4)
;
;does copy the string into the current address of <reg>
;and increments <reg> respectively. a null is added
;to the end address of <reg>.


pstrn	macro	reg,*string,(UWORD)len
	ifnc	'\2','a1'
	move.l	\2,a1
	endc
	ifnc	'\3','d1'
	move.w	\3,d1
	endc
	subq.w	#1,d1
ps.\@a	move.b	(a1)+,(\1)+
	dbf	d1,ps.\@a
	clr.b	(\1)
	endm

;does copy a given number of characters into the current addr
;of <reg>. <reg> is incremented respectively. A null is
;added into the end of target string.


lstr	macro	reg,string
	lea	ps.\@a(pc),\1
	ifc	'\3',''
	bra.s	ps.\@b
	endc
	ifnc	'\3',''
	\3	\4
	endc
ps.\@a	dc.b	\2
	dc.b	0
	ds.w	0
ps.\@b
	endm

;Example:	lstr	a0,<'-ADD'>
;loads the address of a string into an address register
;		lstr	a0,<'Error: '>,rts
;		lstr	a0,<'Illegal Quantity'>,bra,stderr


pstr	macro	reg,string
	lea	ps.\@a(pc),a1
ps.\@b	move.b	(a1)+,(\1)+
	bne.s	ps.\@b
	subq.w	#1,\1
	bra.s	ps.\@c
ps.\@a	dc.b	\2
	dc.b	0
	ds.w	0
ps.\@c
	endm

;Example:  pstr    a0,<' - Error code '>
;puts the string into the current address of <reg>
;and increments <reg> respectively. a null is added
;to the end address of <reg>.


pnull	macro	reg
	clr.b	(\1)+
	endm

;Needs no example, eh


plf	macro	reg
	move.b	#10,(\1)+
	endm

;Needs no example, eh


pchr	macro	reg,chr
	move.b	\2,(\1)+
	endm

;Needs no example, eh


; MACROS FOR ALLOCMENU

;	.menu	'Project'
;	.item	'New',<'IW',180>
;	.item	'Open',,'O'
;	.item	'Save',,'S'
;	.item	'Save As',,'J'
;	.item	'Print'
;	.subitm	'Draft',<'IW',60>
;	.subitm	'NLQ'
;	.item	'Quit',,'Q'
;	dc.w	0

.menu	macro	'name',<specdata>
	dc.b	1,0
	dc.w	.menuE\@-.menuB\@
.menuB\@
	ifnc	'\2',''
	dc.w	\2
	endc
.menuE\@
	dc.b	\1
	dc.b	0
	ds.w	0
	endm

.item	macro	'name',<specdata> [,'cmd']
	dc.b	2
	ifnc	'\3',''
	dc.b	\3
	endc
	ifc	'\3',''
	dc.b	0
	endc
	dc.w	.itemE\@-.itemB\@
.itemB\@
	ifnc	'\2',''
	dc.w	\2
	endc
.itemE\@
	dc.b	\1
	dc.b	0
	ds.w	0
	endm

.subitm	macro	'name',<specdata> [,'cmd']
	dc.b	3
	ifnc	'\3',''
	dc.b	\3
	endc
	ifc	'\3',''
	dc.b	0
	endc
	dc.w	.subitmE\@-.subitmB\@
.subitmB\@
	ifnc	'\2',''
	dc.w	\2
	endc
.subitmE\@
	dc.b	\1
	dc.b	0
	ds.w	0
	endm

