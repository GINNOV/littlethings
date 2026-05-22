;                 MANX to NORMAL PC Addressing Conversion
;
;  Amoung many other deficencies, the Manx C compiler does not correctly
;  compute PC relative addressing modes. Unfortunately, the compiler tends
;  to use this mode when it compiles C switches. If you were to take the
;  assembly listing as output by the Manx compiler and assemble it with
;  another company's assembler, the resulting code would not run properly.
;  The reason that Manx compiled code DOES WORK with the Manx assembler is
;  because the assembler is written incorrectly as well, and in this case,
;  two wrongs just happen to make a right. Here is a typical C switch as
;  output by the Manx compiler.

;.L1 move.w   Number0to2,d0 ;there are 3 cases in the switch for this example
;    moveq    #-1,d1        ;returns d1 = the switch taken
;    bra      .L3
;.L2 dc.w     .0-.L4-2      ;CASE 0
;    dc.w     .1-.L4-2      ;CASE 1
;    dc.w     .2-.L4-2      ;CASE 2
;.L3 cmpi.w   #3,d0         ;check that the number is from 0 to 2
;    bcc      .L5
;    add.w    d0,d0
;    move.w   .L2(pc,d0.w),d0
;.L4 jmp      (pc,d0.w)     ;this LOOKS like 0(pc,d0.w) to another assembler
                            ;but Manx translates it as .L4+2(pc,d0.w)
;.L5 moveq    #0,d0
;    rts
;.0  moveq    #0,d1
;    bra.s    .L5
;.1  moveq    #1,d1
;    bra.s    .L5
;.2  moveq    #2,d1
;    bra.s    .L5

; The correct (i.e. NOT MANX WAY) code should be as follows:

.L1 move.w   Number0to2,d0
    moveq    #-1,d1
    bra.s    .L3
.L2 dc.w     .0-.L4-2         ;CASE 0
    dc.w     .1-.L4-2         ;CASE 1
    dc.w     .2-.L4-2         ;CASE 2
.L3 move.w   d0,d1
    subq.w   #3,d1            ;faster
    bcc.s    .L5
    add.w    d0,d0
    move.w   .L2(pc,d0.w),d0
.L4 jmp      .L4+2(pc,d0.w)   ;This is correct
.L5 moveq    #0,d0
    rts
.0  moveq    #0,d1
    bra.s    .L5
.1  moveq    #1,d1
    bra.s    .L5
.2  moveq    #2,d1
    bra.s    .L5

Number0to2 dc.w 2
