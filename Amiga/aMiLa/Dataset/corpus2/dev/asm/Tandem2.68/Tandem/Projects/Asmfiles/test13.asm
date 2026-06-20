* test finding of 680x0/68881 instructions

* 68000 all ok

 move ccr,d0
 move d0,ccr
 andi #20,ccr
 eori #20,ccr
 ori #20,ccr

* effectively priveleged - cause trap, or not used in Amiga
* ctrl/p finds all of these

 bkpt #7       ;(0)
 chk (a0),d0   ;(1)
 chk2 (a0),d0  ;(2)
 illegal       ;(3)
 trap #3       ;(4)
 trapcc #4     ;(5)
 trapv         ;(6)
 tas (a0)      ;(7) ;do not use in Amiga

* priveleged instructions

 andi #20,sr   ;1
 eori #20,sr   ;2
 move d0,sr    ;3
 move sr,d0    ;4  strictly, not priv in 68000, but treat as priv
 move usp,a1   ;5
 move a1,usp   ;6
 movec a0,sfc  ;7
 movec sfc,a0  ;8
 moves d0,(a0) ;9
 moves (a0),d0 ;10
 ori #20,sr    ;11
 reset         ;12
 rte           ;13
 stop #5       ;14

* MMU opcodes (n.b. Tandem does not assemble CALLM,RTM - 68020 only)

 pflush #7,#7        ;15
 pflusha             ;16
 ploadr #0,(a0)      ;17
 ploadw #0,(a0)      ;18
 pmove.d crp,(a0)    ;19
 pmovefd.d (a0),crp  ;20
 ptestr #0,(a5),#7   ;21
 ptestw #0,(a5),#7   ;22

* 68881 priveleged/exception causing opcodes

 frestore (a0)  ;23
 fsave (a0)     ;24
 ftrapeq        ;25
