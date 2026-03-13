
***************************************************************************
*                                                                         *
*                                                                         *
*				            *
*	      S P E L L   S I N G E R	            *
*                      =========================	            *
*                                                                         *
*                                                                         *
*                                                                         *
*                           Initialisation                                *
*                           --------------                                *
*                                                                         *
*                                                                         *
***************************************************************************


* by ART & MAGIC


* Coding:	Yves Grolet
* Date:	25/12/1991
* Tab:            custom






***************************************************************************



	IFNE	Asm_Absolute=0
	SYSTEM_OFF
	ENDC



* INITIALISE VIDEO
* ----------------


                  lea	Custom,C
	lea	Rel_Start+32768,D

	move	#$7fff,d0
	move	d0,Intena(C)
	move	d0,Intreq(C)
	move	d0,Dmacon(C)

	move.l	#Dummy_Cl,Cop1lc(C)
	move	d0,Copjmp1(C)

	move	#$2000,sr

	move.l	#$409000b0,Diwstrt(C)
	move.l	#$003800c8,Ddfstrt(C)

	clr.l	Bpl1mod(C)
	move.l	#%01100110000000000000000000000000,Bplcon0(C)

                  move.l	#$00000fff,Color+16(C)
                  move.l	#$0eee0222,Color+20(C)
                  move.l	#$03330444,Color+24(C)
                  move.l	#$05550888,Color+28(C)
	clr	Color(C)

	move.l	#Scr_0,d0
	lea     Cl_Bplpt0+2,a0	* Front screen bpl ptr
	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	add.l	#38*192,d0
	move	d0,12(a0)
	swap	d0
	move	d0,8(a0)
	swap	d0
	add.l	#38*192,d0
	move	d0,20(a0)
	swap	d0
	move	d0,16(a0)

	move.l	#Scr_A,d0
	lea     Cl_Bplpt1+2,a0	* Back screen bpl ptr
	move	d0,4(a0)
	swap	d0
	move	d0,(a0)
	swap	d0
	add.l	#38*192,d0
	move	d0,12(a0)
	swap	d0
	move	d0,8(a0)
	swap	d0
	add.l	#38*192,d0
	move	d0,20(a0)
	swap	d0
	move	d0,16(a0)



* VARIABLES INIT
* --------------


	clr	Stage_2_Step(D)
                  move.l	#Scr_B0,Scr_B_Used(D)
                  move.l	#Scr_B1,Scr_B_Build(D)
	clr	Stage_3_Step(D)
                  move.l	#Scr_C0,Scr_C_Used(D)
                  move.l	#Scr_C1,Scr_C_Build(D)

	move	#0,Pos_X(D)
	move	#0,Pos_Y(D)
	st	Initial_Build(D)



* LET'S GO
* --------


                  WAIT_SYNCH

	move.l	#Main_Cl,Cop1lc(C)
	move	d0,Copjmp1(C)

	move.l	#Int3,$6c

	IFNE	ASM_ABSOLUTE=1
	move	#%1100000000010000,Intena(C)
	ELSEIF
	move	#%1110000000010000,Intena(C)
	ENDC
                  move	#%1000011111000000,Dmacon(C)







