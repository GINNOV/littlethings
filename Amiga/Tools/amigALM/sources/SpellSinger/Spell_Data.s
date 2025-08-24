
***************************************************************************
*                                                                         *
*                                                                         *
*				            *
*	      S P E L L   S I N G E R	            *
*                      =========================	            *
*                                                                         *
*                                                                         *
*                                                                         *
*                                Data                                     *
*                                ----                                     *
*                                                                         *
*                                                                         *
***************************************************************************


* by ART & MAGIC


* Coding:	Yves Grolet
* Date:	25/12/1991
* Tab:            custom






***************************************************************************

*	D A T A   M A C R O   D E F I N I T I O N

***************************************************************************



* INCLUDE PATH MACRO
* ------------------


LINCBIN	MACRO
	IFNE	Asm_Level=1
	INCBIN	WORK:Agony/LMer/\1
	ENDC

	IFNE	Asm_Level=2
	INCBIN	WORK:Agony/LForet/\1
	ENDC

	IFNE	Asm_Level=3
	INCBIN	WORK:Agony/LMarais/\1
	ENDC

	IFNE	Asm_Level=4
	INCBIN	WORK:Agony/LMontagnes/\1
	ENDC

	IFNE	Asm_Level=5
	INCBIN	WORK:Agony/LPlateaux/\1
	ENDC

	IFNE	Asm_Level=6
	INCBIN	WORK:Agony/LFeux/\1
	ENDC
	ENDM


RINCBIN	MACRO
	INCBIN	WORK:SpellSinger/\1
	ENDM



* RELATIVE SYSTEM MACRO
* ---------------------


_	MACRO
	IFNE	(*-Rel_Start-32768)>65535
	FAIL	"Relative Zone Too Big."
	ENDC
\1	EQU     *-Rel_Start-32768
_\1
	ENDM






***************************************************************************

*	P R O G R A M M   A B S O L U T E   D A T A

***************************************************************************



* Copper List
* -----------


Main_Cl

Cl_Bplpt0         		* Front Screen
	C_MOVE	0,Bpl1pt
	C_MOVE	0,Bpl1pt+2
	C_MOVE	0,Bpl3pt
	C_MOVE	0,Bpl3pt+2
	C_MOVE	0,Bpl5pt
	C_MOVE	0,Bpl5pt+2
Cl_Bplpt1			* Back Screen
	C_MOVE	0,Bpl2pt
	C_MOVE	0,Bpl2pt+2
	C_MOVE	0,Bpl4pt
	C_MOVE	0,Bpl4pt+2
	C_MOVE	0,Bpl6pt
	C_MOVE	0,Bpl6pt+2

	C_WAIT	255
	C_MOVE	%1000000000010000,Intreq
Dummy_Cl
	C_END



* Screens
* -------


Scr_0
	DS.B	42*194*3
Scr_1
                  DS.B	42*194*3
Scr_1_Mask
	DS.B	42*194
	DS.B	36*7
Scr_2
                  DS.B	42*194*3
Scr_2_Mask
	DS.B	42*194
Scr_3
                  DS.B	42*192*3
Scr_3_Mask
	DS.B	42*192
Scr_4
                  DS.B	42*192*3
Scr_A
	DS.B	38*192*3
Scr_B0
	DS.B	38*192*3
Scr_B1
	DS.B	38*192*3
Scr_C0
	DS.B	38*192*3
Scr_C1
	DS.B	38*192*3
Scr_D
	DS.B	38*48*3



* Scroll data
* -----------


Map_1
	RINCBIN	Map.bin

;	REPT	692
;	DC.W    20
;	DC.W    0
;	DC.W    21
;	DC.W    1
;	DC.W    22
;	DC.W    2
;	DC.W    23
;	DC.W    3
;	DC.W    24
;	DC.W    4
;	DC.W    25
;	DC.W    5
;	DC.W    26
;	DC.W    6
;	DC.W    27
;	DC.W    7
;	DC.W    28
;	DC.W    8
;	DC.W    29
;	DC.W    9
;	DC.W    30
;	DC.W    10
;	DC.W    31
;	DC.W    11
;	DC.W    32
;	DC.W    12
;	DC.W    33
;	DC.W    13
;	DC.W    34
;	DC.W    14
;	DC.W    35
;	DC.W    15
;	DC.W    36
;	DC.W    16
;	DC.W    37
;	DC.W    17
;	DC.W    38
;	DC.W    18
;	DC.W    39
;	DC.W    19
;	ENDR

Char_1
                  RINCBIN	Char.bin
Char_Mask
	DS.B    32









***************************************************************************

*	P R O G R A M M   R E L A T I V E   D A T A

***************************************************************************



Rel_Start



* Scrolling
* ---------


 _ Map_1_R_Buff
	DS.B	4*15
 _ Map_1_L_Buff
	DS.B	4*15
 _ Map_1_D_Buff
	DS.B	8*21
 _ x38
n	SET	0
	REPT	194
	DC.W	n
n	SET	n+38
	ENDR

 _ x42
n	SET	0
	REPT	194
	DC.W	n
n	SET	n+42
	ENDR



* Variables
* ---------


 _ Gen_25hz_Phase
	DS.W	1
 _ Pos_X
	DS.W	1
 _ Pos_Y
	DS.W	1
 _ Move_Up
	DS.W	1
 _ Move_Right
	DS.W	1
 _ Move_Down
	DS.W	1
 _ Move_Left
	DS.W	1
 _ Scr_B_Used
	DS.L	1
 _ Scr_B_Build
	DS.L	1
 _ Stage_2_Step
	DS.W	1
 _ Scr_C_Used
	DS.L	1
 _ Scr_C_Build
	DS.L	1
 _ Stage_3_Step
	DS.W	1
 _ Scr_1_Ptr
	DS.L	1
 _ Scr_1_R_Ptr
	DS.L	1
 _ Scr_1_L_Ptr
	DS.L	1
 _ Map_1_Ptr
	DS.L	1
 _ Scr_1_R_Step
	DS.W	1
 _ Scr_1_L_Step
	DS.W	1
 _ Scr_1_D_Step
	DS.W	1
 _ Scr_1_U_Step
	DS.W	1
 _ Scr_1_Split
	DS.W	1
 _ Initial_Build
	DS.W	1





