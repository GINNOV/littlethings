
   Section  codice,CODE

   incdir   "dh1:programs/asmone/modem/over/"

   include  "daworkbench.s"
   include  "startup2.s"

      ;5432109876543210
DMASET   EQU   %1000001110000000 ; copper e bitplane abilitati

WAITDISK equ   10
width equ   256
height   equ   256
plsiz equ   width*height/8

START:
   movem.l  d0-d7/a0-a6,-(SP) ; setto la musica
   lea   P61_data,a0 ; Indirizzo del modulo in a0
   lea   $dff000,a6  ; Ricordiamoci il $dff000 in a6!
   sub.l a1,a1    ; I samples non sono a parte, mettiamo zero
   sub.l a2,a2    ; no samples -> modulo non compattato
   lea   samples,a2  ; modulo compattato! Buffer destinazione per
            ; i samples (in chip ram) da indicare!
   bsr.w P61_Init
   movem.l  (SP)+,d0-d7/a0-a6

   lea   $dff000,a5
   move.l   BaseVbr(PC),A1
   move.l   #MyInt6c,$6C(A1)
   move.w   #DMASET,$96(a5)      ; DMACON - abilita bitplane e copper
   move.w   #$e020,$9a(a5)    ; INTENA - Abilito Master and lev6

*** init textures
   moveq #15,d6
   moveq #15,d7
   lea   bumppic,a2  ; texture da fare
   bsr   make_chk

   moveq #2,d6
   moveq #2,d7
   lea   phong,a2
   bsr   make_chk
   bsr   MakeUpAngles
***

   move.l   #FONDINO,d0
   lea   BPLPOINTERS,A1 

   move.w   d0,6(a1)
   swap  d0
   move.w   d0,2(a1)
   swap  d0

   move.l   #VUOTO,d0
   lea   BPLPOINTERS2,A1   
   move.w   d0,6(a1)
   swap  d0
   move.w   d0,2(a1)
   swap  d0

   move.l   #COPPERLIST,$dff080
   move.w   d0,$dff088

   move.w   #$c00,$dff106
   move.w   #$11,$dff10c

   clr.l VBcounter

   lea   TESTO1(PC),a0
   bsr.w PRINTATESTO

LOGO1:
   bsr.w WBLAN

   lea   PALETTE1,a3
   jsr   FADEAGA

   btst  #6,$bfe001  ; se premi il mouse ESCI!!!
   beq.w ESCI

   cmpi.l   #64,VBcounter
   blo.s LOGO1

   clr.l VBcounter

LOGO2:
   bsr.w WBLAN

   btst  #6,$bfe001  ; se premi il mouse ESCI!!!
   beq.w ESCI

   cmpi.l   #500,VBcounter
   blo.s LOGO2
   clr.l VBcounter

LOGO3:
   bsr.w WBLAN

   lea   PALETTE1,a3
   jsr   FADEAGA

   btst  #6,$bfe001  ; se premi il mouse ESCI!!!
   beq.w ESCI

   cmpi.l   #64,VBcounter
   blo.s LOGO3

   clr.l VBcounter

   bsr   wblan
   move.l   #flash_cop,$dff080
   move.w   d0,$dff088
   bsr   wblan

   ; logo Over
   move.l   #pic_logo,d0
   lea   pic_bpl,a0
   moveq #5,d1    ; 6 piani
.bploop:move.w d0,6(a0)
   swap  d0
   move.w   d0,2(a0)
   swap  d0
   add.l #(256/8)*201,d0
   addq  #8,a0
   dbra  d1,.bploop
   move.l   #logo_cop,$dff080
   move.w   d0,$dff088
   
waitvbl:
   move.l   $dff004,d0
   and.l #$1ff00,d0
   cmp.l #$12c00,d0
   bne.s waitvbl

   btst  #6,$bfe001  ; se premi il mouse ESCI!!!
   beq.w ESCI

   cmp.l #650,vbcounter
   blo.s waitvbl

   clr.l vbcounter
   ; 2a PARTE

   move.l   #copperlist,$dff080
   move.w   d0,$dff088

   clr.w FLAGFADEINOUT
   clr.w MULTIPLIER
   clr.l TEMPORANEO

   lea   TESTO2(PC),a0
   bsr.w PRINTATESTO

LOGO1b:
   bsr.w WBLAN

   lea   PALETTE2,a3
   jsr   FADEAGA

   btst  #6,$bfe001  ; se premi il mouse ESCI!!!
   beq.w ESCI

   cmpi.l   #64,VBcounter
   blo.s LOGO1b

   clr.l VBcounter

LOGO2b:
   bsr.w WBLAN

   btst  #6,$bfe001  ; se premi il mouse ESCI!!!
   beq.w ESCI

   cmpi.l   #500,VBcounter
   blo.s LOGO2b

   clr.l VBcounter

LOGO3b:
   bsr.w WBLAN

   lea   PALETTE2,a3
   jsr   FADEAGA

   btst  #6,$bfe001  ; se premi il mouse ESCI!!!
   beq.w ESCI

   cmpi.l   #64,VBcounter
   blo.s LOGO3b

   clr.l VBcounter

   bsr   wblan
   move.l   #flash_cop,$dff080
   move.w   d0,$dff088
   bsr   wblan

   ; bump mapping
   move.l   basevbr,a0
   move.l   #bump_int6c,$6c(a0)
   move.l   #bump_cop,$dff080
   move.w   d0,$dff088

bump_loop:
   move.l   $dff004,d0
   and.l #$1ff00,d0
   cmp.l #$12c00,d0
   bne.s bump_loop

   lea   bump_bpl,a0
   bsr   swapscreen
   bsr   bump
   lea   _chk,a0
   move.l   logic,a1
   bsr   chunky2planar256

   btst  #6,$bfe001  ; se premi il mouse ESCI!!!
   beq.w ESCI

   cmp.w #650,vbcounter
   ble.s bump_loop

   bsr   clear2
   
   move.l   basevbr,a0
   move.l   #myint6c,$6c(a0)
   move.l   #copperlist,$dff080
   move.w   d0,$dff088

   clr.l vbcounter
   clr.w FLAGFADEINOUT
   clr.w MULTIPLIER
   clr.l TEMPORANEO

   lea   TESTO3(PC),a0
   bsr.w PRINTATESTO

LOGO1c:
   bsr.w WBLAN

   lea   PALETTE3,a3
   jsr   FADEAGA

   btst  #6,$bfe001  ; se premi il mouse ESCI!!!
   beq.w ESCI

   cmpi.l   #64,VBcounter
   blo.s LOGO1c

   clr.l VBcounter

LOGO2c:
   bsr.w WBLAN

   btst  #6,$bfe001  ; se premi il mouse ESCI!!!
   beq.w ESCI

   cmpi.l   #500,VBcounter
   blo.s LOGO2c

   clr.l VBcounter

LOGO3c:
   bsr.w WBLAN

   lea   PALETTE3,a3
   jsr   FADEAGA

   btst  #6,$bfe001  ; se premi il mouse ESCI!!!
   beq.w ESCI

   cmpi.l   #64,VBcounter
   blo.s LOGO3c

   clr.l VBcounter

   moveq #1,d6
   moveq #1,d7
   lea   phong,a2
   bsr   make_chk
   bsr   MakeUpAngles

env_wbl1:move.l   $dff004,d0
   and.l #$1ff00,d0
   cmp.l #$2c00,d0
   bne.s env_wbl1
   ; env-map

   move.l   #flash_cop,$dff080
   move.w   d0,$dff088

   bsr   divx
   bsr   mulx
env_wbl2:move.l   $dff004,d0
   and.l #$1ff00,d0
   cmp.l #$2c00,d0
   bne.s env_wbl2

   move.w	#1,env_flag

   move.l   a7,old_sp
   lea   -100(sp),sp
   bsr   clear2
   ;
   move.l   #env_cop,$dff080
   move.w   d0,$dff088
LoopMain:
   move.l   $dff004,d0
   and.l #$1ff00,d0
   cmp.l #$12c00,d0
   bne.s loopmain
   lea   env_bpl,a0
   bsr   swapscreen
   bsr   clearscreen ; clear logic screen
   bsr   rots     ; rotate points&normals
   bsr   hface    ; check for visible faces
   bsr   sort_draw   ; draw faces
   lea   _chk,a0
   move.l   logic,a1
   bsr   chunky2planar256

   cmp.l #650,vbcounter
   bhi.s env_end

   btst  #6,$bfe001  ; check 4 sx mouse
   beq.s ESCI2

	bra.s	LOOPMAIN

ESCI2:
   move.l old_sp,a7
	bra.w	ESCI

env_end:
   move.l old_sp,a7
   bra   _cont

old_sp:  dc.l  0

_cont:
   move.l   #copperlist,$dff080
   move.w   d0,$dff088
   move.w   #0,env_flag

   bsr   clear2

   clr.l vbcounter

   ; 4a PARTE

   clr.w FLAGFADEINOUT
   clr.w MULTIPLIER
   clr.l TEMPORANEO

   lea   TESTO4(PC),a0
   bsr.w PRINTATESTO

LOGO1d:
   bsr.w WBLAN

   lea   PALETTE4,a3
   jsr   FADEAGA

   btst  #6,$bfe001  ; se premi il mouse ESCI!!!
   beq.w ESCI

   cmpi.l   #64,VBcounter
   blo.s LOGO1d

   clr.l VBcounter

LOGO2d:
   bsr.w WBLAN

   btst  #6,$bfe001  ; se premi il mouse ESCI!!!
   beq.w ESCI

   cmpi.l   #500,VBcounter
   blo.s LOGO2d

   clr.l VBcounter

LOGO3d:
   bsr.w WBLAN

   lea   PALETTE4,a3
   jsr   FADEAGA

   btst  #6,$bfe001  ; se premi il mouse ESCI!!!
   beq.w ESCI

   cmpi.l   #64,VBcounter
   blo.s LOGO3d

   clr.l VBcounter

ESCI:
   lea   $dff000,a6  ; stoppo la musica
   bsr.w P61_End
   rts         ; esci

*** Routines dell'env
*** Hidden faces
hface:   lea   faces,a5 ;
   lea   _2dcoords,a6
   move.l   #numfaces,d7
   moveq #0,d6
   move.w   d6,num      ; azzera contatore per il sort
   lea   z_buf,a4 ; coordinate 3d
   lea   buf,a2
   moveq #0,d6
faces_loop:
   movem.l  (a5)+,d0/d2/d4
   movem.l  (a6,d0.w*8),d0-d1
   movem.l  (a6,d2.w*8),d2-d3
   movem.l  (a6,d4.w*8),d4-d5
   lea   12(a5),a5
   ; coords p0=d0/d1 p1=d2/d3 p2=d4/d5
   ; hidden faces
   ; (x1-x0)(y2-y0)-(x2-x0)(y1-y0)
   sub.l d0,d2    ; x1-x0
   sub.l d0,d4    ; x2-x0
   sub.l d1,d3    ; y1-y0
   sub.l d1,d5    ; y2-y0
   muls.l   d5,d2    ; (x1-x0)(y2-y0)
   muls.l   d3,d4    ; (x2-x0)(y1-y0)
   sub.l d4,d2    ;
   blt.w noface      ; <0 no calc&draw face
   ; >=0 then draw
   movem.l  -24(a5),d0-d2  ; indici delle z
   move.w   (a4,d0.w*2),d6 ; z1
   add.w (a4,d1.w*2),d6 ; z1+z2
   add.w (a4,d2.w*2),d6 ; z1+z2+z3
   move.l   d6,(a2)+ ; save #face,z-face
   add.w #1,num      ; incrementa numero facce da disegnare
noface:  add.l #$10000,d6  ; contatore numero faccia
   dbra  d7,faces_loop  ; next face
   bsr   sort     ; insert sort della faccia
   rts

*** Disegna le facce dalla piu' lontana alla piu' vicina
sort_draw:
   lea   buf-2,a3 ; a3 -> lista ordinata delle facce
   lea   _2dcoords,a4; a4 -> lista punti
   lea   lista,a5 ; a5 -> lista facce
   move.w   num,d7   ; numero di facce da disegnare
   beq.s sort_draw_end
   lea   (a3,d7*4),a3   ; get correct value
   subq  #1,d7    ; -1 per il dbra
draw_faces:
   move.l   -(a3),d6 ; ????.numfaccia
   movem.l  (a5,d6.w*4),a6 ; indirizzo faccia
   movem.l  (a6)+,d0/d2/d4/a0-a2 ; indici dei punti
   movem.l  (a4,d0.w*8),d0-d1
   movem.l  (a4,d2.w*8),d2-d3
   movem.l  (a4,d4.w*8),d4-d5 ; coordinate 2d
   movem.l  d7/a3-a6,-(sp)
   bsr   scan
   bsr   make_final
   bsr   tmap
   movem.l  (sp)+,d7/a3-a6
   dbra  d7,draw_faces
sort_draw_end:
   rts

*** Radix sort
sort: moveq #0,d1
   bsr   split
   bsr   merge
   moveq #4,d1
   bsr   split
   bsr   merge
   moveq #8,d1
   bsr   split
   bsr   merge
   moveq #12,d1
   bsr   split
   bsr   merge
   rts

split:   lea   buf,a0   ; elementi da ordinare
   lea   rx_val,a1   ; tabella #immessi
   lea   rx_tab,a2   ; tabella con i valori
   move.w   num,d0      ; #immesi
   subq  #1,d0
   moveq #$f,d6      ; per l'and
   move.w   #1,a4
rx_loop:move.l (a0)+,d2
   move.w   d2,d3
   lsr.l d1,d3    ; shift
   and.l d6,d3    ; num&$f-> indice
   move.l   d3,d4
   move.w   (a1,d4.w*2),d5 ; #immessi per indice
   add.w d3,d3
   add.w d3,d3    ; d3*4
   lsl.l #8,d3    ; d3<<10 (256*4)
   add.w #1,(a1,d4.l*2) ; incrementa indice di linea
   move.l   a2,a3
   add.l d3,a3    ; linea corrente
   move.l   d2,(a3,d5.w*4) ; mette il num in tabella
   dbra  d0,rx_loop  ; prossimo val
   rts

merge:   lea   buf,a0
   lea   rx_val,a1
   moveq #15,d7
   move.l   #256*4,d2
   lea   rx_tab,a2
   moveq #0,d1
loop1:   move.w   (a1),d0  ; # numeri
   beq.s fine_1
   move.l   a2,a3
   subq  #1,d0
loop2:   move.l   (a3)+,(a0)+ ; copia val in lista
   dbra  d0,loop2
fine_1:  move.w   d1,(a1)+ ; azzera il contatore
   add.l d2,a2    ; altra linea di valori
   dbra  d7,loop1
   rts

num:  dc.w  0

*** Scambia schermi ***
swapscreen:
   move.l   logic,d0
   move.l   actual,d1
   exg.l d0,d1
   move.l   d0,logic
   move.l   d1,actual
   moveq #7,d0
.bloop:  move.w   d1,6(a0)
   swap  d1
   move.w   d1,2(a0)
   swap  d1
   add.l #plsiz,d1
   add.l #8,a0
   dbra  d0,.bloop
   rts
   
*** Cancella schermo chunky
clearscreen:
   move.l   #((plsiz*8)/32)-1,d0
   lea   _chk,a0
   moveq #0,d1
cl_loop:
   move.l   d1,(a0)+
   move.l   d1,(a0)+
   move.l   d1,(a0)+
   move.l   d1,(a0)+
   move.l   d1,(a0)+
   move.l   d1,(a0)+
   move.l   d1,(a0)+
   move.l   d1,(a0)+
   dbra  d0,cl_loop
   rts

clear2:  lea   vuoto,a0
   move.l   #320*256/32-1,d0
   moveq #0,d1
.cl_loop:
   move.l   d1,(a0)+
   move.l   d1,(a0)+
   move.l   d1,(a0)+
   move.l   d1,(a0)+
   move.l   d1,(a0)+
   move.l   d1,(a0)+
   move.l   d1,(a0)+
   move.l   d1,(a0)+
   dbra  d0,.cl_loop
   rts

*** Tabella per le divisioni
divx: move.l   #-300,d0 ; start value
   lea   tabdi,a0
   move.w   #299,d1
divloop1:
   moveq #1,d2
   tst   d0
   beq.s nodiv
   swap  d2
   divs.l   d0,d2
nodiv:   move.l   d2,(a0)+
   addq  #1,d0
   dbra  d1,divloop1
   ; -----
   moveq #1,d0
   lea   tabdiv,a0
   move.w   #299,d1     ; 400 valori (-200..200)
   addq  #4,a0
divloop:move.l #$10000,d2  ; 1«16
   divs.l   d0,d2
   move.l   d2,(a0)+
   addq  #1,d0
   dbra  d1,divloop
   rts

*** Tabella width*k
mulx: lea   multab,a0   ;
   moveq #0,d0    ; count 4 muls
   move.l   #255,d1     ; count 4 loop
   move.l   #width,d2   ; const (larghezza schermo)
mloop:   move.l   d0,d3    ; d0->d3
   mulu  d2,d3    ; d3*160
   move.l   d3,(a0)+ ; store result
   addq  #1,d0    ; inc d0
   dbra  d1,mloop ; loop !!!
   rts

********* Scanline Engine ************
   cnop  0,4
scan: ; d0/d1 = x0/y0 tp0=(0,0)
   ; d2/d3 = x1/y1 tp1=(0,256)
   ; d4/d5 = x2/y2 tp2=(256,0)
   ; sort vertex by y
   cmp.w d3,d1       ; y0>y1?
   bge.s swap_p0p1
   bra.s cont1
swap_p0p1:
   exg.l d0,d2       ; swap x0/x1 coords
   exg.l d1,d3       ; swap y0/y1
   exg.l a0,a1
cont1:   cmp.w d5,d1       ; y0>y2?
   bge.s swap_p0p2
   bra.s cont2
swap_p0p2:
   exg.l d5,d1       ; swap y0/y2
   exg.l d0,d4       ; swap x0/x2
   exg.l a0,a2
cont2:   cmp.w d5,d3       ; y1>y2?
   bge.s swap_p1p2
   bra.w cont
swap_p1p2:
   exg.l d2,d4       ; swap x2/x0
   exg.l d5,d3       ; swap y2/y0
   exg.l a1,a2
   ; p0->p1, p1->p2, p0->p2
cont: movem.l  d0-d5/a0-a2,tp_order
   cmp.w d5,d1    ; y2<y0 ?
   beq.w scan_end ; yes = exit
   ; calcolo du,dv per il triangolo e calcolo
   ; du,dv per la scanline
   lea   tabdiv,a0
   lea   tab1,a1
   lea   (a1,d1.w*2),a1 ; goto 1st value
   move.l   d2,a3    ; x1 in a3
   moveq #0,d2    ; reset d2 for addx
   move.l   d3,d6    ; y1
   sub.l d1,d6    ; y1-y0
   beq.s no_scan01   ; =0? no scanline to calc
   move.l   a3,d7    ; x1
   sub.l d0,d7    ; x1-x0
   muls.l   (a0,d6.w*4),d7 ; d7=(x1-x0)*((1«16)/(y1-y0))
   swap  d7    ; swap int&dec (addx)
   move.l   d7,a2    ; save dx/dy
   move.w   d6,d7    ; y1-y0
   move.w   d0,d6    ; x=x0
   subq  #1,d7    ; dy-1 cycles
   ; calc a scanline p0->p1
   ; d6=x0, d7=y0, a2=dx, a4=y1, a1 ptr to tab, d2=0 (per l'addx)
scan_loop0:
   move.w   d6,(a1)+ ; save in tab1
   add.l a2,d6    ;
   addx.l   d2,d6    ; x=x+dx
   dbra  d7,scan_loop0
no_scan01:
   move.l   d5,d6    ; y2
   sub.l d3,d6    ; y2-y1
   beq.s no_scan12   ; =0? no scanline calc
   move.l   d4,d7    ; x2
   sub.l a3,d7    ; x2-x1
   muls.l   (a0,d6.w*4),d7 ; d7=(x2-x1)*((1«16)/(y2-y1))
   swap  d7    ; swap int&dec (addx)
   move.l   d7,a2    ; dx
   move.w   d6,d7    ; d7=dy
   subq  #1,d7    ; dy-1
   move.w   a3,d6    ; x1
   ; calc a scanline p1->p2
scan_loop1:
   move.w   d6,(a1)+ ; save in tab1
   add.l a2,d6    ;
   addx.l   d2,d6    ; x=x+dx
   dbra  d7,scan_loop1
no_scan12:
   sub.l d1,d5    ; y2-y0
   beq.s scan_end
   sub.l d0,d4    ; x2-x0
   muls.l   (a0,d5.w*4),d4 ; d7=(x0-x2)*((1«16)/(y0-y2))
   swap  d4
   lea   tab2,a1  ; ptr to tab2
   lea   (a1,d1.w*2),a1 ; goto 1st value
   subq  #1,d5
scan_loop2:
   move.w   d0,(a1)+
   add.l d4,d0
   addx.w   d2,d0 
   dbra  d5,scan_loop2
scan_end:
   rts

tp_order:dcb.l 6+3,0 ; x0-y2,*tp

*** interpola le uv lungo il lato sx del triangolo
   cnop  0,4
make_final:
   movem.l  tp_order(pc),d0-d5/a0-a2   ; get order tmap points
   cmp.l d1,d5
   ble.w end_makeuv
   lea   tabdiv,a4   ; tabella divisioni
   lea   uvtab,a3
   sub.l a5,a5    ; reset a5
   lea   (a3,d1.w*2),a3 ; goto 1st value
   move.l   d4,d6    ; save   x2
   move.l   d5,d7    ;   "   y2
   sub.l d0,d6    ; x2-x0
   sub.l d1,d7    ; y2-y0
   muls.l   (a4,d7.w*4),d6
   move.l   d6,a5    ; save result 4 cmp
   move.l   d5,d7    ; save   y2
   move.l   d4,d6    ;   "   x2
   sub.l d2,d6    ; x2-x1
   swap  d6    ;      «16
   sub.l d3,d7    ; y2-y1
   beq.s prova
   divs.l   d7,d6    ; (x2-x1)/(y2-y1)=m2
prova:   cmp.l d6,a5    ;
   bgt.w scan02      ; m1<m2 => type 2 uv-scan
   beq.w end_makeuv  ; m1=m2 => no scan (a line isn't scanned)
scan012:sub.l  d3,d5    ; y2-y1
   sub.l d1,d3    ; y1-y0
   ble.s eq10
   ; calc du/dy dv/dy
   move.l   (a4,d3.w*4),d7 ; 1/dy1
   move.l   (a1),d2     ; u1
   sub.l (a0),d2     ; u1-u0
   move.l   4(a1),d4 ; v1
   sub.l 4(a0),d4 ; v1-v0
   muls.l   d7,d4    ; dv1/dy1
   lsl.l #8,d4    ;
   muls.l   d7,d2    ; du1/dy1
   move.w   d2,d4    ;
   swap  d2    ;
   swap  d4    ;
   move.l   (a0),d0     ; u0
   move.l   4(a0),d1 ; v0
   lsl.w #8,d1    ; v0«8
   subq  #1,d3
mkloop1:move.w d1,d6    ; v«8
   move.b   d0,d6    ; v«8+u
   move.w   d6,(a3)+ ; store v,u
   add.l d4,d1    ; v+=dv
   addx.w   d2,d0    ; u+=du
   dbra  d3,mkloop1
makeuv2:tst.l  d5    ; y2-y1=0?
   ble.s end_makeuv
   move.l   (a4,d5.w*4),d7 ; 1/dy2
   move.l   (a2),d2     ; u2
   sub.l (a1),d2     ; u2-u1
   move.l   4(a2),d4 ; v2
   sub.l 4(a1),d4 ; v2-v1
   muls.l   d7,d4    ; dv2/dy2
   lsl.l #8,d4
   muls.l   d7,d2    ; du2/dy2
   move.w   d2,d4    ;
   swap  d2    ;
   swap  d4    ;
   subq  #1,d5    ;
_mkloop2:
   move.w   d1,d6    ; v«8
   move.b   d0,d6    ; v«8+u
   move.w   d6,(a3)+ ; store v,u
   add.l d4,d1    ; v+=dv
   addx.w   d2,d0    ; u+=du
   dbra  d5,_mkloop2
end_makeuv:
   rts
   ; type 2 uv-scan
eq10: exg.l a0,a1
   exg.l d0,d2
   lea   tp_order(pc),a5
   move.l   d0,(a5)
   move.l   d2,8(a5)
   move.l   a0,24(a5)
   move.l   a1,28(a5)   ; save some regs
   move.l   20(a5),d5   ; restore d5
scan02:  sub.l d1,d5
   beq.s end_makeuv
   move.l   (a4,d5.w*4),d7 ; 1/dy
   move.l   (a2),d0
   sub.l (a0),d0     ; u2-u0
   move.l   4(a2),d1
   sub.l 4(a0),d1 ; v2-v0
   muls.l   d7,d1    ; dv/dy
   lsl.l #8,d1    ; (v_int,v_dec),?
   muls.l   d7,d0    ; du/dy
   move.w   d0,d1    ; (v_int,v_dec),u_dec
   swap  d0    ; u_dec,u_int
   swap  d1    ; u_dec,(v_int,v_dec)
   move.l   4(a0),d3 ; v
   lsl.w #8,d3    ; v«8
   move.l   (a0),d2     ; u
   subq  #1,d5
scan02_loop:
   move.w   d3,d6    ; v«8
   move.b   d2,d6    ; v«8+u
   move.w   d6,(a3)+ ; store v,u
   add.l d1,d3    ; (v+=dv)«8
   addx.w   d0,d2
   dbra  d5,scan02_loop
   rts

*** Tmap Ver.7 ***
   cnop  0,4
tmap: movem.l  tp_order(pc),d0-d5/a0-a2
   sub.l d1,d5    ; (y3-y1)
   beq.w no_txt
   ; calc du/dx dv/dx
   lea   tabdiv,a3
   move.l   d5,a5
   sub.l d1,d3    ; y2-y1
   beq.s _width
   muls.l   (a3,d5.w*4),d3 ; ((y2-y1)«16)/(y3-y1)
_width:  sub.l d0,d4    ; (x3-x1)
   sub.l d2,d0    ; (x1-x2)
   swap  d0    ; (x1-x2)«16
   muls.l   d3,d4
   add.l d0,d4    ; (x1-x2)«16+tmp*(x3-x1)
   swap  d4
;  ext.l d4
   move.l   (a4,d4.w*4),d0 ; 1/width
   ;du/dx:  
   move.l   (a0),d6
   move.l   (a2),d5     ; u3
   sub.l d6,d5    ; (u3-u1)
   muls.l   d3,d5    ; (u3-u1)*tmp
   sub.l (a1),d6     ; (u1-u2)
   swap  d6    ; (u1-u2)«16
   add.l d5,d6    ; (u3-u1)*tmp+(u1-u2)«16
   tst.l d4
   beq.s nodudx
   swap  d6
   ext.l d6
   muls.l   d0,d6    ; ((u3-u1)*tmp+(u1-u2)«16)/width
nodudx:  move.l   4(a0),d7
   move.l   4(a2),d5 ; v3
   sub.l d7,d5    ; (v3-v1)
   sub.l 4(a1),d7 ; (v1-v2)
   swap  d7    ; (v1-v2)«16
   muls.l   d3,d5    ; tmp*(v3-v1)
   add.l d5,d7    ; tmp*(v3-v1)+(v1-v2)«16
   tst.l d4
   beq.s tmap_init
   swap  d7
   ext.l d7
   muls.l   d0,d7    ; (tmp*(v3-v1)+(v1-v2)«16)/width
   ; d4=lunghezza massima scanline
tmap_init:
   tst   d4
   bge.s ok_width
   neg.w d4
ok_width:
   lsl.l #8,d7    ; dv«8
   move.w   d6,d7    ; u_dec
   swap  d6    ; u_dec,u_int
   swap  d7    ; u_dec,(v_int,v_dec)
   ; precalcolo una scanline
   lea   scan_precalc(pc),a3
   moveq #0,d0    ; start u
   moveq #0,d2    ; start v
precalc_loop:
   move.w   d0,d3    ; v«8
   move.b   d2,d3    ; u
   move.w   d3,(a3)+ ; save offset
   add.l d7,d0    ; v+=dv
   addx.w   d6,d2    ; u+=du
   dbra  d4,precalc_loop
   ; fine precalcolo
   lea   tab1,a4
   lea   tab2,a3
   lea   uvtab,a6
   lea   (a4,d1.w*2),a4
   lea   (a3,d1.w*2),a3
   lea   (a6,d1.w*2),a6 ; inizializza alcuni valori
   lea   _chk,a1
   lea   multab,a0
   move.l   (a0,d1.w*4),d1 ; y*160
   add.l d1,a1    ; inizio chunky alla linea y1
   move.l   a5,d7    ; y3-y1
   subq  #1,d7
   moveq #0,d4
   move.l   #width,d2
   move.l   #phong,d3
   move.l   #scan_precalc,d6
scan_loop:
   move.w   (a4)+,d0 ; x_left
   move.w   (a3)+,d1 ; x_right
   cmp.w d0,d1    ;
   bgt.s _okd0d1     ;
   beq.s _no_scan ;
   exg   d0,d1    ;
_okd0d1:move.w (a6)+,d4 ; v«8+u
   sub.w d0,d1    ; lunghezza della scanline
   lea   (a1,d0.w),a5   ; inizio della scanline sul chunky
   move.l   d3,a0    ; #txt in a0
   add.l d4,a0    ; indirizzo primo punto sulla texture
   move.l   d6,a2
   subq  #1,d1
txt_loop:
   move.w   (a2)+,d5 ; prendi l'offset
   move.b   (a0,d5.w),(a5)+   ; metti il punto sullo schermo
   dbra  d1,txt_loop ; altro pixel
txt_end:add.l  d2,a1    ; altra riga (a1+width)
   dbra  d7,scan_loop
no_txt:  rts
_no_scan:
   addq  #2,a6
   bra   txt_end

scan_precalc:  ds.w  width ; massima lunghezza di una scanline

*** Rotazioni
xang: dc.w  0
yang: dc.w  0
zang: dc.w  0
rots: lea   sin,a0
   lea   cos,a1
   lea   _3dbuf,a2
   lea   _2dcoords,a3
   lea   norm,a4
   lea   _3dtxt,a5
   lea   z_buf,a6
   movem.w  xang(pc),d0-d1 ; get angles
   move.w   (a0,d0.w*2),d5 ; sinx
   move.w   (a0,d1.w*2),d6 ; siny
   swap  d5
   swap  d6
   move.w   (a1,d0.w*2),d5 ; cosx
   move.w   (a1,d1.w*2),d6 ; cosy   
   move.l   #numpts,d7
   move.l   #128,a0
   ; d5=sinx,cosx
   ; d6=siny,cosy
rot_loop:
   ; rots around y axis
   ; z=zcosy-xsiny
   ; x=xcosy+zsiny
   movem.w  (a2)+,d0-d2 ; get 3d coords
   move.w   d0,d3    ; x
   move.w   d2,d4    ; z
   muls  d6,d3    ; x*cosy
   muls  d6,d4    ; z*cosy
   swap  d6
   muls  d6,d0    ; x*siny
   muls  d6,d2    ; z*siny
   swap  d6
   add.l d2,d3    ; xcosy+zsiny=x'
   sub.l d0,d4    ; zcosy-xsiny=z'
   asr.l #8,d4    ; z ok
   move.l   d3,d0    ; save x coord
   ; rot around x axis
   ; y=ycosß-zsinß
   ; z=zcosß+ysinß
   ; d5=sinx,cosx
   move.w   d1,d3    ; y
   move.w   d4,d2    ; z'
   muls  d5,d3    ; y*cosx
   muls  d5,d2    ; z*cosx
   swap  d5
   muls  d5,d1    ; y*sinx
   muls  d5,d4    ; z*sinx
   swap  d5
   add.l d1,d2    ; zcosx+ysinx=z''
   sub.l d4,d3    ; ycosx-zsinx=y'
   asr.l #8,d2    ; z ok
   add.l #900,d2     ;per la prospettiva (z<>0)
   move.w   d2,(a6)+ ; salva z nel z_buf
   ;
   ; prospettiva
   ;
   neg.l d3
   divs.l   d2,d0    ; x/z
   divs.l   d2,d3    ; y/z
   add.l #128,d0     ; x+off_x
   add.l #128,d3     ; y+off_y
   move.l   d0,(a3)+ ; x_s
   move.l   d3,(a3)+ ; y_s
   ; Ruota le normali
   movem.w  (a4)+,d0-d2 ; get vertex normal
   move.w   d0,d3    ; x
   move.w   d2,d4    ; z
   muls  d6,d3    ; x*cosy
   muls  d6,d4    ; z*cosy
   swap  d6
   muls  d6,d0    ; x*siny
   muls  d6,d2    ; z*siny
   swap  d6
   add.l d2,d3    ; xcosy+zsiny=x'
   sub.l d0,d4    ; zcosy-xsiny=z'
   asr.l #8,d3    ; x ok
   asr.l #8,d4    ; z ok
   move.l   d3,d0    ; save x coord
   move.w   d1,d3    ; y
   move.w   d4,d2    ; z'
   muls  d5,d3    ; y*cosx
   muls  d5,d2    ; z*cosx
   swap  d5
   muls  d5,d1    ; y*sinx
   muls  d5,d4    ; z*sinx
   swap  d5
   add.l d1,d2    ; zcosx+ysinx=z''
   sub.l d4,d3    ; ycosx-zsinx=y'
   asr.l #8,d3    ; y ok
   add.l a0,d3    ; y/2+128
   add.l a0,d0    ; x/2+128
   move.l   d0,(a5)+
   move.l   d3,(a5)+
   dbra  d7,rot_loop
   rts

Chunky2Planar256
   movem.l  d0-d7/a0-a6,-(sp)

   move.l   a0,a2
   adda.l   #plsiz*8,a2
   move.l   #$ff00ff00,a3
   move.l   #$f0f0f0f0,a4
.loop1
   movem.l  (a0),d0-d7
.skip
   move.w   d4,a6
   move.w   d0,d4
   swap  d4
   move.w   d4,d0
   move.w   a6,d4
   move.w   d5,a6
   move.w   d1,d5
   swap  d5
   move.w   d5,d1
   move.w   a6,d5
   move.w   d6,a6
   move.w   d2,d6
   swap  d6
   move.w   d6,d2
   move.w   a6,d6
   move.w   d7,a6
   move.w   d3,d7
   swap  d7
   move.w   d7,d3
   move.w   a6,d7
   exg   d4,a3
   exg   d5,a4
   exg   d6,a5
   exg   d7,a6
   move.l   d0,d6
   move.l   d2,d7
   and.l d4,d0
   and.l d4,d7
   eor.l d7,d2
   eor.l d0,d6
   lsr.l #8,d7
   lsl.l #8,d6
   or.l  d7,d0
   or.l  d6,d2
   move.l   d1,d6
   move.l   d3,d7
   and.l d4,d1
   and.l d4,d7
   eor.l d7,d3
   eor.l d1,d6
   lsr.l #8,d7
   lsl.l #8,d6
   or.l  d7,d1
   or.l  d6,d3
   move.l   d0,d6
   move.l   d1,d7
   and.l d5,d0
   and.l d5,d7
   eor.l d7,d1
   eor.l d0,d6
   lsr.l #4,d7
   or.l  d7,d0
   move.l   d0,(a0)+ ;0
   lsl.l #4,d6
   or.l  d6,d1
   move.l   d1,(a0)+ ;1
   move.l   d2,d6
   move.l   d3,d7
   and.l d5,d2
   and.l d5,d7
   eor.l d7,d3
   eor.l d2,d6
   lsr.l #4,d7
   or.l  d7,d2
   move.l   d2,(a0)+ ;2
   lsl.l #4,d6
   or.l  d6,d3
   move.l   d3,(a0)+ ;3
   exg   a3,d0
   exg   a4,d1
   exg   a5,d2
   exg   a6,d3
   move.l   d0,d6
   move.l   d2,d7
   and.l d4,d0
   and.l d4,d7
   eor.l d7,d2
   eor.l d0,d6
   lsr.l #8,d7
   lsl.l #8,d6
   or.l  d7,d0
   or.l  d6,d2
   move.l   d1,d6
   move.l   d3,d7
   and.l d4,d1
   and.l d4,d7
   eor.l d7,d3
   eor.l d1,d6
   lsr.l #8,d7
   lsl.l #8,d6
   or.l  d7,d1
   or.l  d6,d3
   move.l   d0,d6
   move.l   d1,d7
   and.l d5,d0
   and.l d5,d7
   eor.l d7,d1
   eor.l d0,d6
   lsr.l #4,d7
   or.l  d7,d0
   move.l   d0,(a0)+ ;4
   lsl.l #4,d6
   or.l  d6,d1
   move.l   d1,(a0)+ ;5
   move.l   d2,d6
   move.l   d3,d7
   and.l d5,d2
   and.l d5,d7
   eor.l d7,d3
   eor.l d2,d6
   lsr.l #4,d7
   or.l  d7,d2
   move.l   d2,(a0)+ ;6
   lsl.l #4,d6
   or.l  d6,d3
   move.l   d3,(a0)+ ;7
   move.l   d4,a3
   move.l   d5,a4
   cmpa.l   a0,a2
   bne.w .loop1
.skip2
   suba.l   #plsiz*8,a0
   move.l   #$cccccccc,d4
   move.l   #$aaaaaaaa,d5
   move.l   #plsiz*1,a3
   move.l   #plsiz*7,a4
.loop2
   move.l   (a0),d0
   move.l   d0,d6
   and.l d4,d0
   move.l   4*4(a0),d2
   move.l   d2,d7
   and.l d4,d7
   eor.l d7,d2
   eor.l d0,d6
   lsr.l #2,d7
   lsl.l #2,d6
   or.l  d7,d0
   or.l  d6,d2
   move.l   2*4(a0),d1
   move.l   d1,d6
   and.l d4,d1
   move.l   6*4(a0),d3
   move.l   d3,d7
   and.l d4,d7
   eor.l d7,d3
   eor.l d1,d6
   lsr.l #2,d7
   lsl.l #2,d6
   or.l  d7,d1
   or.l  d6,d3
   move.l   d0,d6
   move.l   d1,d7
   and.l d5,d0
   and.l d5,d7
   eor.l d7,d1
   eor.l d0,d6
   lsr.l #1,d7
   add.l d6,d6
   or.l  d7,d0
   adda.l   a4,a1
   move.l   d0,(a1)
   or.l  d6,d1
   suba.l   a3,a1
   move.l   d1,(a1)
   move.l   d2,d6
   move.l   d3,d7
   and.l d5,d2
   and.l d5,d7
   eor.l d7,d3
   eor.l d2,d6
   lsr.l #1,d7
   add.l d6,d6
   or.l  d7,d2
   suba.l   a3,a1
   move.l   d2,(a1)
   or.l  d6,d3
   suba.l   a3,a1
   move.l   d3,(a1)
   move.l   1*4(a0),d0
   move.l   d0,d6
   and.l d4,d0
   move.l   5*4(a0),d2
   move.l   d2,d7
   and.l d4,d7
   eor.l d7,d2
   eor.l d0,d6
   lsr.l #2,d7
   lsl.l #2,d6
   or.l  d7,d0
   or.l  d6,d2
   move.l   3*4(a0),d1
   move.l   d1,d6
   and.l d4,d1
   move.l   7*4(a0),d3
   move.l   d3,d7
   and.l d4,d7
   eor.l d7,d3
   eor.l d1,d6
   lsr.l #2,d7
   lsl.l #2,d6
   or.l  d7,d1
   or.l  d6,d3
   move.l   d0,d6
   move.l   d1,d7
   and.l d5,d0
   and.l d5,d7
   eor.l d7,d1
   eor.l d0,d6
   lsr.l #1,d7
   add.l d6,d6
   or.l  d7,d0
   suba.l   a3,a1
   move.l   d0,(a1)
   or.l  d6,d1
   suba.l   a3,a1
   move.l   d1,(a1)
   move.l   d2,d6
   move.l   d3,d7
   and.l d5,d2
   and.l d5,d7
   eor.l d7,d3
   eor.l d2,d6
   lsr.l #1,d7
   add.l d6,d6
   or.l  d7,d2
   suba.l   a3,a1
   move.l   d2,(a1)
   or.l  d6,d3
   suba.l   a3,a1
   move.l   d3,(a1)+
   addi.l   #8*4,a0
   cmpa.l   a0,a2
   bne.w .loop2
   movem.l  (a7)+,d0-d7/a0-a6
   rts

*** Fine env-map


******************************************************************************
;        ROUTINE CHE ASPETTA IL VBL
******************************************************************************

WBLAN:
   move.l   $dff004,d0
   and.l #$0001ff00,d0
   cmp.l #$00012b00,d0
   bne.s WBLAN
WBLAN1:
   move.l   $dff004,d0
   and.l #$0001ff00,d0
   cmp.l #$00012b00,d0
   beq.s WBLAN1
   rts

******************************************************************************
         ; Interrupt level 3, VERTB...
******************************************************************************

   cnop  0,4
MyInt6c:
   BTST  #5,$DFF01F
   beq.s NoIntVertb
   MOVEM.L  D0-D7/A0-A6,-(SP)
   tst.w env_flag
   beq.s no_env
   move.w   #511,d2
   move.w   xang(pc),d0
   addq  #1,d0
   and.w d2,d0
   move.w   yang(pc),d1
   addq  #2,d1
   and.w d2,d1
   movem.w  d0-d1,xang
no_env:
   ST FrameFlagCounter
   addq.l   #1,VBcounter
   MOVEM.L  (SP)+,D0-D7/A0-A6
NoIntVertb:
   BTST  #4,$DFF01F
   beq.w NoIntCoper
NoIntCoper:
   MOVE.W   #$70,$DFF09C
   RTE

bump_int6c:
   btst  #5,$dff01f
   beq.s _noint
   move.l   a7,Save_Int_Sp
   movem.l  d0-d7/a0-a6,-(sp)
   lea   $dff000,a6
   bsr.w LightMover
   add.w #1,vbcounter
   movem.l  (sp)+,d0-d7/a0-a6
   move.l   Save_Int_Sp,a7
_noint:  move.w   #$0070,$dff09c
   rte

save_int_sp:   dc.l  0
env_flag:	dc.w	0

; d6=incx
; d7=incy
; a2 ptr to chunky
make_chk:
   lea   sin,a0
   lea   cos,a1
   move.l   #255,d0
   moveq #0,d5    ; y
   moveq #0,d3
   moveq #0,d4
mkl1: move.l   #255,d1
   moveq #0,d2    ; x
   move.w   (a0,d5.w*2),d3 ; (sin y)*256
mkl2: move.w   (a0,d2.w*2),d4 ; (sin x)*256
   muls.w   d3,d4    ; sinx*siny
   asr.l #8,d4
   asr.l #1,d4
   add.w #128,d4
   move.b   d4,(a2)+
   add.w d6,d2
   and.w #511,d5
   and.w #511,d2
   dbra  d1,mkl2
   add.w d7,d5
   dbra  d0,mkl1
   rts

   CNOP  0,4
MakeUpAngles:
   lea   BumpPic,a0
   lea   AnglesTab,a1
   move.l   #256*256-1,d7
.loop:   move.b   1(a0),d0
   sub.b (a0),d0
   ext.w d0
   move.b   256(a0),d1
   sub.b (a0)+,d1
   ext.w d1
   lsr.w #8,d1
   move.b   d0,d1
   move.w   d1,(a1)+
   dbf   d7,.loop
   rts

   CNOP  0,4
Bump: lea   _chk,a0
   lea   Phong,a1
   lea   AnglesTab,a2
   move.l   #256*256-1,d7
   move.w   BumpX,d4
   moveq #0,d0
   moveq #0,d1
   moveq #0,d2
.loop:   move.w   (a2)+,d0
   add.w d4,d0
   move.b   (a1,d0.l),(a0)+
   addq  #1,d4
   dbra  d7,.loop
   rts
   move.w   (a2)+,d1
   add.w d4,d1
   move.b   (a1,d1.l),d5   ; d5=p0
   rol.l #8,d5
   addq  #1,d4
   move.w   (a2)+,d1
   add.w d4,d1
   move.b   (a1,d1.l),d5   ; d5=p0,p1
   rol.l #8,d5
   addq  #1,d4
   move.w   (a2)+,d1
   add.w d4,d1
   move.b   (a1,d1.l),d5   ; d5=p0,p1,p2
   rol.l #8,d5
   addq  #1,d4
   move.w   (a2)+,d1
   add.w d4,d1
   move.b   (a1,d1.l),d5   ; d5=p0,p1,p2,p3
   addq  #1,d4
   move.l   d5,(a0)+
   dbra  d7,.loop
   rts

   CNOP  0,4
LightMover:
   move.w   BumpX,d0
   move.w   Adder,d1

   cmpi.w   #-30,d0
   bge.s .x1_ok
   move.w   #-30,d0
   neg   d1
.x1_ok:
   cmpi.w   #+70,d0
   ble.s .x2_ok
   move.w   #+70,d0
   neg   d1
.x2_ok:
   add.w d1,d0
   move.w   d1,adder
   move.w   d0,BumpX
   rts

bumpx:   dc.w  0
adder:   dc.w  1
*****************************************************************************

FrameFlagCounter:
   dc.w  0

AspettaFrameFlag:
   SF FrameFlagCounter
StoFlaNon:
   TST.B FrameFlagCounter
   BEQ.B StoFlaNon
   RTS

AspettVBL:
   cmp.b #$40,$dff006
   bne.s AspettVBL
AspettVBL2:
   cmp.b #$40,$dff006
   beq.s AspettVBL2
   rts

*******************************************************************************

VBcounter:
   dc.l  0

*******************************************************************************
;        ROUTINE DI PRINTING TESTO
*******************************************************************************

PRINTATESTO:
;  LEA   TESTO(PC),A0   ; lo metto nel maincode
   LEA   VUOTO,A3
   MOVEQ #15-1,D3 ; numero righe
.PRINTRIGA:
   MOVEQ #40-1,D0
.PRINTCHAR2:
   MOVEQ #0,D2
   MOVE.B   (A0)+,D2
   SUB.B #$20,D2
   MULU.W   #8,D2
   MOVE.L   D2,A2
   ADD.L #FONT,A2
   MOVE.B   (A2)+,(A3)
   MOVE.B   (A2)+,40(A3)
   MOVE.B   (A2)+,40*2(A3)
   MOVE.B   (A2)+,40*3(A3)
   MOVE.B   (A2)+,40*4(A3)
   MOVE.B   (A2)+,40*5(A3)
   MOVE.B   (A2)+,40*6(A3)
   MOVE.B   (A2)+,40*7(A3)

   ADDQ.w   #1,A3
   DBRA  D0,.PRINTCHAR2
   ADD.W #40*7,A3
   DBRA  D3,.PRINTRIGA
   RTS

TESTO1:
   dc.b  "                                        "
   dc.b  "                                        "
   dc.b  "     WELCOME TO                         "
   dc.b  "                                        "
   dc.b  "                                        "
   dc.b  "                ANOTHER                 "
   dc.b  "                                        "
   dc.b  "                                        "
   dc.b  "                       FAAAST INTRO     "
   dc.b  "                                        "
   dc.b  "                                        "
   dc.b  "       FROM                             "
   dc.b  "                                        "
   dc.b  "                                        "
   dc.b  "               X-ZONE                   "
   dc.b  "                                        "
   even

TESTO2:
   dc.b  "                                        "
   dc.b  "                                        "
   dc.b  "    CREDITS (?):                        "
   dc.b  "                                        "
   dc.b  "                                        "
   dc.b  "    C O D E         WASHBURN            "
   dc.b  "                                AND     "
   dc.b  "                     MODEM              "
   dc.b  "                                        "
   dc.b  "                                        "
   dc.b  "    G F X            LANCH              "
   dc.b  "                                        "
   dc.b  "                                        "
   dc.b  "    M U S I C      CORROSION            "
   dc.b  "                                        "
   dc.b  "                                        "
   even

TESTO3:
   dc.b  "                                        "
   dc.b  "                                        "
   dc.b  "   WE WANT TO SAY 'YUHUUU!'             "
   dc.b  "                                        "
   dc.b  "                TO A LOT OF FRIENDS:    "
   dc.b  "                                        "
   dc.b  "                                        "
   dc.b  "ABYSS - AGRESSIONE - ALONE - AMIGACIRCLE"
   dc.b  "BALANCE - CAPSULE - CHAOS AGE - CYDONIA "
   dc.b  "DTC - ELVEN - ESSENCE - ETERNALLY - KNB "
   dc.b  "FENIXCORPORATION - GODS - HAUJOBB - LLFB"
   dc.b  "METRO - MORBID VISION - NETWORK - NIVEL7"
   dc.b  "ODRUSBA - QKP - RAM JAM - SOFT ONE - 3LE"
   dc.b  "                                        "
   dc.b  "            AND THE OTHERS???           "
   dc.b  "                                        "
   even

TESTO4:
	dc.b	"                                        "
	dc.b	"  THIS BUNCH OF BYTES                   "
	dc.b	"                                        "
	dc.b	"        WAS PUT TOGHETHER               "
	dc.b	"                                        "
	dc.b	"                 ONLY FOR FUN,          "
	dc.b	"                                        "
	dc.b	"                    FOR FRIENDSHIP      "
	dc.b	"                                        "
	dc.b	"                     AND FOR MY MOTHER  "
	dc.b	"                                        "
	dc.b	"  ...IN ONLY 6 HOURS!!!                 "
	dc.b	"                                        "
	dc.b	"                                        "
	dc.b	" THAT'S ALL FOR NOW...  TIME IS O-V-E-R "
	dc.b	"                                        "
	dc.b	"                                        "
	even

*******************************************************************************
;        ROUTINE DI FADE AGA
*******************************************************************************

FADEAGA:
   bsr.w CALCOLAMETTICOL

   btst.b   #1,FLAGFADEINOUT
   bne.s FADEOUT

FADEIN:
   addq.w   #4,MULTIPLIER
   cmp.w #256,MULTIPLIER
   bne.s NONFINITO
   bchg.b   #1,FLAGFADEINOUT

FADEOUT:
   subq.w   #4,MULTIPLIER
   bne.w NONFINITO

NONFINITO:
   rts

FLAGFADEINOUT:
   dc.w  0

MULTIPLIER:
   dc.w  0

TEMPORANEO:
   dc.l  0

CALCOLAMETTICOL:
   lea   TEMPORANEO(pc),a0
   lea   COL0+2,a1
   lea   COL0B+2,a2
;  lea   PALETTE1(pc),a3      ; lo metto nel maincode
   moveq #8-1,d7

CONVERTIPALETTEBANK:
   moveq #0,d0
   moveq #0,d2
   moveq #0,d3
   moveq #32-1,d6

DALONGAREGISTRI:
   ;rosso   

   move.l   (a3),d4
   andi.l   #%000011111111,d4
   mulu.w   MULTIPLIER(pc),d4
   asr.w #8,d4
   andi.l   #%000011111111,d4
   move.l   d4,d5

   ;verde

   move.l   (a3),d4
   andi.l   #%1111111100000000,d4
   lsr.l #8,d4
   mulu.w   MULTIPLIER(pc),d4
   asr.w #8,d4
   andi.l   #%0000000011111111,d4
   lsl.l #8,d4
   or.l  d4,d5

   ;blu

   move.l   (a3)+,d4
   andi.l   #%111111110000000000000000,d4
   lsr.l #8,d4
   lsr.l #8,d4
   mulu.w   MULTIPLIER(pc),d4
   asr.w #8,d4
   andi.l   #%0000000011111111,d4
   lsl.l #8,d4
   lsl.l #8,d4
   or.l  d4,d5
   move.l   d5,(a0)

   move.b   1(a0),(a2)
   andi.b   #%00001111,(a2)
   move.b   2(a0),d2
   lsl.b #4,d2
   move.b   3(a0),d3
   andi.b   #%00001111,d3
   or.b  d2,d3
   move.b   d3,1(a2)

   move.b   1(A0),d0
   andi.b   #%11110000,d0
   lsr.b #4,d0
   move.b   d0,(a1)
   move.b   2(a0),d2
   andi.b   #%11110000,d2
   move.b   3(a0),d3
   andi.b   #%11110000,d3
   lsr.b #4,d3
   ori.b d2,d3
   move.b   d3,1(a1)
   addq.w   #4,a1
   addq.w   #4,a2
   dbra  d6,DALONGAREGISTRI

   add.w #(128+8),a1
   add.w #(128+8),a2

   dbra  d7,CONVERTIPALETTEBANK
   rts

PALETTE1:
   dc.l  $131131,$462462,$ffffff,$ffffff
   cnop  0,8

PALETTE2:
   dc.l  $131000,$462000,$ffffff,$ffffff
   cnop  0,8

PALETTE3:
   dc.l  $030131,$060462,$ffffff,$ffffff
   cnop  0,8

PALETTE4:
   dc.l  $0e3222,$335033,$ffffff,$ffffff
   cnop  0,8

*******************************************************************************
;           ROUTINE MUSICALE
*******************************************************************************

fade  = 0
jump = 0
system = 1
CIA = 1
exec = 1
opt020 = 1
use = $409504

   include  "play.s"

   Section  modulozzo,DATA
P61_DATA:
   incbin   "P61.over"  ; Compresso

   Section  smp,BSS_C
SAMPLES:
   ds.b  5184

;=============================================================================

   section  dati_oggetto,data

tabdi:   dcb.l 300,0
tabdiv:  dcb.l 301,0

tab1: dcb.w height   ; start x for scanline (#linee dello schermo)
tab2: dcb.w height   ; end   x  "     "
uvtab:   dcb.w height*2,0  ; tab 4 left-x u,v values for each scan

actual:  dc.l  vuoto
logic:   dc.l  bitpl2

multab:  ds.l  256

   include  "over.raw.s"

buf:  ds.l  numfaces+1
z_buf:   ds.l  numfaces+1

   SECTION  grafica,DATA_C

COPPERLIST:
   dc.w  $8E,$2c81
   dc.w  $90,$2cc1
   dc.w  $92,$38
   dc.w  $94,$d0
   dc.w  $102,0
   dc.w  $104,0
   dc.w  $108,-8
   dc.w  $1fc,3

   dc.w  $100,%0010001000000000

BPLPOINTERS:
   dc.w $e0,0,$e2,0
BPLPOINTERS2:
   dc.w $e4,0,$e6,0

   DC.W  $106,$c00   ; SELEZIONA PALETTE 0 (0-31), NIBBLE ALTI
COL0:
   DC.W  $180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
   DC.W  $190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
   DC.W  $1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
   DC.W  $1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

   DC.W  $106,$e00   ; SELEZIONA PALETTE 0 (0-31), NIBBLE BASSI
COL0B:
   DC.W  $180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
   DC.W  $190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
   DC.W  $1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
   DC.W  $1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

   DC.W  $106,$2C00  ; SELEZIONA PALETTE 1 (32-63), NIBBLE ALTI

   DC.W  $180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
   DC.W  $190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
   DC.W  $1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
   DC.W  $1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

   DC.W  $106,$2E00  ; SELEZIONA PALETTE 1 (32-63), NIBBLE BASSI

   DC.W  $180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
   DC.W  $190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
   DC.W  $1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
   DC.W  $1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

   DC.W  $106,$4C00  ; SELEZIONA PALETTE 2 (64-95), NIBBLE ALTI

   DC.W  $180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
   DC.W  $190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
   DC.W  $1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
   DC.W  $1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

   DC.W  $106,$4E00  ; SELEZIONA PALETTE 2 (64-95), NIBBLE BASSI

   DC.W  $180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
   DC.W  $190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
   DC.W  $1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
   DC.W  $1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

   DC.W  $106,$6C00  ; SELEZIONA PALETTE 3 (96-127), NIBBLE ALTI

   DC.W  $180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
   DC.W  $190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
   DC.W  $1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
   DC.W  $1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

   DC.W  $106,$6E00  ; SELEZIONA PALETTE 3 (96-127), NIBBLE BASSI

   DC.W  $180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
   DC.W  $190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
   DC.W  $1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
   DC.W  $1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

   DC.W  $106,$8C00  ; SELEZIONA PALETTE 4 (128-159), NIBBLE ALTI

   DC.W  $180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
   DC.W  $190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
   DC.W  $1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
   DC.W  $1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

   DC.W  $106,$8E00  ; SELEZIONA PALETTE 4 (128-159), NIBBLE BASSI

   DC.W  $180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
   DC.W  $190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
   DC.W  $1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
   DC.W  $1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

   DC.W  $106,$AC00  ; SELEZIONA PALETTE 5 (160-191), NIBBLE ALTI

   DC.W  $180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
   DC.W  $190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
   DC.W  $1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
   DC.W  $1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

   DC.W  $106,$AE00  ; SELEZIONA PALETTE 5 (160-191), NIBBLE BASSI

   DC.W  $180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
   DC.W  $190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
   DC.W  $1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
   DC.W  $1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

   DC.W  $106,$CC00  ; SELEZIONA PALETTE 6 (192-223), NIBBLE ALTI

   DC.W  $180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
   DC.W  $190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
   DC.W  $1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
   DC.W  $1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

   DC.W  $106,$CE00  ; SELEZIONA PALETTE 6 (192-223), NIBBLE BASSI

   DC.W  $180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
   DC.W  $190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
   DC.W  $1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
   DC.W  $1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

   DC.W  $106,$EC00  ; SELEZIONA PALETTE 7 (224-255), NIBBLE ALTI

   DC.W  $180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
   DC.W  $190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
   DC.W  $1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
   DC.W  $1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

   DC.W  $106,$EE00  ; SELEZIONA PALETTE 7 (224-255), NIBBLE BASSI

   DC.W  $180,0,$182,0,$184,0,$186,0,$188,0,$18A,0,$18C,0,$18E,0
   DC.W  $190,0,$192,0,$194,0,$196,0,$198,0,$19A,0,$19C,0,$19E,0
   DC.W  $1A0,0,$1A2,0,$1A4,0,$1A6,0,$1A8,0,$1AA,0,$1AC,0,$1AE,0
   DC.W  $1B0,0,$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1BE,0

A set $2c+1
   REPT  ($ff-$2c)/2
   dc.b  A,$01,$ff,$fe
   dc.w  $10a,-8-40
A set A+1
   dc.b  A,$01,$ff,$fe
   dc.w  $10a,-8
A set A+1
   ENDR
   dc.w  $ffdf,$fffe
A set 0
   REPT  $2c/2+1
   dc.b  A,$01,$ff,$fe
   dc.w  $10a,-8-40
A set A+1
   dc.b  A,$01,$ff,$fe
   dc.w  $10a,-8
A set A+1
   ENDR

   dc.w  $ffff,$fffe

flash_cop:
   dc.w  $100,$200
   dc.w  $106,0
   dc.w  $180,$fff
   dc.w  $106,$200
   dc.w  $180,$fff
   dc.w  $ffff,$fffe

   ; env-copperlist
env_cop:
   dc.w  $120,$0000
   dc.w  $122,$0000
   dc.w  $124,$0000
   dc.w  $126,$0000
   dc.w  $128,$0000
   dc.w  $12a,$0000
   dc.w  $12c,$0000
   dc.w  $12e,$0000
   dc.w  $130,$0000
   dc.w  $132,$0000
   dc.w  $134,$0000
   dc.w  $136,$0000
   dc.w  $138,$0000
   dc.w  $13a,$0000
   dc.w  $13c,$0000
   dc.w  $13e,$0000
   dc.w  $1fc,$4003  ; The magical F-mode register
   dc.w  $102,$8800  ; Hor-Scroll
   dc.w  $104,$0224  ; Sprite/Gfx priority
   dc.w  $108,-8  ; Modulo (odd)
   dc.w  $10A,-8  ; Modulo (even)
   dc.w  $8E,$2c81   ; Screen Size
   dc.w  $90,$2ca1   ; Screen Size
   dc.w  $92,$0048   ; H-start
   dc.w  $94,$00c0   ; H-stop
   dc.w  $100,$211   ; Bit-Plane control reg.
   ; -=> Palette <=-
   incbin   "fog4.pal"
   dc.w  $106,0,$180,0
   dc.w  $120,0,$122,0,$124,0,$126,0
   dc.w  $128,0,$12a,0,$12c,0,$12e,0
   dc.w  $130,0,$132,0,$134,0,$136,0
   dc.w  $138,0,$13a,0,$13c,0,$13e,0
env_bpl:dc.w   $e0,0,$e2,0
   dc.w  $e4,0,$e6,0
   dc.w  $e8,0,$ea,0
   dc.w  $ec,0,$ee,0
   dc.w  $f0,0,$f2,0
   dc.w  $f4,0,$f6,0
   dc.w  $f8,0,$fa,0
   dc.w  $fc,0,$fe,0
   DC.W  $FFFF,$FFFE

bump_cop:
   dc.w  $120,$0000
   dc.w  $122,$0000
   dc.w  $124,$0000
   dc.w  $126,$0000
   dc.w  $128,$0000
   dc.w  $12a,$0000
   dc.w  $12c,$0000
   dc.w  $12e,$0000
   dc.w  $130,$0000
   dc.w  $132,$0000
   dc.w  $134,$0000
   dc.w  $136,$0000
   dc.w  $138,$0000
   dc.w  $13a,$0000
   dc.w  $13c,$0000
   dc.w  $13e,$0000
   dc.w  $1fc,$4003  ; The magical F-mode register
   dc.w  $102,$8800  ; Hor-Scroll
   dc.w  $104,$0224  ; Sprite/Gfx priority
   dc.w  $108,-8  ; Modulo (odd)
   dc.w  $10A,-8  ; Modulo (even)
   dc.w  $8E,$2c81   ; Screen Size
   dc.w  $90,$2ca1   ; Screen Size
   dc.w  $92,$0048   ; H-start
   dc.w  $94,$00c0   ; H-stop
   dc.w  $100,$211   ; Bit-Plane control reg.

   incbin   "fog3.pal"
bump_bpl:
BPL1: dc.w  $e0,0,$e2,0
BPL2: dc.w  $e4,0,$e6,0
BPL3: dc.w  $e8,0,$ea,0
BPL4: dc.w  $ec,0,$ee,0
BPL5: dc.w  $f0,0,$f2,0
BPL6: dc.w  $f4,0,$f6,0
BPL7: dc.w  $f8,0,$fa,0
BPL8: dc.w  $fc,0,$fe,0
   dc.w  $ffff,$fffe

logo_cop:
   dc.w  $120,$0000
   dc.w  $122,$0000
   dc.w  $124,$0000
   dc.w  $126,$0000
   dc.w  $128,$0000
   dc.w  $12a,$0000
   dc.w  $12c,$0000
   dc.w  $12e,$0000
   dc.w  $130,$0000
   dc.w  $132,$0000
   dc.w  $134,$0000
   dc.w  $136,$0000
   dc.w  $138,$0000
   dc.w  $13a,$0000
   dc.w  $13c,$0000
   dc.w  $13e,$0000
   dc.w  $1fc,$4000  ; The magical F-mode register
   dc.w  $102,$8800  ; Hor-Scroll
   dc.w  $104,$0224  ; Sprite/Gfx priority
   dc.w  $108,0   ; Modulo (odd)
   dc.w  $10A,0   ; Modulo (even)
   dc.w  $8E,$2c81   ; Screen Size
   dc.w  $90,$ffa1   ; Screen Size
   dc.w  $92,$0048   ; H-start
   dc.w  $94,$00c0   ; H-stop
   dc.w  $100,$6201  ; Bit-Plane control reg.
   incbin   "over.pal"
pic_bpl:dc.w   $e0,0,$e2,0
   dc.w  $e4,0,$e6,0
   dc.w  $e8,0,$ea,0
   dc.w  $ec,0,$ee,0
   dc.w  $f0,0,$f2,0
   dc.w  $f4,0,$f6,0
   dc.w  $ffff,$fffe

   SECTION  pics,DATA_C
FONDINO:incbin "fondino.raw"

   SECTION  picsvuote,BSS_C
VUOTO:   ds.b  40*256*8
bitpl2:  ds.b  width*height

   SECTION  fontidelclitunno,DATA_c
FONT: incbin   "nice.fnt"

	section pict,data_c
   cnop  0,8
pic_logo:incbin   "over2.raw"
	ds.b	10*256

   section  chkscreen,bss
_chk: ds.b  width*height
rx_val:  ds.w  16
rx_tab:  ds.l  256*16

   section  textures,bss
bumppic:ds.b   256*256
anglestab:
   ds.w  256*256
phong:   ds.b  256*256

   section  sin-costab,data
*** Sintable 512 valori
sin:
   DC.W  $0000,$0003,$0006,$0009,$000C,$000F,$0012,$0015,$0018,$001B
   DC.W  $001E,$0021,$0025,$0028,$002B,$002E,$0031,$0034,$0037,$003A
   DC.W  $003D,$0040,$0043,$0046,$0049,$004C,$004F,$0052,$0054,$0057
   DC.W  $005A,$005D,$0060,$0063,$0066,$0069,$006B,$006E,$0071,$0074
   DC.W  $0076,$0079,$007C,$007F,$0081,$0084,$0087,$0089,$008C,$008E
   DC.W  $0091,$0093,$0096,$0098,$009B,$009D,$00A0,$00A2,$00A5,$00A7
   DC.W  $00A9,$00AB,$00AE,$00B0,$00B2,$00B4,$00B7,$00B9,$00BB,$00BD
   DC.W  $00BF,$00C1,$00C3,$00C5,$00C7,$00C9,$00CB,$00CD,$00CE,$00D0
   DC.W  $00D2,$00D4,$00D5,$00D7,$00D9,$00DA,$00DC,$00DD,$00DF,$00E0
   DC.W  $00E2,$00E3,$00E5,$00E6,$00E7,$00E9,$00EA,$00EB,$00EC,$00ED
   DC.W  $00EE,$00EF,$00F0,$00F1,$00F2,$00F3,$00F4,$00F5,$00F6,$00F7
   DC.W  $00F7,$00F8,$00F9,$00F9,$00FA,$00FB,$00FB,$00FC,$00FC,$00FC
   DC.W  $00FD,$00FD,$00FD,$00FE,$00FE,$00FE,$00FE,$00FE
*** Costable
cos:
   DC.W  $00FF,$00FE,$00FE,$00FE,$00FE,$00FE,$00FE,$00FE,$00FD,$00FD
   Dc.W  $00FD,$00FC,$00FC,$00FB,$00FB,$00FA,$00FA,$00F9,$00F8,$00F8
   DC.W  $00F7,$00F6,$00F5,$00F4,$00F4,$00F3,$00F2,$00F1,$00F0,$00EF
   DC.W  $00EE,$00EC,$00EB,$00EA,$00E9,$00E7,$00E6,$00E5,$00E3,$00E2
   DC.W  $00E1,$00DF,$00DE,$00DC,$00DA,$00D9,$00D7,$00D5,$00D4,$00D2
   DC.W  $00D0,$00CE,$00CD,$00CB,$00C9,$00C7,$00C5,$00C3,$00C1,$00BF
   DC.W  $00BD,$00BB,$00B9,$00B6,$00B4,$00B2,$00B0,$00AD,$00AB,$00A9
   DC.W  $00A7,$00A4,$00A2,$009F,$009D,$009A,$0098,$0095,$0093,$0090
   DC.W  $008E,$008B,$0089,$0086,$0083,$0081,$007E,$007B,$0078,$0076
   DC.W  $0073,$0070,$006D,$006A,$0068,$0065,$0062,$005F,$005C,$0059
   DC.W  $0056,$0053,$0050,$004D,$004A,$0047,$0044,$0041,$003E,$003B
   DC.W  $0038,$0035,$0032,$002F,$002C,$0029,$0026,$0023,$0020,$001D
   DC.W  $001A,$0016,$0013,$0010,$000D,$000A,$0007,$0004,$0001,$FFFE
   DC.W  $FFFB,$FFF8,$FFF5,$FFF2,$FFEF,$FFEC,$FFE9,$FFE6,$FFE2,$FFDF
   DC.W  $FFDC,$FFD9,$FFD6,$FFD3,$FFD0,$FFCD,$FFCA,$FFC7,$FFC4,$FFC1
   DC.W  $FFBE,$FFBB,$FFB8,$FFB5,$FFB2,$FFAF,$FFAC,$FFA9,$FFA6,$FFA3
   DC.W  $FFA0,$FF9D,$FF9A,$FF98,$FF95,$FF92,$FF8F,$FF8C,$FF8A,$FF87
   DC.W  $FF84,$FF81,$FF7F,$FF7C,$FF79,$FF77,$FF74,$FF72,$FF6F,$FF6C
   DC.W  $FF6A,$FF67,$FF65,$FF62,$FF60,$FF5E,$FF5B,$FF59,$FF56,$FF54
   DC.W  $FF52,$FF50,$FF4D,$FF4B,$FF49,$FF47,$FF45,$FF43,$FF41,$FF3E
   DC.W  $FF3C,$FF3B,$FF39,$FF37,$FF35,$FF33,$FF31,$FF2F,$FF2D,$FF2C
   DC.W  $FF2A,$FF28,$FF27,$FF25,$FF24,$FF22,$FF21,$FF1F,$FF1E,$FF1C
   DC.W  $FF1B,$FF19,$FF18,$FF17,$FF16,$FF14,$FF13,$FF12,$FF11,$FF10
   DC.W  $FF0F,$FF0E,$FF0D,$FF0C,$FF0B,$FF0A,$FF0A,$FF09,$FF08,$FF07
   DC.W  $FF07,$FF06,$FF06,$FF05,$FF05,$FF04,$FF04,$FF03,$FF03,$FF03
   DC.W  $FF02,$FF02,$FF02,$FF02,$FF02,$FF02,$FF02,$FF02,$FF02,$FF02
   DC.W  $FF02,$FF02,$FF02,$FF02,$FF03,$FF03,$FF03,$FF04,$FF04,$FF04
   DC.W  $FF05,$FF05,$FF06,$FF07,$FF07,$FF08,$FF09,$FF09,$FF0A,$FF0B
   DC.W  $FF0C,$FF0D,$FF0E,$FF0F,$FF10,$FF11,$FF12,$FF13,$FF14,$FF15
   DC.W  $FF16,$FF18,$FF19,$FF1A,$FF1C,$FF1D,$FF1E,$FF20,$FF21,$FF23
   DC.W  $FF24,$FF26,$FF28,$FF29,$FF2B,$FF2D,$FF2E,$FF30,$FF32,$FF34
   DC.W  $FF36,$FF38,$FF3A,$FF3C,$FF3E,$FF40,$FF42,$FF44,$FF46,$FF48
   DC.W  $FF4A,$FF4C,$FF4F,$FF51,$FF53,$FF55,$FF58,$FF5A,$FF5D,$FF5F
   DC.W  $FF61,$FF64,$FF66,$FF69,$FF6B,$FF6E,$FF70,$FF73,$FF76,$FF78
   DC.W  $FF7B,$FF7E,$FF80,$FF83,$FF86,$FF88,$FF8B,$FF8E,$FF91,$FF94
   DC.W  $FF96,$FF99,$FF9C,$FF9F,$FFA2,$FFA5,$FFA8,$FFAB,$FFAE,$FFB1
   DC.W  $FFB3,$FFB6,$FFB9,$FFBC,$FFBF,$FFC2,$FFC6,$FFC9,$FFCC,$FFCF
   DC.W  $FFD2,$FFD5,$FFD8,$FFDB,$FFDE,$FFE1,$FFE4,$FFE7,$FFEA,$FFEE
   DC.W  $FFF1,$FFF4,$FFF7,$FFFA,$FFFD,$0000,$0002,$0006,$0009,$000C
   DC.W  $000F,$0012,$0015,$0018,$001B,$001E,$0021,$0025,$0028,$002B
   DC.W  $002E,$0031,$0034,$0037,$003A,$003D,$0040,$0043,$0046,$0049
   DC.W  $004C,$004F,$0052,$0055,$0058,$005B,$005E,$0061,$0063,$0066
   DC.W  $0069,$006C,$006F,$0072,$0074,$0077,$007A,$007D,$007F,$0082
   DC.W  $0085,$0087,$008A,$008D,$008F,$0092,$0094,$0097,$0099,$009C
   DC.W  $009E,$00A1,$00A3,$00A6,$00A8,$00AA,$00AC,$00AF,$00B1,$00B3
   DC.W  $00B5,$00B8,$00BA,$00BC,$00BE,$00C0,$00C2,$00C4,$00C6,$00C8
   DC.W  $00CA,$00CC,$00CE,$00CF,$00D1,$00D3,$00D5,$00D6,$00D8,$00DA
   DC.W  $00DB,$00DD,$00DE,$00E0,$00E1,$00E3,$00E4,$00E6,$00E7,$00E8
   DC.W  $00E9,$00EB,$00EC,$00ED,$00EE,$00EF,$00F0,$00F1,$00F2,$00F3
   DC.W  $00F4,$00F5,$00F6,$00F7,$00F7,$00F8,$00F9,$00F9,$00FA,$00FB
   DC.W  $00FB,$00FC,$00FC,$00FC,$00FD,$00FD,$00FD,$00FE,$00FE,$00FE
   DC.W  $00FE,$00FE
