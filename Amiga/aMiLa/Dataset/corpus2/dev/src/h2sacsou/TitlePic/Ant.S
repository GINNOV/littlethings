ùúùúÿËGgÿËGgÿËGgÿËGgÿËGgÿËGgÿËGgÿËGgÿËGgRaster=0

Track=1		;0=ASM-One version
		;1=Track version

MyDmacon=%01111101111
;	  abcdefghhhh
; a = Blitter nasty
; b = Enable DMA activity (always set this!)
; c = Bitplane enable
; d = Copper enable
; e = Blitter enable
; f = Sprite enable
; g = Disk enable
; h = Audio channels enable

MyIntena=%100000000100000
;	  abcdeeeefghijkl
; a = Enable interrupts
; b = Lev. 6 External interrupt
; c = Lev. 5 Disk sync found
; d = Lev. 5 Serial port receive buffer full
; e = Lev. 4 Audio ch. 3-0 block finished
; f = Lev. 3 Blitter finished
; g = Lev. 3 Vertical blank
; h = Lev. 3 Copper
; i = Lev. 2 I/O Ports and timers
; j = Lev. 1 Software
; k = Lev. 1 Disk block finished
; l = Lev. 1 Serial port transmit buffer empty

		SECTION	Kode,code_c


		JumpPtr	Begin

*******************************************************************************
**Macros
*******************************************************************************
WaitBlt:	macro
.vent\@:	btst	#14,$dff002
		bne	.vent\@
		endm

*******************************************************************************
**Initialisering
*******************************************************************************
Begin:
		IF	Track=0
		move.w	Intenar+Base,OldIntena
		move.w	Dmacon+Base,OldDmacon
		move.w	#$7fff,Intena+Base
		move.w	#$7fff,Dmacon+Base
		move.w	#$7fff,Intreq+Base

		move.l	(Lev3Base).w,OldIrq3
		ELSE
		move.l	#Lev3Irq,(Lev1Base).w
		rts
		ENDC


		lea	Planer+2,a0
		move.l	#(Pic+32+0*40),d0
		moveq	#4-1,d1
.loop		move.w	d0,4(a0)
		swap	d0
		move.w	d0,(a0)
		swap	d0
		add.l	#256*40,d0
		addq.w	#8,a0
		dbra	d1,.loop

		move.l	#Screen,d0
		move.w	d0,4(a0)
		swap	d0
		move.w	d0,(a0)

		bsr	TypeScreen|.ting

		IF	Track=0
		move.l	#Lev3Irq,(Lev3Base).w
		waitblt

		move.w	#MyDmacon+$8000,Dmacon+Base
		move.w	#MyIntena+$8000,Intena+Base

Wait:
		move.w	IWantOut(pc),d0
		beq.b	wait

*******************************************************************************
**Exit to AmigaDOS
*******************************************************************************
ExitToDos:
		move.w	#$7fff,Intena+Base
		move.w	#$7fff,Dmacon+Base
		ENDC
		rts

VBlank:		dc.w	0
		IF	Track=0
OldIntena:	dc.w	0
OldDmacon:	dc.w	0
OldIrq3:	dc.l	0
IWantOut:	dc.w	0
		ELSE
IWantOut:	EQU	$80
		ENDC

*******************************************************************************
**Level 3 interrupt
*******************************************************************************
Lev3Irq:
		movem.l	d0-a6,-(sp)
		move.l	#Copper,Cop2lch+Base
		move.w	d0,Copjmp2+Base
		move.w	#1,VBlank
*******************************************************************************
		bsr	Faders
		cmp.w	#3,Story
		bne.b	.NoLeft
*******************************************************************************
		move.w	#-1,IWantOut
.NoLeft:	IF	Track=0
		btst	#6,$bfe001
		bne.b	.mus
		move.w	#-1,IWantOut
.mus
		ENDC
		if	Raster=1
		move.w	#$f00,Color00+Base
		endif
		waitblt
		if	Raster=1
		move.w	#$00f,Color00+Base
		endif
		movem.l	(sp)+,d0-a6
		IFEQ	Track-0
		move.w	#$0020,Intreq+Base
		ELSE
		move.w	#$0004,Intreq+Base
		ENDC
		rte


Faders:		move.w	Story(pc),d0
		beq	FadeUp
		subq.w	#1,d0
		beq	TypeScreen
		rts






*******************************************************************************
**
**  Type screen
**
*******************************************************************************
TypeScreen:
.wait	btst	#2,$dff016
	bne.b	.heltud

	lea	Base,a6
	WaitBlt
	move.l	#Screen,Bltdpth(a6)
	move.l	#$01000000,Bltcon0(a6)
	move.w	#0,Bltdmod(a6)
	move.w	#256<<6!20,Bltsize(a6)
	WaitBlt
.ting	lea	Screen+2*40,a6
	lea	PlaneFont,a0
	move.l	TextPtr(pc),a1
.next	tst.b	(a1)
	beq.b	.out
	bsr.b	WriteLine
	bra.b	.next
.out	addq.w	#1,a1
	tst.b	(a1)
	bne.b	.norm
	lea	Text(pc),a1
.norm	move.l	a1,TextPtr

.wait2	btst	#2,$dff016
	beq.b	.wait2
.heltud
	rts

WriteLine:	moveq	#0,d0
	move.b	(a1)+,d0
	cmp.b	#10,d0
	beq.b	.CRLF
	cmp.b	#1,d0
	bne.b	.notvenstre
	moveq	#0,d1	;X-Pos
	bra.b	.printit
.notvenstre	bsr.w	FindPixelSize
	move.w	#320,d1
	sub.w	d3,d1
	cmp.b	#2,d0
	bne.b	.printit
	lsr.w	#1,d1
.printit	moveq	#0,d0
	move.b	(a1)+,d0
	cmp.b	#10,d0
	beq.b	.CRLF
	bsr.b	PrintChar
	add.w	d2,d1
	bra.b	.printit
.CRLF	lea	20*40(a6),a6
	rts


** in:  d0=asciichar
**      d1=pos
**      a0=font
**      a6=screen
** out: d2=charsize
** trashes:
PrintChar:	bra.b	.jump
.wloop	bsr.b	.copybyte
	addq.w	#1,a2
	bsr.b	.copybyte
	lea	35(a2),a2
	lea	38(a3),a3
	dbra	d4,.wloop
	rts
.copybyte	moveq	#0,d5
	move.b	(a2),d5
	ror.w	d3,d5
	or.b	d5,(a3)+
	lsr.w	#8,d5
	or.b	d5,(a3)
	rts
.jump	sub.b	#32,d0
	add.w	d0,d0
	moveq	#0,d2
	moveq	#0,d3
	move.b	FontConverter(PC,d0.w),d3
	move.b	FontConverter+1(PC,d0.w),d2
	cmp.b	#35,d3
	shi	d5
	divu	#36,d3
	move.w	d3,d4
	mulu	#36*17,d4
	swap	d3
	add.w	d3,d4
	lea	(a0,d4.w),a2	;font
	move.w	d1,d3
	move.w	d3,d4
	lsr.w	#3,d4
	lea	(a6,d4.w),a3	;screen
	tst.b	d5
	beq.b	.small
	lea	-2*40(a3),a3
.small	and.w	#7,d3	;scrollvalue
	moveq	#17-1,d4
	cmp.b	#8,d2
	bhi.b	.wloop
.bloop	bsr.b	.copybyte
	lea	36(a2),a2
	lea	39(a3),a3
	dbra	d4,.bloop
	rts

** in:  a1=text
** out: d3=pixelsize
** trashes: d2/d4/a2
FindPixelSize:	move.l	a1,a2
	moveq	#0,d3
.next	moveq	#0,d2
	move.b	(a2)+,d2
	cmp.b	#10,d2
	beq.b	.gotit
	sub.b	#32,d2
	add.w	d2,d2
	moveq	#0,d4
	move.b	FontConverter+1(PC,d2.w),d4
	add.w	d4,d3
	bra.b	.next
.gotit	rts

FontConverter:	dc.b	82,6,86,3,79,8,82,6	 ; SPC - '#'
	dc.b	82,6,82,6,75,8,80,4	 ; '$' - '''
	dc.b	72,6,73,6,96,10,82,6	 ; '(' - '+'
	dc.b	77,4,74,5,76,3,83,11	 ; ',' - '/'
	dc.b	51,8,87,7,88,8,89,8	 ; '0' - '3'
	dc.b	90,8,91,8,92,8,93,8	 ; '4' - '7'
	dc.b	94,8,95,8,78,3,82,6	 ; '8' - ';'
	dc.b	82,6,82,6,82,6,85,8	 ; '<' - '?'
	dc.b	82,6,36,8,37,8,38,8	 ; '@' - 'C'
	dc.b	39,8,40,8,41,8,42,8	 ; 'D' - 'G'
	dc.b	43,8,44,3,45,8,46,8	 ; 'H' - 'K'
	dc.b	47,4,48,12,50,8,51,8 ; 'L' - 'O'
	dc.b	52,8,53,8,54,8,55,8	 ; 'P' - 'S'
	dc.b	56,8,57,8,58,8,59,12 ; 'T' - 'W'
	dc.b	61,8,62,8,63,8,72,6	 ; 'X' - '['
	dc.b	82,6,73,6,82,6,82,6	 ; '\' - '_'
	dc.b	81,8,00,8,01,8,02,8	 ; '`' - 'c'
	dc.b	03,8,04,8,05,8,06,8	 ; 'd' - 'g'
	dc.b	07,8,08,3,09,8,10,8	 ; 'h' - 'k'
	dc.b	11,4,12,12,14,8,15,8 ; 'l' - 'o'
	dc.b	16,8,17,8,18,8,19,8	 ; 'p' - 's'
	dc.b	20,8,21,8,22,8,23,12 ; 't' - 'w'
	dc.b	25,8,26,8,27,8,72,6	 ; 'x' - '{'
	dc.b	82,6,82,6,82,6,82,6	 ; '|' - DEL

	blk.w	32,(82<<8)!6

	dc.b	82,6,82,6,82,6,82,6	 ; SPC - '£'
	dc.b	82,6,82,6,82,6,82,6	 ; '¤' - '§'
	dc.b	82,6,82,6,82,6,82,6	 ; '¨' - '«'
	dc.b	82,6,82,6,82,6,82,6	 ; '¬' - '¯'
	dc.b	82,6,82,6,82,6,82,6	 ; '°' - '³'
	dc.b	82,6,82,6,82,6,82,6	 ; '´' - '·'
	dc.b	82,6,82,6,82,6,82,6	 ; '¸' - '»'
	dc.b	82,6,82,6,82,6,82,6	 ; '¼' - '¿'
	dc.b	82,6,82,6,82,6,82,6	 ; 'À' - 'Ã'
	dc.b	71,8,68,8,64,10,82,6 ; 'Ä' - 'Ç'
	dc.b	82,6,82,6,82,6,82,6	 ; 'È' - 'Ë'
	dc.b	82,6,82,6,82,6,82,6	 ; 'Ì' - 'Ï'
	dc.b	82,6,82,6,82,6,82,6	 ; 'Ð' - 'Ó'
	dc.b	82,6,82,6,69,8,82,6	 ; 'Ô' - '×'
	dc.b	66,10,82,6,82,6,82,6 ; 'Ø' - 'Û'
	dc.b	70,8,82,6,82,8,82,6	 ; 'Ü' - 'ß'
	dc.b	82,6,82,6,82,6,82,6	 ; 'à' - 'ã'
	dc.b	35,8,32,8,28,11,82,6 ; 'ä' - 'ç'
	dc.b	82,6,82,6,82,6,82,6	 ; 'è' - 'ë'
	dc.b	82,6,82,6,82,6,82,6	 ; 'ì' - 'ï'
	dc.b	82,6,82,6,82,6,82,6	 ; 'ð' - 'ó'
	dc.b	82,6,82,6,33,8,82,6	 ; 'ô' - '÷'
	dc.b	30,10,82,6,82,6,82,6 ; 'ø' - 'û'
	dc.b	34,8,82,6,82,8,82,6	 ; 'ü' - 'ÿ'


TextPtr:	dc.l	Text
Text:	dc.b	2,'Welcome to this "hidden" part and',10
	dc.b	10
	dc.b	2,'FUCK YOU!!!',10
	dc.b	10
	dc.b	2,'...for watching this demo',10
	dc.b	10
	dc.b	2,'Instructions:',10
	dc.b	2,'Use RMB to change page!!!!',10
	dc.b	0

	dc.b	2,'Solnova sez:',10
	dc.b	2,'"Enjoy this picture because we don''t"',10
	dc.b	0

	dc.b	1,` After almost a year the promised demo`,10
	dc.b	1,`from the creators of "In the Kitchen"`,10
	dc.b	1,`showed up.`,10
	dc.b	10
	dc.b	1,` "How to Skin a Cat" was planned in`,10
	dc.b	1,`Anarchy and miraculously brought to`,10
	dc.b	1,`life, during a period of 2 months, in`,10
	dc.b	1,`Melon.  The demo has had some sex change`,10
	dc.b	1,`operations and changed character from a`,10
	dc.b	1,`quite anarchistic style to a more`,10
	dc.b	1,`acceptable (and perhaps sophisticated?)`,10
	dc.b	1,`composition, but still with the magic`,10,0

	dc.b	1,`touch that seems to be the typical side`,10
	dc.b	1,`effect of being ex-Rednex members.`,10
	dc.b	10
	dc.b	1,` This product was also decided by the`,10
	dc.b	1,`developers to be the last demo for a`,10
	dc.b	1,`long time and therefore they are`,10
	dc.b	1,`retiring.  They have decided to leave`,10
	dc.b	1,`Melon and so they will, this is their`,10
	dc.b	1,`way of saying goodbye.`,10,0

	dc.b	2,`So what is all this fuzz about..??`,10
	dc.b	10
	dc.b	2,` Well, aparently you posses a great deal`,10
	dc.b	2,`of patience since you've come this`,10
	dc.b	2,`far....  ...and so much for the patience`,10
	dc.b	2,`part.!?`,10
	dc.b	10
	dc.b	2,` I'm Solnova, and I did the Gfx in this`,10
	dc.b	2,`demo by Slammer...  ('cept for the fab`,10
	dc.b	2,`title pic by Mack, that is...) ...and so`,10
	dc.b	2,`much for the bragging part.?!`,10,0

	dc.b	2,` As usual there are some words to be`,10
	dc.b	2,`said, so why not start right away and`,10
	dc.b	2,`sprinkle holy water on the following`,10
	dc.b	2,`persons:`,10
	dc.b	10
	dc.b	2,` Marie, My girlfriend (*)`,10
	dc.b	10
	dc.b	2,` Slammer, My obedient coder..  (?)`,10
	dc.b	10
	dc.b	2,` Nuke'&'Dan/Lemon., The madmen from the`,10
	dc.b	2,`United Kingdom`,10,0

	dc.b	2,` HitHansen/FB, Yet another skinhead from`,10
	dc.b	2,`Utd Jylland`,10
	dc.b	10
	dc.b	2,` Corny/DCS, The ever happy (cap wearing)`,10
	dc.b	2,`viking!`,10
	dc.b	10
	dc.b	2,` Andre'/Crln, Probably the most insane`,10
	dc.b	2,`guy around!`,10
	dc.b	10
	dc.b	2,` Seen/Melon., The fatherly mega leader.`,10,0

	dc.b	2,` ICronite/CC, Low frequent noise on`,10
	dc.b	2,`legs!`,10
	dc.b	10
	dc.b	2,` Milkshake/CC, An almost retired`,10
	dc.b	2,`veteran.`,10
	dc.b	10
	dc.b	2,`Bannasoft/Melon., a 24h-a-day * hunting`,10
	dc.b	2,`machine.`,10
	dc.b	10
	dc.b	2,`Heatseeker/Impulse, A Norwegian friend.`,10,0

	dc.b	2,`Toastmaster/Movement, the 2nd most`,10
	dc.b	2,`insane guy!`,10
	dc.b	10
	dc.b	2,`Plus the attendants at the Fishing Trip`,10
	dc.b	10
	dc.b	2,`Well..`,10
	dc.b	2,`That's about it, sorry for the forgotten`,10
	dc.b	2,`ones.`,10,0

	dc.b	2,` Oh..  I'm glad that it's all over by`,10
	dc.b	2,`now...  This demo has really been`,10
	dc.b	2,`exhausting (!), especially the 3 last`,10
	dc.b	2,`days before the party.  Slammer came`,10
	dc.b	2,`Wednesday the 26th of May, so we have`,10
	dc.b	2,`worked on the demo almost constantly for`,10
	dc.b	2,`3 days..  The music arrived on Thursday,`,10
	dc.b	2,`just in time (Thanks mate!  By the way I`,10
	dc.b	2,`need your new address so I can mail your`,10
	dc.b	2,`fish!) The childish "cat" drawing is a`,10
	dc.b	2,`real child's work, it was done by my 7`,10
	dc.b	2,`year old nephew, and then scanned and`,10,0

	dc.b	2,`finished in Dpaint by me.  The mean`,10
	dc.b	2,`looking ant in the background was drawn`,10
	dc.b	2,`a 100 percent by me in Dpaint, but it`,10
	dc.b	2,`was taken from "Dragon Magazine" issue`,10
	dc.b	2,`178 and then modified a bit (fancy`,10
	dc.b	2,`stuff..!) The 1 plane faces in the demo`,10
	dc.b	2,`were taken from a Danish cocoa milk`,10
	dc.b	2,`brand named "Matilde", watch out for`,10
	dc.b	2,`her, she can be a real bitch!  The title`,10
	dc.b	2,`picture by me, was taken from a Danish`,10
	dc.b	2,`comic book named "Valhalla", not scanned`,10
	dc.b	2,`but drawn in Dpaint too...`,10,0

	dc.b	10
	dc.b	10
	dc.b	10
	dc.b	2,` I wonder if I'm the only picture`,10
	dc.b	2,`ripping guy around, nah..  I'm probably`,10
	dc.b	2,`just the most honest one...`,10
	dc.b	10
	dc.b	10
	dc.b	2,`      ...I'm off`,10
	dc.b	10
	dc.b	10
	dc.b	2,`...and Slammer takes over...`,10,0


	dc.b	2,'Goddam....  Oh my...  I''m drunk and',10
	dc.b	2,'nobody knows what this scroller''ll',10
	dc.b	2,'contain...  But it''s guaranteed to be',10
	dc.b	2,'strange :) Hohum...  just finished reading',10
	dc.b	2,'Neuromancer (english version (uhauha))...',10
	dc.b	2,'Focken great!!!!  Go down and buy it',10
	dc.b	2,'NOW!!!  So, why do I write a scroller?',10
	dc.b	2,'Well why not? Heck, scrollers are a',10
	dc.b	2,'coders way of masscommunicating to a big',10
	dc.b	2,'audience... Non-coders write articles',10
	dc.b	2,'to RAW instead. hmmmm...  increasingly',10
	dc.b	2,'strange mood here...  right now my',10,0

	dc.b	2,'wonderful A500 is playing the FishTrip',10
	dc.b	2,'tune (sorry, don''t know the real name,',10
	dc.b	2,'by Andre, the MASTER!!!).  I''m typing',10
	dc.b	2,'on my 1200 (nice computer, get one)..',10
	dc.b	2,'Just watched "Freddy is back"-demo from',10
	dc.b	2,'Paradox and it rules big time!!!',10
	dc.b	2,'Incredible how he made a good demo out',10
	dc.b	2,'of one routine...  I mean, take a look',10
	dc.b	2,'at THIS crap...  Several routines but it',10
	dc.b	2,'sucks!!! Whooops, when you''re drunk you',10
	dc.b	2,'get friendly...  here goes:',10,0

	dc.b	1,`HitHansen/Funky Buddhas :  Take care, you`,10
	dc.b	3,`hear?  And make the music... (Let it him`,10
	dc.b	3,`'em...  NOT!!!!!)`,10
	dc.b	1,`Jones/STB :  Well, eventually I WILL visit`,10
	dc.b	3,`you...  Be ready!!!`,10
	dc.b	1,`ICronite/Camel Corp.  :  Stop sunbathing`,10
	dc.b	3,`and CODE!!!  I'm looking forward to`,10
	dc.b	3,`the next demo from you...  (Kick that ass! :)`,10
	dc.b	1,`Milkshake/Camel Corp.  :  I hear you sold`,10
	dc.b	3,`your computer???? Why?????`,10
	dc.b	1,`Solnova/Tegning :  Hum, well it had to`,10
	dc.b	3,`happen...  Now what?  Let's make the demo`,10,0

	dc.b	3,`for XMas and hope there's a party it can`,10
	dc.b	3,`win (heehee :)`,10
	dc.b	1,`Quackbuster/STB :  Why haven't I received`,10
	dc.b	3,`EC????  Send it you *CENSORED*`,10
	dc.b	1,`Saviour/Complex :  Hope you're getting off`,10
	dc.b	3,`with that 15 or 16 year old girl of`,10
	dc.b	3,`yours...  What was her name again?  And for`,10
	dc.b	3,`the record, next time you're gonna smoke`,10
	dc.b	3,`TELL ME!!!!  ;)`,10
	dc.b	1,`Gargoyle/Parasite :  Nice talk we had at`,10
	dc.b	3,`the Gathering '93...  You're a cool dude`,10
	dc.b	3,`(but you need some gay contacts...?)`,10,0

	dc.b	2,`Interrupt level 7 (NMI) here:  Uf, "»Ja«`,10
	dc.b	2,`PILSNER" tastes like shit!!!  You can probably`,10
	dc.b	2,`only get it in "Jaco" so don't buy your`,10
	dc.b	2,`stuff there!!!!!`,10
	dc.b	1,`I.B.M./Crystal :  Ugh, sorry about the`,10
	dc.b	3,`intro....  It WILL be finished...`,10
	dc.b	3,`eventually...  maybe....  if I get the time...`,10
	dc.b	3,`and I feel like it....  c ya...`,10
	dc.b	1,`Estrup/STB:  Oh no!  My account's expired....`,10
	dc.b	3,`I don't live anymore...  is there a life`,10
	dc.b	3,`outside the matrix?  And, more importantly,`,10
	dc.b	3,`where is EC?`,10,0

	dc.b	1,`Bored of Himself :  Well, I'll get a new`,10
	dc.b	3,`account somehow....  So what's your addy?`,10
	dc.b	3,`An' make the game good you hear?`,10
	dc.b	1,`Castor/Warpigs : Lene og Svend!!! I thought`,10
	dc.b	3,`you were going to Frederiks birthday... catch`,10
	dc.b	3,`you some other time... Hope you are doing some`,10
	dc.b	3,`code.`,10
	dc.b	1,`Dr.  What?/Direct :  Looooooong time no`,10
	dc.b	3,`see/hear/talk...  Must have been one year or`,10
	dc.b	3,`more!!!  What are you guys up to now?  Think`,10
	dc.b	3,`I'll call you up some time...  If I have some`,10
	dc.b	3,`spare cash...  The payphone's expensive :)`,10,0

	dc.b	1,`Asbjørn Præst/Kødsovs :  Fraktaler, fraktaler,`,10
	dc.b	3,`fraktaler!!!  Make someting INTERESTING!!!`,10
	dc.b	3,`heard ya got 13 in 3-års opgave (or was it`,10
	dc.b	3,`11?)...  anyway ...  Congrats!!!  (Ehehe my`,10
	dc.b	3,`3d-fractal will beat any of your shit btw...`,10
	dc.b	3,`You just wait!!!!  ;)`,10
	dc.b	1,`Stefan/Kødsovs :  Arg, why don't you guys get`,10
	dc.b	3,`some HANDLES, so it is possible to make a`,10
	dc.b	3,`decent greetslist???  Fuck, you are secret`,10
	dc.b	3,`(du er hem'lig!)...  svensk lancier....`,10
	dc.b	3,`and with HitHansen....  *shake head*`,10,0

	dc.b	1,`V.A.G.  :  1200 rules, no?  Hope you like`,10
	dc.b	3,`this little thing.  Took me ages to code`,10
	dc.b	3,`somehow...  Love being inactive....  ;) IRC`,10
	dc.b	3,`rules...  (but don't FSP...  hope they didn't`,10
	dc.b	3,`get you?) Thanks for helping me order a`,10
	dc.b	3,`german 1200...  shit it never turned up here`,10
	dc.b	3,`though...  ;)`,10
	dc.b	1,`Jugi/Complex :  Jeeeeesus, you finns are`,10
	dc.b	3,`weirrrd....Think I'll visit a finnish party`,10
	dc.b	3,`once...  (just once, you have to :)...  you`,10
	dc.b	3,`seem to spend more time on hotsex than on`,10
	dc.b	3,`amiga....  or is that`,10,0

	dc.b	1,`Tai-Pan/Complex :  Yeah, my big hero!!!  I`,10
	dc.b	3,`am just a humble slave willing to do as you`,10
	dc.b	3,`command.  I am just grateful to talk to`,10
	dc.b	3,`you...  *bow*..  I wonder if I'll ever get`,10
	dc.b	3,`my blitter stuff working as I was bitching`,10
	dc.b	3,`about...`,10
	dc.b	1,`Tibo :  WHY don't you get an IRC-handle`,10
	dc.b	3,`that's the same as your scene-handle???`,10
	dc.b	3,`Take a look at Jugi, Saviour, Estrup and`,10
	dc.b	3,`me!!! Shit I can't remember your handle or`,10
	dc.b	3,`anything...  Been three months (at least!)`,10
	dc.b	3,`without IRC...  Catch you there sometime!`,10,0

	dc.b	1,`ALFred (Doc Psi/Zenith):  Hooooaaaaarrrr!!!!`,10
	dc.b	3,`WHERE is your ten-disk demo????  Nice`,10
	dc.b	3,`meeting you at the party '92 (same to you,`,10
	dc.b	3,`Tibo, btw!!!)...  And why did I get a`,10
	dc.b	3,`Toblerone?  You guys had a bet or`,10
	dc.b	3,`something about how old I was??? (Heck`,10
	dc.b	3,`I look young but I'm 19..  same as Tibo`,10
	dc.b	3,`but he looks like he's 30!!!! (no shit...`,10
	dc.b	3,`get rid of that beard!!!!  you told me`,10
	dc.b	3,`that you had a beard but I never`,10
	dc.b	3,`expected THAT!!!))`,10,0

	dc.b	1,`Perplex/Spaceballs :  Oh no, why`,10
	dc.b	3,`Spaceballs????  Pure Mental Coders were`,10
	dc.b	3,`not you I guess...  or maybe they`,10
	dc.b	3,`were...  too much "mental" for you?  (And`,10
	dc.b	3,`don't SavBot that much :)`,10
	dc.b	1,`Savage/I.C.E.  :  Whops, sorry long time`,10
	dc.b	3,`no IRC...  Shit I'm looking forward to`,10
	dc.b	3,`getting a new account so I can into some`,10
	dc.b	3,`hot swapping again!!!! d:-P ...  And why`,10
	dc.b	3,`do you HAVE to check the email-addy of`,10
	dc.b	3,`the user?? Impossible to swap using a`,10
	dc.b	3,`"friends" account...  grrrrr ;)`,10,0

	dc.b	1,`U4ia/Megawatts : IRC-maniac!!!! Each time`,10
	dc.b	3,`I get on you're there or you get on while`,10
	dc.b	3,`I'm there!!!! You can't stop now! You're`,10
	dc.b	3,`addicted... just try...`,10
	dc.b	1,`ABACUSMUD : Yes!!!! The *BEST* mud on`,10
	dc.b	3,`InterNet!!!! If you want to 1) ruin your`,10
	dc.b	3,`studying, 2) take a trip into hyperspace,`,10
	dc.b	3,`3) meet extremely cool dudes and dudettes,`,10
	dc.b	3,`then type "telnet abacusmud.hgs.se 4080" `,10
	dc.b	3,`.... beware... it won't let you go when you`,10
	dc.b	3,`are there.. you have been warned...`,10,0


	dc.b	2,`Ok break here.... Just saw some oldtimers`,10
	dc.b	2,`(demos)... And amongst them "In the`,10
	dc.b	2,`Kitchen" and, more importantly, the`,10
	dc.b	2,`review from Top Secret 11.... Hrmph...`,10
	dc.b	2,`personally I think that it's the best`,10
	dc.b	2,`demo I've done, TFG :) And, MUD, the`,10
	dc.b	2,`titlepic is NOT from Mystix but from`,10
	dc.b	2,`Facet! Anyway I can only agree with TFGs`,10
	dc.b	2,`rating of the demos from the Hurricane`,10
	dc.b	2,`party... But, MUD, ok the demo itself is too`,10
	dc.b	2,`short, but there is not too few routines.`,10
	dc.b	2,`Heck I could EASILY have made it twice as`,10
	dc.b	2,`long by putting BORING texts between each`,10,0

	dc.b	2,`part.... but that's not me... Hmmm, in the`,10
	dc.b	2,`S.O.S. demo there is 9 routines (11 if you`,10
	dc.b	2,`count the milk-and-logo and the the writer)`,10
	dc.b	2,`and in ITK there is 12 (not counting the`,10
	dc.b	2,`writers and pictureshowers)... I don't`,10
	dc.b	2,`understand... 12 routines is fewer than`,10
	dc.b	2,`9??? Maybe it's just me...`,10
	dc.b	10
	dc.b	2,`Speaking of ITK, let's have some of the`,10
	dc.b	2,`missing credits here.... The LARGE 8 colour`,10
	dc.b	2,`font in the scroller-with-perspective-and-a-`,10
	dc.b	2,`Matilde-underneath-part`,10,0

	dc.b	2,`by Airwalk of Kefrens!!! (Sorry I forgot`,10
	dc.b	2,`that in the credits part... Can't tell you`,10
	dc.b	2,`really how sorry I am..) And the music-`,10
	dc.b	2,`replayer is by a dude whose name I cannot`,10
	dc.b	2,`remember!!! (This might seem like a little`,10
	dc.b	2,`thing but it is not! I think ITK is the only,`,10
	dc.b	2,`first, and last DEMO to use this cool`,10
	dc.b	2,`replayer. Written by a friend of 4Mat and`,10
	dc.b	2,`karl_m... Greets to all three of you!)`,10,0








	dc.b	0
	EVEN








*******************************************************************************
**FadeUpDn
*******************************************************************************
Story:		dc.w	0
FadeUp:
		lea	Colors+2,a0
		lea	Pic,a1
		moveq	#16-1,d7
		moveq	#0,d6
.loop:		move.w	(a0),d0
		move.w	(a1)+,d1
		bsr	fader
		move.w	d0,(a0)
		cmp.w	d0,d1
		bne	.notens
		addq.w	#1,d6
.notens:	addq.w	#4,a0
		dbra	d7,.loop
		cmp.w	#16,d6
		bne	.ud
		addq.w	#1,Story
.ud:		rts

**d0=fade from
**d1=fade to
**out: d0=newcol
fader:		move.w	d0,d2
		move.w	d1,d3
		lsr.w	#8,d2
		lsr.w	#8,d3
		cmp.w	d2,d3
		beq	.nored
		blt	.redsub
		add.w	#$100,d0
		bra	.nored
.redsub:	sub.w	#$100,d0
.nored:		move.w	d0,d2
		move.w	d1,d3
		lsr.w	#4,d2
		lsr.w	#4,d3
		and.w	#$f,d2
		and.w	#$f,d3
		cmp.w	d2,d3
		beq	.nogreen
		blt	.greensub
		add.w	#$10,d0
		bra	.nogreen
.greensub:	sub.w	#$10,d0
.nogreen:	move.w	d0,d2
		move.w	d1,d3
		and.w	#$f,d2
		and.w	#$f,d3
		cmp.w	d2,d3
		beq	.noblue
		blt	.bluesub
		addq.w	#$1,d0
		bra	.noblue
.bluesub:	subq.w	#$1,d0
.noblue:	rts

*******************************************************************************
**Copperlist
*******************************************************************************
Copper:
		dc.w	Spr0pth,$0000
		dc.w	Spr0ptl,$0000
		dc.w	Spr1pth,$0000
		dc.w	Spr1ptl,$0000
		dc.w	Spr2pth,$0000
		dc.w	Spr2ptl,$0000
		dc.w	Spr3pth,$0000
		dc.w	Spr3ptl,$0000
		dc.w	Spr4pth,$0000
		dc.w	Spr4ptl,$0000
		dc.w	Spr5pth,$0000
		dc.w	Spr5ptl,$0000
		dc.w	Spr6pth,$0000
		dc.w	Spr6ptl,$0000
		dc.w	Spr7pth,$0000
		dc.w	Spr7ptl,$0000

		dc.w	Diwstrt,$2c81
		dc.w	Diwstop,$2cc1
		dc.w	Ddfstrt,$0038
		dc.w	Ddfstop,$00d0

		dc.w	$106,$0c40

Colors:	dc.w	$0180,$000,$0182,$000,$0184,$000,$0186,$000
	dc.w	$0188,$000,$018a,$000,$018c,$000,$018e,$000
	dc.w	$0190,$000,$0192,$000,$0194,$000,$0196,$000
	dc.w	$0198,$000,$019a,$000,$019c,$000,$019e,$000
	dc.w	$01a0,$f88,$01a2,$f88,$01a4,$f88,$01a6,$f88
	dc.w	$01a8,$f88,$01aa,$f88,$01ac,$f88,$01ae,$f88
	dc.w	$01b0,$f88,$01b2,$f88,$01b4,$f88,$01b6,$f88
	dc.w	$01b8,$f88,$01ba,$f88,$01bc,$f88,$01be,$f88

		dc.w	$1001,$fffe
Planer:		dc.w	Bpl1pth,0	;(Pic+32+0*40)>>16
		dc.w	Bpl1ptl,0	;(Pic+32+0*40)&$ffff
		dc.w	Bpl2pth,0	;(Pic+32+1*40)>>16
		dc.w	Bpl2ptl,0	;(Pic+32+1*40)&$ffff
		dc.w	Bpl3pth,0	;(Pic+32+2*40)>>16
		dc.w	Bpl3ptl,0	;(Pic+32+2*40)&$ffff
		dc.w	Bpl4pth,0	;(Pic+32+3*40)>>16
		dc.w	Bpl4ptl,0	;(Pic+32+3*40)&$ffff
		dc.w	Bpl5pth,0	;(Pic+32+3*40)>>16
		dc.w	Bpl5ptl,0	;(Pic+32+3*40)&$ffff

		dc.w	Bpl1mod,0
		dc.w	Bpl2mod,0

		dc.w	Bplcon0,$5200
		dc.w	Bplcon1,$0000
		dc.w	Bplcon2,$0024

		dc.w	$ffff,$fffe

*******************************************************************************
**Screens+Gfx
*******************************************************************************
	INCDIR	"Work:Code/Sources/HTSAC/EndPart/"
Pic:	INCBIN	"PissedAnt.raw4*320*256+cmap"

	INCDIR	Work:Code/Sources/HTSAC/PlaneWriter/
PlaneFont:	INCBIN	Planefont.raw

TheEnd:

		SECTION	Pis,bss_c

Screen:	ds.b	(256+22)*40


*******************************************************************************
**Hardware registers
*******************************************************************************
Bltddat=$000
Dmaconr=$002
Vposr=$004
Vhposr=$006
Dskdatr=$008
Joy0dat=$00a
Joy1dat=$00c
Clxdat=$00e
Adkconr=$010
Pot0dat=$012
Pot1dat=$014
Potgor=$016
Serdatr=$018
Dskbytr=$01a
Intenar=$01c
Intreqr=$01e
Dskpth=$020
Dskptl=$022
Dsklen=$024
Dskdat=$026
Refptr=$028
Vposw=$02a
Vhposw=$02c
Copcon=$02e
Serdat=$030
Serper=$032
Potgo=$034
Joytest=$036
Strequ=$038
Strvbl=$03a
Strhor=$03c
Strlong=$03e
Bltcon0=$040
Bltcon1=$042
Bltafwm=$044
Bltalwm=$046
Bltcpth=$048
Bltcptl=$04a
Bltbpth=$04c
Bltbptl=$04e
Bltapth=$050
Bltaptl=$052
Bltdpth=$054
Bltdptl=$056
Bltsize=$058
Bltcmod=$060
Bltbmod=$062
Bltamod=$064
Bltdmod=$066
Bltcdat=$070
Bltbdat=$072
Bltadat=$074
Dsksync=$07e
Cop1lch=$080
Cop1lcl=$082
Cop2lch=$084
Cop2lcl=$086
Copjmp1=$088
Copjmp2=$08a
Copins=$08c
Diwstrt=$08e
Diwstop=$090
Ddfstrt=$092
Ddfstop=$094
Dmacon=$096
Clxcon=$98
Intena=$09a
Intreq=$09c
Adkcon=$09e
Aud0dat=$0aa
Aud1dat=$0ba
Aud2dat=$0ca
Aud3dat=$0da
Aud0lch=$0a0
Aud1lch=$0b0
Aud2lch=$0c0
Aud3lch=$0d0
Aud0len=$0a4
Aud1len=$0b4
Aud2len=$0c4
Aud3len=$0d4
Aud0per=$0a6
Aud1per=$0b6
Aud2per=$0c6
Aud3per=$0d6
Aud0vol=$0a8
Aud1vol=$0b8
Aud2vol=$0c8
Aud3vol=$0d8
Aud0lcl=$0a2
Aud1lcl=$0b2
Aud2lcl=$0c2
Aud3lcl=$0d2
Bpl1pth=$0e0
Bpl1ptl=$0e2
Bpl2pth=$0e4
Bpl2ptl=$0e6
Bpl3pth=$0e8
Bpl3ptl=$0ea
Bpl4pth=$0ec
Bpl4ptl=$0ee
Bpl5pth=$0f0
Bpl5ptl=$0f2
Bpl6pth=$0f4
Bpl6ptl=$0f6
Bplcon0=$100
Bplcon1=$102
Bplcon2=$104
Bpl1mod=$108
Bpl2mod=$10a
Bpl1dat=$110
Bpl2dat=$112
Bpl3dat=$114
Bpl4dat=$116
Bpl5dat=$118
Bpl6dat=$11a
Spr0pth=$120
Spr0ptl=$122
Spr1pth=$124
Spr1ptl=$126
Spr2pth=$128
Spr2ptl=$12a
Spr3pth=$12c
Spr3ptl=$12e
Spr4pth=$130
Spr4ptl=$132
Spr5pth=$134
Spr5ptl=$136
Spr6pth=$138
Spr6ptl=$13a
Spr7pth=$13c
Spr7ptl=$13e
Spr0pos=$140
Spr0ctl=$142
Spr0data=$144
Spr0datb=$146
Spr1pos=$148
Spr1ctl=$14a
Spr1data=$14c
Spr1datb=$14e
Spr2pos=$150
Spr2ctl=$152
Spr2data=$154
Spr2datb=$156
Spr3pos=$158
Spr3ctl=$15a
Spr3data=$15c
Spr3datb=$15e
Spr4pos=$160
Spr4ctl=$162
Spr4data=$164
Spr4datb=$166
Spr5pos=$168
Spr5ctl=$16a
Spr5data=$16c
Spr5datb=$16e
Spr6pos=$170
Spr6ctl=$172
Spr6data=$174
Spr6datb=$176
Spr7pos=$178
Spr7ctl=$17a
Spr7data=$17c
Spr7datb=$17e
Color00=$180
Color01=$182
Color02=$184
Color03=$186
Color04=$188
Color05=$18a
Color06=$18c
Color07=$18e
Color08=$190
Color09=$192
Color10=$194
Color11=$196
Color12=$198
Color13=$19a
Color14=$19c
Color15=$19e
Color16=$1a0
Color17=$1a2
Color18=$1a4
Color19=$1a6
Color20=$1a8
Color21=$1aa
Color22=$1ac
Color23=$1ae
Color24=$1b0
Color25=$1b2
Color26=$1b4
Color27=$1b6
Color28=$1b8
Color29=$1ba
Color30=$1bc
Color31=$1be
Base=$dff000

*******************************************************************************
**Interrupt addresses
*******************************************************************************
Lev1Base=$64
Lev2Base=$68
Lev3Base=$6c
Lev4Base=$70
Lev5Base=$74
Lev6Base=$78
Lev7Base=$7c

