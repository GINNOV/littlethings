    cnop  0,4
    ifd  gos_s_rnd
RandomSeed
    add.l  d0,d1
    movem.l  d0/d1,rnd
LongRnd   movem.l d2-d3,-(sp)
    movem.l  rnd,d0/d1
    andi.b  #$0e,d0
    ori.b  #$20,d0
    move.l  d0,d2
    move.l  d1,d3
    add.l  d2,d2
    addx.l  d3,d3
    add.l  d2,d0
    addx.l  d3,d1
    swap  d3
    swap  d2
    move.w  d2,d3
    clr.w  d2
    add.l  d2,d0
    addx.l  d3,d1
    movem.l  d0/d1,rnd
    move.l  d1,d0
    movem.l  (sp)+,d2-d3
    rts

Random
    move.w  d2,-(sp)
    addq  #1,d0
    move.w  d0,d2
    beq  AH10
    bsr  LongRnd
    clr.w  d0
    swap  d0
    divu.w  d2,d0
    clr.w  d0
    swap  d0
AH10      move.w   (sp)+,d2
    rts
    endc

    ifd  gos_randtime
ctime
    move.l  #xDateStamp,d1
    move.l  DOSBase,a6
    jsr  -192(a6)
    rts

    cnop  0,4

xDateStamp
xds_std    ds.l 1
xds_min    ds.l 1
xds_tick   ds.l 1
rand     ds.l   1
rnd      ds.l   2

    endc


    ifd  gos_s_waits
_s_waits
    move.l  stdin,d1
    move.l  #1,d2
    move.l  DOSBase,a6
    jsr  -204(a6)
    rts
    endc


    IFD  x_go_numb02
_s_numb0
    moveq.l  #0,d3
_numbloopa
    addq  #1,d3
    tst.b  (a5)+
    bne  _numbloopa
    subq  #1,d3
    rts
    ENDC

    IFD  go_s_writes0
s_writes0
    move.l  DOSBase,a6
    move.l  stdout,d1
    jsr  -48(a6)
    rts
    ENDC

    IFD  go_s_write0
s_write0
    move.l  DOSBase,a6
    jsr  -48(a6)
    rts
    ENDC

    ifd  gos_s_raw
_s_raw
    move.l  DOSBase,a6
    jsr  -60(a6)
    move.l  d0,d1
    move.l  DOSBase,a6
    moveq  #1,d2
    jsr  -426(a6)
    rts
    endc

    ifd  gos_s_con
_s_con
    move.l  DOSBase,a6
    jsr  -60(a6)
    move.l  d0,d1
    move.l  DOSBase,a6
    moveq  #0,d2
    jsr  -426(a6)
    rts
    endc

    ifd  gos_s_reads
_s_reads
    move.l  DOSBase,a6
    move.l  stdin,d1
    jsr  -42(a6)
    rts
    endc

    ifd  gos_s_read1
_s_read1
    move.l  DOSBase,a6
    move.l  #1,d3
    move.l  stdin,d1
    jsr  -42(a6)
    rts
    endc


    IFD  gos_st_cmp
st_cmp
    move.l  a0,a2
    move.b  (a0),d1
st_cmp_loop1
    moveq.l  #0,d3
    addq.l  #1,d0
    tst.b  (a1)
    beq  st_cmp_aus1
    cmp.b  (a1)+,d1
    bne  st_cmp_loop1
    add.l  #1,a2
st_cmp_loop2
    addq.l  #1,d0
    addq.l  #1,d3
    tst.b  (a2)
    beq  st_cmp_aus2
    tst.b  (a1)
    beq  st_cmp_aus1
    cmp.b  (a2)+,(a1)+
    bne  st_cmp2
    bra  st_cmp_loop2
st_cmp2
    sub.l  #1,a1
    subq.l  #1,d0
    bra  st_cmp
st_cmp_aus1
    moveq.l  #0,d0
    rts
st_cmp_aus2
    sub.l  d3,d0
    rts
    ENDC

    IFD  gos_longzustring
* Long in d2 -> String in a0
_s_longzustring:
    move.l  a0,a2
    moveq.l  #0,d3
    moveq.l  #0,d4
    tst.l  d2    ;Zahl positiv
    bpl  _l2splus    ;wenn so
    neg.l  d2    ;sonst wandeln
    move.b  #1,d3    ;markiert negative Zahl
_l2splus
    moveq  #9,d0    ;10 Digits konnvertieren

    move.l  a2,a0
    lea  _l2stab,a1    ;Tabelle
_l2snext
    moveq  #'0',d1    ;Fange mit Digit '0' an
_l2sdec
    addq  #1,d1    ;Digit + 1
    sub.l  (a1),d2    ;noch drin?
    bcc.s  _l2sdec    ;wenn so
    subq  #1,d1    ;korrigiere Digit
    add.l  (a1),d2    ;den auch
    tst.b  d4
    bne  _l2sin
    cmp.b  #'0',d1
    bne  _l2sin
    bra  _l2sgos
_l2sin
    moveq.l  #1,d4
    move.b  d1,(a0)+    ;Digiit -> Buffer
_l2sgos
    lea  4(a1),a1    ;next power_10
    dbra  d0,_l2snext    ;for 8 Digits
    ;move.l  a2,a0                   ;Nun 0-Unterdr. u. Vorz.
    moveq.l  #0,d0
    tst.b  d3    ;war Zahl negativ?
    beq  _l2sdone    ;wenn nicht
    moveq.l  #-1,d0    ;sonst - vorsetzen
_l2sdone    rts

    cnop  0,4
_l2stab

    dc.l  1000000000
    cnop  0,4
    dc.l  100000000
    cnop  0,4
    dc.l  10000000
    cnop  0,4
    dc.l  1000000
    cnop  0,4
    dc.l  100000
    cnop  0,4
    dc.l  10000
    cnop  0,4
    dc.l  1000
    cnop  0,4
    dc.l  100
    cnop  0,4
    dc.l  10
    cnop  0,4
    dc.l  1
    ENDC

    ifd  gos_s_atoi
atoi       movem.l a1-a5/d1-d7,-(sp)
    move.l  a0,-(sp)
    clr.w  d1
atoi_l1  addq  #1,d1

    cmp.b  #48,(a0)+
    bge  atoi_l1

atoi_l5
    subq  #1,d1
    cmp.w  #10,d1
    bgt  err_overflow
    subq  #1,d1
    move.l  (sp)+,a0
    clr.l  d0
    lea  atoi_tab,a1

atoi_l2
    move.b  (a0)+,d2
    ext.w  d2
    sub.w  #48,d2
    cmp.w  #9,d2
    bgt  err_overflow
    tst.w  d2
    beq  atoi_nextpos
    move.w  d1,d3
    lsl.w  #2,d3
    subq  #1,d2
atoi_l3
    add.l  0(a1,d3.w),d0
    dbra  d2,atoi_l3

atoi_nextpos
    dbra  d1,atoi_l2
atoi_end
    movem.l  (sp)+,a1-a5/d1-d7
    rts

err_overflow
    move.l  #-1,a0
    clr.l  d0
    bra  atoi_end

    cnop  0,4

atoi_tab   dc.l  1
    dc.l  10
    dc.l  100
    dc.l  1000
    dc.l  10000
    dc.l  100000
    dc.l  1000000
    dc.l  10000000
    dc.l  100000000
    dc.l  1000000000
    endc


    ifd  gos_FillString
_fillString
_filoop
    ;cmp.b  #0,(a1)
    ;beq   _fillaus
    move.b  d1,(a1)+
    dbra  d0,_filoop
_fillaus
    rts
    endc

    ifd  gos_NullString
_nullString
    moveq.l  #0,d1
_nuloop
    ;cmp.b  #0,(a1)
    ;beq   _nullaus
    move.b  d1,(a1)+
    dbra  d0,_nuloop
_nullaus
    rts
    endc


    ifd  gos_vtov
s_vtov

_m1vtov
    move.b  (a0)+,(a1)+
    cmpi.b  #0,(a0)
    dbeq  d0,_m1vtov
    rts
    endc

    ifd  gos_2in1o    ;chain Buffer,String1,String2,maxLen
s_2in1o                                                         ; Byte
m12in1
    move.b  (a1)+,(a0)+
    tst.b  (a1)
    beq  m22in1
    cmp.b  #13,(a1)
    beq  m22in1
    cmp.b  #10,(a1)
    beq  m22in1

    dbeq  d0,m12in1

m22in1
    move.b  (a2)+,(a0)+
    tst.b  (a2)
    beq  zin1out
    cmp.b  #13,(a2)
    beq  zin1out
    cmp.b  #10,(a2)
    beq  zin1out

    dbeq  d0,m22in1
zin1out
    move.b  #0,(a0)
    rts
    endc

    ifd  _gos_s_str_tl
str_tl
    move.l  #long,d2
    move.l  DOSBase,a6
    jsr  _LVOStrToLong(a6),move.l,long,d1

    rts
    endc


    ifd  gos_cmp0
s_cmp0
    cmp.b  #0,(a0)
    beq  _a0is0
    cmp.b  #0,(a1)
    beq  c_high0
    cmp.b  #10,(a0)
    beq  _a0is0
    cmp.b  #10,(a1)
    beq  c_high0

    cmp.b  (a1)+,(a0)+
    dbne  d0,s_cmp0
    bgt  c_high0
    blt  c_low0
c_gleich0
    moveq.l  #0,d0
    rts
c_high0
    moveq.l  #1,d0
    rts
c_low0
    moveq.l  #-1,d0
    rts
_a0is0
    cmp.b  #0,(a1)
    beq  c_gleich0

    cmp.b  #10,(a1)
    beq  c_gleich0

    bra  c_low0
    endc

    ifd  go_getstring2    ;PuffPos zurück in d0
s_getstring
s_test_gs
    move.b  (a5),d7
    outcase.b  #32,s_gs_aus
    ltoutcase.b  #31,s_gs_aus


    ifd  DELIMITERS
    move.l  DELIMITERS,a4
    looutcase.b  #65,s_gs_ein1
    hioutcase.b  #122,s_gs_ein1
    looutcase.b  #97,s_gs_zw3
    bra  s_gs_zw4
s_gs_zw3
    hioutcase.b  #90,s_gs_ein1
s_gs_zw4
    endc
s_gs_wert
    move.b  (a5)+,(a3)+
    addq.l  #1,d0
    bra  s_test_gs
s_gs_ein1
    cl5
s_gs_ein
    move.b  (a4)+,d5
    cmp.b  (a5),d5
    beq  s_gs_aus
    ifno.b  d5,s_gs_ein
    bra  s_gs_wert
s_gs_aus
    move.b  #0,(a3)
    addq.l  #1,d0
    rts
    endc

    ifd  gos_hex
sx_hex
    moveq  #8,d1
sx_next
    rol.l  #4,d2
    move.l  d2,d3
    and.b  #$0f,d3
    add.b  #48,d3
    cmp.b  #58,d3
    bcs  sx_out
    addq.b  #7,d3
sx_out
    move.b  d3,(a0)+
    dbra  d1,sx_next
    move.b  #0,(a0)
    rts
    endc

    ifd  gos_s_copyvor
s_copyvor
    add.l  d0,a0
    move.l  a0,a1

    sub.l  d3,a1
    sub.l  d0,d2

    cmp.l  d2,d1
    if.l  d1,_>,d2,d2,s_cvlxn
    move.l  d2,d1
    ifend  s_cvlxn

s_cv_loop
    move.b  (a0)+,(a1)+
    dbra  d1,s_cv_loop
    rts
    endc

    ifd  gos_s_copynach
s_copynach
    sub.l  d0,d2

    cmp.l  d2,d1
    if.l  d1,_>,d2,d2,s_cvlxn
    move.l  d2,d1
    ifend  s_cvlxn

    add.l  d0,a0
    add.l  d1,a0
    add.l  #1,a0
    move.l  a0,a1
    add.l  d3,a1

s_cv_loopn
    move.b  -(a0),-(a1)
    dbra  d1,s_cv_loopn
    rts
    endc


    ifd  gos_s_insert_z
s_insert_z
    add.l  d2,a0
    sub.l  #1,a0
    move.l  a0,a1
    sub.l  #1,a1
    sub.l  d0,d2
    sub.l  #2,d2

s_insert_z_loop
    move.b  -(a1),-(a0)
    dbra  d2,s_insert_z_loop
    move.b  d1,(a0)
    rts
    endc

ser_getStatus
    move.l  #0,40(a1)
    move.l  #0,36(a1)
    move.w  #CMDquery,28(a1)
    movea.l  4,a6
    jsr  -456(a6)
    rts

    ifd  _x_x_x
_FC_Waitser

    GetMsg  _SerReadPort0
    GetSer  0,#Buff2,#1

    moveq.l  #0,d1
    move.b  15(a1),d1
    bset.l  d1,d0
    bset.l  #12,d0
    or.l  d0,_SigMask
    move.l  _SigMask,d0


    move.l  4,a6
    jsr  -318(a6)
    rts
    endc

    ifd  _s_setser
_FC_setser1
    moveq.l  #0,d1
    move.b  15(a0),d1
    moveq.l  #0,d0
    bset.l  d1,d0
    or.l  d0,_Sig_Ser

    movea.l  4,a6
    jsr  -372(a6)    ;GetMsg
    rts
_FC_setser2
    move.w  #2,28(a1)
    movea.l  4,a6
    jsr  -462(a6)
    rts
    ifnd  _Sig_Ser
    cnop  0,4

_Sig_Ser   dc.l 0
    endc
    endc

    ifd  _s_goset_c
    ifnd  _Sig_C
    cnop  0,4

_Sig_C    dc.l $1000
    endc

    endc

    ifd  _s_gosettimer
_s_settimer
    movea.l  _TimePort,a0
    moveq.l  #0,d1
    move.b  15(a0),d1
    moveq.l  #0,d0
    bset.l  d1,d0
    or.l  d0,_Sig_Time

    movea.l  4,a6
    jsr  -372(a6)    ;GetMsg

    move.l  _TimeReq,a1
    rts


_s_settimer2

    move.w  #9,28(a1)
    movea.l  4,a6
    jsr  -462(a6)    ;SendIO

    rts
    ifnd  _Sig_Time
    cnop  0,4
_Sig_Time  dc.l 0
    endc

    endc

