;-------------------------------------------------
;   TDRender Library V 1.0 Beta 
;   3D frame render library
;   Yves Rosso - 1997
;   compiled with SNMA 2.04
;-------------------------------------------------


 CPU M68030!M68882
 
 SNMAOPT E,S,P,L
 
 incdir  "include:"
 include "exec/initializers.i"
 include "exec/resident.i"
 include "exec/alerts.i"
 include "exec/execbase.i"
 include "exec/exec_lib.i"
 include "utility/utility.i"

; include "utility/utility_lib.i"
 
 include "tdrender_lib.i"
 

;-------------------------------------------------
; Prevent executing lib

ST moveq #-1,d0
   rts
   
;-------------------------------------------------

RomTag
   dc.w  RTC_MATCHWORD
   dc.l  RomTag,EndLib
   dc.b  RTF_AUTOINIT,ST_VERNUM
   dc.b  NT_LIBRARY,0
   dc.l  TDRender.Name,Library.ID
   dc.l  Library.Init
   
Library.Init
   dc.l  stb_SIZEOF
   dc.l  Functions.Table
   dc.l  Data.Table
   dc.l  Lib.InitRoutine
   
Functions.Table
   dc.l  Lib.Open
   dc.l  Lib.Close
   dc.l  Lib.Expunge
   dc.l  NullFunc
   dc.l  tdClearFrmBuf
   dc.l  tdClearFrmBufCol
   dc.l  tdRgbToVal
   dc.l  tdPixelColRgb
   dc.l  tdPixelColVal
   dc.l  tdPixel
   dc.l  tdLine
   dc.l  tdBox
   dc.l  tdBoxFill
   dc.l  tdDrawStars
   dc.l  tdMovRotStars
   dc.l  tdSetLight
   dc.l  tdSetCamera
   dc.l  tdGetMatrix
   dc.l  tdRotCoord
   dc.l  tdDrwObFrmCam
   dc.l  tdDrawObject
   dc.l  -1
   
Data.Table
   INITBYTE  LN_TYPE,NT_LIBRARY
   INITLONG  LN_NAME,TDRender.Name
   INITLONG  LIB_IDSTRING,Library.ID
   INITBYTE  LIB_FLAGS,LIBF_SUMUSED!LIBF_CHANGED
   INITWORD  LIB_VERSION,ST_VERNUM
   INITWORD  LIB_REVISION,ST_REVNUM
   dc.l      0


;-------------------------------------------------
; Success = Lib.InitRoutine(Base,SegList)   
;   (d0)                     (d0,a0)
;-------------------------------------------------

Lib.InitRoutine
    movem.l     d7/a5-a6,-(sp)
    move.l      d0,a5
    move.l      a6,stb_ExecBase(a5)
    move.l      a0,stb_SegList(a5)
    lea         Utility.Name(pc),a1
    moveq       #37,d0
    jsr         _LVOOpenLibrary(a6)
    move.l      d0,stb_UtilityBase(a5)
    bne.s       .UtilOpened
    move.l      #AG_OpenLib!AO_UtilityLib,d7
    jsr         _LVOAlert(a6)
    bra.s       .NoUtil
.UtilOpened
    move.l      a5,d0
.Back
    movem.l     (sp)+,d7/a5-a6
    rts

.NoUtil
    move.l      a5,a1
    moveq       #0,d0
    move.w      LIB_NEGSIZE(a5),d0
    sub.l       d0,a1
    add.w       LIB_POSSIZE(a5),d0
    jsr         _LVOFreeMem(a6)
    moveq       #0,d0
    bra.s       .Back
 
;-------------------------------------------------

Lib.Open
    addq.w      #1,LIB_OPENCNT(a6)
    bclr        #LIBB_DELEXP,LIB_FLAGS(a6)
    move.l      a6,d0
    rts

;-------------------------------------------------

Lib.Close
    subq.w      #1,LIB_OPENCNT(a6)
    bne.s       NullFunc
    btst        #LIBB_DELEXP,LIB_FLAGS(a6)
    bne.s       Lib.Expunge
NullFunc
    moveq       #0,d0
    rts

;-------------------------------------------------

Lib.Expunge
    movem.l     d2/a5-a6,-(sp)
    move.l      a6,a5
    tst.w       LIB_OPENCNT(a5)
    beq.s       .DoIt
    bset        #LIBB_DELEXP,LIB_FLAGS(a5)
    moveq       #0,d0
    bra.s       .Ret
.DoIt
    move.l      stb_ExecBase(a5),a6
    move.l      a5,a1
    jsr         _LVORemove(a6)
    move.l      stb_UtilityBase(a5),a1
    jsr         _LVOCloseLibrary(a6)
    move.l      stb_SegList(a5),d2
    moveq       #0,d0
    move.l      a5,a1
    move.w      LIB_NEGSIZE(a5),d0
    sub.l       d0,a1
    add.w       LIB_POSSIZE(a5),d0
    jsr         _LVOFreeMem(a6)
    move.l      d2,d0
.Ret
    movem.l     (sp)+,d2/a5-a6
    rts
    

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; tdClearFrmBuf(a0)
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;       BufferAddress in A0  (*) 320x240 buffer 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
tdClearFrmBuf
    movem.l     a0/d0-d1,-(sp)
    move.w      #239,d1
.loopy:
    move.w      #319,d0
.loopx:
    move.l      #0,(a0)+
    dbra.w      d0,.loopx
    dbra.w      d1,.loopy
    movem.l     (sp)+,a0/d0-d1
    rts

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; tdClearFrmBufCol(a0,d0)
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;       BufferAddress in A0  (*) 320x240 buffer
;               Color in D0  xRGB 32bit color
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
tdClearFrmBufCol
    movem.l     a0/d0-d2,-(sp)
    move.w      #239,d2
.loopy:
    move.w      #319,d1
.loopx:
    move.l      d0,(a0)+
    dbra.w      d1,.loopx
    dbra.w      d2,.loopy
    movem.l     (sp)+,a0/d0-d2
    rts

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; D0 = tdRgbToVal(d0,d1,d2)
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;           Red Color in D0  
;         Green Color in D1
;          Blue Color in D2
;
; return xRGB32 Color in D0 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
tdRgbToVal
    movem.l     d1-d2,-(sp)
    lsl.l       #8,d1
    swap        d0
    clr.w       d0
    add.l       d1,d0
    add.l       d2,d0
    movem.l     (sp)+,d1-d2
    rts

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; D0,D1,D2 = tdPixelColRgb(a0,d0,d1)
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;       BufferAddress in A0 
;        x coordinate in D0
;        y coordinate in D1
;
; return    Red Color in D0  
;         Green Color in D1
;          Blue Color in D2
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
tdPixelColRgb
    movem.l d3/a0,-(sp)
    cmp.w   #319,d0	        ; First, check if any of the coordinates
    bhi     .outp           ; exceeds the screen. If any of the coordinates
    tst.w   d0
    bmi     .outp

    cmp.w   #239,d1         ; does, then we just skip the whole routine.
    bhi     .outp
    tst.w   d1
    bmi     .outp

    move.l  d1,d3           ; *-  (y=d1=d3)*320
    lsl.l   #6,d1           ; *
    lsl.l   #8,d3           ; *
    add.l   d3,d1           ; *-  y*320 optimized
    add.l   d0,d1           ; *-  +x
    lsl.l   #2,d1           ; *-  *4  for xRGB32 colors buffer
    adda.l  d1,a0           ; *-  place A0 on location X,Y
    
    move.l  (a0),d0         ; Get xRGB color from pixel x,y in D0
    
    move.b  d0,d2           ; Get Blue color in D2
    extb.l  d2
    lsr.l   #8,d0
    move.b  d0,d1           ; Get Green color in D1
    extb.l  d1
    lsr.l   #8,d0           ; Get Red color in D0
   
.outp:
    movem.l (sp)+,d3/a0
    rts

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; D0 = tdPixelColVal(a0,d0,d1)
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;       BufferAddress in A0 
;        x coordinate in D0
;        y coordinate in D1
;
; return xRGB32 Color in D0 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
tdPixelColVal
    movem.l d1-d3/a0,-(sp)
    cmp.w   #319,d0	        ; First, check if any of the coordinates
    bhi     .outp           ; exceeds the screen. If any of the coordinates
    tst.w   d0
    bmi     .outp

    cmp.w   #239,d1         ; does, then we just skip the whole routine.
    bhi     .outp
    tst.w   d1
    bmi     .outp

    move.l  d1,d3           ; *-  (y=d1=d3)*320
    lsl.l   #6,d1           ; *
    lsl.l   #8,d3           ; *
    add.l   d3,d1           ; *-  y*320 optimized
    add.l   d0,d1           ; *-  +x
    lsl.l   #2,d1           ; *-  *4  for xRGB32 colors buffer
    adda.l  d1,a0           ; *-  place A0 on location X,Y

    move.l  (a0),d0         ; Get xRGB color from pixel x,y in D0
.outp:
    movem.l (sp)+,d1-d3/a0
    rts

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; tdPixel(a0,d0,d1,d2)       
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;       BufferAddress in A0 
;        X Coordinate in d0
;        Y Coordinate in d1
;               Color in d2
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
tdPixel
    movem.l d0-d3/a0,-(sp)
    cmp.w   #319,d0	        ; First, check if any of the coordinates
    bhi     .outp           ; exceeds the screen. If any of the coordinates
    tst.w   d0
    bmi     .outp

    cmp.w   #239,d1         ; does, then we just skip the whole routine.
    bhi     .outp
    tst.w   d1
    bmi     .outp

    move.l  d1,d3           ; *-  (y=d1=d3)*320
    lsl.l   #6,d1           ; *
    lsl.l   #8,d3           ; *
    add.l   d3,d1           ; *-  y*320 optimized
    add.l   d0,d1           ; *-  +x
    lsl.l   #2,d1           ; *-  *4  for xRGB32 colors buffer
    adda.l  d1,a0           ; *-  place A0 on location X,Y
    move.l  d2,(a0)
.outp:
    movem.l (sp)+,d0-d3/a0
    rts

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; tdLine(a0,d0,d1,d2,d3,d4)       
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;       BufferAddress in A0 
;       Xo Coordinate in d0
;       Yo Coordinate in d1
;       Xe Coordinate in d2
;       Ye Coordinate in d3
;               Color in d4
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
tdLine
    movem.l d0-d7/a0,-(sp)
        cmp.w   #319,d0	    ; First, check if any of the coordinates
        bhi     .outl       ; exceeds the screen. If any of the coordinates
        tst.w   d0
        bmi     .outl

        cmp.w   #239,d1     ; does, then we just skip the whole routine.
        bhi     .outl
        tst.w   d1
        bmi     .outl

        cmp.w   #319,d2
        bhi     .outl
        tst.w   d2
        bmi     .outl

        cmp.w   #239,d3
        bhi     .outl
        tst.w   d3
        bmi     .outl

        cmp.w   d0,d2       ; Xe must be greater than Xo <=> d2 > d0
        bhi     .cont
        exg     d2,d0       ; d0 > d2 then swap coords
        exg     d3,d1
.cont:
    sub.l   d0,d2			; Calc delta x
	sub.l   d1,d3			; Calc delta y
    
                            ; Draw line
                            ; =========
    move.l  d1,d5           ; *-  Prepare a0 from point(Xo,Yo)
    lsl.l   #6,d1           ; *
    lsl.l   #8,d5           ; *
    add.l   d5,d1           ; *-  y*320 optimized
    add.l   d0,d1           ; *-  +x
    lsl.l   #2,d1           ; *-  *4  for xRGB32 colors buffer
    adda.l  d1,a0           ; *-  place A0 on location Xo,Yo


    tst.l   d3
    bmi     .drwlineup      ; if delta y < 0 then draw line up 


                            ; Draw line DOWN
                            ; ==============
	cmp.l   d2,d3           ; if dx < dy then line > 45 deg
	bhi     .d3g1
	
                            ; line < 45 deg
    move.l  d2,d7           ; for x loop
    moveq.l #0,d1
    add.l   d3,d1
.loop1:
    move.l  d4,(a0)+
    add.l   d3,d1
    cmp.l   d2,d1
    bhi     .dtotg1
    bra     .dtotl1
.dtotg1:
    sub.l   d2,d1
    adda.l  #1280,a0        ; + 320*4=1280
.dtotl1:
	dbra    d7,.loop1
    bra     .outl


.d3g1:                      ; line > 45 deg
    move.l  d3,d7           ; for y loop
    moveq.l #0,d1
    add.l   d2,d1
.loop2:
    move.l  d4,(a0)+
    adda.l  #1276,a0        ; + (320-1)*4=1276
    add.l   d2,d1
    cmp.l   d3,d1
    bhi     .dtotg2
    bra     .dtotl2
.dtotg2:
    sub.l   d3,d1
    adda.l  #4,a0
.dtotl2:
	dbra    d7,.loop2
    bra     .outl

   
.drwlineup:                 ; Draw line UP
    neg.l   d3              ; ============
	cmp.l   d2,d3           ; if dx < dy then line > 45 deg
	bhi     .d3g2
	
                            ; line < 45 deg
    move.l  d2,d7           ; for x loop
    moveq.l #0,d1
    add.l   d3,d1
.loop3:
    move.l  d4,(a0)+
    add.l   d3,d1
    cmp.l   d2,d1
    bhi     .dtotg3
    bra     .dtotl3
.dtotg3:
    sub.l   d2,d1
    suba.l  #1280,a0
.dtotl3:
	dbra    d7,.loop3
    bra     .outl


.d3g2:                      ; line > 45 deg
    move.l  d3,d7           ; for y loop
    moveq.l #0,d1
    add.l   d2,d1
.loop4:
    move.l  d4,(a0)+
    suba.l  #1284,a0
    add.l   d2,d1
    cmp.l   d3,d1
    bhi     .dtotg4
    bra     .dtotl4
.dtotg4:
    sub.l   d3,d1
    adda.l  #4,a0
.dtotl4:
	dbra    d7,.loop4

.outl:
    movem.l (sp)+,d0-d7/a0
    rts

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; tdBox(a0,d0,d1,d2,d3,d4)       
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;       BufferAddress in A0 
;       Xo Coordinate in d0
;       Yo Coordinate in d1
;       Xe Coordinate in d2
;       Ye Coordinate in d3
;               Color in d4
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
tdBox
    movem.l d0-d7/a0-a3,-(sp)
        cmp.w   #319,d0	    ; First, check if any of the coordinates
        bhi     .outbx      ; exceeds the screen. If any of the coordinates
        tst.w   d0
        bmi     .outbx

        cmp.w   #239,d1     ; does, then we just skip the whole routine.
        bhi     .outbx
        tst.w   d1
        bmi     .outbx

        cmp.w   #319,d2
        bhi     .outbx
        tst.w   d2
        bmi     .outbx

        cmp.w   #239,d3
        bhi     .outbx
        tst.w   d3
        bmi     .outbx
        

        cmp.w   d0,d2       ; Xe must be greater than Xo <=> d2 > d0
        bhi     .contx
        exg     d2,d0       ; d0 > d2 then swap coords
.contx:
        cmp.w   d1,d3       ; Ye must be greater than Yo <=> d3 > d1
        bhi     .conty
        exg     d3,d1       ; d1 > d3 then swap coords
.conty:

        sub.l   d0,d2	    ; Calc delta x
	    sub.l   d1,d3       ; Calc delta y
        
        move.l  d2,d6       ; Keep delta X
        move.l  d3,d7       ; Keep delta Y

        move.l  a0,a1       ; copy framebuf address
        move.l  a0,a2       ; copy framebuf address
        move.l  a0,a3       ; copy framebuf address

        move.l  d1,d5       ; *-  Prepare aX from point(Xo,Yo)
        lsl.l   #6,d1       ; *
        lsl.l   #8,d5       ; *
        add.l   d5,d1       ; *-  y*320 optimized
        add.l   d0,d1       ; *-  +x
        lsl.l   #2,d1       ; *-  *4  for xRGB32 colors buffer
        adda.l  d1,a0       ; *-  place A0 on location Xo,Yo
        adda.l  d1,a1       ; *-  place A1 on location Xo,Yo
        adda.l  d1,a2       ; *-  place A2 on location Xo,Yo
        adda.l  d1,a3       ; *-  place A3 on location Xo,Yo
        
        move.l  d3,d5       ; *-  Prepare a1 
        lsl.l   #6,d3       ; *
        lsl.l   #8,d5       ; *
        add.l   d5,d3       ; *-  +dy*320 optimized
        lsl.l   #2,d3       ; *-  *4  for xRGB32 colors buffer
        adda.l  d3,a1       ; *-  place A1 by delta Y
        
                            ; *-  Prepare a3 
        lsl.l   #2,d2       ; *-  +dx*4  for xRGB32 colors buffer
        adda.l  d2,a3       ; *-  place A3 by delta X

.loopx:
        move.l  d4,(a0)+    ; Horizontal Lines
        move.l  d4,(a1)+
        dbra    d6,.loopx

.loopy:
        move.l  d4,(a2)+    ; Vertical Lines
        adda.l   #1276,a2
        move.l  d4,(a3)+
        adda.l   #1276,a3
        dbra    d7,.loopy

.outbx:
    movem.l (sp)+,d0-d7/a0-a3
    rts

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; tdBoxFill(a0,d0,d1,d2,d3,d4)       
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;       BufferAddress in A0 
;       Xo Coordinate in d0
;       Yo Coordinate in d1
;       Xe Coordinate in d2
;       Ye Coordinate in d3
;               Color in d4
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
tdBoxFill
    movem.l d0-d7/a0,-(sp)
        cmp.w   #319,d0	    ; First, check if any of the coordinates
        bhi     .outbx      ; exceeds the screen. If any of the coordinates
        tst.w   d0
        bmi     .outbx

        cmp.w   #239,d1     ; does, then we just skip the whole routine.
        bhi     .outbx
        tst.w   d1
        bmi     .outbx

        cmp.w   #319,d2
        bhi     .outbx
        tst.w   d2
        bmi     .outbx

        cmp.w   #239,d3
        bhi     .outbx
        tst.w   d3
        bmi     .outbx
        

        cmp.w   d0,d2       ; Xe must be greater than Xo <=> d2 > d0
        bhi     .contx
        exg     d2,d0       ; d0 > d2 then swap coords
.contx:
        cmp.w   d1,d3       ; Ye must be greater than Yo <=> d3 > d1
        bhi     .conty
        exg     d3,d1       ; d1 > d3 then swap coords
.conty:

        sub.l   d0,d2	    ; Calc delta x
	    sub.l   d1,d3       ; Calc delta y
        
        move.l  d2,d7       ; Keep delta x
        
        move.l  d1,d5       ; *-  Prepare a0 from point(Xo,Yo)
        lsl.l   #6,d1       ; *
        lsl.l   #8,d5       ; *
        add.l   d5,d1       ; *-  y*320 optimized
        add.l   d0,d1       ; *-  +x
        lsl.l   #2,d1       ; *-  *4  for xRGB32 colors buffer
        adda.l  d1,a0       ; *-  place A0 on location Xo,Yo
        
        move.l  #319,d5
        sub.l   d2,d5
        lsl.l   #2,d5

.loopy:
        move.l  d7,d2       ; Init delta x each loopy
.loopx:
        move.l  d4,(a0)+    ; Horizontal Lines
        dbra    d2,.loopx

        adda.l  d5,a0       ; Vertical Jump Down +d5
        dbra    d3,.loopy


.outbx:
    movem.l (sp)+,d0-d7/a0
    rts

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; tdDrawStars(a0,a1,d0,d1)       
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;      Render Buffer Address in A0 
;       Stars Buffer Address in A1
;               Stars Number in D0
;                  Draw Mode in D1 ( 0 - normal
;                                  ( 1 - flashing 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
tdDrawStars
    movem.l     d0-d7/a0-a2,-(sp)
    fmovem.l    fp0-fp1,-(sp)
   
    move.l  a0,a2           ; Keep frame buffer address
    move.w  #$A4B8,d5
.loopstr:
    move.l  a2,a0           ; Init frame buffer address
    
    fmove.s (a1)+,fp0       ; Get x float
    fmove.s (a1)+,fp1       ; Get y float
    fint    fp0
    fint    fp1
    fmove.l fp0,d2          ; Get x integer
    fmove.l fp1,d3          ; Get y integer

    cmp.l   #319,d2	        ; First, check if any of the coordinates
    bhi     .outstr         ; exceeds the screen. If any of the coordinates
    tst.l   d2
    bmi     .outstr

    cmp.l   #239,d3         ; does, then we just skip the whole routine.
    bhi     .outstr
    tst.l   d3              ; D2,D3 (x,y) pixel
    bmi     .outstr

    move.l  d3,d4           ; *-  (y=d3=d4)*320
    lsl.l   #6,d3           ; *
    lsl.l   #8,d4           ; *
    add.l   d4,d3           ; *-  y*320 optimized
    add.l   d2,d3           ; *-  +x (+d2)
    lsl.l   #2,d3           ; *-  *4  for xRGB32 colors buffer
    adda.l  d3,a0           ; *-  place A0 on location X,Y

    tst.b   d1
    beq     .normst

    add.w   #$33,d5
    lsl.l   #2,d5           ; Get random byte value from D5
    swap    d5
    move.b  d5,d6
    or.b    #$88,d6
    extb.l  d6
    move.l  d6,d7
    lsl.l   #8,d7
    add.l   d7,d6
    lsl.l   #8,d7
    add.l   d7,d6           ; Compute xRGB 32 value bright color
    
    
    move.l  d6,(a0)         ; Place random bright in pixel location
    
    bra     .brlop
        
.normst:    
    move.l  #$00CCCCCC,(a0) ; Place normal bright in pixel location

.brlop:
        dbra    d0,.loopstr

.outstr:
    fmovem.l    (sp)+,fp0-fp1
    movem.l     (sp)+,d0-d7/a0-a2
    rts

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; tdMovRotStars(a0,d0,d1,d2,d3,d4,d5)       
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;       Stars Buffer Address in A0 
;              X Translation in D0
;              Y Translation in D1
;          X Rotation Center in D2
;          Y Rotation Center in D3  
;          Angle Of Rotation in D4 (degree value)
;               Stars Number in D5
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
tdMovRotStars
    movem.l     d0-d5/a0,-(sp)
    fmovem.l    fp0-fp7,-(sp)
    
    fmove.l     d4,fp1      ; Angle in degree integer to float
    fmovecr     #$00,fp0    ; Get pi from FPU ROM ( $00 -> pi )
    fmul        #180,fp0    ; pi * 180
    fdiv        fp0,fp1     ; a = Angle /(pi * 180)
    fcos        fp1,fp2     ; Get c=cos(a) from radian angle
    fsin        fp1,fp3     ; Get s=sin(a) from radian angle

;    fsincos     fp1,fp2:fp3 ; Get c=cos(a) and s=sin(a) from radian angle

    fmove.l     d2,fp4      ; xc = fxc          -> Get fxc rotate center
    fmove.l     d3,fp5      ; yc = fyc          -> Get fyc rotate center

.loopmr:
    fmove.s     (a0)+,fp0   ; Get tx float from stars buffer
    fmove.s     (a0)+,fp1   ; Get ty float from stars buffer
;-------------------------------------------------
    fmove.x     fp1,fp6     ; tpx  = ty         -> Keep tx coord
    fsub        fp5,fp6     ; tpx  = tpx - fyc
    fmul        fp3,fp6     ; tpx  = tpx * s
    
    fmove.x     fp0,fp7     ; tmpx = tx
    fsub        fp4,fp7     ; tmpx = tmpx - fxc
    fmul        fp2,fp7     ; tmpx = tmpx * c
    fsub        fp6,fp7     ; tmpx = tmpx - tpx
    fmove.l     d0,fp6      ; fxd  = xd          -> Get fxd translation
    fadd        fp6,fp7     ; tmpx = tmpx + fxd
    fadd        fp4,fp7     ; tmpx = tmpx + fxc
    
    fcmp.l      #0,fp7      ; 0 < tmpy < 319 ?
    fblt        .xleszero
    fcmp.l      #319,fp7
    fbgt        .xgremax
    bra         .endstx
.xleszero:
    fadd.l      #319,fp7
    bra         .endstx
.xgremax:
    fsub.l      #319,fp7
.endstx:
    suba.l      #8,a0
    fmove.s     fp7,(a0)+   ; Modify stars x float coord
;-------------------------------------------------
    fmove.x     fp1,fp6     ; tpy  = ty         -> Keep ty coord
    fsub        fp5,fp6     ; tpy  = tpy - fyc
    fmul        fp2,fp6     ; tpy  = tpy * c
    
    fmove.x     fp0,fp7     ; tmpy = tx
    fsub        fp4,fp7     ; tmpy = tmpy - fxc
    fmul        fp3,fp7     ; tmpy = tmpy * s
    fadd        fp6,fp7     ; tmpy = tmpy + tpy
    fmove.l     d1,fp6      ; fyd  = yd         -> Get fyd translation
    fadd        fp6,fp7     ; tmpy = tmpy + fyd
    fadd        fp5,fp7     ; tmpy = tmpy + fyc
    
    fcmp.l      #0,fp7      ; 0 < tmpy < 239 ?
    fblt        .yleszero
    fcmp.l      #239,fp7
    fbgt        .ygremax
    bra         .endsty
.yleszero:
    fadd.l      #239,fp7
    bra         .endsty
.ygremax:
    fsub.l      #239,fp7
.endsty:
    fmove.s     fp7,(a0)+   ; Modify stars y float coord
;-------------------------------------------------
    dbra    d5,.loopmr
.outmr:
    fmovem.l    (sp)+,fp0-fp7
    movem.l     (sp)+,d0-d5/a0
    rts





;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; tdSetLight(d0,d1,d2,d3,d4,d5)       
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;      Light Xo position in D0 (integer) \
;            Yo position in D1 (integer)  |
;            Zo position in D2 (integer) /
;            -----------------------------> 2 pts to define a vector
;            Xe position in D3 (integer) \
;            Ye position in D4 (integer)  |
;            Ze position in D5 (integer) /
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
tdSetLight
    movem.l     d0-d5/a0,-(sp)
    lea         lightprm(pc),a0 ; Get address of light parameter tab
    move.l      d0,(a0)
    move.l      d1,4(a0)
    move.l      d2,8(a0)
    move.l      d3,12(a0)
    move.l      d4,16(a0)
    move.l      d5,20(a0)
    movem.l     (sp)+,d0-d5/a0
    rts



    
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; tdSetCamera(d0,d1,d2,d3,d4,d5)       
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;           Camera X position in D0 (integer)
;                  Y position in D1 (integer)
;                  Z position in D2 (integer)
;                    an Angle in D3 (degree value) 
;                    bn Angle in D4 (degree value)
;                    cn Angle in D5 (degree value) 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
tdSetCamera
    movem.l     d0-d5/a0-a2,-(sp)
    fmovem.l    fp0-fp2,-(sp)
;-------------------------------------------------------------------
    lea         camera(pc),a0 ; Get address of camera position tab
;-------------------------------------------------------------------
    move.l      d0,(a0)         ;
    move.l      d1,4(a0)        ;
    move.l      d2,8(a0)        ;   Store parameters for camera
    move.l      d3,12(a0)       ;
    move.l      d4,16(a0)       ;
    move.l      d5,20(a0)       ;
;-------------------------------------------------------------------
    exg         d3,d0           ;   Get Angles in d0,d1,d2
    exg         d4,d1           ;   -
    exg         d5,d2           ;   -
    jsr         tdGetMatrix     ;   Pre-Calculate object-pos matrix from camera angles
;-------------------------------------------------------------------
    lea         lightvec(pc),a1 ; Get address of light vector tab
    lea         lightprm(pc),a2 ; Get address of light parameter tab
;-------------------------------------------------------------------
    move.l      (a2),d0         ;
    move.l      4(a2),d1        ;
    move.l      8(a2),d2        ;   Get parameters of light
    move.l      12(a2),d3       ;
    move.l      16(a2),d4       ;
    move.l      20(a2),d5       ;
;-------------------------------------------------------------------
    sub.l       (a0),d0         ;
    sub.l       4(a0),d1        ;   Modify light parameters according to camera
    sub.l       8(a0),d2        ;
;-------------------------------------------------------------------
    jsr         tdRotCoord      ;   Get new coords for light first point
;-------------------------------------------------------------------
    sub.l       (a0),d3         ;
    sub.l       4(a0),d4        ;   Modify light parameters according to camera
    sub.l       8(a0),d5        ;
;-------------------------------- 
    exg         d3,d0           ;
    exg         d4,d1           ;   Exchange coords of first and second pts
    exg         d5,d2           ;
;-------------------------------------------------------------------
    jsr         tdRotCoord      ;   Get new coords for light second point
;-------------------------------------------------------------------
    sub.l       d0,d3           ;
    sub.l       d1,d4           ;   Get Vector values of light
    sub.l       d2,d5           ;
;-------------------------------------------------------------------
    fmove.l     d3,fp0          ;
    fmove.l     d4,fp1          ;   Convert Long to Float values of light vector
    fmove.l     d5,fp2          ;
;-------------------------------------------------------------------
    fmove.s     fp0,(a1)        ;
    fmove.s     fp1,4(a1)       ;   Store Float values of light vector
    fmove.s     fp2,8(a1)       ;
;-------------------------------------------------------------------
    fmovem.l    (sp)+,fp0-fp2
    movem.l     (sp)+,d0-d5/a0-a2
    rts








;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; tdGetMatrix(d0,d1,d2)
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;                    an Angle in D0 (degree value) 
;                    bn Angle in D1 (degree value)
;                    cn Angle in D2 (degree value) 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
tdGetMatrix
    movem.l     d0-d2/a0,-(sp)
    fmovem.l    fp0-fp7,-(sp)
;-------------------------------------------------------------------
;-------------------------------------------------------------------
    fmovecr     #$00,fp7        ; Get pi from FPU rom
    fdiv        #180,fp7        ; pi/180
;-------------------------------------------------------------------
    fmove.l     d0,fp0          ; Angle an to float FP0 (degree)
    fmove.l     d1,fp2          ; Angle bn to float FP2 (degree)
    fmove.l     d2,fp4          ; Angle cn to float FP4 (degree)
;-------------------------------------------------------------------
    fmul        fp7,fp0         ; a = an * pi/180 (radians)
    fmul        fp7,fp2         ; b = bn * pi/180 (radians)
    fmul        fp7,fp4         ; c = cn * pi/180 (radians)
;-------------------------------------------------------------------
    fsin        fp0,fp1         ; sin a = FP1 = sa
    fcos        fp0,fp0         ; cos a = FP0 = ca
    fsin        fp2,fp3         ; sin b = FP3 = sb
    fcos        fp2,fp2         ; cos b = FP2 = cb
    fsin        fp4,fp5         ; sin c = FP5 = sc
    fcos        fp4,fp4         ; cos c = FP4 = cc
;-------------------------------------------------------------------
;-------------------------------------------------------------------
    lea         obmatrix(pc),a0 ; Get address of matrix tab -> Store 9 Matrix Values
;-------------------------------------------------------------------
;-------------------------------------------------------------------
    fmove.x     fp0,fp6         ;   xx  = ca
    fmul        fp2,fp6         ;       = ca * cb 
    fmove.s     fp6,(a0)        ; obmatrix 00 : [xx]
;-------------------------------;
    fmove.x     fp1,fp6         ;   xy  = sa
    fmul        fp2,fp6         ;       = sa * cb
    fmove.s     fp6,4(a0)       ; obmatrix 04 : [xy]
;-------------------------------;                                
                                ;   xz  = sb    
    fmove.s     fp3,8(a0)       ; obmatrix 08 : [xz]
;-------------------------------------------------------------------
    fmove.x     fp4,fp6         ;   yx  =  cc
    fmul        fp1,fp6         ;       = (cc * sa)
    fmove.x     fp5,fp7         ;                   + (sc)
    fmul        fp3,fp7         ;                   + (sc * sb)
    fmul        fp0,fp7         ;                   + (sc * sb * ca)
    fadd        fp6,fp7         ;   yx  = (cc * sa) + (sc * sb * ca)
    fmove.s     fp7,12(a0)      ; obmatrix 12 : [yx]
;-------------------------------;    
    fmove.x     fp4,fp6         ;   yy  =   cc
    fmul        fp0,fp6         ;       =  (cc * ca)
    fneg        fp6             ;       = -(cc * ca)
    fmove.x     fp5,fp7         ;                    + (sc)
    fmul        fp3,fp7         ;                    + (sc * sb)
    fmul        fp1,fp7         ;                    + (sc * sb * sa)
    fadd        fp6,fp7         ;   yy  = -(cc * ca) + (sc * sb * sa)
    fmove.s     fp7,16(a0)      ;  obmatrix 16 : [yy]
;-------------------------------;    
    fmove.x     fp5,fp6         ;   yz  =  sc
    fmul        fp2,fp6         ;       =  sc * cb
    fneg        fp6             ;       =-(sc * cb)
    fmove.s     fp6,20(a0)      ;  obmatrix 20 : [yz]
;-------------------------------------------------------------------
    fmove.x     fp5,fp6         ;   zx  =  sc
    fmul        fp1,fp6         ;       = (sc * sa)
    fmove.x     fp4,fp7         ;       - (cc) 
    fmul        fp3,fp7         ;       - (cc * sb)
    fmul        fp0,fp7         ;       - (cc * sb * ca)
    fsub        fp7,fp6         ;   zx  = (sc * sa) - (cc * sb * ca)
    fmove.s     fp6,24(a0)      ;  obmatrix 24 : [zx]
;-------------------------------;
    fmove.x     fp5,fp6         ;   zy  =  sc
    fmul        fp0,fp6         ;       = (sc * ca)
    fneg        fp6             ;       = - (sc * ca)
    fmove.x     fp4,fp7         ;       - (cc) 
    fmul        fp3,fp7         ;       - (cc * sb)
    fmul        fp1,fp7         ;       - (cc * sb * sa)
    fsub        fp7,fp6         ;   zy  = - (sc * ca) - (cc * sb * sa)
    fmove.s     fp6,28(a0)      ;  obmatrix 28 : [zy]
;-------------------------------;    
    fmove.x     fp4,fp6         ;   zz  = cc
    fmul        fp2,fp6         ;       = cc * cb
    fmove.s     fp6,32(a0)      ;  obmatrix 32 : [zz]
;-------------------------------------------------------------------
;-------------------------------------------------------------------
    fmovem.l    (sp)+,fp0-fp7
    movem.l     (sp)+,d0-d2/a0
    rts







;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; tdRotCoord(d0,d1,d2)
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;                  X position in D0 (integer)
;                  Y position in D1 (integer)
;                  Z position in D2 (integer)
;
; Return Xrot,Yrot,Zrot in D0,D1,D2
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
tdRotCoord
    movem.l     a0,-(sp)
    fmovem.l    fp0-fp6,-(sp)
    ;-----------------------------------------------------
    ;  Point (X,Y,Z) = (Xrot,Yrot,Zrot)  rotated by obmatrix
    ;-----------------------------------------------------
    lea         obmatrix(pc),a0   ; Get address of obmatrix tab     -> Store 9 Matrix Values

    fmove.l     d0,fp0          ; xao to FP0 float from object buffer
    fmove.l     d1,fp1          ; yao to FP1 float from object buffer
    fmove.l     d2,fp2          ; zao to FP2 float from object buffer
    
    fmove.s     (a0),fp3        ;           Get obmatrix:[00] = xx
    fmul        fp0,fp3         ;  xx * xao
    fmove.s     4(a0),fp4       ;           Get obmatrix:[04] = xy
    fmul        fp1,fp4         ;  xy * yao
    fadd        fp4,fp3         ; (xx * xao)+(xy * yao)
    fmove.s     8(a0),fp4       ;           Get obmatrix:[08] = xz
    fmul        fp2,fp4         ;  xz * zao
    fadd        fp4,fp3         ; (xx * xao)+(xy * yao)+(xz * zao) = fp3 = xa
    fmove.l     fp3,d0          ; return Xrot

    fmove.s     12(a0),fp4      ;           Get obmatrix:[12] = yx
    fmul        fp0,fp4         ;  yx * xao
    fmove.s     16(a0),fp5      ;           Get obmatrix:[16] = yy
    fmul        fp1,fp5         ;  yy * yao
    fadd        fp5,fp4         ; (yx * xao)+(yy * yao)
    fmove.s     20(a0),fp5      ;           Get obmatrix:[20] = yz
    fmul        fp2,fp5         ;  yz * zao
    fadd        fp5,fp4         ; (yx * xao)+(yy * yao)+(yz * zao) = fp4 = ya
    fmove.l     fp4,d1          ; return Yrot
    
    fmove.s     24(a0),fp5      ;           Get obmatrix:[24] = zx
    fmul        fp0,fp5         ;  zx * xao
    fmove.s     28(a0),fp6      ;           Get obmatrix:[28] = zy
    fmul        fp1,fp6         ;  zy * yao
    fadd        fp6,fp5         ; (zx * xao)+(zy * yao)
    fmove.s     32(a0),fp6      ;           Get obmatrix:[32] = zz
    fmul        fp2,fp6         ;  zz * zao
    fadd        fp6,fp5         ; (zx * xao)+(zy * yao)+(zz * zao) = fp5 = za
    fmove.l     fp5,d2          ; return Zrot
    ;-----------------------------------------------------
    fmovem.l    (sp)+,fp0-fp6
    movem.l     (sp)+,a0
    rts







    
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; tdDrwObFrmCam(a0,a1,d0,d1,d2,d3,d4,d5)       
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;        Frame Buffer Address in A0 
; Object Faces Buffer Address in A1 
;           Object X position in D0 (integer)
;                  Y position in D1 (integer)
;                  Z position in D2 (integer)
;                    an Angle in D3 (degree value) 
;                    bn Angle in D4 (degree value)
;                    cn Angle in D5 (degree value) 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
tdDrwObFrmCam
    movem.l     d0-d6/a0-a2,-(sp)
;-------------------------------------------------------------------
    lea         camera(pc),a2   ; Get address of camera position tab
;-------------------------------------------------------------------
    sub.l       (a2),d0
    sub.l       4(a2),d1
    sub.l       8(a2),d2
    add.l       12(a2),d3
    add.l       16(a2),d4
    add.l       20(a2),d5
    jsr         tdRotCoord      ; Get new coords for object from camera matrix
;-------------------------------------------------------------------
    tst.l       d2              ; Zo > 0 ?
    bmi         .enddofcam      ;        * Zo < 0 so EXIT

    move.l      #0,d6           ; Z =     0
    sub.l       #240,d6         ;   =  -240
    muls.l      d0,d6           ;   = (-240 * Xo)
    divs.l      #160,d6         ;   = (-240 * Xo)/160
    sub.l       #240,d6         ;   =((-240 * Xo)/160)-240
    cmp.l       d6,d2           ; Zo > Z ?
    ble         .enddofcam      ;        * Zo <= Z so EXIT
    
    move.l      #240,d6         ; Z =   240
    muls.l      d0,d6           ;   =  (240 * Xo)
    divs.l      #160,d6         ;   =  (240 * Xo)/160
    sub.l       #240,d6         ;   = ((240 * Xo)/160)-240
    cmp.l       d6,d2           ; Zo > Z ?
    ble         .enddofcam      ;        * Zo <= Z so EXIT
                                
    move.l      #0,d6           ; Z =     0
    sub.l       #240,d6         ;   =  -240
    muls.l      d1,d6           ;   = (-240 * Yo)
    divs.l      #120,d6         ;   = (-240 * Yo)/120
    sub.l       #240,d6         ;   =((-240 * Yo)/120)-240
    cmp.l       d6,d2           ; Zo > Z ?
    ble         .enddofcam      ;        * Zo <= Z so EXIT
    
    move.l      #240,d6         ; Z =   240
    muls.l      d1,d6           ;   =  (240 * Yo)
    divs.l      #120,d6         ;   =  (240 * Yo)/120
    sub.l       #240,d6         ;   = ((240 * Yo)/120)-240
    cmp.l       d6,d2           ; Zo > Z ?
    ble         .enddofcam      ;        * Zo <= Z so EXIT
    
    jsr         tdDrawObject
;-------------------------------------------------------------------
.enddofcam:
    movem.l     (sp)+,d0-d6/a0-a2
    rts









;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; tdDrawObject(a0,a1,d0,d1,d2,d3,d4,d5)       
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;        Frame Buffer Address in A0 
; Object Faces Buffer Address in A1 
;           Object X position in D0 (integer)
;                  Y position in D1 (integer)
;                  Z position in D2 (integer)
;                    an Angle in D3 (degree value) 
;                    bn Angle in D4 (degree value)
;                    cn Angle in D5 (degree value) 
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
tdDrawObject
    movem.l     d0-d7/a0-a4,-(sp)
    fmovem.l    fp0-fp7,-(sp)
;-------------------------------------------------------------------
HSCRX   equ.l   160
HSCRY   equ.l   120
DIST    equ.l   240
;-------------------------------------------------------------------
    fmovecr     #$00,fp7        ; Get pi from FPU rom
    fdiv        #180,fp7        ; pi/180
;-------------------------------------------------------------------
    fmove.l     d3,fp0          ; Angle an to float FP0 (degree)
    fmove.l     d4,fp2          ; Angle bn to float FP2 (degree)
    fmove.l     d5,fp4          ; Angle cn to float FP4 (degree)
;-------------------------------------------------------------------
    fmul        fp7,fp0         ; a = an * pi/180 (radians)
    fmul        fp7,fp2         ; b = bn * pi/180 (radians)
    fmul        fp7,fp4         ; c = cn * pi/180 (radians)
;-------------------------------------------------------------------
    fsin        fp0,fp1         ; sin a = FP1 = sa
    fcos        fp0,fp0         ; cos a = FP0 = ca
    fsin        fp2,fp3         ; sin b = FP3 = sb
    fcos        fp2,fp2         ; cos b = FP2 = cb
    fsin        fp4,fp5         ; sin c = FP5 = sc
    fcos        fp4,fp4         ; cos c = FP4 = cc
;-------------------------------------------------------------------
;-------------------------------------------------------------------
    lea         fcmatrix(pc),a2 ; Get address of fcmatrix tab -> Store 9 Matrix Values
    lea         faces(pc),a3    ; Get address of faces tab    -> Store 3 x 2D Faces
    lea         tdfaces(pc),a4  ; Get address of tdfaces tab  -> Store 1 x 3D Faces
;-------------------------------------------------------------------
;-------------------------------------------------------------------
    fmove.x     fp0,fp6         ;   xx  = ca
    fmul        fp2,fp6         ;       = ca * cb 
    fmove.s     fp6,(a2)        ; fcmatrix 00 : [xx]
;-------------------------------;
    fmove.x     fp1,fp6         ;   xy  = sa
    fmul        fp2,fp6         ;       = sa * cb
    fmove.s     fp6,4(a2)       ; fcmatrix 04 : [xy]
;-------------------------------;                                
                                ;   xz  = sb    
    fmove.s     fp3,8(a2)       ; fcmatrix 08 : [xz]
;-------------------------------------------------------------------
    fmove.x     fp4,fp6         ;   yx  =  cc
    fmul        fp1,fp6         ;       = (cc * sa)
    fmove.x     fp5,fp7         ;                   + (sc)
    fmul        fp3,fp7         ;                   + (sc * sb)
    fmul        fp0,fp7         ;                   + (sc * sb * ca)
    fadd        fp6,fp7         ;   yx  = (cc * sa) + (sc * sb * ca)
    fmove.s     fp7,12(a2)      ; fcmatrix 12 : [yx]
;-------------------------------;    
    fmove.x     fp4,fp6         ;   yy  =   cc
    fmul        fp0,fp6         ;       =  (cc * ca)
    fneg        fp6             ;       = -(cc * ca)
    fmove.x     fp5,fp7         ;                    + (sc)
    fmul        fp3,fp7         ;                    + (sc * sb)
    fmul        fp1,fp7         ;                    + (sc * sb * sa)
    fadd        fp6,fp7         ;   yy  = -(cc * ca) + (sc * sb * sa)
    fmove.s     fp7,16(a2)      ;  fcmatrix 16 : [yy]
;-------------------------------;    
    fmove.x     fp5,fp6         ;   yz  =  sc
    fmul        fp2,fp6         ;       =  sc * cb
    fneg        fp6             ;       =-(sc * cb)
    fmove.s     fp6,20(a2)      ;  fcmatrix 20 : [yz]
;-------------------------------------------------------------------
    fmove.x     fp5,fp6         ;   zx  =  sc
    fmul        fp1,fp6         ;       = (sc * sa)
    fmove.x     fp4,fp7         ;       - (cc) 
    fmul        fp3,fp7         ;       - (cc * sb)
    fmul        fp0,fp7         ;       - (cc * sb * ca)
    fsub        fp7,fp6         ;   zx  = (sc * sa) - (cc * sb * ca)
    fmove.s     fp6,24(a2)      ;  fcmatrix 24 : [zx]
;-------------------------------;
    fmove.x     fp5,fp6         ;   zy  =  sc
    fmul        fp0,fp6         ;       = (sc * ca)
    fneg        fp6             ;       = - (sc * ca)
    fmove.x     fp4,fp7         ;       - (cc) 
    fmul        fp3,fp7         ;       - (cc * sb)
    fmul        fp1,fp7         ;       - (cc * sb * sa)
    fsub        fp7,fp6         ;   zy  = - (sc * ca) - (cc * sb * sa)
    fmove.s     fp6,28(a2)      ;  fcmatrix 28 : [zy]
;-------------------------------;    
    fmove.x     fp4,fp6         ;   zz  = cc
    fmul        fp2,fp6         ;       = cc * cb
    fmove.s     fp6,32(a2)      ;  fcmatrix 32 : [zz]
;-------------------------------------------------------------------
;-------------------------------------------------------------------


    move.l      (a1)+,d3        ; nb of point for first polygon

;=================================================
; Polygon Trace Loop =============================
;=================================================
.loopface:    
    
    move.l      (a1)+,d4        ; colour of polygon
    
    ;  First point XA,YA,ZA = rotated by fcmatrix
    ;--------------------------------------------
    
    fmove.l     (a1)+,fp0          ; xao to FP0 float from object buffer
    fmove.l     (a1)+,fp1          ; yao to FP1 float from object buffer
    fmove.l     (a1)+,fp2          ; zao to FP2 float from object buffer
    
    fmove.s     (a2),fp3        ;           Get fcmatrix:[00] = xx
    fmul        fp0,fp3         ;  xx * xao
    fmove.s     4(a2),fp4       ;           Get fcmatrix:[04] = xy
    fmul        fp1,fp4         ;  xy * yao
    fadd        fp4,fp3         ; (xx * xao)+(xy * yao)
    fmove.s     8(a2),fp4       ;           Get fcmatrix:[08] = xz
    fmul        fp2,fp4         ;  xz * zao
    fadd        fp4,fp3         ; (xx * xao)+(xy * yao)+(xz * zao) = fp3 = xa
    fmove.s     fp3,(a4)        ; Store xa = tdfaces:[00]

    fmove.s     12(a2),fp4      ;           Get fcmatrix:[12] = yx
    fmul        fp0,fp4         ;  yx * xao
    fmove.s     16(a2),fp5      ;           Get fcmatrix:[16] = yy
    fmul        fp1,fp5         ;  yy * yao
    fadd        fp5,fp4         ; (yx * xao)+(yy * yao)
    fmove.s     20(a2),fp5      ;           Get fcmatrix:[20] = yz
    fmul        fp2,fp5         ;  yz * zao
    fadd        fp5,fp4         ; (yx * xao)+(yy * yao)+(yz * zao) = fp4 = ya
    fmove.s     fp4,4(a4)       ; Store ya = tdfaces:[04]
    
    fmove.s     24(a2),fp5      ;           Get fcmatrix:[24] = zx
    fmul        fp0,fp5         ;  zx * xao
    fmove.s     28(a2),fp6      ;           Get fcmatrix:[28] = zy
    fmul        fp1,fp6         ;  zy * yao
    fadd        fp6,fp5         ; (zx * xao)+(zy * yao)
    fmove.s     32(a2),fp6      ;           Get fcmatrix:[32] = zz
    fmul        fp2,fp6         ;  zz * zao
    fadd        fp6,fp5         ; (zx * xao)+(zy * yao)+(zz * zao) = fp5 = za
    fmove.s     fp5,8(a4)       ; Store za = tdfaces:[08]

    ;  First point XAp,YAp = projection of XA,YA,ZA on screen
    ;--------------------------------------------------------
    fmove.l     d0,fp6          ; xpos to FP6 float
    fadd        fp3,fp6         ;  xpos + xa
    fmul.l      #DIST,fp6       ; (xpos + xa ) * dist
    fmove.l     d2,fp7          ; zpos to FP7 float
    fadd        fp5,fp7         ;  zpos + za
    fdiv        fp7,fp6         ;[(xpos + xa ) * dist]/(zpos + za) = [*]
    fadd.l      #HSCRX,fp6      ;   [*] + xe = XAp
    fmove.l     fp6,(a3)        ;  faces 00 : [xap]
    
    fmove.l     d1,fp6          ; ypos to FP6 float
    fadd        fp4,fp6         ;  ypos + ya
    fmul.l      #DIST,fp6       ; (ypos + ya ) * dist
    fmove.l     d2,fp7          ; zpos to FP7 float
    fadd        fp5,fp7         ;  zpos + za
    fdiv        fp7,fp6         ;[(ypos + ya ) * dist]/(zpos + za) = [*]
    fadd.l      #HSCRY,fp6       ;   [*] + ye = YAp
    fmove.l     fp6,4(a3)        ;  faces 04 : [yap]



    ;  Second point XB,YB,ZB = rotated by fcmatrix
    ;---------------------------------------------

    fmove.l     (a1)+,fp0       ; xbo to FP0 float from object buffer
    fmove.l     (a1)+,fp1       ; ybo to FP1 float from object buffer
    fmove.l     (a1)+,fp2       ; zbo to FP2 float from object buffer

    fmove.s     (a2),fp3
    fmul        fp0,fp3
    fmove.s     4(a2),fp4
    fmul        fp1,fp4
    fadd        fp4,fp3
    fmove.s     8(a2),fp4
    fmul        fp2,fp4
    fadd        fp4,fp3         ; fp3 = xb
    fmove.s     fp3,12(a4)      ; Store xb = tdfaces:[12]

    fmove.s     12(a2),fp4
    fmul        fp0,fp4
    fmove.s     16(a2),fp5
    fmul        fp1,fp5
    fadd        fp5,fp4
    fmove.s     20(a2),fp5
    fmul        fp2,fp5
    fadd        fp5,fp4         ; fp4 = yb
    fmove.s     fp4,16(a4)      ; Store yb = tdfaces:[16]
    
    fmove.s     24(a2),fp5
    fmul        fp0,fp5
    fmove.s     28(a2),fp6
    fmul        fp1,fp6
    fadd        fp6,fp5
    fmove.s     32(a2),fp6
    fmul        fp2,fp6
    fadd        fp6,fp5         ; fp5 = zb
    fmove.s     fp5,20(a4)      ; Store zb = tdfaces:[20]

    ;  Second point XBp,YBp = projection of XB,YB,ZB on screen
    ;---------------------------------------------------------
    fmove.l     d0,fp6 
    fadd        fp3,fp6
    fmul.l      #DIST,fp6
    fmove.l     d2,fp7 
    fadd        fp5,fp7
    fdiv        fp7,fp6
    fadd.l      #HSCRX,fp6
    fmove.l     fp6,8(a3)        ;  faces 08 : [xbp]
    
    fmove.l     d1,fp6 
    fadd        fp4,fp6
    fmul.l      #DIST,fp6
    fmove.l     d2,fp7 
    fadd        fp5,fp7
    fdiv        fp7,fp6
    fadd.l      #HSCRY,fp6
    fmove.l     fp6,12(a3)        ;  faces 12 : [ybp]

    
    ;  Third point XC,YC,ZC = rotated by fcmatrix
    ;--------------------------------------------

    fmove.l     (a1)+,fp0          ; xco to FP0 float from object buffer
    fmove.l     (a1)+,fp1          ; yco to FP1 float from object buffer
    fmove.l     (a1)+,fp2          ; zco to FP2 float from object buffer
    
    fmove.s     (a2),fp3
    fmul        fp0,fp3
    fmove.s     4(a2),fp4
    fmul        fp1,fp4
    fadd        fp4,fp3
    fmove.s     8(a2),fp4
    fmul        fp2,fp4
    fadd        fp4,fp3         ; fp3 = xc
    fmove.s     fp3,24(a4)      ; Store xc = tdfaces:[24]

    fmove.s     12(a2),fp4
    fmul        fp0,fp4
    fmove.s     16(a2),fp5
    fmul        fp1,fp5
    fadd        fp5,fp4
    fmove.s     20(a2),fp5
    fmul        fp2,fp5
    fadd        fp5,fp4         ; fp4 = yc
    fmove.s     fp4,28(a4)      ; Store yc = tdfaces:[28]
    
    fmove.s     24(a2),fp5
    fmul        fp0,fp5
    fmove.s     28(a2),fp6
    fmul        fp1,fp6
    fadd        fp6,fp5
    fmove.s     32(a2),fp6
    fmul        fp2,fp6
    fadd        fp6,fp5         ; fp5 = zc
    fmove.s     fp5,32(a4)      ; Store zc = tdfaces:[32]

    ;  Third point XCp,YCp = projection of XC,YC,ZC on screen
    ;--------------------------------------------------------
    fmove.l     d0,fp6 
    fadd        fp3,fp6
    fmul.l      #DIST,fp6
    fmove.l     d2,fp7 
    fadd        fp5,fp7
    fdiv        fp7,fp6
    fadd.l      #HSCRX,fp6
    fmove.l     fp6,16(a3)        ;  faces 16 : [xcp]
    
    fmove.l     d1,fp6 
    fadd        fp4,fp6
    fmul.l      #DIST,fp6
    fmove.l     d2,fp7 
    fadd        fp5,fp7
    fdiv        fp7,fp6
    fadd.l      #HSCRY,fp6
    fmove.l     fp6,20(a3)        ;  faces 20 : [ycp]


;-------------------------------------------------
    
    cmp.l       #3,d3           ; 3 or 4 lines for polygon ?
    bne         .quad
    
;------------------------------------------------- 3 LINES
    move.l      16(a3),d5
    sub.l       (a3),d5
    move.l      12(a3),d6
    sub.l       4(a3),d6
    muls.l      d6,d5
    move.l      8(a3),d6
    sub.l       (a3),d6
    move.l      20(a3),d7
    sub.l       4(a3),d7
    muls.l      d7,d6
    sub.l       d6,d5           ; Normal Vector after 3D to 2D
;-------------------------------------------------
    move.l      (a1)+,d6        ; Get shading flag for this face
    tst.b       d6
    beq         .nomodcol1      ; 0 - No shading
    jsr         .modifcol       ; 1 - adapt color value according to light
.nomodcol1:
;-------------------------------------------------
    cmp.l       #0,d5           ; if normal < 0 then draw polygon
    bge         .tstendloop     ; normal > 0 so no visible
    jsr         .filltria       ; normal < 0 so draw polygon
    bra         .tstendloop

;------------------------------------------------- 4 LINES
.quad:
    ;  Fourth point XD,YD,ZD = rotated by fcmatrix
    ;---------------------------------------------

    fmove.l     (a1)+,fp0       ; xdo to FP0 float from object buffer
    fmove.l     (a1)+,fp1       ; ydo to FP1 float from object buffer
    fmove.l     (a1)+,fp2       ; zdo to FP2 float from object buffer
    
    fmove.s     (a2),fp3
    fmul        fp0,fp3
    fmove.s     4(a2),fp4
    fmul        fp1,fp4
    fadd        fp4,fp3
    fmove.s     8(a2),fp4
    fmul        fp2,fp4
    fadd        fp4,fp3         ; fp3 = xd

    fmove.s     12(a2),fp4
    fmul        fp0,fp4
    fmove.s     16(a2),fp5
    fmul        fp1,fp5
    fadd        fp5,fp4
    fmove.s     20(a2),fp5
    fmul        fp2,fp5
    fadd        fp5,fp4         ; fp4 = yd
    
    fmove.s     24(a2),fp5
    fmul        fp0,fp5
    fmove.s     28(a2),fp6
    fmul        fp1,fp6
    fadd        fp6,fp5
    fmove.s     32(a2),fp6
    fmul        fp2,fp6
    fadd        fp6,fp5         ; fp5 = zd

    ;  Fourth point XDp,YDp = projection of XD,YD,ZD on screen
    ;--------------------------------------------------------
    fmove.l     d0,fp6 
    fadd        fp3,fp6
    fmul.l      #DIST,fp6
    fmove.l     d2,fp7 
    fadd        fp5,fp7
    fdiv        fp7,fp6
    fadd.l      #HSCRX,fp6
    fmove.l     fp6,24(a3)        ;  faces 24 : [xdp]
    
    fmove.l     d1,fp6 
    fadd        fp4,fp6
    fmul.l      #DIST,fp6
    fmove.l     d2,fp7 
    fadd        fp5,fp7
    fdiv        fp7,fp6
    fadd.l      #HSCRY,fp6
    fmove.l     fp6,28(a3)        ;  faces 28 : [ydcp]

    
;-------------------------------------------------
    move.l      16(a3),d5
    sub.l       (a3),d5
    move.l      12(a3),d6
    sub.l       4(a3),d6
    muls.l      d6,d5
    move.l      8(a3),d6
    sub.l       (a3),d6
    move.l      20(a3),d7
    sub.l       4(a3),d7
    muls.l      d7,d6
    sub.l       d6,d5           ; Normal Vector after 3D to 2D
;-------------------------------------------------
    move.l      (a1)+,d6        ; Get shading flag for this face
    tst.b       d6  
    beq         .nomodcol2      ; 0 - No shading
    jsr         .modifcol       ; 1 - adapt color value according to light
.nomodcol2:
;-------------------------------------------------
    cmp.l       #0,d5           ; if normal < 0 then draw polygon
    bge         .tstendloop     ; normal > 0 so no visible
    jsr         .filltria       ; normal < 0 so draw polygon 1
    move.l      16(a3),8(a3)    ;   xcp to xbp
    move.l      20(a3),12(a3)   ;   ycp to ybp
    move.l      24(a3),16(a3)   ;   xdp to xcp
    move.l      28(a3),20(a3)   ;   ydp to ycp
    jsr         .filltria       ; draw polygon 2
;-------------------------------------------------
.tstendloop:
    move.l      (a1)+,d3        ; nb of point for next polygon
    tst.l       d3              ; or end if = 0
    bne         .loopface
;=================================================
; End Of Polygon Trace Loop ======================
;=================================================
.outdrob:
    fmovem.l    (sp)+,fp0-fp7
    movem.l     (sp)+,d0-d7/a0-a4
    rts


;-------------------------------------------------------------------------
;-------------------------------------------------------------------------
; Sub that modify color of plane according to light position
;-------------------------------------------------------------------------
.modifcol:
    movem.l     d0-d3/a0-a5,-(sp)
    fmovem.l    fp0-fp7,-(sp)
    
    ; Calculate Cos of angle between light vector and  normal of face
    ;---------------------------------------------------------------------
    lea         lightvec(pc),a5 ; Get address of light vector tab
    ;---------------------------------------------------------------------
    fmove.s     16(a4),fp0      ; Get tdfaces[16] = yb 
    fsub.s      4(a4),fp0       ; yb - ya
    fmove.s     32(a4),fp1      ; Get tdfaces[32] = zc 
    fsub.s      8(a4),fp1       ; zc - za
    fmul        fp1,fp0         ;  fp0 = (yb-ya)*(zc-za)
    fmove.s     28(a4),fp1      ; Get tdfaces[28] = yc 
    fsub.s      4(a4),fp1       ; yc - ya
    fmove.s     20(a4),fp2      ; Get tdfaces[20] = zb 
    fsub.s      8(a4),fp2       ; zb - za
    fmul        fp2,fp1         ;  fp1 = (yc-ya)*(zb-za)
    fsub        fp1,fp0         ;=>fp0 = (yb-ya)*(zc-za)-(yc-ya)*(zb-za) = n1

    fmove.s     12(a4),fp1      ; Get tdfaces[12] = xb 
    fsub.s      (a4),fp1        ; xb - xa
    fmove.s     32(a4),fp2      ; Get tdfaces[32] = zc 
    fsub.s      8(a4),fp2       ; zc - za
    fmul        fp2,fp1         ;  fp1 = (xb-xa)*(zc-za)
    fmove.s     24(a4),fp2      ; Get tdfaces[24] = xc 
    fsub.s      (a4),fp2        ; xc - xa
    fmove.s     20(a4),fp3      ; Get tdfaces[20] = zb 
    fsub.s      8(a4),fp3       ; zb - za
    fmul        fp3,fp2         ;  fp2 = (xc-xa)*(zb-za)
    fsub        fp2,fp1         ;  fp1 = (xb-xa)*(zc-za)-(xc-xa)*(zb-za)
    fneg        fp1             ;=>fp1 = -[(xb-xa)*(zc-za)-(xc-xa)*(zb-za)] = n2

    fmove.s     12(a4),fp2      ; Get tdfaces[12] = xb 
    fsub.s      (a4),fp2        ; xb - xa
    fmove.s     28(a4),fp3      ; Get tdfaces[28] = yc 
    fsub.s      4(a4),fp3       ; yc - ya
    fmul        fp3,fp2         ;  fp2 = (xb-xa)*(yc-ya)
    fmove.s     24(a4),fp3      ; Get tdfaces[24] = xc 
    fsub.s      (a4),fp3        ; xc - xa
    fmove.s     16(a4),fp4      ; Get tdfaces[16] = yb 
    fsub.s      4(a4),fp4       ; yb - ya
    fmul        fp4,fp3         ;  fp3 = (xc-xa)*(yb-ya)
    fsub        fp3,fp2         ;=>fp2 = (xb-xa)*(yc-ya)-(xc-xa)*(yb-ya) = n3

    fmove.s     (a5),fp3        ; Get lightvec[00] = L1
    fmul        fp0,fp3         ;  fp3 = n1 * L1
    fmove.s     4(a5),fp4       ; Get lightvec[04] = L2
    fmul        fp1,fp4         ;  fp4 = n2 * L2
    fadd        fp4,fp3         ;  fp3 = n1 * L1  +  n2 * L2
    fmove.s     8(a5),fp4       ; Get lightvec[08] = L3
    fmul        fp2,fp4         ;  fp4 = n3 * L3
    fadd        fp4,fp3         ;=>fp3 = n1 * L1  +  n2 * L2  +  n3 * L3
    
    fmove.x     fp0,fp4         ;  fp4 = n1
    fmul        fp4,fp4         ;      = (n1)²
    fmove.x     fp1,fp5         ;  fp5 = n2   
    fmul        fp5,fp5         ;      = (n2)²
    fadd        fp5,fp4         ;  fp4 = (n1)² + (n2)²
    fmove.x     fp2,fp5         ;  fp5 = n3
    fmul        fp5,fp5         ;      = (n3)²
    fadd        fp5,fp4         ;  fp4 = (n1)² + (n2)² + (n3)²
    fsqrt       fp4             ;=>fp4 = Fsqrt( (n1)² + (n2)² + (n3)² )

    fmove.s     (a5),fp5        ; Get lightvec[00] = L1
    fmul        fp5,fp5         ;  fp5 = (L1)²
    fmove.s     4(a5),fp6       ; Get lightvec[04] = L2
    fmul        fp6,fp6         ;  fp6 = (L2)²
    fadd        fp6,fp5         ;  fp5 = (L1)² + (L2)²
    fmove.s     8(a5),fp6       ; Get lightvec[08] = L3
    fmul        fp6,fp6         ;  fp6 = (L3)²
    fadd        fp6,fp5         ;  fp5 = (L1)² + (L2)² + (L3)²
    fsqrt       fp5             ;=>fp5 = Fsqrt( (L1)² + (L2)² + (L3)² )

    fmul        fp5,fp4         ;=>fp4 = Fsqrt((n1)²+(n2)²+(n3)²)*Fsqrt((L1)²+(L2)²+(L3)²)

    
                                ;                    ( n1*L1 + n2*L2 + n3*L3 )
    fdiv        fp4,fp3         ;=>fp3 = -------------------------------------------------
                                ;        Fsqrt((n1)²+(n2)²+(n3)²)*Fsqrt((L1)²+(L2)²+(L3)²)
                                ; Cos of angle between light vector and  normal of face
                                ;  -1 < fp3 < 1
    fmul        #255,fp3        ;-255 < fp3 < 255
    
    clr.l       d0
    clr.l       d1
    clr.l       d2
    clr.l       d3
    
    ; Extract R,G,B values from xRGB value (d4 => d0,d1,d2)
    ;---------------------------------------------------------------------
    move.l      d4,d0           ; Get xRGB color from pixel x,y in D0
    move.b      d0,d2           ; Get Blue color in D2
;    extb.l      d2
    lsr.l       #8,d0
    move.b      d0,d1           ; Get Green color in D1
;    extb.l      d1
    lsr.l       #8,d0           ; Get Red color in D0
;    extb.l      d0
    
    
    ; Modify color of face
    ;---------------------------------------------------------------------
    cmp.l       #1,d6           ; Test for texture flag
    
    fmove.l     fp3,d3
    tst.l       d3
    bmi         .nochngind
    move.l      #0,d3

.nochngind:    
    neg.l       d3
    mulu        d3,d0
    divu        #255,d0
    extb.l      d0

    mulu        d3,d1
    divu        #255,d1
    extb.l      d1

    mulu        d3,d2
    divu        #255,d2
    extb.l      d2
    
    ; Compose xRGB value from R,G,B (d0,d1,d2 => d4)
    ;---------------------------------------------------------------------
    lsl.l       #8,d1
    swap        d0              ; Get Red color in D0
    clr.w       d0
    add.w       d1,d0           ; Get Green color in D1
    add.b       d2,d0           ; Get Blue color in D2
    move.l      d0,d4

    fmovem.l    (sp)+,fp0-fp7
    movem.l     (sp)+,d0-d3/a0-a5
    rts

;-------------------------------------------------------------------------
;-------------------------------------------------------------------------
; Sub for Triangle draw lines and fill
;-------------------------------------------------------------------------
.filltria:
    movem.l     d0-d7/a0-a5,-(sp)
;-------------------------------------------------------------------------
; Draw 3 lines
;-------------------------------------------------------------------------
    move.l      (a3),d0             ;   get xap 
    move.l      4(a3),d1            ;   get yap
    move.l      8(a3),d2            ;   get xbp
    move.l      12(a3),d3           ;   get ybp
;-----------------------------------
        cmp.w   #319,d0
        bhi     .outfilltria
        tst.w   d0
        bmi     .outfilltria
        cmp.w   #239,d1
        bhi     .outfilltria
        tst.w   d1
        bmi     .outfilltria         ;TEST 0<x<319 & 0<y<239
        cmp.w   #319,d2
        bhi     .outfilltria
        tst.w   d2
        bmi     .outfilltria
        cmp.w   #239,d3
        bhi     .outfilltria
        tst.w   d3
        bmi     .outfilltria
;-----------------------------------
    jsr         tdLine              ; Draw line (A)-(B) 
;-----------------------------------
;-----------------------------------
    move.l      d2,d0               ;   get xbp 
    move.l      d3,d1               ;   get ybp
    move.l      16(a3),d2           ;   get xcp
    move.l      20(a3),d3           ;   get ycp
;-----------------------------------
        cmp.w   #319,d0
        bhi     .outfilltria
        tst.w   d0
        bmi     .outfilltria
        cmp.w   #239,d1
        bhi     .outfilltria
        tst.w   d1
        bmi     .outfilltria         ;TEST 0<x<319 & 0<y<239
        cmp.w   #319,d2
        bhi     .outfilltria
        tst.w   d2
        bmi     .outfilltria
        cmp.w   #239,d3
        bhi     .outfilltria
        tst.w   d3
        bmi     .outfilltria
;-----------------------------------
    jsr         tdLine              ; Draw line (B)-(C)
;-----------------------------------
;-----------------------------------
    move.l      d2,d0               ;   get xcp 
    move.l      d3,d1               ;   get ycp
    move.l      (a3),d2             ;   get xap
    move.l      4(a3),d3            ;   get yap
;-----------------------------------
        cmp.w   #319,d0
        bhi     .outfilltria
        tst.w   d0
        bmi     .outfilltria
        cmp.w   #239,d1
        bhi     .outfilltria
        tst.w   d1
        bmi     .outfilltria         ;TEST 0<x<319 & 0<y<239
        cmp.w   #319,d2
        bhi     .outfilltria
        tst.w   d2
        bmi     .outfilltria
        cmp.w   #239,d3
        bhi     .outfilltria
        tst.w   d3
        bmi     .outfilltria
;-----------------------------------
    jsr         tdLine              ; Draw line (C)-(A)
;-----------------------------------
;-------------------------------------------------------------------------
; Get xmin,xmax in                  D0,D1
;-------------------------------------------------------------------------
    move.l      (a3),d0             ; get xap 
    cmp.l       8(a3),d0            ;     compare xap to xbp
    bge         .xapgxbp            ; if xap > xbp go .xapgxbp
;-----------------------------------
                                    ; * xbp > xap
    move.l      8(a3),d0            ; get xbp
    cmp.l       16(a3),d0           ;     compare xbp to xcp
    bge         .xbpgxcp1           ; if xbp > xcp go .xbpgxcp1
;-----------------------------------
                                    ; * xcp > xbp (> xap)
    move.l      (a3),d0             ;    D0 = xap = xmin
    move.l      16(a3),d1           ;    D1 = xcp = xmax
    bra         .trixpend           ;-> out ...........
;-----------------------------------
.xbpgxcp1:                          ; * xbp > xcp (1)
    move.l      8(a3),d1            ;    D1 = xbp = xmax
    move.l      (a3),d0             ; get xap 
    cmp.l       16(a3),d0           ;     compare xap to xcp
    bge         .xapgxbp1           ; if xap > xcp go .xapgxcp1
;-----------------------------------
    bra         .trixpend           ; * xcp > xap (1) D0 = xap = xmin  -> out ......
;-----------------------------------
.xapgxbp1:                          ; * xap > xcp (1)
    move.l      16(a3),d0           ;    D0 = xcp = xmin
    bra         .trixpend           ;-> out ...........
;-----------------------------------
.xapgxbp:                           ; * xap > xbp
    cmp.l       16(a3),d0           ;     compare xap to xcp
    bge         .xapgxcp2           ; if xap > xcp go .xapgxcp2
;-----------------------------------
                                    ; * xcp > xap (> xbp)
    move.l      8(a3),d0            ;    D0 = xbp = xmin
    move.l      16(a3),d1           ;    D1 = xcp = xmax
    bra         .trixpend           ;-> out ...........
;-----------------------------------
.xapgxcp2:                          ; * xap > xcp (2)
    move.l      (a3),d1             ;    D1 = xap = xmax
    move.l      8(a3),d0            ; get xbp
    cmp.l       16(a3),d0           ;     compare xbp to xcp
    bge         .xbpgxcp2           ; if xbp > xcp go .xbpgxcp2 
;-----------------------------------
    bra         .trixpend           ; * xcp > xbp (2) D0 = xbp = xmin -> out .....
;-----------------------------------
.xbpgxcp2:                          ; * xbp > xcp (2)
    move.l      16(a3),d0           ;  D0 = xcp = xmin
.trixpend:                          ;-> out .......................................
;-------------------------------------------------------------------------
; Get ymin,ymax in                  D2,D3
;-------------------------------------------------------------------------
    move.l      4(a3),d2            ; get yap 
    cmp.l       12(a3),d2           ;     compare yap to ybp
    bge         .yapgybp            ; if yap > ybp go .yapgybp
;-----------------------------------
                                    ; * ybp > yap
    move.l      12(a3),d2           ; get ybp
    cmp.l       20(a3),d2           ;     compare ybp to ycp
    bge         .ybpgycp1           ; if ybp > ycp go .ybpgycp1
;-----------------------------------
                                    ; * ycp > ybp (> yap)
    move.l      4(a3),d2            ;    d2 = yap = xmin
    move.l      20(a3),d3           ;    d3 = ycp = xmax
    bra         .triypend           ;-> out ...........
;-----------------------------------
.ybpgycp1:                          ; * ybp > ycp (1)
    move.l      12(a3),d3           ;    d3 = ybp = xmax
    move.l      4(a3),d2            ; get yap 
    cmp.l       20(a3),d2           ;     compare yap to ycp
    bge         .yapgybp1           ; if yap > ycp go .yapgycp1
;-----------------------------------
    bra         .triypend           ; * ycp > yap (1) d2 = yap = xmin  -> out ......
;-----------------------------------
.yapgybp1:                          ; * yap > ycp (1)
    move.l      20(a3),d2           ;    d2 = ycp = xmin
    bra         .triypend           ;-> out ...........
;-----------------------------------
.yapgybp:                           ; * yap > ybp
    cmp.l       20(a3),d2           ;     compare yap to ycp
    bge         .yapgycp2           ; if yap > ycp go .yapgycp2
;-----------------------------------
                                    ; * ycp > yap (> ybp)
    move.l      12(a3),d2           ;    d2 = ybp = xmin
    move.l      20(a3),d3           ;    d3 = ycp = xmax
    bra         .triypend           ;-> out ...........
;-----------------------------------
.yapgycp2:                          ; * yap > ycp (2)
    move.l      4(a3),d3            ;    d3 = yap = xmax
    move.l      12(a3),d2           ; get ybp
    cmp.l       20(a3),d2           ;     compare ybp to ycp
    bge         .ybpgycp2           ; if ybp > ycp go .ybpgycp2 
;-----------------------------------
    bra         .triypend           ; * ycp > ybp (2) d2 = ybp = xmin -> out .....
;-----------------------------------
.ybpgycp2:                          ; * ybp > ycp (2)
    move.l      20(a3),d2           ;  d2 = ycp = xmin
.triypend:                          ;-> out ..............................
;-------------------------------------------------------------------------
; A4 rangefill tab : x/y min/max
; D4 color
;-------------------------------------------------------------------------
    lea         rangefill(pc),a4    ; Get address of rangefill tab
    move.l      d0,(a4)             ; Store xmin : rangefill [00]
    move.l      d1,4(a4)            ; Store xmax : rangefill [04]
    move.l      d2,8(a4)            ; Store ymin : rangefill [08]
    move.l      d3,12(a4)           ; Store ymax : rangefill [12]
;-------------------------------------------------------------------------
;    exg d1,d2                      ; For Debug
;    jsr tdLine
;    bra .outfilltria
;-------------------------------------------------------------------------
; Loops For Fill
;-------------------------------------------------------------------------
    move.l      8(a4),d7            ; get ymin in D7  yp = ymin
.loopyfill:
    move.l      4(a4),d6            ; get xmax in D6  xp = xmax
    addq.l      #1,d6
    move.l      a0,a5               ; copy frame buffer address in A5
    move.l      d7,d2               ; *-  yp = d2
    move.l      d7,d3               ; *-  yp = d3
    lsl.l       #6,d2               ; *
    lsl.l       #8,d3               ; *
    add.l       d3,d2               ; *-  yp * 320 optimized
    add.l       d6,d2               ; *-  + xp
    lsl.l       #2,d2               ; *-  * 4  for xRGB32 colors buffer
    adda.l      d2,a5               ; *-  place A5 on location Xp,Yp

.loopxm:
    move.l      -(a5),d5            ; get colour of point (xp,yp)
    cmp.l       d4,d5               ; color equal to line color ?
    bne         .colneqxm           ; not equal so continue ... .colneqxm
    move.l      d6,d0               ; keep xp start in D0
    bra         .initlpxp           ; go .initlpxp
.colneqxm:
    subq.l      #1,d6               ; xp = xp-1
    cmp.l       (a4),d6             ; xp < ymin ?
    bne         .loopxm
    bra         .endloopxp

.initlpxp:
    move.l      (a4),d6             ; get xmin in D6  xp = xmin
    move.l      a0,a5               ; copy frame buffer address in A5
    move.l      d7,d2               ; *-  yp = d2
    move.l      d7,d3               ; *-  yp = d3
    lsl.l       #6,d2               ; *
    lsl.l       #8,d3               ; *
    add.l       d3,d2               ; *-  yp * 320 optimized
    add.l       d6,d2               ; *-  + xp
    lsl.l       #2,d2               ; *-  * 4  for xRGB32 colors buffer
    adda.l      d2,a5               ; *-  place A5 on location Xp,Yp

.loopxp:
    move.l      (a5)+,d5            ; get colour of point (xp,yp)
    cmp.l       d4,d5               ; color equal to line color ?
    bne         .colneqxp           ; if not equal then continue ...
                                    ; init horizontal drawing if colors are equal
    move.l      a0,a5               ; copy frame buffer address in A5
    move.l      d7,d2               ; *-  yp = d2
    move.l      d7,d3               ; *-  yp = d3
    lsl.l       #6,d2               ; *
    lsl.l       #8,d3               ; *
    add.l       d3,d2               ; *-  yp * 320 optimized
    add.l       d0,d2               ; *-  + xp
    lsl.l       #2,d2               ; *-  * 4  for xRGB32 colors buffer
    adda.l      d2,a5               ; *-  place A5 on location (Xp start,Yp)
    sub.l       d6,d0               ; init line lenght

.hordrawlp:                         ; Fill Loop
    move.l      d4,-(a5)            ; draw pixel
    dbra        d0,.hordrawlp       ;   finished ?
    bra         .endloopxp          ; exit fill line 

.colneqxp:
    addq.l      #1,d6               ; xp = xp+1
    cmp.l       4(a4),d6            ; xp > xmax ?
    bne         .loopxp
.endloopxp:

    addq.l      #1,d7               ; yp = yp+1
    cmp.l       12(a4),d7           ; yp > ymax ?
    blt         .loopyfill
.outfilltria:
    movem.l     (sp)+,d0-d7/a0-a5
    rts
;---------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------
                                                ; 00,04,08 , 12,16,20 , 24,28,32
fcmatrix        dc.s    0,0,0,0,0,0,0,0,0       ; xx,xy,xz , yx,yy,yz , zx,zy,zz
;---------------------------------------------------------------------------------------
                                                ; 00,04,08 , 12,16,20 , 24,28,32
obmatrix        dc.s    0,0,0,0,0,0,0,0,0       ; xx,xy,xz , yx,yy,yz , zx,zy,zz
;---------------------------------------------------------------------------------------
                                                ; 00,04,08 , 12,16,20 , 24,28,32
tdfaces         dc.s    0,0,0,0,0,0,0,0,0       ; xa,ya,za , xb,yb,zb , xc,yc,zc
;---------------------------------------------------------------------------------------
                                                ;  00,04  ,  08,12  ,  16,20  ,  24,28
faces           dc.l    0,0,0,0,0,0,0,0         ; xap,yap , xbp,ybp , xcp,ycp , xdp,ydp
;---------------------------------------------------------------------------------------
                                                ;  00  ,  04  ,  08  ,  12
rangefill       dc.l    0,0,0,0                 ; xmin , xmax , ymin , ymax
;---------------------------------------------------------------------------------------
                                                ;  00  ,  04  ,  08  ,  12  ,  16  ,  20
lightprm        dc.l    0,0,0,10,10,10          ; xpos , ypos , zpos , aang , bang , cang
;---------------------------------------------------------------------------------------
                                                ;  00  ,  04  ,  08
lightvec        dc.s    0,0,0                   ; xnrm , ynrm , znrm
;---------------------------------------------------------------------------------------
                                                ;  00  ,  04  ,  08  ,  12  ,  16  ,  20
camera          dc.l    160,120,220,0,0,0       ; xpos , ypos , zpos , aang , bang , cang
;---------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------
TDRender.Name   dc.b    'tdrender.library',0
Library.ID      dc.b    'tdrender.library 1.0 (15.11.96) for 030_FPU',0
Utility.Name    dc.b    'utility.library',0

EndLib
