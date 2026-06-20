* test scanning for 68020+

* set prefs for rel .L not -> .W

Fred:
 divu.l d4,d3   ;1
 divs.l d4,d3   ;2
 divul d4,d3:d5 ;3
 divsl d4,d3:d5 ;4
 mulu.l d4,d3   ;5
 muls.l d4,d3   ;6
 bfchg d3{2:3}  ;7
 bftst d3{2:3}  ;8
 cas d1,d2,(a3) ;9
 cas2 d1:d2,d3:d4,(a4):(a3) ;10
 chk2 (a4),a1   ;11
 extb d3        ;12
 pack d3,d4,#5  ;13
 bcc.l Jim      ;14
 bsr.l Jim      ;15
 rtd #4         ;16
 rtr            ;17
 bkpt #3        ;18
 moves (a4),d3  ;19
 tst.l (Fred,a4,d3)  ;20
 tst.l ([1,a4],a3,1) ;21
 tst.l ([1,a4,a3],1) ;22
 tst.l (Fred.l,pc,d3)   ;23
 tst.l ([Fred,pc],a3,1) ;24
 tst.l ([Fred,pc,a3],1) ;25
Jim:
