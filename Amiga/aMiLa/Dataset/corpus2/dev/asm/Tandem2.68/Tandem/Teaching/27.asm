* 27.asm      Use TL routines to open a window    version 0.00   1.9.97

 include 'Front.i'        ;*** Change to 'Tandem.i' to step thru TL's ***

strings: dc.b 0
st_1: dc.b 'My Screen',0 ;1
st_2: dc.b 'My Window',0 ;2

 ds.w 0

dpen: dc.l -1              ;default pens structure

* open screen & window; close & exit when close gadget clicked
Program:
 TLscreen #2,#st_1,#dpen   ;open screen: 2 planes, title st_2, pens dpen
 beq Pr_bad                ;go if can't
 TLwindow #0,#20,#10,#100,#20,#400,#150,#0,#st_2
                           ;open window 0
                           ;posn 20,10  minsize 100,20  maxsize 400,150
                           ;flags: #0=Front.i's default (i.e. HIRES)
                           ;title st_2
 beq Pr_bad                ;go if can't
Pr_wait:
 TLkeyboard                ;get IDCMP
 cmp.b #$93,d0             ;close window?
 bne Pr_wait               ;no, keep waiting
 rts                       ;Front.i closes everything
Pr_bad:
 move.l xxp_intb(a4),a6
 sub.l a0,a0
 jsr _LVODisplayBeep(a6)   ;if bad, beep existing screens
 rts
