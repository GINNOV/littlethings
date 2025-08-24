
***************************************************************************
*                                                                         *
*                                                                         *
*				            *
*		   A  G  O  N  Y		            *
*                          =================            	            *
*                                                                         *
*                                                                         *
*                                                                         *
*                             COPPER LIST                                 *
*                             -----------                                 *
*                                                                         *
*                                                                         *
***************************************************************************


* by ART & MAGIC


* Artwork:        Franck Sauer
*	Marc Albinet

* Coding:	Yves Grolet
* Date:	25/06/1990
* Tab:            custom



	IFNE	Asm_Level=4



***************************************************************************

*	L E V E L   4

***************************************************************************



* COPPER LIST   S T A R T
* -----------------------


Top_Right	equ	$1ae

B_COL	MACRO
                  C_WAIT  $86,\1
                  C_MOVE	Bcol,Color
	C_WAIT	Top_Right,\1
	c_MOVE	0,Color
	ENDM

M0_COL	MACRO
                  C_WAIT  $86,\1
                  C_MOVE	Bcol,Color
	C_WAIT	$140,\1
	C_MOVE	Mcol,Color+18
	C_WAIT	Top_Right,\1
	C_MOVE	0,Color
	C_MOVE	Scol,Color+18
	ENDM

M1_COL	MACRO
                  C_WAIT  $86,\1
                  C_MOVE	Bcol,Color
	C_WAIT	$100,\1
	C_MOVE	Mcol,Color+18
	C_WAIT	Top_Right,\1
	C_MOVE	0,Color
	C_MOVE	Scol,Color+18
	ENDM

 _ Main_Cl

 _ Spr_Ptr
	C_MOVE	0,Spr0pt
	C_MOVE	0,Spr0pt+2
	C_MOVE	0,Spr1pt
	C_MOVE	0,Spr1pt+2
	C_MOVE	0,Spr2pt
	C_MOVE	0,Spr2pt+2
	C_MOVE	0,Spr3pt
	C_MOVE	0,Spr3pt+2
	C_MOVE	0,Spr4pt
	C_MOVE	0,Spr4pt+2
	C_MOVE	0,Spr5pt
	C_MOVE	0,Spr5pt+2
	C_MOVE	0,Spr6pt
	C_MOVE	0,Spr6pt+2
	C_MOVE	0,Spr7pt
	C_MOVE	0,Spr7pt+2
 _ Back_Ptr
	C_MOVE	0,Bpl4pt
	C_MOVE	0,Bpl4pt+2	* Bpl4&6 Back scroll
	C_MOVE	0,Bpl6pt
	C_MOVE	0,Bpl6pt+2
			* Displayed Window Y Start $40  1.l
 _ Back_Color0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
	C_MOVE	0,Color

	IFNE	ASM_Vdo_Mode=0
	C_MOVE	$2d90,Diwstrt
	C_MOVE	$00a0,Diwstop
	C_MOVE	$0038,Ddfstrt
	C_MOVE	$00c8,Ddfstop
	ELSEIF
	C_MOVE	$1d90,Diwstrt
	C_MOVE	$f0a0,Diwstop
	C_MOVE	$0038,Ddfstrt
	C_MOVE	$00c8,Ddfstop
	ENDC



* STATUS SCREEN
* -------------


	C_MOVE	0,Bpl1mod
	C_MOVE	0,Bpl2mod
	C_MOVE	%1010001000000000,Bplcon0
	C_MOVE	%0000000000000000,Bplcon2
	C_MOVE	0,Bplcon1
 _ Status_Ptr
	C_MOVE	0,Bpl1pt
	C_MOVE	0,Bpl1pt+2
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2

	C_MOVE	0,Color+2

Count             SET	$30-3
Col	SET	$653
                  rept	8
	C_WAIT	0,Count
Count	SET	Count+1
	C_MOVE	Col,Color+6
	C_WAIT	0,Count
Count	SET	Count+1
	C_MOVE	Col,Color+6
Col	SET	Col+$111
	ENDR

	IFNE	ASM_Vdo_Mode=0
	C_MOVE	$00b0,Diwstop
	ELSEIF
	C_MOVE	$f0b0,Diwstop
	ENDC


* GAME SCREEN
* -----------


	C_WAIT	0,$3f

 _ Fr_Color0a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12
 _ Fr_Color0b_f0
	C_MOVE	0,Color+14

	C_WAIT	$1a6,$3f
 _ Bpl_con0
	C_MOVE	%0110011000000000,Bplcon0
	C_MOVE	%0000000000100100,Bplcon2
	C_MOVE	6,Bpl1mod

 _ Front_Ptr
	C_MOVE	0,Bpl1pt            * Front playfield ptr
	C_MOVE	0,Bpl1pt+2
	C_MOVE	0,Bpl3pt
	C_MOVE	0,Bpl3pt+2
	C_MOVE	0,Bpl5pt
	C_MOVE	0,Bpl5pt+2
 _ Sky_Ptr0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2

	C_MOVE	2,Bpl2mod
 _ Video_Shift
	C_MOVE	0,Bplcon1

	C_MOVE	0,Copjmp2


* COPPER LIST   F L I P 0
* -----------------------


 _ Cl_Flip_Phase0


Bcol	SET	$076                * Back Color
Scol	SET	$476	* Sky Color
Mcol	SET	$143	* Mountain Color
Cmod0             SET	$100
Cmod1             SET	$010
Count	SET     $40

	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod0
                  REPT	10
	B_COL	Count,Bcol	* $40
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod0
                  REPT	10
	B_COL	Count,Bcol	* $4a
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod0
                  REPT	10
	B_COL	Count,Bcol	* $54
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod0
	B_COL	$5e


	C_WAIT	$86,$5f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$5f
	C_MOVE	0,Color
 _ Back_Color1_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color1a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr1_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$60
	C_MOVE	Bcol,Color
 _ Fr_Color1b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$60
	C_MOVE	0,Color


Count	SET	Count+3
                  REPT    7
	B_COL	Count	* $61
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod0
                  REPT	10
	B_COL	Count	* $68
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod0
                  REPT	10
	B_COL	Count	* $72
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod0

	B_COL	$7c
	B_COL	$7d
	B_COL	$7e

	C_WAIT	$86,$7f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$7f
 	C_MOVE	0,Color
 _ Back_Color2_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color2a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr2_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$80
	C_MOVE	Bcol,Color
 _ Fr_Color2b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$80
	C_MOVE	0,Color


Count	SET	Count+5
                  REPT    5	* $81
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod0

                  REPT	10	* $86
	B_COL   Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod0

                  REPT	10      	* $90
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod0

                  REPT    5     	* $9a
	B_COL	Count
Count	SET	Count+1
	ENDR


	C_WAIT	$86,$9f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$9f
	C_MOVE	0,Color
 _ Back_Color3_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color3a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr3_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$a0
	C_MOVE	Bcol,Color
 _ Fr_Color3b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$a0
	C_MOVE	0,Color


                  B_COL	$a1
                  B_COL	$a2
	M0_COL	$a3

Count	SET	Count+5
Bcol              SET	Bcol+Cmod0
Mcol	SET	Mcol+Cmod0
Scol              SET	Scol+Cmod0

                  REPT	10
	M0_COL	Count	* $a4
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
Mcol	SET	Mcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT	10
	M0_COL	Count	* $ae
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
Mcol	SET	Mcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT    7
	M0_COL	Count	* $b8
Count	SET	Count+1
	ENDR


	C_WAIT	$86,$bf
	C_MOVE	Bcol,Color
	C_MOVE	$502,Bpl2mod
	C_WAIT	$140,$bf
	C_MOVE	Mcol,Color+18
	C_WAIT	$180,$bf
	C_MOVE	0,Color
                  C_WAIT	Top_Right,$bf
	C_MOVE	Scol,Color+18
 _ Back_Color4_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color4a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr4_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$c0
	C_MOVE	Bcol,Color
 _ Fr_Color4b_f0
	C_MOVE	0,Color+14

	C_WAIT	$140,$c0
	C_MOVE	Mcol,Color+18
	C_WAIT  Top_Right,$c0
	C_MOVE	0,Color
	C_MOVE	Scol,Color+18


	M0_COL	$c1

Count	SET	Count+3
Bcol              SET	Bcol+Cmod0
Mcol	SET	Mcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT	10
	M1_COL	Count	* $c2
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
Mcol	SET	Mcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT    8
	M1_COL	Count	* $cc
Count	SET	Count+1
	ENDR

	C_MOVE  Mcol,Color+18

	B_COL   $d4
	B_COL   $d5
Count	SET	Count+2

Bcol              SET	Bcol+Cmod1
Mcol	SET	Mcol+Cmod0
	C_MOVE  Mcol,Color+18

                  REPT    9
	B_COL	Count	* $d6
Count	SET	Count+1
	ENDR

Bcol	SET	Mcol

	C_WAIT	$86,$df
	C_MOVE	Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$df
	C_MOVE	0,Color

Bcol              SET	Bcol+Cmod0

 _ Back_Color5_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color5a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr5_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$e0
	C_MOVE	Bcol,Color
 _ Fr_Color5b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$e0
	C_MOVE	0,Color


Count	SET	Count+2
                  REPT    9
	B_COL	Count	* $e1
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0

                  REPT	10
	B_COL	Count	* $e8
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0

                  REPT	12
	B_COL	Count	* $f2
Count	SET	Count+1
	ENDR

 _ Cl_Flip_Jump0
	C_MOVE	0,cop2lc
	C_MOVE	0,cop2lc+2

	C_MOVE	%1000000000010000,Intreq
 _ Dummy_Cl
                  C_END




* COPPER LIST   F L I P 1
* -----------------------


 _ Cl_Flip_Phase1


Bcol	SET	$076                * Back Color
Scol	SET	$476	* Sky Color
Mcol	SET	$143	* Mountain Color
Cmod0             SET	$100
Cmod1             SET	$010
Count	SET     $40

	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod0

                  REPT	15
	B_COL	Count,Bcol	* $40
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod0

                  REPT	10
	B_COL	Count,Bcol	* $4a
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod0

                  REPT    6
	B_COL	Count,Bcol	* $54
Count	SET	Count+1
	ENDR


	C_WAIT	$86,$5f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$5f
	C_MOVE	0,Color
 _ Back_Color1_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color1a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr1_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$60
	C_MOVE	Bcol,Color
 _ Fr_Color1b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$60
	C_MOVE	0,Color


Count	SET	Count+2

                  REPT    2
	B_COL	Count	* $61
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod0

                  REPT	10
	B_COL	Count	* $68
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod0

                  REPT	10
	B_COL	Count	* $72
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod0

                  REPT    8
	B_COL	Count	* $72
Count	SET	Count+1
	ENDR

	C_WAIT	$86,$7f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$7f
 	C_MOVE	0,Color
 _ Back_Color2_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color2a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr2_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$80
	C_MOVE	Bcol,Color
 _ Fr_Color2b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$80
	C_MOVE	0,Color



Count	set	Count+2
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod0

                  REPT    10	* $81
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod0

                  REPT	10	* $86
	B_COL   Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod0

                  REPT	10      	* $90
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod0


	C_WAIT	$86,$9f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$9f
	C_MOVE	0,Color
 _ Back_Color3_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color3a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr3_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$a0
	C_MOVE	Bcol,Color
 _ Fr_Color3b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$a0
	C_MOVE	0,Color



Count	SET	Count+2
Bcol              SET	Bcol+Cmod0
Scol              SET	Scol+Cmod0

                  REPT    5
	B_COL	Count	* $a4
Count	SET	Count+1
	ENDR

                  REPT    3
	M0_COL	Count	* $a4
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
Mcol	SET	Mcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT	10
	M0_COL	Count	* $ae
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
Mcol	SET	Mcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT    10
	M0_COL	Count	* $b8
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
Mcol	SET	Mcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT    2
	M0_COL	Count	* $b8
Count	SET	Count+1
	ENDR


	C_WAIT	$86,$bf
	C_MOVE	Bcol,Color
	C_MOVE	$502,Bpl2mod
	C_WAIT	$140,$bf
	C_MOVE	Mcol,Color+18
	C_WAIT	$180,$bf
 	C_MOVE	0,Color
                  C_WAIT	Top_Right,$bf
	C_MOVE	Scol,Color+18
 _ Back_Color4_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color4a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr4_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$c0
	C_MOVE	Bcol,Color
 _ Fr_Color4b_f1
	C_MOVE	0,Color+14

	C_WAIT	$140,$c0
	C_MOVE	Mcol,Color+18
	C_WAIT  Top_Right,$c0
	C_MOVE	0,Color
	C_MOVE	Scol,Color+18


Count	SET	Count+2

                  REPT    6
	M1_COL	Count	* $c2
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
Mcol	SET	Mcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT    10
	M1_COL	Count	* $c2
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
Mcol	SET	Mcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT    3
	M1_COL	Count	* $cc
Count	SET	Count+1
	ENDR

	C_MOVE  Mcol,Color+18

                  REPT    7
	B_COL	Count	* $cc
Count	SET	Count+1
	ENDR


Bcol              SET	Bcol+Cmod1
Mcol	SET	Mcol+Cmod0
	C_MOVE  Mcol,Color+18

                  REPT    4
	B_COL	Count	* $d6
Count	SET	Count+1
	ENDR

Bcol	SET	Mcol

	C_WAIT	$86,$df
	C_MOVE	Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$df
	C_MOVE	0,Color

 _ Back_Color5_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color5a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod

 _ Sky_Ptr5_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$e0
	C_MOVE	Bcol,Color
 _ Fr_Color5b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$e0
	C_MOVE	0,Color


Count	SET	Count+2
                  REPT    4
	B_COL	Count	* $e1
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0

                  REPT	10
	B_COL	Count	* $e8
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0

                  REPT    10
	B_COL	Count	* $f2
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0

                  REPT    7
	B_COL	Count	* $f2
Count	SET	Count+1
	ENDR


 _ Cl_Flip_Jump1
	C_MOVE	0,cop2lc
	C_MOVE	0,cop2lc+2

	C_MOVE	%1000000000010000,Intreq
                  C_END




	ENDC




	IFNE	Asm_Level=2



***************************************************************************

*	L E V E L   2

***************************************************************************



* COPPER LIST   S T A R T
* -----------------------


Top_Right	equ	$1ae

B_COL	MACRO
                  C_WAIT  $86,\1
                  C_MOVE	Bcol,Color
	C_WAIT	Top_Right,\1
	c_MOVE	0,Color
	ENDM

M0_COL	MACRO
                  C_WAIT  $86,\1
                  C_MOVE	Bcol,Color
	C_WAIT	$140,\1
;	C_MOVE	Mcol,Color+18
	C_WAIT	Top_Right,\1
	C_MOVE	0,Color
	C_MOVE	Scol,Color+18
	ENDM

M1_COL	MACRO
                  C_WAIT  $86,\1
                  C_MOVE	Bcol,Color
	C_WAIT	$100,\1
;	C_MOVE	Mcol,Color+18
	C_WAIT	Top_Right,\1
	C_MOVE	0,Color
	C_MOVE	Scol,Color+18
	ENDM

 _ Main_Cl

 _ Spr_Ptr
	C_MOVE	0,Spr0pt
	C_MOVE	0,Spr0pt+2
	C_MOVE	0,Spr1pt
	C_MOVE	0,Spr1pt+2
	C_MOVE	0,Spr2pt
	C_MOVE	0,Spr2pt+2
	C_MOVE	0,Spr3pt
	C_MOVE	0,Spr3pt+2
	C_MOVE	0,Spr4pt
	C_MOVE	0,Spr4pt+2
	C_MOVE	0,Spr5pt
	C_MOVE	0,Spr5pt+2
	C_MOVE	0,Spr6pt
	C_MOVE	0,Spr6pt+2
	C_MOVE	0,Spr7pt
	C_MOVE	0,Spr7pt+2
 _ Back_Ptr
	C_MOVE	0,Bpl4pt
	C_MOVE	0,Bpl4pt+2	* Bpl4&6 Back scroll
	C_MOVE	0,Bpl6pt
	C_MOVE	0,Bpl6pt+2
			* Displayed Window Y Start $40  1.l
 _ Back_Color0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
	C_MOVE	0,Color

	IFNE	ASM_Vdo_Mode=0
	C_MOVE	$2d90,Diwstrt
	C_MOVE	$00a0,Diwstop
	C_MOVE	$0038,Ddfstrt
	C_MOVE	$00c8,Ddfstop
	ELSEIF
	C_MOVE	$1d90,Diwstrt
	C_MOVE	$f0a0,Diwstop
	C_MOVE	$0038,Ddfstrt
	C_MOVE	$00c8,Ddfstop
	ENDC



* STATUS SCREEN
* -------------


	C_MOVE	0,Bpl1mod
	C_MOVE	0,Bpl2mod
	C_MOVE	%1010001000000000,Bplcon0
	C_MOVE	%0000000000000000,Bplcon2
	C_MOVE	0,Bplcon1
 _ Status_Ptr
	C_MOVE	0,Bpl1pt
	C_MOVE	0,Bpl1pt+2
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2

	C_MOVE	0,Color+2

Count             SET	$30-3
Col	SET	$653
                  rept	8
	C_WAIT	0,Count
Count	SET	Count+1
	C_MOVE	Col,Color+6
	C_WAIT	0,Count
Count	SET	Count+1
	C_MOVE	Col,Color+6
Col	SET	Col+$111
	ENDR

	IFNE	ASM_Vdo_Mode=0
	C_MOVE	$00b0,Diwstop
	ELSEIF
	C_MOVE	$f0b0,Diwstop
	ENDC


* GAME SCREEN
* -----------


	C_WAIT	0,$3f

 _ Fr_Color0a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12
 _ Fr_Color0b_f0
	C_MOVE	0,Color+14

	C_WAIT	$1a6,$3f
 _ Bpl_con0
	C_MOVE	%0110011000000000,Bplcon0
	C_MOVE	%0000000000100100,Bplcon2
	C_MOVE	6,Bpl1mod

 _ Front_Ptr
	C_MOVE	0,Bpl1pt            * Front playfield ptr
	C_MOVE	0,Bpl1pt+2
	C_MOVE	0,Bpl3pt
	C_MOVE	0,Bpl3pt+2
	C_MOVE	0,Bpl5pt
	C_MOVE	0,Bpl5pt+2
 _ Sky_Ptr0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2

	C_MOVE	2,Bpl2mod
 _ Video_Shift
	C_MOVE	0,Bplcon1

	C_MOVE	0,Copjmp2


* COPPER LIST   F L I P 0
* -----------------------


 _ Cl_Flip_Phase0


Bcol	SET	$0077                * Back Color
Scol	SET	$0389	* Sky Color
Cmod0             SET	$100
Cmod1             SET	$100
Count	SET     $40

	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1
                  REPT	10
	B_COL	Count,Bcol	* $40
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1
                  REPT	10
	B_COL	Count,Bcol	* $4a
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1
                  REPT	10
	B_COL	Count,Bcol	* $54
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1
	B_COL	$5e


	C_WAIT	$86,$5f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$5f
	C_MOVE	0,Color
 _ Back_Color1_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color1a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr1_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$60
	C_MOVE	Bcol,Color
 _ Fr_Color1b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$60
	C_MOVE	0,Color


Count	SET	Count+3
                  REPT    7
	B_COL	Count	* $61
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1
                  REPT	10
	B_COL	Count	* $68
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

Scol	SET	$0044	* Sky Color
Cmod1             SET	$100

                  REPT	10
	B_COL	Count	* $72
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
;Scol              SET	Scol+Cmod1

	B_COL	$7c
	B_COL	$7d
	B_COL	$7e

	C_WAIT	$86,$7f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$7f
 	C_MOVE	0,Color
 _ Back_Color2_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color2a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr2_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$80
	C_MOVE	Bcol,Color
 _ Fr_Color2b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$80
	C_MOVE	0,Color


Count	SET	Count+5
                  REPT    5	* $81
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
;Scol              SET	Scol+Cmod1
                  REPT	10	* $86
	B_COL   Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
;Scol              SET	Scol+Cmod1

                  REPT	10      	* $90
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
;Scol              SET	Scol+Cmod1

                  REPT    5     	* $9a
	B_COL	Count
Count	SET	Count+1
	ENDR


	C_WAIT	$86,$9f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$9f
	C_MOVE	0,Color
 _ Back_Color3_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color3a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr3_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$a0
	C_MOVE	Bcol,Color
 _ Fr_Color3b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$a0
	C_MOVE	0,Color


                  B_COL	$a1
                  B_COL	$a2
	M0_COL	$a3

Count	SET	Count+5
Bcol              SET	Bcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT	10
	M0_COL	Count	* $a4
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT	10
	M0_COL	Count	* $ae
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT    7
	M0_COL	Count	* $b8
Count	SET	Count+1
	ENDR


	C_WAIT	$86,$bf
	C_MOVE	Bcol,Color
	C_MOVE	$502,Bpl2mod
	C_WAIT	$140,$bf
                  C_WAIT	Top_Right,$bf
	C_MOVE	0,Color
 _ Back_Color4_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color4a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr4_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$c0
	C_MOVE	Bcol,Color
 _ Fr_Color4b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$c0
	C_MOVE	0,Color


	M0_COL	$c1

Count	SET	Count+3
Bcol              SET	Bcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT	10
	M1_COL	Count	* $c2
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT    8
	M1_COL	Count	* $cc
Count	SET	Count+1
	ENDR


	B_COL   $d4
	B_COL   $d5
Count	SET	Count+2

;Bcol              SET	Bcol+Cmod0

                  REPT    9
	B_COL	Count	* $d6
Count	SET	Count+1
	ENDR

Bcol	SET     Scol

	C_WAIT	$86,$df
	C_MOVE	Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$df
	C_MOVE	0,Color

Bcol              SET	Bcol+Cmod1

 _ Back_Color5_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color5a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod

 _ Sky_Ptr5_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$e0


	C_MOVE	Bcol,Color
 _ Fr_Color5b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$e0
	C_MOVE	0,Color


Count	SET	Count+2
                  REPT    9
	B_COL	Count	* $e1
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod1

                  REPT	10
	B_COL	Count	* $e8
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod1

                  REPT	12
	B_COL	Count	* $f2
Count	SET	Count+1
	ENDR


 _ Cl_Flip_Jump0
	C_MOVE	0,cop2lc
	C_MOVE	0,cop2lc+2

	C_MOVE	%1000000000010000,Intreq
 _ Dummy_Cl
                  C_END




* COPPER LIST   F L I P 1
* -----------------------


 _ Cl_Flip_Phase1


Bcol	SET	$0077        	* Back Color
Scol	SET	$0389	* Sky Color
Cmod0             SET	$100
Cmod1             SET	$100
Count	SET     $40

	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	15
	B_COL	Count,Bcol	* $40
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10
	B_COL	Count,Bcol	* $4a
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    6
	B_COL	Count,Bcol	* $54
Count	SET	Count+1
	ENDR


	C_WAIT	$86,$5f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$5f
	C_MOVE	0,Color
 _ Back_Color1_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color1a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr1_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$60
	C_MOVE	Bcol,Color
 _ Fr_Color1b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$60
	C_MOVE	0,Color


Count	SET	Count+2

                  REPT    2
	B_COL	Count	* $61
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10
	B_COL	Count	* $68
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
;Scol              SET	Scol+Cmod1

                  REPT	10
	B_COL	Count	* $72
Count	SET	Count+1
	ENDR

Scol	SET	$0044	* Sky Color
Cmod1             SET	$100

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
;Scol              SET	Scol+Cmod1

                  REPT    8
	B_COL	Count	* $72
Count	SET	Count+1
	ENDR

	C_WAIT	$86,$7f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$7f
 	C_MOVE	0,Color
 _ Back_Color2_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color2a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr2_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$80
	C_MOVE	Bcol,Color
 _ Fr_Color2b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$80
	C_MOVE	0,Color



Count	set	Count+2
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
;Scol              SET	Scol+Cmod1

                  REPT    10	* $81
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
;Scol              SET	Scol+Cmod1

                  REPT	10	* $86
	B_COL   Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10      	* $90
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1


	C_WAIT	$86,$9f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$9f
	C_MOVE	0,Color
 _ Back_Color3_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color3a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr3_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$a0
	C_MOVE	Bcol,Color
 _ Fr_Color3b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$a0
	C_MOVE	0,Color



Count	SET	Count+2
Bcol              SET	Bcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT    5
	B_COL	Count	* $a4
Count	SET	Count+1
	ENDR

                  REPT    3
	M0_COL	Count	* $a4
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT	10
	M0_COL	Count	* $ae
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT    10
	M0_COL	Count	* $b8
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT    2
	M0_COL	Count	* $b8
Count	SET	Count+1
	ENDR


	C_WAIT	$86,$bf
	C_MOVE	Bcol,Color
	C_MOVE	$502,Bpl2mod
	C_WAIT	$140,$bf
                  C_WAIT	Top_Right,$bf
	C_MOVE	0,Color
 _ Back_Color4_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color4a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr4_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$c0
	C_MOVE	Bcol,Color
 _ Fr_Color4b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$c0
	C_MOVE	0,Color


Count	SET	Count+2

                  REPT    6
	M1_COL	Count	* $c2
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT    10
	M1_COL	Count	* $c2
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT    3
	M1_COL	Count	* $cc
Count	SET	Count+1
	ENDR


                  REPT    7
	B_COL	Count	* $cc
Count	SET	Count+1
	ENDR


Bcol              SET	Bcol+Cmod0

                  REPT    4
	B_COL	Count	* $d6
Count	SET	Count+1
	ENDR

Bcol              SET	Scol

	C_WAIT	$86,$df
	C_MOVE	Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$df
	C_MOVE	0,Color

 _ Back_Color5_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color5a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod

 _ Sky_Ptr5_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$e0

	C_MOVE	Bcol,Color
 _ Fr_Color5b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$e0
	C_MOVE	0,Color


Count	SET	Count+2
                  REPT    4
	B_COL	Count	* $e1
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod1

                  REPT	10
	B_COL	Count	* $e8
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod1

                  REPT    10
	B_COL	Count	* $f2
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod1

                  REPT    7
	B_COL	Count	* $f2
Count	SET	Count+1
	ENDR


 _ Cl_Flip_Jump1
	C_MOVE	0,Cop2lc
	C_MOVE	0,Cop2lc+2

	C_MOVE	%1000000000010000,Intreq

                  C_END



	ENDC



	IFNE	Asm_Level=3



***************************************************************************

*	L E V E L   3

***************************************************************************



* COPPER LIST   S T A R T
* -----------------------


Top_Right	equ	$1ae

B_COL	MACRO
                  C_WAIT  $86,\1
                  C_MOVE	Bcol,Color
	C_WAIT	Top_Right,\1
	c_MOVE	0,Color
	ENDM

M0_COL	MACRO
                  C_WAIT  $86,\1
                  C_MOVE	Bcol,Color
	C_WAIT	$140,\1
;	C_MOVE	Mcol,Color+18
	C_WAIT	Top_Right,\1
	C_MOVE	0,Color
	C_MOVE	Scol,Color+18
	ENDM

M1_COL	MACRO
                  C_WAIT  $86,\1
                  C_MOVE	Bcol,Color
	C_WAIT	$100,\1
;	C_MOVE	Mcol,Color+18
	C_WAIT	Top_Right,\1
	C_MOVE	0,Color
	C_MOVE	Scol,Color+18
	ENDM

 _ Main_Cl

 _ Spr_Ptr
	C_MOVE	0,Spr0pt
	C_MOVE	0,Spr0pt+2
	C_MOVE	0,Spr1pt
	C_MOVE	0,Spr1pt+2
	C_MOVE	0,Spr2pt
	C_MOVE	0,Spr2pt+2
	C_MOVE	0,Spr3pt
	C_MOVE	0,Spr3pt+2
	C_MOVE	0,Spr4pt
	C_MOVE	0,Spr4pt+2
	C_MOVE	0,Spr5pt
	C_MOVE	0,Spr5pt+2
	C_MOVE	0,Spr6pt
	C_MOVE	0,Spr6pt+2
	C_MOVE	0,Spr7pt
	C_MOVE	0,Spr7pt+2
 _ Back_Ptr
	C_MOVE	0,Bpl4pt
	C_MOVE	0,Bpl4pt+2	* Bpl4&6 Back scroll
	C_MOVE	0,Bpl6pt
	C_MOVE	0,Bpl6pt+2
			* Displayed Window Y Start $40  1.l
 _ Back_Color0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
	C_MOVE	0,Color

	IFNE	ASM_Vdo_Mode=0
	C_MOVE	$2d90,Diwstrt
	C_MOVE	$00a0,Diwstop
	C_MOVE	$0038,Ddfstrt
	C_MOVE	$00c8,Ddfstop
	ELSEIF
	C_MOVE	$1d90,Diwstrt
	C_MOVE	$f0a0,Diwstop
	C_MOVE	$0038,Ddfstrt
	C_MOVE	$00c8,Ddfstop
	ENDC



* STATUS SCREEN
* -------------


	C_MOVE	0,Bpl1mod
	C_MOVE	0,Bpl2mod
	C_MOVE	%1010001000000000,Bplcon0
	C_MOVE	%0000000000000000,Bplcon2
	C_MOVE	0,Bplcon1
 _ Status_Ptr
	C_MOVE	0,Bpl1pt
	C_MOVE	0,Bpl1pt+2
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2

	C_MOVE	0,Color+2

Count             SET	$30-3
Col	SET	$653
                  rept	8
	C_WAIT	0,Count
Count	SET	Count+1
	C_MOVE	Col,Color+6
	C_WAIT	0,Count
Count	SET	Count+1
	C_MOVE	Col,Color+6
Col	SET	Col+$111
	ENDR

	IFNE	ASM_Vdo_Mode=0
	C_MOVE	$00b0,Diwstop
	ELSEIF
	C_MOVE	$f0b0,Diwstop
	ENDC


* GAME SCREEN
* -----------


	C_WAIT	0,$3f

 _ Fr_Color0a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12
 _ Fr_Color0b_f0
	C_MOVE	0,Color+14

	C_WAIT	$1a6,$3f
 _ Bpl_con0
	C_MOVE	%0110011000000000,Bplcon0
	C_MOVE	%0000000000100100,Bplcon2
	C_MOVE	6,Bpl1mod

 _ Front_Ptr
	C_MOVE	0,Bpl1pt            * Front playfield ptr
	C_MOVE	0,Bpl1pt+2
	C_MOVE	0,Bpl3pt
	C_MOVE	0,Bpl3pt+2
	C_MOVE	0,Bpl5pt
	C_MOVE	0,Bpl5pt+2
 _ Sky_Ptr0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2

	C_MOVE	2,Bpl2mod
 _ Video_Shift
	C_MOVE	0,Bplcon1

	C_MOVE	0,Copjmp2


* COPPER LIST   F L I P 0
* -----------------------


 _ Cl_Flip_Phase0


Bcol	SET	$340                * Back Color
Scol	SET	$340	* Sky Color
Cmod0             SET	$001
Cmod1             SET	$000
Count	SET     $40

	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1
                  REPT	10
	B_COL	Count,Bcol	* $40
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1
                  REPT	10
	B_COL	Count,Bcol	* $4a
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1
                  REPT	10
	B_COL	Count,Bcol	* $54
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1
	B_COL	$5e


	C_WAIT	$86,$5f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$5f
	C_MOVE	0,Color
 _ Back_Color1_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color1a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr1_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$60
	C_MOVE	Bcol,Color
 _ Fr_Color1b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$60
	C_MOVE	0,Color


Count	SET	Count+3
                  REPT    7
	B_COL	Count	* $61
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1
                  REPT	10
	B_COL	Count	* $68
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10
	B_COL	Count	* $72
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

	B_COL	$7c
	B_COL	$7d
	B_COL	$7e

	C_WAIT	$86,$7f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$7f
 	C_MOVE	0,Color
 _ Back_Color2_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color2a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr2_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$80
	C_MOVE	Bcol,Color
 _ Fr_Color2b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$80
	C_MOVE	0,Color


Count	SET	Count+5
                  REPT    5	* $81
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18

Cmod1             SET	$001
Scol              SET	Scol+Cmod1

                  REPT	10	* $86
	B_COL   Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10      	* $90
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18

Scol              SET	Scol+Cmod1

                  REPT    5     	* $9a
	B_COL	Count
Count	SET	Count+1
	ENDR


	C_WAIT	$86,$9f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$9f
	C_MOVE	0,Color
 _ Back_Color3_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color3a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr3_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$a0
	C_MOVE	Bcol,Color
 _ Fr_Color3b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$a0
	C_MOVE	0,Color


                  B_COL	$a1
                  B_COL	$a2
	M0_COL	$a3

Count	SET	Count+5
Bcol              SET	Bcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT	10
	M0_COL	Count	* $a4
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT	10
	M0_COL	Count	* $ae
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT    7
	M0_COL	Count	* $b8
Count	SET	Count+1
	ENDR


	C_WAIT	$86,$bf
	C_MOVE	Bcol,Color
	C_MOVE	$502,Bpl2mod
	C_WAIT	$140,$bf
                  C_WAIT	Top_Right,$bf
	C_MOVE	0,Color
 _ Back_Color4_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color4a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr4_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$c0
	C_MOVE	Bcol,Color
 _ Fr_Color4b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$c0
	C_MOVE	0,Color


	M0_COL	$c1

Count	SET	Count+3
Bcol              SET	Bcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT	10
	M1_COL	Count	* $c2
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT    8
	M1_COL	Count	* $cc
Count	SET	Count+1
	ENDR


	B_COL   $d4
	B_COL   $d5
Count	SET	Count+2

Bcol              SET	Bcol+Cmod0

                  REPT    9
	B_COL	Count	* $d6
Count	SET	Count+1
	ENDR


	C_WAIT	$86,$df
	C_MOVE	Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$df
	C_MOVE	0,Color

Bcol              SET	Bcol+Cmod0

 _ Back_Color5_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color5a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod

 _ Sky_Ptr5_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$e0

Bcol              SET	$346	; Begin Water

	C_MOVE	Bcol,Color
 _ Fr_Color5b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$e0
	C_MOVE	0,Color


Count	SET	Count+2
	B_COL	Count	* $e1
Count	SET	Count+1

Bcol              SET	Bcol-$100

                  REPT    4
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol-$100

                  REPT    4
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol-$100

                  REPT    4
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol-$001

                  REPT    4
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol-$001

                  REPT    4
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol-$001

                  REPT    4
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol-$001

                  REPT    4
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol-$001

                  REPT    2
	B_COL	Count
Count	SET	Count+1
	ENDR



 _ Cl_Flip_Jump0
	C_MOVE	0,cop2lc
	C_MOVE	0,cop2lc+2

	C_MOVE	%1000000000010000,Intreq
 _ Dummy_Cl
                  C_END




* COPPER LIST   F L I P 1
* -----------------------


 _ Cl_Flip_Phase1


Bcol	SET	$340                * Back Color
Scol	SET	$340	* Sky Color
Cmod0             SET	$001
Cmod1             SET	$000
Count	SET     $40

	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	15
	B_COL	Count,Bcol	* $40
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10
	B_COL	Count,Bcol	* $4a
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    6
	B_COL	Count,Bcol	* $54
Count	SET	Count+1
	ENDR


	C_WAIT	$86,$5f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$5f
	C_MOVE	0,Color
 _ Back_Color1_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color1a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr1_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$60
	C_MOVE	Bcol,Color
 _ Fr_Color1b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$60
	C_MOVE	0,Color


Count	SET	Count+2

                  REPT    2
	B_COL	Count	* $61
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10
	B_COL	Count	* $68
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10
	B_COL	Count	* $72
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    8
	B_COL	Count	* $72
Count	SET	Count+1
	ENDR

	C_WAIT	$86,$7f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$7f
 	C_MOVE	0,Color
 _ Back_Color2_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color2a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr2_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$80
	C_MOVE	Bcol,Color
 _ Fr_Color2b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$80
	C_MOVE	0,Color



Count	set	Count+2
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    10	* $81
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10	* $86
	B_COL   Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18

Cmod1             SET	$001
Scol              SET	Scol+Cmod1

                  REPT	10      	* $90
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1


	C_WAIT	$86,$9f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$9f
	C_MOVE	0,Color
 _ Back_Color3_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color3a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr3_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$a0
	C_MOVE	Bcol,Color
 _ Fr_Color3b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$a0
	C_MOVE	0,Color



Count	SET	Count+2
Bcol              SET	Bcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT    5
	B_COL	Count	* $a4
Count	SET	Count+1
	ENDR

                  REPT    3
	M0_COL	Count	* $a4
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT	10
	M0_COL	Count	* $ae
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT    10
	M0_COL	Count	* $b8
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT    2
	M0_COL	Count	* $b8
Count	SET	Count+1
	ENDR


	C_WAIT	$86,$bf
	C_MOVE	Bcol,Color
	C_MOVE	$502,Bpl2mod
	C_WAIT	$140,$bf
                  C_WAIT	Top_Right,$bf
	C_MOVE	0,Color
 _ Back_Color4_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color4a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr4_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$c0
	C_MOVE	Bcol,Color
 _ Fr_Color4b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$c0
	C_MOVE	0,Color


Count	SET	Count+2

                  REPT    6
	M1_COL	Count	* $c2
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT    10
	M1_COL	Count	* $c2
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
Scol              SET	Scol+Cmod1

                  REPT    3
	M1_COL	Count	* $cc
Count	SET	Count+1
	ENDR


                  REPT    7
	B_COL	Count	* $cc
Count	SET	Count+1
	ENDR


Bcol              SET	Bcol+Cmod0

                  REPT    4
	B_COL	Count	* $d6
Count	SET	Count+1
	ENDR


	C_WAIT	$86,$df
	C_MOVE	Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$df
	C_MOVE	0,Color

 _ Back_Color5_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color5a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod

 _ Sky_Ptr5_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$e0

Bcol              SET	$346	* Begin Water

	C_MOVE	Bcol,Color
 _ Fr_Color5b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$e0
	C_MOVE	0,Color


Count	SET	Count+2
                  REPT	3
	B_COL	Count	* $e1
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol-$100

                  REPT    4
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol-$100

                  REPT    4
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol-$100

                  REPT    4
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol-$001

                  REPT    4
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol-$001

                  REPT    4
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol-$001

                  REPT    4
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol-$001

                  REPT    4
	B_COL	Count
Count	SET	Count+1
	ENDR


 _ Cl_Flip_Jump1
	C_MOVE	0,Cop2lc
	C_MOVE	0,Cop2lc+2

	C_MOVE	%1000000000010000,Intreq
                  C_END



	ENDC




	IFNE	Asm_Level=1



***************************************************************************

*	L E V E L   1

***************************************************************************



* COPPER LIST   S T A R T
* -----------------------


Top_Right	equ	$1ae

B_COL	MACRO
                  C_WAIT  $86,\1
                  C_MOVE	Bcol,Color
	C_WAIT	Top_Right,\1
	c_MOVE	0,Color
	ENDM

 _ Main_Cl

 _ Spr_Ptr
	C_MOVE	0,Spr0pt
	C_MOVE	0,Spr0pt+2
	C_MOVE	0,Spr1pt
	C_MOVE	0,Spr1pt+2
	C_MOVE	0,Spr2pt
	C_MOVE	0,Spr2pt+2
	C_MOVE	0,Spr3pt
	C_MOVE	0,Spr3pt+2
	C_MOVE	0,Spr4pt
	C_MOVE	0,Spr4pt+2
	C_MOVE	0,Spr5pt
	C_MOVE	0,Spr5pt+2
	C_MOVE	0,Spr6pt
	C_MOVE	0,Spr6pt+2
	C_MOVE	0,Spr7pt
	C_MOVE	0,Spr7pt+2
 _ Back_Ptr
	C_MOVE	0,Bpl4pt
	C_MOVE	0,Bpl4pt+2	* Bpl4&6 Back scroll
	C_MOVE	0,Bpl6pt
	C_MOVE	0,Bpl6pt+2
			* Displayed Window Y Start $40  1.l
 _ Back_Color0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
	C_MOVE	0,Color

	IFNE	ASM_Vdo_Mode=0
	C_MOVE	$2d90,Diwstrt
	C_MOVE	$00a0,Diwstop
	C_MOVE	$0038,Ddfstrt
	C_MOVE	$00c8,Ddfstop
	ELSEIF
	C_MOVE	$1d90,Diwstrt
	C_MOVE	$f0a0,Diwstop
	C_MOVE	$0038,Ddfstrt
	C_MOVE	$00c8,Ddfstop
	ENDC



* STATUS SCREEN
* -------------


	C_MOVE	0,Bpl1mod
	C_MOVE	0,Bpl2mod
	C_MOVE	%1010001000000000,Bplcon0
	C_MOVE	%0000000000000000,Bplcon2
	C_MOVE	0,Bplcon1
 _ Status_Ptr
	C_MOVE	0,Bpl1pt
	C_MOVE	0,Bpl1pt+2
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2

	C_MOVE	0,Color+2

Count             SET	$30-3
Col	SET	$653
                  rept	8
	C_WAIT	0,Count
Count	SET	Count+1
	C_MOVE	Col,Color+6
	C_WAIT	0,Count
Count	SET	Count+1
	C_MOVE	Col,Color+6
Col	SET	Col+$111
	ENDR

	IFNE	ASM_Vdo_Mode=0
	C_MOVE	$00b0,Diwstop
	ELSEIF
	C_MOVE	$f0b0,Diwstop
	ENDC


* GAME SCREEN
* -----------


	C_WAIT	0,$3f

 _ Fr_Color0a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12
 _ Fr_Color0b_f0
	C_MOVE	0,Color+14

	C_WAIT	$1a6,$3f
 _ Bpl_con0
	C_MOVE	%0110011000000000,Bplcon0
	C_MOVE	%0000000000100100,Bplcon2
	C_MOVE	6,Bpl1mod

 _ Front_Ptr
	C_MOVE	0,Bpl1pt            * Front playfield ptr
	C_MOVE	0,Bpl1pt+2
	C_MOVE	0,Bpl3pt
	C_MOVE	0,Bpl3pt+2
	C_MOVE	0,Bpl5pt
	C_MOVE	0,Bpl5pt+2
 _ Sky_Ptr0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2

	C_MOVE	2,Bpl2mod
 _ Video_Shift
	C_MOVE	0,Bplcon1

	C_MOVE	0,Copjmp2


* COPPER LIST   F L I P 0
* -----------------------


 _ Cl_Flip_Phase0


Bcol	SET	$059                * Back Color
Scol	SET	$166	* Sky Color
Cmod0             SET	-$001
Cmod1             SET	-$001
Count	SET     $40

	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1
                  REPT	10
	B_COL	Count,Bcol	* $40
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

Cmod1	SET	$100

                  REPT	10
	B_COL	Count,Bcol	* $4a
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1
                  REPT	10
	B_COL	Count,Bcol	* $54
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1
	B_COL	$5e


	C_WAIT	$86,$5f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$5f
	C_MOVE	0,Color
 _ Back_Color1_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color1a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr1_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$60
	C_MOVE	Bcol,Color
 _ Fr_Color1b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$60
	C_MOVE	0,Color


Count	SET	Count+3
                  REPT    7
	B_COL	Count	* $61
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1
                  REPT	10
	B_COL	Count	* $68
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1
                  REPT	10
	B_COL	Count	* $72
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0

Cmod0	SET	$100

	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

	B_COL	$7c
	B_COL	$7d
	B_COL	$7e

	C_WAIT	$86,$7f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$7f
 	C_MOVE	0,Color
 _ Back_Color2_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color2a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr2_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$80
	C_MOVE	Bcol,Color
 _ Fr_Color2b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$80
	C_MOVE	0,Color


Count	SET	Count+5
                  REPT    5	* $81
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10	* $86
	B_COL   Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10      	* $90
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    5     	* $9a
	B_COL	Count
Count	SET	Count+1
	ENDR


	C_WAIT	$86,$9f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$9f
	C_MOVE	0,Color
 _ Back_Color3_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color3a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr3_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$a0
	C_MOVE	Bcol,Color
 _ Fr_Color3b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$a0
	C_MOVE	0,Color


                  B_COL	$a1
                  B_COL	$a2
	B_COL	$a3

Count	SET	Count+5

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10
	B_COL	Count	* $a4
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18

Scol              SET     $744
Cmod1	SET	-$100

                  REPT	10
	B_COL	Count	* $ae
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    7
	B_COL	Count	* $b8
Count	SET	Count+1
	ENDR


	C_WAIT	$86,$bf
	C_MOVE	Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$bf
	C_MOVE	0,Color
 _ Back_Color4_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color4a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr4_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$c0
	C_MOVE	Bcol,Color
 _ Fr_Color4b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$c0
	C_MOVE	0,Color


	B_COL	$c1

Count	SET	Count+3
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10
	B_COL	Count	* $c2
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    8
	B_COL	Count	* $cc
Count	SET	Count+1
	ENDR


	B_COL   $d4
	B_COL   $d5
Count	SET	Count+2

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18

                  REPT    9
	B_COL	Count	* $d6
Count	SET	Count+1
	ENDR

Bcol	SET	Scol
Cmod0	SET	Cmod1

	C_WAIT	$86,$df
	C_MOVE	Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$df
	C_MOVE	0,Color

Bcol              SET	Bcol+Cmod0

 _ Back_Color5_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color5a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr5_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$e0
	C_MOVE	Bcol,Color
 _ Fr_Color5b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$e0
	C_MOVE	0,Color


Count	SET	Count+2
                  REPT    9
	B_COL	Count	* $e1
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0

                  REPT	10
	B_COL	Count	* $e8
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0

                  REPT	12
	B_COL	Count	* $f2
Count	SET	Count+1
	ENDR

 _ Cl_Flip_Jump0
	C_MOVE	0,cop2lc
	C_MOVE	0,cop2lc+2

	C_MOVE	%1000000000010000,Intreq
 _ Dummy_Cl
                  C_END




* COPPER LIST   F L I P 1
* -----------------------


 _ Cl_Flip_Phase1


Bcol	SET	$059                * Back Color
Scol	SET	$166	* Sky Color
Cmod0             SET	-$001
Cmod1             SET	-$001
Count	SET     $40

	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	15
	B_COL	Count,Bcol	* $40
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

Cmod1	SET	$100

                  REPT	10
	B_COL	Count,Bcol	* $4a
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    6
	B_COL	Count,Bcol	* $54
Count	SET	Count+1
	ENDR


	C_WAIT	$86,$5f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$5f
	C_MOVE	0,Color
 _ Back_Color1_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color1a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr1_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$60
	C_MOVE	Bcol,Color
 _ Fr_Color1b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$60
	C_MOVE	0,Color


Count	SET	Count+2

                  REPT    2
	B_COL	Count	* $61
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10
	B_COL	Count	* $68
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10
	B_COL	Count	* $72
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0

Cmod0	SET	$100

	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    8
	B_COL	Count	* $72
Count	SET	Count+1
	ENDR

	C_WAIT	$86,$7f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$7f
 	C_MOVE	0,Color
 _ Back_Color2_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color2a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr2_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$80
	C_MOVE	Bcol,Color
 _ Fr_Color2b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$80
	C_MOVE	0,Color



Count	set	Count+2
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    10	* $81
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10	* $86
	B_COL   Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10      	* $90
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

	C_WAIT	$86,$9f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$9f
	C_MOVE	0,Color
 _ Back_Color3_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color3a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr3_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$a0
	C_MOVE	Bcol,Color
 _ Fr_Color3b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$a0
	C_MOVE	0,Color



Count	SET	Count+2

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    5
	B_COL	Count	* $a4
Count	SET	Count+1
	ENDR

                  REPT    3
	B_COL	Count	* $a4
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

Scol	SET	$744
Cmod1	SET	-$100

                  REPT	10
	B_COL	Count	* $ae
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18

                  REPT    10
	B_COL	Count	* $b8
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    2
	B_COL	Count	* $b8
Count	SET	Count+1
	ENDR


	C_WAIT	$86,$bf
	C_MOVE	Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$bf
 	C_MOVE	0,Color
 _ Back_Color4_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color4a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr4_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$c0
	C_MOVE	Bcol,Color
 _ Fr_Color4b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$c0
	C_MOVE	0,Color


Count	SET	Count+2

                  REPT    6
	B_COL	Count	* $c2
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    10
	B_COL	Count	* $c2
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    3
	B_COL	Count	* $cc
Count	SET	Count+1
	ENDR

                  REPT    7
	B_COL	Count	* $cc
Count	SET	Count+1
	ENDR


Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18

                  REPT    4
	B_COL	Count	* $d6
Count	SET	Count+1
	ENDR

Bcol	SET	Scol
	C_MOVE	Scol,Color+18
Cmod0	SET	Cmod1

	C_WAIT	$86,$df
	C_MOVE	Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$df
	C_MOVE	0,Color

 _ Back_Color5_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color5a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod

 _ Sky_Ptr5_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$e0
	C_MOVE	Bcol,Color
 _ Fr_Color5b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$e0
	C_MOVE	0,Color


Count	SET	Count+2
                  REPT    4
	B_COL	Count	* $e1
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0

                  REPT	10
	B_COL	Count	* $e8
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0

                  REPT    10
	B_COL	Count	* $f2
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0

                  REPT    7
	B_COL	Count	* $f2
Count	SET	Count+1
	ENDR


 _ Cl_Flip_Jump1
	C_MOVE	0,cop2lc
	C_MOVE	0,cop2lc+2

	C_MOVE	%1000000000010000,Intreq

                  C_END



	ENDC





	IFNE	Asm_Level=5



***************************************************************************

*	L E V E L   5

***************************************************************************



* COPPER LIST   S T A R T
* -----------------------


Top_Right	equ	$1ae

B_COL	MACRO
                  C_WAIT  $86,\1
                  C_MOVE	Bcol,Color
	C_WAIT	Top_Right,\1
	c_MOVE	0,Color
	ENDM

M0_COL	MACRO
                  C_WAIT  $86,\1
                  C_MOVE	Bcol,Color
	C_WAIT	Top_Right,\1
	C_MOVE	0,Color
	C_MOVE	Scol,Color+18
	ENDM

M1_COL	MACRO
                  C_WAIT  $86,\1
                  C_MOVE	Bcol,Color
	C_WAIT	Top_Right,\1
	C_MOVE	0,Color
	C_MOVE	Scol,Color+18
	ENDM

 _ Main_Cl

 _ Spr_Ptr
	C_MOVE	0,Spr0pt
	C_MOVE	0,Spr0pt+2
	C_MOVE	0,Spr1pt
	C_MOVE	0,Spr1pt+2
	C_MOVE	0,Spr2pt
	C_MOVE	0,Spr2pt+2
	C_MOVE	0,Spr3pt
	C_MOVE	0,Spr3pt+2
	C_MOVE	0,Spr4pt
	C_MOVE	0,Spr4pt+2
	C_MOVE	0,Spr5pt
	C_MOVE	0,Spr5pt+2
	C_MOVE	0,Spr6pt
	C_MOVE	0,Spr6pt+2
	C_MOVE	0,Spr7pt
	C_MOVE	0,Spr7pt+2
 _ Back_Ptr
	C_MOVE	0,Bpl4pt
	C_MOVE	0,Bpl4pt+2	* Bpl4&6 Back scroll
	C_MOVE	0,Bpl6pt
	C_MOVE	0,Bpl6pt+2
			* Displayed Window Y Start $40  1.l
 _ Back_Color0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
	C_MOVE	0,Color

	IFNE	ASM_Vdo_Mode=0
	C_MOVE	$2d90,Diwstrt
	C_MOVE	$00a0,Diwstop
	C_MOVE	$0038,Ddfstrt
	C_MOVE	$00c8,Ddfstop
	ELSEIF
	C_MOVE	$1d90,Diwstrt
	C_MOVE	$f0a0,Diwstop
	C_MOVE	$0038,Ddfstrt
	C_MOVE	$00c8,Ddfstop
	ENDC



* STATUS SCREEN
* -------------


	C_MOVE	0,Bpl1mod
	C_MOVE	0,Bpl2mod
	C_MOVE	%1010001000000000,Bplcon0
	C_MOVE	%0000000000000000,Bplcon2
	C_MOVE	0,Bplcon1
 _ Status_Ptr
	C_MOVE	0,Bpl1pt
	C_MOVE	0,Bpl1pt+2
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2

	C_MOVE	0,Color+2

Count             SET	$30-3
Col	SET	$653
                  rept	8
	C_WAIT	0,Count
Count	SET	Count+1
	C_MOVE	Col,Color+6
	C_WAIT	0,Count
Count	SET	Count+1
	C_MOVE	Col,Color+6
Col	SET	Col+$111
	ENDR

	IFNE	ASM_Vdo_Mode=0
	C_MOVE	$00b0,Diwstop
	ELSEIF
	C_MOVE	$f0b0,Diwstop
	ENDC


* GAME SCREEN
* -----------


	C_WAIT	0,$3f

 _ Fr_Color0a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12
 _ Fr_Color0b_f0
	C_MOVE	0,Color+14

	C_WAIT	$1a6,$3f
 _ Bpl_con0
	C_MOVE	%0110011000000000,Bplcon0
	C_MOVE	%0000000000100100,Bplcon2
	C_MOVE	6,Bpl1mod

 _ Front_Ptr
	C_MOVE	0,Bpl1pt            * Front playfield ptr
	C_MOVE	0,Bpl1pt+2
	C_MOVE	0,Bpl3pt
	C_MOVE	0,Bpl3pt+2
	C_MOVE	0,Bpl5pt
	C_MOVE	0,Bpl5pt+2
 _ Sky_Ptr0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2

	C_MOVE	2,Bpl2mod
 _ Video_Shift
	C_MOVE	0,Bplcon1

	C_MOVE	0,Copjmp2


* COPPER LIST   F L I P 0
* -----------------------


 _ Cl_Flip_Phase0


Bcol	SET	$0033                * Back Color
Scol	SET	$0000	* Sky Color
Cmod0             SET	$100
Cmod1             SET	$100
Count	SET     $40

	C_MOVE	Scol,Color+18
;Scol              SET	Scol+Cmod1
                  REPT	10
	B_COL	Count,Bcol	* $40
Count	SET	Count+1
	ENDR
;Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
;Scol              SET	Scol+Cmod1
                  REPT	10
	B_COL	Count,Bcol	* $4a
Count	SET	Count+1
	ENDR
;Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
;Scol              SET	Scol+Cmod1
                  REPT	10
	B_COL	Count,Bcol	* $54
Count	SET	Count+1
	ENDR

;Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
;Scol              SET	Scol+Cmod1
	B_COL	$5e


	C_WAIT	$86,$5f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$5f
	C_MOVE	0,Color
 _ Back_Color1_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color1a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr1_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$60
	C_MOVE	Bcol,Color
 _ Fr_Color1b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$60
	C_MOVE	0,Color


Count	SET	Count+3
                  REPT    7
	B_COL	Count	* $61
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
;Scol              SET	Scol+Cmod1
                  REPT	10
	B_COL	Count	* $68
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
;Scol              SET	Scol+Cmod1


                  REPT	10
	B_COL	Count	* $72
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
;Scol              SET	Scol+Cmod1

	B_COL	$7c
	B_COL	$7d
	B_COL	$7e

	C_WAIT	$86,$7f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$7f
 	C_MOVE	0,Color
 _ Back_Color2_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color2a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr2_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$80
	C_MOVE	Bcol,Color
 _ Fr_Color2b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$80
	C_MOVE	0,Color


Count	SET	Count+5
                  REPT    5	* $81
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1
                  REPT	10	* $86
	B_COL   Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10      	* $90
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    5     	* $9a
	B_COL	Count
Count	SET	Count+1
	ENDR


	C_WAIT	$86,$9f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$9f
	C_MOVE	0,Color
 _ Back_Color3_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color3a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr3_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$a0
	C_MOVE	Bcol,Color
 _ Fr_Color3b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$a0
	C_MOVE	0,Color


                  B_COL	$a1
                  B_COL	$a2
	B_COL	$a3

Count	SET	Count+5
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10
	B_COL	Count	* $a4
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10
	B_COL	Count	* $ae
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    7
	B_COL	Count	* $b8
Count	SET	Count+1
	ENDR


	C_WAIT	$86,$bf
	C_MOVE	Bcol,Color
	C_MOVE	$502,Bpl2mod
	C_WAIT	$140,$bf
                  C_WAIT	Top_Right,$bf
	C_MOVE	0,Color
 _ Back_Color4_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color4a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr4_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$c0
	C_MOVE	Bcol,Color
 _ Fr_Color4b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$c0
	C_MOVE	0,Color


	B_COL	$c1

Count	SET	Count+3
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10
	B_COL	Count	* $c2
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    10
	B_COL	Count	* $cc
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
;Scol              SET	Scol+Cmod1

                  REPT    9
	B_COL	Count	* $d6
Count	SET	Count+1
	ENDR

Bcol	SET     Scol
Cmod1	SET	-$0100

	C_WAIT	$86,$df
	C_MOVE	Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$df
	C_MOVE	0,Color

Bcol              SET	Bcol+Cmod1

 _ Back_Color5_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color5a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod

 _ Sky_Ptr5_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$e0


	C_MOVE	Bcol,Color
 _ Fr_Color5b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$e0
	C_MOVE	0,Color


Count	SET	Count+2
                  REPT    9
	B_COL	Count	* $e1
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod1

                  REPT	10
	B_COL	Count	* $e8
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod1

                  REPT	12
	B_COL	Count	* $f2
Count	SET	Count+1
	ENDR


 _ Cl_Flip_Jump0
	C_MOVE	0,cop2lc
	C_MOVE	0,cop2lc+2

	C_MOVE	%1000000000010000,Intreq
 _ Dummy_Cl
                  C_END




* COPPER LIST   F L I P 1
* -----------------------


 _ Cl_Flip_Phase1


Bcol	SET	$0033        	* Back Color
Scol	SET	$0000	* Sky Color
Cmod0             SET	$100
Cmod1             SET	$100
Count	SET     $40

	C_MOVE	Scol,Color+18
;Scol              SET	Scol+Cmod1

                  REPT	15
	B_COL	Count,Bcol	* $40
Count	SET	Count+1
	ENDR

;Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
;Scol              SET	Scol+Cmod1

                  REPT	10
	B_COL	Count,Bcol	* $4a
Count	SET	Count+1
	ENDR

;Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
;Scol              SET	Scol+Cmod1

                  REPT    6
	B_COL	Count,Bcol	* $54
Count	SET	Count+1
	ENDR


	C_WAIT	$86,$5f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$5f
	C_MOVE	0,Color
 _ Back_Color1_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color1a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr1_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$60
	C_MOVE	Bcol,Color
 _ Fr_Color1b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$60
	C_MOVE	0,Color


Count	SET	Count+2

                  REPT    2
	B_COL	Count	* $61
Count	SET	Count+1
	ENDR

;Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
;Scol              SET	Scol+Cmod1


                  REPT	10
	B_COL	Count	* $68
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
;Scol              SET	Scol+Cmod1

                  REPT	10
	B_COL	Count	* $72
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
;Scol              SET	Scol+Cmod1

                  REPT    8
	B_COL	Count	* $72
Count	SET	Count+1
	ENDR

	C_WAIT	$86,$7f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$7f
 	C_MOVE	0,Color
 _ Back_Color2_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color2a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr2_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$80
	C_MOVE	Bcol,Color
 _ Fr_Color2b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$80
	C_MOVE	0,Color



Count	set	Count+2
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
;Scol              SET	Scol+Cmod1

                  REPT    10	* $81
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10	* $86
	B_COL   Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10      	* $90
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1


	C_WAIT	$86,$9f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$9f
	C_MOVE	0,Color
 _ Back_Color3_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color3a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr3_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$a0
	C_MOVE	Bcol,Color
 _ Fr_Color3b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$a0
	C_MOVE	0,Color


Count	SET	Count+2

                  REPT    8
	B_COL	Count	* $a4
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10
	B_COL	Count	* $ae
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    10
	B_COL	Count	* $b8
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    2
	B_COL	Count	* $b8
Count	SET	Count+1
	ENDR


	C_WAIT	$86,$bf
	C_MOVE	Bcol,Color
	C_MOVE	$502,Bpl2mod
	C_WAIT	$140,$bf
                  C_WAIT	Top_Right,$bf
	C_MOVE	0,Color
 _ Back_Color4_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color4a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr4_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$c0
	C_MOVE	Bcol,Color
 _ Fr_Color4b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$c0
	C_MOVE	0,Color


Count	SET	Count+2

                  REPT    6
	B_COL	Count	* $c2
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    10
	B_COL	Count	* $c2
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    10
	B_COL	Count	* $cc
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
;Scol              SET	Scol+Cmod1

                  REPT    4
	B_COL	Count	* $d6
Count	SET	Count+1
	ENDR

Bcol              SET	Scol
Cmod1	SET	-$0100

	C_WAIT	$86,$df
	C_MOVE	Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$df
	C_MOVE	0,Color

 _ Back_Color5_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color5a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod

 _ Sky_Ptr5_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$e0

	C_MOVE	Bcol,Color
 _ Fr_Color5b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$e0
	C_MOVE	0,Color


Count	SET	Count+2
                  REPT    4
	B_COL	Count	* $e1
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod1

                  REPT	10
	B_COL	Count	* $e8
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod1

                  REPT    10
	B_COL	Count	* $f2
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod1

                  REPT    7
	B_COL	Count	* $f2
Count	SET	Count+1
	ENDR


 _ Cl_Flip_Jump1
	C_MOVE	0,Cop2lc
	C_MOVE	0,Cop2lc+2

	C_MOVE	%1000000000010000,Intreq

                  C_END



	ENDC




	IFNE	Asm_Level=6



***************************************************************************

*	L E V E L   6

***************************************************************************



* COPPER LIST   S T A R T
* -----------------------


Top_Right	equ	$1ae

B_COL	MACRO
                  C_WAIT  $86,\1
                  C_MOVE	Bcol,Color
	C_WAIT	Top_Right,\1
	c_MOVE	0,Color
	ENDM

M0_COL	MACRO
                  C_WAIT  $86,\1
                  C_MOVE	Bcol,Color
	C_WAIT	Top_Right,\1
	C_MOVE	0,Color
	C_MOVE	Scol,Color+18
	ENDM

M1_COL	MACRO
                  C_WAIT  $86,\1
                  C_MOVE	Bcol,Color
	C_WAIT	Top_Right,\1
	C_MOVE	0,Color
	C_MOVE	Scol,Color+18
	ENDM

 _ Main_Cl

 _ Spr_Ptr
	C_MOVE	0,Spr0pt
	C_MOVE	0,Spr0pt+2
	C_MOVE	0,Spr1pt
	C_MOVE	0,Spr1pt+2
	C_MOVE	0,Spr2pt
	C_MOVE	0,Spr2pt+2
	C_MOVE	0,Spr3pt
	C_MOVE	0,Spr3pt+2
	C_MOVE	0,Spr4pt
	C_MOVE	0,Spr4pt+2
	C_MOVE	0,Spr5pt
	C_MOVE	0,Spr5pt+2
	C_MOVE	0,Spr6pt
	C_MOVE	0,Spr6pt+2
	C_MOVE	0,Spr7pt
	C_MOVE	0,Spr7pt+2
 _ Back_Ptr
	C_MOVE	0,Bpl4pt
	C_MOVE	0,Bpl4pt+2	* Bpl4&6 Back scroll
	C_MOVE	0,Bpl6pt
	C_MOVE	0,Bpl6pt+2
			* Displayed Window Y Start $40  1.l
 _ Back_Color0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
	C_MOVE	0,Color

	IFNE	ASM_Vdo_Mode=0
	C_MOVE	$2d90,Diwstrt
	C_MOVE	$00a0,Diwstop
	C_MOVE	$0038,Ddfstrt
	C_MOVE	$00c8,Ddfstop
	ELSEIF
	C_MOVE	$1d90,Diwstrt
	C_MOVE	$f0a0,Diwstop
	C_MOVE	$0038,Ddfstrt
	C_MOVE	$00c8,Ddfstop
	ENDC



* STATUS SCREEN
* -------------


	C_MOVE	0,Bpl1mod
	C_MOVE	0,Bpl2mod
	C_MOVE	%1010001000000000,Bplcon0
	C_MOVE	%0000000000000000,Bplcon2
	C_MOVE	0,Bplcon1
 _ Status_Ptr
	C_MOVE	0,Bpl1pt
	C_MOVE	0,Bpl1pt+2
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2

	C_MOVE	0,Color+2

Count             SET	$30-3
Col	SET	$653
                  rept	8
	C_WAIT	0,Count
Count	SET	Count+1
	C_MOVE	Col,Color+6
	C_WAIT	0,Count
Count	SET	Count+1
	C_MOVE	Col,Color+6
Col	SET	Col+$111
	ENDR

	IFNE	ASM_Vdo_Mode=0
	C_MOVE	$00b0,Diwstop
	ELSEIF
	C_MOVE	$f0b0,Diwstop
	ENDC


* GAME SCREEN
* -----------


	C_WAIT	0,$3f

 _ Fr_Color0a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12
 _ Fr_Color0b_f0
	C_MOVE	0,Color+14

	C_WAIT	$1a6,$3f
 _ Bpl_con0
	C_MOVE	%0110011000000000,Bplcon0
	C_MOVE	%0000000000100100,Bplcon2
	C_MOVE	6,Bpl1mod

 _ Front_Ptr
	C_MOVE	0,Bpl1pt            * Front playfield ptr
	C_MOVE	0,Bpl1pt+2
	C_MOVE	0,Bpl3pt
	C_MOVE	0,Bpl3pt+2
	C_MOVE	0,Bpl5pt
	C_MOVE	0,Bpl5pt+2
 _ Sky_Ptr0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2

	C_MOVE	2,Bpl2mod
 _ Video_Shift
	C_MOVE	0,Bplcon1

	C_MOVE	0,Copjmp2


* COPPER LIST   F L I P 0
* -----------------------


 _ Cl_Flip_Phase0


Bcol	SET	$0042                * Back Color
Scol	SET	$0032	* Sky Color
Cmod0             SET	$100
Cmod1             SET	$100
Count	SET     $40

	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1
                  REPT	10
	B_COL	Count,Bcol	* $40
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1
                  REPT	10
	B_COL	Count,Bcol	* $4a
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1
                  REPT	10
	B_COL	Count,Bcol	* $54
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1
	B_COL	$5e


	C_WAIT	$86,$5f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$5f
	C_MOVE	0,Color
 _ Back_Color1_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color1a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr1_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$60
	C_MOVE	Bcol,Color
 _ Fr_Color1b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$60
	C_MOVE	0,Color


Count	SET	Count+3
                  REPT    7
	B_COL	Count	* $61
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1
                  REPT	10
	B_COL	Count	* $68
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1


                  REPT	10
	B_COL	Count	* $72
Count	SET	Count+1
	ENDR
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

	B_COL	$7c
	B_COL	$7d
	B_COL	$7e

	C_WAIT	$86,$7f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$7f
 	C_MOVE	0,Color
 _ Back_Color2_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color2a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr2_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$80
	C_MOVE	Bcol,Color
 _ Fr_Color2b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$80
	C_MOVE	0,Color


Count	SET	Count+5
                  REPT    5	* $81
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1
                  REPT	10	* $86
	B_COL   Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10      	* $90
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    5     	* $9a
	B_COL	Count
Count	SET	Count+1
	ENDR


	C_WAIT	$86,$9f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$9f
	C_MOVE	0,Color
 _ Back_Color3_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color3a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr3_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$a0
	C_MOVE	Bcol,Color
 _ Fr_Color3b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$a0
	C_MOVE	0,Color


                  B_COL	$a1
                  B_COL	$a2
	B_COL	$a3

Count	SET	Count+5

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

Bcol	SET	$332	* color change

                  REPT	10
	B_COL	Count	* $a4
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10
	B_COL	Count	* $ae
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    7
	B_COL	Count	* $b8
Count	SET	Count+1
	ENDR

	C_WAIT	$86,$bf
	C_MOVE	Bcol,Color
	C_MOVE	$502,Bpl2mod
	C_WAIT	$140,$bf
                  C_WAIT	Top_Right,$bf
	C_MOVE	0,Color
 _ Back_Color4_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color4a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr4_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$c0
	C_MOVE	Bcol,Color
 _ Fr_Color4b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$c0
	C_MOVE	0,Color


	B_COL	$c1

Count	SET	Count+3
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10
	B_COL	Count	* $c2
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    10
	B_COL	Count	* $cc
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

Cmod0	SET	-$100
Cmod1	SET	-$100

                  REPT    9
	B_COL	Count	* $d6
Count	SET	Count+1
	ENDR

	C_WAIT	$86,$df
	C_MOVE	Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$df
	C_MOVE	0,Color

Bcol              SET	Bcol+Cmod1

 _ Back_Color5_f0
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color5a_f0
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod

 _ Sky_Ptr5_f0
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$e0


	C_MOVE	Bcol,Color
 _ Fr_Color5b_f0
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$e0
	C_MOVE	0,Color


Count	SET	Count+2
                  REPT    9
	B_COL	Count	* $e1
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod1

                  REPT	10
	B_COL	Count	* $e8
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod1

                  REPT	12
	B_COL	Count	* $f2
Count	SET	Count+1
	ENDR


 _ Cl_Flip_Jump0
	C_MOVE	0,cop2lc
	C_MOVE	0,cop2lc+2

	C_MOVE	%1000000000010000,Intreq
 _ Dummy_Cl
                  C_END




* COPPER LIST   F L I P 1
* -----------------------


 _ Cl_Flip_Phase1


Bcol	SET	$0042        	* Back Color
Scol	SET	$0032	* Sky Color
Cmod0             SET	$100
Cmod1             SET	$100
Count	SET     $40

	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	15
	B_COL	Count,Bcol	* $40
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10
	B_COL	Count,Bcol	* $4a
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    6
	B_COL	Count,Bcol	* $54
Count	SET	Count+1
	ENDR


	C_WAIT	$86,$5f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$5f
	C_MOVE	0,Color
 _ Back_Color1_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color1a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr1_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$60
	C_MOVE	Bcol,Color
 _ Fr_Color1b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$60
	C_MOVE	0,Color


Count	SET	Count+2

                  REPT    2
	B_COL	Count	* $61
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1


                  REPT	10
	B_COL	Count	* $68
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10
	B_COL	Count	* $72
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    8
	B_COL	Count	* $72
Count	SET	Count+1
	ENDR

	C_WAIT	$86,$7f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$7f
 	C_MOVE	0,Color
 _ Back_Color2_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color2a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr2_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$80
	C_MOVE	Bcol,Color
 _ Fr_Color2b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$80
	C_MOVE	0,Color



Count	set	Count+2
Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    10	* $81
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10	* $86
	B_COL   Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10      	* $90
	B_COL	Count
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

Bcol	SET	$332	* color change

	C_WAIT	$86,$9f
	C_MOVE  Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$9f
	C_MOVE	0,Color
 _ Back_Color3_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color3a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr3_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$a0
	C_MOVE	Bcol,Color
 _ Fr_Color3b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$a0
	C_MOVE	0,Color


Count	SET	Count+2

                  REPT    8
	B_COL	Count	* $a4
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT	10
	B_COL	Count	* $ae
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    10
	B_COL	Count	* $b8
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    2
	B_COL	Count	* $b8
Count	SET	Count+1
	ENDR


	C_WAIT	$86,$bf
	C_MOVE	Bcol,Color
	C_MOVE	$502,Bpl2mod
	C_WAIT	$140,$bf
                  C_WAIT	Top_Right,$bf
	C_MOVE	0,Color
 _ Back_Color4_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color4a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod
 _ Sky_Ptr4_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$c0
	C_MOVE	Bcol,Color
 _ Fr_Color4b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$c0
	C_MOVE	0,Color


Count	SET	Count+2

                  REPT    6
	B_COL	Count	* $c2
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    10
	B_COL	Count	* $c2
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

                  REPT    10
	B_COL	Count	* $cc
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod0
	C_MOVE	Scol,Color+18
Scol              SET	Scol+Cmod1

Cmod0	SET	-$100
Cmod1	SET	-$100

                  REPT    4
	B_COL	Count	* $d6
Count	SET	Count+1
	ENDR

	C_WAIT	$86,$df
	C_MOVE	Bcol,Color
	C_MOVE	$502,Bpl2mod

                  C_WAIT	Top_Right,$df
	C_MOVE	0,Color

 _ Back_Color5_f1
                  C_MOVE	0,Color+20
                  C_MOVE	0,Color+22
                  C_MOVE	0,Color+24
                  C_MOVE	0,Color+26
                  C_MOVE	0,Color+28
                  C_MOVE	0,Color+30
 _ Fr_Color5a_f1
	C_MOVE	0,Color+2	* Front Palette
	C_MOVE	0,Color+4
	C_MOVE	0,Color+6
	C_MOVE	0,Color+8
	C_MOVE	0,Color+10
	C_MOVE	0,Color+12

                  C_MOVE	2,Bpl2mod

 _ Sky_Ptr5_f1
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
                  C_WAIT	$86,$e0

	C_MOVE	Bcol,Color
 _ Fr_Color5b_f1
	C_MOVE	0,Color+14

	C_WAIT  Top_Right,$e0
	C_MOVE	0,Color


Count	SET	Count+2
                  REPT    4
	B_COL	Count	* $e1
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod1

                  REPT	10
	B_COL	Count	* $e8
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod1

                  REPT    10
	B_COL	Count	* $f2
Count	SET	Count+1
	ENDR

Bcol              SET	Bcol+Cmod1

                  REPT    7
	B_COL	Count	* $f2
Count	SET	Count+1
	ENDR


 _ Cl_Flip_Jump1
	C_MOVE	0,Cop2lc
	C_MOVE	0,Cop2lc+2

	C_MOVE	%1000000000010000,Intreq

                  C_END



	ENDC




***************************************************************************



