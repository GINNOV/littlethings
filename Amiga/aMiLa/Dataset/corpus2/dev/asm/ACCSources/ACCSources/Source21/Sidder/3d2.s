
; Sidder sent me this code, but forgot to send his CustomRegisters include
;file which must contain a few macros for building Copper lists. Also, all
;hardware registers must be defined as actual addresses as apposed to offsets
;from $dff000. I have converted the file to work with hardware.i, but for
;some reason I had to set the screen modulos to -1 in the Copper list. This
;may just be another quirk of my v2.0 machine, so if the graphics appear
;skewed on yous set the modulo to 0 and try again. To save you having to
;search for the Copper list, use the following equate:

ScrnMod		equ		-1		; change to 0 if skewed

; Hope this helps. Mark....

;
; Program Name : 3d2.s
; Coded by     : SIDDER
; Date         : 2-Nov-91
;
; All this code has been converted from some turbo pascal code
; that I had on the PC, that code used floating point though.
; Watching lines rotate on the PC looked very slow and flickered
; so I decided to write it on my Amiga. Use and abuse the following 
; routines. I have documented most of it - if you understands a little
; math it should be easy to follow - SIDDER.
;
; I Know the code is very messy but I have tries to break it down
; into subroutines as to try and show hoe it has been done
;
; I will work on perspective and other transformations 
; and also speed-up these slow routines.
;
; Credits : 
;		All Graphics by POG
;		Music ripped
;		Mark Meany - Sine table
;		copperlist and double -
;		- buffering of screens : Masterbeat
;		
;		Everybody who writes/uses the ACC disks -
;		- keep up the good work boys and girls !!
;
; I few notes on the code - Try changing the following things
;	- start numbers of degreex,degreey,degreez
;       - Also the degree skip values
;	- comment out the x,y,z rotation in the Main_3D routine
;	  this enable rotation around only 1 or 2 axis
;
;
; If you want to contact me my address is :-  Jonathan Sidebotham
;					      34 Hall Street,
;					      New Mills,
;					      Stockport,
;					      Cheshire,
;					      SK12 3BR.
;					TEL : 0663 744812
;					WORK: 061-491-2222
;
; Raistlin I know you only live ten minutes away - we
; must go for a pint some day !!!
;
;
;	Incdir	include2.0:include/     ; cant live without
					; the hard disc !!
	Include Source:Include/hardware.i
	
	Section	3d,Code_c	; force chip RAM

Ciaapra = $BFE001
Openlibrary = -30-522	
Disable	    = -120
Enable	    = -126
Startlist   = 38
Execbase = 4

	Move.l	Execbase,a6
	Jsr	Disable(a6)	; go away multi-tasking
	
	jsr	init3dsys	; initialize 3d system
	jsr	mt_init		; hello song
	
	move.w	#90,degreez	; z-axis
	move.w	#45,degreey	; y-axis 
	move.w	#0,degreex	; x-axis
		
	move.w	#$f00,logocol	; red for logo
	move.w	#$0f0,vucol	; green for rotate
	move.w	#0,backcol	; black for background

	move.l	#logo,d0	; Get address of our screen memory.
	move.w	d0,pl2l		; Move the low word into copper list.
	swap	d0		; Swap the low and high words in d0.
	move.w	d0,pl2h		; Move the high word into the copper
				; list.

	Move.l	#Clstart,$dff000+COP1LCH ; Move address of our copper list
				; into the copper
	Clr	$dff000+COPJMP1		; strobe the copper

	Move.w	#$8780,$dff000+DMACON	; get the DMA we want
	Move.w	#$0020,$dff000+DMACON	; dont want sprites today
	Lea	$dff000+SPR0DATA,a0	; address of sprite data
	Moveq	#7,d0
Clop
	Clr.l	(a0)		; no crap sprite data please -
	Addq.l	#8,a0
	Dbf	d0,Clop		; from any sprite !!

Wait:	Move.l	$dff004,d2	; no flicker thanx
	And.l	#$0001ff00,d2	
	Cmp.l	#$00000100,d2
	Bne.s	Wait

	jsr	Main_3D		; main 3d routine
	
	jsr	mt_music	; Are my routines that slow ????
	jsr	mt_music
	jsr	mt_music
			
	Btst	#6,Ciaapra	; LMB ?
	Bne	Wait

	jsr	mt_end		; bye bye song

	Move.l	Execbase,a6	; come back OS
	Move.l	#Grname,a1
	Clr.l	d0
	Jsr	Openlibrary(a6)
	Move.l	d0,a4
	Move.l	Startlist(a4),$dff000+COP1LCH
	Clr.w	$dff000+COPJMP1
	Move.w	#$83E0,$dff000+DMACON
	Jsr	Enable(a6)
	Clr.l	d0
	Rts
;
; Main 3D graphics loop
;
Main_3D:
	Move.l	Current(pc),d0		; show current screen
	Move	d0,Screen+2		; load into copper
	Swap	d0
	Move	d0,Screen+6
	Eor.l	#$3000,Current		; address of our hidden screen
	Move.l	Current(pc),a0	
	Move.l	#$1f00000,$dff000+BLTCON0	; A=D, clear out our new
					; - screen only
	Move.l	a0,$dff000+BLTDPTH
	Clr	$dff000+BLTADAT		; what to clear it with - 0's
	Clr	$dff000+BLTDMOD		; no destination modulo
	Move	#256*64+20,$dff000+BLTSIZE	; full screen blit

	jsr	draw_3d			; draw the 3d - this is drawn
					; in the hidden screen and
					; then blitted to the current
					; screen (above)
	
	move.w	#2,d0			; rotate Z
	move.w	degreez,d1		; get degree value
	add.w	#6,d1			; add degrees
	cmp.w	#360,d1			; is it 360 degrees
	ble	.ok
	move.w	#6,degreez
	move.w	degreez,d1
.ok	move.w	d1,degreez		; save new degree value
	jsr	rotate3			; form rotation matrix
	move.b	#1,rotated		; set the rotated flag
	
	move.b	#1,changetoy		; ROTATE AROUND Y-AXIS
	move.b	#0,changetoz		; flags needed to stop
					; - some nasty errors
	move.w	#1,d0
	move.w	degreey,d1
	add.w	#2,d1			; degree step
	cmp	#360,d1			; full rotation yet ?
	ble	.ok1			; no
	move.w	#2,degreey		; yes - restart
	move.w	degreey,d1
.ok1	move.w	d1,degreey
	jsr	rotate3			; perform the rotation matrix
					; and multiply with the current
	
	move.b	#0,changetoy		; ROTATE AROUND X-AXIS
	move.b	#1,changetox
	move.w	#0,d0
	move.w	degreex,d1
	add.w	#8,d1			; degree step
	cmp.w	#360,d1			; full rotation ?
	ble	.ok2
	move.w	#8,degreex
	move.w	degreex,d1	
.ok2	move.w	d1,degreex
	jsr	rotate3			; perform the rotation matrix
	
	move.b	#1,changetoz		; its the flags again
	move.b	#0,changetox
	rts
;
;
; Blitter draw line routine - nothing special here !!
;
; Taken from the Amiga system programmers guide - good book
; - but I prefer the official hardware reference manual
;
DrawLine:
	move.l	Current(pc),a0		; address of screen for blitter
	move.w	#40,a1			; width of screen in bytes
	move.w	#$ffff,a2		; pattern (solid line)
	
	move.l	a1,d4
	mulu	d1,d4
	moveq	#-$10,d5
	and.w	d0,d5
	lsr.w	#3,d5
	add.w	d5,d4
	add.l	a0,d4
	
	clr.l	d5
	sub.w	d1,d3
	roxl.b	#1,d5
	tst.w	d3
	bge.s	.y2gy1
	neg.w	d3
.y2gy1:
	sub.w	d0,d2
	roxl.b	#1,d5
	tst.w	d2
	bge.s	.x2gx1
	neg.w	d2
.x2gx1:
	move.w	d3,d1
	sub.w	d2,d1
	bge.s	.dygdx
	exg	d2,d3
.dygdx:
	roxl.b	#1,d5
	move.b	Octant_table(pc,d5),d5
	add.w	d2,d2
.WBlit:
	btst	#14,$dff000+DMACONR
	bne.s	.WBlit
	
	move.w	d2,$dff000+BLTBMOD
	sub.w	d3,d2
	bge.s	.signn1
	or.b	#$40,d5
.signn1:
	move.w	d2,$dff000+BLTAPTL
	sub.w	d3,d2
	move.w	d2,$dff000+BLTAMOD
	
	move.w	#$8000,$dff000+BLTADAT
	move.w	a2,$dff000+BLTBDAT
	move.w	#$ffff,$dff000+BLTAFWM
	and.w	#$000f,d0
	ror.w	#4,d0
	or.w	#$0bca,d0
	move.w	d0,$dff000+BLTCON0
	move.w	d5,$dff000+BLTCON1
	move.l	d4,$dff000+BLTCPTH
	move.l	d4,$dff000+BLTDPTH
	move.w	a1,$dff000+BLTCMOD
	move.w	a1,$dff000+BLTDMOD
	
	lsl.w	#6,d3
	addq.w	#2,d3
	move.w	d3,$dff000+BLTSIZE
	rts


Octant_table
	Dc.b	1,17,9,21,5,25,13,29

Grname:	Dc.b	"graphics.library",0

logo:	incbin  majorsid.raw         ;mblogo8
	Even

;----------- Variables ------------

Current	Dc.l	$70000		; address of bitplane

;
; Copperlist
;
Clstart:
;	dc.w		$Wait	0,20
	dc.w		$1401,$fffe
	dc.w		DIWSTRT,$2f81		Mov	$2f81,Diwstrt
	dc.w		DIWSTOP,$f4c1		Mov	$f4c1,Diwstop
	dc.w		DDFSTRT,$0038		Mov	$0038,Ddfstrt
	dc.w		DIWSTOP,$00d0		Mov	$00d0,Diwstop    ;Diwstop
Screen
	dc.w		BPL1PTL,0		Mov	0,Bpl1ptl
	dc.w		BPL1PTH,7		Mov	7,Bpl1pth
	dc.w		BPLCON0,$2400		Mov	%0010010000000000,Bplcon0

; For some reason I had to set the following screen modulos to -1 for the
;graphics to appear correctly on my version 2 machine. If this corrupts on
;your machine, set these modulos back to 0, both of 'em. MM

	dc.w		BPL1MOD,ScrnMod		Mov	0,Bpl1mod
	dc.w		BPL2MOD,ScrnMod		for v2.0 machines
	
	dc.w	$180
backcol dc.w	$000	
	dc.w	$182
vucol	dc.w	$fff
	dc.w	$192
logocol	dc.w	$007
	dc.w	BPL2PTH		; Bitplane high word.
pl2h:
	dc.w 0

	dc.w BPL2PTL		; Bitplane low word.
pl2l:
	dc.w 0

	dc.w	$df09,$fffe
	dc.w	$100,$1200
	dc.w	$ffff,$fffe	end of copper list
	
;	Wait	224,255
;	Wait	$fe,$ff		; end of copperlist
;
;
;********************************************************************
; THE START OF MY 3-D ROUTINES - They use matrices to calculate
;				 new angles.
;
;**********************************************************************
; 
; xfrm3p subroutine - 
; 
; multiplies x_coord,y_coord,z_coord,w_coord with the current 
; transformation matrix and stores the results in xt,yt,zt,wt
;
get_xyz: 
        move.l  x_coord,d0          	; get the current x coord 
        move.l  y_coord,d1 		; get the current y coord
        move.l  z_coord,d2 		; get the current z coord
        move.l  w_coord,d3 		; get w coord (always 1)
        rts 
add_up:
	clr.l	d4			; clear add up register 
        add.l   d0,d4			; add each position
        add.l   d1,d4 
        add.l   d2,d4 
        add.l   d3,d4 
        rts 
xfrm3p:
	jsr	savecurnt		; save old coord2 values
					; as these are the start of
					; the next line
					 
        jsr     get_xyz 		; get the line data
        muls    t3curnt,d0 		; get matrix info
        muls    t3curnt+8,d1 		; multiply matrix columns
        muls    t3curnt+16,d2 
        muls    t3curnt+24,d3 
        jsr     add_up 			; add them all together
        move.l  d4,xt_coord2         	; transformed X coord 
        jsr     get_xyz 
        muls    t3curnt+2,d0 
        muls    t3curnt+10,d1 
        muls    t3curnt+18,d2 
        muls    t3curnt+26,d3 
        jsr     add_up 
        move.l  d4,yt_coord2         	; transformed Y coord 
        jsr     get_xyz 
        muls    t3curnt+4,d0 
        muls    t3curnt+12,d1 
        muls    t3curnt+20,d2 
        muls    t3curnt+28,d3 
        jsr     add_up 
        move.l  d4,zt_coord2         	; transformed Z coord 
        jsr     get_xyz 
        muls    t3curnt+6,d0 
        muls    t3curnt+14,d1 
        muls    t3curnt+22,d2 
        muls    t3curnt+30,d3 
        jsr     add_up 
        move.l  d4,wt_coord2         	; transformed W coord - 
        				; is this needed ?
        rts 
; 
;  savecurnt - saves the last xt,yt,zt coords as the blitter needs the 
;              start and end points of the line 
; 
savecurnt: 
       move.l   xt_coord2,xt_coord1
       move.l   yt_coord2,yt_coord1 
       move.l   zt_coord2,zt_coord1 
       move.l   wt_coord2,wt_coord1 
       rts 
;
;*********************************************************************
; 
; concat3 subroutine - 
; 
;   multiplies two matrices together uses temporary matrix 
;   and puts result back into the current matrix 
; 

concat3: 
        lea	t3curnt,a2          	; address of current matrix 
        lea	t3temp,a3           	; address of temporary matrix 
        lea	t3temp2,a4		; address of result matrix
        
        clr.l   d0                      ; initialise loop counter 1 
        clr.l   d1                      ; initialise loop counter 2 
        move.w	#0,counter		; initialise the counter for
        				; - the result matrix
loop_1: 
        move.w  d0,d2 
        muls    #8,d2                   ; offset into current matrix 
 	muls	#2,d1 			; offset into temp matrix
 	
        move.w  (a2,d2),d3		; get value from current matrix
        move.w  (a3,d1),d4 		; get value from temp matrix
        add.w   #2,d2                   ; point to next position in current
        add.w   #8,d1 			; point to next position in temp
        move.w  (a2,d2),d5		; get next values
        move.w  (a3,d1),d6 
        muls    d3,d4			; multiply them
        muls    d5,d6
        add.l	d4,d6			; add them together 
        move.l  d6,d7                   ; save half of the value 
 
        add.w   #2,d2                   ; same as above 
        add.w   #8,d1 
        move.w  (a2,d2),d3 
        move.w  (a3,d1),d4 
        add.w   #2,d2 
        add.w   #8,d1 
        move.w  (a2,d2),d5 
        move.w  (a3,d1),d6 
        muls    d3,d4 
        muls    d5,d6
        add.l	d4,d6 
        add.l   d7,d6                   ; add both values 
 
 	sub.w	#24,d1			; put loop counters back
        sub.w   #6,d2			; - as before
        move.w	counter,d3 		; get result matrix position
        move.w  d6,(a4,d3)              ; save value to result matrix 
        divs	#2,d1			; put loop cvalue back
 	add.w	#2,d3			; result matrix position
 	move.w	d3,counter		; save result matrix position
 	
        add.w   #1,d1                   ; increment inner loop 
        cmp.w   #3,d1                   ; end of loop ? 
        ble     loop_1 
        clr.l   d1                      ; set loop counter back to 0 
        add.w   #1,d0                   ; increment outer loop 
        cmp.w   #3,d0                   ; end of loop ? 
        ble     loop_1 
        
        clr.l	d0
loop_2  move.w	(a4,d0),d1		; copy result to current matrix
        move.w	d1,(a2,d0)
        addq	#2,d0
        cmp	#30,d0
        ble	loop_2			; next position ?
        
        rts                             ; end of CONCAT3
         
;************************************************************************
;
; rotate3 - subroutine
;
; on entry needs d0 - axis (0,1,2)
;                d1 - degree of rotation
;
rotate3:
	lea	t3curnt,a2		; address of temp matrix
	lea	t3temp,a3		; address of current matrix
	lea	t3temp2,a4
	
	cmp.w	#0,d0			; determine axis rotation
	bne	.testy
	moveq	#1,d2
	moveq	#2,d3
	move.w	#1,sign_bit
.testy	cmp.w	#1,d0
	bne	.testz
	moveq	#0,d2
	moveq	#2,d3
	move.w	#-1,sign_bit
.testz	cmp.w	#2,d0
	bne	.axis_ok
	moveq	#0,d2
	moveq	#1,d3
	move.w	#1,sign_bit
	
.axis_ok:
	jsr	t3init			; initialise temp matrix
	jsr	t3init2			; initialise result matrix
	
	move.w	d2,d4			; i1
	muls	#4,d4			; i1x4
	add.w	d2,d4			; i1x4 + i1
	jsr	clear_matrix
	move.w	d3,d4			; i2
	muls	#4,d4			; i2x4
	add.w	d3,d4			; i2x4 + i2
	jsr	clear_matrix
	move.w	d2,d4			; i1
	muls	#4,d4			; i1x4 
	add.w	d3,d4			; i1x4 + i2
	jsr	clear_matrix
	move.w	d3,d4			; i2
	muls	#4,d4			; i2x4
	add.w	d2,d4			; i2x4 + i1
	jsr	clear_matrix
	move.w	d2,save_d2		; put d2 into temp store
					; remember d1 is angle in degrees

	tst	d1
	bpl.s	.noadd
	add	#360,d1
.noadd	lea	sin_table,a1
	move.l	d1,d2 
	lsl	#1,d1
	move	0(a1,d1),d4		; sin value from the sin table
	cmp	#270,d2
	blt.s	.plus9
	sub	#270,d2
	bra.s	.sendsin
.plus9	add	#90,d2
.sendsin
	lsl	#1,d2
	move	0(a1,d2),d5		; cos value from the sin table

	move.w	save_d2,d2		; get d2 back from temp store
	move.w	d2,d6			; set-up rotation matrix d2=i1
	muls	#4,d6			; i1x4 -> d6
	add.w	d2,d6			; i1x4 + i1 -> d6
	muls	#2,d6			; position in matrix
	move.w	d5,(a3,d6)		; cos/sin  value into matrix
	
	move.w	d3,d6
	muls	#4,d6
	add.w	d3,d6
	muls	#2,d6			; position in matrix
	move.w	d5,(a3,d6)		; cos/sin value into matrix
	
	move.w	d2,d6
	muls	#4,d6
	add.w	d3,d6
	muls	#2,d6			; position in matrix
	muls	sign_bit,d4
	move.w	d4,(a3,d6)
	
	move.w	d3,d6
	muls	#4,d6
	add.w	d2,d6
	muls	#-1,d4
	muls	#2,d6			; position in matrix
	move.w	d4,(a3,d6)
	
	cmp.b	#1,changetoz
	bne	cx1
	moveq	#16,d0
	moveq	#18,d1
	jsr	save_vals
cx1	cmp.b	#1,changetox
	bne	cy1
	moveq	#2,d0
	moveq	#4,d1
	jsr	save_vals
cy1	cmp.b	#1,changetoy
	bne	docat
	moveq	#8,d0
	moveq	#12,d1
	jsr	save_vals

docat	jsr	concat3			; do concat routine

	cmp.b	#1,changetoz		; its the flags
	bne	cx2
	moveq	#16,d0
	moveq	#18,d1
	jsr	rest_vals
cx2	cmp.b	#1,changetox
	bne	cy2
	moveq	#2,d0
	moveq	#4,d1
	jsr	rest_vals
cy2	cmp.b	#1,changetoy
	bne	endrot
	moveq	#8,d0
	moveq	#12,d1
	jsr	rest_vals
endrot	rts				; end of rotation		
	
	
save_vals:
	move.w	(a2,d0),save_val_1
	move.w	(a2,d1),save_val_2
	rts
	
rest_vals:
	move.w	save_val_1,(a2,d0)
	move.w	save_val_2,(a2,d1)
	rts
	
clear_matrix:
	muls	#2,d4			; offset into matrix
	cmp	#0,d4
	bne	.t2
	move.w	#1,(a2,d4)		; okay set to 1	
	bra	.end			; and get out
.t2:	cmp	#10,d4
	bne	.t3
	move.w	#1,(a2,d4)		; set to 1
	bra	.end			; and get out
.t3	cmp	#20,d4
	bne	.t4
	move.w	#1,(a2,d4)		; set to 1
	bra	.end			; and get out
.t4	clr.w	(a2,d4)			; not pos 0,5 or 10 clear it
.end	divs	#2,d4
	rts
;
; move3abs - moves to a 3d co-ordinate
;
;
move3abs:
	jsr	xfrm3p			; get transformed positions
	move.b	rotated,d1
	cmp.b	#1,d1			; if a rotation then division
					; by 16384 to get proper value
	bne	.coords_ok		; otherwise get outta here..
	clr.l	d1
	clr.l	d2
	move.l	x_coord,d1
	move.l	xt_coord2,d2
	cmp.l	d1,d2
	beq	.y1
	asr.l	#8,d2
	asr.l	#6,d2
	move.l	d2,xt_coord2
.y1	move.l	y_coord,d1
	move.l	yt_coord2,d2
	cmp.l	d1,d2
	beq	.z1
	asr.l	#8,d2
	asr.l	#6,d2
	move.l	d2,yt_coord2
.z1	move.l	z_coord,d1
	move.l	zt_coord2,d2
	cmp.l	d1,d2
	beq	.coords_ok
	asr.l	#8,d2
	asr.l	#6,d2
	move.l	d2,zt_coord2
.coords_ok:
	clr.l	d2
	clr.l	d3
        move.l  xt_coord2,d2 
        move.l  yt_coord2,d3
        sub.l	wx,d2			; get real coords
        sub.l	wy,d3
        neg.l	d3
;        muls	tx,d2			; scaling factor
;        muls	ty,d3			; - not used
        add.l	vh,d3
	move.l	d2,xt_coord2		; and save them
	move.l	d3,yt_coord2
	rts
; 
; line3abs - draws a line from the last point to the new point 
; 
line3abs: 
       jsr      xfrm3p 
       move.b	rotated,d1
       cmp.b    #1,d1 
       bne      .coords_ok 
       clr.l	d1
       clr.l	d2
       move.l   x_coord,d1 
       move.l   xt_coord2,d2 
       cmp.l    d1,d2 
       beq      .y1 
       asr.l	#8,d2
       asr.l	#6,d2
       move.l   d2,xt_coord2 
.y1    move.l   y_coord,d1 
       move.l   yt_coord2,d2 
       cmp.l    d1,d2 
       beq      .z1
       asr.l	#8,d2
       asr.l	#6,d2 
       move.l   d2,yt_coord2 
.z1    move.l   z_coord,d1 
       move.l   zt_coord2,d2 
       cmp.l    d1,d2 
       beq      .coords_ok
       asr.l	#8,d2
       asr.l	#6,d2 
       move.l   d2,zt_coord2 
.coords_ok: 
       clr.l	d0
       clr.l	d1
       clr.l	d2
       clr.l	d3
       move.l   xt_coord1,d0            ; setup registers for blitter 
       move.l   yt_coord1,d1            ; - drawline procedure 
       move.l   xt_coord2,d2 
       move.l   yt_coord2,d3
	sub.l	wx,d2			; get real coords
       sub.l	wy,d3
       neg.l	d3
;       muls	tx,d2
;       muls	ty,d3
       add.l	vh,d3
       
       cmp	d2,d0			; if coords the same then add
       bne	.nsame			; 1 to the end of the line
       cmp	d3,d1			; the blitter doesnt like to
       bne	.nsame			; draw a line when x1,y1 is
       add.l	#1,d2			; the same as x2,y2 - I got
       add.l	#1,d3			; some well weird results
       
.nsame move.l	d2,xt_coord2
       move.l	d3,yt_coord2
       jsr      DrawLine 		; and draw the line
       rts 
; 
; draw_3d - main 3d draw routine , this is a my name - I shall
;		get around to making this a lot better
;		NOTE :- the x-axis is -160 -> +160
;			the y-axis is -128 -> +128
;			
; 
draw_3d:
	move.b	#0,kill 
	move.l	#-80,x_coord		; S data
	move.l	#-20,y_coord
	move.l	#0,z_coord
	jsr	move3abs
	move.l	#-55,x_coord
	move.l	#-20,y_coord
	jsr	line3abs
	move.l	#5,y_coord
	jsr	line3abs

	move.l	#-75,x_coord
	jsr	line3abs
	move.l	#15,y_coord
	jsr	line3abs
	move.l	#-55,x_coord
	jsr	line3abs
	move.l	#20,y_coord
	jsr	line3abs
	move.l	#-80,x_coord
	jsr	line3abs
	move.l	#-5,y_coord
	jsr	line3abs
	move.l	#-60,x_coord
	jsr	line3abs
	move.l	#-15,y_coord
	jsr	line3abs
	move.l	#-80,x_coord
	jsr	line3abs
	move.l	#-20,y_coord
	jsr	line3abs

	move.l	#-50,x_coord		; i data
	move.l	#20,y_coord
	move.l	#10,z_coord
	jsr	move3abs
	move.l	#-25,x_coord
	jsr	line3abs
	move.l	#15,y_coord
	jsr	line3abs
	move.l	#-35,x_coord
	jsr	line3abs
	move.l	#-15,y_coord
	jsr	line3abs
	move.l	#-25,x_coord
	jsr	line3abs
	move.l	#-20,y_coord
	jsr	line3abs
	move.l	#-50,x_coord
	jsr	line3abs
	move.l	#-15,y_coord
	jsr	line3abs
	move.l	#-40,x_coord
	jsr	line3abs
	move.l	#15,y_coord
	jsr	line3abs
	move.l	#-50,x_coord
	jsr	line3abs
	move.l	#20,y_coord
	jsr	line3abs
	
	move.l	#-20,x_coord	; d data
;	move.l	#0,z_coord
	move.l	#0,z_coord
	jsr	move3abs
	move.l	#-10,x_coord
	jsr	line3abs
	move.l	#0,x_coord
	move.l	#10,y_coord
	jsr	line3abs
	move.l	#-10,y_coord
	jsr	line3abs
	move.l	#-10,x_coord
	move.l	#-20,y_coord
	jsr	line3abs
	move.l	#-20,x_coord
	jsr	line3abs
	move.l	#20,y_coord
	jsr	line3abs
	move.l	#-15,x_coord
	move.l	#10,y_coord
	jsr	move3abs
	move.l	#-10,x_coord
	jsr	line3abs
	move.l	#-5,x_coord
	move.l	#5,y_coord
	jsr	line3abs
	move.l	#-5,y_coord
	jsr	line3abs
	move.l	#-10,x_coord
	move.l	#-10,y_coord
	jsr	line3abs
	move.l	#-15,x_coord
	jsr	line3abs
	move.l	#10,y_coord
	jsr	line3abs
	
	move.l	#5,x_coord		; second d data
	move.l	#20,y_coord
;	move.l	#0,z_coord
	move.l	#10,z_coord
	jsr	move3abs
	move.l	#15,x_coord
	jsr	line3abs
	move.l	#25,x_coord
	move.l	#10,y_coord
	jsr	line3abs
	move.l	#-10,y_coord
	jsr	line3abs
	move.l	#15,x_coord
	move.l	#-20,y_coord
	jsr	line3abs
	move.l	#5,x_coord
	jsr	line3abs
	move.l	#20,y_coord
	jsr	line3abs
	move.l	#10,x_coord
	move.l	#10,y_coord
	jsr	move3abs
	move.l	#15,x_coord
	jsr	line3abs
	move.l	#20,x_coord
	move.l	#5,y_coord
	jsr	line3abs
	move.l	#-5,y_coord
	jsr	line3abs
	move.l	#15,x_coord
	move.l	#-10,y_coord
	jsr	line3abs
	move.l	#10,x_coord
	jsr	line3abs
	move.l	#10,y_coord
	jsr	line3abs
	
	move.l	#30,x_coord		; e data
	move.l	#20,y_coord
;	move.l	#0,z_coord
	move.l	#0,z_coord
	jsr	move3abs
	move.l	#50,x_coord
	jsr	line3abs
	move.l	#15,y_coord
	jsr	line3abs
	move.l	#35,x_coord
	jsr	line3abs
	move.l	#5,y_coord
	jsr	line3abs
	move.l	#45,x_coord
	jsr	line3abs
	move.l	#-5,y_coord
	jsr	line3abs
	move.l	#35,x_coord
	jsr	line3abs
	move.l	#-15,y_coord
	jsr	line3abs
	move.l	#50,x_coord
	jsr	line3abs
	move.l	#-20,y_coord
	jsr	line3abs
	move.l	#30,x_coord
	jsr	line3abs
	move.l	#20,y_coord
	jsr	line3abs
	
	move.l	#55,x_coord		; r data
;	move.l	#0,z_coord
	move.l	#10,z_coord
	jsr	move3abs
	move.l	#75,x_coord
	jsr	line3abs
	move.l	#0,y_coord
	jsr	line3abs
	move.l	#60,x_coord
	jsr	line3abs
	move.l	#75,x_coord
	move.l	#-15,y_coord
	jsr	line3abs
	move.l	#70,x_coord
	move.l	#-20,y_coord
	jsr	line3abs
	move.l	#60,x_coord
	move.l	#-5,y_coord
	jsr	line3abs
	move.l	#-20,y_coord
	jsr	line3abs
	move.l	#55,x_coord
	jsr	line3abs
	move.l	#20,y_coord
	jsr	line3abs
	move.l	#60,x_coord
	move.l	#15,y_coord
	jsr	move3abs
	move.l	#70,x_coord
	jsr	line3abs
	move.l	#5,y_coord
	jsr	line3abs
	move.l	#60,x_coord
	jsr	line3abs
	move.l	#15,y_coord
	jsr	line3abs
        rts 
; 
; t3init - initialise the temporary matrix 
; 
t3init: 
       move.w   #1,t3temp 
       clr.w    t3temp+2 
       clr.w    t3temp+4 
       clr.w    t3temp+6 
       clr.w    t3temp+8
       move.w   #1,t3temp+10 
       clr.w    t3temp+12 
       clr.w    t3temp+14 
       clr.w    t3temp+16 
       clr.w    t3temp+18 
       move.w   #1,t3temp+20 
       clr.w    t3temp+22 
       clr.w    t3temp+24 
       clr.w    t3temp+26 
       clr.w    t3temp+28 
       move.w   #1,t3temp+30 
       rts 

; 
; t3init2 - initialise the temporary matrix 
; 
t3init2: 
       move.w   #1,t3temp2 
       clr.w    t3temp2+2 
       clr.w    t3temp2+4 
       clr.w    t3temp2+6 
       clr.w    t3temp2+8
       move.w   #1,t3temp2+10 
       clr.w    t3temp2+12 
       clr.w    t3temp2+14 
       clr.w    t3temp2+16 
       clr.w    t3temp2+18 
       move.w   #1,t3temp2+20 
       clr.w    t3temp2+22 
       clr.w    t3temp2+24 
       clr.w    t3temp2+26 
       clr.w    t3temp2+28 
       move.w   #1,t3temp2+30 
       rts 

; 
; clear_curnt - initialise the current matrix 
; 
clear_curnt: 
       move.w   #1,t3curnt 
       clr.w    t3curnt+2 
       clr.w    t3curnt+4 
       clr.w    t3curnt+6 
       clr.w    t3curnt+8
       move.w   #1,t3curnt+10 
       clr.w    t3curnt+12 
       clr.w    t3curnt+14 
       clr.w    t3curnt+16 
       clr.w    t3curnt+18 
       move.w   #1,t3curnt+20 
       clr.w    t3curnt+22 
       clr.w    t3curnt+24 
       clr.w    t3curnt+26 
       clr.w    t3curnt+28 
       move.w   #1,t3curnt+30 
       rts 

; init3dsys - initialize the 3-D system 
; 
init3dsys: 
       move.l   #320,xx2 
       move.l   #256,yy2 
       move.l   #320,vl 
       move.l   #256,vh 
       move.l   #-160,wx 
       move.l   #-128,wy 
       move.l   #256,wh 	; reaL height
       move.l   #320,wl 	; real width
       move.l   #1,tx 		; the scaling factors
       move.l   #1,ty
       jsr      t3init 		; initialise matrix
       rts 
; 
; variables 
;
;
		even
degreex		dc.w	0		; current degree X
degreey		dc.w	0		; current degree Y
degreez		dc.w	0		; current degree Z
save_d2		dc.w	0		; temp store for d2
xx1		dc.l	0		; real x1 value
xx2		dc.l	0		; real x2 value
yy1		dc.l	0		; real y1 value
yy2		dc.l	0		; real y2 value
vh		dc.l	0		; y2-y1 value (height)
vl		dc.l	0		; x2-x1 value (length)

wx		dc.l	0		; world coord left
wy		dc.l	0		; world coord bottom
wh		dc.l	0		; world coord top-bottom
wl		dc.l	0		; world coord right-left
tx		dc.l	0		; vl / wl
ty		dc.l	0		; vh / wh
 
x_coord         dc.l    0 		; current x-coord (3-D)
y_coord         dc.l    0 		; current y-coord (3-D)
z_coord         dc.l    0		; current z-coord (3-D)
w_coord         dc.l    1		; w - coord always 1 
xt_coord1       dc.l    0		; old transformed x-coord 
yt_coord1       dc.l    0 		; old transformed y-coord
zt_coord1       dc.l    0 		; old transformed z-coord
wt_coord1       dc.l    0		; old transformed w-coord
xt_coord2	dc.l	0		; new transformed X-coord
yt_coord2	dc.l	0		; new transformed y-coord
zt_coord2	dc.l	0		; new transformed z-coord
wt_coord2	dc.l	0		; new transformed w coord
counter		dc.w	0 
sign_bit	dc.w	0
save_val_1	dc.w	0		; temp store
save_val_2	dc.w	0		;  "     "

changetox	dc.b	0		; flags, stop nasty errors
changetoy	dc.b	0		; - during the concat
changetoz	dc.b	0		; - procedure...
rotated		dc.b	0		; rotated flag
kill		dc.b	0
dist		dc.w	0		; distance for perpective trans.

t3curnt         dc.w    1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1 
 
t3temp          dc.w    1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1 
 
t3temp2		dc.w	1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1

GRname: 	dc.b 	"graphics.library",0
		even
		
sin_table	dc.w 0,286,572,857,1143,1428,1713,1997,2280
		dc.w 2563,2845,3126,3406,3686,3964,4240,4516
		dc.w 4790,5063,5334,5604,5872,6138,6402,6664
		dc.w 6924,7182,7438,7692,7943,8192,8438,8682		
		dc.w 8923,9162,9397,9630,9860,10087,10311,10531
		dc.w 10749,10963,11174,11381,11585,11786,11982,12176
		dc.w 12365,12551,12733,12911,13085,13255,13421,13583
		dc.w 13741,13894,14044,14189,14330,14466,14598,14726
		dc.w 14849,14968,15082,15191,15296,15396,15491,15582
		dc.w 15668,15749,15826,15897,15964,16026,16083,16135
		dc.w 16182,16225,16262,16294,16322,16344,16362,16374
		dc.w 16382,16384
		dc.w 16382
		dc.w 16374,16362,16344,16322,16294,16262,16225,16182
		dc.w 16135,16083,16026,15964,15897,15826,15749,15668		
		dc.w 15582,15491,15396,15296,15191,15082,14967,14849
		dc.w 14726,14598,14466,14330,14189,14044,13894,13741		
		dc.w 13583,13421,13255,13085,12911,12733,12551,12365
		dc.w 12176,11982,11786,11585,11381,11174,10963,10749
		dc.w 10531,10311,10087,9860,9630,9397,9162,8923
		dc.w 8682,8438,8192,7943,7692,7438,7182,6924
		dc.w 6664,6402,6138,5872,5604,5334,5063,4790
		dc.w 4516,4240,3964,3686,3406,3126,2845,2563
		dc.w 2280,1997,1713,1428,1143,857,572,286,0
		dc.w -286,-572,-857,-1143,-1428,-1713,-1997,-2280
		dc.w -2563,-2845,-3126,-3406,-3686,-3964,-4240,-4516
		dc.w -4790,-5063,-5334,-5604,-5872,-6138,-6402,-6664
		dc.w -6924,-7182,-7438,-7692,-7943,-8192,-8438,-8682		
		dc.w -8923,-9162,-9397,-9630,-9860,-10087,-10311,-10531
		dc.w -10749,-10963,-11174,-11381,-11585,-11786,-11982,-12176
		dc.w -12365,-12551,-12733,-12911,-13085,-13255,-13421,-13583
		dc.w -13741,-13894,-14044,-14189,-14330,-14466,-14598,-14726
		dc.w -14849,-14968,-15082,-15191,-15296,-15396,-15491,-15582
		dc.w -15668,-15749,-15826,-15897,-15964,-16026,-16083,-16135
		dc.w -16182,-16225,-16262,-16294,-16322,-16344,-16362,-16374
		dc.w -16382,-16384
		dc.w -16382
		dc.w -16374,-16362,-16344,-16322,-16294,-16262,-16225,-16182
		dc.w -16135,-16083,-16026,-15964,-15897,-15826,-15749,-15668		
		dc.w -15582,-15491,-15396,-15296,-15191,-15082,-14967,-14849
		dc.w -14726,-14598,-14466,-14330,-14189,-14044,-13894,-13741		
		dc.w -13583,-13421,-13255,-13085,-12911,-12733,-12551,-12365
		dc.w -12176,-11982,-11786,-11585,-11381,-11174,-10963,-10749
		dc.w -10531,-10311,-10087,-9860,-9630,-9397,-9162,-8923
		dc.w -8682,-8438,-8192,-7943,-7692,-7438,-7182,-6924
		dc.w -6664,-6402,-6138,-5872,-5604,-5334,-5063,-4790
		dc.w -4516,-4240,-3964,-3686,-3406,-3126,-2845,-2563
		dc.w -2280,-1997,-1713,-1428,-1143,-857,-572,-286,0

**************************************
*   NoisetrackerV1.0 replayroutine   *
* Mahoney & Kaktus - HALLONSOFT 1989 *
**************************************


mt_init:lea	mt_data,a0
	move.l	a0,a1
	add.l	#$3b8,a1
	moveq	#$7f,d0
	moveq	#0,d1
mt_loop:move.l	d1,d2
	subq.w	#1,d0
mt_lop2:move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	mt_loop
	dbf	d0,mt_lop2
	addq.b	#1,d2

	lea	mt_samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$43c,d2
	add.l	a0,d2
	move.l	d2,a2
	moveq	#$1e,d0
mt_lop3:clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.l	#$1e,a0
	dbf	d0,mt_lop3

	or.b	#$2,Ciaapra
	move.b	#$6,mt_speed
	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.b	mt_songpos
	clr.b	mt_counter
	clr.w	mt_pattpos
	rts

mt_end:	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$f,$dff096
	rts

mt_music:
	movem.l	d0-d4/a0-a3/a5-a6,-(a7)
	lea	mt_data,a0
	addq.b	#$1,mt_counter
	move.b	mt_counter,D0
	cmp.b	mt_speed,D0
	blt.s	mt_nonew
	clr.b	mt_counter
	bra	mt_getnew

mt_nonew:
	lea	mt_voice1(pc),a6
	lea	$dff0a0,a5
	bsr	mt_checkcom
	lea	mt_voice2(pc),a6
	lea	$dff0b0,a5
	bsr	mt_checkcom
	lea	mt_voice3(pc),a6
	lea	$dff0c0,a5
	bsr	mt_checkcom
	lea	mt_voice4(pc),a6
	lea	$dff0d0,a5
	bsr	mt_checkcom
	bra	mt_endr

mt_arpeggio:
	moveq	#0,d0
	move.b	mt_counter,d0
	divs	#$3,d0
	swap	d0
	cmp.w	#$0,d0
	beq.s	mt_arp2
	cmp.w	#$2,d0
	beq.s	mt_arp1

	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	bra.s	mt_arp3
mt_arp1:moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	bra.s	mt_arp3
mt_arp2:move.w	$10(a6),d2
	bra.s	mt_arp4
mt_arp3:asl.w	#1,d0
	moveq	#0,d1
	move.w	$10(a6),d1
	lea	mt_periods(pc),a0
	moveq	#$24,d7
mt_arploop:
	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	mt_arp4
	addq.l	#2,a0
	dbf	d7,mt_arploop
	rts
mt_arp4:move.w	d2,$6(a5)
	rts

mt_getnew:
	lea	mt_data,a0
	move.l	a0,a3
	move.l	a0,a2
	add.l	#$c,a3
	add.l	#$3b8,a2
	add.l	#$43c,a0

	moveq	#0,d0
	move.l	d0,d1
	move.b	mt_songpos,d0
	move.b	(a2,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	mt_pattpos,d1
	clr.w	mt_dmacon

	lea	$dff0a0,a5
	lea	mt_voice1(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0b0,a5
	lea	mt_voice2(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0c0,a5
	lea	mt_voice3(pc),a6
	bsr.s	mt_playvoice
	lea	$dff0d0,a5
	lea	mt_voice4(pc),a6
	bsr.s	mt_playvoice
	bra	mt_setdma

mt_playvoice:
	move.l	(a0,d1.l),(a6)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$2(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2
	move.b	(a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	mt_setregs
	moveq	#0,d3
	lea	mt_samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$1,d2
	asl.l	#2,d2
	mulu	#$1e,d4
	move.l	(a1,d2.l),$4(a6)
	move.w	(a3,d4.l),$8(a6)
	move.w	$2(a3,d4.l),$12(a6)
	move.w	$4(a3,d4.l),d3
	tst.w	d3
	beq.s	mt_noloop
	move.l	$4(a6),d2
	asl.w	#1,d3
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$4(a3,d4.l),d0
	add.w	$6(a3,d4.l),d0
	move.w	d0,8(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
	bra.s	mt_setregs
mt_noloop:
	move.l	$4(a6),d2
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$6(a3,d4.l),$e(a6)
	move.w	$12(a6),$8(a5)
mt_setregs:
	move.w	(a6),d0
	and.w	#$fff,d0
	beq	mt_checkcom2
	move.b	$2(a6),d0
	and.b	#$F,d0
	cmp.b	#$3,d0
	bne.s	mt_setperiod
	bsr	mt_setmyport
	bra	mt_checkcom2
mt_setperiod:
	move.w	(a6),$10(a6)
	and.w	#$fff,$10(a6)
	move.w	$14(a6),d0
	move.w	d0,$dff096
	clr.b	$1b(a6)

	move.l	$4(a6),(a5)
	move.w	$8(a6),$4(a5)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	move.w	$14(a6),d0
	or.w	d0,mt_dmacon
	bra	mt_checkcom2

mt_setdma:
	move.w	#$12c,d0
mt_wait:dbf	d0,mt_wait
	move.w	mt_dmacon,d0
	or.w	#$8000,d0
	move.w	d0,$dff096
	move.w	#$12c,d0
mt_wai2:dbf	d0,mt_wai2
	lea	$dff000,a5
	lea	mt_voice4(pc),a6
	move.l	$a(a6),$d0(a5)
	move.w	$e(a6),$d4(a5)
	lea	mt_voice3(pc),a6
	move.l	$a(a6),$c0(a5)
	move.w	$e(a6),$c4(a5)
	lea	mt_voice2(pc),a6
	move.l	$a(a6),$b0(a5)
	move.w	$e(a6),$b4(a5)
	lea	mt_voice1(pc),a6
	move.l	$a(a6),$a0(a5)
	move.w	$e(a6),$a4(a5)

	add.w	#$10,mt_pattpos
	cmp.w	#$400,mt_pattpos
	bne.s	mt_endr
mt_nex:	clr.w	mt_pattpos
	clr.b	mt_break
	addq.b	#1,mt_songpos
	and.b	#$7f,mt_songpos
	move.b	mt_songpos,d1
	cmp.b	mt_data+$3b6,d1
	bne.s	mt_endr
	clr.b	mt_songpos
mt_endr:tst.b	mt_break
	bne.s	mt_nex
	movem.l	(a7)+,d0-d4/a0-a3/a5-a6
	rts

mt_setmyport:
	move.w	(a6),d2
	and.w	#$fff,d2
	move.w	d2,$18(a6)
	move.w	$10(a6),d0
	clr.b	$16(a6)
	cmp.w	d0,d2
	beq.s	mt_clrport
	bge.s	mt_rt
	move.b	#$1,$16(a6)
	rts
mt_clrport:
	clr.w	$18(a6)
mt_rt:	rts

mt_myport:
	move.b	$3(a6),d0
	beq.s	mt_myslide
	move.b	d0,$17(a6)
	clr.b	$3(a6)
mt_myslide:
	tst.w	$18(a6)
	beq.s	mt_rt
	moveq	#0,d0
	move.b	$17(a6),d0
	tst.b	$16(a6)
	bne.s	mt_mysub
	add.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	bgt.s	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
mt_myok:move.w	$10(a6),$6(a5)
	rts
mt_mysub:
	sub.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	blt.s	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
	move.w	$10(a6),$6(a5)
	rts

mt_vib:	move.b	$3(a6),d0
	beq.s	mt_vi
	move.b	d0,$1a(a6)

mt_vi:	move.b	$1b(a6),d0
	lea	mt_sin(pc),a4
	lsr.w	#$2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b	(a4,d0.w),d2
	move.b	$1a(a6),d0
	and.w	#$f,d0
	mulu	d0,d2
	lsr.w	#$6,d2
	move.w	$10(a6),d0
	tst.b	$1b(a6)
	bmi.s	mt_vibmin
	add.w	d2,d0
	bra.s	mt_vib2
mt_vibmin:
	sub.w	d2,d0
mt_vib2:move.w	d0,$6(a5)
	move.b	$1a(a6),d0
	lsr.w	#$2,d0
	and.w	#$3c,d0
	add.b	d0,$1b(a6)
	rts

mt_nop:	move.w	$10(a6),$6(a5)
	rts

mt_checkcom:
	move.w	$2(a6),d0
	and.w	#$fff,d0
	beq.s	mt_nop
	move.b	$2(a6),d0
	and.b	#$f,d0
	tst.b	d0
	beq	mt_arpeggio
	cmp.b	#$1,d0
	beq.s	mt_portup
	cmp.b	#$2,d0
	beq	mt_portdown
	cmp.b	#$3,d0
	beq	mt_myport
	cmp.b	#$4,d0
	beq	mt_vib
	move.w	$10(a6),$6(a5)
	cmp.b	#$a,d0
	beq.s	mt_volslide
	rts

mt_volslide:
	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_voldown
	add.w	d0,$12(a6)
	cmp.w	#$40,$12(a6)
	bmi.s	mt_vol2
	move.w	#$40,$12(a6)
mt_vol2:move.w	$12(a6),$8(a5)
	rts

mt_voldown:
	moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	sub.w	d0,$12(a6)
	bpl.s	mt_vol3
	clr.w	$12(a6)
mt_vol3:move.w	$12(a6),$8(a5)
	rts

mt_portup:
	moveq	#0,d0
	move.b	$3(a6),d0
	sub.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$71,d0
	bpl.s	mt_por2
	and.w	#$f000,$10(a6)
	or.w	#$71,$10(a6)
mt_por2:move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_portdown:
	clr.w	d0
	move.b	$3(a6),d0
	add.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$358,d0
	bmi.s	mt_por3
	and.w	#$f000,$10(a6)
	or.w	#$358,$10(a6)
mt_por3:move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_checkcom2:
	move.b	$2(a6),d0
	and.b	#$f,d0
	cmp.b	#$e,d0
	beq.s	mt_setfilt
	cmp.b	#$d,d0
	beq.s	mt_pattbreak
	cmp.b	#$b,d0
	beq.s	mt_posjmp
	cmp.b	#$c,d0
	beq.s	mt_setvol
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	rts

mt_setfilt:
	rts
mt_pattbreak:
	not.b	mt_break
	rts
mt_posjmp:
	move.b	$3(a6),d0
	subq.b	#$1,d0
	move.b	d0,mt_songpos
	not.b	mt_break
	rts
mt_setvol:
	cmp.b	#$40,$3(a6)
	ble.s	mt_vol4
	move.b	#$40,$3(a6)
mt_vol4:move.b	$3(a6),$8(a5)
	rts
mt_setspeed:
	move.b	$3(a6),d0
	and.w	#$1f,d0
	beq.s	mt_rts2
	clr.b	mt_counter
	move.b	d0,mt_speed
mt_rts2:rts




mt_sin:
 dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
 dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_periods:
 dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
 dc.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
 dc.w $00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f,$0087
 dc.w $007f,$0078,$0071,$0000,$0000

mt_speed:	dc.b	$6
mt_songpos:	dc.b	$0
mt_pattpos:	dc.w	$0
mt_counter:	dc.b	$0


mt_break:	dc.b	$0
mt_dmacon:	dc.w	$0
mt_samplestarts:dcb.l	$1f,0
mt_voice1:	dcb.w	10,0
		dc.w	$1
		dcb.w	3,0
mt_voice2:	dcb.w	10,0
		dc.w	$2
		dcb.w	3,0
mt_voice3:	dcb.w	10,0
		dc.w	$4
		dcb.w	3,0
mt_voice4:	dcb.w	10,0
		dc.w	$8
		dcb.w	3,0

mt_data
; 
; put song module here
; 
	incbin Source:Modules/mod.music
;
;
end




