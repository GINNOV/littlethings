* test sundry pseudo ops

 cargs #$20,fred.b,jim.b,joe,jill.w,helen.l,june
 cargs sarah,beth

 moveq #fred,d0  ;$20
 moveq #jim,d0   ;$21
 moveq #joe,d0   ;$22
 moveq #jill,d0  ;$24
 moveq #helen,d0 ;$26
 moveq #june,d0  ;$2A
 moveq #sarah,d0 ;$00
 moveq #beth,d0  ;$02

 rts

* fo,so,rs

 foval 10
z1: fo.b 1
z2: fo.b 2
z3: fo.b 0
z4: fo 1
z5: fo.l 1
 foset 30
z6: fo 1
 setfo 40
z7: fo 1
 foreset
z8: fo 1
 clrfo
z9: fo.l 2
zA: fo 1
 moveq #z1,d0   ;0A
 moveq #z2,d0   ;09
 moveq #z3,d0   ;07
 moveq #z4,d0   ;07
 moveq #z5,d0   ;05
 moveq #z6,d0   ;1E
 moveq #z7,d0   ;28
 moveq #z8,d0   ;00
 moveq #z9,d0   ;00
 moveq #zA,d0   ;F8

 soval 10
x1: so.b 1
x2: so.b 2
x3: so.b 0
x4: so 1
x5: so.l 1
 soset 30
x6: so 1
 setso 40
x7: so 1
 soreset
x8: so 1
 clrso
x9: so.l 2
xA: so 1
 moveq #x1,d0   ;0A
 moveq #x2,d0   ;0B
 moveq #x3,d0   ;0D
 moveq #x4,d0   ;0D
 moveq #x5,d0   ;0F
 moveq #x6,d0   ;1E
 moveq #x7,d0   ;28
 moveq #x8,d0   ;00
 moveq #x9,d0   ;00
 moveq #xA,d0   ;08

 rsval 10
y1: rs.b 1
y2: rs.b 2
y3: rs.b 0
y4: rs 1
y5: rs.l 1
 rsset 30
y6: rs 1
 setrs 40
y7: rs 1
 rsreset
y8: rs 1
 clrrs
y9: rs.l 2
yA: rs 1
 moveq #y1,d0   ;0A
 moveq #y2,d0   ;0B
 moveq #y3,d0   ;0D
 moveq #y4,d0   ;0D
 moveq #y5,d0   ;0F
 moveq #y6,d0   ;1E
 moveq #y7,d0   ;28
 moveq #y8,d0   ;00
 moveq #y9,d0   ;00
 moveq #yA,d0   ;08
