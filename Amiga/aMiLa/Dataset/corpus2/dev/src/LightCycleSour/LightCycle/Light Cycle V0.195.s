;TOSPJPKPJPKAAAABNMDAAAAJKBIAAAAENPGAAAACMIAPPDMMGOPAAAACNONPPDMMGOPAAAAOAJNAHIJDHEN
;Light Cycle

;Menu for Light cycle start 92.08.25.
;version unknown
;ranking 4=
;Corpright by Real Destruction of R/THE/K
;Tricity Vitava 1992


;  Light Cicle V$0.01xx + Menu.
;
;	     by
;
;	   R.The.K.
;	      of
;R E A L   D E S T R U C T I O N
;
;Vitava 1992.08.02
;Updates:
;1992.08.03	Keyboard, Add 1 Light Cycle, 5 Bipl
;1992.08.08	Other Analize
;1992.08.09	Kill only one
;1992.08.10	Correct Kill, Enter Restart
;1992.08.13	 ? ? ?, Points
;1992.08.15	Kill points bug
;1992.08.22	Choose Control
;1992.08.25	Menu
;1992.09.11	23:40:00...,Better flash (with errors) [P.S. or not]
;1992.09.12	3Points
;1992.09.16	End when flash end
;1992.09.17	.pp ?
;1992.09.26	Color font menu
;1992.09.28	przerwania Creatu(o)ry(a) dolaczone ???
;1992.10.01	m - wlancza,wylancza muzyke, zycia,credits (wersja podstaw.)
;1992.10.02	Live, little corect
;1992.10.17	Tlo.itd.itp.xtd.atd.itp.... . .  .  .    .     .      .       .
;MCMXCII.X.XVIII ? ? ?
;1992.10.18	Zmiana miejsca przerwania
;1992.10.24	Zmiana spowrotem z 3 przerwaniem nie gasi stacji,Speed Enable
;               p pause and p continiue, no player, dol punkty
;1992.10.25
;1992.10.29	Track Disk Device (drive turn off wow!)
;1992.10.30	oblalem bramki na prawku, dopisuje jakies bzdury tzn poczatek
;		game over,przeniesione zycia i ich pojawianie sie
;		test komputerow itd.
;1992.11.06	contynuacja game over	(lenght 38280 83 86 88) 38396 38486
;1992.11.11	swieto wyzwolenia czegos tam, jasno-ciemno i ciemno-jasno
;		versia $12e-$13d Game_over_seq:
;1992.11.23	18 zdalem prawko !!!!,password dorzucony, ok 607lini efecty
;1992.11.24	sciemnianie do menu
;1992.11.26	* ? ! ? * -do not
;1992.12.04	* ? ! ? * -next d.n.
;1992.12.23,24	>extern,test przezycia (czy player O_K_Alive
;		divs facked up, fast error correct,cut something
;		left shift=no vertical
;1993.01.03	Lea Copper(pc)
;1993.01.04	Ciekawe ile bede mial 2 ???,load level,grettings,some error in
;		alive ???,!!! CHECK THIS !!!
;????.??.??	alive ok!
;1993.02.17	hi score dorzucone. hi_score_p: |wyzej|
;1993.05.16	optimize,optymize,... 163-188 z 63000-59914.17.20
;		to macro jest chore
;1993.07.22	Jak ja dawno tego nie ogladalem,
;1994.08.12	
;		skoïczone.. ostre poprawki, moûe mnie zatrudniâ a Iridin?
;		184»1a4

;Checked to xxx line
;wykopac a5 z controls !
;stanolem na 580 credits table: !!

;UWAGA PRZERABIAM NA xx(a5)
;Cos nie tak z pas table ?

;			INCDIR	'df0:'
			INCDIR	'dh1:Sources/LightCycle/'

MUSIC=1
KEYTEST=1
SAVE=1

Wysokosc:	equ	8	;Wys fontow

	IFEQ	SAVE
*	*	*	*	*	*	*	*	*
Tlo2		equ	$155000
	>extern	'tlo2+.pic',Tlo2	;$a098
Fonts		equ	tlo2+$a098
	>extern	'slp2.fnt',Fonts	;$300
mt_data		equ	$130000
*	>extern	'mod.voice from rv-125',mt_data ;141654 $22956
	>extern	'mod.soviet dog',mt_data	;131304 $200e8
	ENDIF

*******************************************************************************
*				    MACRO				      *
*******************************************************************************
VERTICAL:	MACRO
	move.l	d0,-(sp)
	move.l	4(a5),d0
	and.l	#$0001ff00,d0
	cmp.l	#\1*2^8,d0
	bne.s	*-16
	move.l	(sp)+,d0
	ENDM

WAITBLITTER:	MACRO
	btst	#14,2(a5)
	bne.s	*-6
	ENDM
EXEC:	MACRO
	move.l	4.w,a6
	ENDM
CALL:	MACRO
	jsr	_\1(a6)
	ENDM
CALLEXEC:MACRO
	move.l	4.w,a6
	jsr	_\1(a6)
	ENDM
CALLB:	MACRO
	MOVEL	\2
	CALL	\1
	ENDM
JUMP:	MACRO
	jmp	_\1(a6)
	ENDM
MOVEL:	MACRO
	move.l	\1Base(pc),a6
	ENDM

*******************************************************************************
*				    PROGRAM				      *
*******************************************************************************


	Section	TheProgram,Code_C

 *****
*        t             t
 *****  ttt  aa   r r ttt
      *  t  a  a   r   t
******   t   aaaa  r   t
Start:
	lea	$dff000,a5

	lea	DosName(pc),a1
	EXEC
	CALL	OldOpenLibrary
	move.l	d0,DosBase
	beq.w	ENDProg


	bsr	StartIrq	;muzyka w przerwaniach

*	lea	Module,a0
*	lea	$40000,a1
*	move.l	#107676,d0
*	bsr	Power_Packer

	bsr	TrackDiskDevice
;menu
	lea	BitplanAdres+2,a0
	move.l	#Ekran,d2
	moveq	#4,d0		;Ilosc bitplanow
	bsr	Copp_Loop

;gra
	lea	BitplanADR+2,a0
	move.l	#Ekran,d2	;Ekran gry
	moveq	#5,d0		;Ilosc Bitplanow
	bsr	Copp_Loop

	lea	Tlo2+$30,a0	; z obrazka do Copper Listy !!!!
	lea	ScreenMinColor(pc),a1
	moveq	#16,d2	;Ilosc Colorow
	bsr	DoColor

	bsr	Fonty

	VERTICAL $100

	bsr	copy_tlo

	lea	Copper,a0
	move.l	a0,$80(a5)

	bsr	CJM

;Texty przed startem

	moveq	#0,d0

	moveq	#3,d6
	move.l	#100,d5
War_Loop:
	lea	WarningText(pc),a0
	bsr	WyswietlText
	move.l	d5,d0
	bsr	Wait_a_m

	bsr	JCM
;>>
	bra.s	TheMenu
;>>
	move.l	d5,d0
	asr.l	#2,d0
	bsr	Wait_a_m
	subq	#1,d6
	bne.s	War_Loop


	moveq	#25,d0
	bsr	Wait_a_m

	bsr	copy_tlo

	lea	GwiazdkaThings,a0
	bsr	WyswietlText
	moveq	#100,d0
	bsr	Wait_a_m

	moveq	#25,d0
	bsr	Wait_a_m

	bsr	JCM


                 * * * * * * * * * * * * * * * * *
*       *
* *   * *
*   *   *
*       *
*       *enu	;;
TheMenu:
	bsr	copy_tlo
	lea	MenuText(pc),a0		;Menu Text
	bsr	WyswietlText
	lea	Copper,a0
	move.l	a0,$80(a5)
	bsr	CJM

Mouse:
	VERTICAL $100

	bsr	ReadKey

	btst	#6,$bfe001		;LMB = Start Game
	beq.w	ChST

	btst	#10,$dff016
	beq.w	The_Real_End_of_The_Game

	btst	#7,$bfe001		;Joy Fire = Start Game
	beq.s	ChST

;	moveq	#%1,d0
;	bsr	Czytaj

	cmp.b	#$75,d0		; ESC = Exit Game
	beq	The_Real_End_of_The_Game
	cmp.b	#$45,d0		; * = Exit Game
	beq	The_Real_End_of_The_Game

	cmp.b	#$5f,d0		;F1 - Control One
	bne.s	CheckTwo
	bsr	ControlsOne
	bra.s	TheMenu
CheckTwo:
	cmp.b	#$5d,d0		;F2 - Control Two
	bne.s	CheckThree
	bsr	ControlsTwo
	bra.w	TheMenu
CheckThree:
	cmp.b	#$5b,d0		;F3 - Control Three
	bne.s	CheckHi
	bsr	ControlsThree
	bra.w	TheMenu
CheckHi:
	cmp.b	#$59,d0		;F4 - Hi Score
	bne.s	CheckCode
	bsr	JCM
	move	#1,MenuEnter
	bsr	hi_score_p	;<NOT AT ALL>
	bra	TheMenu
CheckCode:
	cmp.b	#$57,d0		;F5 - Password
	bne.s	CheckCredits
	bsr	Password
	bra	TheMenu
CheckCredits:
	cmp.b	#$55,d0		;F6 - Credits
	bne.s	Check_Start
	bsr	Credits		;wersja podstawowa
	bra	TheMenu
Check_Start:
	cmp.b	#$4d,d0		;F10 - Start
	bne.s	ContCheck
ChST:
	bsr	Init_Game	;Start Game
	bra	TheMenu	;powrot do menu
ContCheck:
	bra	Mouse
                 * * * * * * * * * * * * * * * * *
ControlsOne:
	lea	Player1_Rgame(pc),a3
	lea	PlayerOne(pc),a4
	moveq	#$000f,d0
	bra.s	ChangeControl
ControlsTwo:
	lea	Player2_Rgame(pc),a3
	lea	PlayerTwo(pc),a4
	move	#$00f0,d0
	bra.s	ChangeControl
ControlsThree:
	lea	Player3_Rgame(pc),a3
	lea	PlayerThree(pc),a4
	move	#$0f00,d0

ChangeControl:
	bsr	JCM
ChangeContr:
	bsr	copy_tlo

	lea	ControlText(pc),a0
	bsr	WyswietlText
	bsr	CJM

contr
	VERTICAL $100
	VERTICAL $101
	bsr	ReadKey

*	moveq	#0,d0		;LMB and Fire not akcept
*	bsr	Czytaj
	cmp.b	#$5f,d0		;F1 - Joy port 1
	bne.s	C_f2
	move	#%0010,(a4)
	bra.s	Change_Control_End
C_f2:
	cmp.b	#$5d,d0		;F2 - Joy port 0
	bne.s	C_f3
	move	#%0001,(a4)
	bra.s	Change_Control_End
C_f3:
	cmp.b	#$5b,d0		;F3 - Keyboard
	bne.s	C_f4
	move	#%0100,(a4)
	bra.s	Change_Control_End
C_f4:
	cmp.b	#$59,d0		;F4 - Computer
	bne.s	C_f5
	move	#%1000,(a4)
	bra	Change_Control_End
C_f5:
*	cmp.b	#$57,d0		;F5 - RedefineKeys *dont work
*	bne.s	C_F6
*	move	#%0100,(a4)	;Keyboard
*	bsr	RedefineKeys
*	bra	Change_Control_End
C_f6:				;F6 - No Player
	cmp.b	#$55,d0
	bne.s	C_f7
	bsr	JCM
	move	#0,(a3)		;player nie gra i juz
	rts

C_f7:				; nothing at now
	bra.s	contr
Change_Control_End:	;if you change somthing here,change in c_f6 too.!
	bsr	JCM
	move	#1,(a3)
	rts

*RedefineKeys:
*	rts

 *****               *  *  *
*                    *    *** ****
*      * **  *     ***  *  *   **
*       *   * *   *  *  *  *     *
 *****  *    **** ***** *  *  ***

Credits:	;wersja podstawowa !

;a gdyby to przerobic ?? ok!

	lea	CreditsTable(pc),a3
creditsloop
	bsr	JCM ;d0-d6 a0
	bsr	copy_tlo	;a0,a1,d0,d1
	tst.l	(a3)
	bne.s	noecr
	rts
noecr
	move.l	(a3)+,a0
	bsr	WyswietlText ;d0,a0,a1,a2
	bsr	CJM ;d3-d5 a0-a1
	bsr	czekay	;d0

	bra.s	creditsloop

CreditsTable:
 dc.l CreditsText0,CreditsText1,CreditsText2,CreditsText3,CreditsText4
 dc.l 0

;Password by R.The.K./R.D. for Light Cycle
;Wersion unknown
;Rozpoznaje kody klawiszy. WOW !
;                 R E A L   D E S T R U C T I O N
Password:
	bsr	JCM

WaitKey:
	IFNE	KEYTEST
	btst	#0,$bfec01
	bne.s	WaitKey
	ENDIF
	rts
ClearKey:
	IFNE	KEYTEST
	move.b	#0,$bfec01
	ENDIF
	rts
ReadKey:
	IFNE	KEYTEST
	move.b	$bfec01,d0
	ELSE
	moveq	#0,d0
	ENDIF
	rts
Ppass:
	bsr	WaitKey

	bsr	copy_tlo

	lea	Text(pc),a0
	bsr	WyswietlText

	bsr	CJM
	move.l	#p_text+6,Password_Adr

Loop_P:
	btst	#6,$bfe001
	beq	End
Loop2:
	cmp.b	#$ff,6(a5)
	bne.s	Loop2

Ttest:
	btst	#6,$bfe001
	beq	End

	bsr	ReadKey

	cmp.b	#63,d0
	bne.s	NieLewy_Shift	;wcisniety !
	move	#1,Shift
NieLewy_Shift:
	cmp.b	#61,d0
	bne.s	NiePrawy_Shift	;wcisniety !
	move	#1,Shift	;1 wcisniety
NiePrawy_Shift:

	cmp.b	#62,d0
	bne.s	NieLewy_ShiftW	;puszczony
	move	#0,Shift
NieLewy_ShiftW:

	cmp.b	#60,d0
	bne.s	NiePrawy_ShiftW	;puszczony
	move	#0,Shift	;0 puszczony
NiePrawy_ShiftW:

;Enter and Return
	cmp.b	#$79,d0	;enter
	beq.s	Yes_Password

	cmp.b	#$77,d0	;return
	bne.s	No_Password
Yes_Password:
	bra.s	Check_Password
No_Password:
;Del
	cmp.b	#$7d,d0	;del
	bne.s	lb_0
	tst	PasswordNr
	beq.s	lb_0
	subq	#1,PasswordNr
	subq.l	#1,Password_Adr
	move.l	Password_Adr,a0
	move.b	#'_',(a0)+
	move.b	#'_',(a0)
lb_0
	btst	#0,$bfec01 ;?
	beq	Loop_P

	move.b	#0,$bfec01
	bsr	Search	;szuka i wrzuca litere

	lea	p_text(pc),a0			;Text
	bsr	WyswietlText

	bra	Loop_P

 **** *             *
*     *             *
*     ***   *    ** * *
*     *  * * *  *   **
 **** *  *  ***  ** * * Password
Check_Password:
	lea	Password_Table(pc),a1
	moveq	#0,d2	;password nr
	moveq	#0,d1

Pas_next:
	lea	6+p_text(pc),a0
	moveq	#12,d0	;ile liter
Chc_Next:
	move.b	(a0)+,d1
	cmp.b	(a1),d1
	beq.s	f1o

	add.b	#32,d1
	cmp.b	(a1),d1 ;duze dla malych liter
	beq.s	f1o

	sub.b	#64,d1
	cmp.b	(a1),d1 ; i male dla duzych liter
	bne.s	NextPassword
f1o:
	addq.l	#1,a1
	subq	#1,d0
	bne.s	Chc_Next
;chaslo znalezione
	move	#$fff,$180(a5)
	bsr.s	Czysc_password
	move	d2,Password_NR ;do rozpoznania ktory password
	bsr	Password_Effect ;niektore daja natychmiastowe efekty
	rts ;powrot do menu

NextPassword:
	addq	#1,d2
	cmp	#ilosc_chasel,d2	;ilosc hasel
	bne.s	nolastpas
;koniec chasel
	move	#$600,$180(a5) ;niema takigo passwordu
	bsr.s	Czysc_password
	bsr	JCM
	rts ;powrot do menu

nolastpas
	move.l	d2,d1
	muls	#12,d1
	lea	Password_Table(pc),a1
	add.l	d1,a1
	bra.s	Pas_next

Czysc_password:
	move.l	#p_text+6,Password_Adr
	move	#0,PasswordNr
	lea	6+p_text(pc),a0
	moveq	#12-1,d0
liniuj:
	move.b	#'_',(a0)+
	dbf	d0,liniuj
	rts

 ****                         *
*                             *
 ****   *    **    * **  ***  ***
     * * *  *  *    *   *     *  *
*****   ***  *****  *    ***  *  *

Search:
	tst	Shift	;1wcisniety 0puszczony
	beq.s	No_Shift
	lea	Shift_Table(pc),a0
	bra.s	Ok_Ok_Cont
No_Shift:
	lea	No_Shift_Table(pc),a0
Ok_Ok_Cont:
	moveq	#0,d1	;' '
Szukaj:
	cmp.b	(a0)+,d0
	beq.s	Found
	addq.l	#1,a0
	addq	#1,d1
	cmp	#90,d1	;za 'z'+troche znaczkow
	bne.s	Szukaj
	rts
Found:
	move.l	Password_Adr(pc),a1
	addq	#1,PasswordNr
	cmp	#12,PasswordNr
	bne.s	Nie_caly_Pasw
	move	#11,PasswordNr
	subq.l	#1,Password_Adr
Nie_caly_Pasw:
	addq.l	#1,Password_Adr
	move.b	(a0),(a1)
	rts
czekay: ;czeka az puscisz lub fire,mouse
	btst	#0,$bfec01
	bne.s	czekay
	move.b	$bfec01,d0
czek:
	btst	#7,$bfe001 ;joy fire
	beq.s	ecze
	btst	#6,$bfe001 ;lmb
	beq.s	ecze
	cmp.b	$bfec01,d0
	beq.s	czek
ecze	rts

Password_Effect:
	bsr.w	JCM
	bsr.w	copy_tlo
p0:
	move.w	Password_NR(pc),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	PassTable(pc,d0.w),a0
	cmp.l	#0,a0
;	tst.l	a0
	beq.s	Jeszcze_niema
	bsr	WyswietlText
	bsr.w	CJM
	bsr	czekay
	bsr.w	JCM
	rts
Jeszcze_niema:
	bsr.w	CJM
	move	#$f00,$180(a5)
	bsr.w	JCM
	rts

PassTable: dc.l AlienTXT,EmptyT,EmptyT,EmptyT,EmptyT,EmptyT,EmptyT,EmptyT
 dc.l EmptyT,EmptyT,EmptyT,mtvTXT,LockyTXT,0,0,0,0,0,0
 dc.l PillarTXT,0,KaneTXT,CreatTXT,0,0

***** ***** *    * *****
  *   *     *    *   *
  *   ***    ****    *
  *   *     *    *   *
  *   ***** *    *   *


***
WyswietlText:		;a0 text
***
	btst	#14,2(a5)
	bne.s	WyswietlText	;?

	moveq	#0,d0	;just clear
	lea	Ekran+$50,a1	;pojawienie sie fontow
OffsetC:
	moveq	#0,d0
	move.b	(a0)+,d0
	bne.s	SameLine
	move.b	(a0)+,d0
	bne.s	noe
	rts
noe
	lea	Ekran+$50,a1	;pojawienie sie fontow
	muls	#4*40,d0
	add.l	d0,a1
	bra.s	OffsetC
SameLine:
	sub.b	#$20,d0			;right character
	add.w	d0,d0
	add.w	d0,d0
	move.l	FontADR(pc,d0.w),a2		;odczyt odresu fonta
BitP4:
	moveq	#21-1,d0		;wysokosc
Copy:
	move.w	(a2),(a1)	;copiowanie na ekran
	lea	40(a2),a2
	lea	40(a1),a1
	move.w	(a2),(a1)
	lea	3*40(a2),a2
	lea	3*40(a1),a1
	dbf	d0,Copy
	lea	[-21*4*40+2](a1),a1

	bra.s	OffsetC
FontADR:
		blk.l	100,0

BlitterClear:
	WAITBLITTER

	move.l	a0,$50(a5)		;BLTAPT
	move.l	#$01000000,$40(a5)	;BLTCON0 d=a
	move.l	#$00000000,$64(a5)		;BLTAMOD
	move.w	#[255*64*3]+[320/16],$58(a5)	;BLTSIZE

	rts

 ****
*
*
 **** -opy tlo

;a0,a1,d0,d1
copy_tlo:
	lea	Ekran,a1
	lea	Tlo2+152,a0
	move.w	#256-1,d0	;ilosc lini
Linia_Loop:
	moveq	#80/4-1,d1
Linia_s_l:	move.l	(a0)+,(a1)+
	dbf	d1,Linia_s_l

	lea	80(a0),a0

	moveq	#80/4-1,d1
Czysc_dwie_linie:
	move.l	#0,(a1)+
	dbf	d1,Czysc_dwie_linie

	dbf	d0,Linia_Loop
	rts

********
*      *
* ******
*   ****
* ******
*      *
********nd	;;
The_Real_End_of_The_Game:
	btst	#14,$dff002
	bne.s	The_Real_End_of_The_Game

	bsr.w	JCM

	bsr	StopIrq	;muzyka w przerwaniach


				ENDProg:

	bsr	FreeMem

	EXEC
	moveq	#0,d0
	move.l	DosBase,a1
	CALL	CloseLibrary

	lea	Gfxname(pc),a1
	CALL	OldOpenLibrary
	beq.s	Error
	move.l	d0,a1
	move.l	38(a1),$dff080
	jsr	-414(a6)

	IFNE	MUSIC
	jsr	mt_end
	ENDIF

	moveq	#0,d0
Error:	rts

Wait_a_moment:
	move.w	#400-1,d1
Wait_a_m:
	VERTICAL $100
	VERTICAL $101

	btst	#6,$bfe001
	bne.s	.1
	btst	#7,$bfe001
	bne.s	.1

	dbf	d1,Wait_a_m
.1
	moveq	#0,d0
	rts

Copp_Loop:
	move.l	d2,d1
	swap	d1
	move.w	d1,(a0)
	addq.l	#4,a0
	move.l	d2,d1
	add.l	#40,d2		;Adr nast Bitpl.
	move.w	d1,(a0)
	addq.l	#4,a0

	subq.b	#1,d0			;Pentla
	bne.s	Copp_Loop
	rts

;Przerzuca colory z ifa do Copper listy !
;by Thestruction of De R.K.
;Vitava 1992.08.04.
;a0-adres colorow w iffie
;a1-gdzie wrzucac w copper liscie
;d2-ilosc kolorow

DoColor:			;Przerzuca Colory

	move.w	#$180,d3	;kolor startowy
DoCol:	moveq	#3-1,d1
	moveq	#0,d0		;Clear
DoColor3Loop:
	move.b	(a0)+,d4
	ror.b	#4,d4
	add.b	d4,d0
	rol.w	#4,d0
	dbra	d1,DoColor3Loop
	ror.w	#4,d0
	move.w	d3,(a1)+
	move.w	d0,(a1)+
	addq.w	#2,d3
	subq.b	#1,d2
	bne.s	DoCol
	rts
;robi tabele adresow fontow
Fonty:
	lea	FontADR(pc),a1
	lea	Tlo2+152+80,a0		;pentla dla adresow fontow
	moveq	#100,d0			;ilosc fontow
cmp1:	moveq	#20,d1		;ile w lini
CMP:
	move.l	a0,(a1)+
	addq.l	#2,a0
	subq.b	#1,d0
	beq.s	.ok
	subq.b	#1,d1
	bne.s	CMP
	add.l	#[21*40*4]-40,a0
	bra.s	cmp1
.ok	rts

ScreenMinColor:
	blk.l	16*2,0

*    *
*    *
*    *
******
*    *
*    *
*    * i Score

**********************************
;Password metamorphoses to hiscore. . .
;                 R E A L   D E S T R U C T I O N

hhhhh	dc.l	0	;***********

hi_score_p:
	btst	#0,$bfec01	;pusc klawisz cholero
	bne.s	hi_score_p

	bsr	JCM

	bsr	copy_tlo

	tst.w	MenuEnter	;wejscie z menu
	bne	Move_HI

	lea	Enter_T(pc),a0
	bsr.w	WyswietlText
	bsr	CJM

	lea	HighScoreData(pc),a0
	move.l	hhhhh,d0
	moveq	#1,d1
szk	cmp.l	(a0),d0
	bpl	okioki
	lea	16(a0),a0
	addq.w	#1,d1
	cmp.w	#10,d1
	bne	szk
;gowno nie wlazlez do hi score
	bra	Move_HI
okioki
	cmp.w	#10,d1
	bne	no10
	move.b	#'1',Enter_T+2
	move.b	#'0',Enter_T+3
	bra	d10z
no10	add.w	#'0',d1
	move.b	d1,Enter_T+3
d10z
	move.l	#Enter_T+5,Password_Adr
	lea	17+Enter_T(pc),a0
	move.l	hhhhh,d0
	bsr	Przelicz_ty_

	lea	Enter_T(pc),a0
	bsr.w	WyswietlText

	moveq	#0,d0
LoopX
	VERTICAL $100

	cmp.b	#63,$bfec01
	bne.s	NL_S	;wcisniety !
	move.w	#1,Shift
NL_S
	cmp.b	#61,$bfec01
	bne.s	NP_S	;wcisniety !
	move.w	#1,Shift	;1 wcisniety
NP_S:
	cmp.b	#62,$bfec01
	bne.s	NL_SW	;wycisniety
	move.w	#0,Shift
NL_SW:
	cmp.b	#60,$bfec01
	bne.s	NP_SW	;wycisniety
	move.w	#0,Shift	;0 puszczony
NP_SW:

;Enter and Return
	cmp.b	#$77,$bfec01	;return
	beq.s	Enter_hi
	cmp.b	#$79,$bfec01	;enter
	beq.s	Enter_hi

;Del
	cmp.b	#$7d,$bfec01
	bne.s	ol2
	cmp.w	#0,PasswordNr
	beq.s	ol2
	subq.w	#1,PasswordNr
	subq.l	#1,Password_Adr
	move.l	Password_Adr,a0
	move.b	#' ',(a0)+
	move.b	#' ',(a0)
ol2:
	btst	#0,$bfec01
	beq.w	LoopX
	move.b	$bfec01,d0
	move.b	#0,$bfec01
	bsr.w	Search2	;szuka i wrzuca litere

	lea	Enter_T(pc),a0
	bsr.w	WyswietlText

	bra.w	LoopX

Enter_hi
	bsr	JCM
	bsr	copy_tlo
	lea	HighScoreData(pc),a1
	move.l	hhhhh,d0
	moveq	#1,d1
ksz	cmp.l	(a1),d0
	bpl	The_place
	lea	16(a1),a1
	addq.w	#1,d1
	bra	ksz

The_place
	moveq	#10,d2
	sub.w	d1,d2
;	subq.w	#1,d2
	lea	EndHii(pc),a2
	lea	16+EndHii(pc),a3
ujii0	moveq	#16-1,d3
ujii	move.b	-(a2),-(a3)
	dbf	d3,ujii
	dbf	d2,ujii0

	move.l	d0,(a1)+	;Wrzuca punkty
	lea	5+Enter_T(pc),a0
	move.b	(a0)+,(a1)+	;przerzuca do hi score <podstawowego
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+


Move_HI
	move.w	#0,MenuEnter
	lea	4+OnePla(pc),a1
	lea	4+HighScoreData(pc),a0
	moveq	#10-1,d0
copnij				;zmienia format do wyswietlenia
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	addq.l	#5,a0	;punkty olac
	lea	11(a1),a1
	dbf	d0,copnij

	lea	OnePla+16,a0
	lea	HighScoreData,a1
	moveq	#10-1,d1
ilscor
	move.l	(a1),d0
	lea	16(a1),a1
	bsr	Przelicz_ty_
	lea	22(a0),a0	;???

	dbf	d1,ilscor

	lea	Hi_Text(pc),a0
	bsr	WyswietlText

	bsr	CJM

	move.b	#0,$bfec01

.1	tst.b	$bfec01
	bne.s	rreettss
	btst	#6,$bfe001
	bne	.1
rreettss
	bsr	JCM
	rts

;dzies
;wescie:
;	a0 gdze wrzucac liczbe w asci
;	d0 liczba
Przelicz_ty_
	movem.l	d0-d2/a0-a1,-(sp)
	lea	Dzes,a1	;tabela dziesiatek (wykopanie divsa
	moveq	#0,d2
	move.l	(a1)+,d1
L_00
	move.l	(a1)+,d1
	beq	nomore_tears

.1	cmp.l	d1,d0
	blt.s	l_02		;Gdy mniejszy
	sub.l	d1,d0
	addq.b	#1,d2
	bra.s	.1
l_02
	move.b	d2,(a0)+	;Wrzutka liczby
	moveq	#0,d2
	bra.s	L_00
nomore_tears
	sub.l	#5,a0
	add.b	#$30,(a0)+	;?'0'=$30
	add.b	#$30,(a0)+
	add.b	#$30,(a0)+
	add.b	#$30,(a0)+
	add.b	#$30,(a0)+
	movem.l	(sp)+,d0-d2/a0-a1
	rts

Enter_T:
	dc.b	0
	dc.b	200,' 1.            00000',0
	even
	dc.w	0
Hi_Text:	;'                    '
;11 na nazwe
	dc.b	0
	dc.b   3,'     <Hi Score>',0
OnePla	dc.b  30,' 1.                 ',0 ;reszta zostanie wrzucona
	dc.b  52,' 2.                 ',0
	dc.b  74,' 3.                 ',0
	dc.b  96,' 4.                 ',0
	dc.b 118,' 5.                 ',0
	dc.b 140,' 6.                 ',0
	dc.b 162,' 7.                 ',0
	dc.b 184,' 8.                 ',0
	dc.b 208,' 9.                 ',0
	dc.b 230,'10.                 ',0
	even

;format zapisu dlugie slowo punkty potem 12 znakow nazwy [12 nie uzywany]
;razem 16 bajtow
;hiscore
HighScoreData:
 dc.l	10000
 dc.b '  Gfx by:   '	;1
 dc.l	9999
 dc.b '  Slepper   '	;2
 dc.l	7500
 dc.b ' Music by:  '	;3
 dc.l	8756
 dc.b '  BFA/SCT   '	;4
 dc.l	8576
 dc.b 'Dr.Stool/RD '	;5
 dc.l	2222
 dc.b ' Code by:   '	;6
 dc.l	2221
 dc.b 'R.The.K./RD '	;7
 dc.l	342
 dc.b '   Real     '	;8
 dc.l	111
 dc.b 'Destruction '	;9
 dc.l	5
 dc.b 'Prod 1992-3 '	;10
EndHii
 blk.b	20,0


Search2:
	tst.w	Shift	;1wcisniety 0puszczony
	beq.s	No_Shift2
	lea	Shift_Table(pc),a0
	bra.s	Ok_Ok_Cont2
No_Shift2:
	lea	No_Shift_Table(pc),a0
Ok_Ok_Cont2:
	move.b	d0,Szukaj2+3
	moveq	#0,d1	;' '
Szukaj2:
	cmp.b	#$00,(a0)+
	beq.s	Found2
	addq.l	#1,a0
	addq.w	#1,d1
	cmp.w	#68,d1	;za 'z'
	bne.s	Szukaj2
	rts
Found2:
	move.l	Password_Adr,a1
	addq.w	#1,PasswordNr
	cmp.w	#11,PasswordNr		;ilosc znakow
	bne.s	Niecalywpis
	move.w	#10,PasswordNr
	subq.l	#1,Password_Adr
Niecalywpis:
	addq.l	#1,Password_Adr
	move.b	(a0),(a1)
	rts

**********************************



*    *      *    *    *****          *
*    *  **  **  ***   *     *  *  ** *    **
*    * *  * * *  *    *     *  * *   *   * *
**** *  *** * *  *    *****  ***  **  **  ****
          *                    *
        ***                 ****

;ZROBIC LEVELY !!!!
Loadit:
	MOVEL	Dos
	moveq	#0,d0
	move.l	#1005,d2
	move.l	d5,d1
*	move.l	#FileName,d1
	jsr	-30(a6)	;open file
	beq.w	Load_Error
	move.l	d0,Handle
	bsr	Seek
	move.l	d0,FileSize
	beq.w	Error
;	bsr.s	AllocMem

	moveq	#0,d0
	move.l	Handle(pc),d1
	move.l	#LoadAdr,d2	;gdzie ladowac
	move.l	FileSize(pc),d3
	CALL	Read
	cmp.w	#-1,d0
	beq.w	Error
	moveq	#0,d0
	move.l	Handle(pc),d1
	jsr	-36(a6)	;close File

;	bsr	FreeMem

	lea	LoadAdr,a0	;skad brac dane
	lea	Iff,a1		;gdzie dekompresowac
	move.l	FileSize(pc),d0
	bsr	Power_Packer
	rts
JumpLevel
	bra	Level0
	bra	Level1
	bra	Level2
	bra	Level3
	bra	Level4
	bra	Level5
	bra	Level6
	bra	Level7
	bra	Level8
	bra	Level9
	bra	Level10

Level0
	lea	Lev0Text,a0
	bsr	WyswietlText
	move.w	#2,Speed_tm
	move.l	#Level0_FM,d5
*	%0001	Prawo
*	%0010	Lewo
*	%0100	Dol
*	%1000	Gora
	move.w	#%0100,Lev_LastRuch1
	move.l	#$340056,Lev_PosX1
	move.w	#%0010,Lev_LastRuch2
	move.l	#$1050026,Lev_PosX2
	move.w	#%1000,lev_LastRuch3
	move.l	#$890076,Lev_PosX3
	rts
Level1
	lea	Lev0Text,a0
	bsr	WyswietlText
	move.w	#2,Speed_tm
	move.l	#Level1_FM,d5
	rts
Level2
	lea	Lev0Text,a0
	bsr	WyswietlText
	move.w	#2,Speed_tm
	move.l	#Level2_FM,d5
	rts
Level3
	lea	Lev0Text,a0
	bsr	WyswietlText
	move.w	#2,Speed_tm
	move.l	#Level3_FM,d5
	rts
Level4
	lea	Lev0Text,a0
	bsr	WyswietlText
	move.w	#2,Speed_tm
	move.l	#Level4_FM,d5
	rts
Level5
	lea	Lev0Text,a0
	bsr	WyswietlText
	move.w	#2,Speed_tm
	move.l	#Level5_FM,d5
	rts
Level6
	lea	Lev0Text,a0
	bsr	WyswietlText
	move.w	#1,Speed_tm
	move.l	#Level6_FM,d5
	rts
Level7
	lea	Lev0Text,a0
	bsr	WyswietlText
	move.w	#1,Speed_tm
	move.l	#Level7_FM,d5
	rts
Level8
	lea	Lev0Text(pc),a0
	bsr	WyswietlText
	move.w	#1,Speed_tm
	move.l	#Level8_FM,d5
	rts
Level9
	lea	Lev0Text,a0
	bsr	WyswietlText
	move.w	#1,Speed_tm
	move.l	#Level9_FM,d5
	rts
Level10
	lea	Lev0Text,a0
	bsr	WyswietlText
	move.w	#2,Speed_tm
	move.l	#Level10_FM,d5
	rts
Load_Error
	move.w	#$fff,$dff180
	move.w	#$f00,$dff180
	move.w	#$0f0,$dff180
	move.w	#$00f,$dff180
	move.w	#$000,$dff180
	btst	#6,$bfe001
	bne	Load_Error
	rts

Init_Game
	bsr.w	JCM

	lea	GameScreenColor,a0	;ZMIENIC !
	bsr.w	Czysc_Colory	;(32)

;	lea	Points_Color,a0	;ZMIENIC !
;	bsr.w	Czysc_Colory	;(32)

	move.w	Player1_Rgame,Player1_game
	move.w	Player2_Rgame,Player2_game
	move.w	Player3_Rgame,Player3_game

	move.l	#0,PunktyPierwszego
	move.l	#0,PunktyDrugiego
	move.l	#0,PunktyTrzeciego

	move.w	#4,Live1	;zycia
	move.w	#4,Live2
	move.w	#4,Live3

;	move.w	PlayerOne_M,PlayerOne
;	move.w	PlayerTwo_M,PlayerTwo
;	move.w	PlayerThree_M,PlayerThree

Start_Game:
	bsr.w	JCM
	bsr	copy_tlo
	moveq	#0,d0
	lea	JumpLevel(pc),a0
	move.w	Level(pc),d0
	add.w	d0,d0
	add.w	d0,d0
	add.l	d0,a0
	jsr	(a0)
	movem.l	d0-a6,-(a7)
	bsr	CJM
	movem.l	(a7)+,d0-a6
	bsr.w	Loadit
	jsr	TrackDiskDevice
	bsr	JCM

	lea	GameCopper,a0
	move.l	a0,$dff080

GameLoop:

	move.w	#0,Crash	;ilosc wyeliminowanych


	lea	Iff+$30,a0	; z obrazka do Copper Listy !!!!
	lea	MintimeColor,a1	;dla jasno-ciemno
;	lea	GameScreenColor,a1
	move.l	#32,d2	;Ilosc Colorow
	bsr	DoColor


	move.w	#0,LFlash1
	move.w	#0,LFlash2
	move.w	#0,LFlash3

	tst.w	Player1_game
	beq.s	NoPlayer1_game
	move.l	Lev_PosX1,PosX
	bra.s	Player1_game_on
NoPlayer1_game:
	move.l	#0,PosX

Player1_game_on:
	tst.w	Player2_game
	beq.s	NoPlayer2_game
	move.l	Lev_PosX2,PosX2
	bra.s	Player2_game_on
NoPlayer2_game:
	move.l	#0,PosX2

Player2_game_on:
	tst.w	Player3_game
	beq.s	NoPlayer3_game
	move.l	Lev_PosX3,PosX3
	bra.s	Player3_game_on
NoPlayer3_game:
	move.l	#0,PosX3

Player3_game_on:
	lea	Iff+$98,a0	;skad kopiowac
	lea	Ekran,a1	;gdzie kopiowac

;	move.l	#256,d0		;ilosc lini do skopiowania

.2					;Z 5 Bitpl robi 5
	move.w	#256*5*40/4-1,d1
.1	move.l	(a0)+,(a1)+
	dbra	d1,.1

;	dbf	d0,.2

	lea	GameCopper,a0
	move.l	a0,$dff080

	lea	Ekran+$bd11,a1	;zycia pierwszego
	move.w	Live1,d1
	bsr.w	Next_Znaczek

	lea	Ekran+$bd1e,a1	;zycia drugiego
	move.w	Live2,d1
	bsr.w	Next_Znaczek

	lea	Ekran+$bd2b,a1	;i trzeciego
	move.w	Live3,d1
	bsr.w	Next_Znaczek

	bsr.w	Ciemno_Jasno	;ROZASNIA OBRAZ

*     **    **   ***
*    *  *  *  *  *  *
*    *  *  *  *  ***
****  **    **   *
Loop:

	lea	Ekran+$bd17,a1		;Adr. Ekranu
	move.l	PunktyPierwszego,d0
	bsr	Points

	lea	Ekran+$bd24,a1		;Adr. Ekranu
	move.l	PunktyDrugiego,d0
	bsr	Points

	lea	Ekran+$bd31,a1		;Adr. Ekranu
	move.l	PunktyTrzeciego,d0
	bsr	Points

;zycia przeniesiono na koniec tercji search for 'pokaz_zycia_tm'

		cmp.b	#$cd,$bfec01	;p = Pausa
	bne.w	no_Pause
		bsr.w	Pause
no_Pause:
;		cmp.b	#$77,$bfec01	;Enter=Restart
;	beq.w	T_T_Te_st
		cmp.b	#$3d,$bfec01	;Prawy Shift=Restart
	beq.w	T_T_Te_st

;		btst	#6,$bfe001	;LMB or Fire Port0
;	beq.w	End
;		btst	#7,$bfe001	;Fire Port1
;	beq.w	End
		cmp.b	#$7f,$bfec01	;Space = End
	beq.w	End

*Pierwszy
	move.w	PosX,d0
	bne.s	OneDo
	move.w	PosY,d1
	beq.s	Drugi
OneDo:
	move.w	PosY,d1
	move.w	LastRuch,d4
	move.w	PlayerOne,d2
	bsr	Ruch

	move.w	d4,LastRuch
	move.w	d0,PosX
	move.w	d1,PosY

Drugi:
	move.w	PosX2,d0
	bne.s	DoDrugi
	move.w	PosY2,d1
	beq.s	Trzeci
DoDrugi:
	move.w	PosY2,d1
	move.w	PlayerTwo,d2
	move.w	LastRuch2,d4

	bsr	Ruch

	move.w	d4,LastRuch2
	move.w	d0,PosX2
	move.w	d1,PosY2

Trzeci:
	move.w	PosX3,d0
	bne.s	DoTrzeci
	move.w	PosY3,d1
	beq.w	End_All_Do
DoTrzeci:
	move.w	PosY3,d1
	move.w	PlayerThree,d2
	move.w	LastRuch3,d4

 	bsr.w	Ruch

	move.w	d4,LastRuch3
	move.w	d0,PosX3
	move.w	d1,PosY3


End_All_Do:
	cmp.b	#63,$bfec01	;left shift=no vertical
	beq	Ultra_Speed

	move.b	#0,$bfec01

	cmp	#1,Speed_tm ;1-fast
	bne.s	FSO126
	not	opz
	beq.s	Ultra_Speed
FSO126
	cmp	#0,Speed_tm	;0 no vertical
	beq.s	Ultra_Speed	;1 fast	(1 frame
				;2 normal (2 frames
;	move.w	#$500,$dff180
					*	 *
Vertical_Part2:				*	 *
	cmp.b	#$ff,$dff006		 *	*
	bne.s	Vertical_Part2		 *	*
Fast_Speed:				  *    *
	cmp.b	#$7,$dff006		   *  *
	bne.s	Fast_Speed		    **
;	move.w	#7,$dff180

Ultra_Speed:

**************
*PierwszyPlot*
**************

	move.w	PosX,d0		;pozyzja x
	bne.s	DoOne
	move.w	PosY,d1		;jezeli obie zero to olewa
	beq.s	Czysto1
DoOne:
	add.l	#1,PunktyPierwszego	;punkty
	move.w	PosY,d1		;pozycja y
	move.l	#2*40,d3	;od ktorego bitplanu zaczynac
	bsr	Plot
	beq.s	Czysto1		;jezeli nie zero to przeszkoda

	move.w	PlayerOne,d2
	btst	#3,d2
	beq.s	PierwszyBang

;PierwszyComputer:
	move.w	LastRuch,d4
	bsr	ComputerMove
	bne.s	PierwszyBang
	move.w	d4,LastRuch
	move.w	d0,PosX
	move.w	d1,PosY
	bra.s	Czysto1
PierwszyBang:
	bsr	RunFlash1
	bra.w	Czysto1

***********
*DrugiPlot*
***********

Czysto1:
	move.w	PosX2,d0
	bne.s	DoTwo
	move.w	PosY2,d1
	beq.s	Czysto2
DoTwo:
	add.l	#1,PunktyDrugiego	;punkty
	move.w	PosY2,d1
	move.l	#3*40,d3
	bsr	Plot

	beq.s	Czysto2
	move.w	PlayerTwo,d2
	btst	#3,d2
	beq.s	DrugiBang

;DrugiComputer:
	move.w	LastRuch2,d4
	bsr	ComputerMove
	beq.s	TfoTfo
DrugiBang:
	bsr	RunFlash2
	bra.s	Czysto2
TfoTfo:
	move.w	d4,LastRuch2
	move.w	d0,PosX2
	move.w	d1,PosY2

*************
*Trzeci Plot*
*************

Czysto2:

	move.w	PosX3,d0
	bne.s	DoThree
	move.w	PosY3,d1
	beq.s	EndOfCicle
DoThree:
	add.l	#1,PunktyTrzeciego	;punkty
	move.w	PosY3,d1
	move.l	#4*40,d3
	bsr	Plot

	beq.s	EndOfCicle
	move.w	PlayerThree,d2
	btst	#3,d2
	beq.s	TrzeciBang

;TrzeciComputer:
	move.w	LastRuch3,d4
	bsr	ComputerMove2
	beq.w	TfoThere
TrzeciBang:
	bsr	RunFlash3
	bra.s	EndOfCicle
TfoThere:
	move.w	d4,LastRuch3
	move.w	d0,PosX3
	move.w	d1,PosY3

EndOfCicle:
	move.w	LFlash1,d0	;czy pierwszy player miga ?
	beq.w	TestFlash2

	lea	GameScreenColor+18,a0	;Colory w copper l.
	lea	Iff+$98+80,a1		;do kopiowania obrazka
	lea	Ekran++80,a2		; to tez
	move.w	Flash_1_loop,d1		;penlta kolorow
	move.w	Flash_1_I_Loop,d2	;pentla dodawan i odej
	move.w	Flash_Color_1,d3	;co dodawac i co odejmowac
	bsr	Flash
	beq.s	NieCrashc1
	move.w	#1,Crash_in_LevelP1

NieCrashc1:
	move.w	d0,LFlash1	;jezeli<>to miganie
	move.w	d1,Flash_1_loop
	move.w	d2,Flash_1_I_Loop
	move.w	d3,Flash_Color_1

TestFlash2:
	move.w	LFlash2,d0
	beq.w	TestFlash3

	lea	GameScreenColor+34,a0
	lea	Iff+$98+120,a1
	lea	Ekran+120,a2
	move.w	Flash_2_loop,d1
	move.w	Flash_2_I_Loop,d2
	move.w	Flash_Color_2,d3
	bsr	Flash
	beq.s	NieCrashc2
	move.w	#1,Crash_in_LevelP2
NieCrashc2:
	move.w	d0,LFlash2
	move.w	d1,Flash_2_loop
	move.w	d2,Flash_2_I_Loop
	move.w	d3,Flash_Color_2

TestFlash3:
	move.w	LFlash3,d0
	beq.w	Test_Flash_End
	lea	GameScreenColor+66,a0
	lea	Iff+$98+160,a1
	lea	Ekran+160,a2
	move.w	Flash_3_loop,d1
	move.w	Flash_3_I_Loop,d2
	move.w	Flash_Color_3,d3
	bsr	Flash
	beq.s	NieCrashc3
	move.w	#1,Crash_in_LevelP3
NieCrashc3:
	move.w	d0,LFlash3
	move.w	d1,Flash_3_loop
	move.w	d2,Flash_3_I_Loop
	move.w	d3,Flash_Color_3
Test_Flash_End:

	tst.w	LFlash1
	bne.w	Loop
	tst.w	LFlash2
	bne.w	Loop
	tst.w	LFlash3
	bne.w	Loop

	moveq	#0,d0

	tst.w	Player1_game	;czy nie wylaczony
	bne.s	x_X_x
	addq.w	#1,d0
x_X_x:	tst.w	Player2_game
	bne.s	x_Y_x
	addq.w	#1,d0
x_Y_x:	tst.w	Player3_game
	bne.s	x_Z_x
	addq.w	#1,d0
x_Z_x:
	cmp.b	#3,d0 ;ilosc wylaczonych jezeli 2 lub trzech to se nie pograsz.
	beq	Game_over_seq
	cmp.b	#2,d0
	beq	Game_over_seq

	add.w	Crash,d0
	cmp.w	#2,d0		;Ilosc wyeliminiwanych !
	blt.w	Loop
*	bne	T_T_Te_st	?

T_T_Te_st:

 ***
*
* **
*  *
*** owno'tm
	tst.w	Crash_in_LevelP1	;jezeli sie zniszczysz
	beq.s	NoNoSubLive1		;to po skoniczeniu innych graczy
	sub.w	#1,Live1		;odejmuje zycia
NoNoSubLive1:
	tst.w	Live1
	bne.s	Ne_1
	btst	#3,PlayerOne+1
	bne.s	computery_nie_gina_1	;jezeli gra computer to traci punkty.

	move.l	PunktyPierwszego,Player1_to_High	;dla hi score
	move.w	#1,Game_Over_Player_1
	move.w	#%1000,PlayerOne	;jezeli zginoles to na twoje miejsce
*	move.w	#0,Player1_game		;wchodzi komputer
computery_nie_gina_1:
	move.w	#4,Live1
	move.l	#0,PunktyPierwszego
Ne_1:
;pokaz_zycia_tm
	lea	Ekran+$bd11,a1	;zycia pierwszego
	move.w	Live1,d1
	bsr.w	Next_Znaczek

	tst.w	Crash_in_LevelP2
	beq.s	NoNoSubLive2
	sub.w	#1,Live2

NoNoSubLive2:
	tst.w	Live2
	bne.s	Ne_2
	btst	#3,PlayerTwo+1
	bne.s	computery_nie_gina_2
	move.l	PunktyDrugiego,Player2_to_High	;dla hi score
	move.w	#1,Game_Over_Player_2
	move.w	#%1000,PlayerTwo
*	move.w	#0,Player2_game
computery_nie_gina_2:
	move.w	#4,Live2
	move.l	#0,PunktyDrugiego
Ne_2:

;pokaz_zycia_tm2
	lea	Ekran+$bd1e,a1	;zycia drugiego
	move.w	Live2,d1
	bsr.w	Next_Znaczek

	tst.w	Crash_in_LevelP3
	beq.s	NoNoSubLive3
	sub.w	#1,Live3
NoNoSubLive3:
	tst.w	Live3
	bne.s	Ne_3
	btst	#3,PlayerThree+1
	bne.s	computery_nie_gina_3
	move.l	PunktyTrzeciego,Player3_to_High	;dla hi score
	move.w	#1,Game_Over_Player_3
	move.w	#%1000,PlayerThree
*	move.w	#0,Player3_game
computery_nie_gina_3:
	move.w	#4,Live3
	move.l	#0,PunktyTrzeciego
Ne_3:
;pokaz_zycia_tm3
	lea	Ekran+$bd2b,a1	;i trzeciego
	move.w	Live3,d1
	bsr.w	Next_Znaczek


;!Tuuuu czy przezyles
	tst.w	Player1_game
	beq.s	.1
	tst.w	Crash_in_LevelP1
	bne	.1
	btst	#3,PlayerOne+1
	beq.s	O_K_Alive
.1
	tst.w	Player2_game
	beq.s	.2
	tst.w	Crash_in_LevelP2
	bne	.2
	btst	#3,PlayerTwo+1
	beq	O_K_Alive
.2
	tst.w	Player3_game
	bne	go_on
	tst.w	Crash_in_LevelP3
	bne	go_on
	btst	#3,PlayerThree+1
	bne	go_on
;jezeli przezyles !
O_K_Alive:
	move.w	#0,Crash_in_LevelP1
	move.w	#0,Crash_in_LevelP2
	move.w	#0,Crash_in_LevelP3
	BSR.W	Jasno_Ciemno
	lea	Copper,a0
	move.l	a0,$dff080
	bsr	copy_tlo
	lea	LevelPass(pc),a0
	bsr	WyswietlText
	bsr	CJM
	bsr	czekay
	bsr	JCM
	addq.w	#1,Level
	cmp.w	#9,Level
	bne	no0
	move.w	#0,Level
no0
	bra	Start_Game

go_on:
	move.w	#0,Crash_in_LevelP1
	move.w	#0,Crash_in_LevelP2
	move.w	#0,Crash_in_LevelP3

;jezeli przezyly tylko komputery to game over !
;tylko jak sie do tego zabrac ?
	moveq	#0,d0
	btst	#3,PlayerOne+1	;jezeli komputer to dodaje
	beq.s	C_Cont_C11
	addq.w	#1,d0
	bra.s	C_Cont_C1
C_Cont_C11:
	tst.w	Player1_game	;nie komputer to moze niegra (zginol lub cus)
	bne.s	C_Cont_C1
	addq.w	#1,d0
C_Cont_C1:
	btst	#3,PlayerTwo+1
	beq.s	C_Cont_C22
	addq.w	#1,d0
	bra.s	C_Cont_C2
C_Cont_C22:
	tst.w	Player2_game
	bne.s	C_Cont_C2
	addq.w	#1,d0
C_Cont_C2:
	btst	#3,PlayerThree+1
	beq.s	C_Cont_C33
	addq.w	#1,d0
	bra.s	C_Cont_C3
C_Cont_C33:
	tst.w	Player3_game
	bne.s	C_Cont_C3
	addq.w	#1,d0
C_Cont_C3:
	cmp.w	#3,d0
	bge.s	Game_over_seq	;wieksze lub rowne !

	BSR.W	Jasno_Ciemno
	bra.w	GameLoop

Game_over_seq:
	BSR.W	Jasno_Ciemno
	bsr.w	copy_tlo
	lea	Copper,a0
	move.l	a0,$dff080

	lea	Game_Over_Text(pc),a0
	bsr.w	WyswietlText
	tst.w	Game_Over_Player_1
	beq.s	sadassd_1
	move.w	#0,Game_Over_Player_1	;czysci wskaznik game over

	move.l	Player1_to_High(pc),d0
	lea	16+GO1Txt(pc),a0
	move.w	#1,Special_P	;tryb specjalny (tylko wrzuci liczbe
	bsr.w	Tylko_Wrzuc

	lea	GO1Txt(pc),a0	;wyswietla game over pl 1
	bsr.w	WyswietlText
	bsr	CJM
	bsr	czekay
	bsr	JCM

	bsr	copy_tlo
	bsr	CJM
	move.l	Player1_to_High(pc),hhhhh
	bsr	hi_score_p
	bsr	JCM

sadassd_1:
	tst.w	Game_Over_Player_2
	beq.s	sadassd_2
	move.w	#0,Game_Over_Player_2

	move.l	Player2_to_High,d0
	lea	16+GO2Txt(pc),a0
	move.w	#1,Special_P
	bsr.w	Tylko_Wrzuc

	lea	GO2Txt(pc),a0
	bsr.w	WyswietlText
sadassd_2:
	tst.w	Game_Over_Player_3
	beq.s	sadassd_3
	move.w	#0,Game_Over_Player_3

	move.l	Player3_to_High,d0
	lea	16+GO3Txt(pc),a0
	move.w	#1,Special_P	;tryb specjalny (tylko wrzuci liczbe
	bsr.w	Tylko_Wrzuc

	lea	GO3Txt(pc),a0
	bsr.w	WyswietlText
sadassd_3:
	bsr	CJM
	bsr	czekay
	bsr	JCM

	rts

******
*     *
*     *
******
*     *
*     *
*     *uch

Ruch:
	btst	#0,d2
	beq.s	JoyPort1
JoyPort0:
	bsr	Joystick0
	bra.s	EndRuch
JoyPort1:
	btst	#1,d2
	beq.s	Key
;Joy1
	bsr	Joystick1
	bra.s	EndRuch
Key:
	btst	#2,d2
	beq.s	Comp1			****
;Keyboard
	bsr	Keyboard
	bra.w	EndRuch
Comp1:
	bsr	Last
EndRuch:	rts

* * * * *
ComputerMove:
* * * * *
*	%0001	Prawo
*	%0010	Lewo
*	%0100	Dol
*	%1000	Gora

	btst	#0,d4
	beq.s	CompLewoL
;CompPrawoLast			;Zderzenie z prawej
	subq.w	#1,d0	;x-1
	addq.w	#1,d1	;y+1
	bsr	Plot
	bne.s	DolZajety
	move.w	#%0100,d4	;jedz w dol
	bra.w	CompRuchEnd
DolZajety:
	subq.w	#2,d1	;poprzednio dodal 1 to teraz odjol 2
	bsr	Plot
	bne.s	Kill
	move.w	#%1000,d4	;jedz w gore
	bra.w	CompRuchEnd
CompLewoL:
	btst	#1,d4
	beQ.s	CompDownL
;CompLewoLast
	addq.w	#1,d0
	addq.w	#1,d1
	bsr	Plot
	bne.s	DolZajety
	move.w	#%0100,d4	;jedz w dol
	bra.w	CompRuchEnd
CompDownL:
	btst	#2,d4
	beQ.s	CompUpL
;CompDownLast
	subq.w	#1,d1	;Y-1
	subq.w	#1,d0	;x-1
	bsr	Plot
	bne.s	LewoZajete
	move.w	#%0010,d4	;jedz w lewo
	bra.w	CompRuchEnd
LewoZajete:
	addq.w	#2,d0
	bsr	Plot
	bne.s	Kill
	move.w	#%0001,d4	;w prawo
	bra.w	CompRuchEnd
CompUpL:
	addq.w	#1,d1
	subq.w	#1,d0
	bsr	Plot
	bne.s	LewoZajete
	move.w	#%0010,d4	;w lewo

CompRuchEnd:
	moveq	#0,d2
	rts
Kill:
	move.w	#$ffff,d2
	rts

ComputerMove2:

	btst	#0,d4
	beq.s	CompLewoL2
;CompPrawoLast			;Zderzenie z prawej
	subq.w	#1,d0	;x-1
	subq.w	#1,d1	;y-1
	bsr	Plot
	bne.s	GorZajety2
	move.w	#%1000,d4	;jedz w dol
	bra.w	CompRuchEnd
GorZajety2:
	addq.w	#2,d1	;poprzednio dodal 1 to teraz odjol 2
	bsr	Plot
	bne.s	Kill
	move.w	#%0100,d4	;jedz w dol
	bra.w	CompRuchEnd
CompLewoL2:
	btst	#1,d4
	beQ.s	CompDownL2
;CompLewoLast
	addq.w	#1,d0		;x+1
	subq.w	#1,d1		;y-1
	bsr	Plot
	bne.s	GorZajety2
	move.w	#%1000,d4	;jedz w gore
	bra.w	CompRuchEnd
CompDownL2:
	btst	#2,d4
	beQ.s	CompUpL2
;CompDownLast
	subq.w	#1,d1	;y-1
	addq.w	#1,d0	;x+1
	bsr	Plot
	bne.s	PrawZajete2
	move.w	#%0001,d4	;jedz w prawo
	bra.w	CompRuchEnd
PrawZajete2:
	subq.w	#2,d0	;x-2 (pozycja przed zderzeniem)
	bsr	Plot
	bne.s	Kill
	move.w	#%0010,d4	;w lewo
	bra.w	CompRuchEnd
CompUpL2:
	addq.w	#1,d1	;y+1
	addq.w	#1,d0	;x+1
	bsr	Plot
	bne.s	PrawZajete2
	move.w	#%0001,d4	;w prawo
	bra.w	CompRuchEnd

Joystick0:
	move.w	$dff00a,d2		;Port0
	bra.s	JoyStick
Joystick1:
	move.w	$dff00c,d2		;Port0
JoyStick:
	btst	#1,d2
	beq.s	Left
;Prawo
	btst	#1,d4
	bne.s	Last
	move.w	#%0001,d4
	addq.w	#1,d0
	bra.w	RuchEnd
Left:
	btst	#9,d2
	beq	UpDown		;1=Lewo 0=Brak Lewa
;Lewo
	btst	#0,d4
	bne.s	Last
	move.w	#%0010,d4
	subq.w	#1,d0
	bra.w	RuchEnd
UpDown:
	move.w	d2,d3
	lsr.w	#1,d3
	eor.w	d2,d3
	btst	#0,d3
	beq.s	Gora
;Dol
	btst	#3,d4
	bne.s	Last
	move.w	#%0100,d4

	addq.w	#1,d1
	bra.s	RuchEnd
Gora:
	btst	#2,d4
	bne.s	Last
	btst	#8,d3
	beq.s	Last

	move.w	#%1000,d4

	sub.w	#1,d1
	bra.w	RuchEnd

Last:

	btst	#0,d4
	beQ.s	LewoL
;PrawoLast
	addq.w	#1,d0
	bra.w	RuchEnd
LewoL:
	btst	#1,d4
	beQ.s	DownL
;LewoLast
	subq.w	#1,d0
	bra.w	RuchEnd
DownL:
	btst	#2,d4
	beQ.s	UpL
;DownLast
	addq.w	#1,d1
	bra.w	RuchEnd
UpL:
	subq.w	#1,d1
	bra.w	RuchEnd

RuchEnd:
	rts

*******
Plot: **
*******
; a0 adr pocz lini na ekr
; d0-pos x d1-pos y

	lea	Ekran,a0	;Ekr start
	add.l	d3,a0

	lea	Ekran+2*40,a1	;120

	move.w	d1,d2
	muls	#40*5,d2	;Bajty w lini*wys
	add.l	d2,a0
	add.l	d2,a1

	move.w	d0,d2	;save x
	lsr.w	#3,d2	;/8
	not.b	d0

;Check3Bitpl
	btst	d0,(a1,d2.w)
	bne.s	Zderzenie

;Check4Bitpl
	add.l	#40,a1
	btst	d0,(a1,d2.w)
	bne.s	Zderzenie

;Check5Bitpl
	add.l	#40,a1
	btst	d0,(a1,d2.w)
	bne.s	Zderzenie

;NiemaZderzenia
	bset	d0,(a0,d2.w)
	not.b	d0
	moveq	#0,d2
	rts

Zderzenie:
	not.b	d0
	move.w	#$ffff,d2	;Error Zderzenie
	rts


**** **** **** **** ****
Keyboard:
**** **** **** **** ****

	move.b	$bfec01,d2		;Keyboard

	cmp.b	#$63,d2		:Prawo
	bne.w	KLeft
;Prawo
	btst	#1,d4
	bne.w	Last
	move.w	#%0001,d4
	addq.w	#1,d0
	bra.w	KeybordEnd
KLeft:
	cmp.b	#$61,d2		;Lewo
	bne	KUpDown
;Lewo
	btst	#0,d4
	bne.w	Last
	move.w	#%0010,d4
	subq.w	#1,d0
	bra.w	KeybordEnd
KUpDown:
	cmp.b	#$65,d2		;Dol
	bne.s	KGora
;Dol
	btst	#3,d4
	bne.w	Last
	move.w	#%0100,d4

	addq.w	#1,d1
	bra.s	KeybordEnd
KGora:
	btst	#2,d4
	bne.w	Last
	cmp.b	#$67,d2		;Gora
	bne.w	Last

	move.w	#%1000,d4

	sub.w	#1,d1
	bra.w	KeybordEnd

KeybordEnd:

	rts
****
*
**
*
*lash

RunFlash1:
	lea	GameScreenColor+18,a0
	move.l	#0,PosX
	move.w	#$0111,d3	;kolory 1
	move.w	#2,LFlash1	;jezeli<>to miganie (2=najpierw odejmowac)
	move.w	#16,Flash_1_loop	;pentla colorow  (1=najpierw dodawac)
	move.w	#16*4,Flash_1_I_Loop	;ile razy wykonac
	move.w	d3,Flash_Color_1
	rts

RunFlash2:
	lea	GameScreenColor+34,a0
	lea	Iff+$98+120,a1
	lea	Ekran+120,a2
	move.l	#0,PosX2
	move.w	#$0011,d3	;kolory drugiego
	move.w	d3,Flash_Color_2
	move.w	#2,LFlash2	;jezeli<>to miganie
	move.w	#16,Flash_2_loop	;pentla colorow
	move.w	#16*4,Flash_2_I_Loop	;ile razy wykonac
	rts

RunFlash3:
	lea	GameScreenColor+66,a0
	lea	Iff+$98+160,a1
	lea	Ekran+160,a2
	move.l	#0,PosX3
	move.w	#$0110,d3	;kolory 3
	move.w	d3,Flash_Color_3
	move.w	#2,LFlash3	;jezeli<>to miganie
	move.w	#16,Flash_3_loop	;pentla colorow
	move.w	#16*4,Flash_3_I_Loop	;ile razy wykonac
	rts

Flash:
	cmp.w	#1,d0
	beq.s	Flash_Add
;Flash_Down:
	sub.w	d3,(a0)+
	addq.l	#2,a0
	sub.w	d3,(a0)+
	addq.l	#2,a0
	sub.w	d3,(a0)+
	addq.l	#2,a0
	sub.w	d3,(a0)+

	subq.w	#1,d1		;Pentla (16 w dol i 16 w gore)
	bne.s	Flash_The_End
	moveq	#1,d0	;teraz w gore
	move.w	#16,d1
	bra.s	Flash_The_End
Flash_Add:
	add.w	d3,(a0)+
	addq.l	#2,a0
	add.w	d3,(a0)+
	addq.l	#2,a0
	add.w	d3,(a0)+
	addq.l	#2,a0
	add.w	d3,(a0)+

	subq.w	#1,d1
	bne.s	Flash_The_End
	moveq	#2,d0	;teraz w dol
	move.w	#16,d1	;odnowienie pentli

Flash_The_End:	
	subq.w	#1,d2	;16*odejmowac i szesn razy dod)
	bne.s	Flash_The_NOT_ALL_END

	moveq	#0,d0
BitCy
	btst	#14,$dff002
	bne.s	BitCy

	move.l	a1,$dff050		;BLTAPT
	move.l	a2,$dff054		;BLTDPT
	move.l	#$ffffffff,$dff044	;BLTAFWM and LFWM
	move.l	#$9f00000,$dff040	;BLTCON0 d=a i 0 do bltcon1
	move.l	#$00a000a0,$dff064		;BLTAMOD i d
	move.w	#[255*64]+[320/16],$dff058	;BLTSIZE

	add.w	#1,Crash	;liczba zabitych

	moveq	#1,d5
	rts

Flash_The_NOT_ALL_END:
	moveq	#0,d5
	rts

  *   *
Pause:
  *   *
	btst	#0,$bfec01
	bne.s	Pause
P_Pause:
	cmp.b	#$cd,$bfec01	;p=koniec pausy
	bne.s	P_Pause
Pause0:
	btst	#0,$bfec01
	bne.s	Pause0

	rts

*  *  *
Points:
*  *  *
;To ..... ! Zamiena dana w pamieci na Dziesietna w asci !
;dziekuje ci real destruction...

;wescie:
;	a1 adres ekranu (bez special
;	a0 gdze wrzucac liczbe w asci
;	d0 liczba


	lea	Hi,a0
	move.l	a0,a2
Tylko_Wrzuc
	lea	Dzes,a3	;tabela dziesiatek (wykopanie divsa
	moveq	#0,d2
	move.l	(a3)+,d1
Dziel
	move.l	(a3)+,d1
	beq	nomore
PorLiczbe
	cmp.l	d1,d0
	blt.s	Moze		;Gdy mniejszy
	sub.l	d1,d0
	addq.b	#1,d2
	bra.s	PorLiczbe
Moze
	move.b	d2,(a0)+	;Wrzutka liczby
	moveq	#0,d2
	bra.s	Dziel
nomore
	tst.w	Special_P	;czy specjalne wejscie (hi score,game over)
	beq.s	No_Special_P	;nie to nie
	move.w	#0,Special_P
	sub.l	#5,a0
	add.b	#$30,(a0)+	;?'0'=$30
	add.b	#$30,(a0)+
	add.b	#$30,(a0)+
	add.b	#$30,(a0)+
	add.b	#$30,(a0)+
	rts
Special_P:	dc.w	0
;
No_Special_P:
	moveq	#0,d0
	moveq	#4,d1
More:
	lea	Fonts+$10*8,a0		;Fonts
Offset:
	move.b	(a2)+,d0
	rol.w	#3,d0			;*8
	add.l	d0,a0

	moveq	#8,d0
CopyFont:
	move.b	(a0)+,(a1)
	add.l	#40*5,a1
	subq.b	#1,d0
	bne.w	CopyFont

	sub.l	#8*40*5-1,a1
	dbra	d1,More
	rts

;pokazuje ilosc zyc

Next_Znaczek:
	subq.w	#1,d1
	beq.s	Ent_Znaczek
	bmi.s	Ent_Znaczek  *to tez
	cmp.w	#5,d1
	bls.s	N_Znacz	;nizszy,rowny
	moveq	#5,d1
N_Znacz:
	lea	Fonts+24,a0		;znaczek zycia
	moveq	#8,d0
CopyZnaczek:
	move.b	(a0)+,(a1)
	add.l	#40*5,a1
	subq.b	#1,d0
	bne.w	CopyZnaczek

	sub.l	#8*40*5-1,a1
	subq.w	#1,d1
	bne.s	N_Znacz
Ent_Znaczek:	*jak i to
	rts

******************************************
End:			;(for the game) _Game_End_
	BSR.W	Jasno_Ciemno
;	movem.l	(sp)+,d0-d7/a0-a6
	rts

******************************************

;Track disk device ,but i'm not sure at all. . .  .   .    .     .      .
;destroyed by r.the.k/r.d. of course in vitava [2*2*50*12]/2+790+[x*x-2]
;x=2
;written on trash'm-one by deftronic.

TrackDiskDevice:
	rts

	movem.l	d0-d7/a0-a6,-(sp)
	move.l	4.w,a6

	sub.l	a1,a1
	jsr	-294(a6)	;find task (name a1)
	move.l	d0,ReadReply+16	;?
	lea	ReadReply,a1
	jsr	-354(a6)	;addport (port a1)
	lea	DiskIO,a1	;?

	moveq	#0,d0
	moveq	#0,d1

	lea	TrackName,a0

	jsr	-444(a6) 	;open device devName,unit,ioRequest,flags a0,d0,a1,d1

	tst.l	d0
	bne.s	Track_Error
* * * *
	lea	DiskIO,a1
	move.l	#ReadReply,14(a1)	;set reply port
	lea	DiskIO,a1
	move.w	#9,28(a1)	;command: TD_MOTOR
	move.l	#0,36(a1)	;Turn motor off
	jsr	-456(a6)	;DoIo

* * * *
	lea	ReadReply,a1
	jsr	-360(a6)	;RemPort (port a1)
	lea	DiskIO,a1
	jsr	-450(a6)	;CloseDevice (ioRequest a1)

Track_Error:
	movem.l	(sp)+,d0-d7/a0-a6
	rts

TrackName:	dc.b	'trackdisk.device',0,0
	even
DiskIO:	blk.l	20,0
ReadReply:	blk.l	8,0

Col_Zmienna:	dc.w	0

Ciemno_Jasno:
;To ma rozjasnic obraz do dobrych kolorow !

	moveq	#0,d3
	moveq	#$f,d5
Color_The_Loop:
	bsr	Wait
	lea	GameScreenColor+2,a0	;Kolory copper (gdzie wrzucac
	lea	MintimeColor+2,a1	;co powinno byc (skad brac
	move.w	#2,Col_Zmienna
Three_l0:
	moveq	#32,d7 ;ilosc colorow
Three_l1:
	moveq	#3,d6
	moveq	#0,d2
	moveq	#$f,d4
Three_l2:
	move.w	(a1),d3
	and.w	d4,d3
	cmp.w	d5,d3
	bpl.s	.1
	moveq	#0,d3
	bra.s	NextcC
.1
	sub.w	d5,d3
NextcC:
	add.w	d3,d2
	lsl.w	#4,d5
	lsl.w	#4,d4
	subq.w	#1,d6
	bne.s	Three_l2

	move.w	d2,(a0)
	addq.l	#4,a0
	addq.l	#4,a1
	lsr.w	#8,d5
	lsr.w	#4,d5

	subq.w	#1,d7
	bne.w	Three_l1

	add.l	#8,a0	;2 dlugie slowa nastepna linia punkty
	sub.w	#1,Col_Zmienna
	bne.s	Three_l0

	dbf	d5,Color_The_Loop

	rts


Jasno_Ciemno:
;Sciemnia obrazek...

	moveq	#16,d0		;to samo 15 czy 16 16!

Szesna_Loop:
	bsr	Wait
	lea	GameScreenColor+2,a0 (skad brac i gdzie wrzucac
	move.w	#2,Col_Zmienna

Point_SLoop:
	move.w	#32,d1
Ilosc_Loop:
	move.w	#%0000000000001111,d2
	move.w	#$0001,d3
	moveq	#0,d6
	moveq	#3,d5
Three_loop:
	move.w	(a0),d4
	and.w	d2,d4
	beq.s	NieSciemniaj
	sub.w	d3,d4
NieSciemniaj:
	lsl.w	#4,d2
	lsl.w	#4,d3
	add.w	d4,d6	;wynik
	subq.w	#1,d5
	bne.s	Three_loop

	move.w	d6,(a0)
	addq.l	#4,a0

	subq.w	#1,d1	;ilosc kolorow
	bne.s	Ilosc_Loop

	add.l	#8,a0	;2 dlugie slowa nastepna linia punkty
	sub.w	#1,Col_Zmienna
	bne.s	Point_SLoop

	subq.l	#1,d0	;Sciemnianie do zera $f
	bne.s	Szesna_Loop
	rts

JCM:
;Sciemnia menu.
;d0-d6 a0
	moveq	#16-1,d0
Szesna_loopM:
	VERTICAL $100
	VERTICAL $101
	lea	ScreenColor+2,a0 (skad brac i gdzie wrzucac
Point_SLoopM:
	moveq	#16-1,d1 ;ilosc kolorow
Ilosc_LoopM:
	moveq	#%0000000000001111,d2
	moveq	#$0001,d3
	moveq	#0,d6
	moveq	#3,d5
Three_loopM:
	move.w	(a0),d4
	and.w	d2,d4
	beq.s	NieSciemniajM
	sub.w	d3,d4
NieSciemniajM:
	lsl.w	#4,d2
	lsl.w	#4,d3
	add.w	d4,d6	;wynik
	subq.w	#1,d5
	bne.s	Three_loopM

	move.w	d6,(a0)
	addq.l	#4,a0

	dbf	d1,Ilosc_LoopM

	dbf	d0,Szesna_loopM	;Sciemnianie do zera $f
	rts

CJM:
;To ma rozjasnic obraz do dobrych kolorow !
;d3-d7 a0-a1
	moveq	#0,d3
	moveq	#$f,d5
Color_The_loopM:
	bsr	Wait_S
	lea	2+ScreenColor,a0	;Kolory copper
	lea	2+ScreenMinColor(pc),a1	;co powinno byc
	moveq	#16-1,d7 ;ilosc colorow
Three_L1M:
	moveq	#3,d6
	moveq	#0,d2
	moveq	#$f,d4
Three_l2M:
	move	(a1),d3
	and	d4,d3
	cmp	d5,d3
	bpl.s	NextCM
	moveq	#0,d3
	bra.s	NextcCM
NextCM:
	sub	d5,d3
NextcCM:
	add	d3,d2
	lsl	#4,d5
	lsl	#4,d4
	subq	#1,d6
	bne.s	Three_l2M

	move	d2,(a0)
	addq.l	#4,a0
	addq.l	#4,a1
	lsr	#8,d5
	lsr	#4,d5

	dbf	d7,Three_L1M

	dbf	d5,Color_The_loopM

	rts


Wait:
	move.l	d0,-(sp)
	moveq	#3-1,d0		;opoznienie w Verticalach
Wwait:
	cmp.b	#$ff,$dff006
	bne.s	Wwait
wwait0:	cmp.b	#$fe,$dff006
	bne.s	wwait0
	dbf	d0,Wwait
	move.l	(sp)+,d0
	rts
Wait_S:
	move.l	d0,-(sp)
	moveq	#1,d0
ve2	cmp.b	#$fe,$dff006
	bne.s	ve2
ve3	cmp.b	#$ff,$dff006
	bne.s	ve3
	dbf	d0,ve2
	move.l	(sp)+,d0
	rts
Czysc_Colory:
;Poniewaz kolory sa przerzucane gdzie indziej to to tworzy kolory 0

	move.w	#$180,d0
	moveq	#32,d1
Rub180:
	move.w	d0,(a0)+
	move.w	#0,(a0)+
	addq.w	#2,d0
	subq.w	#1,d1
	bne.s	Rub180
	rts

;*********************************
;* POWER PACKER DECRUNCH ROUTINE *
;*********************************
; Resourced by Mac of Katharsis!
;
;przy wejsciu w a0 start bloku,w d0 dlugosc bloku
;	w a1 dokad ma zdepakowac
;	kod jest calkowicie relokowalny
;

Power_Packer:
	cmpi.l #'PP20',(a0)	;tylko standartowe pliki
	bne.s rets		;nie zakodowane etc.
	lea costam(pc),a2
	move.l 4(a0),(a2)
	add.l d0,a0
	movem.l	d1-d7/a2-a6,-(sp)
	bsr.s	lbCEAE
	movem.l	(sp)+,d1-d7/a2-a6
rets
	rts
lbCEAE
	move.l a1,a2
	lea costam(pc),a5
	move.l -(a0),d5
	moveq	#0,d1
	move.b d5,d1
	lsr.l #8,d5
	add.l d5,a1
	move.l -(a0),d5
	lsr.l d1,d5
	move.b	#$20,d7
	sub.b d1,d7
lbC000EC8
	bsr.s lbC000F3A
	tst.b d1
	bne.s lbC000EEE
	moveq #0,d2
lbC000ED0
	moveq #2,d0
	bsr.s lbC000F3C
	add.w d1,d2
	cmp.w #3,d1
	beq.w lbC000ED0
lbC000EDC
	moveq #8,d0
	bsr.s lbC000F3C
	move.b	d1,-(a1)
	dbf d2,lbC000EDC
	cmp.l	a1,a2
	bcs.s	lbC000EEE
	rts
lbC000EEE
	moveq #2,d0
	bsr.s	lbC000F3C
	moveq	#0,d0
	move.b	0(a5,d1.w),d0
	move.l	d0,d4
	move.w	d1,d2
	addq.w	#1,d2
	cmp.w	#4,d2
	bne.s lbC000F20
	bsr.s lbC000F3A
	move.l d4,d0
	tst.b d1
	bne.s lbC000F0E
	moveq	#7,d0
lbC000F0E
	bsr.s	lbC000F3C
	move.w	d1,d3
lbC000F12
	moveq #3,d0
	bsr.s lbC000F3C
	add.w	d1,d2
	cmp.w	#7,d1
	beq.w	lbC000F12
	bra.s	lbC000F24
lbC000F20
	bsr.s	lbC000F3C
	move.w	d1,d3
lbC000F24
	move.b	0(a1,d3.w),d0
	move.b	d0,-(a1)
	dbf d2,lbC000F24
*	move.w	d3,$00DFF180	;kolor decrunchu	[a ja go wykopalem]
	cmp.l	a1,a2		;troche go zmienilem	[r the k]
	bcs.s	lbC000EC8
	rts
lbC000F3A
	moveq	#1,d0
lbC000F3C
	moveq	#0,d1
	subq.w	#1,d0
lbC000F40
	lsr.l	#1,d5
	roxl.l	#1,d1
	subq.b	#1,d7
	bne.s	lbC000F4E
	move.b	#$20,d7
	move.l	-(a0),d5
lbC000F4E
	dbf d0,lbC000F40
	rts
costam	dc.l	$090A0B0B

	blk.l	40,0

MintimeColor:
	blk.l	32,0
Mintime_Points_Color:
 dc.w	$0180,$0000,$0182,$0ddd,$0184,$0bbb,$0186,$0aaa
 dc.w	$0188,$0fff,$018a,$0fff,$018c,$0fff,$018e,$0fff
 dc.w	$0190,$00ff,$0192,$00ff,$0194,$00ff,$0196,$00ff
 dc.w	$0198,$0009,$019a,$000b,$019c,$000d,$019e,$000f
 dc.w	$01a0,$0ff0,$01a2,$0ff0,$01a4,$0ff0,$01a6,$0ff0
 dc.w	$01a8,$000a,$01aa,$00a0,$01ac,$0a00,$01ae,$00aa
 dc.w	$01b0,$0111,$01b2,$0333,$01b4,$0555,$01b6,$0666
 dc.w	$01b8,$0888,$01ba,$0aaa,$01bc,$0ccc,$01be,$0eee


MenuText:	;   '                    '
	dc.b	0
	dc.b	  3,' <REAL DESTRUCTION>',0
	dc.b	 28,'    Gdynia 1992-3',0
	dc.b	 70,' F1 - Player One',0
	dc.b	 91,' F2 - Player Two',0
	dc.b	112,' F3 - Player Three',0
	dc.b	132,' F4 - HiScore',0
	dc.b	150,' F5 - Password ',0
	dc.b	170,' F6 - Credits',0
	dc.b	210,'F10 - Start',0
	dc.b	0,0
	even

ControlText:	;   '                    '
	dc.b	0
	dc.b	 60,' F1 - Joy Port 1',0
	dc.b	 81,' F2 - Joy Port 0',0
	dc.b	102,' F3 - Keyboard',0
	dc.b	124,' F4 - COMPUTER',0
	dc.b	145,'*F5 - Redefine Keys',0
	dc.b	166,' F6 - No player',0
	dc.b	0,0
	even

WarningText:	;   '                    '
	dc.b	0
	dc.b	 40,'      Warning !',0
	dc.b	 60,'    This is just',0
	dc.b	 81,'    a preview of',0
	dc.b	103,'  coming full game',0
	dc.b	125,'        from',0
	dc.b	147,' <Real Destruction>',0
	dc.b	0,0
	even

GwiazdkaThings:	;   '                    '

	dc.b	0
	dc.b	100,'   Things with *',0
	dc.b	121,'     dont work',0
	dc.b	0,0
	even

CreditsText0:
	dc.b	0
	dc.b	 60,'    Light Cycle',0
	dc.b	 85,'       is  a',0
	dc.b	110,' <Real Destruction>',0
	dc.b	132,'     Production',0
	dc.b	231,' Gdynia 1993.01.03',0
	dc.b	0,0
	even
CreditsText1:
	dc.b	0
	dc.b	 99,'Credits:',0
	dc.b	120,'    Gfx:Sleeper/RD',0
	dc.b	141,'  Music:BFA/Suspect',0
	dc.b	162,'  Music:Dr.Stool/RD',0
	dc.b	183,'   Code:R.The.K./RD',0
	dc.b	0,0
	even

CreditsText2:
	dc.b	0
	dc.b	  5,'    Instruction:',0
	dc.b	 50,'Press:',0
	dc.b	 75,'P     - Pause',0
	dc.b	 96,'M     - Music ON/OFF',0
	dc.b	117,'L.SHIFT - Restart',0
	dc.b	138,'R.SHIFT - Speed Up',0
	dc.b	159,'SPACE - Quit Game',0
	dc.b	180,'Esc in menu for quit',0
	dc.b	201,'    to dos',0
	dc.b	0,0
	even

CreditsText3:	;   '                    '
	dc.b	0
	dc.b	  4,'If you wanna contact',0
	dc.b	 23,' <Real Destruction>',0
	dc.b	 45,'   Then write to:',0
	dc.b	 66,'     [R.The.K.]',0
	dc.b	104,'  Rafal Konkolewski',0
	dc.b	125,' Nauczycielska 4/23',0
	dc.b	146,'       81-614',0
	dc.b	167,'       Gdynia',0
	dc.b	188,'       Poland',0
	dc.b	0,0

CreditsText4:	;   '                    '
	dc.b	0
	dc.b	  1,' Grettings fly to:',0
	dc.b 	 21,' BFA, Coza, Creator',0
	dc.b	 42,'   Crupel Monster',0
	dc.b	 63,'   Dr.Stool, Fenom',0
	dc.b	 84,'  Glowa, Ifa, Kane',0
	dc.b	105,'     KWK, Locky',0
	dc.b	126,'  Malin, Michal M',0
	dc.b	147,'  Pillar, Piontal',0
	dc.b	168,'  Przemas, Rewizor',0
	dc.b	189,'SCA, Slipper, Sergey',0
	dc.b	210,'TCDS, Tetlox, Torba',0
	dc.b	231,'        XTD',0

	dc.b	0,0
	even

Lev0Text
	dc.b 0
	dc.b 160,'Loading Level ',0,0,0,0

LevelPass
 dc.b 0
 dc.b 120,' You may pass',0,0

Game_Over_Text:	;   '                    '
	dc.b	0
	dc.b	 50,' Its look like...',0
	dc.b	 71,'     Game Over.',0
	dc.b	0,0

GO1Txt:		;'                    '
	dc.b	0
	dc.b	 92,'Player 1 -          ',0
	dc.b	0,0

GO2Txt:		;'                    '
	dc.b	0
	dc.b	113,'Player 2 -          ',0
	dc.b	0,0

GO3Txt:		;'                    '
	dc.b	0
	dc.b	135,'Player 3 -          ',0
	dc.b	0,0

Text:
	dc.b	0
	dc.b	 70,'  Enter Password:'
p_text:
	dc.b	0
	dc.b	120,'    ____________    ',0,0

Password_Table:

;Levels code
	dc.b	'alien 3_____'	;0
	dc.b	'none________'	;1
	dc.b	'lev2________'	;2
	dc.b	'lev3________'	;3
	dc.b	'lev4________'	;4
	dc.b	'lev5________'	;5
	dc.b	'lev6________'	;6
	dc.b	'lev7________'	;7
	dc.b	'lev8________'	;8
	dc.b	'lev9________'	;9
	dc.b	'lev10_______'	;10
	dc.b	'MTV_________'	;11 Special from here
	dc.b	'Loki________'	;12
	dc.b	'R.The.K.____'	;13
	dc.b	'Dr.Stool____'	;14
	dc.b	'Piontal_____'	;15
	dc.b	'Slipper_____'	;16
	dc.b	'Shit________'	;17
	dc.b	'fuck________'	;18
	dc.b	'fuck off____'	;19
	dc.b	'tcds________'	;20
	dc.b	'Pillar______'	;21
	dc.b	'Colombo_____'	;22
	dc.b	'Kane________'	;23
	dc.b	'Creator_____'	;24
	dc.b	'SCA_________'	;25
	dc.b	'Michal M____'	;26

ilosc_chasel	equ 24+1

DosName:	dc.b 'dos.library',0
Gfxname:	dc.b 'graphics.library',0,0

*******************************************************************************
*				TEXTY DO HASE?L				      *
*******************************************************************************

;texty passwordow
AlienTXT: ;'                    ' ;11
 dc.b	0
 dc.b	 150,'    This is good.',0,0

EmptyT: ;'                    ' ;11
 dc.b	0
 dc.b	 150,'not now',0,0

mtvTXT:   ;'                    ' ;11
	dc.b	0
 dc.b	 110,'     I like MTV',0,0

LockyTXT:  ;'                    ' ;12
	dc.b	0
 dc.b	 130,'    How how how...',0
 dc.b	 152,' my brother is here.',0,0

PillarTXT:;'                    ' ;21
	dc.b	0
 dc.b	 150,' Thanks for help.',0,0
* dc.b	 173,'       ',0,0

KaneTXT ;'                    ' ;23
	dc.b	0
 dc.b	 150,' Thanks for help.',0,0

CreatTXT ;'                    ' ;24
	dc.b	0
 dc.b	129,'!!!!!!!!!!!!!!!!!!!!',0
 dc.b	150,'     MOJE DYSKI',0
 dc.b	172,'!!!!!!!!!!!!!!!!!!!!',0,0

 	even

Level0_FM:	dc.b	'dh1:sources/lightcycle/Levels/Level0.pic.pp',0
Level1_FM:	dc.b	'dh1:sources/lightcycle/levels/Level1.pic.pp',0
Level2_FM:	dc.b	'dh1:sources/lightcycle/levels/Level2.pic.pp',0
Level3_FM:	dc.b	'dh1:sources/lightcycle/levels/Level3.pic.pp',0
Level4_FM:	dc.b	'dh1:sources/lightcycle/levels/Level4.pic.pp',0
Level5_FM:	dc.b	'dh1:sources/lightcycle/levels/Level5.pic.pp',0
Level6_FM:	dc.b	'dh1:sources/lightcycle/levels/Level6.pic.pp',0
Level7_FM:	dc.b	'dh1:sources/lightcycle/levels/Level7.pic.pp',0
Level8_FM:	dc.b	'dh1:sources/lightcycle/levels/Level8.pic.pp',0
Level9_FM:	dc.b	'dh1:sources/lightcycle/levels/Level9.pic.pp',0
Level10_FM:	dc.b	'dh1:sources/lightcycle/levels/Level10.pic.pp',0

	even

***********************************
INTB_VERTB  equ   5                 ; for vblank interrupt
_AddIntServer	EQU	-168
_RemIntServer	EQU	-174

StartIrq:
	IFNE	MUSIC
	jsr	mt_init
	ENDIF

	EXEC
	lea	VBlankServer(pc),a1
	moveq	#INTB_VERTB,d0
	JUMP	AddIntServer	; (intNumber,interrupt)
***********************************
StopIrq:
	EXEC
	moveq	#INTB_VERTB,d0
	lea	VBlankServer(pc),a1
	CALL	RemIntServer	; (intNumber,interrupt)
	IFNE	MUSIC
	bsr	mt_end
	ENDIF
	rts

*********************************
VBlankServer:
	dc.l	0,0	;node succ,ln_Pred
ln_type1:dc.b	2,0	;ln_Type,ln_Prio
	dc.l	IrqName	;ln_name
	dc.l	0	;irq data
	dc.l	Interrupt ;irq code

IrqName:	dc.b	'Light Cycle Music',0
*Irq
	even
Interrupt:
	movem.l	d0-a6,-(sp)
	lea	$dff000,a5
	tst.w	Music_On
	beq.w	No_Music

	IFNE	MUSIC
	jsr	mt_music
	ENDIF
No_Music:
;	cmp.b	#$91,$bfec01	;litera m wlancza,wylancza muzyke
;	bne.s	Koniec_Przerwania
;	move.b	#0,$bfec01
;	not.w	Music_on
;Nie_Zmiana_M:
;	tst.w	Music_On
;	bne.s	Koniec_Przerwania
;	clr.w	$a8(a5)	;?
;	clr.w	$b8(a5)
;	clr.w	$c8(a5)
;	clr.w	$d8(a5)
;	move.w	#$f,$96(a5)

Koniec_Przerwania:
	movem.l	(sp)+,d0-a6
	rts

Music_On:
	dc.w	-1

Seek:		MOVEL	Dos
		move.l	Handle(pc),d1
		moveq	#0,d2
		moveq	#OFFSET_END,d3
	CALL	Seek
		move.l	Handle(pc),d1
		moveq	#0,d2
		moveq	#OFFSET_BEGINNING,d3
	JUMP	Seek

FreeMem:
	tst.l	AllocMem
	beq.s	.nofree

	move.l	AllocMem(pc),a1
	move.l	FileSize(pc),d0
	EXEC
	CALL	FreeMem
	clr.l	AllocMem
.nofree
	rts

*	*	*	*	*	*	*	*	*
*	*	*	*	*	*	*	*	*

	IFNE	MUSIC
	include	'PT2.1A_Play+.s'
	ENDIF

	IF	SAVE=1
Fonts
	incbin	'slp2.fnt'
	ENDIF

*******************************************************************************

*				DANE:

*******************************************************************************

Dzes	;tabela dziesiatek (wykopanie divsa
 dc.l 100000,10000,1000,100,10,1,0,0
 
No_Shift_Table:
;Tabela kodow
;bez shifta !
 DC.B	$FF,'`',$FD,'1',$FB,'2',$F9,'3',$F7,'4',$F5,'5',$F3,'6',$F1,'7'
 DC.B	$ef,'8',$ed,'9',$eb,'0',$e9,'-',$e7,'=',$e5,'\',$7b,'?',$df,'q'
 DC.B	$dd,'w',$db,'e',$d9,'r',$d7,'t',$d5,'y',$d3,'u',$d1,'i',$cf,'o'
 DC.B	$cd,'p',$cb,'[',$c9,']',$bf,'a',$bd,'s',$bb,'d',$b9,'f',$b7,'g'
 DC.B	$b5,'h',$b3,'j',$b1,'k',$af,'l',$ad,';',$ab,'''',$a9,'@',$9f,'<'
 DC.B	$9d,'z',$9b,'x',$99,'c',$97,'v',$95,'b',$93,'n',$91,'m',$8f,','
 DC.B	$8d,'.',$8b,'/',$4b,'[',$49,']',$47,'`',$45,'*',$85,'7',$83,'8'
 DC.B	$81,'9',$6b,'-',$a5,'4',$a3,'5',$a1,'6',$43,'+',$c5,'1',$c3,'2'
 DC.B	$c1,'3',$e1,'0',$87,'.',$7f,' '

Shift_Table:
;Tabela kodow
;z shiftem
 DC.B	$FF,'~',$FD,'!',$FB,'"',$F9,'#',$F7,'$',$F5,'%',$F3,'^',$F1,'&'
 DC.B	$EF,'*',$ED,'(',$EB,')',$E9,'_',$E7,'+',$E5,'|',$7B,'?',$DF,'Q'
 DC.B	$DD,'W',$DB,'E',$D9,'R',$D7,'T',$D5,'Y',$D3,'U',$D1,'I',$CF,'O'
 DC.B	$CD,'P',$CB,'[',$C9,']',$BF,'A',$BD,'S',$BB,'D',$B9,'F',$B7,'G'
 DC.B	$B5,'H',$B3,'J',$B1,'K',$AF,'L',$AD,':',$AB,'"',$A9,'?',$9F,'>'
 DC.B	$9D,'Z',$9B,'X',$99,'C',$97,'V',$95,'B',$93,'N',$91,'M',$8F,'<'
 DC.B	$8D,'>',$8B,'?',$4B,'[',$49,']',$47,'`',$45,'*',$85,'7',$83,'8'
 DC.B	$81,'9',$6B,'-',$A5,'4',$A3,'5',$A1,'6',$43,'+',$C5,'1',$C3,'2'
 DC.B	$C1,'3',$E1,'0',$87,'.',$7F,' '

*	%0001	Prawo
*	%0010	Lewo
*	%0100	Dol
*	%1000	Gora

AllocMem:	dc.l	0
FileSize:	dc.l	0
LastRuch:	dc.w	%0100
PosX:		dc.w	50
PosY:		dc.w	90
LastRuch2:	dc.w	%0001
PosX2:		dc.w	51
PosY2:		dc.w	185
LastRuch3:	dc.w	%0010
PosX3:		dc.w	100
PosY3:		dc.w	70

Lev_LastRuch1:	dc.w	0
Lev_PosX1:		dc.l	0
Lev_LastRuch2:	dc.w	0
Lev_PosX2:		dc.l	0
lev_LastRuch3:	dc.w	0
Lev_PosX3:		dc.l	0

*	%0001	JoyPort0
*	%0010	JoyPort1
*	%0100	Keyboard (Cursors+SPACE)
*	%1000	Computer (or computer help)
PlayerOne:	dc.w	%0010 ;w grze
PlayerTwo:	dc.w	%1000
PlayerThree:	dc.w	%1000

Live1:	dc.w	0
Live2:	dc.w	0
Live3:	dc.w	0

Player1_game:	dc.w	1	;1 gra zero nie gra
Player2_game:	dc.w	1
Player3_game:	dc.w	1

Player1_Rgame:	dc.w	1	;1 gra zero nie gra
Player2_Rgame:	dc.w	1
Player3_Rgame:	dc.w	1

Crash_in_LevelP1:	dc.w	0	;jerzeli zniszczyles sie w tercji
Crash_in_LevelP2:	dc.w	0	;to na koniec odejmuje zycia
Crash_in_LevelP3:	dc.w	0

Game_Over_Player_1:	dc.w	0	;1 game over in this Level
Game_Over_Player_2:	dc.w	0
Game_Over_Player_3:	dc.w	0

LFlash1:	dc.w	0
LFlash2:	dc.w	0
LFlash3:	dc.w	0
Flash_1_loop:	dc.w	0
Flash_1_I_Loop:	dc.w	0
Flash_Color_1:	dc.w	0
Flash_2_loop:	dc.w	0
Flash_2_I_Loop:	dc.w	0
Flash_Color_2:	dc.w	0
Flash_3_loop:	dc.w	0
Flash_3_I_Loop:	dc.w	0
Flash_Color_3:	dc.w	0

Hi:			blk.b	6,0
PunktyPierwszego:	dc.l	0
PunktyDrugiego:		dc.l	0
PunktyTrzeciego:	dc.l	0

Player1_to_High:	dc.l	0	;dla hi score
Player2_to_High:	dc.l	0
Player3_to_High:	dc.l	0

Level:	dc.w	0	;numer Levela
Crash:	dc.w	0
MenuEnter: dc.w	0

Speed_tm:	dc.w	2
Old_DMA:	dc.w	0
oldcop:		dc.l	0
opz		dc.w	0
Password_NR:	dc.w	0	;znaleziony password
PasswordNr:	dc.w	0 ;zmienna pomocnicza
Password_Adr:	dc.l	0 ;adres do porownania
Shift:	dc.w	0	;0-puszczony 1-wcisniety
DosBase:	dc.l	0
Handle:		dc.l	0
LoadAdr:	ds.b	30000	;na podw spakowany iff

		SECTION		'COPPER',DATA_C


***************************************
Copper:
	dc.w	$1fc,0
	dc.w	$0100,%0100001000000000	;Bptlcontrol reg.
	dc.w	$0102,$0000	;Hor-Scroll
	dc.w	$0104,$0000	;Sprite/Gfx priorit
	dc.w	$0108,$0078	;Modulo	(Odd)
	dc.w	$010a,$0078	;Modulo	(Exen)
	dc.w	$008e,$2981	;DiwStrt
	dc.w	$0090,$29c1	;DiwStop
	dc.w	$0092,$0038
	dc.w	$0094,$00d0

BitplanAdres
	dc.w	$00e0,$0006	;1	;Btpl Adr.
	dc.w	$00e2,$0000
	dc.w	$00e4,$0006	;2
	dc.w	$00e6,$2800
	dc.w	$00e8,$0006	;3
	dc.w	$00ea,$5000
	dc.w	$00ec,$0006	;4
	dc.w	$00ee,$7800

;Clear Sprites
 dc.l $1200000,$1220000,$1240000,$1260000
 dc.l $1280000,$12a0000,$12c0000,$12e0000
 dc.l $1300000,$1320000,$1340000,$1360000
 dc.l $1380000,$13a0000,$13c0000,$13e0000
ScreenColor:
 dc.w $180,0,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w $190,0,$192,0,$194,0,$196,0,$198,0,$19a,0,$19c,0,$19e,0
	dc.l	-2

GameCopper:
	dc.w	$1fc,0
	dc.w	$0100,$5200	;Bptlcontrol reg.
	dc.w	$0102,$0000	;Hor-Scroll
	dc.w	$0104,$0000	;Sprite/Gfx priorit
	dc.w	$0108,$00a0	;Modulo	(Odd)
	dc.w	$010a,$00a0	;Modulo	(Exen)
	dc.w	$008e,$2981
	dc.w	$0090,$29c1
	dc.w	$0092,$0038
	dc.w	$0094,$00d0

BitplanADR:
	dc.w	$e0,0,$e2,0
	dc.w	$e4,0,$e6,0
	dc.w	$e8,0,$ea,0
	dc.w	$ec,0,$ee,0
	dc.w	$f0,0,$f2,0
	dc.w	$f4,0,$f6,0

;clear sprites
 dc.l $1200000,$1220000,$1240000,$1260000,$1280000,$12a0000,$12c0000,$12e0000
 dc.l $1300000,$1320000,$1340000,$1360000,$1380000,$13a0000,$13c0000,$13e0000

GameScreenColor:	;nie wazne bierze kolory z obrazka !

 dc.w	$180,0,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w	$190,0,$192,0,$194,0,$196,0,$198,0,$19a,0,$19c,0,$19e,0
 dc.w	$1a0,0,$1a2,0,$1a4,0,$1a6,0,$1a8,0,$1aa,0,$1ac,0,$1ae,0
 dc.w	$1b0,0,$1b2,0,$1b4,0,$1b6,0,$1b8,0,$1ba,0,$1bc,0,$1be,0

*	dc.w	$3001,$fffe
*	dc.w	$0180,$0fff

	dc.w	$ffdf,$fffe	;colory dolu i punktow
	dc.w	$1001,$fffe
Points_Color:
 dc.w	$180,0,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
 dc.w	$190,0,$192,0,$194,0,$196,0,$198,0,$19a,0,$19c,0,$19e,0
 dc.w	$1a0,0,$1a2,0,$1a4,0,$1a6,0,$1a8,0,$1aa,0,$1ac,0,$1ae,0
 dc.w	$1b0,0,$1b2,0,$1b4,0,$1b6,0,$1b8,0,$1ba,0,$1bc,0,$1be,0

	dc.l	-2


	IFNE	SAVE
Tlo2
	incbin	'tlo2+.pic'
	IFNE	MUSIC
mt_data
	incbin	'mod.voice from rv-125'
;	incbin	'mod.soviet dog'
	ENDIF

	ENDIF

		SECTION	'SCREEN',BSS_C
	ds.b	40*20
Ekran:
	ds.b	40*256*5
	ds.b	40*20

		SECTION	'SCREEN',BSS_C
Iff:			;gdzie dekompresowac
	ds.b	40*256*5
	ds.b	40*20

*	*	*	*	*	*	*	*	*

			;DOS INCLUDE
_CurrentDir:	equ	-126
_Open:	equ	-30
_Close:	equ	-36
_Read:	equ	-42
_Write:	equ	-48
_Lock:	equ	-84
_UnLock:	equ	-90
_Examine:	equ	-102
OFFSET_END	equ	1
OFFSET_BEGINNING	equ	-1
_Seek	EQU	-66

;EXEC
_AllocMem	EQU	-198
_FreeMem	EQU	-210
_OpenLibrary	EQU	-552
_CloseLibrary	EQU	-414
_OldOpenLibrary:	equ	-408

