
***************************************************************************
*                                                                         *
*                                                                         *
*				            *
*	      A R N Y ' S   D R E A M S	            *
*                      ===========================	            *
*                                                                         *
*                                                                         *
*                                                                         *
*                              DATA MODULE                                *
*                              -----------                                *
*                                                                         *
*                                                                         *
***************************************************************************

*	D A T A   M A C R O   D E F I N I T I O N

***************************************************************************



* INCLUDE PATH MACRO
* ------------------


DINCBIN	MACRO
	INCBIN	WORK:Arny's_Dreams/Data/\1
	ENDM

GINCBIN	MACRO
	INCBIN	WORK:Arny's_Dreams/Graph/\1
	ENDM






***************************************************************************

*	P R O G R A M M   A B S O L U T E   D A T A

***************************************************************************



* Copper List
* -----------


	H_COPPER_LIST



* World data
* ----------


	RSRESET		* Level Data Header
LD_Arny_X	RS.W	1
LD_Arny_y	RS.W	1
LD_Ball_x	RS.W	1
LD_Ball_Y	RS.W	1
LD_Exit_X	RS.W	1
LD_Exit_Y	RS.W	1
LD_Level_Time	RS.W	1
LD_Monsters_Off	RS.W	1
LD_Gadgets_Off	RS.W	1
LD_Objects_Off	RS.W	1
LD_Char_Num	RS.W	1
LD_Map_Off	RS.W	1

World_Dat
	DINCBIN World0.wld
Char_Image
	GINCBIN	World0_Base.raw
	GINCBIN	World0_Shape.raw
Baground_Image
                  DINCBIN	World0_Baground.bin
World_Pal0
	GINCBIN	World0.pal
Common_Pal
	GINCBIN	Common.pal



* Object
* ------


Obj_Image
                  DINCBIN	Obj.Bin

Ball_Size	EQU	4*(2*2*32+4+4)
Spr_Size          EQU     4*(2*2*32)
First_Bob         EQU	1	* first bob in Obj_Image
Bob_Image	EQU	Obj_Image+(First_Bob-1)*Spr_Size+Ball_Size






***************************************************************************

*	P R O G R A M M   R E L A T I V E   D A T A

***************************************************************************



Rel_Start



* Status Screen
* -------------


;	DINCBIN	Status.pal
count	set	0
	REPT    16
	DC.L	count
count	set	count+$01110111
	ENDR



* Objects
* -------


	RSRESET
Obj_X	RS.W	1
Obj_Y	RS.W	1
Obj_Id	RS.W	1
Obj_Ptr	RS.L	1	* only use for blitter bitmap restore
Obj_Safe_Buffer	RS.B	5*(32*6)
Obj_Sizeof	RS.B	0

Obj_Num	EQU     16

* Object attibution :
*
* 0 Arny (bob)
* 1 Ball (Spr)
* 2 Arny Weapon (bob)
* 3 Monster Weapon (bob)
* 4->15 Monster (spr)

 _ Obj_Struct
	DCB.B	Obj_Sizeof*Obj_Num

 _ Obj_Id_2_Off

Count	SET	0
	REPT    64
	DC.W	Count
Count             SET	Count+4*32*5
	ENDR



* Table
* -----


 _ C_Id_2_Off_Table
	DINCBIN	C_Id_2_Off.bin



* Back Colors
* -----------

 _ CL_Deg0
	DC.W	$f8e
	DC.W	$e8e
	DC.W	$d8e
	DC.W	$c8e
	DC.W	$b8e
	DC.W	$a8e
	DC.W	$98e
	DC.W	$88e
	DC.W	$78e
	DC.W	$68e
	DC.W	$58e
	DC.W	$48e
	DC.W	$38e
	DC.W	$28e
	DC.W	$18e
	DC.W	$08e
 _ CL_Deg1
	DC.W	$f28
	DC.W	$e28
	DC.W	$d28
	DC.W	$c28
	DC.W	$b28
	DC.W	$a28
	DC.W	$928
	DC.W	$828
	DC.W	$728
	DC.W	$628
	DC.W	$528
	DC.W	$428
	DC.W	$328
	DC.W	$228
	DC.W	$128
	DC.W	$028



* Variables
* ---------


 _ Camera_X
	DS.W	1
 _ Camera_Y
	DS.W	1
 _ Camera_Mode
	DS.W	1
 _ Camera_Dest_X
	DS.W	1
 _ Camera_Dest_Y
	DS.W	1
 _ Curent_Level
	DS.W	1
 _ Level_Data_Ptr
	DS.L	1
 _ Arny_X
	DS.W	1
 _ Arny_y
	DS.W	1
 _ Arny_Speed_X
	DS.W	1
 _ Arny_Speed_Y
	DS.W	1
 _ Flying_Mode
	DS.W	1
 _ Ball_x
	DS.W	1
 _ Ball_Y
	DS.W	1
 _ Exit_X
	DS.W	1
 _ Exit_Y
	DS.W	1
 _ Level_Time
	DS.W	1
 _ Joy_Up
	DS.W	1
 _ Joy_Right
	DS.W	1
 _ Joy_Down
	DS.W	1
 _ Joy_Left
	DS.W	1
 _ Joy_Fire
	DS.W	1
 _ Jump_Step
	DS.W	1






***************************************************************************

*                 B U F F E R S

***************************************************************************


	IFNE	Asm_Absolute=0

	SECTION	Buffer,BSS_C


Status_Bitmap
	DS.B	40*21*5
Char_Mask
	DS.B	4*32
Game_Bitmap
	DS.B	64*512*5
Game_Bitmap_Mask
	DS.B	64*512
Game_Base_Mask
	DS.B	64*512


	ENDC



