




***************************************************************************
*                                                                         *
*                                                                         *
*				            *
*		   A  G  O  N  Y		            *
*                          =================            	            *
*                                                                         *
*                                                                         *
*                                                                         *
*                            MAIN  MODULE                                 *
*                            ------------                                 *
*                                                                         *
*                                                                         *
***************************************************************************


* by ART & MAGIC


* Artwork:        Franck Sauer
*	Marc Albinet

* Coding:	Yves Grolet
* Date:	25/06/1990
* Tab:            custom




***************************************************************************


	OPT	o+,c-,w-,o3-



Debug	SET	1	* if 1 debuging version
Asm_Level	SET	1	* Ag general level to assemble
Asm_Vdo_Mode	SET     1	* 0 Pal   1 Ntsc
Asm_Absolute	SET	0	* 0 none  1 $400 (look at $f0000)
Asm_Demo_Mode	SET	0	* 0 none  1 record  2 play
Asm_Protect	SET	0
ASM_Restart	SET     0


	IFNE	Asm_Absolute=0
	SECTION	Chip,Code_c
	ELSEIF
Debug	SET	0
	ORG	$600
	ENDC

	IFNE	Debug=1
	OPT	d+
	ENDC


C	EQUR	a6
D	EQUR	a5


	IFNE	ASM_Vdo_Mode=0
	INCLUDE	WORK:Global/Preset.s
	ELSEIF
	INCLUDE	WORK:Global/Preset_ntsc.s
	ENDC

	INCDIR	WORK:Agony/

	INCLUDE Disk/Load.s






***************************************************************************

*	G L O B A L   I N I T I A L I S A T I O N

***************************************************************************



Code_Start
	IFNE	Asm_Absolute=0
	SYSTEM_OFF
	ENDC


	IFNE	Asm_Level=1
	INCLUDE	Game/LMER.lab
	INCLUDE	Game/LMER.alb
	ENDC

	IFNE	Asm_Level=2
	INCLUDE	Game/LFORET.lab
	INCLUDE	Game/LFORET.alb
	ENDC

	IFNE	Asm_Level=3
	INCLUDE	Game/LMARAIS.lab
	INCLUDE	Game/LMARAIS.alb
	ENDC

	IFNE	Asm_Level=4
	INCLUDE	Game/LMONTAGNES.lab
	INCLUDE	Game/LMONTAGNES.alb
	ENDC

	IFNE	Asm_Level=5
	INCLUDE	Game/LPLATEAUX.lab
	INCLUDE	Game/LPLATEAUX.alb
	ENDC

	IFNE	Asm_Level=6
	INCLUDE	Game/LFEUX.lab
	INCLUDE	Game/LFEUX.alb
	ENDC



* INITIALISE VIDEO
* ----------------


	IFNE	ASM_Vdo_Mode=0
SPR_Y_OFF	SET	$40
	ELSEIF
SPR_Y_OFF	SET	$30
	ENDC

	WAIT_SYNCH

	lea	Custom,C
	lea	Rel_Start+32768,D

	move	#$7fff,d0
	move	d0,Intena(C)
	move	d0,Intreq(C)
	move	d0,Dmacon(C)

	move.l	#_Dummy_Cl,Cop1lc(C)
	move	d0,Copjmp1(C)

	move	#$2000,sr




* INITIALISE KEYBOARD
* -------------------


	IFNE	ASM_Demo_Mode=0
	move.l	#Keyboard_Int,$68
	IFNE	asm_absolute=0
	move.b	#$7f,Icr+Ciaa
	lea	Ciab,a1
	clr.b	Cra(a1)
	move.b	#$7f,Icr(a1)
	tst.b   Icr(a1)
	move.b	#%10001000,Icr(a1)
	ENDC
	ENDC



* INITIALISE AUDIO
* ----------------


	bset	#1,$bfe001
	move    #277,Aud0per(C)
	clr	Aud0vol(C)
	clr	Sound0_Int_Step(D)
	clr	Sound0_Last_Pri(D)

	jsr	MUSIC_INIT



* INITIALISE VARIABLE & COPPER LIST
* ---------------------------------


                  move	#%1000011001000000,Dmacon(C)

	INCLUDE	Ag_Pre_Comp.s
Restart
	lea	Sorcerer_Pal(D),a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,Color+32(C)

                  lea	Cl_Flip_Jump0+2(D),a0
	move.l	#_Cl_Flip_phase1,d0
	move	d0,4(a0)
	swap	d0
	move	d0,(a0)

                  lea	Cl_Flip_Jump1+2(D),a0
	move.l	#_Cl_Flip_phase0,d0
	move.l	d0,cop2lc(C)
	move	d0,4(a0)
	swap	d0
	move	d0,(a0)

	move.l	#Back_Screen0,Cur_Back_Build(D)	* Back Screen
	move.l	#Back_Screen1,Cur_Back_Show(D)

	move.l	#_Back_Pattern+4,Pat_Ptr(D)

                  lea	Back_Pattern+16*2+6*4*2(D),a0       * Pattern 0
	move.l	a0,Pat0_Ptr_Stat(D)
	move.l	a0,Pat0_Ptr_Dyn(D)
	moveq	#1,d1
	move	d1,Pat0_Dly_Count(D)

	lea	Back_Pattern(D),a0		* Pattern 1
	move.l	a0,a2
	move	2(a0),d0
	add	d0,a0

	addq	#2,a0
	lea	Back_Color0+2(D),a1
	move	(a0)+,d0
	move	d0,(a1)
	move	d0,4(a1)
	move	(a0)+,d0
	move	d0,8(a1)
	move	d0,12(a1)
	move	(a0)+,d0
	move	d0,16(a1)
	move	d0,20(a1)

	addq	#2,a0
	lea	Back_Color1_f0+2(D),a1
	lea	Back_Color1_f1+2(D),a3
	move	(a0)+,d0
	move	d0,(a1)
	move	d0,4(a1)
	move	d0,(a3)
	move	d0,4(a3)
	move	(a0)+,d0
	move	d0,8(a1)
	move	d0,12(a1)
	move	d0,8(a3)
	move	d0,12(a3)
	move	(a0)+,d0
	move	d0,16(a1)
	move	d0,20(a1)
	move	d0,16(a3)
	move	d0,20(a3)

	addq	#2,a0
	lea	Back_Color2_f0+2(D),a1
	lea	Back_Color2_f1+2(D),a3
	move	(a0)+,d0
	move	d0,(a1)
	move	d0,4(a1)
	move	d0,(a3)
	move	d0,4(a3)
	move	(a0)+,d0
	move	d0,8(a1)
	move	d0,12(a1)
	move	d0,8(a3)
	move	d0,12(a3)
	move	(a0)+,d0
	move	d0,16(a1)
	move	d0,20(a1)
	move	d0,16(a3)
	move	d0,20(a3)

	addq	#2,a0
	lea	Back_Color3_f0+2(D),a1
	lea	Back_Color3_f1+2(D),a3
	move	(a0)+,d0
	move	d0,(a1)
	move	d0,4(a1)
	move	d0,(a3)
	move	d0,4(a3)
	move	(a0)+,d0
	move	d0,8(a1)
	move	d0,12(a1)
	move	d0,8(a3)
	move	d0,12(a3)
	move	(a0)+,d0
	move	d0,16(a1)
	move	d0,20(a1)
	move	d0,16(a3)
	move	d0,20(a3)

	addq	#2,a0
	lea	Back_Color4_f0+2(D),a1
	lea	Back_Color4_f1+2(D),a3
	move	(a0)+,d0
	move	d0,(a1)
	move	d0,4(a1)
	move	d0,(a3)
	move	d0,4(a3)
	move	(a0)+,d0
	move	d0,8(a1)
	move	d0,12(a1)
	move	d0,8(a3)
	move	d0,12(a3)
	move	(a0)+,d0
	move	d0,16(a1)
	move	d0,20(a1)
	move	d0,16(a3)
	move	d0,20(a3)

	addq	#2,a0
	lea	Back_Color5_f0+2(D),a1
	lea	Back_Color5_f1+2(D),a3
	move	(a0)+,d0
	move	d0,(a1)
	move	d0,4(a1)
	move	d0,(a3)
	move	d0,4(a3)
	move	(a0)+,d0
	move	d0,8(a1)
	move	d0,12(a1)
	move	d0,8(a3)
	move	d0,12(a3)
	move	(a0)+,d0
	move	d0,16(a1)
	move	d0,20(a1)
	move	d0,16(a3)
	move	d0,20(a3)


	move.l	a0,Pat1_Ptr_Stat(D)
	move.l	a0,Pat1_Ptr_Dyn(D)
	move	d1,Pat1_Dly_Count(D)

	move	4(a2),d0		* Pattern 2
	add	d0,a2
	lea	6*4*2(a2),a2
	move.l	a2,Pat2_Ptr_Stat(D)
	move.l	a2,Pat2_Ptr_Dyn(D)
	move	d1,Pat2_Dly_Count(D)

                  move.l	#_Status_Screen_Disp,d0
	lea	Status_Ptr+2(D),a0
	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	add.l	#76*19,d0
	move	d0,12(a0)
	swap	d0
	move	d0,8(a0)

	move	#31,Back_Shift(D)
	move	#33,Front_Shift(D)

	lea	Start_list,a0
                  move	(a0)+,Sl_Waiting(D)
	move.l	a0,Start_List_ptr(D)
                  move	#-32,Level_X(D)

	moveq	#0,d0
	move	d0,Back_Config(D)
	move	d0,Back_Phase(D)
	move	d0,Front_Phase(D)
	move	d0,Front_Pal_Count(D)

	move.l	#_Front_Map,Front_Read_Ptr(D)
	move.l	#_Front_Pal-6*7*2,Front_Pal_Ptr(D)
	lea	Front_Screens,a0
	move.l	a0,Cur_Front_Show(D)
	lea	Front_Screen1(a0),a0
	move.l	a0,Cur_Front_Build(D)
	lea	Front_Rest_Scr-Front_Screen1(a0),a0
	move.l	a0,Rest_Screen_Ptr(D)

Fw_F_Off	SET     20*12
	move	#Fw_F_Off,Fw_Fire_Step(D)

	move	#64+256,Sorcerer_X(D)
	move	#50+256,Sorcerer_Y(D)

	move	#64+256,Axe_Up_X(D)
	move	#4+256,Axe_Up_Y(D)

	move	#64+256,Axe_Down_X(D)
	move	#160+256,Axe_Down_Y(D)

	st	Curent_Spell+1(D)
	move	#18,Status_Delay(D)
	IFNE	Asm_Level=1
	st	Rain_on(D)
	ENDC
	IFEQ	ASM_Demo_Mode=0
	move.l	#Demo_Track,Demo_Track_Ptr
	ENDC

	lea	Clear_Start,a0
	lea	Clear_End,a1
.clr_loop
	clr.l	(a0)+
	cmp.l	a1,a0
	blt	.clr_loop

	move	#13,Text_Num(D)
	move	#-1,Text_Delay(D)
	move	#1,Begin_To_Start(D)   * 0 begined 1 text on 2 text off
	st	Stop+1(D)



* LET'S GO
* --------


                  WAIT_SYNCH

	move.l	#_Main_Cl,Cop1lc(C)
	move.l	#_Main_Cl,Curent_cl
	move	d0,Copjmp1(C)

	move.l	#Int3,$6c
	move.l	#Int4,$70
	IFNE	ASM_Demo_mode=0
	move	#%1100000010111000,Intena(C)
	ELSEIF
	move	#%1100000010110000,Intena(C)
	ENDC
                  move	#%1000011111100000,Dmacon(C)

	IFNE	ASM_Restart=1
                  clr	Sheet_Flag	* init for playable demo
	move	#3,Fw_Fire_Weapon
	st	Axe_Up_On+1
	st	Axe_Down_On+1
	moveq	#0,d0
	move.l	d0,Score
	move	#%111,Life
	move.l	d0,Extra_Life
	move.l	d0,Spell_Advailable
	move.l	d0,Spell_Advailable+4
	move.l	d0,Spell_Advailable+8
	move.l	d0,Spell_Advailable+12
	move	d0,Spell_Next_Bonus
                  ENDC






***************************************************************************

*	M A I N   L O O P   A T   2 5   H Z

***************************************************************************



Main_Loop



* WAIT VERTICAL SYNCHRO
* ---------------------


Wait_Synch_Loop
	IFNE	ASM_Vdo_Mode=0
                  cmp	#2,Gen_25hz_Phase(D)
	blt	Wait_Synch_Loop
;                  btst	#0,Vpos+1(C)	* wait for vbl >= 256
;	beq     Wait_Synch_Loop
	ELSEIF
                  cmp	#3,Gen_25hz_Phase(D)
	blt	Wait_Synch_Loop
                  btst	#0,Vpos+1(C)	* wait for vbl >= 256
	beq     Wait_Synch_Loop
	ENDC

	clr	Gen_25hz_Phase(D)



* UPDATE COPPER LIST SCREEN INFO
* ------------------------------


	tst	Pause2(D)
 	bne     No_Cl_Update

	tst	Back_Phase(D)
	bne	.Phase1

	eor	#240,Back_Old_Off(D)

	move    Back_Shift(D),d0
	move	d0,d1
                  and	#%1111,d0
                  lsl	#4,d0
	move	Video_Shift+2(D),d2
	and	#%1111,d2
	or	d0,d2
	move	d2,Video_Shift+2(D)

	move.l	Cur_Back_Build(D),d0
	move.l	Cur_Back_Show(D),Cur_Back_Build(D)
	move.l	d0,Cur_Back_Show(D)

                  btst	#4,d1
	bne	.no
	addq.l	#2,d0
.no
	lea     Back_Ptr+2(D),a0	* Back scroll bpl ptr
	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	add.l	#$500,d0
	move	d0,12(a0)
	swap	d0
	move	d0,8(a0)
	swap	d0	* Sky Ptr
	add.l	#2*40*192-$500,d0
	lea	Sky_Ptr0+2(D),a0
	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	add.l	#40*32,d0
	lea	Sky_Ptr1_f0+2(D),a0
	lea	Sky_Ptr1_f1+2(D),a1
	move	d0,4(a0)
	move	d0,4(a1)
	swap	d0
	move	d0,(a0)
	move	d0,(a1)
	swap	d0
	add.l	#40*32,d0
	lea	Sky_Ptr2_f0+2(D),a0
	lea	Sky_Ptr2_f1+2(D),a1
	move	d0,4(a0)
	move	d0,4(a1)
	swap	d0
	move	d0,(a0)
	move	d0,(a1)
	swap	d0
	add.l	#40*32,d0
	lea	Sky_Ptr3_f0+2(D),a0
	lea	Sky_Ptr3_f1+2(D),a1
	move	d0,4(a0)
	move	d0,4(a1)
	swap	d0
	move	d0,(a0)
	move	d0,(a1)
	swap	d0
	add.l	#40*32,d0
	lea	Sky_Ptr4_f0+2(D),a0
	lea	Sky_Ptr4_f1+2(D),a1
	move	d0,4(a0)
	move	d0,4(a1)
	swap	d0
	move	d0,(a0)
	move	d0,(a1)
	swap	d0
	add.l	#40*32,d0
	lea	Sky_Ptr5_f0+2(D),a0
	lea	Sky_Ptr5_f1+2(D),a1
	move	d0,4(a0)
	move	d0,4(a1)
	swap	d0
	move	d0,(a0)
	move	d0,(a1)
.Phase1
	lea     Front_Ptr+2(D),a0	* FRONT scroll bpl ptr
	move.l	Cur_Front_Show(D),d0
	btst	#4,Front_Shift+1(D)
	bne	.no1
	addq.l	#2,d0
.no1
	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	add.l	#192*44,d0
	move	d0,12(a0)
	swap	d0
	move	d0,8(a0)
	swap	d0
	add.l	#192*44,d0
	move	d0,20(a0)
	swap	d0
	move	d0,16(a0)
No_Cl_Update



* FRONT SCROLL
* ------------


;        	st	$dff180

	INCLUDE	Ag_Front_Scroll_.s

;	clr	$dff180



* BACK SCROLL
* -----------


;        	st	$dff180

	INCLUDE	Ag_Back_Scroll.s

;	clr	$dff180



* SEARCH SHORT PHASE
* ------------------


	clr	Short_Phase(D)
	move.l	Vpos(C),d0
	move	Old_Vpos(D),d1
	lsr	#8,d0
	and	#$1ff,d0
	move	d0,Old_Vpos(D)
	cmp	d1,d0
	bgt	No_Short
	st	Short_Phase+1(D)
No_Short



* GAME
* ----


	INCLUDE	Ag_Object_.s

	INCLUDE	Ag_Playability_.s



* STATUS LINE
* -----------


;        	st	$dff180

	INCLUDE	Ag_Status.s

;	clr	$dff180



* SOUNDS
* ------


;        	st	$dff180

	INCLUDE	Ag_Sounds.s

;	clr	$dff180



* ALIEN FIRE
* ----------


AF_Wait_Phase
                  cmp	#1,Gen_25hz_Phase(D)
	blt     AF_Wait_Phase
AF_Wait_Synch
                  cmp	#2,Gen_25hz_Phase(D)
	bge     .ok
	move.l	Vpos(C),d0
	and.l	#$0001ff00,d0
	cmp.l	#$00004000,d0
	blt     AF_Wait_Synch
	cmp.l	#$00010000,d0
	bgt	AF_Wait_Synch
.ok
;        	st	$dff180

	INCLUDE	Ag_Alien_Fire.s

;	clr	$dff180



* FRONT SCROLL CONTROL
* --------------------


	tst	Pause2(D)
	bne     Front_Ctrl_End

	tst	Stop2(D)
	bne     .ok

	cmp	#16,Front_Phase(D)
	bne     .ok
	clr	Front_Phase(D)
	addq.l	#4,Cur_Front_Build(D)
	addq.l	#4,Cur_Front_Show(D)
	addq.l	#4,Rest_Screen_Ptr(D)
.ok				;Page Flipping
	move.l	Cur_Front_Build(D),d0
	move.l	Cur_Front_Show(D),Cur_Front_Build(D)
	move.l	d0,Cur_Front_Show(D)

Front_Ctrl_End


	IFNE	Debug=1
	EXIT_TEST
	ENDC



* BEGIN TO START
* --------------


	tst	Begin_To_Start(D)
	beq	BTS_End
                  btst	#7,JoyFire	* FIRE TEST
	bne	.No_Fire
	clr	Stop(D)
	move	#2,Text_Delay(D)
	clr	Begin_To_Start(D)
	st	Old_Text_Num+1(D)
	bra	BTS_End
.No_Fire
	addq    #1,BTS_Delay(D)
                  cmp     #10,BTS_Delay(D)
	bne     BTS_End
	clr     BTS_Delay(D)
	cmp     #1,Begin_To_Start(D)
	beq	.phase1
	move	#1,Begin_To_Start(D)
	lea	Status_Screen(D),a1
	move	#76*18/4,d1
.clr_loop
	clr.l	(a1)+
	dbra	d1,.clr_loop
	bra	BTS_End
.phase1
	move	#2,Begin_To_Start(D)
	move	#13,Text_Num(D)
	move	#-1,Text_Delay(D)
	st	Old_Text_Num+1(D)
BTS_End



* CLENA UP
* --------


	tst	Clean_Up(D)
	beq     CU_Bank_End
	st	AF_Off+1(D)
	lea	Track_Table(D),a0
	move.l	#$80000000,d0
	moveq	#15,d1
.loop
	or.l	d0,(a0)+
	dbra	d1,.loop
	lea	Rout_Struct(D),a0
	moveq	#-1,d0
	moveq	#31,d1
.loop2
	move.l	d0,(a0)+
	dbra	d1,.loop2
	lea     AWO_Struct(D),a0	* a0 AWO Dyn Ptr
	lea	AF_Struct,a1
CU_Bank_Loop
	move	(a0)+,d0	* d0 Curent Alien Num
                  beq	CU_Bank_Ignored
	cmp	#-1,d0
	bne	CU_Bank_Tested
CU_Bank_Ignored
	lea	16*AWO_Len+2(a0),a0
	cmp.l	#_AWO_Struct+AWO_Size*32,a0
	bge     CU_Bank_End
	bra	CU_Bank_Loop
CU_Bank_Tested
	move	(a0)+,d1
	move.l	a0,Curent_Bank_Ptr(D)
	add	d1,a0
	subq	#1,d0
.obj_loop
	move.b	AWO_Alien_Status(a0),d1
	and	#$f,d1
	bne	.obj_end
	move.b	#1,AWO_Alien_Status(a0)
.obj_end
	lea     AWO_Len(a0),a0
	dbra    d0,.obj_loop

	move.l  Curent_Bank_Ptr(D),a0
	lea	16*AWO_Len(a0),a0
	cmp.l	#_AWO_Struct+AWO_Size*32,a0
	beq     CU_Bank_End
                  bra     CU_Bank_Loop
CU_Bank_End



* KEY UP CTRL
* -----------


	tst	Key_Up_Flag(D)
	beq	No_Keyup
	clr	Key_Up_Flag(D)
	st	Key+1(D)
No_Keyup



* QUIT DELAY AND MAIN LOOP CTRL
* -----------------------------


	tst	Quit_Delay(D)
	beq	.no_quit
                  subq	#1,Quit_Delay(D)
	cmp     #1,Quit_Delay(D)
	beq	Exit
.no_quit
	bra	Main_Loop



* EXIT LEVEL
* ----------


Exit
	IFNE	ASM_Restart=1
	clr	Quit_Delay(D)
	clr	Clean_Up(D)
	clr	Stop(D)
	clr	Prg_Pause(D)
	bra	Restart
	ENDC

	IFNE	Debug=1
	moveq	#$0000,d7
	move	#90,d6
	bsr	SetFade
	moveq	#$0001,d7
	move	#90,d6
	bsr	SetFade
	moveq	#$0002,d7
	move	#90,d6
	bsr	SetFade
	moveq	#$0003,d7
	move	#90,d6
	bsr	SetFade
	clr     Delay_Count
.Delay0
                  cmp	#50,Delay_Count
	bne     .Delay0
	SYSTEM_ON
                  rts
	ENDC

	IFNE	Asm_Absolute=1

	st	Curent_Spell+1(D)
	st	Stop+1(D)
	clr 	Die(D)

	tst	Life
	beq	Game_Over

	IFNE	ASM_Level=1
                  LOAD	FILE_1_4,Load_Buffer
                  ENDC

	IFNE	ASM_Level=2
                  LOAD	FILE_1_6,Load_Buffer
                  ENDC

	IFNE	ASM_Level=3
                  LOAD	FILE_2_2,Load_Buffer
                  ENDC

	IFNE	ASM_Level=4
                  LOAD	FILE_2_4,Load_Buffer
                  ENDC

	IFNE	ASM_Level=5
                  LOAD	FILE_2_6,Load_Buffer
                  ENDC

	IFNE	ASM_Level=6
                  LOAD	FILE_0_3,Load_Buffer
                  ENDC

	moveq	#$0000,d7
	move	#90,d6
	bsr	SetFade
	moveq	#$0001,d7
	move	#90,d6
	bsr	SetFade
	moveq	#$0002,d7
	move	#90,d6
	bsr	SetFade
	moveq	#$0003,d7
	move	#90,d6
	bsr	SetFade
	clr     Delay_Count
.Delay
                  cmp	#50,Delay_Count
	bne     .Delay

	move	#$7fff,d1
	move	d1,Intena+Custom
	move	d1,Intreq+Custom
	move	d1,Dmacon+Custom
	clr	$dff180
	lea	Load_Buffer,a1
	IFNE	ASM_Level=6
                  lea	$600,a0
	ELSEIF
                  lea	$61500,a0
	ENDC
	move.l	a0,-(sp)
	jmp	$80
Game_Over
                  LOAD	FILE_1_1,Load_Buffer
	moveq	#$0000,d7
	move	#90,d6
	bsr	SetFade
	moveq	#$0001,d7
	move	#90,d6
	bsr	SetFade
	moveq	#$0002,d7
	move	#90,d6
	bsr	SetFade
	moveq	#$0003,d7
	move	#90,d6
	bsr	SetFade
	clr     Delay_Count
.Delay
                  cmp	#50,Delay_Count
	bne     .Delay
	move	#$7fff,d1
	move	d1,Intena+Custom
	move	d1,Intreq+Custom
	move	d1,Dmacon+Custom
	clr	$dff180
	moveq	#0,d0
	lea	Load_Buffer,a1
                  lea	$600,a0
	move.l	a0,-(sp)
	jmp	$80

	ENDC

Delay_Count
	DS.W	1

	LOAD_1
	LOAD_2
	LOAD_3
	LOAD_4
	LOAD_5
	LOAD_6
	LOAD_7
	LOAD_8
	LOAD_9
	LOAD_10
	LOAD_11
	LOAD_12
	LOAD_13
	LOAD_14
	LOAD_15
	LOAD_16






***************************************************************************

*	V B L   I N T E R U P T I O N S

***************************************************************************



* INTERRUPTION 3
* --------------


Int3
                  movem.l	d0-d7/a0-a6,-(sp)
                  lea	Custom,C
	lea	Rel_Start+32768,D

                  move	Intreqr(C),d0
	btst	#4,d0
	bne	Copper_Int3

                  addq	#1,Delay_Count



* INTERRUPTION 3 VBL SCREEN START
* -------------------------------


	IFNE	ASM_Vdo_Mode=0
                  jsr	MUSIC_PLAY
	ELSEIF
	addq	#1,Mus_Ntsc_Skip(D)
	cmp	#6,Mus_Ntsc_Skip(D)
	beq	.skip
                  jsr	MUSIC_PLAY
	bra	.cont
.skip
	clr	Mus_Ntsc_Skip(D)
.cont
	ENDC



* INTERRUPTION 3 VBL END
* ----------------------


	move	#%0000000000100000,Intreq(C)
                  movem.l	(sp)+,d0-d7/a0-a6
	rte



* INTERRUPTION 3 COPPER SCREEN END
* --------------------------------


Copper_Int3


                  move	#%1000000000100000,Dmacon(C)	* open spr dma (chg disk)



* 25 Hz GENERAL PHASE INCREMENTATION
* ----------------------------------


	IFNE	ASM_Vdo_Mode=0
	addq	#1,Gen_25hz_Phase(D)
	tst     Quit_Delay(D)
	bne	No_Inc
	cmp     #3,Gen_25hz_Phase(D)
	bge     Int3_End
No_Inc
	ELSEIF
	addq	#1,Gen_25hz_Phase(D)
;	tst     Quit_Delay(D)
;	bne	No_Inc
	cmp     #1,Gen_25hz_Phase(D)
	beq     Int3_End
No_Inc
	ENDC



* MAIN CHARACTERE
* ---------------


;	REPT	16
;	st	$dff180
;	ENDR
;	clr	$dff180

	INCLUDE	Ag_Sprites.s

;	clr     $dff180



* FRONT SHIFT
* -----------


	tst	Stop2(D)
	bne	.stoped

	move	Video_Shift+2(D),d2
	and	#%11110000,d2
	move	Front_Shift(D),d0
;	addq	#1,d0
	and	#%1111,d0
	or	d0,d2
	move	d2,Video_Shift+2(D)

	tst	Vdo_S_Inc(D)
	bne	.stoped
	st	Vdo_S_Inc+1(D)
                  subq	#1,Front_Shift(D)
.stoped



* RAIN
* ----
	IFNE	Asm_Level=1

	tst	Rain_On(D)
                  beq	No_Rain
	tst	Icones_Mode(D)
	bne	No_Rain
	tst	Die(D)
	bne	No_Rain
                  cmp.b	#-1,Curent_Spell+1(D)
	bne	No_Rain

                  lea	Rain_X_Table(D),a0
	add	Rain_X_Off0(D),a0
	lea	Rain_Spr0(D),a1
	move.l	#$6670778,Color+58(C)
	move	#$889,Color+62(C)
	move.l	a1,Spr6ptB(D)
	move.l	#$40004700,d1
	moveq	#0,d4

	moveq	#23,d0
Rain_Loop0
	move.l	d1,d2
	moveq	#0,d3
	move	(a0)+,d3
	sub	d4,d3
	swap	d3
	or.l	d3,d2
	move.l	d2,(a1)+
	lea	4*7(a1),a1
                  add.l	#$08000800,d1
	addq	#1,d4

	dbra	d0,Rain_Loop0

	tst     Pause(D)
	bne     .ok
                  subq	#6,Rain_X_Off0(D)
	bpl	.ok
	move	#96,Rain_X_Off0(D)
.ok

                  lea	Rain_X_Table(D),a0
	add	Rain_X_Off1(D),a0
	lea	Rain_Spr1(D),a1
	move.l	a1,Spr7ptB(D)
	move.l	#$40004700,d1
	moveq	#0,d4

	moveq	#23,d0
Rain_Loop1
	move.l	d1,d2
	moveq	#0,d3
	move	(a0)+,d3
	sub	d4,d3
	swap	d3
	or.l	d3,d2
	move.l	d2,(a1)+
	lea	4*7(a1),a1
                  add.l	#$08000800,d1
	addq	#2,d4

	dbra	d0,Rain_Loop1

	tst     Pause(D)
	bne     No_Rain
                  subq	#4,Rain_X_Off1(D)
	bpl     No_Rain
	move	#96,Rain_X_Off1(D)
No_Rain
	ENDC


* INTERRUPTION 3 COPPER END
* -------------------------


Int3_End
	move	#%0000000000010000,Intreq(C)
                  movem.l	(sp)+,d0-d7/a0-a6
	rte






***************************************************************************

*	S O U N D S   I N T E R R U P T I O N   &   S U B

***************************************************************************



* INTERRUPTION 4
* --------------


Int4
                  movem.l	d0-d7/a0-a6,-(sp)
                  lea	Custom,C
	lea	Rel_Start+32768,D



* CLOSE SOUND DMA
* ---------------


	addq    #1,Sound0_Int_Step(D)
	cmp	#1,Sound0_Int_Step(D)
	beq	.no
	move	#$0001,dmacon(C)
                 	clr	Aud0vol(C)
	clr	Sound0_Int_Step(D)
	clr	Sound0_Last_Pri(D)
	move	#%10000000,Intena(C)
.no


* INTERRUPTION 4 SOUNDS END
* -------------------------


	move	#%0000000010000000,Intreq(C)
                  movem.l	(sp)+,d0-d7/a0-a6
	rte



* START SOUND SUB		d0 : sound num   d1, volume
* ---------------


Sound_Start
	movem.l	d0/d1/a0/C/D,-(sp)
                  lea	Custom,C
	lea	Rel_Start+32768,D

	move	Sound0_Req(D),d0
	lea	Pri_Table(D),a0
	move.b	(a0,d0.w),d1
	cmp.b   Sound0_Last_Pri(D),d1
	blt     .no_pri
 	move	#%10000000,Intena(C)
	move.b	d1,Sound0_Last_Pri(D)	* Start Sound
	move	d0,Sound0(D)
	move	Sound0_Vol_Req(D),Sound0_Vol(D)
                	clr	Aud0vol(C)
.no_pri
	movem.l	(sp)+,d0/d1/a0/C/D
	rts






***************************************************************************

*	K E Y B O A R D   I N T E R R U P T I O N

***************************************************************************



* KEYBOARD INTERRUPTION START
* ---------------------------


Keyboard_Int
                  movem.l	d0-d7/a0-a6,-(sp)
                  lea	Custom,C
	lea	Rel_Start+32768,D



* READ KEYCODE
* ------------


	rclr	d0
 	move.b	Sdr+Ciab,d0       	* d0 key code
 	st	Sdr+Ciab            * put 1 on serial port
	move.b	#%01010001,Cra+Ciab * turn serial port in out

	btst	#0,d0
	bne	Key_Down
	st	Key_Up_Flag+1(D)
	bra	Keyb_End
Key_Down
	lsr	#1,d0
	eor	#$7f,d0
	move.b	d0,Key+1(D)
Keyb_End
	tst.b	Icr+Ciab	* clear int bit
	moveq	#1,d0
	and	Vpos(C),d0
	lsl	#8,d0
	move.b	Vhpos(C),d0
Keyb_Wait1                                    * wait 1rst raster line
	moveq	#1,d1
	and	Vpos(C),d1
	lsl	#8,d1
	move.b	Vhpos(C),d1
	cmp	d1,d0
	beq	Keyb_Wait1
Keyb_Wait2			* wait 2nd raster line
	moveq	#1,d0
	and	Vpos(C),d0
	lsl	#8,d0
	move.b	Vhpos(C),d0
	cmp	d1,d0
	beq.s   Keyb_Wait2

	clr.b	Cra+Ciab	* turn serial port in entry



* KEY TEST
* --------


	move	Key(D),d0
	cmp	#$19,d0
	beq	Do_Pause
	cmp	#$40,d0
	beq	Do_Menu
	cmp	#$45,d0
	beq	Abort
	cmp	#$37,d0
	beq    	Change_Mode

                  tst	Sheet_Flag
	beq	.cont
	cmp	#$44,d0	*sheet keys
                  beq	Sheet_next
	cmp	#$50,d0
	beq	F1
	cmp	#$51,d0
	beq	F2
	cmp	#$52,d0
	beq	F3
	cmp	#$53,d0
	beq	F4
.cont
	cmp.b	#$ff,Key+1(D)
	beq	Ki_return
	tst	Pause(D)
	beq	ki_return
                  bra	Pause_off



* SPECIAL FUNCTIONS
* -----------------


Do_Menu
	st	Key+1(D)
	tst 	Die(D)
	bne	Ki_Return
	tst	Begin_To_Start(D)
	bne	Ki_Return
                  tst	Icones_Mode(D)
	bne	Pause_Off
	cmp	#2,Curent_Spell(D)
	beq     Ki_Return
	tst	Quit_Delay(D)
	bne     Ki_Return

	move	Curent_Spell(D),Safe_Cur_Spell(D)
                  st	Pause+1(D)
	st	Stop+1(D)
	st	Icones_Mode+1(D)
	move	#24*2,Arow_y(D)
	clr	Icones_Fire_Up(D)
	bra     Ki_Return

Change_Mode
	st	Key+1(D)
	eor     #1,Menu_Mode
	bra	Ki_Return
Do_pause
	tst	Begin_To_Start(D)
	bne	Ki_Return
	tst 	Die(D)
	bne	Ki_Return
	st	Key+1(D)
	tst	Pause(D)
	beq	Active_Pause
Pause_Off
	clr     Pause(D)
	clr	Stop(D)
	move	#2,Text_Delay(D)
	tst	Icones_Mode(D)
	beq	.no_spell
	st	Icones_Off+1(D)
	move	Safe_Cur_Spell(D),Curent_Spell(D)
	lea	Empty_Spr(D),a0
	move.l	a0,Spr0ptB(D)
	move.l	a0,Spr1ptB(D)
	move.l	a0,Spr2ptB(D)
	move.l	a0,Spr3ptB(D)
	move.l	a0,Spr4ptB(D)
	move.l	a0,Spr5ptB(D)
	move.l	a0,Spr6ptB(D)
	move.l	a0,Spr7ptB(D)
	st	Old_Text_Num(D)
.no_spell
	and	#%111111111111011,Bpl_con0+2(D)
	bra     Ki_Return
Active_Pause
                  st	Pause+1(D)
	st	Stop+1(D)
	move	#10,Text_Num(D)
	move	#-1,Text_Delay(D)
	or	#%000000000000100,Bpl_con0+2(D)
	bra     Ki_Return
Abort
	tst     Quit_Delay(D)
	bne	Ki_Return
	move	#20,Quit_Delay(D)
	clr     Life
	st	Clean_up(D)
	bra     ki_return
Sheet_Next
	move	#20,Quit_Delay(D)
	st	Clean_up(D)
	bra     ki_return

F1
	st	Key+1(D)
	eor	#1,Axe_Down_On
	beq	.no
	move    Sorcerer_X(D),Axe_Down_X(D)
	move    Sorcerer_X(D),Axe_Up_X(D)
.no
	bra     ki_return
F2
	st	Key+1(D)
	eor	#1,Axe_Up_On
	beq	.no
	move    Sorcerer_X(D),Axe_Up_X(D)
	move    Sorcerer_X(D),Axe_Down_X(D)
	lea	Spell_Advailable,a0
	moveq	#7,d0
.loop
	move	#1,(a0)+
	dbra	d0,.loop
.no
	bra     ki_return
F3
	st	Key+1(D)
                  addq	#1,Fw_Fire_Weapon
                  and	#3,Fw_Fire_Weapon
	move.l	#$20000,Point(D)
	bra     ki_return

F4
	st	Key+1(D)
                  move	#3,Fw_Fire_Weapon
	move.l	#$80000,Point(D)
	move	#1,Axe_Down_On
	move	#1,Axe_Up_On
	bra     ki_return



* KEYBOARD INTERRUPTION END
* -------------------------


ki_return
	move	#%0000000000001000,Intreq(C)
                  movem.l	(sp)+,d0-d7/a0-a6
	rte






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
	INCBIN	WORK:Agony/\1
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



* AUDIO DATA
* ----------


Sound_Dat
	IFNE	ASM_Demo_Mode=0
	IFNE	ASM_Level=1!ASM_Level=2!ASM_Level=3!ASM_Level=4
	RINCBIN	Sounds/Sound.bin
	ENDC
	IFNE	ASM_Level=5
	RINCBIN	Sounds/Sound_s.bin
	ENDC
	IFNE	ASM_Level=6
	RINCBIN	Sounds/Sound_vs.bin
	ENDC
	ENDC

	IFNE	ASM_Level=1
	INCLUDE	Muzack/Sea&Fire.s
	ENDC
	IFNE	ASM_Level=2
	INCLUDE	Muzack/Forest.s
	ENDC
	IFNE	ASM_Level=3
	INCLUDE	Muzack/Marshes&Highlands.s
	ENDC
	IFNE	ASM_Level=4
	INCLUDE	Muzack/Mountains.s
	ENDC
	IFNE	ASM_Level=5
	INCLUDE	Muzack/Marshes&Highlands.s
	ENDC
	IFNE	ASM_Level=6
	INCLUDE	Muzack/Sea&Fire.s
	ENDC


* SPRITES
* -------


Sorcerer_Dat
                  RINCBIN	Main_Char/Sorcerer.bin
Buffer_Disk
Sorcerer2_Dat
                  RINCBIN	Main_Char/Sorcerer2.bin
;Sorcerer3_Dat
;                 RINCBIN	Main_Char/Sorcerer3.bin
Fw_Fire_Spr
                  RINCBIN	Main_Char/FwFire.bin
Bonus_Spr
	RINCBIN	Main_Char/Bonusses.bin
Alien_Fire_Spr
	RINCBIN	Main_Char/Alien_Fire.bin
Die_Spr
	RINCBIN	Main_Char/Die.bin



* SCROLL CHARSET
* --------------


Sky_Dat
	LINCBIN	Sky.bin
Load_Buffer
Back_Charset
	LINCBIN	Back.bin
Front_Charset
	LINCBIN	Front.Bin



* OBJECTS
* -------


Sprites_Bitmap
	LINCBIN	Objects.bin
Sprites_Mask
	IFNE	ASM_Level=1
	DS.B	52000-(Sprites_Mask-Sprites_Bitmap)
                  ENDC
	IFNE	ASM_Level=2
	DS.B	55000-(Sprites_Mask-Sprites_Bitmap)
                  ENDC
	IFNE	ASM_Level=3
	DS.B	53000-(Sprites_Mask-Sprites_Bitmap)
                  ENDC
	IFNE	ASM_Level=4
	DS.B	56000-(Sprites_Mask-Sprites_Bitmap)
                  ENDC
	IFNE	ASM_Level=5
	DS.B	57000-(Sprites_Mask-Sprites_Bitmap)
                  ENDC
	IFNE	ASM_Level=6
	DS.B	63500-(Sprites_Mask-Sprites_Bitmap)
                  ENDC

Objects_Struct
	LINCBIN	Objects.obj



* GAME DATA
* ---------



Track_Struct

Count	set	0
	REPT    16
	DS.B	11
	DC.B	Count*4
Count            	SET	Count+1
	DS.W	2
	DS.B	32*4
	ENDR

	RSRESET
AF_X	RS.W	1
AF_Y	RS.W	1
AF_Y_Count_Stat	RS.B	1
AF_Y_Count_Dyn	RS.B	1
AF_Closer_Num	RS.B	1
AF_Closer_Offset	RS.B	1
AF_Len	RS.B	0

AF_Struct
	DCB.B	32*AF_Len,-1

	IFNE	Asm_Level=1
	INCLUDE	Game/Ag_Game_LMER.s
	ENDC

	IFNE	Asm_Level=2
	INCLUDE	Game/Ag_Game_LFORET.s
	ENDC

	IFNE	Asm_Level=3
	INCLUDE	Game/Ag_Game_LMARAIS.s
	ENDC

	IFNE	Asm_Level=4
	INCLUDE	Game/Ag_Game_LMONTAGNES.s
	ENDC

	IFNE	Asm_Level=5
	INCLUDE	Game/Ag_Game_LPLATEAUX.s
	ENDC

	IFNE	Asm_Level=6
	INCLUDE	Game/Ag_Game_LFEUX.s
	ENDC



* DEMO DATA
* ---------


	IFNE	ASM_Demo_Mode=1
Demo_Track
	DS.B    12*1024
Demo_Track_End

Demo_Track_Ptr
	DS.L    1
	ENDC

	IFNE	ASM_Demo_Mode=2
Demo_Track
	IFNE	ASM_Level=1
	RINCBIN	Demo/Demo_Track_sea
	ELSEIF
	RINCBIN	Demo/Demo_Track_forest
	ENDC
JoyFire
	DS.W	1
JoyMove
	DS.W	1
Demo_Track_Ptr
	DS.L    1
                  ENDC

	IFEQ	ASM_Demo_Mode=0
Text
	IFNE	ASM_Level=1
	INCBIN	WORK:Agony/Present/Level_Sea.txt
	ELSEIF
	INCBIN	WORK:Agony/Present/Level_Forest.txt
	ENDC
Page_Cl
	C_MOVE	0,Bpl1pt
	C_MOVE	0,Bpl1pt+2
                  C_END
Font_L
	INCBIN	WORK:Agony/Present/Font_L.bin
Font
	INCBIN	WORK:Agony/Present/Font.bin

	ENDC



***************************************************************************

*	P R O G R A M M   R E L A T I V E   D A T A

***************************************************************************



Rel_Start



* BACK SCROLL
* -----------


 _ Back_Frame
	LINCBIN	Back.frm
 _ Back_Pattern
	LINCBIN	Back.pat
 _ Back_Char_Info
	LINCBIN	Back.inf
 _ Read_Table
	RINCBIN	Table/Back_Read.bin
 _ Back_Old_Char
                  DS.B    480
 _ X60

Count	SET	0
	REPT	128
	DC.W	Count
Count             SET	Count+60
	ENDR

 _ Write_Table
	DC.W	$0000,$0a00,$1400,$1e00,$2800,$3200
	DC.W	$0004,$0a04,$1404,$1e04,$2804,$3204
	DC.W	$0008,$0a08,$1408,$1e08,$2808,$3208
	DC.W	$000c,$0a0c,$140c,$1e0c,$280c,$320c
	DC.W	$0010,$0a10,$1410,$1e10,$2810,$3210

	DC.W	$0014,$0a14,$1414,$1e14,$2814,$3214
	DC.W	$0018,$0a18,$1418,$1e18,$2818,$3218
	DC.W	$001c,$0a1c,$141c,$1e1c,$281c,$321c
	DC.W	$0020,$0a20,$1420,$1e20,$2820,$3220
	DC.W	$0024,$0a24,$1424,$1e24,$2824,$3224

 _ Sky_Anim_Table
	IFNE	Asm_Level=5
	DC.W	0*1440,1*1440,2*1440,15*1440
	DC.W	0*1440,1*1440,2*1440,15*1440
	DC.W	3*1440,4*1440,5*1440,15*1440
	DC.W	3*1440,4*1440,5*1440,15*1440
	DC.W	6*1440,7*1440,8*1440,15*1440
	DC.W	6*1440,7*1440,8*1440,15*1440
	DC.W	9*1440,10*1440,11*1440,15*1440
	DC.W	9*1440,10*1440,11*1440,15*1440
	DC.W	12*1440,13*1440,14*1440,15*1440
	DC.W	12*1440,13*1440,14*1440,15*1440
                  ELSEIF
	DC.W	0*1440,1*1440,2*1440,3*1440
	ENDC


* FRONT SCROLL
* ------------


 _ Front_Map
	LINCBIN	Front.Map
 _ Front_Pal
	LINCBIN	Front.Pal
 _ Front_Pal_Buffer
	DS.W	7*6
 _ Front_Table
	RINCBIN	Table/Front_Write.bin
 _ X384

Count	SET	0
	REPT    256
	DC.L	Count
Count             SET	Count+384
	ENDR
 _ Front_Mask
	DS.B    128
 _ Rain_X_Table
	RINCBIN	Table/Rain_X.bin
	RINCBIN	Table/Rain_X.bin
 _ Rain_Spr0
	REPT	24
	DC.L	0
	DC.W	%0000000000000001
	DC.W	%0000000000000000
	DC.W	%0000000000000001
	DC.W	%0000000000000000
	DC.W	%0000000000000010
	DC.W	%0000000000000000
	DC.W	%0000000000000000
	DC.W	%0000000000000010
	DC.W	%0000000000000000
	DC.W	%0000000000000010
	DC.W	%0000000000000100
	DC.W	%0000000000000100
	DC.W	%0000000000000100
	DC.W	%0000000000000100
	ENDR
 _ Rain_Spr1
	REPT	24
	DC.L	0
	DC.W	%0000000000000001
	DC.W	%0000000000000000
	DC.W	%0000000000000001
	DC.W	%0000000000000000
	DC.W	%0000000000000010
	DC.W	%0000000000000000
	DC.W	%0000000000000000
	DC.W	%0000000000000010
	DC.W	%0000000000000000
	DC.W	%0000000000000010
	DC.W	%0000000000000100
	DC.W	%0000000000000100
	DC.W	%0000000000000100
	DC.W	%0000000000000100
	ENDR



* SOUNDS
* ------


 _ Pri_Table			* PRI , Self NO Breackable
	DC.B    4
	DC.B    3
	DC.B    1
	DC.B    2

	EVEN



* MAIN CHARACTERE
* ---------------


 _ Sorcerer_Pal
                  RINCBIN	Main_Char/Sorcerer.pal
 _ X224
	DC.W	0
	DC.W    224
	DC.W    224*2
	DC.W    224*3
 _ Empty_Spr
	DC.L	0
 _ Axe_Traj
                  RINCBIN	Main_Char/Axe_Traj.bin
 _ Icones_Spr
	RINCBIN	Main_Char/Icones.bin
 _ Icones_Pal
	RINCBIN	Main_Char/Icones.pal
 _ Arow_Spr
	RINCBIN	Main_Char/Arow.bin
 _ Mask_Spr
	DC.L	$418c0082
	DS.L	192
	DC.L	0
	DC.L	$418c0082
	DS.L	192
	DC.L	0
 _ Spell_Pri
	DC.W    4
	DC.W    1
	DC.W    0
	DC.W    7
	DC.W    2
	DC.W    3
	DC.W    6
	DC.W    5
 _ Time_Table
	DC.W	$15
	DC.W	$06
	DC.W	$05
	DC.W	$10
	DC.W	$08
	DC.W	$06
	DC.W	$12
	DC.W	$08
 _ Time_Y_Table
	RINCBIN	Main_Char/Time_Table.bin
 _ Bonus_Shape
	DC.W	0
	DC.W	800
	DC.W	1600
	DC.W	2400
 _ Bonus_Image
	DC.W	0
	DC.W    1
	DC.W    2
	DC.W    3
	DC.W    3
	DC.W    3
	DC.W    3
	DC.W    3
	DC.W    3
	DC.W    3
	DC.W    3
	DC.W	0
 _ Rot_Table
	RINCBIN Main_Char/Rot.bin
 _ Sin_Table
	RINCBIN	Main_Char/Sin_Table.bin
 _ FW_FB_Spr0
 _ FBall_3spr0
	RINCBIN	Main_Char/Fire_Ball_3spr.bin
 _ FW_FB_Spr1
 _ FBall_3spr1
	RINCBIN	Main_Char/Fire_Ball_3spr.bin
 _ Back_FB_Spr0
	RINCBIN	Main_Char/Back_FB.bin
 _ Back_FB_Spr1
	RINCBIN	Main_Char/Back_FB.bin
 _ Smart_B_Spr
	RINCBIN	Main_Char/Smart_Bomb.bin
 _ Mega_B_Spr
	RINCBIN	Main_Char/Mega_Blast.bin
 _ Time_Spr
	RINCBIN Main_Char/Time.bin
 _ Die_Table
	RINCBIN	Main_Char/Die_Table.bin
 _ Die_Dyn_Ptr
	DS.L	8



* STATUS LINE
* -----------


 _ Status_Screen_Disp
	DCB.B	76*18,$ff
	DCB.B	76,0
 _ Status_Screen
	DS.B	76*19
 _ Status_Digit
	RINCBIN	Status/Digit.bin
 _ Text_Dat
	RINCBIN	Status/Text.bin



* OBJECTS
* -------


 _ Sprites_Struct
	LINCBIN	Objects.sst
 _ Spr_Struct_End

	RSRESET		* ATTACK_WAVE_OBJ STRUCT
AWO_Alien_X	RS.W	1
AWO_Alien_Y	RS.W	1
AWO_Alien_Obj_Off	RS.W	1
AWO_Alien_Energy	RS.W	1 * if 255 unshotable
AWO_Alien_Status	RS.B	1 * bit 0-3 explo state  bit 4-7 colis. flash state
AWO_Alien_F_Rt_S	RS.B	1
AWO_Alien_F_Rt_D	RS.B	1
AWO_Futur	RS.B	1
AWO_Len	RS.B	0

AWO_size	EQU	AWO_Len*16+4

 _ AWO_Struct
	REPT    32
	DC.W	-1
	DC.W	0
	DS.B	16*AWO_Len
	ENDR

	RSRESET		* SPRITES STRUCT
;Pix_Delta_X	RS.B	1
;Pix_Delta_Y	RS.B	1
Mask_Rout_Ptr	RS.L	1
H_C_Rout_Ptr	RS.L	1
V_C_Rout_Ptr	RS.L	1
Normal_Rout_Ptr	RS.L	1
Frst_Bitplane_Ptr	RS.L	1
Mask_Bitplane_Ptr	RS.L	1

 _ C_Blit_Mask_Buff
	DS.B	8*64

 _ Blit_Routines_Ptr

                  DC.L	N_Blit0
                  DC.L	N_Blit1
                  DC.L	N_Blit2
                  DC.L	N_Blit3
                  DC.L	N_Blit4
                  DC.L	N_Blit5
                  DC.L	N_Blit6
                  DC.L	N_Blit7
                  DC.L	N_Blit8
                  DC.L	N_Blit9
                  DC.L	N_Blit10
                  DC.L	N_Blit11

 _ Mask_Blit_Rout_Ptr

                  DC.L	M_Blit0
                  DC.L	M_Blit1
                  DC.L	M_Blit2
                  DC.L	M_Blit3
                  DC.L	M_Blit0
                  DC.L	M_Blit1
                  DC.L	M_Blit2
                  DC.L	M_Blit3
                  DC.L    M_Nop
                  DC.L    M_Nop
                  DC.L    M_Nop
                  DC.L    M_Nop

 _ V_C_Blit_Rout_Ptr

                  DC.L	V_C_Blit0
                  DC.L	V_C_Blit1
                  DC.L	V_C_Blit2
                  DC.L	V_C_Blit3
                  DC.L	V_C_Blit0
                  DC.L	V_C_Blit1
                  DC.L	V_C_Blit2
                  DC.L	V_C_Blit3
                  DC.L	V_C_Blit4
                  DC.L	V_C_Blit5
                  DC.L	V_C_Blit6
                  DC.L	V_C_Blit7

 _ H_C_Blit_Rout_Ptr

                  DC.L	H_C_Blit0
                  DC.L	H_C_Blit1
                  DC.L	H_C_Blit2
                  DC.L	H_C_Blit3
                  DC.L	H_C_Blit0
                  DC.L	H_C_Blit1
                  DC.L	H_C_Blit2
                  DC.L	H_C_Blit3
                  DC.L	V_C_Blit4
                  DC.L	V_C_Blit5
                  DC.L	V_C_Blit6
                  DC.L	V_C_Blit7
 _ X44

Count	SET	0
	REPT    193
	DC.W	Count
Count             SET	Count+44
	ENDR
 _ Fwm_Conv
	DC.W	%0000000000000000
                  DC.W	%0000000000000001
	DC.W	%0000000000000011
	DC.W	%0000000000000111
	DC.W	%0000000000001111
	DC.W	%0000000000011111
	DC.W	%0000000000111111
	DC.W	%0000000001111111
	DC.W	%0000000011111111
	DC.W    %0000000111111111
	DC.W	%0000001111111111
	DC.W	%0000011111111111
	DC.W	%0000111111111111
	DC.W	%0001111111111111
	DC.W	%0011111111111111
	DC.W	%0111111111111111
	DC.W	%1111111111111111

 _ Lwm_Conv
	DC.W	%1111111111111111
                  DC.W	%1111111111111110
	DC.W	%1111111111111100
	DC.W	%1111111111111000
	DC.W	%1111111111110000
	DC.W	%1111111111100000
	DC.W	%1111111111000000
	DC.W	%1111111110000000
	DC.W	%1111111100000000
	DC.W	%1111111000000000
	DC.W	%1111110000000000
	DC.W	%1111100000000000
	DC.W	%1111000000000000
	DC.W	%1110000000000000
	DC.W	%1100000000000000
	DC.W	%1000000000000000
	DC.W	%0000000000000000



* TRACKS & GAME
* -------------



	RSRESET 	* TRACK STRUCT
TS_Awo_Ptr	RS.l	1
TS_Aws_Ptr	RS.l	1
TS_Alien_Num	RS.W	1
TS_First_Alien	RS.B    1
TS_Num	RS.B	1
TS_X_Start	RS.W	1
TS_Y_Start	RS.W	1
TS_Aliens	RS.B	0

 _ Track_Table

Count	SET     0
	REPT	16
	DC.L    Track_Struct+Count!$80000000
Count             SET	Count+144
	ENDR

	RSRESET		* ATTACK_WAVE_START STRUCT
AWS_Table_X_Off	RS.W	1
AWS_Table_Y_Off	RS.W	1
AWS_Table_Obj_Off	RS.W	1
AWS_Alien_Rate	RS.B	1
AWS_Alien_Num     RS.B	1
AWS_Alien_Energy	RS.W	1
AWS_Alien_Bad_F	RS.B	1
AWS_Alien_F_Rate	RS.B	1
AWS_Pal_Mod_Lin0	RS.B	1
AWS_Pal_Mod_Lin1	RS.B	1
AWS_Pal_Mod_Lin2	RS.B	1
AWS_Pal_Mod_Lin3	RS.B	1
AWS_Pal_Mod_Lin4	RS.B	1
AWS_Pal_Mod_Lin5	RS.B	1
AWS_Pal_Mod_Col1	RS.W	1
AWS_Pal_Mod_Col2	RS.W	1
AWS_Pal_Mod_Col3	RS.W	1
AWS_Pal_Mod_Col4	RS.W	1
AWS_Pal_Mod_Col5	RS.W	1
AWS_Pal_Mod_Col6	RS.W	1
AWS_Pal_Mod_Col7	RS.W	1
AWS_Len	RS.B	0

 _ Good_Col_List
	DCB.B	2*4*8,-1


;	IFNE	Asm_Level=1
First_Explo_Spr	EQU     0
;	ENDC

 _ Explo_Spr_List
	DC.W	0
	DC.W	First_Explo_Spr+0
	DC.W	First_Explo_Spr+0
	DC.W	First_Explo_Spr+1
	DC.W	First_Explo_Spr+1
	DC.W	First_Explo_Spr+2
	DC.W	First_Explo_Spr+2
	DC.W	First_Explo_Spr+3
	DC.W	First_Explo_Spr+3
	DC.W	First_Explo_Spr+4
	DC.W	First_Explo_Spr+4
	DC.W	First_Explo_Spr+5
	DC.W	First_Explo_Spr+5
	DC.W	First_Explo_Spr+6
	DC.W	First_Explo_Spr+7

 _ BS_Count
	DS.B    N+2
 _ BS_Offset
	DS.B	N+2
 _ BS_Order
	DS.B	N_

 _ AF_LFO
	DS.W	8


	RSRESET
Rout_Code_Ptr     RS.L	1
Rout_Param_Ptr	RS.L	1
Rout_Awo_Ptr	RS.L	1
Rout_Variables	RS.W    8
Rout_Len	RS.B	0

 _ Rout_Struct
	DCB.B	32*Rout_Len,-1



* COPPER LIST
* -----------


	INCLUDE Ag_Copper_List.s



* VARIABLE
* --------


 _ Gen_25hz_Phase
	DS.W	1
 _ Cur_Back_Build
	DS.L	1
 _ Cur_Back_Show
	DS.L	1
 _ Cur_Front_Build
	DS.L	1
 _ Cur_Front_Show
	DS.L	1
 _ Rest_Screen_Ptr
	DS.L	1
 _ Back_Phase
	DS.W    1
 _ Back_Config
	DS.W    1
 _ Pat_Ptr
	DS.L	1
 _ Pat0_Ptr_Stat
	DS.L	1
 _ Pat0_Ptr_Dyn
	DS.L	1
 _ Pat0_Dly_Count
	DS.W	1
 _ Pat0_Frm_Ptr
	DS.L	1
 _ Pat1_Ptr_Stat
	DS.L	1
 _ Pat1_Ptr_Dyn
	DS.L	1
 _ Pat1_Dly_Count
	DS.W	1
 _ Pat1_Frm_Ptr
	DS.L	1
 _ Pat2_Ptr_Stat
	DS.L	1
 _ Pat2_Ptr_Dyn
	DS.L	1
 _ Pat2_Dly_Count
	DS.W	1
 _ Pat2_Frm_Ptr
	DS.L	1
 _ Back_Shift
	DS.W	1
 _ Front_Shift
	DS.W	1
 _ Front_Shift_Phase
	DS.W	1
 _ Refresh_Frame
	DS.W	1
 _ Sky_Count
	DS.W	1
 _ Back_Old_Off
	DS.W	1
 _ Front_Phase
	DS.W	1
 _ Front_Read_Ptr
	DS.L	1
 _ Front_Pal_Ptr
	DS.L	1
 _ Front_Pal_Count
	DS.L	1
 _ Safe_Dest_Off
	DS.L	1
 _ Safe_Dest_Ptr
	DS.L	1
 _ Safe_Src_Ptr
	DS.L	1
 _ Sorcerer_X
	DS.W	1
 _ Sorcerer_Y
	DS.W	1
 _ Sorcerer_Shape
                  DS.W	1
 _ Sorcerer_Delay
	DS.W	1
 _ Axe_Up_X
	DS.W	1
 _ Axe_Up_Y
	DS.W	1
 _ Axe_Down_X
	DS.W	1
 _ Axe_Down_Y
	DS.W	1
 _ Axe_Delay
	DS.W	1
 _ Axe_Move
	DS.W	1
 _ Old_Score
                  DC.L	-1
 _ Point
	DS.L	1
 _ Spell_Time
	DC.W    $0
 _ Old_Spell_Time
                  DC.W	-1
 _ Old_Life
                  DC.W	-1
 _ Fw_Fire_X
	DS.W	1
 _ Fw_Fire_Y
	DS.W	1
 _ Fw_Fire_Step
	DS.W	1
 _ Fw_Fire_Phase
	DS.W	1
 _ Fw_Fire_Off
	DS.W	1
 _ Key
	DS.W	1
 _ Key_Up_Flag
	DS.W	1
 _ Pause
	DS.W	1
 _ Pause2
	DS.W	1
 _ Prg_Pause
	DS.W	1
 _ Stop
	DS.W	1
 _ Stop2
	DS.W	1
 _ Text_Num
                  DS.W	1
 _ Old_Text_Num
                  DS.W	1
 _ Text_Delay
	DS.W	1
 _ Refresh_Status
	DS.W	1
 _ Status_Delay
	DS.W	1
 _ Icones_Mode
	DS.W	1
 _ Fire_Count
	DS.W	1
 _ Icones_Off
	DS.W	1
 _ Arow_Y
	DS.W	1
 _ Arow_Down
	DS.W	1
 _ Arow_Up
	DS.W	1
 _ Curent_Spell
	DS.W	1
 _ Safe_Cur_Spell
	DS.W	1
 _ Icones_Fire_Up
	DS.W	1
 _ Spell_Time_Delay
	DS.W	1
 _ Rain_X_Off0
	DS.W	1
 _ Rain_X_Off1
	DS.W	1
 _ Dm_Ta
	DS.W	1
 _ Ap_Ta
	DS.L	1
 _ Mbl
	DS.W	1
 _ Bm_Ta
	DS.W	1
 _ S_Ts
	DS.W	1
 _ Curent_AWO_Ptr
	DS.L	1
 _ Alien_AWO_Count
	DS.W	1
 _ Curent_Alien_Num
 	DS.W	1
 _ Curent_Bank_Ptr
	DS.L	1
 _ Start_List_Ptr
	DS.L	1
 _ Level_X
	DS.W	1
 _ Sl_Waiting
	DS.W	1
 _ Refresh_Pal
	DS.W	1
 _ Vdo_S_Inc
	DS.W	1
 _ Flash_Phase
	DS.W	1
 _ Cur_Explo_State
	DS.W	1
 _ Af_Anim_Count
	DS.W	1
 _ Old_Vpos
	DS.W	1
 _ Short_Phase
	DS.W	1
 _ Rain_On
	DS.W	1
 _ Rot_Step
	DS.W	1
 _ Back_FB_X0
	DS.W	1
 _ Back_FB_X1
	DC.W    -100
 _ Fw_FB_X0
	DS.W	1
 _ Fw_FB_X1
	DC.W    128
 _ Sorcerer2_X
	DS.W	1
 _ Sorcerer2_Y
	DS.W	1
 _ Sorcerer2_Shape
	DS.W	1
 _ Sorcerer_On
	DS.W	1
 _ Smart_B_X
	DS.W	1
 _ Smart_B_Step
	DS.W	1
 _ Smart_B_StepH
	DS.W	1
 _ Smart_B_StepHC
	DS.W	1
 _ Mega_B_X
	DS.W	1
 _ Time_Step
	DS.W	1
 _ Time_Y
	DS.W	1
 _ Die
	DS.W	1
 _ Die_Mode
	DS.W	1
 _ Die_X
	DS.W	1
 _ Die_Y
	DS.W	1
 _ Rout_Pal_Ptr
	DC.L	-1
 _ Rout_Mod_Pal_Counter
	DS.W	1
 _ Bonus_Anim
	DS.W	1
 _ Bonus_Mode
	DS.W	1
 _ Bonus_Delay
	DS.W	1
 _ Bonus_X
	DS.W	1
 _ Bonus_Y
	DS.W	1
 _ Bonus_Num
	DS.W	1
 _ Spr0ptB
	DS.L	1
 _ Spr1ptB
	DS.L	1
 _ Spr2ptB
	DS.L	1
 _ Spr3ptB
	DS.L	1
 _ Spr4ptB
	DS.L	1
 _ Spr5ptB
	DS.L	1
 _ Spr6ptB
	DS.L	1
 _ Spr7ptB
	DS.L	1
 _ Sound0
	DC.W    -1
 _ Sound0_b
	DC.W	-1
 _ Sound0_Req
	DS.W	1
 _ Sound0_Vol
	DS.W	1
 _ Sound0_Vol_Req
	DS.W	1
 _ Sound0_Int_Step
	DS.W    1
 _ Sound0_Last_Pri
	DS.W 	1
 _ Quit_Delay
	DS.W	1
 _ AF_Off
	DS.W	1
 _ Selection_On
	DS.W	1
 _ R_F_AWO_Ptr1
	DS.L	1
 _ R_F_AWO_Ptr2
	DS.L	1
 _ R_F_AWO_Ptr3
	DS.L	1
 _ Begin_To_Start
	DS.W	1
 _ BTS_Delay
	DS.W	1
 _ Clean_Up
	DS.W	1
 _ Mus_Ntsc_Skip
	DS.W	1





***************************************************************************

*	P R O G R A M M   B U F F E R

***************************************************************************



* SCREEN
* ------


	RSRESET
Front_Screen0	RS.B	44*192*3
Front_Screen1	RS.B	44*192*3
Front_Rest_Scr	RS.B	44*192*3

Clear_Start
	IFNE	ASM_Absolute=0
Front_Screens
	DS.B	40*31*3
	DS.B	44*192*3*3
Front_Screens_E

Back_Screen0
	DS.B	40*192*2
Sky_Screen0
	DS.B	40*192
Back_Screen1
	DS.B	40*192*2
Sky_Screen1
	DS.B	40*192
Clear_End
	ELSEIF
Front_Screens
Front_Screens_E	EQU	Front_Screens+(40*31*3)+(44*192*9)
Back_Screen0	EQU     Front_Screens_E
Sky_Screen0	EQU	Front_Screens_E+(40*192*2)
Back_Screen1	EQU	Sky_Screen0+(40*192)
Sky_Screen1	EQU	Back_Screen1+(40*192*2)
Clear_End	EQU	Sky_Screen1+40*192
	ENDC





***************************************************************************



	END


