





***************************************************************************
*                                                                         *
*                                                                         *
*				            *
*	      S P E L L   S I N G E R	            *
*                      =========================	            *
*                                                                         *
*                                                                         *
*                                                                         *
*                            MAIN  MODULE                                 *
*                            ------------                                 *
*                                                                         *
*                                                                         *
***************************************************************************


* by ART & MAGIC


* Coding:	Yves Grolet
* Date:	25/12/1991
* Tab:            custom






***************************************************************************



	OPT	o+,c-,w-,o3-

Debug	SET	1	* if 1 debuging version
Asm_Absolute	SET	0	* 0 none  1 $400 (look at $f0000)

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

	INCLUDE	WORK:Global/Preset.s

	INCDIR	WORK:SpellSinger/







***************************************************************************



	INCLUDE	Spell_Init.s



Main_Loop



* WAIT VERTICAL SYNCHRO
* ---------------------


Wait_Synch_Loop
                  cmp	#2,Gen_25hz_Phase(D)
	blt	Wait_Synch_Loop
                  btst	#0,Vpos+1(C)	* wait for vbl >= 256
	beq     Wait_Synch_Loop

	clr	Gen_25hz_Phase(D)



* SCROLLING
* ---------


	BORDER	$000

	INCLUDE	Spell_Back_Scroll.s



	bra	Main_Loop





	INCLUDE	Spell_Interuption.s

	INCLUDE	Spell_Data.s



	END








