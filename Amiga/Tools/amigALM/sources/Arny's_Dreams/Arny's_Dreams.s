
***************************************************************************
*                                                                         *
*                                                                         *
*				            *
*	      A R N Y ' S   D R E A M S	            *
*                      ===========================	            *
*                                                                         *
*                                                                         *
*                                                                         *
*                            MAIN  MODULE                                 *
*                            ------------                                 *
*                                                                         *
*                                                                         *
***************************************************************************

* By Yves Grolet

* Date 20/6/1992

***************************************************************************


	OPT	O+,C-,W-,O3-

Asm_Absolute	SET	0	* 0 Developement 1 Absolute (ORG)

	IFNE	Asm_Absolute=0
	SECTION	Main,CODE_C
	OPT	D+
	ELSEIF
	ORG	$400
	ENDC

C	EQUR	a6	* Ptr on hardware custom registers
D	EQUR	a5                  * Ptr on base of relative data

	INCLUDE	WORK:Global/Preset.s

	INCDIR	WORK:Arny's_Dreams/


***************************************************************************


	SYSTEM_OFF	* Turn off system int, dma, ...

	INCLUDE	AD_Hardware.s

                  lea	Custom,C	* ! reserve a6
	lea	Rel_Start+32768,D	* ! reserve a5

	INCLUDE	AD_Game_Init.s

	INCLUDE	AD_Game_Loop.s

	INCLUDE	AD_Game_Sub.s


	INCLUDE	AD_Data.s

	END








