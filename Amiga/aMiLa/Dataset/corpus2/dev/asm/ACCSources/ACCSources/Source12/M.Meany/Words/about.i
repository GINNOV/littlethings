
About		lea		AboutWin,a0
		CALLINT		OpenWindow
		move.l		d0,d7
		beq		NoAbout

		move.l		d0,a0
		move.l		wd_UserPort(a0),a3
		move.l		wd_RPort(a0),a5

		move.l		#AboutText,AboutITPtr
		moveq.l		#20,d6		line counter
		moveq.l		#0,d5		y-offsett
DoAboutText	move.l		a5,a0		rastport
		lea		AboutIT,a1	IText ptr
		moveq.l		#0,d0		x-offset
		move.l		d5,d1		y-offset
		CALLSYS		PrintIText	print next line

		add.l		#49,AboutITPtr	point at next line
		add.l		#8,d5		bump y-offset
		dbra		d6,DoAboutText	print next line


WaitAbout	move.l		a3,a0		a0-->user port
		CALLEXEC	WaitPort	wait for something to happen
		move.l		a3,a0		a0-->window pointer
		CALLSYS		GetMsg		get any messages
		tst.l		d0		was there a message ?
		beq.s		WaitAbout	if not loop back
		move.l		d0,a1		a1-->message
		move.l		im_Class(a1),d2	d2=IDCMP flags
		CALLEXEC	ReplyMsg	answer os or it get angry

		cmp.l		#GADGETDOWN,d2	OK gadget hit ?
		bne.s		WaitAbout

		move.l		d7,a0
		CALLINT		CloseWindow
NoAbout		rts


AboutWin
	dc.w	92,0
	dc.w	425,199
	dc.b	1,2
	dc.l	GADGETDOWN
	dc.l	WINDOWDEPTH+ACTIVATE+NOCAREREFRESH
	dc.l	AboutGadg
	dc.l	0
	dc.l	AboutName
	dc.l	0
	dc.l	0
	dc.w	5,5
	dc.w	640,200
	dc.w	WBENCHSCREEN
;AboutName
;	dc.b	'   Words      © M.Meany     May 1991',0
;AboutName
;	dc.b	'   SOFTVILLE PD  TEL : (0705) 266509',0
AboutName
	dc.b	' AMIGANUTS UNITED PD  TEL: (O7O3) 78568O',0



	even
AboutGadg
	dc.l	0
	dc.w	20,182
	dc.w	389,13
	dc.w	0
	dc.w	GADGIMMEDIATE
	dc.w	BOOLGADGET
	dc.l	AboutBorder
	dc.l	0
	dc.l	AboutIText
	dc.l	0
	dc.l	0
	dc.w	0
	dc.l	0
AboutBorder
	dc.w	-2,-1
	dc.b	1,2,RP_JAM1
	dc.b	5
	dc.l	AboutVectors
	dc.l	0
AboutVectors
	dc.w	0,0
	dc.w	392,0
	dc.w	392,14
	dc.w	0,14
	dc.w	0,0
AboutIText
	dc.b	2,0,RP_JAM2,0
	dc.w	10,3
	dc.l	0
	dc.l	GadgText
	dc.l	0
GadgText
	dc.b	'OK  OK  OK  OK  OK  OK  OK  OK  OK  OK  OK  OK',0
	even

AboutIT	dc.b	1,0,RP_JAM2,0
	dc.w	20,11
	dc.l	0
AboutITPtr
	dc.l	AboutText
	dc.l	0


; About text. 48 characters per line, 21 lines.

AboutText
	dc.b	" This version of Words is shareware. The maximum",0
	dc.b	"number of words that can  be loaded has been set",0
	dc.b	"to 1O,OOO. Send £5.00 to me at the address below",0
	dc.b	"for unrestricted version supplied with a 3O,OOO+",0
	dc.b	"word glossary. You will also receive news of any",0
	dc.b	"major updates to the  program and  completion of",0
	dc.b	"any  foreign  language  glossaries  that  become",0
	dc.b	"available. Assembly source may be made available",0
	dc.b	"on request.                                     ",0
	dc.b	"                                                ",0
	dc.b	"             Mark Meany,                        ",0
	dc.b	"             1 Cromwell Road,                   ",0
	dc.b	"             Southampton,                       ",0
	dc.b	"             Hant's,                            ",0
	dc.b	"             England.                           ",0
	dc.b	"                                                ",0
	dc.b	"Special thanks to  Derrick  Carter  for his work",0
	dc.b	"on the glossary and Nico  Francois for releasing",0
	dc.b	"PowerPacker library, which this program uses.   ",0
	dc.b	"The program  also uses the  ARP  library, thanks",0
	dc.b	"guys, whoever you are !  © M.Meany, May 91.     ",0
