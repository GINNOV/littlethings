start	;This is the Pointer to the first level
	
	dc.b	"LEVEL 001",0	;10 bytes
	incbin	YOB:LEV/rew1.lvl

	;now we have the list of options for that baddy!
	
	dc.b	"BADDY01",0		;8 bytes	
	dc.b	bad_name+0,"J"
	dc.b	bad_name+1,"o"
	dc.b	bad_name+2,"h"
	dc.b	bad_name+3,"n"
	dc.b	bad_speed,1
	dc.b	bad_cango,BOBF_LEFT|BOBF_RIGHT
	dc.b	bad_go,BOBF_RIGHT
	dc.b	bad_power,1	;whats i hit for *
	dc.b	bad_hp,3	;whats my hp *
	dc.b	bad_ability,BOBF_PLAT|BOBF_FALL
	dc.b	bad_look,LOOKF_MARIO
	dc.b	bad_mar_max,4
	dc.b	bad_fal_max,40
	dc.b	bad_platx,16
	dc.b	bad_randg,200
	dc.b	bad_gfxnum,3
	dc.b	0,0
		
	even

	dc.b	"BADDY02",0		;8 bytes	
	dc.b	bad_name+0,"T"
	dc.b	bad_name+1,"h"
	dc.b	bad_name+2,"u"
	dc.b	bad_name+3,"g"
	dc.b	bad_cango,BOBF_DOWN|BOBF_LEFT|BOBF_RIGHT	
	dc.b	bad_go,BOBF_LEFT	
	dc.b	bad_speed,1
	dc.b	bad_power,1	;whats i hit for *
	dc.b	bad_hp,3
	dc.b	bad_gun,WeapSmart
	dc.b	bad_ability,BOBF_PLAT|BOBF_FALL|BOBF_GUN2
	dc.b	bad_look,LOOKF_MARIO
	dc.b	bad_mar_max,4
	dc.b	bad_platx,16
	dc.b	bad_gfxnum,2
	dc.b	bad_gungfk,0
	dc.b	bad_gungfk+1,0
	dc.b	bad_power,1	;whats i hit for *

	dc.b	0,0		;zero terminate list
	even


	;for a normal weapon. set the cango l/r to decide which way to shoot
	;baddyies that jump up n down and shoot right
	dc.b	"BADDY03",0		;8 bytes	
	dc.b	bad_name+0,"H"
	dc.b	bad_name+1,"o"
	dc.b	bad_name+2,"p"
	dc.b	bad_name+3,"R"
	dc.b	bad_cango,BOBF_UP|BOBF_DOWN|BOBF_RIGHT
	dc.b	bad_gun,WeapNorm
	dc.b	bad_ability,BOBF_PLAT|BOBF_FALL|BOBF_GUN2|BOBF_JUMP
	dc.b	bad_randg,150
	dc.b	bad_rand2,140
	dc.b	bad_hp,3
	dc.b	bad_gfxnum,1
	dc.b	bad_gungfk,0
	dc.b	bad_gungfk+1,24
	dc.b	bad_an_off,0	;set his gfk right
	dc.b	bad_power,1	;whats i hit for *
	dc.b	0,0		;zero terminate list
	
	even
	dc.b	"BADDY04",0		;8 bytes	
	;baddyies that jump up n down and shoot left
	dc.b	bad_name+0,"H"
	dc.b	bad_name+1,"o"
	dc.b	bad_name+2,"p"
	dc.b	bad_name+3,"L"
	dc.b	bad_cango,BOBF_UP|BOBF_DOWN|BOBF_LEFT
	dc.b	bad_gun,WeapNorm
	dc.b	bad_ability,BOBF_PLAT|BOBF_FALL|BOBF_GUN2|BOBF_JUMP
	dc.b	bad_randg,150
	dc.b	bad_rand2,140
	dc.b	bad_hp,3
	dc.b	bad_gfxnum,1
	dc.b	bad_gungfk,0
	dc.b	bad_gungfk+1,24
	dc.b	bad_an_off,9	;set his gfk left
	dc.b	bad_power,1	;whats i hit for *

	dc.b	0,0		;zero terminate list
	even
	dc.b	"BADDY05",0		;8 bytes	
	;Lazer Cannon shoot right
	dc.b	bad_name+0,"L"
	dc.b	bad_name+1,"a"
	dc.b	bad_name+2,"z"
	dc.b	bad_name+3,"R"
	dc.b	bad_cango,BOBF_UP|BOBF_DOWN|BOBF_RIGHT
	dc.b	bad_gun,WeapLazer
	dc.b	bad_ability,BOBF_PLAT|BOBF_FALL|BOBF_GUN2
	dc.b	bad_randg,250
	dc.b	bad_rand2,140
	dc.b	bad_hp,20
	dc.b	bad_gfxnum,4
	dc.b	bad_gungfk,0
	dc.b	bad_gungfk+1,48
	dc.b	bad_an_off,0	;set his gfk right
	dc.b	bad_power,0	;whats i hit for *
	dc.b	0,0		;zero terminate list
	
	even
	dc.b	"BADDY06",0		;8 bytes	
	;Lazer Cannon shoot left
	dc.b	bad_name+0,"L"
	dc.b	bad_name+1,"a"
	dc.b	bad_name+2,"z"
	dc.b	bad_name+3,"L"
	dc.b	bad_cango,BOBF_UP|BOBF_DOWN|BOBF_LEFT
	dc.b	bad_gun,WeapLazer
	dc.b	bad_ability,BOBF_PLAT|BOBF_FALL|BOBF_GUN2
	dc.b	bad_randg,250
	dc.b	bad_rand2,140
	dc.b	bad_hp,20
	dc.b	bad_gfxnum,4
	dc.b	bad_gungfk,0
	dc.b	bad_gungfk+1,48
	dc.b	bad_an_off,9	;set his gfk left
	dc.b	bad_power,0	;whats i hit for *

	dc.b	0,0		;zero terminate list
	even

	

	dc.b	0,0,0,0,0,0,0,0
	


stop	


	;bit defs:-
	;the no. at the end is the actual bit effected 0-15
	;to use:
	;	BOBB_UP	3 = %0011  bset   BOBB_UP,d0
	;	BOBF_UP	8 = %1000  move.w BOBF_UP,d0
	
	BITDEF	BOB,UP,3
	BITDEF	BOB,DOWN,2
	BITDEF	BOB,LEFT,1
	BITDEF	BOB,RIGHT,0
	
	BITDEF	BOB,GUN1,0	;intelligent fire
	BITDEF	BOB,JUMP,1
	BITDEF	BOB,DEAD,2
	BITDEF	BOB,FALL,3
	BITDEF	BOB,GUN2,4	;rand fire
	BITDEF	BOB,PLAT,7
	
	BITDEF	LOOK,MARIO,2
	
	BITDEF	ATTR,SEEKX,0	;seek in x
	BITDEF	ATTR,SEEKY,1	;seek in y
	BITDEF	ATTR,EDGE,2		;bounces on edge of scr
	BITDEF	ATTR,BFORM,3	;bounces off pform
	BITDEF	ATTR,HFORM,4	;hugs pform
	BITDEF	ATTR,AGRAV,5	;fall to gravity ALWAYS
	BITDEF	ATTR,GRAV,6		;fall to gravity when out of energy

	;kill bullet when	
	BITDEF	KBUL,BOTTOM,0	;bottom of screen
	BITDEF	KBUL,EDGE,1		;edges of screen
	BITDEF	KBUL,PFORM,2	;platform of screen
	
	
	

WeapSmart	equ	1
WeapNorm	equ	2
WeapLazer	equ	3


;SPARE BITS in look & doing
 
;animation
;first byte is how many frames for direction
;then follows the frame no.s (upto 8 different frames)

bad_name	equ	0	;whats you name
bad_x	equ	4	;xpos
bad_y	equ	6	;ypos
bad_actual	equ	8	;coarse
bad_smooth	equ	12	;smooth
bad_anim	equ	14	;what char am I?
bad_speed	equ	15	;speed
bad_cango	equ	16	;what dirs am i alowed
bad_go	equ	17	;what dir(s) am i going
bad_gun	equ	18	;what is my weapon
bad_power	equ	19	;what I hit for
bad_hp	equ	20	;what my hit pts
bad_ability	equ	21	;what can i do
bad_look	equ	22	;what i see
bad_mapx	equ	23	;players mapx pos
bad_mapy	equ	24	;players mapy pos
bad_an_rcnt	equ	25	;how many frames for right
bad_an_rfrm	equ	26	;anim frames for right
bad_an_lcnt	equ	34	;how many frames for left
bad_an_lfrm	equ	35	;anim frames for left
bad_an_ucnt	equ	43	;how many frames for up
bad_an_ufrm	equ	44	;anim frames for up
bad_an_dcnt	equ	52	;how many frames for down
bad_an_dfrm	equ	53	;anim frames for down
bad_an_off	equ	61	;anim offset to suss dir anims
bad_mar	equ	62	;what pos in mario movement pos thing
bad_mar_max	equ	63	;what the max pos in mario movement
bad_doing	equ	64	;what am i doing
bad_fal	equ	65	;falling counter
bad_fal_max	equ	66	;falling maximum
bad_randg	equ	67	;do summink on this no.
bad_act_was	equ	68	;bad actual pos
bad_jmp_pos	equ	72	;jumping pos
bad_platx	equ	73	;platform pos
bad_status	equ	74	;status: alive dead or what!
bad_gfxnum	equ	75	;what bank of gfx are we using (0-256)
bad_gungfk	equ	76	;baddy gun gfk (R) > < > <
bad_rand2	equ	77	;do summink on this no. OTHER
