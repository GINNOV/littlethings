  ;returned in d0:
  ;
  ;    00 : play/pause
  ;    01 : reverse
  ;    02 : forward
  ;    03 : green
  ;    04 : yellow
  ;    05 : red
  ;    06 : blue

readcd321
  ;
  lea $bfe001,a2
  lea $dff016,a1
  ;
  moveq #7,d3
  move
 #$4000,d4
  bset  d3,$200(a2)
  bclr  d3,(a2)
  move  #$2000,$dff034

 moveq #0,d0
  moveq #6,d1
.loop tst.b (a2)
  tst.b (a2)
  tst.b (a2)

 tst.b (a2)
  tst.b (a2)
  tst.b (a2)
  tst.b (a2)
  tst.b (a2)
  move
 (a1),d2
  bset  d3,(a2)
  bclr  d3,(a2)
  and d4,d2
  bne.s .skip
  bset
 d1,d0
.skip dbf d1,.loop
  move  #$3000,$dff034
  bclr  d3,$200(a2)
  ;

 rts

;
;readcd320
;  ;
;  lea $bfe001,a2
;  lea $dff016,a1
;  ;
;  moveq #6,d3
;
; move  #$400,d4
;  bset  d3,$200(a2)
;  bclr  d3,(a2)
;  move  #$f200,$dff034
;
; moveq #0,d0
;  moveq #6,d1
;.loop tst.b (a2)
;  tst.b (a2)
;  tst.b (a2)
;
; tst.b (a2)
;  tst.b (a2)
;  tst.b (a2)
;  tst.b (a2)
;  tst.b (a2)
;  move
; (a1),d2
;  bset  d3,(a2)
;  bclr  d3,(a2)
;  and d4,d2
;  bne.s .skip
;  bset
; d1,d0
;.skip dbf d1,.loop
;  move  #$f300,$dff034  ;#0
;  bclr  d3,$200(a2)
;
;
;  rts
